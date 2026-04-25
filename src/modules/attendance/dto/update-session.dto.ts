import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsDateString, IsEnum, IsOptional, IsString } from 'class-validator';
import { SessionType, SessionStatus } from '../enums';

export class UpdateSessionDto {
  @ApiPropertyOptional({
    description: 'Session date (YYYY-MM-DD)',
    example: '2026-03-01',
  })
  @IsOptional()
  @IsDateString()
  sessionDate?: string;

  @ApiPropertyOptional({
    description: 'Type of session',
    enum: ['lecture', 'lab', 'tutorial', 'exam'],
  })
  @IsOptional()
  @IsEnum(SessionType)
  sessionType?: SessionType;

  @ApiPropertyOptional({
    description: 'Start time (HH:MM:SS)',
    example: '09:00:00',
  })
  @IsOptional()
  @IsString()
  startTime?: string;

  @ApiPropertyOptional({
    description: 'End time (HH:MM:SS)',
    example: '10:30:00',
  })
  @IsOptional()
  @IsString()
  endTime?: string;

  @ApiPropertyOptional({
    description: 'Location of the session',
    example: 'Room 101',
  })
  @IsOptional()
  @IsString()
  location?: string;

  @ApiPropertyOptional({
    description: 'Session status',
    enum: ['scheduled', 'in_progress', 'completed', 'cancelled'],
  })
  @IsOptional()
  @IsEnum(SessionStatus)
  status?: SessionStatus;

  @ApiPropertyOptional({
    description: 'Additional notes',
    example: 'Midterm review session',
  })
  @IsOptional()
  @IsString()
  notes?: string;
}
