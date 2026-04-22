import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import type { Relation } from 'typeorm';
import type { Lab } from './lab.entity';
import type { User } from '../../auth/entities/user.entity';
import type { File } from '../../files/entities/file.entity';

@Entity('lab_submissions')
export class LabSubmission {
  @PrimaryGeneratedColumn('increment', { name: 'submission_id', type: 'bigint', unsigned: true })
  id: number;

  @Column({ name: 'lab_id', type: 'bigint', unsigned: true })
  labId: number;

  @Column({ name: 'user_id', type: 'bigint', unsigned: true })
  userId: number;

  @Column({ name: 'file_id', type: 'bigint', unsigned: true, nullable: true })
  fileId: number | null;

  @Column({ name: 'submission_text', type: 'text', nullable: true })
  submissionText: string;

  @Column({ name: 'submitted_at', type: 'timestamp', default: () => 'CURRENT_TIMESTAMP' })
  submittedAt: Date;

  @Column({ name: 'is_late', type: 'tinyint', default: 0 })
  isLate: boolean;

  @Column({ name: 'status', type: 'enum', enum: ['submitted', 'graded', 'returned', 'resubmit'], default: 'submitted' })
  status: string;

  @Column({ name: 'score', type: 'decimal', precision: 5, scale: 2, nullable: true })
  score: number | null;

  @Column({ name: 'feedback', type: 'text', nullable: true })
  feedback: string | null;

  @Column({ name: 'graded_by', type: 'bigint', unsigned: true, nullable: true })
  gradedBy: number | null;

  @Column({ name: 'graded_at', type: 'timestamp', nullable: true })
  gradedAt: Date | null;

  @ManyToOne('Lab', 'submissions')
  @JoinColumn({ name: 'lab_id' })
  lab: Relation<Lab>;

  @ManyToOne('User', { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'user_id' })
  user: Relation<User>;

  @ManyToOne('File', { onDelete: 'SET NULL', nullable: true })
  @JoinColumn({ name: 'file_id' })
  file: Relation<File>;

  @ManyToOne('User', { onDelete: 'SET NULL', nullable: true })
  @JoinColumn({ name: 'graded_by' })
  grader: Relation<User> | null;
}
