import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
  Index,
} from 'typeorm';
import type { Relation } from 'typeorm';
import type { User } from '../../auth/entities/user.entity';
import type { Semester } from '../../campus/entities/semester.entity';

@Entity('gpa_calculations')
@Index(['userId', 'semesterId'], { unique: true })
export class GpaCalculation {
  @PrimaryGeneratedColumn('increment', {
    name: 'gpa_id',
    type: 'bigint',
  })
  id: number;

  @Column({
    type: 'bigint',
    nullable: false,
    name: 'user_id',
  })
  userId: number;

  @Column({
    type: 'bigint',
    nullable: false,
    name: 'semester_id',
  })
  semesterId: number;

  @Column({
    type: 'decimal',
    precision: 3,
    scale: 2,
    nullable: true,
    name: 'semester_gpa',
  })
  semesterGpa: number;

  @Column({
    type: 'decimal',
    precision: 3,
    scale: 2,
    nullable: true,
    name: 'cumulative_gpa',
  })
  cumulativeGpa: number;

  @Column({
    type: 'int',
    nullable: true,
    name: 'total_credits',
  })
  totalCredits: number;

  @Column({
    type: 'decimal',
    precision: 10,
    scale: 2,
    nullable: true,
    name: 'total_quality_points',
  })
  totalQualityPoints: number;

  @Column({
    type: 'timestamp',
    nullable: true,
    name: 'calculated_at',
  })
  calculatedAt: Date;

  @ManyToOne('User', {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'user_id' })
  user: Relation<User>;

  @ManyToOne('Semester', {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'semester_id' })
  semester: Relation<Semester>;
}
