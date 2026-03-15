# Contract: Pagination and Error Normalization

## Canonical Pagination Envelope

All prioritized list modules consume this response shape:

- `page`
- `limit`
- `total`
- `totalPages`
- `data`

## List Query Behavior

- Shared query inputs: `page`, `limit`, `sort`, `search`, `filters`.
- Filter/sort/search changes reset page to 1.
- Empty responses must produce stable empty-state UX.

## Covered Phase Modules

- Courses, enrollments, grades
- Notifications, announcements, tasks
- Search, analytics lists, reports history
- Community, discussions, labs lists

## Error Category Contract

- authentication
- authorization
- validation
- conflict
- not-found
- server-error
- transient-network

## UX Expectations

- Authentication errors: refresh/re-auth flow.
- Authorization errors: denied action UX.
- Validation errors: inline and summary guidance.
- Conflict/not-found errors: actionable non-blocking guidance.
- Server/transient errors: retry affordances and user-safe fallback states.

## Observability

- Emit `pagination_contract_failure` for pagination contract mismatches.
- Required event payload: `feature`, `module`, `error_category`, `correlation_id`.
