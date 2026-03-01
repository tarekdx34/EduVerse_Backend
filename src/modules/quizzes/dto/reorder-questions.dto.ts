import { ApiProperty } from '@nestjs/swagger';
import { IsArray, IsNumber, ArrayNotEmpty } from 'class-validator';

export class ReorderQuestionsDto {
  @ApiProperty({
    description: 'Array of question IDs in desired order',
    example: [5, 3, 1, 4, 2],
    type: [Number],
  })
  @IsArray()
  @ArrayNotEmpty()
  @IsNumber({}, { each: true })
  questionIds: number[];
}
