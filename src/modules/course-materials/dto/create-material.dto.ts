import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsNotEmpty,
  IsString,
  IsNumber,
  IsEnum,
  IsOptional,
  IsBoolean,
  MaxLength,
  IsUrl,
} from 'class-validator';
import { MaterialType } from '../enums';

export class CreateMaterialDto {
  @ApiProperty({
    description: 'Material title',
    example: 'Lecture 1: Introduction to Programming',
    maxLength: 255,
  })
  @IsString()
  @MaxLength(255)
  @IsNotEmpty()
  title: string;

  @ApiPropertyOptional({
    description: 'Material description',
    example: 'This lecture covers the basics of programming concepts.',
  })
  @IsString()
  @IsOptional()
  description?: string;

  @ApiProperty({
    description: 'Type of material',
    enum: ['lecture', 'slide', 'video', 'reading', 'link', 'document', 'other'],
    example: 'lecture',
  })
  @IsEnum(MaterialType)
  @IsNotEmpty()
  materialType: MaterialType;

  @ApiPropertyOptional({
    description: 'File ID from Files module (for uploaded files)',
    example: 1,
  })
  @IsNumber()
  @IsOptional()
  fileId?: number;

  @ApiPropertyOptional({
    description: 'External URL for links or embedded content',
    example: 'https://www.youtube.com/watch?v=example',
    maxLength: 500,
  })
  @IsString()
  @MaxLength(500)
  @IsOptional()
  externalUrl?: string;

  @ApiPropertyOptional({
    description: 'Order index for sorting materials',
    example: 1,
    minimum: 0,
  })
  @IsNumber()
  @IsOptional()
  orderIndex?: number;

  @ApiPropertyOptional({
    description: 'Week number for organizing materials by course week',
    example: 1,
    minimum: 1,
  })
  @IsNumber()
  @IsOptional()
  weekNumber?: number;

  @ApiPropertyOptional({
    description: 'Whether the material is published and visible to students',
    example: true,
  })
  @IsBoolean()
  @IsOptional()
  isPublished?: boolean;
}
