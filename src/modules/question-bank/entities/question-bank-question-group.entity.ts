import {
  Column,
  CreateDateColumn,
  DeleteDateColumn,
  Entity,
  Index,
  JoinColumn,
  ManyToOne,
  OneToMany,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';
import type { Relation } from 'typeorm';
import type { Course } from '../../courses/entities/course.entity';
import type { File } from '../../files/entities/file.entity';
import { CourseChapter } from './course-chapter.entity';
import { QuestionBankQuestionGroupItem } from './question-bank-question-group-item.entity';

export enum QuestionGroupType {
  PASSAGE = 'passage',
  CASE_STUDY = 'case_study',
  IMAGE_SET = 'image_set',
  MULTIPART = 'multipart',
  OTHER = 'other',
}

@Entity('question_bank_question_groups')
@Index(['courseId', 'chapterId'])
export class QuestionBankQuestionGroup {
  @PrimaryGeneratedColumn({ name: 'group_id', type: 'bigint', unsigned: true })
  id: number;

  @Column({ name: 'course_id', type: 'bigint', unsigned: true })
  courseId: number;

  @Column({
    name: 'chapter_id',
    type: 'bigint',
    unsigned: true,
    nullable: true,
  })
  chapterId: number | null;

  @Column({ name: 'title', type: 'varchar', length: 255, nullable: true })
  title: string | null;

  @Column({ name: 'shared_prompt', type: 'text', nullable: true })
  sharedPrompt: string | null;

  @Column({
    name: 'shared_file_id',
    type: 'bigint',
    unsigned: true,
    nullable: true,
  })
  sharedFileId: number | null;

  @Column({
    name: 'shared_file_caption',
    type: 'varchar',
    length: 500,
    nullable: true,
  })
  sharedFileCaption: string | null;

  @Column({
    name: 'shared_file_alt_text',
    type: 'varchar',
    length: 500,
    nullable: true,
  })
  sharedFileAltText: string | null;

  @Column({
    name: 'group_type',
    type: 'enum',
    enum: QuestionGroupType,
    default: QuestionGroupType.OTHER,
  })
  groupType: QuestionGroupType;

  @Column({ name: 'created_by', type: 'bigint', unsigned: true })
  createdBy: number;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  @DeleteDateColumn({ name: 'deleted_at', nullable: true })
  deletedAt: Date | null;

  @ManyToOne('Course', { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'course_id' })
  course: Relation<Course>;

  @ManyToOne(() => CourseChapter, { nullable: true, onDelete: 'SET NULL' })
  @JoinColumn({ name: 'chapter_id' })
  chapter: Relation<CourseChapter> | null;

  @ManyToOne('File', { nullable: true, onDelete: 'SET NULL' })
  @JoinColumn({ name: 'shared_file_id', referencedColumnName: 'fileId' })
  sharedFile: Relation<File> | null;

  @OneToMany(() => QuestionBankQuestionGroupItem, (item) => item.group, {
    cascade: true,
  })
  items: Relation<QuestionBankQuestionGroupItem[]>;
}
