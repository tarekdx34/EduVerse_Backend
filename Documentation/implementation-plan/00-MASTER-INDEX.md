# EduVerse Backend Implementation Plan - Master Index

## Overview

This documentation contains the complete implementation plan for building out the EduVerse backend to fully support all 5 frontend dashboards (Admin, Instructor, Student, IT Admin, Teaching Assistant).

---

## Sprint Status Overview

| Sprint | Phases Covered | Status | Notes |
|--------|---------------|--------|-------|
| Sprint 1 | Phase 1 (Core Academic Operations) | ✅ DONE | Assignments, Grades, Quizzes, Attendance, Labs |
| Sprint 2 | Phase 2 (Communication & Collaboration) | ✅ DONE | Notifications, Discussions, Announcements, Chat, Community |
| Sprint 3 | Phase 3-5 (Scheduling, Analytics, Materials) | ✅ DONE | Schedule, Analytics, Reports, Search, Course Materials |
| Sprint 4 | Phase 6-7 (User Management, System Admin) | 🔲 REMAINING | User profiles, settings, system monitoring, backups |
| Sprint 5 | Phase 8-9 (Advanced Features, Tasks) | 🔲 REMAINING | Tasks, Reminders, advanced features |
| Sprint 6 | Phase 10-12 (Gamification, Payments, AI) | 🔲 REMAINING | Gamification, Payments, Certificates, AI (external team) |

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

**Modules delivered:** Assignments, Grades, Quizzes, Attendance, Labs

Sprint 1 established the foundational academic modules. Each module provides full CRUD operations and role-based access for Instructors, TAs, and Students. These modules are individually functional but were built in isolation. They do not yet communicate with each other (e.g., quiz grading does not write to the Grades module).

**Dependency note:** Sprint 1 modules are prerequisites for Analytics (Sprint 3), Tasks (Sprint 5), and Schedule integration (Sprint 3). See [Integration Gaps](#integration-gaps-found-in-done-sprints) below.

### Sprint 2 - Communication & Collaboration ✅

**Modules delivered:** Notifications, Discussions, Announcements, Chat, Community

Sprint 2 delivered all communication channels. The Chat module uses WebSocket for real-time messaging. Notifications infrastructure exists but is not wired to any event producer - no other module calls `NotificationsService` to send notifications on actions like assignment creation or grade posting.

**Dependency note:** Notifications must be integrated as a cross-cutting concern across Sprint 1 and Sprint 3 modules. See [Integration Gaps](#integration-gaps-found-in-done-sprints) below.

### Sprint 3 - Scheduling, Analytics, Materials ✅

**Modules delivered:** Schedule, Analytics, Reports, Search, Course Materials

Sprint 3 introduced the scheduling calendar, analytics dashboards, report generation, search, and course materials. However, these modules operate on their own data stores and do not aggregate from the academic modules delivered in Sprint 1. The Search module maintains its own index but does not index content from other modules.

**Dependency note:** Analytics and Reports need data pipelines from Sprint 1 modules. Schedule needs deadline feeds from Assignments, Quizzes, and Labs.

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
| 6 | User Management & Admin | 2 modules | 🟡 Medium | 🔄 REMAINING | [Phase 8](./phase-08-user-management.md) |
| 7 | System & IT Administration | 4 modules | 🟡 Medium | 🔄 REMAINING | [Phase 9](./phase-09-system-admin.md) |
| 8 | Advanced Features | 7 modules | 🟢 Lower | 🔄 REMAINING | [Phase 11](./phase-11-advanced.md) |
| 9 | Tasks & Reminders | 1 module | 🟢 Lower | 🔄 REMAINING | [Phase 6](./phase-06-gamification.md) |
| 10 | Gamification | 1 module | 🔵 Last | 🔄 REMAINING | [Phase 6](./phase-06-gamification.md) |
| 11 | Payments & Certificates | 2 modules | 🔵 Last | 🔄 REMAINING | [Phase 10](./phase-10-payments.md) |
| 12 | AI Features (External Team) | 1 module | 🔵 Last | 🔄 REMAINING | [Phase 7](./phase-07-ai.md) |

**Total: 32 new modules across 12 phases**

### Sprint-to-Phase Dependency Chain

```
Sprint 1 (Phase 1) ──► Sprint 3 (Phases 3-5) ──► Sprint 4 (Phases 6-7)
    │                       │                          │
    │  Grades, Quizzes,     │  Analytics, Schedule,    │  User profiles need
    │  Labs, Assignments    │  Search depend on        │  enrollment + grade
    │  are prerequisites    │  Sprint 1 data           │  data from Phase 1
    │                       │                          │
    ▼                       ▼                          ▼
Sprint 2 (Phase 2) ──► Sprint 5 (Phases 8-9) ──► Sprint 6 (Phases 10-12)
    │                       │                          │
    │  Notifications,       │  Tasks auto-generate     │  Gamification reads
    │  Discussions,         │  from Sprint 1 deadlines;│  from Grades, Quizzes,
    │  Announcements        │  Advanced features       │  Attendance; AI needs
    │                       │  integrate all modules   │  all prior data
    ▼                       ▼                          ▼
  Notifications must      Tasks (Phase 9) needs      Payments (Phase 11) needs
  be wired into ALL       Assignments, Quizzes,      Enrollments, Courses;
  event-producing         Labs deadline feeds        AI (Phase 12) needs
  modules (Phases 1-5)                               full data access
```

---

## Enhanced Remaining Sprints

### Sprint 4 - User Management & System Admin (Phases 6-7) 🔲

**New connections/APIs identified:**
- User profiles should pull enrollment history from the Enrollments module
- User settings should allow notification preferences (ties to Notifications module)
- System monitoring should track API usage across all existing modules
- Backup system should cover all database tables introduced in Sprints 1-3
- Integration configuration should support Chat WebSocket connections and YouTube API

**Prerequisites from done sprints:** Auth, Campus, Enrollments, Notifications, Chat

### Sprint 5 - Advanced Features & Tasks (Phases 8-9) 🔲

**New connections/APIs identified:**
- Tasks module must expose `POST /tasks/auto-generate` endpoint that reads deadlines from Assignments, Quizzes, and Labs
- Tasks should subscribe to creation events from Assignments, Quizzes, and Labs to auto-generate student task items
- Reminders should integrate with Notifications to deliver deadline alerts
- Advanced features (e.g., office hours, peer review) should integrate with Schedule and Enrollments
- Office hours should create Schedule events and send Notifications on booking

**Prerequisites from done sprints:** Assignments, Quizzes, Labs (Sprint 1), Notifications (Sprint 2), Schedule (Sprint 3)

### Sprint 6 - Gamification, Payments, AI (Phases 10-12) 🔲

**New connections/APIs identified:**
- Gamification should read from Grades, Quizzes, Attendance, and Labs for XP/badge calculations
- Gamification leaderboards should aggregate data via Analytics module
- Payments module needs Enrollments for course fee association and Courses for pricing
- Certificates should verify completion via Grades and Attendance
- AI module (external team) needs read access to all Sprint 1-5 data via standardized query APIs

**Prerequisites from done sprints:** Grades, Quizzes, Attendance, Labs (Sprint 1), Analytics (Sprint 3), Enrollments (existing)

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
