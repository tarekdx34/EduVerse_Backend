import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsNotEmpty, IsNumber, IsOptional } from 'class-validator';

export class ImportAttendanceDto {
  @ApiProperty({
    description: 'Session ID to import attendance for',
    example: 1,
  })
  @IsNotEmpty()
  @IsNumber()
  sessionId: number;
}

export class ImportResultDto {
  @ApiProperty({ description: 'Total records processed', example: 25 })
  totalProcessed: number;

  @ApiProperty({ description: 'Successfully imported records', example: 23 })
  successCount: number;

  @ApiProperty({ description: 'Failed records', example: 2 })
  failedCount: number;

  @ApiProperty({
    description: 'List of errors',
    example: [
      { row: 5, error: 'Student ID 999 not enrolled in course' },
      { row: 12, error: 'Invalid status value' },
    ],
  })
  errors: { row: number; error: string }[];
}

export class ExportAttendanceQueryDto {
  @ApiPropertyOptional({
    description: 'Session ID to export',
    example: 1,
  })
  @IsOptional()
  @IsNumber()
  sessionId?: number;

  @ApiPropertyOptional({
    description: 'Section ID to export all sessions',
    example: 1,
  })
  @IsOptional()
  @IsNumber()
  sectionId?: number;
}

export class AiPhotoUploadDto {
  @ApiProperty({
    description: 'Session ID for the attendance',
    example: 1,
  })
  @IsNotEmpty()
  @IsNumber()
  sessionId: number;
}

export class AiProcessingResultDto {
  @ApiProperty({ description: 'Processing ID', example: 1 })
  processingId: number;

  @ApiProperty({
    description: 'Processing status',
    example: 'completed',
    enum: ['pending', 'processing', 'completed', 'failed', 'manual_review'],
  })
  status: string;

  @ApiProperty({ description: 'Number of detected faces', example: 25 })
  detectedFacesCount: number;

  @ApiProperty({ description: 'Number of matched students', example: 23 })
  matchedStudentsCount: number;

  @ApiProperty({ description: 'Number of unmatched faces', example: 2 })
  unmatchedFacesCount: number;

  @ApiPropertyOptional({ description: 'Error message if failed' })
  errorMessage?: string;

  @ApiPropertyOptional({ description: 'Processing time in milliseconds' })
  processingTimeMs?: number;
}
