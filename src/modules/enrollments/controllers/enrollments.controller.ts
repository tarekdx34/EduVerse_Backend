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
  BadRequestException,
} from '@nestjs/common';
import { EnrollmentsService } from '../services';
import { EnrollCourseDto } from '../dto/enroll-course.dto';
import { EnrollmentResponseDto } from '../dto/enrollment-response.dto';
import { AvailableCoursesFilterDto, AvailableCoursesDto } from '../dto/available-courses.dto';
import { DropCourseDto } from '../dto/drop-course.dto';
import { Roles } from '../../auth/roles.decorator';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../auth/guards/roles.guard';
import { RoleName } from '../../auth/entities/role.entity';

@Controller('api/enrollments')
@UseGuards(JwtAuthGuard, RolesGuard)
export class EnrollmentsController {
  constructor(private readonly enrollmentsService: EnrollmentsService) {}

  /**
   * GET /api/enrollments/my-courses
   * Get all courses enrolled by the authenticated student
   */
  @Get('my-courses')
  @Roles(RoleName.STUDENT)
  async getMyEnrollments(
    @Request() req,
    @Query('semester') semester?: number,
  ): Promise<EnrollmentResponseDto[]> {
    console.log('GET MY COURSES - req.user.userId:', req.user.userId, 'req.user.id:', req.user.id);
    const userId = req.user.userId || req.user.id;
    return this.enrollmentsService.getMyEnrollments(userId, semester);
  }

  /**
   * GET /api/enrollments/available
   * Get list of available courses for student enrollment
   */
  @Get('available')
  @Roles(RoleName.STUDENT)
  async getAvailableCourses(
    @Request() req,
    @Query() filters: AvailableCoursesFilterDto,
  ): Promise<AvailableCoursesDto[]> {
    return this.enrollmentsService.getAvailableCourses(req.user.userId, filters);
  }

  /**
   * POST /api/enrollments/register
   * Enroll a student in a course section
   */
  @Post('register')
  @Roles(RoleName.STUDENT)
  async enrollCourse(
    @Request() req,
    @Body() enrollCourseDto: EnrollCourseDto,
  ): Promise<EnrollmentResponseDto> {
    // DEBUG: Check what req.user contains
    console.log('=== ENROLL DEBUG ===');
    console.log('req.user:', req.user);
    console.log('req.user.userId:', req.user.userId);
    console.log('req.user.id:', req.user.id);
    console.log('req.user properties:', Object.keys(req.user));
    console.log('==================');
    
    const userId = req.user.userId || req.user.id;
    if (!userId) {
      throw new BadRequestException('User ID not found in authentication token');
    }
    
    return this.enrollmentsService.enrollStudent(userId, enrollCourseDto);
  }

  /**
   * GET /api/enrollments/:id
   * Get enrollment details by ID
   */
  @Get(':id')
  async getEnrollmentById(@Param('id') id: number): Promise<EnrollmentResponseDto> {
    return this.enrollmentsService.getEnrollmentById(id);
  }

  /**
   * DELETE /api/enrollments/:id
   * Drop/withdraw from a course enrollment
   */
  @Delete(':id')
  async dropCourse(
    @Request() req,
    @Param('id') enrollmentId: number,
    @Body() dropCourseDto?: DropCourseDto,
  ): Promise<EnrollmentResponseDto> {
    const isAdmin = req.user.roles?.some((r) => r.roleName === RoleName.ADMIN);
    return this.enrollmentsService.dropCourse(
      enrollmentId,
      req.user.userId,
      isAdmin,
    );
  }

  /**
   * GET /api/courses/:courseId/enrollments
   * Get all enrollments for a specific course (instructor/admin only)
   */
  @Get('course/:courseId/list')
  @Roles(RoleName.INSTRUCTOR, RoleName.ADMIN)
  async getCourseEnrollments(
    @Param('courseId') courseId: number,
  ): Promise<EnrollmentResponseDto[]> {
    // This would list all sections for the course
    // Implementation depends on course structure
    return [];
  }

  /**
   * GET /api/sections/:sectionId/students
   * Get all enrolled students in a section (instructor/admin only)
   */
  @Get('section/:sectionId/students')
  @Roles(RoleName.INSTRUCTOR, RoleName.ADMIN)
  async getSectionStudents(
    @Param('sectionId') sectionId: number,
  ): Promise<EnrollmentResponseDto[]> {
    return this.enrollmentsService.getSectionStudents(sectionId);
  }

  /**
   * GET /api/sections/:sectionId/waitlist
   * Get waitlist for a section (instructor/admin only)
   */
  @Get('section/:sectionId/waitlist')
  @Roles(RoleName.INSTRUCTOR, RoleName.ADMIN)
  async getSectionWaitlist(
    @Param('sectionId') sectionId: number,
  ): Promise<EnrollmentResponseDto[]> {
    return this.enrollmentsService.getWaitlist(sectionId);
  }

  /**
   * PUT /api/enrollments/:id/status
   * Update enrollment status (admin only)
   */
  @Post(':id/status')
  @Roles(RoleName.ADMIN)
  async updateEnrollmentStatus(
    @Param('id') enrollmentId: number,
    @Body() body: { status: string },
  ): Promise<EnrollmentResponseDto> {
    // Implementation for admin to update status
    return this.enrollmentsService.getEnrollmentById(enrollmentId);
  }
}
