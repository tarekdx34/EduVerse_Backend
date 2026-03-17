import { IsNotEmpty, IsInt, IsOptional, Min, Max } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';

export class AssignReviewsDto {
  @ApiProperty({ description: 'Assignment ID whose submissions get peer reviewed', example: 1 })
  @IsNotEmpty()
  @Type(() => Number)
  @IsInt()
  assignmentId: number;

  @ApiPropertyOptional({
    description: 'Number of reviewers assigned per submission (default 2)',
    example: 2,
    default: 2,
  })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(5)
  reviewersPerSubmission?: number;
}
