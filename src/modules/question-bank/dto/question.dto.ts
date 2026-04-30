import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  ArrayMinSize,
  IsArray,
  IsBoolean,
  IsEnum,
  IsInt,
  IsNotEmpty,
  IsOptional,
  IsString,
  Min,
  ValidateNested,
} from 'class-validator';
import {
  BloomLevel,
  QuestionBankDifficulty,
  QuestionBankStatus,
  QuestionBankType,
} from '../enums/question-bank.enums';

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
  courseId: number;

  @ApiProperty()
  @Type(() => Number)
  @IsInt()
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
  questionFileId?: number;

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
}

export class UpdateQuestionBankQuestionDto {
  @ApiPropertyOptional()
  @IsOptional()
  @Type(() => Number)
  @IsInt()
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
  questionFileId?: number | null;

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
  courseId?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @Type(() => Number)
  @IsInt()
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
}

