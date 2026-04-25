import { IsOptional, IsEnum, IsNumber, Min } from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { ApiPropertyStringEnumOptional } from '../../../common/swagger/string-enum.schema';
import { TaskStatus, TaskPriority, TaskType } from '../entities/student-task.entity';

export enum TaskSortBy {
  DUE_DATE = 'due_date',
  CREATED_AT = 'created_at',
  PRIORITY = 'priority',
}

export class TaskQueryDto {
  @ApiPropertyStringEnumOptional({
    description: 'Filter by status',
    enumObject: TaskStatus,
  })
  @IsOptional()
  @IsEnum(TaskStatus)
  status?: TaskStatus;

  @ApiPropertyStringEnumOptional({
    description: 'Filter by priority',
    enumObject: TaskPriority,
  })
  @IsOptional()
  @IsEnum(TaskPriority)
  priority?: TaskPriority;

  @ApiPropertyStringEnumOptional({
    description: 'Filter by task type',
    enumObject: TaskType,
  })
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

  @ApiPropertyStringEnumOptional({
    description: 'Sort by field',
    enumObject: TaskSortBy,
    default: TaskSortBy.CREATED_AT,
  })
  @IsOptional()
  @IsEnum(TaskSortBy)
  sortBy?: TaskSortBy = TaskSortBy.CREATED_AT;
}
