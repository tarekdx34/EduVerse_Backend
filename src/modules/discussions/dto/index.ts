import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsOptional, IsNumber, IsInt, Min, Max } from 'class-validator';
import { Type } from 'class-transformer';

// ============ Create Thread ============
export class CreateThreadDto {
  @ApiProperty({ description: 'Course ID', example: 1 })
  @IsNumber()
  courseId: number;

  @ApiProperty({ description: 'Thread title', example: 'Help with Binary Search Trees' })
  @IsString()
  title: string;

  @ApiPropertyOptional({ description: 'Thread description', example: 'I need help understanding BST insertion and deletion algorithms.' })
  @IsOptional()
  @IsString()
  description?: string;
}

// ============ Update Thread ============
export class UpdateThreadDto {
  @ApiPropertyOptional({ description: 'Thread title', example: 'Updated: Binary Search Trees Discussion' })
  @IsOptional()
  @IsString()
  title?: string;

  @ApiPropertyOptional({ description: 'Thread description', example: 'Updated description with more details' })
  @IsOptional()
  @IsString()
  description?: string;
}

// ============ Create Reply ============
export class CreateReplyDto {
  @ApiProperty({ description: 'Reply text', example: 'You should start by understanding the invariant property of BSTs.' })
  @IsString()
  messageText: string;

  @ApiPropertyOptional({ description: 'Parent message ID for nested replies', example: 5 })
  @IsOptional()
  @IsNumber()
  parentMessageId?: number;
}

// ============ Thread Query ============
export class ThreadQueryDto {
  @ApiPropertyOptional({ description: 'Filter by course ID', example: 1 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  courseId?: number;

  @ApiPropertyOptional({ description: 'Page number', example: 1, default: 1 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page?: number = 1;

  @ApiPropertyOptional({ description: 'Results per page', example: 20, default: 20 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(50)
  limit?: number = 20;
}
