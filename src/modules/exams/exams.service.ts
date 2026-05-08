import {
  BadRequestException,
  Injectable,
  Logger,
  NotFoundException,
  Optional,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { InjectRepository } from '@nestjs/typeorm';
import { createClient, SupabaseClient } from '@supabase/supabase-js';
import { randomUUID } from 'crypto';
import * as fs from 'fs';
import * as path from 'path';
import JSZip from 'jszip';
import PDFDocument from 'pdfkit';
import {
  Between,
  DataSource,
  EntityManager,
  FindOperator,
  In,
  LessThanOrEqual,
  MoreThanOrEqual,
  Repository,
} from 'typeorm';
import { Course } from '../courses/entities/course.entity';
import { CourseChapter } from '../question-bank/entities/course-chapter.entity';
import { QuestionBankFillBlank } from '../question-bank/entities/question-bank-fill-blank.entity';
import { QuestionBankOption } from '../question-bank/entities/question-bank-option.entity';
import { QuestionBankQuestionAttachment } from '../question-bank/entities/question-bank-question-attachment.entity';
import { QuestionBankQuestionVersion } from '../question-bank/entities/question-bank-question-version.entity';
import { QuestionBankQuestionGroup } from '../question-bank/entities/question-bank-question-group.entity';
import { QuestionBankQuestionGroupItem } from '../question-bank/entities/question-bank-question-group-item.entity';
import { QuestionBankQuestion } from '../question-bank/entities/question-bank-question.entity';
import { QuestionBankStatus } from '../question-bank/enums/question-bank.enums';
import { InstructorCourseAccessService } from '../question-bank/services/instructor-course-access.service';
import { FileStorageService } from '../files/file-storage.service';
import {
  AddDraftItemDto,
  DuplicateDraftDto,
  ReorderDraftItemsDto,
  ReplacementCheckDto,
} from './dto/exam-draft-item.dto';
import {
  ExamAnswerKeyStyle,
  ExamExportVariant,
  ExportExamDto,
} from './dto/exam-export.dto';
import {
  ApplyExamPaperTemplateDto,
  SaveExamPaperTemplateDto,
} from './dto/exam-paper-template.dto';
import {
  ArchiveExamDto,
  PublishExamDto,
  UnpublishExamDto,
} from './dto/exam-lifecycle.dto';
import {
  CreateExamSectionDto,
  NormalizeSectionMarksDto,
  ReorderExamSectionsDto,
  UpdateExamSectionDto,
} from './dto/exam-section.dto';
import {
  ExamGroupSelectionMode,
  ExamGenerationScope,
  ExamGenerationRuleDto,
  ExamGenerationSectionDto,
  GenerateExamPreviewDto,
  UpdateDraftItemDto,
} from './dto/generate-exam.dto';
import { ExamDraftListQueryDto, ExamListQueryDto } from './dto/exam-query.dto';
import { ExamResponseDto } from './dto/exam-response.dto';
import { ExamDraftItem } from './entities/exam-draft-item.entity';
import { ExamDraftSection } from './entities/exam-draft-section.entity';
import {
  ExamDraft,
  ExamDraftStatus,
  ExamMarkDistributionMode,
  ExamRoundingPolicy,
} from './entities/exam-draft.entity';
import {
  ExamExport,
  ExamExportFormat,
  ExamExportStatus,
} from './entities/exam-export.entity';
import { ExamItemSnapshot } from './entities/exam-item-snapshot.entity';
import { ExamItem } from './entities/exam-item.entity';
import {
  ExamPaperLayoutMode,
  ExamPaperTemplate,
} from './entities/exam-paper-template.entity';
import { ExamSection } from './entities/exam-section.entity';
import { Exam, ExamStatus } from './entities/exam.entity';

type PaginatedResult<T> = {
  data: T[];
  meta: { total: number; page: number; limit: number; totalPages: number };
};

type SelectedDraftItem = {
  questionId: number;
  chapterId: number;
  weight: number;
  weightUnits: number;
  marks: number | null;
  itemOrder: number;
  draftSectionId: number | null;
  sectionIndex: number | null;
  sourceGroupId?: number | null;
  sourceGroupItemOrder?: number | null;
  overrideReason?: string | null;
  originRuleJson?: Record<string, unknown> | null;
};

type AvailabilityBucket = {
  sectionIndex: number | null;
  sectionTitle: string | null;
  ruleIndex: number;
  required: number;
  available: number;
  canGenerate: boolean;
  scope: ExamGenerationScope;
  chapterIds: number[];
  groupIds: number[];
  questionType?: string | null;
  difficulty?: string | null;
  bloomLevel?: string | null;
  groupSelectionMode: ExamGroupSelectionMode;
  skippedGroupsTooLarge?: number;
  matchingGroupCount?: number;
  largestSkippedGroupSize?: number;
  filters?: Record<string, unknown>;
};

type ResolvedExamExportSettings = {
  studentNameLine: boolean;
  showCourseCode: boolean;
  pageBreakPerSection: boolean;
  showInstructorName: boolean;
  showTotalMarks: boolean;
  showQuestionMarks: boolean;
  answerKeyStyle: ExamAnswerKeyStyle;
  paperTemplateSnapshot?: Record<string, unknown> | null;
};

type ExamPaperElement = {
  type?: string;
  text?: string;
  token?: string;
  value?: string;
  zone?: string;
  x?: number;
  y?: number;
  width?: number;
  height?: number;
  bold?: boolean;
  italic?: boolean;
  align?: 'left' | 'center' | 'right';
  fontSize?: number;
};

@Injectable()
export class ExamsService {
  private readonly logger = new Logger(ExamsService.name);
  private supabase?: SupabaseClient;
  private questionImagesBucketName = 'question-images';
  private usePublicUrlsForQuestionImages = false;

  constructor(
    private readonly dataSource: DataSource,
    @InjectRepository(Course)
    private readonly courseRepo: Repository<Course>,
    @InjectRepository(CourseChapter)
    private readonly chapterRepo: Repository<CourseChapter>,
    @InjectRepository(QuestionBankQuestion)
    private readonly questionRepo: Repository<QuestionBankQuestion>,
    @InjectRepository(QuestionBankOption)
    private readonly optionRepo: Repository<QuestionBankOption>,
    @InjectRepository(QuestionBankFillBlank)
    private readonly blankRepo: Repository<QuestionBankFillBlank>,
    @InjectRepository(QuestionBankQuestionAttachment)
    private readonly attachmentRepo: Repository<QuestionBankQuestionAttachment>,
    @InjectRepository(QuestionBankQuestionGroup)
    private readonly groupRepo: Repository<QuestionBankQuestionGroup>,
    @InjectRepository(QuestionBankQuestionGroupItem)
    private readonly groupItemRepo: Repository<QuestionBankQuestionGroupItem>,
    @InjectRepository(ExamDraft)
    private readonly draftRepo: Repository<ExamDraft>,
    @InjectRepository(ExamDraftItem)
    private readonly draftItemRepo: Repository<ExamDraftItem>,
    @InjectRepository(ExamDraftSection)
    private readonly draftSectionRepo: Repository<ExamDraftSection>,
    @InjectRepository(Exam)
    private readonly examRepo: Repository<Exam>,
    @InjectRepository(ExamItem)
    private readonly examItemRepo: Repository<ExamItem>,
    @InjectRepository(ExamSection)
    private readonly examSectionRepo: Repository<ExamSection>,
    @InjectRepository(ExamItemSnapshot)
    private readonly snapshotRepo: Repository<ExamItemSnapshot>,
    @InjectRepository(ExamExport)
    private readonly exportRepo: Repository<ExamExport>,
    @InjectRepository(ExamPaperTemplate)
    private readonly paperTemplateRepo: Repository<ExamPaperTemplate>,
    private readonly instructorCourseAccess: InstructorCourseAccessService,
    @Optional()
    private readonly fileStorageService?: FileStorageService,
    @Optional()
    private readonly configService?: ConfigService,
  ) {
    const supabaseUrl = this.configService?.get<string>('SUPABASE_URL');
    const supabaseServiceRoleKey = this.configService?.get<string>(
      'SUPABASE_SERVICE_ROLE_KEY',
    );
    this.questionImagesBucketName =
      this.configService?.get<string>('SUPABASE_BUCKET_QUESTION_IMAGES') ||
      'question-images';
    this.usePublicUrlsForQuestionImages =
      this.configService?.get<string>('SUPABASE_QUESTION_IMAGES_PUBLIC') ===
      'true';

    if (supabaseUrl && supabaseServiceRoleKey) {
      this.supabase = createClient(supabaseUrl, supabaseServiceRoleKey);
    }
  }

  async listPaperTemplates(userId: number, courseId?: number) {
    if (courseId) {
      await this.instructorCourseAccess.assertInstructorOwnsCourse(
        userId,
        courseId,
      );
    }
    const query = this.paperTemplateRepo
      .createQueryBuilder('template')
      .where('template.ownerInstructorId = :userId', { userId })
      .orderBy('template.updatedAt', 'DESC');
    if (courseId) {
      query.andWhere(
        '(template.courseId IS NULL OR template.courseId = :courseId)',
        {
          courseId,
        },
      );
    }
    const templates = await query.getMany();
    return templates.map((template) => this.toPaperTemplateResponse(template));
  }

  async createPaperTemplate(userId: number, dto: SaveExamPaperTemplateDto) {
    if (dto.courseId) {
      await this.instructorCourseAccess.assertInstructorOwnsCourse(
        userId,
        dto.courseId,
      );
    }
    const template = this.paperTemplateRepo.create({
      ownerInstructorId: userId,
      courseId: dto.courseId ?? null,
      name: dto.name.trim(),
      layoutMode: dto.layoutMode ?? ExamPaperLayoutMode.STRUCTURED,
      pageSize: dto.pageSize || 'A4',
      orientation: dto.orientation || 'portrait',
      marginsJson: dto.marginsJson ?? null,
      headerJson: dto.headerJson ?? null,
      trailingJson: dto.trailingJson ?? null,
      footerJson: dto.footerJson ?? null,
    });
    return this.toPaperTemplateResponse(
      await this.paperTemplateRepo.save(template),
    );
  }

  async updatePaperTemplate(
    templateId: number,
    userId: number,
    dto: SaveExamPaperTemplateDto,
  ) {
    const template = await this.findPaperTemplateForOwner(templateId, userId);
    if (dto.courseId) {
      await this.instructorCourseAccess.assertInstructorOwnsCourse(
        userId,
        dto.courseId,
      );
    }
    Object.assign(template, {
      courseId: dto.courseId ?? null,
      name: dto.name.trim(),
      layoutMode: dto.layoutMode ?? template.layoutMode,
      pageSize: dto.pageSize || template.pageSize,
      orientation: dto.orientation || template.orientation,
      marginsJson: dto.marginsJson ?? null,
      headerJson: dto.headerJson ?? null,
      trailingJson: dto.trailingJson ?? null,
      footerJson: dto.footerJson ?? null,
    });
    return this.toPaperTemplateResponse(
      await this.paperTemplateRepo.save(template),
    );
  }

  async deletePaperTemplate(templateId: number, userId: number) {
    const template = await this.findPaperTemplateForOwner(templateId, userId);
    await this.paperTemplateRepo.remove(template);
  }

  async applyPaperTemplate(
    examId: number,
    userId: number,
    dto: ApplyExamPaperTemplateDto,
  ) {
    const exam = await this.findExamById(examId, userId);
    const snapshot = await this.resolvePaperTemplateSnapshot(exam, dto, userId);
    await this.examRepo.update(exam.id, {
      paperTemplateId: dto.paperTemplateId ?? null,
      paperTemplateSnapshotJson: snapshot as any,
    } as any);
    return {
      examId: exam.id,
      paperTemplateId: dto.paperTemplateId ?? null,
      paperTemplateSnapshot: snapshot,
    };
  }

  async findExams(
    userId: number,
    page: number = 1,
    limit: number = 20,
    filters: Pick<
      ExamListQueryDto,
      'courseId' | 'status' | 'dateFrom' | 'dateTo'
    > = {},
  ): Promise<PaginatedResult<ExamResponseDto>> {
    const courseIds = filters.courseId
      ? [filters.courseId]
      : await this.instructorCourseAccess.getInstructorCourseIds(userId);
    if (filters.courseId) {
      await this.instructorCourseAccess.assertInstructorOwnsCourse(
        userId,
        filters.courseId,
      );
    }
    if (!courseIds.length) {
      return this.emptyPage(page, limit);
    }

    const { safePage, safeLimit, skip } = this.normalizePagination(page, limit);
    const where: Record<string, unknown> = { courseId: In(courseIds) };
    if (filters.status) where.status = filters.status;
    this.applyCreatedAtFilter(where, filters.dateFrom, filters.dateTo);
    const [data, total] = await this.examRepo.findAndCount({
      where,
      order: { createdAt: 'DESC' },
      skip,
      take: safeLimit,
    });

    return this.page(
      data.map((exam) => this.toExamResponse(exam)),
      total,
      safePage,
      safeLimit,
    );
  }

  async findDrafts(
    userId: number,
    page: number = 1,
    limit: number = 20,
    filters: Pick<
      ExamDraftListQueryDto,
      'courseId' | 'status' | 'dateFrom' | 'dateTo'
    > = {},
  ): Promise<PaginatedResult<ExamDraft>> {
    const courseIds = filters.courseId
      ? [filters.courseId]
      : await this.instructorCourseAccess.getInstructorCourseIds(userId);
    if (filters.courseId) {
      await this.instructorCourseAccess.assertInstructorOwnsCourse(
        userId,
        filters.courseId,
      );
    }
    if (!courseIds.length) {
      return this.emptyPage(page, limit);
    }

    const { safePage, safeLimit, skip } = this.normalizePagination(page, limit);
    const where: Record<string, unknown> = { courseId: In(courseIds) };
    if (filters.status) where.status = filters.status;
    this.applyCreatedAtFilter(where, filters.dateFrom, filters.dateTo);
    const [data, total] = await this.draftRepo.findAndCount({
      where,
      order: { createdAt: 'DESC' },
      skip,
      take: safeLimit,
    });

    return this.page(data, total, safePage, safeLimit);
  }

  async findDraftById(draftId: number, userId: number): Promise<ExamDraft> {
    const draft = await this.draftRepo.findOne({
      where: { id: draftId },
      relations: [
        'items',
        'items.question',
        'items.question.file',
        'items.question.chapter',
        'items.question.options',
        'items.question.fillBlanks',
        'items.question.attachments',
        'items.question.attachments.file',
        'sections',
      ],
      order: {
        sections: { sectionOrder: 'ASC' },
        items: { itemOrder: 'ASC' },
      },
    });

    if (!draft) {
      throw new NotFoundException('Draft not found');
    }
    await this.instructorCourseAccess.assertInstructorOwnsCourse(
      userId,
      draft.courseId,
    );
    await this.markExpiredDraftIfNeeded(draft);
    await this.attachDraftItemContext(draft);
    return draft;
  }

  async generatePreview(dto: GenerateExamPreviewDto, userId: number) {
    this.logger.log(
      `Generating exam preview for course=${dto.courseId} user=${userId}`,
    );
    await this.ensureCourseExists(dto.courseId);
    await this.instructorCourseAccess.assertInstructorOwnsCourse(
      userId,
      dto.courseId,
    );

    const seed = dto.seed || randomUUID();
    const sections = dto.sections || [];
    const flatRules = dto.rules || [];
    if (!sections.length && !flatRules.length) {
      throw new BadRequestException('At least one rule or section is required');
    }
    await this.validateGenerationRequest(dto);

    const generated = await this.prepareGeneratedDraftItems(dto, seed);

    const draftId = await this.dataSource.transaction(async (manager) => {
      const draft = await manager.save(
        manager.create(ExamDraft, {
          courseId: dto.courseId,
          title: dto.title,
          generationRequestJson: dto as unknown as Record<string, unknown>,
          generatedBy: userId,
          seed,
          totalMarks: dto.totalMarks ?? generated.totalMarks,
          durationMinutes: dto.durationMinutes ?? null,
          instructions: dto.instructions || null,
          headerText: dto.headerText || null,
          footerText: dto.footerText || null,
          markDistributionMode:
            dto.markDistributionMode ||
            ExamMarkDistributionMode.WEIGHT_NORMALIZED,
          roundingPolicy: dto.roundingPolicy || ExamRoundingPolicy.NONE,
          status: ExamDraftStatus.OPEN,
          expiresAt: new Date(Date.now() + 1000 * 60 * 60 * 24),
        }),
      );

      const sectionIdByIndex = new Map<number, number>();
      for (const [index, section] of sections.entries()) {
        const savedSection = await manager.save(
          manager.create(ExamDraftSection, {
            draftId: draft.id,
            title: section.title,
            instructions: section.instructions || null,
            sectionOrder: index,
            totalMarks: section.totalMarks ?? null,
            answerPolicy: section.answerPolicy,
            requiredAnswerCount: section.requiredAnswerCount ?? null,
          }),
        );
        sectionIdByIndex.set(index, savedSection.id);
      }

      for (const item of generated.items) {
        await manager.save(
          manager.create(ExamDraftItem, {
            draftId: draft.id,
            draftSectionId:
              item.sectionIndex === null
                ? null
                : sectionIdByIndex.get(item.sectionIndex) || null,
            questionId: item.questionId,
            chapterId: item.chapterId,
            questionType: generated.questionMap.get(item.questionId)!
              .questionType,
            difficulty: generated.questionMap.get(item.questionId)!.difficulty,
            bloomLevel: generated.questionMap.get(item.questionId)!.bloomLevel,
            weight: item.weight,
            weightUnits: item.weightUnits,
            marks: item.marks,
            itemOrder: item.itemOrder,
            sourceGroupId: item.sourceGroupId ?? null,
            sourceGroupItemOrder: item.sourceGroupItemOrder ?? null,
            overrideReason: item.overrideReason,
            originRuleJson: item.originRuleJson ?? null,
          }),
        );
      }

      return draft.id;
    });

    const draft = await this.findDraftById(draftId, userId);
    this.logger.log(
      `Generated exam draft=${draft.id} course=${dto.courseId} questions=${draft.items.length}`,
    );
    return {
      draftId: draft.id,
      seed,
      totalQuestions: draft.items.length,
      totalWeight: draft.items.reduce(
        (sum, item) => sum + Number(item.weight),
        0,
      ),
      totalMarks: draft.totalMarks,
      sections: draft.sections,
      items: draft.items,
    };
  }

  async checkGenerationAvailability(
    dto: GenerateExamPreviewDto,
    userId: number,
  ): Promise<{
    totalRequired: number;
    totalAvailable: number;
    canGenerate: boolean;
    buckets: AvailabilityBucket[];
  }> {
    await this.ensureCourseExists(dto.courseId);
    await this.instructorCourseAccess.assertInstructorOwnsCourse(
      userId,
      dto.courseId,
    );
    const sections = dto.sections || [];
    const flatRules = dto.rules || [];
    if (!sections.length && !flatRules.length) {
      throw new BadRequestException('At least one rule or section is required');
    }
    await this.validateGenerationRequest(dto);
    const buckets = await this.buildAvailabilityBuckets(dto);
    return {
      totalRequired: buckets.reduce((sum, bucket) => sum + bucket.required, 0),
      totalAvailable: buckets.reduce(
        (sum, bucket) => sum + bucket.available,
        0,
      ),
      canGenerate: buckets.every((bucket) => bucket.canGenerate),
      buckets,
    };
  }

  async getExamStats(
    userId: number,
    courseId?: number,
  ): Promise<{
    drafts: number;
    openDrafts: number;
    expiringSoonDrafts: number;
    savedExams: number;
    publishedExams: number;
    archivedExams: number;
    approvedQuestionPool: number;
  }> {
    const courseIds = courseId
      ? [courseId]
      : await this.instructorCourseAccess.getInstructorCourseIds(userId);
    if (courseId) {
      await this.instructorCourseAccess.assertInstructorOwnsCourse(
        userId,
        courseId,
      );
    }
    if (!courseIds.length) {
      return {
        drafts: 0,
        openDrafts: 0,
        expiringSoonDrafts: 0,
        savedExams: 0,
        publishedExams: 0,
        archivedExams: 0,
        approvedQuestionPool: 0,
      };
    }
    const expiringBefore = new Date(Date.now() + 1000 * 60 * 60 * 2);
    const [
      drafts,
      openDrafts,
      expiringSoonDrafts,
      savedExams,
      publishedExams,
      archivedExams,
      approvedQuestionPool,
    ] = await Promise.all([
      this.draftRepo.count({ where: { courseId: In(courseIds) } }),
      this.draftRepo.count({
        where: { courseId: In(courseIds), status: ExamDraftStatus.OPEN },
      }),
      this.draftRepo.count({
        where: {
          courseId: In(courseIds),
          status: ExamDraftStatus.OPEN,
          expiresAt: LessThanOrEqual(expiringBefore),
        },
      }),
      this.examRepo.count({ where: { courseId: In(courseIds) } }),
      this.examRepo.count({
        where: { courseId: In(courseIds), status: ExamStatus.PUBLISHED },
      }),
      this.examRepo.count({
        where: { courseId: In(courseIds), status: ExamStatus.ARCHIVED },
      }),
      this.questionRepo.count({
        where: { courseId: In(courseIds), status: QuestionBankStatus.APPROVED },
      }),
    ]);
    return {
      drafts,
      openDrafts,
      expiringSoonDrafts,
      savedExams,
      publishedExams,
      archivedExams,
      approvedQuestionPool,
    };
  }

  async getGenerationReadiness(
    userId: number,
    courseId: number,
  ): Promise<{
    totalApproved: number;
    grouped: number;
    standalone: number;
    byChapter: Array<{ chapterId: number; chapterName: string; count: number }>;
    byType: Array<{ value: string; count: number }>;
    byDifficulty: Array<{ value: string; count: number }>;
    byBloom: Array<{ value: string; count: number }>;
  }> {
    await this.instructorCourseAccess.assertInstructorOwnsCourse(
      userId,
      courseId,
    );
    const base = this.questionRepo
      .createQueryBuilder('q')
      .leftJoin('q.groupItems', 'qgi')
      .where('q.course_id = :courseId', { courseId })
      .andWhere('q.status = :status', { status: QuestionBankStatus.APPROVED });

    const [totalApproved, grouped, byChapter, byType, byDifficulty, byBloom] =
      await Promise.all([
        base.clone().getCount(),
        base
          .clone()
          .andWhere('qgi.group_id IS NOT NULL')
          .groupBy('q.question_id')
          .getCount(),
        base
          .clone()
          .innerJoin(
            CourseChapter,
            'chapter',
            'chapter.chapter_id = q.chapter_id',
          )
          .select('q.chapter_id', 'chapterId')
          .addSelect('chapter.name', 'chapterName')
          .addSelect('COUNT(DISTINCT q.question_id)', 'count')
          .groupBy('q.chapter_id')
          .addGroupBy('chapter.name')
          .getRawMany<{
            chapterId: string;
            chapterName: string;
            count: string;
          }>(),
        base
          .clone()
          .select('q.question_type', 'value')
          .addSelect('COUNT(DISTINCT q.question_id)', 'count')
          .groupBy('q.question_type')
          .getRawMany<{ value: string; count: string }>(),
        base
          .clone()
          .select('q.difficulty', 'value')
          .addSelect('COUNT(DISTINCT q.question_id)', 'count')
          .groupBy('q.difficulty')
          .getRawMany<{ value: string; count: string }>(),
        base
          .clone()
          .select('q.bloom_level', 'value')
          .addSelect('COUNT(DISTINCT q.question_id)', 'count')
          .groupBy('q.bloom_level')
          .getRawMany<{ value: string; count: string }>(),
      ]);

    return {
      totalApproved,
      grouped,
      standalone: Math.max(totalApproved - grouped, 0),
      byChapter: byChapter.map((row) => ({
        chapterId: Number(row.chapterId),
        chapterName: row.chapterName,
        count: Number(row.count),
      })),
      byType: byType.map((row) => ({
        value: row.value,
        count: Number(row.count),
      })),
      byDifficulty: byDifficulty.map((row) => ({
        value: row.value,
        count: Number(row.count),
      })),
      byBloom: byBloom.map((row) => ({
        value: row.value,
        count: Number(row.count),
      })),
    };
  }

  async validateDraft(
    draftId: number,
    userId: number,
  ): Promise<{
    canSave: boolean;
    warnings: string[];
    errors: string[];
    checklist: Array<{
      key: string;
      status: 'ok' | 'warning' | 'error';
      message: string;
      action?: string | null;
    }>;
    totalQuestions: number;
    totalMarks: number | null;
    sectionSummaries: Array<{
      sectionId: number;
      title: string;
      itemCount: number;
      sectionMarks: number | null;
      itemMarksTotal: number;
      answerPolicy: string;
      requiredAnswerCount: number | null;
    }>;
  }> {
    const draft = await this.findDraftById(draftId, userId);
    const errors: string[] = [];
    const warnings: string[] = [];
    if (!draft.items.length) errors.push('Draft has no questions');
    if (draft.status !== ExamDraftStatus.OPEN)
      errors.push(`Draft is ${draft.status}`);
    if (draft.expiresAt.getTime() <= Date.now())
      errors.push('Draft has expired');
    const sectionSummaries = (draft.sections || []).map((section) => {
      const items = (draft.items || []).filter(
        (item) => Number(item.draftSectionId) === Number(section.id),
      );
      const itemMarksTotal = Number(
        items
          .reduce((sum, item) => sum + Number(item.marks || 0), 0)
          .toFixed(2),
      );
      if (!items.length)
        errors.push(`Section "${section.title}" has no questions`);
      if (
        section.totalMarks !== null &&
        section.totalMarks !== undefined &&
        section.answerPolicy !== 'answer_any' &&
        Math.abs(itemMarksTotal - Number(section.totalMarks)) > 0.01
      ) {
        warnings.push(
          `Section "${section.title}" item marks do not match section total`,
        );
      }
      return {
        sectionId: Number(section.id),
        title: section.title,
        itemCount: items.length,
        sectionMarks:
          section.totalMarks === null || section.totalMarks === undefined
            ? null
            : Number(section.totalMarks),
        itemMarksTotal,
        answerPolicy: section.answerPolicy,
        requiredAnswerCount: section.requiredAnswerCount ?? null,
      };
    });
    const sectionMarksMismatch = warnings.some((warning) =>
      warning.includes('item marks do not match section total'),
    );
    const unassignedCount = (draft.items || []).filter(
      (item) => !item.draftSectionId,
    ).length;
    const allQuestionsApproved = (draft.items || []).every(
      (item) => item.question?.status === QuestionBankStatus.APPROVED,
    );
    const groupedItems = (draft.items || []).filter(
      (item) => item.sourceGroupId,
    );
    const groupPromptsIncluded = groupedItems.every(
      (item) =>
        (item as unknown as Record<string, unknown>)['sourceGroupPrompt'] ||
        (item as unknown as Record<string, unknown>)['sourceGroupTitle'],
    );
    const imagesAccessible = (draft.items || []).every((item) => {
      const record = item as unknown as Record<string, unknown>;
      return (
        !item.question?.questionFileId || !!record['questionImagePreviewUrl']
      );
    });
    const checklist = [
      this.checklistItem(
        'hasQuestions',
        draft.items.length > 0,
        'Draft has questions',
        'Draft has no questions',
        'regenerate',
      ),
      this.checklistItem(
        'allSectionsHaveQuestions',
        !sectionSummaries.some((section) => section.itemCount === 0),
        'All sections have questions',
        'One or more sections have no questions',
        'addQuestion',
      ),
      this.checklistItem(
        'sectionMarksMatch',
        !sectionMarksMismatch,
        'Section marks match',
        'Some section item marks do not match section totals',
        'normalizeMarks',
        'warning',
      ),
      this.checklistItem(
        'allQuestionsApproved',
        allQuestionsApproved,
        'All questions are approved',
        'Some source questions are no longer approved',
        'openQuestionBank',
      ),
      this.checklistItem(
        'imagesAccessible',
        imagesAccessible,
        'Images are accessible',
        'One or more prompt images could not be previewed',
        'reviewImages',
        'warning',
      ),
      this.checklistItem(
        'groupPromptsIncluded',
        !groupedItems.length || groupPromptsIncluded,
        'Grouped prompts are included',
        'One or more grouped prompts are missing from the draft preview',
        'reloadDraft',
        'warning',
      ),
      this.checklistItem(
        'answerKeyReady',
        true,
        'Answer key data is available',
        'Answer key data is incomplete',
        null,
      ),
      this.checklistItem(
        'unassignedQuestions',
        unassignedCount === 0,
        'No unassigned questions',
        `${unassignedCount} question(s) are unassigned`,
        'moveUnassigned',
        'warning',
      ),
      this.checklistItem(
        'exportReady',
        errors.length === 0,
        'Export preview is ready',
        'Fix validation errors before export',
        'finalReview',
      ),
    ];
    return {
      canSave: errors.length === 0,
      warnings,
      errors,
      checklist,
      totalQuestions: draft.items.length,
      totalMarks: draft.totalMarks === null ? null : Number(draft.totalMarks),
      sectionSummaries,
    };
  }

  async regenerateDraft(
    draftId: number,
    userId: number,
    options: { seed?: string; keepManualEdits?: boolean } = {},
  ) {
    const draft = await this.findEditableDraft(draftId, userId);
    const request = {
      ...(draft.generationRequestJson as unknown as GenerateExamPreviewDto),
      seed: options.seed || randomUUID(),
    };
    const generated = await this.generatePreview(request, userId);
    let preservedManualEdits = 0;
    if (options.keepManualEdits) {
      preservedManualEdits = await this.copyManualDraftItems(
        draft,
        Number(generated.draftId),
      );
    }
    return {
      ...generated,
      preservedManualEdits,
      replacedGeneratedItems: Math.max(
        draft.items.length - preservedManualEdits,
        0,
      ),
      warnings: preservedManualEdits
        ? [`Preserved ${preservedManualEdits} manual edit(s)`]
        : [],
    };
  }

  async duplicateDraft(
    draftId: number,
    userId: number,
    dto: DuplicateDraftDto,
  ): Promise<ExamDraft> {
    const draft = await this.findDraftById(draftId, userId);
    const title = dto.title?.trim() || `${draft.title} Copy`;
    if (dto.regenerate) {
      const generated = await this.generatePreview(
        {
          ...(draft.generationRequestJson as unknown as GenerateExamPreviewDto),
          title,
          seed: dto.seed || randomUUID(),
        },
        userId,
      );
      return this.findDraftById(Number(generated.draftId), userId);
    }

    const newDraftId = await this.dataSource.transaction(async (manager) => {
      const copiedDraft = await manager.save(
        manager.create(ExamDraft, {
          courseId: draft.courseId,
          title,
          generationRequestJson: draft.generationRequestJson,
          generatedBy: userId,
          seed: dto.seed || `${draft.seed}-copy`,
          totalMarks: draft.totalMarks,
          durationMinutes: draft.durationMinutes,
          instructions: draft.instructions,
          headerText: draft.headerText,
          footerText: draft.footerText,
          studentNameLine: draft.studentNameLine,
          showCourseCode: draft.showCourseCode,
          pageBreakPerSection: draft.pageBreakPerSection,
          showInstructorName: draft.showInstructorName,
          answerKeyStyle: draft.answerKeyStyle,
          paperTemplateId: draft.paperTemplateId,
          paperTemplateSnapshotJson: draft.paperTemplateSnapshotJson,
          markDistributionMode: draft.markDistributionMode,
          roundingPolicy: draft.roundingPolicy,
          status: ExamDraftStatus.OPEN,
          expiresAt: new Date(Date.now() + 1000 * 60 * 60 * 24),
        }),
      );
      const sectionIdByOldId = new Map<number, number>();
      for (const section of draft.sections || []) {
        const copiedSection = await manager.save(
          manager.create(ExamDraftSection, {
            draftId: copiedDraft.id,
            title: section.title,
            instructions: section.instructions,
            sectionOrder: section.sectionOrder,
            totalMarks: section.totalMarks,
            answerPolicy: section.answerPolicy,
            requiredAnswerCount: section.requiredAnswerCount,
          }),
        );
        sectionIdByOldId.set(section.id, copiedSection.id);
      }
      for (const item of draft.items || []) {
        await manager.save(
          manager.create(ExamDraftItem, {
            draftId: copiedDraft.id,
            draftSectionId: item.draftSectionId
              ? sectionIdByOldId.get(item.draftSectionId) || null
              : null,
            questionId: item.questionId,
            chapterId: item.chapterId,
            questionType: item.questionType,
            difficulty: item.difficulty,
            bloomLevel: item.bloomLevel,
            weight: item.weight,
            weightUnits: item.weightUnits,
            marks: item.marks,
            itemOrder: item.itemOrder,
            sourceGroupId: item.sourceGroupId,
            sourceGroupItemOrder: item.sourceGroupItemOrder,
            overrideReason: item.overrideReason,
            originRuleJson: item.originRuleJson,
          }),
        );
      }
      return copiedDraft.id;
    });
    return this.findDraftById(newDraftId, userId);
  }

  async checkReplacement(
    draftId: number,
    itemId: number,
    dto: ReplacementCheckDto,
    userId: number,
  ): Promise<{
    matchesOriginalRules: boolean;
    reasons: string[];
    requiresOverrideReason: boolean;
  }> {
    const draft = await this.findEditableDraft(draftId, userId);
    const item = draft.items.find(
      (entry) => Number(entry.id) === Number(itemId),
    );
    if (!item) {
      throw new NotFoundException('Draft item not found');
    }
    const question = await this.questionRepo.findOne({
      where: { id: dto.replacementQuestionId },
      relations: ['groupItems'],
    });
    if (!question) {
      throw new NotFoundException('Replacement question not found');
    }
    if (Number(question.courseId) !== Number(draft.courseId)) {
      throw new BadRequestException(
        'Replacement question belongs to another course',
      );
    }
    const rule = (item.originRuleJson || {}) as Partial<ExamGenerationRuleDto>;
    const fallback: Partial<ExamGenerationRuleDto> = {
      chapterId: item.chapterId,
      questionType: item.questionType,
      difficulty: item.difficulty,
      bloomLevel: item.bloomLevel,
    };
    const effectiveRule = {
      ...fallback,
      ...rule,
    } as ExamGenerationRuleDto;
    const reasons: string[] = [];
    if (!this.questionMatchesGenerationRule(question, effectiveRule)) {
      reasons.push('Question does not match the original rule filters');
    }
    if (question.status !== QuestionBankStatus.APPROVED) {
      reasons.push('Question is not approved');
    }
    return {
      matchesOriginalRules: reasons.length === 0,
      reasons,
      requiresOverrideReason: reasons.length > 0,
    };
  }

  async reshuffleDraftSection(
    draftId: number,
    sectionId: number,
    userId: number,
    options: { seed?: string; keepManualEdits?: boolean } = {},
  ) {
    const draft = await this.findEditableDraft(draftId, userId);
    const sections = await this.draftSectionRepo.find({
      where: { draftId },
      order: { sectionOrder: 'ASC', id: 'ASC' },
    });
    const section = sections.find(
      (item) => Number(item.id) === Number(sectionId),
    );
    if (!section) {
      throw new NotFoundException('Draft section not found');
    }
    const request =
      draft.generationRequestJson as Partial<GenerateExamPreviewDto>;
    const sectionIndex = sections.findIndex(
      (item) => Number(item.id) === Number(sectionId),
    );
    const sectionRequest = request.sections?.[sectionIndex];
    if (!sectionRequest?.rules?.length) {
      throw new BadRequestException(
        'This section has no saved generation rules',
      );
    }
    const existingItems = await this.draftItemRepo.find({
      where: { draftId },
      order: { itemOrder: 'ASC', id: 'ASC' },
    });
    const selectedQuestionIds = new Set(
      existingItems
        .filter((item) => Number(item.draftSectionId) !== Number(sectionId))
        .map((item) => Number(item.questionId)),
    );
    const pickedItems: SelectedDraftItem[] = [];
    const seed = options.seed || randomUUID();
    for (const [ruleIndex, rule] of sectionRequest.rules.entries()) {
      const candidates = await this.findCandidateQuestions(
        draft.courseId,
        rule,
        request.groupSelectionMode || ExamGroupSelectionMode.INDEPENDENT,
        selectedQuestionIds,
      );
      const picked = this.pickCandidateQuestions(
        candidates,
        rule.count,
        `${seed}:section-reshuffle:${sectionId}:${ruleIndex}`,
        request.groupSelectionMode || ExamGroupSelectionMode.INDEPENDENT,
      );
      if (picked.length < rule.count) {
        throw new BadRequestException(
          'Not enough matching questions to reshuffle section',
        );
      }
      for (const candidate of picked) {
        selectedQuestionIds.add(candidate.questionId);
        pickedItems.push({
          questionId: candidate.questionId,
          chapterId: candidate.chapterId,
          weight: rule.weightPerQuestion,
          weightUnits: rule.weightPerQuestion,
          marks: null,
          itemOrder: 0,
          draftSectionId: sectionId,
          sectionIndex,
          sourceGroupId: candidate.sourceGroupId,
          sourceGroupItemOrder: candidate.sourceGroupItemOrder,
          originRuleJson: {
            ...rule,
            sectionIndex,
            sectionTitle: section.title,
            groupSelectionMode:
              request.groupSelectionMode || ExamGroupSelectionMode.INDEPENDENT,
          } as unknown as Record<string, unknown>,
        });
      }
    }
    this.applyMarks(
      pickedItems,
      Number(
        section.totalMarks ?? sectionRequest.totalMarks ?? pickedItems.length,
      ),
      request.markDistributionMode ||
        ExamMarkDistributionMode.WEIGHT_NORMALIZED,
      request.roundingPolicy || ExamRoundingPolicy.NONE,
    );
    const oldSectionItems = existingItems.filter(
      (item) => Number(item.draftSectionId) === Number(sectionId),
    );
    const insertionOrder = oldSectionItems.length
      ? Math.min(...oldSectionItems.map((item) => Number(item.itemOrder)))
      : existingItems.length;

    await this.dataSource.transaction(async (manager) => {
      if (oldSectionItems.length) {
        await manager.remove(ExamDraftItem, oldSectionItems);
      }
      const questions = await this.questionRepo.find({
        where: { id: In(pickedItems.map((item) => item.questionId)) },
      });
      const questionMap = new Map(
        questions.map((question) => [Number(question.id), question]),
      );
      await manager.save(
        pickedItems.map((item, index) => {
          const question = questionMap.get(item.questionId);
          if (!question) {
            throw new NotFoundException(
              `Question ${item.questionId} not found`,
            );
          }
          return manager.create(ExamDraftItem, {
            draftId,
            draftSectionId: sectionId,
            questionId: item.questionId,
            chapterId: item.chapterId,
            questionType: question.questionType,
            difficulty: question.difficulty,
            bloomLevel: question.bloomLevel,
            weight: item.weight,
            weightUnits: item.weightUnits,
            marks: item.marks,
            itemOrder: insertionOrder + index,
            sourceGroupId: item.sourceGroupId,
            sourceGroupItemOrder: item.sourceGroupItemOrder,
            overrideReason: null,
            originRuleJson: item.originRuleJson ?? null,
          });
        }),
      );
    });
    await this.compactDraftItemOrder(draftId);
    return this.findDraftById(draftId, userId);
  }

  async normalizeSectionMarks(
    draftId: number,
    sectionId: number,
    userId: number,
    dto: NormalizeSectionMarksDto,
  ): Promise<ExamDraftItem[]> {
    await this.findEditableDraft(draftId, userId);
    const section = await this.draftSectionRepo.findOne({
      where: { id: sectionId, draftId },
    });
    if (!section) {
      throw new NotFoundException('Draft section not found');
    }
    const items = await this.draftItemRepo.find({
      where: { draftId, draftSectionId: sectionId },
      order: { itemOrder: 'ASC', id: 'ASC' },
    });
    if (!items.length) {
      throw new BadRequestException(
        'Cannot normalize marks for an empty section',
      );
    }
    const totalMarks = dto.totalMarks ?? Number(section.totalMarks ?? 0);
    if (totalMarks <= 0) {
      throw new BadRequestException(
        'Section total marks must be greater than zero',
      );
    }
    const draftItems = items.map((item) => ({
      questionId: item.questionId,
      chapterId: item.chapterId,
      weight: Number(item.weight || item.weightUnits || item.marks || 1),
      weightUnits: Number(item.weightUnits || item.weight || 1),
      marks: item.marks === null ? null : Number(item.marks),
      itemOrder: item.itemOrder,
      draftSectionId: item.draftSectionId,
      sectionIndex: null,
      sourceGroupId: item.sourceGroupId,
      sourceGroupItemOrder: item.sourceGroupItemOrder,
    })) as SelectedDraftItem[];
    this.applyMarks(
      draftItems,
      totalMarks,
      ExamMarkDistributionMode.WEIGHT_NORMALIZED,
      ExamRoundingPolicy.NONE,
    );
    for (const [index, item] of items.entries()) {
      item.marks = draftItems[index].marks;
    }
    await this.draftItemRepo.save(items);
    if (
      section.totalMarks === null ||
      Number(section.totalMarks) !== totalMarks
    ) {
      section.totalMarks = totalMarks;
      await this.draftSectionRepo.save(section);
    }
    return items;
  }

  async createDraftSection(
    draftId: number,
    dto: CreateExamSectionDto,
    userId: number,
  ): Promise<ExamDraftSection> {
    const draft = await this.findEditableDraft(draftId, userId);
    const maxOrder = await this.draftSectionRepo
      .createQueryBuilder('section')
      .select('MAX(section.section_order)', 'maxOrder')
      .where('section.draft_id = :draftId', { draftId: draft.id })
      .getRawOne<{ maxOrder: string | null }>();
    return this.draftSectionRepo.save(
      this.draftSectionRepo.create({
        draftId: draft.id,
        title: dto.title,
        instructions: dto.instructions || null,
        sectionOrder: Number(maxOrder?.maxOrder ?? -1) + 1,
        totalMarks: dto.totalMarks ?? null,
        answerPolicy: dto.answerPolicy,
        requiredAnswerCount: dto.requiredAnswerCount ?? null,
      }),
    );
  }

  async updateDraftSection(
    draftId: number,
    sectionId: number,
    dto: UpdateExamSectionDto,
    userId: number,
  ): Promise<ExamDraftSection> {
    await this.findEditableDraft(draftId, userId);
    const section = await this.draftSectionRepo.findOne({
      where: { id: sectionId, draftId },
    });
    if (!section) {
      throw new NotFoundException('Draft section not found');
    }
    Object.assign(section, dto);
    return this.draftSectionRepo.save(section);
  }

  async deleteDraftSection(
    draftId: number,
    sectionId: number,
    userId: number,
  ): Promise<void> {
    await this.findEditableDraft(draftId, userId);
    const section = await this.draftSectionRepo.findOne({
      where: { id: sectionId, draftId },
    });
    if (!section) {
      throw new NotFoundException('Draft section not found');
    }
    await this.dataSource.transaction(async (manager) => {
      await manager.update(
        ExamDraftItem,
        { draftId, draftSectionId: sectionId },
        { draftSectionId: null },
      );
      await manager.remove(section);
    });
  }

  async reorderDraftSections(
    draftId: number,
    dto: ReorderExamSectionsDto,
    userId: number,
  ): Promise<ExamDraftSection[]> {
    await this.findEditableDraft(draftId, userId);
    await this.dataSource.transaction(async (manager) => {
      for (const item of dto.items) {
        await manager.update(
          ExamDraftSection,
          { id: item.sectionId, draftId },
          { sectionOrder: item.sectionOrder + 10000 },
        );
      }
      for (const item of dto.items) {
        await manager.update(
          ExamDraftSection,
          { id: item.sectionId, draftId },
          { sectionOrder: item.sectionOrder },
        );
      }
    });
    return this.draftSectionRepo.find({
      where: { draftId },
      order: { sectionOrder: 'ASC', id: 'ASC' },
    });
  }

  async addDraftItem(
    draftId: number,
    dto: AddDraftItemDto,
    userId: number,
  ): Promise<ExamDraftItem> {
    const draft = await this.findEditableDraft(draftId, userId);
    const question = await this.findApprovedQuestionForDraft(
      dto.questionId,
      draft.courseId,
    );
    if (dto.draftSectionId) {
      await this.ensureDraftSectionExists(draft.id, dto.draftSectionId);
    }
    this.assertQuestionMatchesDraftGeneration(
      draft,
      question,
      dto.draftSectionId ?? null,
      dto.overrideReason,
    );
    const maxOrder = await this.draftItemRepo
      .createQueryBuilder('item')
      .select('MAX(item.item_order)', 'maxOrder')
      .where('item.draft_id = :draftId', { draftId: draft.id })
      .getRawOne<{ maxOrder: string | null }>();
    const weight = dto.weightUnits ?? dto.marks ?? 1;
    const sourceGroup = await this.findPrimaryGroupItem(question.id);

    return this.draftItemRepo.save(
      this.draftItemRepo.create({
        draftId: draft.id,
        draftSectionId: dto.draftSectionId ?? null,
        questionId: question.id,
        chapterId: question.chapterId,
        questionType: question.questionType,
        difficulty: question.difficulty,
        bloomLevel: question.bloomLevel,
        weight,
        weightUnits: dto.weightUnits ?? weight,
        marks: dto.marks ?? null,
        itemOrder: Number(maxOrder?.maxOrder ?? -1) + 1,
        sourceGroupId: sourceGroup?.groupId ?? null,
        sourceGroupItemOrder: sourceGroup?.itemOrder ?? null,
        overrideReason: dto.overrideReason?.trim() || null,
      }),
    );
  }

  async updateDraftItem(
    draftId: number,
    itemId: number,
    dto: UpdateDraftItemDto,
    userId: number,
  ): Promise<ExamDraftItem> {
    const draft = await this.findEditableDraft(draftId, userId);
    const item = await this.draftItemRepo.findOne({
      where: { id: itemId, draftId },
    });
    if (!item) {
      throw new NotFoundException('Draft item not found');
    }

    if (dto.replacementQuestionId) {
      const question = await this.findApprovedQuestionForDraft(
        dto.replacementQuestionId,
        draft.courseId,
      );
      item.questionId = question.id;
      item.chapterId = question.chapterId;
      item.questionType = question.questionType;
      item.difficulty = question.difficulty;
      item.bloomLevel = question.bloomLevel;
      const sourceGroup = await this.findPrimaryGroupItem(question.id);
      item.sourceGroupId = sourceGroup?.groupId ?? null;
      item.sourceGroupItemOrder = sourceGroup?.itemOrder ?? null;
      this.assertQuestionMatchesDraftGeneration(
        draft,
        question,
        dto.draftSectionId === undefined
          ? item.draftSectionId
          : dto.draftSectionId,
        dto.overrideReason,
      );
      item.overrideReason = dto.overrideReason?.trim() || null;
    }
    if (dto.draftSectionId !== undefined && dto.draftSectionId !== null) {
      await this.ensureDraftSectionExists(draft.id, dto.draftSectionId);
      item.draftSectionId = dto.draftSectionId;
    } else if (dto.draftSectionId === null) {
      item.draftSectionId = null;
    }
    if (dto.weight !== undefined) item.weight = dto.weight;
    if (dto.weightUnits !== undefined) item.weightUnits = dto.weightUnits;
    if (dto.marks !== undefined) item.marks = dto.marks;
    if (dto.itemOrder !== undefined) item.itemOrder = dto.itemOrder;
    return this.draftItemRepo.save(item);
  }

  async removeDraftItem(
    draftId: number,
    itemId: number,
    userId: number,
  ): Promise<void> {
    await this.findEditableDraft(draftId, userId);
    const item = await this.draftItemRepo.findOne({
      where: { id: itemId, draftId },
    });
    if (!item) {
      throw new NotFoundException('Draft item not found');
    }
    const itemCount = await this.draftItemRepo.count({ where: { draftId } });
    if (itemCount <= 1) {
      throw new BadRequestException(
        'Cannot remove the last item from an open draft',
      );
    }
    await this.draftItemRepo.remove(item);
  }

  async reorderDraftItems(
    draftId: number,
    dto: ReorderDraftItemsDto,
    userId: number,
  ): Promise<ExamDraftItem[]> {
    await this.findEditableDraft(draftId, userId);
    const existingItems = await this.draftItemRepo.find({
      where: { draftId },
      select: ['id'],
    });
    this.assertFullDraftItemReorder(existingItems, dto);
    await this.dataSource.transaction(async (manager) => {
      for (const item of dto.items) {
        await manager.update(
          ExamDraftItem,
          { id: item.itemId, draftId },
          { itemOrder: item.itemOrder + 10000 },
        );
      }
      for (const item of dto.items) {
        await manager.update(
          ExamDraftItem,
          { id: item.itemId, draftId },
          { itemOrder: item.itemOrder },
        );
      }
    });
    return this.draftItemRepo.find({
      where: { draftId },
      order: { itemOrder: 'ASC', id: 'ASC' },
    });
  }

  async saveDraft(draftId: number, userId: number): Promise<Exam> {
    const draft = await this.draftRepo.findOne({
      where: { id: draftId },
      relations: ['items', 'sections'],
      order: {
        sections: { sectionOrder: 'ASC' },
        items: { itemOrder: 'ASC' },
      },
    });
    if (!draft) {
      throw new NotFoundException('Draft not found');
    }
    await this.instructorCourseAccess.assertInstructorOwnsCourse(
      userId,
      draft.courseId,
    );

    if (draft.status === ExamDraftStatus.FINALIZED && draft.finalizedExamId) {
      return this.findExamById(draft.finalizedExamId, userId);
    }
    this.assertDraftIsEditable(draft);
    if (!draft.items.length) {
      throw new BadRequestException('Cannot save a draft without items');
    }
    const validation = await this.validateDraft(draftId, userId);
    if (!validation.canSave) {
      throw new BadRequestException({
        message: 'Draft has validation errors',
        errors: validation.errors,
        warnings: validation.warnings,
      });
    }

    const examId = await this.dataSource.transaction(async (manager) => {
      const totalWeight = draft.items.reduce(
        (sum, item) => sum + Number(item.weight),
        0,
      );
      const itemMarksTotal = draft.items.reduce(
        (sum, item) => sum + Number(item.marks || 0),
        0,
      );
      const totalMarks = draft.totalMarks ?? (itemMarksTotal || null);
      const exam = await manager.save(
        manager.create(Exam, {
          courseId: draft.courseId,
          title: draft.title,
          totalWeight,
          totalMarks,
          durationMinutes: draft.durationMinutes,
          instructions: draft.instructions,
          headerText: draft.headerText,
          footerText: draft.footerText,
          studentNameLine: draft.studentNameLine,
          showCourseCode: draft.showCourseCode,
          pageBreakPerSection: draft.pageBreakPerSection,
          showInstructorName: draft.showInstructorName,
          answerKeyStyle: draft.answerKeyStyle,
          paperTemplateId: draft.paperTemplateId,
          paperTemplateSnapshotJson: draft.paperTemplateSnapshotJson,
          status: ExamStatus.DRAFT,
          createdBy: userId,
          snapshotJson: {
            draftId: draft.id,
            seed: draft.seed,
            generatedAt: draft.createdAt.toISOString(),
            savedAt: new Date().toISOString(),
          },
        }),
      );

      const sectionIdByDraftSectionId = new Map<number, number>();
      for (const section of draft.sections || []) {
        const savedSection = await manager.save(
          manager.create(ExamSection, {
            examId: exam.id,
            title: section.title,
            instructions: section.instructions,
            sectionOrder: section.sectionOrder,
            totalMarks: section.totalMarks,
            answerPolicy: section.answerPolicy,
            requiredAnswerCount: section.requiredAnswerCount,
          }),
        );
        sectionIdByDraftSectionId.set(section.id, savedSection.id);
      }

      for (const item of draft.items.sort(
        (a, b) => a.itemOrder - b.itemOrder,
      )) {
        const examItem = await manager.save(
          manager.create(ExamItem, {
            examId: exam.id,
            questionId: item.questionId,
            sectionId: item.draftSectionId
              ? sectionIdByDraftSectionId.get(item.draftSectionId) || null
              : null,
            weight: item.weight,
            weightUnits: item.weightUnits,
            marks: item.marks,
            itemOrder: item.itemOrder,
          }),
        );
        await this.createExamItemSnapshot(manager, examItem, item);
      }

      await manager.update(ExamDraft, draft.id, {
        status: ExamDraftStatus.FINALIZED,
        finalizedExamId: exam.id,
        finalizedBy: userId,
        finalizedAt: new Date(),
      });
      this.logger.log(`Saved draft=${draft.id} as exam=${exam.id}`);
      return exam.id;
    });

    return this.findExamById(examId, userId);
  }

  async publishExam(
    examId: number,
    dto: PublishExamDto,
    userId: number,
  ): Promise<Exam> {
    const exam = await this.findExamById(examId, userId);
    if (exam.status === ExamStatus.ARCHIVED) {
      throw new BadRequestException('Archived exams cannot be published');
    }
    await this.examRepo.update(exam.id, {
      status: ExamStatus.PUBLISHED,
      publishedBy: userId,
      publishedAt: new Date(),
      statusReason: dto.reason || null,
    });
    return this.findExamById(exam.id, userId);
  }

  async unpublishExam(
    examId: number,
    dto: UnpublishExamDto,
    userId: number,
  ): Promise<Exam> {
    const exam = await this.findExamById(examId, userId);
    if (exam.status === ExamStatus.ARCHIVED) {
      throw new BadRequestException('Archived exams cannot be unpublished');
    }
    await this.examRepo.update(exam.id, {
      status: ExamStatus.DRAFT,
      statusReason: dto.reason || null,
    });
    return this.findExamById(exam.id, userId);
  }

  async archiveExam(
    examId: number,
    dto: ArchiveExamDto,
    userId: number,
  ): Promise<Exam> {
    const exam = await this.findExamById(examId, userId);
    await this.examRepo.update(exam.id, {
      status: ExamStatus.ARCHIVED,
      archivedBy: userId,
      archivedAt: new Date(),
      statusReason: dto.reason || null,
    });
    return this.findExamById(exam.id, userId);
  }

  async findExamById(examId: number, userId: number): Promise<Exam> {
    const exam = await this.examRepo.findOne({
      where: { id: examId },
      relations: [
        'course',
        'items',
        'items.snapshot',
        'items.question',
        'sections',
      ],
      order: {
        sections: { sectionOrder: 'ASC' },
        items: { itemOrder: 'ASC' },
      },
    });
    if (!exam) {
      throw new NotFoundException('Exam not found');
    }
    await this.instructorCourseAccess.assertInstructorOwnsCourse(
      userId,
      exam.courseId,
    );
    return exam;
  }

  async getFullExamDetail(examId: number, userId: number) {
    const exam = await this.findExamById(examId, userId);
    const itemDtos = await Promise.all(
      (exam.items || [])
        .sort((a, b) => a.itemOrder - b.itemOrder)
        .map(async (item) => ({
          id: item.id,
          examId: item.examId,
          questionId: item.questionId,
          sectionId: item.sectionId,
          weight: item.weight,
          weightUnits: item.weightUnits,
          marks: item.marks,
          itemOrder: item.itemOrder,
          snapshot: await this.decorateSnapshotForPreview(item.snapshot),
        })),
    );
    return {
      ...this.toExamResponse(exam),
      durationMinutes: exam.durationMinutes,
      instructions: exam.instructions,
      headerText: exam.headerText,
      footerText: exam.footerText,
      studentNameLine: exam.studentNameLine,
      showCourseCode: exam.showCourseCode,
      pageBreakPerSection: exam.pageBreakPerSection,
      showInstructorName: exam.showInstructorName,
      answerKeyStyle: exam.answerKeyStyle,
      paperTemplateId: exam.paperTemplateId,
      paperTemplateSnapshot: exam.paperTemplateSnapshotJson,
      snapshot: exam.snapshotJson,
      seed:
        typeof exam.snapshotJson?.seed === 'string'
          ? exam.snapshotJson.seed
          : null,
      generatedAt:
        typeof exam.snapshotJson?.generatedAt === 'string'
          ? exam.snapshotJson.generatedAt
          : null,
      savedAt:
        typeof exam.snapshotJson?.savedAt === 'string'
          ? exam.snapshotJson.savedAt
          : null,
      statusReason: exam.statusReason,
      createdAt: exam.createdAt,
      snapshotCreatedAt: exam.createdAt,
      course: exam.course
        ? {
            id: exam.course.id,
            code: exam.course.code,
            name: exam.course.name,
          }
        : null,
      sections: (exam.sections || []).map((section) => ({
        id: section.id,
        examId: section.examId,
        title: section.title,
        instructions: section.instructions,
        sectionOrder: section.sectionOrder,
        totalMarks: section.totalMarks,
        answerPolicy: section.answerPolicy,
        requiredAnswerCount: section.requiredAnswerCount,
        items: itemDtos.filter(
          (item) => Number(item.sectionId) === Number(section.id),
        ),
      })),
      items: itemDtos,
    };
  }

  async exportExamAsWord(
    examId: number,
    dto: ExportExamDto | undefined,
    userId: number,
  ): Promise<{ fileName: string; mimeType: string; content: string }> {
    const exam = await this.findExamById(examId, userId);
    const includeAnswerKey =
      dto?.includeAnswerKey === true ||
      dto?.variant === ExamExportVariant.ANSWER_KEY ||
      dto?.variant === ExamExportVariant.COMBINED;
    const format = dto?.format || ExamExportFormat.HTML_DOC;
    const settings = this.resolveExportSettings(exam, dto);
    settings.paperTemplateSnapshot = await this.resolvePaperTemplateSnapshot(
      exam,
      {
        paperTemplateId: dto?.paperTemplateId,
        paperTemplateSnapshot: dto?.paperTemplateSnapshot,
      },
      userId,
    );
    if (dto) {
      await this.examRepo.update(exam.id, {
        studentNameLine: settings.studentNameLine ? 1 : 0,
        showCourseCode: settings.showCourseCode ? 1 : 0,
        pageBreakPerSection: settings.pageBreakPerSection ? 1 : 0,
        showInstructorName: settings.showInstructorName ? 1 : 0,
        answerKeyStyle: settings.answerKeyStyle,
        paperTemplateId: dto.paperTemplateId ?? exam.paperTemplateId ?? null,
        paperTemplateSnapshotJson: (settings.paperTemplateSnapshot ??
          null) as any,
      } as any);
      Object.assign(exam, {
        studentNameLine: settings.studentNameLine ? 1 : 0,
        showCourseCode: settings.showCourseCode ? 1 : 0,
        pageBreakPerSection: settings.pageBreakPerSection ? 1 : 0,
        showInstructorName: settings.showInstructorName ? 1 : 0,
        answerKeyStyle: settings.answerKeyStyle,
        paperTemplateId: dto.paperTemplateId ?? exam.paperTemplateId ?? null,
        paperTemplateSnapshotJson: settings.paperTemplateSnapshot ?? null,
      });
    }
    const content =
      format === ExamExportFormat.PDF
        ? await this.buildExamPdf(exam, includeAnswerKey, settings)
        : await this.buildExamDocx(exam, includeAnswerKey, settings);
    await this.exportRepo.save(
      this.exportRepo.create({
        examId: exam.id,
        format,
        status: ExamExportStatus.COMPLETED,
        requestedBy: userId,
        completedAt: new Date(),
      }),
    );
    this.logger.log(`Exported exam=${exam.id} format=${format} user=${userId}`);
    return {
      fileName:
        format === ExamExportFormat.PDF
          ? `exam-${exam.id}.pdf`
          : `exam-${exam.id}.docx`,
      mimeType:
        format === ExamExportFormat.PDF
          ? 'application/pdf'
          : 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      content: content.toString('base64'),
    };
  }

  private async prepareGeneratedDraftItems(
    dto: GenerateExamPreviewDto,
    seed: string,
  ): Promise<{
    items: SelectedDraftItem[];
    questionMap: Map<number, QuestionBankQuestion>;
    totalMarks: number | null;
  }> {
    const shortages: Array<Record<string, unknown>> = [];
    const selectedQuestionIds = new Set<number>();
    const selectedItems: SelectedDraftItem[] = [];
    const sectionInputs: Array<{
      section: ExamGenerationSectionDto | null;
      rules: ExamGenerationRuleDto[];
      sectionIndex: number | null;
    }> = dto.sections?.length
      ? dto.sections.map((section, index) => ({
          section,
          rules: section.rules,
          sectionIndex: index,
        }))
      : [{ section: null, rules: dto.rules || [], sectionIndex: null }];

    for (const entry of sectionInputs) {
      const sectionStartIndex = selectedItems.length;
      for (const [ruleIndex, rule] of entry.rules.entries()) {
        const candidates = await this.findCandidateQuestions(
          dto.courseId,
          rule,
          dto.groupSelectionMode || ExamGroupSelectionMode.INDEPENDENT,
          selectedQuestionIds,
        );

        if (candidates.length < rule.count) {
          const normalized = this.normalizeGenerationRule(rule);
          shortages.push({
            section: entry.section?.title ?? null,
            ruleIndex,
            scope: normalized.scope,
            chapterIds: normalized.chapterIds,
            groupIds: normalized.groupIds,
            groupSelectionMode:
              dto.groupSelectionMode || ExamGroupSelectionMode.INDEPENDENT,
            required: rule.count,
            available: candidates.length,
            questionType: rule.questionType ?? null,
            difficulty: rule.difficulty ?? null,
            bloomLevel: rule.bloomLevel ?? null,
          });
          continue;
        }

        const picked = this.pickCandidateQuestions(
          candidates,
          rule.count,
          `${seed}:${entry.sectionIndex ?? 'flat'}:${ruleIndex}:${JSON.stringify(
            this.normalizeGenerationRule(rule),
          )}`,
          dto.groupSelectionMode || ExamGroupSelectionMode.INDEPENDENT,
        );
        if (picked.length < rule.count) {
          const normalized = this.normalizeGenerationRule(rule);
          shortages.push({
            section: entry.section?.title ?? null,
            ruleIndex,
            scope: normalized.scope,
            chapterIds: normalized.chapterIds,
            groupIds: normalized.groupIds,
            groupSelectionMode:
              dto.groupSelectionMode || ExamGroupSelectionMode.INDEPENDENT,
            required: rule.count,
            available: picked.length,
            questionType: rule.questionType ?? null,
            difficulty: rule.difficulty ?? null,
            bloomLevel: rule.bloomLevel ?? null,
          });
          continue;
        }
        for (const candidate of picked) {
          selectedQuestionIds.add(candidate.questionId);
          selectedItems.push({
            questionId: candidate.questionId,
            chapterId: candidate.chapterId,
            weight: rule.weightPerQuestion,
            weightUnits: rule.weightPerQuestion,
            marks: null,
            itemOrder: selectedItems.length,
            draftSectionId: null,
            sectionIndex: entry.sectionIndex,
            sourceGroupId: candidate.sourceGroupId,
            sourceGroupItemOrder: candidate.sourceGroupItemOrder,
            originRuleJson: {
              ...rule,
              sectionIndex: entry.sectionIndex,
              sectionTitle: entry.section?.title ?? null,
              groupSelectionMode:
                dto.groupSelectionMode || ExamGroupSelectionMode.INDEPENDENT,
            } as unknown as Record<string, unknown>,
          });
        }
      }
      if (entry.section) {
        const sectionItems = selectedItems.slice(sectionStartIndex);
        this.applyMarks(
          sectionItems,
          entry.section.totalMarks,
          dto.markDistributionMode ||
            ExamMarkDistributionMode.WEIGHT_NORMALIZED,
          dto.roundingPolicy || ExamRoundingPolicy.NONE,
        );
      }
    }

    if (shortages.length) {
      this.logger.warn(
        `Exam generation shortage course=${dto.courseId} shortages=${JSON.stringify(
          shortages,
        )}`,
      );
      throw new BadRequestException({
        message: 'Insufficient question pool for one or more buckets',
        shortages,
      });
    }

    if (!dto.sections?.length && dto.totalMarks !== undefined) {
      this.applyMarks(
        selectedItems,
        dto.totalMarks,
        dto.markDistributionMode || ExamMarkDistributionMode.WEIGHT_NORMALIZED,
        dto.roundingPolicy || ExamRoundingPolicy.NONE,
      );
    } else if (!dto.sections?.length) {
      selectedItems.forEach((item) => {
        item.marks = item.weight;
      });
    }

    const questionEntities = await this.questionRepo.find({
      where: { id: In(Array.from(selectedQuestionIds)) },
    });
    const questionMap = new Map(questionEntities.map((q) => [Number(q.id), q]));

    return {
      items: selectedItems,
      questionMap,
      totalMarks:
        dto.totalMarks ??
        dto.sections?.reduce(
          (sum, section) => sum + Number(section.totalMarks || 0),
          0,
        ) ??
        null,
    };
  }

  private async buildAvailabilityBuckets(
    dto: GenerateExamPreviewDto,
  ): Promise<AvailabilityBucket[]> {
    const selectedQuestionIds = new Set<number>();
    const entries = dto.sections?.length
      ? dto.sections.map((section, sectionIndex) => ({
          section,
          rules: section.rules,
          sectionIndex,
        }))
      : [{ section: null, rules: dto.rules || [], sectionIndex: null }];
    const buckets: AvailabilityBucket[] = [];
    for (const entry of entries) {
      for (const [ruleIndex, rule] of entry.rules.entries()) {
        const candidates = await this.findCandidateQuestions(
          dto.courseId,
          rule,
          dto.groupSelectionMode || ExamGroupSelectionMode.INDEPENDENT,
          selectedQuestionIds,
        );
        const normalized = this.normalizeGenerationRule(rule);
        const groupFit = await this.analyzeGroupedRuleFit(
          dto.courseId,
          rule,
          selectedQuestionIds,
          rule.count,
          dto.groupSelectionMode || ExamGroupSelectionMode.INDEPENDENT,
        );
        const picked = this.pickCandidateQuestions(
          candidates,
          rule.count,
          `availability:${entry.sectionIndex ?? 'flat'}:${ruleIndex}`,
          dto.groupSelectionMode || ExamGroupSelectionMode.INDEPENDENT,
        );
        buckets.push({
          sectionIndex: entry.sectionIndex,
          sectionTitle: entry.section?.title ?? null,
          ruleIndex,
          required: rule.count,
          available: candidates.length,
          canGenerate: picked.length >= rule.count,
          scope: normalized.scope,
          chapterIds: normalized.chapterIds,
          groupIds: normalized.groupIds,
          questionType: rule.questionType ?? null,
          difficulty: rule.difficulty ?? null,
          bloomLevel: rule.bloomLevel ?? null,
          groupSelectionMode:
            dto.groupSelectionMode || ExamGroupSelectionMode.INDEPENDENT,
          skippedGroupsTooLarge: groupFit.skippedGroupsTooLarge,
          matchingGroupCount: groupFit.matchingGroupCount,
          largestSkippedGroupSize: groupFit.largestSkippedGroupSize,
          filters: {
            courseId: dto.courseId,
            chapterIds: normalized.chapterIds,
            groupIds: normalized.groupIds,
            questionType: rule.questionType ?? null,
            difficulty: rule.difficulty ?? null,
            bloomLevel: rule.bloomLevel ?? null,
            status: QuestionBankStatus.APPROVED,
          },
        });
        for (const candidate of picked) {
          selectedQuestionIds.add(candidate.questionId);
        }
      }
    }
    return buckets;
  }

  private async validateGenerationRequest(
    dto: GenerateExamPreviewDto,
  ): Promise<void> {
    const rules = dto.sections?.length
      ? dto.sections.flatMap((section) => section.rules)
      : dto.rules || [];
    for (const rule of rules) {
      const normalized = this.normalizeGenerationRule(rule);
      if (
        normalized.scope === ExamGenerationScope.GROUP &&
        dto.groupSelectionMode === ExamGroupSelectionMode.EXCLUDE_GROUPED
      ) {
        throw new BadRequestException(
          'Group scoped rules cannot exclude grouped questions',
        );
      }
      for (const chapterId of normalized.chapterIds) {
        await this.ensureChapterBelongsToCourse(dto.courseId, chapterId);
      }
      for (const groupId of normalized.groupIds) {
        await this.ensureGroupBelongsToCourse(dto.courseId, groupId);
      }
    }
  }

  private normalizeGenerationRule(rule: ExamGenerationRuleDto): {
    scope: ExamGenerationScope;
    chapterIds: number[];
    groupIds: number[];
  } {
    const scope =
      rule.scope ||
      (rule.groupIds?.length
        ? ExamGenerationScope.GROUP
        : rule.chapterIds?.length
          ? ExamGenerationScope.CHAPTERS
          : rule.chapterId
            ? ExamGenerationScope.CHAPTER
            : ExamGenerationScope.COURSE);
    const chapterIds =
      scope === ExamGenerationScope.CHAPTER
        ? [Number(rule.chapterId)]
        : scope === ExamGenerationScope.CHAPTERS
          ? [...new Set((rule.chapterIds || []).map(Number))]
          : [];
    const groupIds =
      scope === ExamGenerationScope.GROUP
        ? [...new Set((rule.groupIds || []).map(Number))]
        : [];
    if (scope === ExamGenerationScope.CHAPTER && !chapterIds[0]) {
      throw new BadRequestException('chapterId is required for chapter rules');
    }
    if (scope === ExamGenerationScope.CHAPTERS && !chapterIds.length) {
      throw new BadRequestException(
        'chapterIds are required for multi-chapter rules',
      );
    }
    if (scope === ExamGenerationScope.GROUP && !groupIds.length) {
      throw new BadRequestException('groupIds are required for group rules');
    }
    return { scope, chapterIds, groupIds };
  }

  private async findCandidateQuestions(
    courseId: number,
    rule: ExamGenerationRuleDto,
    groupSelectionMode: ExamGroupSelectionMode,
    selectedQuestionIds: Set<number>,
  ): Promise<
    Array<{
      questionId: number;
      chapterId: number;
      sourceGroupId: number | null;
      sourceGroupItemOrder: number | null;
    }>
  > {
    const normalized = this.normalizeGenerationRule(rule);
    if (groupSelectionMode === ExamGroupSelectionMode.KEEP_GROUP_TOGETHER) {
      return this.findGroupedCandidateQuestions(
        courseId,
        rule,
        selectedQuestionIds,
      );
    }

    const qb = this.questionRepo
      .createQueryBuilder('q')
      .select('q.question_id', 'questionId')
      .addSelect('q.chapter_id', 'chapterId')
      .addSelect('MIN(qgi.group_id)', 'sourceGroupId')
      .addSelect('MIN(qgi.item_order)', 'sourceGroupItemOrder')
      .leftJoin('q.groupItems', 'qgi')
      .where('q.course_id = :courseId', { courseId })
      .andWhere('q.status = :status', { status: QuestionBankStatus.APPROVED });

    if (normalized.scope === ExamGenerationScope.CHAPTER) {
      qb.andWhere('q.chapter_id = :chapterId', {
        chapterId: normalized.chapterIds[0],
      });
    } else if (normalized.scope === ExamGenerationScope.CHAPTERS) {
      qb.andWhere('q.chapter_id IN (:...chapterIds)', {
        chapterIds: normalized.chapterIds,
      });
    } else if (normalized.scope === ExamGenerationScope.GROUP) {
      qb.andWhere('qgi.group_id IN (:...groupIds)', {
        groupIds: normalized.groupIds,
      });
    }
    if (groupSelectionMode === ExamGroupSelectionMode.EXCLUDE_GROUPED) {
      qb.andWhere('qgi.group_id IS NULL');
    }
    this.applyRuleFilters(qb, rule);
    qb.groupBy('q.question_id').addGroupBy('q.chapter_id');

    const rows = await qb.getRawMany<{
      questionId: string;
      chapterId: string;
      sourceGroupId: string | null;
      sourceGroupItemOrder: string | null;
    }>();
    return rows
      .map((row) => ({
        questionId: Number(row.questionId),
        chapterId: Number(row.chapterId),
        sourceGroupId: row.sourceGroupId ? Number(row.sourceGroupId) : null,
        sourceGroupItemOrder: row.sourceGroupItemOrder
          ? Number(row.sourceGroupItemOrder)
          : null,
      }))
      .filter((candidate) => !selectedQuestionIds.has(candidate.questionId));
  }

  private async findGroupedCandidateQuestions(
    courseId: number,
    rule: ExamGenerationRuleDto,
    selectedQuestionIds: Set<number>,
  ): Promise<
    Array<{
      questionId: number;
      chapterId: number;
      sourceGroupId: number | null;
      sourceGroupItemOrder: number | null;
    }>
  > {
    const independent = await this.findCandidateQuestions(
      courseId,
      rule,
      ExamGroupSelectionMode.INDEPENDENT,
      selectedQuestionIds,
    );
    const grouped = independent.filter((candidate) => candidate.sourceGroupId);
    const ungrouped = independent.filter(
      (candidate) => !candidate.sourceGroupId,
    );
    const groupedByGroup = new Map<number, typeof grouped>();
    for (const candidate of grouped) {
      const groupId = candidate.sourceGroupId!;
      groupedByGroup.set(groupId, [
        ...(groupedByGroup.get(groupId) || []),
        candidate,
      ]);
    }
    const completeGroups: typeof grouped = [];
    for (const [groupId, candidates] of groupedByGroup.entries()) {
      const approvedCount = await this.groupItemRepo
        .createQueryBuilder('item')
        .innerJoin('item.question', 'question')
        .where('item.group_id = :groupId', { groupId })
        .andWhere('question.status = :status', {
          status: QuestionBankStatus.APPROVED,
        })
        .getCount();
      if (approvedCount === candidates.length) {
        completeGroups.push(
          ...candidates.sort(
            (a, b) =>
              Number(a.sourceGroupItemOrder || 0) -
              Number(b.sourceGroupItemOrder || 0),
          ),
        );
      }
    }
    return [...completeGroups, ...ungrouped];
  }

  private async analyzeGroupedRuleFit(
    courseId: number,
    rule: ExamGenerationRuleDto,
    selectedQuestionIds: Set<number>,
    requestedCount: number,
    groupSelectionMode: ExamGroupSelectionMode,
  ): Promise<{
    skippedGroupsTooLarge: number;
    matchingGroupCount: number;
    largestSkippedGroupSize: number;
  }> {
    if (groupSelectionMode !== ExamGroupSelectionMode.KEEP_GROUP_TOGETHER) {
      return {
        skippedGroupsTooLarge: 0,
        matchingGroupCount: 0,
        largestSkippedGroupSize: 0,
      };
    }
    const independent = await this.findCandidateQuestions(
      courseId,
      rule,
      ExamGroupSelectionMode.INDEPENDENT,
      selectedQuestionIds,
    );
    const groupedByGroup = new Map<number, number>();
    for (const candidate of independent) {
      if (!candidate.sourceGroupId) continue;
      groupedByGroup.set(
        candidate.sourceGroupId,
        (groupedByGroup.get(candidate.sourceGroupId) || 0) + 1,
      );
    }
    const sizes = [...groupedByGroup.values()];
    const tooLarge = sizes.filter((size) => size > requestedCount);
    return {
      skippedGroupsTooLarge: tooLarge.length,
      matchingGroupCount: sizes.length,
      largestSkippedGroupSize: tooLarge.length ? Math.max(...tooLarge) : 0,
    };
  }

  private pickCandidateQuestions(
    candidates: Array<{
      questionId: number;
      chapterId: number;
      sourceGroupId: number | null;
      sourceGroupItemOrder: number | null;
    }>,
    count: number,
    seed: string,
    groupSelectionMode: ExamGroupSelectionMode,
  ): Array<{
    questionId: number;
    chapterId: number;
    sourceGroupId: number | null;
    sourceGroupItemOrder: number | null;
  }> {
    if (groupSelectionMode !== ExamGroupSelectionMode.KEEP_GROUP_TOGETHER) {
      const shuffled = this.seededShuffle(
        candidates.map((candidate) => candidate.questionId),
        seed,
      );
      const byQuestionId = new Map(
        candidates.map((candidate) => [candidate.questionId, candidate]),
      );
      return shuffled
        .slice(0, count)
        .map((questionId) => byQuestionId.get(questionId))
        .filter(Boolean) as typeof candidates;
    }

    const ungrouped = candidates.filter(
      (candidate) => !candidate.sourceGroupId,
    );
    const groupedByGroup = new Map<number, typeof candidates>();
    for (const candidate of candidates.filter(
      (candidate) => candidate.sourceGroupId,
    )) {
      const groupId = candidate.sourceGroupId!;
      groupedByGroup.set(groupId, [
        ...(groupedByGroup.get(groupId) || []),
        candidate,
      ]);
    }
    const groupIds = this.seededShuffle([...groupedByGroup.keys()], seed);
    const selected: typeof candidates = [];
    for (const groupId of groupIds) {
      const block = [...(groupedByGroup.get(groupId) || [])].sort(
        (a, b) =>
          Number(a.sourceGroupItemOrder || 0) -
          Number(b.sourceGroupItemOrder || 0),
      );
      if (selected.length + block.length <= count) {
        selected.push(...block);
      }
      if (selected.length === count) return selected;
    }
    const remaining = count - selected.length;
    if (remaining > 0) {
      const shuffledUngrouped = this.seededShuffle(
        ungrouped.map((candidate) => candidate.questionId),
        `${seed}:ungrouped`,
      );
      const byQuestionId = new Map(
        ungrouped.map((candidate) => [candidate.questionId, candidate]),
      );
      selected.push(
        ...(shuffledUngrouped
          .slice(0, remaining)
          .map((questionId) => byQuestionId.get(questionId))
          .filter(Boolean) as typeof candidates),
      );
    }
    return selected.length === count ? selected : [];
  }

  private applyRuleFilters(
    qb: ReturnType<Repository<QuestionBankQuestion>['createQueryBuilder']>,
    rule: ExamGenerationRuleDto,
  ): void {
    if (rule.questionType) {
      qb.andWhere('q.question_type = :questionType', {
        questionType: rule.questionType,
      });
    }
    if (rule.difficulty) {
      qb.andWhere('q.difficulty = :difficulty', {
        difficulty: rule.difficulty,
      });
    }
    if (rule.bloomLevel) {
      qb.andWhere('q.bloom_level = :bloomLevel', {
        bloomLevel: rule.bloomLevel,
      });
    }
  }

  private applyMarks(
    items: SelectedDraftItem[],
    totalMarks: number,
    mode: ExamMarkDistributionMode,
    roundingPolicy: ExamRoundingPolicy,
  ): void {
    if (!items.length) {
      return;
    }

    if (mode === ExamMarkDistributionMode.MANUAL) {
      items.forEach((item) => {
        item.marks = this.roundMarks(item.weight, roundingPolicy);
      });
      return;
    }

    if (mode === ExamMarkDistributionMode.EQUAL) {
      const mark = this.roundMarks(totalMarks / items.length, roundingPolicy);
      items.forEach((item) => {
        item.marks = mark;
      });
      this.adjustLastItemToTotal(items, totalMarks);
      return;
    }

    const totalWeight = items.reduce(
      (sum, item) => sum + Number(item.weight || 0),
      0,
    );
    if (totalWeight <= 0) {
      throw new BadRequestException(
        'Total weight must be greater than zero for mark distribution',
      );
    }
    items.forEach((item) => {
      item.marks = this.roundMarks(
        (Number(item.weight) / totalWeight) * totalMarks,
        roundingPolicy,
      );
    });
    this.adjustLastItemToTotal(items, totalMarks);
  }

  private adjustLastItemToTotal(
    items: SelectedDraftItem[],
    totalMarks: number,
  ): void {
    const currentTotal = items.reduce(
      (sum, item) => sum + Number(item.marks || 0),
      0,
    );
    const delta = Number((totalMarks - currentTotal).toFixed(2));
    if (Math.abs(delta) > 0 && items.length) {
      const last = items[items.length - 1];
      last.marks = Number((Number(last.marks || 0) + delta).toFixed(2));
    }
  }

  private roundMarks(value: number, policy: ExamRoundingPolicy): number {
    const factorByPolicy: Record<ExamRoundingPolicy, number> = {
      [ExamRoundingPolicy.NONE]: 100,
      [ExamRoundingPolicy.NEAREST_0_25]: 4,
      [ExamRoundingPolicy.NEAREST_0_5]: 2,
      [ExamRoundingPolicy.NEAREST_1]: 1,
    };
    const factor = factorByPolicy[policy];
    return Number((Math.round(value * factor) / factor).toFixed(2));
  }

  private async createExamItemSnapshot(
    manager: EntityManager,
    examItem: ExamItem,
    draftItem: ExamDraftItem,
  ): Promise<void> {
    const question = await this.questionRepo.findOne({
      where: { id: draftItem.questionId },
      relations: [
        'file',
        'options',
        'fillBlanks',
        'attachments',
        'attachments.file',
      ],
    });
    if (!question) {
      throw new NotFoundException('Question not found for snapshot');
    }
    const version = await manager.findOne(QuestionBankQuestionVersion, {
      where: { questionId: question.id },
      order: { versionNumber: 'DESC' },
    });
    const groupItem = draftItem.sourceGroupId
      ? await this.groupItemRepo.findOne({
          where: {
            groupId: draftItem.sourceGroupId,
            questionId: question.id,
          },
          relations: ['group', 'group.sharedFile'],
        })
      : null;
    await manager.save(
      manager.create(ExamItemSnapshot, {
        examItemId: examItem.id,
        sourceQuestionId: question.id,
        sourceQuestionVersionId: version?.id ?? null,
        sectionId: examItem.sectionId,
        questionType: question.questionType,
        questionText: question.questionText,
        questionFileId: question.questionFileId,
        questionFileStoragePath: question.file?.filePath ?? null,
        questionFileCaption: question.questionFileCaption,
        questionFileAltText: question.questionFileAltText,
        sourceGroupId: groupItem?.groupId ?? draftItem.sourceGroupId ?? null,
        sourceGroupTitle: groupItem?.group?.title ?? null,
        sourceGroupType: groupItem?.group?.groupType ?? null,
        sourceGroupPrompt: groupItem?.group?.sharedPrompt ?? null,
        sourceGroupFileId: groupItem?.group?.sharedFileId ?? null,
        sourceGroupFileStoragePath:
          groupItem?.group?.sharedFile?.filePath ?? null,
        sourceGroupFileCaption: groupItem?.group?.sharedFileCaption ?? null,
        sourceGroupFileAltText: groupItem?.group?.sharedFileAltText ?? null,
        sourceGroupItemOrder:
          groupItem?.itemOrder ?? draftItem.sourceGroupItemOrder ?? null,
        optionsJson: (question.options || []).map((option) => ({
          optionId: option.id,
          optionText: option.optionText,
          isCorrect: option.isCorrect,
          optionOrder: option.optionOrder,
        })),
        fillBlanksJson: (question.fillBlanks || []).map((blank) => ({
          blankId: blank.id,
          blankKey: blank.blankKey,
          acceptableAnswer: blank.acceptableAnswer,
          isCaseSensitive: blank.isCaseSensitive,
        })),
        expectedAnswerText: question.expectedAnswerText,
        hints: question.hints,
        attachmentsJson: (question.attachments || []).map((attachment) => ({
          attachmentId: attachment.id,
          fileId: attachment.fileId,
          caption: attachment.caption,
          altText: attachment.altText,
          displayOrder: attachment.displayOrder,
          isPrimary: attachment.isPrimary,
          storagePath: attachment.storagePath,
        })),
        marks: draftItem.marks,
        itemOrder: draftItem.itemOrder,
      }),
    );
  }

  private buildExamHtml(
    exam: Exam,
    includeAnswerKey: boolean,
    settings: ResolvedExamExportSettings,
  ): string {
    const sectionsById = new Map(
      (exam.sections || []).map((section) => [section.id, section]),
    );
    const orderedItems = this.orderExamItemsForPaper(exam);
    const paperTemplate =
      settings.paperTemplateSnapshot || this.defaultPaperTemplateSnapshot(exam);
    const lines = [
      '<html><head><meta charset="utf-8">',
      '<style>',
      '@page { size: A4; margin: 16mm; }',
      'body { font-family: "Times New Roman", serif; color: #111; }',
      '.paper-header { border-bottom: 1px solid #111; padding-bottom: 8px; margin-bottom: 18px; }',
      '.paper-header-grid { width: 100%; border-collapse: collapse; }',
      '.paper-header-grid td { vertical-align: top; width: 33.33%; font-size: 11pt; line-height: 1.25; }',
      '.paper-header-center { text-align: center; }',
      '.paper-header-right { text-align: right; direction: rtl; }',
      '.paper-meta { width: 100%; border-collapse: collapse; border-top: 1px solid #111; margin-top: 8px; padding-top: 6px; }',
      '.paper-meta td { font-size: 10.5pt; padding-top: 3px; }',
      '.paper-free { position: relative; min-height: 1px; }',
      '.paper-free .paper-element { position: absolute; white-space: pre-wrap; }',
      '.paper-question { margin: 12px 0; page-break-inside: avoid; }',
      '.question-image { display:block; max-width: 520px; max-height: 320px; margin: 8px auto; }',
      '.paper-trailing { margin-top: 42px; text-align: center; font-size: 12pt; }',
      '.paper-examiners { margin-top: 54px; text-align: center; font-size: 10.5pt; }',
      'footer { margin-top: 42px; text-align: center; font-size: 9pt; mso-element:footer; }',
      '</style></head><body>',
      this.renderPaperHeaderHtml(exam, paperTemplate, settings),
    ].filter(Boolean);
    if (exam.durationMinutes) {
      lines.push(
        `<p>Duration: ${this.escapeHtml(String(exam.durationMinutes))} minutes</p>`,
      );
    }
    if (exam.instructions) {
      lines.push(`<p>${this.escapeHtml(exam.instructions)}</p>`);
    }
    let currentSectionId: number | null | undefined = undefined;
    let questionNumber = 1;
    for (const item of orderedItems) {
      if (item.sectionId !== currentSectionId) {
        currentSectionId = item.sectionId;
        const section = currentSectionId
          ? sectionsById.get(currentSectionId)
          : null;
        if (section) {
          if (settings.pageBreakPerSection && lines.length > 4) {
            lines.push('<div style="page-break-before: always;"></div>');
          }
          lines.push(`<h2>${this.escapeHtml(section.title)}</h2>`);
          if (
            settings.showTotalMarks &&
            section.totalMarks !== null &&
            section.totalMarks !== undefined
          ) {
            lines.push(
              `<p>Section Marks: ${this.escapeHtml(String(section.totalMarks))}</p>`,
            );
          }
          if (section.instructions) {
            lines.push(`<p>${this.escapeHtml(section.instructions)}</p>`);
          }
        }
      }
      const snapshot = item.snapshot;
      const questionText =
        snapshot?.questionText ||
        (item.question as QuestionBankQuestion | undefined)?.questionText ||
        '[Image Question]';
      lines.push('<div class="paper-question">');
      lines.push(
        `<p><strong>${questionNumber++}.</strong> ${this.escapeHtml(questionText)}</p>`,
      );
      if (snapshot?.questionFileStoragePath) {
        lines.push(
          this.renderHtmlImage(
            snapshot.questionFileStoragePath,
            snapshot.questionFileCaption || snapshot.questionFileAltText || '',
            snapshot.questionFileAltText || snapshot.questionFileCaption,
          ),
        );
      }
      if (settings.showQuestionMarks) {
        lines.push(
          `<p>Marks: ${this.escapeHtml(String(snapshot?.marks ?? item.marks ?? item.weight))}</p>`,
        );
      }
      const attachments = (snapshot?.attachmentsJson || []) as Array<{
        caption?: string | null;
        altText?: string | null;
        storagePath?: string | null;
        displayOrder?: number;
      }>;
      if (attachments.length) {
        lines.push('<ul>');
        for (const attachment of [...attachments].sort(
          (a, b) => Number(a.displayOrder || 0) - Number(b.displayOrder || 0),
        )) {
          const label =
            attachment.caption ||
            attachment.altText ||
            attachment.storagePath ||
            'Question attachment';
          const image = attachment.storagePath
            ? this.renderHtmlImage(
                attachment.storagePath,
                label,
                attachment.altText,
              )
            : null;
          lines.push(`<li>${image || this.escapeHtml(label)}</li>`);
        }
        lines.push('</ul>');
      }
      const options = (snapshot?.optionsJson || []) as Array<{
        optionText?: string;
        isCorrect?: number | boolean;
      }>;
      if (options.length) {
        lines.push('<ol type="A">');
        for (const option of options) {
          const marker =
            includeAnswerKey && Boolean(option.isCorrect) ? ' (correct)' : '';
          lines.push(
            `<li>${this.escapeHtml(`${option.optionText || ''}${marker}`)}</li>`,
          );
        }
        lines.push('</ol>');
      }
      if (includeAnswerKey) {
        const fillBlanks = (snapshot?.fillBlanksJson || []) as Array<{
          blankKey?: string;
          acceptableAnswer?: string;
        }>;
        if (fillBlanks.length) {
          lines.push('<ul>');
          for (const blank of fillBlanks) {
            lines.push(
              `<li>${this.escapeHtml(blank.blankKey || '')}: ${this.escapeHtml(blank.acceptableAnswer || '')}</li>`,
            );
          }
          lines.push('</ul>');
        }
        if (snapshot?.expectedAnswerText) {
          lines.push(
            `<p>Expected Answer: ${this.escapeHtml(snapshot.expectedAnswerText)}</p>`,
          );
        }
        if (snapshot?.hints) {
          lines.push(`<p>Hints: ${this.escapeHtml(snapshot.hints)}</p>`);
        }
      }
      lines.push('</div>');
    }
    lines.push(this.renderPaperTrailingHtml(exam, paperTemplate));
    lines.push(this.renderPaperFooterHtml(exam, paperTemplate));
    lines.push('</body></html>');
    return lines.join('\n');
  }

  private async buildExamDocx(
    exam: Exam,
    includeAnswerKey: boolean,
    settings: ResolvedExamExportSettings,
  ): Promise<Buffer> {
    const zip = new JSZip();
    const media: Array<{
      id: string;
      fileName: string;
      contentType: string;
      bytes: Buffer;
    }> = [];
    const nextImage = (storagePath: string): string | null => {
      const fullPath = this.resolveStoragePath(storagePath);
      if (!fullPath) return null;
      const bytes = fs.readFileSync(fullPath);
      const ext =
        path.extname(fullPath).toLowerCase().replace('.', '') || 'png';
      const contentType =
        ext === 'jpg' || ext === 'jpeg'
          ? 'image/jpeg'
          : ext === 'gif'
            ? 'image/gif'
            : 'image/png';
      const id = `rIdImage${media.length + 1}`;
      const fileName = `image${media.length + 1}.${ext === 'jpg' ? 'jpeg' : ext}`;
      media.push({ id, fileName, contentType, bytes });
      return id;
    };
    const sectionsById = new Map(
      (exam.sections || []).map((section) => [section.id, section]),
    );
    const orderedItems = this.orderExamItemsForPaper(exam);
    const paperTemplate =
      settings.paperTemplateSnapshot || this.defaultPaperTemplateSnapshot(exam);
    const body: string[] = [this.docxHeaderXml(exam, paperTemplate, settings)];
    let currentSectionId: number | null | undefined = undefined;
    let questionNumber = 1;
    for (const item of orderedItems) {
      if (item.sectionId !== currentSectionId) {
        currentSectionId = item.sectionId;
        const section = currentSectionId
          ? sectionsById.get(currentSectionId)
          : null;
        if (section) {
          body.push(
            this.docxParagraph(section.title, {
              heading: true,
              pageBreakBefore: settings.pageBreakPerSection && body.length > 1,
            }),
          );
          if (
            settings.showTotalMarks &&
            section.totalMarks !== null &&
            section.totalMarks !== undefined
          ) {
            body.push(
              this.docxParagraph(`Section Marks: ${section.totalMarks}`),
            );
          }
          if (section.instructions) {
            body.push(this.docxParagraph(section.instructions));
          }
        }
      }
      const snapshot = item.snapshot;
      const questionText =
        snapshot?.questionText ||
        (item.question as QuestionBankQuestion | undefined)?.questionText ||
        '[Image Question]';
      body.push(
        this.docxParagraph(`${questionNumber++}. ${questionText}`, {
          bold: true,
        }),
      );
      if (snapshot?.questionFileStoragePath) {
        const imageId = nextImage(snapshot.questionFileStoragePath);
        if (imageId) body.push(this.docxImageParagraph(imageId));
      }
      if (settings.showQuestionMarks) {
        body.push(
          this.docxParagraph(
            `Marks: ${snapshot?.marks ?? item.marks ?? item.weight}`,
          ),
        );
      }
      const attachments = (snapshot?.attachmentsJson || []) as Array<{
        caption?: string | null;
        altText?: string | null;
        storagePath?: string | null;
        displayOrder?: number;
      }>;
      for (const attachment of [...attachments].sort(
        (a, b) => Number(a.displayOrder || 0) - Number(b.displayOrder || 0),
      )) {
        if (attachment.storagePath) {
          const imageId = nextImage(attachment.storagePath);
          if (imageId) body.push(this.docxImageParagraph(imageId));
        }
      }
      const options = (snapshot?.optionsJson || []) as Array<{
        optionText?: string;
        isCorrect?: number | boolean;
      }>;
      const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
      options.forEach((option, index) => {
        const marker =
          includeAnswerKey && Boolean(option.isCorrect) ? ' (correct)' : '';
        body.push(
          this.docxParagraph(
            `${letters[index] || `${index + 1}`}. ${option.optionText || ''}${marker}`,
          ),
        );
      });
      if (includeAnswerKey) {
        const fillBlanks = (snapshot?.fillBlanksJson || []) as Array<{
          blankKey?: string;
          acceptableAnswer?: string;
        }>;
        for (const blank of fillBlanks) {
          body.push(
            this.docxParagraph(
              `${blank.blankKey || ''}: ${blank.acceptableAnswer || ''}`,
            ),
          );
        }
        if (snapshot?.expectedAnswerText) {
          body.push(
            this.docxParagraph(
              `Expected Answer: ${snapshot.expectedAnswerText}`,
            ),
          );
        }
        if (snapshot?.hints) {
          body.push(this.docxParagraph(`Hints: ${snapshot.hints}`));
        }
      }
    }
    body.push(this.docxTrailingXml(exam, paperTemplate));
    body.push(this.docxSectionProperties());
    const documentXml = this.docxDocumentXml(body.join(''));
    const footerXml = this.docxFooterXml(exam, paperTemplate);
    const rels = [
      '<Relationship Id="rIdFooter1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Target="footer1.xml"/>',
      ...media.map(
        (image) =>
          `<Relationship Id="${image.id}" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/${image.fileName}"/>`,
      ),
    ].join('');
    zip.file('[Content_Types].xml', this.docxContentTypesXml(media));
    zip.file(
      '_rels/.rels',
      '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/></Relationships>',
    );
    zip.file('word/document.xml', documentXml);
    zip.file('word/footer1.xml', footerXml);
    zip.file('word/styles.xml', this.docxStylesXml());
    zip.file('word/settings.xml', this.docxSettingsXml());
    zip.file(
      'word/_rels/document.xml.rels',
      `<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">${rels}</Relationships>`,
    );
    for (const image of media) {
      zip.file(`word/media/${image.fileName}`, image.bytes);
    }
    return zip.generateAsync({ type: 'nodebuffer' });
  }

  private docxDocumentXml(bodyXml: string): string {
    return `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing" xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture">
<w:body>${bodyXml}</w:body></w:document>`;
  }

  private docxContentTypesXml(
    media: Array<{ fileName: string; contentType: string }>,
  ): string {
    const imageTypes = [...new Set(media.map((image) => image.contentType))]
      .map((contentType) => {
        const extension =
          contentType === 'image/jpeg'
            ? 'jpeg'
            : contentType === 'image/gif'
              ? 'gif'
              : 'png';
        return `<Default Extension="${extension}" ContentType="${contentType}"/>`;
      })
      .join('');
    return `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
<Default Extension="xml" ContentType="application/xml"/>
${imageTypes}
<Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
<Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/>
<Override PartName="/word/settings.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.settings+xml"/>
<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml"/>
</Types>`;
  }

  private docxStylesXml(): string {
    return `<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:rPr><w:rFonts w:ascii="Arial" w:hAnsi="Arial" w:cs="Arial"/><w:sz w:val="22"/><w:szCs w:val="22"/></w:rPr></w:style>
</w:styles>`;
  }

  private docxSettingsXml(): string {
    return `<?xml version="1.0" encoding="UTF-8" standalone="yes"?><w:settings xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"><w:displayBackgroundShape/><w:compat/></w:settings>`;
  }

  private docxHeaderXml(
    exam: Exam,
    template: Record<string, unknown>,
    settings: ResolvedExamExportSettings,
  ): string {
    const header = this.asRecord(template.headerJson);
    const left = this.asArray(header.leftLines).map((line) =>
      this.resolvePaperElementText(exam, this.asElement(line)),
    );
    const normalizedLeft = left.length
      ? left
      : this.asArray(header.left).map((line) =>
          this.resolvePaperElementText(exam, this.asElement(line)),
        );
    const center = this.asArray(header.centerLines).map((line) =>
      this.resolvePaperElementText(exam, this.asElement(line)),
    );
    const normalizedCenter = center.length
      ? center
      : this.asArray(header.center).map((line) =>
          this.resolvePaperElementText(exam, this.asElement(line)),
        );
    const right = this.asArray(header.rightLines).map((line) =>
      this.resolvePaperElementText(exam, this.asElement(line)),
    );
    const normalizedRight = right.length
      ? right
      : this.asArray(header.right).map((line) =>
          this.resolvePaperElementText(exam, this.asElement(line)),
        );
    const metaLeft = this.asArray(header.metadataLeftLines).map((line) =>
      this.resolvePaperElementText(exam, this.asElement(line)),
    );
    const normalizedMetaLeft = metaLeft.length
      ? metaLeft
      : this.asArray(header.metadataLeft).map((line) =>
          this.resolvePaperElementText(exam, this.asElement(line)),
        );
    const metaRight = this.asArray(header.metadataRightLines).map((line) =>
      this.resolvePaperElementText(exam, this.asElement(line)),
    );
    const normalizedMetaRight = metaRight.length
      ? metaRight
      : this.asArray(header.metadataRight).map((line) =>
          this.resolvePaperElementText(exam, this.asElement(line)),
        );
    const rows = [
      this.docxThreeCellRow(normalizedLeft, normalizedCenter, normalizedRight),
      this.docxThreeCellRow(
        normalizedMetaLeft,
        [exam.title],
        normalizedMetaRight,
      ),
    ];
    const extraRows: string[] = [];
    if (settings.showTotalMarks && exam.totalMarks !== null) {
      extraRows.push(`Total Marks: ${exam.totalMarks}`);
    }
    if (settings.studentNameLine) {
      extraRows.push('Student Name: ____________________');
    }
    if (settings.showCourseCode) {
      extraRows.push(
        `Course: ${[exam.course?.code, exam.course?.name]
          .filter(Boolean)
          .join(' - ')}`,
      );
    }
    if (settings.showInstructorName) {
      extraRows.push('Instructor Name: ____________________');
    }
    return [
      `<w:tbl><w:tblPr><w:tblW w:w="0" w:type="auto"/><w:tblBorders><w:bottom w:val="single" w:sz="8" w:space="0" w:color="000000"/></w:tblBorders></w:tblPr>${rows.join('')}</w:tbl>`,
      ...extraRows.map((row) => this.docxParagraph(row)),
    ].join('');
  }

  private docxThreeCellRow(
    left: string[],
    center: string[],
    right: string[],
  ): string {
    return `<w:tr>${this.docxCell(left, 'left')}${this.docxCell(center, 'center')}${this.docxCell(right, 'right')}</w:tr>`;
  }

  private docxCell(
    lines: string[],
    align: 'left' | 'center' | 'right',
  ): string {
    const content = lines.length ? lines : [''];
    return `<w:tc><w:tcPr><w:tcW w:w="3120" w:type="dxa"/></w:tcPr>${content
      .map((line) =>
        this.docxParagraph(line, {
          align,
          rtl: align === 'right' || this.containsArabic(line),
        }),
      )
      .join('')}</w:tc>`;
  }

  private docxTrailingXml(
    exam: Exam,
    template: Record<string, unknown>,
  ): string {
    const trailing = this.asRecord(template.trailingJson);
    const lines: string[] = [];
    for (const raw of this.asArray(trailing.lines)) {
      lines.push(this.resolvePaperElementText(exam, this.asElement(raw)));
    }
    const examiners = String(trailing.examiners || exam.footerText || '');
    if (examiners) {
      lines.push(this.resolvePaperText(exam, examiners));
    }
    return lines
      .filter((line) => line.trim().length > 0)
      .map((line) => this.docxParagraph(line, { align: 'center' }))
      .join('');
  }

  private docxFooterXml(exam: Exam, template: Record<string, unknown>): string {
    const footer = this.asRecord(template.footerJson);
    const format = String(
      footer.pageNumberFormat || 'Page {page} of {totalPages}',
    );
    return `<?xml version="1.0" encoding="UTF-8" standalone="yes"?><w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"><w:p><w:pPr><w:jc w:val="center"/></w:pPr>${this.docxPageFieldRuns(exam, format)}</w:p></w:ftr>`;
  }

  private docxPageFieldRuns(exam: Exam, format: string): string {
    const resolved = this.resolvePaperText(exam, format, {
      page: '{page}',
      totalPages: '{totalPages}',
    });
    const parts = resolved.split(/(\{page\}|\{totalPages\})/g);
    return parts
      .map((part) => {
        if (part === '{page}') {
          return '<w:fldSimple w:instr="PAGE"><w:r><w:t>1</w:t></w:r></w:fldSimple>';
        }
        if (part === '{totalPages}') {
          return '<w:fldSimple w:instr="NUMPAGES"><w:r><w:t>1</w:t></w:r></w:fldSimple>';
        }
        return part ? this.docxRun(part) : '';
      })
      .join('');
  }

  private docxSectionProperties(): string {
    return '<w:sectPr><w:footerReference w:type="default" r:id="rIdFooter1"/><w:pgSz w:w="11906" w:h="16838"/><w:pgMar w:top="907" w:right="907" w:bottom="907" w:left="907" w:header="454" w:footer="454" w:gutter="0"/></w:sectPr>';
  }

  private docxParagraph(
    text: string,
    options: {
      align?: 'left' | 'center' | 'right';
      bold?: boolean;
      heading?: boolean;
      rtl?: boolean;
      pageBreakBefore?: boolean;
    } = {},
  ): string {
    const rtl = options.rtl || this.containsArabic(text);
    const align = options.align || (rtl ? 'right' : 'left');
    const pageBreak = options.pageBreakBefore ? '<w:pageBreakBefore/>' : '';
    const heading = options.heading
      ? '<w:spacing w:before="180" w:after="80"/><w:outlineLvl w:val="1"/>'
      : '';
    return `<w:p><w:pPr>${pageBreak}${heading}<w:jc w:val="${align}"/>${rtl ? '<w:bidi/>' : ''}</w:pPr>${this.docxRun(text, { bold: options.bold || options.heading, rtl })}</w:p>`;
  }

  private docxRun(
    text: string,
    options: { bold?: boolean; rtl?: boolean } = {},
  ): string {
    const rtl = options.rtl || this.containsArabic(text);
    return `<w:r><w:rPr><w:rFonts w:ascii="Arial" w:hAnsi="Arial" w:cs="Arial"/>${options.bold ? '<w:b/><w:bCs/>' : ''}${rtl ? '<w:rtl/>' : ''}</w:rPr><w:t xml:space="preserve">${this.escapeXml(text)}</w:t></w:r>`;
  }

  private docxImageParagraph(imageId: string): string {
    return `<w:p><w:pPr><w:jc w:val="center"/></w:pPr><w:r><w:drawing><wp:inline distT="0" distB="0" distL="0" distR="0"><wp:extent cx="3429000" cy="2286000"/><wp:docPr id="${imageId.replace(/\D/g, '') || '1'}" name="${imageId}"/><a:graphic><a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/picture"><pic:pic><pic:nvPicPr><pic:cNvPr id="0" name="${imageId}"/><pic:cNvPicPr/></pic:nvPicPr><pic:blipFill><a:blip r:embed="${imageId}"/><a:stretch><a:fillRect/></a:stretch></pic:blipFill><pic:spPr><a:xfrm><a:off x="0" y="0"/><a:ext cx="3429000" cy="2286000"/></a:xfrm><a:prstGeom prst="rect"><a:avLst/></a:prstGeom></pic:spPr></pic:pic></a:graphicData></a:graphic></wp:inline></w:drawing></w:r></w:p>`;
  }

  private escapeXml(value: string): string {
    return String(value)
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&apos;');
  }

  private containsArabic(value: string): boolean {
    return /[\u0600-\u06FF]/.test(value);
  }

  private orderExamItemsForPaper(exam: Exam): ExamItem[] {
    const items = [...(exam.items || [])];
    const bySection = new Map<number, ExamItem[]>();
    for (const item of items) {
      if (item.sectionId === null || item.sectionId === undefined) {
        continue;
      }
      const key = Number(item.sectionId);
      bySection.set(key, [...(bySection.get(key) || []), item]);
    }
    const sortItems = (a: ExamItem, b: ExamItem) =>
      Number(a.itemOrder) - Number(b.itemOrder) || Number(a.id) - Number(b.id);
    const consumedSections = new Set<number>();
    const blocks: { order: number; id: number; items: ExamItem[] }[] = [];
    for (const item of items.sort(sortItems)) {
      if (item.sectionId === null || item.sectionId === undefined) {
        blocks.push({
          order: Number(item.itemOrder),
          id: Number(item.id),
          items: [item],
        });
        continue;
      }
      const sectionId = Number(item.sectionId);
      if (consumedSections.has(sectionId)) continue;
      const sectionItems = (bySection.get(sectionId) || []).sort(sortItems);
      consumedSections.add(sectionId);
      blocks.push({
        order: sectionItems.length
          ? Number(sectionItems[0].itemOrder)
          : Number(item.itemOrder),
        id: sectionId,
        items: sectionItems,
      });
    }
    return blocks
      .sort((a, b) => a.order - b.order || a.id - b.id)
      .flatMap((block) => block.items);
  }

  private async buildExamPdf(
    exam: Exam,
    includeAnswerKey: boolean,
    settings: ResolvedExamExportSettings,
  ): Promise<Buffer> {
    const doc = new PDFDocument({ margin: 48, size: 'A4', bufferPages: true });
    this.registerExamPdfFonts(doc);
    const chunks: Buffer[] = [];
    doc.on('data', (chunk: Buffer) => chunks.push(chunk));
    const finished = new Promise<Buffer>((resolve, reject) => {
      doc.on('end', () => resolve(Buffer.concat(chunks)));
      doc.on('error', reject);
    });

    const sectionsById = new Map(
      (exam.sections || []).map((section) => [section.id, section]),
    );
    const orderedItems = this.orderExamItemsForPaper(exam);
    const paperTemplate =
      settings.paperTemplateSnapshot || this.defaultPaperTemplateSnapshot(exam);

    this.renderPaperHeaderPdf(doc, exam, paperTemplate, settings);
    doc.moveDown();

    let currentSectionId: number | null | undefined = undefined;
    let questionNumber = 1;
    for (const item of orderedItems) {
      if (item.sectionId !== currentSectionId) {
        currentSectionId = item.sectionId;
        const section = currentSectionId
          ? sectionsById.get(currentSectionId)
          : null;
        if (section) {
          if (settings.pageBreakPerSection && questionNumber > 1) {
            doc.addPage();
          }
          this.ensurePdfSpace(doc, 96);
          this.writePdfText(doc.moveDown(0.5).fontSize(15), section.title);
          doc.fontSize(10);
          if (
            settings.showTotalMarks &&
            section.totalMarks !== null &&
            section.totalMarks !== undefined
          ) {
            this.writePdfText(
              doc,
              `Section Marks: ${String(section.totalMarks)}`,
            );
          }
          if (section.instructions) {
            this.writePdfText(doc, section.instructions);
          }
          doc.moveDown(0.5);
        }
      }

      const snapshot = item.snapshot;
      this.ensurePdfSpace(doc, 140);
      const questionText =
        snapshot?.questionText ||
        (item.question as QuestionBankQuestion | undefined)?.questionText ||
        '[Image Question]';
      this.writePdfText(
        doc.fontSize(11),
        `${questionNumber++}. ${questionText}`,
      );
      if (snapshot?.questionFileStoragePath) {
        this.addPdfImage(
          doc,
          snapshot.questionFileStoragePath,
          snapshot.questionFileCaption || snapshot.questionFileAltText || '',
        );
      }
      if (settings.showQuestionMarks) {
        this.writePdfText(
          doc.fontSize(10),
          `Marks: ${String(snapshot?.marks ?? item.marks ?? item.weight)}`,
        );
      }

      const attachments = (snapshot?.attachmentsJson || []) as Array<{
        caption?: string | null;
        altText?: string | null;
        storagePath?: string | null;
        displayOrder?: number;
      }>;
      for (const attachment of [...attachments].sort(
        (a, b) => Number(a.displayOrder || 0) - Number(b.displayOrder || 0),
      )) {
        const label =
          attachment.caption ||
          attachment.altText ||
          attachment.storagePath ||
          'Question attachment';
        if (attachment.storagePath) {
          this.addPdfImage(doc, attachment.storagePath, label);
        } else {
          this.writePdfText(doc, `Attachment: ${label}`);
        }
      }

      const options = (snapshot?.optionsJson || []) as Array<{
        optionText?: string;
        isCorrect?: number | boolean;
      }>;
      options.forEach((option, index) => {
        const letter = String.fromCharCode(65 + index);
        const marker =
          includeAnswerKey && Boolean(option.isCorrect) ? ' (correct)' : '';
        this.writePdfText(
          doc,
          `${letter}. ${option.optionText || ''}${marker}`,
        );
      });

      if (includeAnswerKey) {
        const fillBlanks = (snapshot?.fillBlanksJson || []) as Array<{
          blankKey?: string;
          acceptableAnswer?: string;
        }>;
        for (const blank of fillBlanks) {
          this.writePdfText(
            doc,
            `${blank.blankKey || ''}: ${blank.acceptableAnswer || ''}`,
          );
        }
        if (snapshot?.expectedAnswerText) {
          this.writePdfText(
            doc,
            `Expected Answer: ${snapshot.expectedAnswerText}`,
          );
        }
        if (snapshot?.hints) {
          this.writePdfText(doc, `Hints: ${snapshot.hints}`);
        }
      }
      doc.moveDown();
    }
    this.renderPaperTrailingPdf(doc, exam, paperTemplate);
    this.renderPaperFooterPdf(doc, exam, paperTemplate);

    doc.end();
    return finished;
  }

  private ensurePdfSpace(doc: PDFKit.PDFDocument, minSpace: number): void {
    if (doc.y + minSpace > doc.page.height - doc.page.margins.bottom) {
      doc.addPage();
    }
  }

  private writePdfText(
    doc: PDFKit.PDFDocument,
    text: string,
    options: PDFKit.Mixins.TextOptions = {},
  ): void {
    const x = doc.page.margins.left;
    const width =
      doc.page.width - doc.page.margins.left - doc.page.margins.right;
    doc.text(text, x, doc.y, { width, ...options });
  }

  private registerExamPdfFonts(doc: PDFKit.PDFDocument): void {
    const regular = this.resolveSystemFontPath([
      'C:\\Windows\\Fonts\\arial.ttf',
      'C:\\Windows\\Fonts\\tahoma.ttf',
      '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',
      '/usr/share/fonts/truetype/liberation/LiberationSans-Regular.ttf',
    ]);
    const bold = this.resolveSystemFontPath([
      'C:\\Windows\\Fonts\\arialbd.ttf',
      'C:\\Windows\\Fonts\\tahomabd.ttf',
      '/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf',
      '/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf',
    ]);
    if (!regular) {
      return;
    }
    doc.registerFont('ExamRegular', regular);
    doc.registerFont('ExamBold', bold || regular);
    doc.font('ExamRegular');
  }

  private resolveSystemFontPath(candidates: string[]): string | null {
    return candidates.find((candidate) => fs.existsSync(candidate)) ?? null;
  }

  private addPdfImage(
    doc: PDFKit.PDFDocument,
    storagePath: string,
    label: string,
  ): void {
    const fullPath = this.resolveStoragePath(storagePath);
    if (!fullPath) {
      doc.fontSize(9).text(label);
      return;
    }
    try {
      this.ensurePdfSpace(doc, 180);
      doc.moveDown(0.25);
      doc.image(fullPath, { fit: [440, 180], align: 'center' });
      if (label.trim()) {
        this.writePdfText(doc.fontSize(9), label, { align: 'center' });
      }
      doc.moveDown(0.25);
    } catch (error) {
      this.logger.warn(`Could not embed exam image ${storagePath}: ${error}`);
      if (label.trim()) {
        this.writePdfText(doc.fontSize(9), label);
      }
    }
  }

  private renderHtmlImage(
    storagePath: string,
    label: string,
    altText?: string | null,
  ): string {
    const dataUri = this.storagePathToDataUri(storagePath);
    if (!dataUri) {
      return label.trim() ? `<p>${this.escapeHtml(label)}</p>` : '';
    }
    const escapedAlt = this.escapeHtml(altText || label);
    return [
      '<figure>',
      `<img class="question-image" src="${dataUri}" alt="${escapedAlt}" />`,
      label.trim() ? `<figcaption>${this.escapeHtml(label)}</figcaption>` : '',
      '</figure>',
    ]
      .filter(Boolean)
      .join('');
  }

  private async findPaperTemplateForOwner(
    templateId: number,
    userId: number,
  ): Promise<ExamPaperTemplate> {
    const template = await this.paperTemplateRepo.findOne({
      where: { id: templateId, ownerInstructorId: userId },
    });
    if (!template) {
      throw new NotFoundException('Paper template not found');
    }
    return template;
  }

  private toPaperTemplateResponse(template: ExamPaperTemplate) {
    return {
      id: template.id,
      templateId: template.id,
      ownerInstructorId: template.ownerInstructorId,
      courseId: template.courseId,
      name: template.name,
      layoutMode: template.layoutMode,
      pageSize: template.pageSize,
      orientation: template.orientation,
      marginsJson: template.marginsJson,
      headerJson: template.headerJson,
      trailingJson: template.trailingJson,
      footerJson: template.footerJson,
      createdAt: template.createdAt,
      updatedAt: template.updatedAt,
      snapshot: this.paperTemplateToSnapshot(template),
    };
  }

  private paperTemplateToSnapshot(
    template: ExamPaperTemplate,
  ): Record<string, unknown> {
    return {
      templateId: template.id,
      name: template.name,
      layoutMode: template.layoutMode,
      pageSize: template.pageSize,
      orientation: template.orientation,
      marginsJson: template.marginsJson,
      headerJson: template.headerJson,
      trailingJson: template.trailingJson,
      footerJson: template.footerJson,
      snapshottedAt: new Date().toISOString(),
    };
  }

  private async resolvePaperTemplateSnapshot(
    exam: Exam,
    dto: ApplyExamPaperTemplateDto,
    userId: number,
  ): Promise<Record<string, unknown> | null> {
    if (dto.paperTemplateSnapshot) {
      return dto.paperTemplateSnapshot;
    }
    if (dto.paperTemplateId) {
      const template = await this.findPaperTemplateForOwner(
        dto.paperTemplateId,
        userId,
      );
      if (
        template.courseId &&
        Number(template.courseId) !== Number(exam.courseId)
      ) {
        throw new BadRequestException(
          'Paper template does not belong to this course',
        );
      }
      return this.paperTemplateToSnapshot(template);
    }
    return (
      exam.paperTemplateSnapshotJson || this.defaultPaperTemplateSnapshot(exam)
    );
  }

  private defaultPaperTemplateSnapshot(exam: Exam): Record<string, unknown> {
    return {
      name: 'Alexandria paper style',
      layoutMode: ExamPaperLayoutMode.HYBRID,
      pageSize: 'A4',
      orientation: 'portrait',
      marginsJson: { top: 16, right: 16, bottom: 16, left: 16 },
      headerJson: {
        left: [
          {
            type: 'token',
            token: 'universityEnglish',
            value: 'Alexandria University',
            bold: true,
          },
          {
            type: 'token',
            token: 'facultyEnglish',
            value: 'Faculty of Engineering',
            bold: true,
          },
          { type: 'token', token: 'departmentEnglish', value: 'Department' },
        ],
        center: [
          { type: 'text', value: 'Alexandria University' },
          { type: 'text', value: '[Logo]' },
        ],
        right: [
          {
            type: 'token',
            token: 'universityArabic',
            value: 'جامعة الإسكندرية',
            bold: true,
          },
          {
            type: 'token',
            token: 'facultyArabic',
            value: 'كلية الهندسة',
            bold: true,
          },
          { type: 'token', token: 'departmentArabic', value: 'القسم' },
        ],
        metadataLeft: [
          { type: 'token', token: 'date', value: 'Date: {date}' },
          { type: 'token', token: 'courseName', value: '{courseName}' },
          {
            type: 'token',
            token: 'duration',
            value: 'Time allowed: {duration}',
          },
        ],
        metadataRight: [
          {
            type: 'token',
            token: 'academicYear',
            value: 'العام الجامعي: {academicYear}',
          },
          { type: 'token', token: 'courseCode', value: 'المادة: {courseCode}' },
          {
            type: 'token',
            token: 'durationArabic',
            value: 'الزمن: {duration}',
          },
        ],
        freeElements: [],
      },
      trailingJson: {
        lines: [
          { type: 'text', value: 'End of questions' },
          { type: 'text', value: 'Good Luck' },
        ],
        examiners: 'Examiners: ______________________________',
      },
      footerJson: {
        pageNumberFormat: 'Page {page} of {totalPages}',
      },
    };
  }

  private renderPaperHeaderHtml(
    exam: Exam,
    template: Record<string, unknown>,
    settings: ResolvedExamExportSettings,
  ): string {
    const header = this.asRecord(template.headerJson);
    const left = this.renderHeaderZoneHtml(
      exam,
      this.asArray(header.left),
      'left',
    );
    const center = this.renderHeaderZoneHtml(
      exam,
      this.asArray(header.center),
      'center',
    );
    const right = this.renderHeaderZoneHtml(
      exam,
      this.asArray(header.right),
      'right',
    );
    const metadataLeft = this.renderHeaderZoneHtml(
      exam,
      this.asArray(header.metadataLeft),
      'left',
    );
    const metadataRight = this.renderHeaderZoneHtml(
      exam,
      this.asArray(header.metadataRight),
      'right',
    );
    const free = this.renderFreeElementsHtml(
      exam,
      this.asArray(header.freeElements),
    );
    return [
      '<header class="paper-header">',
      '<table class="paper-header-grid"><tr>',
      `<td>${left}</td>`,
      `<td class="paper-header-center">${center}</td>`,
      `<td class="paper-header-right">${right}</td>`,
      '</tr></table>',
      `<div class="paper-free">${free}</div>`,
      '<table class="paper-meta"><tr>',
      `<td>${metadataLeft}</td>`,
      `<td style="text-align: center;">${this.escapeHtml(exam.title)}</td>`,
      `<td style="text-align: right; direction: rtl;">${metadataRight}</td>`,
      '</tr></table>',
      exam.instructions ? `<p>${this.escapeHtml(exam.instructions)}</p>` : '',
      settings.showTotalMarks
        ? `<p>Total Marks: ${this.escapeHtml(String(exam.totalMarks ?? exam.totalWeight ?? ''))}</p>`
        : '',
      settings.studentNameLine
        ? '<p>Student Name: ____________________</p>'
        : '',
      settings.showCourseCode
        ? `<p>Course: ${this.escapeHtml([exam.course?.code, exam.course?.name].filter(Boolean).join(' - '))}</p>`
        : '',
      settings.showInstructorName
        ? '<p>Instructor Name: ____________________</p>'
        : '',
      '</header>',
    ]
      .filter(Boolean)
      .join('\n');
  }

  private renderPaperTrailingHtml(
    exam: Exam,
    template: Record<string, unknown>,
  ): string {
    const trailing = this.asRecord(template.trailingJson);
    const lines = this.asArray(trailing.lines)
      .map((line) => this.renderPaperTextHtml(exam, this.asElement(line)))
      .join('');
    const examiners = String(trailing.examiners || exam.footerText || '');
    return [
      '<section class="paper-trailing">',
      lines,
      '</section>',
      examiners
        ? `<p class="paper-examiners">${this.escapeHtml(this.resolvePaperText(exam, examiners))}</p>`
        : '',
    ].join('\n');
  }

  private renderPaperFooterHtml(
    exam: Exam,
    template: Record<string, unknown>,
  ): string {
    const footer = this.asRecord(template.footerJson);
    const text = String(
      footer.pageNumberFormat || 'Page {page} of {totalPages}',
    );
    return `<footer>${this.escapeHtml(
      this.resolvePaperText(exam, text, { page: '1', totalPages: '1' }),
    )}</footer>`;
  }

  private renderHeaderZoneHtml(
    exam: Exam,
    items: unknown[],
    align: 'left' | 'center' | 'right',
  ): string {
    return items
      .map((item) =>
        this.renderPaperTextHtml(exam, { ...this.asElement(item), align }),
      )
      .join('');
  }

  private renderPaperTextHtml(exam: Exam, item: ExamPaperElement): string {
    if (item.type === 'line') {
      return '<hr />';
    }
    const text = this.resolvePaperElementText(exam, item);
    const styles = [
      item.bold ? 'font-weight:700' : '',
      item.italic ? 'font-style:italic' : '',
      item.align ? `text-align:${item.align}` : '',
      item.fontSize ? `font-size:${Number(item.fontSize)}pt` : '',
    ]
      .filter(Boolean)
      .join(';');
    return `<div style="${styles}">${this.escapeHtml(text)}</div>`;
  }

  private renderFreeElementsHtml(exam: Exam, elements: unknown[]): string {
    return elements
      .map((raw) => {
        const element = this.asElement(raw);
        const text = this.resolvePaperElementText(exam, element);
        const style = [
          `left:${Number(element.x || 0)}mm`,
          `top:${Number(element.y || 0)}mm`,
          element.width ? `width:${Number(element.width)}mm` : '',
          element.height ? `height:${Number(element.height)}mm` : '',
          element.bold ? 'font-weight:700' : '',
          element.italic ? 'font-style:italic' : '',
          element.fontSize ? `font-size:${Number(element.fontSize)}pt` : '',
          element.align ? `text-align:${element.align}` : '',
        ]
          .filter(Boolean)
          .join(';');
        return `<div class="paper-element" style="${style}">${this.escapeHtml(text)}</div>`;
      })
      .join('');
  }

  private renderPaperHeaderPdf(
    doc: PDFKit.PDFDocument,
    exam: Exam,
    template: Record<string, unknown>,
    settings: ResolvedExamExportSettings,
  ): void {
    const header = this.asRecord(template.headerJson);
    const top = doc.y;
    const leftX = doc.page.margins.left;
    const rightX = doc.page.width - doc.page.margins.right;
    const width = rightX - leftX;
    doc.font('ExamRegular').fontSize(10);
    this.drawPdfZone(
      doc,
      exam,
      this.asArray(header.left),
      leftX,
      top,
      width / 3,
      'left',
    );
    this.drawPdfZone(
      doc,
      exam,
      this.asArray(header.center),
      leftX + width / 3,
      top,
      width / 3,
      'center',
    );
    this.drawPdfZone(
      doc,
      exam,
      this.asArray(header.right),
      leftX + (width * 2) / 3,
      top,
      width / 3,
      'right',
    );
    doc.y = top + 70;
    doc.x = leftX;
    doc.moveTo(leftX, doc.y).lineTo(rightX, doc.y).stroke();
    doc.moveDown(0.35);
    const metaTop = doc.y;
    this.drawPdfZone(
      doc,
      exam,
      this.asArray(header.metadataLeft),
      leftX,
      metaTop,
      width / 3,
      'left',
    );
    doc.fontSize(10).text(exam.title, leftX + width / 3, metaTop, {
      width: width / 3,
      align: 'center',
    });
    this.drawPdfZone(
      doc,
      exam,
      this.asArray(header.metadataRight),
      leftX + (width * 2) / 3,
      metaTop,
      width / 3,
      'right',
    );
    doc.y = metaTop + 48;
    doc.x = leftX;
    if (exam.instructions) {
      this.writePdfText(doc.fontSize(10), exam.instructions);
    }
    if (settings.showTotalMarks) {
      this.writePdfText(
        doc.fontSize(10),
        `Total Marks: ${String(exam.totalMarks ?? exam.totalWeight ?? '')}`,
      );
    }
    if (settings.studentNameLine) {
      this.writePdfText(doc.fontSize(10), 'Student Name: ____________________');
    }
    if (settings.showCourseCode) {
      this.writePdfText(
        doc.fontSize(10),
        `Course: ${[exam.course?.code, exam.course?.name]
          .filter(Boolean)
          .join(' - ')}`,
      );
    }
    if (settings.showInstructorName) {
      this.writePdfText(
        doc.fontSize(10),
        'Instructor Name: ____________________',
      );
    }
    doc.moveTo(leftX, doc.y).lineTo(rightX, doc.y).stroke();
    doc.moveDown();
  }

  private drawPdfZone(
    doc: PDFKit.PDFDocument,
    exam: Exam,
    rawItems: unknown[],
    x: number,
    y: number,
    width: number,
    align: 'left' | 'center' | 'right',
  ): void {
    let currentY = y;
    for (const raw of rawItems) {
      const item = this.asElement(raw);
      const text = this.resolvePaperElementText(exam, item);
      doc.font(item.bold ? 'ExamBold' : 'ExamRegular');
      doc.fontSize(Number(item.fontSize || 10));
      doc.text(text, x, currentY, { width, align: item.align || align });
      currentY += Number(item.fontSize || 10) + 3;
    }
    doc.font('ExamRegular');
  }

  private renderPaperTrailingPdf(
    doc: PDFKit.PDFDocument,
    exam: Exam,
    template: Record<string, unknown>,
  ): void {
    const trailing = this.asRecord(template.trailingJson);
    this.ensurePdfSpace(doc, 120);
    doc.moveDown(2);
    for (const raw of this.asArray(trailing.lines)) {
      const text = this.resolvePaperElementText(exam, this.asElement(raw));
      doc.fontSize(12).text(text, { align: 'center' });
    }
    const examiners = String(trailing.examiners || exam.footerText || '');
    if (examiners) {
      doc
        .moveDown(3)
        .fontSize(10)
        .text(this.resolvePaperText(exam, examiners), {
          align: 'center',
        });
    }
  }

  private renderPaperFooterPdf(
    doc: PDFKit.PDFDocument,
    exam: Exam,
    template: Record<string, unknown>,
  ): void {
    const footer = this.asRecord(template.footerJson);
    const format = String(
      footer.pageNumberFormat || 'Page {page} of {totalPages}',
    );
    const range = doc.bufferedPageRange();
    for (let i = range.start; i < range.start + range.count; i++) {
      doc.switchToPage(i);
      const pageNumber = i - range.start + 1;
      const text = this.resolvePaperText(exam, format, {
        page: String(pageNumber),
        totalPages: String(range.count),
      });
      const footerY = doc.page.height - doc.page.margins.bottom - 12;
      doc
        .font('ExamRegular')
        .fontSize(8)
        .text(text, doc.page.margins.left, footerY, {
          width:
            doc.page.width - doc.page.margins.left - doc.page.margins.right,
          align: 'center',
          lineBreak: false,
        });
    }
  }

  private resolvePaperElementText(exam: Exam, item: ExamPaperElement): string {
    return this.resolvePaperText(
      exam,
      String(item.value ?? item.text ?? (item.token ? `{${item.token}}` : '')),
    );
  }

  private resolvePaperText(
    exam: Exam,
    value: string,
    overrides: Record<string, string> = {},
  ): string {
    const courseCode = exam.course?.code || '';
    const courseName = exam.course?.name || exam.title;
    const duration = exam.durationMinutes
      ? `${exam.durationMinutes} minutes`
      : '';
    const now = new Date();
    const academicYear = `${now.getFullYear()}/${now.getFullYear() + 1}`;
    const replacements: Record<string, string> = {
      courseCode,
      courseName,
      examTitle: exam.title,
      duration,
      totalMarks: String(exam.totalMarks ?? exam.totalWeight ?? ''),
      date: now.toISOString().slice(0, 10),
      academicYear,
      page: '1',
      totalPages: '{totalPages}',
      ...overrides,
      universityEnglish: 'Alexandria University',
      facultyEnglish: 'Faculty of Engineering',
      departmentEnglish: '',
      universityArabic: 'جامعة الإسكندرية',
      facultyArabic: 'كلية الهندسة',
      departmentArabic: '',
    };
    return value.replace(/\{([A-Za-z0-9_]+)\}/g, (_, key: string) => {
      return replacements[key] ?? `{${key}}`;
    });
  }

  private asRecord(value: unknown): Record<string, unknown> {
    return value && typeof value === 'object' && !Array.isArray(value)
      ? (value as Record<string, unknown>)
      : {};
  }

  private asArray(value: unknown): unknown[] {
    return Array.isArray(value) ? value : [];
  }

  private asElement(value: unknown): ExamPaperElement {
    return this.asRecord(value) as ExamPaperElement;
  }

  private async decorateSnapshotForPreview(snapshot: ExamItemSnapshot | null) {
    if (!snapshot) {
      return null;
    }
    const attachments = (snapshot.attachmentsJson || []) as Array<
      Record<string, unknown> & { storagePath?: string | null }
    >;
    const attachmentPreviews = await Promise.all(
      attachments.map(async (attachment) => ({
        ...attachment,
        previewUrl: await this.questionImagePreviewUrl(
          this.toOptionalNumber(attachment.fileId),
          attachment.storagePath,
        ),
      })),
    );
    return {
      ...snapshot,
      snapshotCreatedAt: snapshot.createdAt,
      questionImagePreviewUrl: await this.questionImagePreviewUrl(
        snapshot.questionFileId,
        snapshot.questionFileStoragePath,
      ),
      sourceGroupImagePreviewUrl: await this.questionImagePreviewUrl(
        snapshot.sourceGroupFileId,
        snapshot.sourceGroupFileStoragePath,
      ),
      attachmentsJson: attachmentPreviews,
    };
  }

  private resolveExportSettings(
    exam: Exam,
    dto?: ExportExamDto,
  ): ResolvedExamExportSettings {
    return {
      studentNameLine:
        dto?.studentNameLine ?? Boolean(Number(exam.studentNameLine ?? 1)),
      showCourseCode:
        dto?.showCourseCode ?? Boolean(Number(exam.showCourseCode ?? 1)),
      pageBreakPerSection:
        dto?.pageBreakPerSection ??
        Boolean(Number(exam.pageBreakPerSection ?? 0)),
      showInstructorName:
        dto?.showInstructorName ??
        Boolean(Number(exam.showInstructorName ?? 0)),
      showTotalMarks: dto?.showTotalMarks ?? true,
      showQuestionMarks: dto?.showQuestionMarks ?? true,
      answerKeyStyle:
        dto?.answerKeyStyle ||
        ((exam.answerKeyStyle as ExamAnswerKeyStyle | null) ??
          ExamAnswerKeyStyle.INLINE),
    };
  }

  private storagePathToDataUri(storagePath: string): string | null {
    const fullPath = this.resolveStoragePath(storagePath);
    if (!fullPath) {
      return null;
    }
    try {
      const extension = path.extname(fullPath).toLowerCase();
      const mimeType =
        extension === '.jpg' || extension === '.jpeg'
          ? 'image/jpeg'
          : extension === '.png'
            ? 'image/png'
            : extension === '.gif'
              ? 'image/gif'
              : extension === '.webp'
                ? 'image/webp'
                : null;
      if (!mimeType) {
        return null;
      }
      const bytes = fs.readFileSync(fullPath);
      return `data:${mimeType};base64,${bytes.toString('base64')}`;
    } catch (error) {
      this.logger.warn(`Could not read exam image ${storagePath}: ${error}`);
      return null;
    }
  }

  private async questionImagePreviewUrl(
    fileId?: number | string | null,
    storagePath?: string | null,
    mimeType?: string | null,
  ): Promise<string | null> {
    const signedUrl = await this.createQuestionImageUrl(
      fileId,
      storagePath,
      mimeType,
    );
    if (signedUrl) {
      return signedUrl;
    }
    return storagePath ? this.storagePathToDataUri(storagePath) : null;
  }

  private async createQuestionImageUrl(
    fileId?: number | string | null,
    storagePath?: string | null,
    mimeType?: string | null,
  ): Promise<string | null> {
    const questionStoragePath = this.buildQuestionImageStoragePath(
      fileId,
      storagePath,
      mimeType,
    );
    if (!this.supabase || !questionStoragePath) {
      return null;
    }

    try {
      if (this.usePublicUrlsForQuestionImages) {
        const { data } = this.supabase.storage
          .from(this.questionImagesBucketName)
          .getPublicUrl(questionStoragePath);
        return data.publicUrl || null;
      }

      const { data, error } = await this.supabase.storage
        .from(this.questionImagesBucketName)
        .createSignedUrls([questionStoragePath], 60 * 60);
      if (error || !data?.[0]?.signedUrl) {
        return null;
      }
      return data[0].signedUrl;
    } catch (error) {
      this.logger.warn(
        `Could not create exam image preview URL ${questionStoragePath}: ${error}`,
      );
      return null;
    }
  }

  private buildQuestionImageStoragePath(
    fileId?: number | string | null,
    storagePath?: string | null,
    mimeType?: string | null,
  ): string | null {
    if (storagePath?.includes('question-bank/files/')) {
      return storagePath.slice(storagePath.indexOf('question-bank/files/'));
    }

    const normalizedFileId = this.toOptionalNumber(fileId);
    if (!normalizedFileId) {
      return null;
    }

    const extension =
      this.getExtensionFromMimeType(mimeType || '') ||
      this.getExtensionFromStoragePath(storagePath || '') ||
      'jpg';
    return `question-bank/files/${normalizedFileId}.${extension}`;
  }

  private getExtensionFromMimeType(mimeType: string): string | null {
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
        return null;
    }
  }

  private getExtensionFromStoragePath(storagePath: string): string | null {
    const extension = path.extname(storagePath).toLowerCase().replace('.', '');
    return ['jpg', 'jpeg', 'png', 'webp', 'gif'].includes(extension)
      ? extension.replace('jpeg', 'jpg')
      : null;
  }

  private toOptionalNumber(value: unknown): number | null {
    if (value === null || value === undefined || value === '') {
      return null;
    }
    const numeric = Number(value);
    return Number.isFinite(numeric) && numeric > 0 ? numeric : null;
  }

  private resolveStoragePath(storagePath: string): string | null {
    if (!this.fileStorageService || !storagePath) {
      return null;
    }
    const fullPath = path.resolve(
      this.fileStorageService.getStoragePath(),
      storagePath,
    );
    const rootPath = path.resolve(this.fileStorageService.getStoragePath());
    if (!fullPath.startsWith(rootPath) || !fs.existsSync(fullPath)) {
      return null;
    }
    return fullPath;
  }

  private escapeHtml(value: string): string {
    return value
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&#039;');
  }

  private async attachDraftItemContext(draft: ExamDraft): Promise<void> {
    const items = draft.items || [];
    if (!items.length) {
      return;
    }

    const questionIds = items.map((item) => Number(item.questionId));
    const versionRepo = this.dataSource.getRepository?.(
      QuestionBankQuestionVersion,
    );
    const [versionsResult, groupItemsResult] = await Promise.all([
      versionRepo
        ? versionRepo.find({
            where: { questionId: In(questionIds) },
            order: { versionNumber: 'DESC' },
          })
        : Promise.resolve([] as QuestionBankQuestionVersion[]),
      this.groupItemRepo.find({
        where: { questionId: In(questionIds) },
        relations: ['group', 'group.sharedFile'],
        order: { groupId: 'ASC', itemOrder: 'ASC' },
      }),
    ]);
    const versions = versionsResult || [];
    const groupItems = groupItemsResult || [];

    const latestVersionByQuestionId = new Map<
      number,
      QuestionBankQuestionVersion
    >();
    for (const version of versions) {
      const questionId = Number(version.questionId);
      if (!latestVersionByQuestionId.has(questionId)) {
        latestVersionByQuestionId.set(questionId, version);
      }
    }

    const groupItemsByQuestionId = new Map<
      number,
      QuestionBankQuestionGroupItem[]
    >();
    for (const groupItem of groupItems) {
      const questionId = Number(groupItem.questionId);
      groupItemsByQuestionId.set(questionId, [
        ...(groupItemsByQuestionId.get(questionId) || []),
        groupItem,
      ]);
    }

    for (const item of items) {
      const question = item.question as QuestionBankQuestion | undefined;
      const record = item as unknown as Record<string, unknown>;
      const latestVersion = latestVersionByQuestionId.get(
        Number(item.questionId),
      );
      const itemGroups =
        groupItemsByQuestionId.get(Number(item.questionId)) || [];
      const groupItem =
        itemGroups.find(
          (entry) => Number(entry.groupId) === Number(item.sourceGroupId),
        ) ||
        itemGroups[0] ||
        null;

      record.sourceQuestionStatus = question?.status ?? null;
      record.sourceQuestionVersionId = latestVersion?.id ?? null;
      record.originRule = item.originRuleJson ?? null;
      record.questionImagePreviewUrl = await this.questionImagePreviewUrl(
        question?.questionFileId,
        question?.file?.filePath,
        question?.file?.mimeType,
      );
      record.supportingAttachments = await Promise.all(
        (question?.attachments || []).map(async (attachment) => ({
          attachmentId: attachment.id,
          fileId: attachment.fileId,
          caption: attachment.caption,
          altText: attachment.altText,
          displayOrder: attachment.displayOrder,
          isPrimary: attachment.isPrimary,
          storagePath: attachment.storagePath,
          previewUrl: await this.questionImagePreviewUrl(
            attachment.fileId,
            attachment.file?.filePath || attachment.storagePath,
            attachment.file?.mimeType,
          ),
        })),
      );
      record.sourceGroupId = groupItem?.groupId ?? item.sourceGroupId ?? null;
      record.sourceGroupTitle = groupItem?.group?.title ?? null;
      record.sourceGroupType = groupItem?.group?.groupType ?? null;
      record.sourceGroupPrompt = groupItem?.group?.sharedPrompt ?? null;
      record.sourceGroupFileId = groupItem?.group?.sharedFileId ?? null;
      record.sourceGroupFileCaption =
        groupItem?.group?.sharedFileCaption ?? null;
      record.sourceGroupFileAltText =
        groupItem?.group?.sharedFileAltText ?? null;
      record.sourceGroupItemOrder =
        groupItem?.itemOrder ?? item.sourceGroupItemOrder ?? null;
      record.sourceGroupImagePreviewUrl = await this.questionImagePreviewUrl(
        groupItem?.group?.sharedFileId,
        groupItem?.group?.sharedFile?.filePath,
        groupItem?.group?.sharedFile?.mimeType,
      );
    }
  }

  private checklistItem(
    key: string,
    passed: boolean,
    okMessage: string,
    failMessage: string,
    action?: string | null,
    failStatus: 'warning' | 'error' = 'error',
  ): {
    key: string;
    status: 'ok' | 'warning' | 'error';
    message: string;
    action: string | null;
  } {
    return {
      key,
      status: passed ? 'ok' : failStatus,
      message: passed ? okMessage : failMessage,
      action: passed ? null : (action ?? null),
    };
  }

  private async copyManualDraftItems(
    sourceDraft: ExamDraft,
    targetDraftId: number,
  ): Promise<number> {
    const manualItems = (sourceDraft.items || []).filter(
      (item) => item.overrideReason || !item.originRuleJson,
    );
    if (!manualItems.length) {
      return 0;
    }
    const maxOrder = await this.draftItemRepo
      .createQueryBuilder('item')
      .select('MAX(item.item_order)', 'maxOrder')
      .where('item.draft_id = :targetDraftId', { targetDraftId })
      .getRawOne<{ maxOrder: string | null }>();
    let nextOrder = Number(maxOrder?.maxOrder ?? -1) + 1;
    await this.draftItemRepo.save(
      manualItems.map((item) =>
        this.draftItemRepo.create({
          draftId: targetDraftId,
          draftSectionId: null,
          questionId: item.questionId,
          chapterId: item.chapterId,
          questionType: item.questionType,
          difficulty: item.difficulty,
          bloomLevel: item.bloomLevel,
          weight: item.weight,
          weightUnits: item.weightUnits,
          marks: item.marks,
          itemOrder: nextOrder++,
          sourceGroupId: item.sourceGroupId,
          sourceGroupItemOrder: item.sourceGroupItemOrder,
          overrideReason: item.overrideReason || 'Preserved manual edit',
          originRuleJson: item.originRuleJson,
        }),
      ),
    );
    return manualItems.length;
  }

  private async findEditableDraft(
    draftId: number,
    userId: number,
  ): Promise<ExamDraft> {
    const draft = await this.findDraftById(draftId, userId);
    this.assertDraftIsEditable(draft);
    return draft;
  }

  private assertDraftIsEditable(draft: ExamDraft): void {
    if (draft.status !== ExamDraftStatus.OPEN) {
      throw new BadRequestException(`Draft is not editable: ${draft.status}`);
    }
    if (draft.expiresAt.getTime() <= Date.now()) {
      throw new BadRequestException('Draft has expired');
    }
  }

  private async markExpiredDraftIfNeeded(draft: ExamDraft): Promise<void> {
    if (
      draft.status === ExamDraftStatus.OPEN &&
      draft.expiresAt.getTime() <= Date.now()
    ) {
      draft.status = ExamDraftStatus.EXPIRED;
      await this.draftRepo.update(draft.id, {
        status: ExamDraftStatus.EXPIRED,
      });
    }
  }

  private async findApprovedQuestionForDraft(
    questionId: number,
    courseId: number,
  ): Promise<QuestionBankQuestion> {
    const question = await this.questionRepo.findOne({
      where: {
        id: questionId,
        courseId,
        status: QuestionBankStatus.APPROVED,
      },
      relations: ['groupItems'],
    });
    if (!question) {
      throw new NotFoundException(
        'Approved question not found for this course',
      );
    }
    return question;
  }

  private assertQuestionMatchesDraftGeneration(
    draft: ExamDraft,
    question: QuestionBankQuestion,
    draftSectionId: number | null | undefined,
    overrideReason?: string,
  ): void {
    const request =
      draft.generationRequestJson as Partial<GenerateExamPreviewDto>;
    const rules = this.getGenerationRulesForDraftSection(
      draft,
      request,
      draftSectionId ?? null,
    );
    if (!rules.length) {
      return;
    }

    const matches = rules.some((rule) =>
      this.questionMatchesGenerationRule(question, rule),
    );
    if (matches) {
      return;
    }

    if (overrideReason?.trim()) {
      this.logger.warn(
        `Draft=${draft.id} question=${question.id} used outside generation constraints with override`,
      );
      return;
    }

    throw new BadRequestException(
      'Question does not match the draft generation constraints. Provide overrideReason to intentionally override.',
    );
  }

  private getGenerationRulesForDraftSection(
    draft: ExamDraft,
    request: Partial<GenerateExamPreviewDto>,
    draftSectionId: number | null,
  ): ExamGenerationRuleDto[] {
    if (draftSectionId) {
      const section = (draft.sections || []).find(
        (draftSection) => Number(draftSection.id) === Number(draftSectionId),
      );
      if (!section) {
        return [];
      }
      return request.sections?.[section.sectionOrder]?.rules || [];
    }
    return request.rules || [];
  }

  private questionMatchesGenerationRule(
    question: QuestionBankQuestion,
    rule: ExamGenerationRuleDto,
  ): boolean {
    const normalized = this.normalizeGenerationRule(rule);
    const questionGroupIds = (question.groupItems || []).map((item) =>
      Number(item.groupId),
    );
    const scopeMatches =
      normalized.scope === ExamGenerationScope.COURSE ||
      (normalized.scope === ExamGenerationScope.GROUP &&
        normalized.groupIds.some((groupId) =>
          questionGroupIds.includes(groupId),
        )) ||
      normalized.chapterIds.includes(Number(question.chapterId));
    return (
      scopeMatches &&
      (!rule.questionType || question.questionType === rule.questionType) &&
      (!rule.difficulty || question.difficulty === rule.difficulty) &&
      (!rule.bloomLevel || question.bloomLevel === rule.bloomLevel)
    );
  }

  private assertFullDraftItemReorder(
    existingItems: Array<Pick<ExamDraftItem, 'id'>>,
    dto: ReorderDraftItemsDto,
  ): void {
    const existingIds = new Set(existingItems.map((item) => Number(item.id)));
    const requestedIds = new Set(dto.items.map((item) => Number(item.itemId)));
    if (
      existingIds.size !== requestedIds.size ||
      [...existingIds].some((id) => !requestedIds.has(id))
    ) {
      throw new BadRequestException(
        'Reorder payload must include every item in the draft exactly once',
      );
    }
  }

  private async compactDraftItemOrder(draftId: number): Promise<void> {
    const items = await this.draftItemRepo.find({
      where: { draftId },
      order: { itemOrder: 'ASC', id: 'ASC' },
    });
    await this.dataSource.transaction(async (manager) => {
      for (const [index, item] of items.entries()) {
        if (Number(item.itemOrder) !== index) {
          await manager.update(
            ExamDraftItem,
            { id: item.id, draftId },
            { itemOrder: index },
          );
        }
      }
    });
  }

  private async ensureDraftSectionExists(
    draftId: number,
    sectionId: number,
  ): Promise<void> {
    const exists = await this.draftSectionRepo.exist({
      where: { id: sectionId, draftId },
    });
    if (!exists) {
      throw new NotFoundException('Draft section not found');
    }
  }

  private async ensureCourseExists(courseId: number): Promise<void> {
    const exists = await this.courseRepo.exist({ where: { id: courseId } });
    if (!exists) {
      throw new NotFoundException('Course not found');
    }
  }

  private async ensureChapterBelongsToCourse(
    courseId: number,
    chapterId: number,
  ): Promise<void> {
    const chapterExists = await this.chapterRepo.exist({
      where: { id: chapterId, courseId },
    });
    if (!chapterExists) {
      throw new BadRequestException(
        `Chapter ${chapterId} does not belong to this course`,
      );
    }
  }

  private async ensureGroupBelongsToCourse(
    courseId: number,
    groupId: number,
  ): Promise<void> {
    const groupExists = await this.groupRepo.exist({
      where: { id: groupId, courseId },
    });
    if (!groupExists) {
      throw new BadRequestException(
        `Group ${groupId} does not belong to this course`,
      );
    }
  }

  private async findPrimaryGroupItem(
    questionId: number,
  ): Promise<QuestionBankQuestionGroupItem | null> {
    return this.groupItemRepo.findOne({
      where: { questionId },
      order: { groupId: 'ASC', itemOrder: 'ASC' },
    });
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

  private page<T>(
    data: T[],
    total: number,
    page: number,
    limit: number,
  ): PaginatedResult<T> {
    return {
      data,
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  private emptyPage<T>(page: number, limit: number): PaginatedResult<T> {
    const { safePage, safeLimit } = this.normalizePagination(page, limit);
    return this.page([], 0, safePage, safeLimit);
  }

  private applyCreatedAtFilter(
    where: Record<string, unknown>,
    dateFrom?: string,
    dateTo?: string,
  ): void {
    const from = dateFrom ? new Date(dateFrom) : undefined;
    const to = dateTo ? new Date(dateTo) : undefined;
    if (from && to && from.getTime() > to.getTime()) {
      throw new BadRequestException('dateFrom must be before dateTo');
    }

    let operator: FindOperator<Date> | undefined;
    if (from && to) operator = Between(from, to);
    else if (from) operator = MoreThanOrEqual(from);
    else if (to) operator = LessThanOrEqual(to);

    if (operator) {
      where.createdAt = operator;
    }
  }

  toExamResponse(exam: Exam): ExamResponseDto {
    return {
      id: Number(exam.id),
      courseId: Number(exam.courseId),
      title: exam.title,
      totalMarks: exam.totalMarks,
      status: exam.status,
      publishedAt: exam.publishedAt,
      archivedAt: exam.archivedAt,
      createdAt: exam.createdAt,
      updatedAt: exam.updatedAt,
      itemCount: exam.items?.length,
      sectionCount: exam.sections?.length,
    };
  }
}
