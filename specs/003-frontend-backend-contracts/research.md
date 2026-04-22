# Phase 0 Research: Frontend-Backend Integration Contracts

## Decision 1: Session token storage and refresh strategy

- Decision: Use in-memory access token with HttpOnly secure cookie refresh token; refresh flow is cookie-first with temporary body fallback during migration.
- Rationale: Reduces token exposure surface in frontend runtime while preserving compatibility with existing refresh endpoint behavior.
- Alternatives considered:
  - localStorage/sessionStorage for both tokens (rejected: higher exposure risk)
  - cookie-only immediate cutover (rejected: migration risk)
  - body-only refresh token (rejected: weaker security posture)

## Decision 2: Role model for frontend access decisions

- Decision: Enforce single-role-per-user contract (student OR instructor OR admin) for route guards and action visibility.
- Rationale: Matches clarified requirement and keeps UI policy deterministic.
- Alternatives considered:
  - multi-role union model (rejected: out of scope and not needed)
  - dominant-role precedence model (rejected: unnecessary complexity)

## Decision 3: Pagination response normalization

- Decision: Standardize canonical paginated response envelope: { page, limit, total, totalPages, data }.
- Rationale: Enables one reusable frontend list adapter and removes module-specific pagination branching.
- Alternatives considered:
  - cursor pagination for all modules (rejected: higher migration cost)
  - frontend-only normalization with no backend standard (rejected: contract ambiguity persists)
  - offset-based envelope (rejected: inconsistent with selected requirement)

## Decision 4: Real-time messaging degradation behavior

- Decision: Use socket-first messaging; on socket outage auto-fallback to short-interval polling for active conversation and unread counts; auto-return to socket on reconnect.
- Rationale: Preserves continuity and recency of message state during transient connectivity failures.
- Alternatives considered:
  - no fallback/manual refresh (rejected: poor user experience)
  - offline queue only for sends (rejected: does not address incoming recency)
  - fully disable messaging while disconnected (rejected: excessive disruption)

## Decision 5: Error contract normalization

- Decision: Normalize backend failures into shared frontend categories: authentication, authorization, validation, conflict, not-found, server-error, and transient-network.
- Rationale: Improves consistency of user messaging and retry/fallback policies across modules.
- Alternatives considered:
  - endpoint-specific ad hoc handling (rejected: fragmented UX and code duplication)
  - single generic error state (rejected: weak actionability)

## Decision 6: Upload contract shape for course materials

- Decision: Keep dedicated upload endpoints and binary field names per flow, with shared frontend upload abstraction:
  - video uploads use field video
  - document uploads use field document
  - generic file uploads use field file
- Rationale: Aligns with existing backend interceptor field names and avoids backend breaking changes.
- Alternatives considered:
  - one universal upload endpoint (rejected: broad backend refactor)
  - frontend field aliasing without explicit contract (rejected: hidden coupling risk)

## Decision 7: Upload pipeline observability expectations

- Decision: Require surfaced upload state milestones at frontend service level: started, progress, completed, failed (typed reason).
- Rationale: Needed for reliable UX in long-running uploads and external provider dependencies.
- Alternatives considered:
  - only final success/failure feedback (rejected: poor operator and user visibility)

## Decision 8: Contract-first scope boundary

- Decision: This planning cycle delivers documentation contracts and quickstart validation paths, not backend feature reimplementation.
- Rationale: The requested output is an SDD/integration contract package to guide coordinated implementation.
- Alternatives considered:
  - immediate code changes across frontend/backend (rejected: out of phase for /speckit.plan)

## Decision 9: Cross-repo integration structure

- Decision: Treat backend and frontend as distinct repositories with shared contract artifacts anchored in backend specs directory.
- Rationale: Matches workspace topology and keeps contract ownership centralized for API/event definitions.
- Alternatives considered:
  - duplicate contracts in both repos (rejected: drift risk)
  - frontend-owned contracts only (rejected: API source-of-truth misalignment)

## Decision 10: Gate evaluation under placeholder constitution

- Decision: Treat constitution gate as pass with explicit note: no enforceable principles currently defined due to template placeholders.
- Rationale: Avoids inventing constraints while maintaining transparent governance status.
- Alternatives considered:
  - block planning as gate failure (rejected: no actionable gate criteria present)

## Decision 11: Phase structure alignment with existing implementation index

- Decision: Mirror integration rollout in 7 combined phases mapped from existing implementation plan ordering:
  1. Auth + Campus
  2. Courses + Enrollments + Grades
  3. Assignments + Quizzes + Attendance
  4. Messaging + Notifications + Announcements
  5. Files + Google Drive + YouTube
  6. Analytics + Reports + Search
  7. Community + Discussions + Tasks + Labs
- Rationale: Preserves team familiarity and enables predictable cross-team coordination while keeping integration scope grouped by domain.
- Alternatives considered:
  - endpoint-by-endpoint rollout without phases (rejected: low coordination clarity)
  - strict module-per-phase rollout (rejected: too fragmented for frontend delivery)
