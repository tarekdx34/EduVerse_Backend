# Contract: Phased Frontend-Backend Integration Plan

This document defines the phased technical integration contract, mirroring backend phase progression while specifying API scope, frontend surfaces, state strategy, and error handling for each phase.

## Cross-Phase Standards

### API client and auth

- Access token held in memory.
- Refresh token flow is cookie-first with temporary request-body fallback.
- Role is single-valued: student OR instructor OR admin.

### State management baseline

- Server state: query/mutation cache layer (React Query style), keyed per module and filter set.
- Session/auth state: centralized auth context/store with refresh orchestration.
- UI state: local component state for transient controls; route state for URL-driven filters.

### Pagination baseline

- Canonical paginated response envelope expected:
  - page
  - limit
  - total
  - totalPages
  - data
- Filters/sort reset page to 1.

### Error normalization baseline

- Normalize to categories:
  - authentication
  - authorization
  - validation
  - conflict
  - not-found
  - server-error
  - transient-network

## Phase 1: Auth + Campus (Foundation)

### API endpoints to integrate

- Auth:
  - POST /api/auth/login
  - POST /api/auth/refresh-token
  - POST /api/auth/logout
  - GET /api/auth/me
  - GET /api/users/profile
  - PUT /api/users/profile
  - GET /api/users/preferences
  - PUT /api/users/preferences
- Campus:
  - GET /api/campuses
  - GET /api/campuses/:id
  - GET /api/campuses/:campusId/departments
  - GET /api/departments/:id
  - GET /api/departments/:deptId/programs
  - GET /api/programs/:id
  - GET /api/semesters
  - GET /api/semesters/current

### Frontend components/pages needed

- Auth pages:
  - login page
  - session-expired redirect view
- Foundation shells:
  - role-aware app layout
  - protected route wrapper
- Campus views:
  - campus list and campus detail
  - department and program selectors
  - semester selector component
- Profile views:
  - profile page
  - preferences page

### State management approach

- Auth store owns session lifecycle and role claim.
- Bootstrap query loads me/profile/preferences at app startup after auth.
- Campus dictionary data cached globally with background refresh.

### Error handling patterns

- 401 triggers silent refresh, then sign-in redirect on failure.
- 403 shows no-access page or disabled action with explanation.
- Validation errors are shown inline for profile/preferences updates.

## Phase 2: Courses + Enrollments + Grades

### API endpoints to integrate

- Courses and sections:
  - GET /api/courses
  - GET /api/courses/:id
  - GET /api/courses/department/:deptId
  - GET /api/sections/course/:courseId
  - GET /api/sections/:id
  - GET /api/schedules/section/:sectionId
- Enrollments:
  - GET /api/enrollments/periods
  - GET /api/enrollments/my-courses
  - GET /api/enrollments/available
  - POST /api/enrollments/register
  - DELETE /api/enrollments/:id
- Grades:
  - GET /api/grades/my
  - GET /api/grades
  - GET /api/grades/transcript/:studentId
  - GET /api/grades/gpa/:studentId
  - GET /api/grades/distribution/:courseId

### Frontend components/pages needed

- Course catalog page
- Course detail page
- Section and schedule subviews
- Enrollment management page (student)
- Instructor enrollment list/roster view
- Grades page
- Transcript and GPA widgets

### State management approach

- Paginated query keys include role, filters, page, limit.
- Enrollment mutations invalidate course availability and my-courses caches.
- Grades and transcript use role-specific read models to avoid overfetch.

### Error handling patterns

- Conflict errors for enrollment seat/prerequisite issues shown as actionable banners.
- Not-found on stale course links routes to safe empty/not-found state.
- Paginated empty states handled consistently via canonical envelope.

## Phase 3: Assignments + Quizzes + Attendance

### API endpoints to integrate

- Assignments:
  - GET /api/assignments
  - GET /api/assignments/:id
  - POST /api/assignments
  - PATCH /api/assignments/:id
  - POST /api/assignments/:id/submit
  - GET /api/assignments/:id/submissions/my
- Quizzes:
  - GET /quizzes
  - GET /quizzes/:id
  - POST /quizzes
  - POST /quizzes/:id/start
  - POST /quizzes/:id/submit
  - GET /quizzes/my-attempts
- Attendance:
  - GET /attendance/sessions
  - POST /attendance/sessions
  - GET /attendance/my
  - GET /attendance/by-course/:courseId
  - POST /attendance/records
  - POST /attendance/records/batch

### Frontend components/pages needed

- Assignment list/detail and submission views
- Instructor grading queue and submission review view
- Quiz list, attempt runner, result view
- Attendance session board and student attendance history view

### State management approach

- Mutation-heavy workflow with optimistic updates where safe (submission status, attendance marks).
- Separate student and instructor query domains per module to preserve role boundaries.
- Quiz attempt state kept in dedicated transient store for timer/progress safety.

### Error handling patterns

- Validation errors for submissions and quiz payloads shown at field and summary levels.
- Timeout/transient errors provide retry affordance without losing draft progress.
- Authorization failures for grading operations degrade to read-only mode.

## Phase 4: Messaging (WebSocket) + Notifications + Announcements

### API endpoints/events to integrate

- Messaging HTTP:
  - GET /api/messages/conversations
  - GET /api/messages/conversations/:id
  - POST /api/messages/conversations
  - POST /api/messages/conversations/:id
  - PATCH /api/messages/:id/read
  - GET /api/messages/unread-count
- Messaging websocket namespace:
  - /messaging events: join_conversation, leave_conversation, send_message, typing, mark_read, edit_message, delete_message
  - server events: new_message, new_message_notification, user_typing, message_read, message_edited, message_deleted, user_status
- Notifications:
  - GET /api/notifications
  - GET /api/notifications/unread-count
  - PATCH /api/notifications/read-all
  - GET /api/notifications/preferences
  - PUT /api/notifications/preferences
- Announcements:
  - GET /api/announcements
  - GET /api/announcements/:id

### Frontend components/pages needed

- Conversation list panel and conversation thread page
- Message composer with typing/read indicators
- Notification center panel
- Announcement feed and announcement detail page

### State management approach

- Socket-first event stream with polling fallback for active thread + unread counters.
- Event reducer layer reconciles incoming events into query cache.
- Notification and announcement feeds use paginated canonical list handling.

### Error handling patterns

- Socket disconnect transitions to degraded polling mode with visible status indicator.
- Reconnect triggers one-time reconciliation fetch.
- Duplicate/out-of-order events resolved by message timestamp and server refresh.

## Phase 5: Files + Google Drive + YouTube

### API endpoints to integrate

- Files:
  - POST /api/files/upload
  - GET /api/files/search
  - GET /api/files/:fileId
  - GET /api/files/:fileId/download
- Course material uploads:
  - POST /api/courses/:courseId/materials/upload-video
  - POST /api/courses/:courseId/materials/upload-document
  - GET /api/courses/:courseId/materials
- Google Drive:
  - GET /google-drive/auth
  - POST /google-drive/files/upload
- YouTube:
  - GET /youtube/auth
  - POST /youtube/upload

### Frontend components/pages needed

- File browser and upload modal
- Course material manager (instructor) and material viewer (student)
- Provider auth/connect status widget
- Upload progress panel with retry controls

### State management approach

- Upload manager store tracks progress lifecycle per upload id.
- Provider metadata mapped to normalized UploadedMaterialRecord model.
- Material lists use paginated canonical list contract.

### Error handling patterns

- Validation errors for file size/type rendered before mutation retry.
- Provider failures categorized separately from local network failures.
- Partial success handling: uploaded file without material metadata triggers recovery action.

## Phase 6: Analytics + Reports + Search

### API endpoints to integrate

- Analytics:
  - GET /api/analytics/dashboard
  - GET /api/analytics/performance
  - GET /api/analytics/engagement
  - GET /api/analytics/attendance-trends
- Reports:
  - GET /api/reports/templates
  - POST /api/reports/generate
  - GET /api/reports/history
  - GET /api/reports/:id/download
- Search:
  - GET /api/search
  - GET /api/search/courses
  - GET /api/search/users
  - GET /api/search/materials
  - GET /api/search/history

### Frontend components/pages needed

- Analytics dashboard widgets
- Report generation wizard and report history page
- Global search surface with typed tabs (courses/users/materials)

### State management approach

- Chart/query state separated from filter-form state.
- Report generation handled as async job workflow with polling/requery.
- Search history and recent queries cached per user session.

### Error handling patterns

- Long-running report operations show pending/failed/completed states.
- Empty analytics/search responses use semantic empty-state components.
- Authorization boundaries prevent exposing admin-only analytics to non-admin roles.

## Phase 7: Community + Discussions + Tasks + Labs

### API endpoints to integrate

- Community:
  - GET /api/community/communities
  - GET /api/community/posts
  - GET /api/community/posts/:id
  - POST /api/community/posts
  - POST /api/community/posts/:id/comment
- Discussions:
  - GET /api/discussions
  - GET /api/discussions/:id
  - POST /api/discussions
  - POST /api/discussions/:id/reply
- Tasks:
  - GET /api/tasks
  - POST /api/tasks
  - PATCH /api/tasks/:id
  - GET /api/tasks/upcoming
  - GET /api/tasks/reminders
- Labs:
  - GET /api/labs
  - GET /api/labs/:id
  - POST /api/labs/:id/submit
  - GET /api/labs/:id/submissions/my

### Frontend components/pages needed

- Community feed and post detail page
- Discussion thread page with replies
- Personal task board and reminders panel
- Labs list/detail/submission pages

### State management approach

- Feed/thread views use paginated canonical lists with optimistic comment/reply mutations.
- Task board uses filterable list cache plus reminder subresource cache.
- Lab submission state shares upload manager primitives from Phase 5.

### Error handling patterns

- Moderation/permission failures shown as role-aware action denials.
- Optimistic create/update rollback on conflict/server errors.
- Form drafts for posts/replies/submissions preserved on transient failure.

## Phase Exit Criteria

Each phase is considered complete only when:

- Endpoint integrations for that phase pass contract checks.
- Frontend pages/components for that phase are wired to real APIs.
- Phase state management pattern is implemented and documented.
- Error handling categories are mapped and verified on at least one positive and one negative flow.
