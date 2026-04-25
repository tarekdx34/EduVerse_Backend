import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsOptional, IsNumber, IsEnum, IsDateString } from 'class-validator';
import { Type } from 'class-transformer';
import { ApiPropertyStringEnumOptional } from '../../../common/swagger/string-enum.schema';
import { ExamType } from '../enums';

export class QueryExamScheduleDto {
  @ApiPropertyOptional({
    description: 'Filter by course ID',
    example: 1,
  })
  @IsNumber()
  @Type(() => Number)
  @IsOptional()
  courseId?: number;

  @ApiPropertyOptional({
    description: 'Filter by semester ID',
    example: 1,
  })
  @IsNumber()
  @Type(() => Number)
  @IsOptional()
  semesterId?: number;

  @ApiPropertyStringEnumOptional({
    description: 'Filter by exam type',
    enumObject: ExamType,
    example: ExamType.MIDTERM,
  })
  @IsEnum(ExamType)
  @IsOptional()
  examType?: ExamType;

  @ApiPropertyOptional({
    description: 'Filter exams from this date onwards (YYYY-MM-DD)',
    example: '2026-04-01',
  })
  @IsDateString()
  @IsOptional()
  fromDate?: string;

  @ApiPropertyOptional({
    description: 'Filter exams until this date (YYYY-MM-DD)',
    example: '2026-06-30',
  })
  @IsDateString()
  @IsOptional()
  toDate?: string;

  @ApiPropertyOptional({
    description: 'Page number for pagination',
    example: 1,
    minimum: 1,
  })
  @IsNumber()
  @Type(() => Number)
  @IsOptional()
  page?: number = 1;

  @ApiPropertyOptional({
    description: 'Number of items per page',
    example: 10,
    minimum: 1,
    maximum: 100,
  })
  @IsNumber()
  @Type(() => Number)
  @IsOptional()
  limit?: number = 10;
}
