import { IsOptional, IsEnum, IsNumber, IsBoolean, Min } from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { ApiPropertyStringEnumOptional } from '../../../common/swagger/string-enum.schema';
import { AnnouncementType, AnnouncementPriority } from '../enums';

export class AnnouncementQueryDto {
  @ApiPropertyOptional({
    description: 'Filter by course ID',
    example: 1,
  })
  @IsOptional()
  @IsNumber()
  @Type(() => Number)
  courseId?: number;

  @ApiPropertyStringEnumOptional({
    description: 'Filter by announcement type',
    enumObject: AnnouncementType,
  })
  @IsOptional()
  @IsEnum(AnnouncementType)
  announcementType?: AnnouncementType;

  @ApiPropertyStringEnumOptional({
    description: 'Filter by priority',
    enumObject: AnnouncementPriority,
  })
  @IsOptional()
  @IsEnum(AnnouncementPriority)
  priority?: AnnouncementPriority;

  @ApiPropertyOptional({
    description: 'Filter by published status',
    example: true,
  })
  @IsOptional()
  @IsBoolean()
  @Type(() => Boolean)
  isPublished?: boolean;

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
