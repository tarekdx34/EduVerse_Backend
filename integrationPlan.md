# EduVerse Frontend Integration Master Plan — Updated
**Last Updated**: 2026-03-15  
**Stack**: React (Vite) + NestJS Backend | **Base URL**: `http://localhost:8081`

---

## ✅ COMPLETED

- Phase 0 — Infrastructure (Axios, AuthContext, ProtectedRoute, error handling, pagination)
- Phase 1 — Auth + Layout (login, logout, refresh, role routing, all 4 dashboard shells, sidebar, header, profile, settings)
- Phase 8 — Messaging (full WebSocket chat on all tabs, Socket.IO, fallback polling)
- Phase 2 — Semester fix (active semester, date range fix in backend)
- Course Management — Create course (multi-step: course + section + schedule + staff), course cards rendering, instructor/TA assignment + display (with new backend endpoints GET /section/:id/instructor and /tas)

---

## REMAINING API MAPPING

### Admin — User Management (`/api/admin`) — NOT YET INTEGRATED

| Method | Endpoint | Component | Roles |
|--------|----------|-----------|-------|
| GET | `/api/admin/users` | `<UserManagementPage />` | admin, it_admin |
| GET | `/api/admin/users/search` | `<UserSearchBar />` | admin, it_admin |
| GET | `/api/admin/users/statistics` | `<AdminDashboard />` | admin, it_admin |
| GET | `/api/admin/users/:id` | `<UserDetailModal />` | admin, it_admin |
| PUT | `/api/admin/users/:id` | `<EditUserForm />` | admin, it_admin |
| PUT | `/api/admin/users/:id/status` | `<UserStatusToggle />` | admin, it_admin |
| GET | `/api/admin/roles` | `<RolesListPage />` | admin, it_admin |
| POST | `/api/admin/roles` | `<CreateRoleForm />` | it_admin only |
| GET | `/api/admin/permissions/matrix` | `<PermissionsMatrix />` | admin, it_admin |

### Campus (`/api/campuses`, `/api/departments`, `/api/programs`) — NOT YET INTEGRATED

| Method | Endpoint | Component | Roles |
|--------|----------|-----------|-------|
| GET | `/api/campuses` | `<CampusListPage />` | Any |
| POST | `/api/campuses` | `<CreateCampusForm />` | admin, it_admin |
| PUT | `/api/campuses/:id` | `<EditCampusForm />` | admin, it_admin |
| GET | `/api/campuses/:id/departments` | `<DepartmentList />` | Any |
| POST | `/api/departments` | `<CreateDeptForm />` | admin, it_admin |
| GET | `/api/departments/:id/programs` | `<ProgramList />` | Any |
| POST | `/api/programs` | `<CreateProgramForm />` | admin, it_admin |

### Enrollments (`/api/enrollments`) — PARTIALLY DONE

| Method | Endpoint | Component | Roles | Status |
|--------|----------|-----------|-------|--------|
| GET | `/api/enrollments/my-courses` | `<MyCoursesSidebar />` | student | ❌ TODO |
| GET | `/api/enrollments/available` | `<AvailableCoursesPage />` | student | ❌ TODO |
| POST | `/api/enrollments/register` | `<EnrollButton />` | student | ❌ TODO |
| DELETE | `/api/enrollments/:id` | `<DropCourseButton />` | student | ❌ TODO |
| GET | `/api/enrollments/section/:id/students` | `<StudentRosterTable />` | instructor, admin | ❌ TODO |
| GET | `/api/enrollments/section/:id/waitlist` | `<WaitlistTable />` | instructor, admin | ❌ TODO |
| POST | `/api/enrollments/assign-instructor` | multi-step modal | admin | ✅ DONE |
| POST | `/api/enrollments/assign-ta` | multi-step modal | admin | ✅ DONE |
| GET | `/api/enrollments/section/:id/instructor` | course card display | admin | ✅ DONE |
| GET | `/api/enrollments/section/:id/tas` | course card display | admin | ✅ DONE |

### Course Materials (`/api/courses/:id/materials`) — NOT YET

| Method | Endpoint | Component | Roles |
|--------|----------|-----------|-------|
| GET | `/api/courses/:id/materials` | `<MaterialsList />` | Any |
| POST | `/api/courses/:id/materials` | `<CreateMaterialForm />` | instructor, ta, admin |
| POST | `/api/courses/:id/materials/video` | `<VideoUploadModal />` | instructor, ta, admin |
| PUT | `/api/courses/:id/materials/:matId` | `<EditMaterialForm />` | instructor, ta, admin |
| DELETE | `/api/courses/:id/materials/:matId` | `<DeleteMaterialButton />` | instructor, admin |
| PATCH | `/api/courses/:id/materials/:matId/visibility` | `<VisibilityToggle />` | instructor, ta, admin |
| GET | `/api/courses/:id/materials/:matId/download` | `<DownloadButton />` | Any |
| GET | `/api/courses/:id/materials/:matId/embed` | `<VideoPlayer />` | Any |
| GET | `/api/courses/:id/structure` | `<CourseStructureView />` | Any |
| POST | `/api/courses/:id/structure` | `<AddWeekForm />` | instructor, admin |

### Assignments (`/api/assignments`) — NOT YET

| Method | Endpoint | Component | Roles |
|--------|----------|-----------|-------|
| GET | `/api/assignments?courseId=X` | `<AssignmentsList />` | Any |
| POST | `/api/assignments` | `<CreateAssignmentForm />` | instructor, admin |
| PATCH | `/api/assignments/:id` | `<EditAssignmentForm />` | instructor, admin |
| POST | `/api/assignments/:id/submit` | `<SubmitAssignmentForm />` | student |
| GET | `/api/assignments/:id/submissions/my` | `<MySubmissionView />` | student |
| GET | `/api/assignments/:id/submissions` | `<AllSubmissionsTable />` | instructor, ta, admin |
| PATCH | `/api/assignments/:id/submissions/:subId/grade` | `<GradeSubmissionForm />` | instructor, ta |

### Quizzes (`/quizzes`) — NOT YET

| Method | Endpoint | Component | Roles |
|--------|----------|-----------|-------|
| GET | `/quizzes?courseId=X` | `<QuizList />` | Any |
| POST | `/quizzes` | `<CreateQuizForm />` | instructor, ta, admin |
| GET | `/quizzes/:id` | `<QuizDetailPage />` | Any |
| POST | `/quizzes/:quizId/attempts/start` | `<StartQuizButton />` | student |
| POST | `/quizzes/attempts/:attemptId/submit` | `<QuizSubmitButton />` | student |
| GET | `/quizzes/my-attempts` | `<MyQuizAttemptsPage />` | student |
| GET | `/quizzes/attempts` | `<AllAttemptsTable />` | instructor, ta, admin |
| GET | `/quizzes/:quizId/statistics` | `<QuizStatisticsChart />` | instructor, admin |
| POST | `/quizzes/:quizId/questions` | `<AddQuestionForm />` | instructor, ta, admin |

### Labs (`/api/labs`) — NOT YET

| Method | Endpoint | Component | Roles |
|--------|----------|-----------|-------|
| GET | `/api/labs?courseId=X` | `<LabsList />` | Any |
| POST | `/api/labs` | `<CreateLabForm />` | instructor, ta, admin |
| GET | `/api/labs/:id/instructions` | `<LabInstructionsView />` | Any |
| POST | `/api/labs/:id/submit` | `<SubmitLabForm />` | student |
| GET | `/api/labs/:id/submissions/my` | `<MyLabSubmissionView />` | student |
| GET | `/api/labs/:id/submissions` | `<LabSubmissionsTable />` | instructor, ta, admin |
| POST | `/api/labs/:id/attendance` | `<MarkLabAttendanceForm />` | instructor, ta, admin |

### Grades (`/api/grades`) — NOT YET

| Method | Endpoint | Component | Roles |
|--------|----------|-----------|-------|
| GET | `/api/grades/my` | `<MyGradesPage />` | student |
| GET | `/api/grades/gpa/:studentId` | `<GPAWidget />` | student, admin |
| GET | `/api/grades/transcript/:studentId` | `<TranscriptView />` | student, admin |
| GET | `/api/grades?courseId=X` | `<GradebookTable />` | instructor, ta, admin |
| GET | `/api/grades/distribution/:courseId` | `<GradeDistributionChart />` | instructor, admin |
| PUT | `/api/grades/:id` | `<EditGradeForm />` | instructor, ta |
| GET | `/api/rubrics?courseId=X` | `<RubricsList />` | instructor, ta |
| POST | `/api/rubrics` | `<CreateRubricForm />` | instructor |

### Attendance (`/attendance`) — NOT YET

| Method | Endpoint | Component | Roles |
|--------|----------|-----------|-------|
| POST | `/attendance/sessions` | `<CreateSessionForm />` | instructor, ta, admin |
| GET | `/attendance/sessions?sectionId=X` | `<AttendanceSessionsList />` | instructor, ta, admin |
| POST | `/attendance/records/batch` | `<BatchAttendanceForm />` | instructor, ta, admin |
| GET | `/attendance/my` | `<MyAttendancePage />` | student |
| GET | `/attendance/by-course/:courseId` | `<CourseAttendancePage />` | instructor, ta, admin |
| GET | `/attendance/summary/:sectionId` | `<AttendanceSummaryChart />` | instructor, ta, admin |
| POST | `/attendance/import-excel` | `<ImportAttendanceButton />` | instructor, admin |

### Announcements (`/api/announcements`) — NOT YET

| Method | Endpoint | Component | Roles |
|--------|----------|-----------|-------|
| GET | `/api/announcements` | `<AnnouncementsList />` | Any |
| POST | `/api/announcements` | `<CreateAnnouncementForm />` | instructor, ta, admin |
| PUT | `/api/announcements/:id` | `<EditAnnouncementForm />` | instructor, ta, admin |
| PATCH | `/api/announcements/:id/publish` | `<PublishButton />` | instructor, admin |
| PATCH | `/api/announcements/:id/pin` | `<PinToggle />` | instructor, admin |

### Discussions (`/api/discussions`) — NOT YET

| Method | Endpoint | Component | Roles |
|--------|----------|-----------|-------|
| GET | `/api/discussions?courseId=X` | `<DiscussionsList />` | Any |
| POST | `/api/discussions` | `<CreateThreadForm />` | Any |
| GET | `/api/discussions/:id` | `<ThreadDetailPage />` | Any |
| POST | `/api/discussions/:id/reply` | `<ReplyForm />` | Any |
| PATCH | `/api/discussions/:id/pin` | `<PinThreadButton />` | instructor, ta, admin |
| PATCH | `/api/discussions/:id/lock` | `<LockThreadButton />` | instructor, ta, admin |

### Community (`/api/community`) — NOT YET

| Method | Endpoint | Component | Roles |
|--------|----------|-----------|-------|
| GET | `/api/community/global` | `<GlobalFeedPage />` | Any |
| GET | `/api/community/communities` | `<CommunitiesList />` | Any |
| GET | `/api/community/communities/:id/posts` | `<CommunityPostsFeed />` | Any |
| POST | `/api/community/communities/:id/posts` | `<CreatePostForm />` | Any |
| POST | `/api/community/posts/:id/comment` | `<CommentForm />` | Any |
| POST | `/api/community/posts/:id/react` | `<ReactionButton />` | Any |

### Files (`/api/files`) — NOT YET

| Method | Endpoint | Component | Roles |
|--------|----------|-----------|-------|
| POST | `/api/files/upload` | `<FileUploadDropzone />` | Any |
| GET | `/api/files/recent` | `<RecentFilesWidget />` | Any |
| GET | `/api/files/shared` | `<SharedFilesPage />` | Any |
| GET | `/api/files/search` | `<FileSearchPage />` | Any |
| GET | `/api/files/:fileId/download` | `<DownloadFileButton />` | Any |
| GET | `/api/files/folders/:id/children` | `<FolderBrowser />` | Any |
| POST | `/api/files/folders` | `<CreateFolderForm />` | Any |

### Notifications (`/api/notifications`) — NOT YET

| Method | Endpoint | Component | Roles |
|--------|----------|-----------|-------|
| GET | `/api/notifications/unread-count` | `<BellIcon />` | Any |
| GET | `/api/notifications` | `<NotificationsDropdown />` | Any |
| PATCH | `/api/notifications/read-all` | `<MarkAllReadButton />` | Any |
| GET | `/api/notifications/preferences` | `<NotificationSettingsPage />` | Any |
| PUT | `/api/notifications/preferences` | `<NotificationSettingsForm />` | Any |
| POST | `/api/notifications/send` | `<SendNotificationForm />` | admin, it_admin |

### Schedule & Calendar — NOT YET

| Method | Endpoint | Component | Roles |
|--------|----------|-----------|-------|
| GET | `/api/schedule/my/daily` | `<DailyScheduleWidget />` | Any |
| GET | `/api/schedule/my/weekly` | `<WeeklyCalendarView />` | Any |
| GET | `/api/calendar/events` | `<PersonalEventsList />` | Any |
| POST | `/api/calendar/events` | `<CreateEventForm />` | Any |
| GET | `/api/exams/schedule` | `<ExamSchedulePage />` | Any |
| POST | `/api/exams/schedule` | `<CreateExamForm />` | instructor, admin |

### Analytics & Reports — NOT YET

| Method | Endpoint | Component | Roles |
|--------|----------|-----------|-------|
| GET | `/api/analytics/dashboard` | `<AdminAnalyticsDashboard />` | admin |
| GET | `/api/analytics/performance?courseId=X` | `<PerformanceChart />` | admin, instructor |
| GET | `/api/analytics/courses/:courseId` | `<CourseAnalyticsPage />` | instructor |
| GET | `/api/analytics/students/:studentId` | `<StudentAnalyticsPage />` | student, admin |
| GET | `/api/analytics/at-risk-students` | `<AtRiskStudentsAlert />` | instructor, admin |
| GET | `/api/reports/templates` | `<ReportTemplatesList />` | admin |
| POST | `/api/reports/generate` | `<GenerateReportForm />` | admin |
| GET | `/api/reports/history` | `<ReportHistoryPage />` | admin |

### Search (`/api/search`) — NOT YET

| Method | Endpoint | Component | Roles |
|--------|----------|-----------|-------|
| GET | `/api/search?query=X` | `<GlobalSearchPage />` | Any |
| GET | `/api/search/courses` | `<CourseSearchResults />` | Any |
| GET | `/api/search/users` | `<UserSearchResults />` | Any |
| GET | `/api/search/materials` | `<MaterialSearchResults />` | Any |

### Tasks & Reminders (`/api/tasks`) — NOT YET

| Method | Endpoint | Component | Roles |
|--------|----------|-----------|-------|
| GET | `/api/tasks?page=1&limit=20` | `<TasksListPage />` | Any |
| POST | `/api/tasks` | `<CreateTaskForm />` | Any |
| GET | `/api/tasks/upcoming?days=7` | `<UpcomingTasksWidget />` | Any |
| PATCH | `/api/tasks/:id` | `<EditTaskForm />` | Any |
| POST | `/api/tasks/:id/complete` | `<CompleteTaskButton />` | Any |
| POST | `/api/tasks/reminders` | `<SetReminderForm />` | Any |

---

## REMAINING PHASES

### Next Up — Phase 3 Completion: Student Enrollment Flow

**Goal**: Student can browse courses, enroll, see My Courses sidebar, view roster.

- [ ] COURSE-03 `<MyCoursesSidebar />` — GET `/api/enrollments/my-courses`
- [ ] COURSE-04 `<AvailableCoursesPage />` — GET `/api/enrollments/available`
- [ ] COURSE-05 `<EnrollButton />` with section picker modal — POST `/api/enrollments/register`
- [ ] COURSE-06 `<DropCourseButton />` — DELETE `/api/enrollments/:id`
- [ ] COURSE-07 `<StudentRosterTable />` — GET `/api/enrollments/section/:sectionId/students`
- [ ] COURSE-08 `<WaitlistTable />` — GET `/api/enrollments/section/:sectionId/waitlist`
- [ ] COURSE-09 `<SectionScheduleView />` — GET `/api/schedules/section/:sectionId`

---

### Phase 4 — Course Materials + Structure

**Goal**: Instructor uploads materials (files + YouTube). Student views/downloads.

- [ ] MAT-01 `<CourseStructureView />` — GET `/api/courses/:id/structure`
- [ ] MAT-02 `<MaterialsList />` — GET `/api/courses/:id/materials` (student: published only)
- [ ] MAT-03 `<VideoPlayer />` — renders YouTube iframe from `externalUrl`
- [ ] MAT-04 `<DownloadButton />` — GET `/api/courses/:id/materials/:matId/download`
- [ ] MAT-05 `<FileUploadModal />` — POST with field `file`, show progress bar
- [ ] MAT-06 `<VideoUploadModal />` — POST with field `video`, YouTube upload
- [ ] MAT-07 `<VisibilityToggle />` — PATCH visibility `{ isPublished: bool }`
- [ ] MAT-08 `<EditMaterialForm />` — PUT material
- [ ] MAT-09 `<AddWeekForm />` — POST `/api/courses/:id/structure`

---

### Phase 5 — Assignments + Quizzes + Labs

**Goal**: Full assessment workflow. Students submit. Instructors grade.

#### Assignments
- [ ] ASGN-01 `<AssignmentsList />` — sorted by dueDate, badge for overdue
- [ ] ASGN-02 `<AssignmentDetailPage />` — instructions + due date + max score
- [ ] ASGN-03 `<SubmitAssignmentForm />` — multipart with optional file
- [ ] ASGN-04 `<MySubmissionView />` — show grade + feedback if graded
- [ ] ASGN-05 `<AllSubmissionsTable />` — paginated, sortable by grade
- [ ] ASGN-06 `<GradeSubmissionForm />` — score + feedback + letterGrade
- [ ] ASGN-07 `<CreateAssignmentForm />` — POST with courseId, title, dueDate, maxScore

#### Quizzes
- [ ] QUIZ-01 `<QuizList />` — show availability window, attempts remaining
- [ ] QUIZ-02 `<QuizAttemptPage />` — timed, countdown timer, auto-submit
- [ ] QUIZ-03 `<QuizResultPage />` — score + answers if allowed
- [ ] QUIZ-04 `<QuizBuilderPage />` — create quiz + add questions
- [ ] QUIZ-05 `<QuizStatisticsChart />` — Chart.js bar chart
- [ ] QUIZ-06 `<MyQuizAttemptsPage />` — GET `/quizzes/my-attempts`

#### Labs
- [ ] LAB-01 `<LabsList />` — per course
- [ ] LAB-02 `<LabDetailPage />` — instructions view
- [ ] LAB-03 `<SubmitLabForm />` — text + optional file
- [ ] LAB-04 `<MyLabSubmissionView />` — student view
- [ ] LAB-05 `<LabSubmissionsTable />` + `<GradeLabForm />`
- [ ] LAB-06 `<MarkLabAttendanceForm />` — present/absent per student

---

### Phase 6 — Grades + Attendance + Rubrics

#### Grades
- [ ] GRADE-01 `<MyGradesPage />` — grouped by course, letter grade + score
- [ ] GRADE-02 `<GPAWidget />` — on student dashboard home
- [ ] GRADE-03 `<TranscriptView />` — full academic history
- [ ] GRADE-04 `<GradebookTable />` — editable cells for instructor
- [ ] GRADE-05 `<GradeDistributionChart />` — Chart.js histogram
- [ ] GRADE-06 `<EditGradeForm />` — PUT `/api/grades/:id`
- [ ] GRADE-07 `<CreateRubricForm />` — POST `/api/rubrics`
- [ ] GRADE-08 `<RubricsList />` — GET `/api/rubrics?courseId=X`

#### Attendance
- [ ] ATT-01 `<CreateSessionForm />` — POST `/attendance/sessions`
- [ ] ATT-02 `<AttendanceSessionsList />` — GET sessions by section
- [ ] ATT-03 `<BatchAttendanceForm />` — present/absent/late toggles per student
- [ ] ATT-04 `<MyAttendancePage />` — per-course attendance percentage
- [ ] ATT-05 `<CourseAttendancePage />` — instructor view
- [ ] ATT-06 `<AttendanceSummaryChart />` — Chart.js line chart
- [ ] ATT-07 `<ImportAttendanceButton />` — Excel file upload
- [ ] ATT-08 `<ExportAttendanceButton />` — download Excel

---

### Phase 7 — Announcements + Discussions + Schedule

#### Announcements
- [ ] ANN-01 `<AnnouncementsList />` — pinned first, role-filtered
- [ ] ANN-02 `<CreateAnnouncementForm />` — rich text editor
- [ ] ANN-03 `<PinToggle />` — PATCH pin
- [ ] ANN-04 `<PublishButton />` — PATCH publish

#### Discussions
- [ ] DISC-01 `<DiscussionsList />` — per course, pinned first
- [ ] DISC-02 `<ThreadDetailPage />` — thread + replies
- [ ] DISC-03 `<ReplyForm />` — inline reply
- [ ] DISC-04 `<PinThreadButton />` + `<LockThreadButton />`

#### Schedule
- [ ] SCHED-01 `<DailyScheduleWidget />` — on dashboard home
- [ ] SCHED-02 `<WeeklyCalendarView />` — FullCalendar
- [ ] SCHED-03 `<CalendarPage />` — schedule + personal events + exams
- [ ] SCHED-04 `<ExamSchedulePage />` — sorted by date
- [ ] SCHED-05 `<CreateExamForm />` — POST `/api/exams/schedule`

---

### Phase 9 — Notifications + Files + Community

#### Notifications
- [ ] NOTIF-01 `<BellIcon />` — poll unread-count every 30s
- [ ] NOTIF-02 `<NotificationsDropdown />` — click navigates by relatedEntityType
- [ ] NOTIF-03 `<NotificationsPage />` — full paginated list
- [ ] NOTIF-04 `<MarkAllReadButton />`
- [ ] NOTIF-05 `<NotificationSettingsPage />`
- [ ] NOTIF-06 `<SendNotificationForm />` — admin only

#### Files
- [ ] FILES-01 `<FilesPage />` — tabs: Recent / Shared / Search / Folders
- [ ] FILES-02 `<RecentFilesWidget />` — on dashboard
- [ ] FILES-03 `<FileUploadDropzone />` — drag-and-drop, progress bar
- [ ] FILES-04 `<FolderBrowser />` — breadcrumb navigation
- [ ] FILES-05 `<CreateFolderForm />`
- [ ] FILES-06 `<DownloadFileButton />`

#### Community
- [ ] COMM-01 `<CommunityPage />` — Global Feed + Department Communities tabs
- [ ] COMM-02 `<PostDetailPage />` — post + comments + reactions
- [ ] COMM-03 `<CreatePostForm />` — rich text + tag selector
- [ ] COMM-04 `<CommentForm />`
- [ ] COMM-05 `<ReactionButton />` — toggle like

---

### Phase 10 — Analytics + Reports + Search

- [ ] ANAL-01 `<AdminAnalyticsDashboard />` — system-wide stats cards
- [ ] ANAL-02 `<PerformanceChart />` — Chart.js line chart
- [ ] ANAL-03 `<InstructorAnalyticsDashboard />` — course-specific
- [ ] ANAL-04 `<StudentAnalyticsPage />` — personal progress
- [ ] ANAL-05 `<AtRiskStudentsAlert />` — warning table
- [ ] REPORT-01 `<ReportTemplatesList />`
- [ ] REPORT-02 `<GenerateReportForm />`
- [ ] REPORT-03 `<ReportHistoryPage />` + `<DownloadReportButton />`
- [ ] SEARCH-01 `<GlobalSearchPage />` — tabbed results
- [ ] SEARCH-02 Wire `<GlobalSearchBar />` in header

---

### Phase 11 — Tasks + Google Drive + YouTube

- [ ] TASKS-01 `<TasksListPage />` — filter by status/priority
- [ ] TASKS-02 `<CreateTaskForm />`
- [ ] TASKS-03 `<UpcomingTasksWidget />` — dashboard widget
- [ ] TASKS-04 `<EditTaskForm />`
- [ ] TASKS-05 `<CompleteTaskButton />`
- [ ] TASKS-06 `<SetReminderForm />`
- [ ] DRIVE-01 `<GoogleDriveConnectPage />` — OAuth flow
- [ ] DRIVE-02 `<DriveFolderBrowser />`
- [ ] YT-01 `<YouTubeSetupPage />` — admin one-time OAuth
- [ ] YT-02 `<YouTubeSearchModal />`

---

### Phase 12 — Polish + Accessibility

- [ ] Loading skeletons on all data-fetching components
- [ ] Empty state components for zero-data cases
- [ ] Error boundaries on all route-level pages
- [ ] Form validation errors inline
- [ ] Mobile responsive — sidebar collapse on <768px
- [ ] Dark mode — respect prefers-color-scheme
- [ ] Accessibility — ARIA labels, keyboard navigation
- [ ] E2E test each role's critical path

---

## Known Backend Gaps

| Gap | Workaround |
|-----|-----------|
| No auto-notifications on assignment/grade | Admin sends manually |
| Notifications not real-time | Poll every 30s |
| YouTube OAuth must be set up first | Show warning in VideoUploadModal |
| No student progress % | Calculate client-side |
| Calendar not auto-populated | Merge schedule API into FullCalendar |

## Test Accounts

| Role | Email | Password |
|------|-------|----------|
| Admin | admin.tarek@example.com | SecureP@ss123 |
| Instructor | instructor.tarek@example.com | SecureP@ss123 |
| Student | student.tarek@example.com | SecureP@ss123 |
| TA | ta.tarek@example.com | SecureP@ss123 |
| IT Admin | it_admin.tarek@example.com | SecureP@ss123 |

## Endpoint Prefix Watch ⚠️

These do NOT use `/api/` prefix:
- Quizzes → `/quizzes/`
- Attendance → `/attendance/`
- YouTube → `/youtube/`
- Google Drive → `/google-drive/`
