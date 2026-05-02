import {
  Body,
  Controller,
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
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/roles.decorator';
import { RoleName } from '../auth/entities/role.entity';
import {
  GenerateExamPreviewDto,
  UpdateDraftItemDto,
} from './dto/generate-exam.dto';
import { Exam } from './entities/exam.entity';
import { ExamsService } from './exams.service';

@ApiTags('Exams')
@ApiBearerAuth('JWT-auth')
@UseGuards(JwtAuthGuard, RolesGuard)
@Controller('api/exams')
export class ExamsController {
  constructor(private readonly examsService: ExamsService) {}

  @Get()
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN, RoleName.STUDENT)
  getExams(
    @Query('page', new ParseIntPipe({ optional: true })) page: number = 1,
    @Query('limit', new ParseIntPipe({ optional: true })) limit: number = 20,
  ) {
    return this.examsService.findExams(page, limit);
  }

  @Get('list')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN, RoleName.STUDENT)
  listExams(
    @Query('page', new ParseIntPipe({ optional: true })) page: number = 1,
    @Query('limit', new ParseIntPipe({ optional: true })) limit: number = 20,
  ) {
    return this.examsService.findExams(page, limit);
  }

  @Get('drafts')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN)
  getDrafts(
    @Query('page', new ParseIntPipe({ optional: true })) page: number = 1,
    @Query('limit', new ParseIntPipe({ optional: true })) limit: number = 20,
  ) {
    return this.examsService.findDrafts(page, limit);
  }

  @Get('drafts/list')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN)
  listDrafts(
    @Query('page', new ParseIntPipe({ optional: true })) page: number = 1,
    @Query('limit', new ParseIntPipe({ optional: true })) limit: number = 20,
  ) {
    return this.examsService.findDrafts(page, limit);
  }

  @Get('drafts/:draftId')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN)
  getDraftById(@Param('draftId', ParseIntPipe) draftId: number) {
    return this.examsService.findDraftById(draftId);
  }

  @Post('generate-preview')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN)
  async generatePreview(@Body() dto: GenerateExamPreviewDto, @Req() req: any) {
    try {
      return await this.examsService.generatePreview(dto, req.user.userId);
    } catch (err) {
      throw err;
    }
  }

  @Patch('drafts/:draftId/items/:itemId')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN)
  updateDraftItem(
    @Param('draftId', ParseIntPipe) draftId: number,
    @Param('itemId', ParseIntPipe) itemId: number,
    @Body() dto: UpdateDraftItemDto,
  ) {
    return this.examsService.updateDraftItem(draftId, itemId, dto);
  }

  @Post('drafts/:draftId/save')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN)
  saveDraft(
    @Param('draftId', ParseIntPipe) draftId: number,
    @Req() req: any,
  ): Promise<Exam> {
    return this.examsService.saveDraft(draftId, req.user.userId);
  }

  @Get(':id')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN, RoleName.STUDENT)
  getExam(@Param('id', ParseIntPipe) id: number): Promise<Exam> {
    return this.examsService.findExamById(id);
  }

  @Post(':id/export-word')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN)
  exportWord(@Param('id', ParseIntPipe) id: number) {
    return this.examsService.exportExamAsWord(id);
  }
}
