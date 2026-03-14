// src/modules/google-drive/entities/drive-file.entity.ts
import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
  Index,
} from 'typeorm';
import { User } from '../../auth/entities/user.entity';
import { DriveFolder } from './drive-folder.entity';

export enum DriveFileEntityType {
  COURSE_MATERIAL = 'course_material',
  LAB_INSTRUCTION = 'lab_instruction',
  LAB_TA_MATERIAL = 'lab_ta_material',
  LAB_SUBMISSION = 'lab_submission',
  ASSIGNMENT_INSTRUCTION = 'assignment_instruction',
  ASSIGNMENT_SUBMISSION = 'assignment_submission',
  PROJECT_INSTRUCTION = 'project_instruction',
  PROJECT_TA_MATERIAL = 'project_ta_material',
  PROJECT_SUBMISSION = 'project_submission',
}

@Entity('drive_files')
@Index(['entityType', 'entityId'])
@Index(['driveFolderId'])
export class DriveFile {
  @PrimaryGeneratedColumn({ name: 'drive_file_id', type: 'bigint', unsigned: true })
  driveFileId: number;

  @Column({ name: 'drive_id', type: 'varchar', length: 100, unique: true })
  driveId: string;

  @Column({ name: 'drive_folder_id', type: 'bigint', unsigned: true })
  driveFolderId: number;

  @Column({ name: 'local_file_id', type: 'bigint', unsigned: true, nullable: true })
  localFileId: number | null;

  @Column({ name: 'file_name', type: 'varchar', length: 255 })
  fileName: string;

  @Column({ name: 'original_file_name', type: 'varchar', length: 255 })
  originalFileName: string;

  @Column({ name: 'mime_type', type: 'varchar', length: 100 })
  mimeType: string;

  @Column({ name: 'file_size', type: 'bigint', unsigned: true })
  fileSize: number;

  @Column({ name: 'web_view_link', type: 'varchar', length: 500, nullable: true })
  webViewLink: string | null;

  @Column({ name: 'web_content_link', type: 'varchar', length: 500, nullable: true })
  webContentLink: string | null;

  @Column({ name: 'thumbnail_link', type: 'varchar', length: 500, nullable: true })
  thumbnailLink: string | null;

  @Column({
    name: 'entity_type',
    type: 'enum',
    enum: DriveFileEntityType,
    nullable: true,
  })
  entityType: DriveFileEntityType | null;

  @Column({ name: 'entity_id', type: 'bigint', unsigned: true, nullable: true })
  entityId: number | null;

  @Column({ name: 'version_number', type: 'int', default: 1 })
  versionNumber: number;

  @Column({ name: 'uploaded_by', type: 'bigint', unsigned: true })
  uploadedBy: number;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  // Relations
  @ManyToOne(() => DriveFolder, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'drive_folder_id' })
  folder: DriveFolder;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'uploaded_by', referencedColumnName: 'userId' })
  uploader: User;
}
