import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import type { Relation } from 'typeorm';
import type { QuizAttempt } from './quiz-attempt.entity';
import type { QuizQuestion } from './quiz-question.entity';

@Entity('quiz_answers')
export class QuizAnswer {
  @PrimaryGeneratedColumn({ name: 'answer_id', type: 'bigint', unsigned: true })
  id: number;

  @Column({ name: 'attempt_id', type: 'bigint', unsigned: true })
  attemptId: number;

  @Column({ name: 'question_id', type: 'bigint', unsigned: true })
  questionId: number;

  @Column({ name: 'answer_text', type: 'text', nullable: true })
  answerText: string;

  @Column({ name: 'selected_option', type: 'json', nullable: true })
  selectedOption: string[];

  @Column({ name: 'is_correct', type: 'tinyint', nullable: true })
  isCorrect: boolean;

  @Column({ name: 'points_earned', type: 'decimal', precision: 5, scale: 2, default: 0 })
  pointsEarned: number;

  @CreateDateColumn({ name: 'answered_at' })
  answeredAt: Date;

  // Relations
  @ManyToOne('QuizAttempt', 'answers', { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'attempt_id' })
  attempt: Relation<QuizAttempt>;

  @ManyToOne('QuizQuestion', 'answers', { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'question_id' })
  question: Relation<QuizQuestion>;
}
