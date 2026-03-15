# Feature Specification: Frontend-Backend Integration Contracts

**Feature Branch**: `004-frontend-backend-contracts`  
**Created**: 2026-03-15  
**Status**: Draft  
**Input**: User description: "Create a full SDD for integrating the EduVerse frontend with the NestJS backend, defining contracts for JWT auth and roles, WebSocket messaging gateway, file uploads for course materials with Google Drive and YouTube, role-based student/instructor/admin views, and pagination patterns across modules."

## Clarifications

### Session 2026-03-15

- Q: What deprecation checkpoint should govern removal of temporary body-token refresh fallback? -> A: Remove fallback only after body-based refresh traffic is below 1% for 14 consecutive days with no Sev1/Sev2 auth incidents during that period.
- Q: What baseline source should be used for SC-007 contract-mismatch ticket reduction measurement? -> A: Use the immediately previous release cycle in the same ticketing system with the same `frontend-backend contract mismatch` label taxonomy.
- Q: What observability checkpoint schema should be required for FR-017? -> A: Require domain-specific events `auth_contract_failure`, `realtime_contract_failure`, `upload_contract_failure`, and `pagination_contract_failure`, each with >=99% capture in validation and fields `feature`, `module`, `error_category`, and `correlation_id`.
- Q: How should rollout proceed when a phase endpoint group is partially unavailable? -> A: Use controlled exceptions only: phase can proceed only with an approved contract exception record (missing endpoints, owner, mitigation, target date) and all impacted UX paths explicitly disabled or marked unavailable.
- Q: What message reconciliation rule should resolve realtime event conflicts and out-of-order updates? -> A: Server timestamp + message version wins; client applies only the newest `(version, updatedAt)` tuple per message.

## User Scenarios & Testing _(mandatory)_

### User Story 1 - Secure Sign-In and Authorized Navigation (Priority: P1)

As a signed-in platform user, I can authenticate once and access only role-allowed routes and actions so that I can work safely without unauthorized controls.

**Why this priority**: Authentication and authorization gates are prerequisites for every protected workflow.

**Independent Test**: Sign in as student, instructor, and admin users, then verify protected-route behavior, role-specific navigation, and silent refresh continuity.

**Acceptance Scenarios**:

1. **Given** valid user credentials, **When** the user signs in, **Then** protected views become accessible and session state is established.
2. **Given** an expired access token and valid refresh token, **When** a protected request is made, **Then** the request completes through silent refresh without manual re-login.
3. **Given** a student account, **When** the dashboard loads, **Then** only student-permitted pages and actions are visible.
4. **Given** an admin account, **When** management routes are opened, **Then** admin controls are available and non-admin controls remain hidden.

---

### User Story 2 - Real-Time Messaging and Notification Reliability (Priority: P1)

As an authenticated user, I can exchange messages with real-time feedback and continue receiving updates during transient socket failures.

**Why this priority**: Messaging is a core communication workflow and requires explicit event and fallback contracts.

**Independent Test**: Open two authenticated clients in one conversation, validate send/typing/read/edit/delete flows, then simulate socket loss and verify polling fallback and recovery.

**Acceptance Scenarios**:

1. **Given** two users in one conversation, **When** one user sends a message, **Then** both users receive consistent message state updates.
2. **Given** a user typing, **When** typing state is emitted, **Then** participants see typing indicators that clear correctly.
3. **Given** the websocket connection drops, **When** messaging remains active, **Then** polling fallback preserves active-thread and unread-count freshness.
4. **Given** websocket connectivity returns, **When** reconnection completes, **Then** the client resumes socket-first updates and reconciles missed events.

---

### User Story 3 - Instructor Content Upload and Learner Access (Priority: P1)

As an instructor, I can upload course videos and documents and publish them as course materials so that learners can reliably access structured content.

**Why this priority**: Course delivery depends on material upload contracts and external provider metadata handling.

**Independent Test**: Upload one video and one document as instructor, validate metadata creation, then verify student visibility and unauthorized-role denial behavior.

**Acceptance Scenarios**:

1. **Given** an authorized instructor, **When** a video upload is submitted, **Then** a material record is returned with provider metadata required for playback.
2. **Given** an authorized instructor, **When** a document upload is submitted, **Then** a material record is returned with provider metadata required for viewing/download.
3. **Given** a student account, **When** course materials are listed, **Then** only learner-visible published items are shown.
4. **Given** a non-instructor role, **When** upload is attempted, **Then** the request is blocked with a safe actionable authorization message.

---

### User Story 4 - Consistent Paginated Data Across Modules (Priority: P2)

As a user, I can navigate large lists with predictable pagination, filters, and sorting behavior across modules.

**Why this priority**: A shared pagination contract reduces integration defects and improves cross-module usability.

**Independent Test**: Validate pagination behavior in courses, notifications, tasks, search, analytics lists, reports history, and community/discussion/labs lists.

**Acceptance Scenarios**:

1. **Given** a paginated endpoint, **When** page/limit parameters change, **Then** data and pagination metadata remain accurate and consistent.
2. **Given** active filters or sorting, **When** criteria change, **Then** pagination resets to page 1 and results refresh correctly.
3. **Given** an empty result set, **When** the query succeeds, **Then** the frontend displays a stable empty state without broken controls.

---

### User Story 5 - Role-Specific Frontend Surfaces (Priority: P2)

As a platform user, I can interact with screens and actions tailored to my single assigned role (student, instructor, or admin).

**Why this priority**: Clear role surfaces enforce least privilege and reduce user confusion.

**Independent Test**: Switch between student, instructor, and admin accounts and verify route-level, menu-level, and action-level permissions.

**Acceptance Scenarios**:

1. **Given** a student role, **When** academic and communication modules are opened, **Then** student actions are enabled and management actions are restricted.
2. **Given** an instructor role, **When** instructional modules are opened, **Then** teaching actions (materials, grading, attendance) are enabled.
3. **Given** an admin role, **When** institutional management modules are opened, **Then** governance and administrative actions are enabled.

### Edge Cases

- Access token expires during in-flight requests while refresh token is also invalid.
- Role claims are missing or mismatch known role matrix values.
- Websocket events arrive out of order around disconnect/reconnect boundaries.
- Upload to an external provider succeeds but material metadata persistence fails.
- Pagination parameters exceed allowed limits or produce sparse/empty pages after filter changes.
- Report generation is delayed or fails after initial request acceptance.
- Community/discussion optimistic updates conflict with server-side moderation outcomes.

## Requirements _(mandatory)_

### Functional Requirements

- **FR-001**: The integration MUST define a frontend session contract that uses in-memory access tokens and HttpOnly secure cookie refresh tokens.
- **FR-002**: The integration MUST define refresh behavior as cookie-first, while allowing temporary request-body fallback during migration.
- **FR-003**: The integration MUST define and document a deprecation checkpoint for removal of the temporary body-token fallback such that removal occurs only after body-based refresh traffic remains below 1% for 14 consecutive days and no Sev1/Sev2 authentication incidents occur during that same window.
- **FR-004**: The integration MUST define protected-route behavior that blocks unauthenticated access to protected views.
- **FR-005**: The integration MUST define single-role claim consumption rules where each account has exactly one role among student, instructor, and admin.
- **FR-006**: The integration MUST define unauthorized and forbidden response handling patterns with consistent user-facing fallback behavior.
- **FR-007**: The integration MUST define authenticated websocket connection, reconnection, and event-handling contracts for messaging.
- **FR-008**: The integration MUST define deterministic message state reconciliation where server timestamp + message version is authoritative and the client applies only the newest `(version, updatedAt)` tuple per message across real-time events and historical message fetches.
- **FR-009**: The integration MUST define websocket degradation behavior that falls back to polling and automatically returns to socket-first behavior after reconnect.
- **FR-010**: The integration MUST define multipart upload contracts for course video and document workflows, including required binary field names and metadata.
- **FR-011**: The integration MUST define upload progress, retry, and failure-state behavior, including partial-success recovery actions.
- **FR-012**: The integration MUST define external provider metadata consumption rules for Google Drive and YouTube-backed materials.
- **FR-013**: The integration MUST define canonical pagination request/response handling using `{ page, limit, total, totalPages, data }` across prioritized modules.
- **FR-014**: The integration MUST define shared list-query behavior for sorting, searching, and filtering with consistent reset and empty-state handling.
- **FR-015**: The integration MUST define normalized API error categories (authentication, authorization, validation, conflict, not-found, server-error, transient-network) and expected UX responses.
- **FR-016**: The integration MUST define role-surface matrices for route visibility, menu visibility, and action permissions across student, instructor, and admin roles.
- **FR-017**: The integration MUST define observability checkpoints using domain-specific events `auth_contract_failure`, `realtime_contract_failure`, `upload_contract_failure`, and `pagination_contract_failure`; each event stream MUST achieve >=99% capture in validation and include `feature`, `module`, `error_category`, and `correlation_id` fields.
- **FR-018**: The integration MUST cover phased endpoint groups for auth/campus, courses/enrollments/grades, assignments/quizzes/attendance, messaging/notifications/announcements, files/providers, analytics/reports/search, and community/discussions/tasks/labs.
- **FR-019**: If any endpoint in a phase group is unavailable, rollout MAY proceed only with an approved contract exception record containing missing endpoints, owner, mitigation, and target date; impacted frontend UX paths MUST be explicitly disabled or marked unavailable until the exception is closed.

### Assumptions

- The backend remains the source of truth for authentication, authorization, and role membership.
- Each account has exactly one role in this feature scope.
- Refresh-token fallback support is temporary and will be retired only after body-based refresh traffic remains below 1% for 14 consecutive days and no Sev1/Sev2 authentication incidents occur in that period.
- Backend endpoint gaps are handled through approved contract exceptions; phases can proceed only when impacted UX paths are explicitly disabled or marked unavailable and exception records include owner, mitigation, and target closure date.
- External providers (Google Drive and YouTube) are preconfigured and authorized by platform administrators.

### Key Entities _(include if feature involves data)_

- **Authenticated Session**: Signed-in runtime context containing user identity, role, access-token lifecycle, and refresh status.
- **Role Access Profile**: Single-role capability matrix for route, menu, and action permissions.
- **Messaging Conversation State**: Conversation data model combining paged history with real-time event deltas.
- **Realtime Event Contract**: Standardized client/server event names and payload expectations for messaging lifecycle actions.
- **Upload Request Contract**: Multipart payload definition for video/document uploads with provider-bound metadata.
- **Uploaded Material Record**: Normalized material entity returned after upload and used for learner-facing rendering.
- **Paginated Query Contract**: Shared request and response semantics for list modules using canonical pagination metadata.
- **API Error Envelope**: Normalized error category and user-facing handling contract across integration domains.

## Success Criteria _(mandatory)_

### Measurable Outcomes

- **SC-001**: At least 95% of authenticated protected requests complete without manual re-login during normal token-refresh conditions.
- **SC-002**: In role-access UAT, 100% of tested student, instructor, and admin restricted actions are correctly allowed or blocked.
- **SC-003**: In two-client messaging tests, at least 98% of message updates are reflected on participants within 2 seconds under normal network conditions.
- **SC-004**: At least 95% of valid video/document upload attempts complete successfully on first submission.
- **SC-005**: Canonical pagination behavior passes 100% of contract test cases across all prioritized phase modules.
- **SC-006**: Contract observability events for auth, websocket, upload, and pagination are emitted for at least 99% of eligible failure scenarios during validation.
- **SC-007**: Support tickets tagged "frontend-backend contract mismatch" decrease by at least 40% relative to the immediately previous release cycle baseline, measured in the same ticketing system and using the same label taxonomy.
- **SC-008**: Temporary body-token refresh fallback is removed only after monitoring shows body-based refresh traffic below 1% for 14 consecutive days with zero Sev1/Sev2 auth incidents in the same period.
