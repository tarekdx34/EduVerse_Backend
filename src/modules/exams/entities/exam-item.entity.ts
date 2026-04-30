import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import type { Relation } from 'typeorm';
import { QuestionBankQuestion } from '../../question-bank/entities/question-bank-question.entity';
import { Exam } from './exam.entity';

@Entity('exam_items')
export class ExamItem {
  @PrimaryGeneratedColumn({ name: 'exam_item_id', type: 'bigint', unsigned: true })
  id: number;

  @Column({ name: 'exam_id', type: 'bigint', unsigned: true })
  examId: number;

  @Column({ name: 'question_id', type: 'bigint', unsigned: true })
  questionId: number;

  @Column({ name: 'weight', type: 'decimal', precision: 7, scale: 2 })
  weight: number;

  @Column({ name: 'item_order', type: 'int', unsigned: true })
  itemOrder: number;

  @ManyToOne(() => Exam, (exam) => exam.items, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'exam_id' })
  exam: Relation<Exam>;

  @ManyToOne(() => QuestionBankQuestion, { onDelete: 'RESTRICT' })
  @JoinColumn({ name: 'question_id' })
  question: Relation<QuestionBankQuestion>;
}

