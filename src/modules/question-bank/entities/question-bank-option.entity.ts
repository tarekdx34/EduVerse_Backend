import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
  Index,
} from 'typeorm';
import type { Relation } from 'typeorm';
import { QuestionBankQuestion } from './question-bank-question.entity';

@Entity('question_bank_options')
@Index(['questionId', 'optionOrder'])
export class QuestionBankOption {
  @PrimaryGeneratedColumn({ name: 'option_id', type: 'bigint', unsigned: true })
  id: number;

  @Column({ name: 'question_id', type: 'bigint', unsigned: true })
  questionId: number;

  @Column({ name: 'option_text', type: 'text' })
  optionText: string;

  @Column({ name: 'is_correct', type: 'tinyint', width: 1, default: 0 })
  isCorrect: number;

  @Column({ name: 'option_order', type: 'int', unsigned: true, default: 0 })
  optionOrder: number;

  @ManyToOne(() => QuestionBankQuestion, (question) => question.options, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'question_id' })
  question: Relation<QuestionBankQuestion>;
}

