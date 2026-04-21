import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
  CreateDateColumn,
  UpdateDateColumn,
  Index,
} from 'typeorm';
import type { Relation } from 'typeorm';
import type { Grade } from './grade.entity';
import type { RubricCriteria } from './rubric-criteria.entity';

@Entity('grade_components')
@Index(['gradeId'])
export class GradeComponent {
  @PrimaryGeneratedColumn('increment', {
    name: 'component_id',
    type: 'bigint',
  })
  id: number;

  @Column({
    type: 'bigint',
    nullable: false,
    name: 'grade_id',
  })
  gradeId: number;

  @Column({
    type: 'bigint',
    nullable: true,
    name: 'rubric_criteria_id',
  })
  rubricCriteriaId: number | null;

  @Column({
    type: 'decimal',
    precision: 5,
    scale: 2,
    nullable: false,
    name: 'score',
  })
  score: number;

  @Column({
    type: 'decimal',
    precision: 5,
    scale: 2,
    nullable: false,
    name: 'max_score',
  })
  maxScore: number;

  @Column({
    type: 'text',
    nullable: true,
    name: 'feedback',
  })
  feedback: string | null;

  @CreateDateColumn({
    name: 'created_at',
  })
  createdAt: Date;

  @UpdateDateColumn({
    name: 'updated_at',
  })
  updatedAt: Date;

  @ManyToOne('Grade', {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'grade_id' })
  grade: Relation<Grade>;

  @ManyToOne('RubricCriteria', {
    onDelete: 'SET NULL',
  })
  @JoinColumn({ name: 'rubric_criteria_id' })
  rubricCriteria: Relation<RubricCriteria>;
}
