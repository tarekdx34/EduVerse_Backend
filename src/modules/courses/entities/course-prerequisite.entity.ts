import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
  CreateDateColumn,
  Index,
  Unique,
} from 'typeorm';
import { Course } from './course.entity';

@Entity('course_prerequisites')
@Unique(['courseId', 'prerequisiteCourseId'])
export class CoursePrerequisite {
  @PrimaryGeneratedColumn('increment', {
    name: 'prerequisite_id',
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
    name: 'prerequisite_course_id',
  })
  prerequisiteCourseId: number;

  @Column({
    type: 'boolean',
    default: true,
    name: 'is_mandatory',
  })
  isMandatory: boolean;

  @CreateDateColumn({
    name: 'created_at',
  })
  createdAt: Date;

  @ManyToOne(() => Course, (course) => course.prerequisites, {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'course_id' })
  course: Course;

  @ManyToOne(() => Course, {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'prerequisite_course_id' })
  prerequisiteCourse: Course;
}
