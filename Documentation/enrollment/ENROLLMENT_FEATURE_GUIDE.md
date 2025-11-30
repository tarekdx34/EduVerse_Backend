# Course Enrollment Feature - Implementation Guide

## Overview
The Course Enrollment feature allows students to register for courses, manage their enrollments, and enables instructors/admins to view and manage enrollments. The system includes:
- Student enrollment with prerequisite validation
- Schedule conflict detection  
- Waitlist management when sections are full
- Drop course functionality with deadline enforcement
- Retake policies (failed grades can be retaken freely, grade improvement requires admin approval)
- Best grade policy (B- or higher for prerequisites)

## Database Tables

### course_enrollments
Tracks student enrollments in course sections with status tracking and grades.

**Key Fields:**
- `enrollment_id` - Primary key
- `user_id` - Student user ID
- `section_id` - Course section ID
- `course_id` - Course ID
- `enrollment_status` - Status: pending, enrolled, dropped, completed, waitlisted, rejected
- `grade` - Letter grade (A, A-, B+, B, B-, C+, C, C-, D+, D, F)
- `final_score` - Numeric grade (0-100)
- `drop_reason` - Why course was dropped
- `drop_notes` - Admin notes on drop
- `dropped_by_user_id` - User who dropped the enrollment
- `enrollment_date` - When student enrolled
- `dropped_at` - When dropped
- `completed_at` - When completed
- `deleted_at` - Soft delete timestamp

### course_instructors
Maps instructors to courses (primary/secondary roles).

**Key Fields:**
- `instructor_id` - Primary key
- `course_id` - Course ID
- `instructor_id_user` - User ID of instructor
- `role` - primary or secondary

### course_tas
Maps TAs to courses.

**Key Fields:**
- `ta_id` - Primary key
- `course_id` - Course ID
- `ta_user_id` - User ID of TA

## API Endpoints

### Student Endpoints

#### GET /api/enrollments/my-courses
Get all enrolled courses for authenticated student.

**Query Parameters:**
- `semester` (optional) - Filter by semester ID

**Response:** `EnrollmentResponseDto[]`

**Example:**
```bash
GET /api/enrollments/my-courses?semester=1
```

#### GET /api/enrollments/available
Get list of available courses student can enroll in.

**Query Parameters:**
- `departmentId` (optional) - Filter by department
- `semesterId` (optional) - Filter by semester
- `search` (optional) - Search by course name/code
- `level` (optional) - Filter by course level
- `page` (optional, default: 1) - Pagination
- `limit` (optional, default: 20) - Items per page

**Response:** `AvailableCoursesDto[]`

**Example:**
```bash
GET /api/enrollments/available?departmentId=1&semesterId=2&search=CS&page=1&limit=20
```

#### POST /api/enrollments/register
Enroll a student in a course section.

**Request Body:**
```json
{
  "sectionId": 5
}
```

**Response:** `EnrollmentResponseDto`

**Business Logic:**
1. Validate section exists
2. Check not already enrolled
3. Check prerequisites met (B- or higher)
4. Check schedule conflicts
5. Validate section capacity
6. Create enrollment or add to waitlist

**Status Codes:**
- 200 - Success (enrolled)
- 200 - Success (waitlisted if section full)
- 400 - Prerequisite not met
- 400 - Schedule conflict
- 400 - Already enrolled
- 409 - Section full (but added to waitlist)

#### GET /api/enrollments/:id
Get enrollment details by ID.

**Response:** `EnrollmentResponseDto`

#### DELETE /api/enrollments/:id
Drop course enrollment.

**Request Body (optional):**
```json
{
  "reason": "student_request",
  "notes": "Optional admin notes"
}
```

**Response:** `EnrollmentResponseDto`

**Business Logic:**
- Students: Check within drop deadline (50% through semester)
- Admins: Can drop anytime
- Update enrollment status to 'dropped'
- Soft delete support
- Automatically promote first waitlisted student

**Status Codes:**
- 200 - Success
- 400 - Drop deadline passed (student only)
- 403 - Permission denied
- 404 - Enrollment not found

### Instructor/Admin Endpoints

#### GET /api/enrollments/section/:sectionId/students
Get all enrolled students in a section.

**Response:** `EnrollmentResponseDto[]`

**Access Control:** Instructor (of course) or Admin

#### GET /api/enrollments/section/:sectionId/waitlist
Get waitlist for a section.

**Response:** `EnrollmentResponseDto[]`

**Access Control:** Instructor (of course) or Admin

#### POST /api/enrollments/:id/status
Update enrollment status (admin only).

**Request Body:**
```json
{
  "status": "enrolled"
}
```

**Access Control:** Admin only

## Data Transfer Objects (DTOs)

### EnrollCourseDto
```typescript
{
  sectionId: number  // Required
}
```

### EnrollmentResponseDto
```typescript
{
  id: number
  userId: number
  courseId: number
  sectionId: number
  status: EnrollmentStatus  // pending, enrolled, dropped, completed, waitlisted, rejected
  grade: string | null      // A, A-, B+, B, B-, C+, C, C-, D+, D, F
  finalScore: number | null // 0-100
  enrollmentDate: Date
  droppedAt: Date | null
  completedAt: Date | null
  canDrop: boolean          // True if within drop deadline
  dropDeadline: Date | null // 50% through semester
  
  // Nested objects
  course: {
    id: number
    name: string
    code: string
    description: string
    credits: number
    level: string
  }
  
  section: {
    id: number
    sectionNumber: string
    maxCapacity: number
    currentEnrollment: number
    location: string | null
  }
  
  semester: {
    id: number
    name: string
    startDate: Date
    endDate: Date
  }
  
  instructor: {
    id: number
    firstName: string
    lastName: string
    email: string
  }
  
  prerequisites: [{
    id: number
    courseId: number
    prerequisiteCourseId: number
    courseCode: string
    courseName: string
    isMandatory: boolean
    studentCompleted: boolean
    studentGrade: string | null
  }]
}
```

### AvailableCoursesFilterDto
```typescript
{
  departmentId?: number
  semesterId?: number
  search?: string
  level?: string
  page?: number = 1
  limit?: number = 20
}
```

### AvailableCoursesDto
```typescript
{
  id: number
  name: string
  code: string
  description: string
  credits: number
  level: string
  departmentId: number
  departmentName: string
  
  sections: [{
    id: number
    sectionNumber: string
    maxCapacity: number
    currentEnrollment: number
    availableSeats: number
    location: string | null
    semesterId: number
    semesterName: string
  }]
  
  prerequisites: [{
    id: number
    courseId: number
    prerequisiteCourseId: number
    courseCode: string
    courseName: string
    isMandatory: boolean
  }]
  
  canEnroll: boolean
  enrollmentStatus?: string
}
```

### DropCourseDto
```typescript
{
  reason?: DropReason  // student_request, failing_grade, admin_removal, etc.
  notes?: string       // Optional notes
}
```

## Enums

### EnrollmentStatus
- `PENDING` - Enrollment awaiting confirmation
- `ENROLLED` - Active enrollment
- `DROPPED` - Student dropped (soft deleted)
- `COMPLETED` - Course completed with grade
- `WAITLISTED` - On waitlist (section full)
- `REJECTED` - Enrollment rejected (prerequisite failed)

### DropReason
- `STUDENT_REQUEST` - Student initiated drop
- `FAILING_GRADE` - Course failed
- `ADMIN_REMOVAL` - Admin removed
- `SCHEDULE_CONFLICT` - Schedule conflict
- `OTHER` - Other reason

## Business Rules

### Prerequisite Validation
1. Course must have completed prerequisite course
2. Prerequisite grade must be B- or higher (best grade policy)
3. If no prerequisites, enrollment allowed
4. Checked during enrollment registration

### Schedule Conflict Detection
1. Compares day of week and time slots
2. Prevents overlapping class times
3. Checked for all current enrollments
4. Includes lecture, lab, and tutorial schedules

### Capacity Management
1. When section reaches maxCapacity
2. New students added to waitlist (status = WAITLISTED)
3. Enrollment count not increased
4. Section status updated to FULL

### Waitlist Processing
1. When enrolled student drops course
2. First waitlisted student automatically enrolled
3. Enrollment count increased
4. Notification sent to student

### Drop Deadline
1. Default: 50% through semester
2. Calculated from semester start/end dates
3. Students can only drop within deadline
4. Admins can override deadline
5. Soft delete support for audit trail

### Retake Policy
1. **Failed Course**: Can retake immediately
   - Student retakes as normal course
   - Previous failed grade is available
   
2. **Passing Grade (B or better)**: Requires admin approval
   - For grade improvement
   - Admin must manually enroll student
   - System throws `RetakeRequiresAdminApprovalException`
   
3. **Best Grade Policy**: B- or higher
   - Used for prerequisite validation
   - Prerequisites require B- minimum

## Exception Handling

### EnrollmentNotFoundException
- Enrollment not found
- Returns 404

### AlreadyEnrolledException
- Student already enrolled in same section
- Returns 409 Conflict

### SectionFullException
- Section at capacity
- Student added to waitlist
- Returns 200 (success with waitlist status)

### PrerequisiteNotMetException
- Student hasn't completed required prerequisites
- Returns 400

### ScheduleConflictException
- Class times overlap with existing enrollment
- Returns 400

### DropDeadlinePassedException
- Drop deadline has passed
- Student can contact admin
- Returns 400

### RetakeRequiresAdminApprovalException
- Retaking for grade improvement (passing grade)
- Returns 400

### EnrollmentAccessDeniedException
- Student trying to access/drop another student's enrollment
- Returns 403

## Implementation Notes

### Grade Scale
```typescript
{
  'A':  { value: 4.0, passing: true },
  'A-': { value: 3.7, passing: true },
  'B+': { value: 3.3, passing: true },
  'B':  { value: 3.0, passing: true },
  'B-': { value: 2.7, passing: true },   // Minimum for prerequisites
  'C+': { value: 2.3, passing: true },
  'C':  { value: 2.0, passing: true },
  'C-': { value: 1.7, passing: false },
  'D+': { value: 1.3, passing: false },
  'D':  { value: 1.0, passing: false },
  'F':  { value: 0.0, passing: false }
}
```

### Database Queries Optimization
- Indexes on: `(userId, status)`, `(sectionId, status)`, `(courseId, userId)`
- Use `IsNull()` for soft delete filtering
- Eager load relations when building responses
- Pagination for large result sets

### Soft Delete Usage
- `deletedAt` field tracks deletion
- Queries use `IsNull()` filter
- Enables audit trail and recovery

### Transaction Safety
- Multiple operations (update status, update count, update section)
- Should be wrapped in transaction if adding persistence layer
- Currently handled by TypeORM repository

## File Structure
```
src/modules/enrollments/
├── entities/
│   ├── course-enrollment.entity.ts
│   ├── course-instructor.entity.ts
│   ├── course-ta.entity.ts
│   └── index.ts
├── dto/
│   ├── enroll-course.dto.ts
│   ├── enrollment-response.dto.ts
│   ├── available-courses.dto.ts
│   ├── drop-course.dto.ts
│   └── index.ts
├── enums/
│   └── index.ts
├── exceptions/
│   └── index.ts
├── services/
│   ├── enrollments.service.ts
│   └── index.ts
├── controllers/
│   ├── enrollments.controller.ts
│   └── index.ts
├── enrollments.module.ts
└── README.md (this file)
```

## Testing Checklist

- [ ] Student can enroll in course
- [ ] Student cannot enroll without prerequisites
- [ ] Student cannot enroll with schedule conflict
- [ ] Student is waitlisted when section full
- [ ] Waitlisted student moved to enrolled when seat available
- [ ] Student can drop within deadline
- [ ] Student cannot drop past deadline
- [ ] Admin can drop at any time
- [ ] Student cannot drop another student's enrollment
- [ ] Drop reason and notes are recorded
- [ ] Failed course can be retaken
- [ ] Passing grade retake requires admin approval
- [ ] Grade improvement only for B or better
- [ ] Available courses shows correct prerequisites
- [ ] Prerequisite status shown correctly
- [ ] Section capacity enforced
- [ ] Schedule conflict detection works with multiple schedules
- [ ] Soft delete tracking works
- [ ] Pagination works for available courses

## Security Notes

- Always verify user role before allowing enrollment/drop operations
- Students can only see/manage their own enrollments
- Instructors can only view their own course sections
- Admins have full access
- Soft delete prevents accidental data loss
- Audit trail via `droppedByUserId` and timestamps
