import {
  Column,
  CreateDateColumn,
  Entity,
  Index,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
} from 'typeorm';
import type { Relation } from 'typeorm';
import type { File } from '../../files/entities/file.entity';
import { Exam } from './exam.entity';

export enum ExamExportFormat {
  HTML_DOC = 'html_doc',
  DOCX = 'docx',
  PDF = 'pdf',
}

export enum ExamExportStatus {
  PENDING = 'pending',
  COMPLETED = 'completed',
  FAILED = 'failed',
}

@Entity('exam_exports')
@Index(['examId', 'createdAt'])
export class ExamExport {
  @PrimaryGeneratedColumn({ name: 'export_id', type: 'bigint', unsigned: true })
  id: number;

  @Column({ name: 'exam_id', type: 'bigint', unsigned: true })
  examId: number;

  @Column({ name: 'format', type: 'enum', enum: ExamExportFormat })
  format: ExamExportFormat;

  @Column({
    name: 'status',
    type: 'enum',
    enum: ExamExportStatus,
    default: ExamExportStatus.PENDING,
  })
  status: ExamExportStatus;

  @Column({ name: 'file_id', type: 'bigint', unsigned: true, nullable: true })
  fileId: number | null;

  @Column({ name: 'requested_by', type: 'bigint', unsigned: true })
  requestedBy: number;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @Column({ name: 'completed_at', type: 'datetime', nullable: true })
  completedAt: Date | null;

  @Column({ name: 'failure_reason', type: 'text', nullable: true })
  failureReason: string | null;

  @ManyToOne(() => Exam, (exam) => exam.exports, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'exam_id' })
  exam: Relation<Exam>;

  @ManyToOne('File', { nullable: true, onDelete: 'SET NULL' })
  @JoinColumn({ name: 'file_id', referencedColumnName: 'fileId' })
  file: Relation<File> | null;
}
