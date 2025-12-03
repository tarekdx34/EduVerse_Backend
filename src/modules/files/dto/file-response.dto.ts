import { Exclude, Expose } from 'class-transformer';

@Expose()
export class FileResponseDto {
  @Expose()
  fileId: number;

  @Expose()
  fileName: string;

  @Expose()
  originalFileName: string;

  @Expose()
  fileSize: number;

  @Expose()
  mimeType: string;

  @Expose()
  folderId?: number;

  @Expose()
  courseId?: number;

  @Expose()
  uploadedBy: number;

  @Expose()
  uploaderName?: string;

  @Expose()
  createdAt: Date;

  @Expose()
  versionCount?: number;
}

