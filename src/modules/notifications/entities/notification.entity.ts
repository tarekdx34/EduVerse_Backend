import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { User } from '../../auth/entities/user.entity';

@Entity('notifications')
export class Notification {
  @PrimaryGeneratedColumn('increment', { name: 'notification_id', type: 'bigint', unsigned: true })
  id: number;

  @Column({ name: 'user_id', type: 'bigint', unsigned: true })
  userId: number;

  @Column({ name: 'notification_type', type: 'enum', enum: ['announcement', 'grade', 'assignment', 'message', 'deadline', 'system'] })
  notificationType: string;

  @Column({ name: 'title', type: 'varchar', length: 255 })
  title: string;

  @Column({ name: 'body', type: 'text' })
  body: string;

  @Column({ name: 'related_entity_type', type: 'varchar', length: 50, nullable: true })
  relatedEntityType: string;

  @Column({ name: 'related_entity_id', type: 'bigint', unsigned: true, nullable: true })
  relatedEntityId: number;

  @Column({ name: 'announcement_id', type: 'bigint', unsigned: true, nullable: true })
  announcementId: number;

  @Column({ name: 'is_read', type: 'tinyint', default: 0 })
  isRead: boolean;

  @Column({ name: 'read_at', type: 'timestamp', nullable: true })
  readAt: Date;

  @Column({ name: 'priority', type: 'enum', enum: ['low', 'medium', 'high', 'urgent'], default: 'medium' })
  priority: string;

  @Column({ name: 'action_url', type: 'varchar', length: 500, nullable: true })
  actionUrl: string;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'user_id' })
  user: User;
}
