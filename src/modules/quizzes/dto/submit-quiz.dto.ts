import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsArray, IsNumber, IsOptional, IsString, ValidateNested } from 'class-validator';
import { Type } from 'class-transformer';

export class AnswerDto {
  @ApiProperty({ description: 'Question ID', example: 1 })
  @IsNumber()
  questionId: number;

  @ApiPropertyOptional({ description: 'Text answer (for short answer/essay)', example: 'The time complexity is O(log n)' })
  @IsOptional()
  @IsString()
  answerText?: string;

  @ApiPropertyOptional({ 
    description: 'Selected option indices (for MCQ)', 
    example: ['2'],
    type: [String]
  })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  selectedOption?: string[];
}

export class SubmitQuizDto {
  @ApiProperty({ 
    description: 'Array of answers', 
    type: [AnswerDto] 
  })
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => AnswerDto)
  answers: AnswerDto[];
}
