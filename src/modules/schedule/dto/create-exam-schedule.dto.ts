import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsNotEmpty,
  IsString,
  IsNumber,
  IsEnum,
  IsOptional,
  IsDateString,
  Matches,
  MaxLength,
  Min,
} from 'class-validator';
import { ExamType } from '../enums';

export class CreateExamScheduleDto {
  @ApiProperty({
    description: 'Course ID for the exam',
    example: 1,
  })
  @IsNumber()
  @IsNotEmpty()
  courseId: number;

  @ApiProperty({
    description: 'Semester ID for the exam',
    example: 1,
  })
  @IsNumber()
  @IsNotEmpty()
  semesterId: number;

  @ApiProperty({
    description: 'Type of exam',
    enum: ExamType,
    example: ExamType.MIDTERM,
  })
  @IsEnum(ExamType)
  @IsNotEmpty()
  examType: ExamType;

  @ApiProperty({
    description: 'Exam date in YYYY-MM-DD format',
    example: '2026-04-15',
  })
  @IsDateString()
  @IsNotEmpty()
  examDate: string;

  @ApiProperty({
    description: 'Start time in HH:MM:SS format',
    example: '09:00:00',
  })
  @Matches(/^([01]\d|2[0-3]):([0-5]\d):([0-5]\d)$/, {
    message: 'startTime must be in HH:MM:SS format',
  })
  @IsNotEmpty()
  startTime: string;

  @ApiProperty({
    description: 'Duration of exam in minutes',
    example: 120,
    minimum: 1,
  })
  @IsNumber()
  @Min(1)
  @IsNotEmpty()
  durationMinutes: number;

  @ApiPropertyOptional({
    description: 'Location of the exam',
    example: 'Hall A, Building 1',
    maxLength: 255,
  })
  @IsString()
  @MaxLength(255)
  @IsOptional()
  location?: string;

  @ApiPropertyOptional({
    description: 'Instructions for the exam',
    example: 'Bring your student ID and calculator',
  })
  @IsString()
  @IsOptional()
  instructions?: string;
}
