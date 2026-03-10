# Courses Module - Comprehensive Testing Guide

## Test Coverage

This guide covers all tests for the Course Management System feature.

---

## 1. Unit Tests (jest)

### Courses Controller Tests
**File:** `src/modules/courses/tests/courses.controller.spec.ts`

**Coverage:**
- ✅ GET /api/courses - List with pagination
- ✅ GET /api/courses/:id - Get by ID with prerequisite count
- ✅ POST /api/courses - Create course
- ✅ PATCH /api/courses/:id - Update course
- ✅ DELETE /api/courses/:id - Soft delete
- ✅ GET /api/courses/department/:id - Get by department
- ✅ GET /api/courses/:id/prerequisites - List prerequisites
- ✅ POST /api/courses/:id/prerequisites - Add prerequisite
- ✅ DELETE /api/courses/:id/prerequisites/:id - Remove prerequisite

**Run Tests:**
```bash
npm test -- courses.controller.spec.ts
```

### Course Sections Controller Tests
**File:** `src/modules/courses/tests/course-sections.controller.spec.ts`

**Coverage:**
- ✅ GET /api/sections/course/:id - Get sections by course
- ✅ GET /api/sections/:id - Get section by ID
- ✅ POST /api/sections - Create section
- ✅ PATCH /api/sections/:id - Update section
- ✅ PATCH /api/sections/:id/enrollment - Update enrollment

**Run Tests:**
```bash
npm test -- course-sections.controller.spec.ts
```

### Course Schedules Controller Tests
**File:** `src/modules/courses/tests/course-schedules.controller.spec.ts`

**Coverage:**
- ✅ GET /api/schedules/section/:id - Get schedules by section
- ✅ GET /api/schedules/:id - Get schedule by ID
- ✅ POST /api/schedules/section/:id - Create schedule
- ✅ DELETE /api/schedules/:id - Delete schedule

**Run Tests:**
```bash
npm test -- course-schedules.controller.spec.ts
```

---

## 2. API Testing (Manual with Postman/cURL)

### Test Setup

**1. Start the application:**
```bash
npm run start:dev
```

**2. Base URL:**
```
http://localhost:3000
```

---

## 3. Course Endpoints Testing

### Create Test Data First

Check existing courses and semesters:
```sql
SELECT course_id, course_code, course_name FROM courses;
SELECT semester_id, semester_name FROM semesters;
```

Use the IDs returned in these queries for the following tests.

---

### 3.1 Courses - Create

**Request:**
```bash
POST /api/courses
Content-Type: application/json

{
  "departmentId": 1,
  "name": "Advanced Web Development",
  "code": "WEB301",
  "description": "Learn modern web development with React and Node.js",
  "credits": 4,
  "level": "JUNIOR",
  "syllabusUrl": "https://example.com/syllabus.pdf"
}
```

**Expected Response (201):**
```json
{
  "id": [any_number],
  "departmentId": 1,
  "name": "Advanced Web Development",
  "code": "WEB301",
  "credits": 4,
  "level": "JUNIOR",
  "status": "ACTIVE"
}
```

**Test Cases:**
- ✅ Valid course creation
- ✅ Duplicate course code in same department (should fail with 409)
- ✅ Invalid credits (0 or >6)
- ✅ Non-existent department (should fail with 404)

---

### 3.2 Courses - List with Pagination

**Request:**
```bash
GET /api/courses?page=1&limit=10&level=JUNIOR&status=ACTIVE
```

**Expected Response (200):**
```json
{
  "data": [
    {
      "id": 1,
      "name": "Course Name",
      "code": "CODE",
      "level": "JUNIOR",
      "status": "ACTIVE"
    }
  ],
  "meta": {
    "total": 5,
    "page": 1,
    "limit": 10,
    "totalPages": 1
  }
}
```

**Test Cases:**
- ✅ Default pagination
- ✅ Filter by department
- ✅ Filter by level
- ✅ Filter by status
- ✅ Search by name or code
- ✅ Pagination with multiple pages

---

### 3.3 Courses - Get by ID

**Request:**
```bash
GET /api/courses/1
```

**Expected Response (200):**
```json
{
  "id": 1,
  "name": "Course Name",
  "code": "CODE",
  "departmentId": 1,
  "credits": 3,
  "level": "SOPHOMORE",
  "status": "ACTIVE",
  "prerequisitesCount": 1,
  "sectionsCount": 2
}
```

**Test Cases:**
- ✅ Valid course ID
- ✅ Non-existent course (should return 404)
- ✅ Soft-deleted course (should return 404)

---

### 3.4 Courses - Update (PATCH)

**Request:**
```bash
PATCH /api/courses/1
Content-Type: application/json

{
  "name": "Updated Course Name",
  "credits": 4
}
```

**Expected Response (200):**
```json
{
  "id": 1,
  "name": "Updated Course Name",
  "credits": 4
}
```

**Test Cases:**
- ✅ Update single field
- ✅ Update multiple fields
- ✅ Update with invalid data
- ✅ Non-existent course (should return 404)

---

### 3.5 Courses - Delete (Soft Delete)

**Request:**
```bash
DELETE /api/courses/1
```

**Expected Response (204 No Content):**
```
(Empty response body)
```

**Test Cases:**
- ✅ Delete course without active sections
- ✅ Delete course with active sections (should fail with 400)
- ✅ Delete already deleted course (should return 404)

**Verification:**
```sql
-- Check if soft deleted
SELECT course_id, deleted_at FROM courses WHERE course_id = 1;
-- Should show deleted_at timestamp

-- Verify API returns 404
GET /api/courses/1 → 404 Not Found
```

---

### 3.6 Courses - Get by Department

**Request:**
```bash
GET /api/courses/department/1
```

**Expected Response (200):**
```json
[
  {
    "id": 1,
    "name": "Course 1",
    "code": "CODE1",
    "departmentId": 1
  },
  {
    "id": 2,
    "name": "Course 2",
    "code": "CODE2",
    "departmentId": 1
  }
]
```

**Test Cases:**
- ✅ Valid department with courses
- ✅ Department with no courses (empty array)
- ✅ Non-existent department (should return empty or 404)

---

## 4. Prerequisites Endpoints Testing

### 4.1 Add Prerequisite

**Request:**
```bash
POST /api/courses/1/prerequisites
Content-Type: application/json

{
  "prerequisiteCourseId": 5,
  "isMandatory": true
}
```

**Expected Response (201):**
```json
{
  "id": 1,
  "courseId": 1,
  "prerequisiteCourseId": 5,
  "isMandatory": true,
  "prerequisiteCourse": {
    "id": 5,
    "name": "Programming Fundamentals",
    "code": "CS105"
  }
}
```

**Test Cases:**
- ✅ Add mandatory prerequisite
- ✅ Add optional prerequisite
- ✅ Circular dependency (should fail with 400)
- ✅ Self-prerequisite (should fail with 400)
- ✅ Non-existent course (should fail with 404)

---

### 4.2 Get Prerequisites

**Request:**
```bash
GET /api/courses/1/prerequisites
```

**Expected Response (200):**
```json
[
  {
    "id": 1,
    "courseId": 1,
    "prerequisiteCourseId": 5,
    "isMandatory": true,
    "prerequisiteCourse": {
      "id": 5,
      "name": "Programming Fundamentals",
      "code": "CS105"
    }
  }
]
```

**Test Cases:**
- ✅ Course with prerequisites
- ✅ Course without prerequisites (empty array)

---

### 4.3 Remove Prerequisite

**Request:**
```bash
DELETE /api/courses/1/prerequisites/1
```

**Expected Response (204 No Content):**
```
(Empty response body)
```

**Test Cases:**
- ✅ Valid prerequisite removal
- ✅ Non-existent prerequisite (should fail with 404)

---

## 5. Sections Endpoints Testing

### 5.1 Create Section

**Request:**
```bash
POST /api/sections
Content-Type: application/json

{
  "courseId": 1,
  "semesterId": 4,
  "sectionNumber": 1,
  "maxCapacity": 40,
  "currentEnrollment": 0,
  "location": "Building A, Room 101"
}
```

**Expected Response (201):**
```json
{
  "id": 1,
  "courseId": 1,
  "semesterId": 4,
  "sectionNumber": "1",
  "maxCapacity": 40,
  "currentEnrollment": 0,
  "location": "Building A, Room 101",
  "status": "OPEN"
}
```

**Test Cases:**
- ✅ Create valid section
- ✅ Auto-calculate status based on enrollment
- ✅ Non-existent course (should fail)
- ✅ Non-existent semester (should fail)

---

### 5.2 Get Sections by Course

**Request:**
```bash
GET /api/sections/course/1?semesterId=4
```

**Expected Response (200):**
```json
[
  {
    "id": 1,
    "courseId": 1,
    "semesterId": 4,
    "sectionNumber": "1",
    "maxCapacity": 40,
    "currentEnrollment": 25,
    "location": "Building A, Room 101",
    "status": "OPEN",
    "schedules": []
  }
]
```

**Test Cases:**
- ✅ Get all sections for course
- ✅ Filter by semester
- ✅ Course with no sections (empty array)

---

### 5.3 Update Enrollment

**Request:**
```bash
PATCH /api/sections/1/enrollment
Content-Type: application/json

{
  "currentEnrollment": 35
}
```

**Expected Response (200):**
```json
{
  "id": 1,
  "currentEnrollment": 35,
  "status": "OPEN"
}
```

**Test Cases:**
- ✅ Valid enrollment update
- ✅ Auto-set status to FULL when enrollment equals capacity
- ✅ Enrollment exceeds capacity (should fail or auto-set FULL)
- ✅ Negative enrollment (should fail)

---

## 6. Schedules Endpoints Testing

### 6.1 Create Schedule

**Request:**
```bash
POST /api/schedules/section/1
Content-Type: application/json

{
  "dayOfWeek": "MONDAY",
  "startTime": "10:00",
  "endTime": "11:30",
  "room": "101",
  "building": "Building A",
  "scheduleType": "LECTURE"
}
```

**Expected Response (201):**
```json
{
  "id": 1,
  "sectionId": 1,
  "dayOfWeek": "MONDAY",
  "startTime": "10:00",
  "endTime": "11:30",
  "room": "101",
  "building": "Building A",
  "scheduleType": "LECTURE"
}
```

**Test Cases:**
- ✅ Valid schedule creation
- ✅ Invalid time range (end before start) - should fail
- ✅ Schedule conflict detection - should fail
- ✅ Non-existent section - should fail with 404

---

### 6.2 Get Schedules by Section

**Request:**
```bash
GET /api/schedules/section/1
```

**Expected Response (200):**
```json
[
  {
    "id": 1,
    "sectionId": 1,
    "dayOfWeek": "MONDAY",
    "startTime": "10:00",
    "endTime": "11:30",
    "room": "101",
    "building": "Building A",
    "scheduleType": "LECTURE"
  }
]
```

**Test Cases:**
- ✅ Section with schedules
- ✅ Section without schedules (empty array)

---

### 6.3 Delete Schedule

**Request:**
```bash
DELETE /api/schedules/1
```

**Expected Response (204 No Content):**
```
(Empty response body)
```

**Test Cases:**
- ✅ Valid schedule deletion
- ✅ Non-existent schedule (should fail with 404)

---

## 7. Error Scenarios

All endpoints should handle these errors correctly:

| Error | Status | Scenario |
|-------|--------|----------|
| Course not found | 404 | GET/PATCH/DELETE non-existent course |
| Duplicate course code | 409 | POST same code in same department |
| Active sections exist | 400 | DELETE course with active sections |
| Circular prerequisite | 400 | Add prerequisite that creates cycle |
| Schedule conflict | 400 | Create schedule with time overlap |
| Enrollment exceeds capacity | 400 | Update enrollment > max_capacity |
| Invalid time range | 400 | Schedule end_time < start_time |

---

## 8. Run All Tests

```bash
# Run all unit tests
npm test

# Run with coverage
npm test -- --coverage

# Run specific test file
npm test -- courses.controller.spec.ts

# Run in watch mode
npm test -- --watch
```

---

## 9. Validation Checklist

- ✅ All CRUD operations work
- ✅ Pagination works correctly
- ✅ Filtering works
- ✅ Soft delete works
- ✅ Prerequisite circular dependency detection works
- ✅ Schedule conflict detection works
- ✅ Enrollment capacity validation works
- ✅ All error scenarios return correct HTTP status codes
- ✅ All relationships between tables work (foreign keys)
- ✅ Soft-deleted records are excluded from queries
