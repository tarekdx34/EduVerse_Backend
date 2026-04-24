import { IsString, IsOptional, IsEnum, IsNumber, Min, MinLength } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
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

  @ApiPropertyOptional({ description: 'Filter by entity type', enum: ['course', 'material', 'user', 'announcement', 'assignment', 'quiz', 'file', 'post'] })
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

  @ApiPropertyOptional({ description: 'Filter by visibility', enum: ['public', 'students', 'instructors', 'private'] })
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

  @ApiPropertyOptional({ description: 'Sort by', enum: ['relevance', 'recent'], default: 'relevance' })
  @IsOptional()
  @IsEnum(SearchSortBy)
  sortBy?: SearchSortBy = SearchSortBy.RELEVANCE;
}
