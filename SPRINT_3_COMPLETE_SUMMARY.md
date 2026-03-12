# SPRINT 3 COMPREHENSIVE SUMMARY - EduVerse Backend

## Overview
**Sprint Name**: Sprint 3: Analytics + Administration
**Priority Level**: 🟡 MEDIUM
**Goal**: Build analytics, user management enhancements, and utility features.
**Prerequisite**: Sprint 1 data must exist (assignments, grades, attendance) for meaningful analytics.

---

## SPRINT 3 TEAM ALLOCATION

### Three Developers, Three Task Tracks:

| Developer | Modules | Focus Area |
|-----------|---------|-----------|
| **Dev A** | Analytics + Reports | Data aggregation and reporting |
| **Dev B** | User Management (Enhanced) + Roles & Permissions | Admin functionality |
| **Dev C** | Tasks & Reminders + Search | Utility features |

---

## DEV A: ANALYTICS MODULE + REPORTS MODULE

### Analytics Module Overview
- **Reference**: Phase 4 - Section 4.1
- **Priority**: MEDIUM (depends on Sprint 1 data)

#### Database Tables
- course_analytics - Course-level metrics
- learning_analytics - Learning progress metrics
- performance_metrics - Performance data
- student_progress - Student progress tracking
- weak_topics_analysis - Topic performance analysis
- ctivity_logs - User activity tracking

#### Key Endpoints (11 total)

| HTTP Method | Endpoint | Description | Accessible By |
|-------------|----------|-------------|----------------|
| GET | /api/analytics/dashboard | Dashboard overview stats | ALL |
| GET | /api/analytics/courses/:courseId | Course-level analytics | INSTRUCTOR, TA, ADMIN |
| GET | /api/analytics/students/:studentId | Student analytics | STUDENT, INSTRUCTOR, ADMIN |
| GET | /api/analytics/performance | Performance trends (time series) | ALL |
| GET | /api/analytics/engagement | Engagement metrics | INSTRUCTOR, ADMIN |
| GET | /api/analytics/attendance-trends | Attendance analytics | INSTRUCTOR, ADMIN |
| GET | /api/analytics/at-risk-students | At-risk student identification | INSTRUCTOR, ADMIN |
| GET | /api/analytics/grade-distribution | Grade distribution data | INSTRUCTOR, ADMIN |
| GET | /api/analytics/enrollment-trends | Enrollment analytics | ADMIN |
| GET | /api/analytics/course-comparison | Compare courses | ADMIN |
| GET | /api/analytics/weak-topics/:courseId | Weak topics analysis | INSTRUCTOR, TA |

#### Business Logic
1. **Real-time Aggregation**: Compile data from grades, attendance, submissions
2. **Periodic Snapshots**: Generate cron job snapshots for historical trends
3. **At-Risk Detection**: Algorithm identifies students with:
   - Low attendance + Low grades + Missing submissions
4. **Role-Based Dashboards**:
   - STUDENT sees own analytics
   - INSTRUCTOR sees course-level analytics
   - ADMIN sees system-wide analytics
5. **Data Export**: JSON format for frontend chart rendering

---

### Reports Module Overview

#### Database Tables
- generated_reports - Report records
- eport_templates - Template definitions
- xport_history - Export tracking

#### Key Endpoints (6 total)

| HTTP Method | Endpoint | Description | Accessible By |
|-------------|----------|-------------|----------------|
| GET | /api/reports/templates | List report templates | INSTRUCTOR, ADMIN |
| POST | /api/reports/generate | Generate report | INSTRUCTOR, ADMIN |
| GET | /api/reports/:id | Get report status/details | INSTRUCTOR, ADMIN |
| GET | /api/reports/:id/download | Download report (PDF/CSV/Excel) | INSTRUCTOR, ADMIN |
| GET | /api/reports/history | Export history | INSTRUCTOR, ADMIN |
| DELETE | /api/reports/:id | Delete report | INSTRUCTOR, ADMIN |

#### Business Logic
1. **Report Types**: attendance, grades, enrollment, performance, financial
2. **Template-Based**: Use predefined templates for generation
3. **Export Formats**: PDF, CSV, Excel
4. **Async Generation**: Queue system for large reports
5. **Report Storage**: Store for re-download capability

---

## DEV B: USER MANAGEMENT (ENHANCED) + ROLES & PERMISSIONS

### User Management Module (Enhanced)

#### Overview
**Note**: Builds on existing Auth module basic user management with enhancements

#### Enhancements
- Advanced user search and filtering
- Bulk user operations (import, status change)
- User profile enhancements (avatar, bio, social links)
- User preferences (language, theme, notification settings)
- User activity tracking

#### Key Additional Endpoints (9 total)

| HTTP Method | Endpoint | Description | Accessible By |
|-------------|----------|-------------|----------------|
| POST | /api/admin/users/bulk-import | Import users from CSV | ADMIN, IT_ADMIN |
| POST | /api/admin/users/bulk-status | Bulk status change | ADMIN, IT_ADMIN |
| GET | /api/users/profile | Get current user profile (full) | ALL |
| PUT | /api/users/profile | Update profile (avatar, bio) | ALL |
| GET | /api/users/preferences | Get user preferences | ALL |
| PUT | /api/users/preferences | Update preferences | ALL |
| PATCH | /api/users/password | Change password | ALL |
| GET | /api/admin/users/statistics | User registration stats | ADMIN, IT_ADMIN |
| GET | /api/admin/users/export | Export user list | ADMIN, IT_ADMIN |

#### Business Logic
1. **CSV Import**: Load users with validation and error reporting
2. **Profile Completeness**: Track profile completion status
3. **User Preferences**: Store language, theme, notification settings in DB
4. **Extend Auth Module**: Build on existing UserManagementController

---

### Roles & Permissions Module (Enhanced)

#### Overview
**Note**: Enhances existing Auth module's role system

#### Enhancements
- Custom role creation
- Fine-grained permission management
- Permission inheritance
- Role-based dashboard configuration

#### Key Additional Endpoints (4 total)

| HTTP Method | Endpoint | Description | Accessible By |
|-------------|----------|-------------|----------------|
| GET | /api/admin/roles/with-users | Roles with user counts | ADMIN, IT_ADMIN |
| POST | /api/admin/roles/custom | Create custom role | IT_ADMIN |
| PUT | /api/admin/roles/:id/permissions/bulk | Bulk permission update | IT_ADMIN |
| GET | /api/admin/permissions/matrix | Permission matrix view | ADMIN, IT_ADMIN |

---

## DEV C: TASKS & REMINDERS MODULE + SEARCH MODULE

### Tasks & Reminders Module

#### Database Tables
- student_tasks - Task definitions
- 	ask_completion - Task completion tracking
- deadline_reminders - Reminder records

#### Key Endpoints (9 total)

| HTTP Method | Endpoint | Description | Accessible By |
|-------------|----------|-------------|----------------|
| GET | /api/tasks | List user's tasks | ALL |
| POST | /api/tasks | Create task | ALL |
| PATCH | /api/tasks/:id | Update task | ALL |
| PATCH | /api/tasks/:id/complete | Mark task complete | ALL |
| DELETE | /api/tasks/:id | Delete task | ALL |
| GET | /api/tasks/upcoming | Upcoming tasks/deadlines | ALL |
| GET | /api/reminders | Get active reminders | ALL |
| POST | /api/reminders | Create reminder | ALL |
| DELETE | /api/reminders/:id | Delete reminder | ALL |

#### Business Logic
1. **Auto-Generate Tasks**: From assignments/quizzes deadlines
2. **Priority Levels**: HIGH, MEDIUM, LOW
3. **Due Date Tracking**: Monitor deadlines
4. **Notifications**: Integrate with Notifications module for reminders
5. **Recurring Tasks**: Support repeated tasks

---

### Search Module

#### Database Tables
- search_history - Search history records
- search_index - Search index

#### Key Endpoints (6 total)

| HTTP Method | Endpoint | Description | Accessible By |
|-------------|----------|-------------|----------------|
| GET | /api/search | Global search across entities | ALL |
| GET | /api/search/courses | Search courses | ALL |
| GET | /api/search/users | Search users | ADMIN, INSTRUCTOR |
| GET | /api/search/materials | Search materials | ALL |
| GET | /api/search/history | Search history | ALL |
| DELETE | /api/search/history | Clear search history | ALL |

#### Business Logic
1. **Full-Text Search**: Across courses, materials, discussions, announcements
2. **Role-Based Filtering**: Results vary by user role
3. **Search History**: Per-user tracking
4. **Autocomplete**: Suggestion support
5. **MySQL FULLTEXT**: Use FULLTEXT indexes for performance

---

## SPRINT 3 TOTALS

- **Total Endpoints**: 33 new API endpoints
- **Total Database Tables**: 17 new tables
- **Module Count**: 6 modules (Analytics, Reports, User Management, Roles & Permissions, Tasks & Reminders, Search)
- **Team**: 3 developers working in parallel
- **Duration**: Estimated 2-3 weeks
- **Key Dependency**: Sprint 1 completion (for meaningful analytics data)

---

## KEY NOTES FOR IMPLEMENTATION

1. **Dev A (Analytics)**: 
   - Must wait for Sprint 1 data (grades, attendance, assignments)
   - Focus on aggregation logic and cron jobs
   - Build reusable calculation functions

2. **Dev B (User Management & Roles)**:
   - Extends existing Auth module
   - Can start in parallel with Sprint 1
   - Test CSV import thoroughly

3. **Dev C (Tasks & Search)**:
   - Tasks can auto-generate from Sprint 1 data
   - Search needs data from multiple modules
   - Implement MySQL FULLTEXT indexes

---

## CROSS-SPRINT DEPENDENCIES

Sprint 3 depends on:
- ✅ Sprint 1: Assignments, Grades, Attendance (for analytics)
- ✅ Sprint 2: Communications (for search indexing)
- ✅ Phase 1: Auth module (for user/role enhancements)

Sprint 3 enables:
- Sprint 4: Admin dashboards
- Sprint 5: Advanced features
- Subsequent phases: All features using analytics and user management

