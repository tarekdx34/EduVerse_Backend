import { IsString, IsOptional, IsEnum, IsNumber, Min, MinLength } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { ApiPropertyStringEnumOptional } from '../../../common/swagger/string-enum.schema';
import { SearchEntityType, SearchVisibility } from '../entities/search-index.entity';

export enum SearchSortBy {
  RELEVANCE = 'relevance',
  RECENT = 'recent',
}

export class GlobalSearchDto {
  @ApiProperty({ description: 'Search query string', example: 'mathematics' })
  @IsString()
  @MinLength(1)
  query: string;

  @ApiPropertyStringEnumOptional({
    description: 'Filter by entity type',
    enumObject: SearchEntityType,
  })
  @IsOptional()
  @IsEnum(SearchEntityType)
  entityType?: SearchEntityType;

  @ApiPropertyOptional({ description: 'Filter by course ID', example: 1 })
  @IsOptional()
  @IsNumber()
  @Type(() => Number)
  courseId?: number;

  @ApiPropertyOptional({ description: 'Filter by campus ID', example: 1 })
  @IsOptional()
  @IsNumber()
  @Type(() => Number)
  campusId?: number;

  @ApiPropertyStringEnumOptional({
    description: 'Filter by visibility',
    enumObject: SearchVisibility,
  })
  @IsOptional()
  @IsEnum(SearchVisibility)
  visibility?: SearchVisibility;

  @ApiPropertyOptional({ description: 'Page number', default: 1, example: 1 })
  @IsOptional()
  @IsNumber()
  @Min(1)
  @Type(() => Number)
  page?: number = 1;

  @ApiPropertyOptional({ description: 'Results per page', default: 20, example: 20 })
  @IsOptional()
  @IsNumber()
  @Min(1)
  @Type(() => Number)
  limit?: number = 20;

  @ApiPropertyStringEnumOptional({
    description: 'Sort by',
    enumObject: SearchSortBy,
    default: SearchSortBy.RELEVANCE,
  })
  @IsOptional()
  @IsEnum(SearchSortBy)
  sortBy?: SearchSortBy = SearchSortBy.RELEVANCE;
}
