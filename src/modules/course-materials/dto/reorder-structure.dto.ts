import { ApiProperty } from '@nestjs/swagger';
import { IsArray, IsNumber, ArrayNotEmpty } from 'class-validator';

export class ReorderStructureDto {
  @ApiProperty({
    description: 'Array of structure item IDs in the new order',
    example: [3, 1, 2, 4],
    type: [Number],
  })
  @IsArray()
  @ArrayNotEmpty()
  @IsNumber({}, { each: true })
  orderIds: number[];
}
