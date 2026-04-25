import {
  IsOptional,
  IsNumber,
  IsDateString,
  IsEnum,
  Min,
} from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { ApiPropertyStringEnumOptional } from '../../../common/swagger/string-enum.schema';
import { MetricType } from '../entities/learning-analytics.entity';

export class StudentAnalyticsQueryDto {
  @ApiPropertyOptional({ description: 'Course ID to filter by' })
  @IsOptional()
  @IsNumber()
  @Type(() => Number)
  courseId?: number;

  @ApiPropertyStringEnumOptional({
    description: 'Metric type filter',
    enumObject: MetricType,
  })
  @IsOptional()
  @IsEnum(MetricType)
  metricType?: MetricType;

  @ApiPropertyOptional({ description: 'Start date (ISO format)' })
  @IsOptional()
  @IsDateString()
  startDate?: string;

  @ApiPropertyOptional({ description: 'End date (ISO format)' })
  @IsOptional()
  @IsDateString()
  endDate?: string;

  @ApiPropertyOptional({ description: 'Page number', default: 1 })
  @IsOptional()
  @IsNumber()
  @Min(1)
  @Type(() => Number)
  page?: number = 1;

  @ApiPropertyOptional({ description: 'Items per page', default: 20 })
  @IsOptional()
  @IsNumber()
  @Min(1)
  @Type(() => Number)
  limit?: number = 20;
}
