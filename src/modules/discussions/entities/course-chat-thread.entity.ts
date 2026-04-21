import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  OneToMany,
  JoinColumn,
} from 'typeorm';
import type { Relation } from 'typeorm';
import type { User } from '../../auth/entities/user.entity';
import type { Course } from '../../courses/entities/course.entity';

@Entity('course_chat_threads')
export class CourseChatThread {
  @PrimaryGeneratedColumn('increment', { name: 'thread_id', type: 'bigint', unsigned: true })
  id: number;

  @Column({ name: 'course_id', type: 'bigint', unsigned: true })
  courseId: number;

  @Column({ name: 'created_by', type: 'bigint', unsigned: true })
  createdBy: number;

  @Column({ name: 'title', type: 'varchar', length: 255 })
  title: string;

  @Column({ name: 'description', type: 'text', nullable: true })
  description: string;

  @Column({ name: 'is_pinned', type: 'tinyint', default: 0 })
  isPinned: boolean;

  @Column({ name: 'is_locked', type: 'tinyint', default: 0 })
  isLocked: boolean;

  @Column({ name: 'view_count', type: 'int', default: 0 })
  viewCount: number;

  @Column({ name: 'reply_count', type: 'int', default: 0 })
  replyCount: number;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  // Relations
  @OneToMany('ChatMessage', 'thread')
  messages: Relation<ChatMessage>[];

  @ManyToOne('Course', { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'course_id' })
  course: Relation<Course>;

  @ManyToOne('User', { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'created_by' })
  creator: Relation<User>;
}

import type { ChatMessage } from './chat-message.entity';
