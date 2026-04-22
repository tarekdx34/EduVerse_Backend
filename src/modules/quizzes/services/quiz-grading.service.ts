import { Injectable, Inject, forwardRef } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { QuizAttempt, QuizAnswer, QuizQuestion, Quiz } from '../entities';
import { QuestionType, AttemptStatus } from '../enums';
import { ManualGradeDto, AttemptResultDto } from '../dto';
import { AttemptNotFoundException } from '../exceptions';
import { GradesService } from '../../grades/services';
import { GradeType } from '../../grades/enums';

@Injectable()
export class QuizGradingService {
  constructor(
    @InjectRepository(QuizAttempt)
    private readonly attemptRepo: Repository<QuizAttempt>,
    @InjectRepository(QuizAnswer)
    private readonly answerRepo: Repository<QuizAnswer>,
    @InjectRepository(QuizQuestion)
    private readonly questionRepo: Repository<QuizQuestion>,
    @Inject(forwardRef(() => GradesService))
    private readonly gradesService: GradesService,
  ) {}

  /**
   * Apply manual grades to essay/short answer questions
   */
  async applyManualGrades(attemptId: number, dto: ManualGradeDto, graderId?: number): Promise<AttemptResultDto> {
    const attempt = await this.attemptRepo.findOne({
      where: { id: attemptId },
      relations: ['quiz', 'quiz.questions', 'answers', 'user'],
    });

    if (!attempt) {
      throw new AttemptNotFoundException(attemptId);
    }

    // Apply grades to each answer
    for (const grade of dto.grades) {
      await this.answerRepo.update(grade.answerId, {
        pointsEarned: grade.pointsEarned,
        isCorrect: grade.pointsEarned > 0,
      });
    }

    // Recalculate total score
    const answers = await this.answerRepo.find({ where: { attemptId } });
    const totalScore = answers.reduce((sum, a) => sum + Number(a.pointsEarned || 0), 0);
    const maxScore = attempt.quiz.questions.reduce((sum, q) => sum + Number(q.points), 0);

    // Update attempt status to graded
    await this.attemptRepo.update(attemptId, {
      score: totalScore,
      status: AttemptStatus.GRADED,
    });

    // Create/update grade record in central grades table
    await this.gradesService.createGrade({
      userId: attempt.userId,
      courseId: attempt.quiz.courseId,
      gradeType: GradeType.QUIZ,
      quizId: attempt.quiz.id,
      score: totalScore,
      maxScore: maxScore,
      isPublished: true,
    }, graderId || attempt.quiz.createdBy);

    return this.buildAttemptResult(attemptId);
  }

  /**
   * Auto-grade all auto-gradable questions in an attempt
   */
  async autoGrade(attemptId: number): Promise<void> {
    const answers = await this.answerRepo.find({
      where: { attemptId },
      relations: ['question'],
    });

    for (const answer of answers) {
      if (this.isAutoGradable(answer.question.questionType)) {
        const result = this.gradeQuestion(answer.question, answer);
        await this.answerRepo.update(answer.id, {
          isCorrect: result.isCorrect,
          pointsEarned: result.pointsEarned,
        });
      }
    }
  }

  /**
   * Check if a question type can be auto-graded
   */
  private isAutoGradable(questionType: QuestionType): boolean {
    return (
      questionType === QuestionType.MCQ ||
      questionType === QuestionType.TRUE_FALSE ||
      questionType === QuestionType.MATCHING
    );
  }

  /**
   * Grade a single question
   */
  private gradeQuestion(
    question: QuizQuestion,
    answer: QuizAnswer,
  ): { isCorrect: boolean; pointsEarned: number } {
    if (!question.correctAnswer) {
      return { isCorrect: false, pointsEarned: 0 };
    }

    let isCorrect = false;

    switch (question.questionType) {
      case QuestionType.MCQ:
        isCorrect = this.gradeMCQ(question, answer);
        break;
      case QuestionType.TRUE_FALSE:
        isCorrect = this.gradeTrueFalse(question, answer);
        break;
      case QuestionType.MATCHING:
        isCorrect = this.gradeMatching(question, answer);
        break;
      default:
        // Short answer and essay require manual grading
        return { isCorrect: false, pointsEarned: 0 };
    }

    return {
      isCorrect,
      pointsEarned: isCorrect ? Number(question.points) : 0,
    };
  }

  /**
   * Grade multiple choice question
   */
  private gradeMCQ(question: QuizQuestion, answer: QuizAnswer): boolean {
    if (!answer.selectedOption || answer.selectedOption.length === 0) {
      return false;
    }

    // correctAnswer could be single index or comma-separated for multi-select
    const correctOptions = question.correctAnswer.split(',').map((s) => s.trim());
    const selectedOptions = answer.selectedOption.map((s) => s.trim());

    // Check if arrays have same elements
    if (correctOptions.length !== selectedOptions.length) return false;
    return correctOptions.every((opt) => selectedOptions.includes(opt));
  }

  /**
   * Grade true/false question
   */
  private gradeTrueFalse(question: QuizQuestion, answer: QuizAnswer): boolean {
    const studentAnswer = (answer.answerText || answer.selectedOption?.[0] || '').toLowerCase().trim();
    const correctAnswer = question.correctAnswer.toLowerCase().trim();

    // Normalize various true/false representations
    const trueValues = ['true', 't', 'yes', 'y', '1'];
    const falseValues = ['false', 'f', 'no', 'n', '0'];

    const studentBool = trueValues.includes(studentAnswer)
      ? true
      : falseValues.includes(studentAnswer)
        ? false
        : null;

    const correctBool = trueValues.includes(correctAnswer)
      ? true
      : falseValues.includes(correctAnswer)
        ? false
        : null;

    return studentBool === correctBool && studentBool !== null;
  }

  /**
   * Grade matching question
   */
  private gradeMatching(question: QuizQuestion, answer: QuizAnswer): boolean {
    if (!answer.selectedOption) return false;

    try {
      // For matching, selectedOption should contain paired values
      // correctAnswer format: "A-1,B-2,C-3"
      const correctPairs = question.correctAnswer.split(',').map((p) => p.trim().toLowerCase());
      const studentPairs = answer.selectedOption.map((p) => p.trim().toLowerCase());

      if (correctPairs.length !== studentPairs.length) return false;
      return correctPairs.every((pair) => studentPairs.includes(pair));
    } catch {
      return false;
    }
  }

  /**
   * Get questions that need manual grading for an attempt
   */
  async getQuestionsNeedingGrading(attemptId: number): Promise<QuizAnswer[]> {
    return this.answerRepo.find({
      where: { attemptId },
      relations: ['question'],
    }).then((answers) =>
      answers.filter(
        (a) =>
          a.question.questionType === QuestionType.SHORT_ANSWER ||
          a.question.questionType === QuestionType.ESSAY,
      ),
    );
  }

  /**
   * Calculate attempt statistics
   */
  async calculateAttemptScore(attemptId: number): Promise<{
    totalScore: number;
    maxScore: number;
    percentage: number;
  }> {
    const attempt = await this.attemptRepo.findOne({
      where: { id: attemptId },
      relations: ['quiz', 'quiz.questions', 'answers'],
    });

    if (!attempt) {
      throw new AttemptNotFoundException(attemptId);
    }

    const totalScore = attempt.answers.reduce((sum, a) => sum + Number(a.pointsEarned || 0), 0);
    const maxScore = attempt.quiz.questions.reduce((sum, q) => sum + Number(q.points), 0);
    const percentage = maxScore > 0 ? (totalScore / maxScore) * 100 : 0;

    return {
      totalScore,
      maxScore,
      percentage: Math.round(percentage * 100) / 100,
    };
  }

  private async buildAttemptResult(attemptId: number): Promise<AttemptResultDto> {
    const attempt = await this.attemptRepo.findOne({
      where: { id: attemptId },
      relations: ['quiz', 'quiz.questions', 'user', 'answers', 'answers.question'],
    });

    if (!attempt) {
      throw new AttemptNotFoundException(attemptId);
    }

    const maxScore = attempt.quiz.questions.reduce((sum, q) => sum + Number(q.points), 0);
    const percentage = maxScore > 0 ? (Number(attempt.score) / maxScore) * 100 : 0;
    const passed = attempt.quiz.passingScore
      ? percentage >= Number(attempt.quiz.passingScore)
      : true;

    const totalQuestions = attempt.quiz.questions?.length || 0;
    const answeredCount = attempt.answers?.length || 0;
    const correctCount = attempt.answers?.filter((a) => a.isCorrect === true).length || 0;
    const wrongCount = attempt.answers?.filter((a) => a.isCorrect === false).length || 0;
    const skippedCount = Math.max(0, totalQuestions - answeredCount);

    return {
      attemptId: attempt.id,
      quizId: attempt.quizId,
      quizTitle: attempt.quiz.title,
      userId: attempt.userId,
      userName: `${attempt.user?.firstName || ''} ${attempt.user?.lastName || ''}`.trim() || 'Unknown',
      attemptNumber: attempt.attemptNumber,
      score: Number(attempt.score) || 0,
      maxScore,
      percentage: Math.round(percentage * 100) / 100,
      passed,
      timeTakenMinutes: attempt.timeTakenMinutes || 0,
      status: attempt.status,
      startedAt: attempt.startedAt,
      submittedAt: attempt.submittedAt,
      correctCount,
      wrongCount,
      skippedCount,
      questions: attempt.answers.map((a) => ({
        questionId: a.questionId,
        questionText: a.question.questionText,
        questionType: a.question.questionType,
        options: a.question.options,
        studentAnswer: a.answerText || a.selectedOption?.join(', ') || '',
        correctAnswer: a.question.correctAnswer,
        isCorrect: a.isCorrect,
        pointsEarned: Number(a.pointsEarned) || 0,
        maxPoints: Number(a.question.points),
        explanation: a.question.explanation,
      })),
    };
  }
}
