import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  Query,
  ParseIntPipe,
  UseGuards,
  Req,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
  ApiParam,
  ApiQuery,
  ApiBody,
  ApiHeader,
} from '@nestjs/swagger';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../auth/guards/roles.guard';
import { Roles } from '../../auth/roles.decorator';
import { RoleName } from '../../auth/entities/role.entity';
import { QuizzesService } from '../services/quizzes.service';
import { QuizGradingService } from '../services/quiz-grading.service';
import {
  CreateQuizDto,
  UpdateQuizDto,
  CreateQuestionDto,
  UpdateQuestionDto,
  StartAttemptDto,
  SubmitQuizDto,
  QuizQueryDto,
  AttemptQueryDto,
  ManualGradeDto,
  AttemptResultDto,
  QuizStatisticsDto,
  StudentQuizProgressDto,
  ReorderQuestionsDto,
} from '../dto';
import { Quiz, QuizQuestion, QuizAttempt, QuizDifficultyLevel } from '../entities';

@ApiTags('📝 Quizzes')
@ApiBearerAuth('JWT-auth')
@UseGuards(JwtAuthGuard, RolesGuard)
@Controller('quizzes')
@ApiHeader({
  name: 'Accept-Language',
  description: 'Language preference (en, ar)',
  required: false,
  example: 'en',
})
export class QuizzesController {
  constructor(
    private readonly quizzesService: QuizzesService,
    private readonly gradingService: QuizGradingService,
  ) {}

  // ============ QUIZ CRUD ============

  @Post()
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN)
  @ApiOperation({
    summary: 'Create a new quiz',
    description: `
## Create Quiz

Creates a new quiz for a course with configurable settings.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: INSTRUCTOR, TA, ADMIN

### Required Fields
- \`courseId\`: Course the quiz belongs to
- \`title\`: Quiz title

### Optional Fields
- \`description\`: Quiz description/instructions
- \`quizType\`: Type (practice, graded, midterm, final)
- \`timeLimitMinutes\`: Time limit for completion
- \`maxAttempts\`: Maximum allowed attempts (null = unlimited)
- \`passingScore\`: Minimum percentage to pass
- \`randomizeQuestions\`: Shuffle question order per attempt
- \`showCorrectAnswers\`: When to reveal answers
- \`availableFrom\` / \`availableUntil\`: Availability window
- \`weight\`: Grade weight in the course

### Behavior
- Quiz is created in \`draft\` status
- Add questions before publishing
- Students cannot see draft quizzes
    `,
  })
  @ApiBody({ type: CreateQuizDto })
  @ApiResponse({ status: 201, description: 'Quiz created successfully', type: Quiz })
  @ApiResponse({ status: 400, description: 'Invalid input or course not found' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - insufficient permissions' })
  async createQuiz(@Body() dto: CreateQuizDto, @Req() req: any): Promise<Quiz> {
    return this.quizzesService.createQuiz(dto, req.user.userId);
  }

  @Get()
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN, RoleName.STUDENT)
  @ApiOperation({
    summary: 'Get all quizzes with filters',
    description: `
## List All Quizzes

Retrieves a paginated list of quizzes with optional filters.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: INSTRUCTOR, TA, ADMIN, STUDENT

### Role-Based Visibility
- **Instructors/TAs/Admins**: See all quizzes including drafts
- **Students**: See only published quizzes within availability window

### Filtering Options
- \`courseId\`: Filter by specific course
- \`quizType\`: Filter by type (practice, graded, midterm, final)
- \`availableOnly\`: Show only currently available quizzes
- \`search\`: Search by quiz title or description

### Pagination
- \`page\`: Page number (default: 1)
- \`limit\`: Items per page (default: 20, max: 100)

### Response
Returns \`data\` array with quizzes and \`total\` count for pagination.
    `,
  })
  @ApiQuery({ name: 'courseId', required: false, type: Number, description: 'Filter by course ID' })
  @ApiQuery({ name: 'quizType', required: false, enum: ['practice', 'graded', 'midterm', 'final'] })
  @ApiQuery({ name: 'availableOnly', required: false, type: Boolean })
  @ApiQuery({ name: 'search', required: false, type: String })
  @ApiQuery({ name: 'page', required: false, type: Number, example: 1 })
  @ApiQuery({ name: 'limit', required: false, type: Number, example: 20 })
  @ApiResponse({ status: 200, description: 'List of quizzes returned' })
  async findAllQuizzes(@Query() query: QuizQueryDto): Promise<{ data: Quiz[]; total: number }> {
    return this.quizzesService.findAllQuizzes(query);
  }

  @Get('difficulty-levels')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN)
  @ApiOperation({
    summary: 'Get available difficulty levels',
    description: `
## Get Difficulty Levels

Returns all available difficulty levels for quiz questions.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: INSTRUCTOR, TA, ADMIN

### Response Includes
Array of difficulty levels with:
- \`difficultyId\`: Unique identifier
- \`levelName\`: Name (Easy, Medium, Hard, etc.)
- \`difficultyValue\`: Numeric value for sorting/filtering
- \`description\`: Description of the difficulty level

### Use Cases
- Populate dropdown when creating questions
- Filter questions by difficulty for quiz creation
    `,
  })
  @ApiResponse({ status: 200, description: 'Difficulty levels returned', type: [QuizDifficultyLevel] })
  async getDifficultyLevels(): Promise<QuizDifficultyLevel[]> {
    return this.quizzesService.getDifficultyLevels();
  }

  @Get('my-attempts')
  @Roles(RoleName.STUDENT)
  @ApiOperation({
    summary: "Get current student's quiz attempts",
    description: `
## My Quiz Attempts

Returns all quiz attempts for the authenticated student.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: STUDENT

### Filtering Options
- \`quizId\`: Filter by specific quiz
- \`status\`: Filter by status (in_progress, submitted, graded, abandoned)

### Pagination
- \`page\`: Page number (default: 1)
- \`limit\`: Items per page (default: 20)

### Response Includes
For each attempt:
- Quiz information
- Start/submit timestamps
- Score and status
- Time taken

### Use Cases
- View attempt history
- Resume in-progress attempts
- Review past performance
    `,
  })
  @ApiQuery({ name: 'quizId', required: false, type: Number })
  @ApiQuery({ name: 'status', required: false, enum: ['in_progress', 'submitted', 'graded', 'abandoned'] })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  @ApiResponse({ status: 200, description: 'List of student attempts' })
  async getMyAttempts(@Query() query: AttemptQueryDto, @Req() req: any): Promise<{ data: QuizAttempt[]; total: number }> {
    return this.quizzesService.findAttemptsByQuery({ ...query, userId: req.user.userId });
  }

  @Get('attempts')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN)
  @ApiOperation({
    summary: 'List all quiz attempts (instructor view)',
    description: `
## List Quiz Attempts

Retrieves a paginated list of quiz attempts with optional filters. For instructor/TA grading and review.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: INSTRUCTOR, TA, ADMIN

### Filtering Options
- \`quizId\`: Filter by specific quiz
- \`userId\`: Filter by specific student
- \`status\`: Filter by attempt status (in_progress, submitted, graded, abandoned)
- \`startDate\` / \`endDate\`: Filter by date range

### Pagination
- \`page\`: Page number (default: 1)
- \`limit\`: Items per page (default: 20, max: 100)

### Response Includes
For each attempt:
- Student information
- Quiz information
- Start/submit timestamps
- Score and status
- Grading status
    `,
  })
  @ApiQuery({ name: 'quizId', required: false, type: Number })
  @ApiQuery({ name: 'userId', required: false, type: Number })
  @ApiQuery({ name: 'status', required: false, enum: ['in_progress', 'submitted', 'graded', 'abandoned'] })
  @ApiQuery({ name: 'startDate', required: false, type: String, example: '2026-01-01' })
  @ApiQuery({ name: 'endDate', required: false, type: String, example: '2026-03-31' })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  @ApiResponse({ status: 200, description: 'List of attempts' })
  async findAttempts(@Query() query: AttemptQueryDto): Promise<{ data: QuizAttempt[]; total: number }> {
    return this.quizzesService.findAttemptsByQuery(query);
  }

  @Get(':id')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN, RoleName.STUDENT)
  @ApiOperation({
    summary: 'Get quiz by ID with questions',
    description: `
## Get Quiz Details

Retrieves detailed information about a specific quiz including its questions.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: INSTRUCTOR, TA, ADMIN, STUDENT

### Role-Based Response
- **Instructors/TAs/Admins**: Full details including correct answers
- **Students**: Questions without correct answers (unless allowed by quiz settings)

### Response Includes
- Quiz metadata (title, description, settings)
- Course information
- Time limit, attempts allowed, passing score
- All questions with their options
- Availability window
    `,
  })
  @ApiParam({ name: 'id', description: 'Quiz ID', type: Number })
  @ApiResponse({ status: 200, description: 'Quiz found', type: Quiz })
  @ApiResponse({ status: 404, description: 'Quiz not found' })
  async findQuizById(@Param('id', ParseIntPipe) id: number): Promise<Quiz> {
    return this.quizzesService.findQuizById(id);
  }

  @Put(':id')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN)
  @ApiOperation({
    summary: 'Update quiz settings',
    description: `
## Update Quiz

Updates quiz settings and metadata. Does not modify individual questions.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: INSTRUCTOR, TA, ADMIN

### Updatable Fields
All fields from CreateQuizDto can be updated:
- Title, description, instructions
- Time limit, max attempts, passing score
- Randomization settings
- Availability window
- Answer visibility settings

### Important Notes
- Cannot update a quiz that has active attempts
- Changing time limit won't affect in-progress attempts
- Use separate endpoints for question management
    `,
  })
  @ApiParam({ name: 'id', description: 'Quiz ID', type: Number })
  @ApiBody({ type: UpdateQuizDto })
  @ApiResponse({ status: 200, description: 'Quiz updated', type: Quiz })
  @ApiResponse({ status: 404, description: 'Quiz not found' })
  async updateQuiz(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateQuizDto,
  ): Promise<Quiz> {
    return this.quizzesService.updateQuiz(id, dto);
  }

  @Delete(':id')
  @Roles(RoleName.INSTRUCTOR, RoleName.ADMIN)
  @ApiOperation({
    summary: 'Delete quiz (soft delete)',
    description: `
## Delete Quiz

Soft deletes a quiz. The quiz data is preserved but hidden from users.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: INSTRUCTOR, ADMIN
- TAs cannot delete quizzes

### Behavior
- Sets \`deleted_at\` timestamp (soft delete)
- Quiz no longer appears in listings
- Existing attempts and grades are preserved
- Cannot be undone via API (requires database intervention)

### When to Use
- Quiz created by mistake
- Obsolete quiz no longer needed
- Do NOT use for temporarily hiding a quiz (use status instead)
    `,
  })
  @ApiParam({ name: 'id', description: 'Quiz ID', type: Number })
  @ApiResponse({ status: 200, description: 'Quiz deleted' })
  @ApiResponse({ status: 404, description: 'Quiz not found' })
  async deleteQuiz(@Param('id', ParseIntPipe) id: number): Promise<{ message: string }> {
    await this.quizzesService.deleteQuiz(id);
    return { message: 'Quiz deleted successfully' };
  }

  // ============ QUESTION MANAGEMENT ============

  @Post(':quizId/questions')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN)
  @ApiOperation({
    summary: 'Add question to quiz',
    description: `
## Add Question

Adds a new question to an existing quiz.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: INSTRUCTOR, TA, ADMIN

### Required Fields
- \`questionText\`: The question content
- \`questionType\`: Type (mcq, true_false, short_answer, essay, matching)
- \`points\`: Points awarded for correct answer

### Question Type Specific Fields
**MCQ (Multiple Choice)**:
- \`options\`: Array of answer options
- \`correctAnswer\`: Index of correct option (0-based)

**True/False**:
- \`correctAnswer\`: "true" or "false"

**Short Answer**:
- \`correctAnswer\`: Expected answer text (for auto-grading)

**Essay**:
- No correct answer (requires manual grading)

**Matching**:
- \`options\`: { left: [...], right: [...] }
- \`correctAnswer\`: Mapping of left to right indices

### Optional Fields
- \`explanation\`: Explanation shown after quiz
- \`difficultyLevelId\`: Reference to difficulty level
- \`orderIndex\`: Position in quiz (auto-assigned if not provided)
    `,
  })
  @ApiParam({ name: 'quizId', description: 'Quiz ID', type: Number })
  @ApiBody({ type: CreateQuestionDto })
  @ApiResponse({ status: 201, description: 'Question added', type: QuizQuestion })
  @ApiResponse({ status: 404, description: 'Quiz not found' })
  async addQuestion(
    @Param('quizId', ParseIntPipe) quizId: number,
    @Body() dto: CreateQuestionDto,
  ): Promise<QuizQuestion> {
    return this.quizzesService.addQuestion(quizId, dto);
  }

  @Put(':quizId/questions/reorder')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN)
  @ApiOperation({
    summary: 'Reorder quiz questions',
    description: `
## Reorder Questions

Sets the display order for all questions in a quiz.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: INSTRUCTOR, TA, ADMIN

### Request Body
\`\`\`json
{
  "questionIds": [5, 3, 1, 4, 2]
}
\`\`\`
Array of question IDs in desired order.

### Behavior
- All question IDs must belong to the specified quiz
- Order index is assigned based on array position
- Missing question IDs will retain their current position

### Note
If \`randomizeQuestions\` is enabled for the quiz, this order only affects the instructor view.
    `,
  })
  @ApiParam({ name: 'quizId', description: 'Quiz ID', type: Number })
  @ApiBody({ type: ReorderQuestionsDto })
  @ApiResponse({ status: 200, description: 'Questions reordered', type: [QuizQuestion] })
  async reorderQuestions(
    @Param('quizId', ParseIntPipe) quizId: number,
    @Body() dto: ReorderQuestionsDto,
  ): Promise<QuizQuestion[]> {
    return this.quizzesService.reorderQuestions(quizId, dto.questionIds);
  }

  @Put(':quizId/questions/:questionId')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN)
  @ApiOperation({
    summary: 'Update quiz question',
    description: `
## Update Question

Updates an existing question in a quiz.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: INSTRUCTOR, TA, ADMIN

### Updatable Fields
All CreateQuestionDto fields can be updated:
- Question text
- Options and correct answer
- Points
- Explanation
- Difficulty level

### Important Notes
- Changing a question after students have attempted may affect grade consistency
- Consider creating a new question instead if quiz has been taken
    `,
  })
  @ApiParam({ name: 'quizId', description: 'Quiz ID', type: Number })
  @ApiParam({ name: 'questionId', description: 'Question ID', type: Number })
  @ApiBody({ type: UpdateQuestionDto })
  @ApiResponse({ status: 200, description: 'Question updated', type: QuizQuestion })
  @ApiResponse({ status: 404, description: 'Question not found' })
  async updateQuestion(
    @Param('quizId', ParseIntPipe) quizId: number,
    @Param('questionId', ParseIntPipe) questionId: number,
    @Body() dto: UpdateQuestionDto,
  ): Promise<QuizQuestion> {
    return this.quizzesService.updateQuestion(quizId, questionId, dto);
  }

  @Delete(':quizId/questions/:questionId')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN)
  @ApiOperation({
    summary: 'Delete question from quiz',
    description: `
## Delete Question

Removes a question from a quiz.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: INSTRUCTOR, TA, ADMIN

### Behavior
- Question is permanently deleted
- Remaining questions maintain their order
- Existing answers referencing this question are orphaned

### Caution
- Do not delete questions from quizzes that have been attempted
- This may invalidate existing scores
    `,
  })
  @ApiParam({ name: 'quizId', description: 'Quiz ID', type: Number })
  @ApiParam({ name: 'questionId', description: 'Question ID', type: Number })
  @ApiResponse({ status: 200, description: 'Question deleted' })
  @ApiResponse({ status: 404, description: 'Question not found' })
  async deleteQuestion(
    @Param('quizId', ParseIntPipe) quizId: number,
    @Param('questionId', ParseIntPipe) questionId: number,
  ): Promise<{ message: string }> {
    await this.quizzesService.deleteQuestion(quizId, questionId);
    return { message: 'Question deleted successfully' };
  }

  // ============ QUIZ ATTEMPTS ============

  @Post(':quizId/attempts/start')
  @Roles(RoleName.STUDENT)
  @ApiOperation({
    summary: 'Start a quiz attempt',
    description: `
## Start Quiz Attempt

Starts a new quiz attempt for the authenticated student.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: STUDENT

### Prerequisites
- Quiz must be published and within availability window
- Student must not have exceeded \`maxAttempts\`
- No in-progress attempt exists for this quiz

### Behavior
- Creates new attempt record with \`in_progress\` status
- Records start time for time limit enforcement
- Logs student IP address
- If \`randomizeQuestions\` is enabled, questions are shuffled

### Response Includes
- Attempt ID (needed for submission)
- Quiz questions (without correct answers)
- Time remaining (if time limited)
- Start timestamp

### Important
- Timer starts immediately upon calling this endpoint
- Time limit is enforced on submission
    `,
  })
  @ApiParam({ name: 'quizId', description: 'Quiz ID', type: Number })
  @ApiBody({ type: StartAttemptDto })
  @ApiResponse({ status: 201, description: 'Attempt started', type: QuizAttempt })
  @ApiResponse({ status: 400, description: 'Quiz not available or attempt limit reached' })
  async startAttempt(
    @Param('quizId', ParseIntPipe) quizId: number,
    @Body() dto: StartAttemptDto,
    @Req() req: any,
  ): Promise<QuizAttempt> {
    return this.quizzesService.startAttempt(quizId, req.user.userId, dto);
  }

  @Post('attempts/:attemptId/submit')
  @Roles(RoleName.STUDENT)
  @ApiOperation({
    summary: 'Submit quiz answers',
    description: `
## Submit Quiz

Submits answers and completes the quiz attempt.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: STUDENT

### Request Body
\`\`\`json
{
  "answers": [
    { "questionId": 1, "selectedOption": 2 },
    { "questionId": 2, "answerText": "true" },
    { "questionId": 3, "answerText": "Essay response here..." }
  ]
}
\`\`\`

### Validation
- Attempt must be \`in_progress\` status
- Cannot submit after time limit expires
- Student must own the attempt

### Auto-Grading
- **MCQ**: Immediately graded
- **True/False**: Immediately graded
- **Short Answer**: Auto-graded if exact match, otherwise manual
- **Essay**: Always requires manual grading

### Response Includes
- Final score (for auto-graded questions)
- Per-question results (if \`showCorrectAnswers\` allows)
- Passing status
- Time taken

### Late Submissions
If submitted after time limit, the attempt is marked but may be flagged for review.
    `,
  })
  @ApiParam({ name: 'attemptId', description: 'Attempt ID', type: Number })
  @ApiBody({ type: SubmitQuizDto })
  @ApiResponse({ status: 200, description: 'Quiz submitted, returns results', type: AttemptResultDto })
  @ApiResponse({ status: 400, description: 'Time expired or already submitted' })
  @ApiResponse({ status: 404, description: 'Attempt not found' })
  async submitAttempt(
    @Param('attemptId', ParseIntPipe) attemptId: number,
    @Body() dto: SubmitQuizDto,
    @Req() req: any,
  ): Promise<AttemptResultDto> {
    return this.quizzesService.submitAttempt(attemptId, req.user.userId, dto);
  }

  @Get('attempts/:attemptId')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN, RoleName.STUDENT)
  @ApiOperation({
    summary: 'Get attempt result details',
    description: `
## Get Attempt Result

Retrieves detailed results for a specific quiz attempt.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: INSTRUCTOR, TA, ADMIN, STUDENT

### Authorization
- Students can only view their own attempts
- Instructors/TAs/Admins can view any attempt

### Response Includes
- Attempt metadata (started, submitted, time taken)
- Score and passing status
- Per-question breakdown:
  - Student's answer
  - Correct answer (based on \`showCorrectAnswers\` setting)
  - Points earned
  - Explanation (if provided)

### Answer Visibility Rules
Controlled by quiz \`showCorrectAnswers\` setting:
- \`immediate\`: Show right after submission
- \`after_due\`: Show after \`availableUntil\` date
- \`never\`: Never show correct answers
    `,
  })
  @ApiParam({ name: 'attemptId', description: 'Attempt ID', type: Number })
  @ApiResponse({ status: 200, description: 'Attempt result', type: AttemptResultDto })
  @ApiResponse({ status: 404, description: 'Attempt not found' })
  async getAttemptResult(
    @Param('attemptId', ParseIntPipe) attemptId: number,
    @Req() req: any,
  ): Promise<AttemptResultDto> {
    return this.quizzesService.getAttemptResult(attemptId, req.user.userId);
  }

  // ============ GRADING ============

  @Post('attempts/:attemptId/grade')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN)
  @ApiOperation({
    summary: 'Apply manual grades to attempt',
    description: `
## Manual Grading

Apply manual grades to essay and short answer questions that require human evaluation.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: INSTRUCTOR, TA, ADMIN

### Request Body
\`\`\`json
{
  "grades": [
    { "answerId": 1, "pointsEarned": 8, "feedback": "Good explanation but missing key concept" },
    { "answerId": 2, "pointsEarned": 10, "feedback": "Excellent response!" }
  ]
}
\`\`\`

### Behavior
- Updates points earned for specified answers
- Recalculates total attempt score
- Changes attempt status to \`graded\` when all questions are graded
- Optionally adds feedback visible to student

### Validation
- Points cannot exceed question's max points
- Points cannot be negative
- Answer must belong to the specified attempt
    `,
  })
  @ApiParam({ name: 'attemptId', description: 'Attempt ID', type: Number })
  @ApiBody({ type: ManualGradeDto })
  @ApiResponse({ status: 200, description: 'Grades applied', type: AttemptResultDto })
  @ApiResponse({ status: 404, description: 'Attempt not found' })
  async applyManualGrades(
    @Param('attemptId', ParseIntPipe) attemptId: number,
    @Body() dto: ManualGradeDto,
  ): Promise<AttemptResultDto> {
    return this.gradingService.applyManualGrades(attemptId, dto);
  }

  @Get('attempts/:attemptId/pending-grading')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN)
  @ApiOperation({
    summary: 'Get questions needing manual grading',
    description: `
## Get Pending Grading

Returns essay and short answer questions that require manual grading for a specific attempt.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: INSTRUCTOR, TA, ADMIN

### Response Includes
Array of answers needing grading:
- Question text
- Student's answer
- Max points for question
- Current points (0 if ungraded)
- Question type

### Use Cases
- Build grading queue for instructors
- Show count of pending grades on dashboard
- Filter to find specific types of questions
    `,
  })
  @ApiParam({ name: 'attemptId', description: 'Attempt ID', type: Number })
  @ApiResponse({ status: 200, description: 'Questions needing grading' })
  async getQuestionsNeedingGrading(@Param('attemptId', ParseIntPipe) attemptId: number) {
    return this.gradingService.getQuestionsNeedingGrading(attemptId);
  }

  // ============ STATISTICS & PROGRESS ============

  @Get(':quizId/statistics')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN)
  @ApiOperation({
    summary: 'Get quiz analytics and statistics',
    description: `
## Quiz Statistics

Returns comprehensive analytics and statistics for a quiz.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: INSTRUCTOR, TA, ADMIN

### Response Includes
**Overall Statistics**:
- Total attempts
- Unique students attempted
- Average score
- Highest/Lowest scores
- Pass rate percentage
- Average time to complete

**Score Distribution**:
- Histogram of score ranges
- Median score

**Per-Question Analytics**:
- Correct answer percentage
- Most common wrong answers
- Average points earned
- Difficulty correlation

### Use Cases
- Identify challenging questions
- Assess quiz difficulty
- Monitor class performance
- Inform curriculum adjustments
    `,
  })
  @ApiParam({ name: 'quizId', description: 'Quiz ID', type: Number })
  @ApiResponse({ status: 200, description: 'Quiz statistics', type: QuizStatisticsDto })
  @ApiResponse({ status: 404, description: 'Quiz not found' })
  async getQuizStatistics(@Param('quizId', ParseIntPipe) quizId: number): Promise<QuizStatisticsDto> {
    return this.quizzesService.getQuizStatistics(quizId);
  }

  @Get('progress/course/:courseId')
  @Roles(RoleName.STUDENT)
  @ApiOperation({
    summary: "Get student's quiz progress for a course",
    description: `
## Student Quiz Progress

Returns the authenticated student's progress across all quizzes in a course.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: STUDENT

### Response Includes
For each quiz in the course:
- Quiz title and type
- Completion status
- Best score achieved
- Attempts used vs allowed
- Upcoming due dates
- Pass/fail status

**Summary**:
- Total quizzes in course
- Quizzes completed
- Average score
- Overall quiz grade contribution

### Use Cases
- Student dashboard
- Progress tracking
- Identifying pending quizzes
    `,
  })
  @ApiParam({ name: 'courseId', description: 'Course ID', type: Number })
  @ApiResponse({ status: 200, description: 'Student progress', type: StudentQuizProgressDto })
  async getStudentProgress(
    @Param('courseId', ParseIntPipe) courseId: number,
    @Req() req: any,
  ): Promise<StudentQuizProgressDto> {
    return this.quizzesService.getStudentProgress(req.user.userId, courseId);
  }
}
