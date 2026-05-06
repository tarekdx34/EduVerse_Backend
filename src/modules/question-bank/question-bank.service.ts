import {
  BadRequestException,
  ForbiddenException,
  HttpException,
  Injectable,
  InternalServerErrorException,
  Logger,
  NotFoundException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { InjectRepository } from '@nestjs/typeorm';
import { createClient, SupabaseClient } from '@supabase/supabase-js';
import { DataSource, EntityManager, In, Repository } from 'typeorm';
import { Course } from '../courses/entities/course.entity';
import { FileResponseDto } from '../files/dto/file-response.dto';
import {
  FilePermission,
  PermissionType,
} from '../files/entities/file-permission.entity';
import { File } from '../files/entities/file.entity';
import { FilesService } from '../files/files.service';
import { CreateChapterDto, UpdateChapterDto } from './dto/chapter.dto';
import {
  CreateQuestionAttachmentDto,
  ReorderQuestionAttachmentsDto,
  UpdateQuestionAttachmentDto,
  UploadQuestionAttachmentMetadataDto,
} from './dto/question-attachment.dto';
import { BulkCreateQuestionBankQuestionsDto } from './dto/question-bulk.dto';
import {
  BatchCreateGroupedQuestionsDto,
  CreateQuestionGroupDto,
  LinkQuestionGroupQuestionsDto,
  QuestionGroupQueryDto,
  ReorderQuestionGroupItemsDto,
  UpdateQuestionGroupDto,
} from './dto/question-group.dto';
import {
  BatchQuestionStatusDto,
  CreateQuestionBankQuestionDto,
  QuestionBankBatchStatusAction,
  QuestionBankQueryDto,
  UpdateQuestionBankQuestionDto,
} from './dto/question.dto';
import { QuestionBankPrivateResponseDto } from './dto/question-response.dto';
import { CourseChapter } from './entities/course-chapter.entity';
import { QuestionBankFillBlank } from './entities/question-bank-fill-blank.entity';
import { QuestionBankOption } from './entities/question-bank-option.entity';
import {
  QuestionAttachmentType,
  QuestionBankQuestionAttachment,
} from './entities/question-bank-question-attachment.entity';
import { QuestionBankQuestionGroupItem } from './entities/question-bank-question-group-item.entity';
import { QuestionBankQuestionGroup } from './entities/question-bank-question-group.entity';
import { QuestionBankQuestionVersion } from './entities/question-bank-question-version.entity';
import { QuestionBankQuestion } from './entities/question-bank-question.entity';
import { QuestionBankReviewEvent } from './entities/question-bank-review-event.entity';
import {
  QuestionBankStatus,
  QuestionBankType,
} from './enums/question-bank.enums';
import { InstructorCourseAccessService } from './services/instructor-course-access.service';

@Injectable()
export class QuestionBankService {
  private readonly logger = new Logger(QuestionBankService.name);
  private readonly supabase: SupabaseClient;
  private readonly questionImagesBucketName: string;
  private readonly maxQuestionImageSize = 15 * 1024 * 1024;
  private readonly usePublicUrlsForQuestionImages: boolean;
  private questionImagesBucketReady = false;

  constructor(
    private readonly dataSource: DataSource,
    @InjectRepository(CourseChapter)
    private readonly chapterRepo: Repository<CourseChapter>,
    @InjectRepository(QuestionBankQuestion)
    private readonly questionRepo: Repository<QuestionBankQuestion>,
    @InjectRepository(QuestionBankQuestionAttachment)
    private readonly attachmentRepo: Repository<QuestionBankQuestionAttachment>,
    @InjectRepository(QuestionBankQuestionGroup)
    private readonly groupRepo: Repository<QuestionBankQuestionGroup>,
    @InjectRepository(QuestionBankQuestionGroupItem)
    private readonly groupItemRepo: Repository<QuestionBankQuestionGroupItem>,
    @InjectRepository(QuestionBankQuestionVersion)
    private readonly versionRepo: Repository<QuestionBankQuestionVersion>,
    @InjectRepository(QuestionBankReviewEvent)
    private readonly reviewEventRepo: Repository<QuestionBankReviewEvent>,
    @InjectRepository(QuestionBankOption)
    private readonly optionRepo: Repository<QuestionBankOption>,
    @InjectRepository(QuestionBankFillBlank)
    private readonly blankRepo: Repository<QuestionBankFillBlank>,
    @InjectRepository(Course)
    private readonly courseRepo: Repository<Course>,
    @InjectRepository(File)
    private readonly fileRepo: Repository<File>,
    @InjectRepository(FilePermission)
    private readonly filePermissionRepo: Repository<FilePermission>,
    private readonly filesService: FilesService,
    private readonly configService: ConfigService,
    private readonly instructorCourseAccess: InstructorCourseAccessService,
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
    userId: number,
  ): Promise<CourseChapter> {
    await this.instructorCourseAccess.assertInstructorOwnsCourse(
      userId,
      courseId,
    );
    const chapterOrder =
      dto.chapterOrder ?? (await this.getNextChapterOrder(courseId));
    const created = this.chapterRepo.create({
      ...dto,
      chapterOrder,
      courseId,
    });
    return this.chapterRepo.save(created);
  }

  async listChapters(
    courseId: number,
    userId: number,
  ): Promise<CourseChapter[]> {
    await this.instructorCourseAccess.assertInstructorOwnsCourse(
      userId,
      courseId,
    );
    return this.chapterRepo.find({
      where: { courseId },
      order: { chapterOrder: 'ASC', id: 'ASC' },
    });
  }

  async updateChapter(
    courseId: number,
    chapterId: number,
    dto: UpdateChapterDto,
    userId: number,
  ): Promise<CourseChapter> {
    await this.instructorCourseAccess.assertInstructorOwnsCourse(
      userId,
      courseId,
    );
    const chapter = await this.chapterRepo.findOne({
      where: { id: chapterId, courseId },
    });
    if (!chapter) {
      throw new NotFoundException('Chapter not found');
    }
    Object.assign(chapter, dto);
    return this.chapterRepo.save(chapter);
  }

  async deleteChapter(
    courseId: number,
    chapterId: number,
    userId: number,
  ): Promise<void> {
    await this.instructorCourseAccess.assertInstructorOwnsCourse(
      userId,
      courseId,
    );
    const chapter = await this.chapterRepo.findOne({
      where: { id: chapterId, courseId },
    });
    if (!chapter) {
      throw new NotFoundException('Chapter not found');
    }
    const questionCount = await this.questionRepo.count({
      where: { courseId, chapterId },
      withDeleted: true,
    });
    if (questionCount > 0) {
      throw new BadRequestException(
        'Chapter cannot be deleted because it has questions. Deactivate or move the questions first.',
      );
    }
    await this.chapterRepo.remove(chapter);
  }

  async uploadQuestionImage(
    userId: number,
    file: Express.Multer.File,
  ): Promise<FileResponseDto> {
    this.validateQuestionImage(file);
    await this.ensureQuestionImagesBucketExists();

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
      await this.cleanupFailedQuestionImageUpload(uploadedFile.fileId, userId);
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

  async uploadQuestionGroupImage(
    userId: number,
    file: Express.Multer.File,
  ): Promise<FileResponseDto> {
    return this.uploadQuestionImage(userId, file);
  }

  async createQuestion(
    dto: CreateQuestionBankQuestionDto,
    userId: number,
  ): Promise<QuestionBankQuestion> {
    await this.instructorCourseAccess.assertInstructorOwnsCourse(
      userId,
      dto.courseId,
    );
    if (dto.chapterId) {
      await this.ensureChapterExists(dto.courseId, dto.chapterId);
    }
    if (dto.questionFileId) {
      await this.ensureAttachableFile(
        dto.questionFileId,
        userId,
        QuestionAttachmentType.IMAGE,
      );
    }
    await this.ensureQuestionAttachmentFiles(dto.attachments, userId);
    this.validateQuestionPayload(dto);

    const questionId = await this.dataSource.transaction(async (manager) => {
      const question = manager.create(QuestionBankQuestion, {
        courseId: dto.courseId,
        chapterId: dto.chapterId,
        questionType: dto.questionType,
        difficulty: dto.difficulty,
        bloomLevel: dto.bloomLevel,
        status: dto.status || QuestionBankStatus.DRAFT,
        questionText: dto.questionText || null,
        questionFileId: dto.questionFileId || null,
        questionFileCaption: dto.questionFileCaption || null,
        questionFileAltText: dto.questionFileAltText || null,
        expectedAnswerText: dto.expectedAnswerText || null,
        hints: dto.hints || null,
        createdBy: userId,
        updatedBy: userId,
      });

      const saved = await manager.save(question);
      await this.replaceQuestionChildren(manager, saved.id, dto);
      await this.createInitialQuestionAttachments(
        manager,
        saved.id,
        dto.attachments,
        userId,
      );
      await this.createQuestionVersion(manager, saved.id, userId);
      return saved.id;
    });

    return this.findQuestionById(questionId, userId);
  }

  async bulkCreateQuestions(
    dto: BulkCreateQuestionBankQuestionsDto,
    userId: number,
  ): Promise<{
    created: QuestionBankQuestion[];
    count: number;
    failed: Array<{ rowIndex: number; message: string }>;
    failedCount: number;
  }> {
    if (!dto.questions.length) {
      throw new BadRequestException('At least one question is required');
    }
    await this.instructorCourseAccess.assertInstructorOwnsCourse(
      userId,
      dto.courseId,
    );

    const created: QuestionBankQuestion[] = [];
    const failed: Array<{ rowIndex: number; message: string }> = [];

    for (const [index, question] of dto.questions.entries()) {
      const questionDto: CreateQuestionBankQuestionDto = {
        ...question,
        courseId: dto.courseId,
        chapterId: question.chapterId || dto.defaultChapterId || 0,
      };
      try {
        if (!questionDto.chapterId) {
          throw new BadRequestException(
            'Each question requires chapterId or defaultChapterId',
          );
        }
        const saved = await this.createQuestion(questionDto, userId);
        created.push(saved);
      } catch (error) {
        failed.push({
          rowIndex: index,
          message: this.resolveBatchFailureMessage(error),
        });
      }
    }

    return {
      created,
      count: created.length,
      failed,
      failedCount: failed.length,
    };
  }

  async getChapterQuestionCounts(
    courseId: number,
    userId: number,
  ): Promise<Array<{ chapterId: number; total: number }>> {
    await this.instructorCourseAccess.assertInstructorOwnsCourse(
      userId,
      courseId,
    );
    const rows = (await this.questionRepo
      .createQueryBuilder('question')
      .select('question.chapterId', 'chapterId')
      .addSelect('COUNT(question.id)', 'total')
      .where('question.courseId = :courseId', { courseId })
      .groupBy('question.chapterId')
      .getRawMany()) as Array<{ chapterId: string | number; total: string }>;
    return rows.map((row) => ({
      chapterId: Number(row.chapterId),
      total: Number(row.total || 0),
    }));
  }

  async listQuestions(
    query: QuestionBankQueryDto,
    userId: number,
  ): Promise<{ data: QuestionBankQuestion[]; total: number }> {
    const page = query.page || 1;
    const limit = query.limit || 20;
    let courseIds: number[];

    if (query.courseId) {
      await this.instructorCourseAccess.assertInstructorOwnsCourse(
        userId,
        query.courseId,
      );
      courseIds = [query.courseId];
    } else {
      courseIds =
        await this.instructorCourseAccess.getInstructorCourseIds(userId);
      if (!courseIds.length) {
        return { data: [], total: 0 };
      }
    }

    const qb = this.questionRepo
      .createQueryBuilder('q')
      .leftJoinAndSelect('q.options', 'options')
      .leftJoinAndSelect('q.fillBlanks', 'fillBlanks')
      .leftJoinAndSelect('q.chapter', 'chapter')
      .leftJoinAndSelect('q.file', 'file')
      .leftJoinAndSelect('q.attachments', 'attachments')
      .leftJoinAndSelect('attachments.file', 'attachmentFile')
      .leftJoinAndSelect('q.groupItems', 'questionGroupItems')
      .leftJoinAndSelect('questionGroupItems.group', 'questionGroup')
      .where('q.courseId IN (:...courseIds)', { courseIds });

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
    if (query.search?.trim()) {
      qb.andWhere('LOWER(q.questionText) LIKE :search', {
        search: `%${query.search.trim().toLowerCase()}%`,
      });
    }
    const hasAttachments = this.parseOptionalBoolean(query.hasAttachments);
    if (hasAttachments === true) {
      qb.andWhere(
        `EXISTS (
          SELECT 1
          FROM question_bank_question_attachments qa
          WHERE qa.question_id = q.question_id
            AND qa.deleted_at IS NULL
        )`,
      );
    }
    if (hasAttachments === false) {
      qb.andWhere(
        `NOT EXISTS (
          SELECT 1
          FROM question_bank_question_attachments qa
          WHERE qa.question_id = q.question_id
            AND qa.deleted_at IS NULL
        )`,
      );
    }
    if (query.groupId) {
      qb.andWhere('questionGroupItems.groupId = :groupId', {
        groupId: query.groupId,
      });
    }
    if (query.createdBy) {
      qb.andWhere('q.createdBy = :createdBy', { createdBy: query.createdBy });
    }

    if (query.groupId) {
      qb.orderBy('questionGroupItems.itemOrder', 'ASC').addOrderBy(
        'q.id',
        'ASC',
      );
    } else {
      qb.orderBy('q.createdAt', 'DESC');
    }
    qb.addOrderBy('attachments.displayOrder', 'ASC')
      .skip((page - 1) * limit)
      .take(limit);
    const [data, total] = await qb.getManyAndCount();
    const withImageUrls = await this.attachQuestionImageUrls(data);
    return { data: withImageUrls, total };
  }

  async getQuestionStats(
    query: QuestionBankQueryDto,
    userId: number,
  ): Promise<{
    total: number;
    draft: number;
    underReview: number;
    approved: number;
    rejected: number;
    archived: number;
    attached: number;
    grouped: number;
  }> {
    let courseIds: number[];

    if (query.courseId) {
      await this.instructorCourseAccess.assertInstructorOwnsCourse(
        userId,
        query.courseId,
      );
      courseIds = [query.courseId];
    } else {
      courseIds =
        await this.instructorCourseAccess.getInstructorCourseIds(userId);
      if (!courseIds.length) {
        return {
          total: 0,
          draft: 0,
          underReview: 0,
          approved: 0,
          rejected: 0,
          archived: 0,
          attached: 0,
          grouped: 0,
        };
      }
    }

    const qb = this.questionRepo
      .createQueryBuilder('q')
      .select('COUNT(DISTINCT q.id)', 'total')
      .addSelect(
        "COUNT(DISTINCT CASE WHEN q.status = 'draft' THEN q.id END)",
        'draft',
      )
      .addSelect(
        "COUNT(DISTINCT CASE WHEN q.status = 'under_review' THEN q.id END)",
        'underReview',
      )
      .addSelect(
        "COUNT(DISTINCT CASE WHEN q.status = 'approved' THEN q.id END)",
        'approved',
      )
      .addSelect(
        "COUNT(DISTINCT CASE WHEN q.status = 'rejected' THEN q.id END)",
        'rejected',
      )
      .addSelect(
        "COUNT(DISTINCT CASE WHEN q.status = 'archived' THEN q.id END)",
        'archived',
      )
      .addSelect(
        `COUNT(DISTINCT CASE WHEN EXISTS (
          SELECT 1
          FROM question_bank_question_attachments qa
          WHERE qa.question_id = q.question_id
            AND qa.deleted_at IS NULL
        ) THEN q.id END)`,
        'attached',
      )
      .addSelect(
        `COUNT(DISTINCT CASE WHEN EXISTS (
          SELECT 1
          FROM question_bank_question_group_items qgi
          WHERE qgi.question_id = q.question_id
        ) THEN q.id END)`,
        'grouped',
      )
      .leftJoin('q.groupItems', 'questionGroupItems')
      .where('q.courseId IN (:...courseIds)', { courseIds });

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
    if (query.search?.trim()) {
      qb.andWhere('LOWER(q.questionText) LIKE :search', {
        search: `%${query.search.trim().toLowerCase()}%`,
      });
    }
    const hasAttachments = this.parseOptionalBoolean(query.hasAttachments);
    if (hasAttachments === true) {
      qb.andWhere(
        `EXISTS (
          SELECT 1
          FROM question_bank_question_attachments qa
          WHERE qa.question_id = q.question_id
            AND qa.deleted_at IS NULL
        )`,
      );
    }
    if (hasAttachments === false) {
      qb.andWhere(
        `NOT EXISTS (
          SELECT 1
          FROM question_bank_question_attachments qa
          WHERE qa.question_id = q.question_id
            AND qa.deleted_at IS NULL
        )`,
      );
    }
    if (query.groupId) {
      qb.andWhere('questionGroupItems.groupId = :groupId', {
        groupId: query.groupId,
      });
    }
    if (query.createdBy) {
      qb.andWhere('q.createdBy = :createdBy', { createdBy: query.createdBy });
    }

    const row = await qb.getRawOne<Record<string, string | number | null>>();
    return {
      total: Number(row?.total || 0),
      draft: Number(row?.draft || 0),
      underReview: Number(row?.underReview || 0),
      approved: Number(row?.approved || 0),
      rejected: Number(row?.rejected || 0),
      archived: Number(row?.archived || 0),
      attached: Number(row?.attached || 0),
      grouped: Number(row?.grouped || 0),
    };
  }

  async findQuestionById(
    questionId: number,
    userId: number,
  ): Promise<QuestionBankQuestion> {
    const question = await this.questionRepo.findOne({
      where: { id: questionId },
      relations: [
        'options',
        'fillBlanks',
        'chapter',
        'file',
        'attachments',
        'attachments.file',
        'groupItems',
        'groupItems.group',
      ],
    });
    if (!question) {
      throw new NotFoundException('Question not found');
    }
    await this.instructorCourseAccess.assertInstructorOwnsCourse(
      userId,
      question.courseId,
    );
    const [withImageUrl] = await this.attachQuestionImageUrls([question]);
    return withImageUrl;
  }

  async updateQuestion(
    questionId: number,
    dto: UpdateQuestionBankQuestionDto,
    userId: number,
  ): Promise<QuestionBankQuestion> {
    const question = await this.findQuestionById(questionId, userId);
    if (dto.chapterId) {
      await this.ensureChapterExists(question.courseId, dto.chapterId);
    }
    if (dto.questionFileId) {
      await this.ensureAttachableFile(
        dto.questionFileId,
        userId,
        QuestionAttachmentType.IMAGE,
        question,
      );
    }
    const shouldResetApprovedStatus =
      question.status === QuestionBankStatus.APPROVED &&
      dto.status === undefined &&
      this.isMeaningfulQuestionUpdate(dto);

    const merged = {
      courseId: question.courseId,
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
      questionFileCaption:
        dto.questionFileCaption === undefined
          ? question.questionFileCaption
          : dto.questionFileCaption || null,
      questionFileAltText:
        dto.questionFileAltText === undefined
          ? question.questionFileAltText
          : dto.questionFileAltText || null,
      expectedAnswerText:
        dto.expectedAnswerText === undefined
          ? question.expectedAnswerText
          : dto.expectedAnswerText || null,
      hints: dto.hints === undefined ? question.hints : dto.hints || null,
      status: dto.status ?? (shouldResetApprovedStatus
        ? QuestionBankStatus.DRAFT
        : question.status),
      options:
        dto.options !== undefined
          ? dto.options
          : this.shouldKeepExistingOptions(
                question.questionType,
                dto.questionType,
              )
            ? this.toOptionDtos(question.options || [])
            : undefined,
      fillBlanks:
        dto.fillBlanks !== undefined
          ? dto.fillBlanks
          : this.shouldKeepExistingFillBlanks(
                question.questionType,
                dto.questionType,
              )
            ? this.toFillBlankDtos(question.fillBlanks || [])
            : undefined,
    } as CreateQuestionBankQuestionDto;

    this.validateQuestionPayload(merged);
    await this.dataSource.transaction(async (manager) => {
      await this.createQuestionVersionFromSnapshot(
        manager,
        question.id,
        userId,
        this.buildQuestionSnapshot(question),
      );
      await manager.update(QuestionBankQuestion, question.id, {
        chapterId: merged.chapterId,
        questionType: merged.questionType,
        difficulty: merged.difficulty,
        bloomLevel: merged.bloomLevel,
        questionText: merged.questionText,
        questionFileId: merged.questionFileId,
        questionFileCaption: merged.questionFileCaption || null,
        questionFileAltText: merged.questionFileAltText || null,
        expectedAnswerText: merged.expectedAnswerText,
        hints: merged.hints,
        status: merged.status,
        updatedBy: userId,
      });
      await this.replaceQuestionChildren(
        manager,
        question.id,
        merged,
        dto,
        dto.questionType !== undefined &&
          dto.questionType !== question.questionType,
      );
      if (shouldResetApprovedStatus) {
        await this.createReviewEvent(
          manager,
          question.id,
          question.status,
          QuestionBankStatus.DRAFT,
          userId,
          'Question content changed; approval is required again.',
        );
      }
      await this.createQuestionVersion(manager, question.id, userId);
    });

    return this.findQuestionById(question.id, userId);
  }

  async deleteQuestion(questionId: number, userId: number): Promise<void> {
    const question = await this.findQuestionById(questionId, userId);
    await this.questionRepo.update(question.id, {
      status: QuestionBankStatus.ARCHIVED,
      updatedBy: userId,
    });
    await this.questionRepo.softDelete(question.id);
  }

  async restoreQuestion(
    questionId: number,
    userId: number,
    comment?: string,
  ): Promise<QuestionBankQuestion> {
    const question = await this.questionRepo.findOne({
      where: { id: questionId },
      withDeleted: true,
    });
    if (!question) {
      throw new NotFoundException('Question not found');
    }
    await this.instructorCourseAccess.assertInstructorOwnsCourse(
      userId,
      question.courseId,
    );

    await this.dataSource.transaction(async (manager) => {
      await manager.restore(QuestionBankQuestion, question.id);
      await manager.update(QuestionBankQuestion, question.id, {
        status: QuestionBankStatus.DRAFT,
        reviewedBy: userId,
        reviewedAt: new Date(),
        reviewComment: comment || 'Restored',
        updatedBy: userId,
      });
      await manager.save(
        manager.create(QuestionBankReviewEvent, {
          questionId: question.id,
          fromStatus: question.status,
          toStatus: QuestionBankStatus.DRAFT,
          comment: comment || 'Restored',
          createdBy: userId,
        }),
      );
      await this.createQuestionVersion(manager, question.id, userId);
    });

    return this.findQuestionById(question.id, userId);
  }

  async addQuestionAttachment(
    questionId: number,
    dto: CreateQuestionAttachmentDto,
    userId: number,
  ): Promise<QuestionBankQuestionAttachment> {
    const question = await this.findQuestionById(questionId, userId);
    const file = await this.ensureAttachableFile(
      dto.fileId,
      userId,
      dto.attachmentType || QuestionAttachmentType.IMAGE,
      question,
    );
    const displayOrder =
      dto.displayOrder ??
      (await this.getNextAttachmentDisplayOrder(questionId));

    return this.dataSource.transaction(async (manager) => {
      await manager
        .createQueryBuilder()
        .update(QuestionBankQuestionAttachment)
        .set({ displayOrder: () => 'display_order + 1' })
        .where('question_id = :questionId', { questionId: question.id })
        .andWhere('display_order >= :displayOrder', { displayOrder })
        .execute();

      if (dto.isPrimary) {
        await manager.update(
          QuestionBankQuestionAttachment,
          { questionId: question.id },
          { isPrimary: 0 },
        );
      }

      const saved = await manager.save(
        manager.create(QuestionBankQuestionAttachment, {
          questionId: question.id,
          fileId: dto.fileId,
          attachmentType: dto.attachmentType || QuestionAttachmentType.IMAGE,
          caption: dto.caption || null,
          altText: dto.altText || null,
          displayOrder,
          isPrimary: dto.isPrimary ? 1 : 0,
          storagePath: this.buildQuestionImageStoragePath(
            dto.fileId,
            file.mimeType || undefined,
          ),
          createdBy: userId,
        }),
      );
      await this.resetApprovedQuestionToDraft(
        manager,
        question,
        userId,
        'Question attachments changed; approval is required again.',
      );
      return saved;
    });
  }

  async uploadQuestionAttachmentImage(
    questionId: number,
    file: Express.Multer.File,
    metadata: UploadQuestionAttachmentMetadataDto,
    userId: number,
  ): Promise<QuestionBankQuestionAttachment> {
    const uploadedFile = await this.uploadQuestionImage(userId, file);
    return this.addQuestionAttachment(
      questionId,
      {
        fileId: uploadedFile.fileId,
        caption: metadata.caption,
        altText: metadata.altText,
        displayOrder: metadata.displayOrder,
        isPrimary: metadata.isPrimary,
        attachmentType: QuestionAttachmentType.IMAGE,
      },
      userId,
    );
  }

  async updateQuestionAttachment(
    questionId: number,
    attachmentId: number,
    dto: UpdateQuestionAttachmentDto,
    userId: number,
  ): Promise<QuestionBankQuestionAttachment> {
    const question = await this.findQuestionById(questionId, userId);
    const attachment = await this.attachmentRepo.findOne({
      where: { id: attachmentId, questionId },
    });
    if (!attachment) {
      throw new NotFoundException('Attachment not found');
    }

    return this.dataSource.transaction(async (manager) => {
      if (dto.isPrimary) {
        await manager.update(
          QuestionBankQuestionAttachment,
          { questionId },
          { isPrimary: 0 },
        );
      }
      Object.assign(attachment, {
        caption: dto.caption === undefined ? attachment.caption : dto.caption,
        altText: dto.altText === undefined ? attachment.altText : dto.altText,
        displayOrder: dto.displayOrder ?? attachment.displayOrder,
        isPrimary:
          dto.isPrimary === undefined
            ? attachment.isPrimary
            : dto.isPrimary
              ? 1
              : 0,
      });
      const saved = await manager.save(attachment);
      await this.resetApprovedQuestionToDraft(
        manager,
        question,
        userId,
        'Question attachments changed; approval is required again.',
      );
      return saved;
    });
  }

  async reorderQuestionAttachments(
    questionId: number,
    dto: ReorderQuestionAttachmentsDto,
    userId: number,
  ): Promise<QuestionBankQuestionAttachment[]> {
    const question = await this.findQuestionById(questionId, userId);
    const ids = dto.items.map((item) => item.attachmentId);
    const existing = await this.attachmentRepo.find({
      where: { questionId, id: In(ids) },
    });
    if (existing.length !== ids.length) {
      throw new BadRequestException('One or more attachments do not exist');
    }

    await this.dataSource.transaction(async (manager) => {
      for (const item of dto.items) {
        await manager.update(
          QuestionBankQuestionAttachment,
          { id: item.attachmentId, questionId },
          { displayOrder: item.displayOrder + 10000 },
        );
      }
      for (const item of dto.items) {
        await manager.update(
          QuestionBankQuestionAttachment,
          { id: item.attachmentId, questionId },
          { displayOrder: item.displayOrder },
        );
      }
      await this.resetApprovedQuestionToDraft(
        manager,
        question,
        userId,
        'Question attachments changed; approval is required again.',
      );
    });

    return this.attachmentRepo.find({
      where: { questionId },
      order: { displayOrder: 'ASC', id: 'ASC' },
    });
  }

  async removeQuestionAttachment(
    questionId: number,
    attachmentId: number,
    userId: number,
  ): Promise<void> {
    const question = await this.findQuestionById(questionId, userId);
    const attachment = await this.attachmentRepo.findOne({
      where: { id: attachmentId, questionId },
    });
    if (!attachment) {
      throw new NotFoundException('Attachment not found');
    }
    await this.dataSource.transaction(async (manager) => {
      await manager.softDelete(QuestionBankQuestionAttachment, attachment.id);
      await this.resetApprovedQuestionToDraft(
        manager,
        question,
        userId,
        'Question attachments changed; approval is required again.',
      );
    });
  }

  async createQuestionGroup(
    dto: CreateQuestionGroupDto,
    userId: number,
  ): Promise<QuestionBankQuestionGroup> {
    await this.instructorCourseAccess.assertInstructorOwnsCourse(
      userId,
      dto.courseId,
    );
    if (dto.chapterId) {
      await this.ensureChapterExists(dto.courseId, dto.chapterId);
    }
    if (dto.sharedFileId) {
      await this.ensureAttachableFile(dto.sharedFileId, userId);
    }

    return this.groupRepo.save(
      this.groupRepo.create({
        ...dto,
        title: dto.title || null,
        sharedPrompt: dto.sharedPrompt || null,
        sharedFileId: dto.sharedFileId || null,
        sharedFileCaption: dto.sharedFileCaption || null,
        sharedFileAltText: dto.sharedFileAltText || null,
        createdBy: userId,
      }),
    );
  }

  async listQuestionGroups(
    query: QuestionGroupQueryDto,
    userId: number,
  ): Promise<{ data: QuestionBankQuestionGroup[]; total: number }> {
    const page = query.page || 1;
    const limit = Math.min(query.limit || 20, 100);
    let courseIds: number[];

    if (query.courseId) {
      await this.instructorCourseAccess.assertInstructorOwnsCourse(
        userId,
        query.courseId,
      );
      courseIds = [query.courseId];
    } else {
      courseIds =
        await this.instructorCourseAccess.getInstructorCourseIds(userId);
      if (!courseIds.length) {
        return { data: [], total: 0 };
      }
    }

    const where: Record<string, unknown> = {
      courseId: In(courseIds),
    };
    if (query.chapterId) {
      where.chapterId = query.chapterId;
    }

    const [data, total] = await this.groupRepo.findAndCount({
      where,
      relations: ['items', 'sharedFile'],
      order: {
        createdAt: 'DESC',
        id: 'DESC',
        items: { itemOrder: 'ASC', id: 'ASC' },
      },
      skip: (page - 1) * limit,
      take: limit,
    });
    return { data: await this.attachQuestionGroupCounts(data), total };
  }

  async updateQuestionGroup(
    groupId: number,
    dto: UpdateQuestionGroupDto,
    userId: number,
  ): Promise<QuestionBankQuestionGroup> {
    const group = await this.findQuestionGroupById(groupId, userId);
    if (dto.sharedFileId) {
      await this.ensureAttachableFile(dto.sharedFileId, userId);
    }
    Object.assign(group, dto);
    return this.groupRepo.save(group);
  }

  async deleteQuestionGroup(groupId: number, userId: number): Promise<void> {
    const group = await this.findQuestionGroupById(groupId, userId);
    await this.groupRepo.softDelete(group.id);
  }

  async linkExistingQuestionsToGroup(
    groupId: number,
    dto: LinkQuestionGroupQuestionsDto,
    userId: number,
  ): Promise<QuestionBankQuestion[]> {
    const group = await this.findQuestionGroupById(groupId, userId);
    const questionIds = Array.from(new Set(dto.questionIds.map(Number)));
    const questions = await this.questionRepo.find({
      where: { id: In(questionIds) },
      relations: ['options', 'fillBlanks', 'attachments', 'attachments.file'],
    });
    if (questions.length !== questionIds.length) {
      throw new BadRequestException('One or more questions do not exist');
    }

    for (const question of questions) {
      await this.instructorCourseAccess.assertInstructorOwnsCourse(
        userId,
        question.courseId,
      );
      if (Number(question.courseId) !== Number(group.courseId)) {
        throw new BadRequestException(
          'Grouped questions must belong to the same course as the group',
        );
      }
      if (question.status === QuestionBankStatus.ARCHIVED) {
        throw new BadRequestException('Archived questions cannot be linked');
      }
    }

    await this.dataSource.transaction(async (manager) => {
      await manager.query(
        'SELECT `group_item_id` FROM `question_bank_question_group_items` WHERE `group_id` = ? FOR UPDATE',
        [groupId],
      );
      const existing = await manager.find(QuestionBankQuestionGroupItem, {
        where: { groupId, questionId: In(questionIds) },
      });
      const existingIds = new Set(existing.map((item) => Number(item.questionId)));
      const [rawMaxOrder] = (await manager.query(
        'SELECT COALESCE(MAX(`item_order`), -1) AS `maxOrder` FROM `question_bank_question_group_items` WHERE `group_id` = ?',
        [groupId],
      )) as Array<{ maxOrder: string | number | null }>;
      let nextItemOrder = Number(rawMaxOrder?.maxOrder ?? -1) + 1;
      for (const questionId of questionIds) {
        if (existingIds.has(Number(questionId))) {
          continue;
        }
        await manager.save(
          manager.create(QuestionBankQuestionGroupItem, {
            groupId,
            questionId,
            itemOrder: nextItemOrder,
          }),
        );
        nextItemOrder += 1;
      }
    });

    return Promise.all(questionIds.map((id) => this.findQuestionById(id, userId)));
  }

  async unlinkQuestionFromGroup(
    groupId: number,
    questionId: number,
    userId: number,
  ): Promise<void> {
    await this.findQuestionGroupById(groupId, userId);
    const item = await this.groupItemRepo.findOne({
      where: { groupId, questionId },
    });
    if (!item) {
      throw new NotFoundException('Question is not linked to this group');
    }
    await this.groupItemRepo.remove(item);
  }

  async addGroupedQuestions(
    groupId: number,
    dto: BatchCreateGroupedQuestionsDto,
    userId: number,
  ): Promise<{
    group: QuestionBankQuestionGroup;
    questions: QuestionBankQuestion[];
  }> {
    const group = await this.findQuestionGroupById(groupId, userId);
    const createdIds = await this.dataSource.transaction(async (manager) => {
      const ids: number[] = [];
      await manager.query(
        'SELECT `group_item_id` FROM `question_bank_question_group_items` WHERE `group_id` = ? FOR UPDATE',
        [groupId],
      );
      const [rawMaxOrder] = (await manager.query(
        'SELECT COALESCE(MAX(`item_order`), -1) AS `maxOrder` FROM `question_bank_question_group_items` WHERE `group_id` = ?',
        [groupId],
      )) as Array<{ maxOrder: string | number | null }>;
      const nextItemOrder = Number(rawMaxOrder?.maxOrder ?? -1) + 1;
      for (const [index, questionDto] of dto.questions.entries()) {
        const normalized = {
          ...questionDto,
          courseId: group.courseId,
          chapterId: questionDto.chapterId,
        };
        if (!normalized.chapterId) {
          throw new BadRequestException(
            'Each grouped question requires chapterId',
          );
        }
        await this.ensureChapterExists(group.courseId, normalized.chapterId);
        if (normalized.questionFileId) {
          await this.ensureAttachableFile(
            normalized.questionFileId,
            userId,
            QuestionAttachmentType.IMAGE,
          );
        }
        await this.ensureQuestionAttachmentFiles(
          normalized.attachments,
          userId,
        );
        this.validateQuestionPayload(normalized);
        const saved = await manager.save(
          manager.create(QuestionBankQuestion, {
            ...this.questionFieldsFromDto(normalized, userId),
            courseId: group.courseId,
          }),
        );
        await this.replaceQuestionChildren(manager, saved.id, normalized);
        await this.createInitialQuestionAttachments(
          manager,
          saved.id,
          normalized.attachments,
          userId,
        );
        await this.createQuestionVersion(manager, saved.id, userId);
        await manager.save(
          manager.create(QuestionBankQuestionGroupItem, {
            groupId,
            questionId: saved.id,
            itemOrder: nextItemOrder + index,
          }),
        );
        ids.push(saved.id);
      }
      return ids;
    });

    const questions = await Promise.all(
      createdIds.map((id) => this.findQuestionById(id, userId)),
    );
    return { group, questions };
  }

  async reorderQuestionGroupItems(
    groupId: number,
    dto: ReorderQuestionGroupItemsDto,
    userId: number,
  ): Promise<QuestionBankQuestionGroupItem[]> {
    await this.findQuestionGroupById(groupId, userId);
    await this.dataSource.transaction(async (manager) => {
      for (const item of dto.items) {
        await manager.update(
          QuestionBankQuestionGroupItem,
          { groupId, questionId: item.questionId },
          { itemOrder: item.itemOrder + 10000 },
        );
      }
      for (const item of dto.items) {
        await manager.update(
          QuestionBankQuestionGroupItem,
          { groupId, questionId: item.questionId },
          { itemOrder: item.itemOrder },
        );
      }
    });
    return this.groupItemRepo.find({
      where: { groupId },
      order: { itemOrder: 'ASC', id: 'ASC' },
    });
  }

  async findQuestionGroupById(
    groupId: number,
    userId: number,
  ): Promise<QuestionBankQuestionGroup> {
    const group = await this.groupRepo.findOne({
      where: { id: groupId },
      relations: ['items', 'sharedFile'],
    });
    if (!group) {
      throw new NotFoundException('Question group not found');
    }
    await this.instructorCourseAccess.assertInstructorOwnsCourse(
      userId,
      group.courseId,
    );
    const [withCounts] = await this.attachQuestionGroupCounts([group]);
    return withCounts;
  }

  async batchUpdateQuestionStatus(
    dto: BatchQuestionStatusDto,
    userId: number,
  ): Promise<{ updated: QuestionBankQuestion[]; count: number }> {
    const questionIds = Array.from(new Set(dto.questionIds.map(Number)));
    const updated: QuestionBankQuestion[] = [];
    for (const questionId of questionIds) {
      if (dto.action === QuestionBankBatchStatusAction.RESTORE) {
        updated.push(
          await this.restoreQuestion(questionId, userId, dto.comment),
        );
        continue;
      }

      updated.push(
        await this.updateQuestionReviewStatus(
          questionId,
          this.toStatusForBatchAction(dto.action),
          userId,
          dto.comment,
        ),
      );
    }
    return { updated, count: updated.length };
  }

  async updateQuestionReviewStatus(
    questionId: number,
    toStatus: QuestionBankStatus,
    userId: number,
    comment?: string,
  ): Promise<QuestionBankQuestion> {
    const question = await this.findQuestionById(questionId, userId);
    this.assertQuestionStatusTransition(question.status, toStatus);
    await this.dataSource.transaction(async (manager) => {
      await manager.update(QuestionBankQuestion, question.id, {
        status: toStatus,
        reviewedBy: userId,
        reviewedAt: new Date(),
        reviewComment: comment || null,
        updatedBy: userId,
      });
      await this.createReviewEvent(
        manager,
        question.id,
        question.status,
        toStatus,
        userId,
        comment || null,
      );
      await this.createQuestionVersion(manager, question.id, userId);
    });

    return this.findQuestionById(question.id, userId);
  }

  private toStatusForBatchAction(
    action: QuestionBankBatchStatusAction,
  ): QuestionBankStatus {
    switch (action) {
      case QuestionBankBatchStatusAction.SUBMIT_FOR_REVIEW:
        return QuestionBankStatus.UNDER_REVIEW;
      case QuestionBankBatchStatusAction.APPROVE:
        return QuestionBankStatus.APPROVED;
      case QuestionBankBatchStatusAction.REJECT:
        return QuestionBankStatus.REJECTED;
      case QuestionBankBatchStatusAction.ARCHIVE:
        return QuestionBankStatus.ARCHIVED;
      default:
        throw new BadRequestException('Unsupported status action');
    }
  }

  private resolveBatchFailureMessage(error: unknown): string {
    if (error instanceof HttpException) {
      const response = error.getResponse();
      if (typeof response === 'string') {
        return response;
      }
      if (response && typeof response === 'object') {
        const message = (response as { message?: unknown }).message;
        if (Array.isArray(message)) {
          return message.join(', ');
        }
        if (typeof message === 'string') {
          return message;
        }
      }
      return error.message;
    }
    if (error instanceof Error) {
      return error.message;
    }
    return 'Question could not be created';
  }

  private assertQuestionStatusTransition(
    fromStatus: QuestionBankStatus,
    toStatus: QuestionBankStatus,
  ): void {
    if (fromStatus === toStatus) return;
    if (toStatus === QuestionBankStatus.UNDER_REVIEW) {
      if (
        fromStatus === QuestionBankStatus.DRAFT ||
        fromStatus === QuestionBankStatus.REJECTED
      ) {
        return;
      }
      throw new BadRequestException(
        'Only draft or rejected questions can be submitted for review',
      );
    }
    if (toStatus === QuestionBankStatus.APPROVED) {
      if (
        fromStatus === QuestionBankStatus.DRAFT ||
        fromStatus === QuestionBankStatus.UNDER_REVIEW
      ) {
        return;
      }
      throw new BadRequestException(
        'Only draft or under review questions can be approved',
      );
    }
    if (toStatus === QuestionBankStatus.REJECTED) {
      if (fromStatus === QuestionBankStatus.UNDER_REVIEW) {
        return;
      }
      throw new BadRequestException(
        'Only under review questions can be rejected',
      );
    }
    if (toStatus === QuestionBankStatus.ARCHIVED) {
      if (fromStatus !== QuestionBankStatus.ARCHIVED) {
        return;
      }
      throw new BadRequestException('Question is already archived');
    }
    throw new BadRequestException('Unsupported status transition');
  }

  private isMeaningfulQuestionUpdate(
    dto: UpdateQuestionBankQuestionDto,
  ): boolean {
    return [
      'chapterId',
      'questionType',
      'difficulty',
      'bloomLevel',
      'questionText',
      'questionFileId',
      'questionFileCaption',
      'questionFileAltText',
      'expectedAnswerText',
      'hints',
      'options',
      'fillBlanks',
    ].some((key) => Object.prototype.hasOwnProperty.call(dto, key));
  }

  private async resetApprovedQuestionToDraft(
    manager: EntityManager,
    question: QuestionBankQuestion,
    userId: number,
    comment: string,
  ): Promise<void> {
    if (question.status !== QuestionBankStatus.APPROVED) {
      return;
    }
    await manager.update(QuestionBankQuestion, question.id, {
      status: QuestionBankStatus.DRAFT,
      reviewedBy: userId,
      reviewedAt: new Date(),
      reviewComment: comment,
      updatedBy: userId,
    });
    await this.createReviewEvent(
      manager,
      question.id,
      question.status,
      QuestionBankStatus.DRAFT,
      userId,
      comment,
    );
  }

  private async createReviewEvent(
    manager: EntityManager,
    questionId: number,
    fromStatus: QuestionBankStatus | null,
    toStatus: QuestionBankStatus,
    userId: number,
    comment?: string | null,
  ): Promise<void> {
    await manager.save(
      manager.create(QuestionBankReviewEvent, {
        questionId,
        fromStatus,
        toStatus,
        comment: comment || null,
        createdBy: userId,
      }),
    );
  }

  private async replaceQuestionChildren(
    manager: EntityManager,
    questionId: number,
    source: CreateQuestionBankQuestionDto,
    patch?: UpdateQuestionBankQuestionDto,
    typeChanged = false,
  ): Promise<void> {
    const typeUsesOptions =
      source.questionType === QuestionBankType.MCQ ||
      source.questionType === QuestionBankType.TRUE_FALSE;
    const typeUsesFillBlanks =
      source.questionType === QuestionBankType.FILL_BLANKS;
    const isCreate = patch === undefined;

    if (isCreate || patch?.options !== undefined || typeChanged) {
      await manager.delete(QuestionBankOption, { questionId });
      if (typeUsesOptions && source.options?.length) {
        const options = source.options.map((option, index) =>
          manager.create(QuestionBankOption, {
            questionId,
            optionText: option.optionText,
            isCorrect: option.isCorrect ? 1 : 0,
            optionOrder: index,
          }),
        );
        await manager.save(options);
      }
    }

    if (isCreate || patch?.fillBlanks !== undefined || typeChanged) {
      await manager.delete(QuestionBankFillBlank, { questionId });
      if (typeUsesFillBlanks && source.fillBlanks?.length) {
        const blanks = source.fillBlanks.map((blank) =>
          manager.create(QuestionBankFillBlank, {
            questionId,
            blankKey: blank.blankKey,
            acceptableAnswer: blank.acceptableAnswer,
            isCaseSensitive: blank.isCaseSensitive ? 1 : 0,
          }),
        );
        await manager.save(blanks);
      }
    }
  }

  private async ensureQuestionAttachmentFiles(
    attachments: CreateQuestionAttachmentDto[] | undefined,
    userId: number,
  ): Promise<void> {
    if (!attachments?.length) return;
    for (const attachment of attachments) {
      await this.ensureAttachableFile(
        attachment.fileId,
        userId,
        attachment.attachmentType || QuestionAttachmentType.IMAGE,
      );
    }
  }

  private async createInitialQuestionAttachments(
    manager: EntityManager,
    questionId: number,
    attachments: CreateQuestionAttachmentDto[] | undefined,
    userId: number,
  ): Promise<void> {
    if (!attachments?.length) return;

    const rows: QuestionBankQuestionAttachment[] = [];
    const usedOrders = new Set<number>();
    let nextOrder = 0;
    const primaryIndex = attachments.findIndex((item) => item.isPrimary);

    for (const [index, attachment] of attachments.entries()) {
      const file = await this.ensureAttachableFile(
        attachment.fileId,
        userId,
        attachment.attachmentType || QuestionAttachmentType.IMAGE,
      );
      let displayOrder =
        attachment.displayOrder !== undefined ? attachment.displayOrder : index;
      while (usedOrders.has(displayOrder)) {
        displayOrder = nextOrder;
        nextOrder += 1;
      }
      usedOrders.add(displayOrder);
      nextOrder = Math.max(nextOrder, displayOrder + 1);

      rows.push(
        manager.create(QuestionBankQuestionAttachment, {
          questionId,
          fileId: attachment.fileId,
          attachmentType:
            attachment.attachmentType || QuestionAttachmentType.IMAGE,
          caption: attachment.caption || null,
          altText: attachment.altText || null,
          displayOrder,
          isPrimary:
            primaryIndex >= 0
              ? index === primaryIndex
                ? 1
                : 0
              : index === 0
                ? 1
                : 0,
          storagePath: this.buildQuestionImageStoragePath(
            attachment.fileId,
            file.mimeType || undefined,
          ),
          createdBy: userId,
        }),
      );
    }

    await manager.save(rows);
  }

  private questionFieldsFromDto(
    dto: CreateQuestionBankQuestionDto,
    userId: number,
  ): Partial<QuestionBankQuestion> {
    return {
      courseId: dto.courseId,
      chapterId: dto.chapterId,
      questionType: dto.questionType,
      difficulty: dto.difficulty,
      bloomLevel: dto.bloomLevel,
      status: dto.status || QuestionBankStatus.DRAFT,
      questionText: dto.questionText || null,
      questionFileId: dto.questionFileId || null,
      questionFileCaption: dto.questionFileCaption || null,
      questionFileAltText: dto.questionFileAltText || null,
      expectedAnswerText: dto.expectedAnswerText || null,
      hints: dto.hints || null,
      createdBy: userId,
      updatedBy: userId,
    };
  }

  private async createQuestionVersion(
    manager: EntityManager,
    questionId: number,
    userId: number,
  ): Promise<void> {
    const question = await manager.findOne(QuestionBankQuestion, {
      where: { id: questionId },
      relations: ['options', 'fillBlanks', 'attachments'],
    });
    if (!question) {
      return;
    }
    await this.createQuestionVersionFromSnapshot(
      manager,
      questionId,
      userId,
      this.buildQuestionSnapshot(question),
    );
  }

  private async createQuestionVersionFromSnapshot(
    manager: EntityManager,
    questionId: number,
    userId: number,
    snapshotJson: Record<string, unknown>,
  ): Promise<QuestionBankQuestionVersion> {
    const raw = await manager
      .createQueryBuilder(QuestionBankQuestionVersion, 'version')
      .select('MAX(version.version_number)', 'maxVersion')
      .where('version.question_id = :questionId', { questionId })
      .getRawOne<{ maxVersion: string | null }>();
    const versionNumber = Number(raw?.maxVersion || 0) + 1;
    return manager.save(
      manager.create(QuestionBankQuestionVersion, {
        questionId,
        versionNumber,
        snapshotJson,
        createdBy: userId,
      }),
    );
  }

  private buildQuestionSnapshot(
    question: QuestionBankQuestion,
  ): Record<string, unknown> {
    return {
      questionId: question.id,
      courseId: question.courseId,
      chapterId: question.chapterId,
      questionType: question.questionType,
      difficulty: question.difficulty,
      bloomLevel: question.bloomLevel,
      questionText: question.questionText,
      questionFileId: question.questionFileId,
      questionFileCaption: question.questionFileCaption,
      questionFileAltText: question.questionFileAltText,
      expectedAnswerText: question.expectedAnswerText,
      hints: question.hints,
      status: question.status,
      options: question.options || [],
      fillBlanks: question.fillBlanks || [],
      attachments: question.attachments || [],
    };
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
      if (payload.fillBlanks?.length) {
        throw new BadRequestException('MCQ questions cannot have fill blanks');
      }
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
      if (payload.fillBlanks?.length) {
        throw new BadRequestException(
          'True/False questions cannot have fill blanks',
        );
      }
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
      if (payload.options?.length) {
        throw new BadRequestException(
          'Fill in the blanks questions cannot have options',
        );
      }
      if (!payload.fillBlanks || payload.fillBlanks.length < 1) {
        throw new BadRequestException(
          'Fill in the blanks questions require at least one blank answer',
        );
      }
      const blankKeys = payload.fillBlanks.map((blank) =>
        blank.blankKey.trim().toLowerCase(),
      );
      if (new Set(blankKeys).size !== blankKeys.length) {
        throw new BadRequestException(
          'Fill in the blanks questions require unique blank keys',
        );
      }
    }

    if (
      payload.questionType === QuestionBankType.WRITTEN ||
      payload.questionType === QuestionBankType.ESSAY
    ) {
      if (payload.options?.length || payload.fillBlanks?.length) {
        throw new BadRequestException(
          'Written/Essay questions cannot have options or fill blanks',
        );
      }
      if (!payload.expectedAnswerText?.trim()) {
        throw new BadRequestException(
          'Written/Essay questions require expectedAnswerText',
        );
      }
    }
  }

  private shouldKeepExistingOptions(
    currentType: QuestionBankType,
    nextType?: QuestionBankType,
  ): boolean {
    const effectiveType = nextType || currentType;
    return (
      effectiveType === currentType &&
      (effectiveType === QuestionBankType.MCQ ||
        effectiveType === QuestionBankType.TRUE_FALSE)
    );
  }

  private shouldKeepExistingFillBlanks(
    currentType: QuestionBankType,
    nextType?: QuestionBankType,
  ): boolean {
    const effectiveType = nextType || currentType;
    return (
      effectiveType === currentType &&
      effectiveType === QuestionBankType.FILL_BLANKS
    );
  }

  private toOptionDtos(
    options: QuestionBankOption[],
  ): CreateQuestionBankQuestionDto['options'] {
    return options.map((option) => ({
      optionText: option.optionText,
      isCorrect: Number(option.isCorrect) === 1,
    }));
  }

  private toFillBlankDtos(
    blanks: QuestionBankFillBlank[],
  ): CreateQuestionBankQuestionDto['fillBlanks'] {
    return blanks.map((blank) => ({
      blankKey: blank.blankKey,
      acceptableAnswer: blank.acceptableAnswer,
      isCaseSensitive: Number(blank.isCaseSensitive) === 1,
    }));
  }

  private parseOptionalBoolean(value: unknown): boolean | undefined {
    if (value === true || value === 'true') return true;
    if (value === false || value === 'false') return false;
    return undefined;
  }

  private async getNextChapterOrder(courseId: number): Promise<number> {
    const raw = await this.chapterRepo
      .createQueryBuilder('chapter')
      .select('MAX(chapter.chapter_order)', 'maxOrder')
      .where('chapter.course_id = :courseId', { courseId })
      .getRawOne<{ maxOrder: string | null }>();
    return Number(raw?.maxOrder ?? 0) + 1;
  }

  private async attachQuestionGroupCounts(
    groups: QuestionBankQuestionGroup[],
  ): Promise<QuestionBankQuestionGroup[]> {
    if (!groups.length) return groups;
    if (typeof this.dataSource.query !== 'function') {
      return groups.map((group) => {
        Object.assign(group as QuestionBankQuestionGroup & Record<string, number>, {
          totalQuestions: group.items?.length ?? 0,
          approvedQuestions: 0,
          draftQuestions: 0,
          underReviewQuestions: 0,
          rejectedQuestions: 0,
          archivedQuestions: 0,
        });
        return group;
      });
    }
    const groupIds = groups.map((group) => Number(group.id));
    const placeholders = groupIds.map(() => '?').join(',');
    const rows = (await this.dataSource.query(
      `
        SELECT
          item.group_id AS groupId,
          COUNT(DISTINCT question.question_id) AS totalQuestions,
          COUNT(DISTINCT CASE WHEN question.status = 'approved' THEN question.question_id END) AS approvedQuestions,
          COUNT(DISTINCT CASE WHEN question.status = 'draft' THEN question.question_id END) AS draftQuestions,
          COUNT(DISTINCT CASE WHEN question.status = 'under_review' THEN question.question_id END) AS underReviewQuestions,
          COUNT(DISTINCT CASE WHEN question.status = 'rejected' THEN question.question_id END) AS rejectedQuestions,
          COUNT(DISTINCT CASE WHEN question.status = 'archived' THEN question.question_id END) AS archivedQuestions
        FROM question_bank_question_group_items item
        INNER JOIN question_bank_questions question
          ON question.question_id = item.question_id
        WHERE item.group_id IN (${placeholders})
        GROUP BY item.group_id
      `,
      groupIds,
    )) as Array<Record<string, string | number>>;
    const byGroupId = new Map(rows.map((row) => [Number(row.groupId), row]));
    return groups.map((group) => {
      const row = byGroupId.get(Number(group.id));
      Object.assign(group as QuestionBankQuestionGroup & Record<string, number>, {
        totalQuestions: Number(row?.totalQuestions || 0),
        approvedQuestions: Number(row?.approvedQuestions || 0),
        draftQuestions: Number(row?.draftQuestions || 0),
        underReviewQuestions: Number(row?.underReviewQuestions || 0),
        rejectedQuestions: Number(row?.rejectedQuestions || 0),
        archivedQuestions: Number(row?.archivedQuestions || 0),
      });
      return group;
    });
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

  private async ensureAttachableFile(
    fileId: number,
    userId: number,
    attachmentType?: QuestionAttachmentType,
    question?: QuestionBankQuestion,
  ): Promise<File> {
    const file = await this.fileRepo.findOne({ where: { fileId } });
    if (!file) {
      throw new NotFoundException('File not found');
    }

    if (attachmentType === QuestionAttachmentType.IMAGE) {
      this.ensureFileMimeTypeIsImage(file);
    }

    if (
      question?.questionFileId &&
      Number(question.questionFileId) === Number(fileId)
    ) {
      return file;
    }

    if (
      Number(file.uploadedBy) === Number(userId) ||
      Number(file.isPublic) === 1
    ) {
      return file;
    }

    const hasPermission = await this.filePermissionRepo.exist({
      where: [
        { fileId, userId, permissionType: PermissionType.READ },
        { fileId, userId, permissionType: PermissionType.WRITE },
        { fileId, userId, permissionType: PermissionType.SHARE },
      ],
    });
    if (hasPermission) {
      return file;
    }

    throw new ForbiddenException(
      'File is not owned by or shared with this instructor',
    );
  }

  private ensureFileMimeTypeIsImage(file: File): void {
    const allowedMimeTypes = new Set([
      'image/jpeg',
      'image/png',
      'image/webp',
      'image/gif',
    ]);
    if (!allowedMimeTypes.has(file.mimeType)) {
      throw new BadRequestException(
        `File ${file.fileId} is not a supported question image`,
      );
    }
  }

  private async cleanupFailedQuestionImageUpload(
    fileId: number,
    userId: number,
  ): Promise<void> {
    try {
      await this.filesService.deleteFile(fileId, userId);
      this.logger.warn(`Cleaned failed question image file=${fileId}`);
    } catch (error) {
      this.logger.error(
        `Failed to clean orphan question image file=${fileId}`,
        error instanceof Error ? error.stack : undefined,
      );
    }
  }

  private async getNextAttachmentDisplayOrder(
    questionId: number,
  ): Promise<number> {
    const raw = await this.attachmentRepo
      .createQueryBuilder('attachment')
      .select('MAX(attachment.display_order)', 'maxOrder')
      .where('attachment.question_id = :questionId', { questionId })
      .getRawOne<{ maxOrder: string | null }>();
    return Number(raw?.maxOrder ?? -1) + 1;
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
    const pathPairs: Array<{
      target: Record<string, unknown>;
      storagePath: string;
      propertyName: string;
    }> = [];

    for (const question of questions) {
      if (question.file) {
        pathPairs.push({
          target: question as unknown as Record<string, unknown>,
          storagePath: this.buildQuestionImageStoragePath(
            Number(question.file.fileId),
            question.file.mimeType || undefined,
          ),
          propertyName: 'questionImageUrl',
        });
      }
      for (const attachment of question.attachments || []) {
        const storagePath =
          attachment.storagePath ||
          (attachment.file
            ? this.buildQuestionImageStoragePath(
                Number(attachment.file.fileId),
                attachment.file.mimeType || undefined,
              )
            : null);
        if (storagePath) {
          pathPairs.push({
            target: attachment as unknown as Record<string, unknown>,
            storagePath,
            propertyName: 'imageUrl',
          });
        }
      }
    }

    const urlMap = await this.createQuestionImageUrls(
      pathPairs.map((pair) => pair.storagePath),
    );
    for (const pair of pathPairs) {
      pair.target[pair.propertyName] = urlMap.get(pair.storagePath) ?? null;
    }

    return questions;
  }

  private async createQuestionImageUrls(
    storagePaths: string[],
  ): Promise<Map<string, string | null>> {
    if (!storagePaths.length) {
      return new Map();
    }

    await this.ensureQuestionImagesBucketExists();

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

  private async ensureQuestionImagesBucketExists(): Promise<void> {
    if (this.questionImagesBucketReady) {
      return;
    }

    const { data, error } = await this.supabase.storage.listBuckets();
    if (error) {
      throw new InternalServerErrorException(
        `Failed to check Supabase buckets: ${error.message}`,
      );
    }

    const exists = (data || []).some(
      (bucket: any) =>
        bucket?.id === this.questionImagesBucketName ||
        bucket?.name === this.questionImagesBucketName,
    );

    if (!exists) {
      const { error: createError } = await this.supabase.storage.createBucket(
        this.questionImagesBucketName,
        {
          public: this.usePublicUrlsForQuestionImages,
          fileSizeLimit: `${this.maxQuestionImageSize}`,
          allowedMimeTypes: [
            'image/jpeg',
            'image/png',
            'image/webp',
            'image/gif',
          ],
        },
      );

      if (createError && !/already exists/i.test(createError.message || '')) {
        throw new InternalServerErrorException(
          `Failed to create Supabase bucket "${this.questionImagesBucketName}": ${createError.message}`,
        );
      }
    }

    this.questionImagesBucketReady = true;
  }

  toPrivateResponse(
    question: QuestionBankQuestion,
  ): QuestionBankPrivateResponseDto {
    return {
      id: Number(question.id),
      questionId: Number(question.id),
      courseId: Number(question.courseId),
      chapterId: Number(question.chapterId),
      questionType: question.questionType,
      difficulty: question.difficulty,
      bloomLevel: question.bloomLevel,
      status: question.status,
      questionText: question.questionText,
      questionFileId: question.questionFileId
        ? Number(question.questionFileId)
        : null,
      questionImageUrl:
        (
          question as QuestionBankQuestion & {
            questionImageUrl?: string | null;
          }
        ).questionImageUrl ?? null,
      questionFileCaption: question.questionFileCaption,
      questionFileAltText: question.questionFileAltText,
      expectedAnswerText: question.expectedAnswerText,
      hints: question.hints,
      options: (question.options || []).map((option) => ({
        optionId: Number(option.id),
        optionText: option.optionText,
        isCorrect: Number(option.isCorrect) === 1,
        optionOrder: option.optionOrder,
      })),
      fillBlanks: (question.fillBlanks || []).map((blank) => ({
        blankId: Number(blank.id),
        blankKey: blank.blankKey,
        acceptableAnswer: blank.acceptableAnswer,
        isCaseSensitive: Number(blank.isCaseSensitive) === 1,
      })),
      attachments: (question.attachments || [])
        .slice()
        .sort((a, b) => Number(a.displayOrder) - Number(b.displayOrder))
        .map((attachment) => ({
          attachmentId: Number(attachment.id),
          fileId: Number(attachment.fileId),
          attachmentType: attachment.attachmentType,
          caption: attachment.caption,
          altText: attachment.altText,
          displayOrder: attachment.displayOrder,
          isPrimary: Number(attachment.isPrimary) === 1,
          storagePath: attachment.storagePath,
          imageUrl: (
            attachment as QuestionBankQuestionAttachment & {
              imageUrl?: string;
            }
          ).imageUrl,
        })),
      groups: (question.groupItems || [])
        .filter((item) => item.group)
        .slice()
        .sort((a, b) => Number(a.itemOrder) - Number(b.itemOrder))
        .map((item) => ({
          groupItemId: Number(item.id),
          groupId: Number(item.groupId),
          itemOrder: Number(item.itemOrder),
          courseId: Number(item.group.courseId),
          chapterId: item.group.chapterId ? Number(item.group.chapterId) : null,
          title: item.group.title,
          sharedPrompt: item.group.sharedPrompt,
          sharedFileId: item.group.sharedFileId
            ? Number(item.group.sharedFileId)
            : null,
          sharedFileCaption: item.group.sharedFileCaption,
          sharedFileAltText: item.group.sharedFileAltText,
          groupType: item.group.groupType,
        })),
    };
  }
}
