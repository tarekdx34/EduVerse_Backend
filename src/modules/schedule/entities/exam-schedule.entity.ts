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
import type { Course } from '../../courses/entities/course.entity';
import type { Semester } from '../../campus/entities/semester.entity';
import { ExamType, EventStatus } from '../enums';

@Entity('exam_schedules')
@Index(['courseId'])
@Index(['semesterId'])
@Index(['examDate'])
export class ExamSchedule {
  @PrimaryGeneratedColumn({
    name: 'exam_id',
    type: 'bigint',
    unsigned: true,
  })
  examId: number;

  @Column({
    name: 'course_id',
    type: 'bigint',
    unsigned: true,
  })
  courseId: number;

  @ManyToOne('Course', { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'course_id' })
  course: Relation<Course>;

  @Column({
    name: 'semester_id',
    type: 'bigint',
    unsigned: true,
  })
  semesterId: number;

  @ManyToOne('Semester', { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'semester_id' })
  semester: Relation<Semester>;

  @Column({
    name: 'exam_type',
    type: 'enum',
    enum: ExamType,
  })
  examType: ExamType;

  @Column({
    name: 'title',
    type: 'varchar',
    length: 255,
    nullable: true,
  })
  title: string | null;

  @Column({
    name: 'exam_date',
    type: 'date',
  })
  examDate: string;

  @Column({
    name: 'start_time',
    type: 'time',
  })
  startTime: string;

  @Column({
    name: 'duration_minutes',
    type: 'int',
  })
  durationMinutes: number;

  @Column({
    name: 'location',
    type: 'varchar',
    length: 255,
    nullable: true,
  })
  location: string | null;

  @Column({
    name: 'instructions',
    type: 'text',
    nullable: true,
  })
  instructions: string | null;

  @Column({
    name: 'status',
    type: 'enum',
    enum: ['scheduled', 'in_progress', 'completed', 'cancelled', 'postponed'],
    default: 'scheduled',
  })
  status: string;

  @CreateDateColumn({
    name: 'created_at',
  })
  createdAt: Date;

  @UpdateDateColumn({
    name: 'updated_at',
  })
  updatedAt: Date;
}
