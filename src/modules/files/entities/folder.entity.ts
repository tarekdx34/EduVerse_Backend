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
import { File } from './file.entity';
import { User } from '../../auth/entities/user.entity';

@Entity('folders')
@Index(['parentFolderId'])
@Index(['courseId'])
@Index(['userId'])
export class Folder {
  @PrimaryGeneratedColumn({ name: 'folder_id', type: 'bigint' })
  folderId: number;

  @Column({ name: 'folder_name', type: 'varchar', length: 255, nullable: false })
  folderName: string;

  @Column({ name: 'parent_folder_id', type: 'bigint', nullable: true })
  parentFolderId?: number;

  @ManyToOne(() => Folder, (folder) => folder.children, { nullable: true })
  @JoinColumn({ name: 'parent_folder_id' })
  parentFolder?: Folder;

  @OneToMany(() => Folder, (folder) => folder.parentFolder)
  children: Folder[];

  @Column({ name: 'course_id', type: 'bigint', nullable: true })
  courseId?: number;

  @Column({ name: 'user_id', type: 'bigint', nullable: true })
  userId?: number;

  @ManyToOne(() => User, { nullable: true })
  @JoinColumn({ name: 'user_id' })
  user?: User;

  @OneToMany(() => File, (file) => file.folder)
  files: File[];

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  @DeleteDateColumn({ name: 'deleted_at', nullable: true })
  deletedAt?: Date;
}

