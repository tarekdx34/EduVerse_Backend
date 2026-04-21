import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  OneToMany,
  JoinColumn,
} from 'typeorm';
import type { Relation } from 'typeorm';
import type { Quiz } from './quiz.entity';
import { QuestionType } from '../enums';
import type { QuizDifficultyLevel } from './quiz-difficulty-level.entity';
import type { QuizAnswer } from './quiz-answer.entity';

@Entity('quiz_questions')
export class QuizQuestion {
  @PrimaryGeneratedColumn({ name: 'question_id', type: 'bigint', unsigned: true })
  id: number;

  @Column({ name: 'quiz_id', type: 'bigint', unsigned: true })
  quizId: number;

  @Column({ name: 'question_text', type: 'text' })
  questionText: string;

  @Column({
    name: 'question_type',
    type: 'enum',
    enum: QuestionType,
  })
  questionType: QuestionType;

  @Column({ type: 'json', nullable: true })
  options: string[];

  @Column({ name: 'correct_answer', type: 'text', nullable: true })
  correctAnswer: string;

  @Column({ type: 'text', nullable: true })
  explanation: string;

  @Column({ type: 'decimal', precision: 5, scale: 2, default: 1 })
  points: number;

  @Column({ name: 'difficulty_level_id', type: 'int', unsigned: true, nullable: true })
  difficultyLevelId: number;

  @Column({ name: 'order_index', type: 'int', default: 0 })
  orderIndex: number;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  // Relations
  @ManyToOne('Quiz', 'questions', { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'quiz_id' })
  quiz: Relation<Quiz>;

  @ManyToOne('QuizDifficultyLevel', { nullable: true })
  @JoinColumn({ name: 'difficulty_level_id' })
  difficultyLevel: Relation<QuizDifficultyLevel>;

  @OneToMany('QuizAnswer', 'question')
  answers: Relation<QuizAnswer>[];
}
