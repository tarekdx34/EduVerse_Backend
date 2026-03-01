import { IsNumber, IsString, IsOptional, Min } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class GradeSubmissionDto {
  @ApiProperty({ description: 'Score', minimum: 0 })
  @IsNumber()
  @Min(0)
  score: number;

  @ApiPropertyOptional({ description: 'Feedback comment' })
  @IsString()
  @IsOptional()
  feedback?: string;
}
