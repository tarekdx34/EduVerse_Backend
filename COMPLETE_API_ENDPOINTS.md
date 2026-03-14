# 📊 EduVerse Backend - Complete API Endpoints Summary

## AUTH MODULE - api/auth (Public + Protected)
POST   /api/auth/register              - Register new user
POST   /api/auth/login                 - User login
POST   /api/auth/logout                - Logout (JWT required)
POST   /api/auth/refresh-token         - Refresh access token
POST   /api/auth/forgot-password       - Request password reset
POST   /api/auth/reset-password        - Reset with token
GET    /api/auth/me                    - Get current user profile
GET    /api/admin/users                - List users (ADMIN)
POST   /api/admin/users                - Create user (ADMIN)
GET    /api/admin/users/:id            - Get user details (ADMIN)
PATCH  /api/admin/users/:id            - Update user (ADMIN)
DELETE /api/admin/users/:id            - Delete user (ADMIN)
POST   /api/admin/users/:id/roles      - Assign roles (ADMIN)

## COURSES MODULE - api/courses
GET    /api/courses                    - List all courses
GET    /api/courses/department/:deptId - Courses by department
GET    /api/courses/:id                - Get course details
POST   /api/courses                    - Create course (INSTRUCTOR/ADMIN)
PATCH  /api/courses/:id                - Update course
DELETE /api/courses/:id                - Delete course
GET    /api/sections                   - List sections
POST   /api/sections                   - Create section
GET    /api/sections/:id               - Get section details
PATCH  /api/sections/:id               - Update section
DELETE /api/sections/:id               - Delete section
GET    /api/schedules                  - List schedules
POST   /api/schedules                  - Create schedule
GET    /api/schedules/:id              - Get schedule

## ENROLLMENTS MODULE - api/enrollments (JWT + Role-based)
GET    /api/enrollments/my-courses     - Get student's enrolled courses (STUDENT)
GET    /api/enrollments/available      - Get available courses to enroll (STUDENT)
POST   /api/enrollments                - Enroll in course (STUDENT)
DELETE /api/enrollments/:enrollmentId  - Drop course (STUDENT)
GET    /api/enrollments/:courseId      - List course enrollments (INSTRUCTOR/ADMIN)
PATCH  /api/enrollments/:id            - Update enrollment (ADMIN)

## ASSIGNMENTS MODULE - api/assignments (JWT + Role-based)
GET    /api/assignments                - List assignments (paginated, filtered)
POST   /api/assignments                - Create assignment (INSTRUCTOR/ADMIN)
GET    /api/assignments/:id            - Get assignment with submissions
PATCH  /api/assignments/:id            - Update assignment
DELETE /api/assignments/:id            - Delete assignment
POST   /api/assignments/:id/submit     - Submit assignment (STUDENT)
POST   /api/assignments/:submissionId/grade - Grade submission (INSTRUCTOR/ADMIN)
GET    /api/assignments/:id/submissions - List all submissions

## QUIZZES MODULE - quizzes (JWT + Role-based)
POST   /quizzes                        - Create quiz (INSTRUCTOR/TA/ADMIN)
GET    /quizzes                        - List quizzes
GET    /quizzes/:quizId                - Get quiz details
PATCH  /quizzes/:quizId                - Update quiz
DELETE /quizzes/:quizId                - Delete quiz
POST   /quizzes/:quizId/start          - Start quiz attempt (STUDENT)
POST   /quizzes/:quizId/submit         - Submit quiz answers
GET    /quizzes/:quizId/results/:attemptId - Get attempt results
GET    /quizzes/:quizId/statistics     - Quiz statistics (INSTRUCTOR)
POST   /quizzes/:quizId/questions      - Add question
PATCH  /quizzes/:quizId/questions/:qId - Update question
DELETE /quizzes/:quizId/questions/:qId - Delete question

## GRADES MODULE - api/grades (JWT + Role-based)
GET    /api/grades                     - List grades (INSTRUCTOR/TA/ADMIN)
GET    /api/grades/my                  - Get my grades (STUDENT)
GET    /api/grades/transcript/:studentId - Get transcript
GET    /api/grades/gpa/:studentId      - Calculate GPA
GET    /api/grades/distribution/:courseId - Grade distribution
PUT    /api/grades/:id                 - Update grade
POST   /api/grades                     - Create grade (INSTRUCTOR/ADMIN)
GET    /api/rubrics                    - List rubrics
POST   /api/rubrics                    - Create rubric
GET    /api/rubrics/:id                - Get rubric
PATCH  /api/rubrics/:id                - Update rubric
DELETE /api/rubrics/:id                - Delete rubric

## ATTENDANCE MODULE - attendance (JWT + Role-based)
POST   /attendance/sessions            - Create session (INSTRUCTOR)
PATCH  /attendance/sessions/:id        - Update session
GET    /attendance/sessions/:sessionId - Get session records
POST   /attendance/mark               - Mark attendance (INSTRUCTOR/SYSTEM)
POST   /attendance/batch              - Batch mark attendance
GET    /attendance/summary/:courseId  - Attendance summary
POST   /attendance/import             - Import from Excel
GET    /attendance/student/:studentId - Student attendance

## LABS MODULE - api/labs (JWT + Role-based)
GET    /api/labs                       - List labs
POST   /api/labs                       - Create lab (INSTRUCTOR/ADMIN)
GET    /api/labs/:id                   - Get lab details
PATCH  /api/labs/:id                   - Update lab
DELETE /api/labs/:id                   - Delete lab
POST   /api/labs/:id/submit            - Submit lab (STUDENT)
GET    /api/labs/:id/submissions       - List submissions
POST   /api/labs/:submissionId/grade   - Grade submission

## ANNOUNCEMENTS MODULE - api/announcements (JWT + Role-based)
GET    /api/announcements              - List announcements
POST   /api/announcements              - Create announcement (INSTRUCTOR/ADMIN)
GET    /api/announcements/:id          - Get announcement
PATCH  /api/announcements/:id          - Update announcement
DELETE /api/announcements/:id          - Delete announcement
POST   /api/announcements/:id/schedule - Schedule announcement

## DISCUSSIONS MODULE - api/discussions (JWT + Role-based)
GET    /api/discussions                - List discussions/threads
POST   /api/discussions                - Create thread
GET    /api/discussions/:threadId      - Get thread with messages
POST   /api/discussions/:threadId/message - Post message
DELETE /api/discussions/:messageId     - Delete message

## COMMUNITY MODULE - api/community* (JWT + Role-based)
GET    /api/community                  - List communities
POST   /api/community                  - Create community
GET    /api/community/:id              - Get community
PATCH  /api/community/:id              - Update community
DELETE /api/community/:id              - Delete community
GET    /api/community/posts            - List posts (all)
POST   /api/community/posts            - Create post
GET    /api/community/posts/:postId    - Get post with comments
PATCH  /api/community/posts/:postId    - Update post
DELETE /api/community/posts/:postId    - Delete post
POST   /api/community/posts/:postId/upvote - Upvote post
GET    /api/community/comments         - List comments
POST   /api/community/comments         - Create comment
DELETE /api/community/comments/:id     - Delete comment
POST   /api/community/reactions        - React to post/comment
GET    /api/community/categories       - List categories
POST   /api/community/categories       - Create category
PATCH  /api/community/categories/:id   - Update category
DELETE /api/community/categories/:id   - Delete category

## MESSAGING MODULE - api/messages (JWT + Role-based)
GET    /api/messages                   - List conversations
POST   /api/messages                   - Send message
GET    /api/messages/:conversationId   - Get conversation
POST   /api/messages/:messageId/reply  - Reply to message
GET    /api/messages/search            - Search messages
DELETE /api/messages/:messageId        - Delete message

## NOTIFICATIONS MODULE - api/notifications (JWT)
GET    /api/notifications              - Get user notifications
POST   /api/notifications/:id/read     - Mark as read
GET    /api/notifications/preferences  - Get preferences
PATCH  /api/notifications/preferences  - Update preferences
DELETE /api/notifications/:id          - Delete notification

## SCHEDULE MODULE - api/schedule, api/exams/schedule, api/calendar/* (JWT + Role-based)
GET    /api/schedule                   - Get user schedule
GET    /api/exams/schedule             - List exam schedules
POST   /api/exams/schedule             - Create exam schedule (INSTRUCTOR/ADMIN)
PATCH  /api/exams/schedule/:id         - Update exam schedule
DELETE /api/exams/schedule/:id         - Delete exam schedule
GET    /api/calendar/events            - List calendar events
POST   /api/calendar/events            - Create event
PATCH  /api/calendar/events/:id        - Update event
DELETE /api/calendar/events/:id        - Delete event
POST   /api/calendar/integrations      - Connect calendar (Google/Outlook)
GET    /api/calendar/integrations      - Get integration status

## COURSE MATERIALS MODULE - api/courses/:courseId/materials* (JWT + Role-based)
GET    /api/courses/:courseId/materials - List materials
POST   /api/courses/:courseId/materials - Upload material (INSTRUCTOR)
GET    /api/courses/:courseId/materials/:id - Get material
PATCH  /api/courses/:courseId/materials/:id - Update material
DELETE /api/courses/:courseId/materials/:id - Delete material
POST   /api/courses/:courseId/materials/bulk - Bulk upload
GET    /api/courses/:courseId/structure - Get course structure
POST   /api/courses/:courseId/structure - Create structure
PATCH  /api/courses/:courseId/structure/:id - Update structure
POST   /api/courses/:courseId/structure/reorder - Reorder modules

## TASKS MODULE - api/tasks (JWT + Role-based)
GET    /api/tasks                      - List tasks (STUDENT/INSTRUCTOR)
POST   /api/tasks                      - Create task
GET    /api/tasks/:id                  - Get task
PATCH  /api/tasks/:id                  - Update task
DELETE /api/tasks/:id                  - Delete task
POST   /api/tasks/:id/complete         - Mark complete
GET    /api/tasks/reminders            - Get deadline reminders
POST   /api/tasks/:id/remind           - Create reminder

## REPORTS MODULE - api/reports (JWT + Role-based)
GET    /api/reports                    - List reports
POST   /api/reports/generate           - Generate report (INSTRUCTOR/ADMIN)
GET    /api/reports/:id                - Get report
DELETE /api/reports/:id                - Delete report
POST   /api/reports/:id/export         - Export report

## ANALYTICS MODULE - api/analytics (JWT + Role-based)
GET    /api/analytics/courses/:courseId - Course analytics (INSTRUCTOR/ADMIN)
GET    /api/analytics/students/:studentId - Student analytics (STUDENT/ADMIN)
GET    /api/analytics/class/:courseId  - Class overview analytics
GET    /api/analytics/dashboard        - Dashboard data

## SEARCH MODULE - api/search (JWT)
GET    /api/search                     - Global search (courses, materials, announcements)
GET    /api/search/history             - Get search history
DELETE /api/search/history/:id         - Delete history entry
GET    /api/search/advanced            - Advanced search with filters

## CAMPUS MODULE - api/* (JWT + Role-based)
GET    /api/campuses                   - List campuses
POST   /api/campuses                   - Create campus (ADMIN)
GET    /api/campuses/:id               - Get campus
PATCH  /api/campuses/:id               - Update campus
DELETE /api/campuses/:id               - Delete campus
GET    /api/departments                - List departments
POST   /api/departments                - Create department (ADMIN)
GET    /api/departments/:id            - Get department
PATCH  /api/departments/:id            - Update department
DELETE /api/departments/:id            - Delete department
GET    /api/programs                   - List programs
POST   /api/programs                   - Create program (ADMIN)
GET    /api/semesters                  - List semesters
POST   /api/semesters                  - Create semester (ADMIN)
PATCH  /api/semesters/:id              - Update semester
DELETE /api/semesters/:id              - Delete semester

## FILES MODULE - api/files* (JWT + Role-based)
GET    /api/files                      - List files
POST   /api/files                      - Upload file
GET    /api/files/:fileId              - Download file
DELETE /api/files/:fileId              - Delete file
GET    /api/files/:fileId/versions     - Get file versions
POST   /api/files/:fileId/share        - Share file
DELETE /api/files/:fileId/permissions/:userId - Revoke permission
GET    /api/files/folders              - List folders
POST   /api/files/folders              - Create folder
GET    /api/files/folders/:folderId    - Get folder contents
PATCH  /api/files/folders/:folderId    - Update folder
DELETE /api/files/folders/:folderId    - Delete folder

## YOUTUBE MODULE - youtube (JWT + Role-based)
POST   /youtube/upload                 - Upload video to YouTube
GET    /youtube/status/:videoId        - Get upload status

---

## Authentication & Authorization

### Public Endpoints (No JWT Required):
- POST /api/auth/register
- POST /api/auth/login
- POST /api/auth/refresh-token
- POST /api/auth/forgot-password
- POST /api/auth/reset-password
- GET /api/courses (list only)

### Protected Endpoints (JWT Required):
- All endpoints requiring @UseGuards(JwtAuthGuard)
- Role-based access via @Roles() decorator

### Role-Based Access Control:
- **STUDENT**: Can access own courses, submissions, grades
- **INSTRUCTOR**: Can create courses, assignments, quizzes; grade submissions
- **TA**: Can manage assignments/quizzes; grade under instructor
- **ADMIN**: Full access to all resources
- **IT_ADMIN**: System administration

### Decorators Used:
- @UseGuards(JwtAuthGuard, RolesGuard)
- @Roles(RoleName.STUDENT, RoleName.INSTRUCTOR, etc.)
- @ApiBearerAuth('JWT-auth') - Swagger documentation
- @Public() - Marks public endpoints

---

## Common Query Parameters

### Pagination:
- **page** - Page number (default: 1)
- **limit** - Items per page (default: 20, max: 100)

### Filtering (varies by endpoint):
- **status** - Filter by status enum
- **departmentId** - Filter by department
- **courseId** - Filter by course
- **search** - Full-text search
- **semester** - Filter by semester
- **date range** - startDate, endDate

### Sorting:
- **sort** - Field to sort by
- **order** - ASC or DESC

---

## Response Format Standards

### Success Response (2xx):
\\\json
{
  "data": {...} or [...],
  "message": "Success message",
  "timestamp": "2024-01-15T10:30:00Z"
}
\\\

### Error Response (4xx/5xx):
\\\json
{
  "statusCode": 400,
  "message": "Error description",
  "error": "BadRequest | Unauthorized | Forbidden | NotFound",
  "timestamp": "2024-01-15T10:30:00Z"
}
\\\

---

## File Saved
✅ Full module analysis: COMPLETE_MODULE_ANALYSIS.md
✅ API Endpoints summary: COMPLETE_API_ENDPOINTS.md
