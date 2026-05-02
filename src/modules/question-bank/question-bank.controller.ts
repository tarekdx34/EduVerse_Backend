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
  UseInterceptors,
  UploadedFile,
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
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/roles.decorator';
import { RoleName } from '../auth/entities/role.entity';
import { FileResponseDto } from '../files/dto/file-response.dto';
import { CreateChapterDto, UpdateChapterDto } from './dto/chapter.dto';
import {
  CreateQuestionBankQuestionDto,
  QuestionBankQueryDto,
  UpdateQuestionBankQuestionDto,
} from './dto/question.dto';
import { CourseChapter } from './entities/course-chapter.entity';
import { QuestionBankQuestion } from './entities/question-bank-question.entity';
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
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN)
  createChapter(
    @Param('courseId', ParseIntPipe) courseId: number,
    @Body() dto: CreateChapterDto,
  ): Promise<CourseChapter> {
    return this.questionBankService.createChapter(courseId, dto);
  }

  @Get('courses/:courseId/chapters')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN, RoleName.STUDENT)
  listChapters(
    @Param('courseId', ParseIntPipe) courseId: number,
  ): Promise<CourseChapter[]> {
    return this.questionBankService.listChapters(courseId);
  }

  @Patch('courses/:courseId/chapters/:chapterId')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN)
  updateChapter(
    @Param('courseId', ParseIntPipe) courseId: number,
    @Param('chapterId', ParseIntPipe) chapterId: number,
    @Body() dto: UpdateChapterDto,
  ): Promise<CourseChapter> {
    return this.questionBankService.updateChapter(courseId, chapterId, dto);
  }

  @Delete('courses/:courseId/chapters/:chapterId')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN)
  async deleteChapter(
    @Param('courseId', ParseIntPipe) courseId: number,
    @Param('chapterId', ParseIntPipe) chapterId: number,
  ): Promise<{ message: string }> {
    await this.questionBankService.deleteChapter(courseId, chapterId);
    return { message: 'Chapter deleted successfully' };
  }

  @Post('question-bank/questions')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN)
  createQuestion(
    @Body() dto: CreateQuestionBankQuestionDto,
    @Req() req: AuthenticatedRequest,
  ): Promise<QuestionBankQuestion> {
    return this.questionBankService.createQuestion(dto, req.user.userId);
  }

  @Post('question-bank/questions/upload-image')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN)
  @UseInterceptors(FileInterceptor('image'))
  @ApiOperation({
    summary: 'Upload question image',
    description:
      'Uploads an image dedicated for question figures or full-image questions. Use returned fileId as questionFileId when creating/updating a question.',
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

  @Get('question-bank/questions')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN, RoleName.STUDENT)
  listQuestions(
    @Query() query: QuestionBankQueryDto,
  ): Promise<{ data: QuestionBankQuestion[]; total: number }> {
    return this.questionBankService.listQuestions(query);
  }

  @Get('question-bank/questions/:id')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN, RoleName.STUDENT)
  getQuestion(
    @Param('id', ParseIntPipe) id: number,
  ): Promise<QuestionBankQuestion> {
    return this.questionBankService.findQuestionById(id);
  }

  @Patch('question-bank/questions/:id')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN)
  updateQuestion(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateQuestionBankQuestionDto,
    @Req() req: AuthenticatedRequest,
  ): Promise<QuestionBankQuestion> {
    return this.questionBankService.updateQuestion(id, dto, req.user.userId);
  }

  @Delete('question-bank/questions/:id')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN)
  async deleteQuestion(
    @Param('id', ParseIntPipe) id: number,
  ): Promise<{ message: string }> {
    await this.questionBankService.deleteQuestion(id);
    return { message: 'Question deleted successfully' };
  }
}
