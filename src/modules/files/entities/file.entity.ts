import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  DeleteDateColumn,
  ManyToOne,
  OneToMany,
  JoinColumn,
  Index,
} from 'typeorm';
import { Folder } from './folder.entity';
import { FileVersion } from './file-version.entity';
import { FilePermission } from './file-permission.entity';
import { User } from '../../auth/entities/user.entity';

@Entity('files')
@Index(['folderId'])
@Index(['uploadedBy'])
@Index(['courseId'])
export class File {
  @PrimaryGeneratedColumn({ name: 'file_id', type: 'bigint' })
  fileId: number;

  @Column({ name: 'file_name', type: 'varchar', length: 255, nullable: false })
  fileName: string;

  @Column({ name: 'original_file_name', type: 'varchar', length: 255, nullable: false })
  originalFileName: string;

  @Column({ name: 'file_path', type: 'text', nullable: false })
  filePath: string;

  @Column({ name: 'file_size', type: 'bigint', nullable: false })
  fileSize: number;

  @Column({ name: 'mime_type', type: 'varchar', length: 100, nullable: false })
  mimeType: string;

  @Column({ name: 'folder_id', type: 'bigint', nullable: true })
  folderId?: number;

  @ManyToOne(() => Folder, (folder) => folder.files, { nullable: true })
  @JoinColumn({ name: 'folder_id' })
  folder?: Folder;

  @Column({ name: 'uploaded_by', type: 'bigint', nullable: false })
  uploadedBy: number;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'uploaded_by' })
  uploader: User;

  @Column({ name: 'course_id', type: 'bigint', nullable: true })
  courseId?: number;

  @OneToMany(() => FileVersion, (version) => version.file)
  versions: FileVersion[];

  @OneToMany(() => FilePermission, (permission) => permission.file)
  permissions: FilePermission[];

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  @DeleteDateColumn({ name: 'deleted_at', nullable: true })
  deletedAt?: Date;
}

