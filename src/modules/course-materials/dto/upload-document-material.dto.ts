import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsNotEmpty,
  IsString,
  IsOptional,
  MaxLength,
  IsInt,
  IsBoolean,
  IsEnum,
  Min,
  Max,
} from 'class-validator';
import { Transform } from 'class-transformer';
import { MaterialType } from '../enums';

export class UploadDocumentMaterialDto {
  @ApiProperty({
    description: 'Document title',
    example: 'Week 1 Lecture Notes: Introduction',
    maxLength: 255,
  })
  @IsString()
  @MaxLength(255)
  @IsNotEmpty()
  title: string;

  @ApiPropertyOptional({
    description: 'Document description',
    example: 'Lecture notes covering introduction to the course and syllabus overview.',
  })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiPropertyOptional({
    description: 'Material type',
    enum: MaterialType,
    example: MaterialType.DOCUMENT,
    default: MaterialType.DOCUMENT,
  })
  @IsOptional()
  @Transform(({ value }) => value || MaterialType.DOCUMENT)
  @IsEnum(MaterialType)
  materialType?: MaterialType;

  @ApiPropertyOptional({
    description: 'Week number to assign the document to',
    example: 1,
    minimum: 1,
    maximum: 52,
  })
  @IsOptional()
  @Transform(({ value }) => value !== undefined && value !== '' ? parseInt(value, 10) : undefined)
  @IsInt()
  @Min(1)
  @Max(52)
  weekNumber?: number;

  @ApiPropertyOptional({
    description: 'Order index for sorting within the week',
    example: 0,
    default: 0,
  })
  @IsOptional()
  @Transform(({ value }) => value !== undefined && value !== '' ? parseInt(value, 10) : undefined)
  @IsInt()
  @Min(0)
  orderIndex?: number;

  @ApiPropertyOptional({
    description: 'Whether to publish immediately (default: false - save as draft)',
    example: false,
    default: false,
  })
  @IsOptional()
  @Transform(({ value }) => value === 'true' || value === true)
  @IsBoolean()
  isPublished?: boolean;
}
