import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  OneToMany,
  JoinColumn,
  Index,
} from 'typeorm';
import type { Relation } from 'typeorm';
import type { File } from './file.entity';
import type { User } from '../../auth/entities/user.entity';

@Entity('folders')
@Index(['parentFolderId'])
@Index(['createdBy'])
export class Folder {
  @PrimaryGeneratedColumn({ name: 'folder_id', type: 'bigint' })
  folderId: number;

  @Column({ name: 'folder_name', type: 'varchar', length: 255, nullable: false })
  folderName: string;

  @Column({ name: 'parent_folder_id', type: 'bigint', nullable: true })
  parentFolderId?: number;

  @ManyToOne('Folder', 'children', { nullable: true })
  @JoinColumn({ name: 'parent_folder_id' })
  parentFolder?: Relation<Folder>;

  @OneToMany('Folder', 'parentFolder')
  children: Relation<Folder>[];

  @Column({ name: 'created_by', type: 'bigint', unsigned: true, nullable: false })
  createdBy: number;

  @ManyToOne('User', { nullable: false })
  @JoinColumn({ name: 'created_by' })
  user?: Relation<User>;

  @Column({ name: 'path', type: 'text', nullable: true })
  path?: string;

  @Column({ name: 'level', type: 'int', default: 0 })
  level: number;

  @Column({ name: 'is_system_folder', type: 'tinyint', default: 0 })
  isSystemFolder: number;

  @OneToMany('File', 'folder')
  files: Relation<File>[];

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;
}

