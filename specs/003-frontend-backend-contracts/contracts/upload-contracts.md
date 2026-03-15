# Contract: Upload Workflows

## 1. Course Video Upload

- Endpoint: POST /api/courses/:courseId/materials/upload-video
- Multipart field: video
- Metadata fields: title(required), description(optional), tags(optional), weekNumber(optional), orderIndex(optional), isPublished(optional)
- Success result must include material metadata and provider identifiers/URLs for playback.

## 2. Course Document Upload

- Endpoint: POST /api/courses/:courseId/materials/upload-document
- Multipart field: document
- Metadata fields: title(required), description(optional), materialType(optional), weekNumber(optional), orderIndex(optional), isPublished(optional)
- Success result must include material metadata and provider identifiers/URLs for view/download.

## 3. Generic File Upload

- Endpoint: POST /api/files/upload
- Multipart field: file
- Metadata fields: folderId(optional), courseId(optional)

## 4. Provider Semantics

- YouTube-backed uploads:
  - provider = youtube
  - include externalUrl/embed URL and provider video id
- Google Drive-backed uploads:
  - provider = google-drive
  - include view/download URLs and provider file id

## 5. Upload UX Contract

- Frontend states: started -> progress -> completed | failed
- Failure categories:
  - validation (file type/size)
  - authorization
  - provider failure
  - network/transient
- Retry policy:
  - automatic retry allowed for transient network failures
  - no automatic retry for validation errors
