import {
  BadRequestException,
  Injectable,
  InternalServerErrorException,
  NotFoundException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { InjectRepository } from '@nestjs/typeorm';
import { createClient, SupabaseClient } from '@supabase/supabase-js';
import { Repository } from 'typeorm';
import { Course } from '../courses/entities/course.entity';
import { FileResponseDto } from '../files/dto/file-response.dto';
import { File } from '../files/entities/file.entity';
import { FilesService } from '../files/files.service';
import { CreateChapterDto, UpdateChapterDto } from './dto/chapter.dto';
import {
  CreateQuestionBankQuestionDto,
  QuestionBankQueryDto,
  UpdateQuestionBankQuestionDto,
} from './dto/question.dto';
import {
  QuestionBankStatus,
  QuestionBankType,
} from './enums/question-bank.enums';
import { CourseChapter } from './entities/course-chapter.entity';
import { QuestionBankFillBlank } from './entities/question-bank-fill-blank.entity';
import { QuestionBankOption } from './entities/question-bank-option.entity';
import { QuestionBankQuestion } from './entities/question-bank-question.entity';

@Injectable()
export class QuestionBankService {
  private readonly supabase: SupabaseClient;
  private readonly questionImagesBucketName: string;
  private readonly maxQuestionImageSize = 15 * 1024 * 1024;
  private readonly usePublicUrlsForQuestionImages: boolean;

  constructor(
    @InjectRepository(CourseChapter)
    private readonly chapterRepo: Repository<CourseChapter>,
    @InjectRepository(QuestionBankQuestion)
    private readonly questionRepo: Repository<QuestionBankQuestion>,
    @InjectRepository(QuestionBankOption)
    private readonly optionRepo: Repository<QuestionBankOption>,
    @InjectRepository(QuestionBankFillBlank)
    private readonly blankRepo: Repository<QuestionBankFillBlank>,
    @InjectRepository(Course)
    private readonly courseRepo: Repository<Course>,
    @InjectRepository(File)
    private readonly fileRepo: Repository<File>,
    private readonly filesService: FilesService,
    private readonly configService: ConfigService,
  ) {
    const supabaseUrl = this.configService.get<string>('SUPABASE_URL');
    const supabaseServiceRoleKey = this.configService.get<string>(
      'SUPABASE_SERVICE_ROLE_KEY',
    );
    this.questionImagesBucketName =
      this.configService.get<string>('SUPABASE_BUCKET_QUESTION_IMAGES') ||
      'question-images';
    this.usePublicUrlsForQuestionImages =
      this.configService.get<string>('SUPABASE_QUESTION_IMAGES_PUBLIC') ===
      'true';

    if (!supabaseUrl || !supabaseServiceRoleKey) {
      throw new Error(
        'SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY environment variables are required',
      );
    }

    this.supabase = createClient(supabaseUrl, supabaseServiceRoleKey);
  }

  async createChapter(
    courseId: number,
    dto: CreateChapterDto,
  ): Promise<CourseChapter> {
    await this.ensureCourseExists(courseId);
    const created = this.chapterRepo.create({ ...dto, courseId });
    return this.chapterRepo.save(created);
  }

  async listChapters(courseId: number): Promise<CourseChapter[]> {
    await this.ensureCourseExists(courseId);
    return this.chapterRepo.find({
      where: { courseId },
      order: { chapterOrder: 'ASC', id: 'ASC' },
    });
  }

  async updateChapter(
    courseId: number,
    chapterId: number,
    dto: UpdateChapterDto,
  ): Promise<CourseChapter> {
    const chapter = await this.chapterRepo.findOne({
      where: { id: chapterId, courseId },
    });
    if (!chapter) {
      throw new NotFoundException('Chapter not found');
    }
    Object.assign(chapter, dto);
    return this.chapterRepo.save(chapter);
  }

  async deleteChapter(courseId: number, chapterId: number): Promise<void> {
    const chapter = await this.chapterRepo.findOne({
      where: { id: chapterId, courseId },
    });
    if (!chapter) {
      throw new NotFoundException('Chapter not found');
    }
    await this.chapterRepo.remove(chapter);
  }

  async uploadQuestionImage(
    userId: number,
    file: Express.Multer.File,
  ): Promise<FileResponseDto> {
    this.validateQuestionImage(file);

    const uploadedFile = await this.filesService.uploadFile(file, userId);
    const storagePath = this.buildQuestionImageStoragePath(
      uploadedFile.fileId,
      file.mimetype,
    );

    const { error: uploadError } = await this.supabase.storage
      .from(this.questionImagesBucketName)
      .upload(storagePath, file.buffer, {
        contentType: file.mimetype,
        upsert: true,
      });

    if (uploadError) {
      throw new InternalServerErrorException(
        `Failed to upload question image: ${uploadError.message}`,
      );
    }

    const imageUrl = await this.createQuestionImageUrl(storagePath);

    return {
      ...uploadedFile,
      imageUrl,
    } as FileResponseDto;
  }

  async createQuestion(
    dto: CreateQuestionBankQuestionDto,
    userId: number,
  ): Promise<QuestionBankQuestion> {
    await this.ensureCourseExists(dto.courseId);
    await this.ensureChapterExists(dto.courseId, dto.chapterId);
    if (dto.questionFileId) {
      await this.ensureFileExists(dto.questionFileId);
    }
    this.validateQuestionPayload(dto);

    const question = this.questionRepo.create({
      courseId: dto.courseId,
      chapterId: dto.chapterId,
      questionType: dto.questionType,
      difficulty: dto.difficulty,
      bloomLevel: dto.bloomLevel,
      status: dto.status || QuestionBankStatus.DRAFT,
      questionText: dto.questionText || null,
      questionFileId: dto.questionFileId || null,
      expectedAnswerText: dto.expectedAnswerText || null,
      hints: dto.hints || null,
      createdBy: userId,
      updatedBy: userId,
    });

    const saved = await this.questionRepo.save(question);
    await this.replaceQuestionChildren(saved.id, dto);
    return this.findQuestionById(saved.id);
  }

  async listQuestions(
    query: QuestionBankQueryDto,
  ): Promise<{ data: QuestionBankQuestion[]; total: number }> {
    const page = query.page || 1;
    const limit = query.limit || 20;
    const qb = this.questionRepo
      .createQueryBuilder('q')
      .leftJoinAndSelect('q.options', 'options')
      .leftJoinAndSelect('q.fillBlanks', 'fillBlanks')
      .leftJoinAndSelect('q.chapter', 'chapter')
      .leftJoinAndSelect('q.file', 'file');

    if (query.courseId)
      qb.andWhere('q.courseId = :courseId', { courseId: query.courseId });
    if (query.chapterId)
      qb.andWhere('q.chapterId = :chapterId', { chapterId: query.chapterId });
    if (query.questionType)
      qb.andWhere('q.questionType = :questionType', {
        questionType: query.questionType,
      });
    if (query.difficulty)
      qb.andWhere('q.difficulty = :difficulty', {
        difficulty: query.difficulty,
      });
    if (query.bloomLevel)
      qb.andWhere('q.bloomLevel = :bloomLevel', {
        bloomLevel: query.bloomLevel,
      });
    if (query.status)
      qb.andWhere('q.status = :status', { status: query.status });

    qb.orderBy('q.createdAt', 'DESC')
      .skip((page - 1) * limit)
      .take(limit);
    const [data, total] = await qb.getManyAndCount();
    const withImageUrls = await this.attachQuestionImageUrls(data);
    return { data: withImageUrls, total };
  }

  async findQuestionById(questionId: number): Promise<QuestionBankQuestion> {
    const question = await this.questionRepo.findOne({
      where: { id: questionId },
      relations: ['options', 'fillBlanks', 'chapter', 'file'],
    });
    if (!question) {
      throw new NotFoundException('Question not found');
    }
    const [withImageUrl] = await this.attachQuestionImageUrls([question]);
    return withImageUrl;
  }

  async updateQuestion(
    questionId: number,
    dto: UpdateQuestionBankQuestionDto,
    userId: number,
  ): Promise<QuestionBankQuestion> {
    const question = await this.findQuestionById(questionId);
    if (dto.chapterId) {
      await this.ensureChapterExists(question.courseId, dto.chapterId);
    }
    if (dto.questionFileId) {
      await this.ensureFileExists(dto.questionFileId);
    }

    const merged = {
      ...question,
      ...dto,
      questionText:
        dto.questionText === undefined
          ? question.questionText
          : dto.questionText || null,
      questionFileId:
        dto.questionFileId === undefined
          ? question.questionFileId
          : dto.questionFileId || null,
      expectedAnswerText:
        dto.expectedAnswerText === undefined
          ? question.expectedAnswerText
          : dto.expectedAnswerText || null,
      hints: dto.hints === undefined ? question.hints : dto.hints || null,
      updatedBy: userId,
    } as CreateQuestionBankQuestionDto;

    this.validateQuestionPayload(merged);
    await this.questionRepo.save({
      id: question.id,
      chapterId: dto.chapterId ?? question.chapterId,
      questionType: dto.questionType ?? question.questionType,
      difficulty: dto.difficulty ?? question.difficulty,
      bloomLevel: dto.bloomLevel ?? question.bloomLevel,
      questionText:
        dto.questionText === undefined
          ? question.questionText
          : dto.questionText || null,
      questionFileId:
        dto.questionFileId === undefined
          ? question.questionFileId
          : dto.questionFileId || null,
      expectedAnswerText:
        dto.expectedAnswerText === undefined
          ? question.expectedAnswerText
          : dto.expectedAnswerText || null,
      hints: dto.hints === undefined ? question.hints : dto.hints || null,
      status: dto.status ?? question.status,
      updatedBy: userId,
    });
    await this.replaceQuestionChildren(question.id, merged, dto);
    return this.findQuestionById(question.id);
  }

  async deleteQuestion(questionId: number): Promise<void> {
    const question = await this.findQuestionById(questionId);
    await this.questionRepo.remove(question);
  }

  private async replaceQuestionChildren(
    questionId: number,
    source: CreateQuestionBankQuestionDto,
    patch?: UpdateQuestionBankQuestionDto,
  ): Promise<void> {
    if (patch?.options !== undefined || source.options !== undefined) {
      await this.optionRepo.delete({ questionId });
      if (source.options?.length) {
        const options = source.options.map((option, index) =>
          this.optionRepo.create({
            questionId,
            optionText: option.optionText,
            isCorrect: option.isCorrect ? 1 : 0,
            optionOrder: index,
          }),
        );
        await this.optionRepo.save(options);
      }
    }

    if (patch?.fillBlanks !== undefined || source.fillBlanks !== undefined) {
      await this.blankRepo.delete({ questionId });
      if (source.fillBlanks?.length) {
        const blanks = source.fillBlanks.map((blank) =>
          this.blankRepo.create({
            questionId,
            blankKey: blank.blankKey,
            acceptableAnswer: blank.acceptableAnswer,
            isCaseSensitive: blank.isCaseSensitive ? 1 : 0,
          }),
        );
        await this.blankRepo.save(blanks);
      }
    }
  }

  private validateQuestionPayload(
    payload: CreateQuestionBankQuestionDto | UpdateQuestionBankQuestionDto,
  ): void {
    const hasText = !!payload.questionText?.trim();
    const hasFile = !!payload.questionFileId;
    if (!hasText && !hasFile) {
      throw new BadRequestException(
        'Either questionText or questionFileId is required',
      );
    }

    if (payload.questionType === QuestionBankType.MCQ) {
      if (!payload.options || payload.options.length < 2) {
        throw new BadRequestException(
          'MCQ questions require at least 2 options',
        );
      }
      const correctCount = payload.options.filter(
        (option) => option.isCorrect,
      ).length;
      if (correctCount < 1) {
        throw new BadRequestException(
          'MCQ questions require at least one correct option',
        );
      }
    }

    if (payload.questionType === QuestionBankType.TRUE_FALSE) {
      if (!payload.options || payload.options.length !== 2) {
        throw new BadRequestException(
          'True/False questions require exactly 2 options',
        );
      }
      const correctCount = payload.options.filter(
        (option) => option.isCorrect,
      ).length;
      if (correctCount !== 1) {
        throw new BadRequestException(
          'True/False questions require exactly one correct option',
        );
      }
    }

    if (payload.questionType === QuestionBankType.FILL_BLANKS) {
      if (!payload.fillBlanks || payload.fillBlanks.length < 1) {
        throw new BadRequestException(
          'Fill in the blanks questions require at least one blank answer',
        );
      }
    }

    if (
      payload.questionType === QuestionBankType.WRITTEN ||
      payload.questionType === QuestionBankType.ESSAY
    ) {
      if (!payload.expectedAnswerText?.trim()) {
        throw new BadRequestException(
          'Written/Essay questions require expectedAnswerText',
        );
      }
    }
  }

  private async ensureCourseExists(courseId: number): Promise<void> {
    const exists = await this.courseRepo.exist({ where: { id: courseId } });
    if (!exists) {
      throw new NotFoundException('Course not found');
    }
  }

  private async ensureChapterExists(
    courseId: number,
    chapterId: number,
  ): Promise<void> {
    const exists = await this.chapterRepo.exist({
      where: { id: chapterId, courseId },
    });
    if (!exists) {
      throw new NotFoundException('Chapter not found for this course');
    }
  }

  private async ensureFileExists(fileId: number): Promise<void> {
    const exists = await this.fileRepo.exist({ where: { fileId } });
    if (!exists) {
      throw new NotFoundException('File not found');
    }
  }

  private validateQuestionImage(file?: Express.Multer.File): void {
    if (!file) {
      throw new BadRequestException('Question image file is required');
    }

    if (file.size <= 0 || file.size > this.maxQuestionImageSize) {
      const maxMb = this.maxQuestionImageSize / (1024 * 1024);
      throw new BadRequestException(
        `Invalid question image size. Maximum allowed size is ${maxMb} MB`,
      );
    }

    const allowedMimeTypes = new Set([
      'image/jpeg',
      'image/png',
      'image/webp',
      'image/gif',
    ]);
    if (!allowedMimeTypes.has(file.mimetype)) {
      throw new BadRequestException(
        `Unsupported image type: ${file.mimetype}. Allowed: image/jpeg, image/png, image/webp, image/gif`,
      );
    }
  }

  private getExtensionFromMimeType(mimeType: string): string {
    switch (mimeType) {
      case 'image/jpeg':
        return 'jpg';
      case 'image/png':
        return 'png';
      case 'image/webp':
        return 'webp';
      case 'image/gif':
        return 'gif';
      default:
        return 'jpg';
    }
  }

  private async attachQuestionImageUrls(
    questions: QuestionBankQuestion[],
  ): Promise<QuestionBankQuestion[]> {
    const questionPathPairs = questions
      .map((question) => {
        const file = question.file;
        if (!file) return null;
        const storagePath = this.buildQuestionImageStoragePath(
          Number(file.fileId),
          file.mimeType || undefined,
        );
        return { questionId: question.id, storagePath };
      })
      .filter(
        (
          pair,
        ): pair is {
          questionId: number;
          storagePath: string;
        } => !!pair,
      );

    const storagePaths = questionPathPairs.map((pair) => pair.storagePath);
    const pathByQuestionId = new Map(
      questionPathPairs.map((pair) => [pair.questionId, pair.storagePath]),
    );

    const urlMap = await this.createQuestionImageUrls(storagePaths);

    return questions.map((question) => {
      const storagePath = pathByQuestionId.get(question.id);
      (question as any).questionImageUrl = storagePath
        ? (urlMap.get(storagePath) ?? null)
        : null;
      return question;
    });
  }

  private async createQuestionImageUrls(
    storagePaths: string[],
  ): Promise<Map<string, string | null>> {
    if (!storagePaths.length) {
      return new Map();
    }

    if (this.usePublicUrlsForQuestionImages) {
      const map = new Map<string, string | null>();
      for (const storagePath of storagePaths) {
        const { data } = this.supabase.storage
          .from(this.questionImagesBucketName)
          .getPublicUrl(storagePath);
        map.set(storagePath, data.publicUrl || null);
      }
      return map;
    }

    const uniquePaths = Array.from(new Set(storagePaths));
    const { data, error } = await this.supabase.storage
      .from(this.questionImagesBucketName)
      .createSignedUrls(uniquePaths, 60 * 60);

    if (error || !data) {
      return new Map(uniquePaths.map((path) => [path, null]));
    }

    const byPath = new Map<string, string | null>();
    data.forEach((item) => {
      if (item.path) {
        byPath.set(item.path, item.signedUrl || null);
      }
    });

    uniquePaths.forEach((path) => {
      if (!byPath.has(path)) {
        byPath.set(path, null);
      }
    });

    return byPath;
  }

  private async createQuestionImageUrl(
    storagePath: string,
  ): Promise<string | null> {
    const urlMap = await this.createQuestionImageUrls([storagePath]);
    return urlMap.get(storagePath) ?? null;
  }

  private buildQuestionImageStoragePath(
    fileId: number,
    mimeType?: string,
  ): string {
    const extension = this.getExtensionFromMimeType(mimeType || 'image/jpeg');
    return `question-bank/files/${fileId}.${extension}`;
  }
}
