import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { QuizType, AttemptStatus, QuestionType } from '../enums';

export class QuestionResultDto {
  @ApiProperty({ description: 'Question ID', example: 1 })
  questionId: number;

  @ApiProperty({ description: 'Question text', example: 'What is O(log n)?' })
  questionText: string;

  @ApiProperty({ description: 'Question type', enum: ['mcq', 'true_false', 'short_answer', 'essay', 'matching'] })
  questionType: QuestionType;

  @ApiPropertyOptional({ description: 'Answer options', type: [String] })
  options?: string[];

  @ApiProperty({ description: 'Student answer', example: '2' })
  studentAnswer: string;

  @ApiPropertyOptional({ description: 'Correct answer (if shown)' })
  correctAnswer?: string;

  @ApiProperty({ description: 'Whether the answer was correct' })
  isCorrect: boolean;

  @ApiProperty({ description: 'Points earned', example: 5 })
  pointsEarned: number;

  @ApiProperty({ description: 'Maximum points', example: 5 })
  maxPoints: number;

  @ApiPropertyOptional({ description: 'Explanation (if shown)' })
  explanation?: string;
}

export class AttemptResultDto {
  @ApiProperty({ description: 'Attempt ID', example: 1 })
  attemptId: number;

  @ApiProperty({ description: 'Quiz ID', example: 1 })
  quizId: number;

  @ApiProperty({ description: 'Quiz title', example: 'Midterm Quiz' })
  quizTitle: string;

  @ApiProperty({ description: 'Student ID', example: 5 })
  userId: number;

  @ApiProperty({ description: 'Student name', example: 'John Doe' })
  userName: string;

  @ApiProperty({ description: 'Attempt number', example: 1 })
  attemptNumber: number;

  @ApiProperty({ description: 'Score earned', example: 85 })
  score: number;

  @ApiProperty({ description: 'Maximum possible score', example: 100 })
  maxScore: number;

  @ApiProperty({ description: 'Score percentage', example: 85 })
  percentage: number;

  @ApiProperty({ description: 'Whether the student passed', example: true })
  passed: boolean;

  @ApiProperty({ description: 'Time taken in minutes', example: 45 })
  timeTakenMinutes: number;

  @ApiProperty({ description: 'Attempt status', enum: ['in_progress', 'submitted', 'graded', 'abandoned'] })
  status: AttemptStatus;

  @ApiProperty({ description: 'Start time', example: '2026-03-15T10:00:00Z' })
  startedAt: Date;

  @ApiProperty({ description: 'Number of correct answers', example: 8 })
  correctCount: number;

  @ApiProperty({ description: 'Number of wrong answers', example: 2 })
  wrongCount: number;

  @ApiProperty({ description: 'Number of skipped questions', example: 0 })
  skippedCount: number;

  @ApiPropertyOptional({ description: 'Submission time' })
  submittedAt?: Date;

  @ApiPropertyOptional({ description: 'Detailed question results', type: [QuestionResultDto] })
  questions?: QuestionResultDto[];
}

export class QuizStatisticsDto {
  @ApiProperty({ description: 'Quiz ID', example: 1 })
  quizId: number;

  @ApiProperty({ description: 'Quiz title', example: 'Midterm Quiz' })
  title: string;

  @ApiProperty({ description: 'Total attempts', example: 30 })
  totalAttempts: number;

  @ApiProperty({ description: 'Completed attempts', example: 28 })
  completedAttempts: number;

  @ApiProperty({ description: 'Average score', example: 78.5 })
  averageScore: number;

  @ApiProperty({ description: 'Highest score', example: 100 })
  highestScore: number;

  @ApiProperty({ description: 'Lowest score', example: 45 })
  lowestScore: number;

  @ApiProperty({ description: 'Pass rate percentage', example: 80 })
  passRate: number;

  @ApiProperty({ description: 'Average time in minutes', example: 35 })
  averageTimeTaken: number;
}

export class QuizSummaryDto {
  @ApiProperty({ description: 'Quiz ID', example: 1 })
  id: number;

  @ApiProperty({ description: 'Quiz title', example: 'Midterm Quiz' })
  title: string;

  @ApiProperty({ description: 'Quiz type', enum: ['practice', 'graded', 'midterm', 'final'] })
  quizType: QuizType;

  @ApiProperty({ description: 'Number of questions', example: 20 })
  questionCount: number;

  @ApiProperty({ description: 'Time limit in minutes', example: 60 })
  timeLimitMinutes: number;

  @ApiProperty({ description: 'Maximum attempts allowed', example: 2 })
  maxAttempts: number;

  @ApiPropertyOptional({ description: 'Student attempts used (for student view)', example: 1 })
  attemptsUsed?: number;

  @ApiPropertyOptional({ description: 'Best score (for student view)', example: 85 })
  bestScore?: number;

  @ApiProperty({ description: 'Whether quiz is available now', example: true })
  isAvailable: boolean;

  @ApiPropertyOptional({ description: 'Available from date' })
  availableFrom?: Date;

  @ApiPropertyOptional({ description: 'Available until date' })
  availableUntil?: Date;
}

export class StudentQuizProgressDto {
  @ApiProperty({ description: 'Course ID', example: 1 })
  courseId: number;

  @ApiProperty({ description: 'Course name', example: 'Introduction to Programming' })
  courseName: string;

  @ApiProperty({ description: 'Total quizzes in course', example: 5 })
  totalQuizzes: number;

  @ApiProperty({ description: 'Quizzes completed', example: 3 })
  completedQuizzes: number;

  @ApiProperty({ description: 'Average quiz score', example: 82.5 })
  averageScore: number;

  @ApiProperty({ description: 'Individual quiz summaries', type: [QuizSummaryDto] })
  quizzes: QuizSummaryDto[];
}
