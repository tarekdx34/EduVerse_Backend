import {
  IsNumber,
  IsString,
  IsOptional,
  IsEnum,
  IsDateString,
  IsBoolean,
  Min,
  Max,
  Length,
} from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { SubmissionType, AssignmentStatus } from '../enums';

export class CreateAssignmentDto {
  @ApiProperty({ description: 'Course ID', example: 1 })
  @IsNumber()
  courseId: number;

  @ApiProperty({
    description: 'Assignment title',
    example: 'Homework 1',
    minLength: 3,
    maxLength: 200,
  })
  @IsString()
  @Length(3, 200)
  title: string;

  @ApiPropertyOptional({ description: 'Assignment description', example: 'Implement a binary search tree with insert, delete, and search operations.' })
  @IsString()
  @IsOptional()
  description?: string;

  @ApiPropertyOptional({ description: 'Assignment instructions', example: 'Submit your code as a single .zip file. Include a README with compilation instructions.' })
  @IsString()
  @IsOptional()
  instructions?: string;

  @ApiPropertyOptional({ description: 'Submission type', enum: SubmissionType, default: SubmissionType.FILE, example: 'file' })
  @IsEnum(SubmissionType)
  @IsOptional()
  submissionType?: SubmissionType;

  @ApiPropertyOptional({
    description: 'Maximum score',
    default: 100,
    minimum: 0,
    maximum: 1000,
    example: 100,
  })
  @IsNumber()
  @Min(0)
  @Max(1000)
  @IsOptional()
  maxScore?: number;

  @ApiPropertyOptional({
    description: 'Weight percentage',
    minimum: 0,
    maximum: 100,
    example: 15,
  })
  @IsNumber()
  @Min(0)
  @Max(100)
  @IsOptional()
  weight?: number;

  @ApiPropertyOptional({ description: 'Due date (ISO 8601)', example: '2025-06-15T23:59:59Z' })
  @IsDateString()
  @IsOptional()
  dueDate?: string;

  @ApiPropertyOptional({ description: 'Available from date (ISO 8601)', example: '2025-06-01T00:00:00Z' })
  @IsDateString()
  @IsOptional()
  availableFrom?: string;

  @ApiPropertyOptional({
    description: 'Allow late submissions',
    default: false,
  })
  @IsBoolean()
  @IsOptional()
  lateSubmissionAllowed?: boolean;

  @ApiPropertyOptional({
    description: 'Late penalty percentage',
    default: 0,
  })
  @IsNumber()
  @Min(0)
  @Max(100)
  @IsOptional()
  latePenaltyPercent?: number;

  @ApiPropertyOptional({ description: 'Max file size in MB', default: 10, example: 10 })
  @IsNumber()
  @IsOptional()
  maxFileSizeMb?: number;

  @ApiPropertyOptional({
    description: 'Allowed file types',
    example: '["pdf","docx","zip"]',
  })
  @IsOptional()
  allowedFileTypes?: string;

  @ApiPropertyOptional({
    description: 'Assignment status',
    enum: AssignmentStatus,
    default: AssignmentStatus.DRAFT,
    example: 'draft',
  })
  @IsEnum(AssignmentStatus)
  @IsOptional()
  status?: AssignmentStatus;
}
