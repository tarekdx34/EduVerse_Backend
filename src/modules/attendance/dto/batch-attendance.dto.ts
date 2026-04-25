import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsNotEmpty,
  IsNumber,
  IsArray,
  ValidateNested,
  IsEnum,
  IsOptional,
  IsString,
} from 'class-validator';
import { Type } from 'class-transformer';
import { AttendanceStatus } from '../enums';

export class BatchAttendanceRecordDto {
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
  @IsString()
  checkInTime?: string;

  @ApiPropertyOptional({
    description: 'Additional notes',
    example: 'Arrived on time',
  })
  @IsOptional()
  @IsString()
  notes?: string;
}

export class BatchAttendanceDto {
  @ApiProperty({
    description: 'Session ID',
    example: 1,
  })
  @IsNotEmpty()
  @IsNumber()
  sessionId: number;

  @ApiProperty({
    description: 'Array of attendance records',
    type: [BatchAttendanceRecordDto],
  })
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => BatchAttendanceRecordDto)
  records: BatchAttendanceRecordDto[];
}
