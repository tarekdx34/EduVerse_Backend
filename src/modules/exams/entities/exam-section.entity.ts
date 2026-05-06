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
import { ExamItem } from './exam-item.entity';
import { Exam } from './exam.entity';
import { ExamSectionAnswerPolicy } from './exam-draft-section.entity';

@Entity('exam_sections')
@Index(['examId', 'sectionOrder'], { unique: true })
export class ExamSection {
  @PrimaryGeneratedColumn({ name: 'section_id', type: 'bigint', unsigned: true })
  id: number;

  @Column({ name: 'exam_id', type: 'bigint', unsigned: true })
  examId: number;

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

  @ManyToOne(() => Exam, (exam) => exam.sections, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'exam_id' })
  exam: Relation<Exam>;

  @OneToMany(() => ExamItem, (item) => item.section)
  items: Relation<ExamItem[]>;
}
