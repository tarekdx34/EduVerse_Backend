import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsNotEmpty,
  IsNumber,
  IsDateString,
  IsEnum,
  IsOptional,
  IsString,
} from 'class-validator';
import { SessionType } from '../enums';

export class CreateSessionDto {
  @ApiProperty({
    description: 'Course section ID',
    example: 1,
  })
  @IsNotEmpty()
  @IsNumber()
  sectionId: number;

  @ApiProperty({
    description: 'Session date (YYYY-MM-DD)',
    example: '2026-03-01',
  })
  @IsNotEmpty()
  @IsDateString()
  sessionDate: string;

  @ApiPropertyOptional({
    description: 'Type of session',
    enum: SessionType,
    default: SessionType.LECTURE,
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
    description: 'Additional notes',
    example: 'Midterm review session',
  })
  @IsOptional()
  @IsString()
  notes?: string;
}
