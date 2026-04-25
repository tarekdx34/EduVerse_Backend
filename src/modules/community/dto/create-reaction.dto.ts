import { IsEnum } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';
import { ReactionType } from '../enums';

export class CreateReactionDto {
  @ApiProperty({
    description: 'Reaction type to add/toggle',
    enum: ['like', 'love', 'haha', 'wow', 'sad', 'angry'],
    example: 'like',
  })
  @IsEnum(ReactionType)
  reactionType: ReactionType;
}
