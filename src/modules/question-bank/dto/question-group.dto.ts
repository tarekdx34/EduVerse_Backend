import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
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
import { QuestionGroupType } from '../entities/question-bank-question-group.entity';
import { CreateQuestionBankQuestionDto } from './question.dto';

export class CreateQuestionGroupDto {
  @ApiProperty()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  courseId: number;

  @ApiPropertyOptional()
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  chapterId?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @MaxLength(255)
  title?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  sharedPrompt?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  sharedFileId?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @MaxLength(500)
  sharedFileCaption?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @MaxLength(500)
  sharedFileAltText?: string;

  @ApiPropertyOptional({ enum: QuestionGroupType })
  @IsOptional()
  @IsEnum(QuestionGroupType)
  groupType?: QuestionGroupType;
}

export class UpdateQuestionGroupDto {
  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @MaxLength(255)
  title?: string | null;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  sharedPrompt?: string | null;

  @ApiPropertyOptional()
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  sharedFileId?: number | null;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @MaxLength(500)
  sharedFileCaption?: string | null;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @MaxLength(500)
  sharedFileAltText?: string | null;

  @ApiPropertyOptional({ enum: QuestionGroupType })
  @IsOptional()
  @IsEnum(QuestionGroupType)
  groupType?: QuestionGroupType;
}

export class BatchCreateGroupedQuestionsDto {
  @ApiProperty({ type: [CreateQuestionBankQuestionDto] })
  @IsArray()
  @ArrayMinSize(1)
  @ValidateNested({ each: true })
  @Type(() => CreateQuestionBankQuestionDto)
  questions: CreateQuestionBankQuestionDto[];
}

export class LinkQuestionGroupQuestionsDto {
  @ApiProperty({ type: [Number] })
  @IsArray()
  @ArrayMinSize(1)
  @Type(() => Number)
  @IsInt({ each: true })
  @Min(1, { each: true })
  questionIds: number[];
}

export class ReorderQuestionGroupItemDto {
  @ApiProperty()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  questionId: number;

  @ApiProperty()
  @Type(() => Number)
  @IsInt()
  @Min(0)
  itemOrder: number;
}

export class ReorderQuestionGroupItemsDto {
  @ApiProperty({ type: [ReorderQuestionGroupItemDto] })
  @IsArray()
  @ArrayMinSize(1)
  @ValidateNested({ each: true })
  @Type(() => ReorderQuestionGroupItemDto)
  items: ReorderQuestionGroupItemDto[];
}

export class QuestionGroupQueryDto {
  @ApiPropertyOptional()
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  courseId?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  chapterId?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  limit?: number;
}
