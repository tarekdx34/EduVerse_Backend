import { Exclude, Expose } from 'class-transformer';

@Expose()
export class FileVersionResponseDto {
  @Expose()
  versionId: number;

  @Expose()
  fileId: number;

  @Expose()
  versionNumber: number;

  @Expose()
  fileSize: number;

  @Expose()
  uploadedBy: number;

  @Expose()
  uploaderName?: string;

  @Expose()
  createdAt: Date;
}

