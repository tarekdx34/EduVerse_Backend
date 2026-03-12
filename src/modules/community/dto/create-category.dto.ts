import { IsString, IsOptional, IsNumber, MaxLength } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateCategoryDto {
  @ApiProperty({
    description: 'Course ID where the category belongs',
    example: 1,
  })
  @IsNumber()
  courseId: number;

  @ApiProperty({
    description: 'Category name',
    example: 'General Discussion',
    maxLength: 255,
  })
  @IsString()
  @MaxLength(255)
  name: string;

  @ApiPropertyOptional({
    description: 'Category description',
    example: 'General discussions about the course topics.',
  })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiPropertyOptional({
    description: 'Order index for sorting categories',
    example: 1,
  })
  @IsOptional()
  @IsNumber()
  orderIndex?: number;
}
