import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
  Index,
} from 'typeorm';
import type { Relation } from 'typeorm';
import { SubmissionStatus } from '../enums';
import type { Assignment } from './assignment.entity';
import type { User } from '../../auth/entities/user.entity';
import type { File } from '../../files/entities/file.entity';

@Entity('assignment_submissions')
@Index(['assignmentId'])
@Index(['userId'])
@Index(['fileId'])
export class AssignmentSubmission {
  @PrimaryGeneratedColumn('increment', {
    name: 'submission_id',
    type: 'bigint',
  })
  id: number;

  @Column({
    type: 'bigint',
    nullable: false,
    name: 'assignment_id',
  })
  assignmentId: number;

  @Column({
    type: 'bigint',
    nullable: false,
    name: 'user_id',
  })
  userId: number;

  @Column({
    type: 'text',
    nullable: true,
    name: 'submission_text',
  })
  submissionText: string | null;

  @Column({
    type: 'varchar',
    length: 500,
    nullable: true,
    name: 'submission_link',
  })
  submissionLink: string | null;

  @Column({
    type: 'bigint',
    nullable: true,
    name: 'file_id',
  })
  fileId: number | null;

  @Column({
    type: 'enum',
    enum: SubmissionStatus,
    default: SubmissionStatus.SUBMITTED,
    name: 'status',
  })
  submissionStatus: SubmissionStatus;

  @Column({
    type: 'tinyint',
    width: 1,
    default: 0,
    name: 'is_late',
  })
  isLate: number;

  @Column({
    type: 'int',
    default: 1,
    name: 'attempt_number',
  })
  attemptNumber: number;

  @Column({
    type: 'timestamp',
    nullable: false,
    name: 'submitted_at',
  })
  submittedAt: Date;

  @Column({
    type: 'decimal',
    precision: 5,
    scale: 2,
    nullable: true,
    name: 'score',
  })
  score: number | null;

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

  @ManyToOne('Assignment', 'submissions', {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'assignment_id' })
  assignment: Relation<Assignment>;

  @ManyToOne('User', {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'user_id' })
  user: Relation<User>;

  @ManyToOne('File', {
    onDelete: 'SET NULL',
  })
  @JoinColumn({ name: 'file_id' })
  file: Relation<File> | null;

  @ManyToOne('User', {
    onDelete: 'SET NULL',
    nullable: true,
  })
  @JoinColumn({ name: 'graded_by' })
  grader: Relation<User> | null;
}
