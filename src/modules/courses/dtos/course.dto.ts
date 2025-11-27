import {
  IsString,
  IsNumber,
  IsOptional,
  IsEnum,
  IsBoolean,
  IsInt,
  Min,
  Max,
  Matches,
  ValidateNested,
  IsArray,
} from 'class-validator';
import { Type } from 'class-transformer';
import { CourseLevel, CourseStatus } from '../enums';

export class CreateCourseDto {
  @IsNumber()
  departmentId: number;

  @IsString()
  name: string;

  @IsString()
  @Matches(/^[A-Z0-9]{2,10}$/, {
    message: 'Course code must be 2-10 uppercase alphanumeric characters',
  })
  code: string;

  @IsString()
  description: string;

  @IsInt()
  @Min(1)
  @Max(6)
  credits: number;

  @IsEnum(CourseLevel)
  level: CourseLevel;

  @IsOptional()
  @IsString()
  syllabusUrl?: string;
}

export class UpdateCourseDto {
  @IsOptional()
  @IsString()
  name?: string;

  @IsOptional()
  @IsString()
  description?: string;

  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(6)
  credits?: number;

  @IsOptional()
  @IsEnum(CourseLevel)
  level?: CourseLevel;

  @IsOptional()
  @IsString()
  syllabusUrl?: string;

  @IsOptional()
  @IsEnum(CourseStatus)
  status?: CourseStatus;
}

export class CourseDto {
  id: number;
  departmentId: number;
  name: string;
  code: string;
  description: string;
  credits: number;
  level: CourseLevel;
  syllabusUrl: string | null;
  status: CourseStatus;
  createdAt: Date;
  updatedAt: Date;
}

export class CourseDetailDto extends CourseDto {
  department: {
    id: number;
    name: string;
    code: string;
  };
  prerequisitesCount: number;
  sectionsCount: number;
}

export class PaginatedCourseDto {
  data: CourseDto[];
  meta: {
    total: number;
    page: number;
    limit: number;
    totalPages: number;
  };
}
