import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  OneToMany,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import type { Relation } from 'typeorm';
import type { Course } from '../../courses/entities/course.entity';
import { ExamDraftItem } from './exam-draft-item.entity';
import { ExamDraftSection } from './exam-draft-section.entity';

export enum ExamDraftStatus {
  OPEN = 'open',
  FINALIZED = 'finalized',
  EXPIRED = 'expired',
  CANCELLED = 'cancelled',
  FAILED = 'failed',
}

export enum ExamMarkDistributionMode {
  MANUAL = 'manual',
  WEIGHT_NORMALIZED = 'weight_normalized',
  EQUAL = 'equal',
}

export enum ExamRoundingPolicy {
  NONE = 'none',
  NEAREST_0_25 = 'nearest_0_25',
  NEAREST_0_5 = 'nearest_0_5',
  NEAREST_1 = 'nearest_1',
}

@Entity('exam_drafts')
export class ExamDraft {
  @PrimaryGeneratedColumn({ name: 'draft_id', type: 'bigint', unsigned: true })
  id: number;

  @Column({ name: 'course_id', type: 'bigint', unsigned: true })
  courseId: number;

  @Column({ name: 'title', type: 'varchar', length: 255 })
  title: string;

  @Column({ name: 'generation_request_json', type: 'json' })
  generationRequestJson: Record<string, unknown>;

  @Column({ name: 'generated_by', type: 'bigint', unsigned: true })
  generatedBy: number;

  @Column({ name: 'seed', type: 'varchar', length: 100 })
  seed: string;

  @Column({
    name: 'total_marks',
    type: 'decimal',
    precision: 10,
    scale: 2,
    nullable: true,
  })
  totalMarks: number | null;

  @Column({ name: 'duration_minutes', type: 'int', unsigned: true, nullable: true })
  durationMinutes: number | null;

  @Column({ name: 'instructions', type: 'text', nullable: true })
  instructions: string | null;

  @Column({ name: 'header_text', type: 'text', nullable: true })
  headerText: string | null;

  @Column({ name: 'footer_text', type: 'text', nullable: true })
  footerText: string | null;

  @Column({ name: 'student_name_line', type: 'tinyint', width: 1, default: 1 })
  studentNameLine: number;

  @Column({ name: 'show_course_code', type: 'tinyint', width: 1, default: 1 })
  showCourseCode: number;

  @Column({ name: 'page_break_per_section', type: 'tinyint', width: 1, default: 0 })
  pageBreakPerSection: number;

  @Column({ name: 'show_instructor_name', type: 'tinyint', width: 1, default: 0 })
  showInstructorName: number;

  @Column({ name: 'answer_key_style', type: 'varchar', length: 20, default: 'inline' })
  answerKeyStyle: string;

  @Column({ name: 'paper_template_id', type: 'bigint', unsigned: true, nullable: true })
  paperTemplateId: number | null;

  @Column({ name: 'paper_template_snapshot_json', type: 'json', nullable: true })
  paperTemplateSnapshotJson: Record<string, unknown> | null;

  @Column({
    name: 'mark_distribution_mode',
    type: 'enum',
    enum: ExamMarkDistributionMode,
    default: ExamMarkDistributionMode.WEIGHT_NORMALIZED,
  })
  markDistributionMode: ExamMarkDistributionMode;

  @Column({
    name: 'rounding_policy',
    type: 'enum',
    enum: ExamRoundingPolicy,
    default: ExamRoundingPolicy.NONE,
  })
  roundingPolicy: ExamRoundingPolicy;

  @Column({
    name: 'status',
    type: 'enum',
    enum: ExamDraftStatus,
    default: ExamDraftStatus.OPEN,
  })
  status: ExamDraftStatus;

  @Column({
    name: 'finalized_exam_id',
    type: 'bigint',
    unsigned: true,
    nullable: true,
  })
  finalizedExamId: number | null;

  @Column({ name: 'finalized_by', type: 'bigint', unsigned: true, nullable: true })
  finalizedBy: number | null;

  @Column({ name: 'finalized_at', type: 'datetime', nullable: true })
  finalizedAt: Date | null;

  @Column({ name: 'failure_reason', type: 'text', nullable: true })
  failureReason: string | null;

  @Column({ name: 'expires_at', type: 'datetime' })
  expiresAt: Date;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  @ManyToOne('Course', { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'course_id' })
  course: Relation<Course>;

  @OneToMany(() => ExamDraftItem, (item) => item.draft, { cascade: true })
  items: Relation<ExamDraftItem[]>;

  @OneToMany(() => ExamDraftSection, (section) => section.draft, {
    cascade: true,
  })
  sections: Relation<ExamDraftSection[]>;
}

