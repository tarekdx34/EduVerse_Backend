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
import type { Rubric } from './rubric.entity';

@Entity('rubric_criteria')
@Index(['rubricId'])
export class RubricCriteria {
  @PrimaryGeneratedColumn('increment', {
    name: 'criteria_id',
    type: 'bigint',
  })
  id: number;

  @Column({
    type: 'bigint',
    nullable: false,
    name: 'rubric_id',
  })
  rubricId: number;

  @Column({
    type: 'varchar',
    length: 200,
    nullable: false,
    name: 'name',
  })
  name: string;

  @Column({
    type: 'text',
    nullable: true,
    name: 'description',
  })
  description: string | null;

  @Column({
    type: 'decimal',
    precision: 5,
    scale: 2,
    nullable: true,
    name: 'max_points',
  })
  maxPoints: number;

  @Column({
    type: 'int',
    default: 0,
    name: 'order_position',
  })
  orderPosition: number;

  @CreateDateColumn({
    name: 'created_at',
  })
  createdAt: Date;

  @UpdateDateColumn({
    name: 'updated_at',
  })
  updatedAt: Date;

  @ManyToOne('Rubric', {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'rubric_id' })
  rubric: Relation<Rubric>;
}
