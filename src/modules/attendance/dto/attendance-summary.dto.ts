import { ApiProperty } from '@nestjs/swagger';

export class AttendanceSummaryDto {
  @ApiProperty({ description: 'Total sessions', example: 20 })
  totalSessions: number;

  @ApiProperty({ description: 'Total present count', example: 18 })
  totalPresent: number;

  @ApiProperty({ description: 'Total absent count', example: 1 })
  totalAbsent: number;

  @ApiProperty({ description: 'Total late count', example: 1 })
  totalLate: number;

  @ApiProperty({ description: 'Total excused count', example: 0 })
  totalExcused: number;

  @ApiProperty({ description: 'Attendance percentage', example: 90.0 })
  attendancePercentage: number;

  @ApiProperty({ description: 'Is at risk (below 75%)', example: false })
  isAtRisk: boolean;
}

export class StudentAttendanceSummaryDto extends AttendanceSummaryDto {
  @ApiProperty({ description: 'Student user ID', example: 21 })
  userId: number;

  @ApiProperty({ description: 'Student name', example: 'John Doe' })
  studentName: string;

  @ApiProperty({ description: 'Student email', example: 'john@example.com' })
  studentEmail: string;
}

export class CourseAttendanceSummaryDto {
  @ApiProperty({ description: 'Course ID', example: 1 })
  courseId: number;

  @ApiProperty({ description: 'Course name', example: 'Introduction to Programming' })
  courseName: string;

  @ApiProperty({ description: 'Section ID', example: 1 })
  sectionId: number;

  @ApiProperty({ description: 'Section name', example: 'Section A' })
  sectionName: string;

  @ApiProperty({ description: 'Total sessions', example: 20 })
  totalSessions: number;

  @ApiProperty({ description: 'Average attendance percentage', example: 85.5 })
  averageAttendance: number;

  @ApiProperty({ description: 'Number of at-risk students', example: 3 })
  atRiskStudentsCount: number;
}

export class WeeklyTrendDto {
  @ApiProperty({ description: 'Week start date', example: '2026-02-24' })
  weekStart: string;

  @ApiProperty({ description: 'Week end date', example: '2026-03-01' })
  weekEnd: string;

  @ApiProperty({ description: 'Number of sessions in the week', example: 3 })
  sessionsCount: number;

  @ApiProperty({ description: 'Average attendance percentage', example: 87.5 })
  averageAttendance: number;
}
