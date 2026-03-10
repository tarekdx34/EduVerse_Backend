import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  DeleteDateColumn,
  ManyToOne,
  OneToMany,
  JoinColumn,
} from 'typeorm';
import { Course } from '../../courses/entities/course.entity';
import { User } from '../../auth/entities/user.entity';
import { QuizType, ShowAnswersAfter } from '../enums';
import { QuizQuestion } from './quiz-question.entity';
import { QuizAttempt } from './quiz-attempt.entity';

@Entity('quizzes')
export class Quiz {
  @PrimaryGeneratedColumn({ name: 'quiz_id', type: 'bigint', unsigned: true })
  id: number;

  @Column({ name: 'course_id', type: 'bigint', unsigned: true })
  courseId: number;

  @Column({ type: 'varchar', length: 255 })
  title: string;

  @Column({ type: 'text', nullable: true })
  description: string;

  @Column({ type: 'text', nullable: true })
  instructions: string;

  @Column({
    name: 'quiz_type',
    type: 'enum',
    enum: QuizType,
    default: QuizType.GRADED,
  })
  quizType: QuizType;

  @Column({ name: 'time_limit_minutes', type: 'int', nullable: true })
  timeLimitMinutes: number;

  @Column({ name: 'max_attempts', type: 'int', default: 1 })
  maxAttempts: number;

  @Column({ name: 'passing_score', type: 'decimal', precision: 5, scale: 2, nullable: true })
  passingScore: number;

  @Column({ name: 'randomize_questions', type: 'tinyint', default: false })
  randomizeQuestions: boolean;

  @Column({ name: 'show_correct_answers', type: 'tinyint', default: true })
  showCorrectAnswers: boolean;

  @Column({
    name: 'show_answers_after',
    type: 'enum',
    enum: ShowAnswersAfter,
    default: ShowAnswersAfter.AFTER_DUE,
  })
  showAnswersAfter: ShowAnswersAfter;

  @Column({ name: 'available_from', type: 'timestamp', nullable: true })
  availableFrom: Date;

  @Column({ name: 'available_until', type: 'timestamp', nullable: true })
  availableUntil: Date;

  @Column({ type: 'decimal', precision: 5, scale: 2, default: 0 })
  weight: number;

  @Column({ name: 'created_by', type: 'bigint', unsigned: true })
  createdBy: number;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  @DeleteDateColumn({ name: 'deleted_at' })
  deletedAt: Date;

  // Relations
  @ManyToOne(() => Course, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'course_id' })
  course: Course;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'created_by' })
  creator: User;

  @OneToMany(() => QuizQuestion, (question) => question.quiz)
  questions: QuizQuestion[];

  @OneToMany(() => QuizAttempt, (attempt) => attempt.quiz)
  attempts: QuizAttempt[];
}
