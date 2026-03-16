import { IsNotEmpty, IsString, IsOptional, IsNumber, Min, Max } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';

export class SubmitReviewDto {
  @ApiProperty({ description: 'Text of the peer review', example: 'Good work overall, but the algorithm could be optimized.' })
  @IsNotEmpty()
  @IsString()
  reviewText: string;

  @ApiPropertyOptional({ description: 'Overall rating out of 5.00', example: 4.50 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(0)
  @Max(5)
  rating?: number;

  @ApiPropertyOptional({
    description: 'JSON string of criteria-based scores',
    example: '{"clarity": 4, "completeness": 5, "correctness": 3}',
  })
  @IsOptional()
  @IsString()
  criteriaScores?: string;
}
