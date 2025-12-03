import { Expose } from 'class-transformer';

@Expose()
export class FolderResponseDto {
  @Expose()
  folderId: number;

  @Expose()
  folderName: string;

  @Expose()
  parentFolderId?: number;

  @Expose()
  courseId?: number;

  @Expose()
  userId?: number;

  @Expose()
  createdAt: Date;

  @Expose()
  children?: FolderResponseDto[];

  @Expose()
  fileCount?: number;
}
