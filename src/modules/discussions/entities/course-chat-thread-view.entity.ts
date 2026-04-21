import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
  Unique,
} from 'typeorm';
import { User } from '../../auth/entities/user.entity';
import { CourseChatThread } from './course-chat-thread.entity';

@Entity('course_chat_thread_views')
@Unique(['threadId', 'userId'])
export class CourseChatThreadView {
  @PrimaryGeneratedColumn('increment', { type: 'bigint', unsigned: true })
  id: number;

  @Column({ name: 'thread_id', type: 'bigint', unsigned: true })
  threadId: number;

  @Column({ name: 'user_id', type: 'bigint', unsigned: true })
  userId: number;

  @CreateDateColumn({ name: 'viewed_at' })
  viewedAt: Date;

  @ManyToOne(() => CourseChatThread, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'thread_id' })
  thread: CourseChatThread;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'user_id' })
  user: User;
}
