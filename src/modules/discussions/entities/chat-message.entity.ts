import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { CourseChatThread } from './course-chat-thread.entity';

@Entity('chat_messages')
export class ChatMessage {
  @PrimaryGeneratedColumn('increment', { name: 'message_id', type: 'bigint', unsigned: true })
  id: number;

  @Column({ name: 'thread_id', type: 'bigint', unsigned: true })
  threadId: number;

  @Column({ name: 'user_id', type: 'bigint', unsigned: true })
  userId: number;

  @Column({ name: 'message_text', type: 'text' })
  messageText: string;

  @Column({ name: 'parent_message_id', type: 'bigint', unsigned: true, nullable: true })
  parentMessageId: number;

  @Column({ name: 'is_answer', type: 'tinyint', default: 0 })
  isAnswer: boolean;

  @Column({ name: 'is_endorsed', type: 'tinyint', default: 0 })
  isEndorsed: boolean;

  @Column({ name: 'endorsed_by', type: 'bigint', unsigned: true, nullable: true })
  endorsedBy: number | null;

  @Column({ name: 'upvote_count', type: 'int', default: 0 })
  upvoteCount: number;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  // Relations
  @ManyToOne(() => CourseChatThread, (t) => t.messages)
  @JoinColumn({ name: 'thread_id' })
  thread: CourseChatThread;
}
