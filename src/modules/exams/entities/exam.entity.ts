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
import { ExamExport } from './exam-export.entity';
import { ExamItem } from './exam-item.entity';
import { ExamSection } from './exam-section.entity';

export enum ExamStatus {
  DRAFT = 'draft',
  PUBLISHED = 'published',
  ARCHIVED = 'archived',
}

@Entity('exams')
export class Exam {
  @PrimaryGeneratedColumn({ name: 'exam_id', type: 'bigint', unsigned: true })
  id: number;

  @Column({ name: 'course_id', type: 'bigint', unsigned: true })
  courseId: number;

  @Column({ name: 'title', type: 'varchar', length: 255 })
  title: string;

  @Column({ name: 'total_weight', type: 'decimal', precision: 10, scale: 2, default: 0 })
  totalWeight: number;

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

  @Column({ name: 'status', type: 'enum', enum: ExamStatus, default: ExamStatus.DRAFT })
  status: ExamStatus;

  @Column({ name: 'snapshot_json', type: 'json' })
  snapshotJson: Record<string, unknown>;

  @Column({ name: 'created_by', type: 'bigint', unsigned: true })
  createdBy: number;

  @Column({ name: 'published_by', type: 'bigint', unsigned: true, nullable: true })
  publishedBy: number | null;

  @Column({ name: 'published_at', type: 'datetime', nullable: true })
  publishedAt: Date | null;

  @Column({ name: 'archived_by', type: 'bigint', unsigned: true, nullable: true })
  archivedBy: number | null;

  @Column({ name: 'archived_at', type: 'datetime', nullable: true })
  archivedAt: Date | null;

  @Column({ name: 'status_reason', type: 'text', nullable: true })
  statusReason: string | null;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  @ManyToOne('Course', { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'course_id' })
  course: Relation<Course>;

  @OneToMany(() => ExamItem, (item) => item.exam, { cascade: true })
  items: Relation<ExamItem[]>;

  @OneToMany(() => ExamSection, (section) => section.exam, { cascade: true })
  sections: Relation<ExamSection[]>;

  @OneToMany(() => ExamExport, (examExport) => examExport.exam)
  exports: Relation<ExamExport[]>;
}

