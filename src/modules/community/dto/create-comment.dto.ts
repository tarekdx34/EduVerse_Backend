import { IsString, IsOptional, IsNumber } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateCommentDto {
  @ApiProperty({
    description: 'Comment text',
    example: 'I would be interested in joining! What time works for everyone?',
  })
  @IsString()
  commentText: string;

  @ApiPropertyOptional({
    description: 'Parent comment ID for nested replies',
    example: 1,
  })
  @IsOptional()
  @IsNumber()
  parentCommentId?: number;
}
