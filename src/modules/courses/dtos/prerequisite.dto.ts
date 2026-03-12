import {
  IsNumber,
  IsOptional,
  IsBoolean,
} from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreatePrerequisiteDto {
  @ApiProperty({ description: 'Prerequisite course ID', example: 1 })
  @IsNumber()
  prerequisiteCourseId: number;

  @ApiProperty({ description: 'Whether this prerequisite is mandatory', example: true })
  @IsBoolean()
  isMandatory: boolean;
}

export class PrerequisiteDto {
  id: number;
  courseId: number;
  prerequisiteCourseId: number;
  isMandatory: boolean;
  prerequisiteCourse: {
    id: number;
    name: string;
    code: string;
    level: string;
  };
  createdAt: Date;
}
