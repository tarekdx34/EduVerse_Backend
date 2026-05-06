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
import { QuestionBankType } from '../../question-bank/enums/question-bank.enums';
import { ExamItem } from './exam-item.entity';

@Entity('exam_item_snapshots')
@Index(['examItemId'], { unique: true })
export class ExamItemSnapshot {
  @PrimaryGeneratedColumn({ name: 'snapshot_id', type: 'bigint', unsigned: true })
  id: number;

  @Column({ name: 'exam_item_id', type: 'bigint', unsigned: true })
  examItemId: number;

  @Column({ name: 'source_question_id', type: 'bigint', unsigned: true })
  sourceQuestionId: number;

  @Column({
    name: 'source_question_version_id',
    type: 'bigint',
    unsigned: true,
    nullable: true,
  })
  sourceQuestionVersionId: number | null;

  @Column({ name: 'section_id', type: 'bigint', unsigned: true, nullable: true })
  sectionId: number | null;

  @Column({ name: 'question_type', type: 'enum', enum: QuestionBankType })
  questionType: QuestionBankType;

  @Column({ name: 'question_text', type: 'text', nullable: true })
  questionText: string | null;

  @Column({ name: 'question_file_id', type: 'bigint', unsigned: true, nullable: true })
  questionFileId: number | null;

  @Column({ name: 'question_file_storage_path', type: 'varchar', length: 500, nullable: true })
  questionFileStoragePath: string | null;

  @Column({ name: 'question_file_caption', type: 'varchar', length: 500, nullable: true })
  questionFileCaption: string | null;

  @Column({ name: 'question_file_alt_text', type: 'varchar', length: 500, nullable: true })
  questionFileAltText: string | null;

  @Column({ name: 'source_group_id', type: 'bigint', unsigned: true, nullable: true })
  sourceGroupId: number | null;

  @Column({ name: 'source_group_title', type: 'varchar', length: 255, nullable: true })
  sourceGroupTitle: string | null;

  @Column({ name: 'source_group_type', type: 'varchar', length: 50, nullable: true })
  sourceGroupType: string | null;

  @Column({ name: 'source_group_prompt', type: 'text', nullable: true })
  sourceGroupPrompt: string | null;

  @Column({ name: 'source_group_file_id', type: 'bigint', unsigned: true, nullable: true })
  sourceGroupFileId: number | null;

  @Column({ name: 'source_group_file_storage_path', type: 'varchar', length: 500, nullable: true })
  sourceGroupFileStoragePath: string | null;

  @Column({ name: 'source_group_file_caption', type: 'varchar', length: 500, nullable: true })
  sourceGroupFileCaption: string | null;

  @Column({ name: 'source_group_file_alt_text', type: 'varchar', length: 500, nullable: true })
  sourceGroupFileAltText: string | null;

  @Column({ name: 'source_group_item_order', type: 'int', unsigned: true, nullable: true })
  sourceGroupItemOrder: number | null;

  @Column({ name: 'options_json', type: 'json', nullable: true })
  optionsJson: Record<string, unknown>[] | null;

  @Column({ name: 'fill_blanks_json', type: 'json', nullable: true })
  fillBlanksJson: Record<string, unknown>[] | null;

  @Column({ name: 'expected_answer_text', type: 'text', nullable: true })
  expectedAnswerText: string | null;

  @Column({ name: 'hints', type: 'text', nullable: true })
  hints: string | null;

  @Column({ name: 'attachments_json', type: 'json', nullable: true })
  attachmentsJson: Record<string, unknown>[] | null;

  @Column({ name: 'marks', type: 'decimal', precision: 7, scale: 2, nullable: true })
  marks: number | null;

  @Column({ name: 'item_order', type: 'int', unsigned: true })
  itemOrder: number;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @ManyToOne(() => ExamItem, (item) => item.snapshot, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'exam_item_id' })
  examItem: Relation<ExamItem>;
}
