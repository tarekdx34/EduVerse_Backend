import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  ArrayMaxSize,
  ArrayMinSize,
  IsArray,
  IsInt,
  IsOptional,
  Min,
  ValidateNested,
} from 'class-validator';
import { CreateQuestionBankQuestionDto } from './question.dto';

export class BulkCreateQuestionBankQuestionsDto {
  @ApiProperty()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  courseId: number;

  @ApiPropertyOptional()
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  defaultChapterId?: number;

  @ApiProperty({ type: [CreateQuestionBankQuestionDto] })
  @IsArray()
  @ArrayMinSize(1)
  @ArrayMaxSize(50)
  @ValidateNested({ each: true })
  @Type(() => CreateQuestionBankQuestionDto)
  questions: CreateQuestionBankQuestionDto[];
}
