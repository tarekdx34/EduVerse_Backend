import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsOptional, IsNumber, IsEnum, IsDateString, IsString } from 'class-validator';
import { Type } from 'class-transformer';
import { QuizType, AttemptStatus } from '../enums';

export class QuizQueryDto {
  @ApiPropertyOptional({ description: 'Filter by course ID', example: 1 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  courseId?: number;

  @ApiPropertyOptional({ description: 'Filter by quiz type', enum: ['practice', 'graded', 'midterm', 'final'] })
  @IsOptional()
  @IsEnum(QuizType)
  quizType?: QuizType;

  @ApiPropertyOptional({ description: 'Filter available quizzes only', example: true })
  @IsOptional()
  availableOnly?: boolean;

  @ApiPropertyOptional({ description: 'Search in title/description', example: 'midterm' })
  @IsOptional()
  @IsString()
  search?: string;

  @ApiPropertyOptional({ description: 'Page number', default: 1, example: 1 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  page?: number;

  @ApiPropertyOptional({ description: 'Items per page', default: 20, example: 20 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  limit?: number;
}

export class AttemptQueryDto {
  @ApiPropertyOptional({ description: 'Filter by quiz ID', example: 1 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  quizId?: number;

  @ApiPropertyOptional({ description: 'Filter by user ID', example: 5 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  userId?: number;

  @ApiPropertyOptional({ description: 'Filter by attempt status', enum: ['in_progress', 'submitted', 'graded', 'abandoned'] })
  @IsOptional()
  @IsEnum(AttemptStatus)
  status?: AttemptStatus;

  @ApiPropertyOptional({ description: 'Filter by start date (from)', example: '2026-01-01' })
  @IsOptional()
  @IsDateString()
  startDate?: string;

  @ApiPropertyOptional({ description: 'Filter by start date (to)', example: '2026-03-31' })
  @IsOptional()
  @IsDateString()
  endDate?: string;

  @ApiPropertyOptional({ description: 'Page number', default: 1 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  page?: number;

  @ApiPropertyOptional({ description: 'Items per page', default: 20 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  limit?: number;
}
