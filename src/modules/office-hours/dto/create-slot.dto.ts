import { IsNotEmpty, IsString, IsOptional, IsInt, IsBoolean, IsIn, IsDateString } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';

export class CreateSlotDto {
  @ApiProperty({
    description: 'Day of the week',
    enum: [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
      'MONDAY',
      'TUESDAY',
      'WEDNESDAY',
      'THURSDAY',
      'FRIDAY',
      'SATURDAY',
      'SUNDAY',
    ],
    example: 'monday',
  })
  @IsNotEmpty()
  @IsIn([
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday',
    'MONDAY',
    'TUESDAY',
    'WEDNESDAY',
    'THURSDAY',
    'FRIDAY',
    'SATURDAY',
    'SUNDAY',
  ])
  dayOfWeek: string;

  @ApiProperty({ description: 'Start time (HH:mm:ss)', example: '10:00:00' })
  @IsNotEmpty()
  @IsString()
  startTime: string;

  @ApiProperty({ description: 'End time (HH:mm:ss)', example: '12:00:00' })
  @IsNotEmpty()
  @IsString()
  endTime: string;

  @ApiPropertyOptional({ description: 'Physical location', example: 'Room 301, Building A' })
  @IsOptional()
  @IsString()
  location?: string;

  @ApiPropertyOptional({ description: 'Building name (legacy admin payload)', example: 'Engineering Building' })
  @IsOptional()
  @IsString()
  building?: string;

  @ApiPropertyOptional({ description: 'Room identifier (legacy admin payload)', example: '301' })
  @IsOptional()
  @IsString()
  room?: string;

  @ApiPropertyOptional({
    description: 'Instructor ID (admin compatibility payload)',
    example: 42,
  })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  instructorId?: number;

  @ApiPropertyOptional({
    description: 'Meeting mode',
    enum: ['in_person', 'online', 'hybrid'],
    example: 'in_person',
    default: 'in_person',
  })
  @IsOptional()
  @IsIn(['in_person', 'online', 'hybrid'])
  mode?: string;

  @ApiPropertyOptional({ description: 'Online meeting URL', example: 'https://meet.google.com/abc-123' })
  @IsOptional()
  @IsString()
  meetingUrl?: string;

  @ApiPropertyOptional({ description: 'Maximum number of appointments per slot', example: 4, default: 4 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  maxAppointments?: number;

  @ApiPropertyOptional({ description: 'Whether this slot recurs weekly', example: true, default: true })
  @IsOptional()
  @IsBoolean()
  isRecurring?: boolean;

  @ApiPropertyOptional({ description: 'Effective from date (YYYY-MM-DD)', example: '2026-03-01' })
  @IsOptional()
  @IsString()
  effectiveFrom?: string;

  @ApiPropertyOptional({ description: 'Effective until date (YYYY-MM-DD)', example: '2026-06-30' })
  @IsOptional()
  @IsString()
  effectiveUntil?: string;

  @ApiPropertyOptional({ description: 'Additional notes', example: 'Available for course CS101 students' })
  @IsOptional()
  @IsString()
  notes?: string;
}
