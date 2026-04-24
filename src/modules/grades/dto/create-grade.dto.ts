import {
  IsNumber,
  IsString,
  IsOptional,
  IsEnum,
  IsBoolean,
  Min,
} from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { GradeType } from '../enums';

export class CreateGradeDto {
  @ApiProperty({ description: 'Student user ID', example: 57 })
  @IsNumber()
  userId: number;

  @ApiProperty({ description: 'Course ID', example: 1 })
  @IsNumber()
  courseId: number;

  @ApiProperty({ description: 'Type of grade', enum: ['assignment', 'quiz', 'lab', 'exam', 'final', 'participation', 'project', 'other'], example: 'assignment' })
  @IsEnum(GradeType)
  gradeType: GradeType;

  @ApiPropertyOptional({ description: 'Assignment ID (if grade type is assignment)', example: 3 })
  @IsNumber()
  @IsOptional()
  assignmentId?: number;

  @ApiPropertyOptional({ description: 'Quiz ID (if grade type is quiz)', example: 1 })
  @IsNumber()
  @IsOptional()
  quizId?: number;

  @ApiPropertyOptional({ description: 'Lab ID (if grade type is lab)', example: 1 })
  @IsNumber()
  @IsOptional()
  labId?: number;

  @ApiProperty({ description: 'Score achieved', example: 85, minimum: 0 })
  @IsNumber()
  @Min(0)
  score: number;

  @ApiProperty({ description: 'Maximum possible score', example: 100, minimum: 0 })
  @IsNumber()
  @Min(0)
  maxScore: number;

  @ApiPropertyOptional({ description: 'Feedback comments', example: 'Great work on the analysis section.' })
  @IsString()
  @IsOptional()
  feedback?: string;

  @ApiPropertyOptional({ description: 'Whether grade is visible to student', example: false, default: false })
  @IsBoolean()
  @IsOptional()
  isPublished?: boolean;
}
