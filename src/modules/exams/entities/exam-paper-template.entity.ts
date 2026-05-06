import {
  Column,
  CreateDateColumn,
  Entity,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';
import type { Relation } from 'typeorm';
import type { Course } from '../../courses/entities/course.entity';

export enum ExamPaperLayoutMode {
  STRUCTURED = 'structured',
  FREE = 'free',
  HYBRID = 'hybrid',
}

@Entity('exam_paper_templates')
export class ExamPaperTemplate {
  @PrimaryGeneratedColumn({
    name: 'template_id',
    type: 'bigint',
    unsigned: true,
  })
  id: number;

  @Column({ name: 'owner_instructor_id', type: 'bigint', unsigned: true })
  ownerInstructorId: number;

  @Column({ name: 'course_id', type: 'bigint', unsigned: true, nullable: true })
  courseId: number | null;

  @Column({ name: 'name', type: 'varchar', length: 255 })
  name: string;

  @Column({
    name: 'layout_mode',
    type: 'enum',
    enum: ExamPaperLayoutMode,
    default: ExamPaperLayoutMode.STRUCTURED,
  })
  layoutMode: ExamPaperLayoutMode;

  @Column({ name: 'page_size', type: 'varchar', length: 20, default: 'A4' })
  pageSize: string;

  @Column({ name: 'orientation', type: 'varchar', length: 20, default: 'portrait' })
  orientation: string;

  @Column({ name: 'margins_json', type: 'json', nullable: true })
  marginsJson: Record<string, unknown> | null;

  @Column({ name: 'header_json', type: 'json', nullable: true })
  headerJson: Record<string, unknown> | null;

  @Column({ name: 'trailing_json', type: 'json', nullable: true })
  trailingJson: Record<string, unknown> | null;

  @Column({ name: 'footer_json', type: 'json', nullable: true })
  footerJson: Record<string, unknown> | null;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  @ManyToOne('Course', { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'course_id' })
  course: Relation<Course> | null;
}
