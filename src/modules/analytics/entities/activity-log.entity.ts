import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
  CreateDateColumn,
} from 'typeorm';
import { User } from '../../auth/entities/user.entity';

export enum ActivityType {
  LOGIN = 'login',
  LOGOUT = 'logout',
  VIEW = 'view',
  SUBMIT = 'submit',
  DOWNLOAD = 'download',
  UPLOAD = 'upload',
  CHAT = 'chat',
  QUIZ = 'quiz',
  OTHER = 'other',
}

@Entity('activity_logs')
export class ActivityLog {
  @PrimaryGeneratedColumn({
    name: 'log_id',
    type: 'bigint',
    unsigned: true,
  })
  logId: number;

  @Column({ name: 'user_id', type: 'bigint', unsigned: true })
  userId: number;

  @Column({ name: 'activity_type', type: 'enum', enum: ActivityType })
  activityType: ActivityType;

  @Column({
    name: 'entity_type',
    type: 'varchar',
    length: 50,
    nullable: true,
  })
  entityType: string;

  @Column({
    name: 'entity_id',
    type: 'bigint',
    unsigned: true,
    nullable: true,
  })
  entityId: number;

  @Column({ name: 'description', type: 'text', nullable: true })
  description: string;

  @Column({ name: 'ip_address', type: 'varchar', length: 45, nullable: true })
  ipAddress: string;

  @Column({ name: 'user_agent', type: 'text', nullable: true })
  userAgent: string;

  @Column({
    name: 'session_duration_minutes',
    type: 'int',
    nullable: true,
  })
  sessionDurationMinutes: number;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'user_id' })
  user: User;
}
