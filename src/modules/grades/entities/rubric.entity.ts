import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  OneToMany,
  JoinColumn,
  CreateDateColumn,
  UpdateDateColumn,
  Index,
} from 'typeorm';
import type { Relation } from 'typeorm';
import type { Course } from '../../courses/entities/course.entity';
import type { User } from '../../auth/entities/user.entity';
import type { RubricCriteria } from './rubric-criteria.entity';

@Entity('rubrics')
@Index(['courseId'])
export class Rubric {
  @PrimaryGeneratedColumn('increment', {
    name: 'rubric_id',
    type: 'bigint',
  })
  id: number;

  @Column({
    type: 'bigint',
    nullable: false,
    name: 'course_id',
  })
  courseId: number;

  @Column({
    type: 'varchar',
    length: 200,
    nullable: false,
    name: 'rubric_name',
  })
  rubricName: string;

  @Column({
    type: 'text',
    nullable: true,
    name: 'description',
  })
  description: string | null;

  @Column({
    type: 'longtext',
    nullable: true,
    name: 'criteria',
  })
  criteria: string | null;

  @Column({
    type: 'decimal',
    precision: 5,
    scale: 2,
    nullable: true,
    name: 'total_points',
  })
  totalPoints: number;

  @Column({
    type: 'bigint',
    nullable: false,
    name: 'created_by',
  })
  createdBy: number;

  @CreateDateColumn({
    name: 'created_at',
  })
  createdAt: Date;

  @UpdateDateColumn({
    name: 'updated_at',
  })
  updatedAt: Date;

  @ManyToOne('Course', {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'course_id' })
  course: Relation<Course>;

  @ManyToOne('User', {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'created_by' })
  creator: Relation<User>;

  @OneToMany('RubricCriteria', 'rubric', {
    cascade: true,
  })
  criteriaItems: Relation<RubricCriteria>[];
}
