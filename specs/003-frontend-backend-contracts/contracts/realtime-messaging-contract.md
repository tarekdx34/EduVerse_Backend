# Contract: Realtime Messaging

## 1. Transport

- Primary transport: WebSocket namespace /messaging
- Auth: token provided during handshake according to backend gateway expectations

## 2. Client Subscription/Interaction Events

- join_conversation { conversationId }
- leave_conversation { conversationId }
- send_message { conversationId, text?, fileId?, replyToId? }
- typing { conversationId, isTyping }
- mark_read { conversationId }
- edit_message { messageId, text }
- delete_message { messageId, forEveryone? }

## 3. Server Event Contract

- new_message
- new_message_notification
- user_typing
- message_read
- message_edited
- message_deleted
- user_status

Each event must include identifiers required for idempotent frontend reconciliation:

- conversationId and/or messageId
- sender/actor user id
- event timestamp where applicable

## 4. Degradation and Recovery

- On socket disconnect:
  - transition to polling mode
  - poll active conversation history and unread counts at short interval
- On reconnect:
  - stop polling
  - rejoin active conversation rooms
  - perform one reconciliation fetch for conversation state

## 5. Conflict/Reconciliation Rules

- Out-of-order events are resolved by timestamp + server source-of-truth fetch.
- Deleted-for-everyone supersedes prior text updates.
- Edited message updates replace only mutable fields.
