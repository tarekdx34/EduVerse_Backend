import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsOptional, IsNumber, IsDateString, IsEnum, IsString } from 'class-validator';
import { Type } from 'class-transformer';
import { SessionStatus, SessionType } from '../enums';

export class AttendanceQueryDto {
  @ApiPropertyOptional({
    description: 'Filter by section ID',
    example: 1,
  })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  sectionId?: number;

  @ApiPropertyOptional({
    description: 'Filter by course ID',
    example: 1,
  })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  courseId?: number;

  @ApiPropertyOptional({
    description: 'Filter by instructor ID',
    example: 8,
  })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  instructorId?: number;

  @ApiPropertyOptional({
    description: 'Filter by session type',
    enum: ['lecture', 'lab', 'tutorial', 'exam'],
  })
  @IsOptional()
  @IsEnum(SessionType)
  sessionType?: SessionType;

  @ApiPropertyOptional({
    description: 'Filter by session status',
    enum: ['scheduled', 'in_progress', 'completed', 'cancelled'],
  })
  @IsOptional()
  @IsEnum(SessionStatus)
  status?: SessionStatus;

  @ApiPropertyOptional({
    description: 'Filter sessions from this date (YYYY-MM-DD)',
    example: '2026-01-01',
  })
  @IsOptional()
  @IsDateString()
  dateFrom?: string;

  @ApiPropertyOptional({
    description: 'Filter sessions until this date (YYYY-MM-DD)',
    example: '2026-12-31',
  })
  @IsOptional()
  @IsDateString()
  dateTo?: string;

  @ApiPropertyOptional({
    description: 'Search by notes',
    example: 'review',
  })
  @IsOptional()
  @IsString()
  search?: string;

  @ApiPropertyOptional({
    description: 'Page number (1-indexed)',
    example: 1,
    default: 1,
  })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  page?: number = 1;

  @ApiPropertyOptional({
    description: 'Items per page',
    example: 10,
    default: 10,
  })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  limit?: number = 10;

  @ApiPropertyOptional({
    description: 'Sort by field',
    example: 'sessionDate',
    enum: ['sessionDate', 'createdAt', 'status'],
  })
  @IsOptional()
  @IsString()
  sortBy?: string = 'sessionDate';

  @ApiPropertyOptional({
    description: 'Sort order',
    example: 'DESC',
    enum: ['ASC', 'DESC'],
  })
  @IsOptional()
  @IsString()
  sortOrder?: 'ASC' | 'DESC' = 'DESC';
}
