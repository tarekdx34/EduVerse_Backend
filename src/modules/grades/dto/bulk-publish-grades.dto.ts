import { ApiProperty } from '@nestjs/swagger';
import { ArrayNotEmpty, IsArray, IsInt } from 'class-validator';
import { Type } from 'class-transformer';

export class BulkPublishGradesDto {
  @ApiProperty({
    description: 'Grade IDs to finalize/publish',
    example: [101, 102, 103],
    type: [Number],
  })
  @IsArray()
  @ArrayNotEmpty()
  @Type(() => Number)
  @IsInt({ each: true })
  gradeIds: number[];
}
