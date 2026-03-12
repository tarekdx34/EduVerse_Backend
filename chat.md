EduVerse Chat — Frontend Integration Guide

1. Connection Setup

// 1. Login via REST to get a JWT token
const res = await fetch('http://localhost:8081/api/auth/login', {
method: 'POST',
headers: { 'Content-Type': 'application/json' },
body: JSON.stringify({ email, password, rememberMe: false })
});
const { accessToken } = await res.json();

// 2. Connect to the messaging namespace
const socket = io('http://localhost:8081/messaging', {
auth: { token: accessToken }, // primary
query: { token: accessToken }, // fallback
transports: ['websocket']
});

Namespace: /messaging
Port: 8081
Token field from login response: accessToken

---

2. REST API Reference

All requests require Authorization: Bearer <token>.

┌──────────┬───────────────────────────────────┬───────────────────────────────────┬────────────────────────────────────────────┐
│ Method │ Path │ Body / Query │ Response │
├──────────┼───────────────────────────────────┼───────────────────────────────────┼────────────────────────────────────────────┤
│ POST │ /api/auth/login │ { email, password, rememberMe } │ { accessToken, user } │
├──────────┼───────────────────────────────────┼───────────────────────────────────┼────────────────────────────────────────────┤
│ GET │ /api/auth/me │ — │ { id, firstName, lastName, email, role } │
├──────────┼───────────────────────────────────┼───────────────────────────────────┼────────────────────────────────────────────┤
│ GET │ /api/messages/conversations │ — │ ConversationSummary[] │
├──────────┼───────────────────────────────────┼───────────────────────────────────┼────────────────────────────────────────────┤
│ POST │ /api/messages/conversations │ StartConversationDto │ { conversationId, message, existing } │
├──────────┼───────────────────────────────────┼───────────────────────────────────┼────────────────────────────────────────────┤
│ GET │ /api/messages/conversations/:id │ ?page=1&limit=50 │ { data: Message[], meta } │
├──────────┼───────────────────────────────────┼───────────────────────────────────┼────────────────────────────────────────────┤
│ POST │ /api/messages/conversations/:id │ { text, fileId?, replyToId? } │ Message │
├──────────┼───────────────────────────────────┼───────────────────────────────────┼────────────────────────────────────────────┤
│ PATCH │ /api/messages/:id/read │ — │ { messageId, readAt } │
├──────────┼───────────────────────────────────┼───────────────────────────────────┼────────────────────────────────────────────┤
│ DELETE │ /api/messages/:id │ — │ { messageId, deletedForMe: true } │
├──────────┼───────────────────────────────────┼───────────────────────────────────┼────────────────────────────────────────────┤
│ DELETE │ /api/messages/:id/everyone │ — │ { messageId, deletedForEveryone: true } │
├──────────┼───────────────────────────────────┼───────────────────────────────────┼────────────────────────────────────────────┤
│ GET │ /api/messages/unread-count │ — │ { count: number } │
├──────────┼───────────────────────────────────┼───────────────────────────────────┼────────────────────────────────────────────┤
│ GET │ /api/messages/search │ ?query=text&page=1&limit=20 │ { data: Message[], meta } │
├──────────┼───────────────────────────────────┼───────────────────────────────────┼────────────────────────────────────────────┤
│ GET │ /api/messages/online-users │ — │ { onlineUserIds: number[] } │
└──────────┴───────────────────────────────────┴───────────────────────────────────┴────────────────────────────────────────────┘

DTO Shapes

// StartConversationDto
{
participantIds: number[]; // user IDs (one for DM, multiple for group)
type: 'direct' | 'group';
groupName?: string; // required if type === 'group'
text: string; // first message
fileId?: number;
}

// ConversationSummary (item in GET /conversations)
{
conversationId: number;
type: 'direct' | 'group';
groupName?: string;
participants: { userId, firstName, lastName, email }[];
lastMessage?: { text, sentAt, senderId };
unreadCount: number;
}

// Message (item in GET /conversations/:id)
{
id: number;
senderId: number;
text: string | null; // null if deleted for everyone
isDeleted: boolean;
fileId?: number;
replyToId?: number | null; // ⚠️ NOT returned by socket send — track client-side
sentAt: Date;
status: 'sent' | 'delivered' | 'read' | 'deleted';
}

// Pagination meta
{ total: number; page: number; limit: number; totalPages: number }

---

3. Socket Events Reference

Events you EMIT (Client → Server)

// Join a conversation room (required before receiving messages)
socket.emit('join_conversation', { conversationId: number });

// Leave a conversation room
socket.emit('leave_conversation', { conversationId: number });

// Send a message
socket.emit('send_message', {
conversationId: number;
text: string;
replyToId?: number; // message ID to reply to
fileId?: number;
});

// Typing indicator
socket.emit('typing', { conversationId: number, isTyping: boolean });

// Mark entire conversation as read
socket.emit('mark_read', { conversationId: number });

// Delete a message
socket.emit('delete_message', {
messageId: number;
forEveryone: boolean; // true = delete for all, false = delete for me only
});

Events you LISTEN TO (Server → Client)

// ── Connection acknowledgments ──
socket.on('joined', (data) => {
// { conversationId: number }
});

socket.on('left', (data) => {
// { conversationId: number }
});

// ── Messages ──
socket.on('message_sent', (data) => {
// Your own message confirmed by server
// { id, conversationId, senderId, text, sentAt, status }
// ⚠️ replyToId is NOT included — store it yourself before emitting send_message
});

socket.on('new_message', (data) => {
// A message received in a conversation you've joined
// { id, conversationId, senderId, text, fileId?, sentAt, status }
// Fires for ALL participants including sender — skip if senderId === myUserId
});

socket.on('new*message_notification', (data) => {
// Fires on your personal room (user*${userId}) when you are NOT in the conversation
// Use to show a notification banner
// { conversationId, senderUserId, message: { text, sentAt } }
});

// ── Typing ──
socket.on('user_typing', (data) => {
// { conversationId, userId, isTyping: boolean }
});

// ── Read receipts ──
socket.on('message_read', (data) => {
// Broadcast when someone marks a conversation read
// { conversationId, userId, readAt, markedRead: number }
});

socket.on('read_confirmed', (data) => {
// Your own mark_read acknowledged
// { conversationId, markedRead: number }
});

// ── Deletion ──
socket.on('message_deleted', (data) => {
// Broadcast when deleted for everyone
// { messageId, deletedForEveryone: true, deletedBy: number }
});

socket.on('delete_confirmed', (data) => {
// Your own delete acknowledged
// { messageId, deletedForMe?: true } or { messageId, deletedForEveryone?: true }
});

// ── Presence ──
socket.on('user_status', (data) => {
// { userId, isOnline: boolean, lastSeen: Date }
// Broadcast globally to all connected clients
});

// ── Errors ──
socket.on('error', (data) => {
// { message: string }
});

---

4. Complete Integration Flows

Flow A — Start a Direct Chat

// 1. Create/find conversation via REST
const res = await fetch('/api/messages/conversations', {
method: 'POST',
headers: { 'Authorization': `Bearer ${token}`, 'Content-Type': 'application/json' },
body: JSON.stringify({ participantIds: [targetUserId], type: 'direct', text: 'Hello!' })
});
const { conversationId, existing } = await res.json();

// 2. Join the socket room
socket.emit('join_conversation', { conversationId });

// 3. Load history via REST
const history = await fetch(`/api/messages/conversations/${conversationId}?page=1&limit=50`, {
headers: { 'Authorization': `Bearer ${token}` }
});
const { data: messages, meta } = await history.json();
// Render messages, oldest first. Load more pages on scroll-up.

Flow B — Receive Incoming Chat Request

// When not in the conversation, this fires on your personal room
socket.on('new_message_notification', ({ conversationId, senderUserId, message }) => {
showNotificationBanner({
title: `New message from user #${senderUserId}`,
preview: message.text,
onAccept: () => {
socket.emit('join_conversation', { conversationId });
// then load history and render
}
});
});

Flow C — Send a Reply (with Quote)

// ⚠️ IMPORTANT: replyToId is NOT echoed back in message_sent
// You must capture it before sending

let pendingReplyId = null; // set when user clicks "Reply" on a bubble

function sendMessage(text) {
const replyToId = pendingReplyId; // snapshot before clearing
socket.emit('send_message', { conversationId, text, replyToId });
pendingReplyId = null; // clear immediately

     // In message_sent handler, use the snapshotted replyToId
     // NOT data.replyToId (server doesn't return it)

}

socket.on('message_sent', (msg) => {
renderBubble({ ...msg, replyToId: snapshotReplyId }); // use your snapshot
});

socket.on('new_message', (msg) => {
if (msg.senderId === myUserId) return; // skip own echoes
renderBubble(msg); // msg.replyToId IS included for others' messages
});

Flow D — Read Receipts

// Mark conversation as read (call when user opens/focuses the chat)
socket.emit('mark_read', { conversationId });

// Show double-tick (✓✓) on your sent messages and turn them teal when read
socket.on('message_read', ({ conversationId, userId, readAt }) => {
if (userId !== myUserId) {
// The OTHER person read the conversation — update all sent bubbles to show read ticks
markMessagesAsRead(conversationId);
}
});

Flow E — Typing Indicator

let typingTimer = null;

messageInput.addEventListener('input', () => {
socket.emit('typing', { conversationId, isTyping: true });
clearTimeout(typingTimer);
typingTimer = setTimeout(() => {
socket.emit('typing', { conversationId, isTyping: false });
}, 2000); // stop after 2s of no input
});

socket.on('user_typing', ({ conversationId, userId, isTyping }) => {
if (userId === myUserId) return;
showTypingIndicator(userId, isTyping);
});

Flow F — Delete a Message

// Delete for everyone (only sender can do this)
socket.emit('delete_message', { messageId, forEveryone: true });
socket.on('message_deleted', ({ messageId, deletedBy }) => {
replaceBubbleWithDeletedPlaceholder(messageId); // "🗑 This message was deleted"
});

// Delete for me only
socket.emit('delete_message', { messageId, forEveryone: false });
socket.on('delete_confirmed', ({ messageId, deletedForMe }) => {
removeBubble(messageId); // only removes from your view
});

Flow G — Load More Messages (Pagination)

let currentPage = 1;
let isLoadingMore = false;

chatContainer.addEventListener('scroll', async () => {
if (chatContainer.scrollTop < 50 && !isLoadingMore) {
isLoadingMore = true;
currentPage++;
const res = await fetch(`/api/messages/conversations/${convId}?page=${currentPage}&limit=50`, {
headers: { 'Authorization': `Bearer ${token}` }
});
const { data, meta } = await res.json();
prependMessages(data); // prepend older messages at the top
isLoadingMore = false;
if (currentPage >= meta.totalPages) disableScrollLoadMore();
}
});

---

5. User Presence

// Online users at app start
const { onlineUserIds } = await fetch('/api/messages/online-users', {
headers: { 'Authorization': `Bearer ${token}` }
}).then(r => r.json());

// Real-time updates
socket.on('user_status', ({ userId, isOnline, lastSeen }) => {
updatePresenceIndicator(userId, isOnline, lastSeen);
});

---

6. What's Missing Backend-wise

These are the gaps between the current backend and a production-ready chat experience:

🔴 Critical Gaps

┌─────────────────────────┬────────────────────────┬────────────────────────────────────────────────────────────────────────────────────────┐  
 │ Feature │ Impact │ Notes │  
 ├─────────────────────────┼────────────────────────┼────────────────────────────────────────────────────────────────────────────────────────┤  
 │ replyToId not returned │ Reply quotes broken │ sendMessage() service hardcodes parentMessageId = conversationId, never saves the │  
 │ in message_sent │ for sender until │ actual reply target. Fix: add replyToId column to message entity and return it. │  
 │ │ refresh │ │  
 ├─────────────────────────┼────────────────────────┼────────────────────────────────────────────────────────────────────────────────────────┤  
 │ No file upload endpoint │ Can't send │ fileId field exists in the schema but there's no POST /api/files/upload in the │  
 │ │ images/attachments │ messaging module (may exist in a separate Files module — needs wiring) │  
 ├─────────────────────────┼────────────────────────┼────────────────────────────────────────────────────────────────────────────────────────┤  
 │ No message edit │ Can't correct typos │ No PATCH /api/messages/:id or edit_message socket event exists at all │  
 └─────────────────────────┴────────────────────────┴────────────────────────────────────────────────────────────────────────────────────────┘

🟡 UX-Blocking Gaps

┌─────────────────────────────┬────────────────────────────────┬────────────────────────────────────────────────────────────────────────────┐  
 │ Feature │ Impact │ Notes │  
 ├─────────────────────────────┼────────────────────────────────┼────────────────────────────────────────────────────────────────────────────┤  
 │ No conversation search │ Can't find a chat by │ Only lists all conversations; no GET │  
 │ │ participant name │ /api/messages/conversations?search=name │  
 ├─────────────────────────────┼────────────────────────────────┼────────────────────────────────────────────────────────────────────────────┤  
 │ No user search (for DM) │ Can't find who to message by │ GET /api/admin/users/search exists but requires ADMIN role — │  
 │ │ email/name │ students/instructors can't use it │  
 ├─────────────────────────────┼────────────────────────────────┼────────────────────────────────────────────────────────────────────────────┤  
 │ No group member management │ Can't add/remove from groups │ No POST /api/messages/conversations/:id/participants or DELETE equivalent │  
 ├─────────────────────────────┼────────────────────────────────┼────────────────────────────────────────────────────────────────────────────┤  
 │ Conversation-level read │ Can't know which exact │ mark_read marks ALL messages in conv as read; no per-message read tracking │  
 │ only │ messages are unread │ exposed │  
 ├─────────────────────────────┼────────────────────────────────┼────────────────────────────────────────────────────────────────────────────┤  
 │ No message delivery status │ No "delivered" confirmation │ Messages are created as sent; no mechanism to update to delivered when │  
 │ │ │ recipient comes online │  
 ├─────────────────────────────┼────────────────────────────────┼────────────────────────────────────────────────────────────────────────────┤  
 │ Typing indicator doesn't │ Stuck typing bubble if client │ No server-side timeout on typing state; client must explicitly send │  
 │ auto-stop │ disconnects │ isTyping: false │  
 └─────────────────────────────┴────────────────────────────────┴────────────────────────────────────────────────────────────────────────────┘

🟢 Nice-to-Have Gaps

┌───────────────────────────┬────────────────────────────────────────────────────────────────────────────────┐
│ Feature │ Notes │
├───────────────────────────┼────────────────────────────────────────────────────────────────────────────────┤
│ Message reactions │ No emoji reaction system │
├───────────────────────────┼────────────────────────────────────────────────────────────────────────────────┤
│ Message pinning │ No pin/unpin │
├───────────────────────────┼────────────────────────────────────────────────────────────────────────────────┤
│ Mute conversation │ No notification preferences per conversation │
├───────────────────────────┼────────────────────────────────────────────────────────────────────────────────┤
│ Forward message │ No forward capability │
├───────────────────────────┼────────────────────────────────────────────────────────────────────────────────┤
│ Online status privacy │ user_status broadcasts to ALL connected users globally — no privacy controls │
├───────────────────────────┼────────────────────────────────────────────────────────────────────────────────┤
│ Message scheduling │ No sendAt field │
├───────────────────────────┼────────────────────────────────────────────────────────────────────────────────┤
│ @ Mentions │ No mention parsing or notifications │
└───────────────────────────┴────────────────────────────────────────────────────────────────────────────────┘

---

Top 3 Backend Fixes to Prioritize

1.  Fix replyToId — Add a proper replyToId (FK to message.id) on the message entity, save it in sendMessage(), and return it in message_sent.  
    This is 1 migration + ~5 lines of service code.
2.  Open user search to all roles — Add a new GET /api/messages/users/search?query= endpoint that any authenticated user can call (returns {  
    userId, firstName, lastName }[] matching by name or email). Required for "start a new chat" UX.
3.  Add message edit — PATCH /api/messages/:id with { text }, sender-only guard, and a corresponding message_edited socket broadcast.
