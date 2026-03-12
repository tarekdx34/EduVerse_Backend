import { IsOptional, IsEnum, IsNumber, IsString, Min } from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { PostType } from '../enums';

export class PostQueryDto {
  @ApiPropertyOptional({
    description: 'Filter by community ID',
    example: 1,
  })
  @IsOptional()
  @IsNumber()
  @Type(() => Number)
  communityId?: number;

  @ApiPropertyOptional({
    description: 'Filter by post type',
    enum: PostType,
  })
  @IsOptional()
  @IsEnum(PostType)
  postType?: PostType;

  @ApiPropertyOptional({
    description: 'Filter by tag name',
    example: 'study-group',
  })
  @IsOptional()
  @IsString()
  tag?: string;

  @ApiPropertyOptional({
    description: 'Sort by field',
    enum: ['recent', 'popular', 'most_comments'],
    default: 'recent',
  })
  @IsOptional()
  sortBy?: 'recent' | 'popular' | 'most_comments';

  @ApiPropertyOptional({
    description: 'Page number for pagination',
    default: 1,
    minimum: 1,
  })
  @IsOptional()
  @IsNumber()
  @Min(1)
  @Type(() => Number)
  page?: number = 1;

  @ApiPropertyOptional({
    description: 'Items per page',
    default: 20,
    minimum: 1,
  })
  @IsOptional()
  @IsNumber()
  @Min(1)
  @Type(() => Number)
  limit?: number = 20;
}
