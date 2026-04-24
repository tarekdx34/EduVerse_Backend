import {
  IsNumber,
  IsOptional,
  IsEnum,
  IsInt,
  Min,
  ValidateNested,
} from 'class-validator';
import { Type } from 'class-transformer';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { SectionStatus } from '../enums';

export class CreateSectionDto {
  @ApiProperty({ description: 'Course ID', example: 1 })
  @IsNumber()
  courseId: number;

  @ApiProperty({ description: 'Semester ID', example: 1 })
  @IsNumber()
  semesterId: number;

  @ApiPropertyOptional({ description: 'Section number (auto-generated if omitted)', example: 1 })
  @IsOptional()
  @IsInt()
  @Min(1)
  sectionNumber?: number;

  @ApiProperty({ description: 'Maximum student capacity', example: 30 })
  @IsInt()
  @Min(1)
  maxCapacity: number;

  @ApiPropertyOptional({ description: 'Current enrollment count', example: 0, default: 0 })
  @IsOptional()
  @IsInt()
  @Min(0)
  currentEnrollment?: number;

  @ApiPropertyOptional({ description: 'Location/room', example: 'Room A101' })
  @IsOptional()
  location?: string;
}

export class UpdateSectionDto {
  @ApiPropertyOptional({ description: 'Maximum student capacity', example: 35 })
  @IsOptional()
  @IsInt()
  @Min(1)
  maxCapacity?: number;

  @ApiPropertyOptional({ description: 'Current enrollment count', example: 25 })
  @IsOptional()
  @IsInt()
  @Min(0)
  currentEnrollment?: number;

  @ApiPropertyOptional({ description: 'Location/room', example: 'Room B202' })
  @IsOptional()
  location?: string;

  @ApiPropertyOptional({ description: 'Section status', enum: ['OPEN', 'CLOSED', 'FULL', 'CANCELLED'], example: 'OPEN' })
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
