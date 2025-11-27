import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
  CreateDateColumn,
  Index,
} from 'typeorm';
import { DayOfWeek, ScheduleType } from '../enums';
import { CourseSection } from './course-section.entity';

@Entity('course_schedules')
@Index(['sectionId'])
@Index(['dayOfWeek', 'building', 'room'])
export class CourseSchedule {
  @PrimaryGeneratedColumn('increment', {
    name: 'schedule_id',
    type: 'bigint',
  })
  id: number;

  @Column({
    type: 'bigint',
    nullable: false,
    name: 'section_id',
  })
  sectionId: number;

  @Column({
    type: 'enum',
    enum: DayOfWeek,
    nullable: false,
    name: 'day_of_week',
  })
  dayOfWeek: DayOfWeek;

  @Column({
    type: 'time',
    nullable: false,
    name: 'start_time',
  })
  startTime: string;

  @Column({
    type: 'time',
    nullable: false,
    name: 'end_time',
  })
  endTime: string;

  @Column({
    type: 'varchar',
    length: 100,
    nullable: true,
    name: 'room',
  })
  room: string | null;

  @Column({
    type: 'varchar',
    length: 100,
    nullable: true,
    name: 'building',
  })
  building: string | null;

  @Column({
    type: 'enum',
    enum: ScheduleType,
    nullable: false,
    name: 'schedule_type',
  })
  scheduleType: ScheduleType;

  @CreateDateColumn({
    name: 'created_at',
  })
  createdAt: Date;

  @ManyToOne(() => CourseSection, (section) => section.schedules, {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'section_id' })
  section: CourseSection;
}
