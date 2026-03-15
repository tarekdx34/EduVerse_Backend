# Data Model: Frontend-Backend Integration Contracts

## 1. AuthenticatedSession

- Purpose: Frontend runtime authentication state.
- Fields:
  - sessionId: string
  - userId: number
  - role: enum(student, instructor, admin)
  - accessToken: string (memory-only)
  - accessTokenExpiresAt: datetime
  - refreshMode: enum(cookie-first-hybrid)
  - isAuthenticated: boolean
- Validation rules:
  - role is required and single-valued.
  - accessToken exists when isAuthenticated=true.
- State transitions:
  - anonymous -> authenticated
  - authenticated -> refreshed
  - authenticated -> expired
  - expired -> authenticated
  - authenticated -> signed_out

## 2. RoleAccessProfile

- Purpose: Single-role permission matrix.
- Fields:
  - role: enum(student, instructor, admin)
  - routePermissions: string[]
  - menuPermissions: string[]
  - actionPermissions: string[]
  - restrictedReasonMap: object
- Validation rules:
  - exactly one profile active per session.

## 3. RefreshFallbackDeprecationCheckpoint

- Purpose: Governance record for temporary body-token fallback removal.
- Fields:
  - checkpointId: string
  - bodyRefreshTrafficRatio: number
  - observationWindowDays: number
  - sev1Sev2AuthIncidentCount: number
  - readyForRemoval: boolean
  - verifiedAt: datetime
- Validation rules:
  - readyForRemoval=true only when ratio < 0.01, observationWindowDays >= 14, and incidentCount == 0.

## 4. MessagingConnectionState

- Purpose: Transport mode and health state.
- Fields:
  - transport: enum(socket, polling)
  - socketConnected: boolean
  - reconnectAttempts: number
  - lastSocketEventAt: datetime|null
  - pollingIntervalMs: number|null
- Validation rules:
  - pollingIntervalMs required when transport=polling.
- State transitions:
  - socket_connected -> socket_degraded
  - socket_degraded -> polling_active
  - polling_active -> socket_reconnected

## 5. MessageVersionedState

- Purpose: Conflict-safe message representation.
- Fields:
  - messageId: number
  - conversationId: number
  - version: number
  - updatedAt: datetime
  - createdAt: datetime
  - text: string|null
  - fileId: number|null
  - deletedForEveryone: boolean
- Validation rules:
  - apply incoming update only if (incoming.version, incoming.updatedAt) is newer.

## 6. UploadRequestContract

- Purpose: Multipart request for material uploads.
- Fields:
  - uploadType: enum(course-video, course-document, generic-file)
  - endpoint: string
  - binaryFieldName: enum(video, document, file)
  - metadata: object
- Validation rules:
  - binaryFieldName must match uploadType mapping.

## 7. UploadedMaterialRecord

- Purpose: Normalized uploaded content metadata.
- Fields:
  - materialId: number
  - courseId: number
  - materialType: enum(video, document)
  - provider: enum(youtube, google-drive, internal)
  - providerAssetId: string|null
  - externalUrl: string|null
  - isPublished: boolean
  - createdAt: datetime
- Validation rules:
  - providerAssetId required for youtube/google-drive providers.

## 8. PaginationEnvelope<T>

- Purpose: Canonical paginated response envelope.
- Fields:
  - page: number
  - limit: number
  - total: number
  - totalPages: number
  - data: T[]
- Validation rules:
  - page >= 1
  - limit > 0
  - data.length <= limit

## 9. ApiErrorEnvelope

- Purpose: Normalized frontend error model.
- Fields:
  - category: enum(authentication, authorization, validation, conflict, not-found, server-error, transient-network)
  - statusCode: number|null
  - message: string
  - details: object|null
  - retryable: boolean
- Validation rules:
  - retryable=true for transient-network and selected server-error conditions.

## 10. ContractExceptionRecord

- Purpose: Controlled rollout exception for missing phase endpoints.
- Fields:
  - exceptionId: string
  - phaseName: string
  - missingEndpoints: string[]
  - owner: string
  - mitigationPlan: string
  - targetClosureDate: date
  - impactedUxPaths: string[]
  - status: enum(open, mitigated, closed)
- Validation rules:
  - missingEndpoints non-empty.
  - impactedUxPaths must be disabled/marked unavailable while status != closed.

## 11. ContractFailureTelemetryEvent

- Purpose: Standardized observability payload.
- Fields:
  - eventName: enum(auth_contract_failure, realtime_contract_failure, upload_contract_failure, pagination_contract_failure)
  - feature: string
  - module: string
  - errorCategory: string
  - correlationId: string
  - occurredAt: datetime
- Validation rules:
  - all five fields required for event acceptance.
