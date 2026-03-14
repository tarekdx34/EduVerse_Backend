# 🗄️ EduVerse Backend - Database Schema & Entity Relationships

## Core Entity Relationships

### USER HIERARCHY
\\\
User (userId) 
├── Roles (Many-to-Many)
├── Sessions (One-to-Many)
├── PasswordReset (One-to-Many)
├── TwoFactorAuth (One-to-Many)
├── UserPreference (One-to-One)
├── EmailVerification (One-to-One)
├── CourseEnrollment (One-to-Many)
├── Grade (One-to-Many)
├── Assignment (One-to-Many, as creator)
├── Quiz (One-to-Many, as creator)
├── Lab (One-to-Many, as creator)
├── CommunityPost (One-to-Many, as author)
├── Message (One-to-Many, as sender)
├── Notification (One-to-Many)
└── AttendanceRecord (One-to-Many)
\\\

### COURSE STRUCTURE
\\\
Campus (campusId)
└── Department (One-to-Many)
    └── Course (One-to-Many)
        ├── CoursePrerequisite (One-to-Many, prerequisites)
        ├── CourseSection (One-to-Many)
        │   ├── CourseSchedule (One-to-Many)
        │   ├── CourseEnrollment (One-to-Many)
        │   │   ├── CourseInstructor
        │   │   ├── CourseTA
        │   │   └── User (Student)
        │   └── AttendanceSession (One-to-Many)
        │       └── AttendanceRecord (One-to-Many)
        ├── Announcement (One-to-Many)
        ├── CourseMaterial (One-to-Many)
        ├── CourseChatThread (One-to-Many)
        ├── CommunityPost (One-to-Many)
        ├── Quiz (One-to-Many)
        ├── Assignment (One-to-Many)
        ├── Lab (One-to-Many)
        └── Grade (One-to-Many)

Semester (semesterId)
└── CourseSection (One-to-Many)
\\\

### ACADEMIC ASSESSMENT FLOW
\\\
User (Student) → CourseEnrollment → Course
                       ↓
         ┌─────────────┼─────────────┐
         ↓             ↓             ↓
    Assignment    Quiz          Lab
         ↓             ↓             ↓
  AssignmentSubmission QuizAttempt LabSubmission
         ↓             ↓             ↓
       Grade  ←────────┴─────────────┘
         ↓
    GradeComponent
    RubricCriteria
    GPACalculation
\\\

### ENROLLMENT & GRADING
\\\
CourseEnrollment (enrollmentId)
├── User (userId)
├── CourseSection (sectionId)
├── Program (programId)
└── Grade (One-to-Many for same user/course)
    ├── Assignment (links to assignment)
    ├── Quiz (links to quiz)
    └── Lab (links to lab)
\\\

### QUIZ STRUCTURE
\\\
Quiz (quizId)
├── Course (courseId)
├── CreatedBy (userId)
├── QuizQuestion (One-to-Many)
│   ├── QuizDifficultyLevel
│   └── QuizAnswer (One-to-Many, correct answers)
└── QuizAttempt (One-to-Many, by students)
    ├── User (userId)
    ├── QuizAnswer (One-to-Many, student answers)
    └── Grade (linked)
\\\

### MESSAGING & COMMUNICATION
\\\
Message (messageId)
├── Sender (userId)
├── ParentMessage (self-join for threads)
├── Replies (One-to-Many, self-join)
└── MessageParticipant (One-to-Many)
    └── User (recipients)

CourseChatThread (threadId)
├── Course (courseId)
└── ChatMessage (One-to-Many)
    ├── Sender (userId)
    └── CreatedAt (timestamp)
\\\

### COMMUNITY & FORUMS
\\\
Community (communityId)
└── CommunityPost (One-to-Many)
    ├── Author (userId)
    ├── Course (optional)
    ├── CommunityComment (One-to-Many)
    │   ├── Author (userId)
    │   └── Replies (self-join)
    ├── CommunityReaction (One-to-Many)
    │   └── User (userId)
    └── CommunityTag (Many-to-Many)

ForumCategory (categoryId)
└── CommunityPost (One-to-Many)
\\\

### FILES & STORAGE
\\\
Folder (folderId)
└── File (One-to-Many)
    ├── FileVersion (One-to-Many)
    └── FilePermission (One-to-Many)
        └── User (userId)
\\\

### NOTIFICATIONS & SCHEDULING
\\\
Notification (notificationId)
├── User (userId)
├── NotificationPreference (One-to-One)
└── ScheduledNotification (One-to-Many)

Announcement (announcementId)
└── Notification (One-to-Many, linked)

DeadlineReminder (reminderId)
├── StudentTask (taskId)
└── User (userId)
\\\

### ANALYTICS & REPORTING
\\\
CourseAnalytics
├── Course (courseId)
└── PerformanceMetrics (One-to-Many)

StudentProgress
├── User (userId)
├── Course (courseId)
└── WeakTopicsAnalysis (One-to-Many)

LearningAnalytics
├── User (userId)
└── ActivityLog (One-to-Many)

GeneratedReport
├── User (userId)
└── ReportTemplate (templateId)
\\\

### CALENDAR & SCHEDULING
\\\
CourseSchedule (course_schedules)
├── CourseSection (sectionId)
└── Day/Time info

ExamSchedule (exam_schedules)
├── Course (courseId)
└── Exam date/time

CalendarEvent (calendar_events)
├── User (userId)
└── CalendarIntegration (integrationId)
    ├── Google Calendar
    └── Outlook Calendar
\\\

---

## Database Tables (70+ total)

### AUTH TABLES (8)
- users
- roles
- permissions
- user_roles (junction)
- sessions
- password_resets
- two_factor_auths
- email_verifications
- user_preferences

### CAMPUS & ORGANIZATIONAL (4)
- campuses
- departments
- programs
- semesters

### COURSES & ENROLLMENT (7)
- courses
- course_sections
- course_schedules
- course_prerequisites
- course_enrollments
- course_instructors
- course_tas

### ACADEMIC ASSESSMENT (12)
- assignments
- assignment_submissions
- quizzes
- quiz_questions
- quiz_attempts
- quiz_answers
- quiz_difficulty_levels
- labs
- lab_submissions
- lab_instructions
- lab_attendance
- grades
- grade_components
- rubrics
- rubric_criteria
- gpa_calculations

### ATTENDANCE (4)
- attendance_sessions
- attendance_records
- attendance_photos
- ai_attendance_processing

### COMMUNICATION (5)
- announcements
- course_chat_threads
- chat_messages
- messages
- message_participants

### COMMUNITY & FORUMS (6)
- communities
- community_posts
- community_comments
- community_reactions
- community_tags
- community_post_tags (junction)
- forum_categories

### FILES & STORAGE (4)
- folders
- files
- file_versions
- file_permissions

### NOTIFICATIONS (3)
- notifications
- notification_preferences
- scheduled_notifications

### SCHEDULE & CALENDAR (3)
- exam_schedules
- calendar_events
- calendar_integrations

### MATERIALS & CONTENT (2)
- course_materials
- lecture_section_lab

### TASKS & REMINDERS (3)
- student_tasks
- task_completions
- deadline_reminders

### ANALYTICS & REPORTING (7)
- course_analytics
- learning_analytics
- performance_metrics
- student_progress
- weak_topics_analysis
- activity_logs
- generated_reports
- report_templates
- export_history

### SEARCH (2)
- search_indexes
- search_history

---

## Enum Types

### User Status
- ACTIVE
- INACTIVE
- SUSPENDED
- PENDING

### Enrollment Status
- ENROLLED
- DROPPED
- COMPLETED

### Course Status
- ACTIVE
- ARCHIVED

### Section Status
- OPEN
- CLOSED
- FULL

### Assignment Status
- DRAFT
- PUBLISHED
- CLOSED

### Submission Type
- FILE
- TEXT
- CODE

### Attendance Status
- PRESENT
- ABSENT
- LATE
- EXCUSED

### Quiz Type
- GRADED
- PRACTICE

### Question Type
- MULTIPLE_CHOICE
- TRUE_FALSE
- SHORT_ANSWER
- ESSAY

### Post Type (Community)
- DISCUSSION
- QUESTION
- ANNOUNCEMENT
- POLL

### Notification Priority
- LOW
- MEDIUM
- HIGH
- URGENT

### Notification Type
- ANNOUNCEMENT
- GRADE
- ASSIGNMENT
- MESSAGE
- DEADLINE
- SYSTEM

### Grade Type
- ASSIGNMENT
- QUIZ
- LAB
- EXAM
- PARTICIPATION

### Message Type
- DIRECT
- GROUP
- ANNOUNCEMENT

### Campus Status
- ACTIVE
- INACTIVE

---

## Key Indexes

### Performance Indexes
- users(email) - UNIQUE
- courses(departmentId, code) - UNIQUE
- course_sections(courseId, semesterId, sectionNumber) - UNIQUE
- course_enrollments(userId, sectionId) - UNIQUE
- grades(userId, courseId)
- grades(courseId, gradeType)
- attendance_records(sessionId)
- attendance_records(userId)
- attendance_records(attendanceStatus)
- assignments(courseId)
- assignments(createdBy)
- assignments(status)

---

## Relationship Cardinalities

### One-to-One (1:1)
- User ↔ UserPreference
- User ↔ EmailVerification

### One-to-Many (1:n)
- Course → CourseSection
- Course → Assignment
- Course → Quiz
- Course → Lab
- User → CourseEnrollment
- CourseEnrollment → Grade

### Many-to-Many (n:m)
- User ↔ Role (via user_roles)
- Community ↔ User (members)
- CommunityPost ↔ CommunityTag

### Self-Referencing
- Message → ParentMessage/Replies
- CommunityComment → ParentComment/Replies

---

## Cascade Rules

### CASCADE (ON DELETE CASCADE)
- CourseSection → when Course deleted
- Assignment → when Course deleted
- AssignmentSubmission → when Assignment deleted
- Grade → when Course/User/Assignment deleted
- AttendanceRecord → when AttendanceSession deleted
- Quiz → when Course deleted
- Message → when Sender/ParentMessage deleted

### SET NULL (ON DELETE SET NULL)
- Grade.gradedBy → when Grader User deleted
- Grade.quiz → when Quiz deleted
- Grade.lab → when Lab deleted
- CourseEnrollment.program → when Program deleted
- PasswordReset → soft delete

### RESTRICT (ON DELETE RESTRICT)
- User → cannot delete while enrolled in courses (must drop first)
- Course → cannot delete while having active sections

---

## Soft Deletes

The following entities support soft deletion (not physically removed):
- User
- Course
- Assignment
- Quiz
- Announcement
- CommunityPost
- Message

### Soft Delete Implementation
- Added deleted_at column
- Type: DeleteDateColumn from TypeORM
- Queries automatically filter deleted records
- Can be restored (set deleted_at to NULL)

---

## Audit Timestamps

All main entities include:
- **created_at** - Record creation timestamp (immutable)
- **updated_at** - Last modification timestamp (auto-updated)

Examples:
- users: createdAt, updatedAt
- courses: createdAt, updatedAt
- grades: createdAt, updatedAt
- messages: sentAt, editedAt

---

## Junction Tables

Many-to-Many relationships use junction tables:
- user_roles (user_id ↔ role_id)
- community_post_tags (post_id ↔ tag_id)
- [Any other n:m relationship in future]

---

## Search Capabilities

### Full-Text Search Tables
- search_indexes - Indexed content for quick lookup
- search_history - User search queries for analytics

### Searchable Entities
- Courses (name, code, description)
- CourseMaterial (title, content)
- CommunityPost (title, content)
- Announcement (title, content)
- Assignment (title, description, instructions)

