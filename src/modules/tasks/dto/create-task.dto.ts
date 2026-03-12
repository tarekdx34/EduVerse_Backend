import { IsString, IsOptional, IsEnum, IsNumber, IsDateString } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { TaskType, TaskPriority } from '../entities/student-task.entity';

export class CreateTaskDto {
  @ApiProperty({ description: 'Task title', example: 'Complete Assignment 1' })
  @IsString()
  title: string;

  @ApiPropertyOptional({ description: 'Task description', example: 'Finish all exercises in chapter 3' })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiProperty({ description: 'Task type', enum: TaskType, example: TaskType.ASSIGNMENT })
  @IsEnum(TaskType)
  taskType: TaskType;

  @ApiPropertyOptional({ description: 'Linked assignment ID', example: 1 })
  @IsOptional()
  @IsNumber()
  @Type(() => Number)
  assignmentId?: number;

  @ApiPropertyOptional({ description: 'Linked quiz ID', example: 1 })
  @IsOptional()
  @IsNumber()
  @Type(() => Number)
  quizId?: number;

  @ApiPropertyOptional({ description: 'Linked lab ID', example: 1 })
  @IsOptional()
  @IsNumber()
  @Type(() => Number)
  labId?: number;

  @ApiPropertyOptional({ description: 'Due date (ISO 8601)', example: '2025-03-15T23:59:00Z' })
  @IsOptional()
  @IsDateString()
  dueDate?: string;

  @ApiPropertyOptional({ description: 'Task priority', enum: TaskPriority, example: TaskPriority.MEDIUM })
  @IsOptional()
  @IsEnum(TaskPriority)
  priority?: TaskPriority;
}
