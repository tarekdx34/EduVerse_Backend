import { ApiProperty } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { IsArray, ValidateNested, ArrayMinSize, ArrayMaxSize } from 'class-validator';
import { CreateMaterialDto } from './create-material.dto';

export class BulkCreateMaterialDto {
  @ApiProperty({
    description: 'Array of materials to create',
    type: [CreateMaterialDto],
    example: [
      {
        title: 'Lecture 1: Introduction',
        materialType: 'lecture',
        description: 'Introduction to the course',
        weekNumber: 1,
      },
      {
        title: 'Lecture 2: Fundamentals',
        materialType: 'lecture',
        description: 'Fundamentals of the subject',
        weekNumber: 1,
      },
    ],
  })
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => CreateMaterialDto)
  @ArrayMinSize(1, { message: 'At least one material is required' })
  @ArrayMaxSize(50, { message: 'Maximum 50 materials can be created at once' })
  materials: CreateMaterialDto[];
}
