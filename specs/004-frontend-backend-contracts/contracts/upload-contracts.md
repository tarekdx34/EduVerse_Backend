# Contract: Upload and External Provider Integration

## Supported Upload Flows

1. Course video upload
   - Endpoint: `POST /api/courses/:courseId/materials/upload-video`
   - Multipart binary field: `video`
2. Course document upload
   - Endpoint: `POST /api/courses/:courseId/materials/upload-document`
   - Multipart binary field: `document`
3. Generic file upload
   - Endpoint: `POST /api/files/upload`
   - Multipart binary field: `file`

## Provider Integration

- Google Drive auth/upload endpoints are used for document workflows.
- YouTube auth/upload endpoints are used for video workflows.
- Returned provider metadata maps to normalized uploaded material records.

## Frontend Behavior

- Show upload progress, completion, and retry states.
- On partial success (file present but metadata persist failure), surface recovery action.
- Restrict upload actions to instructor role.

## Error Mapping

- Validation errors: unsupported type/size/fields.
- Authorization errors: non-instructor upload attempts.
- Provider errors: remote API or authorization failure.
- Network errors: retryable transient conditions.

## Observability

- Emit `upload_contract_failure` for upload contract mismatches.
- Required event payload: `feature`, `module`, `error_category`, `correlation_id`.
