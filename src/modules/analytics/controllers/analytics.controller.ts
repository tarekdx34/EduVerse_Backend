import {
  Controller,
  Get,
  Param,
  Query,
  Request,
  UseGuards,
  ParseIntPipe,
  ParseArrayPipe,
} from '@nestjs/common';
import {
  ApiTags,
  ApiBearerAuth,
  ApiOperation,
  ApiResponse,
  ApiParam,
  ApiQuery,
} from '@nestjs/swagger';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../auth/guards/roles.guard';
import { Roles } from '../../../common/decorators/roles.decorator';
import { RoleName } from '../../auth/entities/role.entity';
import { AnalyticsService } from '../services/analytics.service';
import { AnalyticsQueryDto } from '../dto/analytics-query.dto';

@ApiTags('📊 Analytics')
@ApiBearerAuth('JWT-auth')
@Controller('api/analytics')
@UseGuards(JwtAuthGuard, RolesGuard)
export class AnalyticsController {
  constructor(private readonly analyticsService: AnalyticsService) {}

  @Get('dashboard')
  @ApiOperation({ summary: 'Get analytics dashboard (role-based)' })
  @ApiResponse({ status: 200, description: 'Dashboard data returned' })
  async getDashboard(@Request() req) {
    const userId = req.user.userId || req.user.id;
    const roles = req.user.roles?.map((r) => r.roleName || r) || [];
    return this.analyticsService.getDashboard(userId, roles);
  }

  @Get('performance')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({ summary: 'Get performance metrics' })
  @ApiResponse({ status: 200, description: 'Performance metrics returned' })
  @ApiQuery({ name: 'courseId', required: true, type: Number })
  async getPerformanceMetrics(@Request() req, @Query() query: AnalyticsQueryDto) {
    const userId = req.user.userId || req.user.id;
    const roles = req.user.roles?.map((r) => r.roleName || r) || [];
    return this.analyticsService.getPerformanceMetrics(
      query.courseId!,
      query,
      userId,
      roles,
    );
  }

  @Get('engagement')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({ summary: 'Get engagement data' })
  @ApiResponse({ status: 200, description: 'Engagement data returned' })
  @ApiQuery({ name: 'courseId', required: true, type: Number })
  async getEngagement(@Request() req, @Query() query: AnalyticsQueryDto) {
    const userId = req.user.userId || req.user.id;
    const roles = req.user.roles?.map((r) => r.roleName || r) || [];
    return this.analyticsService.getEngagement(
      query.courseId!,
      query,
      userId,
      roles,
    );
  }

  @Get('attendance-trends')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({ summary: 'Get attendance trends' })
  @ApiResponse({ status: 200, description: 'Attendance trends returned' })
  @ApiQuery({ name: 'courseId', required: true, type: Number })
  async getAttendanceTrends(@Request() req, @Query() query: AnalyticsQueryDto) {
    const userId = req.user.userId || req.user.id;
    const roles = req.user.roles?.map((r) => r.roleName || r) || [];
    return this.analyticsService.getAttendanceTrends(
      query.courseId!,
      query,
      userId,
      roles,
    );
  }

  @Get('at-risk-students')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({ summary: 'Get at-risk students' })
  @ApiResponse({ status: 200, description: 'At-risk students returned' })
  @ApiQuery({ name: 'courseId', required: false, type: Number })
  async getAtRiskStudents(@Request() req, @Query('courseId') courseId?: number) {
    const userId = req.user.userId || req.user.id;
    const roles = req.user.roles?.map((r) => r.roleName || r) || [];
    return this.analyticsService.getAtRiskStudents(
      courseId ? Number(courseId) : undefined,
      userId,
      roles,
    );
  }

  @Get('grade-distribution')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({ summary: 'Get grade distribution' })
  @ApiResponse({ status: 200, description: 'Grade distribution returned' })
  @ApiQuery({ name: 'courseId', required: true, type: Number })
  async getGradeDistribution(
    @Request() req,
    @Query('courseId', ParseIntPipe) courseId: number,
  ) {
    const userId = req.user.userId || req.user.id;
    const roles = req.user.roles?.map((r) => r.roleName || r) || [];
    return this.analyticsService.getGradeDistribution(courseId, userId, roles);
  }

  @Get('enrollment-trends')
  @Roles(RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({ summary: 'Get enrollment trends' })
  @ApiResponse({ status: 200, description: 'Enrollment trends returned' })
  async getEnrollmentTrends(@Query() query: AnalyticsQueryDto) {
    return this.analyticsService.getEnrollmentTrends(query);
  }

  @Get('course-comparison')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({ summary: 'Compare metrics across courses' })
  @ApiResponse({ status: 200, description: 'Course comparison returned' })
  @ApiQuery({
    name: 'courseIds',
    required: true,
    type: String,
    description: 'Comma-separated course IDs',
  })
  async getCourseComparison(
    @Request() req,
    @Query(
      'courseIds',
      new ParseArrayPipe({ items: Number, separator: ',' }),
    )
    courseIds: number[],
  ) {
    const userId = req.user.userId || req.user.id;
    const roles = req.user.roles?.map((r) => r.roleName || r) || [];
    return this.analyticsService.getCourseComparison(courseIds, userId, roles);
  }

  @Get('courses/:courseId')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({ summary: 'Get course analytics' })
  @ApiResponse({ status: 200, description: 'Course analytics returned' })
  @ApiParam({ name: 'courseId', description: 'Course ID', type: Number })
  async getCourseAnalytics(
    @Request() req,
    @Param('courseId', ParseIntPipe) courseId: number,
  ) {
    const userId = req.user.userId || req.user.id;
    const roles = req.user.roles?.map((r) => r.roleName || r) || [];
    return this.analyticsService.getCourseAnalytics(courseId, userId, roles);
  }

  @Get('students/:studentId')
  @Roles(
    RoleName.INSTRUCTOR,
    RoleName.ADMIN,
    RoleName.IT_ADMIN,
    RoleName.STUDENT,
  )
  @ApiOperation({ summary: 'Get student analytics' })
  @ApiResponse({ status: 200, description: 'Student analytics returned' })
  @ApiParam({ name: 'studentId', description: 'Student ID', type: Number })
  @ApiQuery({ name: 'courseId', required: false, type: Number })
  async getStudentAnalytics(
    @Param('studentId', ParseIntPipe) studentId: number,
    @Query('courseId') courseId?: number,
  ) {
    return this.analyticsService.getStudentAnalytics(
      studentId,
      courseId ? Number(courseId) : undefined,
    );
  }

  @Get('weak-topics/:courseId')
  @ApiOperation({ summary: 'Get weak topics analysis' })
  @ApiResponse({ status: 200, description: 'Weak topics returned' })
  @ApiParam({ name: 'courseId', description: 'Course ID', type: Number })
  @ApiQuery({ name: 'userId', required: false, type: Number })
  async getWeakTopics(
    @Param('courseId', ParseIntPipe) courseId: number,
    @Query('userId') userId?: number,
  ) {
    return this.analyticsService.getWeakTopics(
      courseId,
      userId ? Number(userId) : undefined,
    );
  }
}
