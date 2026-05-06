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
  UploadedFile,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiBody,
  ApiConsumes,
  ApiOperation,
  ApiResponse,
  ApiTags,
} from '@nestjs/swagger';
import { FileInterceptor } from '@nestjs/platform-express';
import { RoleName } from '../auth/entities/role.entity';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/roles.decorator';
import { FileResponseDto } from '../files/dto/file-response.dto';
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
  QuestionBankQueryDto,
  UpdateQuestionBankQuestionDto,
} from './dto/question.dto';
import { QuestionBankPrivateResponseDto } from './dto/question-response.dto';
import { CourseChapter } from './entities/course-chapter.entity';
import { QuestionBankQuestionAttachment } from './entities/question-bank-question-attachment.entity';
import { QuestionBankQuestionGroupItem } from './entities/question-bank-question-group-item.entity';
import { QuestionBankQuestionGroup } from './entities/question-bank-question-group.entity';
import { QuestionBankStatus } from './enums/question-bank.enums';
import { QuestionBankService } from './question-bank.service';

type AuthenticatedRequest = {
  user: {
    userId: number;
  };
};

@ApiTags('Question Bank')
@ApiBearerAuth('JWT-auth')
@UseGuards(JwtAuthGuard, RolesGuard)
@Controller('api')
export class QuestionBankController {
  constructor(private readonly questionBankService: QuestionBankService) {}

  @Post('courses/:courseId/chapters')
  @Roles(RoleName.INSTRUCTOR)
  createChapter(
    @Param('courseId', ParseIntPipe) courseId: number,
    @Body() dto: CreateChapterDto,
    @Req() req: AuthenticatedRequest,
  ): Promise<CourseChapter> {
    return this.questionBankService.createChapter(
      courseId,
      dto,
      req.user.userId,
    );
  }

  @Get('courses/:courseId/chapters')
  @Roles(RoleName.INSTRUCTOR)
  listChapters(
    @Param('courseId', ParseIntPipe) courseId: number,
    @Req() req: AuthenticatedRequest,
  ): Promise<CourseChapter[]> {
    return this.questionBankService.listChapters(courseId, req.user.userId);
  }

  @Patch('courses/:courseId/chapters/:chapterId')
  @Roles(RoleName.INSTRUCTOR)
  updateChapter(
    @Param('courseId', ParseIntPipe) courseId: number,
    @Param('chapterId', ParseIntPipe) chapterId: number,
    @Body() dto: UpdateChapterDto,
    @Req() req: AuthenticatedRequest,
  ): Promise<CourseChapter> {
    return this.questionBankService.updateChapter(
      courseId,
      chapterId,
      dto,
      req.user.userId,
    );
  }

  @Delete('courses/:courseId/chapters/:chapterId')
  @Roles(RoleName.INSTRUCTOR)
  async deleteChapter(
    @Param('courseId', ParseIntPipe) courseId: number,
    @Param('chapterId', ParseIntPipe) chapterId: number,
    @Req() req: AuthenticatedRequest,
  ): Promise<{ message: string }> {
    await this.questionBankService.deleteChapter(
      courseId,
      chapterId,
      req.user.userId,
    );
    return { message: 'Chapter deleted successfully' };
  }

  @Post('question-bank/questions')
  @Roles(RoleName.INSTRUCTOR)
  async createQuestion(
    @Body() dto: CreateQuestionBankQuestionDto,
    @Req() req: AuthenticatedRequest,
  ): Promise<QuestionBankPrivateResponseDto> {
    const question = await this.questionBankService.createQuestion(
      dto,
      req.user.userId,
    );
    return this.questionBankService.toPrivateResponse(question);
  }

  @Post('question-bank/questions/batch')
  @Roles(RoleName.INSTRUCTOR)
  async bulkCreateQuestions(
    @Body() dto: BulkCreateQuestionBankQuestionsDto,
    @Req() req: AuthenticatedRequest,
  ): Promise<{
    created: QuestionBankPrivateResponseDto[];
    count: number;
    failed: Array<{ rowIndex: number; message: string }>;
    failedCount: number;
  }> {
    const result = await this.questionBankService.bulkCreateQuestions(
      dto,
      req.user.userId,
    );
    return {
      count: result.count,
      created: result.created.map((question) =>
        this.questionBankService.toPrivateResponse(question),
      ),
      failed: result.failed,
      failedCount: result.failedCount,
    };
  }

  @Post('question-bank/questions/upload-image')
  @Roles(RoleName.INSTRUCTOR)
  @UseInterceptors(FileInterceptor('image'))
  @ApiOperation({
    summary: 'Upload question image',
    description:
      'Uploads an image dedicated for question figures or full-image questions. Use returned fileId as questionFileId or attachment fileId.',
  })
  @ApiConsumes('multipart/form-data')
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        image: {
          type: 'string',
          format: 'binary',
          description: 'Question image (jpeg/png/webp/gif)',
        },
      },
      required: ['image'],
    },
  })
  @ApiResponse({
    status: 201,
    description: 'Question image uploaded successfully',
  })
  uploadQuestionImage(
    @UploadedFile() image: Express.Multer.File,
    @Req() req: AuthenticatedRequest,
  ): Promise<FileResponseDto> {
    return this.questionBankService.uploadQuestionImage(req.user.userId, image);
  }

  @Post('question-bank/groups/upload-image')
  @Roles(RoleName.INSTRUCTOR)
  @UseInterceptors(FileInterceptor('image'))
  @ApiOperation({
    summary: 'Upload question group image',
    description:
      'Uploads an image for a question group shared prompt. Use returned fileId as sharedFileId.',
  })
  @ApiConsumes('multipart/form-data')
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        image: {
          type: 'string',
          format: 'binary',
          description: 'Question group image (jpeg/png/webp/gif)',
        },
      },
      required: ['image'],
    },
  })
  @ApiResponse({
    status: 201,
    description: 'Question group image uploaded successfully',
  })
  uploadQuestionGroupImage(
    @UploadedFile() image: Express.Multer.File,
    @Req() req: AuthenticatedRequest,
  ): Promise<FileResponseDto> {
    return this.questionBankService.uploadQuestionGroupImage(
      req.user.userId,
      image,
    );
  }

  @Get('question-bank/questions')
  @Roles(RoleName.INSTRUCTOR)
  async listQuestions(
    @Query() query: QuestionBankQueryDto,
    @Req() req: AuthenticatedRequest,
  ): Promise<{ data: QuestionBankPrivateResponseDto[]; total: number }> {
    const result = await this.questionBankService.listQuestions(
      query,
      req.user.userId,
    );
    return {
      total: result.total,
      data: result.data.map((question) =>
        this.questionBankService.toPrivateResponse(question),
      ),
    };
  }

  @Get('question-bank/questions/stats')
  @Roles(RoleName.INSTRUCTOR)
  getQuestionStats(
    @Query() query: QuestionBankQueryDto,
    @Req() req: AuthenticatedRequest,
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
    return this.questionBankService.getQuestionStats(query, req.user.userId);
  }

  @Get('question-bank/questions/chapter-counts')
  @Roles(RoleName.INSTRUCTOR)
  getChapterQuestionCounts(
    @Query('courseId', ParseIntPipe) courseId: number,
    @Req() req: AuthenticatedRequest,
  ): Promise<Array<{ chapterId: number; total: number }>> {
    return this.questionBankService.getChapterQuestionCounts(
      courseId,
      req.user.userId,
    );
  }

  @Post('question-bank/questions/status/batch')
  @Roles(RoleName.INSTRUCTOR)
  async batchQuestionStatus(
    @Body() dto: BatchQuestionStatusDto,
    @Req() req: AuthenticatedRequest,
  ): Promise<{ updated: QuestionBankPrivateResponseDto[]; count: number }> {
    const result = await this.questionBankService.batchUpdateQuestionStatus(
      dto,
      req.user.userId,
    );
    return {
      count: result.count,
      updated: result.updated.map((question) =>
        this.questionBankService.toPrivateResponse(question),
      ),
    };
  }

  @Get('question-bank/questions/:id')
  @Roles(RoleName.INSTRUCTOR)
  async getQuestion(
    @Param('id', ParseIntPipe) id: number,
    @Req() req: AuthenticatedRequest,
  ): Promise<QuestionBankPrivateResponseDto> {
    const question = await this.questionBankService.findQuestionById(
      id,
      req.user.userId,
    );
    return this.questionBankService.toPrivateResponse(question);
  }

  @Patch('question-bank/questions/:id')
  @Roles(RoleName.INSTRUCTOR)
  async updateQuestion(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateQuestionBankQuestionDto,
    @Req() req: AuthenticatedRequest,
  ): Promise<QuestionBankPrivateResponseDto> {
    const question = await this.questionBankService.updateQuestion(
      id,
      dto,
      req.user.userId,
    );
    return this.questionBankService.toPrivateResponse(question);
  }

  @Delete('question-bank/questions/:id')
  @Roles(RoleName.INSTRUCTOR)
  async deleteQuestion(
    @Param('id', ParseIntPipe) id: number,
    @Req() req: AuthenticatedRequest,
  ): Promise<{ message: string }> {
    await this.questionBankService.deleteQuestion(id, req.user.userId);
    return { message: 'Question archived successfully' };
  }

  @Post('question-bank/questions/:id/attachments')
  @Roles(RoleName.INSTRUCTOR)
  addAttachment(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: CreateQuestionAttachmentDto,
    @Req() req: AuthenticatedRequest,
  ): Promise<QuestionBankQuestionAttachment> {
    return this.questionBankService.addQuestionAttachment(
      id,
      dto,
      req.user.userId,
    );
  }

  @Post('question-bank/questions/:id/attachments/upload-image')
  @Roles(RoleName.INSTRUCTOR)
  @UseInterceptors(FileInterceptor('image'))
  @ApiConsumes('multipart/form-data')
  uploadAttachmentImage(
    @Param('id', ParseIntPipe) id: number,
    @UploadedFile() image: Express.Multer.File,
    @Body() metadata: UploadQuestionAttachmentMetadataDto,
    @Req() req: AuthenticatedRequest,
  ): Promise<QuestionBankQuestionAttachment> {
    return this.questionBankService.uploadQuestionAttachmentImage(
      id,
      image,
      metadata,
      req.user.userId,
    );
  }

  @Patch('question-bank/questions/:id/attachments/reorder')
  @Roles(RoleName.INSTRUCTOR)
  reorderAttachments(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: ReorderQuestionAttachmentsDto,
    @Req() req: AuthenticatedRequest,
  ): Promise<QuestionBankQuestionAttachment[]> {
    return this.questionBankService.reorderQuestionAttachments(
      id,
      dto,
      req.user.userId,
    );
  }

  @Patch('question-bank/questions/:id/attachments/:attachmentId')
  @Roles(RoleName.INSTRUCTOR)
  updateAttachment(
    @Param('id', ParseIntPipe) id: number,
    @Param('attachmentId', ParseIntPipe) attachmentId: number,
    @Body() dto: UpdateQuestionAttachmentDto,
    @Req() req: AuthenticatedRequest,
  ): Promise<QuestionBankQuestionAttachment> {
    return this.questionBankService.updateQuestionAttachment(
      id,
      attachmentId,
      dto,
      req.user.userId,
    );
  }

  @Delete('question-bank/questions/:id/attachments/:attachmentId')
  @Roles(RoleName.INSTRUCTOR)
  async removeAttachment(
    @Param('id', ParseIntPipe) id: number,
    @Param('attachmentId', ParseIntPipe) attachmentId: number,
    @Req() req: AuthenticatedRequest,
  ): Promise<{ message: string }> {
    await this.questionBankService.removeQuestionAttachment(
      id,
      attachmentId,
      req.user.userId,
    );
    return { message: 'Attachment removed successfully' };
  }

  @Post('question-bank/groups')
  @Roles(RoleName.INSTRUCTOR)
  createGroup(
    @Body() dto: CreateQuestionGroupDto,
    @Req() req: AuthenticatedRequest,
  ): Promise<QuestionBankQuestionGroup> {
    return this.questionBankService.createQuestionGroup(dto, req.user.userId);
  }

  @Get('question-bank/groups')
  @Roles(RoleName.INSTRUCTOR)
  listGroups(
    @Query() query: QuestionGroupQueryDto,
    @Req() req: AuthenticatedRequest,
  ): Promise<{ data: QuestionBankQuestionGroup[]; total: number }> {
    return this.questionBankService.listQuestionGroups(query, req.user.userId);
  }

  @Get('question-bank/groups/:groupId')
  @Roles(RoleName.INSTRUCTOR)
  getGroup(
    @Param('groupId', ParseIntPipe) groupId: number,
    @Req() req: AuthenticatedRequest,
  ): Promise<QuestionBankQuestionGroup> {
    return this.questionBankService.findQuestionGroupById(
      groupId,
      req.user.userId,
    );
  }

  @Patch('question-bank/groups/:groupId')
  @Roles(RoleName.INSTRUCTOR)
  updateGroup(
    @Param('groupId', ParseIntPipe) groupId: number,
    @Body() dto: UpdateQuestionGroupDto,
    @Req() req: AuthenticatedRequest,
  ): Promise<QuestionBankQuestionGroup> {
    return this.questionBankService.updateQuestionGroup(
      groupId,
      dto,
      req.user.userId,
    );
  }

  @Delete('question-bank/groups/:groupId')
  @Roles(RoleName.INSTRUCTOR)
  async deleteGroup(
    @Param('groupId', ParseIntPipe) groupId: number,
    @Req() req: AuthenticatedRequest,
  ): Promise<{ message: string }> {
    await this.questionBankService.deleteQuestionGroup(
      groupId,
      req.user.userId,
    );
    return { message: 'Question group deleted successfully' };
  }

  @Post('question-bank/groups/:groupId/questions/batch')
  @Roles(RoleName.INSTRUCTOR)
  async addGroupedQuestions(
    @Param('groupId', ParseIntPipe) groupId: number,
    @Body() dto: BatchCreateGroupedQuestionsDto,
    @Req() req: AuthenticatedRequest,
  ): Promise<{
    group: QuestionBankQuestionGroup;
    questions: QuestionBankPrivateResponseDto[];
  }> {
    const result = await this.questionBankService.addGroupedQuestions(
      groupId,
      dto,
      req.user.userId,
    );
    return {
      group: result.group,
      questions: result.questions.map((question) =>
        this.questionBankService.toPrivateResponse(question),
      ),
    };
  }

  @Post('question-bank/groups/:groupId/questions/link')
  @Roles(RoleName.INSTRUCTOR)
  async linkExistingQuestionsToGroup(
    @Param('groupId', ParseIntPipe) groupId: number,
    @Body() dto: LinkQuestionGroupQuestionsDto,
    @Req() req: AuthenticatedRequest,
  ): Promise<{ questions: QuestionBankPrivateResponseDto[]; count: number }> {
    const questions =
      await this.questionBankService.linkExistingQuestionsToGroup(
        groupId,
        dto,
        req.user.userId,
      );
    return {
      count: questions.length,
      questions: questions.map((question) =>
        this.questionBankService.toPrivateResponse(question),
      ),
    };
  }

  @Delete('question-bank/groups/:groupId/questions/:questionId')
  @Roles(RoleName.INSTRUCTOR)
  async unlinkQuestionFromGroup(
    @Param('groupId', ParseIntPipe) groupId: number,
    @Param('questionId', ParseIntPipe) questionId: number,
    @Req() req: AuthenticatedRequest,
  ): Promise<{ message: string }> {
    await this.questionBankService.unlinkQuestionFromGroup(
      groupId,
      questionId,
      req.user.userId,
    );
    return { message: 'Question removed from group successfully' };
  }

  @Patch('question-bank/groups/:groupId/questions/reorder')
  @Roles(RoleName.INSTRUCTOR)
  reorderGroupItems(
    @Param('groupId', ParseIntPipe) groupId: number,
    @Body() dto: ReorderQuestionGroupItemsDto,
    @Req() req: AuthenticatedRequest,
  ): Promise<QuestionBankQuestionGroupItem[]> {
    return this.questionBankService.reorderQuestionGroupItems(
      groupId,
      dto,
      req.user.userId,
    );
  }

  @Post('question-bank/questions/:id/submit-for-review')
  @Roles(RoleName.INSTRUCTOR)
  async submitForReview(
    @Param('id', ParseIntPipe) id: number,
    @Req() req: AuthenticatedRequest,
  ): Promise<QuestionBankPrivateResponseDto> {
    const question = await this.questionBankService.updateQuestionReviewStatus(
      id,
      QuestionBankStatus.UNDER_REVIEW,
      req.user.userId,
      'Submitted for review',
    );
    return this.questionBankService.toPrivateResponse(question);
  }

  @Post('question-bank/questions/:id/approve')
  @Roles(RoleName.INSTRUCTOR)
  async approveQuestion(
    @Param('id', ParseIntPipe) id: number,
    @Body('comment') comment: string | undefined,
    @Req() req: AuthenticatedRequest,
  ): Promise<QuestionBankPrivateResponseDto> {
    const question = await this.questionBankService.updateQuestionReviewStatus(
      id,
      QuestionBankStatus.APPROVED,
      req.user.userId,
      comment,
    );
    return this.questionBankService.toPrivateResponse(question);
  }

  @Post('question-bank/questions/:id/reject')
  @Roles(RoleName.INSTRUCTOR)
  async rejectQuestion(
    @Param('id', ParseIntPipe) id: number,
    @Body('comment') comment: string | undefined,
    @Req() req: AuthenticatedRequest,
  ): Promise<QuestionBankPrivateResponseDto> {
    const question = await this.questionBankService.updateQuestionReviewStatus(
      id,
      QuestionBankStatus.REJECTED,
      req.user.userId,
      comment || 'Rejected',
    );
    return this.questionBankService.toPrivateResponse(question);
  }

  @Post('question-bank/questions/:id/archive')
  @Roles(RoleName.INSTRUCTOR)
  async archiveQuestion(
    @Param('id', ParseIntPipe) id: number,
    @Body('comment') comment: string | undefined,
    @Req() req: AuthenticatedRequest,
  ): Promise<QuestionBankPrivateResponseDto> {
    const question = await this.questionBankService.updateQuestionReviewStatus(
      id,
      QuestionBankStatus.ARCHIVED,
      req.user.userId,
      comment,
    );
    return this.questionBankService.toPrivateResponse(question);
  }

  @Post('question-bank/questions/:id/restore')
  @Roles(RoleName.INSTRUCTOR)
  async restoreQuestion(
    @Param('id', ParseIntPipe) id: number,
    @Body('comment') comment: string | undefined,
    @Req() req: AuthenticatedRequest,
  ): Promise<QuestionBankPrivateResponseDto> {
    const question = await this.questionBankService.restoreQuestion(
      id,
      req.user.userId,
      comment,
    );
    return this.questionBankService.toPrivateResponse(question);
  }
}
