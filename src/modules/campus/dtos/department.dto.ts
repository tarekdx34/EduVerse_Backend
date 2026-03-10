import {
  IsString,
  IsNotEmpty,
  Length,
  Matches,
  IsOptional,
  IsInt,
  IsPositive,
  IsEnum,
} from 'class-validator';
import { PartialType } from '@nestjs/mapped-types';
import { Type } from 'class-transformer';
import { Status } from '../enums/status.enum';

export class CreateDepartmentDto {
  @Type(() => Number)
  @IsInt()
  @IsPositive()
  campusId: number;

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

  @Type(() => Number)
  @IsOptional()
  @IsInt()
  @IsPositive()
  headOfDepartmentId?: number;

  @IsOptional()
  @IsString()
  description?: string;

  @IsOptional()
  @IsEnum(Status)
  status?: Status;
}

export class UpdateDepartmentDto extends PartialType(CreateDepartmentDto) {}

export class DepartmentDto {
  id: number;
  campusId: number;
  name: string;
  code: string;
  headOfDepartmentId: number;
  description: string;
  status: Status;
  createdAt: Date;
  updatedAt: Date;
  campusName?: string;
  headName?: string;
  headEmail?: string;
  programCount?: number;
}
