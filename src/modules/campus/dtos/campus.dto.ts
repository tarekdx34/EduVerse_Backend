import {
  IsString,
  IsNotEmpty,
  Length,
  Matches,
  IsOptional,
  IsEnum,
} from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { PartialType } from '@nestjs/swagger';
import { Status } from '../enums/status.enum';

export class CreateCampusDto {
  @ApiProperty({
    description: 'Campus name',
    example: 'Main Campus',
    minLength: 1,
    maxLength: 100,
  })
  @IsString()
  @IsNotEmpty()
  @Length(1, 100)
  name: string;

  @ApiProperty({
    description: 'Campus code (2-20 uppercase alphanumeric)',
    example: 'MAIN01',
    pattern: '^[A-Z0-9]{2,20}$',
  })
  @IsString()
  @IsNotEmpty()
  @Matches(/^[A-Z0-9]{2,20}$/, {
    message: 'Code must be 2-20 uppercase alphanumeric characters',
  })
  code: string;

  @ApiPropertyOptional({
    description: 'Campus address',
    example: '123 University Ave',
  })
  @IsOptional()
  @IsString()
  address?: string;

  @ApiPropertyOptional({
    description: 'City',
    example: 'Cairo',
  })
  @IsOptional()
  @IsString()
  city?: string;

  @ApiPropertyOptional({
    description: 'Country',
    example: 'Egypt',
  })
  @IsOptional()
  @IsString()
  country?: string;

  @ApiPropertyOptional({
    description: 'Phone number',
    example: '+20 123 456 7890',
  })
  @IsOptional()
  @Matches(/^[\d\s\-\+\(\)\.]+$/, {
    message: 'Invalid phone format',
  })
  phone?: string;

  @ApiPropertyOptional({
    description: 'Campus email',
    example: 'main@university.edu',
  })
  @IsOptional()
  @IsString()
  email?: string;

  @ApiPropertyOptional({
    description: 'Timezone',
    example: 'Africa/Cairo',
  })
  @IsOptional()
  @IsString()
  timezone?: string;

  @ApiPropertyOptional({
    description: 'Campus status',
    enum: Status,
    example: Status.ACTIVE,
  })
  @IsOptional()
  @IsEnum(Status)
  status?: Status;
}

export class UpdateCampusDto extends PartialType(CreateCampusDto) {}

export class CampusDto {
  @ApiProperty({ example: 1 })
  id: number;

  @ApiProperty({ example: 'Main Campus' })
  name: string;

  @ApiProperty({ example: 'MAIN01' })
  code: string;

  @ApiProperty({ example: '123 University Ave' })
  address: string;

  @ApiProperty({ example: 'Cairo' })
  city: string;

  @ApiProperty({ example: 'Egypt' })
  country: string;

  @ApiProperty({ example: '+20 123 456 7890' })
  phone: string;

  @ApiProperty({ example: 'main@university.edu' })
  email: string;

  @ApiProperty({ example: 'Africa/Cairo' })
  timezone: string;

  @ApiProperty({ enum: Status, example: Status.ACTIVE })
  status: Status;

  @ApiProperty({ example: '2024-01-15T10:30:00Z' })
  createdAt: Date;

  @ApiProperty({ example: '2024-01-15T10:30:00Z' })
  updatedAt: Date;

  @ApiPropertyOptional({ example: 5 })
  departmentCount?: number;
}
