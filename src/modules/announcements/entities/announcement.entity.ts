import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';
import { User } from '../../auth/entities/user.entity';
import { Course } from '../../courses/entities/course.entity';
import { AnnouncementType, AnnouncementPriority, TargetAudience } from '../enums';

@Entity('announcements')
export class Announcement {
  @PrimaryGeneratedColumn({ name: 'announcement_id', type: 'bigint', unsigned: true })
  id: number;

  @Column({ name: 'course_id', type: 'bigint', unsigned: true, nullable: true })
  courseId: number;

  @Column({ name: 'created_by', type: 'bigint', unsigned: true })
  createdBy: number;

  @Column({ length: 255 })
  title: string;

  @Column({ type: 'text' })
  content: string;

  @Column({
    name: 'announcement_type',
    type: 'enum',
    enum: AnnouncementType,
    default: AnnouncementType.COURSE,
  })
  announcementType: AnnouncementType;

  @Column({
    type: 'enum',
    enum: AnnouncementPriority,
    default: AnnouncementPriority.MEDIUM,
  })
  priority: AnnouncementPriority;

  @Column({
    name: 'target_audience',
    type: 'enum',
    enum: TargetAudience,
    default: TargetAudience.ALL,
  })
  targetAudience: TargetAudience;

  @Column({ name: 'is_published', type: 'tinyint', default: 0 })
  isPublished: boolean;

  @Column({ name: 'published_at', type: 'timestamp', nullable: true })
  publishedAt?: Date;

  @Column({ name: 'expires_at', type: 'timestamp', nullable: true })
  expiresAt?: Date;

  @Column({ name: 'attachment_file_id', type: 'bigint', unsigned: true, nullable: true })
  attachmentFileId?: number;

  @Column({ name: 'view_count', type: 'int', default: 0 })
  viewCount: number;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  // Relations
  @ManyToOne(() => User, { eager: true })
  @JoinColumn({ name: 'created_by' })
  author: User;

  @ManyToOne(() => Course, { eager: true, nullable: true })
  @JoinColumn({ name: 'course_id' })
  course: Course;
}
