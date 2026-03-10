import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Patch,
  Body,
  Param,
  Query,
  Req,
  UseGuards,
  ParseIntPipe,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiParam,
  ApiBody,
  ApiResponse,
  ApiBearerAuth,
} from '@nestjs/swagger';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../auth/guards/roles.guard';
import { Roles } from '../../auth/roles.decorator';
import { RoleName } from '../../auth/entities/role.entity';
import { LabsService } from '../services/labs.service';
import {
  CreateLabDto,
  UpdateLabDto,
  SubmitLabDto,
  GradeLabSubmissionDto,
  CreateInstructionDto,
  MarkLabAttendanceDto,
  LabQueryDto,
} from '../dto';

@ApiTags('Labs')
@ApiBearerAuth('JWT-auth')
@Controller('api/labs')
@UseGuards(JwtAuthGuard, RolesGuard)
export class LabsController {
  constructor(private readonly labsService: LabsService) {}

  // ============ LABS CRUD ============

  @Get()
  @ApiOperation({
    summary: 'List labs',
    description: 'List all labs with optional filtering by course and status. Supports pagination.',
  })
  @ApiResponse({ status: 200, description: 'Labs retrieved successfully' })
  async findAll(@Query() query: LabQueryDto) {
    return this.labsService.findAll(query);
  }

  @Post()
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN, RoleName.IT_ADMIN)
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Create lab',
    description: 'Create a new lab assignment. Requires INSTRUCTOR, TA, ADMIN, or IT_ADMIN role.',
  })
  @ApiBody({ type: CreateLabDto })
  @ApiResponse({ status: 201, description: 'Lab created successfully' })
  @ApiResponse({ status: 403, description: 'Forbidden - Insufficient role' })
  async create(@Body() dto: CreateLabDto, @Req() req: any) {
    const userId = req.user.userId || req.user.id;
    return this.labsService.create(dto, userId);
  }

  @Get(':id')
  @ApiOperation({
    summary: 'Get lab by ID',
    description: 'Get lab details including instructions.',
  })
  @ApiParam({ name: 'id', description: 'Lab ID', example: 1 })
  @ApiResponse({ status: 200, description: 'Lab retrieved successfully' })
  @ApiResponse({ status: 404, description: 'Lab not found' })
  async findOne(@Param('id', ParseIntPipe) id: number) {
    return this.labsService.findById(id);
  }

  @Put(':id')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'Update lab',
    description: 'Update lab details. Requires INSTRUCTOR, TA, ADMIN, or IT_ADMIN role.',
  })
  @ApiParam({ name: 'id', description: 'Lab ID', example: 1 })
  @ApiBody({ type: UpdateLabDto })
  @ApiResponse({ status: 200, description: 'Lab updated successfully' })
  @ApiResponse({ status: 404, description: 'Lab not found' })
  async update(@Param('id', ParseIntPipe) id: number, @Body() dto: UpdateLabDto) {
    return this.labsService.update(id, dto);
  }

  @Delete(':id')
  @Roles(RoleName.INSTRUCTOR, RoleName.ADMIN, RoleName.IT_ADMIN)
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({
    summary: 'Delete lab',
    description: 'Delete a lab. Requires INSTRUCTOR, ADMIN, or IT_ADMIN role.',
  })
  @ApiParam({ name: 'id', description: 'Lab ID', example: 1 })
  @ApiResponse({ status: 204, description: 'Lab deleted successfully' })
  @ApiResponse({ status: 404, description: 'Lab not found' })
  async remove(@Param('id', ParseIntPipe) id: number) {
    return this.labsService.remove(id);
  }

  // ============ INSTRUCTIONS ============

  @Get(':id/instructions')
  @ApiOperation({
    summary: 'Get lab instructions',
    description: 'Get all instructions for a lab, ordered by order_index.',
  })
  @ApiParam({ name: 'id', description: 'Lab ID', example: 1 })
  @ApiResponse({ status: 200, description: 'Instructions retrieved' })
  async getInstructions(@Param('id', ParseIntPipe) id: number) {
    return this.labsService.getInstructions(id);
  }

  @Post(':id/instructions')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN, RoleName.IT_ADMIN)
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Add instruction to lab',
    description: 'Add a step-by-step instruction to a lab. Supports markdown text and file attachments.',
  })
  @ApiParam({ name: 'id', description: 'Lab ID', example: 1 })
  @ApiBody({ type: CreateInstructionDto })
  @ApiResponse({ status: 201, description: 'Instruction added' })
  async addInstruction(@Param('id', ParseIntPipe) id: number, @Body() dto: CreateInstructionDto) {
    return this.labsService.addInstruction(id, dto);
  }

  // ============ SUBMISSIONS ============

  @Post(':id/submit')
  @Roles(RoleName.STUDENT)
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Submit lab work',
    description: 'Submit lab work as a student. Can include text and/or file attachment. Auto-detects late submissions.',
  })
  @ApiParam({ name: 'id', description: 'Lab ID', example: 1 })
  @ApiBody({ type: SubmitLabDto })
  @ApiResponse({ status: 201, description: 'Lab submitted successfully' })
  async submit(@Param('id', ParseIntPipe) id: number, @Body() dto: SubmitLabDto, @Req() req: any) {
    const userId = req.user.userId || req.user.id;
    return this.labsService.submit(id, userId, dto);
  }

  @Get(':id/submissions')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'List lab submissions',
    description: 'List all submissions for a lab. Requires INSTRUCTOR, TA, ADMIN, or IT_ADMIN role.',
  })
  @ApiParam({ name: 'id', description: 'Lab ID', example: 1 })
  @ApiResponse({ status: 200, description: 'Submissions retrieved' })
  async getSubmissions(@Param('id', ParseIntPipe) id: number) {
    return this.labsService.getSubmissions(id);
  }

  @Get(':id/submissions/my')
  @Roles(RoleName.STUDENT)
  @ApiOperation({
    summary: 'Get my lab submission',
    description: 'Get the current student\'s submission for a lab.',
  })
  @ApiParam({ name: 'id', description: 'Lab ID', example: 1 })
  @ApiResponse({ status: 200, description: 'Student submission retrieved' })
  async getMySubmission(@Param('id', ParseIntPipe) id: number, @Req() req: any) {
    const userId = req.user.userId || req.user.id;
    return this.labsService.getMySubmission(id, userId);
  }

  @Patch(':id/submissions/:subId/grade')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'Grade lab submission',
    description: 'Update the status of a lab submission (grade, return, request resubmit).',
  })
  @ApiParam({ name: 'id', description: 'Lab ID', example: 1 })
  @ApiParam({ name: 'subId', description: 'Submission ID', example: 1 })
  @ApiBody({ type: GradeLabSubmissionDto })
  @ApiResponse({ status: 200, description: 'Submission graded' })
  @ApiResponse({ status: 404, description: 'Submission not found' })
  async gradeSubmission(
    @Param('id', ParseIntPipe) id: number,
    @Param('subId', ParseIntPipe) subId: number,
    @Body() dto: GradeLabSubmissionDto,
  ) {
    return this.labsService.gradeSubmission(id, subId, dto);
  }

  // ============ ATTENDANCE ============

  @Post(':id/attendance')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN, RoleName.IT_ADMIN)
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Mark lab attendance',
    description: 'Mark or update a student\'s attendance for a lab session.',
  })
  @ApiParam({ name: 'id', description: 'Lab ID', example: 1 })
  @ApiBody({ type: MarkLabAttendanceDto })
  @ApiResponse({ status: 201, description: 'Attendance marked' })
  async markAttendance(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: MarkLabAttendanceDto,
    @Req() req: any,
  ) {
    const markedBy = req.user.userId || req.user.id;
    return this.labsService.markAttendance(id, dto, markedBy);
  }

  @Get(':id/attendance')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'Get lab attendance',
    description: 'Get attendance records for a lab session.',
  })
  @ApiParam({ name: 'id', description: 'Lab ID', example: 1 })
  @ApiResponse({ status: 200, description: 'Attendance records retrieved' })
  async getAttendance(@Param('id', ParseIntPipe) id: number) {
    return this.labsService.getAttendance(id);
  }
}
