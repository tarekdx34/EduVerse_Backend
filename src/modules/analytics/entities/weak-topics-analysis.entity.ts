import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';
import { User } from '../../auth/entities/user.entity';

@Entity('weak_topics_analysis')
export class WeakTopicsAnalysis {
  @PrimaryGeneratedColumn({
    name: 'analysis_id',
    type: 'bigint',
    unsigned: true,
  })
  analysisId: number;

  @Column({ name: 'user_id', type: 'bigint', unsigned: true })
  userId: number;

  @Column({ name: 'course_id', type: 'bigint', unsigned: true })
  courseId: number;

  @Column({ name: 'topic_name', type: 'varchar', length: 255 })
  topicName: string;

  @Column({
    name: 'weakness_score',
    type: 'decimal',
    precision: 5,
    scale: 2,
  })
  weaknessScore: number;

  @Column({ name: 'attempt_count', type: 'int', default: 0 })
  attemptCount: number;

  @Column({
    name: 'success_rate',
    type: 'decimal',
    precision: 5,
    scale: 2,
    default: 0.0,
  })
  successRate: number;

  @Column({ name: 'last_attempted_at', type: 'timestamp', nullable: true })
  lastAttemptedAt: Date;

  @Column({
    name: 'recommendation_generated',
    type: 'tinyint',
    width: 1,
    default: 0,
  })
  recommendationGenerated: boolean;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'user_id' })
  user: User;
}
