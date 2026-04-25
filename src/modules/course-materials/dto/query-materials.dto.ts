import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsOptional, IsNumber, IsEnum, IsBoolean, IsString } from 'class-validator';
import { Type, Transform } from 'class-transformer';
import { MaterialType } from '../enums';

export class QueryMaterialsDto {
  @ApiPropertyOptional({
    description: 'Filter by material type',
    enum: ['lecture', 'slide', 'video', 'reading', 'link', 'document', 'other'],
    example: 'lecture',
  })
  @IsEnum(MaterialType)
  @IsOptional()
  materialType?: MaterialType;

  @ApiPropertyOptional({
    description: 'Filter by week number',
    example: 1,
  })
  @IsNumber()
  @Type(() => Number)
  @IsOptional()
  weekNumber?: number;

  @ApiPropertyOptional({
    description: 'Filter by visibility (only for instructors/admins)',
    example: true,
  })
  @Transform(({ value }) => value === 'true' || value === true)
  @IsBoolean()
  @IsOptional()
  isPublished?: boolean;

  @ApiPropertyOptional({
    description: 'Search in title and description',
    example: 'introduction',
  })
  @IsString()
  @IsOptional()
  search?: string;

  @ApiPropertyOptional({
    description: 'Sort by field',
    enum: ['createdAt', 'title', 'orderIndex'],
    example: 'orderIndex',
  })
  @IsString()
  @IsOptional()
  sortBy?: 'createdAt' | 'title' | 'orderIndex';

  @ApiPropertyOptional({
    description: 'Sort order',
    enum: ['ASC', 'DESC'],
    example: 'ASC',
  })
  @IsString()
  @IsOptional()
  sortOrder?: 'ASC' | 'DESC';

  @ApiPropertyOptional({
    description: 'Page number for pagination',
    example: 1,
    minimum: 1,
  })
  @IsNumber()
  @Type(() => Number)
  @IsOptional()
  page?: number = 1;

  @ApiPropertyOptional({
    description: 'Number of items per page',
    example: 10,
    minimum: 1,
    maximum: 100,
  })
  @IsNumber()
  @Type(() => Number)
  @IsOptional()
  limit?: number = 10;
}
