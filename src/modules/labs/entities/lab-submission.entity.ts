import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { Lab } from './lab.entity';

@Entity('lab_submissions')
export class LabSubmission {
  @PrimaryGeneratedColumn('increment', { name: 'submission_id', type: 'bigint', unsigned: true })
  id: number;

  @Column({ name: 'lab_id', type: 'bigint', unsigned: true })
  labId: number;

  @Column({ name: 'user_id', type: 'bigint', unsigned: true })
  userId: number;

  @Column({ name: 'file_id', type: 'bigint', unsigned: true, nullable: true })
  fileId: number;

  @Column({ name: 'submission_text', type: 'text', nullable: true })
  submissionText: string;

  @Column({ name: 'submitted_at', type: 'timestamp', default: () => 'CURRENT_TIMESTAMP' })
  submittedAt: Date;

  @Column({ name: 'is_late', type: 'tinyint', default: 0 })
  isLate: boolean;

  @Column({ name: 'status', type: 'enum', enum: ['submitted', 'graded', 'returned', 'resubmit'], default: 'submitted' })
  status: string;

  @ManyToOne(() => Lab, (lab) => lab.submissions)
  @JoinColumn({ name: 'lab_id' })
  lab: Lab;
}
