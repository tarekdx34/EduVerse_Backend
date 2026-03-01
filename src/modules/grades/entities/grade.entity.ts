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
import { GradeType } from '../enums';
import { User } from '../../auth/entities/user.entity';
import { Course } from '../../courses/entities/course.entity';
import { Assignment } from '../../assignments/entities/assignment.entity';

@Entity('grades')
@Index(['userId', 'courseId'])
@Index(['courseId', 'gradeType'])
export class Grade {
  @PrimaryGeneratedColumn('increment', {
    name: 'grade_id',
    type: 'bigint',
  })
  id: number;

  @Column({
    type: 'bigint',
    nullable: false,
    name: 'user_id',
  })
  userId: number;

  @Column({
    type: 'bigint',
    nullable: false,
    name: 'course_id',
  })
  courseId: number;

  @Column({
    type: 'enum',
    enum: GradeType,
    nullable: false,
    name: 'grade_type',
  })
  gradeType: GradeType;

  @Column({
    type: 'bigint',
    nullable: true,
    name: 'assignment_id',
  })
  assignmentId: number | null;

  @Column({
    type: 'bigint',
    nullable: true,
    name: 'quiz_id',
  })
  quizId: number | null;

  @Column({
    type: 'bigint',
    nullable: true,
    name: 'lab_id',
  })
  labId: number | null;

  @Column({
    type: 'decimal',
    precision: 5,
    scale: 2,
    nullable: false,
    name: 'score',
  })
  score: number;

  @Column({
    type: 'decimal',
    precision: 5,
    scale: 2,
    nullable: false,
    name: 'max_score',
  })
  maxScore: number;

  @Column({
    type: 'decimal',
    precision: 5,
    scale: 2,
    nullable: true,
    name: 'percentage',
  })
  percentage: number | null;

  @Column({
    type: 'varchar',
    length: 5,
    nullable: true,
    name: 'letter_grade',
  })
  letterGrade: string | null;

  @Column({
    type: 'text',
    nullable: true,
    name: 'feedback',
  })
  feedback: string | null;

  @Column({
    type: 'bigint',
    nullable: true,
    name: 'graded_by',
  })
  gradedBy: number | null;

  @Column({
    type: 'timestamp',
    nullable: true,
    name: 'graded_at',
  })
  gradedAt: Date | null;

  @Column({
    type: 'tinyint',
    width: 1,
    default: 0,
    name: 'is_published',
  })
  isPublished: number;

  @CreateDateColumn({
    name: 'created_at',
  })
  createdAt: Date;

  @UpdateDateColumn({
    name: 'updated_at',
  })
  updatedAt: Date;

  @ManyToOne(() => User, {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'user_id' })
  user: User;

  @ManyToOne(() => Course, {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'course_id' })
  course: Course;

  @ManyToOne(() => Assignment, {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'assignment_id' })
  assignment: Assignment;

  @ManyToOne(() => User, {
    onDelete: 'SET NULL',
  })
  @JoinColumn({ name: 'graded_by' })
  grader: User;
}
