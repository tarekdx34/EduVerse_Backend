# Community System Restructure — Feature Summary

> **Date:** June 2025
> **Scope:** Community module refactored from course-only scoping to a three-tier hierarchy.

---

## 1. Overview

The community module was restructured from course-only scoping to a three-tier hierarchy:

| Tier | Scope | Access |
|------|-------|--------|
| **Global Community** | Platform-wide (community\_id = 1) | All authenticated users |
| **Department Communities** | Per-department, multiple allowed | Restricted by enrollment chain |
| **Course Discussions** | Per-course Q&A threads | Enrolled students + admin/instructor bypass |

Global and department communities use the `/api/community` endpoints. Course discussions use the separate `/api/discussions` endpoints and support Q&A features (pin, lock, mark-as-answer, endorse).

---

## 2. Architecture

```
Platform
├── Global Community (community_id = 1, always exists)
│   └── Posts (+ comments, reactions, tags)
├── Department Communities (restricted by enrollment chain)
│   ├── "Math Cohort 2026" → Posts
│   ├── "CS General"       → Posts
│   └── ... (N communities per department)
└── Courses
    └── Discussions (Q&A threads + replies)
        ├── Pin / Lock
        ├── Mark as Answer
        └── Endorse
```

### Enrollment Chain (Department Access)

```
User → Enrollment → Section → Course → Department
```

A user can access a department community only if they are enrolled in at least one course within that department. Admins, instructors, and TAs bypass this check.

---

## 3. API Endpoints

### Community Endpoints (`/api/community`)

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| `GET` | `/api/community/communities` | Any | List accessible communities |
| `POST` | `/api/community/communities` | Admin / Instructor / DeptHead | Create community |
| `GET` | `/api/community/communities/:id` | Any (access checked) | Get single community |
| `PUT` | `/api/community/communities/:id` | Admin / Owner | Update community |
| `GET` | `/api/community/communities/:id/posts` | Any (access checked) | List posts in community |
| `POST` | `/api/community/communities/:id/posts` | Any (access checked) | Create post in community |
| `GET` | `/api/community/global` | Any | List global posts (supports `?tag=`) |
| `POST` | `/api/community/global/posts` | Any | Create global post |
| `GET` | `/api/community/department/:id` | Enrolled / Admin | List dept communities |
| `GET` | `/api/community/my-departments` | Any | User's department IDs |
| `GET` | `/api/community/tags` | Any | List all tags |
| `POST` | `/api/community/tags` | Admin / Instructor / TA | Create tag |

### Discussion Endpoints (`/api/discussions`)

Existing Q&A endpoints remain unchanged. Enrollment guard added to restrict access to enrolled students, with admin/instructor bypass.

---

## 4. Access Control Rules

| Scope | Rule |
|-------|------|
| **Global** | Any authenticated user can read and post |
| **Department** | Only users enrolled in courses within that department (via `enrollment → section → course → department` chain). Admins, instructors, and TAs bypass. |
| **Discussions** | Only enrolled students in the course + admin/instructor bypass |

---

## 5. Database Changes

### New Tables

#### `communities`

| Column | Type | Notes |
|--------|------|-------|
| `id` | INT (PK, AI) | |
| `name` | VARCHAR(255) | e.g. "Global Community", "CS General" |
| `description` | TEXT | Nullable |
| `scope` | ENUM('global', 'department') | |
| `department_id` | INT (FK → departments) | Nullable, set for department-scoped |
| `created_by` | INT (FK → users) | |
| `created_at` | TIMESTAMP | |
| `updated_at` | TIMESTAMP | |

#### `community_tags`

| Column | Type | Notes |
|--------|------|-------|
| `id` | INT (PK, AI) | |
| `name` | VARCHAR(100) | Unique |

#### `community_post_tags` (join table)

| Column | Type | Notes |
|--------|------|-------|
| `post_id` | INT (FK → community\_posts) | Composite PK |
| `tag_id` | INT (FK → community\_tags) | Composite PK |

### Modified Tables

#### `community_posts`

| Change | Details |
|--------|---------|
| Added `community_id` | FK → `communities`, NOT NULL |
| Made `course_id` | Nullable (no longer required) |

### Seed Data

```sql
-- Global community (always id = 1)
INSERT INTO communities (id, name, description, scope, department_id, created_by)
VALUES (1, 'Global Community', 'Open to all authenticated users', 'global', NULL, 1);
```

---

## 6. Files Created

| File | Purpose |
|------|---------|
| `src/modules/community/entities/community.entity.ts` | Community container entity |
| `src/modules/community/entities/community-tag.entity.ts` | Tag entity |
| `src/modules/community/services/communities.service.ts` | CRUD + access control for communities |
| `src/modules/community/services/community-tags.service.ts` | Tag management |
| `src/modules/community/controllers/communities.controller.ts` | All `/api/community` routes |
| `src/modules/community/dto/create-community.dto.ts` | Create community validation |
| `src/modules/community/dto/update-community.dto.ts` | Update community validation |
| `src/modules/community/dto/community-query.dto.ts` | Query/filter params |
| `src/modules/community/dto/create-tag.dto.ts` | Create tag validation |

---

## 7. Files Modified

| File | Changes |
|------|---------|
| `src/modules/community/entities/community-post.entity.ts` | Added `communityId` FK, `tags` ManyToMany relation |
| `src/modules/community/entities/index.ts` | Added new entity exports |
| `src/modules/community/dto/create-post.dto.ts` | `courseId` → `communityId` + `tags` field |
| `src/modules/community/dto/post-query.dto.ts` | `courseId` → `communityId` + `tag` filter |
| `src/modules/community/dto/index.ts` | Added new DTO exports |
| `src/modules/community/services/community-posts.service.ts` | Filter by `communityId` + tag handling |
| `src/modules/community/services/index.ts` | Added new service exports |
| `src/modules/community/controllers/index.ts` | Added new controller export |
| `src/modules/community/community.module.ts` | Registered new entities, controllers, services |
| `src/modules/discussions/services/discussions.service.ts` | Added enrollment guard |
| `src/modules/discussions/controllers/discussions.controller.ts` | Pass `userId` / `roles` to service |

---

## 8. Testing Results

All endpoints tested and passing:

| Test | Result |
|------|--------|
| List communities (student) | ✅ Shows global + enrolled depts only |
| Create community (admin) | ✅ Created "Math Cohort 2026" |
| Access guard (non-enrolled dept) | ✅ Returns empty / 403 |
| Global posts | ✅ Paginated with tags |
| Create post with tags | ✅ Auto-creates missing tags |
| Filter by tag | ✅ Works with `?tag=` |
| Update community | ✅ Admin can update |
| Discussion enrollment guard | ✅ Blocks non-enrolled, allows enrolled |
| Admin bypass | ✅ Admin can access all |

---

## 9. Key Design Decisions

1. **Communities are container entities** — posts belong to `community_id`, not directly to a scope. This keeps the data model flat and extensible.

2. **Global community is always id = 1** — seeded on first migration. Convenience routes (`/api/community/global`) hardcode this ID.

3. **Multiple communities per department** — e.g., "CS Cohort 2026", "CS General". A department is not a community; it can have many.

4. **Courses use Q&A Discussions only** — no community posts inside courses. Course-level interaction goes through `/api/discussions`.

5. **Tags auto-created on post creation** — when a post includes tags that don't exist yet, they are created inline. No separate creation step required for end users.

6. **Direct SQL for schema changes** — the project uses `synchronize: false`, so all schema changes are applied via raw SQL migrations rather than TypeORM auto-sync.

---

## 10. Example Requests

### Create a Department Community

```bash
POST /api/community/communities
Authorization: Bearer <admin_token>
Content-Type: application/json

{
  "name": "CS Cohort 2026",
  "description": "Community for the 2026 CS cohort",
  "scope": "department",
  "departmentId": 3
}
```

### Create a Post with Tags

```bash
POST /api/community/communities/1/posts
Authorization: Bearer <user_token>
Content-Type: application/json

{
  "content": "Welcome to the global community!",
  "tags": ["announcement", "welcome"]
}
```

### Filter Global Posts by Tag

```bash
GET /api/community/global?tag=announcement&page=1&limit=10
Authorization: Bearer <user_token>
```

---

*This document serves as both a retroactive feature summary and a template for future feature documentation.*
