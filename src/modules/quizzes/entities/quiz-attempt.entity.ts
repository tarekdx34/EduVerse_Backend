import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  OneToMany,
  JoinColumn,
} from 'typeorm';
import type { Relation } from 'typeorm';
import type { Quiz } from './quiz.entity';
import type { User } from '../../auth/entities/user.entity';
import { AttemptStatus } from '../enums';
import type { QuizAnswer } from './quiz-answer.entity';

@Entity('quiz_attempts')
export class QuizAttempt {
  @PrimaryGeneratedColumn({ name: 'attempt_id', type: 'bigint', unsigned: true })
  id: number;

  @Column({ name: 'quiz_id', type: 'bigint', unsigned: true })
  quizId: number;

  @Column({ name: 'user_id', type: 'bigint', unsigned: true })
  userId: number;

  @Column({ name: 'attempt_number', type: 'int' })
  attemptNumber: number;

  @CreateDateColumn({ name: 'started_at' })
  startedAt: Date;

  @Column({ name: 'submitted_at', type: 'timestamp', nullable: true })
  submittedAt: Date;

  @Column({ type: 'decimal', precision: 5, scale: 2, nullable: true })
  score: number;

  @Column({ name: 'time_taken_minutes', type: 'int', nullable: true })
  timeTakenMinutes: number;

  @Column({
    type: 'enum',
    enum: AttemptStatus,
    default: AttemptStatus.IN_PROGRESS,
  })
  status: AttemptStatus;

  @Column({ name: 'ip_address', type: 'varchar', length: 45, nullable: true })
  ipAddress: string;

  // Relations
  @ManyToOne('Quiz', 'attempts', { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'quiz_id' })
  quiz: Relation<Quiz>;

  @ManyToOne('User', { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'user_id' })
  user: Relation<User>;

  @OneToMany('QuizAnswer', 'attempt')
  answers: Relation<QuizAnswer>[];
}
