import { IsString, IsOptional, IsEnum, IsNumber, IsObject } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';

export class GenerateReportDto {
  @ApiProperty({ description: 'Template ID to generate the report from', example: 1 })
  @IsNumber()
  @Type(() => Number)
  templateId: number;

  @ApiProperty({ description: 'Name for the generated report', example: 'Q1 Student Performance Report' })
  @IsString()
  reportName: string;

  @ApiPropertyOptional({
    description: 'Filter criteria for the report',
    example: { courseId: 1, semesterId: 2, startDate: '2024-01-01', endDate: '2024-06-30' },
  })
  @IsObject()
  @IsOptional()
  filters?: Record<string, any>;

  @ApiPropertyOptional({
    description: 'Export format for the report',
    enum: ['pdf', 'excel', 'csv', 'json'],
    default: 'pdf',
  })
  @IsEnum(['pdf', 'excel', 'csv', 'json'])
  @IsOptional()
  exportFormat?: string = 'pdf';
}
