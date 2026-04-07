import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsNotEmpty,
  IsNumber,
  IsArray,
  IsString,
  IsOptional,
  MaxLength,
  ValidateNested,
} from 'class-validator';
import { Type } from 'class-transformer';

export class ApplyTemplateToSectionDto {
  @ApiProperty({
    description: 'Template ID to apply',
    example: 1,
  })
  @IsNumber()
  @IsNotEmpty()
  templateId: number;

  @ApiProperty({
    description: 'Course section ID to apply template to',
    example: 1,
  })
  @IsNumber()
  @IsNotEmpty()
  sectionId: number;

  @ApiPropertyOptional({
    description: 'Building override (if different from template)',
    example: 'Science Building',
  })
  @IsString()
  @MaxLength(100)
  @IsOptional()
  building?: string;

  @ApiPropertyOptional({
    description: 'Room override (if different from template)',
    example: 'Room 205',
  })
  @IsString()
  @MaxLength(100)
  @IsOptional()
  room?: string;
}

export class BulkApplyTemplateDto {
  @ApiProperty({
    description: 'Template ID to apply',
    example: 1,
  })
  @IsNumber()
  @IsNotEmpty()
  templateId: number;

  @ApiProperty({
    description: 'Array of section IDs to apply template to',
    example: [1, 2, 3],
    type: [Number],
  })
  @IsArray()
  @IsNumber({}, { each: true })
  @IsNotEmpty()
  sectionIds: number[];

  @ApiPropertyOptional({
    description: 'Building override for all sections',
    example: 'Science Building',
  })
  @IsString()
  @MaxLength(100)
  @IsOptional()
  building?: string;

  @ApiPropertyOptional({
    description: 'Room override for all sections',
    example: 'Room 205',
  })
  @IsString()
  @MaxLength(100)
  @IsOptional()
  room?: string;
}
