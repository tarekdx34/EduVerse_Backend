import { IsOptional, IsNumber, IsEnum, IsBoolean } from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { GradeType } from '../enums';

export class GradeQueryDto {
  @ApiPropertyOptional({ description: 'Filter by course ID', example: 1 })
  @IsNumber()
  @IsOptional()
  @Type(() => Number)
  courseId?: number;

  @ApiPropertyOptional({ description: 'Filter by student user ID', example: 57 })
  @IsNumber()
  @IsOptional()
  @Type(() => Number)
  userId?: number;

  @ApiPropertyOptional({ description: 'Filter by grade type', enum: ['assignment', 'quiz', 'lab', 'exam', 'final', 'participation', 'project', 'other'], example: 'assignment' })
  @IsEnum(GradeType)
  @IsOptional()
  gradeType?: GradeType;

  @ApiPropertyOptional({ description: 'Filter by published status', example: true })
  @IsBoolean()
  @IsOptional()
  @Type(() => Boolean)
  isPublished?: boolean;

  @ApiPropertyOptional({ description: 'Page number', default: 1, example: 1 })
  @IsNumber()
  @IsOptional()
  @Type(() => Number)
  page?: number;

  @ApiPropertyOptional({ description: 'Items per page', default: 10, example: 10 })
  @IsNumber()
  @IsOptional()
  @Type(() => Number)
  limit?: number;
}
