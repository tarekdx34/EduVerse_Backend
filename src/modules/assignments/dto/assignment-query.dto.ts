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
  @ApiPropertyOptional({ description: 'Filter by course ID' })
  @IsNumber()
  @Type(() => Number)
  @IsOptional()
  courseId?: number;

  @ApiPropertyOptional({ description: 'Filter by section ID' })
  @IsNumber()
  @Type(() => Number)
  @IsOptional()
  sectionId?: number;

  @ApiPropertyOptional({ enum: AssignmentStatus })
  @IsEnum(AssignmentStatus)
  @IsOptional()
  status?: AssignmentStatus;

  @ApiPropertyOptional({ description: 'Due before date (ISO 8601)' })
  @IsDateString()
  @IsOptional()
  dueBefore?: string;

  @ApiPropertyOptional({ description: 'Due after date (ISO 8601)' })
  @IsDateString()
  @IsOptional()
  dueAfter?: string;

  @ApiPropertyOptional({ description: 'Search in title' })
  @IsString()
  @IsOptional()
  search?: string;

  @ApiPropertyOptional({ description: 'Page number', default: 1 })
  @IsNumber()
  @Type(() => Number)
  @IsOptional()
  page?: number;

  @ApiPropertyOptional({ description: 'Items per page', default: 10 })
  @IsNumber()
  @Type(() => Number)
  @IsOptional()
  limit?: number;

  @ApiPropertyOptional({
    description: 'Sort by field',
    enum: ['dueDate', 'createdAt', 'title'],
  })
  @IsString()
  @IsOptional()
  sortBy?: string;

  @ApiPropertyOptional({ description: 'Sort order', enum: ['ASC', 'DESC'] })
  @IsString()
  @IsOptional()
  sortOrder?: 'ASC' | 'DESC';
}
