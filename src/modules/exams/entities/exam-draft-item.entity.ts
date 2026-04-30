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

  @Column({ name: 'item_order', type: 'int', unsigned: true })
  itemOrder: number;

  @ManyToOne(() => ExamDraft, (draft) => draft.items, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'draft_id' })
  draft: Relation<ExamDraft>;

  @ManyToOne(() => QuestionBankQuestion, { onDelete: 'RESTRICT' })
  @JoinColumn({ name: 'question_id' })
  question: Relation<QuestionBankQuestion>;
}

