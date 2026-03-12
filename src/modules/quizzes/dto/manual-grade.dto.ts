import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsNumber, IsOptional, IsString, IsArray, ValidateNested } from 'class-validator';
import { Type } from 'class-transformer';

export class GradeAnswerDto {
  @ApiProperty({ description: 'Answer ID', example: 1 })
  @IsNumber()
  answerId: number;

  @ApiProperty({ description: 'Points to award', example: 3.5 })
  @IsNumber()
  pointsEarned: number;

  @ApiPropertyOptional({ description: 'Instructor feedback', example: 'Good explanation, but missed one key point.' })
  @IsOptional()
  @IsString()
  feedback?: string;
}

export class ManualGradeDto {
  @ApiProperty({ 
    description: 'Array of answer grades', 
    type: [GradeAnswerDto] 
  })
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => GradeAnswerDto)
  grades: GradeAnswerDto[];
}
