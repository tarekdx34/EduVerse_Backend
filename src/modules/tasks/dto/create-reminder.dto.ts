import { IsNumber, IsDateString, IsOptional, IsEnum } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { ReminderType } from '../entities/deadline-reminder.entity';

export class CreateReminderDto {
  @ApiProperty({ description: 'Task ID to set reminder for', example: 1 })
  @IsNumber()
  @Type(() => Number)
  taskId: number;

  @ApiProperty({ description: 'Reminder time (ISO 8601)', example: '2025-03-14T10:00:00Z' })
  @IsDateString()
  reminderTime: string;

  @ApiPropertyOptional({ description: 'Reminder type', enum: ReminderType, default: ReminderType.IN_APP })
  @IsOptional()
  @IsEnum(ReminderType)
  reminderType?: ReminderType;
}
