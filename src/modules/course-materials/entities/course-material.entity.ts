import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
  CreateDateColumn,
  UpdateDateColumn,
  Index,
} from 'typeorm';
import type { Relation } from 'typeorm';
import type { Course } from '../../courses/entities/course.entity';
import type { File } from '../../files/entities/file.entity';
import type { User } from '../../auth/entities/user.entity';
import { MaterialType } from '../enums';

@Entity('course_materials')
@Index(['courseId'])
@Index(['uploadedBy'])
@Index(['materialType'])
@Index(['weekNumber'])
export class CourseMaterial {
  @PrimaryGeneratedColumn({
    name: 'material_id',
    type: 'bigint',
    unsigned: true,
  })
  materialId: number;

  @Column({
    name: 'course_id',
    type: 'bigint',
    unsigned: true,
  })
  courseId: number;

  @ManyToOne('Course', { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'course_id' })
  course: Relation<Course>;

  @Column({
    name: 'file_id',
    type: 'bigint',
    unsigned: true,
    nullable: true,
  })
  fileId: number | null;

  @ManyToOne('File', { onDelete: 'SET NULL', nullable: true })
  @JoinColumn({ name: 'file_id' })
  file: Relation<File> | null;

  @Column({
    name: 'drive_file_id',
    type: 'bigint',
    unsigned: true,
    nullable: true,
    comment: 'FK to drive_files table for Google Drive integration',
  })
  driveFileId: number | null;

  @Column({
    name: 'material_type',
    type: 'enum',
    enum: MaterialType,
    default: MaterialType.DOCUMENT,
  })
  materialType: MaterialType;

  @Column({
    name: 'title',
    type: 'varchar',
    length: 255,
  })
  title: string;

  @Column({
    name: 'description',
    type: 'text',
    nullable: true,
  })
  description: string | null;

  @Column({
    name: 'external_url',
    type: 'varchar',
    length: 500,
    nullable: true,
  })
  externalUrl: string | null;

  @Column({
    name: 'youtube_video_id',
    type: 'varchar',
    length: 50,
    nullable: true,
  })
  youtubeVideoId: string | null;

  @Column({
    name: 'order_index',
    type: 'int',
    default: 0,
  })
  orderIndex: number;

  @Column({
    name: 'week_number',
    type: 'int',
    nullable: true,
  })
  weekNumber: number | null;

  @Column({
    name: 'view_count',
    type: 'int',
    default: 0,
  })
  viewCount: number;

  @Column({
    name: 'download_count',
    type: 'int',
    default: 0,
  })
  downloadCount: number;

  @Column({
    name: 'uploaded_by',
    type: 'bigint',
    unsigned: true,
  })
  uploadedBy: number;

  @ManyToOne('User', { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'uploaded_by' })
  uploader: Relation<User>;

  @Column({
    name: 'is_published',
    type: 'tinyint',
    default: 0,
  })
  isPublished: boolean;

  @Column({
    name: 'published_at',
    type: 'timestamp',
    nullable: true,
  })
  publishedAt: Date | null;

  @CreateDateColumn({
    name: 'created_at',
  })
  createdAt: Date;

  @UpdateDateColumn({
    name: 'updated_at',
  })
  updatedAt: Date;
}
