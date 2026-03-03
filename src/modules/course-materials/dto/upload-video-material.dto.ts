import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsNotEmpty,
  IsString,
  IsOptional,
  MaxLength,
} from 'class-validator';

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
}
