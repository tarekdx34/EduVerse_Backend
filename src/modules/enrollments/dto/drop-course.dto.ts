import { IsString, IsOptional } from 'class-validator';
import { DropReason } from '../enums';

export class DropCourseDto {
  @IsOptional()
  @IsString()
  reason?: DropReason;

  @IsOptional()
  @IsString()
  notes?: string;
}
