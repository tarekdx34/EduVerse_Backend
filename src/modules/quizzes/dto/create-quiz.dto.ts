import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsString,
  IsNumber,
  IsEnum,
  IsOptional,
  IsBoolean,
  IsDateString,
  Min,
  Max,
  MaxLength,
} from 'class-validator';
import { QuizType, ShowAnswersAfter } from '../enums';

export class CreateQuizDto {
  @ApiProperty({ description: 'Course ID this quiz belongs to', example: 1 })
  @IsNumber()
  courseId: number;

  @ApiProperty({ description: 'Quiz title', example: 'Midterm Quiz: Arrays and Data Structures' })
  @IsString()
  @MaxLength(255)
  title: string;

  @ApiPropertyOptional({ description: 'Quiz description', example: 'This quiz covers chapters 1-5' })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiPropertyOptional({ description: 'Instructions for students', example: 'Answer all questions. No partial credit.' })
  @IsOptional()
  @IsString()
  instructions?: string;

  @ApiPropertyOptional({ 
    description: 'Quiz type', 
    enum: QuizType, 
    default: QuizType.GRADED,
    example: QuizType.GRADED 
  })
  @IsOptional()
  @IsEnum(QuizType)
  quizType?: QuizType;

  @ApiPropertyOptional({ description: 'Time limit in minutes (null = unlimited)', example: 60 })
  @IsOptional()
  @IsNumber()
  @Min(1)
  timeLimitMinutes?: number;

  @ApiPropertyOptional({ description: 'Maximum allowed attempts', default: 1, example: 2 })
  @IsOptional()
  @IsNumber()
  @Min(1)
  @Max(10)
  maxAttempts?: number;

  @ApiPropertyOptional({ description: 'Minimum passing score percentage', example: 70 })
  @IsOptional()
  @IsNumber()
  @Min(0)
  @Max(100)
  passingScore?: number;

  @ApiPropertyOptional({ description: 'Randomize question order', default: false })
  @IsOptional()
  @IsBoolean()
  randomizeQuestions?: boolean;

  @ApiPropertyOptional({ description: 'Show correct answers to students', default: true })
  @IsOptional()
  @IsBoolean()
  showCorrectAnswers?: boolean;

  @ApiPropertyOptional({ 
    description: 'When to show answers', 
    enum: ShowAnswersAfter, 
    default: ShowAnswersAfter.AFTER_DUE 
  })
  @IsOptional()
  @IsEnum(ShowAnswersAfter)
  showAnswersAfter?: ShowAnswersAfter;

  @ApiPropertyOptional({ description: 'When the quiz becomes available (ISO 8601)', example: '2026-03-15T09:00:00Z' })
  @IsOptional()
  @IsDateString()
  availableFrom?: string;

  @ApiPropertyOptional({ description: 'When the quiz closes (ISO 8601)', example: '2026-03-22T23:59:59Z' })
  @IsOptional()
  @IsDateString()
  availableUntil?: string;

  @ApiPropertyOptional({ description: 'Grade weight in the course (percentage)', example: 15 })
  @IsOptional()
  @IsNumber()
  @Min(0)
  @Max(100)
  weight?: number;
}
