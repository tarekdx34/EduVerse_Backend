import { PartialType } from '@nestjs/swagger';
import { IsOptional, IsEnum, IsNumber, Min, Max } from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { CreateTaskDto } from './create-task.dto';
import { TaskStatus } from '../entities/student-task.entity';

export class UpdateTaskDto extends PartialType(CreateTaskDto) {
  @ApiPropertyOptional({ description: 'Task status', enum: TaskStatus, example: TaskStatus.IN_PROGRESS })
  @IsOptional()
  @IsEnum(TaskStatus)
  status?: TaskStatus;

  @ApiPropertyOptional({ description: 'Completion percentage (0-100)', example: 50 })
  @IsOptional()
  @IsNumber()
  @Min(0)
  @Max(100)
  @Type(() => Number)
  completionPercentage?: number;
}
