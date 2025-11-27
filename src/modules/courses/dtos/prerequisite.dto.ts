import {
  IsNumber,
  IsOptional,
  IsBoolean,
} from 'class-validator';

export class CreatePrerequisiteDto {
  @IsNumber()
  prerequisiteCourseId: number;

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
