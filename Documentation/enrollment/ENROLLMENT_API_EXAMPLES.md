# Course Enrollment API Examples

## Authentication Header (All Requests)
```
Authorization: Bearer <jwt_token>
Content-Type: application/json
```

## 1. Student Endpoints

### 1.1 Get My Enrolled Courses
```bash
GET /api/enrollments/my-courses

# With semester filter
GET /api/enrollments/my-courses?semester=2

Response 200 OK:
[
  {
    "id": 1,
    "userId": 5,
    "courseId": 10,
    "sectionId": 15,
    "status": "enrolled",
    "grade": null,
    "finalScore": null,
    "enrollmentDate": "2025-01-15T10:30:00Z",
    "droppedAt": null,
    "completedAt": null,
    "canDrop": true,
    "dropDeadline": "2025-03-15T23:59:59Z",
    "course": {
      "id": 10,
      "name": "Data Structures",
      "code": "CS201",
      "description": "Study of data structures and algorithms",
      "credits": 3,
      "level": "SOPHOMORE"
    },
    "section": {
      "id": 15,
      "sectionNumber": "A",
      "maxCapacity": 30,
      "currentEnrollment": 28,
      "location": "Building A, Room 101"
    },
    "semester": {
      "id": 2,
      "name": "Spring 2025",
      "startDate": "2025-01-13T00:00:00Z",
      "endDate": "2025-05-09T23:59:59Z"
    },
    "instructor": {
      "id": 3,
      "firstName": "John",
      "lastName": "Smith",
      "email": "john.smith@university.edu"
    },
    "prerequisites": [
      {
        "id": 1,
        "courseId": 10,
        "prerequisiteCourseId": 5,
        "courseCode": "CS101",
        "courseName": "Introduction to Programming",
        "isMandatory": true,
        "studentCompleted": true,
        "studentGrade": "A-"
      }
    ]
  }
]
```

### 1.2 Discover Available Courses
```bash
# Basic search
GET /api/enrollments/available?search=CS&page=1&limit=20

# By department and semester
GET /api/enrollments/available?departmentId=1&semesterId=2&level=JUNIOR

# With all filters
GET /api/enrollments/available?departmentId=1&semesterId=2&search=Algorithm&level=SOPHOMORE&page=1&limit=10

Response 200 OK:
[
  {
    "id": 20,
    "name": "Algorithms",
    "code": "CS301",
    "description": "Design and analysis of algorithms",
    "credits": 4,
    "level": "JUNIOR",
    "departmentId": 1,
    "departmentName": "Computer Science",
    "sections": [
      {
        "id": 25,
        "sectionNumber": "A",
        "maxCapacity": 30,
        "currentEnrollment": 28,
        "availableSeats": 2,
        "location": "Tech Building, Room 201",
        "semesterId": 2,
        "semesterName": "Spring 2025"
      },
      {
        "id": 26,
        "sectionNumber": "B",
        "maxCapacity": 35,
        "currentEnrollment": 35,
        "availableSeats": 0,
        "location": "Tech Building, Room 202",
        "semesterId": 2,
        "semesterName": "Spring 2025"
      }
    ],
    "prerequisites": [
      {
        "id": 2,
        "courseId": 20,
        "prerequisiteCourseId": 10,
        "courseCode": "CS201",
        "courseName": "Data Structures",
        "isMandatory": true
      },
      {
        "id": 3,
        "courseId": 20,
        "prerequisiteCourseId": 15,
        "courseCode": "CS210",
        "courseName": "Discrete Mathematics",
        "isMandatory": false
      }
    ],
    "canEnroll": true,
    "enrollmentStatus": null
  },
  {
    "id": 21,
    "name": "Advanced Algorithms",
    "code": "CS401",
    "description": "Advanced topics in algorithm design",
    "credits": 3,
    "level": "SENIOR",
    "departmentId": 1,
    "departmentName": "Computer Science",
    "sections": [
      {
        "id": 27,
        "sectionNumber": "A",
        "maxCapacity": 25,
        "currentEnrollment": 20,
        "availableSeats": 5,
        "location": "Tech Building, Room 301",
        "semesterId": 2,
        "semesterName": "Spring 2025"
      }
    ],
    "prerequisites": [
      {
        "id": 4,
        "courseId": 21,
        "prerequisiteCourseId": 20,
        "courseCode": "CS301",
        "courseName": "Algorithms",
        "isMandatory": true
      }
    ],
    "canEnroll": true,
    "enrollmentStatus": null
  }
]
```

### 1.3 Enroll in a Course
```bash
POST /api/enrollments/register
Content-Type: application/json

{
  "sectionId": 25
}

Response 200 OK:
{
  "id": 150,
  "userId": 5,
  "courseId": 20,
  "sectionId": 25,
  "status": "enrolled",
  "grade": null,
  "finalScore": null,
  "enrollmentDate": "2025-01-20T14:30:00Z",
  "droppedAt": null,
  "completedAt": null,
  "canDrop": true,
  "dropDeadline": "2025-03-15T23:59:59Z",
  ...
}

# Error Responses:

# 400 - Prerequisite not met
{
  "statusCode": 400,
  "message": "Prerequisite course CS201 not completed"
}

# 400 - Schedule conflict
{
  "statusCode": 400,
  "message": "Schedule conflict with existing enrollment"
}

# 409 - Already enrolled
{
  "statusCode": 409,
  "message": "Student is already enrolled in this section"
}

# 200 - Waitlisted (section full)
{
  "id": 151,
  "userId": 5,
  "courseId": 20,
  "sectionId": 26,
  "status": "waitlisted",  # Note: status is waitlisted
  ...
}
```

### 1.4 Get Enrollment Details
```bash
GET /api/enrollments/150

Response 200 OK:
{
  "id": 150,
  "userId": 5,
  "courseId": 20,
  "sectionId": 25,
  "status": "enrolled",
  "grade": null,
  "finalScore": null,
  "enrollmentDate": "2025-01-20T14:30:00Z",
  "droppedAt": null,
  "completedAt": null,
  "canDrop": true,
  "dropDeadline": "2025-03-15T23:59:59Z",
  "course": {
    "id": 20,
    "name": "Algorithms",
    "code": "CS301",
    "description": "Design and analysis of algorithms",
    "credits": 4,
    "level": "JUNIOR"
  },
  "section": {
    "id": 25,
    "sectionNumber": "A",
    "maxCapacity": 30,
    "currentEnrollment": 29,
    "location": "Tech Building, Room 201"
  },
  "semester": {
    "id": 2,
    "name": "Spring 2025",
    "startDate": "2025-01-13T00:00:00Z",
    "endDate": "2025-05-09T23:59:59Z"
  },
  "instructor": {
    "id": 3,
    "firstName": "John",
    "lastName": "Smith",
    "email": "john.smith@university.edu"
  },
  "prerequisites": [
    {
      "id": 2,
      "courseId": 20,
      "prerequisiteCourseId": 10,
      "courseCode": "CS201",
      "courseName": "Data Structures",
      "isMandatory": true,
      "studentCompleted": true,
      "studentGrade": "B+"
    }
  ]
}
```

### 1.5 Drop Course (Student)
```bash
# Simple drop
DELETE /api/enrollments/150

# Drop with reason and notes
DELETE /api/enrollments/150
Content-Type: application/json

{
  "reason": "student_request",
  "notes": "Personal reasons"
}

Response 200 OK:
{
  "id": 150,
  "userId": 5,
  "courseId": 20,
  "sectionId": 25,
  "status": "dropped",
  "grade": null,
  "finalScore": null,
  "enrollmentDate": "2025-01-20T14:30:00Z",
  "droppedAt": "2025-02-10T10:15:00Z",
  "completedAt": null,
  "canDrop": false,
  ...
}

# Error Responses:

# 400 - Drop deadline passed
{
  "statusCode": 400,
  "message": "Drop deadline has passed. Contact admin to drop this course"
}

# 403 - Permission denied
{
  "statusCode": 403,
  "message": "You do not have permission to access this enrollment"
}

# 404 - Not found
{
  "statusCode": 404,
  "message": "Enrollment not found"
}
```

## 2. Instructor/Admin Endpoints

### 2.1 Get Enrolled Students in Section
```bash
GET /api/enrollments/section/25/students

Response 200 OK:
[
  {
    "id": 150,
    "userId": 5,
    "courseId": 20,
    "sectionId": 25,
    "status": "enrolled",
    "grade": null,
    "finalScore": null,
    "enrollmentDate": "2025-01-20T14:30:00Z",
    "droppedAt": null,
    "completedAt": null,
    ...
  },
  {
    "id": 151,
    "userId": 6,
    "courseId": 20,
    "sectionId": 25,
    "status": "enrolled",
    "grade": null,
    "finalScore": null,
    "enrollmentDate": "2025-01-21T09:15:00Z",
    "droppedAt": null,
    "completedAt": null,
    ...
  }
]
```

### 2.2 Get Course Waitlist
```bash
GET /api/enrollments/section/26/waitlist

Response 200 OK:
[
  {
    "id": 152,
    "userId": 7,
    "courseId": 20,
    "sectionId": 26,
    "status": "waitlisted",
    "grade": null,
    "finalScore": null,
    "enrollmentDate": "2025-01-25T16:45:00Z",
    "droppedAt": null,
    "completedAt": null,
    "canDrop": false,
    "dropDeadline": null,
    ...
  },
  {
    "id": 153,
    "userId": 8,
    "courseId": 20,
    "sectionId": 26,
    "status": "waitlisted",
    "grade": null,
    "finalScore": null,
    "enrollmentDate": "2025-01-26T11:20:00Z",
    "droppedAt": null,
    "completedAt": null,
    ...
  }
]
```

### 2.3 Drop Course (Admin Override)
```bash
# Admin can drop anytime, bypassing deadline
DELETE /api/enrollments/150
Content-Type: application/json

{
  "reason": "admin_removal",
  "notes": "Student account inactive"
}

Response 200 OK:
{
  "id": 150,
  "userId": 5,
  "courseId": 20,
  "sectionId": 25,
  "status": "dropped",
  "enrollmentDate": "2025-01-20T14:30:00Z",
  "droppedAt": "2025-02-15T14:30:00Z",
  "dropReason": "admin_removal",
  "dropNotes": "Student account inactive",
  "droppedByUserId": 1,  # Admin user ID
  ...
}
```

### 2.4 Update Enrollment Status (Admin)
```bash
POST /api/enrollments/150/status
Content-Type: application/json

{
  "status": "completed"
}

Response 200 OK:
{
  "id": 150,
  "userId": 5,
  "courseId": 20,
  "sectionId": 25,
  "status": "completed",
  "grade": "A-",
  "finalScore": 92.5,
  "completedAt": "2025-05-10T23:59:59Z",
  ...
}
```

## 3. Special Scenarios

### 3.1 Retake Course (Failed Grade)
```bash
# Student can immediately retake a failed course
GET /api/enrollments/available?search=CS301

Response shows:
- Course CS301 with status: "failed" in history
- canEnroll: true (because failed)
- Previous grade: F

POST /api/enrollments/register
{
  "sectionId": 25
}

# New enrollment created, can retake freely
```

### 3.2 Retake Course (Grade Improvement - Requires Admin)
```bash
# Student passed with B, wants to retake for better grade
POST /api/enrollments/register
{
  "sectionId": 25
}

Response 400 Bad Request:
{
  "statusCode": 400,
  "message": "Retaking courses for grade improvement requires admin approval"
}

# Admin manually enrolls or approves
# (Via admin interface or direct database)
```

### 3.3 Automatic Waitlist to Enrolled Promotion
```bash
# Student on waitlist
{
  "id": 152,
  "status": "waitlisted",
  "enrollmentDate": "2025-01-25T16:45:00Z"
}

# When another student drops:
DELETE /api/enrollments/150  # Seat freed

# Waitlisted student automatically becomes enrolled
# (No action needed from student)

GET /api/enrollments/152
{
  "id": 152,
  "status": "enrolled",  # Changed automatically!
  "enrollmentDate": "2025-01-25T16:45:00Z"
}
```

### 3.4 Drop Deadline Calculation
```bash
Semester: Jan 13 - May 9 (117 days total)
Drop Deadline: 50% through = ~58 days from start
Drop Deadline Date: March 12, 2025

- Before March 12: Student can drop
- After March 12: Enrollment no longer droppable
  - Returns: "Drop deadline has passed"
  - Student must contact admin

GET /api/enrollments/150
{
  "canDrop": false,  # After deadline
  "dropDeadline": "2025-03-12T23:59:59Z"
}
```

## Error Response Format

All errors follow this format:
```json
{
  "statusCode": 400,
  "message": "Error description",
  "error": "BadRequest"
}
```

Common Status Codes:
- `200` - Success
- `400` - Bad Request (validation, business logic)
- `403` - Forbidden (permission denied)
- `404` - Not Found
- `409` - Conflict (duplicate enrollment)

## Pagination Example

```bash
GET /api/enrollments/available?page=2&limit=10

Request Parameters:
- page: 2 (second page)
- limit: 10 (items per page)

Response:
[
  // 10 items on page 2
]

To get next page:
GET /api/enrollments/available?page=3&limit=10
```

---

**Last Updated:** 2025-11-30
**API Version:** 1.0
**Status:** Ready for Testing
