import {
  Column,
  CreateDateColumn,
  DeleteDateColumn,
  Entity,
  Index,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';
import type { Relation } from 'typeorm';
import type { File } from '../../files/entities/file.entity';
import { QuestionBankQuestion } from './question-bank-question.entity';

export enum QuestionAttachmentType {
  IMAGE = 'image',
  DOCUMENT = 'document',
  AUDIO = 'audio',
  VIDEO = 'video',
}

@Entity('question_bank_question_attachments')
@Index(['questionId', 'displayOrder'], { unique: true })
@Index(['fileId'])
export class QuestionBankQuestionAttachment {
  @PrimaryGeneratedColumn({
    name: 'attachment_id',
    type: 'bigint',
    unsigned: true,
  })
  id: number;

  @Column({ name: 'question_id', type: 'bigint', unsigned: true })
  questionId: number;

  @Column({ name: 'file_id', type: 'bigint', unsigned: true })
  fileId: number;

  @Column({
    name: 'attachment_type',
    type: 'enum',
    enum: QuestionAttachmentType,
    default: QuestionAttachmentType.IMAGE,
  })
  attachmentType: QuestionAttachmentType;

  @Column({ name: 'caption', type: 'varchar', length: 500, nullable: true })
  caption: string | null;

  @Column({ name: 'alt_text', type: 'varchar', length: 500, nullable: true })
  altText: string | null;

  @Column({ name: 'display_order', type: 'int', unsigned: true, default: 0 })
  displayOrder: number;

  @Column({ name: 'is_primary', type: 'tinyint', width: 1, default: 0 })
  isPrimary: number;

  @Column({ name: 'storage_path', type: 'varchar', length: 500, nullable: true })
  storagePath: string | null;

  @Column({ name: 'created_by', type: 'bigint', unsigned: true })
  createdBy: number;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  @DeleteDateColumn({ name: 'deleted_at', nullable: true })
  deletedAt: Date | null;

  @ManyToOne(() => QuestionBankQuestion, (question) => question.attachments, {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'question_id' })
  question: Relation<QuestionBankQuestion>;

  @ManyToOne('File', { onDelete: 'RESTRICT' })
  @JoinColumn({ name: 'file_id', referencedColumnName: 'fileId' })
  file: Relation<File>;
}
