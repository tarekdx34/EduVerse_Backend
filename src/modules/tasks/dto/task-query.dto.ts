import { IsOptional, IsEnum, IsNumber, Min } from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { TaskStatus, TaskPriority, TaskType } from '../entities/student-task.entity';

export enum TaskSortBy {
  DUE_DATE = 'due_date',
  CREATED_AT = 'created_at',
  PRIORITY = 'priority',
}

export class TaskQueryDto {
  @ApiPropertyOptional({ description: 'Filter by status', enum: ['pending', 'in_progress', 'completed', 'overdue'] })
  @IsOptional()
  @IsEnum(TaskStatus)
  status?: TaskStatus;

  @ApiPropertyOptional({ description: 'Filter by priority', enum: ['low', 'medium', 'high'] })
  @IsOptional()
  @IsEnum(TaskPriority)
  priority?: TaskPriority;

  @ApiPropertyOptional({ description: 'Filter by task type', enum: ['assignment', 'quiz', 'lab', 'study', 'custom'] })
  @IsOptional()
  @IsEnum(TaskType)
  taskType?: TaskType;

  @ApiPropertyOptional({ description: 'Page number', example: 1, default: 1 })
  @IsOptional()
  @IsNumber()
  @Min(1)
  @Type(() => Number)
  page?: number = 1;

  @ApiPropertyOptional({ description: 'Items per page', example: 20, default: 20 })
  @IsOptional()
  @IsNumber()
  @Min(1)
  @Type(() => Number)
  limit?: number = 20;

  @ApiPropertyOptional({ description: 'Sort by field', enum: ['due_date', 'created_at', 'priority'], default: 'created_at' })
  @IsOptional()
  @IsEnum(TaskSortBy)
  sortBy?: TaskSortBy = TaskSortBy.CREATED_AT;
}
