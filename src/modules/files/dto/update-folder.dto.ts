import {
  IsString,
  IsOptional,
  MinLength,
  MaxLength,
  IsNumber,
} from 'class-validator';

export class UpdateFolderDto {
  @IsOptional()
  @IsString()
  @MinLength(1, { message: 'Folder name must be at least 1 character' })
  @MaxLength(255, { message: 'Folder name cannot exceed 255 characters' })
  folderName?: string;

  @IsOptional()
  @IsNumber()
  parentFolderId?: number;
}

