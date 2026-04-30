import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  IsArray,
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
  QuestionBankType,
} from '../../question-bank/enums/question-bank.enums';

export class ExamGenerationRuleDto {
  @ApiProperty()
  @Type(() => Number)
  @IsInt()
  chapterId: number;

  @ApiProperty()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  count: number;

  @ApiProperty()
  @Type(() => Number)
  @Min(0)
  weightPerQuestion: number;

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
}

export class GenerateExamPreviewDto {
  @ApiProperty()
  @Type(() => Number)
  @IsInt()
  courseId: number;

  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  title: string;

  @ApiProperty({ type: [ExamGenerationRuleDto] })
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => ExamGenerationRuleDto)
  rules: ExamGenerationRuleDto[];

  @ApiPropertyOptional({ description: 'Optional deterministic seed' })
  @IsOptional()
  @IsString()
  seed?: string;
}

export class UpdateDraftItemDto {
  @ApiPropertyOptional()
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  replacementQuestionId?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @Type(() => Number)
  @Min(0)
  weight?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(0)
  itemOrder?: number;
}

