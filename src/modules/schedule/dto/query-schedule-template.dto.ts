import { ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsOptional,
  IsEnum,
  IsNumber,
  IsBoolean,
  IsString,
  Min,
} from 'class-validator';
import { Type } from 'class-transformer';
import { TemplateScheduleType } from '../entities/schedule-template.entity';

export class QueryScheduleTemplateDto {
  @ApiPropertyOptional({
    description: 'Filter by schedule type',
    enum: ['LECTURE', 'LAB', 'TUTORIAL', 'HYBRID'],
    example: 'LECTURE',
  })
  @IsEnum(TemplateScheduleType)
  @IsOptional()
  scheduleType?: TemplateScheduleType;

  @ApiPropertyOptional({
    description: 'Filter by department ID',
    example: 1,
  })
  @IsNumber()
  @Type(() => Number)
  @IsOptional()
  departmentId?: number;

  @ApiPropertyOptional({
    description: 'Filter by active status',
    example: true,
  })
  @IsBoolean()
  @Type(() => Boolean)
  @IsOptional()
  isActive?: boolean;

  @ApiPropertyOptional({
    description: 'Search in name or description',
    example: 'lecture',
  })
  @IsString()
  @IsOptional()
  search?: string;

  @ApiPropertyOptional({
    description: 'Page number for pagination',
    example: 1,
    default: 1,
  })
  @IsNumber()
  @Type(() => Number)
  @Min(1)
  @IsOptional()
  page?: number;

  @ApiPropertyOptional({
    description: 'Items per page',
    example: 10,
    default: 10,
  })
  @IsNumber()
  @Type(() => Number)
  @Min(1)
  @IsOptional()
  limit?: number;
}
