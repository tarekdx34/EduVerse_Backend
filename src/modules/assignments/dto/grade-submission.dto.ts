import { IsNumber, IsString, IsOptional, Min } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class GradeSubmissionDto {
  @ApiProperty({ description: 'Score', minimum: 0, example: 85 })
  @IsNumber()
  @Min(0)
  score: number;

  @ApiPropertyOptional({ description: 'Feedback comment', example: 'Well done! Consider improving the conclusion.' })
  @IsString()
  @IsOptional()
  feedback?: string;
}
