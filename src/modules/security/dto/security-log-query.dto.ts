import { IsOptional, IsNumber, IsDateString, IsEnum, Min } from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { SecurityEventType, SecuritySeverity } from '../entities/security-log.entity';

export class SecurityLogQueryDto {
  @ApiPropertyOptional({ description: 'Filter by event type', enum: SecurityEventType })
  @IsOptional()
  @IsEnum(SecurityEventType)
  eventType?: SecurityEventType;

  @ApiPropertyOptional({ description: 'Filter by severity', enum: SecuritySeverity })
  @IsOptional()
  @IsEnum(SecuritySeverity)
  severity?: SecuritySeverity;

  @ApiPropertyOptional({ description: 'Filter by user ID' })
  @IsOptional()
  @IsNumber()
  @Type(() => Number)
  userId?: number;

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
