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
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
  ApiParam,
  ApiBody,
} from '@nestjs/swagger';
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
  @Roles(RoleName.INSTRUCTOR, RoleName.ADMIN)
  @ApiOperation({
    summary: 'Create assignment',
    description:
      'Create a new assignment for a course. Only instructors and admins.',
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
  @Roles(RoleName.INSTRUCTOR, RoleName.ADMIN)
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
  @Roles(RoleName.INSTRUCTOR, RoleName.ADMIN)
  @ApiOperation({ summary: 'Delete assignment (soft delete)' })
  @ApiParam({ name: 'id', type: Number, description: 'Assignment ID', example: 3 })
  @ApiResponse({ status: 200, description: 'Assignment deleted' })
  async remove(@Param('id') id: number) {
    return this.assignmentsService.remove(+id);
  }

  @Patch(':id/status')
  @Roles(RoleName.INSTRUCTOR, RoleName.ADMIN)
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
}
