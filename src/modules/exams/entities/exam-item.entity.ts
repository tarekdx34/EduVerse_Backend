import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  OneToOne,
  JoinColumn,
} from 'typeorm';
import type { Relation } from 'typeorm';
import { QuestionBankQuestion } from '../../question-bank/entities/question-bank-question.entity';
import { Exam } from './exam.entity';
import { ExamItemSnapshot } from './exam-item-snapshot.entity';
import { ExamSection } from './exam-section.entity';

@Entity('exam_items')
export class ExamItem {
  @PrimaryGeneratedColumn({ name: 'exam_item_id', type: 'bigint', unsigned: true })
  id: number;

  @Column({ name: 'exam_id', type: 'bigint', unsigned: true })
  examId: number;

  @Column({ name: 'question_id', type: 'bigint', unsigned: true })
  questionId: number;

  @Column({ name: 'section_id', type: 'bigint', unsigned: true, nullable: true })
  sectionId: number | null;

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

  @Column({ name: 'override_reason', type: 'text', nullable: true })
  overrideReason: string | null;

  @ManyToOne(() => Exam, (exam) => exam.items, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'exam_id' })
  exam: Relation<Exam>;

  @ManyToOne(() => QuestionBankQuestion, { onDelete: 'RESTRICT' })
  @JoinColumn({ name: 'question_id' })
  question: Relation<QuestionBankQuestion>;

  @ManyToOne(() => ExamSection, (section) => section.items, {
    nullable: true,
    onDelete: 'SET NULL',
  })
  @JoinColumn({ name: 'section_id' })
  section: Relation<ExamSection> | null;

  @OneToOne(() => ExamItemSnapshot, (snapshot) => snapshot.examItem)
  snapshot: Relation<ExamItemSnapshot>;
}

