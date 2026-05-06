import { ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { IsDateString, IsEnum, IsInt, IsOptional, Min } from 'class-validator';
import { ExamDraftStatus } from '../entities/exam-draft.entity';
import { ExamStatus } from '../entities/exam.entity';

export class ExamListQueryDto {
  @ApiPropertyOptional({ default: 1 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page?: number = 1;

  @ApiPropertyOptional({ default: 20 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  limit?: number = 20;

  @ApiPropertyOptional()
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  courseId?: number;

  @ApiPropertyOptional({ enum: ExamStatus })
  @IsOptional()
  @IsEnum(ExamStatus)
  status?: ExamStatus;

  @ApiPropertyOptional({ description: 'Inclusive created-at lower bound' })
  @IsOptional()
  @IsDateString()
  dateFrom?: string;

  @ApiPropertyOptional({ description: 'Inclusive created-at upper bound' })
  @IsOptional()
  @IsDateString()
  dateTo?: string;
}

export class ExamDraftListQueryDto {
  @ApiPropertyOptional({ default: 1 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page?: number = 1;

  @ApiPropertyOptional({ default: 20 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  limit?: number = 20;

  @ApiPropertyOptional()
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  courseId?: number;

  @ApiPropertyOptional({ enum: ExamDraftStatus })
  @IsOptional()
  @IsEnum(ExamDraftStatus)
  status?: ExamDraftStatus;

  @ApiPropertyOptional({ description: 'Inclusive created-at lower bound' })
  @IsOptional()
  @IsDateString()
  dateFrom?: string;

  @ApiPropertyOptional({ description: 'Inclusive created-at upper bound' })
  @IsOptional()
  @IsDateString()
  dateTo?: string;
}
