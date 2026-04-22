# Tasks: Frontend-Backend Integration Contracts

**Input**: Design documents from `specs/004-frontend-backend-contracts/`
**Prerequisites**: plan.md ✅, spec.md ✅, research.md ✅, data-model.md ✅, contracts/ ✅
**Tests**: Not requested — no test tasks included.
**Organization**: Tasks grouped by user story to enable independent implementation and testing.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no blocking dependencies within phase)
- **[Story]**: User story label (US1–US5)
- Paths use cross-repo convention: `src/` = `../Frontend/eduverse/src/`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Scaffold the frontend contract integration baseline — API client, dependency, and lib directory.

- [ ] T001 Add `socket.io-client` dependency to frontend in `../Frontend/eduverse/package.json`
- [ ] T002 [P] Create shared Axios instance with base URL and JWT bearer header injection in `../Frontend/eduverse/src/services/api.js`
- [ ] T003 [P] Create stub files for contract utility modules (`errorEnvelope.js`, `pagination.js`, `contractTelemetry.js`, `roleAccessProfile.js`) in `../Frontend/eduverse/src/lib/`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Shared utilities that MUST be complete before any user story begins.
**⚠️ CRITICAL**: All user story phases depend on this phase being complete.

- [ ] T004 Implement `ApiErrorEnvelope` parser mapping HTTP status codes to the 7 error categories (authentication, authorization, validation, conflict, not-found, server-error, transient-network) with `retryable` flag in `../Frontend/eduverse/src/lib/errorEnvelope.js`
- [ ] T005 [P] Implement `PaginationEnvelope` helpers (`parsePagination`, `buildPageQuery`) that consume `{ page, limit, total, totalPages, data }` and validate field constraints in `../Frontend/eduverse/src/lib/pagination.js`
- [ ] T006 [P] Implement `ContractFailureTelemetry` scaffolding with the 4 named event types (`auth_contract_failure`, `realtime_contract_failure`, `upload_contract_failure`, `pagination_contract_failure`) and required fields (`feature`, `module`, `error_category`, `correlation_id`) in `../Frontend/eduverse/src/lib/contractTelemetry.js`
- [ ] T007 Implement cookie-first refresh interceptor on the Axios instance (attach token from in-memory store, retry on 401 using HttpOnly refresh cookie) in `../Frontend/eduverse/src/services/api.js`
- [ ] T008 [P] Create `AuthContext` with session lifecycle state (`anonymous → authenticated → refreshed → expired → signed_out`) and `isAuthenticated`, `role`, `userId` fields in `../Frontend/eduverse/src/context/AuthContext.jsx`
- [ ] T009 [P] Create `ProtectedRoute` component skeleton that reads `isAuthenticated` from `AuthContext` and redirects unauthenticated users to `/login` in `../Frontend/eduverse/src/components/ProtectedRoute.jsx`

**Checkpoint**: Foundational infrastructure ready — user story implementation can now begin in parallel.

---

## Phase 3: User Story 1 — Secure Sign-In and Authorized Navigation (Priority: P1) 🎯 MVP

**Goal**: Deliver a complete auth/session lifecycle with single-role gating, silent refresh, and fallback-removal governance.

**Independent Test**: Sign in as student, instructor, and admin users; verify protected-route behavior, role-specific navigation, and silent refresh continuity.

### Implementation for User Story 1

- [ ] T010 [P] [US1] Implement `AuthenticatedSession` state model (sessionId, userId, role, accessToken in memory, accessTokenExpiresAt, refreshMode, isAuthenticated) in `../Frontend/eduverse/src/context/AuthContext.jsx`
- [ ] T011 [P] [US1] Implement `RoleAccessProfile` permission matrices for student, instructor, and admin roles (routePermissions, menuPermissions, actionPermissions, restrictedReasonMap) in `../Frontend/eduverse/src/lib/roleAccessProfile.js`
- [ ] T012 [US1] Implement `login()` consuming `POST /auth/login`, populating `AuthContext` with session state and storing access token in memory in `../Frontend/eduverse/src/services/authService.js`
- [ ] T013 [US1] Implement body-token fallback branch in the Axios refresh interceptor: if cookie refresh fails, attempt request-body token as temporary fallback per FR-002 in `../Frontend/eduverse/src/services/api.js`
- [ ] T014 [P] [US1] Implement `RefreshFallbackDeprecationCheckpoint` validator (readyForRemoval = ratio < 0.01 AND observationWindowDays >= 14 AND incidentCount === 0) in `../Frontend/eduverse/src/lib/deprecationCheckpoint.js`
- [ ] T015 [US1] Wire `ProtectedRoute` to use `RoleAccessProfile.routePermissions` for role-based route access control in `../Frontend/eduverse/src/components/ProtectedRoute.jsx`
- [ ] T016 [US1] Implement `logout()` clearing in-memory access token and calling `POST /auth/logout` to invalidate the refresh cookie in `../Frontend/eduverse/src/services/authService.js`
- [ ] T017 [US1] Implement session-expired handler: on unrecoverable 401, clear auth state and redirect to `/login` with an expired-session banner in `../Frontend/eduverse/src/context/AuthContext.jsx`
- [ ] T018 [US1] Implement role-claim validation guard: if role from JWT is missing or not in `{student, instructor, admin}`, force sign-out with a safe actionable error in `../Frontend/eduverse/src/context/AuthContext.jsx`

**Checkpoint**: US1 fully functional — authentication, silent refresh, role-based routing, and logout all independently testable.

---

## Phase 4: User Story 2 — Real-Time Messaging and Notification Reliability (Priority: P1)

**Goal**: Deliver a socket-first messaging layer with deterministic reconciliation, polling fallback, and automatic recovery.

**Independent Test**: Open two authenticated clients in one conversation, validate send/typing/read/edit/delete flows, simulate socket loss and verify polling fallback and recovery.

### Implementation for User Story 2

- [ ] T019 [P] [US2] Implement `MessagingConnectionState` model (transport: socket | polling, socketConnected, reconnectAttempts, lastSocketEventAt, pollingIntervalMs) in `../Frontend/eduverse/src/context/MessagingContext.jsx`
- [ ] T020 [P] [US2] Implement `MessageVersionedState` reconcile filter: apply incoming update only when `(incoming.version, incoming.updatedAt)` is newer than stored state in `../Frontend/eduverse/src/lib/messageReconciliation.js`
- [ ] T021 [US2] Implement Socket.IO client connection with JWT auth token and reconnection policy in `../Frontend/eduverse/src/services/socketService.js`
- [ ] T022 [US2] Implement client-side event handlers for `message_sent`, `message_edited`, `message_deleted`, `typing_start`, `typing_stop`, and `message_read` events in `../Frontend/eduverse/src/services/socketService.js`
- [ ] T023 [US2] Implement polling fallback service: activate when socket disconnects (poll `GET /messages/conversations` and active thread), deactivate on socket reconnect in `../Frontend/eduverse/src/services/messagingFallback.js`
- [ ] T024 [US2] Implement `MessagingContext` reducer that merges socket events and polling results through the `messageReconciliation` filter in `../Frontend/eduverse/src/context/MessagingContext.jsx`
- [ ] T025 [P] [US2] Wire conversation list page to `GET /messages/conversations` with `PaginationEnvelope` and unread-count freshness in `../Frontend/eduverse/src/pages/MessagingPage.jsx`
- [ ] T026 [US2] Implement message thread with real-time event subscription and a reconciliation fetch (`GET /messages/:id/history`) triggered on socket reconnect in `../Frontend/eduverse/src/pages/MessagingPage.jsx`

**Checkpoint**: US2 fully functional — socket messaging, typing indicators, fallback polling, and reconciliation all independently testable.

---

## Phase 5: User Story 3 — Instructor Content Upload and Learner Access (Priority: P1)

**Goal**: Deliver multipart upload flows for video and document course materials with provider metadata and learner-side visibility gating.

**Independent Test**: Upload one video and one document as instructor; validate provider metadata return; verify student visibility and unauthorized-role denial.

### Implementation for User Story 3

- [ ] T027 [P] [US3] Implement `UploadRequestContract` binary field mapper (uploadType → binaryFieldName: `video` for course-video, `document` for course-document, `file` for generic) in `../Frontend/eduverse/src/lib/uploadContract.js`
- [ ] T028 [P] [US3] Implement `UploadedMaterialRecord` normalizer validating `providerAssetId` required for youtube/google-drive providers and `isPublished` flag in `../Frontend/eduverse/src/lib/materialRecord.js`
- [ ] T029 [US3] Implement video upload service calling `POST /materials/upload` with `FormData` field `video`, multipart headers, and upload progress tracking in `../Frontend/eduverse/src/services/uploadService.js`
- [ ] T030 [US3] Implement document upload service calling `POST /materials/upload` with `FormData` field `document`, multipart headers, and upload progress tracking in `../Frontend/eduverse/src/services/uploadService.js`
- [ ] T031 [US3] Implement upload failure recovery UI: retry button on failure, partial-success notification when provider upload succeeds but metadata persistence fails in `../Frontend/eduverse/src/components/UploadModal.jsx`
- [ ] T032 [P] [US3] Implement provider metadata consumer deriving YouTube playback URL and Google Drive view/download URL from `UploadedMaterialRecord.providerAssetId` in `../Frontend/eduverse/src/lib/providerMetadata.js`
- [ ] T033 [US3] Implement instructor material manager page with upload workflow (modal trigger, progress bar, published/unpublished toggle) in `../Frontend/eduverse/src/pages/MaterialManagerPage.jsx`
- [ ] T034 [US3] Implement learner material viewer page filtering to published-only materials, rendering provider URLs for playback/download in `../Frontend/eduverse/src/pages/CourseDetailPage.jsx`

**Checkpoint**: US3 fully functional — instructor upload, provider metadata consumption, and learner-only published view all independently testable.

---

## Phase 6: User Story 4 — Consistent Paginated Data Across Modules (Priority: P2)

**Goal**: Enforce the canonical `{ page, limit, total, totalPages, data }` envelope and list-query behaviors (filter reset, empty state) across all seven phase module groups.

**Independent Test**: Validate pagination behavior in courses, notifications, tasks, search, analytics lists, reports history, and community/discussion/labs lists.

### Implementation for User Story 4

- [ ] T035 [P] [US4] Apply `PaginationEnvelope` helpers to courses and sections list queries with filter/sort parameter forwarding in `../Frontend/eduverse/src/services/courseService.js`
- [ ] T036 [P] [US4] Apply `PaginationEnvelope` helpers to enrollments and grades list queries in `../Frontend/eduverse/src/services/enrollmentService.js`
- [ ] T037 [P] [US4] Apply `PaginationEnvelope` helpers to assignments and quizzes list queries in `../Frontend/eduverse/src/services/assignmentService.js`
- [ ] T038 [P] [US4] Apply `PaginationEnvelope` helpers to notifications list queries in `../Frontend/eduverse/src/services/notificationService.js`
- [ ] T039 [P] [US4] Apply `PaginationEnvelope` helpers to typed search endpoint queries in `../Frontend/eduverse/src/services/searchService.js`
- [ ] T040 [P] [US4] Apply `PaginationEnvelope` helpers to analytics dashboard/performance, report history, and report template list queries in `../Frontend/eduverse/src/services/analyticsService.js`
- [ ] T041 [P] [US4] Apply `PaginationEnvelope` helpers to community posts, discussion replies, tasks/reminders, and lab submission list queries in `../Frontend/eduverse/src/services/communityService.js`
- [ ] T042 [US4] Implement shared `PaginationControls` component (previous/next, page selector, limit selector, total indicator) in `../Frontend/eduverse/src/components/PaginationControls.jsx`
- [ ] T043 [US4] Implement `usePagination` hook that resets `page` to 1 whenever filter or sort criteria change in `../Frontend/eduverse/src/hooks/usePagination.js`
- [ ] T044 [P] [US4] Implement stable `EmptyState` component displayed when `PaginationEnvelope.data` is empty, preserving filter controls in `../Frontend/eduverse/src/components/EmptyState.jsx`

**Checkpoint**: US4 fully functional — canonical pagination enforced across all 7 phase module groups, independently testable per module.

---

## Phase 7: User Story 5 — Role-Specific Frontend Surfaces (Priority: P2)

**Goal**: Enforce single-role surface matrices across route, menu, and action levels for all seven phase groups; handle partial-availability via exception governance.

**Independent Test**: Switch between student, instructor, and admin accounts and verify route-level, menu-level, and action-level permissions across all seven integration phases.

### Implementation for User Story 5

- [ ] T045 [P] [US5] Define student role surface matrix (routePermissions, menuPermissions, actionPermissions) covering all 7 phase groups in `../Frontend/eduverse/src/lib/roleAccessProfile.js`
- [ ] T046 [P] [US5] Define instructor role surface matrix (teaching, grading, attendance, materials, instructor-scoped analytics) covering all 7 phase groups in `../Frontend/eduverse/src/lib/roleAccessProfile.js`
- [ ] T047 [P] [US5] Define admin role surface matrix (governance, institutional management, analytics, community oversight) covering all 7 phase groups in `../Frontend/eduverse/src/lib/roleAccessProfile.js`
- [ ] T048 [US5] Implement `NavigationMenu` component rendering only menu items present in `RoleAccessProfile.menuPermissions` for the current session role in `../Frontend/eduverse/src/components/NavigationMenu.jsx`
- [ ] T049 [P] [US5] Implement `ActionGuard` component that disables or hides buttons/actions not present in `RoleAccessProfile.actionPermissions` in `../Frontend/eduverse/src/components/ActionGuard.jsx`
- [ ] T050 [P] [US5] Implement `UnavailableSurface` component that renders a disabled placeholder with `ContractExceptionRecord.owner` and `targetClosureDate` in tooltip for contract-exception-governed paths in `../Frontend/eduverse/src/components/UnavailableSurface.jsx`
- [ ] T051 [US5] Wire Phase 1 (auth/campus) page routes to role surfaces: student and instructor protected shell, admin management routes in `../Frontend/eduverse/src/App.jsx`
- [ ] T052 [US5] Wire Phase 2 (courses/enrollments/grades) page surfaces to role surfaces: student catalog, instructor gradebook, admin course administration in `../Frontend/eduverse/src/pages/`
- [ ] T053 [US5] Wire Phase 3 (assignments/quizzes/attendance) page surfaces to role surfaces: student submission, instructor grading/attendance board, admin oversight in `../Frontend/eduverse/src/pages/`
- [ ] T054 [US5] Wire Phase 4 (messaging/notifications/announcements) page surfaces to role surfaces: per-role announcement publish permission, per-role notification filtering in `../Frontend/eduverse/src/pages/`
- [ ] T055 [US5] Wire Phase 5 (files/providers) page surfaces to role surfaces: instructor upload-enabled material manager, student published-viewer-only in `../Frontend/eduverse/src/pages/`
- [ ] T056 [US5] Wire Phase 6 (analytics/reports/search) page surfaces to role surfaces: admin analytics dashboards, instructor report generation, student accessible report views in `../Frontend/eduverse/src/pages/`
- [ ] T057 [US5] Wire Phase 7 (community/discussions/tasks/labs) page surfaces to role surfaces: student task boards, instructor discussion moderation, admin community oversight in `../Frontend/eduverse/src/pages/`

**Checkpoint**: US5 fully functional — all 7 phase groups have role-gated routes, menus, and actions independently testable by role.

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Observability wiring, deprecation governance, exception runbook, and final validation.

- [ ] T058 [P] Implement `auth_contract_failure` telemetry emitter with required fields (`feature`, `module`, `error_category`, `correlation_id`) in `../Frontend/eduverse/src/lib/contractTelemetry.js`
- [ ] T059 [P] Implement `realtime_contract_failure` telemetry emitter with required fields in `../Frontend/eduverse/src/lib/contractTelemetry.js`
- [ ] T060 [P] Implement `upload_contract_failure` telemetry emitter with required fields in `../Frontend/eduverse/src/lib/contractTelemetry.js`
- [ ] T061 [P] Implement `pagination_contract_failure` telemetry emitter with required fields in `../Frontend/eduverse/src/lib/contractTelemetry.js`
- [ ] T062 Wire all four telemetry emitters to their corresponding error handlers: auth emitter in `authService.js`, realtime emitter in `socketService.js`, upload emitter in `uploadService.js`, pagination emitter in the `usePagination` hook in `../Frontend/eduverse/src/`
- [ ] T063 [P] Create `RefreshFallbackDeprecationCheckpoint` monitoring runbook documenting metric source, 14-day window measurement, zero-incident gate, and removal procedure in `specs/004-frontend-backend-contracts/docs/deprecation-monitoring.md`
- [ ] T064 [P] Create `ContractExceptionRecord` governance runbook documenting record creation, required fields (owner, mitigation, targetClosureDate), UX disable procedure, and closure criteria in `specs/004-frontend-backend-contracts/docs/exception-governance.md`
- [ ] T065 Run the quickstart.md 6-step validation flow (auth+role, refresh deprecation gate, messaging realtime+degradation, upload+providers, pagination+errors, observability+release metrics) and record pass/fail results

---

## Dependencies & Execution Order

### Phase Dependencies

```
Phase 1 (Setup)         → No dependencies; start immediately
Phase 2 (Foundational)  → Depends on Phase 1 completion; BLOCKS all user stories
Phase 3 (US1)           → Depends on Phase 2 ✓
Phase 4 (US2)           → Depends on Phase 2 ✓
Phase 5 (US3)           → Depends on Phase 2 ✓
Phase 6 (US4)           → Depends on Phase 2 ✓
Phase 7 (US5)           → Depends on Phase 2 ✓; reads from Phase 3 roleAccessProfile
Phase 8 (Polish)        → Depends on all US phases completing
```

### User Story Dependencies

| Story | Phase | Priority | Depends On          | Notes                                            |
| ----- | ----- | -------- | ------------------- | ------------------------------------------------ |
| US1   | 3     | P1       | Phase 2 only        | MVP — implement first                            |
| US2   | 4     | P1       | Phase 2 only        | Can start in parallel with US1                   |
| US3   | 5     | P1       | Phase 2 only        | Can start in parallel with US1, US2              |
| US4   | 6     | P2       | Phase 2 only        | Can start after Phase 2; all 7 service files [P] |
| US5   | 7     | P2       | Phase 2, US1 (T011) | US5 imports `roleAccessProfile` seeded in US1    |

### Within Each User Story

- Data models / utility functions → services → pages / context reducers
- T011 (`roleAccessProfile.js`) in US1 is a prerequisite for T045–T047 in US5

---

## Parallel Opportunities Per Story

### Phase 2 (Foundational)

```
T004 ─────────────────────────────────|
T005 ─────────────────────────────|   |─── T007 (refresh interceptor) ─── T008 ─── T009
T006 ─────────────────────────────|
```

### US1 (Phase 3)

```
T010 ──────────────────────────|
T011 ──────────────────────────|─── T012 ─── T013 ─── T015 ─── T016 ─── T017 ─── T018
T014 ─────────────────────────────────────────────────────────────────────────────────
```

### US2 (Phase 4)

```
T019 ──────────────────────|
T020 ─────────────────────|─── T021 ─── T022 ─── T023 ─── T024 ─── T025 ─── T026
```

### US3 (Phase 5)

```
T027 ─────────────────────────│
T028 ─────────────────────────│─── T029 ─── T031 ─── T033
T032 ─────────────────────────│─── T030 ─────────────────── T034
```

### US4 (Phase 6)

```
T035 │
T036 │
T037 │
T038 │─── (all parallel) ─── T042 ─── T043
T039 │                       T044 ─────────
T040 │
T041 │
```

### US5 (Phase 7)

```
T045 │
T046 │─── T048 ─── T051 ─── T052 ─── T053 ─── T054 ─── T055 ─── T056 ─── T057
T047 │
T049 ──── (parallel, different file)
T050 ──── (parallel, different file)
```

---

## Implementation Strategy

**MVP scope** (deliver first): **US1 only** (T001–T018)

- Unlocks all protected route testing
- Establishes auth infrastructure all other stories depend on
- Independently verifiable with three test accounts

**Increment 2**: US2 + US3 (T019–T034) — both are P1, different file sets, can be parallelized across developers

**Increment 3**: US4 (T035–T044) — self-contained pagination enforcement; all service tasks are [P]

**Increment 4**: US5 (T045–T057) — requires T011 from US1 done; phase-wiring tasks sequential within phase group

**Increment 5**: Polish (T058–T065) — telemetry, governance docs, final quickstart run
