import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
  CreateDateColumn,
  Index,
} from 'typeorm';
import { Course } from '../../courses/entities/course.entity';
import { CourseMaterial } from './course-material.entity';
import { OrganizationType } from '../enums';

@Entity('lecture_sections_labs')
@Index(['courseId'])
@Index(['weekNumber'])
export class LectureSectionLab {
  @PrimaryGeneratedColumn({
    name: 'organization_id',
    type: 'bigint',
    unsigned: true,
  })
  organizationId: number;

  @Column({
    name: 'course_id',
    type: 'bigint',
    unsigned: true,
  })
  courseId: number;

  @ManyToOne(() => Course, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'course_id' })
  course: Course;

  @Column({
    name: 'material_id',
    type: 'bigint',
    unsigned: true,
    nullable: true,
  })
  materialId: number | null;

  @ManyToOne(() => CourseMaterial, { onDelete: 'SET NULL', nullable: true })
  @JoinColumn({ name: 'material_id' })
  material: CourseMaterial | null;

  @Column({
    name: 'organization_type',
    type: 'enum',
    enum: OrganizationType,
    nullable: true,
  })
  organizationType: OrganizationType | null;

  @Column({
    name: 'title',
    type: 'varchar',
    length: 255,
  })
  title: string;

  @Column({
    name: 'week_number',
    type: 'int',
    nullable: true,
  })
  weekNumber: number | null;

  @Column({
    name: 'order_index',
    type: 'int',
    default: 0,
  })
  orderIndex: number;

  @Column({
    name: 'description',
    type: 'text',
    nullable: true,
  })
  description: string | null;

  @CreateDateColumn({
    name: 'created_at',
  })
  createdAt: Date;
}
