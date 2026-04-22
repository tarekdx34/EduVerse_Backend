import { IsString, IsOptional, IsInt, IsEnum, IsNumber, IsDateString, Min, Max } from 'class-validator';
import { ApiProperty, ApiPropertyOptional, PartialType } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { LabStatus } from '../enums';

// Re-export upload DTOs
export { UploadLabInstructionDto, UploadLabTaMaterialDto, UploadLabSubmissionDto } from './upload-lab-files.dto';

export class CreateLabDto {
  @ApiProperty({ example: 1, description: 'Course ID' })
  @IsInt()
  courseId: number;

  @ApiProperty({ example: 'Binary Search Lab', description: 'Lab title' })
  @IsString()
  title: string;

  @ApiPropertyOptional({ example: 'Implement binary search in Python', description: 'Lab description' })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiPropertyOptional({ example: 1, description: 'Lab number in sequence' })
  @IsOptional()
  @IsInt()
  labNumber?: number;

  @ApiPropertyOptional({ example: '2026-04-15T23:59:59Z', description: 'Due date' })
  @IsOptional()
  @IsDateString()
  dueDate?: string;

  @ApiPropertyOptional({ example: '2026-04-01T00:00:00Z', description: 'Available from date' })
  @IsOptional()
  @IsDateString()
  availableFrom?: string;

  @ApiPropertyOptional({ example: 100, description: 'Maximum score' })
  @IsOptional()
  @IsNumber()
  maxScore?: number;

  @ApiPropertyOptional({ example: 10, description: 'Weight in final grade' })
  @IsOptional()
  @IsNumber()
  weight?: number;

  @ApiPropertyOptional({ example: 'draft', enum: LabStatus, description: 'Lab status' })
  @IsOptional()
  @IsEnum(LabStatus)
  status?: LabStatus;

  @ApiPropertyOptional({ example: 'pdf,docx,zip', description: 'Comma-separated list of allowed file extensions for student submissions' })
  @IsOptional()
  @IsString()
  allowedFileTypes?: string;

  @ApiPropertyOptional({ example: 10, description: 'Maximum file size in MB for student submissions' })
  @IsOptional()
  @IsNumber()
  maxFileSizeMb?: number;
}

export class UpdateLabDto extends PartialType(CreateLabDto) {}

export class SubmitLabDto {
  @ApiPropertyOptional({ example: 'My solution code...', description: 'Text submission' })
  @IsOptional()
  @IsString()
  submissionText?: string;

  @ApiPropertyOptional({ example: 1, description: 'File ID for uploaded submission' })
  @IsOptional()
  @IsInt()
  fileId?: number;
}

export class GradeLabSubmissionDto {
  @ApiProperty({ example: 'graded', enum: ['submitted', 'graded', 'returned', 'resubmit'], description: 'Submission status' })
  @IsEnum(['submitted', 'graded', 'returned', 'resubmit'])
  status: string;

  @ApiPropertyOptional({ example: 85, description: 'Score for the submission' })
  @IsOptional()
  @IsNumber()
  @Min(0)
  score?: number;

  @ApiPropertyOptional({ example: 'Good work! Consider optimizing your code for better performance.', description: 'Feedback for the student' })
  @IsOptional()
  @IsString()
  feedback?: string;
}

export class CreateInstructionDto {
  @ApiPropertyOptional({ example: 'Step 1: Create a new Python file', description: 'Instruction text (markdown)' })
  @IsOptional()
  @IsString()
  instructionText?: string;

  @ApiPropertyOptional({ example: 1, description: 'File ID for instruction attachment' })
  @IsOptional()
  @IsInt()
  fileId?: number;

  @ApiPropertyOptional({ example: 1, description: 'Order index for sorting' })
  @IsOptional()
  @IsInt()
  orderIndex?: number;
}

export class UpdateInstructionDto {
  @ApiPropertyOptional({ example: '# Updated markdown text', description: 'Updated instruction text (markdown)' })
  @IsOptional()
  @IsString()
  instructionText?: string;

  @ApiPropertyOptional({ example: 2, description: 'Updated order index for reordering' })
  @IsOptional()
  @IsInt()
  orderIndex?: number;

  @ApiPropertyOptional({ example: 1, description: 'Updated file ID for instruction attachment' })
  @IsOptional()
  @IsInt()
  fileId?: number;
}

export class MarkLabAttendanceDto {
  @ApiProperty({ example: 57, description: 'User (student) ID' })
  @IsInt()
  userId: number;

  @ApiProperty({ example: 'present', enum: ['present', 'absent', 'excused', 'late'], description: 'Attendance status' })
  @IsEnum(['present', 'absent', 'excused', 'late'])
  attendanceStatus: string;

  @ApiPropertyOptional({ example: 'Arrived on time', description: 'Notes' })
  @IsOptional()
  @IsString()
  notes?: string;
}

export class LabQueryDto {
  @ApiPropertyOptional({ example: 1, description: 'Filter by course ID' })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  courseId?: number;

  @ApiPropertyOptional({ example: 'published', enum: LabStatus, description: 'Filter by status' })
  @IsOptional()
  @IsEnum(LabStatus)
  status?: LabStatus;

  @ApiPropertyOptional({ example: 1, description: 'Page number' })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page?: number = 1;

  @ApiPropertyOptional({ example: 20, description: 'Items per page' })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  limit?: number = 20;
}
