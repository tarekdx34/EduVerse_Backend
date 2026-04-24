import { ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsOptional,
  IsEnum,
  IsNumber,
  IsDateString,
  IsString,
  Min,
} from 'class-validator';
import { Type } from 'class-transformer';
import { CampusEventType, CampusEventStatus } from '../entities/campus-event.entity';

export class QueryCampusEventDto {
  @ApiPropertyOptional({
    description: 'Filter by event type',
    enum: ['university_wide', 'department', 'campus', 'program'],
    example: 'university_wide',
  })
  @IsEnum(CampusEventType)
  @IsOptional()
  eventType?: CampusEventType;

  @ApiPropertyOptional({
    description: 'Filter by scope ID',
    example: 1,
  })
  @IsNumber()
  @Type(() => Number)
  @IsOptional()
  scopeId?: number;

  @ApiPropertyOptional({
    description: 'Filter by status',
    enum: ['draft', 'published', 'cancelled', 'completed'],
    example: 'published',
  })
  @IsEnum(CampusEventStatus)
  @IsOptional()
  status?: CampusEventStatus;

  @ApiPropertyOptional({
    description: 'Filter events from this date (YYYY-MM-DD)',
    example: '2026-04-01',
  })
  @IsDateString()
  @IsOptional()
  fromDate?: string;

  @ApiPropertyOptional({
    description: 'Filter events until this date (YYYY-MM-DD)',
    example: '2026-04-30',
  })
  @IsDateString()
  @IsOptional()
  toDate?: string;

  @ApiPropertyOptional({
    description: 'Filter by tag',
    example: 'workshop',
  })
  @IsString()
  @IsOptional()
  tag?: string;

  @ApiPropertyOptional({
    description: 'Search in title or description',
    example: 'fun day',
  })
  @IsString()
  @IsOptional()
  search?: string;

  @ApiPropertyOptional({
    description: 'Page number for pagination',
    example: 1,
    default: 1,
  })
  @IsNumber()
  @Type(() => Number)
  @Min(1)
  @IsOptional()
  page?: number;

  @ApiPropertyOptional({
    description: 'Items per page',
    example: 10,
    default: 10,
  })
  @IsNumber()
  @Type(() => Number)
  @Min(1)
  @IsOptional()
  limit?: number;
}
