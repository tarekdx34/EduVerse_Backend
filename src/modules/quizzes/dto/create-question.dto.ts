import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsString,
  IsNumber,
  IsEnum,
  IsOptional,
  IsArray,
  Min,
} from 'class-validator';
import { QuestionType } from '../enums';

export class CreateQuestionDto {
  @ApiProperty({ description: 'Question text', example: 'What is the time complexity of binary search?' })
  @IsString()
  questionText: string;

  @ApiProperty({ 
    description: 'Question type', 
    enum: ['mcq', 'true_false', 'short_answer', 'essay', 'matching'], 
    example: 'mcq' 
  })
  @IsEnum(QuestionType)
  questionType: QuestionType;

  @ApiPropertyOptional({ 
    description: 'Answer options (for MCQ/Matching)', 
    example: ['O(1)', 'O(n)', 'O(log n)', 'O(n²)'],
    type: [String]
  })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  options?: string[];

  @ApiPropertyOptional({ 
    description: 'Correct answer (index for MCQ, text for short answer)', 
    example: '2' 
  })
  @IsOptional()
  @IsString()
  correctAnswer?: string;

  @ApiPropertyOptional({ description: 'Explanation shown after answering', example: 'Binary search divides the search space in half each iteration.' })
  @IsOptional()
  @IsString()
  explanation?: string;

  @ApiPropertyOptional({ description: 'Points for this question', default: 1, example: 5 })
  @IsOptional()
  @IsNumber()
  @Min(0)
  points?: number;

  @ApiPropertyOptional({ description: 'Difficulty level ID', example: 2 })
  @IsOptional()
  @IsNumber()
  difficultyLevelId?: number;

  @ApiPropertyOptional({ description: 'Display order (0-based)', example: 0 })
  @IsOptional()
  @IsNumber()
  @Min(0)
  orderIndex?: number;
}
