import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsNotEmpty,
  IsString,
  IsEnum,
  IsOptional,
  IsBoolean,
  IsNumber,
  IsArray,
  ValidateNested,
  MaxLength,
} from 'class-validator';
import { Type } from 'class-transformer';
import { TemplateScheduleType } from '../entities/schedule-template.entity';
import { DayOfWeek, ScheduleType } from '../../courses/enums';

export class TemplateSlotDto {
  @ApiProperty({
    description: 'Day of week',
    enum: ['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY'],
    example: 'MONDAY',
  })
  @IsEnum(DayOfWeek)
  @IsNotEmpty()
  dayOfWeek: DayOfWeek;

  @ApiProperty({
    description: 'Start time (HH:MM:SS)',
    example: '09:00:00',
  })
  @IsString()
  @IsNotEmpty()
  startTime: string;

  @ApiProperty({
    description: 'End time (HH:MM:SS)',
    example: '11:00:00',
  })
  @IsString()
  @IsNotEmpty()
  endTime: string;

  @ApiProperty({
    description: 'Type of slot',
    enum: ['LECTURE', 'LAB', 'TUTORIAL', 'EXAM'],
    example: 'LECTURE',
  })
  @IsEnum(ScheduleType)
  @IsNotEmpty()
  slotType: ScheduleType;

  @ApiPropertyOptional({
    description: 'Building name',
    example: 'Engineering Building',
  })
  @IsString()
  @IsOptional()
  building?: string;

  @ApiPropertyOptional({
    description: 'Room number',
    example: 'Room 301',
  })
  @IsString()
  @IsOptional()
  room?: string;
}

export class CreateScheduleTemplateDto {
  @ApiProperty({
    description: 'Template name',
    example: 'MW 2-Hour Lecture Pattern',
    maxLength: 255,
  })
  @IsString()
  @MaxLength(255)
  @IsNotEmpty()
  name: string;

  @ApiPropertyOptional({
    description: 'Template description',
    example: 'Standard Monday-Wednesday 2-hour lecture schedule',
  })
  @IsString()
  @IsOptional()
  description?: string;

  @ApiPropertyOptional({
    description: 'Department ID (null = university-wide)',
    example: 1,
  })
  @IsNumber()
  @IsOptional()
  departmentId?: number;

  @ApiProperty({
    description: 'Schedule type',
    enum: ['LECTURE', 'LAB', 'TUTORIAL', 'HYBRID'],
    example: 'LECTURE',
  })
  @IsEnum(TemplateScheduleType)
  @IsNotEmpty()
  scheduleType: TemplateScheduleType;

  @ApiProperty({
    description: 'Time slots for the template',
    type: [TemplateSlotDto],
    example: [
      {
        dayOfWeek: 'MONDAY',
        startTime: '09:00:00',
        endTime: '11:00:00',
        slotType: 'LECTURE',
      },
      {
        dayOfWeek: 'WEDNESDAY',
        startTime: '09:00:00',
        endTime: '11:00:00',
        slotType: 'LECTURE',
      },
    ],
  })
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => TemplateSlotDto)
  @IsNotEmpty()
  slots: TemplateSlotDto[];

  @ApiPropertyOptional({
    description: 'Is template active',
    example: true,
    default: true,
  })
  @IsBoolean()
  @IsOptional()
  isActive?: boolean;
}
