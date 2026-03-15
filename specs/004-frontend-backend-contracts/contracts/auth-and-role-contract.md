# Contract: Auth and Role Integration

## Session Model

- Access token is stored in frontend memory only.
- Refresh token is sent/managed through HttpOnly secure cookie.
- Silent refresh is attempted automatically for expired access tokens.

## Refresh Contract

- Primary flow: cookie-first refresh endpoint call.
- Temporary migration flow: request-body refresh token allowed.
- Removal gate: body-based refresh traffic <1% for 14 consecutive days and zero Sev1/Sev2 auth incidents in that window.

## Role Contract

- Exactly one role per account: student OR instructor OR admin.
- Role claim drives route visibility, menu visibility, and action permissions.

## Protected Route Behavior

- Unauthenticated user: block protected route and redirect to sign-in/session-expired path.
- Unauthorized role: show no-access/disabled-action UX with explanatory messaging.

## Error Mapping

- 401 -> authentication category; attempt refresh once, then redirect.
- 403 -> authorization category; keep session but deny action.
- Validation payload errors -> inline form feedback + summary.

## Observability

- Emit `auth_contract_failure` on auth contract mismatches.
- Required event payload: `feature`, `module`, `error_category`, `correlation_id`.
