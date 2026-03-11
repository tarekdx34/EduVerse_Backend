import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
  CreateDateColumn,
} from 'typeorm';
import { User } from '../../auth/entities/user.entity';

export enum TrendDirection {
  IMPROVING = 'improving',
  STABLE = 'stable',
  DECLINING = 'declining',
}

@Entity('performance_metrics')
export class PerformanceMetrics {
  @PrimaryGeneratedColumn({
    name: 'metric_id',
    type: 'bigint',
    unsigned: true,
  })
  metricId: number;

  @Column({ name: 'user_id', type: 'bigint', unsigned: true })
  userId: number;

  @Column({ name: 'course_id', type: 'bigint', unsigned: true })
  courseId: number;

  @Column({ name: 'metric_name', type: 'varchar', length: 100 })
  metricName: string;

  @Column({
    name: 'metric_value',
    type: 'decimal',
    precision: 10,
    scale: 2,
  })
  metricValue: number;

  @Column({ name: 'calculation_date', type: 'date' })
  calculationDate: Date;

  @Column({
    name: 'trend',
    type: 'enum',
    enum: TrendDirection,
    nullable: true,
  })
  trend: TrendDirection;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'user_id' })
  user: User;
}
