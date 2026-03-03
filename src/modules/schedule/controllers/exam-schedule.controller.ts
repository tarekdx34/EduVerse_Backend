import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
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
import { ExamScheduleService } from '../services';
import {
  CreateExamScheduleDto,
  UpdateExamScheduleDto,
  QueryExamScheduleDto,
} from '../dto';

@ApiTags('📝 Exam Schedules')
@ApiBearerAuth('JWT-auth')
@Controller('api/exams/schedule')
@UseGuards(JwtAuthGuard, RolesGuard)
export class ExamScheduleController {
  constructor(private readonly examService: ExamScheduleService) {}

  @Get()
  @ApiOperation({
    summary: 'List exam schedules',
    description: `
## List Exam Schedules

Returns paginated list of exam schedules with optional filtering.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles**: ALL (filtered by role)

### Role-Based Filtering
- **Students**: See exams for enrolled courses only
- **Instructors**: See exams for courses they teach
- **TAs**: See exams for courses they assist
- **Admins**: See all exam schedules

### Query Parameters
- \`courseId\`: Filter by course
- \`semesterId\`: Filter by semester
- \`examType\`: Filter by type (midterm, final, quiz, makeup)
- \`fromDate\`: Filter from date
- \`toDate\`: Filter until date
    `,
  })
  @ApiResponse({ status: 200, description: 'Paginated list of exam schedules' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async findAll(@Query() query: QueryExamScheduleDto, @Req() req: any) {
    const userId = req.user.userId || req.user.id;
    const roles = this.extractRoles(req.user);
    return this.examService.findAll(query, userId, roles);
  }

  @Get('conflicts')
  @Roles(RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'Check exam conflicts',
    description: `
## Check Exam Conflicts

Identifies overlapping exam schedules that could affect students enrolled in multiple courses.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles**: ADMIN, IT_ADMIN only

### Use Cases
- Identify scheduling conflicts before finalizing exam dates
- Generate conflict reports for academic planning
    `,
  })
  @ApiResponse({ status: 200, description: 'List of conflicting exam schedules' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - Admin role required' })
  async checkConflicts(
    @Query('courseId') courseId?: number,
    @Query('semesterId') semesterId?: number,
  ) {
    return this.examService.checkExamConflicts(courseId, semesterId);
  }

  @Get(':id')
  @ApiOperation({
    summary: 'Get exam schedule by ID',
    description: `
## Get Exam Details

Returns detailed information about a specific exam schedule.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles**: ALL
    `,
  })
  @ApiParam({ name: 'id', description: 'Exam schedule ID', type: Number, example: 1 })
  @ApiResponse({ status: 200, description: 'Exam schedule details' })
  @ApiResponse({ status: 404, description: 'Exam schedule not found' })
  async findById(@Param('id', ParseIntPipe) id: number, @Req() req: any) {
    const userId = req.user.userId || req.user.id;
    const roles = this.extractRoles(req.user);
    return this.examService.findById(id, userId, roles);
  }

  @Post()
  @Roles(RoleName.INSTRUCTOR, RoleName.ADMIN, RoleName.IT_ADMIN)
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Create exam schedule',
    description: `
## Create New Exam Schedule

Creates a new exam schedule for a course.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles**: INSTRUCTOR, ADMIN only

### Conflict Detection
The system automatically checks for:
- Same location/time conflicts
- Overlapping exam times

### Required Fields
- \`courseId\`: Course ID
- \`semesterId\`: Semester ID
- \`examType\`: Type of exam
- \`examDate\`: Date of exam
- \`startTime\`: Start time
- \`durationMinutes\`: Duration in minutes
    `,
  })
  @ApiBody({ type: CreateExamScheduleDto })
  @ApiResponse({ status: 201, description: 'Exam schedule created successfully' })
  @ApiResponse({ status: 400, description: 'Invalid input data' })
  @ApiResponse({ status: 403, description: 'Forbidden - Instructor/Admin role required' })
  @ApiResponse({ status: 409, description: 'Exam schedule conflict' })
  async create(@Body() dto: CreateExamScheduleDto, @Req() req: any) {
    const userId = req.user.userId || req.user.id;
    const roles = this.extractRoles(req.user);
    return this.examService.create(dto, userId, roles);
  }

  @Put(':id')
  @Roles(RoleName.INSTRUCTOR, RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'Update exam schedule',
    description: `
## Update Exam Schedule

Updates an existing exam schedule.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles**: INSTRUCTOR (own courses), ADMIN

### Conflict Detection
If date/time changes, conflict detection is re-run.
    `,
  })
  @ApiParam({ name: 'id', description: 'Exam schedule ID', type: Number, example: 1 })
  @ApiBody({ type: UpdateExamScheduleDto })
  @ApiResponse({ status: 200, description: 'Exam schedule updated successfully' })
  @ApiResponse({ status: 404, description: 'Exam schedule not found' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  @ApiResponse({ status: 409, description: 'Exam schedule conflict' })
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateExamScheduleDto,
    @Req() req: any,
  ) {
    const userId = req.user.userId || req.user.id;
    const roles = this.extractRoles(req.user);
    return this.examService.update(id, dto, userId, roles);
  }

  @Delete(':id')
  @Roles(RoleName.INSTRUCTOR, RoleName.ADMIN, RoleName.IT_ADMIN)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Delete exam schedule',
    description: `
## Delete Exam Schedule

Removes an exam schedule from the system.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles**: INSTRUCTOR (own courses), ADMIN
    `,
  })
  @ApiParam({ name: 'id', description: 'Exam schedule ID', type: Number, example: 1 })
  @ApiResponse({ status: 200, description: 'Exam schedule deleted successfully' })
  @ApiResponse({ status: 404, description: 'Exam schedule not found' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  async delete(@Param('id', ParseIntPipe) id: number, @Req() req: any) {
    const userId = req.user.userId || req.user.id;
    const roles = this.extractRoles(req.user);
    return this.examService.delete(id, userId, roles);
  }

  private extractRoles(user: any): string[] {
    if (Array.isArray(user.roles)) {
      return user.roles.map((r: any) => (typeof r === 'string' ? r : r.name || r.roleName));
    }
    return [];
  }
}
