import { IsOptional, IsNumber, IsDateString, IsEnum, IsString, Min } from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { ApiPropertyStringEnumOptional } from '../../../common/swagger/string-enum.schema';
import { ErrorType, ErrorSeverity } from '../entities/system-error.entity';

export class ErrorQueryDto {
  @ApiPropertyStringEnumOptional({
    description: 'Filter by error type',
    enumObject: ErrorType,
  })
  @IsOptional()
  @IsEnum(ErrorType)
  errorType?: ErrorType;

  @ApiPropertyStringEnumOptional({
    description: 'Filter by severity',
    enumObject: ErrorSeverity,
  })
  @IsOptional()
  @IsEnum(ErrorSeverity)
  severity?: ErrorSeverity;

  @ApiPropertyOptional({ description: 'Filter by resolved status (0 or 1)' })
  @IsOptional()
  @IsNumber()
  @Type(() => Number)
  isResolved?: number;

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
