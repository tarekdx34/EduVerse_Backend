import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
} from 'typeorm';

@Entity('scheduled_notifications')
export class ScheduledNotification {
  @PrimaryGeneratedColumn('increment', { name: 'scheduled_id', type: 'bigint', unsigned: true })
  id: number;

  @Column({ name: 'user_id', type: 'bigint', unsigned: true })
  userId: number;

  @Column({ name: 'notification_type', type: 'varchar', length: 50 })
  notificationType: string;

  @Column({ name: 'title', type: 'varchar', length: 255 })
  title: string;

  @Column({ name: 'body', type: 'text' })
  body: string;

  @Column({ name: 'scheduled_for', type: 'timestamp' })
  scheduledFor: Date;

  @Column({ name: 'status', type: 'enum', enum: ['pending', 'sent', 'failed', 'cancelled'], default: 'pending' })
  status: string;

  @Column({ name: 'created_by', type: 'bigint', unsigned: true })
  createdBy: number;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @Column({ name: 'sent_at', type: 'timestamp', nullable: true })
  sentAt: Date;
}
