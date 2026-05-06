import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  IsArray,
  IsEnum,
  IsInt,
  IsNotEmpty,
  IsOptional,
  IsString,
  IsNumber,
  Min,
  MaxLength,
  ValidateNested,
  ValidateIf,
  ArrayNotEmpty,
  ArrayUnique,
} from 'class-validator';
import {
  BloomLevel,
  QuestionBankDifficulty,
  QuestionBankType,
} from '../../question-bank/enums/question-bank.enums';
import {
  ExamMarkDistributionMode,
  ExamRoundingPolicy,
} from '../entities/exam-draft.entity';
import { ExamSectionAnswerPolicy } from '../entities/exam-draft-section.entity';

export enum ExamGroupSelectionMode {
  INDEPENDENT = 'independent',
  KEEP_GROUP_TOGETHER = 'keep_group_together',
  EXCLUDE_GROUPED = 'exclude_grouped',
}

export enum ExamGenerationScope {
  COURSE = 'course',
  CHAPTER = 'chapter',
  CHAPTERS = 'chapters',
  GROUP = 'group',
}

export class ExamGenerationRuleDto {
  @ApiPropertyOptional({ enum: ExamGenerationScope })
  @IsOptional()
  @IsEnum(ExamGenerationScope)
  scope?: ExamGenerationScope;

  @ApiPropertyOptional()
  @ValidateIf((dto: ExamGenerationRuleDto) =>
    !dto.scope || dto.scope === ExamGenerationScope.CHAPTER,
  )
  @Type(() => Number)
  @IsInt()
  chapterId?: number;

  @ApiPropertyOptional({ type: [Number] })
  @ValidateIf((dto: ExamGenerationRuleDto) =>
    dto.scope === ExamGenerationScope.CHAPTERS,
  )
  @IsArray()
  @ArrayNotEmpty()
  @ArrayUnique()
  @Type(() => Number)
  @IsInt({ each: true })
  chapterIds?: number[];

  @ApiPropertyOptional({ type: [Number] })
  @ValidateIf((dto: ExamGenerationRuleDto) =>
    dto.scope === ExamGenerationScope.GROUP,
  )
  @IsArray()
  @ArrayNotEmpty()
  @ArrayUnique()
  @Type(() => Number)
  @IsInt({ each: true })
  groupIds?: number[];

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

export class ExamGenerationSectionDto {
  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  title: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  instructions?: string;

  @ApiProperty()
  @Type(() => Number)
  @IsNumber()
  @Min(0)
  totalMarks: number;

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

  @ApiProperty({ type: [ExamGenerationRuleDto] })
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => ExamGenerationRuleDto)
  rules: ExamGenerationRuleDto[];
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
  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => ExamGenerationRuleDto)
  rules?: ExamGenerationRuleDto[];

  @ApiPropertyOptional()
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(0)
  totalMarks?: number;

  @ApiPropertyOptional({ enum: ExamMarkDistributionMode })
  @IsOptional()
  @IsEnum(ExamMarkDistributionMode)
  markDistributionMode?: ExamMarkDistributionMode;

  @ApiPropertyOptional({ enum: ExamRoundingPolicy })
  @IsOptional()
  @IsEnum(ExamRoundingPolicy)
  roundingPolicy?: ExamRoundingPolicy;

  @ApiPropertyOptional({ type: [ExamGenerationSectionDto] })
  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => ExamGenerationSectionDto)
  sections?: ExamGenerationSectionDto[];

  @ApiPropertyOptional({
    enum: ExamGroupSelectionMode,
    description:
      'Only independent selection is currently implemented. Other modes are reserved for the future group-aware generator phase.',
  })
  @IsOptional()
  @IsEnum(ExamGroupSelectionMode)
  groupSelectionMode?: ExamGroupSelectionMode;

  @ApiPropertyOptional({ description: 'Optional deterministic seed' })
  @IsOptional()
  @IsString()
  seed?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  durationMinutes?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  instructions?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  headerText?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  footerText?: string;
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
  @Min(0)
  weightUnits?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @Type(() => Number)
  @Min(0)
  marks?: number;

  @ApiPropertyOptional()
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  draftSectionId?: number | null;

  @ApiPropertyOptional()
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(0)
  itemOrder?: number;

  @ApiPropertyOptional({
    description:
      'Required when intentionally replacing with a question outside the original generation rule constraints.',
  })
  @IsOptional()
  @IsString()
  @MaxLength(1000)
  overrideReason?: string;
}

