# Course Management System - API Endpoints Documentation

## Overview
Complete API endpoints for the Course Management System feature including course creation, prerequisites, sections, and schedules.

---

## Course Management Endpoints

### 1. GET /api/courses
**List all courses with pagination and filters**

**Query Parameters:**
- `departmentId` (optional): Filter by department ID
- `level` (optional): Filter by course level (FRESHMAN, SOPHOMORE, JUNIOR, SENIOR, GRADUATE)
- `status` (optional): Filter by status (ACTIVE, INACTIVE, ARCHIVED)
- `search` (optional): Search by course name or code
- `page` (optional, default: 1): Page number
- `limit` (optional, default: 20): Items per page

**Example Request:**
```bash
GET /api/courses?departmentId=1&level=SOPHOMORE&page=1&limit=20
```

**Example Response (200 OK):**
```json
{
  "data": [
    {
      "id": 1,
      "departmentId": 1,
      "name": "Data Structures",
      "code": "CS201",
      "description": "Study of data structures and algorithms",
      "credits": 3,
      "level": "SOPHOMORE",
      "syllabusUrl": "https://example.com/syllabus.pdf",
      "status": "ACTIVE",
      "createdAt": "2025-11-27T10:00:00Z",
      "updatedAt": "2025-11-27T10:00:00Z"
    }
  ],
  "meta": {
    "total": 1,
    "page": 1,
    "limit": 20,
    "totalPages": 1
  }
}
```

---

### 2. POST /api/courses
**Create a new course**

**Request Body:**
```json
{
  "departmentId": 1,
  "name": "Advanced Data Structures and Algorithms",
  "code": "CS2024",
  "description": "Study of advanced data structures and algorithm optimization techniques",
  "credits": 4,
  "level": "JUNIOR",
  "syllabusUrl": "https://example.com/syllabus-advanced.pdf"
}
```

**Example Response (201 Created):**
```json
{
  "id": 42,
  "departmentId": 1,
  "name": "Advanced Data Structures and Algorithms",
  "code": "CS2024",
  "description": "Study of advanced data structures and algorithm optimization techniques",
  "credits": 4,
  "level": "JUNIOR",
  "syllabusUrl": "https://example.com/syllabus-advanced.pdf",
  "status": "ACTIVE",
  "createdAt": "2025-11-27T17:46:00Z",
  "updatedAt": "2025-11-27T17:46:00Z"
}
```

**Error Response (409 Conflict):**
```json
{
  "statusCode": 409,
  "message": "Course code 'CS201' already exists in department 1",
  "error": "Conflict"
}
```

---

### 3. GET /api/courses/:id
**Get course details with prerequisites and sections count**

**Example Request:**
```bash
GET /api/courses/1
```

**Example Response (200 OK):**
```json
{
  "id": 1,
  "departmentId": 1,
  "name": "Data Structures",
  "code": "CS201",
  "description": "Study of data structures and algorithms",
  "credits": 3,
  "level": "SOPHOMORE",
  "syllabusUrl": "https://example.com/syllabus.pdf",
  "status": "ACTIVE",
  "createdAt": "2025-11-27T10:00:00Z",
  "updatedAt": "2025-11-27T10:00:00Z",
  "department": {
    "id": 1,
    "name": "Computer Science",
    "code": "CS"
  },
  "prerequisitesCount": 1,
  "sectionsCount": 2
}
```

**Error Response (404 Not Found):**
```json
{
  "statusCode": 404,
  "message": "Course with ID 999 not found",
  "error": "Not Found"
}
```

---

### 4. PATCH /api/courses/:id
**Update course details**

**Request Body (all fields optional):**
```json
{
  "name": "Data Structures and Algorithms",
  "description": "Advanced study of data structures and algorithms",
  "credits": 4,
  "level": "JUNIOR",
  "syllabusUrl": "https://example.com/new_syllabus.pdf",
  "status": "ACTIVE"
}
```

**Example Response (200 OK):**
```json
{
  "id": 1,
  "departmentId": 1,
  "name": "Data Structures and Algorithms",
  "code": "CS201",
  "description": "Advanced study of data structures and algorithms",
  "credits": 4,
  "level": "JUNIOR",
  "syllabusUrl": "https://example.com/new_syllabus.pdf",
  "status": "ACTIVE",
  "createdAt": "2025-11-27T10:00:00Z",
  "updatedAt": "2025-11-27T12:00:00Z"
}
```

---

### 5. DELETE /api/courses/:id
**Soft delete a course (cannot delete if active sections exist)**

**Example Request:**
```bash
DELETE /api/courses/1
```

**Response (204 No Content):**
```
(Empty response body)
```

**Error Response (400 Bad Request):**
```json
{
  "statusCode": 400,
  "message": "Cannot delete course 1. Active sections exist",
  "error": "Bad Request"
}
```

---

### 6. GET /api/courses/department/:deptId
**Get all courses in a specific department**

**Example Request:**
```bash
GET /api/courses/department/1
```

**Example Response (200 OK):**
```json
[
  {
    "id": 1,
    "departmentId": 1,
    "name": "Data Structures",
    "code": "CS201",
    "description": "Study of data structures and algorithms",
    "credits": 3,
    "level": "SOPHOMORE",
    "syllabusUrl": "https://example.com/syllabus.pdf",
    "status": "ACTIVE",
    "createdAt": "2025-11-27T10:00:00Z",
    "updatedAt": "2025-11-27T10:00:00Z",
    "department": {
      "id": 1,
      "name": "Computer Science",
      "code": "CS"
    }
  }
]
```

---

## Prerequisite Management Endpoints

### 7. GET /api/courses/:id/prerequisites
**Get all prerequisites for a course**

**Example Request:**
```bash
GET /api/courses/1/prerequisites
```

**Example Response (200 OK):**
```json
[
  {
    "id": 1,
    "courseId": 1,
    "prerequisiteCourseId": 2,
    "isMandatory": true,
    "prerequisiteCourse": {
      "id": 2,
      "name": "Introduction to Programming",
      "code": "CS101",
      "level": "FRESHMAN"
    },
    "createdAt": "2025-11-27T10:00:00Z"
  }
]
```

---

### 8. POST /api/courses/:id/prerequisites
**Add a prerequisite to a course**

**Note:** Use courseId from an existing non-conflicting course. Example assumes course 42 exists.

**Request Body:**
```json
{
  "prerequisiteCourseId": 5,
  "isMandatory": true
}
```

**Example Response (201 Created):**
```json
{
  "id": 15,
  "courseId": 42,
  "prerequisiteCourseId": 5,
  "isMandatory": true,
  "prerequisiteCourse": {
    "id": 5,
    "name": "Programming Fundamentals",
    "code": "CS105",
    "level": "FRESHMAN"
  },
  "createdAt": "2025-11-27T17:46:00Z"
}
```

**Error Response (400 Bad Request - Circular Dependency):**
```json
{
  "statusCode": 400,
  "message": "Circular dependency detected: Course 1 cannot have 3 as prerequisite",
  "error": "Bad Request"
}
```

---

### 9. DELETE /api/courses/:id/prerequisites/:prereqId
**Remove a prerequisite from a course**

**Example Request:**
```bash
DELETE /api/courses/1/prerequisites/1
```

**Response (204 No Content):**
```
(Empty response body)
```

---

## Section Management Endpoints

### 10. POST /api/sections
**Create a new course section**

**Request Body:**
```json
{
  "courseId": 42,
  "semesterId": 3,
  "sectionNumber": 2,
  "maxCapacity": 45,
  "currentEnrollment": 0,
  "location": "Building B, Room 215"
}
```

**Example Response (201 Created):**
```json
{
  "id": 88,
  "courseId": 42,
  "semesterId": 3,
  "sectionNumber": "2",
  "maxCapacity": 45,
  "currentEnrollment": 0,
  "location": "Building B, Room 215",
  "status": "OPEN",
  "createdAt": "2025-11-27T17:46:00Z",
  "updatedAt": "2025-11-27T17:46:00Z"
}
```

---

### 11. GET /api/sections/course/:courseId
**Get all sections for a course**

**Query Parameters:**
- `semesterId` (optional): Filter by semester

**Example Request:**
```bash
GET /api/sections/course/42?semesterId=3
```

**Example Response (200 OK):**
```json
[
  {
    "id": 88,
    "courseId": 42,
    "semesterId": 3,
    "sectionNumber": "2",
    "maxCapacity": 45,
    "currentEnrollment": 18,
    "location": "Building B, Room 215",
    "status": "OPEN",
    "createdAt": "2025-11-27T17:46:00Z",
    "updatedAt": "2025-11-27T17:46:00Z",
    "course": {
      "id": 42,
      "name": "Advanced Data Structures and Algorithms",
      "code": "CS2024"
    },
    "semester": {
      "id": 3,
      "name": "Spring 2025",
      "startDate": "2025-01-15T00:00:00Z",
      "endDate": "2025-05-15T00:00:00Z"
    },
    "schedules": [
      {
        "id": 103,
        "dayOfWeek": "TUESDAY",
        "startTime": "09:00",
        "endTime": "10:30",
        "room": "215",
        "building": "Building B",
        "scheduleType": "LECTURE"
      }
    ]
  }
]
```

---

### 12. GET /api/sections/:id
**Get section details**

**Example Request:**
```bash
GET /api/sections/88
```

**Example Response (200 OK):**
```json
{
  "id": 88,
  "courseId": 42,
  "semesterId": 3,
  "sectionNumber": "2",
  "maxCapacity": 45,
  "currentEnrollment": 18,
  "location": "Building B, Room 215",
  "status": "OPEN",
  "createdAt": "2025-11-27T17:46:00Z",
  "updatedAt": "2025-11-27T17:46:00Z",
  "course": {
    "id": 42,
    "name": "Advanced Data Structures and Algorithms",
    "code": "CS2024"
  },
  "semester": {
    "id": 3,
    "name": "Spring 2025",
    "startDate": "2025-01-15T00:00:00Z",
    "endDate": "2025-05-15T00:00:00Z"
  },
  "schedules": []
}
```

---

### 13. PATCH /api/sections/:id
**Update section details**

**Example Request:**
```bash
PATCH /api/sections/88
```

**Request Body (all fields optional):**
```json
{
  "maxCapacity": 50,
  "currentEnrollment": 22,
  "location": "Building C, Room 320",
  "status": "OPEN"
}
```

**Example Response (200 OK):**
```json
{
  "id": 88,
  "courseId": 42,
  "semesterId": 3,
  "sectionNumber": "2",
  "maxCapacity": 50,
  "currentEnrollment": 22,
  "location": "Building C, Room 320",
  "status": "OPEN",
  "createdAt": "2025-11-27T17:46:00Z",
  "updatedAt": "2025-11-27T18:00:00Z"
}
```

---

### 14. PATCH /api/sections/:id/enrollment
**Update current enrollment count**

**Example Request:**
```bash
PATCH /api/sections/88/enrollment
```

**Request Body:**
```json
{
  "currentEnrollment": 35
}
```

**Example Response (200 OK):**
```json
{
  "id": 88,
  "courseId": 42,
  "semesterId": 3,
  "sectionNumber": "2",
  "maxCapacity": 50,
  "currentEnrollment": 35,
  "location": "Building C, Room 320",
  "status": "OPEN",
  "createdAt": "2025-11-27T17:46:00Z",
  "updatedAt": "2025-11-27T18:05:00Z"
}
```

**Error Response (400 Bad Request - Section Full):**
```json
{
  "statusCode": 400,
  "message": "Section 1 is full and cannot accept more enrollments",
  "error": "Bad Request"
}
```

---

## Schedule Management Endpoints

### 15. POST /api/schedules/section/:sectionId
**Create a class schedule for a section**

**Example Request:**
```bash
POST /api/schedules/section/88
```

**Request Body:**
```json
{
  "dayOfWeek": "TUESDAY",
  "startTime": "14:00",
  "endTime": "15:30",
  "room": "320",
  "building": "Building C",
  "scheduleType": "LECTURE"
}
```

**Example Response (201 Created):**
```json
{
  "id": 156,
  "sectionId": 88,
  "dayOfWeek": "TUESDAY",
  "startTime": "14:00",
  "endTime": "15:30",
  "room": "320",
  "building": "Building C",
  "scheduleType": "LECTURE",
  "createdAt": "2025-11-27T17:46:00Z"
}
```

**Error Response (400 Bad Request - Time Conflict):**
```json
{
  "statusCode": 400,
  "message": "Schedule conflict: Time conflict on MONDAY in Building A 101",
  "error": "Bad Request"
}
```

**Error Response (400 Bad Request - Invalid Time):**
```json
{
  "statusCode": 400,
  "message": "Invalid time range: end time must be after start time",
  "error": "Bad Request"
}
```

---

### 16. GET /api/schedules/section/:sectionId
**Get all schedules for a section**

**Example Request:**
```bash
GET /api/schedules/section/88
```

**Example Response (200 OK):**
```json
[
  {
    "id": 156,
    "sectionId": 88,
    "dayOfWeek": "TUESDAY",
    "startTime": "14:00",
    "endTime": "15:30",
    "room": "320",
    "building": "Building C",
    "scheduleType": "LECTURE",
    "createdAt": "2025-11-27T17:46:00Z"
  },
  {
    "id": 157,
    "sectionId": 88,
    "dayOfWeek": "THURSDAY",
    "startTime": "14:00",
    "endTime": "16:00",
    "room": "321",
    "building": "Building C",
    "scheduleType": "LAB",
    "createdAt": "2025-11-27T17:47:00Z"
  }
]
```

---

### 17. GET /api/schedules/:id
**Get schedule details**

**Example Request:**
```bash
GET /api/schedules/156
```

**Example Response (200 OK):**
```json
{
  "id": 156,
  "sectionId": 88,
  "dayOfWeek": "TUESDAY",
  "startTime": "14:00",
  "endTime": "15:30",
  "room": "320",
  "building": "Building C",
  "scheduleType": "LECTURE",
  "createdAt": "2025-11-27T17:46:00Z",
  "section": {
    "id": 88,
    "courseId": 42,
    "semesterId": 3,
    "sectionNumber": "2",
    "maxCapacity": 50,
    "currentEnrollment": 35,
    "location": "Building C, Room 320",
    "status": "OPEN",
    "createdAt": "2025-11-27T17:46:00Z",
    "updatedAt": "2025-11-27T18:05:00Z"
  }
}
```

---

### 18. DELETE /api/schedules/:id
**Delete a schedule**

**Example Request:**
```bash
DELETE /api/schedules/156
```

**Response (204 No Content):**
```
(Empty response body)
```

---

## Testing Workflow Example

Follow this workflow to test without database conflicts:

1. **Create Course (POST /api/courses)**
   - Use code: `CS2024` (not in database)
   - Department: 1 (must exist)
   - Response ID: Use this for next steps

2. **Add Prerequisite (POST /api/courses/:id/prerequisites)**
   - Use prerequisiteCourseId: 5 (must exist in database)
   - courseId: from step 1

3. **Create Section (POST /api/sections)**
   - courseId: from step 1
   - semesterId: 3 (must exist in database)
   - sectionNumber: 2 (unique per course per semester)

4. **Add Schedule (POST /api/schedules/section/:sectionId)**
   - sectionId: from step 3
   - dayOfWeek: TUESDAY
   - startTime: 14:00
   - endTime: 15:30
   - room: 320
   - building: Building C (avoid conflicts)

5. **Update Section (PATCH /api/sections/:id)**
   - sectionId: from step 3
   - Update enrollment or location

6. **Get Details**
   - Use IDs from created resources
   - All returned data will match your created test data

---

## Common Status Codes

| Code | Meaning |
|------|---------|
| 200 | OK - Successful request |
| 201 | Created - Resource successfully created |
| 204 | No Content - Successful deletion/update with no response body |
| 400 | Bad Request - Invalid request parameters or business logic violation |
| 404 | Not Found - Resource not found |
| 409 | Conflict - Resource already exists (e.g., duplicate course code) |
| 500 | Internal Server Error - Server-side error |

---

## Enum Values

### Course Level
- FRESHMAN
- SOPHOMORE
- JUNIOR
- SENIOR
- GRADUATE

### Course Status
- ACTIVE
- INACTIVE
- ARCHIVED

### Section Status
- OPEN
- CLOSED
- FULL
- CANCELLED

### Schedule Type
- LECTURE
- LAB
- TUTORIAL
- EXAM

### Day of Week
- MONDAY
- TUESDAY
- WEDNESDAY
- THURSDAY
- FRIDAY
- SATURDAY
- SUNDAY

---

## Testing Notes

1. **Use Non-Conflicting Data**: All examples use IDs (42, 88, 156) and codes (CS2024) that won't conflict with existing database records. Replace with actual IDs from your database if needed.

2. **Circular Prerequisite Detection**: Create Course A → Course B → Course C, then try to add Course C as prerequisite to Course A. Should fail with circular dependency error.

3. **Schedule Conflict Detection**: Create two schedules for the same room on the same day with overlapping times. Should fail with conflict error.

4. **Section Capacity**: Try to update enrollment to exceed max capacity. Should either fail or automatically set status to FULL.

5. **Soft Delete**: Delete a course with active sections. Should fail. Archive or close all sections first, then delete.

6. **Pagination**: Test page and limit parameters to ensure proper pagination in course listings.

7. **Prerequisite Course Validation**: Ensure prerequisiteCourseId exists in database before adding.

8. **Department/Semester Validation**: Verify departmentId and semesterId exist before creating courses and sections.
