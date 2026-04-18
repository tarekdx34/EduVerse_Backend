import {
  Controller,
  Get,
  Post,
  Put,
  Patch,
  Delete,
  Body,
  Param,
  Query,
  UseGuards,
  ParseIntPipe,
  Headers,
  UploadedFile,
  UseInterceptors,
  Res,
  StreamableFile,
  ForbiddenException,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
  ApiParam,
  ApiConsumes,
  ApiBody,
  ApiHeader,
} from '@nestjs/swagger';
import type { Response } from 'express';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../auth/guards/roles.guard';
import { Roles } from '../../../common/decorators/roles.decorator';
import { CurrentUser } from '../../../common/decorators/current-user.decorator';
import { RoleName } from '../../auth/entities/role.entity';
import {
  AttendanceService,
  AttendanceExcelService,
  AttendanceAiService,
  StudentFaceReferenceService,
} from '../services';
import {
  CreateSessionDto,
  UpdateSessionDto,
  MarkAttendanceDto,
  BatchAttendanceDto,
  AttendanceQueryDto,
  UpdateRecordDto,
  ImportAttendanceDto,
} from '../dto';
import { AttendanceSession, AttendanceRecord } from '../entities';

@ApiTags('📋 Attendance')
@ApiBearerAuth('JWT-auth')
@UseGuards(JwtAuthGuard, RolesGuard)
@Controller('attendance')
@ApiHeader({
  name: 'Accept-Language',
  description: 'Language preference (en, ar)',
  required: false,
  example: 'en',
})
export class AttendanceController {
  constructor(
    private readonly attendanceService: AttendanceService,
    private readonly excelService: AttendanceExcelService,
    private readonly aiService: AttendanceAiService,
    private readonly studentFaceReferenceService: StudentFaceReferenceService,
  ) {}

  // ==================== SESSION ENDPOINTS ====================

  @Post('sessions')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN)
  @ApiOperation({
    summary: 'Create a new attendance session',
    description: `
## Create Attendance Session

Creates a new attendance session for a course section. When a session is created, attendance records are automatically initialized for all enrolled students with a default status of "absent".

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: INSTRUCTOR, TA, ADMIN

### Required Fields
- \`sectionId\`: Course section ID
- \`sessionDate\`: Date of the session (YYYY-MM-DD)
- \`sessionType\`: Type of session (lecture, lab, tutorial, exam, other)

### Optional Fields
- \`startTime\` / \`endTime\`: Session time window
- \`location\`: Room/location
- \`notes\`: Additional notes

### Behavior
- Session is created with status \`scheduled\`
- All enrolled students get an initial \`absent\` record
- The instructor ID is automatically set from the authenticated user
    `,
  })
  @ApiResponse({
    status: 201,
    description: 'Session created successfully',
    type: AttendanceSession,
  })
  @ApiResponse({ status: 400, description: 'Invalid input data' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - insufficient role' })
  async createSession(
    @Body() dto: CreateSessionDto,
    @CurrentUser() user: any,
  ): Promise<AttendanceSession> {
    return this.attendanceService.createSession(dto, user.userId);
  }

  @Get('sessions')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN)
  @ApiOperation({
    summary: 'List attendance sessions with filters',
    description: `
## List Attendance Sessions

Retrieves a paginated list of attendance sessions with optional filters.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: INSTRUCTOR, TA, ADMIN

### Filtering Options
- \`sectionId\`: Filter by course section
- \`startDate\` / \`endDate\`: Filter by date range
- \`status\`: Filter by session status (scheduled, in_progress, completed, cancelled)
- \`sessionType\`: Filter by type (lecture, lab, tutorial, exam, other)

### Pagination
- \`page\`: Page number (default: 1)
- \`limit\`: Items per page (default: 20, max: 100)

### Response
Returns paginated list with \`data\` array and \`total\` count.
    `,
  })
  @ApiResponse({
    status: 200,
    description: 'List of sessions with pagination',
  })
  async findAllSessions(@Query() query: AttendanceQueryDto) {
    return this.attendanceService.findAllSessions(query);
  }

  @Get('sessions/:id')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN)
  @ApiOperation({
    summary: 'Get attendance session by ID with records',
    description: `
## Get Session Details

Retrieves detailed information about a specific attendance session including all attendance records.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: INSTRUCTOR, TA, ADMIN

### Response Includes
- Session information (date, type, status, location)
- Section details with course info
- Instructor details
- All attendance records with student info
- Attendance statistics (present/absent/late counts)
    `,
  })
  @ApiParam({ name: 'id', description: 'Session ID', example: 1 })
  @ApiResponse({
    status: 200,
    description: 'Session details with attendance records',
    type: AttendanceSession,
  })
  @ApiResponse({ status: 404, description: 'Session not found' })
  async findSessionById(
    @Param('id', ParseIntPipe) id: number,
  ): Promise<AttendanceSession> {
    return this.attendanceService.findSessionById(id);
  }

  @Put('sessions/:id')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN)
  @ApiOperation({
    summary: 'Update an attendance session',
    description: `
## Update Attendance Session

Updates an existing attendance session. Cannot update closed/completed sessions.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: INSTRUCTOR, TA, ADMIN

### Updatable Fields
- \`sessionDate\`: Date of the session
- \`sessionType\`: Type of session
- \`startTime\` / \`endTime\`: Session time window
- \`location\`: Room/location
- \`notes\`: Additional notes
- \`status\`: Session status

### Restrictions
- Cannot update sessions with status \`completed\` or \`cancelled\`
    `,
  })
  @ApiParam({ name: 'id', description: 'Session ID', example: 1 })
  @ApiResponse({
    status: 200,
    description: 'Session updated successfully',
    type: AttendanceSession,
  })
  @ApiResponse({ status: 400, description: 'Session is closed' })
  @ApiResponse({ status: 404, description: 'Session not found' })
  async updateSession(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateSessionDto,
  ): Promise<AttendanceSession> {
    return this.attendanceService.updateSession(id, dto);
  }

  @Delete('sessions/:id')
  @Roles(RoleName.INSTRUCTOR, RoleName.ADMIN)
  @ApiOperation({
    summary: 'Delete an attendance session',
    description: `
## Delete Attendance Session

Deletes an attendance session and all associated records.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: INSTRUCTOR, ADMIN

### Notes
- This is a hard delete operation
- All attendance records for this session will be deleted
- TAs cannot delete sessions (only Instructors and Admins)
    `,
  })
  @ApiParam({ name: 'id', description: 'Session ID', example: 1 })
  @ApiResponse({ status: 200, description: 'Session deleted successfully' })
  @ApiResponse({ status: 404, description: 'Session not found' })
  async deleteSession(@Param('id', ParseIntPipe) id: number): Promise<void> {
    return this.attendanceService.deleteSession(id);
  }

  @Patch('sessions/:id/close')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN)
  @ApiOperation({
    summary: 'Close an attendance session',
    description: `
## Close Attendance Session

Closes an attendance session, preventing further modifications to attendance records.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: INSTRUCTOR, TA, ADMIN

### Behavior
- Sets session status to \`completed\`
- Calculates and updates final attendance statistics
- Prevents any further changes to attendance records
- Cannot close an already closed session
    `,
  })
  @ApiParam({ name: 'id', description: 'Session ID', example: 1 })
  @ApiResponse({
    status: 200,
    description: 'Session closed successfully',
    type: AttendanceSession,
  })
  @ApiResponse({ status: 400, description: 'Session already closed' })
  @ApiResponse({ status: 404, description: 'Session not found' })
  async closeSession(
    @Param('id', ParseIntPipe) id: number,
  ): Promise<AttendanceSession> {
    return this.attendanceService.closeSession(id);
  }

  @Get('sessions/:id/records')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN)
  @ApiOperation({
    summary: 'Get all attendance records for a session',
    description: `
## Get Session Attendance Records

Retrieves all attendance records for a specific session with student details.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: INSTRUCTOR, TA, ADMIN

### Response Includes
For each record:
- Student information (ID, name, email)
- Attendance status (present, absent, late, excused)
- Check-in time (if present)
- How it was marked (manual, ai, self)
- Notes
    `,
  })
  @ApiParam({ name: 'id', description: 'Session ID', example: 1 })
  @ApiResponse({
    status: 200,
    description: 'List of attendance records',
    type: [AttendanceRecord],
  })
  @ApiResponse({ status: 404, description: 'Session not found' })
  async getSessionRecords(
    @Param('id', ParseIntPipe) id: number,
  ): Promise<AttendanceRecord[]> {
    return this.attendanceService.getSessionRecords(id);
  }

  // ==================== RECORD ENDPOINTS ====================

  @Post('records')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN)
  @ApiOperation({
    summary: 'Mark attendance for a single student',
    description: `
## Mark Single Student Attendance

Marks attendance for a single student in a session.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: INSTRUCTOR, TA, ADMIN

### Required Fields
- \`sessionId\`: Attendance session ID
- \`userId\`: Student user ID
- \`attendanceStatus\`: Status (present, absent, late, excused)

### Optional Fields
- \`notes\`: Additional notes about the attendance
- \`checkInTime\`: Manual check-in time override

### Behavior
- Updates existing record if student already has one for this session
- Cannot mark attendance for closed sessions
    `,
  })
  @ApiResponse({
    status: 201,
    description: 'Attendance marked successfully',
    type: AttendanceRecord,
  })
  @ApiResponse({ status: 400, description: 'Session is closed' })
  @ApiResponse({ status: 404, description: 'Session not found' })
  async markAttendance(
    @Body() dto: MarkAttendanceDto,
  ): Promise<AttendanceRecord> {
    return this.attendanceService.markAttendance(dto);
  }

  @Post('records/batch')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN)
  @ApiOperation({
    summary: 'Mark attendance for multiple students at once',
    description: `
## Batch Mark Attendance

Marks attendance for multiple students in a single request. Useful for quickly marking entire class.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: INSTRUCTOR, TA, ADMIN

### Required Fields
- \`sessionId\`: Attendance session ID
- \`records\`: Array of { userId, attendanceStatus, notes? }

### Behavior
- Updates existing records or creates new ones
- All operations in a single transaction
- Cannot mark attendance for closed sessions
- Partial success not allowed - all or nothing
    `,
  })
  @ApiResponse({
    status: 201,
    description: 'Batch attendance marked successfully',
    type: [AttendanceRecord],
  })
  @ApiResponse({ status: 400, description: 'Session is closed' })
  @ApiResponse({ status: 404, description: 'Session not found' })
  async markBatchAttendance(
    @Body() dto: BatchAttendanceDto,
  ): Promise<AttendanceRecord[]> {
    return this.attendanceService.markBatchAttendance(dto);
  }

  @Put('records/:id')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN)
  @ApiOperation({
    summary: 'Update an individual attendance record',
    description: `
## Update Attendance Record

Updates an existing attendance record for a student.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: INSTRUCTOR, TA, ADMIN

### Updatable Fields
- \`attendanceStatus\`: New status (present, absent, late, excused)
- \`notes\`: Additional notes
- \`checkInTime\`: Check-in time

### Restrictions
- Cannot update records for closed sessions
    `,
  })
  @ApiParam({ name: 'id', description: 'Record ID', example: 1 })
  @ApiResponse({
    status: 200,
    description: 'Record updated successfully',
    type: AttendanceRecord,
  })
  @ApiResponse({ status: 400, description: 'Session is closed' })
  @ApiResponse({ status: 404, description: 'Record not found' })
  async updateRecord(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateRecordDto,
  ): Promise<AttendanceRecord> {
    return this.attendanceService.updateRecord(id, dto);
  }

  // ==================== SUMMARY ENDPOINTS ====================

  @Get('my')
  @Roles(RoleName.STUDENT)
  @ApiOperation({
    summary: "Get current student's own attendance summary",
    description: `
## My Attendance Summary

Retrieves the authenticated student's own attendance summary across all enrolled courses.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: STUDENT

### Response Includes
For each enrolled course:
- Course and section information
- Total sessions
- Present/Absent/Late/Excused counts
- Attendance percentage
- At-risk flag (if below 75%)
    `,
  })
  @ApiResponse({
    status: 200,
    description: 'Student attendance summary',
  })
  async getMyAttendance(@CurrentUser() user: any) {
    return this.attendanceService.getStudentAttendance(user.userId);
  }

  @Get('by-student/:studentId')
  @Roles(RoleName.STUDENT, RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN)
  @ApiOperation({
    summary: 'Get attendance summary for a specific student',
    description: `
## Student Attendance Summary

Retrieves attendance summary for a specific student. Students can only view their own data unless they are instructors/TAs/admins.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: STUDENT (own data only), INSTRUCTOR, TA, ADMIN

### Query Parameters
- \`courseId\`: (Optional) Filter by specific course

### Response Includes
- Course-wise attendance breakdown
- Overall attendance percentage
- At-risk indicator
    `,
  })
  @ApiParam({ name: 'studentId', description: 'Student user ID', example: 21 })
  @ApiResponse({
    status: 200,
    description: 'Student attendance summary',
  })
  @ApiResponse({ status: 403, description: 'Forbidden - cannot access other student data' })
  async getStudentAttendance(
    @Param('studentId', ParseIntPipe) studentId: number,
    @Query('courseId') courseId?: number,
    @CurrentUser() user?: any,
  ) {
    // Authorization check
    if (user) {
      const userRoles = user.roles?.map((r: any) => r.roleName) || [];
      const isAdmin = userRoles.includes(RoleName.ADMIN) || userRoles.includes(RoleName.IT_ADMIN);
      const isInstructorOrTA = userRoles.includes(RoleName.INSTRUCTOR) || userRoles.includes(RoleName.TA);
      const isStudent = userRoles.includes(RoleName.STUDENT);

      // Admin has full access
      if (isAdmin) {
        return this.attendanceService.getStudentAttendance(studentId, courseId);
      }

      // Instructors/TAs can view attendance for courses they teach
      if (isInstructorOrTA) {
        // For simplicity, allow instructors/TAs to view any student data if a courseId is provided
        // A more complete implementation would verify the instructor teaches that specific course
        if (courseId) {
          return this.attendanceService.getStudentAttendance(studentId, courseId);
        }
        // Without courseId filter, instructors can still view student data
        // (assuming they have valid course relationships)
        return this.attendanceService.getStudentAttendance(studentId, courseId);
      }

      // Students can only view their own data
      if (isStudent && studentId !== user.userId) {
        throw new ForbiddenException('You can only view your own attendance data');
      }
    }

    return this.attendanceService.getStudentAttendance(studentId, courseId);
  }

  @Get('by-course/:courseId')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN)
  @ApiOperation({
    summary: 'Get attendance summary for a course (all sections)',
    description: `
## Course Attendance Summary

Retrieves attendance summary for all sections of a course.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: INSTRUCTOR, TA, ADMIN

### Response Includes
For each section:
- Section information
- Total sessions conducted
- Average attendance percentage
- Number of at-risk students (below 75%)
    `,
  })
  @ApiParam({ name: 'courseId', description: 'Course ID', example: 1 })
  @ApiResponse({
    status: 200,
    description: 'Course attendance summary by section',
  })
  async getCourseAttendance(@Param('courseId', ParseIntPipe) courseId: number) {
    return this.attendanceService.getCourseAttendanceSummary(courseId);
  }

  @Get('summary/:sectionId')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN)
  @ApiOperation({
    summary: 'Get attendance summary for a section',
    description: `
## Section Attendance Summary

Retrieves detailed attendance summary for a specific course section.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: INSTRUCTOR, TA, ADMIN

### Response Includes
- Section and course information
- Total sessions conducted
- Average attendance rate
- Number of at-risk students
- Per-student attendance breakdown
    `,
  })
  @ApiParam({ name: 'sectionId', description: 'Section ID', example: 1 })
  @ApiResponse({
    status: 200,
    description: 'Section attendance summary',
  })
  async getSectionSummary(@Param('sectionId', ParseIntPipe) sectionId: number) {
    return this.attendanceService.getSectionSummary(sectionId);
  }

  @Get('trends/:sectionId')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN)
  @ApiOperation({
    summary: 'Get weekly attendance trends for a section',
    description: `
## Weekly Attendance Trends

Retrieves weekly attendance trends for a section to identify patterns.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: INSTRUCTOR, TA, ADMIN

### Response Includes
Array of weekly data:
- Week number and date range
- Sessions held that week
- Average attendance percentage
- Present/Absent/Late counts

### Use Cases
- Identify declining attendance patterns
- Correlate attendance with academic calendar
- Plan interventions for at-risk periods
    `,
  })
  @ApiParam({ name: 'sectionId', description: 'Section ID', example: 1 })
  @ApiResponse({
    status: 200,
    description: 'Weekly attendance trends',
  })
  async getWeeklyTrends(@Param('sectionId', ParseIntPipe) sectionId: number) {
    return this.attendanceService.getWeeklyTrends(sectionId);
  }

  @Get('report/:sectionId')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN)
  @ApiOperation({
    summary: 'Get detailed attendance report for a section',
    description: `
## Section Attendance Report

Generates a comprehensive attendance report for a section, suitable for administrative purposes.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: INSTRUCTOR, TA, ADMIN

### Response Includes
- Complete attendance matrix (students × sessions)
- Individual student statistics
- At-risk student list
- Session-wise breakdown
    `,
  })
  @ApiParam({ name: 'sectionId', description: 'Section ID', example: 1 })
  @ApiResponse({
    status: 200,
    description: 'Detailed section attendance report',
  })
  async getSectionReport(@Param('sectionId', ParseIntPipe) sectionId: number) {
    return this.attendanceService.getSectionSummary(sectionId);
  }

  // ==================== EXCEL IMPORT/EXPORT ENDPOINTS ====================

  @Post('import-excel')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN)
  @UseInterceptors(FileInterceptor('file'))
  @ApiOperation({
    summary: 'Import attendance from Excel file',
    description: `
## Import Attendance from Excel

Imports attendance data from an Excel file for a specific session.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: INSTRUCTOR, TA, ADMIN

### Excel File Format
Required columns:
- \`student_id\` or \`email\`: Student identifier
- \`status\`: Attendance status (PRESENT/P, ABSENT/A, LATE/L, EXCUSED/E)

Optional columns:
- \`notes\`: Additional notes

### Behavior
- Validates student IDs against enrolled students
- Skips invalid/unknown students
- Returns detailed import result with success/failure counts

### File Requirements
- Format: .xlsx (Excel 2007+)
- Max size: 5MB
- First row must be headers
    `,
  })
  @ApiConsumes('multipart/form-data')
  @ApiBody({
    description: 'Excel file with attendance data',
    schema: {
      type: 'object',
      properties: {
        file: {
          type: 'string',
          format: 'binary',
          description: 'Excel file (.xlsx) with columns: student_id, status',
        },
        sessionId: {
          type: 'number',
          description: 'Session ID to import attendance for',
        },
      },
      required: ['file', 'sessionId'],
    },
  })
  @ApiResponse({
    status: 200,
    description: 'Import result with success/failure counts',
  })
  @ApiResponse({ status: 400, description: 'Invalid Excel format' })
  async importFromExcel(
    @UploadedFile() file: Express.Multer.File,
    @Body() dto: ImportAttendanceDto,
  ) {
    return this.excelService.importFromExcel(dto.sessionId, file.buffer);
  }

  @Get('export-excel/:sessionId')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN)
  @ApiOperation({
    summary: 'Export attendance session to Excel file',
    description: `
## Export Session to Excel

Exports attendance data for a single session to an Excel file.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: INSTRUCTOR, TA, ADMIN

### Excel Output
- Session information header
- Student list with:
  - Student ID, Name, Email
  - Attendance status
  - Check-in time
  - Notes
- Summary statistics
    `,
  })
  @ApiParam({ name: 'sessionId', description: 'Session ID', example: 1 })
  @ApiResponse({
    status: 200,
    description: 'Excel file download',
    content: {
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet': {},
    },
  })
  @ApiResponse({ status: 404, description: 'Session not found' })
  async exportToExcel(
    @Param('sessionId', ParseIntPipe) sessionId: number,
    @Res({ passthrough: true }) res: Response,
  ): Promise<StreamableFile> {
    const buffer = await this.excelService.exportToExcel(sessionId);
    res.set({
      'Content-Type':
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'Content-Disposition': `attachment; filename="attendance_session_${sessionId}.xlsx"`,
    });
    return new StreamableFile(buffer);
  }

  @Get('export-excel/section/:sectionId')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN)
  @ApiOperation({
    summary: 'Export all attendance for a section to Excel',
    description: `
## Export Section Attendance to Excel

Exports complete attendance data for all sessions in a section.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: INSTRUCTOR, TA, ADMIN

### Excel Output
- Section and course information
- Attendance matrix (students as rows, sessions as columns)
- Individual student attendance percentages
- At-risk students highlighted
    `,
  })
  @ApiParam({ name: 'sectionId', description: 'Section ID', example: 1 })
  @ApiResponse({
    status: 200,
    description: 'Excel file download with all sessions',
    content: {
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet': {},
    },
  })
  async exportSectionToExcel(
    @Param('sectionId', ParseIntPipe) sectionId: number,
    @Res({ passthrough: true }) res: Response,
  ): Promise<StreamableFile> {
    const buffer = await this.excelService.exportSectionToExcel(sectionId);
    res.set({
      'Content-Type':
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'Content-Disposition': `attachment; filename="attendance_section_${sectionId}.xlsx"`,
    });
    return new StreamableFile(buffer);
  }

  // ==================== AI PHOTO ENDPOINTS ====================

  @Post('face-references/me')
  @Roles(RoleName.STUDENT)
  @UseInterceptors(FileInterceptor('image'))
  @ApiOperation({
    summary: 'Upload my face reference image',
    description:
      'Uploads a student face reference image to Supabase private storage and marks it as the primary image for AI attendance.',
  })
  @ApiConsumes('multipart/form-data')
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        image: {
          type: 'string',
          format: 'binary',
          description: 'Face image (jpeg/png/webp)',
        },
      },
      required: ['image'],
    },
  })
  @ApiResponse({ status: 201, description: 'Face reference uploaded' })
  async uploadMyFaceReference(
    @UploadedFile() image: Express.Multer.File,
    @CurrentUser() user: any,
  ) {
    return this.studentFaceReferenceService.uploadMyReference(user.userId, image);
  }

  @Get('face-references/me')
  @Roles(RoleName.STUDENT)
  @ApiOperation({
    summary: 'List my face reference images',
    description:
      'Returns all active face reference images for the current student, including signed URLs.',
  })
  @ApiResponse({ status: 200, description: 'List of student face references' })
  async getMyFaceReferences(@CurrentUser() user: any) {
    return this.studentFaceReferenceService.listMyReferences(user.userId);
  }

  @Delete('face-references/me/:referenceId')
  @Roles(RoleName.STUDENT)
  @ApiOperation({
    summary: 'Delete my face reference image',
    description:
      'Deletes a student face reference image from Supabase storage and marks it inactive.',
  })
  @ApiParam({ name: 'referenceId', description: 'Face reference ID', example: 1 })
  @ApiResponse({ status: 200, description: 'Face reference deleted' })
  async deleteMyFaceReference(
    @Param('referenceId', ParseIntPipe) referenceId: number,
    @CurrentUser() user: any,
  ) {
    await this.studentFaceReferenceService.deleteMyReference(user.userId, referenceId);
    return { success: true };
  }

  @Get('face-references/section/:sectionId')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN)
  @ApiOperation({
    summary: 'Get section face references for AI matching',
    description:
      'Returns signed URLs for active primary student reference images restricted to enrolled students in the section.',
  })
  @ApiParam({ name: 'sectionId', description: 'Section ID', example: 1 })
  @ApiResponse({ status: 200, description: 'Section-scoped face references' })
  async getSectionFaceReferences(
    @Param('sectionId', ParseIntPipe) sectionId: number,
  ) {
    return this.studentFaceReferenceService.getSectionReferencesForAi(sectionId);
  }

  @Post('ai-photo')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN)
  @UseInterceptors(FileInterceptor('photo'))
  @ApiOperation({
    summary: 'Upload photo for AI-based attendance recognition',
    description: `
## AI Photo Attendance

Uploads a classroom photo for AI-based face recognition to automatically mark attendance.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: INSTRUCTOR, TA, ADMIN

### Process Flow
1. Upload photo with session ID
2. System returns a \`processingId\`
3. AI service processes the image asynchronously
4. Poll \`GET /attendance/ai-photo/{processingId}\` for results
5. Once complete, attendance records are automatically updated

### Requirements
- Photo format: JPEG, PNG
- Recommended resolution: 1920x1080 or higher
- Good lighting for accurate recognition
- Clear view of student faces

### Notes
- Processing time: 30-60 seconds typically
- Requires pre-registered student face data
- Manual review recommended for low-confidence matches
    `,
  })
  @ApiConsumes('multipart/form-data')
  @ApiBody({
    description: 'Class photo for AI processing',
    schema: {
      type: 'object',
      properties: {
        photo: {
          type: 'string',
          format: 'binary',
          description: 'Class photo for face recognition',
        },
        sessionId: {
          type: 'number',
          description: 'Session ID for attendance',
        },
      },
      required: ['photo', 'sessionId'],
    },
  })
  @ApiResponse({
    status: 200,
    description: 'Processing started, returns processing ID for polling',
  })
  @ApiResponse({ status: 404, description: 'Session not found' })
  async uploadPhotoForAi(
    @UploadedFile() photo: Express.Multer.File,
    @Body('sessionId', ParseIntPipe) sessionId: number,
    @CurrentUser() user: any,
  ) {
    // When the Files module stores the class photo, pass its id here. Otherwise NULL (no FK to files).
    return this.aiService.uploadPhotoForProcessing(
      sessionId,
      null,
      user.userId,
      photo,
    );
  }

  @Get('ai-photo/:processingId')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN)
  @ApiOperation({
    summary: 'Get AI processing result',
    description: `
## Get AI Processing Result

Polls for the result of an AI photo processing request.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: INSTRUCTOR, TA, ADMIN

### Response Includes
- Processing status (pending, processing, completed, failed)
- If completed:
  - Detected faces count
  - Matched students count
  - Unmatched faces count
  - List of matched students with confidence scores
  - Attendance records that were updated

### Polling Strategy
- Initial wait: 5 seconds
- Poll interval: 5-10 seconds
- Timeout: 2 minutes (processing failed if not complete)
    `,
  })
  @ApiParam({ name: 'processingId', description: 'Processing ID', example: 1 })
  @ApiResponse({
    status: 200,
    description: 'Processing result with matched students count',
  })
  async getAiProcessingResult(
    @Param('processingId', ParseIntPipe) processingId: number,
  ) {
    return this.aiService.getProcessingResult(processingId);
  }
}
