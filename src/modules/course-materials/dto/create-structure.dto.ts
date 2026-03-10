import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsNotEmpty,
  IsString,
  IsNumber,
  IsEnum,
  IsOptional,
  MaxLength,
  Min,
} from 'class-validator';
import { OrganizationType } from '../enums';

export class CreateStructureDto {
  @ApiProperty({
    description: 'Structure item title',
    example: 'Week 1: Introduction',
    maxLength: 255,
  })
  @IsString()
  @MaxLength(255)
  @IsNotEmpty()
  title: string;

  @ApiPropertyOptional({
    description: 'Description of this content section',
    example: 'Introduction to the course and basic concepts',
  })
  @IsString()
  @IsOptional()
  description?: string;

  @ApiProperty({
    description: 'Type of content organization',
    enum: OrganizationType,
    example: OrganizationType.LECTURE,
  })
  @IsEnum(OrganizationType)
  @IsNotEmpty()
  organizationType: OrganizationType;

  @ApiPropertyOptional({
    description: 'Week number for this content',
    example: 1,
    minimum: 1,
  })
  @IsNumber()
  @Min(1)
  @IsOptional()
  weekNumber?: number;

  @ApiPropertyOptional({
    description: 'Order index for sorting',
    example: 1,
    minimum: 0,
  })
  @IsNumber()
  @IsOptional()
  orderIndex?: number;

  @ApiPropertyOptional({
    description: 'Associated material ID',
    example: 1,
  })
  @IsNumber()
  @IsOptional()
  materialId?: number;
}
