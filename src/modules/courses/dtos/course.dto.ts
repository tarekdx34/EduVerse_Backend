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
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { CourseLevel, CourseStatus } from '../enums';

export class CreateCourseDto {
  @ApiProperty({ description: 'Department ID', example: 1 })
  @IsNumber()
  departmentId: number;

  @ApiProperty({ description: 'Course name', example: 'Introduction to Computer Science' })
  @IsString()
  name: string;

  @ApiProperty({ description: 'Course code (2-10 uppercase alphanumeric)', example: 'CS101' })
  @IsString()
  @Matches(/^[A-Z0-9]{2,10}$/, {
    message: 'Course code must be 2-10 uppercase alphanumeric characters',
  })
  code: string;

  @ApiProperty({ description: 'Course description', example: 'Fundamentals of programming and computational thinking.' })
  @IsString()
  description: string;

  @ApiProperty({ description: 'Credit hours (1-6)', example: 3, minimum: 1, maximum: 6 })
  @IsInt()
  @Min(1)
  @Max(6)
  credits: number;

  @ApiProperty({ description: 'Course level', enum: ['FRESHMAN', 'SOPHOMORE', 'JUNIOR', 'SENIOR', 'GRADUATE'], example: 'FRESHMAN' })
  @IsEnum(CourseLevel)
  level: CourseLevel;

  @ApiPropertyOptional({ description: 'Syllabus URL', example: 'https://example.com/syllabus/cs101.pdf' })
  @IsOptional()
  @IsString()
  syllabusUrl?: string;

  @ApiPropertyOptional({ description: 'Skills gained from this course', example: ['Python', 'Data Analysis'] })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  skills?: string[];
}

export class UpdateCourseDto {
  @ApiPropertyOptional({ description: 'Course name', example: 'Advanced Computer Science' })
  @IsOptional()
  @IsString()
  name?: string;

  @ApiPropertyOptional({ description: 'Course description', example: 'Updated course description.' })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiPropertyOptional({ description: 'Credit hours (1-6)', example: 3 })
  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(6)
  credits?: number;

  @ApiPropertyOptional({ description: 'Course level', enum: ['FRESHMAN', 'SOPHOMORE', 'JUNIOR', 'SENIOR', 'GRADUATE'], example: 'JUNIOR' })
  @IsOptional()
  @IsEnum(CourseLevel)
  level?: CourseLevel;

  @ApiPropertyOptional({ description: 'Syllabus URL', example: 'https://example.com/syllabus/cs101-v2.pdf' })
  @IsOptional()
  @IsString()
  syllabusUrl?: string;

  @ApiPropertyOptional({ description: 'Course status', enum: ['ACTIVE', 'INACTIVE', 'ARCHIVED'], example: 'ACTIVE' })
  @IsOptional()
  @IsEnum(CourseStatus)
  status?: CourseStatus;

  @ApiPropertyOptional({ description: 'Skills gained from this course', example: ['Python', 'Data Analysis'] })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  skills?: string[];
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
  skills: string[] | null;
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
