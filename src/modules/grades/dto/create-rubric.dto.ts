import { IsNumber, IsString, IsOptional, MinLength, MaxLength } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateRubricDto {
  @ApiProperty({ description: 'Course ID', example: 1 })
  @IsNumber()
  courseId: number;

  @ApiProperty({ description: 'Rubric name', example: 'Essay Grading Rubric', minLength: 3, maxLength: 200 })
  @IsString()
  @MinLength(3)
  @MaxLength(200)
  rubricName: string;

  @ApiPropertyOptional({ description: 'Rubric description', example: 'Rubric for evaluating research essays' })
  @IsString()
  @IsOptional()
  description?: string;

  @ApiPropertyOptional({
    description: 'JSON criteria definition',
    example: '[{"name":"Content","maxPoints":40,"description":"Quality of content"},{"name":"Grammar","maxPoints":30,"description":"Writing quality"},{"name":"Format","maxPoints":30,"description":"Proper formatting"}]',
  })
  @IsString()
  @IsOptional()
  criteria?: string;

  @ApiProperty({ description: 'Total points for the rubric', example: 100 })
  @IsNumber()
  totalPoints: number;
}
