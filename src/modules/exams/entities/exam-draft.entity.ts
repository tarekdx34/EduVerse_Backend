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
}

