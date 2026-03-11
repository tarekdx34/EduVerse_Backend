# EduVerse Backend Implementation Plan - Master Index

## Overview

This documentation contains the complete implementation plan for building out the EduVerse backend to fully support all 5 frontend dashboards (Admin, Instructor, Student, IT Admin, Teaching Assistant).

---

## Sprint Status Overview

| Sprint | Focus Area | Dev A | Dev B | Dev C | Status |
|--------|-----------|-------|-------|-------|--------|
| Sprint 1 | Core Academic | Assignments + Grades | Attendance + Quizzes | Labs + Notifications | ✅ DONE |
| Sprint 2 | Communication + Content | Messaging + Discussions | Announcements + Community | Schedule + Course Materials | ✅ DONE |
| Sprint 3 | Analytics + Admin | Analytics + Reports | User Mgmt + Roles & Permissions | Tasks & Reminders + Search | ✅ DONE |
| Sprint 4 | System & IT + Advanced | Security & Audit + System Settings | Monitoring + Backup | Study Groups + Office Hours + Peer Review | 🔲 REMAINING |
| Sprint 5 | Advanced (continued) | Live Sessions + Localization | Support & Feedback + Certificates | Voice & Transcription | 🔲 REMAINING |
| Sprint 6 | Last Priority | Gamification | Payments | AI Integration (external team) | 🔲 REMAINING |

---

## Current Backend State

### Completed Modules ✅
| Module | Description | Tables Covered |
|--------|-------------|----------------|
| Auth | Login, register, JWT, roles, permissions, sessions, password reset, email verification, 2FA | users, user_roles, sessions, login_attempts, email_verifications, password_resets, two_factor_auth |
| Campus | Multi-campus, departments, programs, semesters | campuses, departments, programs, semesters |
| Courses | Course catalog, sections, schedules, prerequisites | courses, course_sections, course_schedules, course_prerequisites |
| Enrollments | Student enrollment, grades, drops, retakes, instructor/TA assignments | course_enrollments, course_instructors, course_tas |
| Files | Upload, download, versioning, permissions, folders | files, file_versions, folders, file_permissions |
| Email | Nodemailer for verification/reset emails | (no tables) |
| YouTube | Video upload/management via Google API | (no tables) |
| Assignments | Create, submit, grade assignments | assignments, assignment_submissions |
| Grades | Grade records, GPA calculation | grades |
| Quizzes | Quiz creation, questions, attempts, grading | quizzes, quiz_questions, quiz_attempts |
| Attendance | Session tracking, student attendance records | attendance_sessions, attendance_records |
| Labs | Lab creation, submissions, grading | labs, lab_submissions |
| Notifications | Notification creation, delivery, read status | notifications |
| Discussions | Threaded discussions per course | discussions, discussion_replies |
| Announcements | Course/section announcements | announcements |
| Chat | Real-time messaging (WebSocket) | chat_messages, chat_rooms |
| Community | Community posts, comments, reactions | community_posts, community_comments |
| Schedule | Calendar events, course schedules | schedule_events |
| Analytics | Dashboard analytics, metrics | analytics_data |
| Reports | Report generation | reports |
| Search | Full-text search index | search_index |
| Course Materials | Lecture materials, resources | course_materials |

### Technology Stack
- **Framework**: NestJS v11
- **ORM**: TypeORM v0.3
- **Database**: MySQL/MariaDB
- **Auth**: JWT (passport-jwt)
- **Validation**: class-validator + class-transformer
- **API Docs**: Swagger/OpenAPI
- **Email**: Nodemailer

### Database
- **137 tables + 2 views** defined in `eduverse_db.sql`
- Most tables lack corresponding backend modules

---

## Frontend Dashboards Requiring Backend Support

| Dashboard | Components | Priority Features |
|-----------|------------|-------------------|
| Admin | 26 components | User/course/department management, analytics, enrollment periods, payments, security |
| Instructor | 40 components | Course detail, assignments, grades, quizzes, attendance, labs, discussions, materials |
| Student | 28 components | Enrolled courses, assignments, grades, quizzes, schedule, messaging, gamification, AI |
| IT Admin | 19 components | System monitoring, security, backups, database, integrations, multi-campus |
| TA | 20 components | Grading, attendance, quizzes, labs, discussions, office hours, materials |

---

## Sprint Analysis (Completed Sprints)

### Sprint 1 - Core Academic Operations ✅

**Modules delivered:** Assignments (10 endpoints), Grades (11 endpoints), Attendance (21 endpoints), Quizzes (19 endpoints), Labs (13 endpoints), Notifications (9 endpoints)

**Dev A** built Assignments + Grades, **Dev B** built Attendance + Quizzes, **Dev C** built Labs + Notifications.

Sprint 1 established the foundational academic modules. Each module provides full CRUD operations and role-based access for Instructors, TAs, and Students. Attendance module stands out with Excel import/export and AI-powered face recognition. Quizzes support auto-grading for MCQ/True-False. The Notifications module was also built in this sprint but is isolated — no other module calls `NotificationsService`.

**Dependency note:** Sprint 1 modules are prerequisites for Analytics (Sprint 3) and Schedule integration (Sprint 2). See [Integration Gaps](#integration-gaps-found-in-done-sprints) below.

### Sprint 2 - Communication & Content ✅

**Modules delivered:** Messaging (12 endpoints), Discussions (10 endpoints), Announcements (9 endpoints), Community (25 endpoints), Schedule (14 endpoints), Course Materials (18 endpoints)

**Dev A** built Messaging + Discussions, **Dev B** built Announcements + Community, **Dev C** built Schedule (Enhanced) + Course Materials.

Sprint 2 delivered all communication channels and content management. The Messaging module uses WebSocket via Socket.IO for real-time messaging. Community has rich features including posts, comments, reactions, forum categories, and tags. Course Materials integrates with YouTube for video uploads. Schedule supports exam conflict detection and external calendar integrations.

**Dependency note:** Schedule should pull deadline data from Sprint 1 modules (Assignments, Quizzes, Labs) but this integration is not yet wired. See [Integration Gaps](#integration-gaps-found-in-done-sprints) below.

### Sprint 3 - Analytics & Administration ✅

**Modules delivered:** Analytics (11 endpoints), Reports (6 endpoints), User Management Enhanced (in Auth module), Roles & Permissions Enhanced (in Auth module), Tasks & Reminders (10 endpoints), Search (6 endpoints)

**Dev A** built Analytics + Reports, **Dev B** enhanced User Management + Roles & Permissions, **Dev C** built Tasks & Reminders + Search.

Sprint 3 introduced analytics dashboards, report generation, task management, and search. However, Analytics and Reports operate on their own data stores and do not aggregate from academic modules delivered in Sprint 1. The Search module maintains its own index but does not index content from Assignments, Quizzes, Labs, Discussions, or Announcements. Tasks module supports manual task creation but does not auto-generate tasks from assignment/quiz/lab deadlines.

**Dependency note:** Analytics and Reports need data pipelines from Sprint 1 modules. Tasks need auto-generation from Sprint 1 deadlines. Search needs to index content from Sprints 1-2.

---

## Integration Gaps Found in Done Sprints

> ⚠️ **Critical:** The following integration gaps were identified across Sprints 1-3. These modules are individually functional but do not communicate with each other as required for a complete system. These gaps should be addressed as integration tasks before or during Sprint 4.

| # | Gap | Modules Involved | Impact |
|---|-----|-----------------|--------|
| 1 | **NotificationsService is isolated** - built but **no other module calls it** | Notifications ↔ All modules | Users receive no notifications for any academic or communication events |
| 2 | **Analytics doesn't aggregate data** - doesn't pull from Assignments, Grades, Attendance, Quizzes, or Labs | Analytics ↔ Sprint 1 modules | Dashboard analytics show no real academic data |
| 3 | **Reports module has no data sources** - doesn't integrate with Analytics or any data source module | Reports ↔ Analytics, Sprint 1 modules | Reports cannot be generated with meaningful content |
| 4 | **Tasks module doesn't auto-generate** - no auto-creation of tasks from assignment/quiz/lab deadlines | Tasks ↔ Assignments, Quizzes, Labs | Students must manually create tasks for every deadline |
| 5 | **Search index is siloed** - doesn't index Assignments, Quizzes, Labs, Discussions, or Announcements | Search ↔ Sprint 1 & 2 modules | Search results are incomplete; users cannot find academic content |
| 6 | **Quiz grading doesn't create Grade records** - quiz scores stay within the Quizzes module | Quizzes → Grades | Quiz scores are not reflected in student grade books |
| 7 | **Lab grading doesn't create Grade records** - lab scores stay within the Labs module | Labs → Grades | Lab scores are not reflected in student grade books |
| 8 | **Schedule doesn't pull deadlines** - no integration with assignment/quiz/lab due dates | Schedule ↔ Assignments, Quizzes, Labs | Calendar doesn't show upcoming academic deadlines |
| 9 | **Discussions/Announcements don't trigger notifications** - posting creates no notification | Discussions, Announcements → Notifications | Users are unaware of new posts or announcements unless they manually check |

### Recommended Resolution Priority

1. **High:** Gaps 1, 6, 7 (notifications wiring, grade record creation from quizzes/labs)
2. **High:** Gaps 8, 9 (schedule deadline sync, discussion/announcement notifications)
3. **Medium:** Gaps 2, 3 (analytics aggregation, reports data sources)
4. **Medium:** Gaps 4, 5 (task auto-generation, search indexing expansion)

---

## Implementation Phases (Revised Priority Order)

> **Note**: Gamification, Payments, and AI are moved to last phases per team decision. AI will be integrated by a separate team.

| Phase | Title | Modules | Priority | Status | Doc File |
|-------|-------|---------|----------|--------|----------|
| 1 | Core Academic Operations | 5 modules | 🔴 Critical | ✅ DONE | [Phase 1](./phase-01-core-academic.md) |
| 2 | Communication & Collaboration | 5 modules | 🟠 High | ✅ DONE | [Phase 2](./phase-02-communication.md) |
| 3 | Scheduling & Calendar | 1 module | 🟠 High | ✅ DONE | [Phase 3](./phase-03-scheduling.md) |
| 4 | Analytics & Reporting | 2 modules | 🟡 Medium | ✅ DONE | [Phase 4](./phase-04-analytics.md) |
| 5 | Course Content & Materials | 1 module | 🟡 Medium | ✅ DONE | [Phase 5](./phase-05-materials.md) |
| 6 | User Management & Admin | 2 modules | 🟡 Medium | 🔲 REMAINING | [Phase 8](./phase-08-user-management.md) |
| 7 | System & IT Administration | 4 modules | 🟡 Medium | 🔲 REMAINING | [Phase 9](./phase-09-system-admin.md) |
| 8 | Advanced Features | 7 modules | 🟢 Lower | 🔲 REMAINING | [Phase 11](./phase-11-advanced.md) |
| 9 | Tasks & Reminders | 1 module | 🟢 Lower | 🔲 REMAINING | [Phase 6](./phase-06-gamification.md) |
| 10 | Gamification | 1 module | 🔵 Last | 🔲 REMAINING | [Phase 6](./phase-06-gamification.md) |
| 11 | Payments & Certificates | 2 modules | 🔵 Last | 🔲 REMAINING | [Phase 10](./phase-10-payments.md) |
| 12 | AI Features (External Team) | 1 module | 🔵 Last | 🔲 REMAINING | [Phase 7](./phase-07-ai.md) |

**Total: 32 new modules across 12 phases**

### Sprint-to-Phase Dependency Chain

```
Sprint 1 (Core Academic) ──────────────────────────────────────┐
  ├── Dev A: Assignments + Grades                               │
  ├── Dev B: Attendance + Quizzes                               │
  ├── Dev C: Labs + Notifications                               │
  │                                                             │
  │  Provides: academic data + notification infrastructure      │
  ▼                                                             │
Sprint 2 (Communication + Content) ────────────────────────────┤
  ├── Dev A: Messaging + Discussions                            │
  ├── Dev B: Announcements + Community                          │
  ├── Dev C: Schedule + Course Materials                        │
  │                                                             │
  │  Provides: communication channels + content management      │
  ▼                                                             │
Sprint 3 (Analytics + Admin) ──────────────────────────────────┤
  ├── Dev A: Analytics + Reports  ← needs Sprint 1 data        │
  ├── Dev B: User Mgmt + Roles   ← extends Auth module         │
  ├── Dev C: Tasks + Search       ← needs Sprint 1 deadlines   │
  │                                                             │
  │  Provides: analytics, admin tools, search, task management  │
  ▼                                                             │
Sprint 4 (System & IT + Advanced) ─────────────────────────────┤
  ├── Dev A: Security & Audit + System Settings                 │
  ├── Dev B: Monitoring + Backup                                │
  ├── Dev C: Study Groups + Office Hours + Peer Review          │
  │                                                             │
  │  Provides: IT admin tools, advanced academic features       │
  ▼                                                             │
Sprint 5 (Advanced continued) ─────────────────────────────────┤
  ├── Dev A: Live Sessions + Localization                       │
  ├── Dev B: Support & Feedback + Certificates                  │
  ├── Dev C: Voice & Transcription                              │
  │                                                             │
  │  Provides: live classes, multi-language, certificates       │
  ▼                                                             │
Sprint 6 (Last Priority) ─────────────────────────────────────┘
  ├── Dev A: Gamification         ← needs Sprint 1-3 data
  ├── Dev B: Payments             ← needs Enrollments, Courses
  └── Dev C: AI Integration       ← external team, needs all data
```

---

## Enhanced Remaining Sprints

### Sprint 4 - System & IT Administration (Phase 9 + Phase 11 partial) 🔲

**Dev A:** Security & Audit + System Settings | **Dev B:** Monitoring + Backup | **Dev C:** Study Groups + Office Hours + Peer Review

**New connections/APIs identified:**
- Security & Audit must log events from Auth module (login, logout, password changes, failed attempts)
- Audit trail should capture academic data changes (grade changes, assignment updates, quiz modifications)
- System settings should store configurable values used by existing modules (AI_ATTENDANCE_SERVICE_URL, YouTube API keys)
- Monitoring should track API usage and WebSocket connection health across all modules
- Backup system must cover all 137+ database tables including all tables introduced in Sprints 1-3
- Study Groups must verify enrollment (students must be in the same course)
- Study Groups, Office Hours, and Peer Review must all integrate with Notifications
- Office Hours must integrate with Schedule (create calendar events for slots)
- Peer Review must link to Assignments and feed scores into Grades

**Prerequisites from done sprints:** Auth, Campus, Enrollments, Notifications, Messaging, Schedule, Assignments, Grades

### Sprint 5 - Advanced Features (Phase 11 continued) 🔲

**Dev A:** Live Sessions + Localization | **Dev B:** Support & Feedback + Certificates | **Dev C:** Voice & Transcription

**New connections/APIs identified:**
- Live Sessions must integrate with Schedule (create calendar events), Notifications (notify on session start/schedule), Course Materials (store recordings as materials via YouTube), and Attendance (auto-mark attendance for participants)
- Localization (TranslationService) must be injectable into all Sprint 1-3 modules that have translatable content
- Support Tickets must integrate with Notifications (notify staff on new ticket, notify user on response)
- Certificates must verify course completion via Grades (all assignments graded, minimum GPA met) and Enrollments (enrollment status 'completed')
- Certificates must integrate with Notifications (notify student when certificate is generated)
- Voice Transcription should store transcriptions as supplementary Course Materials

**Prerequisites from done sprints:** Assignments, Quizzes, Labs (Sprint 1), Notifications (Sprint 1), Schedule (Sprint 2), Course Materials (Sprint 2), Grades (Sprint 1)

### Sprint 6 - Gamification, Payments, AI (Phase 6, 10, 7) 🔲

**Dev A:** Gamification | **Dev B:** Payments | **Dev C:** AI Integration Interfaces (external team)

**New connections/APIs identified:**
- Gamification must read from Grades, Quizzes, Attendance, Labs, and Community for XP/badge calculations
- Gamification should expose `GamificationService` for other modules to call `awardXP()` on events
- Gamification leaderboards should aggregate data via Analytics module
- Gamification must integrate with Notifications (notify on badge earned, level up)
- Payments module needs Enrollments for course fee association and Courses for pricing
- Payments should block enrollment if payment is pending; release on payment completion
- Payments must integrate with Notifications (notify on payment due, success, refund)
- Certificates (Sprint 5) may require payment verification before generation
- AI module needs read access to Course Materials (for summarization), Quizzes (for generation), Assignments (for AI grading), and Grades (for writing AI grades)
- AI must integrate with Notifications (notify when AI task completes)
- AI should integrate with Search (index AI-generated content)

**Prerequisites from done sprints:** Grades, Quizzes, Attendance, Labs (Sprint 1), Analytics (Sprint 3), Community (Sprint 2), Enrollments, Courses (existing)

---

## Developer Assignment (3-Developer Parallel Plan)

See **[Developer Assignment & Sprint Plan](./developer-assignment.md)** for the complete breakdown of how all phases are distributed across 3 developers working in parallel.

---

## Architecture Pattern

Every module follows the standard NestJS pattern:

```
module-name/
├── module-name.module.ts          # Module definition
├── entities/
│   └── entity-name.entity.ts      # TypeORM entities
├── dto/
│   ├── create-entity.dto.ts       # Create DTOs with validation
│   ├── update-entity.dto.ts       # Update DTOs (PartialType)
│   └── entity-response.dto.ts     # Response DTOs
├── enums/
│   └── entity-status.enum.ts      # Enumerations
├── controllers/
│   └── entity.controller.ts       # REST controllers
├── services/
│   └── entity.service.ts          # Business logic
└── exceptions/
    └── entity-not-found.exception.ts  # Custom exceptions
```

---

## Cross-Cutting Concerns

### Authentication & Authorization
- All endpoints require JWT authentication (`@UseGuards(JwtAuthGuard)`)
- Role-based access via `@Roles()` decorator
- Roles: `STUDENT`, `INSTRUCTOR`, `TA`, `ADMIN`, `IT_ADMIN`

### Pagination
```typescript
interface PaginatedResponse<T> {
  data: T[];
  meta: {
    total: number;
    page: number;
    limit: number;
    totalPages: number;
  };
}
```

### Error Handling
- Custom exceptions extending `HttpException`
- Consistent error response format
- Proper HTTP status codes

### API Response Format
```typescript
// Success
{ data: T, message: string }

// Error
{ statusCode: number, message: string, error: string }

// Paginated
{ data: T[], meta: { total, page, limit, totalPages } }
```

### Localization (Arabic + English)
- All user-facing content supports **Arabic (ar)** and **English (en)**
- Uses centralized `content_translations` table (not separate columns)
- API endpoints accept `Accept-Language` header (`ar` or `en`, default: `en`)
- Entities with translatable fields: courses, assignments, quizzes, announcements, materials, labs, notifications, calendar events
- Non-translatable entities: grades, attendance records, enrollments, files, payments, logs, analytics
- See [Developer Assignment](./developer-assignment.md) for full localization implementation pattern
