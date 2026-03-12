import { IsEnum } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';
import { ReactionType } from '../enums';

export class CreateReactionDto {
  @ApiProperty({
    description: 'Reaction type to add/toggle',
    enum: ReactionType,
    example: ReactionType.LIKE,
  })
  @IsEnum(ReactionType)
  reactionType: ReactionType;
}
