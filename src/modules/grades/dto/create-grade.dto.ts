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
  @ApiProperty()
  @IsNumber()
  userId: number;

  @ApiProperty()
  @IsNumber()
  courseId: number;

  @ApiProperty({ enum: GradeType })
  @IsEnum(GradeType)
  gradeType: GradeType;

  @ApiPropertyOptional()
  @IsNumber()
  @IsOptional()
  assignmentId?: number;

  @ApiPropertyOptional()
  @IsNumber()
  @IsOptional()
  quizId?: number;

  @ApiPropertyOptional()
  @IsNumber()
  @IsOptional()
  labId?: number;

  @ApiProperty()
  @IsNumber()
  @Min(0)
  score: number;

  @ApiProperty()
  @IsNumber()
  @Min(0)
  maxScore: number;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  feedback?: string;

  @ApiPropertyOptional()
  @IsBoolean()
  @IsOptional()
  isPublished?: boolean;
}
