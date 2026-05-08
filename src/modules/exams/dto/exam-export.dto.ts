import { ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  IsOptional,
  IsBoolean,
  IsEnum,
  IsInt,
  IsObject,
  Min,
} from 'class-validator';
import { ExamExportFormat } from '../entities/exam-export.entity';

export enum ExamExportVariant {
  STUDENT = 'student',
  ANSWER_KEY = 'answer_key',
  COMBINED = 'combined',
}

export enum ExamAnswerKeyStyle {
  INLINE = 'inline',
  SEPARATE = 'separate',
}

export class ExportExamDto {
  @ApiPropertyOptional({ enum: ExamExportFormat })
  @IsOptional()
  @IsEnum(ExamExportFormat)
  format?: ExamExportFormat;

  @ApiPropertyOptional({ default: false })
  @IsOptional()
  @IsBoolean()
  includeAnswerKey?: boolean;

  @ApiPropertyOptional({ enum: ExamExportVariant })
  @IsOptional()
  @IsEnum(ExamExportVariant)
  variant?: ExamExportVariant;

  @ApiPropertyOptional({ default: true })
  @IsOptional()
  @IsBoolean()
  studentNameLine?: boolean;

  @ApiPropertyOptional({ default: true })
  @IsOptional()
  @IsBoolean()
  showCourseCode?: boolean;

  @ApiPropertyOptional({ default: false })
  @IsOptional()
  @IsBoolean()
  pageBreakPerSection?: boolean;

  @ApiPropertyOptional({ default: false })
  @IsOptional()
  @IsBoolean()
  showInstructorName?: boolean;

  @ApiPropertyOptional({ default: true })
  @IsOptional()
  @IsBoolean()
  showTotalMarks?: boolean;

  @ApiPropertyOptional({ default: true })
  @IsOptional()
  @IsBoolean()
  showQuestionMarks?: boolean;

  @ApiPropertyOptional({ enum: ExamAnswerKeyStyle })
  @IsOptional()
  @IsEnum(ExamAnswerKeyStyle)
  answerKeyStyle?: ExamAnswerKeyStyle;

  @ApiPropertyOptional()
  @IsOptional()
  @IsInt()
  @Min(1)
  @Type(() => Number)
  paperTemplateId?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsObject()
  paperTemplateSnapshot?: Record<string, unknown>;
}
