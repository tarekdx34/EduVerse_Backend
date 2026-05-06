import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  ParseIntPipe,
  Patch,
  Post,
  Query,
  Req,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { RoleName } from '../auth/entities/role.entity';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/roles.decorator';
import {
  AddDraftItemDto,
  DuplicateDraftDto,
  ReorderDraftItemsDto,
  ReplacementCheckDto,
} from './dto/exam-draft-item.dto';
import { ExportExamDto } from './dto/exam-export.dto';
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
import { ExamDraftListQueryDto, ExamListQueryDto } from './dto/exam-query.dto';
import { ExamResponseDto } from './dto/exam-response.dto';
import {
  GenerateExamPreviewDto,
  UpdateDraftItemDto,
} from './dto/generate-exam.dto';
import { ExamDraftItem } from './entities/exam-draft-item.entity';
import { ExamDraftSection } from './entities/exam-draft-section.entity';
import { ExamsService } from './exams.service';

type AuthenticatedRequest = {
  user: {
    userId: number;
  };
};

@ApiTags('Exams')
@ApiBearerAuth('JWT-auth')
@UseGuards(JwtAuthGuard, RolesGuard)
@Controller('api/exams')
export class ExamsController {
  constructor(private readonly examsService: ExamsService) {}

  @Get()
  @Roles(RoleName.INSTRUCTOR)
  getExams(
    @Req() req: AuthenticatedRequest,
    @Query() query: ExamListQueryDto,
  ) {
    return this.examsService.findExams(
      req.user.userId,
      query.page,
      query.limit,
      query,
    );
  }

  @Get('list')
  @Roles(RoleName.INSTRUCTOR)
  listExams(
    @Req() req: AuthenticatedRequest,
    @Query() query: ExamListQueryDto,
  ) {
    return this.examsService.findExams(
      req.user.userId,
      query.page,
      query.limit,
      query,
    );
  }

  @Get('drafts')
  @Roles(RoleName.INSTRUCTOR)
  getDrafts(
    @Req() req: AuthenticatedRequest,
    @Query() query: ExamDraftListQueryDto,
  ) {
    return this.examsService.findDrafts(
      req.user.userId,
      query.page,
      query.limit,
      query,
    );
  }

  @Get('drafts/list')
  @Roles(RoleName.INSTRUCTOR)
  listDrafts(
    @Req() req: AuthenticatedRequest,
    @Query() query: ExamDraftListQueryDto,
  ) {
    return this.examsService.findDrafts(
      req.user.userId,
      query.page,
      query.limit,
      query,
    );
  }

  @Get('drafts/:draftId')
  @Roles(RoleName.INSTRUCTOR)
  getDraftById(
    @Param('draftId', ParseIntPipe) draftId: number,
    @Req() req: AuthenticatedRequest,
  ) {
    return this.examsService.findDraftById(draftId, req.user.userId);
  }

  @Get('stats')
  @Roles(RoleName.INSTRUCTOR)
  getStats(
    @Req() req: AuthenticatedRequest,
    @Query('courseId') courseId?: string,
  ) {
    return this.examsService.getExamStats(
      req.user.userId,
      courseId ? Number(courseId) : undefined,
    );
  }

  @Get('generation-readiness')
  @Roles(RoleName.INSTRUCTOR)
  getGenerationReadiness(
    @Req() req: AuthenticatedRequest,
    @Query('courseId', ParseIntPipe) courseId: number,
  ) {
    return this.examsService.getGenerationReadiness(req.user.userId, courseId);
  }

  @Post('generate-preview')
  @Roles(RoleName.INSTRUCTOR)
  generatePreview(
    @Body() dto: GenerateExamPreviewDto,
    @Req() req: AuthenticatedRequest,
  ) {
    return this.examsService.generatePreview(dto, req.user.userId);
  }

  @Post('generation-availability')
  @Roles(RoleName.INSTRUCTOR)
  generationAvailability(
    @Body() dto: GenerateExamPreviewDto,
    @Req() req: AuthenticatedRequest,
  ) {
    return this.examsService.checkGenerationAvailability(dto, req.user.userId);
  }

  @Get('paper-templates')
  @Roles(RoleName.INSTRUCTOR)
  listPaperTemplates(
    @Req() req: AuthenticatedRequest,
    @Query('courseId') courseId?: string,
  ) {
    return this.examsService.listPaperTemplates(
      req.user.userId,
      courseId ? Number(courseId) : undefined,
    );
  }

  @Post('paper-templates')
  @Roles(RoleName.INSTRUCTOR)
  createPaperTemplate(
    @Body() dto: SaveExamPaperTemplateDto,
    @Req() req: AuthenticatedRequest,
  ) {
    return this.examsService.createPaperTemplate(req.user.userId, dto);
  }

  @Patch('paper-templates/:templateId')
  @Roles(RoleName.INSTRUCTOR)
  updatePaperTemplate(
    @Param('templateId', ParseIntPipe) templateId: number,
    @Body() dto: SaveExamPaperTemplateDto,
    @Req() req: AuthenticatedRequest,
  ) {
    return this.examsService.updatePaperTemplate(
      templateId,
      req.user.userId,
      dto,
    );
  }

  @Delete('paper-templates/:templateId')
  @Roles(RoleName.INSTRUCTOR)
  async deletePaperTemplate(
    @Param('templateId', ParseIntPipe) templateId: number,
    @Req() req: AuthenticatedRequest,
  ) {
    await this.examsService.deletePaperTemplate(templateId, req.user.userId);
    return { message: 'Paper template deleted successfully' };
  }

  @Post('drafts/:draftId/sections')
  @Roles(RoleName.INSTRUCTOR)
  createDraftSection(
    @Param('draftId', ParseIntPipe) draftId: number,
    @Body() dto: CreateExamSectionDto,
    @Req() req: AuthenticatedRequest,
  ): Promise<ExamDraftSection> {
    return this.examsService.createDraftSection(draftId, dto, req.user.userId);
  }

  @Get('drafts/:draftId/validation')
  @Roles(RoleName.INSTRUCTOR)
  validateDraft(
    @Param('draftId', ParseIntPipe) draftId: number,
    @Req() req: AuthenticatedRequest,
  ) {
    return this.examsService.validateDraft(draftId, req.user.userId);
  }

  @Post('drafts/:draftId/regenerate')
  @Roles(RoleName.INSTRUCTOR)
  regenerateDraft(
    @Param('draftId', ParseIntPipe) draftId: number,
    @Body() dto: { seed?: string; keepManualEdits?: boolean },
    @Req() req: AuthenticatedRequest,
  ) {
    return this.examsService.regenerateDraft(draftId, req.user.userId, dto);
  }

  @Post('drafts/:draftId/duplicate')
  @Roles(RoleName.INSTRUCTOR)
  duplicateDraft(
    @Param('draftId', ParseIntPipe) draftId: number,
    @Body() dto: DuplicateDraftDto,
    @Req() req: AuthenticatedRequest,
  ) {
    return this.examsService.duplicateDraft(draftId, req.user.userId, dto);
  }

  @Post('drafts/:draftId/sections/:sectionId/reshuffle')
  @Roles(RoleName.INSTRUCTOR)
  reshuffleDraftSection(
    @Param('draftId', ParseIntPipe) draftId: number,
    @Param('sectionId', ParseIntPipe) sectionId: number,
    @Body() dto: { seed?: string; keepManualEdits?: boolean },
    @Req() req: AuthenticatedRequest,
  ) {
    return this.examsService.reshuffleDraftSection(
      draftId,
      sectionId,
      req.user.userId,
      dto,
    );
  }

  @Post('drafts/:draftId/sections/:sectionId/normalize-marks')
  @Roles(RoleName.INSTRUCTOR)
  normalizeSectionMarks(
    @Param('draftId', ParseIntPipe) draftId: number,
    @Param('sectionId', ParseIntPipe) sectionId: number,
    @Body() dto: NormalizeSectionMarksDto,
    @Req() req: AuthenticatedRequest,
  ) {
    return this.examsService.normalizeSectionMarks(
      draftId,
      sectionId,
      req.user.userId,
      dto,
    );
  }

  @Patch('drafts/:draftId/sections/reorder')
  @Roles(RoleName.INSTRUCTOR)
  reorderDraftSections(
    @Param('draftId', ParseIntPipe) draftId: number,
    @Body() dto: ReorderExamSectionsDto,
    @Req() req: AuthenticatedRequest,
  ): Promise<ExamDraftSection[]> {
    return this.examsService.reorderDraftSections(
      draftId,
      dto,
      req.user.userId,
    );
  }

  @Patch('drafts/:draftId/sections/:sectionId')
  @Roles(RoleName.INSTRUCTOR)
  updateDraftSection(
    @Param('draftId', ParseIntPipe) draftId: number,
    @Param('sectionId', ParseIntPipe) sectionId: number,
    @Body() dto: UpdateExamSectionDto,
    @Req() req: AuthenticatedRequest,
  ): Promise<ExamDraftSection> {
    return this.examsService.updateDraftSection(
      draftId,
      sectionId,
      dto,
      req.user.userId,
    );
  }

  @Delete('drafts/:draftId/sections/:sectionId')
  @Roles(RoleName.INSTRUCTOR)
  async deleteDraftSection(
    @Param('draftId', ParseIntPipe) draftId: number,
    @Param('sectionId', ParseIntPipe) sectionId: number,
    @Req() req: AuthenticatedRequest,
  ): Promise<{ message: string }> {
    await this.examsService.deleteDraftSection(
      draftId,
      sectionId,
      req.user.userId,
    );
    return { message: 'Draft section deleted successfully' };
  }

  @Post('drafts/:draftId/items')
  @Roles(RoleName.INSTRUCTOR)
  addDraftItem(
    @Param('draftId', ParseIntPipe) draftId: number,
    @Body() dto: AddDraftItemDto,
    @Req() req: AuthenticatedRequest,
  ): Promise<ExamDraftItem> {
    return this.examsService.addDraftItem(draftId, dto, req.user.userId);
  }

  @Patch('drafts/:draftId/items/reorder')
  @Roles(RoleName.INSTRUCTOR)
  reorderDraftItems(
    @Param('draftId', ParseIntPipe) draftId: number,
    @Body() dto: ReorderDraftItemsDto,
    @Req() req: AuthenticatedRequest,
  ): Promise<ExamDraftItem[]> {
    return this.examsService.reorderDraftItems(draftId, dto, req.user.userId);
  }

  @Patch('drafts/:draftId/items/:itemId')
  @Roles(RoleName.INSTRUCTOR)
  updateDraftItem(
    @Param('draftId', ParseIntPipe) draftId: number,
    @Param('itemId', ParseIntPipe) itemId: number,
    @Body() dto: UpdateDraftItemDto,
    @Req() req: AuthenticatedRequest,
  ) {
    return this.examsService.updateDraftItem(
      draftId,
      itemId,
      dto,
      req.user.userId,
    );
  }

  @Post('drafts/:draftId/items/:itemId/replacement-check')
  @Roles(RoleName.INSTRUCTOR)
  replacementCheck(
    @Param('draftId', ParseIntPipe) draftId: number,
    @Param('itemId', ParseIntPipe) itemId: number,
    @Body() dto: ReplacementCheckDto,
    @Req() req: AuthenticatedRequest,
  ) {
    return this.examsService.checkReplacement(
      draftId,
      itemId,
      dto,
      req.user.userId,
    );
  }

  @Delete('drafts/:draftId/items/:itemId')
  @Roles(RoleName.INSTRUCTOR)
  async removeDraftItem(
    @Param('draftId', ParseIntPipe) draftId: number,
    @Param('itemId', ParseIntPipe) itemId: number,
    @Req() req: AuthenticatedRequest,
  ): Promise<{ message: string }> {
    await this.examsService.removeDraftItem(draftId, itemId, req.user.userId);
    return { message: 'Draft item removed successfully' };
  }

  @Post('drafts/:draftId/save')
  @Roles(RoleName.INSTRUCTOR)
  saveDraft(
    @Param('draftId', ParseIntPipe) draftId: number,
    @Req() req: AuthenticatedRequest,
  ): Promise<ExamResponseDto> {
    return this.examsService
      .saveDraft(draftId, req.user.userId)
      .then((exam) => this.examsService.toExamResponse(exam));
  }

  @Get(':id/full')
  @Roles(RoleName.INSTRUCTOR)
  getFullExam(
    @Param('id', ParseIntPipe) id: number,
    @Req() req: AuthenticatedRequest,
  ) {
    return this.examsService.getFullExamDetail(id, req.user.userId);
  }

  @Patch(':id/paper-template')
  @Roles(RoleName.INSTRUCTOR)
  applyPaperTemplate(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: ApplyExamPaperTemplateDto,
    @Req() req: AuthenticatedRequest,
  ) {
    return this.examsService.applyPaperTemplate(id, req.user.userId, dto);
  }

  @Get(':id')
  @Roles(RoleName.INSTRUCTOR)
  getExam(
    @Param('id', ParseIntPipe) id: number,
    @Req() req: AuthenticatedRequest,
  ): Promise<ExamResponseDto> {
    return this.examsService
      .findExamById(id, req.user.userId)
      .then((exam) => this.examsService.toExamResponse(exam));
  }

  @Post(':id/publish')
  @Roles(RoleName.INSTRUCTOR)
  publishExam(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: PublishExamDto,
    @Req() req: AuthenticatedRequest,
  ): Promise<ExamResponseDto> {
    return this.examsService
      .publishExam(id, dto, req.user.userId)
      .then((exam) => this.examsService.toExamResponse(exam));
  }

  @Post(':id/unpublish')
  @Roles(RoleName.INSTRUCTOR)
  unpublishExam(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UnpublishExamDto,
    @Req() req: AuthenticatedRequest,
  ): Promise<ExamResponseDto> {
    return this.examsService
      .unpublishExam(id, dto, req.user.userId)
      .then((exam) => this.examsService.toExamResponse(exam));
  }

  @Post(':id/archive')
  @Roles(RoleName.INSTRUCTOR)
  archiveExam(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: ArchiveExamDto,
    @Req() req: AuthenticatedRequest,
  ): Promise<ExamResponseDto> {
    return this.examsService
      .archiveExam(id, dto, req.user.userId)
      .then((exam) => this.examsService.toExamResponse(exam));
  }

  @Post(':id/export-word')
  @Roles(RoleName.INSTRUCTOR)
  exportWord(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: ExportExamDto,
    @Req() req: AuthenticatedRequest,
  ) {
    return this.examsService.exportExamAsWord(id, dto, req.user.userId);
  }
}
