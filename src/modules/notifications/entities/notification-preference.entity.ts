import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';

@Entity('notification_preferences')
export class NotificationPreference {
  @PrimaryGeneratedColumn('increment', { name: 'preference_id', type: 'bigint', unsigned: true })
  id: number;

  @Column({ name: 'user_id', type: 'bigint', unsigned: true, unique: true })
  userId: number;

  @Column({ name: 'email_enabled', type: 'tinyint', default: 1 })
  emailEnabled: boolean;

  @Column({ name: 'push_enabled', type: 'tinyint', default: 1 })
  pushEnabled: boolean;

  @Column({ name: 'sms_enabled', type: 'tinyint', default: 0 })
  smsEnabled: boolean;

  @Column({ name: 'announcement_email', type: 'tinyint', default: 1 })
  announcementEmail: boolean;

  @Column({ name: 'grade_email', type: 'tinyint', default: 1 })
  gradeEmail: boolean;

  @Column({ name: 'assignment_email', type: 'tinyint', default: 1 })
  assignmentEmail: boolean;

  @Column({ name: 'message_email', type: 'tinyint', default: 1 })
  messageEmail: boolean;

  @Column({ name: 'deadline_reminder_days', type: 'int', default: 2 })
  deadlineReminderDays: number;

  @Column({ name: 'quiet_hours_start', type: 'time', nullable: true })
  quietHoursStart: string;

  @Column({ name: 'quiet_hours_end', type: 'time', nullable: true })
  quietHoursEnd: string;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;
}
