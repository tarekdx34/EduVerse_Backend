import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  OneToMany,
  JoinColumn,
  CreateDateColumn,
  UpdateDateColumn,
  Index,
  Unique,
} from 'typeorm';
import { SectionStatus } from '../enums';
import { Course } from './course.entity';
import { CourseSchedule } from './course-schedule.entity';
import { Semester } from '../../campus/entities/semester.entity';

@Entity('course_sections')
@Unique(['courseId', 'semesterId', 'sectionNumber'])
@Index(['courseId', 'semesterId'])
@Index(['semesterId', 'status'])
export class CourseSection {
  @PrimaryGeneratedColumn('increment', {
    name: 'section_id',
    type: 'bigint',
  })
  id: number;

  @Column({
    type: 'bigint',
    nullable: false,
    name: 'course_id',
  })
  courseId: number;

  @Column({
    type: 'bigint',
    nullable: false,
    name: 'semester_id',
  })
  semesterId: number;

  @Column({
    type: 'varchar',
    length: 50,
    nullable: false,
    name: 'section_number',
  })
  sectionNumber: string;

  @Column({
    type: 'int',
    nullable: false,
    name: 'max_capacity',
  })
  maxCapacity: number;

  @Column({
    type: 'int',
    default: 0,
    name: 'current_enrollment',
  })
  currentEnrollment: number;

  @Column({
    type: 'varchar',
    length: 255,
    nullable: true,
    name: 'location',
  })
  location: string | null;

  @Column({
    type: 'enum',
    enum: SectionStatus,
    default: SectionStatus.OPEN,
    name: 'status',
  })
  status: SectionStatus;

  @CreateDateColumn({
    name: 'created_at',
  })
  createdAt: Date;

  @UpdateDateColumn({
    name: 'updated_at',
  })
  updatedAt: Date;

  @ManyToOne(() => Course, (course) => course.sections, {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'course_id' })
  course: Course;

  @ManyToOne(() => Semester, {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'semester_id' })
  semester: Semester;

  @OneToMany(() => CourseSchedule, (schedule) => schedule.section, {
    cascade: true,
  })
  schedules: CourseSchedule[];
}
