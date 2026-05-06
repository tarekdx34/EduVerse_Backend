import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { PartialType } from '@nestjs/mapped-types';
import { Type } from 'class-transformer';
import {
  ArrayMinSize,
  IsArray,
  IsEnum,
  IsInt,
  IsOptional,
  IsString,
  MaxLength,
  Min,
  ValidateNested,
} from 'class-validator';
import { ExamSectionAnswerPolicy } from '../entities/exam-draft-section.entity';

export class CreateExamSectionDto {
  @ApiProperty()
  @IsString()
  @MaxLength(255)
  title: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  instructions?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @Type(() => Number)
  @Min(0)
  totalMarks?: number;

  @ApiPropertyOptional({ enum: ExamSectionAnswerPolicy })
  @IsOptional()
  @IsEnum(ExamSectionAnswerPolicy)
  answerPolicy?: ExamSectionAnswerPolicy;

  @ApiPropertyOptional()
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  requiredAnswerCount?: number;
}

export class UpdateExamSectionDto extends PartialType(CreateExamSectionDto) {}

export class ReorderExamSectionItemDto {
  @ApiProperty()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  sectionId: number;

  @ApiProperty()
  @Type(() => Number)
  @IsInt()
  @Min(0)
  sectionOrder: number;
}

export class ReorderExamSectionsDto {
  @ApiProperty({ type: [ReorderExamSectionItemDto] })
  @IsArray()
  @ArrayMinSize(1)
  @ValidateNested({ each: true })
  @Type(() => ReorderExamSectionItemDto)
  items: ReorderExamSectionItemDto[];
}

export class NormalizeSectionMarksDto {
  @ApiPropertyOptional()
  @IsOptional()
  @Type(() => Number)
  @Min(0)
  totalMarks?: number;
}
