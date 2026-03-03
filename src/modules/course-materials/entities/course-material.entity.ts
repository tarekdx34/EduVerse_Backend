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
import { Course } from '../../courses/entities/course.entity';
import { File } from '../../files/entities/file.entity';
import { User } from '../../auth/entities/user.entity';
import { MaterialType } from '../enums';

@Entity('course_materials')
@Index(['courseId'])
@Index(['uploadedBy'])
@Index(['materialType'])
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

  @ManyToOne(() => Course, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'course_id' })
  course: Course;

  @Column({
    name: 'file_id',
    type: 'bigint',
    unsigned: true,
    nullable: true,
  })
  fileId: number | null;

  @ManyToOne(() => File, { onDelete: 'SET NULL', nullable: true })
  @JoinColumn({ name: 'file_id' })
  file: File | null;

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
    name: 'order_index',
    type: 'int',
    default: 0,
  })
  orderIndex: number;

  @Column({
    name: 'uploaded_by',
    type: 'bigint',
    unsigned: true,
  })
  uploadedBy: number;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'uploaded_by' })
  uploader: User;

  @Column({
    name: 'is_published',
    type: 'tinyint',
    default: 1,
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
