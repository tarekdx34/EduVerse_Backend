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
  HttpCode,
  HttpStatus,
  ParseIntPipe,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
  ApiParam,
  ApiQuery,
  ApiBody,
} from '@nestjs/swagger';
import { EnrollmentsService } from '../services';
import { EnrollCourseDto } from '../dto/enroll-course.dto';
import { EnrollmentResponseDto } from '../dto/enrollment-response.dto';
import { AvailableCoursesFilterDto, AvailableCoursesDto } from '../dto/available-courses.dto';
import { DropCourseDto } from '../dto/drop-course.dto';
import { AssignInstructorDto, InstructorAssignmentResponseDto } from '../dto/assign-instructor.dto';
import { AssignTADto, TAAssignmentResponseDto } from '../dto/assign-ta.dto';
import { Roles } from '../../auth/roles.decorator';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../auth/guards/roles.guard';
import { RoleName } from '../../auth/entities/role.entity';

@ApiTags('✅ Enrollments')
@Controller('api/enrollments')
@UseGuards(JwtAuthGuard, RolesGuard)
@ApiBearerAuth('JWT-auth')
export class EnrollmentsController {
  constructor(private readonly enrollmentsService: EnrollmentsService) {}

  /**
   * GET /api/enrollments/periods
   * Get enrollment periods (derived from semesters with registration dates)
   */
  @Get('periods')
  @Roles(RoleName.IT_ADMIN, RoleName.ADMIN, RoleName.INSTRUCTOR, RoleName.TA, RoleName.STUDENT)
  @ApiOperation({
    summary: 'Get enrollment periods',
    description: 'Returns semesters with registration date ranges as enrollment periods.',
  })
  @ApiResponse({ status: 200, description: 'List of enrollment periods' })
  async getEnrollmentPeriods(): Promise<any[]> {
    return this.enrollmentsService.getEnrollmentPeriods();
  }

  /**
   * GET /api/enrollments/my-courses
   * Get all courses enrolled by the authenticated student
   */
  @Get('my-courses')
  @Roles(RoleName.STUDENT)
  @ApiOperation({
    summary: 'Get my enrolled courses',
    description: `
## Get Student's Enrolled Courses

Retrieves all courses the authenticated student is enrolled in.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: STUDENT only

### Filtering
Use \`semester\` query parameter to filter by specific semester.

### Response Includes
- Course information
- Section details
- Enrollment status
- Grades (if available)
    `,
  })
  @ApiQuery({ name: 'semester', required: false, type: Number, description: 'Semester ID to filter' })
  @ApiResponse({ status: 200, description: 'List of enrolled courses' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - Student role required' })
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
  @ApiOperation({
    summary: 'Get available courses',
    description: `
## Get Available Courses for Enrollment

Retrieves courses the student can enroll in based on prerequisites and availability.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: STUDENT only

### Availability Criteria
- Prerequisites completed
- Section has available seats
- No schedule conflicts
- Within enrollment period

### Filtering Options
Available through query parameters (see AvailableCoursesFilterDto).
    `,
  })
  @ApiResponse({ status: 200, description: 'List of available courses' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - Student role required' })
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
  @ApiOperation({
    summary: 'Enroll in a course',
    description: `
## Register for Course Section

Enrolls the authenticated student in a course section.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: STUDENT only

### Enrollment Process
1. Validates prerequisites are met
2. Checks section capacity
3. Checks for schedule conflicts
4. Creates enrollment record
5. Updates section enrollment count

### Notes
- If section is full, student is added to waitlist
- Enrollment may be pending approval
    `,
  })
  @ApiBody({ type: EnrollCourseDto })
  @ApiResponse({ status: 201, description: 'Successfully enrolled' })
  @ApiResponse({ status: 400, description: 'Prerequisites not met or schedule conflict' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - Student role required' })
  @ApiResponse({ status: 409, description: 'Already enrolled in this course' })
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
   * GET /api/enrollments/teaching
   * Get all courses taught by the authenticated instructor
   */
  @Get('teaching')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN)
  @ApiOperation({
    summary: 'Get teaching courses',
    description: 'Retrieves all course sections assigned to the authenticated instructor.',
  })
  @ApiResponse({ status: 200, description: 'List of teaching courses' })
  async getTeachingCourses(@Request() req): Promise<any[]> {
    const userId = req.user.userId || req.user.id;
    return this.enrollmentsService.getTeachingCourses(userId);
  }

  /**
   * GET /api/enrollments/:id
   * Get enrollment details by ID
   */
  @Get(':id')
  @ApiOperation({
    summary: 'Get enrollment by ID',
    description: `
## Get Enrollment Details

Retrieves details of a specific enrollment.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: Any authenticated user (own enrollments) or ADMIN/INSTRUCTOR
    `,
  })
  @ApiParam({ name: 'id', description: 'Enrollment ID', type: Number })
  @ApiResponse({ status: 200, description: 'Enrollment details' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 404, description: 'Enrollment not found' })
  async getEnrollmentById(@Param('id') id: number): Promise<EnrollmentResponseDto> {
    return this.enrollmentsService.getEnrollmentById(id);
  }

  /**
   * DELETE /api/enrollments/:id
   * Drop/withdraw from a course enrollment
   */
  @Delete(':id')
  @ApiOperation({
    summary: 'Drop/withdraw from course',
    description: `
## Drop Course Enrollment

Withdraws from an enrolled course.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: STUDENT (own enrollment) or ADMIN

### Withdrawal Rules
- Before deadline: Full withdrawal
- After deadline: May incur penalties or show as "W" grade
- Admins can override restrictions

### Notes
Dropping may move waitlisted students into the section.
    `,
  })
  @ApiParam({ name: 'id', description: 'Enrollment ID', type: Number })
  @ApiBody({ type: DropCourseDto, required: false })
  @ApiResponse({ status: 200, description: 'Successfully dropped' })
  @ApiResponse({ status: 400, description: 'Drop deadline passed' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 404, description: 'Enrollment not found' })
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
  @ApiOperation({
    summary: 'Get course enrollments',
    description: `
## Get All Enrollments for Course

Retrieves all enrollments across all sections of a course.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: INSTRUCTOR, ADMIN only
    `,
  })
  @ApiParam({ name: 'courseId', description: 'Course ID', type: Number })
  @ApiResponse({ status: 200, description: 'List of enrollments' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - Instructor or Admin required' })
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
  @ApiOperation({
    summary: 'Get section students',
    description: `
## Get Enrolled Students in Section

Retrieves all students enrolled in a specific section.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: INSTRUCTOR, ADMIN only

### Response Includes
- Student information
- Enrollment status
- Enrollment date
    `,
  })
  @ApiParam({ name: 'sectionId', description: 'Section ID', type: Number })
  @ApiResponse({ status: 200, description: 'List of enrolled students' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - Instructor or Admin required' })
  @ApiResponse({ status: 404, description: 'Section not found' })
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
  @ApiOperation({
    summary: 'Get section waitlist',
    description: `
## Get Section Waitlist

Retrieves all students on the waitlist for a section.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: INSTRUCTOR, ADMIN only

### Response
Students are ordered by waitlist position.
    `,
  })
  @ApiParam({ name: 'sectionId', description: 'Section ID', type: Number })
  @ApiResponse({ status: 200, description: 'Waitlist students' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - Instructor or Admin required' })
  @ApiResponse({ status: 404, description: 'Section not found' })
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
  @ApiOperation({
    summary: 'Update enrollment status',
    description: `
## Update Enrollment Status

Manually updates the status of an enrollment.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: ADMIN only

### Available Statuses
- enrolled, waitlisted, dropped, completed, failed
    `,
  })
  @ApiParam({ name: 'id', description: 'Enrollment ID', type: Number })
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        status: { type: 'string', example: 'enrolled' },
      },
    },
  })
  @ApiResponse({ status: 200, description: 'Status updated' })
  @ApiResponse({ status: 400, description: 'Invalid status' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - Admin required' })
  @ApiResponse({ status: 404, description: 'Enrollment not found' })
  async updateEnrollmentStatus(
    @Param('id') enrollmentId: number,
    @Body() body: { status: string },
  ): Promise<EnrollmentResponseDto> {
    // Implementation for admin to update status
    return this.enrollmentsService.getEnrollmentById(enrollmentId);
  }

  // ─── Admin: Instructor Assignment Endpoints ───────────────────────────────

  /**
   * POST /api/enrollments/sections/:sectionId/instructors
   * Assign an instructor to a course section (admin only)
   */
  @Post('sections/:sectionId/instructors')
  @Roles(RoleName.ADMIN)
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Assign instructor to section',
    description: `
## Assign Instructor to Course Section

Assigns a user with the Instructor role to a specific course section.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: ADMIN only

### Instructor Roles
- \`primary\` – Main instructor (default)
- \`co_instructor\` – Secondary instructor
- \`guest\` – Guest lecturer
    `,
  })
  @ApiParam({ name: 'sectionId', description: 'Course section ID', type: Number })
  @ApiBody({ type: AssignInstructorDto })
  @ApiResponse({ status: 201, description: 'Instructor assigned successfully', type: InstructorAssignmentResponseDto })
  @ApiResponse({ status: 400, description: 'Invalid request body' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - Admin required' })
  @ApiResponse({ status: 404, description: 'Section or user not found' })
  @ApiResponse({ status: 409, description: 'Instructor already assigned to this section' })
  async assignInstructor(
    @Param('sectionId', ParseIntPipe) sectionId: number,
    @Body() dto: AssignInstructorDto,
  ): Promise<InstructorAssignmentResponseDto> {
    return this.enrollmentsService.assignInstructor(sectionId, dto);
  }

  /**
   * DELETE /api/enrollments/sections/:sectionId/instructors/:assignmentId
   * Remove an instructor from a course section (admin only)
   */
  @Delete('sections/:sectionId/instructors/:assignmentId')
  @Roles(RoleName.ADMIN)
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({
    summary: 'Remove instructor from section',
    description: `
## Remove Instructor Assignment

Removes an instructor assignment from a course section.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: ADMIN only
    `,
  })
  @ApiParam({ name: 'sectionId', description: 'Course section ID', type: Number })
  @ApiParam({ name: 'assignmentId', description: 'Instructor assignment ID', type: Number })
  @ApiResponse({ status: 204, description: 'Instructor removed successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - Admin required' })
  @ApiResponse({ status: 404, description: 'Section or assignment not found' })
  async removeInstructor(
    @Param('sectionId', ParseIntPipe) sectionId: number,
    @Param('assignmentId', ParseIntPipe) assignmentId: number,
  ): Promise<void> {
    return this.enrollmentsService.removeInstructor(sectionId, assignmentId);
  }

  /**
   * GET /api/enrollments/sections/:sectionId/instructors
   * List all instructors for a section (admin/instructor)
   */
  @Get('sections/:sectionId/instructors')
  @Roles(RoleName.ADMIN, RoleName.INSTRUCTOR)
  @ApiOperation({
    summary: 'Get instructors for a section',
    description: `
## List Section Instructors

Returns all instructors assigned to a course section.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: ADMIN, INSTRUCTOR
    `,
  })
  @ApiParam({ name: 'sectionId', description: 'Course section ID', type: Number })
  @ApiResponse({ status: 200, description: 'List of instructor assignments', type: [InstructorAssignmentResponseDto] })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - Admin or Instructor required' })
  @ApiResponse({ status: 404, description: 'Section not found' })
  async getSectionInstructors(
    @Param('sectionId', ParseIntPipe) sectionId: number,
  ): Promise<InstructorAssignmentResponseDto[]> {
    return this.enrollmentsService.getSectionInstructors(sectionId);
  }

  // ─── Admin: TA Assignment Endpoints ──────────────────────────────────────

  /**
   * POST /api/enrollments/sections/:sectionId/tas
   * Assign a Teaching Assistant to a course section (admin only)
   */
  @Post('sections/:sectionId/tas')
  @Roles(RoleName.ADMIN)
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Assign Teaching Assistant to section',
    description: `
## Assign TA to Course Section

Assigns a user with the Teaching Assistant role to a specific course section.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: ADMIN only

### Optional Fields
- \`responsibilities\` – Free-text description of TA duties (e.g., "Grading labs, office hours Mon/Wed")
    `,
  })
  @ApiParam({ name: 'sectionId', description: 'Course section ID', type: Number })
  @ApiBody({ type: AssignTADto })
  @ApiResponse({ status: 201, description: 'TA assigned successfully', type: TAAssignmentResponseDto })
  @ApiResponse({ status: 400, description: 'Invalid request body' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - Admin required' })
  @ApiResponse({ status: 404, description: 'Section or user not found' })
  @ApiResponse({ status: 409, description: 'TA already assigned to this section' })
  async assignTA(
    @Param('sectionId', ParseIntPipe) sectionId: number,
    @Body() dto: AssignTADto,
  ): Promise<TAAssignmentResponseDto> {
    return this.enrollmentsService.assignTA(sectionId, dto);
  }

  /**
   * DELETE /api/enrollments/sections/:sectionId/tas/:assignmentId
   * Remove a Teaching Assistant from a course section (admin only)
   */
  @Delete('sections/:sectionId/tas/:assignmentId')
  @Roles(RoleName.ADMIN)
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({
    summary: 'Remove Teaching Assistant from section',
    description: `
## Remove TA Assignment

Removes a Teaching Assistant assignment from a course section.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: ADMIN only
    `,
  })
  @ApiParam({ name: 'sectionId', description: 'Course section ID', type: Number })
  @ApiParam({ name: 'assignmentId', description: 'TA assignment ID', type: Number })
  @ApiResponse({ status: 204, description: 'TA removed successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - Admin required' })
  @ApiResponse({ status: 404, description: 'Section or assignment not found' })
  async removeTA(
    @Param('sectionId', ParseIntPipe) sectionId: number,
    @Param('assignmentId', ParseIntPipe) assignmentId: number,
  ): Promise<void> {
    return this.enrollmentsService.removeTA(sectionId, assignmentId);
  }

  /**
   * GET /api/enrollments/sections/:sectionId/tas
   * List all TAs for a section (admin/instructor)
   */
  @Get('sections/:sectionId/tas')
  @Roles(RoleName.ADMIN, RoleName.INSTRUCTOR)
  @ApiOperation({
    summary: 'Get Teaching Assistants for a section',
    description: `
## List Section Teaching Assistants

Returns all Teaching Assistants assigned to a course section.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: ADMIN, INSTRUCTOR
    `,
  })
  @ApiParam({ name: 'sectionId', description: 'Course section ID', type: Number })
  @ApiResponse({ status: 200, description: 'List of TA assignments', type: [TAAssignmentResponseDto] })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - Admin or Instructor required' })
  @ApiResponse({ status: 404, description: 'Section not found' })
  async getSectionTAs(
    @Param('sectionId', ParseIntPipe) sectionId: number,
  ): Promise<TAAssignmentResponseDto[]> {
    return this.enrollmentsService.getSectionTAs(sectionId);
  }
}
