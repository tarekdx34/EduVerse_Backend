import {
  IsString,
  IsEnum,
  IsOptional,
  Matches,
} from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { DayOfWeek, ScheduleType } from '../enums';

export class CreateScheduleDto {
  @ApiProperty({
    description: 'Day of the week',
    enum: DayOfWeek,
    example: 'monday',
  })
  @IsEnum(DayOfWeek)
  dayOfWeek: DayOfWeek;

  @ApiProperty({
    description: 'Start time in HH:mm format (24-hour)',
    example: '09:00',
  })
  @IsString()
  @Matches(/^([0-1][0-9]|2[0-3]):[0-5][0-9]$/, {
    message: 'Start time must be in HH:mm format (24-hour)',
  })
  startTime: string;

  @ApiProperty({
    description: 'End time in HH:mm format (24-hour)',
    example: '10:30',
  })
  @IsString()
  @Matches(/^([0-1][0-9]|2[0-3]):[0-5][0-9]$/, {
    message: 'End time must be in HH:mm format (24-hour)',
  })
  endTime: string;

  @ApiPropertyOptional({
    description: 'Room number/name',
    example: 'A101',
  })
  @IsOptional()
  @IsString()
  room?: string;

  @ApiPropertyOptional({
    description: 'Building name',
    example: 'Main Building',
  })
  @IsOptional()
  @IsString()
  building?: string;

  @ApiProperty({
    description: 'Type of schedule entry',
    enum: ScheduleType,
    example: 'lecture',
  })
  @IsEnum(ScheduleType)
  scheduleType: ScheduleType;
}

export class CourseScheduleDto {
  id: number;
  sectionId: number;
  dayOfWeek: DayOfWeek;
  startTime: string;
  endTime: string;
  room: string | null;
  building: string | null;
  scheduleType: ScheduleType;
  createdAt: Date;
}
