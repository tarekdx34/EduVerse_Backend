import { Injectable, BadRequestException, ForbiddenException, Inject, forwardRef } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Between, Like, IsNull } from 'typeorm';
import { Quiz, QuizQuestion, QuizAttempt, QuizAnswer, QuizDifficultyLevel } from '../entities';
import { AttemptStatus, QuestionType, QuizStatus } from '../enums';
import {
  CreateQuizDto,
  UpdateQuizDto,
  CreateQuestionDto,
  UpdateQuestionDto,
  StartAttemptDto,
  SubmitQuizDto,
  QuizQueryDto,
  AttemptQueryDto,
  QuizSummaryDto,
  QuizStatisticsDto,
  AttemptResultDto,
  StudentQuizProgressDto,
} from '../dto';
import {
  QuizNotFoundException,
  QuestionNotFoundException,
  AttemptNotFoundException,
  AttemptLimitReachedException,
  QuizTimeExpiredException,
  QuizNotAvailableException,
  AttemptAlreadySubmittedException,
} from '../exceptions';
import { Course } from '../../courses/entities/course.entity';
import { RoleName } from '../../auth/entities/role.entity';
import { CourseTA } from '../../enrollments/entities/course-ta.entity';
import { CourseInstructor } from '../../enrollments/entities/course-instructor.entity';
import { GradesService } from '../../grades/services';
import { GradeType } from '../../grades/enums';

@Injectable()
export class QuizzesService {
  constructor(
    @InjectRepository(Quiz)
    private readonly quizRepo: Repository<Quiz>,
    @InjectRepository(QuizQuestion)
    private readonly questionRepo: Repository<QuizQuestion>,
    @InjectRepository(QuizAttempt)
    private readonly attemptRepo: Repository<QuizAttempt>,
    @InjectRepository(QuizAnswer)
    private readonly answerRepo: Repository<QuizAnswer>,
    @InjectRepository(QuizDifficultyLevel)
    private readonly difficultyRepo: Repository<QuizDifficultyLevel>,
    @InjectRepository(Course)
    private readonly courseRepo: Repository<Course>,
    @InjectRepository(CourseTA)
    private readonly courseTARepo: Repository<CourseTA>,
    @InjectRepository(CourseInstructor)
    private readonly courseInstructorRepo: Repository<CourseInstructor>,
    @Inject(forwardRef(() => GradesService))
    private readonly gradesService: GradesService,
  ) {}

  // ============ QUIZ CRUD ============

  async createQuiz(dto: CreateQuizDto, createdBy: number, roles: string[]): Promise<Quiz> {
    await this.assertCourseManagementAccess(dto.courseId, createdBy, roles);

    const course = await this.courseRepo.findOne({ where: { id: dto.courseId } });
    if (!course) {
      throw new BadRequestException(`Course with ID ${dto.courseId} not found`);
    }

    const quiz = this.quizRepo.create({
      courseId: dto.courseId,
      title: dto.title,
      description: dto.description,
      instructions: dto.instructions,
      quizType: dto.quizType,
      timeLimitMinutes: dto.timeLimitMinutes,
      maxAttempts: dto.maxAttempts,
      passingScore: dto.passingScore,
      randomizeQuestions: dto.randomizeQuestions,
      showCorrectAnswers: dto.showCorrectAnswers,
      showAnswersAfter: dto.showAnswersAfter,
      availableFrom: dto.availableFrom ? new Date(dto.availableFrom) : undefined,
      availableUntil: dto.availableUntil ? new Date(dto.availableUntil) : undefined,
      weight: dto.weight,
      createdBy,
    });

    return this.quizRepo.save(quiz);
  }

  async findAllQuizzes(query: QuizQueryDto): Promise<{ data: Quiz[]; total: number }> {
    const page = query.page || 1;
    const limit = query.limit || 20;
    const skip = (page - 1) * limit;

    const qb = this.quizRepo
      .createQueryBuilder('quiz')
      .leftJoinAndSelect('quiz.course', 'course')
      .leftJoinAndSelect('quiz.creator', 'creator')
      .where('quiz.deletedAt IS NULL');

    if (query.courseId) {
      qb.andWhere('quiz.courseId = :courseId', { courseId: query.courseId });
    }

    if (query.quizType) {
      qb.andWhere('quiz.quizType = :quizType', { quizType: query.quizType });
    }

    if (query.search) {
      qb.andWhere('(quiz.title LIKE :search OR quiz.description LIKE :search)', {
        search: `%${query.search}%`,
      });
    }

    if (query.availableOnly) {
      const now = new Date();
      qb.andWhere('(quiz.availableFrom IS NULL OR quiz.availableFrom <= :now)', { now });
      qb.andWhere('(quiz.availableUntil IS NULL OR quiz.availableUntil >= :now)', { now });
    }

    const [data, total] = await qb
      .orderBy('quiz.createdAt', 'DESC')
      .skip(skip)
      .take(limit)
      .getManyAndCount();

    return { data, total };
  }

  async findQuizById(id: number): Promise<Quiz> {
    const quiz = await this.quizRepo.findOne({
      where: { id, deletedAt: IsNull() },
      relations: ['course', 'creator', 'questions', 'questions.difficultyLevel'],
    });

    if (!quiz) {
      throw new QuizNotFoundException(id);
    }

    return quiz;
  }

  async updateQuiz(id: number, dto: UpdateQuizDto, userId: number, roles: string[]): Promise<Quiz> {
    const quiz = await this.findQuizById(id);
    await this.assertQuizManagementAccess(quiz, userId, roles);

    Object.assign(quiz, {
      ...dto,
      availableFrom: dto.availableFrom ? new Date(dto.availableFrom) : quiz.availableFrom,
      availableUntil: dto.availableUntil ? new Date(dto.availableUntil) : quiz.availableUntil,
    });

    await this.quizRepo.save(quiz);
    return this.findQuizById(id);
  }

  async deleteQuiz(id: number, userId: number, roles: string[]): Promise<void> {
    const quiz = await this.findQuizById(id);
    await this.assertQuizManagementAccess(quiz, userId, roles);
    await this.quizRepo.softDelete(id);
  }

  async changeStatus(id: number, status: QuizStatus, userId: number, roles: string[]): Promise<Quiz> {
    const quiz = await this.findQuizById(id);
    await this.assertQuizManagementAccess(quiz, userId, roles);
    
    quiz.status = status;
    return this.quizRepo.save(quiz);
  }

  // ============ QUESTION MANAGEMENT ============

  async addQuestion(
    quizId: number,
    dto: CreateQuestionDto,
    userId: number,
    roles: string[],
  ): Promise<QuizQuestion> {
    const quiz = await this.findQuizById(quizId);
    await this.assertQuizManagementAccess(quiz, userId, roles);

    const maxOrder = await this.questionRepo
      .createQueryBuilder('q')
      .where('q.quizId = :quizId', { quizId })
      .select('MAX(q.orderIndex)', 'max')
      .getRawOne();

    const question = this.questionRepo.create({
      ...dto,
      quizId,
      orderIndex: dto.orderIndex ?? (maxOrder?.max ?? -1) + 1,
    });

    return this.questionRepo.save(question);
  }

  async updateQuestion(
    quizId: number,
    questionId: number,
    dto: UpdateQuestionDto,
    userId: number,
    roles: string[],
  ): Promise<QuizQuestion> {
    const quiz = await this.findQuizById(quizId);
    await this.assertQuizManagementAccess(quiz, userId, roles);

    const question = await this.questionRepo.findOne({
      where: { id: questionId, quizId },
    });

    if (!question) {
      throw new QuestionNotFoundException(questionId);
    }

    Object.assign(question, dto);
    await this.questionRepo.save(question);

    const updated = await this.questionRepo.findOne({
      where: { id: questionId },
      relations: ['difficultyLevel'],
    });

    if (!updated) {
      throw new QuestionNotFoundException(questionId);
    }

    return updated;
  }

  async deleteQuestion(
    quizId: number,
    questionId: number,
    userId: number,
    roles: string[],
  ): Promise<void> {
    const quiz = await this.findQuizById(quizId);
    await this.assertQuizManagementAccess(quiz, userId, roles);

    const question = await this.questionRepo.findOne({
      where: { id: questionId, quizId },
    });

    if (!question) {
      throw new QuestionNotFoundException(questionId);
    }

    await this.questionRepo.delete(questionId);
  }

  async reorderQuestions(quizId: number, questionIds: number[]): Promise<QuizQuestion[]> {
    const quiz = await this.findQuizById(quizId);

    for (let i = 0; i < questionIds.length; i++) {
      await this.questionRepo.update(
        { id: questionIds[i], quizId },
        { orderIndex: i },
      );
    }

    return this.questionRepo.find({
      where: { quizId },
      order: { orderIndex: 'ASC' },
    });
  }

  // ============ QUIZ ATTEMPTS ============

  async startAttempt(quizId: number, userId: number, dto: StartAttemptDto): Promise<QuizAttempt> {
    const quiz = await this.findQuizById(quizId);

    // Check availability
    this.checkQuizAvailability(quiz);

    // Check attempt limit
    const existingAttempts = await this.attemptRepo.count({
      where: { quizId, userId },
    });

    if (existingAttempts >= quiz.maxAttempts) {
      throw new AttemptLimitReachedException(quizId, quiz.maxAttempts);
    }

    // Check for in-progress attempt
    const inProgress = await this.attemptRepo.findOne({
      where: { quizId, userId, status: AttemptStatus.IN_PROGRESS },
    });

    if (inProgress) {
      // Resume existing attempt
      return this.getAttemptWithQuestions(inProgress.id);
    }

    const attempt = this.attemptRepo.create({
      quizId,
      userId,
      attemptNumber: existingAttempts + 1,
      status: AttemptStatus.IN_PROGRESS,
      ipAddress: dto.ipAddress,
    });

    const saved = await this.attemptRepo.save(attempt);
    return this.getAttemptWithQuestions(saved.id);
  }

  async getAttemptWithQuestions(attemptId: number): Promise<QuizAttempt> {
    const attempt = await this.attemptRepo.findOne({
      where: { id: attemptId },
      relations: ['quiz', 'quiz.questions', 'quiz.questions.difficultyLevel', 'answers'],
    });

    if (!attempt) {
      throw new AttemptNotFoundException(attemptId);
    }

    // If randomize is enabled, shuffle questions
    if (attempt.quiz.randomizeQuestions) {
      attempt.quiz.questions = this.shuffleArray([...attempt.quiz.questions]);
    } else {
      attempt.quiz.questions.sort((a, b) => a.orderIndex - b.orderIndex);
    }

    // Hide correct answers during attempt
    for (const q of attempt.quiz.questions) {
      (q as any).correctAnswer = null;
      (q as any).explanation = null;
    }

    return attempt;
  }

  async submitAttempt(attemptId: number, userId: number, dto: SubmitQuizDto): Promise<AttemptResultDto> {
    const attempt = await this.attemptRepo.findOne({
      where: { id: attemptId, userId },
      relations: ['quiz', 'quiz.questions'],
    });

    if (!attempt) {
      throw new AttemptNotFoundException(attemptId);
    }

    if (attempt.status !== AttemptStatus.IN_PROGRESS) {
      throw new AttemptAlreadySubmittedException(attemptId);
    }

    // Check time limit
    if (attempt.quiz.timeLimitMinutes) {
      const elapsed = (Date.now() - attempt.startedAt.getTime()) / 60000;
      if (elapsed > attempt.quiz.timeLimitMinutes + 1) { // 1 min grace
        throw new QuizTimeExpiredException(attemptId);
      }
    }

    // Save answers
    for (const answerDto of dto.answers) {
      const question = attempt.quiz.questions.find((q) => q.id === answerDto.questionId);
      if (!question) continue;

      const answer = this.answerRepo.create({
        attemptId,
        questionId: answerDto.questionId,
        answerText: answerDto.answerText,
        selectedOption: answerDto.selectedOption,
      });

      await this.answerRepo.save(answer);
    }

    // Auto-grade MCQ and True/False
    await this.autoGradeAttempt(attemptId);

    // Calculate final score
    const answers = await this.answerRepo.find({ where: { attemptId } });
    const totalScore = answers.reduce((sum, a) => sum + Number(a.pointsEarned || 0), 0);
    const maxScore = attempt.quiz.questions.reduce((sum, q) => sum + Number(q.points), 0);

    const timeTaken = Math.round((Date.now() - attempt.startedAt.getTime()) / 60000);

    // Determine status based on whether manual grading is needed
    const needsManualGrading = attempt.quiz.questions.some(
      (q) => q.questionType === QuestionType.SHORT_ANSWER || q.questionType === QuestionType.ESSAY,
    );

    const finalStatus = needsManualGrading ? AttemptStatus.SUBMITTED : AttemptStatus.GRADED;

    await this.attemptRepo.update(attemptId, {
      submittedAt: new Date(),
      score: totalScore,
      timeTakenMinutes: timeTaken,
      status: finalStatus,
    });

    // Create grade record in central grades table if fully graded (no manual grading needed)
    if (!needsManualGrading) {
      await this.gradesService.createGrade({
        userId: userId,
        courseId: attempt.quiz.courseId,
        gradeType: GradeType.QUIZ,
        quizId: attempt.quiz.id,
        score: totalScore,
        maxScore: maxScore,
        isPublished: true,
      }, attempt.quiz.createdBy);
    }

    return this.getAttemptResult(attemptId, userId);
  }

  private async autoGradeAttempt(attemptId: number): Promise<void> {
    const answers = await this.answerRepo.find({
      where: { attemptId },
      relations: ['question'],
    });

    for (const answer of answers) {
      if (
        answer.question.questionType === QuestionType.MCQ ||
        answer.question.questionType === QuestionType.TRUE_FALSE
      ) {
        const isCorrect = this.checkAnswer(answer.question, answer);
        await this.answerRepo.update(answer.id, {
          isCorrect,
          pointsEarned: isCorrect ? answer.question.points : 0,
        });
      }
    }
  }

  private checkAnswer(question: QuizQuestion, answer: QuizAnswer): boolean {
    if (!question.correctAnswer) return false;

    if (question.questionType === QuestionType.MCQ) {
      // For MCQ, correctAnswer is the index
      return answer.selectedOption?.includes(question.correctAnswer);
    }

    if (question.questionType === QuestionType.TRUE_FALSE) {
      const studentAnswer = answer.answerText?.toLowerCase() || answer.selectedOption?.[0]?.toLowerCase();
      return studentAnswer === question.correctAnswer.toLowerCase();
    }

    return false;
  }

  async getAttemptResult(attemptId: number, userId: number): Promise<AttemptResultDto> {
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

    // Determine if we should show answers
    const showAnswers = this.shouldShowAnswers(attempt.quiz, attempt);

    const result: AttemptResultDto = {
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
    };

    if (showAnswers) {
      result.questions = attempt.answers.map((a) => ({
        questionId: a.questionId,
        questionText: a.question.questionText,
        questionType: a.question.questionType,
        options: a.question.options,
        studentAnswer: a.answerText || a.selectedOption?.join(', ') || '',
        correctAnswer: attempt.quiz.showCorrectAnswers ? a.question.correctAnswer : undefined,
        isCorrect: a.isCorrect,
        pointsEarned: Number(a.pointsEarned) || 0,
        maxPoints: Number(a.question.points),
        explanation: attempt.quiz.showCorrectAnswers ? a.question.explanation : undefined,
      }));
    }

    return result;
  }

  private shouldShowAnswers(quiz: Quiz, attempt: QuizAttempt): boolean {
    if (quiz.showAnswersAfter === 'immediate') return true;
    if (quiz.showAnswersAfter === 'never') return false;
    // after_due - check if past availableUntil
    if (quiz.availableUntil && new Date() > quiz.availableUntil) return true;
    return false;
  }

  private checkQuizAvailability(quiz: Quiz): void {
    const now = new Date();

    if (quiz.availableFrom && now < quiz.availableFrom) {
      throw new QuizNotAvailableException(quiz.id, `Quiz is not available until ${quiz.availableFrom.toISOString()}`);
    }

    if (quiz.availableUntil && now > quiz.availableUntil) {
      throw new QuizNotAvailableException(quiz.id, `Quiz closed on ${quiz.availableUntil.toISOString()}`);
    }
  }

  // ============ STATISTICS & SUMMARIES ============

  async getQuizStatistics(quizId: number): Promise<QuizStatisticsDto> {
    const quiz = await this.findQuizById(quizId);

    const attempts = await this.attemptRepo.find({
      where: { quizId, status: AttemptStatus.GRADED },
    });

    if (attempts.length === 0) {
      return {
        quizId,
        title: quiz.title,
        totalAttempts: 0,
        completedAttempts: 0,
        averageScore: 0,
        highestScore: 0,
        lowestScore: 0,
        passRate: 0,
        averageTimeTaken: 0,
      };
    }

    const scores = attempts.map((a) => Number(a.score) || 0);
    const times = attempts.map((a) => a.timeTakenMinutes || 0);
    const passed = quiz.passingScore
      ? attempts.filter((a) => Number(a.score) >= Number(quiz.passingScore)).length
      : attempts.length;

    return {
      quizId,
      title: quiz.title,
      totalAttempts: await this.attemptRepo.count({ where: { quizId } }),
      completedAttempts: attempts.length,
      averageScore: Math.round((scores.reduce((a, b) => a + b, 0) / scores.length) * 100) / 100,
      highestScore: Math.max(...scores),
      lowestScore: Math.min(...scores),
      passRate: Math.round((passed / attempts.length) * 100),
      averageTimeTaken: Math.round(times.reduce((a, b) => a + b, 0) / times.length),
    };
  }

  async getStudentProgress(userId: number, courseId: number): Promise<StudentQuizProgressDto> {
    const course = await this.courseRepo.findOne({ where: { id: courseId } });
    if (!course) {
      throw new BadRequestException(`Course ${courseId} not found`);
    }

    const quizzes = await this.quizRepo.find({
      where: { courseId, deletedAt: IsNull() },
      relations: ['questions'],
    });

    const quizSummaries: QuizSummaryDto[] = [];
    let totalCompleted = 0;
    let totalScore = 0;

    for (const quiz of quizzes) {
      const attempts = await this.attemptRepo.find({
        where: { quizId: quiz.id, userId },
        order: { score: 'DESC' },
      });

      const bestAttempt = attempts.find((a) => a.status === AttemptStatus.GRADED);
      const isCompleted = !!bestAttempt;

      if (isCompleted) {
        totalCompleted++;
        totalScore += Number(bestAttempt.score) || 0;
      }

      quizSummaries.push({
        id: quiz.id,
        title: quiz.title,
        quizType: quiz.quizType,
        questionCount: quiz.questions?.length || 0,
        timeLimitMinutes: quiz.timeLimitMinutes,
        maxAttempts: quiz.maxAttempts,
        attemptsUsed: attempts.length,
        bestScore: bestAttempt ? Number(bestAttempt.score) : undefined,
        isAvailable: this.isQuizAvailable(quiz),
        availableFrom: quiz.availableFrom,
        availableUntil: quiz.availableUntil,
      });
    }

    return {
      courseId,
      courseName: course.name,
      totalQuizzes: quizzes.length,
      completedQuizzes: totalCompleted,
      averageScore: totalCompleted > 0 ? Math.round((totalScore / totalCompleted) * 100) / 100 : 0,
      quizzes: quizSummaries,
    };
  }

  async findAttemptsByQuery(query: AttemptQueryDto): Promise<{ data: QuizAttempt[]; total: number }> {
    const page = query.page || 1;
    const limit = query.limit || 20;
    const skip = (page - 1) * limit;

    const qb = this.attemptRepo
      .createQueryBuilder('attempt')
      .leftJoinAndSelect('attempt.quiz', 'quiz')
      .leftJoinAndSelect('attempt.user', 'user');

    if (query.quizId) {
      qb.andWhere('attempt.quizId = :quizId', { quizId: query.quizId });
    }

    if (query.userId) {
      qb.andWhere('attempt.userId = :userId', { userId: query.userId });
    }

    if (query.status) {
      qb.andWhere('attempt.status = :status', { status: query.status });
    }

    if (query.startDate && query.endDate) {
      qb.andWhere('attempt.startedAt BETWEEN :start AND :end', {
        start: new Date(query.startDate),
        end: new Date(query.endDate),
      });
    }

    const [data, total] = await qb
      .orderBy('attempt.startedAt', 'DESC')
      .skip(skip)
      .take(limit)
      .getManyAndCount();

    return { data, total };
  }

  async getDifficultyLevels(): Promise<QuizDifficultyLevel[]> {
    return this.difficultyRepo.find({ order: { difficultyValue: 'ASC' } });
  }

  private isQuizAvailable(quiz: Quiz): boolean {
    const now = new Date();
    if (quiz.availableFrom && now < quiz.availableFrom) return false;
    if (quiz.availableUntil && now > quiz.availableUntil) return false;
    return true;
  }

  private shuffleArray<T>(array: T[]): T[] {
    for (let i = array.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [array[i], array[j]] = [array[j], array[i]];
    }
    return array;
  }

  private async assertCourseManagementAccess(
    courseId: number,
    userId: number,
    roles: string[],
  ): Promise<void> {
    if (roles.some((role) => [RoleName.ADMIN, RoleName.IT_ADMIN].includes(role as RoleName))) {
      return;
    }

    const [instructorAssignment, taAssignment] = await Promise.all([
      this.courseInstructorRepo
        .createQueryBuilder('assignment')
        .innerJoin('assignment.section', 'section')
        .where('assignment.userId = :userId', { userId })
        .andWhere('section.courseId = :courseId', { courseId })
        .getOne(),
      this.courseTARepo
        .createQueryBuilder('assignment')
        .innerJoin('assignment.section', 'section')
        .where('assignment.userId = :userId', { userId })
        .andWhere('section.courseId = :courseId', { courseId })
        .getOne(),
    ]);

    if (!instructorAssignment && !taAssignment) {
      throw new ForbiddenException('You do not have access to manage quizzes for this course');
    }
  }

  private async assertQuizManagementAccess(
    quiz: Quiz,
    userId: number,
    roles: string[],
  ): Promise<void> {
    if (roles.some((role) => [RoleName.ADMIN, RoleName.IT_ADMIN].includes(role as RoleName))) {
      return;
    }

    if (Number(quiz.createdBy) === userId) {
      return;
    }

    await this.assertCourseManagementAccess(Number(quiz.courseId), userId, roles);
  }
}
