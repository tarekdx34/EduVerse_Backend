import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import type { Relation } from 'typeorm';
import { QuestionBankQuestion } from './question-bank-question.entity';

@Entity('question_bank_fill_blanks')
export class QuestionBankFillBlank {
  @PrimaryGeneratedColumn({ name: 'blank_id', type: 'bigint', unsigned: true })
  id: number;

  @Column({ name: 'question_id', type: 'bigint', unsigned: true })
  questionId: number;

  @Column({ name: 'blank_key', type: 'varchar', length: 100 })
  blankKey: string;

  @Column({ name: 'acceptable_answer', type: 'text' })
  acceptableAnswer: string;

  @Column({ name: 'is_case_sensitive', type: 'tinyint', width: 1, default: 0 })
  isCaseSensitive: number;

  @ManyToOne(() => QuestionBankQuestion, (question) => question.fillBlanks, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'question_id' })
  question: Relation<QuestionBankQuestion>;
}

