import {
  Controller,
  Get,
  Query,
  Param,
  Req,
  UseGuards,
  ParseIntPipe,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiParam,
  ApiResponse,
  ApiBearerAuth,
  ApiQuery,
} from '@nestjs/swagger';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../auth/guards/roles.guard';
import { ScheduleService } from '../services';
import { QueryScheduleDto } from '../dto';

@ApiTags('📅 Schedule')
@ApiBearerAuth('JWT-auth')
@Controller('api/schedule')
@UseGuards(JwtAuthGuard, RolesGuard)
export class ScheduleController {
  constructor(private readonly scheduleService: ScheduleService) {}

  @Get('my/daily')
  @ApiOperation({
    summary: 'Get my daily schedule',
    description: `
## Get Today's Schedule

Returns the current user's schedule for today (or specified date), aggregating:
- **Class schedules** from enrolled/taught courses
- **Calendar events** (personal and course-related)
- **Exams** scheduled for the day

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles**: ALL (Student, Instructor, TA, Admin)

### Role-Based Filtering
- **Students**: See schedules for enrolled courses only
- **Instructors**: See schedules for courses they teach
- **TAs**: See schedules for courses they assist
- **Admins**: See all schedules
    `,
  })
  @ApiQuery({ 
    name: 'date', 
    required: false, 
    type: String, 
    description: 'Date in YYYY-MM-DD format (defaults to today)',
    example: '2026-04-15',
  })
  @ApiResponse({ status: 200, description: 'Daily schedule retrieved successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized - Invalid or missing token' })
  async getDailySchedule(@Query('date') date: string, @Req() req: any) {
    const userId = req.user.userId || req.user.id;
    const roles = this.extractRoles(req.user);
    return this.scheduleService.getDailySchedule(userId, roles, date);
  }

  @Get('my/weekly')
  @ApiOperation({
    summary: 'Get my weekly schedule',
    description: `
## Get Weekly Schedule

Returns the current user's schedule for the week, aggregating daily schedules.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles**: ALL (Student, Instructor, TA, Admin)

### Response Structure
Returns 7 days starting from Monday of the current week (or specified start date).
    `,
  })
  @ApiQuery({ 
    name: 'startDate', 
    required: false, 
    type: String, 
    description: 'Start date of week in YYYY-MM-DD format',
    example: '2026-04-13',
  })
  @ApiResponse({ status: 200, description: 'Weekly schedule retrieved successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getWeeklySchedule(@Query('startDate') startDate: string, @Req() req: any) {
    const userId = req.user.userId || req.user.id;
    const roles = this.extractRoles(req.user);
    return this.scheduleService.getWeeklySchedule(userId, roles, startDate);
  }

  @Get('range')
  @ApiOperation({
    summary: 'Get schedule for date range',
    description: `
## Get Schedule Range

Returns events and exams within a specified date range with optional filtering.

### Query Parameters
- \`startDate\`: Start of range (YYYY-MM-DD)
- \`endDate\`: End of range (YYYY-MM-DD)
- \`eventType\`: Filter by event type
- \`courseId\`: Filter by specific course
    `,
  })
  @ApiResponse({ status: 200, description: 'Schedule range retrieved successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getScheduleRange(@Query() query: QueryScheduleDto, @Req() req: any) {
    const userId = req.user.userId || req.user.id;
    const roles = this.extractRoles(req.user);
    return this.scheduleService.getScheduleRange(userId, roles, query);
  }

  @Get('section/:sectionId')
  @ApiOperation({
    summary: 'Get section schedule',
    description: `
## Get Section Schedule

Returns all class meeting times for a specific course section.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles**: ALL
    `,
  })
  @ApiParam({ 
    name: 'sectionId', 
    description: 'Course section ID', 
    type: Number, 
    example: 1,
  })
  @ApiResponse({ status: 200, description: 'Section schedule retrieved successfully' })
  @ApiResponse({ status: 404, description: 'Section not found' })
  async getSectionSchedule(@Param('sectionId', ParseIntPipe) sectionId: number) {
    return this.scheduleService.getSectionSchedule(sectionId);
  }

  @Get('academic')
  @ApiOperation({
    summary: 'Get academic calendar',
    description: `
## Get Academic Calendar

Returns academic calendar with important dates, exam schedules, and semester milestones.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles**: ALL
    `,
  })
  @ApiQuery({ 
    name: 'semesterId', 
    required: false, 
    type: Number, 
    description: 'Filter by semester ID',
    example: 1,
  })
  @ApiResponse({ status: 200, description: 'Academic calendar retrieved successfully' })
  async getAcademicCalendar(@Query('semesterId') semesterId?: number) {
    return this.scheduleService.getAcademicCalendar(semesterId);
  }

  private extractRoles(user: any): string[] {
    if (Array.isArray(user.roles)) {
      return user.roles.map((r: any) => (typeof r === 'string' ? r : r.name || r.roleName));
    }
    return [];
  }
}
