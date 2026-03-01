import { IsNumber, IsString, IsOptional, MinLength, MaxLength } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateRubricDto {
  @ApiProperty()
  @IsNumber()
  courseId: number;

  @ApiProperty()
  @IsString()
  @MinLength(3)
  @MaxLength(200)
  rubricName: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  description?: string;

  @ApiPropertyOptional({ description: 'JSON criteria definition' })
  @IsString()
  @IsOptional()
  criteria?: string;

  @ApiProperty()
  @IsNumber()
  totalPoints: number;
}
