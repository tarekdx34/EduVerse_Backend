# Phase 0 Research: Frontend-Backend Integration Contracts

## Decision 1: Session token storage and refresh strategy

- Decision: Use in-memory access token with HttpOnly secure cookie refresh token; refresh flow is cookie-first with temporary body fallback.
- Rationale: Minimizes token exposure while preserving migration compatibility.
- Alternatives considered:
  - localStorage/sessionStorage for access token (rejected: higher exposure risk)
  - immediate cookie-only cutoff (rejected: migration break risk)

## Decision 2: Temporary refresh fallback removal gate

- Decision: Remove body-token refresh fallback only when body-based refresh traffic is below 1% for 14 consecutive days and there are zero Sev1/Sev2 auth incidents during that window.
- Rationale: Uses measurable safety criteria for deprecation without indefinite overlap.
- Alternatives considered:
  - immediate removal next release (rejected: elevated outage risk)
  - fixed-time removal regardless of telemetry (rejected: not data-driven)

## Decision 3: Role model for UX authorization

- Decision: Enforce exactly one role per account: student OR instructor OR admin.
- Rationale: Deterministic route/menu/action gating simplifies policy and testing.
- Alternatives considered:
  - multi-role union model (rejected: out of clarified scope)
  - dominant-role precedence (rejected: ambiguous behavior)

## Decision 4: Realtime reconciliation policy

- Decision: Server timestamp + message version is authoritative; client applies newest (version, updatedAt) tuple per message.
- Rationale: Handles out-of-order and reconnect event streams predictably.
- Alternatives considered:
  - receive-order wins (rejected: non-deterministic under network jitter)
  - full refetch on every event (rejected: excessive load and latency)

## Decision 5: Websocket degradation behavior

- Decision: Socket-first with automatic polling fallback for active thread and unread counts; automatically return to socket mode on reconnect with one-time reconciliation fetch.
- Rationale: Maintains continuity when transport quality degrades.
- Alternatives considered:
  - no fallback/manual refresh only (rejected: poor UX)
  - polling-first always (rejected: unnecessary overhead)

## Decision 6: Upload contract shape

- Decision: Preserve backend multipart field names and separate upload flows:
  - video field: `video`
  - document field: `document`
  - generic file field: `file`
- Rationale: Aligns to existing backend interceptors and avoids breaking changes.
- Alternatives considered:
  - one unified upload endpoint/field (rejected: broad backend refactor)

## Decision 7: Pagination and list-query standardization

- Decision: Canonical envelope `{ page, limit, total, totalPages, data }` plus shared filter/sort/search behavior with page reset to 1 on criteria change.
- Rationale: Enables reusable list adapters across many modules.
- Alternatives considered:
  - endpoint-specific list handling (rejected: drift and higher defect rate)

## Decision 8: Error normalization taxonomy

- Decision: Normalize failures into authentication, authorization, validation, conflict, not-found, server-error, and transient-network categories.
- Rationale: Ensures consistent user handling and retry policy across domains.
- Alternatives considered:
  - generic single error state (rejected: poor actionability)

## Decision 9: Observability checkpoint schema

- Decision: Require domain events `auth_contract_failure`, `realtime_contract_failure`, `upload_contract_failure`, `pagination_contract_failure` with fields `feature`, `module`, `error_category`, `correlation_id` and >=99% capture in validation.
- Rationale: Provides actionable diagnostics and measurable readiness criteria.
- Alternatives considered:
  - one generic event (rejected: weak triage value)
  - open schema per team (rejected: inconsistent telemetry)

## Decision 10: Rollout policy for partial endpoint availability

- Decision: Permit phase rollout only through approved contract exceptions containing missing endpoints, owner, mitigation, and target date; impacted UX paths must be explicitly disabled/marked unavailable.
- Rationale: Supports delivery continuity while preventing hidden contract drift.
- Alternatives considered:
  - hard block for any missing endpoint (rejected: overly rigid)
  - proceed with mocks without governance (rejected: uncontrolled risk)

## Decision 11: Success criteria measurement baseline

- Decision: For contract mismatch ticket reduction, use the immediately previous release cycle in the same ticketing system and label taxonomy.
- Rationale: Keeps metric comparability and auditability.
- Alternatives considered:
  - three-cycle rolling baseline (rejected: dilutes recent impact)
  - quarter-based baseline (rejected: misaligned to release cadence)
