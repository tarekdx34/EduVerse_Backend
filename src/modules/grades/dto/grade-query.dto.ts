import { IsOptional, IsNumber, IsEnum, IsBoolean } from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { GradeType } from '../enums';

export class GradeQueryDto {
  @ApiPropertyOptional()
  @IsNumber()
  @IsOptional()
  @Type(() => Number)
  courseId?: number;

  @ApiPropertyOptional()
  @IsNumber()
  @IsOptional()
  @Type(() => Number)
  userId?: number;

  @ApiPropertyOptional({ enum: GradeType })
  @IsEnum(GradeType)
  @IsOptional()
  gradeType?: GradeType;

  @ApiPropertyOptional()
  @IsBoolean()
  @IsOptional()
  @Type(() => Boolean)
  isPublished?: boolean;

  @ApiPropertyOptional({ default: 1 })
  @IsNumber()
  @IsOptional()
  @Type(() => Number)
  page?: number;

  @ApiPropertyOptional({ default: 10 })
  @IsNumber()
  @IsOptional()
  @Type(() => Number)
  limit?: number;
}
