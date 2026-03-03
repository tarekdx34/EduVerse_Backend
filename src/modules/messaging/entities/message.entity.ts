import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  OneToMany,
  JoinColumn,
} from 'typeorm';

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

  @Column({ name: 'read_status', type: 'tinyint', default: 0 })
  readStatus: boolean;

  @Column({ name: 'sent_at', type: 'timestamp', default: () => 'CURRENT_TIMESTAMP' })
  sentAt: Date;

  // Relations
  @ManyToOne(() => Message, (m) => m.replies, { nullable: true })
  @JoinColumn({ name: 'parent_message_id' })
  parentMessage: Message;

  @OneToMany(() => Message, (m) => m.parentMessage)
  replies: Message[];

  @OneToMany(() => MessageParticipant, (mp) => mp.message)
  participants: MessageParticipant[];
}

import { MessageParticipant } from './message-participant.entity';
