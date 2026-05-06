import { ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsEnum,
  IsInt,
  IsObject,
  IsOptional,
  IsString,
  MaxLength,
  Min,
} from 'class-validator';
import { Type } from 'class-transformer';
import { ExamPaperLayoutMode } from '../entities/exam-paper-template.entity';

export class SaveExamPaperTemplateDto {
  @IsOptional()
  @IsInt()
  @Min(1)
  @Type(() => Number)
  courseId?: number;

  @IsString()
  @MaxLength(255)
  name: string;

  @ApiPropertyOptional({ enum: ExamPaperLayoutMode })
  @IsOptional()
  @IsEnum(ExamPaperLayoutMode)
  layoutMode?: ExamPaperLayoutMode;

  @IsOptional()
  @IsString()
  @MaxLength(20)
  pageSize?: string;

  @IsOptional()
  @IsString()
  @MaxLength(20)
  orientation?: string;

  @IsOptional()
  @IsObject()
  marginsJson?: Record<string, unknown>;

  @IsOptional()
  @IsObject()
  headerJson?: Record<string, unknown>;

  @IsOptional()
  @IsObject()
  trailingJson?: Record<string, unknown>;

  @IsOptional()
  @IsObject()
  footerJson?: Record<string, unknown>;
}

export class ApplyExamPaperTemplateDto {
  @IsOptional()
  @IsInt()
  @Min(1)
  @Type(() => Number)
  paperTemplateId?: number;

  @IsOptional()
  @IsObject()
  paperTemplateSnapshot?: Record<string, unknown>;
}
