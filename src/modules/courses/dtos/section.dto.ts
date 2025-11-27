import {
  IsNumber,
  IsOptional,
  IsEnum,
  IsInt,
  Min,
  ValidateNested,
} from 'class-validator';
import { Type } from 'class-transformer';
import { SectionStatus } from '../enums';

export class CreateSectionDto {
  @IsNumber()
  courseId: number;

  @IsNumber()
  semesterId: number;

  @IsOptional()
  @IsInt()
  @Min(1)
  sectionNumber?: number;

  @IsInt()
  @Min(1)
  maxCapacity: number;

  @IsOptional()
  @IsInt()
  @Min(0)
  currentEnrollment?: number;

  @IsOptional()
  location?: string;
}

export class UpdateSectionDto {
  @IsOptional()
  @IsInt()
  @Min(1)
  maxCapacity?: number;

  @IsOptional()
  @IsInt()
  @Min(0)
  currentEnrollment?: number;

  @IsOptional()
  location?: string;

  @IsOptional()
  @IsEnum(SectionStatus)
  status?: SectionStatus;
}

export class CourseSectionDto {
  id: number;
  courseId: number;
  semesterId: number;
  sectionNumber: string;
  maxCapacity: number;
  currentEnrollment: number;
  location: string | null;
  status: SectionStatus;
  createdAt: Date;
  updatedAt: Date;
}

export class CourseSectionDetailDto extends CourseSectionDto {
  course: {
    id: number;
    name: string;
    code: string;
  };
  semester: {
    id: number;
    name: string;
    startDate: Date;
    endDate: Date;
  };
  schedules: Array<{
    id: number;
    dayOfWeek: string;
    startTime: string;
    endTime: string;
    room: string;
    building: string;
    scheduleType: string;
  }>;
}
