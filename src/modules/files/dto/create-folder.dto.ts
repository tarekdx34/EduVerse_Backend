import {
  IsString,
  IsNotEmpty,
  MinLength,
  MaxLength,
  IsOptional,
  IsNumber,
} from 'class-validator';

export class CreateFolderDto {
  @IsString()
  @IsNotEmpty({ message: 'Folder name is required' })
  @MinLength(1, { message: 'Folder name must be at least 1 character' })
  @MaxLength(255, { message: 'Folder name cannot exceed 255 characters' })
  folderName: string;

  @IsOptional()
  @IsNumber()
  parentFolderId?: number;

  @IsOptional()
  @IsNumber()
  courseId?: number;

  @IsOptional()
  @IsNumber()
  userId?: number;
}

