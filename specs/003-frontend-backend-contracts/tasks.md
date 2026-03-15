# Tasks: Frontend-Backend Integration Contracts

**Input**: Design documents from `/specs/003-frontend-backend-contracts/`
**Prerequisites**: `plan.md`, `spec.md`, `research.md`, `data-model.md`, `contracts/`

**Tests**: Include phase-level validation tasks for each user story using the contract quickstart scenarios.
**Organization**: Tasks are grouped by user story so each story can be implemented and validated independently.

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Initialize shared frontend-backend integration scaffolding and contract config.

- [ ] T001 Create frontend API environment template in ../Frontend/eduverse/.env.example
- [ ] T002 Create centralized API endpoint registry for phased modules in ../Frontend/eduverse/src/services/config/endpoints.js
- [ ] T003 [P] Create shared HTTP client bootstrap with credentialed cookie support in ../Frontend/eduverse/src/services/lib/httpClient.js
- [ ] T004 [P] Create canonical pagination parser utility in ../Frontend/eduverse/src/lib/pagination/normalizePagination.js
- [ ] T005 [P] Create normalized API error mapper utility in ../Frontend/eduverse/src/lib/errors/mapApiError.js
- [ ] T006 Create integration contract constants for role/auth/pagination in ../Frontend/eduverse/src/lib/contracts/integrationContracts.js

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Build cross-cutting session, guard, and state foundations required by all user stories.

**⚠️ CRITICAL**: Complete this phase before user story implementation.

- [ ] T007 Create auth session store (memory token + refresh orchestration) in ../Frontend/eduverse/src/context/AuthContext.jsx
- [ ] T008 [P] Implement auth API service (login/me/refresh/logout) in ../Frontend/eduverse/src/services/authService.js
- [ ] T009 [P] Create role capability matrix for single-role model in ../Frontend/eduverse/src/lib/auth/roleCapabilities.js
- [ ] T010 Implement protected route and role gate wrappers in ../Frontend/eduverse/src/components/auth/ProtectedRoute.jsx
- [ ] T011 [P] Add global query client bootstrap and cache defaults in ../Frontend/eduverse/src/lib/query/queryClient.js
- [ ] T012 [P] Add global API error boundary and fallback renderer in ../Frontend/eduverse/src/components/errors/AppErrorBoundary.jsx
- [ ] T013 Wire auth provider, query client, and error boundary in ../Frontend/eduverse/src/main.jsx

**Checkpoint**: Foundation complete; user stories can start.

---

## Phase 3: User Story 1 - Secure Sign-In and Authorized Navigation (Priority: P1) 🎯 MVP

**Goal**: Deliver secure login, refresh lifecycle, and role-aware navigation/route protection.

**Independent Test**: Sign in with student/instructor/admin accounts, verify silent refresh, and verify role-specific route/menu behavior.

### Validation for User Story 1

- [ ] T014 [US1] Add contract validation checklist for auth and role routing in specs/003-frontend-backend-contracts/checklists/us1-auth-role-validation.md

### Implementation for User Story 1

- [ ] T015 [P] [US1] Implement login page and submit flow in ../Frontend/eduverse/src/pages/auth/LoginPage.jsx
- [ ] T016 [P] [US1] Implement session expired redirect page in ../Frontend/eduverse/src/pages/auth/SessionExpiredPage.jsx
- [ ] T017 [US1] Implement auth bootstrap hook (me/profile/preferences preload) in ../Frontend/eduverse/src/hooks/useAuthBootstrap.js
- [ ] T018 [P] [US1] Implement user profile service contract in ../Frontend/eduverse/src/services/userProfileService.js
- [ ] T019 [P] [US1] Implement profile page bound to users/profile endpoints in ../Frontend/eduverse/src/pages/profile/ProfilePage.jsx
- [ ] T020 [P] [US1] Implement preferences page bound to users/preferences endpoints in ../Frontend/eduverse/src/pages/profile/PreferencesPage.jsx
- [ ] T021 [US1] Build role-aware navigation shell in ../Frontend/eduverse/src/components/layout/RoleAwareLayout.jsx
- [ ] T022 [US1] Register protected auth/profile routes in ../Frontend/eduverse/src/App.jsx
- [ ] T023 [US1] Add unauthorized/forbidden UX handler components in ../Frontend/eduverse/src/components/errors/AuthzStateViews.jsx

**Checkpoint**: US1 is independently functional and testable.

---

## Phase 4: User Story 2 - Real-Time Messaging Experience (Priority: P1)

**Goal**: Deliver socket-first messaging with reconciliation and polling fallback.

**Independent Test**: Two authenticated clients can exchange messages, typing/read events sync, and polling fallback activates on socket loss.

### Validation for User Story 2

- [ ] T024 [US2] Add realtime contract validation checklist in specs/003-frontend-backend-contracts/checklists/us2-realtime-validation.md

### Implementation for User Story 2

- [ ] T025 [P] [US2] Implement messaging HTTP service (conversations/messages/unread) in ../Frontend/eduverse/src/services/messagingService.js
- [ ] T026 [P] [US2] Implement messaging socket client and event bindings in ../Frontend/eduverse/src/services/realtime/messagingSocketClient.js
- [ ] T027 [US2] Implement socket degradation and polling fallback manager in ../Frontend/eduverse/src/services/realtime/messagingFallbackManager.js
- [ ] T028 [US2] Implement conversation list panel connected to API cache in ../Frontend/eduverse/src/components/messaging/ConversationListPanel.jsx
- [ ] T029 [P] [US2] Implement conversation thread with event reconciliation in ../Frontend/eduverse/src/components/messaging/ConversationThread.jsx
- [ ] T030 [P] [US2] Implement composer with typing/read/edit/delete actions in ../Frontend/eduverse/src/components/messaging/MessageComposer.jsx
- [ ] T031 [US2] Implement notifications service and unread aggregation in ../Frontend/eduverse/src/services/notificationService.js
- [ ] T032 [P] [US2] Implement notification center panel in ../Frontend/eduverse/src/components/notifications/NotificationCenter.jsx
- [ ] T033 [P] [US2] Implement announcement feed/detail pages in ../Frontend/eduverse/src/pages/announcements/AnnouncementsPage.jsx
- [ ] T034 [US2] Wire messaging/notifications routes and providers in ../Frontend/eduverse/src/App.jsx

**Checkpoint**: US2 is independently functional and testable.

---

## Phase 5: User Story 3 - Upload and Attach Learning Content (Priority: P1)

**Goal**: Deliver instructor upload flows for video/document materials with provider metadata handling.

**Independent Test**: Instructor uploads video and document successfully, students can view published materials, and unauthorized users are blocked with actionable errors.

### Validation for User Story 3

- [ ] T035 [US3] Add upload/material contract validation checklist in specs/003-frontend-backend-contracts/checklists/us3-upload-validation.md

### Implementation for User Story 3

- [ ] T036 [P] [US3] Implement file/material upload API service contracts in ../Frontend/eduverse/src/services/materialUploadService.js
- [ ] T037 [P] [US3] Implement provider integration API wrappers (Drive/YouTube) in ../Frontend/eduverse/src/services/providerIntegrationService.js
- [ ] T038 [US3] Implement upload manager store for progress/retry lifecycle in ../Frontend/eduverse/src/context/UploadManagerContext.jsx
- [ ] T039 [P] [US3] Implement course material manager page for instructor uploads in ../Frontend/eduverse/src/pages/materials/CourseMaterialManagerPage.jsx
- [ ] T040 [P] [US3] Implement upload modal with multipart field mapping in ../Frontend/eduverse/src/components/materials/MaterialUploadModal.jsx
- [ ] T041 [P] [US3] Implement upload progress panel and retry controls in ../Frontend/eduverse/src/components/materials/UploadProgressPanel.jsx
- [ ] T042 [P] [US3] Implement student material viewer page in ../Frontend/eduverse/src/pages/materials/CourseMaterialsPage.jsx
- [ ] T043 [US3] Add role-based upload action guards to material surfaces in ../Frontend/eduverse/src/components/materials/MaterialActionGuards.jsx
- [ ] T044 [US3] Register materials routes and provider connect flows in ../Frontend/eduverse/src/App.jsx

**Checkpoint**: US3 is independently functional and testable.

---

## Phase 6: User Story 4 - Consistent Paginated Data Views (Priority: P2)

**Goal**: Standardize pagination/filter/sort behavior across module list views.

**Independent Test**: Multiple paginated modules use the same envelope parser and page-reset behavior on filter changes, including empty states.

### Validation for User Story 4

- [ ] T045 [US4] Add pagination contract validation checklist in specs/003-frontend-backend-contracts/checklists/us4-pagination-validation.md

### Implementation for User Story 4

- [ ] T046 [P] [US4] Implement shared list query hook for page/filter/sort/search in ../Frontend/eduverse/src/hooks/usePaginatedListQuery.js
- [ ] T047 [P] [US4] Implement canonical pagination UI component in ../Frontend/eduverse/src/components/lists/PaginationControls.jsx
- [ ] T048 [P] [US4] Implement reusable empty/error list state component in ../Frontend/eduverse/src/components/lists/ListStateView.jsx
- [ ] T049 [US4] Refactor course catalog list to canonical pagination contract in ../Frontend/eduverse/src/pages/courses/CourseCatalogPage.jsx
- [ ] T050 [P] [US4] Refactor notifications list to canonical pagination contract in ../Frontend/eduverse/src/components/notifications/NotificationCenter.jsx
- [ ] T051 [P] [US4] Refactor tasks list to canonical pagination contract in ../Frontend/eduverse/src/pages/tasks/TasksPage.jsx
- [ ] T052 [P] [US4] Refactor search results list to canonical pagination contract in ../Frontend/eduverse/src/pages/search/SearchPage.jsx
- [ ] T053 [US4] Add shared pagination query adapter tests and examples in ../Frontend/eduverse/src/lib/pagination/README.md

**Checkpoint**: US4 is independently functional and testable.

---

## Phase 7: User Story 5 - Role-Specific Application Surfaces (Priority: P2)

**Goal**: Complete role-targeted route/action visibility and permission-safe UX for student/instructor/admin.

**Independent Test**: Switching between role accounts changes accessible routes, menu items, and action availability with correct denial UX.

### Validation for User Story 5

- [ ] T054 [US5] Add role surface matrix validation checklist in specs/003-frontend-backend-contracts/checklists/us5-role-surface-validation.md

### Implementation for User Story 5

- [ ] T055 [P] [US5] Implement centralized route permission registry by role in ../Frontend/eduverse/src/lib/auth/routePermissions.js
- [ ] T056 [P] [US5] Implement menu visibility registry by role in ../Frontend/eduverse/src/lib/auth/menuPermissions.js
- [ ] T057 [US5] Apply route registry to app router guards in ../Frontend/eduverse/src/App.jsx
- [ ] T058 [P] [US5] Apply menu registry to sidebar/top-nav rendering in ../Frontend/eduverse/src/components/layout/SidebarNavigation.jsx
- [ ] T059 [P] [US5] Add role-gated action wrappers for feature controls in ../Frontend/eduverse/src/components/auth/RoleActionGate.jsx
- [ ] T060 [US5] Add no-access and request-permission UX surfaces in ../Frontend/eduverse/src/pages/errors/NoAccessPage.jsx
- [ ] T061 [US5] Validate role-specific surfaces for courses/grades/materials/admin areas in ../Frontend/eduverse/src/pages/role-access/RoleAccessAuditPage.jsx

**Checkpoint**: US5 is independently functional and testable.

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Finish cross-story hardening, observability, and rollout documentation.

- [ ] T062 [P] Add contract mismatch telemetry hooks (auth/socket/upload/pagination) in ../Frontend/eduverse/src/services/observability/contractTelemetry.js
- [ ] T063 [P] Add integration error dictionary for user-facing copy in ../Frontend/eduverse/src/lib/errors/errorMessages.js
- [ ] T064 Update frontend integration runbook with phase rollout steps in ../Frontend/eduverse/README.md
- [ ] T065 Update backend contract docs with implementation status markers in specs/003-frontend-backend-contracts/contracts/phased-frontend-backend-integration-plan.md
- [ ] T066 Run quickstart validation and record results in specs/003-frontend-backend-contracts/checklists/quickstart-validation-results.md

---

## Dependencies & Execution Order

### Phase Dependencies

- Setup (Phase 1) has no dependencies.
- Foundational (Phase 2) depends on Setup and blocks all user stories.
- User stories (Phases 3-7) depend on Foundational completion.
- Polish (Phase 8) depends on completion of selected user stories.

### User Story Dependencies

- US1 (P1): starts immediately after Phase 2.
- US2 (P1): starts after Phase 2; shares auth foundation but is independently testable.
- US3 (P1): starts after Phase 2; depends on role/auth foundation only.
- US4 (P2): starts after Phase 2; can run in parallel with US2/US3.
- US5 (P2): starts after Phase 2; should be finalized after US1/US3 route surfaces are in place.

### Suggested Story Completion Order

1. US1 (MVP auth and role-safe navigation)
2. US2 and US3 (parallel if staffing allows)
3. US4
4. US5

## Parallel Execution Examples

### User Story 1

- Run T015, T016, T018, T019, T020 in parallel (different files).
- Then complete T017, T021, T022, T023 sequentially.

### User Story 2

- Run T025, T026, T029, T030, T032, T033 in parallel.
- Then complete T027, T028, T031, T034.

### User Story 3

- Run T036, T037, T039, T040, T041, T042 in parallel.
- Then complete T038, T043, T044.

### User Story 4

- Run T046, T047, T048 in parallel.
- Then execute T049-T053 based on page ownership.

### User Story 5

- Run T055, T056, T058, T059 in parallel.
- Then execute T057, T060, T061.

## Implementation Strategy

### MVP First (US1)

1. Complete Phase 1 and Phase 2.
2. Complete US1 tasks (T014-T023).
3. Validate with student/instructor/admin login and route checks.
4. Demo/deploy MVP auth foundation.

### Incremental Delivery

1. Deliver US1.
2. Deliver US2 and US3.
3. Deliver US4.
4. Deliver US5.
5. Complete Polish and quickstart validation.

### Team Parallelization

1. Team completes Phase 1-2 together.
2. Assign US2 and US3 to separate developers while another handles US4.
3. Merge into US5 access hardening and final polish.
