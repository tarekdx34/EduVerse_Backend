import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  OneToMany,
  JoinColumn,
} from 'typeorm';
import type { Relation } from 'typeorm';

@Entity('messages')
export class Message {
  @PrimaryGeneratedColumn('increment', { name: 'message_id', type: 'bigint', unsigned: true })
  id: number;

  @Column({ name: 'sender_id', type: 'bigint', unsigned: true })
  senderId: number;

  @Column({ name: 'subject', type: 'varchar', length: 255, nullable: true })
  subject: string | null;

  @Column({ name: 'body', type: 'text', nullable: true })
  body: string | null;

  @Column({ name: 'message_type', type: 'enum', enum: ['direct', 'group', 'announcement'] })
  messageType: string;

  @Column({ name: 'parent_message_id', type: 'bigint', unsigned: true, nullable: true })
  parentMessageId: number;

  @Column({ name: 'reply_to_id', type: 'bigint', unsigned: true, nullable: true })
  replyToId: number | null;

  @Column({ name: 'read_status', type: 'tinyint', default: 0 })
  readStatus: boolean;

  @Column({ name: 'sent_at', type: 'timestamp', default: () => 'CURRENT_TIMESTAMP' })
  sentAt: Date;

  @Column({ name: 'edited_at', type: 'timestamp', nullable: true })
  editedAt: Date | null;

  // Relations
  @ManyToOne('Message', 'replies', { nullable: true })
  @JoinColumn({ name: 'parent_message_id' })
  parentMessage: Relation<Message>;

  @OneToMany('Message', 'parentMessage')
  replies: Relation<Message>[];

  @ManyToOne('Message', { nullable: true })
  @JoinColumn({ name: 'reply_to_id' })
  replyTo: Relation<Message>;

  @OneToMany('MessageParticipant', 'message')
  participants: Relation<MessageParticipant>[];
}

import type { MessageParticipant } from './message-participant.entity';
