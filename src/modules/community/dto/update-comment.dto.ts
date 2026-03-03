import { IsString } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class UpdateCommentDto {
  @ApiProperty({
    description: 'Updated comment text',
    example: 'Updated: I can meet on Saturday afternoon instead.',
  })
  @IsString()
  commentText: string;
}
