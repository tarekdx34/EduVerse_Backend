import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
  CreateDateColumn,
} from 'typeorm';
import { User } from '../../auth/entities/user.entity';
import { StudentTask } from './student-task.entity';

export enum ReminderType {
  EMAIL = 'email',
  PUSH = 'push',
  SMS = 'sms',
  IN_APP = 'in_app',
}

export enum ReminderStatus {
  PENDING = 'pending',
  SENT = 'sent',
  FAILED = 'failed',
}

@Entity('deadline_reminders')
export class DeadlineReminder {
  @PrimaryGeneratedColumn({ name: 'reminder_id', type: 'bigint', unsigned: true })
  reminderId: number;

  @Column({ name: 'task_id', type: 'bigint', unsigned: true })
  taskId: number;

  @Column({ name: 'user_id', type: 'bigint', unsigned: true })
  userId: number;

  @Column({ name: 'reminder_time', type: 'timestamp' })
  reminderTime: Date;

  @Column({
    name: 'reminder_type',
    type: 'enum',
    enum: ReminderType,
    default: ReminderType.IN_APP,
  })
  reminderType: ReminderType;

  @Column({ name: 'status', type: 'enum', enum: ReminderStatus, default: ReminderStatus.PENDING })
  status: ReminderStatus;

  @Column({ name: 'sent_at', type: 'timestamp', nullable: true })
  sentAt: Date | null;

  @CreateDateColumn({ name: 'created_at', type: 'timestamp' })
  createdAt: Date;

  @ManyToOne(() => StudentTask)
  @JoinColumn({ name: 'task_id' })
  task: StudentTask;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'user_id' })
  user: User;
}
