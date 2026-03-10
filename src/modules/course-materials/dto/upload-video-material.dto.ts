import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsNotEmpty,
  IsString,
  IsOptional,
  MaxLength,
  IsInt,
  IsBoolean,
  Min,
  Max,
} from 'class-validator';
import { Transform } from 'class-transformer';

export class UploadVideoMaterialDto {
  @ApiProperty({
    description: 'Video title',
    example: 'Lecture 1: Introduction to Data Structures',
    maxLength: 255,
  })
  @IsString()
  @MaxLength(255)
  @IsNotEmpty()
  title: string;

  @ApiPropertyOptional({
    description: 'Video description',
    example: 'This video covers the basics of data structures including arrays and linked lists.',
  })
  @IsString()
  @IsOptional()
  description?: string;

  @ApiPropertyOptional({
    description: 'Tags for the video (comma-separated or array)',
    example: ['lecture', 'data-structures', 'cs101'],
  })
  @IsOptional()
  tags?: string[];

  @ApiPropertyOptional({
    description: 'Week number to assign the video to',
    example: 1,
    minimum: 1,
    maximum: 52,
  })
  @Transform(({ value }) => value !== undefined && value !== '' ? parseInt(value, 10) : undefined)
  @IsInt()
  @Min(1)
  @Max(52)
  @IsOptional()
  weekNumber?: number;

  @ApiPropertyOptional({
    description: 'Order index for sorting within the week',
    example: 0,
    default: 0,
  })
  @Transform(({ value }) => value !== undefined && value !== '' ? parseInt(value, 10) : undefined)
  @IsInt()
  @Min(0)
  @IsOptional()
  orderIndex?: number;

  @ApiPropertyOptional({
    description: 'Whether to publish immediately (default: false - save as draft)',
    example: false,
    default: false,
  })
  @Transform(({ value }) => value === 'true' || value === true)
  @IsBoolean()
  @IsOptional()
  isPublished?: boolean;
}
