# EduVerse Backend Development Phases - Spring Boot Implementation Guide

> **Note**: This document is designed for Java Spring Boot implementation, even though the current codebase uses NestJS/TypeScript. The structure and concepts are transferable.

---

## ✅ COMPLETED PHASES

### 🎯 PHASE 1: Foundation & Core Infrastructure (COMPLETED)

#### What Was Built:

**1. Authentication System ✅**
- User registration with email verification
- Login with JWT tokens (access + refresh tokens)
- Password reset functionality (forgot password, reset password)
- Session management with "Remember Me" support
- Two-Factor Authentication (2FA) entity structure
- Email verification system
- Token refresh mechanism

**2. User Management & Roles ✅**
- Complete Role-Based Access Control (RBAC)
- User roles: STUDENT, INSTRUCTOR, TA, ADMIN, IT_ADMIN
- Permission system with module-based permissions
- User-role and role-permission relationships
- User status management (ACTIVE, INACTIVE, SUSPENDED, PENDING)
- User profile management

**3. Multi-Campus Support ✅**
- Campus ID integration in user entity
- Support for multi-campus structure (ready for Phase 2 expansion)

**4. Security Features ✅**
- JWT authentication guards
- Role-based guards
- Password hashing with bcrypt
- Session tracking
- Public endpoint decorator for unauthenticated routes

**5. Email Service ✅**
- Email sending service integrated
- Verification emails
- Password reset emails

#### Database Tables Implemented:
- `users` - User accounts
- `roles` - User roles
- `permissions` - System permissions
- `user_roles` - User-role mapping
- `role_permissions` - Role-permission mapping
- `sessions` - Active user sessions
- `password_resets` - Password reset tokens
- `two_factor_auth` - 2FA data

#### Key Endpoints (NestJS Implementation):
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login
- `POST /api/auth/logout` - User logout
- `POST /api/auth/refresh-token` - Refresh access token
- `POST /api/auth/forgot-password` - Request password reset
- `POST /api/auth/reset-password` - Reset password
- `POST /api/auth/verify-email` - Verify email
- `GET /api/auth/me` - Get current user

---

### 🏗️ PHASE 2: Academic Structure (COMPLETED)

#### What Was Built:

**1. Course Management (Instructor) ✅**
- Create and manage courses
- Course sections and schedules
- Course prerequisites system
- Course metadata (title, description, credits, etc.)
- Course status management

**2. Course Enrollment (Student) ✅**
- Student course registration
- Enrollment management
- Course instructor assignments
- Teaching Assistant (TA) assignments to courses
- Enrollment status tracking

#### Database Tables Implemented:
- `courses` - Course definitions
- `course_sections` - Course sections
- `course_schedules` - Course schedules
- `course_prerequisites` - Prerequisite relationships
- `course_enrollments` - Student enrollments
- `course_instructors` - Instructor-course assignments
- `course_tas` - TA-course assignments

#### Key Features:
- Students can enroll in available courses
- Instructors can create and manage their courses
- TAs can be assigned to assist with courses
- Course prerequisites prevent enrollment until requirements met
- Course schedules for time management

---

## 📋 REMAINING PHASES TO IMPLEMENT

---

## 📁 PHASE 3: File Management System

### Feature Name
**File Management System**

### Database Tables
- `folders` - Folder structure
- `files` - File metadata
- `file_versions` - File versioning
- `file_permissions` - Access control

### Endpoints

#### Folder Management
- `POST /api/files/folders` - Create folder
- `GET /api/files/folders/{folderId}` - Get folder details
- `GET /api/files/folders/{folderId}/children` - Get folder contents
- `PUT /api/files/folders/{folderId}` - Update folder
- `DELETE /api/files/folders/{folderId}` - Delete folder
- `GET /api/files/folders/{folderId}/tree` - Get folder tree structure

#### File Management
- `POST /api/files/upload` - Upload file
- `GET /api/files/{fileId}` - Get file metadata
- `GET /api/files/{fileId}/download` - Download file
- `PUT /api/files/{fileId}` - Update file metadata
- `DELETE /api/files/{fileId}` - Delete file
- `POST /api/files/{fileId}/versions` - Create new version
- `GET /api/files/{fileId}/versions` - Get file versions
- `GET /api/files/{fileId}/versions/{versionId}/download` - Download specific version

#### File Permissions
- `GET /api/files/{fileId}/permissions` - Get file permissions
- `POST /api/files/{fileId}/permissions` - Grant permission
- `PUT /api/files/{fileId}/permissions/{permissionId}` - Update permission
- `DELETE /api/files/{fileId}/permissions/{permissionId}` - Revoke permission

#### Search & Browse
- `GET /api/files/search` - Search files
- `GET /api/files/recent` - Get recently accessed files
- `GET /api/files/shared` - Get shared files

### Files Required

#### Entities (Models)
- `Folder.java` - Folder entity
- `File.java` - File entity
- `FileVersion.java` - File version entity
- `FilePermission.java` - File permission entity

#### Repositories
- `FolderRepository.java` - Folder data access
- `FileRepository.java` - File data access
- `FileVersionRepository.java` - File version data access
- `FilePermissionRepository.java` - File permission data access

#### Services
- `FileService.java` - File business logic
- `FolderService.java` - Folder business logic
- `FileStorageService.java` - Physical file storage operations
- `FilePermissionService.java` - Permission management

#### DTOs
- `CreateFolderDto.java`
- `UpdateFolderDto.java`
- `FolderResponseDto.java`
- `UploadFileDto.java`
- `FileResponseDto.java`
- `FileVersionResponseDto.java`
- `FilePermissionDto.java`
- `GrantPermissionDto.java`
- `FileSearchDto.java`

#### Controllers
- `FileController.java` - File endpoints
- `FolderController.java` - Folder endpoints

#### Configuration
- `FileStorageConfig.java` - Storage configuration
- `FileStorageProperties.java` - Storage properties

### Claude Prompt for Phase 3

```
You are building Phase 3: File Management System for EduVerse, a Spring Boot educational platform.

CONTEXT - What's Already Done:
✅ Phase 1: Complete authentication system with JWT, user roles (STUDENT, INSTRUCTOR, TA, ADMIN, IT_ADMIN), permissions, and multi-campus support
✅ Phase 2: Course management and enrollment system with courses, course sections, schedules, prerequisites, and enrollments
✅ Database: MySQL with JPA/Hibernate
✅ Security: JWT authentication, role-based access control (RBAC) guards
✅ User entity with relationships to roles, sessions, and campus

WHAT TO BUILD:

1. FOLDER MANAGEMENT SYSTEM
   - Create a folder hierarchy structure (folders can have parent folders)
   - Folders belong to a course (courseId) or can be user-specific
   - Support nested folder structure (parent-child relationships)
   - Each folder has: folderId, folderName, parentFolderId (nullable), courseId (nullable), userId (nullable), createdAt, updatedAt
   - Folders can be organized by course materials, assignments, submissions, etc.

2. FILE UPLOAD & STORAGE
   - Upload files to folders with metadata (filename, size, MIME type, uploader)
   - Store physical files in a configurable storage location (local filesystem or cloud)
   - Support multiple file types (documents, images, videos, PDFs, etc.)
   - File entity should track: fileId, fileName, originalFileName, filePath, fileSize, mimeType, folderId, uploadedBy, createdAt, updatedAt
   - Implement file size limits and type restrictions

3. FILE VERSIONING
   - Track multiple versions of the same file
   - Each version maintains: versionId, fileId, versionNumber, filePath, uploadedBy, createdAt
   - Allow downloading specific versions
   - Keep version history for audit purposes

4. FILE PERMISSIONS
   - Implement granular permission system (READ, WRITE, DELETE, SHARE)
   - Permissions can be granted to: individual users, roles, or course members
   - Track: permissionId, fileId, userId (nullable), roleId (nullable), permissionType, grantedBy, createdAt
   - Default permissions: file owner has all permissions, course instructors have READ/WRITE

5. FILE OPERATIONS
   - Download files with proper access control
   - Search files by name, type, course, folder
   - Get recently accessed files
   - Get shared files (files shared with current user)
   - Delete files (soft delete recommended)

TECHNICAL REQUIREMENTS:
- Use Spring Boot 3.x with Java 17+
- Use JPA/Hibernate for database operations
- Implement proper exception handling (FileNotFoundException, PermissionDeniedException, etc.)
- Use @PreAuthorize for endpoint security based on roles
- File storage should be configurable (application.properties)
- Implement file validation (size, type, name)
- Use DTOs for all request/response objects
- Follow RESTful API conventions
- Add proper logging for file operations
- Implement transaction management for file operations

INTEGRATION POINTS:
- Files are associated with courses (from Phase 2)
- Permissions integrate with user roles (from Phase 1)
- File uploads are performed by authenticated users (JWT from Phase 1)

TESTING:
- Create unit tests for services
- Create integration tests for controllers
- Test file upload/download functionality
- Test permission system
- Test folder hierarchy operations

DELIVERABLES:
1. All entity classes with proper JPA annotations and relationships
2. Repository interfaces extending JpaRepository
3. Service classes with business logic
4. Controller classes with REST endpoints
5. DTO classes for all requests/responses
6. Exception classes for file-related errors
7. Configuration classes for file storage
8. Application properties for storage configuration
```

---

## 📚 PHASE 4: Course Content & Materials

### Feature Name
**Course Content & Materials Management**

### Database Tables
- `course_materials` - Course materials
- `lecture_sections_labs` - Lecture sections and labs organization

### Endpoints

#### Course Materials
- `POST /api/courses/{courseId}/materials` - Upload course material
- `GET /api/courses/{courseId}/materials` - Get all course materials
- `GET /api/courses/{courseId}/materials/{materialId}` - Get material details
- `PUT /api/courses/{courseId}/materials/{materialId}` - Update material
- `DELETE /api/courses/{courseId}/materials/{materialId}` - Delete material
- `GET /api/courses/{courseId}/materials/by-week/{weekNumber}` - Get materials by week
- `GET /api/courses/{courseId}/materials/by-section/{sectionId}` - Get materials by section

#### Lecture Sections & Labs
- `POST /api/courses/{courseId}/sections` - Create lecture section/lab
- `GET /api/courses/{courseId}/sections` - Get all sections
- `GET /api/courses/{courseId}/sections/{sectionId}` - Get section details
- `PUT /api/courses/{courseId}/sections/{sectionId}` - Update section
- `DELETE /api/courses/{courseId}/sections/{sectionId}` - Delete section
- `GET /api/courses/{courseId}/sections/{sectionId}/materials` - Get section materials

#### Student Dashboard
- `GET /api/students/dashboard` - Get student dashboard data
- `GET /api/students/courses` - Get enrolled courses
- `GET /api/students/courses/{courseId}` - Get course page for student
- `GET /api/students/courses/{courseId}/materials` - Get accessible course materials

### Files Required

#### Entities
- `CourseMaterial.java` - Course material entity
- `LectureSectionLab.java` - Lecture section/lab entity

#### Repositories
- `CourseMaterialRepository.java`
- `LectureSectionLabRepository.java`

#### Services
- `CourseMaterialService.java`
- `LectureSectionLabService.java`
- `StudentDashboardService.java`

#### DTOs
- `CreateCourseMaterialDto.java`
- `UpdateCourseMaterialDto.java`
- `CourseMaterialResponseDto.java`
- `CreateSectionDto.java`
- `UpdateSectionDto.java`
- `SectionResponseDto.java`
- `StudentDashboardDto.java`
- `CoursePageDto.java`

#### Controllers
- `CourseMaterialController.java`
- `LectureSectionController.java`
- `StudentDashboardController.java`

### Claude Prompt for Phase 4

```
You are building Phase 4: Course Content & Materials Management for EduVerse, a Spring Boot educational platform.

CONTEXT - What's Already Done:
✅ Phase 1: Complete authentication system with JWT, user roles, permissions, multi-campus support
✅ Phase 2: Course management (courses, sections, schedules, prerequisites) and enrollment system
✅ Phase 3: File management system with folders, files, versions, and permissions
✅ Users can be STUDENT, INSTRUCTOR, TA, ADMIN, IT_ADMIN
✅ Courses have sections, schedules, and enrollments
✅ Files can be uploaded to folders with permission control

WHAT TO BUILD:

1. COURSE MATERIALS SYSTEM
   - Instructors can upload materials (lectures, notes, slides, videos, etc.) to courses
   - Materials are linked to files from Phase 3 file system
   - Materials can be organized by week number or lecture section
   - Each material has: materialId, courseId, fileId (from Phase 3), materialTitle, description, materialType (LECTURE, SLIDE, VIDEO, DOCUMENT, etc.), weekNumber (nullable), sectionId (nullable), uploadedBy, isVisible, createdAt, updatedAt
   - Materials have visibility control (visible/hidden to students)
   - Materials can be marked as required or optional

2. LECTURE SECTIONS & LABS ORGANIZATION
   - Organize course content into sections (Lecture 1, Lab 1, Tutorial 1, etc.)
   - Sections belong to a course
   - Each section has: sectionId, courseId, sectionName, sectionType (LECTURE, LAB, TUTORIAL, SEMINAR), weekNumber, description, instructorId, createdAt, updatedAt
   - Materials can be associated with specific sections
   - Sections help organize course timeline and content

3. STUDENT DASHBOARD
   - Students can view all their enrolled courses
   - For each course, show: course name, instructor, progress, upcoming deadlines, recent materials
   - Dashboard aggregates data from enrollments, materials, assignments (future), quizzes (future)
   - Show course cards with key information

4. COURSE PAGE FOR STUDENTS
   - Detailed view of a single enrolled course
   - Display course information, instructor details, schedule
   - Show all accessible materials organized by week or section
   - Display course announcements (future phase)
   - Show course progress and statistics

TECHNICAL REQUIREMENTS:
- Use Spring Boot 3.x with Java 17+
- Use JPA/Hibernate with proper relationships
- Materials must integrate with File system from Phase 3 (use File entity)
- Implement proper authorization:
  - Instructors can create/update/delete materials for their courses
  - TAs can manage materials if assigned to course
  - Students can only view visible materials for enrolled courses
- Use @PreAuthorize for security
- Implement soft delete for materials
- Add proper validation for material types, week numbers
- Use DTOs for all requests/responses
- Follow RESTful conventions
- Add pagination for material lists

INTEGRATION POINTS:
- Course materials use File entity from Phase 3
- Materials belong to Courses from Phase 2
- Access control uses User roles from Phase 1
- Materials visibility respects course enrollment from Phase 2

BUSINESS RULES:
- Only enrolled students can view course materials
- Materials marked as hidden are not visible to students
- Instructors can see all materials regardless of visibility
- TAs can manage materials for courses they're assigned to
- Week numbers should be validated against course duration

DELIVERABLES:
1. CourseMaterial entity with relationships to Course and File
2. LectureSectionLab entity with relationship to Course
3. Repository interfaces
4. Service classes with business logic
5. Controller classes with REST endpoints
6. DTO classes for requests/responses
7. Exception handling for unauthorized access
8. Dashboard aggregation logic
```

---

## ✍️ PHASE 5: Assignments & Submissions

### Feature Name
**Assignment Management & Submission System**

### Database Tables
- `assignments` - Assignment definitions
- `rubrics` - Grading rubrics
- `assignment_submissions` - Student submissions
- `student_tasks` - To-do tasks
- `task_completion` - Task completion tracking

### Endpoints

#### Assignment Management (Instructor)
- `POST /api/courses/{courseId}/assignments` - Create assignment
- `GET /api/courses/{courseId}/assignments` - Get all assignments
- `GET /api/courses/{courseId}/assignments/{assignmentId}` - Get assignment details
- `PUT /api/courses/{courseId}/assignments/{assignmentId}` - Update assignment
- `DELETE /api/courses/{courseId}/assignments/{assignmentId}` - Delete assignment
- `GET /api/courses/{courseId}/assignments/{assignmentId}/submissions` - Get all submissions
- `POST /api/courses/{courseId}/assignments/{assignmentId}/publish` - Publish assignment
- `POST /api/courses/{courseId}/assignments/{assignmentId}/unpublish` - Unpublish assignment

#### Rubrics
- `POST /api/assignments/{assignmentId}/rubrics` - Create rubric
- `GET /api/assignments/{assignmentId}/rubrics` - Get assignment rubrics
- `PUT /api/rubrics/{rubricId}` - Update rubric
- `DELETE /api/rubrics/{rubricId}` - Delete rubric

#### Submission Management (Student)
- `POST /api/assignments/{assignmentId}/submissions` - Submit assignment
- `GET /api/assignments/{assignmentId}/submissions/my-submission` - Get my submission
- `PUT /api/submissions/{submissionId}` - Update submission (before deadline)
- `DELETE /api/submissions/{submissionId}` - Delete submission (before deadline)
- `GET /api/submissions/{submissionId}` - Get submission details
- `GET /api/submissions/{submissionId}/download` - Download submission files

#### To-Do System
- `GET /api/students/tasks` - Get all student tasks
- `GET /api/students/tasks/pending` - Get pending tasks
- `GET /api/students/tasks/completed` - Get completed tasks
- `POST /api/students/tasks` - Create manual task
- `PUT /api/students/tasks/{taskId}` - Update task
- `PUT /api/students/tasks/{taskId}/complete` - Mark task as complete
- `DELETE /api/students/tasks/{taskId}` - Delete task

### Files Required

#### Entities
- `Assignment.java` - Assignment entity
- `Rubric.java` - Rubric entity
- `RubricItem.java` - Rubric item/criterion entity
- `AssignmentSubmission.java` - Submission entity
- `SubmissionFile.java` - Submission file attachment entity
- `StudentTask.java` - Task entity
- `TaskCompletion.java` - Task completion tracking entity

#### Repositories
- `AssignmentRepository.java`
- `RubricRepository.java`
- `RubricItemRepository.java`
- `AssignmentSubmissionRepository.java`
- `SubmissionFileRepository.java`
- `StudentTaskRepository.java`
- `TaskCompletionRepository.java`

#### Services
- `AssignmentService.java`
- `RubricService.java`
- `AssignmentSubmissionService.java`
- `StudentTaskService.java`

#### DTOs
- `CreateAssignmentDto.java`
- `UpdateAssignmentDto.java`
- `AssignmentResponseDto.java`
- `CreateRubricDto.java`
- `UpdateRubricDto.java`
- `RubricResponseDto.java`
- `CreateSubmissionDto.java`
- `UpdateSubmissionDto.java`
- `SubmissionResponseDto.java`
- `CreateTaskDto.java`
- `UpdateTaskDto.java`
- `TaskResponseDto.java`

#### Controllers
- `AssignmentController.java`
- `RubricController.java`
- `AssignmentSubmissionController.java`
- `StudentTaskController.java`

### Claude Prompt for Phase 5

```
You are building Phase 5: Assignments & Submissions System for EduVerse, a Spring Boot educational platform.

CONTEXT - What's Already Done:
✅ Phase 1: Authentication, user roles (STUDENT, INSTRUCTOR, TA, ADMIN), JWT security
✅ Phase 2: Course management, course sections, enrollments
✅ Phase 3: File management system (folders, files, versions, permissions)
✅ Phase 4: Course materials, lecture sections, student dashboard
✅ Students can enroll in courses, view materials
✅ Instructors can create courses, upload materials
✅ File system supports file uploads with permissions

WHAT TO BUILD:

1. ASSIGNMENT CREATION (Instructor/TA)
   - Instructors can create assignments for their courses
   - Assignment fields: assignmentId, courseId, assignmentTitle, description, assignmentType (HOMEWORK, PROJECT, ESSAY, etc.), maxScore, dueDate, allowLateSubmission (boolean), latePenalty (percentage), instructions, attachedFiles (from Phase 3), isPublished, createdAt, updatedAt
   - Assignments can have multiple attached files (instructions, templates, etc.)
   - Assignments can be published/unpublished (students only see published)
   - Support for different assignment types and configurations

2. RUBRIC SYSTEM
   - Create grading rubrics for assignments
   - Rubric has: rubricId, assignmentId, rubricName, description
   - RubricItems: itemId, rubricId, criterionName, description, maxPoints, weight (percentage)
   - Rubrics help standardize grading
   - Multiple rubrics can exist per assignment (for different grading scenarios)

3. ASSIGNMENT SUBMISSION (Student)
   - Students can submit assignments before due date
   - Submission fields: submissionId, assignmentId, studentId, submittedFiles (from Phase 3), submissionText (for text submissions), submittedAt, status (DRAFT, SUBMITTED, LATE, GRADED), grade (nullable), feedback (nullable)
   - Students can upload multiple files as submission
   - Support late submissions with penalty calculation
   - Students can update submission before due date
   - Track submission status and timestamps

4. TO-DO SYSTEM (Student)
   - Automatic task generation from assignments (when assignment is published)
   - Manual task creation by students
   - Task fields: taskId, studentId, taskTitle, description, taskType (AUTOMATIC, MANUAL), relatedAssignmentId (nullable), dueDate, priority (LOW, MEDIUM, HIGH), status (PENDING, IN_PROGRESS, COMPLETED), createdAt, updatedAt
   - Task completion tracking: completionId, taskId, completedAt, notes
   - Students can mark tasks as complete
   - Tasks help students track deadlines and work

TECHNICAL REQUIREMENTS:
- Use Spring Boot 3.x with Java 17+
- Use JPA/Hibernate with proper relationships
- Integrate with File system from Phase 3 for assignment attachments and submission files
- Implement proper authorization:
  - Instructors/TAs can create/manage assignments for their courses
  - Students can only submit to published assignments in enrolled courses
  - Students can only view/edit their own submissions
- Use @PreAuthorize for security
- Implement deadline validation (prevent submission after deadline unless late allowed)
- Calculate late penalty automatically
- Use DTOs for all requests/responses
- Follow RESTful conventions
- Add proper validation for dates, scores, file types
- Implement transaction management for submission operations
- Add automatic task generation when assignment is published

INTEGRATION POINTS:
- Assignments belong to Courses from Phase 2
- Assignment files use File entity from Phase 3
- Submission files use File entity from Phase 3
- Access control uses User roles from Phase 1
- Tasks are linked to assignments and students

BUSINESS RULES:
- Only enrolled students can submit assignments
- Submissions cannot be modified after due date (unless late submission allowed)
- Late submissions automatically calculate penalty
- Tasks are auto-generated when assignment is published
- Students can create manual tasks for personal organization
- Rubrics are optional but help with grading consistency
- Assignment must be published for students to see and submit

DELIVERABLES:
1. Assignment entity with relationships to Course and File
2. Rubric and RubricItem entities
3. AssignmentSubmission entity with file attachments
4. StudentTask entity with completion tracking
5. Repository interfaces
6. Service classes with business logic (deadline validation, penalty calculation, task generation)
7. Controller classes with REST endpoints
8. DTO classes for requests/responses
9. Exception handling (DeadlinePassedException, UnauthorizedSubmissionException, etc.)
10. Scheduled task for auto-generating tasks from published assignments
```

---

## 📝 PHASE 6: Quiz System

### Feature Name
**Quiz Creation & Taking System**

### Database Tables
- `quizzes` - Quiz definitions
- `quiz_questions` - Quiz questions
- `quiz_difficulty_levels` - Difficulty levels
- `quiz_attempts` - Student quiz attempts
- `quiz_answers` - Student answers

### Endpoints

#### Quiz Management (Instructor)
- `POST /api/courses/{courseId}/quizzes` - Create quiz
- `GET /api/courses/{courseId}/quizzes` - Get all quizzes
- `GET /api/courses/{courseId}/quizzes/{quizId}` - Get quiz details
- `PUT /api/courses/{courseId}/quizzes/{quizId}` - Update quiz
- `DELETE /api/courses/{courseId}/quizzes/{quizId}` - Delete quiz
- `POST /api/quizzes/{quizId}/questions` - Add question to quiz
- `PUT /api/quizzes/{quizId}/questions/{questionId}` - Update question
- `DELETE /api/quizzes/{quizId}/questions/{questionId}` - Delete question
- `POST /api/quizzes/{quizId}/publish` - Publish quiz
- `POST /api/quizzes/{quizId}/unpublish` - Unpublish quiz

#### Question Bank
- `GET /api/questions/bank` - Get question bank
- `POST /api/questions/bank` - Add question to bank
- `GET /api/questions/bank/{questionId}` - Get question details
- `PUT /api/questions/bank/{questionId}` - Update question
- `DELETE /api/questions/bank/{questionId}` - Delete question

#### Quiz Taking (Student)
- `GET /api/quizzes/{quizId}/start` - Start quiz attempt
- `GET /api/quizzes/{quizId}/attempts/current` - Get current attempt
- `POST /api/quiz-attempts/{attemptId}/answers` - Submit answer
- `PUT /api/quiz-attempts/{attemptId}/answers/{answerId}` - Update answer
- `POST /api/quiz-attempts/{attemptId}/submit` - Submit quiz
- `GET /api/quiz-attempts/{attemptId}` - Get attempt details
- `GET /api/quiz-attempts/{attemptId}/results` - Get quiz results
- `GET /api/students/quizzes/available` - Get available quizzes

### Files Required

#### Entities
- `Quiz.java` - Quiz entity
- `QuizQuestion.java` - Question entity
- `QuestionOption.java` - Multiple choice options
- `QuizDifficultyLevel.java` - Difficulty level entity
- `QuizAttempt.java` - Quiz attempt entity
- `QuizAnswer.java` - Student answer entity

#### Repositories
- `QuizRepository.java`
- `QuizQuestionRepository.java`
- `QuestionOptionRepository.java`
- `QuizDifficultyLevelRepository.java`
- `QuizAttemptRepository.java`
- `QuizAnswerRepository.java`

#### Services
- `QuizService.java`
- `QuizQuestionService.java`
- `QuizAttemptService.java`
- `QuizGradingService.java`

#### DTOs
- `CreateQuizDto.java`
- `UpdateQuizDto.java`
- `QuizResponseDto.java`
- `CreateQuestionDto.java`
- `UpdateQuestionDto.java`
- `QuestionResponseDto.java`
- `StartQuizAttemptDto.java`
- `SubmitAnswerDto.java`
- `QuizAttemptResponseDto.java`
- `QuizResultsDto.java`

#### Controllers
- `QuizController.java`
- `QuizQuestionController.java`
- `QuizAttemptController.java`

### Claude Prompt for Phase 6

```
You are building Phase 6: Quiz System for EduVerse, a Spring Boot educational platform.

CONTEXT - What's Already Done:
✅ Phase 1: Authentication, user roles (STUDENT, INSTRUCTOR, TA, ADMIN), JWT security
✅ Phase 2: Course management, course sections, enrollments
✅ Phase 3: File management system
✅ Phase 4: Course materials
✅ Phase 5: Assignments and submissions (with rubrics)
✅ Students submit assignments and take quizzes
✅ Rubrics exist for assignments
✅ TAs are assigned to courses

WHAT TO BUILD:

1. QUIZ CREATION (Instructor/TA)
   - Instructors can create quizzes for their courses
   - Quiz fields: quizId, courseId, quizTitle, description, quizType (GRADED, PRACTICE, SURVEY), maxScore, timeLimit (minutes, nullable), allowMultipleAttempts (boolean), maxAttempts (nullable), showCorrectAnswers (boolean), showResultsImmediately (boolean), randomizeQuestions (boolean), randomizeOptions (boolean), difficultyLevelId, isPublished, startDate, endDate, createdAt, updatedAt
   - Quizzes can have time limits
   - Support for different quiz types and configurations

2. QUESTION BANK SYSTEM
   - Create reusable questions in a question bank
   - Questions can be used across multiple quizzes
   - Question fields: questionId, questionText, questionType (MULTIPLE_CHOICE, TRUE_FALSE, SHORT_ANSWER, ESSAY, MATCHING, FILL_BLANK), points, difficultyLevelId, createdBy, createdAt, updatedAt
   - Questions belong to courses or can be global (for reuse)
   - Support multiple question types with appropriate answer structures

3. QUESTION OPTIONS & ANSWERS
   - For multiple choice: optionId, questionId, optionText, isCorrect (boolean), order
   - For true/false: correctAnswer (boolean)
   - For short answer: correctAnswer (text), acceptPartialMatch (boolean)
   - For essay: sampleAnswer (text, nullable), rubric (nullable)
   - For matching: matchPairs (JSON structure)
   - For fill-in-blank: blanks with correct answers

4. QUIZ ATTEMPTS (Student)
   - Students can start quiz attempts
   - Attempt fields: attemptId, quizId, studentId, startedAt, submittedAt (nullable), timeRemaining (seconds), status (IN_PROGRESS, SUBMITTED, TIMED_OUT, GRADED), score (nullable), grade (nullable)
   - Track time remaining for timed quizzes
   - Support multiple attempts if allowed
   - Prevent starting new attempt if max attempts reached

5. ANSWER SUBMISSION
   - Students submit answers during quiz attempt
   - Answer fields: answerId, attemptId, questionId, answerText (JSON for complex answers), isCorrect (nullable, calculated after submission), pointsAwarded (nullable), submittedAt
   - Answers can be updated before quiz submission
   - Auto-grade answers where possible (multiple choice, true/false, short answer with exact match)
   - Essay questions require manual grading

6. QUIZ GRADING
   - Auto-grade objective questions immediately
   - Calculate total score based on question points
   - Store grades for manual review if needed
   - Provide results to students based on quiz settings (immediate or after deadline)

TECHNICAL REQUIREMENTS:
- Use Spring Boot 3.x with Java 17+
- Use JPA/Hibernate with proper relationships
- Implement timer functionality for timed quizzes (use scheduled tasks or WebSocket for real-time updates)
- Use JSON for complex answer structures (matching, fill-in-blank)
- Implement proper authorization:
  - Instructors/TAs can create/manage quizzes for their courses
  - Students can only take published quizzes in enrolled courses
  - Students can only view their own attempts
- Use @PreAuthorize for security
- Implement time limit enforcement
- Validate quiz availability (start date, end date, max attempts)
- Use DTOs for all requests/responses
- Follow RESTful conventions
- Add proper validation for dates, scores, time limits
- Implement transaction management for quiz attempts
- Add question randomization logic
- Implement auto-grading for objective questions

INTEGRATION POINTS:
- Quizzes belong to Courses from Phase 2
- Access control uses User roles from Phase 1
- Questions can be linked to courses for organization
- Difficulty levels are shared across the system

BUSINESS RULES:
- Only enrolled students can take quizzes
- Quiz must be published and within start/end date
- Students cannot exceed max attempts
- Timed quizzes automatically submit when time expires
- Answers cannot be changed after quiz submission
- Randomization applies when starting attempt (questions and/or options)
- Auto-grading happens for objective questions immediately
- Essay questions require manual grading (Phase 7)
- Results visibility controlled by quiz settings

DELIVERABLES:
1. Quiz entity with relationships to Course and DifficultyLevel
2. QuizQuestion entity with support for multiple question types
3. QuestionOption entity for multiple choice questions
4. QuizAttempt entity tracking student attempts
5. QuizAnswer entity storing student answers
6. Repository interfaces
7. Service classes with business logic (timer, auto-grading, randomization)
8. Controller classes with REST endpoints
9. DTO classes for requests/responses
10. Exception handling (QuizNotAvailableException, MaxAttemptsReachedException, TimeExpiredException, etc.)
11. Scheduled task or WebSocket for time limit tracking
12. Auto-grading service for objective questions
```

---

## 🎓 PHASE 7: Grading System

### Feature Name
**Grading & Assessment Management**

### Database Tables
- `grades` - Grade records
- `grade_components` - Grade breakdown components
- `collaborative_grading` - TA grading assignments
- `gpa_calculations` - GPA tracking

### Endpoints

#### Grading (Instructor/TA)
- `POST /api/assignments/{assignmentId}/submissions/{submissionId}/grade` - Grade assignment submission
- `PUT /api/grades/{gradeId}` - Update grade
- `GET /api/assignments/{assignmentId}/grades` - Get all grades for assignment
- `POST /api/quizzes/{quizId}/attempts/{attemptId}/grade` - Grade quiz attempt (manual)
- `POST /api/grades/{gradeId}/feedback` - Add feedback to grade
- `GET /api/courses/{courseId}/grades` - Get all grades for course
- `GET /api/courses/{courseId}/grades/export` - Export grades

#### Rubric-Based Grading
- `POST /api/submissions/{submissionId}/grade-with-rubric` - Grade using rubric
- `GET /api/submissions/{submissionId}/rubric-grading` - Get rubric grading details

#### Collaborative Grading
- `POST /api/grades/{gradeId}/assign-ta` - Assign TA to grade
- `GET /api/tas/grading-assignments` - Get TA grading assignments
- `POST /api/grades/{gradeId}/ta-grade` - TA submits grade
- `POST /api/grades/{gradeId}/approve` - Instructor approves TA grade

#### Grade Analytics
- `GET /api/students/{studentId}/grades` - Get student grades
- `GET /api/students/{studentId}/gpa` - Calculate student GPA
- `GET /api/courses/{courseId}/grade-statistics` - Get course grade statistics
- `GET /api/courses/{courseId}/grade-distribution` - Get grade distribution

### Files Required

#### Entities
- `Grade.java` - Grade entity
- `GradeComponent.java` - Grade component entity
- `CollaborativeGrading.java` - Collaborative grading assignment entity
- `GpaCalculation.java` - GPA calculation entity

#### Repositories
- `GradeRepository.java`
- `GradeComponentRepository.java`
- `CollaborativeGradingRepository.java`
- `GpaCalculationRepository.java`

#### Services
- `GradingService.java`
- `RubricGradingService.java`
- `CollaborativeGradingService.java`
- `GpaCalculationService.java`
- `GradeAnalyticsService.java`

#### DTOs
- `CreateGradeDto.java`
- `UpdateGradeDto.java`
- `GradeResponseDto.java`
- `RubricGradingDto.java`
- `AssignTaGradingDto.java`
- `TaGradeSubmissionDto.java`
- `StudentGradesDto.java`
- `GpaResponseDto.java`
- `GradeStatisticsDto.java`
- `GradeDistributionDto.java`

#### Controllers
- `GradingController.java`
- `CollaborativeGradingController.java`
- `GradeAnalyticsController.java`

### Claude Prompt for Phase 7

```
You are building Phase 7: Grading System for EduVerse, a Spring Boot educational platform.

CONTEXT - What's Already Done:
✅ Phase 1: Authentication, user roles (STUDENT, INSTRUCTOR, TA, ADMIN), JWT security
✅ Phase 2: Course management, enrollments
✅ Phase 3: File management system
✅ Phase 4: Course materials
✅ Phase 5: Assignments and submissions (with rubrics)
✅ Phase 6: Quiz system with auto-grading for objective questions
✅ Students submit assignments and take quizzes
✅ Rubrics exist for assignments
✅ TAs are assigned to courses

WHAT TO BUILD:

1. ASSIGNMENT GRADING
   - Instructors/TAs can grade assignment submissions
   - Grade fields: gradeId, submissionId, assignmentId, studentId, gradedBy, score, maxScore, percentage, letterGrade (A, B, C, etc.), feedback, gradedAt, updatedAt
   - Support rubric-based grading (use rubrics from Phase 5)
   - Calculate final grade from rubric items if rubric used
   - Store individual component scores from rubric
   - Allow adding detailed feedback

2. RUBRIC-BASED GRADING
   - Grade submissions using assigned rubrics
   - For each rubric item, record: componentId, gradeId, rubricItemId, score, maxPoints, feedback
   - Calculate total score from all rubric components
   - Weight components according to rubric weights
   - Store component-level feedback

3. QUIZ GRADING (Manual for Essays)
   - Grade essay questions in quizzes (objective questions auto-graded in Phase 6)
   - Update quiz attempt score with manual grades
   - Add feedback for essay answers
   - Recalculate total quiz score after manual grading

4. COLLABORATIVE GRADING (TA Support)
   - Instructors can assign grading tasks to TAs
   - CollaborativeGrading: collaborationId, gradeId, assignedTo (TA), assignedBy (Instructor), status (PENDING, IN_PROGRESS, COMPLETED, APPROVED), taScore (nullable), taFeedback (nullable), instructorApproval (boolean), assignedAt, completedAt
   - TAs can submit grades for review
   - Instructors can approve or modify TA grades
   - Track grading workload distribution

5. GRADE COMPONENTS
   - Break down grades into components (assignment, quiz, participation, etc.)
   - Component fields: componentId, gradeId, componentName, componentType, score, maxScore, weight (percentage)
   - Support weighted grade calculations
   - Track grade breakdown for transparency

6. GPA CALCULATION
   - Calculate student GPA based on course grades
   - GPA fields: gpaId, studentId, semesterId (nullable), courseId (nullable), gpaValue, creditHours, calculationMethod, calculatedAt
   - Support semester GPA, cumulative GPA, course-specific GPA
   - Use letter grades to calculate GPA points (A=4.0, B=3.0, etc.)
   - Update GPA when new grades are added

7. GRADE ANALYTICS
   - Course-level statistics: average, median, min, max, standard deviation
   - Grade distribution (histogram of grades)
   - Student performance tracking
   - Grade trends over time
   - Export grades to CSV/Excel

TECHNICAL REQUIREMENTS:
- Use Spring Boot 3.x with Java 17+
- Use JPA/Hibernate with proper relationships
- Integrate with Assignment submissions from Phase 5
- Integrate with Quiz attempts from Phase 6
- Integrate with Rubrics from Phase 5
- Implement proper authorization:
  - Instructors can grade all submissions in their courses
  - TAs can grade assigned submissions
  - Students can only view their own grades
- Use @PreAuthorize for security
- Implement grade calculation logic (weighted averages, rubric calculations)
- Validate scores don't exceed max scores
- Use DTOs for all requests/responses
- Follow RESTful conventions
- Add proper validation for scores, percentages
- Implement transaction management for grading operations
- Add GPA calculation service with configurable grading scales
- Implement grade export functionality (CSV, Excel)

INTEGRATION POINTS:
- Grades linked to AssignmentSubmissions from Phase 5
- Grades linked to QuizAttempts from Phase 6
- Rubric grading uses Rubrics from Phase 5
- Collaborative grading involves TAs from user roles (Phase 1)
- GPA calculations use course enrollments from Phase 2

BUSINESS RULES:
- Only instructors/TAs can grade submissions
- TAs can only grade assignments they're assigned to
- Grades cannot exceed max score for assignment/quiz
- Rubric-based grading must use all rubric items
- Letter grades calculated from percentage (configurable scale)
- GPA updates automatically when grades change
- Students can view grades after instructor publishes them
- Grade statistics only visible to instructors/admins

DELIVERABLES:
1. Grade entity with relationships to submissions and quiz attempts
2. GradeComponent entity for detailed breakdown
3. CollaborativeGrading entity for TA assignments
4. GpaCalculation entity for GPA tracking
5. Repository interfaces
6. Service classes with business logic (grading calculations, rubric processing, GPA computation)
7. Controller classes with REST endpoints
8. DTO classes for requests/responses
9. Exception handling (UnauthorizedGradingException, InvalidScoreException, etc.)
10. Grade calculation utilities (weighted averages, letter grade conversion)
11. GPA calculation service with configurable scales
12. Grade export service (CSV/Excel generation)
13. Analytics service for grade statistics
```

---

## 🔬 PHASE 8: Lab Management

### Feature Name
**Lab Management System**

### Database Tables
- `labs` - Lab definitions
- `lab_instructions` - Lab instruction content
- `lab_submissions` - Lab submissions
- `lab_attendance` - Lab attendance tracking

### Endpoints

#### Lab Management (Instructor/TA)
- `POST /api/courses/{courseId}/labs` - Create lab
- `GET /api/courses/{courseId}/labs` - Get all labs
- `GET /api/courses/{courseId}/labs/{labId}` - Get lab details
- `PUT /api/courses/{courseId}/labs/{labId}` - Update lab
- `DELETE /api/courses/{courseId}/labs/{labId}` - Delete lab
- `POST /api/labs/{labId}/instructions` - Add lab instructions
- `PUT /api/labs/{labId}/instructions` - Update lab instructions

#### Lab Submissions
- `POST /api/labs/{labId}/submissions` - Submit lab work
- `GET /api/labs/{labId}/submissions/my-submission` - Get my submission
- `GET /api/labs/{labId}/submissions` - Get all submissions (Instructor/TA)
- `PUT /api/lab-submissions/{submissionId}` - Update submission
- `GET /api/lab-submissions/{submissionId}` - Get submission details

#### Lab Attendance
- `POST /api/labs/{labId}/attendance/mark` - Mark attendance
- `GET /api/labs/{labId}/attendance` - Get attendance records
- `GET /api/labs/{labId}/attendance/students/{studentId}` - Get student attendance
- `PUT /api/attendance/{attendanceId}` - Update attendance record

### Files Required

#### Entities
- `Lab.java` - Lab entity
- `LabInstruction.java` - Lab instruction entity
- `LabSubmission.java` - Lab submission entity
- `LabAttendance.java` - Lab attendance entity

#### Repositories
- `LabRepository.java`
- `LabInstructionRepository.java`
- `LabSubmissionRepository.java`
- `LabAttendanceRepository.java`

#### Services
- `LabService.java`
- `LabSubmissionService.java`
- `LabAttendanceService.java`

#### DTOs
- `CreateLabDto.java`
- `UpdateLabDto.java`
- `LabResponseDto.java`
- `CreateLabInstructionDto.java`
- `UpdateLabInstructionDto.java`
- `CreateLabSubmissionDto.java`
- `LabSubmissionResponseDto.java`
- `MarkAttendanceDto.java`
- `AttendanceResponseDto.java`

#### Controllers
- `LabController.java`
- `LabSubmissionController.java`
- `LabAttendanceController.java`

### Claude Prompt for Phase 8

```
You are building Phase 8: Lab Management System for EduVerse, a Spring Boot educational platform.

CONTEXT - What's Already Done:
✅ Phase 1: Authentication, user roles (STUDENT, INSTRUCTOR, TA, ADMIN), JWT security
✅ Phase 2: Course management, course sections, enrollments
✅ Phase 3: File management system
✅ Phase 4: Course materials
✅ Phase 5: Assignments and submissions
✅ Phase 6: Quiz system
✅ Phase 7: Grading system
✅ TAs are assigned to courses and can assist with grading
✅ File upload/download system is available
✅ Students can submit assignments

WHAT TO BUILD:

1. LAB CREATION (Instructor/TA)
   - Create labs for courses (similar to assignments but specialized for lab work)
   - Lab fields: labId, courseId, labTitle, description, labNumber, labType (PRACTICAL, SIMULATION, FIELD_WORK, etc.), scheduledDate, scheduledTime, duration (minutes), location, maxScore, dueDate, isPublished, createdBy, createdAt, updatedAt
   - Labs are linked to course sections (from Phase 2)
   - Labs can have scheduled sessions with specific times and locations
   - Support different lab types

2. LAB INSTRUCTIONS
   - Detailed instructions for each lab
   - Instruction fields: instructionId, labId, instructionTitle, instructionContent (text/HTML), attachedFiles (from Phase 3), order, createdAt, updatedAt
   - Labs can have multiple instruction sections
   - Instructions can include files (PDFs, documents, code templates)
   - Support rich text formatting

3. LAB SUBMISSIONS
   - Students submit lab work (code, reports, results, etc.)
   - Submission fields: submissionId, labId, studentId, submittedFiles (from Phase 3), submissionText, results (JSON for structured data), submittedAt, status (DRAFT, SUBMITTED, LATE, GRADED), grade (nullable), feedback (nullable)
   - Similar to assignment submissions but tailored for lab work
   - Support file uploads and text submissions
   - Track submission timestamps

4. LAB ATTENDANCE
   - Track student attendance for lab sessions
   - Attendance fields: attendanceId, labId, studentId, attendanceDate, attendanceTime, status (PRESENT, ABSENT, LATE, EXCUSED), markedBy (Instructor/TA), notes, createdAt
   - Mark attendance during or after lab session
   - Support different attendance statuses
   - Track who marked the attendance
   - Calculate attendance percentage for students

TECHNICAL REQUIREMENTS:
- Use Spring Boot 3.x with Java 17+
- Use JPA/Hibernate with proper relationships
- Integrate with File system from Phase 3 for lab instructions and submissions
- Integrate with Course system from Phase 2
- Integrate with Grading system from Phase 7 (labs can be graded)
- Implement proper authorization:
  - Instructors/TAs can create/manage labs for their courses
  - Students can only submit to published labs in enrolled courses
  - TAs can mark attendance and grade lab submissions
- Use @PreAuthorize for security
- Implement deadline validation for submissions
- Use DTOs for all requests/responses
- Follow RESTful conventions
- Add proper validation for dates, times, scores
- Implement transaction management
- Calculate attendance statistics

INTEGRATION POINTS:
- Labs belong to Courses from Phase 2
- Lab files use File entity from Phase 3
- Lab submissions can be graded using Grading system from Phase 7
- Attendance tracking uses User and Course entities
- TAs can manage labs for courses they're assigned to

BUSINESS RULES:
- Only enrolled students can submit labs
- Lab must be published for students to see and submit
- Attendance can be marked by Instructors or TAs
- Lab submissions follow similar rules to assignments (deadlines, late submissions)
- Attendance records help track student participation
- Labs are typically hands-on practical work

DELIVERABLES:
1. Lab entity with relationships to Course
2. LabInstruction entity with file attachments
3. LabSubmission entity with file attachments
4. LabAttendance entity tracking attendance
5. Repository interfaces
6. Service classes with business logic
7. Controller classes with REST endpoints
8. DTO classes for requests/responses
9. Exception handling
10. Attendance calculation service
```

---

## 📊 PHASE 9: Attendance System

### Feature Name
**Attendance Tracking System**

### Database Tables
- `attendance_sessions` - Attendance session definitions
- `attendance_records` - Individual attendance records
- `face_recognition_data` - Face enrollment data (future)
- `attendance_photos` - Attendance photos (future)
- `ai_attendance_processing` - AI processing records (future)

### Endpoints

#### Attendance Sessions
- `POST /api/courses/{courseId}/attendance-sessions` - Create attendance session
- `GET /api/courses/{courseId}/attendance-sessions` - Get all sessions
- `GET /api/courses/{courseId}/attendance-sessions/{sessionId}` - Get session details
- `PUT /api/attendance-sessions/{sessionId}` - Update session
- `DELETE /api/attendance-sessions/{sessionId}` - Delete session
- `POST /api/attendance-sessions/{sessionId}/start` - Start session
- `POST /api/attendance-sessions/{sessionId}/end` - End session

#### Attendance Marking
- `POST /api/attendance-sessions/{sessionId}/mark` - Mark attendance (manual)
- `POST /api/attendance-sessions/{sessionId}/mark-bulk` - Mark multiple students
- `GET /api/attendance-sessions/{sessionId}/records` - Get all attendance records
- `PUT /api/attendance-records/{recordId}` - Update attendance record
- `DELETE /api/attendance-records/{recordId}` - Delete record

#### Attendance Reports
- `GET /api/courses/{courseId}/attendance/students/{studentId}` - Get student attendance
- `GET /api/courses/{courseId}/attendance/statistics` - Get attendance statistics
- `GET /api/courses/{courseId}/attendance/export` - Export attendance report
- `GET /api/students/my-attendance` - Get my attendance records

### Files Required

#### Entities
- `AttendanceSession.java` - Attendance session entity
- `AttendanceRecord.java` - Attendance record entity
- `FaceRecognitionData.java` - Face recognition data (future)
- `AttendancePhoto.java` - Attendance photo (future)
- `AiAttendanceProcessing.java` - AI processing record (future)

#### Repositories
- `AttendanceSessionRepository.java`
- `AttendanceRecordRepository.java`
- `FaceRecognitionDataRepository.java` (future)
- `AttendancePhotoRepository.java` (future)
- `AiAttendanceProcessingRepository.java` (future)

#### Services
- `AttendanceSessionService.java`
- `AttendanceRecordService.java`
- `AttendanceStatisticsService.java`
- `FaceRecognitionService.java` (future - placeholder)

#### DTOs
- `CreateAttendanceSessionDto.java`
- `UpdateAttendanceSessionDto.java`
- `AttendanceSessionResponseDto.java`
- `MarkAttendanceDto.java`
- `BulkMarkAttendanceDto.java`
- `AttendanceRecordResponseDto.java`
- `StudentAttendanceDto.java`
- `AttendanceStatisticsDto.java`

#### Controllers
- `AttendanceSessionController.java`
- `AttendanceRecordController.java`
- `AttendanceStatisticsController.java`

### Claude Prompt for Phase 9

```
You are building Phase 9: Attendance System for EduVerse, a Spring Boot educational platform.

CONTEXT - What's Already Done:
✅ Phase 1: Authentication, user roles (STUDENT, INSTRUCTOR, TA, ADMIN), JWT security
✅ Phase 2: Course management, course sections, enrollments
✅ Phase 3: File management system
✅ Phase 4: Course materials
✅ Phase 5: Assignments and submissions
✅ Phase 6: Quiz system
✅ Phase 8: Lab management with lab attendance
✅ Students are enrolled in courses
✅ Instructors and TAs can manage courses

WHAT TO BUILD:

1. ATTENDANCE SESSIONS
   - Create attendance sessions for courses
   - Session fields: sessionId, courseId, sessionTitle, sessionDate, sessionTime, duration (minutes), sessionType (LECTURE, LAB, TUTORIAL, etc.), location, isActive, startedAt (nullable), endedAt (nullable), createdBy, createdAt, updatedAt
   - Sessions can be scheduled in advance or created on-the-fly
   - Sessions have start/end times for tracking
   - Support different session types

2. MANUAL ATTENDANCE MARKING
   - Mark attendance for students in a session
   - Record fields: recordId, sessionId, studentId, attendanceStatus (PRESENT, ABSENT, LATE, EXCUSED), markedAt, markedBy (Instructor/TA), notes, createdAt
   - Support bulk marking (mark multiple students at once)
   - Track who marked the attendance
   - Allow updating attendance records
   - Support different attendance statuses

3. ATTENDANCE TRACKING
   - Track attendance history for students
   - Calculate attendance statistics:
     - Total sessions, present count, absent count, late count
     - Attendance percentage
     - Attendance trends over time
   - Generate attendance reports per course
   - Export attendance data

4. FACE RECOGNITION PREPARATION (Future Enhancement)
   - Create entity structures for future AI face recognition
   - FaceRecognitionData: dataId, studentId, faceEncoding (JSON), enrolledAt
   - AttendancePhoto: photoId, sessionId, studentId, photoUrl, processedAt
   - AiAttendanceProcessing: processingId, sessionId, status, processedAt, results (JSON)
   - These are placeholders for Phase 9 - actual AI implementation comes later
   - Design database schema to support future integration

TECHNICAL REQUIREMENTS:
- Use Spring Boot 3.x with Java 17+
- Use JPA/Hibernate with proper relationships
- Integrate with Course system from Phase 2
- Integrate with User system from Phase 1
- Implement proper authorization:
  - Instructors/TAs can create/manage attendance sessions for their courses
  - Instructors/TAs can mark attendance
  - Students can only view their own attendance
- Use @PreAuthorize for security
- Implement session time tracking
- Use DTOs for all requests/responses
- Follow RESTful conventions
- Add proper validation for dates, times
- Implement transaction management for bulk operations
- Calculate attendance statistics and percentages
- Support attendance export (CSV, Excel)

INTEGRATION POINTS:
- Attendance sessions belong to Courses from Phase 2
- Attendance records linked to Users (students) from Phase 1
- Marked by Instructors/TAs from user roles (Phase 1)
- Can integrate with course sections from Phase 2

BUSINESS RULES:
- Only enrolled students can have attendance records
- Attendance can only be marked for active sessions
- Instructors/TAs can mark attendance for their courses
- Attendance records can be updated before session ends
- Calculate attendance percentage: (Present + Late) / Total Sessions
- Students can view their own attendance history
- Attendance statistics visible to instructors/admins

DELIVERABLES:
1. AttendanceSession entity with relationships to Course
2. AttendanceRecord entity with relationships to Session and User
3. Face recognition entities (placeholders for future)
4. Repository interfaces
5. Service classes with business logic (statistics calculation, bulk operations)
6. Controller classes with REST endpoints
7. DTO classes for requests/responses
8. Exception handling
9. Attendance statistics service
10. Attendance export service (CSV/Excel)
11. Database schema ready for future AI face recognition integration
```

---

## 📝 Notes

- This document is designed for **Java Spring Boot** implementation
- Each phase builds upon previous phases
- All endpoints assume JWT authentication from Phase 1
- Database relationships should be properly configured with JPA/Hibernate
- Use `@PreAuthorize` for role-based access control
- Follow RESTful API conventions
- Implement proper exception handling for each phase
- Add comprehensive logging
- Write unit and integration tests for each feature

---

**Last Updated**: Phase 9 documented. Remaining phases (10-24) to be added as needed.



