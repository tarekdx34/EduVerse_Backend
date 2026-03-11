import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
  CreateDateColumn,
} from 'typeorm';
import { User } from '../../auth/entities/user.entity';

export enum MetricType {
  ENGAGEMENT = 'engagement',
  PERFORMANCE = 'performance',
  PARTICIPATION = 'participation',
  TIME = 'time',
}

@Entity('learning_analytics')
export class LearningAnalytics {
  @PrimaryGeneratedColumn({
    name: 'analytics_id',
    type: 'bigint',
    unsigned: true,
  })
  analyticsId: number;

  @Column({ name: 'user_id', type: 'bigint', unsigned: true })
  userId: number;

  @Column({ name: 'course_id', type: 'bigint', unsigned: true })
  courseId: number;

  @Column({
    name: 'progress_id',
    type: 'bigint',
    unsigned: true,
    nullable: true,
  })
  progressId: number;

  @Column({ name: 'metric_type', type: 'enum', enum: MetricType })
  metricType: MetricType;

  @Column({
    name: 'metric_value',
    type: 'decimal',
    precision: 10,
    scale: 2,
  })
  metricValue: number;

  @Column({ name: 'metric_date', type: 'date' })
  metricDate: Date;

  @Column({ name: 'additional_data', type: 'longtext', nullable: true })
  additionalData: string;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'user_id' })
  user: User;
}
