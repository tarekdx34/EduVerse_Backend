import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  OneToMany,
  JoinColumn,
  CreateDateColumn,
  UpdateDateColumn,
  DeleteDateColumn,
  Index,
} from 'typeorm';
import type { Relation } from 'typeorm';
import { CourseLevel, CourseStatus } from '../enums';
import type { Department } from '../../campus/entities/department.entity';
import type { CoursePrerequisite } from './course-prerequisite.entity';
import type { CourseSection } from './course-section.entity';

@Entity('courses')
@Index(['departmentId', 'code'], { unique: true })
@Index(['departmentId', 'status'])
export class Course {
  @PrimaryGeneratedColumn('increment', {
    name: 'course_id',
    type: 'bigint',
    unsigned: true,
  })
  id: number;

  @Column({
    type: 'bigint',
    unsigned: true,
    nullable: false,
    name: 'department_id',
  })
  departmentId: number;

  @Column({
    type: 'varchar',
    length: 200,
    nullable: false,
    name: 'course_name',
  })
  name: string;

  @Column({
    type: 'varchar',
    length: 20,
    nullable: false,
    name: 'course_code',
  })
  code: string;

  @Column({
    type: 'text',
    nullable: true,
    name: 'course_description',
  })
  description: string;

  @Column({
    type: 'int',
    nullable: false,
    name: 'credits',
  })
  credits: number;

  @Column({
    type: 'enum',
    enum: CourseLevel,
    nullable: false,
    name: 'level',
  })
  level: CourseLevel;

  @Column({
    type: 'varchar',
    length: 255,
    nullable: true,
    name: 'syllabus_url',
  })
  syllabusUrl: string | null;

  @Column({
    type: 'bigint',
    nullable: true,
    name: 'instructor_id',
  })
  instructorId: number | null;

  @Column({
    type: 'json',
    nullable: true,
    name: 'ta_ids',
  })
  taIds: number[] | null;

  @Column({
    type: 'json',
    nullable: true,
    name: 'skills',
  })
  skills: string[] | null;

  @Column({
    type: 'enum',
    enum: CourseStatus,
    default: CourseStatus.ACTIVE,
    name: 'status',
  })
  status: CourseStatus;

  @CreateDateColumn({
    name: 'created_at',
  })
  createdAt: Date;

  @UpdateDateColumn({
    name: 'updated_at',
  })
  updatedAt: Date;

  @DeleteDateColumn({
    name: 'deleted_at',
    nullable: true,
  })
  deletedAt: Date | null;

  @ManyToOne('Department', {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'department_id' })
  department: Relation<Department>;

  @OneToMany('CoursePrerequisite', 'course', {
    cascade: true,
  })
  prerequisites: Relation<CoursePrerequisite>[];

  @OneToMany('CourseSection', 'course', {
    cascade: true,
  })
  sections: Relation<CourseSection>[];
}
