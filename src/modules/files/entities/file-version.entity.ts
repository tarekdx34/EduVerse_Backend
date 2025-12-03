import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
  Index,
} from 'typeorm';
import { File } from './file.entity';
import { User } from '../../auth/entities/user.entity';

@Entity('file_versions')
@Index(['fileId'])
export class FileVersion {
  @PrimaryGeneratedColumn({ name: 'version_id', type: 'bigint' })
  versionId: number;

  @Column({ name: 'file_id', type: 'bigint', nullable: false })
  fileId: number;

  @ManyToOne(() => File, (file) => file.versions, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'file_id' })
  file: File;

  @Column({ name: 'version_number', type: 'int', nullable: false })
  versionNumber: number;

  @Column({ name: 'file_path', type: 'text', nullable: false })
  filePath: string;

  @Column({ name: 'file_size', type: 'bigint', nullable: false })
  fileSize: number;

  @Column({ name: 'uploaded_by', type: 'bigint', nullable: false })
  uploadedBy: number;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'uploaded_by' })
  uploader: User;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;
}

