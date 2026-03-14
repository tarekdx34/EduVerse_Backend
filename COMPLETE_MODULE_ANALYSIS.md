# 🏗️ EduVerse Backend - Complete NestJS Module Structure Analysis

## Overview
**Total Modules:** 23
**Architecture:** Modular NestJS with TypeORM
**Database:** MySQL
**All modules registered in:** src/app.module.ts

---

## 📋 Table of Contents
1. [Module Registration](#module-registration)
2. [Core Modules](#core-modules)
3. [Academic Modules](#academic-modules)
4. [Community & Discussion Modules](#community--discussion-modules)
5. [Administrative Modules](#administrative-modules)
6. [Infrastructure Modules](#infrastructure-modules)

---

## Module Registration

### All 23 modules imported in src/app.module.ts:
- AuthModule
- EmailModule
- CampusModule
- CoursesModule
- EnrollmentsModule
- YoutubeModule
- FilesModule
- AssignmentsModule
- GradesModule
- AttendanceModule
- QuizzesModule
- LabsModule
- NotificationsModule
- MessagingModule
- DiscussionsModule
- AnnouncementsModule
- CommunityModule
- ScheduleModule
- CourseMaterialsModule
- TasksModule
- ReportsModule
- SearchModule
- AnalyticsModule

---

## Core Modules

### 1️⃣ AUTH MODULE (Authentication & Authorization)
**Location:** \src/modules/auth/\

#### Entities (8):
- **User** - Primary user entity with roles, sessions
  - Fields: userId, email, passwordHash, firstName, lastName, phone, profilePictureUrl, bio, socialLinks, campusId, status (ACTIVE/INACTIVE/SUSPENDED/PENDING), emailVerified, lastLoginAt
  - Relationships: ManyToMany(Role), OneToMany(Session), OneToMany(PasswordReset), OneToMany(TwoFactorAuth)
  
- **Role** - User roles (STUDENT, INSTRUCTOR, TA, ADMIN, IT_ADMIN)
  - Many-to-Many relationship with User
  - Has many Permissions
  
- **Permission** - Fine-grained access control
  - Linked to Roles
  
- **Session** - Active user sessions with tokens
  - userId, refreshToken, userAgent, ipAddress, expiresAt
  
- **PasswordReset** - Password reset tokens
  - userId, token, expiresAt
  
- **TwoFactorAuth** - 2FA configuration
  - userId, secret, isEnabled, backupCodes
  
- **EmailVerification** - Email verification tokens
  - userId, token, expiresAt
  
- **UserPreference** - User UI/notification preferences
  - userId, theme, notifications, language

#### DTOs (5):
- **user.dto** - User profile data transfer
- **user-response.dto** - Response format for user endpoints
- **user-management.dto** - Admin operations
- **register-request.dto** - Registration validation
- **login-request.dto** - Login credentials
- **auth-response.dto** - Auth token response

#### Controllers (3):
- **auth.controller** (@Controller('api/auth'))
  - POST /register - Public user registration
  - POST /login - Public login
  - POST /logout - Logout (requires JWT)
  - POST /refresh-token - Refresh access token
  - POST /forgot-password - Request password reset
  - POST /reset-password - Reset with token
  - GET /me - Get current user profile
  
- **user-management.controller** (@Controller('api/admin'))
  - User CRUD operations for admins
  
- **user-profile.controller** (@Controller('api/users'))
  - Profile management endpoints

#### Services (2):
- **auth.service** - Authentication logic, JWT handling
- **user-management.service** - User CRUD & role assignment

---

### 2️⃣ COURSES MODULE
**Location:** \src/modules/courses/\

#### Entities (4):
- **Course**
  - Fields: courseId, departmentId, name, code, description, credits, level (enum), syllabusUrl, status (ACTIVE/ARCHIVED)
  - Relationships: ManyToOne(Department), OneToMany(CoursePrerequisite), OneToMany(CourseSection)
  
- **CourseSection**
  - Fields: sectionId, courseId, semesterId, sectionNumber, maxCapacity, currentEnrollment, location, status (OPEN/CLOSED/FULL)
  - Relationships: ManyToOne(Course), ManyToOne(Semester), OneToMany(CourseSchedule)
  
- **CourseSchedule**
  - Class meeting times and locations for sections
  
- **CoursePrerequisite**
  - Links prerequisite courses to courses

#### DTOs (4):
- **course.dto** - Create/Update course
- **section.dto** - Section management
- **schedule.dto** - Schedule management
- **prerequisite.dto** - Prerequisite relationships

#### Controllers (3):
- **courses.controller** (@Controller('api/courses'))
  - GET / - List all courses with filters
  - GET /department/:deptId - List courses by department
  - GET /:id - Get course details
  - POST / - Create course (INSTRUCTOR/ADMIN)
  - PATCH /:id - Update course
  - DELETE /:id - Delete course
  
- **course-sections.controller** (@Controller('api/sections'))
  - GET / - List sections
  - POST / - Create section
  - GET /:id - Get section details
  - PATCH /:id - Update section
  - DELETE /:id - Delete section
  
- **course-schedules.controller** (@Controller('api/schedules'))
  - Schedule management for course sections

#### Services (3):
- **courses.service** - Course CRUD & filtering
- **course-sections.service** - Section management
- **course-schedules.service** - Schedule management

---

## Academic Modules

### 3️⃣ ENROLLMENTS MODULE
**Location:** \src/modules/enrollments/\

#### Entities (3):
- **CourseEnrollment**
  - Fields: enrollmentId, userId, sectionId, programId, status (ENROLLED/DROPPED/COMPLETED), grade, finalScore
  - Relationships: ManyToOne(User), ManyToOne(CourseSection), ManyToOne(Program)
  
- **CourseInstructor**
  - Link instructors to course sections
  
- **CourseTA**
  - Link teaching assistants to course sections

#### DTOs (3):
- **enrollment-response.dto**
- **enroll-course.dto**
- **available-courses.dto**
- **drop-course.dto**

#### Controllers (1):
- **enrollments.controller** (@Controller('api/enrollments'))
  - GET /my-courses - Get student's enrolled courses
  - GET /available - Get available courses to enroll
  - POST / - Enroll in course
  - DELETE /:enrollmentId - Drop course

#### Services (1):
- **enrollments.service** - Enrollment CRUD & validation

---

### 4️⃣ ASSIGNMENTS MODULE
**Location:** \src/modules/assignments/\

#### Entities (2):
- **Assignment**
  - Fields: assignmentId, courseId, title, description, instructions, maxScore, weight, dueDate, availableFrom, lateSubmissionAllowed, latePenaltyPercent, submissionType (FILE/TEXT/CODE), maxFileSizeMb, allowedFileTypes, status (DRAFT/PUBLISHED/CLOSED), createdBy
  - Relationships: ManyToOne(Course), ManyToOne(User), OneToMany(AssignmentSubmission)
  
- **AssignmentSubmission**
  - Student submission with files, grade, feedback

#### DTOs (5):
- **create-assignment.dto**
- **update-assignment.dto**
- **submit-assignment.dto**
- **grade-submission.dto**
- **assignment-query.dto**

#### Controllers (1):
- **assignments.controller** (@Controller('api/assignments'))
  - GET / - List assignments with filters
  - POST / - Create assignment (INSTRUCTOR/ADMIN)
  - GET /:id - Get assignment details
  - PATCH /:id - Update assignment
  - DELETE /:id - Delete assignment
  - POST /:id/submit - Submit assignment
  - POST /:submissionId/grade - Grade submission

#### Services (1):
- **assignments.service** - CRUD & grading

---

### 5️⃣ QUIZZES MODULE
**Location:** \src/modules/quizzes/\

#### Entities (5):
- **Quiz**
  - Fields: quizId, courseId, title, description, instructions, quizType (GRADED/PRACTICE), timeLimitMinutes, maxAttempts, passingScore, randomizeQuestions, showCorrectAnswers, showAnswersAfter (enum), availableFrom, availableUntil, weight, createdBy
  - Relationships: ManyToOne(Course), ManyToOne(User), OneToMany(QuizQuestion), OneToMany(QuizAttempt)
  
- **QuizQuestion**
  - Different question types with options and correct answers
  
- **QuizAttempt**
  - Student quiz attempt with start/end times, score
  
- **QuizAnswer**
  - Individual answers to questions
  
- **QuizDifficultyLevel**
  - Question difficulty tracking

#### DTOs (10):
- **create-quiz.dto**, **update-quiz.dto**
- **create-question.dto**, **update-question.dto**
- **start-attempt.dto**, **submit-quiz.dto**
- **quiz-query.dto**, **quiz-results.dto**
- **manual-grade.dto**, **reorder-questions.dto**

#### Controllers (1):
- **quizzes.controller** (@Controller('quizzes'))
  - POST / - Create quiz (INSTRUCTOR/TA/ADMIN)
  - GET / - List quizzes
  - GET /:quizId - Get quiz details
  - PATCH /:quizId - Update quiz
  - DELETE /:quizId - Delete quiz
  - POST /:quizId/start - Start attempt
  - POST /:quizId/submit - Submit answers
  - GET /:quizId/results/:attemptId - Get attempt results

#### Services (2):
- **quizzes.service** - Quiz CRUD & attempt management
- **quiz-grading.service** - Auto & manual grading

---

### 6️⃣ GRADES MODULE
**Location:** \src/modules/grades/\

#### Entities (5):
- **Grade**
  - Fields: gradeId, userId, courseId, gradeType (ASSIGNMENT/QUIZ/LAB/EXAM/PARTICIPATION), assignmentId, quizId, labId, score, maxScore, percentage, letterGrade, feedback, gradedBy, gradedAt, isPublished
  - Relationships: ManyToOne(User), ManyToOne(Course), ManyToOne(Assignment), ManyToOne(Quiz), ManyToOne(Lab), ManyToOne(User-Grader)
  
- **GradeComponent**
  - Breakdown of grade components
  
- **Rubric**
  - Grading rubric for assignments
  
- **RubricCriteria**
  - Individual criteria within rubric
  
- **GpaCalculation**
  - GPA calculations per student/semester

#### DTOs (4):
- **create-grade.dto**, **update-grade.dto**
- **create-rubric.dto**
- **grade-query.dto**
- **transcript-response.dto**

#### Controllers (2):
- **grades.controller** (@Controller('api/grades'))
  - GET / - List grades (INSTRUCTOR/TA/ADMIN)
  - GET /my - Get student's grades (STUDENT)
  - GET /transcript/:studentId - Get transcript
  - GET /gpa/:studentId - Calculate GPA
  - GET /distribution/:courseId - Grade distribution
  - PUT /:id - Update grade
  
- **rubrics.controller** (@Controller('api/rubrics'))
  - Rubric CRUD operations

#### Services (2):
- **grades.service** - Grade CRUD, GPA calculation, transcript
- **rubrics.service** - Rubric management

---

### 7️⃣ ATTENDANCE MODULE
**Location:** \src/modules/attendance/\

#### Entities (4):
- **AttendanceSession**
  - Class session for attendance tracking
  
- **AttendanceRecord**
  - Fields: recordId, sessionId, userId, attendanceStatus (PRESENT/ABSENT/LATE/EXCUSED), checkInTime, markedBy (MANUAL/AI/SYSTEM), confidenceScore, notes
  - Relationships: ManyToOne(AttendanceSession), ManyToOne(User)
  
- **AttendancePhoto**
  - Photos for AI-based attendance
  
- **AiAttendanceProcessing**
  - AI processing status and results

#### DTOs (8):
- **create-session.dto**, **update-session.dto**
- **mark-attendance.dto**, **batch-attendance.dto**
- **update-record.dto**
- **attendance-query.dto**, **attendance-summary.dto**
- **import-attendance.dto**

#### Controllers (1):
- **attendance.controller** (@Controller('attendance'))
  - POST /sessions - Create session
  - PATCH /sessions/:id - Update session
  - POST /mark - Mark attendance
  - POST /batch - Batch mark attendance
  - GET /sessions/:sessionId - Get session records
  - POST /import - Import from Excel
  - GET /summary/:courseId - Attendance summary

#### Services (3):
- **attendance.service** - Attendance CRUD
- **attendance-excel.service** - Excel import/export
- **attendance-ai.service** - AI photo recognition

---

### 8️⃣ LABS MODULE
**Location:** \src/modules/labs/\

#### Entities (4):
- **Lab**
  - Lab assignments/projects
  
- **LabSubmission**
  - Student lab submissions with grading
  
- **LabInstruction**
  - Lab instructions and resources
  
- **LabAttendance**
  - Lab attendance tracking

#### DTOs (Multiple)
- Various lab management DTOs

#### Controllers (1):
- **labs.controller** (@Controller('api/labs'))
  - Lab CRUD and submission operations

#### Services (1):
- **labs.service** - Lab management

---

## Community & Discussion Modules

### 9️⃣ COMMUNITY MODULE
**Location:** \src/modules/community/\

#### Entities (6):
- **Community**
  - General community groups/forums
  
- **CommunityPost**
  - Fields: postId, courseId, communityId, userId, title, content, postType (DISCUSSION/QUESTION/ANNOUNCEMENT/POLL), isPinned, isLocked, viewCount, upvoteCount, replyCount
  - Relationships: ManyToOne(User), ManyToOne(Course), ManyToOne(Community), OneToMany(CommunityComment), OneToMany(CommunityReaction), ManyToMany(CommunityTag)
  
- **CommunityComment**
  - Comments on posts with nested replies
  
- **CommunityReaction**
  - Like/upvote reactions to posts
  
- **CommunityTag**
  - Tags for categorizing posts
  
- **ForumCategory**
  - Forum categories/sections

#### DTOs (12):
- **create-post.dto**, **update-post.dto**, **post-query.dto**
- **create-comment.dto**, **update-comment.dto**
- **create-reaction.dto**
- **create-tag.dto**
- **create-community.dto**, **update-community.dto**
- **create-category.dto**, **update-category.dto**
- **community-query.dto**

#### Controllers (4):
- **communities.controller** (@Controller('api/community'))
  - CRUD for communities
  
- **community-posts.controller** (@Controller('api/community/posts'))
  - GET / - List posts with filters
  - POST / - Create post
  - GET /:postId - Get post
  - PATCH /:postId - Update post
  - DELETE /:postId - Delete post
  
- **community-comments.controller** (@Controller('api/community/comments'))
  - Comments CRUD
  
- **forum-categories.controller** (@Controller('api/community/categories'))
  - Category management

#### Services (5):
- **communities.service**
- **community-posts.service**
- **community-comments.service**
- **community-tags.service**
- **forum-categories.service**

---

### 🔟 DISCUSSIONS MODULE
**Location:** \src/modules/discussions/\

#### Entities (2):
- **CourseChatThread**
  - Course-specific discussion threads
  
- **ChatMessage**
  - Individual chat messages

#### DTOs (Multiple)
- Discussion management DTOs

#### Controllers (1):
- **discussions.controller** (@Controller('api/discussions'))
  - Thread and message CRUD

#### Services (1):
- **discussions.service**

---

### 1️⃣1️⃣ ANNOUNCEMENTS MODULE
**Location:** \src/modules/announcements/\

#### Entities (1):
- **Announcement**
  - Course/system announcements with scheduling

#### DTOs (4):
- **create-announcement.dto**
- **update-announcement.dto**
- **schedule-announcement.dto**
- **announcement-query.dto**

#### Controllers (1):
- **announcements.controller** (@Controller('api/announcements'))
  - GET / - List announcements
  - POST / - Create (INSTRUCTOR/ADMIN)
  - GET /:id - Get details
  - PATCH /:id - Update
  - DELETE /:id - Delete
  - POST /:id/schedule - Schedule announcement

#### Services (1):
- **announcements.service**

---

## Administrative Modules

### 1️⃣2️⃣ CAMPUS MODULE
**Location:** \src/modules/campus/\

#### Entities (4):
- **Campus**
  - Fields: campusId, name, code (unique), address, city, country, phone, email, timezone, status (ACTIVE/INACTIVE)
  - Relationships: OneToMany(Department)
  
- **Department**
  - Fields: departmentId, campusId, name, code, phone, email, status
  - Relationships: ManyToOne(Campus)
  
- **Program**
  - Degree/program offerings
  
- **Semester**
  - Academic semester/term information

#### DTOs (4):
- **campus.dto**, **department.dto**, **program.dto**, **semester.dto**

#### Controllers (4):
- **campus.controller** (@Controller('api/campuses'))
  - Campus CRUD
  
- **department.controller** (@Controller('api'))
  - Department CRUD
  
- **program.controller** (@Controller('api'))
  - Program CRUD
  
- **semester.controller** (@Controller('api/semesters'))
  - Semester CRUD

#### Services (4):
- **campus.service**
- **department.service**
- **program.service**
- **semester.service**

---

### 1️⃣3️⃣ ATTENDANCE MODULE (Already covered - see Academic Modules)

### 1️⃣4️⃣ REPORTS MODULE
**Location:** \src/modules/reports/\

#### Entities (3):
- **GeneratedReport**
  - Generated reports for analysis
  
- **ReportTemplate**
  - Report templates for customization
  
- **ExportHistory**
  - Track exported reports

#### DTOs (2):
- **generate-report.dto**
- **report-query.dto**

#### Controllers (1):
- **reports.controller** (@Controller('api/reports'))
  - Report generation and export

#### Services (1):
- **reports.service**

---

## Infrastructure Modules

### 1️⃣5️⃣ FILES MODULE
**Location:** \src/modules/files/\

#### Entities (4):
- **Folder**
  - User/course file folders
  
- **File**
  - Files with metadata and versioning
  
- **FileVersion**
  - File version history
  
- **FilePermission**
  - File-level permissions

#### DTOs (9):
- **upload-file.dto**, **create-folder.dto**
- **file-response.dto**, **folder-response.dto**
- **file-version-response.dto**
- **file-permission.dto**, **grant-permission.dto**
- **file-search.dto**, **update-folder.dto**

#### Controllers (2):
- **files.controller** (@Controller('api/files'))
  - GET / - List files
  - POST / - Upload file
  - GET /:fileId - Download file
  - DELETE /:fileId - Delete file
  
- **folder.controller** (@Controller('api/files/folders'))
  - Folder CRUD operations

#### Services (4):
- **files.service** - File CRUD
- **folder.service** - Folder management
- **file-storage.service** - S3/Cloud storage
- **file-permission.service** - Permission management

---

### 1️⃣6️⃣ NOTIFICATIONS MODULE
**Location:** \src/modules/notifications/\

#### Entities (3):
- **Notification**
  - Fields: notificationId, userId, notificationType (announcement/grade/assignment/message/deadline/system), title, body, relatedEntityType, relatedEntityId, isRead, readAt, priority (low/medium/high/urgent), actionUrl
  - Relationships: ManyToOne(User)
  
- **NotificationPreference**
  - User notification settings
  
- **ScheduledNotification**
  - Scheduled notifications

#### DTOs (Multiple)
- Notification management DTOs

#### Controllers (1):
- **notifications.controller** (@Controller('api/notifications'))
  - Notification CRUD and preferences

#### Services (1):
- **notifications.service**

---

### 1️⃣7️⃣ MESSAGING MODULE
**Location:** \src/modules/messaging/\

#### Entities (2):
- **Message**
  - Fields: messageId, senderId, subject, body, messageType (direct/group/announcement), parentMessageId, replyToId, readStatus, sentAt, editedAt
  - Relationships: ManyToOne(Message), OneToMany(Message), OneToMany(MessageParticipant)
  
- **MessageParticipant**
  - Link messages to recipient users

#### DTOs (Multiple)
- Message management DTOs

#### Controllers (1):
- **messaging.controller** (@Controller('api/messages'))
  - Message CRUD with threading

#### Services (1):
- **messaging.service** - Message operations

---

### 1️⃣8️⃣ SCHEDULE MODULE
**Location:** \src/modules/schedule/\

#### Entities (3):
- **ExamSchedule**
  - Exam scheduling for courses
  
- **CalendarEvent**
  - Generic calendar events
  
- **CalendarIntegration**
  - Integration with Google Calendar/Outlook

#### DTOs (8):
- **create-exam-schedule.dto**, **update-exam-schedule.dto**
- **create-calendar-event.dto**, **update-calendar-event.dto**
- **query-exam-schedule.dto**, **query-calendar-event.dto**
- **connect-calendar.dto**, **query-schedule.dto**

#### Controllers (4):
- **schedule.controller** (@Controller('api/schedule'))
- **exam-schedule.controller** (@Controller('api/exams/schedule'))
- **calendar-events.controller** (@Controller('api/calendar/events'))
- **calendar-integrations.controller** (@Controller('api/calendar/integrations'))

#### Services (4):
- **schedule.service**
- **exam-schedule.service**
- **calendar-events.service**
- **calendar-integrations.service**

---

### 1️⃣9️⃣ COURSE MATERIALS MODULE
**Location:** \src/modules/course-materials/\

#### Entities (2):
- **CourseMaterial**
  - Lecture notes, slides, videos, documents
  
- **LectureSectionLab**
  - Structure linking lectures/sections/labs

#### DTOs (6):
- **create-material.dto**, **update-material.dto**
- **bulk-create-material.dto**
- **query-materials.dto**
- **create-structure.dto**, **update-structure.dto**
- **reorder-structure.dto**, **toggle-visibility.dto**
- **upload-video-material.dto**

#### Controllers (2):
- **materials.controller** (@Controller('api/courses/:courseId/materials'))
  - GET / - List materials
  - POST / - Upload material
  - PATCH /:materialId - Update material
  - DELETE /:materialId - Delete material
  
- **course-structure.controller** (@Controller('api/courses/:courseId/structure'))
  - Course structure/organization

#### Services (2):
- **materials.service**
- **course-structure.service**

---

### 2️⃣0️⃣ TASKS MODULE
**Location:** \src/modules/tasks/\

#### Entities (3):
- **StudentTask**
  - Student task management
  
- **TaskCompletion**
  - Task completion tracking
  
- **DeadlineReminder**
  - Deadline reminder notifications

#### DTOs (4):
- **create-task.dto**, **update-task.dto**
- **task-query.dto**
- **create-reminder.dto**

#### Controllers (1):
- **tasks.controller** (@Controller('api/tasks'))
  - Task CRUD and deadline reminders

#### Services (2):
- **tasks.service**
- **reminders.service** - Deadline reminders

---

### 2️⃣1️⃣ ANALYTICS MODULE
**Location:** \src/modules/analytics/\

#### Entities (6):
- **CourseAnalytics**
  - Course engagement metrics
  
- **LearningAnalytics**
  - Learning behavior tracking
  
- **PerformanceMetrics**
  - Student performance data
  
- **StudentProgress**
  - Course progress tracking
  
- **WeakTopicsAnalysis**
  - Weak topic identification for students
  
- **ActivityLog**
  - System activity logging

#### DTOs (2):
- **analytics-query.dto**
- **student-analytics-query.dto**

#### Controllers (1):
- **analytics.controller** (@Controller('api/analytics'))
  - GET /courses/:courseId - Course analytics
  - GET /students/:studentId - Student analytics
  - GET /class/:courseId - Class analytics

#### Services (2):
- **analytics.service** - Analytics calculations
- **analytics-cron.service** - Scheduled analytics processing

---

### 2️⃣2️⃣ SEARCH MODULE
**Location:** \src/modules/search/\

#### Entities (2):
- **SearchIndex**
  - Search index for full-text search
  
- **SearchHistory**
  - User search history

#### DTOs (2):
- **global-search.dto**
- **search-history-query.dto**

#### Controllers (1):
- **search.controller** (@Controller('api/search'))
  - Global search across courses, materials, announcements

#### Services (1):
- **search.service**

---

### 2️⃣3️⃣ EMAIL MODULE
**Location:** \src/modules/email/\

#### Entities: None (Service-only)

#### DTOs: None

#### Controllers: None

#### Services (1):
- **email.service** - Email sending for notifications, passwords, etc.

---

### 2️⃣4️⃣ YOUTUBE MODULE
**Location:** \src/modules/youtube/\

#### Entities: None

#### DTOs: None

#### Controllers (1):
- **youtube.controller** (@Controller('youtube'))
  - YouTube integration for video uploads

#### Services (1):
- **youtube.service** - YouTube API integration

---

## Key Relationships Summary

### User-Centric Relationships:
- User → Roles (Many-to-Many)
- User → CourseEnrollment (One-to-Many)
- User → Grade (One-to-Many)
- User → Assignment/Quiz/Lab (Many creators)
- User → Message (One-to-Many as sender)
- User → Notification (One-to-Many)

### Course-Centric Relationships:
- Course → Department (Many-to-One)
- Course → CourseSection (One-to-Many)
- Course → CourseEnrollment (One-to-Many via Section)
- Course → Assignment/Quiz/Lab (One-to-Many)
- Course → Grade (One-to-Many)
- Course → CourseMaterial (One-to-Many)
- Course → Announcement (One-to-Many)

### Academic Assessment Flow:
- Assignment → AssignmentSubmission → Grade
- Quiz → QuizAttempt → QuizAnswer → Grade
- Lab → LabSubmission → Grade
- All grades rollup to CourseEnrollment.finalScore

### Enrollment Flow:
- User → CourseEnrollment (Many-to-Many via CourseSection)
- CourseEnrollment → Grade (One-to-Many)
- CourseEnrollment.status → ENROLLED/DROPPED/COMPLETED

---

## Key Features by Module

### Authentication & Security:
- JWT token-based authentication
- Role-based access control (RBAC)
- Password hashing with bcrypt
- Email verification
- Password reset tokens
- 2FA support
- Session management

### Academic Management:
- Course enrollment with prerequisites
- Assignment submissions with late penalties
- Quiz creation with adaptive difficulty
- Grade tracking and GPA calculation
- Lab sessions and submissions
- Attendance tracking with AI recognition

### Communication:
- Direct messaging with threading
- Course discussions
- Announcements with scheduling
- Notifications with preferences
- Email integration

### Community & Engagement:
- Community forums with categories
- Posts with reactions and comments
- Tagging system
- Pinned/locked posts
- Reputation system (upvotes)

### Administrative:
- Multi-campus support
- Department and program management
- Academic calendar (semesters)
- User management (creation, role assignment)
- Report generation and export
- Analytics and performance tracking

### Infrastructure:
- File management with versioning
- File-level permissions
- Integration with cloud storage
- Calendar integration (Google/Outlook)
- Search functionality
- Activity logging
- Scheduled notifications/reminders

---

## Architecture Patterns

### Module Structure Pattern:
Each module follows: Entity → DTO → Controller → Service → Repository (TypeORM)

### Database Constraints:
- Unique indexes for key fields
- Foreign key relationships with CASCADE/SET NULL
- Soft deletes with DeleteDateColumn
- Audit trails with CreateDateColumn/UpdateDateColumn

### Authentication Guards:
- JwtAuthGuard - Validates JWT tokens
- RolesGuard - Enforces role-based access
- @Public() decorator for public endpoints
- @Roles() decorator for role requirements

### Status Enums:
- User: ACTIVE, INACTIVE, SUSPENDED, PENDING
- Course: ACTIVE, ARCHIVED
- Section: OPEN, CLOSED, FULL
- Assignment: DRAFT, PUBLISHED, CLOSED
- Enrollment: ENROLLED, DROPPED, COMPLETED
- Grade: Published/Unpublished
- Notification: Read/Unread

