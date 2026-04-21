import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
  Index,
} from 'typeorm';
import type { Relation } from 'typeorm';
import type { File } from './file.entity';
import type { User } from '../../auth/entities/user.entity';

@Entity('file_versions')
@Index(['fileId'])
export class FileVersion {
  @PrimaryGeneratedColumn({ name: 'version_id', type: 'bigint' })
  versionId: number;

  @Column({ name: 'file_id', type: 'bigint', unsigned: true, nullable: false })
  fileId: number;

  @ManyToOne('File', 'versions', { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'file_id' })
  file: Relation<File>;

  @Column({ name: 'version_number', type: 'int', nullable: false })
  versionNumber: number;

  @Column({ name: 'file_path', type: 'varchar', length: 500, nullable: false })
  filePath: string;

  @Column({ name: 'file_size', type: 'bigint', nullable: true })
  fileSize: number;

  @Column({ name: 'uploaded_by', type: 'bigint', unsigned: true, nullable: false })
  uploadedBy: number;

  @ManyToOne('User')
  @JoinColumn({ name: 'uploaded_by' })
  uploader: Relation<User>;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;
}

