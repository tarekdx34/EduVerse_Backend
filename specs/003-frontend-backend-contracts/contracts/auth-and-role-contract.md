# Contract: Auth and Role Access

## 1. Session Contract

### 1.1 Login

- Endpoint: POST /api/auth/login
- Request: email, password, rememberMe(optional)
- Response:
  - user object including single role
  - accessToken
  - refreshToken (temporary migration support in body)
- Frontend behavior:
  - store accessToken in memory only
  - treat refresh as cookie-first after login

### 1.2 Refresh

- Endpoint: POST /api/auth/refresh-token
- Standard mode: cookie-first credentialed request
- Migration mode: request-body refreshToken accepted temporarily
- Frontend behavior:
  - attempt cookie-first silent refresh
  - fallback to body token only during migration window
  - if both fail: transition session to expired and redirect to login

### 1.3 Logout

- Endpoint: POST /api/auth/logout
- Frontend behavior:
  - clear in-memory session
  - invalidate local auth caches
  - redirect to unauthenticated entry point

## 2. Single-Role Claim Contract

- Role field is single-valued.
- Allowed integration personas: student, instructor, admin.
- Frontend guard policy:
  - unknown or missing role => deny protected routes and show safe error state.

## 3. Role Access Matrix (High-Level)

### student

- Allowed: enrolled courses/materials, own grades, own tasks, messaging, discussions.
- Denied: admin user management, institutional configuration, instructor grading authoring actions.

### instructor

- Allowed: content/material management, grading, attendance workflows, course-level moderation.
- Denied: global admin governance operations.

### admin

- Allowed: user/role management, institution-wide management, reporting/analytics governance.

## 4. Auth Error Handling Contract

- 401 authentication failures:
  - try silent refresh once when eligible
  - on failure, force sign-in flow
- 403 authorization failures:
  - keep session active
  - show insufficient permission UI
- Validation/Conflict errors:
  - preserve user form state and render actionable messages
