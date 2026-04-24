import { ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsOptional,
  IsNumber,
  IsDateString,
  IsEnum,
} from 'class-validator';
import { Type } from 'class-transformer';
import { EventType } from '../enums';

export class QueryScheduleDto {
  @ApiPropertyOptional({
    description: 'Specific date to query (YYYY-MM-DD)',
    example: '2026-04-15',
  })
  @IsDateString()
  @IsOptional()
  date?: string;

  @ApiPropertyOptional({
    description: 'Start date of range (YYYY-MM-DD)',
    example: '2026-04-01',
  })
  @IsDateString()
  @IsOptional()
  startDate?: string;

  @ApiPropertyOptional({
    description: 'End date of range (YYYY-MM-DD)',
    example: '2026-04-30',
  })
  @IsDateString()
  @IsOptional()
  endDate?: string;

  @ApiPropertyOptional({
    description: 'Filter by course ID',
    example: 1,
  })
  @IsNumber()
  @Type(() => Number)
  @IsOptional()
  courseId?: number;

  @ApiPropertyOptional({
    description: 'Filter by section ID',
    example: 1,
  })
  @IsNumber()
  @Type(() => Number)
  @IsOptional()
  sectionId?: number;

  @ApiPropertyOptional({
    description: 'Filter by event type',
    enum: ['lecture', 'lab', 'exam', 'assignment', 'quiz', 'meeting', 'holiday', 'academic', 'custom'],
    example: 'lecture',
  })
  @IsEnum(EventType)
  @IsOptional()
  eventType?: EventType;
}
