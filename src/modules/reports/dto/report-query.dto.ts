import { IsOptional, IsEnum, IsNumber, IsString } from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';

export class ReportQueryDto {
  @ApiPropertyOptional({
    description: 'Filter by report type',
    example: 'student',
  })
  @IsString()
  @IsOptional()
  reportType?: string;

  @ApiPropertyOptional({
    description: 'Filter by generation status',
    enum: ['pending', 'processing', 'completed', 'failed'],
  })
  @IsEnum(['pending', 'processing', 'completed', 'failed'])
  @IsOptional()
  generationStatus?: string;

  @ApiPropertyOptional({ description: 'Page number', example: 1, minimum: 1 })
  @IsNumber()
  @Type(() => Number)
  @IsOptional()
  page?: number = 1;

  @ApiPropertyOptional({ description: 'Items per page', example: 20, minimum: 1, maximum: 100 })
  @IsNumber()
  @Type(() => Number)
  @IsOptional()
  limit?: number = 20;

  @ApiPropertyOptional({
    description: 'Sort by field',
    enum: ['created_at', 'report_name'],
  })
  @IsEnum(['created_at', 'report_name'])
  @IsOptional()
  sortBy?: string = 'created_at';
}
