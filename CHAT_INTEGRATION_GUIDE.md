# EduVerse Chat Integration Guide

> **Version**: 1.0  
> **Last Updated**: 2025-07-13  
> **Audience**: Frontend developers building the EduVerse chat UI  
> **Backend**: NestJS · Socket.IO · JWT Auth  
> **Base URL**: `http://localhost:8081`

---

## Table of Contents

- [1. Architecture Overview](#1-architecture-overview)
- [2. Authentication](#2-authentication)
  - [2.1 Login](#21-login)
  - [2.2 Get Current User](#22-get-current-user)
- [3. Socket.IO Connection](#3-socketio-connection)
  - [3.1 Connecting](#31-connecting)
  - [3.2 Rooms](#32-rooms)
  - [3.3 Error Handling](#33-error-handling)
- [4. REST API Reference](#4-rest-api-reference)
  - [4.1 Conversations](#41-conversations)
  - [4.2 Messages](#42-messages)
  - [4.3 Presence & Search](#43-presence--search)
- [5. DTOs (Data Transfer Objects)](#5-dtos-data-transfer-objects)
- [6. Socket Events — Client → Server](#6-socket-events--client--server)
- [7. Socket Events — Server → Client](#7-socket-events--server--client)
- [8. Data Model Notes](#8-data-model-notes)
- [9. Important Gotchas](#9-important-gotchas)
- [10. Integration Flows](#10-integration-flows)
  - [Flow A: Start a Direct Chat](#flow-a-start-a-direct-chat)
  - [Flow B: Receive an Incoming Chat](#flow-b-receive-an-incoming-chat)
  - [Flow C: Send a Reply with Quote](#flow-c-send-a-reply-with-quote)
  - [Flow D: Read Receipts](#flow-d-read-receipts)
  - [Flow E: Typing Indicator](#flow-e-typing-indicator)
  - [Flow F: Delete a Message](#flow-f-delete-a-message)
  - [Flow G: Edit a Message](#flow-g-edit-a-message)
  - [Flow H: Load More Messages / Pagination](#flow-h-load-more-messages--pagination)
  - [Flow I: User Presence](#flow-i-user-presence)
  - [Flow J: Search Users to Start Chat](#flow-j-search-users-to-start-chat)
  - [Flow K: Search Messages](#flow-k-search-messages)
- [11. Quick-Start Checklist](#11-quick-start-checklist)
- [12. Known Limitations](#12-known-limitations)

---

## 1. Architecture Overview

```
┌──────────────┐         HTTPS (REST)          ┌──────────────────┐
│              │ ◄──────────────────────────── │                  │
│   Frontend   │                               │  NestJS Backend  │
│   (Browser)  │ ◄──────────────────────────── │  :8081           │
│              │    WebSocket (Socket.IO)       │                  │
└──────────────┘    namespace: /messaging       └──────────────────┘
```

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **REST API** | `GET/POST/PATCH/DELETE /api/messages/*` | CRUD operations, search, history |
| **WebSocket** | Socket.IO namespace `/messaging` | Real-time events: messages, typing, presence |
| **Auth** | JWT Bearer token | Protects both REST and Socket connections |

**Key principle**: Use REST for initial data loads and mutations that need guaranteed delivery. Use WebSocket for real-time push events. The backend fires socket events as side-effects of REST calls too, so both channels stay in sync.

---

## 2. Authentication

### 2.1 Login

```
POST /api/auth/login
Content-Type: application/json
```

**Request body:**

```json
{
  "email": "student@example.com",
  "password": "password123",
  "rememberMe": true
}
```

**Response `200 OK`:**

```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIs...",
  "user": {
    "id": 1,
    "firstName": "John",
    "lastName": "Doe",
    "email": "student@example.com",
    "role": "student"
  }
}
```

> ⚠️ The token field is **`accessToken`** (camelCase). Store it securely (e.g., `httpOnly` cookie or in-memory). It is required for every subsequent request.

### 2.2 Get Current User

```
GET /api/auth/me
Authorization: Bearer <accessToken>
```

**Response `200 OK`:**

```json
{
  "id": 1,
  "firstName": "John",
  "lastName": "Doe",
  "email": "student@example.com",
  "role": "student"
}
```

---

## 3. Socket.IO Connection

### 3.1 Connecting

The messaging WebSocket lives on the **`/messaging`** namespace. The token **must** be sent in **both** `auth.token` and `query.token` for the handshake to succeed.

```typescript
import { io, Socket } from 'socket.io-client';

const BASE_URL = 'http://localhost:8081';

function connectChat(accessToken: string): Socket {
  const socket = io(`${BASE_URL}/messaging`, {
    // Token in BOTH locations — required by backend middleware
    auth: { token: accessToken },
    query: { token: accessToken },
    transports: ['websocket', 'polling'],
    reconnection: true,
    reconnectionAttempts: 10,
    reconnectionDelay: 1000,
    reconnectionDelayMax: 5000,
  });

  socket.on('connect', () => {
    console.log('✅ Connected to /messaging', socket.id);
    // Backend auto-joins you to your personal room: user_{userId}
  });

  socket.on('connect_error', (err) => {
    console.error('❌ Connection error:', err.message);
    // Common causes: expired token, wrong namespace, server down
  });

  socket.on('disconnect', (reason) => {
    console.warn('🔌 Disconnected:', reason);
    // Socket.IO will auto-reconnect unless reason is 'io server disconnect'
  });

  return socket;
}
```

> **Reconnection**: Socket.IO handles reconnection automatically. On reconnect, the backend re-joins the user to their `user_{userId}` room. You must re-join any conversation rooms you were in.

### 3.2 Rooms

| Room Pattern | Joined How | Receives |
|-------------|-----------|----------|
| `user_{userId}` | **Automatically** on socket connect | `new_message_notification`, `user_status` |
| `conversation_{conversationId}` | **Manually** via `join_conversation` event | `new_message`, `user_typing`, `message_read`, `message_deleted`, `message_edited` |

### 3.3 Error Handling

The server emits `error` events for invalid payloads or unauthorized actions:

```typescript
socket.on('error', (payload: { message: string }) => {
  console.error('Socket error:', payload.message);
  // Examples: "Conversation not found", "Not authorized to delete this message"
});
```

---

## 4. REST API Reference

All endpoints require the `Authorization: Bearer <accessToken>` header unless noted otherwise.

### 4.1 Conversations

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/api/messages/conversations` | List all conversations for the current user |
| `POST` | `/api/messages/conversations` | Start a new conversation (direct or group) |
| `GET` | `/api/messages/conversations/:id` | Get messages in a conversation (paginated) |
| `POST` | `/api/messages/conversations/:id` | Send a message to an existing conversation |

#### List Conversations

```
GET /api/messages/conversations
Authorization: Bearer <token>
```

**Response `200 OK`** — Array of conversation summaries:

```json
[
  {
    "conversationId": 42,
    "type": "direct",
    "groupName": null,
    "participants": [
      { "userId": 1, "firstName": "John", "lastName": "Doe" },
      { "userId": 2, "firstName": "Jane", "lastName": "Smith" }
    ],
    "lastMessage": {
      "id": 305,
      "text": "See you in class!",
      "sentAt": "2025-07-12T10:30:00.000Z",
      "senderId": 2
    },
    "unreadCount": 3
  }
]
```

#### Start a Conversation

```
POST /api/messages/conversations
Authorization: Bearer <token>
Content-Type: application/json
```

**Request body** (`StartConversationDto`):

```json
{
  "participantIds": [2],
  "type": "direct",
  "text": "Hey, do you have the notes from today?",
  "fileId": null
}
```

**Response `201 Created`:**

```json
{
  "conversationId": 42,
  "message": {
    "id": 305,
    "text": "Hey, do you have the notes from today?",
    "senderId": 1,
    "sentAt": "2025-07-12T10:30:00.000Z"
  },
  "existing": false
}
```

> **Note**: For `type: "direct"`, if a conversation already exists between the two users, the response returns `existing: true` with the existing `conversationId`. No duplicate direct conversations are created.

#### Get Conversation Messages (Paginated)

```
GET /api/messages/conversations/42?page=1&limit=50
Authorization: Bearer <token>
```

**Response `200 OK`:**

```json
{
  "data": [
    {
      "id": 305,
      "text": "Hey, do you have the notes from today?",
      "senderId": 1,
      "sentAt": "2025-07-12T10:30:00.000Z",
      "fileId": null,
      "replyToId": null,
      "editedAt": null,
      "status": "sent"
    }
  ],
  "meta": {
    "page": 1,
    "limit": 50,
    "total": 1,
    "totalPages": 1
  }
}
```

#### Send a Message to a Conversation

```
POST /api/messages/conversations/42
Authorization: Bearer <token>
Content-Type: application/json
```

**Request body** (`SendMessageDto`):

```json
{
  "text": "Sure! I'll share them now.",
  "replyToId": 305,
  "fileId": null
}
```

**Response `201 Created`** — The created message object.

### 4.2 Messages

| Method | Endpoint | Description |
|--------|----------|-------------|
| `PATCH` | `/api/messages/:id/read` | Mark a message as read |
| `PATCH` | `/api/messages/:id` | Edit a message *(NEW)* |
| `DELETE` | `/api/messages/:id` | Delete for me only |
| `DELETE` | `/api/messages/:id/everyone` | Delete for everyone (sender only) |

#### Mark as Read

```
PATCH /api/messages/42/read
Authorization: Bearer <token>
```

**Response `200 OK`:**

```json
{
  "messageId": 42,
  "readAt": "2025-07-12T10:35:00.000Z"
}
```

#### Edit a Message *(NEW)*

```
PATCH /api/messages/305
Authorization: Bearer <token>
Content-Type: application/json
```

**Request body:**

```json
{
  "text": "Updated message text"
}
```

**Response `200 OK`:**

```json
{
  "id": 305,
  "text": "Updated message text",
  "editedAt": "2025-07-12T11:00:00.000Z"
}
```

#### Delete for Me

```
DELETE /api/messages/305
Authorization: Bearer <token>
```

**Response `200 OK`:**

```json
{
  "messageId": 305,
  "deletedForMe": true
}
```

#### Delete for Everyone

```
DELETE /api/messages/305/everyone
Authorization: Bearer <token>
```

**Response `200 OK`:**

```json
{
  "messageId": 305,
  "deletedForEveryone": true
}
```

> ⚠️ Only the **original sender** can delete for everyone. The message body becomes `__DELETED__` in the database.

### 4.3 Presence & Search

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/api/messages/unread-count` | Get total unread message count |
| `GET` | `/api/messages/online-users` | Get list of online user IDs |
| `GET` | `/api/messages/search` | Search messages by text |
| `GET` | `/api/messages/users/search` | Search users by name *(NEW)* |

#### Unread Count

```
GET /api/messages/unread-count
Authorization: Bearer <token>
```

**Response:** `{ "count": 7 }`

#### Online Users

```
GET /api/messages/online-users
Authorization: Bearer <token>
```

**Response:** `{ "onlineUserIds": [1, 3, 5, 12] }`

#### Search Messages

```
GET /api/messages/search?query=notes&page=1&limit=20
Authorization: Bearer <token>
```

**Response:**

```json
{
  "data": [
    {
      "id": 305,
      "text": "Hey, do you have the notes from today?",
      "senderId": 1,
      "conversationId": 42,
      "sentAt": "2025-07-12T10:30:00.000Z"
    }
  ],
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 1,
    "totalPages": 1
  }
}
```

#### Search Users *(NEW)*

```
GET /api/messages/users/search?query=john
Authorization: Bearer <token>
```

**Response:**

```json
[
  {
    "userId": 1,
    "firstName": "John",
    "lastName": "Doe",
    "email": "john.doe@example.com"
  }
]
```

---

## 5. DTOs (Data Transfer Objects)

Use these TypeScript interfaces to type your requests:

```typescript
/** POST /api/messages/conversations */
interface StartConversationDto {
  participantIds: number[];       // User IDs to include
  type: 'direct' | 'group';      // Conversation type
  groupName?: string;             // Required for 'group' type
  text: string;                   // Initial message text
  fileId?: number;                // Optional file attachment
}

/** POST /api/messages/conversations/:id */
interface SendMessageDto {
  text: string;                   // Message body
  fileId?: number;                // Optional file attachment
  replyToId?: number;             // ID of the message being replied to
}

/** GET /api/messages/conversations/:id query params */
interface MessageQueryDto {
  page?: number;                  // Default: 1, Min: 1
  limit?: number;                 // Default: 50, Min: 1, Max: 100
}

/** GET /api/messages/search query params */
interface SearchMessagesDto {
  query: string;                  // Search text (required)
  page?: number;                  // Default: 1
  limit?: number;                 // Default: 20, Max: 50
}
```

---

## 6. Socket Events — Client → Server

These are events your frontend **emits** to the server.

| Event | Payload | Response Event | Notes |
|-------|---------|----------------|-------|
| `join_conversation` | `{ conversationId: number }` | `joined` → `{ conversationId }` | Joins the `conversation_{id}` room |
| `leave_conversation` | `{ conversationId: number }` | `left` → `{ conversationId }` | Leaves the room |
| `send_message` | `{ conversationId, text, replyToId?, fileId? }` | `message_sent` → message object | Also triggers `new_message` broadcast |
| `typing` | `{ conversationId, isTyping: boolean }` | *(none)* | Broadcasts `user_typing` to room |
| `mark_read` | `{ conversationId: number }` | `read_confirmed` → `{ conversationId, markedRead }` | Marks ALL messages in conversation |
| `delete_message` | `{ messageId, forEveryone: boolean }` | `delete_confirmed` → `{ messageId, ... }` | `forEveryone` only works for sender |
| `edit_message` | `{ messageId, text }` | `edit_confirmed` → `{ messageId, text, editedAt }` | *(NEW)* |

---

## 7. Socket Events — Server → Client

These are events your frontend **listens** for.

| Event | Payload | Delivered To | When |
|-------|---------|-------------|------|
| `message_sent` | `{ id, conversationId, senderId, text, fileId?, replyToId?, sentAt, status }` | **Sender only** (callback) | After `send_message` emit |
| `new_message` | `{ id, conversationId, senderId, text, fileId?, sentAt, status, senderUserId }` | **Conversation room** (all members including sender) | When any member sends a message |
| `new_message_notification` | `{ conversationId, message, senderUserId }` | **`user_{id}` room** (participants NOT in conversation room) | When a message is sent to a conversation you haven't joined |
| `user_typing` | `{ conversationId, userId, isTyping }` | **Conversation room** | When a member starts/stops typing |
| `message_read` | `{ conversationId, userId, readAt, markedRead }` | **Conversation room** | When a member marks messages as read |
| `message_deleted` | `{ messageId, deletedForEveryone, deletedBy }` | **All clients** (broadcast) | When a message is deleted for everyone |
| `message_edited` | `{ messageId, text, editedAt, editedBy }` | **Conversation room** | When a message is edited *(NEW)* |
| `user_status` | `{ userId, isOnline, lastSeen }` | **All clients** (broadcast) | When any user connects/disconnects |
| `joined` | `{ conversationId }` | **Sender only** | Confirmation of `join_conversation` |
| `left` | `{ conversationId }` | **Sender only** | Confirmation of `leave_conversation` |
| `read_confirmed` | `{ conversationId, markedRead }` | **Sender only** | Confirmation of `mark_read` |
| `delete_confirmed` | `{ messageId, deletedForMe/deletedForEveryone }` | **Sender only** | Confirmation of `delete_message` |
| `edit_confirmed` | `{ messageId, text, editedAt }` | **Sender only** | Confirmation of `edit_message` *(NEW)* |
| `error` | `{ message: string }` | **Sender only** | On any server-side error |

---

## 8. Data Model Notes

### Conversation Tree Structure

```
Root Message (conversation container)
├── id: 100 (rootMessageId)
├── type: 'direct' | 'group'
├── groupName: string | null
│
├── Child Message (id: 101, parentMessageId: 100)
│   └── text: "Hey, how are you?"
│
├── Child Message (id: 102, parentMessageId: 100, replyToId: 101)
│   └── text: "I'm good! How about you?"     ← reply to msg 101
│
└── Child Message (id: 103, parentMessageId: 100)
    └── text: "Anyone have the assignment?"
```

- **`parentMessageId`** — always points to the root message of the conversation. This is managed by the backend; you don't need to send it.
- **`replyToId`** — the ID of a specific message being quoted/replied to. This is what you pass in `SendMessageDto` and display in the UI as a quoted reply.

### Message Status Values

| Status | Meaning |
|--------|---------|
| `sent` | Message has been saved to the database |
| `read` | Message has been read by the recipient |

---

## 9. Important Gotchas

### ⚡ Gotcha 1: Duplicate Messages for Sender

When you emit `send_message`, you receive:
1. **`message_sent`** — direct callback to the sender
2. **`new_message`** — broadcast to the conversation room (which includes you!)

**You will get the same message twice.** Deduplicate in your handler:

```typescript
const myUserId = getCurrentUserId();

socket.on('new_message', (msg) => {
  // Skip if this is my own message — already handled via message_sent
  if (msg.senderId === myUserId) return;

  addMessageToChat(msg);
});
```

### ⚡ Gotcha 2: `replyToId` vs `parentMessageId`

- `parentMessageId` = structural (links message to conversation root). **Backend managed.**
- `replyToId` = semantic (which message is being quoted). **Frontend provides this.**

Never confuse the two. When rendering a reply, fetch the referenced message by `replyToId`.

### ⚡ Gotcha 3: Read Receipts Are Conversation-Level

`mark_read` marks **ALL** unread messages in the conversation as read — not a single message. Call it when the user opens/views a conversation.

### ⚡ Gotcha 4: Delete for Everyone Uses `__DELETED__` Marker

Messages deleted for everyone are not removed from the database. Their `body` is set to `'__DELETED__'`. When rendering:

```typescript
function renderMessage(msg: Message) {
  if (msg.text === '__DELETED__') {
    return '🚫 This message was deleted';
  }
  return msg.text;
}
```

### ⚡ Gotcha 5: Client Must Cancel Typing

The backend has **no server-side typing timeout**. If your user stops typing, you **must** emit `isTyping: false` explicitly. Implement a client-side debounce:

```typescript
let typingTimeout: ReturnType<typeof setTimeout>;

function onInputChange(conversationId: number) {
  socket.emit('typing', { conversationId, isTyping: true });

  clearTimeout(typingTimeout);
  typingTimeout = setTimeout(() => {
    socket.emit('typing', { conversationId, isTyping: false });
  }, 3000); // Stop typing after 3s of inactivity
}
```

### ⚡ Gotcha 6: `new_message_notification` vs `new_message`

- **`new_message`** fires to the `conversation_{id}` room — only received if you have **joined** the conversation via socket.
- **`new_message_notification`** fires to the `user_{id}` room — received when you are **NOT** in the conversation room. Use this for notification badges and toast popups.

---

## 10. Integration Flows

### Flow A: Start a Direct Chat

**Scenario**: User clicks on another user's profile and starts a conversation.

```
┌──────────┐          ┌──────────┐          ┌──────────┐
│  Search   │  ───►   │  Create  │  ───►    │  Join &  │
│  Users    │         │  Conv    │          │  Chat    │
└──────────┘          └──────────┘          └──────────┘
```

```typescript
import axios from 'axios';
import { io, Socket } from 'socket.io-client';

const API = 'http://localhost:8081/api';
let socket: Socket;

async function startDirectChat(
  token: string,
  targetUserId: number,
  initialMessage: string,
) {
  // 1. Create (or reuse) a direct conversation
  const { data } = await axios.post(
    `${API}/messages/conversations`,
    {
      participantIds: [targetUserId],
      type: 'direct',
      text: initialMessage,
    },
    { headers: { Authorization: `Bearer ${token}` } },
  );

  const { conversationId, message, existing } = data;

  if (existing) {
    console.log(`Reusing existing conversation ${conversationId}`);
  }

  // 2. Connect socket (if not already connected)
  if (!socket || !socket.connected) {
    socket = io('http://localhost:8081/messaging', {
      auth: { token },
      query: { token },
      transports: ['websocket', 'polling'],
    });
    await new Promise<void>((resolve) => socket.on('connect', resolve));
  }

  // 3. Join the conversation room
  socket.emit('join_conversation', { conversationId });
  await new Promise<void>((resolve) => {
    socket.once('joined', (payload) => {
      console.log(`Joined conversation ${payload.conversationId}`);
      resolve();
    });
  });

  // 4. Load message history
  const history = await axios.get(
    `${API}/messages/conversations/${conversationId}?page=1&limit=50`,
    { headers: { Authorization: `Bearer ${token}` } },
  );

  console.log(`Loaded ${history.data.data.length} messages`);
  return { conversationId, messages: history.data.data, meta: history.data.meta };
}
```

---

### Flow B: Receive an Incoming Chat

**Scenario**: Another user sends you a message while you're not in their conversation.

```
┌─────────────────────┐        ┌──────────────┐        ┌───────────┐
│ new_message_         │ ───►  │ Show toast / │  ───►  │ Join conv │
│ notification         │       │ badge update │        │ & load    │
└─────────────────────┘        └──────────────┘        └───────────┘
```

```typescript
function setupNotificationListener(socket: Socket, token: string) {
  socket.on('new_message_notification', async (payload) => {
    const { conversationId, message, senderUserId } = payload;

    // 1. Show a toast notification
    showToast(`New message from user #${senderUserId}: ${message.text}`);

    // 2. Update the conversation list badge
    incrementUnreadBadge(conversationId);

    // 3. When user clicks the notification → open the conversation
    // openConversation(conversationId, token);
  });
}

async function openConversation(
  socket: Socket,
  conversationId: number,
  token: string,
) {
  // Join the conversation room
  socket.emit('join_conversation', { conversationId });

  // Load history
  const { data } = await axios.get(
    `${API}/messages/conversations/${conversationId}?page=1&limit=50`,
    { headers: { Authorization: `Bearer ${token}` } },
  );

  renderMessages(data.data);

  // Mark as read
  socket.emit('mark_read', { conversationId });
}
```

---

### Flow C: Send a Reply with Quote

**Scenario**: User long-presses/clicks a message to reply to it with a quoted reference.

```typescript
interface ReplyState {
  replyToId: number | null;
  replyToText: string | null;
}

const replyState: ReplyState = { replyToId: null, replyToText: null };

// User selects a message to reply to
function setReplyTarget(messageId: number, messageText: string) {
  replyState.replyToId = messageId;
  replyState.replyToText = messageText;
  showReplyPreview(messageText); // UI: show quoted text above input
}

function clearReplyTarget() {
  replyState.replyToId = null;
  replyState.replyToText = null;
  hideReplyPreview();
}

// Send the reply
function sendReply(socket: Socket, conversationId: number, text: string) {
  const payload: Record<string, unknown> = { conversationId, text };

  if (replyState.replyToId) {
    payload.replyToId = replyState.replyToId;
  }

  socket.emit('send_message', payload);

  socket.once('message_sent', (msg) => {
    addMessageToChat({
      ...msg,
      replyToId: replyState.replyToId,
      replyToText: replyState.replyToText, // Keep locally for display
    });
    clearReplyTarget();
  });
}

// Rendering a reply bubble
function renderMessageBubble(msg: Message) {
  if (msg.replyToId) {
    // Fetch the quoted message from your local message cache
    const quoted = getMessageById(msg.replyToId);
    return `
      <div class="reply-quote">
        ↩ ${quoted?.text ?? 'Original message unavailable'}
      </div>
      <div class="message-body">${msg.text}</div>
    `;
  }
  return `<div class="message-body">${msg.text}</div>`;
}
```

---

### Flow D: Read Receipts

**Scenario**: Show blue ticks / "read" status when the recipient sees your message.

```
Sender                          Receiver
  │                                │
  │  ── send_message ──►           │
  │  ◄── message_sent ──           │
  │                                │
  │           new_message ──►      │
  │                                │  (user views conversation)
  │                                │  ── mark_read ──►
  │  ◄── message_read ──          │  ◄── read_confirmed ──
  │                                │
  │  Update UI: ✓✓ (blue)         │
```

```typescript
// RECEIVER: Mark as read when viewing a conversation
function onConversationVisible(socket: Socket, conversationId: number) {
  socket.emit('mark_read', { conversationId });

  socket.on('read_confirmed', (payload) => {
    console.log(`Marked ${payload.markedRead} messages as read in conv ${payload.conversationId}`);
  });
}

// SENDER: Listen for read receipts from others
function setupReadReceipts(socket: Socket, myUserId: number) {
  socket.on('message_read', (payload) => {
    const { conversationId, userId, readAt, markedRead } = payload;

    if (userId === myUserId) return; // Ignore own read events

    // Update tick marks for messages in this conversation
    updateMessageTicks(conversationId, {
      readBy: userId,
      readAt,
      count: markedRead,
    });
  });
}

// UI helper
function getTickIcon(message: Message, readReceipts: ReadReceipt[]) {
  const isRead = readReceipts.some(
    (r) => r.conversationId === message.conversationId,
  );
  return isRead ? '✓✓' : '✓'; // Double tick = read, single = sent
}
```

---

### Flow E: Typing Indicator

**Scenario**: Show "User is typing..." when the other person types.

```typescript
// ─── SENDER SIDE: Emit typing events ───

let typingTimeout: ReturnType<typeof setTimeout> | null = null;
let isCurrentlyTyping = false;

function handleInputChange(socket: Socket, conversationId: number) {
  // Start typing (only emit once)
  if (!isCurrentlyTyping) {
    isCurrentlyTyping = true;
    socket.emit('typing', { conversationId, isTyping: true });
  }

  // Reset the inactivity timer
  if (typingTimeout) clearTimeout(typingTimeout);

  typingTimeout = setTimeout(() => {
    isCurrentlyTyping = false;
    socket.emit('typing', { conversationId, isTyping: false });
  }, 3000);
}

function handleSendMessage(socket: Socket, conversationId: number) {
  // Immediately cancel typing when message is sent
  if (isCurrentlyTyping) {
    isCurrentlyTyping = false;
    if (typingTimeout) clearTimeout(typingTimeout);
    socket.emit('typing', { conversationId, isTyping: false });
  }
}

// ─── RECEIVER SIDE: Show typing indicator ───

const typingUsers = new Map<number, Set<number>>(); // conversationId → Set<userId>

function setupTypingListener(socket: Socket, myUserId: number) {
  socket.on('user_typing', (payload) => {
    const { conversationId, userId, isTyping } = payload;

    if (userId === myUserId) return; // Ignore own typing events

    if (!typingUsers.has(conversationId)) {
      typingUsers.set(conversationId, new Set());
    }

    const users = typingUsers.get(conversationId)!;
    if (isTyping) {
      users.add(userId);
    } else {
      users.delete(userId);
    }

    updateTypingUI(conversationId, users);
  });
}

function updateTypingUI(conversationId: number, userIds: Set<number>) {
  if (userIds.size === 0) {
    hideTypingIndicator(conversationId);
  } else if (userIds.size === 1) {
    showTypingIndicator(conversationId, `User is typing...`);
  } else {
    showTypingIndicator(conversationId, `${userIds.size} people are typing...`);
  }
}
```

---

### Flow F: Delete a Message

**Scenario**: User deletes their own message — either for themselves only or for everyone.

```typescript
// ─── DELETE: Emit the event ───

function deleteMessage(
  socket: Socket,
  messageId: number,
  forEveryone: boolean,
) {
  socket.emit('delete_message', { messageId, forEveryone });
}

// ─── SENDER: Confirmation ───

socket.on('delete_confirmed', (payload) => {
  if (payload.deletedForEveryone) {
    // Remove/replace message for everyone
    replaceMessageContent(payload.messageId, '🚫 This message was deleted');
  } else if (payload.deletedForMe) {
    // Remove from local view only
    removeMessageFromView(payload.messageId);
  }
});

// ─── ALL CLIENTS: Broadcast for "delete for everyone" ───

socket.on('message_deleted', (payload) => {
  const { messageId, deletedForEveryone, deletedBy } = payload;

  if (deletedForEveryone) {
    replaceMessageContent(messageId, '🚫 This message was deleted');
  }
});

// ─── RENDERING DELETED MESSAGES ───

function renderMessage(msg: Message) {
  if (msg.text === '__DELETED__') {
    return '<div class="deleted-message">🚫 This message was deleted</div>';
  }
  return `<div class="message">${msg.text}</div>`;
}
```

---

### Flow G: Edit a Message

**Scenario**: User edits a previously sent message.

```typescript
// ─── EDIT: Emit the event ───

function editMessage(socket: Socket, messageId: number, newText: string) {
  socket.emit('edit_message', { messageId, text: newText });
}

// ─── SENDER: Confirmation ───

socket.on('edit_confirmed', (payload) => {
  const { messageId, text, editedAt } = payload;
  updateMessageInView(messageId, text, editedAt);
});

// ─── ALL CONVERSATION MEMBERS: Broadcast ───

socket.on('message_edited', (payload) => {
  const { messageId, text, editedAt, editedBy } = payload;
  updateMessageInView(messageId, text, editedAt);
});

// ─── RENDERING EDITED MESSAGES ───

function renderMessage(msg: Message) {
  const editedLabel = msg.editedAt
    ? `<span class="edited-label">(edited)</span>`
    : '';

  return `<div class="message">${msg.text} ${editedLabel}</div>`;
}
```

---

### Flow H: Load More Messages / Pagination

**Scenario**: User scrolls up to load older messages.

```typescript
interface PaginationState {
  currentPage: number;
  totalPages: number;
  isLoading: boolean;
}

const paginationState: PaginationState = {
  currentPage: 1,
  totalPages: 1,
  isLoading: false,
};

async function loadMessages(
  conversationId: number,
  token: string,
  page: number = 1,
  limit: number = 50,
) {
  const { data } = await axios.get(
    `${API}/messages/conversations/${conversationId}`,
    {
      params: { page, limit },
      headers: { Authorization: `Bearer ${token}` },
    },
  );

  paginationState.currentPage = data.meta.page;
  paginationState.totalPages = data.meta.totalPages;

  return data;
}

async function loadMoreMessages(conversationId: number, token: string) {
  if (paginationState.isLoading) return;
  if (paginationState.currentPage >= paginationState.totalPages) return;

  paginationState.isLoading = true;
  const nextPage = paginationState.currentPage + 1;

  try {
    const { data, meta } = await loadMessages(conversationId, token, nextPage);

    // Prepend older messages to the top of the chat
    prependMessages(data);

    // Preserve scroll position so the view doesn't jump
    preserveScrollPosition();
  } finally {
    paginationState.isLoading = false;
  }
}

// Attach to scroll event
function onChatScroll(
  event: Event,
  conversationId: number,
  token: string,
) {
  const container = event.target as HTMLElement;

  // When user scrolls to the top, load more
  if (container.scrollTop === 0) {
    loadMoreMessages(conversationId, token);
  }
}
```

---

### Flow I: User Presence

**Scenario**: Show green/gray dots next to user names based on online status.

```typescript
const onlineUsers = new Set<number>();

// ─── INITIAL LOAD: Fetch current online users ───

async function loadOnlineUsers(token: string) {
  const { data } = await axios.get(`${API}/messages/online-users`, {
    headers: { Authorization: `Bearer ${token}` },
  });

  onlineUsers.clear();
  data.onlineUserIds.forEach((id: number) => onlineUsers.add(id));
  refreshPresenceUI();
}

// ─── REAL-TIME UPDATES: Listen for status changes ───

function setupPresenceListener(socket: Socket) {
  socket.on('user_status', (payload) => {
    const { userId, isOnline, lastSeen } = payload;

    if (isOnline) {
      onlineUsers.add(userId);
    } else {
      onlineUsers.delete(userId);
    }

    updateUserPresenceUI(userId, isOnline, lastSeen);
  });
}

// ─── UI HELPERS ───

function isUserOnline(userId: number): boolean {
  return onlineUsers.has(userId);
}

function getPresenceIndicator(userId: number): string {
  return isUserOnline(userId) ? '🟢 Online' : '⚫ Offline';
}
```

---

### Flow J: Search Users to Start Chat

**Scenario**: User types a name into the "New Chat" search bar.

```typescript
let searchTimeout: ReturnType<typeof setTimeout>;

async function searchUsers(query: string, token: string) {
  const { data } = await axios.get(`${API}/messages/users/search`, {
    params: { query },
    headers: { Authorization: `Bearer ${token}` },
  });

  return data as Array<{
    userId: number;
    firstName: string;
    lastName: string;
    email: string;
  }>;
}

// Debounced search for the input field
function onSearchInput(input: string, token: string) {
  clearTimeout(searchTimeout);

  if (input.length < 2) {
    clearSearchResults();
    return;
  }

  searchTimeout = setTimeout(async () => {
    const users = await searchUsers(input, token);
    renderUserSearchResults(users);
  }, 300);
}

// When user selects a result → start a direct chat
async function onUserSelected(userId: number, token: string) {
  // This is Flow A — startDirectChat
  // You'll need the user to type an initial message or provide a default
  const result = await startDirectChat(token, userId, 'Hi! 👋');
  navigateToConversation(result.conversationId);
}
```

---

### Flow K: Search Messages

**Scenario**: User searches for a message across all conversations.

```typescript
interface SearchResult {
  data: Message[];
  meta: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
}

async function searchMessages(
  query: string,
  token: string,
  page: number = 1,
  limit: number = 20,
): Promise<SearchResult> {
  const { data } = await axios.get(`${API}/messages/search`, {
    params: { query, page, limit },
    headers: { Authorization: `Bearer ${token}` },
  });

  return data;
}

// Render search results with conversation context
function renderSearchResults(results: SearchResult) {
  results.data.forEach((msg) => {
    const item = document.createElement('div');
    item.className = 'search-result-item';
    item.innerHTML = `
      <div class="search-result-conv">Conversation #${msg.conversationId}</div>
      <div class="search-result-text">${highlightMatch(msg.text, currentQuery)}</div>
      <div class="search-result-time">${formatTime(msg.sentAt)}</div>
    `;

    // Click to navigate to that conversation and scroll to the message
    item.onclick = () => navigateToMessage(msg.conversationId, msg.id);

    searchContainer.appendChild(item);
  });
}

function highlightMatch(text: string, query: string): string {
  const regex = new RegExp(`(${escapeRegex(query)})`, 'gi');
  return text.replace(regex, '<mark>$1</mark>');
}
```

---

## 11. Quick-Start Checklist

Use this checklist to verify your integration is complete:

- [ ] **Auth**: Login and store `accessToken`
- [ ] **Socket**: Connect to `/messaging` with token in `auth` AND `query`
- [ ] **Conversations**: List all conversations on app load
- [ ] **Unread badge**: Fetch `unread-count` and display badge
- [ ] **Open conversation**: Join room → load history → mark as read
- [ ] **Send message**: Emit `send_message` → handle `message_sent`
- [ ] **Receive message**: Handle `new_message` with sender deduplication
- [ ] **Notifications**: Handle `new_message_notification` for unjoined conversations
- [ ] **Typing**: Emit `typing` with debounce → handle `user_typing`
- [ ] **Read receipts**: Emit `mark_read` → handle `message_read`
- [ ] **Replies**: Pass `replyToId` in `send_message` → render quoted text
- [ ] **Delete**: Emit `delete_message` → handle both `delete_confirmed` + `message_deleted`
- [ ] **Edit**: Emit `edit_message` → handle both `edit_confirmed` + `message_edited`
- [ ] **Pagination**: Load older messages on scroll-up
- [ ] **Presence**: Fetch `online-users` + listen `user_status`
- [ ] **Search users**: Implement user search for new conversations
- [ ] **Search messages**: Implement message search across conversations
- [ ] **Leave room**: Emit `leave_conversation` when navigating away
- [ ] **Reconnect**: Re-join conversation rooms on socket reconnect
- [ ] **Error handling**: Listen for `error` events and display user-friendly messages
- [ ] **Deleted markers**: Render `__DELETED__` messages as "This message was deleted"

---

## 12. Known Limitations

These are current limitations of the messaging backend. Plan your UI accordingly:

| Area | Limitation | Workaround |
|------|-----------|------------|
| **File uploads** | `fileId` field exists in DTOs but there is no file upload endpoint in the messaging module | Integrate with the separate Files module (if available) to upload first, then pass `fileId` |
| **Conversation search** | No endpoint to search conversations by name or participant | Filter the conversation list client-side |
| **Group management** | No endpoints for adding/removing group members after creation | Groups are immutable once created; create a new group if membership changes |
| **Message reactions** | No emoji reaction support (👍, ❤️, etc.) | Not available — would need backend changes |
| **Message pinning** | No ability to pin important messages | Not available |
| **Message forwarding** | No ability to forward messages to other conversations | Copy text and send as a new message |
| **Notification preferences** | No mute/unmute per conversation | Not available — all notifications are delivered |
| **Delivery status** | No `delivered` status tracking (only `sent` and `read`) | Use `sent` as the baseline; no intermediate delivery confirmation |
| **Online privacy** | `user_status` broadcasts to ALL connected users | All users can see who is online; no privacy controls or "appear offline" option |
| **Typing timeout** | Server has no timeout — relies on client to send `isTyping: false` | Implement a 3-second client-side timeout (see [Flow E](#flow-e-typing-indicator)) |
| **Read receipt granularity** | `mark_read` is conversation-level, not per-message | All unread messages in the conversation are marked at once |

---

*This guide covers the complete EduVerse messaging API as of the current backend version. For updates, check the backend source code or contact the backend team.*

