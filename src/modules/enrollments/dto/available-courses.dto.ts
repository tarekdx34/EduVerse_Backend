import { IsOptional, IsString, IsNumber, Min } from 'class-validator';

export class AvailableCoursesFilterDto {
  @IsOptional()
  @IsNumber()
  @Min(1)
  departmentId?: number;

  @IsOptional()
  @IsNumber()
  @Min(1)
  semesterId?: number;

  @IsOptional()
  @IsString()
  search?: string;

  @IsOptional()
  @IsString()
  level?: string;

  @IsOptional()
  @IsNumber()
  @Min(1)
  page?: number = 1;

  @IsOptional()
  @IsNumber()
  @Min(1)
  limit?: number = 20;
}

export class AvailableCoursesDto {
  id: number;
  name: string;
  code: string;
  description: string;
  credits: number;
  level: string;
  departmentId: number;
  departmentName: string;

  sections: {
    id: number;
    sectionNumber: string;
    maxCapacity: number;
    currentEnrollment: number;
    availableSeats: number;
    location: string | null;
    semesterId: number;
    semesterName: string;
  }[];

  prerequisites: {
    id: number;
    courseId: number;
    prerequisiteCourseId: number;
    courseCode: string;
    courseName: string;
    isMandatory: boolean;
  }[];

  canEnroll: boolean;
  enrollmentStatus?: string;
}
