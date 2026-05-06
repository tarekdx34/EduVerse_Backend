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
import { QuestionBankStatus } from '../enums/question-bank.enums';
import { QuestionBankQuestion } from './question-bank-question.entity';

@Entity('question_bank_review_events')
@Index(['questionId', 'createdAt'])
export class QuestionBankReviewEvent {
  @PrimaryGeneratedColumn({ name: 'review_event_id', type: 'bigint', unsigned: true })
  id: number;

  @Column({ name: 'question_id', type: 'bigint', unsigned: true })
  questionId: number;

  @Column({
    name: 'from_status',
    type: 'enum',
    enum: QuestionBankStatus,
    nullable: true,
  })
  fromStatus: QuestionBankStatus | null;

  @Column({ name: 'to_status', type: 'enum', enum: QuestionBankStatus })
  toStatus: QuestionBankStatus;

  @Column({ name: 'comment', type: 'text', nullable: true })
  comment: string | null;

  @Column({ name: 'created_by', type: 'bigint', unsigned: true })
  createdBy: number;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @ManyToOne(() => QuestionBankQuestion, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'question_id' })
  question: Relation<QuestionBankQuestion>;
}
