import {
  Column,
  CreateDateColumn,
  Entity,
  Index,
  JoinColumn,
  ManyToOne,
  OneToMany,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';
import type { Relation } from 'typeorm';
import { ExamDraftItem } from './exam-draft-item.entity';
import { ExamDraft } from './exam-draft.entity';

export enum ExamSectionAnswerPolicy {
  ANSWER_ALL = 'answer_all',
  ANSWER_ANY = 'answer_any',
}

@Entity('exam_draft_sections')
@Index(['draftId', 'sectionOrder'], { unique: true })
export class ExamDraftSection {
  @PrimaryGeneratedColumn({
    name: 'draft_section_id',
    type: 'bigint',
    unsigned: true,
  })
  id: number;

  @Column({ name: 'draft_id', type: 'bigint', unsigned: true })
  draftId: number;

  @Column({ name: 'title', type: 'varchar', length: 255 })
  title: string;

  @Column({ name: 'instructions', type: 'text', nullable: true })
  instructions: string | null;

  @Column({ name: 'section_order', type: 'int', unsigned: true })
  sectionOrder: number;

  @Column({
    name: 'total_marks',
    type: 'decimal',
    precision: 10,
    scale: 2,
    nullable: true,
  })
  totalMarks: number | null;

  @Column({
    name: 'answer_policy',
    type: 'enum',
    enum: ExamSectionAnswerPolicy,
    default: ExamSectionAnswerPolicy.ANSWER_ALL,
  })
  answerPolicy: ExamSectionAnswerPolicy;

  @Column({
    name: 'required_answer_count',
    type: 'int',
    unsigned: true,
    nullable: true,
  })
  requiredAnswerCount: number | null;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  @ManyToOne(() => ExamDraft, (draft) => draft.sections, {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'draft_id' })
  draft: Relation<ExamDraft>;

  @OneToMany(() => ExamDraftItem, (item) => item.section)
  items: Relation<ExamDraftItem[]>;
}
