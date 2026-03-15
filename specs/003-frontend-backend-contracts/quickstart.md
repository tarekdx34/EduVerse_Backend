# Quickstart: Frontend-Backend Integration Contracts

## Purpose

Use this guide to validate the contract package between EduVerse frontend and backend before implementation tasks are generated.

## Prerequisites

- Backend repository available at eduverse-backend/
- Frontend repository available at ../Frontend/eduverse/
- Valid test users for exactly one role per account: student, instructor, admin
- Backend reachable with API and messaging gateway endpoints

## Step 1: Validate Auth Contract

1. Sign in with each role account.
2. Confirm access token is only held in runtime memory state.
3. Confirm refresh uses credentialed cookie-first flow.
4. Confirm temporary body-token refresh fallback works only during migration mode.
5. Confirm logout clears session state and protected views.

Expected result:

- Protected views are accessible only while session is valid.
- 401 and 403 handling follows normalized behavior.

## Step 2: Validate Role Access Contract

1. Open role-scoped navigation for each account type.
2. Verify only one active role is present in session context.
3. Verify denied actions are hidden or blocked safely.

Expected result:

- Student/instructor/admin experiences are distinct and deterministic.

## Step 3: Validate Messaging Realtime Contract

1. Open two browser sessions with authenticated users in one conversation.
2. Test send, edit, delete, typing, and mark-read flows.
3. Disable socket connectivity and verify polling fallback starts.
4. Restore connectivity and verify automatic return to socket mode.

Expected result:

- Message state remains consistent during degrade/recover transitions.

## Step 4: Validate Upload Contracts

1. Upload one course video using the video multipart field.
2. Upload one course document using the document multipart field.
3. Validate returned provider metadata (YouTube/Drive URLs and ids).
4. Validate progress + failure category behavior for oversized/invalid files.

Expected result:

- Upload flows produce consistent frontend state transitions and material records.

## Step 5: Validate Pagination and Error Contracts

1. Exercise paginated modules: courses, enrollments, grades, tasks, notifications, search, reports.
2. Verify canonical response handling with page/limit/total/totalPages/data.
3. Apply filters and verify automatic reset to page 1.
4. Validate empty-state and error-state rendering.

Expected result:

- One reusable list adapter handles all targeted paginated modules.

## Exit Criteria

- All five contract domains validated without unresolved blocking ambiguities.
- Any endpoint-specific deviations are recorded as contract exceptions for task phase.
