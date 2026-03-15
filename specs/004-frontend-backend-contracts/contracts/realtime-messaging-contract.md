# Contract: Realtime Messaging

## Transport Strategy

- Socket-first via messaging namespace.
- Automatic fallback to polling when socket disconnect persists.
- Automatic return to socket mode after reconnect + reconciliation fetch.

## Client Emitted Events

- `join_conversation`
- `leave_conversation`
- `send_message`
- `typing`
- `mark_read`
- `edit_message`
- `delete_message`

## Server Emitted Events

- `new_message`
- `new_message_notification`
- `user_typing`
- `message_read`
- `message_edited`
- `message_deleted`
- `user_status`

## Reconciliation Rule

- Server timestamp + message version is authoritative.
- Client applies only newest `(version, updatedAt)` tuple per message.
- Reconnect triggers one-time backfill to reconcile missed events.

## Failure Handling

- Socket failure -> degrade status + polling active for unread/active thread.
- Out-of-order events -> ignore stale tuple.
- Unauthorized socket state -> terminate socket and re-enter auth flow.

## Observability

- Emit `realtime_contract_failure` for event contract mismatches.
- Required event payload: `feature`, `module`, `error_category`, `correlation_id`.
