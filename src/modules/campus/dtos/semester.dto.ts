import {
  IsString,
  IsNotEmpty,
  Length,
  Matches,
  IsOptional,
  IsDateString,
} from 'class-validator';
import { PartialType } from '@nestjs/mapped-types';
import { Type } from 'class-transformer';
import { SemesterStatus } from '../enums/semester-status.enum';

export class CreateSemesterDto {
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

  @Type(() => Date)
  @IsDateString()
  startDate: string;

  @Type(() => Date)
  @IsDateString()
  endDate: string;

  @Type(() => Date)
  @IsDateString()
  registrationStart: string;

  @Type(() => Date)
  @IsDateString()
  registrationEnd: string;
}

export class UpdateSemesterDto extends PartialType(CreateSemesterDto) {}

export class SemesterDto {
  id: number;
  name: string;
  code: string;
  startDate: Date;
  endDate: Date;
  registrationStart: Date;
  registrationEnd: Date;
  status: SemesterStatus;
  createdAt: Date;
}
