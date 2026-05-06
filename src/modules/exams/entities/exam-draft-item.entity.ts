import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
  Index,
} from 'typeorm';
import type { Relation } from 'typeorm';
import { BloomLevel, QuestionBankDifficulty, QuestionBankType } from '../../question-bank/enums/question-bank.enums';
import { QuestionBankQuestion } from '../../question-bank/entities/question-bank-question.entity';
import { ExamDraftSection } from './exam-draft-section.entity';
import { ExamDraft } from './exam-draft.entity';

@Entity('exam_draft_items')
@Index(['draftId', 'itemOrder'])
export class ExamDraftItem {
  @PrimaryGeneratedColumn({ name: 'draft_item_id', type: 'bigint', unsigned: true })
  id: number;

  @Column({ name: 'draft_id', type: 'bigint', unsigned: true })
  draftId: number;

  @Column({ name: 'question_id', type: 'bigint', unsigned: true })
  questionId: number;

  @Column({
    name: 'draft_section_id',
    type: 'bigint',
    unsigned: true,
    nullable: true,
  })
  draftSectionId: number | null;

  @Column({ name: 'chapter_id', type: 'bigint', unsigned: true })
  chapterId: number;

  @Column({ name: 'question_type', type: 'enum', enum: QuestionBankType })
  questionType: QuestionBankType;

  @Column({ name: 'difficulty', type: 'enum', enum: QuestionBankDifficulty })
  difficulty: QuestionBankDifficulty;

  @Column({ name: 'bloom_level', type: 'enum', enum: BloomLevel })
  bloomLevel: BloomLevel;

  @Column({ name: 'weight', type: 'decimal', precision: 7, scale: 2 })
  weight: number;

  @Column({
    name: 'weight_units',
    type: 'decimal',
    precision: 7,
    scale: 2,
    nullable: true,
  })
  weightUnits: number | null;

  @Column({
    name: 'marks',
    type: 'decimal',
    precision: 7,
    scale: 2,
    nullable: true,
  })
  marks: number | null;

  @Column({ name: 'item_order', type: 'int', unsigned: true })
  itemOrder: number;

  @Column({
    name: 'source_group_id',
    type: 'bigint',
    unsigned: true,
    nullable: true,
  })
  sourceGroupId: number | null;

  @Column({
    name: 'source_group_item_order',
    type: 'int',
    unsigned: true,
    nullable: true,
  })
  sourceGroupItemOrder: number | null;

  @Column({ name: 'override_reason', type: 'text', nullable: true })
  overrideReason: string | null;

  @Column({ name: 'origin_rule_json', type: 'json', nullable: true })
  originRuleJson: Record<string, unknown> | null;

  @ManyToOne(() => ExamDraft, (draft) => draft.items, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'draft_id' })
  draft: Relation<ExamDraft>;

  @ManyToOne(() => QuestionBankQuestion, { onDelete: 'RESTRICT' })
  @JoinColumn({ name: 'question_id' })
  question: Relation<QuestionBankQuestion>;

  @ManyToOne(() => ExamDraftSection, (section) => section.items, {
    nullable: true,
    onDelete: 'SET NULL',
  })
  @JoinColumn({ name: 'draft_section_id' })
  section: Relation<ExamDraftSection> | null;
}

