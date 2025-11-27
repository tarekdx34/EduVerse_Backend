import {
  IsString,
  IsEnum,
  IsOptional,
  Matches,
} from 'class-validator';
import { DayOfWeek, ScheduleType } from '../enums';

export class CreateScheduleDto {
  @IsEnum(DayOfWeek)
  dayOfWeek: DayOfWeek;

  @IsString()
  @Matches(/^([0-1][0-9]|2[0-3]):[0-5][0-9]$/, {
    message: 'Start time must be in HH:mm format (24-hour)',
  })
  startTime: string;

  @IsString()
  @Matches(/^([0-1][0-9]|2[0-3]):[0-5][0-9]$/, {
    message: 'End time must be in HH:mm format (24-hour)',
  })
  endTime: string;

  @IsOptional()
  @IsString()
  room?: string;

  @IsOptional()
  @IsString()
  building?: string;

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
