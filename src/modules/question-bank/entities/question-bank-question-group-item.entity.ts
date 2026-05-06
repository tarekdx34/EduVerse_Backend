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
import { QuestionBankQuestionGroup } from './question-bank-question-group.entity';

@Entity('question_bank_question_group_items')
@Index(['groupId', 'questionId'], { unique: true })
@Index(['groupId', 'itemOrder'], { unique: true })
export class QuestionBankQuestionGroupItem {
  @PrimaryGeneratedColumn({
    name: 'group_item_id',
    type: 'bigint',
    unsigned: true,
  })
  id: number;

  @Column({ name: 'group_id', type: 'bigint', unsigned: true })
  groupId: number;

  @Column({ name: 'question_id', type: 'bigint', unsigned: true })
  questionId: number;

  @Column({ name: 'item_order', type: 'int', unsigned: true, default: 0 })
  itemOrder: number;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @ManyToOne(() => QuestionBankQuestionGroup, (group) => group.items, {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'group_id' })
  group: Relation<QuestionBankQuestionGroup>;

  @ManyToOne(() => QuestionBankQuestion, (question) => question.groupItems, {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'question_id' })
  question: Relation<QuestionBankQuestion>;
}
