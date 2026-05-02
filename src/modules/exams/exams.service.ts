import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { randomUUID } from 'crypto';
import { In, Repository } from 'typeorm';
import { Course } from '../courses/entities/course.entity';
import { CourseChapter } from '../question-bank/entities/course-chapter.entity';
import { QuestionBankQuestion } from '../question-bank/entities/question-bank-question.entity';
import { QuestionBankStatus } from '../question-bank/enums/question-bank.enums';
import {
  GenerateExamPreviewDto,
  UpdateDraftItemDto,
} from './dto/generate-exam.dto';
import { ExamDraftItem } from './entities/exam-draft-item.entity';
import { ExamDraft } from './entities/exam-draft.entity';
import { ExamItem } from './entities/exam-item.entity';
import { Exam } from './entities/exam.entity';

type PaginatedResult<T> = {
  data: T[];
  meta: { total: number; page: number; limit: number; totalPages: number };
};

@Injectable()
export class ExamsService {
  constructor(
    @InjectRepository(Course)
    private readonly courseRepo: Repository<Course>,
    @InjectRepository(CourseChapter)
    private readonly chapterRepo: Repository<CourseChapter>,
    @InjectRepository(QuestionBankQuestion)
    private readonly questionRepo: Repository<QuestionBankQuestion>,
    @InjectRepository(ExamDraft)
    private readonly draftRepo: Repository<ExamDraft>,
    @InjectRepository(ExamDraftItem)
    private readonly draftItemRepo: Repository<ExamDraftItem>,
    @InjectRepository(Exam)
    private readonly examRepo: Repository<Exam>,
    @InjectRepository(ExamItem)
    private readonly examItemRepo: Repository<ExamItem>,
  ) {}

  async findExams(
    page: number = 1,
    limit: number = 20,
  ): Promise<PaginatedResult<Exam>> {
    const { safePage, safeLimit, skip } = this.normalizePagination(page, limit);
    const [data, total] = await this.examRepo.findAndCount({
      order: { createdAt: 'DESC' },
      skip,
      take: safeLimit,
    });

    return {
      data,
      meta: {
        total,
        page: safePage,
        limit: safeLimit,
        totalPages: Math.ceil(total / safeLimit),
      },
    };
  }

  async findDrafts(
    page: number = 1,
    limit: number = 20,
  ): Promise<PaginatedResult<ExamDraft>> {
    const { safePage, safeLimit, skip } = this.normalizePagination(page, limit);
    const [data, total] = await this.draftRepo.findAndCount({
      order: { createdAt: 'DESC' },
      skip,
      take: safeLimit,
    });

    return {
      data,
      meta: {
        total,
        page: safePage,
        limit: safeLimit,
        totalPages: Math.ceil(total / safeLimit),
      },
    };
  }

  async findDraftById(draftId: number): Promise<ExamDraft> {
    const draft = await this.draftRepo.findOne({
      where: { id: draftId },
      relations: ['items'],
    });

    if (!draft) {
      throw new NotFoundException('Draft not found');
    }

    return draft;
  }

  async generatePreview(dto: GenerateExamPreviewDto, userId: number) {
    await this.ensureCourseExists(dto.courseId);
    try {
      if (!dto.rules.length) {
        throw new BadRequestException('At least one rule is required');
      }

      const seed = dto.seed || randomUUID();
      const shortages: Array<Record<string, unknown>> = [];
      const selectedQuestionIds = new Set<number>();
      const selectedItems: Array<{
        questionId: number;
        chapterId: number;
        weight: number;
        itemOrder: number;
      }> = [];

      for (const rule of dto.rules) {
        const chapterExists = await this.chapterRepo.exist({
          where: { id: rule.chapterId, courseId: dto.courseId },
        });
        if (!chapterExists) {
          throw new BadRequestException(
            `Chapter ${rule.chapterId} does not belong to this course`,
          );
        }

        const qb = this.questionRepo
          .createQueryBuilder('q')
          .select('q.question_id', 'id')
          .where('q.course_id = :courseId', { courseId: dto.courseId })
          .andWhere('q.chapter_id = :chapterId', { chapterId: rule.chapterId })
          .andWhere('q.status = :status', {
            status: QuestionBankStatus.APPROVED,
          });

        if (rule.questionType)
          qb.andWhere('q.question_type = :questionType', {
            questionType: rule.questionType,
          });
        if (rule.difficulty)
          qb.andWhere('q.difficulty = :difficulty', {
            difficulty: rule.difficulty,
          });
        if (rule.bloomLevel)
          qb.andWhere('q.bloom_level = :bloomLevel', {
            bloomLevel: rule.bloomLevel,
          });

        const rawIds = await qb.getRawMany<{ id: string }>();
        const candidates = rawIds
          .map((row) => Number(row.id))
          .filter((id) => !selectedQuestionIds.has(id));

        if (candidates.length < rule.count) {
          shortages.push({
            chapterId: rule.chapterId,
            required: rule.count,
            available: candidates.length,
            questionType: rule.questionType ?? null,
            difficulty: rule.difficulty ?? null,
            bloomLevel: rule.bloomLevel ?? null,
          });
          continue;
        }

        const shuffled = this.seededShuffle(
          candidates,
          `${seed}:${rule.chapterId}`,
        );
        const picked = shuffled.slice(0, rule.count);
        for (const questionId of picked) {
          selectedQuestionIds.add(questionId);
          selectedItems.push({
            questionId,
            chapterId: rule.chapterId,
            weight: rule.weightPerQuestion,
            itemOrder: selectedItems.length,
          });
        }
      }

      if (shortages.length) {
        throw new BadRequestException({
          message: 'Insufficient question pool for one or more buckets',
          shortages,
        });
      }

      const draft = await this.draftRepo.save(
        this.draftRepo.create({
          courseId: dto.courseId,
          title: dto.title,
          generationRequestJson: dto as unknown as Record<string, unknown>,
          generatedBy: userId,
          seed,
          expiresAt: new Date(Date.now() + 1000 * 60 * 60 * 24),
        }),
      );

      const questionEntities = await this.questionRepo.find({
        where: { id: In(Array.from(selectedQuestionIds)) },
      });
      const questionMap = new Map(
        questionEntities.map((q) => [Number(q.id), q]),
      );

      const draftItems = await this.draftItemRepo.save(
        selectedItems.map((item) =>
          this.draftItemRepo.create({
            draftId: draft.id,
            questionId: item.questionId,
            chapterId: item.chapterId,
            questionType: questionMap.get(item.questionId)!.questionType,
            difficulty: questionMap.get(item.questionId)!.difficulty,
            bloomLevel: questionMap.get(item.questionId)!.bloomLevel,
            weight: item.weight,
            itemOrder: item.itemOrder,
          }),
        ),
      );

      return {
        draftId: draft.id,
        seed,
        totalQuestions: draftItems.length,
        totalWeight: draftItems.reduce(
          (sum, item) => sum + Number(item.weight),
          0,
        ),
        items: draftItems,
      };
    } catch (e) {
      console.error('GENERATE PREVIEW ERROR:', e);
      throw new BadRequestException(e.message || 'Unknown error');
    }
  }

  async updateDraftItem(
    draftId: number,
    itemId: number,
    dto: UpdateDraftItemDto,
  ): Promise<ExamDraftItem> {
    const item = await this.draftItemRepo.findOne({
      where: { id: itemId, draftId },
    });
    if (!item) {
      throw new NotFoundException('Draft item not found');
    }

    if (dto.replacementQuestionId) {
      const question = await this.questionRepo.findOne({
        where: { id: dto.replacementQuestionId },
      });
      if (!question) {
        throw new NotFoundException('Replacement question not found');
      }
      item.questionId = question.id;
      item.chapterId = question.chapterId;
      item.questionType = question.questionType;
      item.difficulty = question.difficulty;
      item.bloomLevel = question.bloomLevel;
    }
    if (dto.weight !== undefined) item.weight = dto.weight;
    if (dto.itemOrder !== undefined) item.itemOrder = dto.itemOrder;
    return this.draftItemRepo.save(item);
  }

  async saveDraft(draftId: number, userId: number): Promise<Exam> {
    const draft = await this.draftRepo.findOne({
      where: { id: draftId },
      relations: ['items'],
    });
    if (!draft) {
      throw new NotFoundException('Draft not found');
    }

    const totalWeight = draft.items.reduce(
      (sum, item) => sum + Number(item.weight),
      0,
    );
    const exam = await this.examRepo.save(
      this.examRepo.create({
        courseId: draft.courseId,
        title: draft.title,
        totalWeight,
        status: 'draft',
        createdBy: userId,
        snapshotJson: {
          draftId: draft.id,
          seed: draft.seed,
          generatedAt: draft.createdAt.toISOString(),
        },
      }),
    );

    await this.examItemRepo.save(
      draft.items.map((item) =>
        this.examItemRepo.create({
          examId: exam.id,
          questionId: item.questionId,
          weight: item.weight,
          itemOrder: item.itemOrder,
        }),
      ),
    );

    return this.findExamById(exam.id);
  }

  async findExamById(examId: number): Promise<Exam> {
    const exam = await this.examRepo.findOne({
      where: { id: examId },
      relations: ['items', 'items.question'],
    });
    if (!exam) {
      throw new NotFoundException('Exam not found');
    }
    return exam;
  }

  async exportExamAsWord(
    examId: number,
  ): Promise<{ fileName: string; mimeType: string; content: string }> {
    const exam = await this.findExamById(examId);
    const lines = [
      `<html><body><h1>${exam.title}</h1>`,
      `<p>Total Weight: ${exam.totalWeight}</p>`,
      `<ol>`,
      ...exam.items
        .sort((a, b) => a.itemOrder - b.itemOrder)
        .map(
          (item) =>
            `<li><p>${(item.question as any).questionText || '[Image Question]'}</p><p>Weight: ${item.weight}</p></li>`,
        ),
      `</ol></body></html>`,
    ];
    return {
      fileName: `exam-${exam.id}.doc`,
      mimeType: 'application/msword',
      content: Buffer.from(lines.join('\n')).toString('base64'),
    };
  }

  private seededShuffle(values: number[], seed: string): number[] {
    const result = [...values];
    let h = 2166136261;
    for (let i = 0; i < seed.length; i += 1) {
      h ^= seed.charCodeAt(i);
      h = Math.imul(h, 16777619);
    }
    for (let i = result.length - 1; i > 0; i -= 1) {
      h ^= h << 13;
      h ^= h >>> 17;
      h ^= h << 5;
      const j = Math.abs(h) % (i + 1);
      [result[i], result[j]] = [result[j], result[i]];
    }
    return result;
  }

  private async ensureCourseExists(courseId: number): Promise<void> {
    const exists = await this.courseRepo.exist({ where: { id: courseId } });
    if (!exists) {
      throw new NotFoundException('Course not found');
    }
  }

  private normalizePagination(
    page?: number,
    limit?: number,
  ): { safePage: number; safeLimit: number; skip: number } {
    const safePage = page && page > 0 ? page : 1;
    const safeLimit = Math.min(100, Math.max(1, limit ?? 20));
    return {
      safePage,
      safeLimit,
      skip: (safePage - 1) * safeLimit,
    };
  }
}
