import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
  CreateDateColumn,
  Index,
} from 'typeorm';
import type { Relation } from 'typeorm';
import { ProcessingStatus } from '../enums';
import type { AttendanceSession } from './attendance-session.entity';
import type { AttendancePhoto } from './attendance-photo.entity';
import type { User } from '../../auth/entities/user.entity';

@Entity('ai_attendance_processing')
@Index(['sessionId'])
@Index(['photoId'])
@Index(['status'])
export class AiAttendanceProcessing {
  @PrimaryGeneratedColumn('increment', {
    name: 'processing_id',
    type: 'bigint',
  })
  id: number;

  @Column({
    type: 'bigint',
    nullable: false,
    name: 'session_id',
  })
  sessionId: number;

  @Column({
    type: 'bigint',
    nullable: false,
    name: 'photo_id',
  })
  photoId: number;

  @Column({
    type: 'enum',
    enum: ProcessingStatus,
    default: ProcessingStatus.PENDING,
    name: 'status',
  })
  status: ProcessingStatus;

  @Column({
    type: 'int',
    default: 0,
    name: 'detected_faces_count',
  })
  detectedFacesCount: number;

  @Column({
    type: 'int',
    default: 0,
    name: 'matched_students_count',
  })
  matchedStudentsCount: number;

  @Column({
    type: 'int',
    default: 0,
    name: 'unmatched_faces_count',
  })
  unmatchedFacesCount: number;

  @Column({
    type: 'longtext',
    nullable: true,
    name: 'unmatched_faces_data',
  })
  unmatchedFacesData: string | null;

  @Column({
    type: 'longtext',
    nullable: true,
    name: 'confidence_scores',
  })
  confidenceScores: string | null;

  @Column({
    type: 'int',
    nullable: true,
    name: 'processing_time_ms',
  })
  processingTimeMs: number | null;

  @Column({
    type: 'text',
    nullable: true,
    name: 'error_message',
  })
  errorMessage: string | null;

  @Column({
    type: 'tinyint',
    default: 0,
    name: 'manual_review_required',
  })
  manualReviewRequired: number;

  @Column({
    type: 'bigint',
    unsigned: true,
    nullable: true,
    name: 'reviewed_by',
  })
  reviewedBy: number | null;

  @Column({
    type: 'timestamp',
    nullable: true,
    name: 'reviewed_at',
  })
  reviewedAt: Date | null;

  @CreateDateColumn({
    name: 'created_at',
  })
  createdAt: Date;

  @Column({
    type: 'timestamp',
    nullable: true,
    name: 'completed_at',
  })
  completedAt: Date | null;

  @ManyToOne('AttendanceSession', {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'session_id' })
  session: Relation<AttendanceSession>;

  @ManyToOne('AttendancePhoto', {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'photo_id' })
  photo: Relation<AttendancePhoto>;

  @ManyToOne('User', {
    onDelete: 'SET NULL',
  })
  @JoinColumn({ name: 'reviewed_by' })
  reviewer: Relation<User>;
}
