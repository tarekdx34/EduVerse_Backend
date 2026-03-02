import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
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
export class File {
  @PrimaryGeneratedColumn({ name: 'file_id', type: 'bigint' })
  fileId: number;

  @Column({ name: 'file_name', type: 'varchar', length: 255, nullable: false })
  fileName: string;

  @Column({ name: 'original_filename', type: 'varchar', length: 255, nullable: false })
  originalFileName: string;

  @Column({ name: 'file_path', type: 'varchar', length: 500, nullable: false })
  filePath: string;

  @Column({ name: 'file_size', type: 'bigint', nullable: true })
  fileSize: number;

  @Column({ name: 'mime_type', type: 'varchar', length: 100, nullable: true })
  mimeType: string;

  @Column({ name: 'file_extension', type: 'varchar', length: 10, nullable: true })
  fileExtension?: string;

  @Column({ name: 'uploaded_by', type: 'bigint', nullable: false })
  uploadedBy: number;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'uploaded_by' })
  uploader: User;

  @Column({ name: 'folder_id', type: 'bigint', nullable: true })
  folderId?: number;

  @ManyToOne(() => Folder, (folder) => folder.files, { nullable: true })
  @JoinColumn({ name: 'folder_id' })
  folder?: Folder;

  @Column({ name: 'checksum', type: 'varchar', length: 64, nullable: true })
  checksum?: string;

  @Column({ name: 'download_count', type: 'int', default: 0 })
  downloadCount: number;

  @Column({ name: 'is_public', type: 'tinyint', default: 0 })
  isPublic: number;

  @Column({ name: 'status', type: 'enum', enum: ['active', 'processing', 'archived', 'deleted'], default: 'active' })
  status: string;

  @OneToMany(() => FileVersion, (version) => version.file)
  versions: FileVersion[];

  @OneToMany(() => FilePermission, (permission) => permission.file)
  permissions: FilePermission[];

  @Column({ name: 'uploaded_at', type: 'timestamp', default: () => 'CURRENT_TIMESTAMP' })
  uploadedAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  @DeleteDateColumn({ name: 'deleted_at', nullable: true })
  deletedAt?: Date;
}

