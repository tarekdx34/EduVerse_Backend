import {
  IsNumber,
  IsString,
  IsOptional,
  IsEnum,
  IsDateString,
} from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { AssignmentStatus } from '../enums';

export class AssignmentQueryDto {
  @ApiPropertyOptional({ description: 'Filter by course ID', example: 1 })
  @IsNumber()
  @Type(() => Number)
  @IsOptional()
  courseId?: number;

  @ApiPropertyOptional({ description: 'Filter by section ID', example: 11 })
  @IsNumber()
  @Type(() => Number)
  @IsOptional()
  sectionId?: number;

  @ApiPropertyOptional({ description: 'Filter by status', enum: AssignmentStatus, example: 'published' })
  @IsEnum(AssignmentStatus)
  @IsOptional()
  status?: AssignmentStatus;

  @ApiPropertyOptional({ description: 'Due before date (ISO 8601)', example: '2025-12-31T23:59:59Z' })
  @IsDateString()
  @IsOptional()
  dueBefore?: string;

  @ApiPropertyOptional({ description: 'Due after date (ISO 8601)', example: '2025-01-01T00:00:00Z' })
  @IsDateString()
  @IsOptional()
  dueAfter?: string;

  @ApiPropertyOptional({ description: 'Search in title', example: 'homework' })
  @IsString()
  @IsOptional()
  search?: string;

  @ApiPropertyOptional({ description: 'Page number', default: 1, example: 1 })
  @IsNumber()
  @Type(() => Number)
  @IsOptional()
  page?: number;

  @ApiPropertyOptional({ description: 'Items per page', default: 10, example: 10 })
  @IsNumber()
  @Type(() => Number)
  @IsOptional()
  limit?: number;

  @ApiPropertyOptional({
    description: 'Sort by field',
    enum: ['dueDate', 'createdAt', 'title'],
    example: 'dueDate',
  })
  @IsString()
  @IsOptional()
  sortBy?: string;

  @ApiPropertyOptional({ description: 'Sort order', enum: ['ASC', 'DESC'], example: 'ASC' })
  @IsString()
  @IsOptional()
  sortOrder?: 'ASC' | 'DESC';
}
