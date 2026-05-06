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
import { QuestionBankQuestion } from './question-bank-question.entity';

@Entity('question_bank_question_versions')
@Index(['questionId', 'versionNumber'], { unique: true })
export class QuestionBankQuestionVersion {
  @PrimaryGeneratedColumn({ name: 'version_id', type: 'bigint', unsigned: true })
  id: number;

  @Column({ name: 'question_id', type: 'bigint', unsigned: true })
  questionId: number;

  @Column({ name: 'version_number', type: 'int', unsigned: true })
  versionNumber: number;

  @Column({ name: 'snapshot_json', type: 'json' })
  snapshotJson: Record<string, unknown>;

  @Column({ name: 'created_by', type: 'bigint', unsigned: true })
  createdBy: number;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @ManyToOne(() => QuestionBankQuestion, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'question_id' })
  question: Relation<QuestionBankQuestion>;
}
