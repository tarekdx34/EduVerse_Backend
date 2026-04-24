import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsNotEmpty,
  IsString,
  IsEnum,
  IsOptional,
  IsBoolean,
  IsDateString,
  IsNumber,
  MaxLength,
  IsArray,
  Min,
} from 'class-validator';
import { Type } from 'class-transformer';
import { CampusEventType, CampusEventStatus } from '../entities/campus-event.entity';

export class CreateCampusEventDto {
  @ApiProperty({
    description: 'Event title',
    example: 'Spring Fun Day 2026',
    maxLength: 255,
  })
  @IsString()
  @MaxLength(255)
  @IsNotEmpty()
  title: string;

  @ApiPropertyOptional({
    description: 'Event description',
    example: 'Annual spring celebration with activities, food, and entertainment.',
  })
  @IsString()
  @IsOptional()
  description?: string;

  @ApiProperty({
    description: 'Type of event',
    enum: ['university_wide', 'department', 'campus', 'program'],
    example: 'university_wide',
  })
  @IsEnum(CampusEventType)
  @IsNotEmpty()
  eventType: CampusEventType;

  @ApiPropertyOptional({
    description: 'Scope ID (department_id, campus_id, or program_id based on event_type)',
    example: 1,
  })
  @IsNumber()
  @IsOptional()
  scopeId?: number;

  @ApiProperty({
    description: 'Start date and time of the event',
    example: '2026-04-20T10:00:00Z',
  })
  @IsDateString()
  @IsNotEmpty()
  startDatetime: string;

  @ApiProperty({
    description: 'End date and time of the event',
    example: '2026-04-20T17:00:00Z',
  })
  @IsDateString()
  @IsNotEmpty()
  endDatetime: string;

  @ApiPropertyOptional({
    description: 'Location description',
    example: 'Main Campus Grounds',
    maxLength: 255,
  })
  @IsString()
  @MaxLength(255)
  @IsOptional()
  location?: string;

  @ApiPropertyOptional({
    description: 'Building name',
    example: 'Engineering Building',
    maxLength: 100,
  })
  @IsString()
  @MaxLength(100)
  @IsOptional()
  building?: string;

  @ApiPropertyOptional({
    description: 'Room number',
    example: 'Room 301',
    maxLength: 100,
  })
  @IsString()
  @MaxLength(100)
  @IsOptional()
  room?: string;

  @ApiPropertyOptional({
    description: 'Is attendance mandatory',
    example: false,
  })
  @IsBoolean()
  @IsOptional()
  isMandatory?: boolean;

  @ApiPropertyOptional({
    description: 'Does event require registration',
    example: true,
  })
  @IsBoolean()
  @IsOptional()
  registrationRequired?: boolean;

  @ApiPropertyOptional({
    description: 'Maximum number of attendees (null = unlimited)',
    example: 100,
  })
  @IsNumber()
  @Min(1)
  @IsOptional()
  maxAttendees?: number;

  @ApiPropertyOptional({
    description: 'Color code for calendar display (hex)',
    example: '#10B981',
    maxLength: 7,
  })
  @IsString()
  @MaxLength(7)
  @IsOptional()
  color?: string;

  @ApiPropertyOptional({
    description: 'Event status',
    enum: ['draft', 'published', 'cancelled', 'completed'],
    example: 'published',
  })
  @IsEnum(CampusEventStatus)
  @IsOptional()
  status?: CampusEventStatus;

  @ApiPropertyOptional({
    description: 'Event tags/categories',
    example: ['workshop', 'career', 'networking'],
    type: [String],
  })
  @IsArray()
  @IsString({ each: true })
  @IsOptional()
  tags?: string[];
}
