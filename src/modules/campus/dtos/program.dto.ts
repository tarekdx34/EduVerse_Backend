import {
  IsString,
  IsNotEmpty,
  Length,
  Matches,
  IsOptional,
  IsInt,
  IsPositive,
  IsEnum,
  Min,
  Max,
} from 'class-validator';
import { PartialType } from '@nestjs/mapped-types';
import { Type } from 'class-transformer';
import { Status } from '../enums/status.enum';
import { DegreeType } from '../enums/degree-type.enum';

export class CreateProgramDto {
  @Type(() => Number)
  @IsInt()
  @IsPositive()
  departmentId: number;

  @IsString()
  @IsNotEmpty()
  @Length(1, 100)
  name: string;

  @IsString()
  @IsNotEmpty()
  @Matches(/^[A-Z0-9]{2,20}$/, {
    message: 'Code must be 2-20 uppercase alphanumeric characters',
  })
  code: string;

  @IsEnum(DegreeType)
  degreeType: DegreeType;

  @Type(() => Number)
  @IsInt()
  @IsPositive()
  @Min(1)
  @Max(10)
  durationYears: number;

  @IsOptional()
  @IsString()
  description?: string;

  @IsOptional()
  @IsEnum(Status)
  status?: Status;
}

export class UpdateProgramDto extends PartialType(CreateProgramDto) {}

export class ProgramDto {
  id: number;
  departmentId: number;
  name: string;
  code: string;
  degreeType: DegreeType;
  durationYears: number;
  description: string;
  status: Status;
  createdAt: Date;
  updatedAt: Date;
  departmentName?: string;
  campusName?: string;
}
