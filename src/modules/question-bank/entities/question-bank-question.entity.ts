import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  DeleteDateColumn,
  ManyToOne,
  OneToMany,
  JoinColumn,
  Index,
} from 'typeorm';
import type { Relation } from 'typeorm';
import type { Course } from '../../courses/entities/course.entity';
import type { File } from '../../files/entities/file.entity';
import { CourseChapter } from './course-chapter.entity';
import { QuestionBankFillBlank } from './question-bank-fill-blank.entity';
import { QuestionBankQuestionAttachment } from './question-bank-question-attachment.entity';
import { QuestionBankQuestionGroupItem } from './question-bank-question-group-item.entity';
import { QuestionBankOption } from './question-bank-option.entity';
import {
  BloomLevel,
  QuestionBankDifficulty,
  QuestionBankStatus,
  QuestionBankType,
} from '../enums/question-bank.enums';

@Entity('question_bank_questions')
@Index([
  'courseId',
  'chapterId',
  'questionType',
  'difficulty',
  'bloomLevel',
  'status',
])
@Index(['courseId', 'bloomLevel', 'status'])
export class QuestionBankQuestion {
  @PrimaryGeneratedColumn({
    name: 'question_id',
    type: 'bigint',
    unsigned: true,
  })
  id: number;

  @Column({ name: 'course_id', type: 'bigint', unsigned: true })
  courseId: number;

  @Column({ name: 'chapter_id', type: 'bigint', unsigned: true })
  chapterId: number;

  @Column({ name: 'bloom_level', type: 'enum', enum: BloomLevel })
  bloomLevel: BloomLevel;

  @Column({ name: 'question_type', type: 'enum', enum: QuestionBankType })
  questionType: QuestionBankType;

  @Column({ name: 'difficulty', type: 'enum', enum: QuestionBankDifficulty })
  difficulty: QuestionBankDifficulty;

  @Column({ name: 'question_text', type: 'text', nullable: true })
  questionText: string | null;

  @Column({
    name: 'question_file_id',
    type: 'bigint',
    unsigned: true,
    nullable: true,
  })
  questionFileId: number | null;

  @Column({
    name: 'question_file_caption',
    type: 'varchar',
    length: 500,
    nullable: true,
  })
  questionFileCaption: string | null;

  @Column({
    name: 'question_file_alt_text',
    type: 'varchar',
    length: 500,
    nullable: true,
  })
  questionFileAltText: string | null;

  @Column({ name: 'expected_answer_text', type: 'text', nullable: true })
  expectedAnswerText: string | null;

  @Column({ name: 'hints', type: 'text', nullable: true })
  hints: string | null;

  @Column({
    name: 'status',
    type: 'enum',
    enum: QuestionBankStatus,
    default: QuestionBankStatus.DRAFT,
  })
  status: QuestionBankStatus;

  @Column({ name: 'created_by', type: 'bigint', unsigned: true })
  createdBy: number;

  @Column({
    name: 'updated_by',
    type: 'bigint',
    unsigned: true,
    nullable: true,
  })
  updatedBy: number | null;

  @Column({
    name: 'reviewed_by',
    type: 'bigint',
    unsigned: true,
    nullable: true,
  })
  reviewedBy: number | null;

  @Column({ name: 'reviewed_at', type: 'datetime', nullable: true })
  reviewedAt: Date | null;

  @Column({ name: 'review_comment', type: 'text', nullable: true })
  reviewComment: string | null;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  @DeleteDateColumn({ name: 'deleted_at', nullable: true })
  deletedAt: Date | null;

  @ManyToOne('Course', { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'course_id' })
  course: Relation<Course>;

  @ManyToOne(() => CourseChapter, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'chapter_id' })
  chapter: Relation<CourseChapter>;

  @ManyToOne('File', { nullable: true, onDelete: 'SET NULL' })
  @JoinColumn({ name: 'question_file_id', referencedColumnName: 'fileId' })
  file: Relation<File> | null;

  @OneToMany(() => QuestionBankOption, (option) => option.question, {
    cascade: true,
  })
  options: Relation<QuestionBankOption[]>;

  @OneToMany(() => QuestionBankFillBlank, (blank) => blank.question, {
    cascade: true,
  })
  fillBlanks: Relation<QuestionBankFillBlank[]>;

  @OneToMany(
    () => QuestionBankQuestionAttachment,
    (attachment) => attachment.question,
  )
  attachments: Relation<QuestionBankQuestionAttachment[]>;

  @OneToMany(() => QuestionBankQuestionGroupItem, (item) => item.question)
  groupItems: Relation<QuestionBankQuestionGroupItem[]>;
}
