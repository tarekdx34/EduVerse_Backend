# Assigning Instructor / TA to a Course Section (Sprint 4)

## Overview

This document describes the analysis and implementation plan for the admin API that allows assigning or removing an **Instructor** or **Teaching Assistant (TA)** for a specific course section.

---

## Problem Statement

Before this feature, there was no REST API for an admin to directly assign an instructor or TA to a course section.  
The database tables (`course_instructors`, `course_tas`) and entities already existed but had no corresponding service methods or controller endpoints.

---

## Analysis

### Existing Infrastructure

| Component | Location | Status before Sprint 4 |
|-----------|----------|------------------------|
| `course_instructors` table | DB | ✅ Exists |
| `course_tas` table | DB | ✅ Exists |
| `CourseInstructor` entity | `src/modules/enrollments/entities/course-instructor.entity.ts` | ✅ Exists |
| `CourseTA` entity | `src/modules/enrollments/entities/course-ta.entity.ts` | ✅ Exists |
| `EnrollmentsService` repositories | `enrollments.service.ts` lines 58–60 | ✅ Injected, unused |
| Service methods (`assignInstructor`, `assignTA`, …) | `enrollments.service.ts` | ❌ Missing |
| Controller endpoints | `enrollments.controller.ts` | ❌ Missing |

### Entity Schemas

**`course_instructors`**

| Column | Type | Notes |
|--------|------|-------|
| `assignment_id` | bigint PK | Auto-increment |
| `section_id` | bigint FK | References `course_sections` |
| `user_id` | bigint FK | References `users` |
| `role` | enum | `primary`, `co_instructor`, `guest` |
| `assigned_at` | timestamp | Auto-set on insert |

Unique constraint: `(section_id, user_id)` — one assignment per user per section.

**`course_tas`**

| Column | Type | Notes |
|--------|------|-------|
| `assignment_id` | bigint PK | Auto-increment |
| `user_id` | bigint FK | References `users` |
| `section_id` | bigint FK | References `course_sections` |
| `responsibilities` | text | Optional TA duties description |
| `assigned_at` | timestamp | Auto-set on insert |

Unique constraint: `(section_id, user_id)` — one TA assignment per user per section.

---

## Implementation

### New Files

| File | Purpose |
|------|---------|
| `src/modules/enrollments/dto/assign-instructor.dto.ts` | `AssignInstructorDto`, `InstructorAssignmentResponseDto` |
| `src/modules/enrollments/dto/assign-ta.dto.ts` | `AssignTADto`, `TAAssignmentResponseDto` |

### Modified Files

| File | Changes |
|------|---------|
| `src/modules/enrollments/dto/index.ts` | Exported new DTOs |
| `src/modules/enrollments/exceptions/index.ts` | Added 6 new exception classes |
| `src/modules/enrollments/services/enrollments.service.ts` | Added 6 new public methods |
| `src/modules/enrollments/controllers/enrollments.controller.ts` | Added 6 new endpoints |

---

## API Endpoints

All endpoints are under the base path `/api/enrollments` and require JWT Bearer authentication.

### Instructor Assignment

#### Assign Instructor to Section

```
POST /api/enrollments/sections/:sectionId/instructors
```

- **Auth**: Bearer JWT
- **Roles**: `admin`
- **Request Body**:
  ```json
  {
    "userId": 5,
    "role": "primary"
  }
  ```
  - `userId` *(required)* – ID of the user to assign
  - `role` *(optional, default: `primary`)* – `primary` | `co_instructor` | `guest`
- **Success**: `201 Created` → `InstructorAssignmentResponseDto`
- **Errors**: `404` section/user not found, `409` already assigned

#### Remove Instructor from Section

```
DELETE /api/enrollments/sections/:sectionId/instructors/:assignmentId
```

- **Auth**: Bearer JWT
- **Roles**: `admin`
- **Success**: `204 No Content`
- **Errors**: `404` section/assignment not found

#### List Section Instructors

```
GET /api/enrollments/sections/:sectionId/instructors
```

- **Auth**: Bearer JWT
- **Roles**: `admin`, `instructor`
- **Success**: `200 OK` → `InstructorAssignmentResponseDto[]`
- **Errors**: `404` section not found

---

### TA Assignment

#### Assign TA to Section

```
POST /api/enrollments/sections/:sectionId/tas
```

- **Auth**: Bearer JWT
- **Roles**: `admin`
- **Request Body**:
  ```json
  {
    "userId": 7,
    "responsibilities": "Grading assignments, office hours Mon/Wed"
  }
  ```
  - `userId` *(required)* – ID of the user to assign
  - `responsibilities` *(optional)* – free-text description of TA duties
- **Success**: `201 Created` → `TAAssignmentResponseDto`
- **Errors**: `404` section/user not found, `409` already assigned

#### Remove TA from Section

```
DELETE /api/enrollments/sections/:sectionId/tas/:assignmentId
```

- **Auth**: Bearer JWT
- **Roles**: `admin`
- **Success**: `204 No Content`
- **Errors**: `404` section/assignment not found

#### List Section TAs

```
GET /api/enrollments/sections/:sectionId/tas
```

- **Auth**: Bearer JWT
- **Roles**: `admin`, `instructor`
- **Success**: `200 OK` → `TAAssignmentResponseDto[]`
- **Errors**: `404` section not found

---

## Response Shapes

### `InstructorAssignmentResponseDto`

```json
{
  "id": 1,
  "sectionId": 10,
  "userId": 5,
  "role": "primary",
  "assignedAt": "2026-03-11T20:00:00.000Z",
  "firstName": "John",
  "lastName": "Doe",
  "email": "john.doe@example.com"
}
```

### `TAAssignmentResponseDto`

```json
{
  "id": 2,
  "sectionId": 10,
  "userId": 7,
  "responsibilities": "Grading assignments, office hours Mon/Wed",
  "assignedAt": "2026-03-11T20:00:00.000Z",
  "firstName": "Jane",
  "lastName": "Smith",
  "email": "jane.smith@example.com"
}
```

---

## New Exception Classes

| Class | HTTP Status | Message |
|-------|-------------|---------|
| `SectionNotFoundException` | 404 | Section with id {id} not found |
| `UserNotFoundException` | 404 | User with id {id} not found |
| `InstructorAlreadyAssignedException` | 409 | This user is already assigned as an instructor for this section |
| `InstructorAssignmentNotFoundException` | 404 | Instructor assignment not found |
| `TAAlreadyAssignedException` | 409 | This user is already assigned as a Teaching Assistant for this section |
| `TAAssignmentNotFoundException` | 404 | Teaching Assistant assignment not found |

---

## Access Control Summary

| Endpoint | Admin | Instructor | TA | Student |
|----------|-------|------------|----|---------|
| POST sections/:id/instructors | ✅ | ❌ | ❌ | ❌ |
| DELETE sections/:id/instructors/:aid | ✅ | ❌ | ❌ | ❌ |
| GET sections/:id/instructors | ✅ | ✅ | ❌ | ❌ |
| POST sections/:id/tas | ✅ | ❌ | ❌ | ❌ |
| DELETE sections/:id/tas/:aid | ✅ | ❌ | ❌ | ❌ |
| GET sections/:id/tas | ✅ | ✅ | ❌ | ❌ |

---

## Notes

- No database migrations are required — the tables already exist.
- The `TypeORM synchronize: false` setting means the schema is managed manually. No changes needed.
- The existing `buildEnrollmentResponse()` method in `enrollments.service.ts` has the instructor-loading query commented out (`// temporarily disabled`). Once sections consistently have instructors assigned via this API, that code can be re-enabled.
