import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
  CreateDateColumn,
  UpdateDateColumn,
  Index,
} from 'typeorm';
import type { Relation } from 'typeorm';
import type { User } from '../../auth/entities/user.entity';
import type { Course } from '../../courses/entities/course.entity';
import type { CourseSchedule } from '../../courses/entities/course-schedule.entity';
import { EventType, EventStatus } from '../enums';

@Entity('calendar_events')
@Index(['userId'])
@Index(['courseId'])
@Index(['startTime'])
@Index(['eventType'])
export class CalendarEvent {
  @PrimaryGeneratedColumn({
    name: 'event_id',
    type: 'bigint',
    unsigned: true,
  })
  eventId: number;

  @Column({
    name: 'user_id',
    type: 'bigint',
    unsigned: true,
  })
  userId: number;

  @ManyToOne('User', { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'user_id' })
  user: Relation<User>;

  @Column({
    name: 'course_id',
    type: 'bigint',
    unsigned: true,
    nullable: true,
  })
  courseId: number | null;

  @ManyToOne('Course', { onDelete: 'CASCADE', nullable: true })
  @JoinColumn({ name: 'course_id' })
  course: Relation<Course> | null;

  @Column({
    name: 'event_type',
    type: 'enum',
    enum: EventType,
  })
  eventType: EventType;

  @Column({
    name: 'title',
    type: 'varchar',
    length: 255,
  })
  title: string;

  @Column({
    name: 'description',
    type: 'text',
    nullable: true,
  })
  description: string | null;

  @Column({
    name: 'location',
    type: 'varchar',
    length: 255,
    nullable: true,
  })
  location: string | null;

  @Column({
    name: 'color',
    type: 'varchar',
    length: 7,
    nullable: true,
  })
  color: string | null;

  @Column({
    name: 'start_time',
    type: 'datetime',
    nullable: true,
  })
  startTime: Date | null;

  @Column({
    name: 'end_time',
    type: 'datetime',
    nullable: true,
  })
  endTime: Date | null;

  @Column({
    name: 'schedule_id',
    type: 'bigint',
    unsigned: true,
    nullable: true,
  })
  scheduleId: number | null;

  @ManyToOne('CourseSchedule', { onDelete: 'CASCADE', nullable: true })
  @JoinColumn({ name: 'schedule_id' })
  schedule: Relation<CourseSchedule> | null;

  @Column({
    name: 'exam_id',
    type: 'bigint',
    unsigned: true,
    nullable: true,
  })
  examId: number | null;

  @Column({
    name: 'is_recurring',
    type: 'tinyint',
    default: 0,
  })
  isRecurring: boolean;

  @Column({
    name: 'recurrence_pattern',
    type: 'varchar',
    length: 100,
    nullable: true,
  })
  recurrencePattern: string | null;

  @Column({
    name: 'reminder_minutes',
    type: 'int',
    default: 30,
  })
  reminderMinutes: number;

  @Column({
    name: 'status',
    type: 'enum',
    enum: EventStatus,
    default: EventStatus.SCHEDULED,
  })
  status: EventStatus;

  @CreateDateColumn({
    name: 'created_at',
  })
  createdAt: Date;

  @UpdateDateColumn({
    name: 'updated_at',
  })
  updatedAt: Date;
}
