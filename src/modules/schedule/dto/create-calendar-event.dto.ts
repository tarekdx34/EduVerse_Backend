import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsNotEmpty,
  IsString,
  IsNumber,
  IsEnum,
  IsOptional,
  IsBoolean,
  IsDateString,
  MaxLength,
  Min,
  Max,
} from 'class-validator';
import { Type } from 'class-transformer';
import { EventType, EventStatus } from '../enums';

export class CreateCalendarEventDto {
  @ApiProperty({
    description: 'Event title',
    example: 'Midterm Exam',
    maxLength: 255,
  })
  @IsString()
  @MaxLength(255)
  @IsNotEmpty()
  title: string;

  @ApiPropertyOptional({
    description: 'Event description',
    example: 'Midterm examination for CS101',
  })
  @IsString()
  @IsOptional()
  description?: string;

  @ApiProperty({
    description: 'Type of event',
    enum: ['lecture', 'lab', 'exam', 'assignment', 'quiz', 'meeting', 'holiday', 'academic', 'custom'],
    example: 'exam',
  })
  @IsEnum(EventType)
  @IsNotEmpty()
  eventType: EventType;

  @ApiProperty({
    description: 'Start time of the event',
    example: '2026-04-15T09:00:00Z',
  })
  @IsDateString()
  @IsNotEmpty()
  startTime: string;

  @ApiProperty({
    description: 'End time of the event',
    example: '2026-04-15T11:00:00Z',
  })
  @IsDateString()
  @IsNotEmpty()
  endTime: string;

  @ApiPropertyOptional({
    description: 'Location of the event',
    example: 'Room 101, Building A',
    maxLength: 255,
  })
  @IsString()
  @MaxLength(255)
  @IsOptional()
  location?: string;

  @ApiPropertyOptional({
    description: 'Color code for the event (hex)',
    example: '#3B82F6',
    maxLength: 7,
  })
  @IsString()
  @MaxLength(7)
  @IsOptional()
  color?: string;

  @ApiPropertyOptional({
    description: 'Course ID if this is a course-related event',
    example: 1,
  })
  @IsNumber()
  @IsOptional()
  courseId?: number;

  @ApiPropertyOptional({
    description: 'Whether the event is recurring',
    example: false,
  })
  @IsBoolean()
  @IsOptional()
  isRecurring?: boolean;

  @ApiPropertyOptional({
    description: 'Recurrence pattern (e.g., "weekly", "daily", "monthly")',
    example: 'weekly',
    maxLength: 100,
  })
  @IsString()
  @MaxLength(100)
  @IsOptional()
  recurrencePattern?: string;

  @ApiPropertyOptional({
    description: 'Reminder time in minutes before event',
    example: 30,
    minimum: 0,
    maximum: 10080, // 7 days
  })
  @IsNumber()
  @Min(0)
  @Max(10080)
  @IsOptional()
  reminderMinutes?: number;

  @ApiPropertyOptional({
    description: 'Event status',
    enum: ['scheduled', 'completed', 'cancelled'],
    example: 'scheduled',
  })
  @IsEnum(EventStatus)
  @IsOptional()
  status?: EventStatus;
}
