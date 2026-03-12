import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsOptional, IsEnum, IsString } from 'class-validator';
import { AttendanceStatus } from '../enums';

export class UpdateRecordDto {
  @ApiPropertyOptional({
    description: 'Attendance status',
    enum: AttendanceStatus,
    example: AttendanceStatus.PRESENT,
  })
  @IsOptional()
  @IsEnum(AttendanceStatus)
  attendanceStatus?: AttendanceStatus;

  @ApiPropertyOptional({
    description: 'Check-in time (ISO 8601)',
    example: '2026-03-01T09:05:00Z',
  })
  @IsOptional()
  @IsString()
  checkInTime?: string;

  @ApiPropertyOptional({
    description: 'Additional notes',
    example: 'Updated due to late arrival',
  })
  @IsOptional()
  @IsString()
  notes?: string;
}
