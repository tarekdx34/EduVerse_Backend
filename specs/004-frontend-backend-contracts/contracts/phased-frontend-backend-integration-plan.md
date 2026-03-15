# Contract: Phased Frontend-Backend Integration Plan

This phased plan mirrors existing EduVerse delivery groupings while enforcing contract-first rollout rules.

## Cross-Phase Standards

- Single-role model: student OR instructor OR admin.
- Session: memory access token + HttpOnly refresh cookie.
- Refresh fallback removal gate: <1% body traffic for 14 days with zero Sev1/Sev2 auth incidents.
- Canonical pagination envelope: `{ page, limit, total, totalPages, data }`.
- Realtime reconciliation: newest `(version, updatedAt)` tuple wins.
- Endpoint gaps require approved contract exception records and explicit UX disable/unavailable states.

## Phase 1: Auth + Campus

- API groups: auth login/refresh/logout/me, users profile/preferences, campuses/departments/programs/semesters.
- Frontend surfaces: login/session-expired, protected shell, profile/preferences, campus selectors.
- State: auth store + bootstrap queries.
- Errors: auth/authz/validation with route-safe fallback.

## Phase 2: Courses + Enrollments + Grades

- API groups: courses, sections, schedules, enrollments, grades/transcript/GPA/distribution.
- Frontend surfaces: catalog, course detail, enrollment manager, grades/transcript widgets.
- State: paginated module caches and mutation invalidation.
- Errors: conflict and not-found scenarios are explicitly handled.

## Phase 3: Assignments + Quizzes + Attendance

- API groups: assignments, quizzes, attendance sessions/records.
- Frontend surfaces: assignment submission, quiz runner, attendance board/history.
- State: mutation-heavy workflows with safe optimistic updates.
- Errors: validation, timeout, and authorization downgrade handling.

## Phase 4: Messaging + Notifications + Announcements

- API groups: messaging HTTP + websocket events, notifications, announcements.
- Frontend surfaces: conversation list/thread, composer, notification center, announcement feed.
- State: socket-first reducer + polling fallback + reconciliation fetch.
- Errors: transport degradation indicators and duplicate/out-of-order suppression.

## Phase 5: Files + Google Drive + YouTube

- API groups: files search/download/upload, materials upload/list, provider auth/upload.
- Frontend surfaces: material manager, upload modal/progress, provider connect status, learner material viewer.
- State: upload lifecycle store and material list cache.
- Errors: file validation, provider failures, partial-success recovery.

## Phase 6: Analytics + Reports + Search

- API groups: analytics dashboard/performance/engagement, reports templates/generate/history/download, typed search endpoints.
- Frontend surfaces: analytics dashboard, report wizard/history, global search tabs.
- State: async report jobs + query-driven analytics/search caches.
- Errors: pending/failed report states and role-boundary restrictions.

## Phase 7: Community + Discussions + Tasks + Labs

- API groups: community posts/comments, discussions/replies, tasks/reminders, labs submissions.
- Frontend surfaces: feed/thread pages, task board, labs detail/submission.
- State: paginated feeds + optimistic mutation rollback.
- Errors: moderation/permission denials and transient draft-preservation behavior.

## Phase Exit Criteria

A phase is complete when:

1. Its endpoint group contracts are validated.
2. Its mapped frontend surfaces are wired to real APIs (or exception-governed unavailable states).
3. Error category mapping is tested on positive and negative paths.
4. Required contract-failure telemetry events meet schema and capture thresholds.
