# Data Model: Frontend-Backend Integration Contracts

## 1. AuthenticatedSession

- Purpose: Represents authenticated frontend runtime state.
- Fields:
  - sessionId: string (client-generated correlation id)
  - userId: number
  - role: enum(student, instructor, admin)
  - accessToken: string (memory only)
  - accessTokenExpiresAt: datetime
  - refreshMode: enum(cookie-first-hybrid)
  - isAuthenticated: boolean
- Validation rules:
  - role is required and single-valued.
  - accessToken must be present when isAuthenticated=true.
- State transitions:
  - anonymous -> authenticated (login success)
  - authenticated -> refreshed (silent refresh success)
  - authenticated -> expired (refresh failed)
  - expired -> authenticated (re-login success)
  - authenticated -> signed_out (logout)

## 2. RoleAccessProfile

- Purpose: Defines UI and action capability map for a single role.
- Fields:
  - role: enum(student, instructor, admin)
  - routePermissions: string[]
  - actionPermissions: string[]
  - hiddenNavigationKeys: string[]
- Validation rules:
  - exactly one profile is active per session.
  - denied actions are omitted from actionPermissions.

## 3. PaginationEnvelope<T>

- Purpose: Canonical paginated response for list modules.
- Fields:
  - page: number (>=1)
  - limit: number (>0)
  - total: number (>=0)
  - totalPages: number (>=0)
  - data: T[]
- Validation rules:
  - totalPages = ceil(total / limit) unless total=0 then 0 or 1 based on backend policy.
  - data length <= limit.

## 4. MessagingConnectionState

- Purpose: Tracks socket health and fallback mode.
- Fields:
  - transport: enum(socket, polling)
  - socketConnected: boolean
  - lastSocketEventAt: datetime|null
  - pollingIntervalMs: number|null
  - reconnectAttempts: number
- Validation rules:
  - pollingIntervalMs required only when transport=polling.
- State transitions:
  - socket_connected -> socket_degraded (disconnect)
  - socket_degraded -> polling_active (fallback enabled)
  - polling_active -> socket_connected (reconnect and poll stop)

## 5. ConversationSummary

- Purpose: Lightweight list item for conversations.
- Fields:
  - conversationId: number
  - participantIds: number[]
  - lastMessagePreview: string
  - unreadCount: number
  - updatedAt: datetime
- Validation rules:
  - unreadCount >= 0.
  - participantIds non-empty.

## 6. MessageItem

- Purpose: Renderable message entity for history and real-time updates.
- Fields:
  - messageId: number
  - conversationId: number
  - senderUserId: number
  - text: string|null
  - fileId: number|null
  - createdAt: datetime
  - editedAt: datetime|null
  - deletedForEveryone: boolean
  - readReceiptUserIds: number[]
- Validation rules:
  - at least one of text or fileId must be present unless deletedForEveryone=true.

## 7. UploadRequest

- Purpose: Generic representation for multipart upload actions.
- Fields:
  - uploadType: enum(course-video, course-document, generic-file)
  - endpoint: string
  - binaryFieldName: enum(video, document, file)
  - metadata: object
- Validation rules:
  - binaryFieldName must match uploadType mapping.

## 8. UploadedMaterialRecord

- Purpose: Normalized material object after upload completion.
- Fields:
  - materialId: number
  - courseId: number
  - title: string
  - materialType: string
  - externalUrl: string|null
  - provider: enum(youtube, google-drive, internal)
  - providerAssetId: string|null
  - isPublished: boolean
  - createdAt: datetime
- Validation rules:
  - providerAssetId required for youtube and google-drive providers.

## 9. ApiErrorEnvelope

- Purpose: Shared frontend error normalization object.
- Fields:
  - category: enum(authentication, authorization, validation, conflict, not-found, server-error, transient-network)
  - statusCode: number|null
  - message: string
  - details: object|null
  - retryable: boolean
- Validation rules:
  - retryable=true for transient-network and selected server-error cases.
