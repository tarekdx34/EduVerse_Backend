import {
  IsString,
  IsNotEmpty,
  MinLength,
  MaxLength,
  IsOptional,
  IsNumber,
} from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateFolderDto {
  @ApiProperty({
    description: 'Folder name',
    example: 'Lecture Notes',
    minLength: 1,
    maxLength: 255,
  })
  @IsString()
  @IsNotEmpty({ message: 'Folder name is required' })
  @MinLength(1, { message: 'Folder name must be at least 1 character' })
  @MaxLength(255, { message: 'Folder name cannot exceed 255 characters' })
  folderName: string;

  @ApiPropertyOptional({ description: 'Parent folder ID (null for root)', example: 1 })
  @IsOptional()
  @IsNumber()
  parentFolderId?: number;

  @ApiPropertyOptional({ description: 'Course ID to associate folder with', example: 1 })
  @IsOptional()
  @IsNumber()
  courseId?: number;

  @ApiPropertyOptional({ description: 'Owner user ID (defaults to current user)' })
  @IsOptional()
  @IsNumber()
  userId?: number;
}
