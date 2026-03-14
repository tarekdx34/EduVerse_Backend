import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsOptional, IsString, MaxLength, IsInt, Min, IsBoolean } from 'class-validator';
import { Transform } from 'class-transformer';

export class UploadLabInstructionDto {
  @ApiPropertyOptional({
    description: 'Instruction title/description',
    example: 'Lab 1 Instructions - Binary Search Implementation',
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

export class UploadLabTaMaterialDto {
  @ApiPropertyOptional({
    description: 'Material title/description',
    example: 'Lab 1 Solution Key',
    maxLength: 255,
  })
  @IsString()
  @MaxLength(255)
  @IsOptional()
  title?: string;

  @ApiPropertyOptional({
    description: 'Material type (solution, rubric, notes)',
    example: 'solution',
  })
  @IsString()
  @IsOptional()
  materialType?: string;
}

export class UploadLabSubmissionDto {
  @ApiPropertyOptional({
    description: 'Submission notes or comments',
    example: 'My implementation uses iterative approach',
  })
  @IsString()
  @IsOptional()
  submissionText?: string;
}
