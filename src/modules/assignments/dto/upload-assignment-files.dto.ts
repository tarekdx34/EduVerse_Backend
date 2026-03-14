import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsOptional, IsString, MaxLength, IsInt, Min } from 'class-validator';
import { Transform } from 'class-transformer';

export class UploadAssignmentInstructionDto {
  @ApiPropertyOptional({
    description: 'Instruction title/description',
    example: 'Assignment 1 Instructions - Database Design',
    maxLength: 255,
  })
  @IsString()
  @MaxLength(255)
  @IsOptional()
  title?: string;

  @ApiPropertyOptional({
    description: 'Order index for sorting instructions',
    example: 0,
    default: 0,
  })
  @Transform(({ value }) => value !== undefined && value !== '' ? parseInt(value, 10) : 0)
  @IsInt()
  @Min(0)
  @IsOptional()
  orderIndex?: number;
}

export class UploadAssignmentSubmissionDto {
  @ApiPropertyOptional({
    description: 'Submission notes or comments',
    example: 'My implementation includes all required features',
  })
  @IsString()
  @IsOptional()
  submissionText?: string;

  @ApiPropertyOptional({
    description: 'Link to external submission (optional)',
    example: 'https://github.com/student/project',
  })
  @IsString()
  @IsOptional()
  submissionLink?: string;
}
