# Quickstart: Frontend-Backend Integration Contracts

## Purpose

Validate contract behavior for authentication, roles, realtime messaging, uploads, pagination, error handling, and observability before implementation task execution.

## Prerequisites

- Backend repo available at eduverse-backend/.
- Frontend repo available at ../Frontend/eduverse/.
- Test accounts: student, instructor, admin (single-role accounts).
- Access to ticketing/telemetry dashboards for SC metrics.

## Step 1: Auth and Role Contract Validation

1. Sign in with each role account.
2. Verify access token exists only in runtime memory.
3. Verify refresh flow is cookie-first and fallback can be toggled for migration.
4. Verify protected route blocking and role-scoped navigation/actions.

Expected:

- 95%+ protected requests continue via silent refresh under normal conditions.
- Unauthorized routes/actions are blocked with consistent UX.

## Step 2: Refresh Fallback Deprecation Gate

1. Collect body-based refresh traffic ratio for 14 consecutive days.
2. Confirm no Sev1/Sev2 auth incidents in same period.
3. Mark checkpoint ready and remove fallback only when both criteria pass.

Expected:

- Removal gate evidence documented prior to fallback removal.

## Step 3: Messaging Realtime + Degradation

1. Open two authenticated clients in one conversation.
2. Validate send, typing, read, edit, and delete events.
3. Simulate websocket outage and confirm polling fallback.
4. Restore socket and verify one-time reconciliation + socket-first return.
5. Inject out-of-order events and verify latest (version, updatedAt) wins.

Expected:

- > =98% message propagation within 2 seconds under normal network.
- No stale updates survive reconciliation.

## Step 4: Upload and Provider Contracts

1. Upload one course video and one course document as instructor.
2. Verify multipart field names (`video`, `document`) and metadata mapping.
3. Verify student-only visibility of published materials.
4. Validate partial-success recovery behavior for provider metadata failures.

Expected:

- > =95% first-attempt success for valid files.
- Role-unsafe upload attempts are blocked safely.

## Step 5: Pagination and Error Normalization

1. Test canonical pagination across courses, notifications, tasks, search, analytics, reports, community, discussions, labs.
2. Change filters/sort and verify page reset to 1.
3. Validate empty states and category-based error UX mapping.

Expected:

- 100% canonical pagination contract pass rate in targeted modules.

## Step 6: Observability and Release Metrics

1. Trigger controlled failures in auth/realtime/upload/pagination flows.
2. Verify telemetry events are emitted with required schema fields.
3. Confirm >=99% capture during validation.
4. Measure SC-007 against immediate previous release-cycle baseline using the same ticketing labels.

Expected:

- Required contract failure events present with schema completeness.
- Ticket reduction metric computed against defined baseline.

## Exit Criteria

- FR-001 through FR-019 validated or exception-recorded.
- All open phase endpoint gaps have approved contract exception records.
- Phase readiness sign-off documented for planning-to-task transition.
