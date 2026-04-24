# EduVerse Notification System Updated Frontend Guide

This guide reflects the current backend notification wiring as of April 24, 2026.

## Realtime Transport

- Namespace: `/notifications`
- Transport: Socket.IO
- Delivery model: notifications are stored in the database and also pushed in realtime
- Realtime events:
  - `newNotification`
  - `unreadCountUpdate`

Example connection:

```ts
import { io } from 'socket.io-client';

const socket = io('http://localhost:3000/notifications', {
  transports: ['websocket'],
  query: {
    userId: currentUser.userId,
  },
});
```

## REST Endpoints

- `GET /api/notifications`
- `GET /api/notifications/unread-count`
- `PATCH /api/notifications/:id/read`
- `PATCH /api/notifications/read-all`
- `DELETE /api/notifications/:id`
- `DELETE /api/notifications`
- `DELETE /api/notifications/read`

## Notification Payload

```json
{
  "id": 123,
  "userId": 45,
  "notificationType": "assignment",
  "title": "New Assignment Posted",
  "body": "A new assignment was posted in your course.",
  "relatedEntityType": "assignment",
  "relatedEntityId": 88,
  "priority": "medium",
  "actionUrl": "/courses/10/assignments/88",
  "isRead": false,
  "readAt": null,
  "createdAt": "2026-04-24T10:30:00.000Z"
}
```

## Notification Types

- `announcement`
- `grade`
- `assignment`
- `message`
- `deadline`
- `system`
- `lab`
- `quiz`
- `material`
- `community`
- `discussion`
- `enrollment`
- `schedule`
- `office_hours`

## Priority Levels

- `low`
- `medium`
- `high`
- `urgent`

## Action URL Patterns

- `announcement`: `/announcements` or course-specific announcement routes
- `grade`: `/grades`
- `assignment`: `/courses/:courseId/assignments/:assignmentId`
- `lab`: `/courses/:courseId/labs/:labId`
- `quiz`: `/courses/:courseId/quizzes/:quizId`
- `material`: `/courses/:courseId/materials`
- `community`: `/community`
- `discussion`: `/courses/:courseId/discussions/:threadId`
- `enrollment`: `/courses/:courseId`
- `schedule`: `/schedule`, `/exams/schedule/:examId`, or `/campus-events/:eventId`
- `office_hours`: office-hours routes already used in the frontend
- `system`: feature-specific routes such as `/profile/security`, `/admin/security`, `/admin/backup`, `/admin/monitoring/alerts`

## Current Trigger Map

### Student-facing

- Assignment published
- Assignment graded
- Assignment deadline reminder
- Lab published
- Lab graded
- Lab deadline reminder
- Quiz published
- Quiz auto-graded result ready
- Quiz closing reminder
- Grade published
- Bulk grade published
- New material uploaded
- Announcement published
- Discussion reply received
- Reply marked as answer
- Reply endorsed
- Reply upvoted
- Community comment/reply/reaction
- Enrollment confirmation
- Course drop confirmation
- Exam scheduled
- Exam schedule updated
- Exam tomorrow reminder
- Campus event registration confirmation
- Campus event reminder
- Attendance explicitly marked absent
- Password changed confirmation
- Office hours notifications
- Peer review assignment / feedback notifications

### Instructor and TA-facing

- Assignment submission received
- Lab submission received
- Daily teaching reminder
- Pending assignment grading reminder
- Pending lab grading reminder
- New discussion thread created in their course
- Teaching assignment notification
- TA assignment notification
- Announcement notifications already wired where targeted
- Office hours notifications

### IT Admin-facing

- Backup completed
- Backup failed
- High/urgent operational alert configured
- High/critical security event logged

## Recommended Notification Center Filters

- All
- Unread
- Announcements
- Academic
- Grades
- Discussions
- Community
- Schedule
- System

Suggested academic group:

- `assignment`
- `lab`
- `quiz`
- `grade`
- `deadline`
- `material`
- `enrollment`

## Badge Logic

- Initial page load:
  - call `GET /api/notifications/unread-count`
- Notification list page:
  - call `GET /api/notifications?page=1&limit=20`
- When `newNotification` arrives:
  - prepend it to the local list if the active filters match
  - increment unread count locally if the item is unread
- When `unreadCountUpdate` arrives:
  - treat the server value as the source of truth
- When user marks one item read:
  - optimistic UI is okay, but keep the websocket/server unread count authoritative
- When user marks all as read:
  - clear local unread badges immediately after success

## Realtime UX Recommendations

- Show a toast for `high` and `urgent` notifications by default
- Suppress toasts for `low` notifications if the user is already on the related page
- Prefer `actionUrl` from the payload rather than rebuilding routes on the client
- Keep websocket connection alive for authenticated sessions only
- Re-fetch the first notification page on reconnect if the app may have missed events

## Notes

- Bulk backend sends still arrive to each user as their own individual notification row and realtime event
- Scheduled reminders use idempotent backend scheduling, so the frontend should not expect duplicate reminders for the same reminder window
- Delivery in this implementation is in-app plus realtime only; email delivery is not part of this pass
