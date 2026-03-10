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
} from 'typeorm';
import { SubmissionType, AssignmentStatus } from '../enums';
import { Course } from '../../courses/entities/course.entity';
import { User } from '../../auth/entities/user.entity';
import { AssignmentSubmission } from './assignment-submission.entity';

@Entity('assignments')
@Index(['courseId'])
@Index(['createdBy'])
@Index(['status'])
export class Assignment {
  @PrimaryGeneratedColumn('increment', {
    name: 'assignment_id',
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
    type: 'varchar',
    length: 255,
    nullable: false,
    name: 'title',
  })
  title: string;

  @Column({
    type: 'text',
    nullable: true,
    name: 'description',
  })
  description: string | null;

  @Column({
    type: 'text',
    nullable: true,
    name: 'instructions',
  })
  instructions: string | null;

  @Column({
    type: 'decimal',
    precision: 5,
    scale: 2,
    default: 100.0,
    name: 'max_score',
  })
  maxScore: number;

  @Column({
    type: 'decimal',
    precision: 5,
    scale: 2,
    default: 0.0,
    name: 'weight',
  })
  weight: number;

  @Column({
    type: 'timestamp',
    nullable: true,
    name: 'due_date',
  })
  dueDate: Date | null;

  @Column({
    type: 'timestamp',
    nullable: true,
    name: 'available_from',
  })
  availableFrom: Date | null;

  @Column({
    type: 'tinyint',
    width: 1,
    default: 0,
    name: 'late_submission_allowed',
  })
  lateSubmissionAllowed: number;

  @Column({
    type: 'decimal',
    precision: 5,
    scale: 2,
    default: 0.0,
    name: 'late_penalty_percent',
  })
  latePenaltyPercent: number;

  @Column({
    type: 'enum',
    enum: SubmissionType,
    default: SubmissionType.FILE,
    name: 'submission_type',
  })
  submissionType: SubmissionType;

  @Column({
    type: 'int',
    default: 10,
    name: 'max_file_size_mb',
  })
  maxFileSizeMb: number;

  @Column({
    type: 'longtext',
    nullable: true,
    name: 'allowed_file_types',
  })
  allowedFileTypes: string | null;

  @Column({
    type: 'enum',
    enum: AssignmentStatus,
    default: AssignmentStatus.DRAFT,
    name: 'status',
  })
  status: AssignmentStatus;

  @Column({
    type: 'bigint',
    nullable: false,
    name: 'created_by',
  })
  createdBy: number;

  @CreateDateColumn({
    name: 'created_at',
  })
  createdAt: Date;

  @UpdateDateColumn({
    name: 'updated_at',
  })
  updatedAt: Date;

  @ManyToOne(() => Course, {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'course_id' })
  course: Course;

  @ManyToOne(() => User, {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'created_by' })
  creator: User;

  @OneToMany(() => AssignmentSubmission, (submission) => submission.assignment)
  submissions: AssignmentSubmission[];
}
