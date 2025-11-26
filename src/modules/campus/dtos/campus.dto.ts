import {
  IsString,
  IsNotEmpty,
  Length,
  Matches,
  IsOptional,
  IsEnum,
} from 'class-validator';
import { PartialType } from '@nestjs/mapped-types';
import { Status } from '../enums/status.enum';

export class CreateCampusDto {
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

  @IsOptional()
  @IsString()
  address?: string;

  @IsOptional()
  @IsString()
  city?: string;

  @IsOptional()
  @IsString()
  country?: string;

  @IsOptional()
  @Matches(/^[\d\s\-\+\(\)\.]+$/, {
    message: 'Invalid phone format',
  })
  phone?: string;

  @IsOptional()
  @IsString()
  email?: string;

  @IsOptional()
  @IsString()
  timezone?: string;

  @IsOptional()
  @IsEnum(Status)
  status?: Status;
}

export class UpdateCampusDto extends PartialType(CreateCampusDto) {}

export class CampusDto {
  id: number;
  name: string;
  code: string;
  address: string;
  city: string;
  country: string;
  phone: string;
  email: string;
  timezone: string;
  status: Status;
  createdAt: Date;
  updatedAt: Date;
  departmentCount?: number;
}
