import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Transform, Type } from 'class-transformer';
import {
  ArrayMinSize,
  IsArray,
  IsBoolean,
  IsEnum,
  IsInt,
  IsNotEmpty,
  IsOptional,
  IsString,
  Max,
  MaxLength,
  Min,
  ValidateNested,
} from 'class-validator';
import {
  BloomLevel,
  QuestionBankDifficulty,
  QuestionBankStatus,
  QuestionBankType,
} from '../enums/question-bank.enums';
import { CreateQuestionAttachmentDto } from './question-attachment.dto';

export enum QuestionBankBatchStatusAction {
  SUBMIT_FOR_REVIEW = 'submit-for-review',
  APPROVE = 'approve',
  REJECT = 'reject',
  ARCHIVE = 'archive',
  RESTORE = 'restore',
}

export class CreateQuestionOptionDto {
  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  optionText: string;

  @ApiProperty({ example: false })
  @IsBoolean()
  @IsOptional()
  isCorrect?: boolean;
}

export class CreateFillBlankDto {
  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  blankKey: string;

  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  acceptableAnswer: string;

  @ApiPropertyOptional({ default: false })
  @IsBoolean()
  @IsOptional()
  isCaseSensitive?: boolean;
}

export class CreateQuestionBankQuestionDto {
  @ApiProperty()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  courseId: number;

  @ApiProperty()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  chapterId: number;

  @ApiProperty({ enum: QuestionBankType })
  @IsEnum(QuestionBankType)
  questionType: QuestionBankType;

  @ApiProperty({ enum: QuestionBankDifficulty })
  @IsEnum(QuestionBankDifficulty)
  difficulty: QuestionBankDifficulty;

  @ApiProperty({ enum: BloomLevel })
  @IsEnum(BloomLevel)
  bloomLevel: BloomLevel;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  questionText?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  questionFileId?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @MaxLength(500)
  questionFileCaption?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @MaxLength(500)
  questionFileAltText?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  expectedAnswerText?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  hints?: string;

  @ApiPropertyOptional({ enum: QuestionBankStatus })
  @IsOptional()
  @IsEnum(QuestionBankStatus)
  status?: QuestionBankStatus;

  @ApiPropertyOptional({ type: [CreateQuestionOptionDto] })
  @IsOptional()
  @IsArray()
  @ArrayMinSize(1)
  @ValidateNested({ each: true })
  @Type(() => CreateQuestionOptionDto)
  options?: CreateQuestionOptionDto[];

  @ApiPropertyOptional({ type: [CreateFillBlankDto] })
  @IsOptional()
  @IsArray()
  @ArrayMinSize(1)
  @ValidateNested({ each: true })
  @Type(() => CreateFillBlankDto)
  fillBlanks?: CreateFillBlankDto[];

  @ApiPropertyOptional({ type: [CreateQuestionAttachmentDto] })
  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => CreateQuestionAttachmentDto)
  attachments?: CreateQuestionAttachmentDto[];
}

export class UpdateQuestionBankQuestionDto {
  @ApiPropertyOptional()
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  chapterId?: number;

  @ApiPropertyOptional({ enum: QuestionBankType })
  @IsOptional()
  @IsEnum(QuestionBankType)
  questionType?: QuestionBankType;

  @ApiPropertyOptional({ enum: QuestionBankDifficulty })
  @IsOptional()
  @IsEnum(QuestionBankDifficulty)
  difficulty?: QuestionBankDifficulty;

  @ApiPropertyOptional({ enum: BloomLevel })
  @IsOptional()
  @IsEnum(BloomLevel)
  bloomLevel?: BloomLevel;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  questionText?: string | null;

  @ApiPropertyOptional()
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  questionFileId?: number | null;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @MaxLength(500)
  questionFileCaption?: string | null;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @MaxLength(500)
  questionFileAltText?: string | null;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  expectedAnswerText?: string | null;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  hints?: string | null;

  @ApiPropertyOptional({ enum: QuestionBankStatus })
  @IsOptional()
  @IsEnum(QuestionBankStatus)
  status?: QuestionBankStatus;

  @ApiPropertyOptional({ type: [CreateQuestionOptionDto] })
  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => CreateQuestionOptionDto)
  options?: CreateQuestionOptionDto[];

  @ApiPropertyOptional({ type: [CreateFillBlankDto] })
  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => CreateFillBlankDto)
  fillBlanks?: CreateFillBlankDto[];
}

export class QuestionBankQueryDto {
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

  @ApiPropertyOptional({ enum: QuestionBankType })
  @IsOptional()
  @IsEnum(QuestionBankType)
  questionType?: QuestionBankType;

  @ApiPropertyOptional({ enum: QuestionBankDifficulty })
  @IsOptional()
  @IsEnum(QuestionBankDifficulty)
  difficulty?: QuestionBankDifficulty;

  @ApiPropertyOptional({ enum: BloomLevel })
  @IsOptional()
  @IsEnum(BloomLevel)
  bloomLevel?: BloomLevel;

  @ApiPropertyOptional({ enum: QuestionBankStatus })
  @IsOptional()
  @IsEnum(QuestionBankStatus)
  status?: QuestionBankStatus;

  @ApiPropertyOptional({ description: 'Case-insensitive text search' })
  @IsOptional()
  @IsString()
  search?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @Transform(({ value, obj, key }) => {
    const raw = obj?.[key] ?? value;
    if (raw === true || raw === 'true') return true;
    if (raw === false || raw === 'false') return false;
    return value;
  })
  hasAttachments?: boolean | string;

  @ApiPropertyOptional()
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  groupId?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  createdBy?: number;

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
  @Max(100)
  limit?: number = 20;
}

export class BatchQuestionStatusDto {
  @ApiProperty({ type: [Number] })
  @IsOptional()
  @IsArray()
  @ArrayMinSize(1)
  @Type(() => Number)
  @IsInt({ each: true })
  @Min(1, { each: true })
  questionIds?: number[];

  @ApiPropertyOptional({
    description:
      'When true, applies the batch action to every question matching the provided filters.',
  })
  @IsOptional()
  @Transform(({ value, obj, key }) => {
    const raw = obj?.[key] ?? value;
    if (raw === true || raw === 'true') return true;
    if (raw === false || raw === 'false') return false;
    return value;
  })
  @IsBoolean()
  allMatchingFilters?: boolean;

  @ApiPropertyOptional({ type: [Number] })
  @IsOptional()
  @IsArray()
  @Type(() => Number)
  @IsInt({ each: true })
  @Min(1, { each: true })
  excludeQuestionIds?: number[];

  @ApiPropertyOptional({
    description:
      'Client-side selected count. The server refuses the batch if the resolved question count differs.',
  })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(0)
  expectedQuestionCount?: number;

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

  @ApiPropertyOptional({ enum: QuestionBankType })
  @IsOptional()
  @IsEnum(QuestionBankType)
  questionType?: QuestionBankType;

  @ApiPropertyOptional({ enum: QuestionBankDifficulty })
  @IsOptional()
  @IsEnum(QuestionBankDifficulty)
  difficulty?: QuestionBankDifficulty;

  @ApiPropertyOptional({ enum: BloomLevel })
  @IsOptional()
  @IsEnum(BloomLevel)
  bloomLevel?: BloomLevel;

  @ApiPropertyOptional({ enum: QuestionBankStatus })
  @IsOptional()
  @IsEnum(QuestionBankStatus)
  status?: QuestionBankStatus;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  search?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @Transform(({ value, obj, key }) => {
    const raw = obj?.[key] ?? value;
    if (raw === true || raw === 'true') return true;
    if (raw === false || raw === 'false') return false;
    return value;
  })
  hasAttachments?: boolean | string;

  @ApiPropertyOptional()
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  groupId?: number;

  @ApiProperty({ enum: QuestionBankBatchStatusAction })
  @IsEnum(QuestionBankBatchStatusAction)
  action: QuestionBankBatchStatusAction;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  comment?: string;
}

export class BatchQuestionDeleteDto {
  @ApiProperty({ type: [Number] })
  @IsOptional()
  @IsArray()
  @ArrayMinSize(1)
  @Type(() => Number)
  @IsInt({ each: true })
  @Min(1, { each: true })
  questionIds?: number[];

  @ApiPropertyOptional({
    description:
      'When true, deletes every question matching the provided filters.',
  })
  @IsOptional()
  @Transform(({ value, obj, key }) => {
    const raw = obj?.[key] ?? value;
    if (raw === true || raw === 'true') return true;
    if (raw === false || raw === 'false') return false;
    return value;
  })
  @IsBoolean()
  allMatchingFilters?: boolean;

  @ApiPropertyOptional({ type: [Number] })
  @IsOptional()
  @IsArray()
  @Type(() => Number)
  @IsInt({ each: true })
  @Min(1, { each: true })
  excludeQuestionIds?: number[];

  @ApiPropertyOptional({
    description:
      'Client-side selected count. The server refuses the batch if the resolved question count differs.',
  })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(0)
  expectedQuestionCount?: number;

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

  @ApiPropertyOptional({ enum: QuestionBankType })
  @IsOptional()
  @IsEnum(QuestionBankType)
  questionType?: QuestionBankType;

  @ApiPropertyOptional({ enum: QuestionBankDifficulty })
  @IsOptional()
  @IsEnum(QuestionBankDifficulty)
  difficulty?: QuestionBankDifficulty;

  @ApiPropertyOptional({ enum: BloomLevel })
  @IsOptional()
  @IsEnum(BloomLevel)
  bloomLevel?: BloomLevel;

  @ApiPropertyOptional({ enum: QuestionBankStatus })
  @IsOptional()
  @IsEnum(QuestionBankStatus)
  status?: QuestionBankStatus;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  search?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @Transform(({ value, obj, key }) => {
    const raw = obj?.[key] ?? value;
    if (raw === true || raw === 'true') return true;
    if (raw === false || raw === 'false') return false;
    return value;
  })
  hasAttachments?: boolean | string;

  @ApiPropertyOptional()
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  groupId?: number;
}
