import { IsOptional, IsNumber, IsString } from 'class-validator';

export class UploadFileDto {
  @IsOptional()
  @IsNumber()
  folderId?: number;

  @IsOptional()
  @IsNumber()
  courseId?: number;

  @IsOptional()
  @IsString()
  description?: string;
}

