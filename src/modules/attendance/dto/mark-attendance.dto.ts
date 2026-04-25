import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsNotEmpty,
  IsNumber,
  IsEnum,
  IsOptional,
  IsString,
  IsDateString,
} from 'class-validator';
import { AttendanceStatus } from '../enums';

export class MarkAttendanceDto {
  @ApiProperty({
    description: 'Session ID',
    example: 1,
  })
  @IsNotEmpty()
  @IsNumber()
  sessionId: number;

  @ApiProperty({
    description: 'Student user ID',
    example: 21,
  })
  @IsNotEmpty()
  @IsNumber()
  userId: number;

  @ApiProperty({
    description: 'Attendance status',
    enum: ['present', 'absent', 'late', 'excused'],
    example: 'present',
  })
  @IsNotEmpty()
  @IsEnum(AttendanceStatus)
  attendanceStatus: AttendanceStatus;

  @ApiPropertyOptional({
    description: 'Check-in time (ISO 8601)',
    example: '2026-03-01T09:05:00Z',
  })
  @IsOptional()
  @IsDateString()
  checkInTime?: string;

  @ApiPropertyOptional({
    description: 'Additional notes',
    example: 'Arrived 5 minutes late',
  })
  @IsOptional()
  @IsString()
  notes?: string;
}
