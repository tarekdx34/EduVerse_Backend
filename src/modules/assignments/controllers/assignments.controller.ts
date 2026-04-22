import {
  Controller,
  Post,
  Get,
  Delete,
  Param,
  Body,
  Query,
  UseGuards,
  Request,
  Patch,
  UseInterceptors,
  UploadedFile,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
  ApiParam,
  ApiBody,
  ApiConsumes,
} from '@nestjs/swagger';
import { FileInterceptor } from '@nestjs/platform-express';
import { Roles } from '../../auth/roles.decorator';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../auth/guards/roles.guard';
import { RoleName } from '../../auth/entities/role.entity';
import { AssignmentsService } from '../services';
import {
  CreateAssignmentDto,
  UpdateAssignmentDto,
  SubmitAssignmentDto,
  GradeSubmissionDto,
  AssignmentQueryDto,
  UploadAssignmentInstructionDto,
  UploadAssignmentSubmissionDto,
} from '../dto';
import { AssignmentStatus } from '../enums';

@ApiTags('📝 Assignments')
@Controller('api/assignments')
@UseGuards(JwtAuthGuard, RolesGuard)
@ApiBearerAuth('JWT-auth')
export class AssignmentsController {
  constructor(private readonly assignmentsService: AssignmentsService) {}

  @Get()
  @ApiOperation({
    summary: 'List assignments',
    description:
      'Filter by course, status, due dates. Supports pagination and sorting.',
  })
  @ApiResponse({ status: 200, description: 'Paginated list of assignments' })
  async findAll(@Query() query: AssignmentQueryDto) {
    return this.assignmentsService.findAll(query);
  }

  @Post()
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN)
  @ApiOperation({
    summary: 'Create assignment',
    description:
      'Create a new assignment for a course. Only instructors, TAs, and admins.',
  })
  @ApiResponse({ status: 201, description: 'Assignment created' })
  async create(@Body() dto: CreateAssignmentDto, @Request() req) {
    const userId = req.user.userId || req.user.id;
    return this.assignmentsService.create(dto, userId);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get assignment details', description: 'Returns assignment with course info and submissions.' })
  @ApiParam({ name: 'id', type: Number, description: 'Assignment ID', example: 3 })
  @ApiResponse({
    status: 200,
    description: 'Assignment details with submissions',
  })
  async findOne(@Param('id') id: number) {
    return this.assignmentsService.findOne(+id);
  }

  @Patch(':id')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN)
  @ApiOperation({ summary: 'Update assignment' })
  @ApiParam({ name: 'id', type: Number, description: 'Assignment ID', example: 3 })
  @ApiResponse({ status: 200, description: 'Assignment updated' })
  async update(
    @Param('id') id: number,
    @Body() dto: UpdateAssignmentDto,
    @Request() req,
  ) {
    const userId = req.user.userId || req.user.id;
    return this.assignmentsService.update(+id, dto, userId);
  }

  @Delete(':id')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN)
  @ApiOperation({ summary: 'Delete assignment (soft delete)' })
  @ApiParam({ name: 'id', type: Number, description: 'Assignment ID', example: 3 })
  @ApiResponse({ status: 200, description: 'Assignment deleted' })
  async remove(@Param('id') id: number) {
    return this.assignmentsService.remove(+id);
  }

  @Patch(':id/status')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN)
  @ApiOperation({
    summary: 'Change assignment status (publish/close/archive)',
  })
  @ApiParam({ name: 'id', type: Number, description: 'Assignment ID', example: 3 })
  @ApiBody({
    schema: {
      properties: {
        status: {
          type: 'string',
          enum: ['draft', 'published', 'closed', 'archived'],
          example: 'published',
        },
      },
    },
  })
  async changeStatus(
    @Param('id') id: number,
    @Body('status') status: AssignmentStatus,
    @Request() req,
  ) {
    const userId = req.user.userId || req.user.id;
    return this.assignmentsService.changeStatus(+id, status, userId);
  }

  @Post(':id/submit')
  @Roles(RoleName.STUDENT)
  @ApiOperation({
    summary: 'Submit assignment',
    description: 'Student submits their work',
  })
  @ApiParam({ name: 'id', type: Number, description: 'Assignment ID', example: 3 })
  async submit(
    @Param('id') id: number,
    @Body() dto: SubmitAssignmentDto,
    @Request() req,
  ) {
    const userId = req.user.userId || req.user.id;
    return this.assignmentsService.submit(+id, dto, userId);
  }

  // /submissions/my must be defined BEFORE /:subId to avoid route conflicts
  @Get(':id/submissions/my')
  @Roles(RoleName.STUDENT)
  @ApiOperation({ summary: "Get student's own submission" })
  @ApiParam({ name: 'id', type: Number, description: 'Assignment ID', example: 3 })
  async getMySubmission(@Param('id') id: number, @Request() req) {
    const userId = req.user.userId || req.user.id;
    return this.assignmentsService.getMySubmission(+id, userId);
  }

  @Get(':id/submissions')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN)
  @ApiOperation({ summary: 'List all submissions for an assignment' })
  @ApiParam({ name: 'id', type: Number, description: 'Assignment ID', example: 3 })
  async getSubmissions(@Param('id') id: number) {
    return this.assignmentsService.getSubmissions(+id);
  }

  @Patch(':id/submissions/:subId/grade')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA)
  @ApiOperation({ summary: 'Grade a submission (creates grade record)' })
  @ApiParam({ name: 'id', type: Number, description: 'Assignment ID', example: 3 })
  @ApiParam({ name: 'subId', type: Number, description: 'Submission ID', example: 1 })
  async gradeSubmission(
    @Param('id') id: number,
    @Param('subId') subId: number,
    @Body() dto: GradeSubmissionDto,
    @Request() req,
  ) {
    const userId = req.user.userId || req.user.id;
    return this.assignmentsService.gradeSubmission(+id, +subId, dto, userId);
  }

  // ============ GOOGLE DRIVE UPLOADS ============

  @Post(':id/instructions/upload')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN)
  @UseInterceptors(FileInterceptor('file'))
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Upload assignment instruction to Google Drive',
    description: 'Upload an assignment instruction file (PDF, DOCX, etc.) directly to Google Drive. Creates folder structure automatically.',
  })
  @ApiParam({ name: 'id', type: Number, description: 'Assignment ID', example: 3 })
  @ApiConsumes('multipart/form-data')
  @ApiBody({
    schema: {
      type: 'object',
      required: ['file'],
      properties: {
        file: {
          type: 'string',
          format: 'binary',
          description: 'Instruction file (PDF, DOCX, etc.)',
        },
        title: {
          type: 'string',
          description: 'Instruction title',
          example: 'Assignment 1 - Database Design Guide',
        },
        orderIndex: {
          type: 'integer',
          description: 'Order index for sorting',
          example: 1,
        },
      },
    },
  })
  @ApiResponse({ status: 201, description: 'Instruction uploaded successfully' })
  @ApiResponse({ status: 400, description: 'No file provided' })
  @ApiResponse({ status: 404, description: 'Assignment not found' })
  async uploadInstruction(
    @Param('id') id: number,
    @UploadedFile() file: Express.Multer.File,
    @Body() dto: UploadAssignmentInstructionDto,
    @Request() req,
  ) {
    if (!file) {
      throw new Error('No file provided');
    }
    const userId = req.user.userId || req.user.id;
    return this.assignmentsService.uploadInstructionToDrive(
      +id,
      file,
      dto.title,
      dto.orderIndex || 0,
      userId,
    );
  }

  @Delete(':assignmentId/instructions/:driveId')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Delete assignment instruction file',
    description: 'Delete an uploaded instruction file from an assignment. Removes the file from Google Drive and the database record.',
  })
  @ApiParam({ name: 'assignmentId', type: Number, description: 'Assignment ID', example: 3 })
  @ApiParam({ name: 'driveId', type: String, description: 'Google Drive file ID (driveId from instructionFiles array)', example: '1IOjnr6y7JRO7hcoMXkpoRIw8txm7WZlV' })
  @ApiResponse({ status: 200, description: 'Instruction file deleted successfully' })
  @ApiResponse({ status: 400, description: 'Instruction file not found or invalid driveId' })
  @ApiResponse({ status: 403, description: 'Forbidden — user not authorized' })
  @ApiResponse({ status: 404, description: 'Assignment not found' })
  async deleteInstruction(
    @Param('assignmentId') assignmentId: number,
    @Param('driveId') driveId: string,
    @Request() req,
  ) {
    const userId = req.user.userId || req.user.id;
    return this.assignmentsService.deleteInstructionFile(
      +assignmentId,
      driveId,
      userId,
    );
  }

  @Post(':id/submissions/upload')
  @Roles(RoleName.STUDENT)
  @UseInterceptors(FileInterceptor('file'))
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Upload assignment submission to Google Drive',
    description: 'Upload assignment submission file directly to Google Drive. Creates student folder automatically. Auto-detects late submissions.',
  })
  @ApiParam({ name: 'id', type: Number, description: 'Assignment ID', example: 3 })
  @ApiConsumes('multipart/form-data')
  @ApiBody({
    schema: {
      type: 'object',
      required: ['file'],
      properties: {
        file: {
          type: 'string',
          format: 'binary',
          description: 'Submission file',
        },
        submissionText: {
          type: 'string',
          description: 'Optional submission notes/comments',
          example: 'Completed all tasks as instructed.',
        },
        submissionLink: {
          type: 'string',
          description: 'Optional link to external submission (e.g., GitHub)',
          example: 'https://github.com/student/project',
        },
      },
    },
  })
  @ApiResponse({ status: 201, description: 'Submission uploaded successfully' })
  @ApiResponse({ status: 400, description: 'No file provided' })
  @ApiResponse({ status: 404, description: 'Assignment not found' })
  async uploadSubmission(
    @Param('id') id: number,
    @UploadedFile() file: Express.Multer.File,
    @Body() dto: UploadAssignmentSubmissionDto,
    @Request() req,
  ) {
    if (!file) {
      throw new Error('No file provided');
    }
    const userId = req.user.userId || req.user.id;
    return this.assignmentsService.uploadSubmissionToDrive(
      +id,
      file,
      dto.submissionText,
      dto.submissionLink,
      userId,
    );
  }
}
