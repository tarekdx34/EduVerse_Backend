# EduVerse — System Architecture, Scenarios & Linking Guide

> **Purpose:** This document explains how every feature in EduVerse works, how all entities are connected, the end-to-end flow of every major scenario, and what is currently missing or incomplete.

---

## Table of Contents

1. [System Overview](#1-system-overview)
2. [User Roles & Access Control](#2-user-roles--access-control)
3. [Complete Entity Relationship Map](#3-complete-entity-relationship-map)
4. [End-to-End Scenarios](#4-end-to-end-scenarios)
   - [Scenario 1: Campus & Course Setup](#scenario-1-campus--course-setup)
   - [Scenario 2: Instructor Assignment](#scenario-2-instructor-assignment)
   - [Scenario 3: Student Registration & Enrollment](#scenario-3-student-registration--enrollment)
   - [Scenario 4: Lecture Video Upload (YouTube)](#scenario-4-lecture-video-upload-youtube-integration)
   - [Scenario 5: Course Materials (Documents, Slides, Links)](#scenario-5-course-materials-documents-slides-links)
   - [Scenario 6: Course Structure Organization](#scenario-6-course-structure-organization)
   - [Scenario 7: Assignments Flow](#scenario-7-assignments-flow)
   - [Scenario 8: Quizzes Flow](#scenario-8-quizzes-flow)
   - [Scenario 9: Labs Flow](#scenario-9-labs-flow)
   - [Scenario 10: Attendance Tracking](#scenario-10-attendance-tracking)
   - [Scenario 11: Grading & GPA](#scenario-11-grading--gpa)
   - [Scenario 12: Discussions & Community](#scenario-12-discussions--community)
   - [Scenario 13: Messaging (Real-Time)](#scenario-13-messaging-real-time)
   - [Scenario 14: Notifications](#scenario-14-notifications)
   - [Scenario 15: Schedule & Calendar](#scenario-15-schedule--calendar)
   - [Scenario 16: File Management](#scenario-16-file-management)
   - [Scenario 17: Announcements](#scenario-17-announcements)
5. [How Everything Is Linked — The Big Picture](#5-how-everything-is-linked--the-big-picture)
6. [Gaps & Missing Features](#6-gaps--missing-features)

---

## 1. System Overview

EduVerse is a comprehensive Learning Management System (LMS) built with **NestJS + TypeORM + MySQL**. It consists of **19 modules** organized into four domains:

```
┌─────────────────────────────────────────────────────────────────┐
│                        EDUVERSE BACKEND                         │
├─────────────────┬───────────────────┬───────────────────────────┤
│   ACADEMIC      │   ASSESSMENT      │   COMMUNICATION           │
│                 │                   │                           │
│  • Courses      │  • Assignments    │  • Discussions            │
│  • Enrollments  │  • Quizzes        │  • Community              │
│  • Course       │  • Labs           │  • Messaging (WebSocket)  │
│    Materials    │  • Grades         │  • Notifications          │
│  • Schedule     │  • Attendance     │  • Announcements          │
│  • Campus       │                   │  • Email                  │
├─────────────────┴───────────────────┴───────────────────────────┤
│   INFRASTRUCTURE                                                │
│                                                                 │
│  • Auth (JWT + Roles)   • Files (Upload/Versioning)             │
│  • YouTube API          • Database (MySQL + TypeORM)            │
└─────────────────────────────────────────────────────────────────┘
```

### Module Count: 19

| # | Module | Purpose |
|---|--------|---------|
| 1 | **auth** | User registration, JWT login, roles, password reset |
| 2 | **campus** | Campuses, departments, programs, semesters |
| 3 | **courses** | Course catalog, sections, schedules, prerequisites |
| 4 | **enrollments** | Student enrollment, instructor/TA assignment |
| 5 | **course-materials** | Lecture content, slides, videos, documents |
| 6 | **youtube** | YouTube API integration for video uploads |
| 7 | **files** | File upload, versioning, permissions, folders |
| 8 | **assignments** | Assignment creation, submission, grading |
| 9 | **quizzes** | Quiz creation, questions, attempts, auto-grading |
| 10 | **labs** | Lab exercises, instructions, submissions |
| 11 | **grades** | Grade records, GPA calculation, transcripts |
| 12 | **attendance** | Session tracking, AI photo processing |
| 13 | **discussions** | Course chat threads, Q&A |
| 14 | **community** | Forum posts, comments, reactions |
| 15 | **messaging** | Direct/group messages with WebSocket |
| 16 | **notifications** | In-app notifications, preferences |
| 17 | **announcements** | Course/system announcements |
| 18 | **schedule** | Exam schedules, calendar events |
| 19 | **email** | Email sending service |

---

## 2. User Roles & Access Control

### Authentication Flow
```
User registers → password hashed (bcrypt) → stored in `users` table
                                          → default role: STUDENT assigned
User logs in   → credentials validated → JWT access token + refresh token returned
                                       → session record created
Every request  → JwtAuthGuard checks Bearer token
               → RolesGuard checks @Roles() decorator against user's roles
```

### Roles (from `roles` table)

| Role | What they can do |
|------|-----------------|
| **STUDENT** | View courses, enroll, submit work, view grades, participate in discussions |
| **INSTRUCTOR** | Create/manage course content, grade submissions, take attendance, upload videos |
| **TA** | Assist instructor — grade, manage materials, mark attendance |
| **ADMIN** | Full system access — manage users, courses, campus, roles |
| **IT_ADMIN** | Technical administration — same as admin |
| **DEPARTMENT_HEAD** | Department-level oversight |

### How Roles Are Assigned
- On registration → user automatically gets **STUDENT** role
- Admin can assign additional roles via `POST /api/admin/users/:id/roles`
- Roles stored in **many-to-many** junction table `user_roles`

---

## 3. Complete Entity Relationship Map

### The Master Diagram

```
                                  ┌──────────┐
                                  │  Campus   │
                                  └─────┬─────┘
                                        │ 1:M
                               ┌────────┴────────┐
                               │                  │
                         ┌─────┴──────┐    ┌──────┴─────┐
                         │ Department │    │  Semester   │
                         └─────┬──────┘    └──────┬──────┘
                               │ 1:M              │
                         ┌─────┴──────┐           │
                         │  Program   │           │
                         └─────┬──────┘           │
                               │                  │
                         ┌─────┴──────┐           │
                         │   Course   │◄──────────┘
                         └─────┬──────┘         (via CourseSection)
                               │
              ┌────────┬───────┼───────┬────────┬──────────┐
              │        │       │       │        │          │
              ▼        ▼       ▼       ▼        ▼          ▼
         ┌─────────┐ ┌─────┐ ┌────┐ ┌────┐ ┌──────┐ ┌──────────┐
         │ Course  │ │Quiz │ │Lab │ │Assi│ │Mater-│ │ Course   │
         │ Section │ │     │ │    │ │gnmt│ │ials  │ │ Structure│
         └────┬────┘ └──┬──┘ └─┬──┘ └─┬──┘ └──┬───┘ │(Lect/Lab)│
              │         │      │      │       │     └──────────┘
    ┌─────────┼────┐    │      │      │       │
    │         │    │    │      │      │       │
    ▼         ▼    ▼    ▼      ▼      ▼       ▼
┌──────┐ ┌────┐ ┌───┐ ┌───┐ ┌───┐ ┌──────┐ ┌────┐
│Enroll│ │Inst│ │TA │ │Att│ │Sub│ │Submit│ │File│
│ment  │ │ructor│ │  │ │empt│ │mis│ │      │ │    │
└──┬───┘ └────┘ └───┘ └───┘ └─┬─┘ └──┬───┘ └────┘
   │                           │      │
   │         ┌─────────────────┘      │
   ▼         ▼                        ▼
┌──────┐  ┌──────┐               ┌──────┐
│ User │  │Grade │               │Grade │
│      │  │      │               │      │
└──────┘  └──────┘               └──────┘
```

### All Entity Relationships (Foreign Keys)

#### Campus Domain
```
Campus ──(1:M)──> Department        (campus_id)
Department ──(M:1)──> User          (head_of_department_id)
Department ──(1:M)──> Program       (department_id)
Department ──(1:M)──> Course        (department_id)
Program ──(M:1)──> Department       (department_id)
```

#### Course Domain
```
Course ──(M:1)──> Department                    (department_id)
Course ──(1:M)──> CourseSection                 (course_id)
Course ──(1:M)──> CoursePrerequisite            (course_id)
CoursePrerequisite ──(M:1)──> Course            (prerequisite_course_id)  [self-ref]

CourseSection ──(M:1)──> Course                 (course_id)
CourseSection ──(M:1)──> Semester               (semester_id)
CourseSection ──(1:M)──> CourseSchedule          (section_id)
CourseSchedule ──(M:1)──> CourseSection          (section_id)
```

#### Enrollment Domain
```
CourseEnrollment ──(M:1)──> User                (user_id)
CourseEnrollment ──(M:1)──> CourseSection        (section_id)
CourseEnrollment ──(M:1)──> Program              (program_id)  [nullable]

CourseInstructor ──(M:1)──> CourseSection        (section_id)
CourseInstructor ──(M:1)──> User                (user_id)

CourseTA ──(M:1)──> CourseSection                (section_id)
CourseTA ──(M:1)──> User                        (user_id)
```

#### Materials Domain
```
CourseMaterial ──(M:1)──> Course                (course_id)
CourseMaterial ──(M:1)──> File                  (file_id)    [nullable]
CourseMaterial ──(M:1)──> User                  (uploaded_by)

LectureSectionLab ──(M:1)──> Course             (course_id)
LectureSectionLab ──(M:1)──> CourseMaterial     (material_id) [nullable]
```

#### Assessment Domain
```
Assignment ──(M:1)──> Course                    (course_id)
Assignment ──(M:1)──> User                      (created_by)
Assignment ──(1:M)──> AssignmentSubmission       (assignment_id)
AssignmentSubmission ──(M:1)──> User            (user_id)
AssignmentSubmission ──(M:1)──> File            (file_id)    [nullable]

Quiz ──(M:1)──> Course                          (course_id)
Quiz ──(M:1)──> User                            (created_by)
Quiz ──(1:M)──> QuizQuestion                    (quiz_id)
Quiz ──(1:M)──> QuizAttempt                     (quiz_id)
QuizQuestion ──(M:1)──> QuizDifficultyLevel     (difficulty_level_id)
QuizQuestion ──(1:M)──> QuizAnswer              (question_id)
QuizAttempt ──(M:1)──> User                     (user_id)
QuizAttempt ──(1:M)──> QuizAnswer               (attempt_id)
QuizAnswer ──(M:1)──> QuizAttempt               (attempt_id)
QuizAnswer ──(M:1)──> QuizQuestion              (question_id)

Lab ──(M:1)──> Course                           (course_id)
Lab ──(1:M)──> LabSubmission                    (lab_id)
Lab ──(1:M)──> LabInstruction                   (lab_id)
Lab ──(1:M)──> LabAttendance                    (lab_id)
```

#### Grades Domain
```
Grade ──(M:1)──> User                           (user_id)     [student]
Grade ──(M:1)──> Course                         (course_id)
Grade ──(M:1)──> Assignment                     (assignment_id) [nullable]
Grade ──(M:1)──> User                           (graded_by)   [nullable]
Grade ──(1:M)──> GradeComponent                 (grade_id)
⚠️ Grade.quiz_id  — column exists, NO ORM relation
⚠️ Grade.lab_id   — column exists, NO ORM relation

GradeComponent ──(M:1)──> Grade                 (grade_id)
GradeComponent ──(M:1)──> RubricCriteria        (rubric_criteria_id)

Rubric ──(M:1)──> Course                        (course_id)
Rubric ──(M:1)──> User                          (created_by)
Rubric ──(1:M)──> RubricCriteria                (rubric_id)

GpaCalculation ──(M:1)──> User                  (user_id)
GpaCalculation ──(M:1)──> Semester              (semester_id)
```

#### Attendance Domain
```
AttendanceSession ──(M:1)──> CourseSection       (section_id)
AttendanceSession ──(M:1)──> User               (instructor_id)
AttendanceSession ──(1:M)──> AttendanceRecord    (session_id)
AttendanceSession ──(1:M)──> AttendancePhoto     (session_id)

AttendanceRecord ──(M:1)──> AttendanceSession    (session_id)
AttendanceRecord ──(M:1)──> User                (user_id)

AttendancePhoto ──(M:1)──> AttendanceSession     (session_id)
AttendancePhoto ──(M:1)──> User                 (uploaded_by)

AIAttendanceProcessing ──(M:1)──> AttendanceSession (session_id)
AIAttendanceProcessing ──(M:1)──> AttendancePhoto   (photo_id)
AIAttendanceProcessing ──(M:1)──> User              (reviewed_by)
```

#### Communication Domain
```
CourseChatThread ──(M:1)──> Course               (course_id)  [via column only]
CourseChatThread ──(1:M)──> ChatMessage           (thread_id)
ChatMessage ──(M:1)──> CourseChatThread           (thread_id)
⚠️ ChatMessage.user_id     — column exists, NO ORM relation
⚠️ ChatMessage.endorsed_by — column exists, NO ORM relation

CommunityPost ──(M:1)──> User                    (user_id)
CommunityPost ──(M:1)──> Course                  (course_id)
CommunityPost ──(1:M)──> CommunityComment         (post_id)
CommunityPost ──(1:M)──> CommunityReaction         (post_id)
CommunityComment ──(M:1)──> User                  (user_id)
CommunityComment ──(M:1)──> CommunityPost          (post_id)
CommunityComment ──(M:1)──> CommunityComment       (parent_comment_id) [self-ref]
CommunityReaction ──(M:1)──> User                  (user_id)
CommunityReaction ──(M:1)──> CommunityPost          (post_id)

Announcement ──(M:1)──> User                      (created_by)
Announcement ──(M:1)──> Course                    (course_id)  [nullable]

Message ──(M:1)──> Message                        (parent_message_id) [self-ref]
Message ──(1:M)──> MessageParticipant              (message_id)
⚠️ MessageParticipant.user_id — column exists, NO ORM relation
```

#### Files Domain
```
File ──(M:1)──> User                              (uploaded_by)
File ──(M:1)──> Folder                            (folder_id)  [nullable]
File ──(1:M)──> FileVersion                       (file_id)
File ──(1:M)──> FilePermission                    (file_id)

Folder ──(M:1)──> Folder                          (parent_folder_id) [self-ref]
Folder ──(M:1)──> User                            (created_by)
Folder ──(1:M)──> File                            (folder_id)

FileVersion ──(M:1)──> File                       (file_id)
FileVersion ──(M:1)──> User                       (uploaded_by)

FilePermission ──(M:1)──> File                    (file_id)
FilePermission ──(M:1)──> User                    (user_id)  [nullable]
FilePermission ──(M:1)──> Role                    (role_id)  [nullable]
FilePermission ──(M:1)──> User                    (granted_by)
```

#### Schedule Domain
```
ExamSchedule ──(M:1)──> Course                    (course_id)
ExamSchedule ──(M:1)──> Semester                  (semester_id)

CalendarEvent ──(M:1)──> User                     (user_id)
CalendarEvent ──(M:1)──> Course                   (course_id)   [nullable]
CalendarEvent ──(M:1)──> CourseSchedule            (schedule_id) [nullable]
```

---

## 4. End-to-End Scenarios

---

### Scenario 1: Campus & Course Setup

**Who:** Admin  
**Goal:** Set up the entire academic hierarchy before courses can be offered.

```
Step 1: Create Campus
  POST /api/campuses
  Body: { name: "Main Campus", code: "MC", city: "Cairo", country: "Egypt" }
  Result → campus_id: 1 stored in `campuses` table

Step 2: Create Department under Campus
  POST /api/departments
  Body: { campusId: 1, name: "Computer Science", code: "CS" }
  Result → department_id: 1, linked to campus_id: 1

Step 3: Create Program under Department
  POST /api/programs
  Body: { departmentId: 1, programName: "BSc Computer Science", code: "BSCS", durationYears: 4 }
  Result → program_id: 1, linked to department_id: 1

Step 4: Create Semester
  POST /api/semesters
  Body: { semesterName: "Fall 2025", startDate: "2025-09-01", endDate: "2026-01-15" }
  Result → semester_id: 1

Step 5: Create Course under Department
  POST /api/courses
  Body: { departmentId: 1, name: "Data Structures", code: "CS201", credits: 3, level: "200" }
  Result → course_id: 1, linked to department_id: 1

Step 6: Create Course Section (offering in a semester)
  POST /api/courses/sections  (or via course-sections endpoint)
  Body: { courseId: 1, semesterId: 1, sectionNumber: "A", maxCapacity: 40, location: "Room 101" }
  Result → section_id: 1, linked to course_id: 1 AND semester_id: 1

Step 7: Create Schedule for Section
  Body: { sectionId: 1, dayOfWeek: "Monday", startTime: "09:00", endTime: "10:30", location: "Room 101" }
  Result → schedule_id: 1, linked to section_id: 1
```

**Linking Chain:**
```
Campus(1) → Department(1) → Course(1) → CourseSection(1) → CourseSchedule(1)
                                  ↑                              ↑
                          department_id                    semester_id → Semester(1)
```

---

### Scenario 2: Instructor Assignment

**Who:** Admin  
**Goal:** Assign an instructor to teach a specific course section.

```
Step 1: Instructor registers (or admin creates user)
  POST /api/auth/register
  Body: { email: "dr.ahmed@univ.edu", password: "...", firstName: "Ahmed", lastName: "Hassan" }
  Result → user_id: 10, automatically gets role: STUDENT

Step 2: Admin assigns INSTRUCTOR role
  POST /api/admin/users/10/roles
  Body: { roleName: "instructor" }
  Result → entry in `user_roles` junction table: user_id: 10, role_id: 2 (instructor)

Step 3: Admin assigns instructor to course section
  POST /api/enrollments/instructors  (or via course-instructors endpoint)
  Body: { sectionId: 1, userId: 10, role: "primary" }
  Result → entry in `course_instructors` table:
           section_id: 1, user_id: 10, role: "primary"
```

**Linking Chain:**
```
User(10) ──(user_roles)──> Role(instructor)
User(10) ──(course_instructors)──> CourseSection(1) ──> Course(1)
```

**What the Instructor Can Now Do:**
- Access Course 1's materials, assignments, quizzes, labs
- Upload lecture videos
- Create assignments, quizzes, labs
- Grade student submissions
- Take attendance
- Post announcements

---

### Scenario 3: Student Registration & Enrollment

**Who:** Student  
**Goal:** Register, find a course, and enroll.

```
Step 1: Student registers
  POST /api/auth/register
  Body: { email: "student@univ.edu", password: "...", firstName: "Sara", lastName: "Ali" }
  Result → user_id: 20, role: STUDENT (auto-assigned)
  ⚠️ emailVerified set to TRUE automatically (no actual verification)

Step 2: Student logs in
  POST /api/auth/login
  Body: { email: "student@univ.edu", password: "..." }
  Result → { accessToken: "eyJ...", refreshToken: "..." }

Step 3: Browse available courses
  GET /api/enrollments/available?semesterId=1
  Result → List of courses with available sections, filtered by:
           ✅ Prerequisites the student has completed
           ✅ Sections with available capacity

Step 4: Enroll in a section
  POST /api/enrollments
  Body: { sectionId: 1 }
  
  System validates:
  ├── ✅ Student not already enrolled in this section
  ├── ✅ Section has capacity (current_enrollment < max_capacity)
  ├── ✅ Prerequisites met (checks `course_prerequisites` + student's completed courses)
  └── ✅ No schedule conflict (checks `course_schedules` vs student's existing schedules)
  
  Result → entry in `course_enrollments` table:
           enrollment_id: 1, user_id: 20, section_id: 1, status: "enrolled"
         → section's current_enrollment incremented: 0 → 1

Step 5: View enrolled courses
  GET /api/enrollments/my
  Result → List of all sections student is enrolled in, with course details
```

**Linking Chain:**
```
User(20) ──(course_enrollments)──> CourseSection(1) ──> Course(1)
                                       │
                                       └──> Semester(1)
```

**What the Student Can Now Do:**
- View course materials (published only)
- Submit assignments
- Take quizzes
- Submit lab work
- Participate in discussions and community
- View their grades
- Receive notifications

---

### Scenario 4: Lecture Video Upload (YouTube Integration)

**Who:** Instructor  
**Goal:** Upload a lecture video to YouTube and link it to the course.

```
Step 1: (One-time) YouTube OAuth Setup
  GET /youtube/auth
  Result → { authUrl: "https://accounts.google.com/o/oauth2/v2/auth?..." }
  
  Instructor visits URL → grants YouTube upload permission → Google redirects to callback

  GET /youtube/callback?code=AUTH_CODE
  Result → { refreshToken: "ya29..." }
  This refresh token is stored in server environment (YOUTUBE_REFRESH_TOKEN)

Step 2: Upload video linked to course material
  POST /api/courses/1/materials/video          ← Note: course-specific endpoint
  Headers: Authorization: Bearer <jwt_token>
  Content-Type: multipart/form-data
  Body: {
    video: <lecture_file.mp4>,
    title: "Lecture 1 - Introduction to Data Structures",
    description: "Overview of arrays, linked lists, and trees",
    tags: ["data-structures", "cs201"]
  }
  
  What happens internally (materials.service.ts):
  ┌─────────────────────────────────────────────────────────┐
  │ 1. Validate instructor has access to course             │
  │ 2. Call youtubeService.uploadVideoFromBuffer()          │
  │    → Video uploaded to YouTube as UNLISTED              │
  │    → YouTube returns: { videoId: "dQw4w9WgXcQ",        │
  │        videoUrl: "https://youtube.com/watch?v=..." }    │
  │ 3. Create course_materials record:                      │
  │    → course_id: 1                                       │
  │    → material_type: "video"                             │
  │    → title: "Lecture 1 - Introduction to..."            │
  │    → external_url: "https://youtube.com/embed/dQw..."   │
  │    → uploaded_by: 10 (instructor's user_id)             │
  │    → is_published: true                                 │
  │ 4. Return material with embed URL                       │
  └─────────────────────────────────────────────────────────┘

Step 3: Students view the video
  GET /api/courses/1/materials
  Result → [
    {
      materialId: 5,
      title: "Lecture 1 - Introduction to Data Structures",
      materialType: "video",
      externalUrl: "https://www.youtube.com/embed/dQw4w9WgXcQ",
      isPublished: true
    }
  ]

Step 4: Frontend embeds the video
  GET /api/courses/1/materials/5/embed
  Result → {
    videoId: "dQw4w9WgXcQ",
    embedUrl: "https://www.youtube.com/embed/dQw4w9WgXcQ",
    iframeHtml: '<iframe src="https://www.youtube.com/embed/dQw4w9WgXcQ" ...></iframe>'
  }
  
  Frontend renders: <iframe src="{embedUrl}" width="560" height="315"></iframe>
```

**Linking Chain:**
```
Instructor(10) uploads video
        │
        ▼
YouTube API ── returns ──> videoId + URL
        │
        ▼
course_materials table:
  material_id: 5
  course_id: 1        ──> links to Course "Data Structures"
  material_type: "video"
  external_url: "https://youtube.com/embed/dQw4w9WgXcQ"
  uploaded_by: 10      ──> links to Instructor user
        │
        ▼
Student sees video via GET /api/courses/1/materials
Frontend renders via <iframe> using embed URL
```

---

### Scenario 5: Course Materials (Documents, Slides, Links)

**Who:** Instructor  
**Goal:** Upload various course materials (PDF, slides, links) to a course.

#### Sub-scenario 5A: Upload a PDF document

```
Step 1: Upload file first
  POST /api/files/upload
  Content-Type: multipart/form-data
  Body: { file: <lecture_notes.pdf> }
  Result → {
    fileId: 15,
    fileName: "lecture_notes_1678...",
    originalFileName: "lecture_notes.pdf",
    filePath: "uploads/...",
    mimeType: "application/pdf"
  }

Step 2: Create material linking file to course
  POST /api/courses/1/materials
  Body: {
    title: "Lecture 1 Notes",
    materialType: "document",       ← enum: lecture, slide, video, reading, link, document
    fileId: 15,                     ← links to the uploaded file
    description: "Chapter 1 notes",
    isPublished: true
  }
  Result → course_materials record:
    material_id: 6, course_id: 1, file_id: 15, uploaded_by: 10
```

#### Sub-scenario 5B: Add an external link

```
  POST /api/courses/1/materials
  Body: {
    title: "Recommended Reading",
    materialType: "link",
    externalUrl: "https://example.com/article",
    description: "Great article on binary trees"
  }
  Result → course_materials record:
    material_id: 7, course_id: 1, file_id: NULL, external_url: "https://..."
```

**Linking Chain:**
```
course_materials (material_id: 6)
  ├── course_id: 1     → Course "Data Structures"
  ├── file_id: 15      → File "lecture_notes.pdf" (in files table)
  └── uploaded_by: 10  → User (Instructor)

course_materials (material_id: 7)
  ├── course_id: 1     → Course "Data Structures"
  ├── file_id: NULL     (no file — it's a link)
  ├── external_url     → "https://example.com/article"
  └── uploaded_by: 10  → User (Instructor)
```

#### Visibility Control
```
  PATCH /api/courses/1/materials/6/visibility
  Body: { isPublished: false }
  Result → Material hidden from students (only visible to instructors/TAs)
```

---

### Scenario 6: Course Structure Organization

**Who:** Instructor  
**Goal:** Organize course content into weeks with lectures, sections, and labs.

```
Step 1: Create Week 1 - Lecture
  POST /api/courses/1/structure
  Body: {
    title: "Lecture 1: Introduction to Arrays",
    organizationType: "lecture",      ← enum: lecture, section, lab, tutorial
    weekNumber: 1,
    orderIndex: 0,
    materialId: 6                     ← links to course_materials record (optional)
  }
  Result → lecture_sections_labs record:
    organization_id: 1, course_id: 1, material_id: 6, week_number: 1

Step 2: Create Week 1 - Lab
  POST /api/courses/1/structure
  Body: {
    title: "Lab 1: Array Operations",
    organizationType: "lab",
    weekNumber: 1,
    orderIndex: 1,
    materialId: null                  ← no material linked yet
  }

Step 3: View course structure (grouped by week)
  GET /api/courses/1/structure
  Result → {
    data: [...all items flat],
    byWeek: {
      1: [
        { title: "Lecture 1: Introduction to Arrays", organizationType: "lecture", material: {...} },
        { title: "Lab 1: Array Operations", organizationType: "lab", material: null }
      ],
      2: [...]
    }
  }
```

**Linking Chain:**
```
lecture_sections_labs (organization_id: 1)
  ├── course_id: 1      → Course "Data Structures"
  ├── material_id: 6     → CourseMaterial "Lecture 1 Notes" → File "lecture_notes.pdf"
  ├── organization_type: "lecture"
  └── week_number: 1

                    ┌────────────────────────┐
                    │    Course Structure     │
                    │    (Week View)          │
                    ├────────────────────────┤
                    │  Week 1                │
                    │  ├─ Lecture 1 [📄 PDF] │
                    │  └─ Lab 1              │
                    │  Week 2                │
                    │  ├─ Lecture 2 [🎬 Video]│
                    │  └─ Section 1          │
                    └────────────────────────┘
```

---

### Scenario 7: Assignments Flow

**Who:** Instructor creates → Student submits → Instructor grades

```
Step 1: Instructor creates assignment
  POST /api/assignments
  Body: {
    courseId: 1,
    title: "Assignment 1: Array Implementation",
    description: "Implement a dynamic array class",
    instructions: "Use Java or Python...",
    maxScore: 100,
    weight: 15.0,                    ← 15% of final grade
    dueDate: "2025-10-15T23:59:59",
    availableFrom: "2025-10-01",
    submissionType: "FILE",           ← enum: FILE, TEXT, LINK, MULTIPLE
    maxFileSizeMb: 10,
    allowedFileTypes: ".java,.py,.zip",
    status: "published"              ← enum: draft, published, closed, archived
  }
  Result → assignment_id: 1, course_id: 1, created_by: 10

Step 2: Student views assignments
  GET /api/assignments?courseId=1
  Result → List of published assignments for the course

Step 3: Student uploads file and submits
  POST /api/files/upload               ← First upload the file
  Result → file_id: 20

  POST /api/assignments/1/submit
  Body: {
    fileId: 20                        ← or submissionText / submissionLink based on type
  }
  
  System checks:
  ├── ✅ Student is enrolled in the course (via course_enrollments)
  ├── ✅ Assignment is published
  ├── ⏰ Checks if submission is late (submittedAt > dueDate)
  └── 📝 Creates submission record

  Result → assignment_submissions record:
    submission_id: 1
    assignment_id: 1     → links to Assignment
    user_id: 20          → links to Student
    file_id: 20          → links to uploaded File
    is_late: false
    status: "submitted"
    attempt_number: 1

Step 4: Instructor views all submissions
  GET /api/assignments/1/submissions
  Result → List of all student submissions with file download links

Step 5: Instructor grades a submission
  PATCH /api/assignments/1/submissions/1/grade
  Body: { score: 85, feedback: "Good work! Consider edge cases." }
  
  System does:
  ├── Updates submission status → "graded"
  └── Creates grade record in `grades` table:
        grade_id: 1
        user_id: 20           → Student
        course_id: 1           → Course
        grade_type: "assignment"
        assignment_id: 1       → Assignment
        score: 85
        max_score: 100
        percentage: 85.00
        graded_by: 10          → Instructor
```

**Linking Chain:**
```
Assignment(1) ──(course_id)──> Course(1)
       │
       ├── AssignmentSubmission(1)
       │     ├── user_id: 20    → Student
       │     └── file_id: 20    → Uploaded File
       │
       └── Grade(1)
             ├── user_id: 20    → Student
             ├── course_id: 1   → Course
             ├── assignment_id: 1 → Assignment
             └── graded_by: 10  → Instructor
```

---

### Scenario 8: Quizzes Flow

**Who:** Instructor creates → Student takes → System auto-grades (or Instructor manually grades)

```
Step 1: Instructor creates quiz
  POST /api/quizzes
  Body: {
    courseId: 1,
    title: "Quiz 1: Arrays & Linked Lists",
    quizType: "graded",               ← enum: graded, practice, survey
    timeLimitMinutes: 30,
    maxAttempts: 2,
    passingScore: 60,
    randomizeQuestions: true,
    showCorrectAnswers: true,
    availableFrom: "2025-10-05",
    availableUntil: "2025-10-06"
  }
  Result → quiz_id: 1

Step 2: Add questions
  POST /api/quizzes/1/questions
  Body: {
    questionText: "What is the time complexity of array insertion?",
    questionType: "multiple_choice",
    options: ["O(1)", "O(n)", "O(log n)", "O(n²)"],
    correctAnswer: "O(n)",
    points: 10,
    difficultyLevelId: 2
  }
  Result → question_id: 1, linked to quiz_id: 1

Step 3: Student starts attempt
  POST /api/quizzes/1/attempts/start
  
  System checks:
  ├── ✅ Quiz is available (within date range)
  ├── ✅ Student hasn't exceeded max attempts
  └── ✅ Student is enrolled in the course
  
  Result → quiz_attempt record:
    attempt_id: 1, quiz_id: 1, user_id: 20, started_at: now()

Step 4: Student submits answers
  POST /api/quizzes/attempts/1/submit
  Body: {
    answers: [
      { questionId: 1, selectedAnswer: "O(n)" },
      { questionId: 2, selectedAnswer: "..." }
    ]
  }
  
  System does:
  ├── Saves each answer in quiz_answers table
  ├── Auto-grades objective questions (MCQ, true/false)
  ├── Calculates total score
  └── Creates quiz_attempt record with score

Step 5: Instructor grades essay questions (if any)
  POST /api/quizzes/attempts/1/grade
  Body: { questionGrades: [{ questionId: 5, score: 8, feedback: "Good analysis" }] }
```

**Linking Chain:**
```
Quiz(1) ──(course_id)──> Course(1)
  │
  ├── QuizQuestion(1)
  │     └── QuizDifficultyLevel(2)
  │
  └── QuizAttempt(1)
        ├── user_id: 20     → Student
        ├── quiz_id: 1      → Quiz
        └── QuizAnswer(s)
              ├── attempt_id: 1  → This attempt
              └── question_id: 1 → Which question
```

---

### Scenario 9: Labs Flow

**Who:** Instructor creates → Student submits → Instructor grades

```
Step 1: Create lab
  POST /api/labs
  Body: {
    courseId: 1,
    title: "Lab 1: Array Implementation",
    labNumber: 1,
    maxScore: 50,
    weight: 10.0,
    dueDate: "2025-10-10",
    status: "published"
  }
  Result → lab_id: 1

Step 2: Add lab instructions
  POST /api/labs/1/instructions
  Body: {
    instructionText: "Step 1: Create a new Java project...",
    orderIndex: 0
  }
  (Can also attach file: fileId for instruction PDFs)

Step 3: Student submits lab work
  POST /api/labs/1/submit
  Body: { submissionText: "Here is my solution...", fileId: 25 }
  
  System checks: late submission (submittedAt vs dueDate)
  Result → lab_submissions record:
    lab_id: 1, user_id: 20, file_id: 25, is_late: false

Step 4: Instructor grades
  PATCH /api/labs/1/submissions/1/grade
  Body: { score: 45, feedback: "Well done!", status: "graded" }

Step 5: Lab attendance (separate from course attendance)
  POST /api/labs/1/attendance
  Body: { userId: 20, attendanceStatus: "present" }
```

**Linking Chain:**
```
Lab(1) ──(course_id)──> Course(1)
  │
  ├── LabInstruction(s) — ordered steps
  ├── LabSubmission(1)
  │     ├── user_id: 20  → Student
  │     └── file_id: 25  → Uploaded file
  └── LabAttendance
        └── user_id: 20  → Student
```

---

### Scenario 10: Attendance Tracking

**Who:** Instructor  
**Goal:** Track student attendance for a course section session.

```
Step 1: Create attendance session
  POST /api/attendance/sessions
  Body: {
    sectionId: 1,                    ← links to CourseSection
    sessionDate: "2025-10-07",
    sessionType: "lecture",           ← enum: lecture, lab, tutorial
    startTime: "09:00",
    endTime: "10:30",
    location: "Room 101"
  }
  
  System auto-creates attendance records for ALL enrolled students:
  ├── Gets all enrolled students from course_enrollments WHERE section_id = 1
  └── Creates attendance_records for each with status: "absent" (default)
  
  Result → session_id: 1, with N attendance records pre-created

Step 2: Mark attendance (manual or batch)
  POST /api/attendance/mark-batch
  Body: {
    sessionId: 1,
    records: [
      { userId: 20, status: "present" },
      { userId: 21, status: "late" },
      { userId: 22, status: "absent" },
      { userId: 23, status: "excused" }
    ]
  }

Step 3: Close session (finalize counts)
  POST /api/attendance/sessions/1/close
  Result → Session updated:
    status: "completed"
    present_count: 1, absent_count: 1, total_students: 4

Step 4: AI-based attendance (optional)
  Upload photo → AI processes faces → matches against enrolled students
  Uses: attendance_photos + ai_attendance_processing tables

Step 5: View attendance reports
  GET /api/attendance/student/20      → Student's overall attendance
  GET /api/attendance/section/1       → Section summary with at-risk students
  GET /api/attendance/section/1/weekly-trends → Weekly patterns
```

**Linking Chain:**
```
AttendanceSession(1)
  ├── section_id: 1    → CourseSection(1) → Course(1)
  ├── instructor_id: 10 → User (Instructor)
  │
  ├── AttendanceRecord(s)
  │     ├── user_id: 20 → User (Student)
  │     └── status: "present"
  │
  └── AttendancePhoto (optional)
        └── AIAttendanceProcessing
```

---

### Scenario 11: Grading & GPA

**Who:** System aggregates grades from multiple sources  
**Goal:** Calculate final grades and GPA.

```
How grades are created (3 sources):

Source 1: Assignment Grading
  PATCH /api/assignments/:id/submissions/:subId/grade
  → Creates Grade record: grade_type = "assignment", assignment_id = X

Source 2: Quiz Auto/Manual Grading
  POST /api/quizzes/attempts/:id/grade
  → Creates Grade record: grade_type = "quiz", quiz_id = X
  ⚠️ quiz_id is a plain column — NOT an ORM relation

Source 3: Lab Grading
  PATCH /api/labs/:id/submissions/:subId/grade
  → Creates Grade record: grade_type = "lab", lab_id = X
  ⚠️ lab_id is a plain column — NOT an ORM relation

Other types: "exam", "participation" (manual entry)

Grade record structure:
  ┌─────────────────────────────────────────────┐
  │ grade_id: 1                                 │
  │ user_id: 20       → Student                 │
  │ course_id: 1       → Course                 │
  │ grade_type: "assignment"                    │
  │ assignment_id: 1   → Assignment (ORM ✅)     │
  │ quiz_id: null      → Quiz (plain column ⚠️) │
  │ lab_id: null        → Lab (plain column ⚠️)  │
  │ score: 85                                   │
  │ max_score: 100                              │
  │ percentage: 85.00                           │
  │ letter_grade: "B+"                          │
  │ graded_by: 10      → Instructor             │
  │ is_published: true                          │
  └─────────────────────────────────────────────┘

View grades:
  GET /api/grades/my                    → Student sees their grades
  GET /api/grades?courseId=1            → Instructor sees all grades for a course
  GET /api/grades/transcript/20        → Full transcript
  GET /api/grades/gpa/20              → GPA calculation
  GET /api/grades/distribution/1       → Grade distribution analytics
```

**GPA Calculation:**
```
GpaCalculation record:
  user_id: 20        → Student
  semester_id: 1     → Semester
  semester_gpa: 3.50
  cumulative_gpa: 3.45
  total_credits: 15
  total_quality_points: 52.50
```

**Full Grading Chain:**
```
Student submits work ──> Submission created ──> Instructor grades
                                                      │
                                                      ▼
                                               Grade record created
                                               (links: user + course + source)
                                                      │
                                                      ▼
                                               GPA calculated
                                               (aggregates all grades per semester)
                                                      │
                                                      ▼
                                               Transcript generated
```

---

### Scenario 12: Discussions & Community

**Who:** All enrolled users  
**Goal:** Course-specific discussions and community forum.

#### 12A: Course Discussions (Chat Threads)
```
Step 1: Create a discussion thread
  POST /api/discussions
  Body: { courseId: 1, title: "Question about Assignment 1", description: "..." }
  Result → thread_id: 1, linked to course_id: 1

Step 2: Reply to thread
  POST /api/discussions/1/reply
  Body: { messageText: "I think the answer is..." }
  Result → chat_message record linked to thread_id: 1

Step 3: Instructor endorses a reply
  PATCH /api/discussions/replies/5/endorse
  Result → message marked as endorsed, endorsed_by: instructor's user_id

Step 4: Mark as answer
  PATCH /api/discussions/replies/5/mark-answer
  Result → is_answer: true
```

#### 12B: Community Forum
```
Step 1: Create a community post
  POST /api/community/posts
  Body: {
    courseId: 1,
    title: "Useful Resources for Arrays",
    content: "Here are some great tutorials...",
    postType: "RESOURCE"              ← enum: DISCUSSION, QUESTION, ANNOUNCEMENT, RESOURCE
  }
  Result → post_id: 1, user_id: 20, course_id: 1

Step 2: Comment on post
  POST /api/community/posts/1/comment
  Body: { commentText: "Thanks for sharing!" }
  Supports nested replies via parentCommentId

Step 3: React to post
  POST /api/community/posts/1/react
  Body: { reactionType: "HELPFUL" }   ← enum: LIKE, HELPFUL, INSIGHTFUL, THANKS
```

**Linking Chain:**
```
CourseChatThread(1) ──(course_id)──> Course(1)
  └── ChatMessage(s) ──> User (author)

CommunityPost(1) ──(course_id)──> Course(1)
  ├── user_id ──> User (author)
  ├── CommunityComment(s) ──> User (commenter)
  │     └── parent_comment_id ──> CommunityComment (nested reply)
  └── CommunityReaction(s) ──> User (reactor)
```

---

### Scenario 13: Messaging (Real-Time)

**Who:** Any authenticated user  
**Goal:** Send direct or group messages with real-time delivery.

```
Step 1: Start conversation
  POST /api/messaging/conversations
  Body: { participantIds: [10, 20], subject: "Question about grades" }
  Result → message + message_participants records

Step 2: Send message
  POST /api/messaging/conversations/1
  Body: { body: "Hi, I have a question..." }
  
  ✅ Real-time delivery via WebSocket:
  │  MessagingGateway broadcasts to room "conversation_1"
  │  All participants receive message instantly
  └── Also pushes to "user_10" and "user_20" notification rooms

Step 3: Real-time features (via WebSocket)
  • Typing indicators: user starts typing → broadcast to room
  • Read receipts: message marked as read → broadcast to sender
  • Online status: user connects/disconnects → broadcast to contacts

Step 4: Read messages
  GET /api/messaging/conversations      → List all conversations
  GET /api/messaging/conversations/1    → Get messages in conversation
  GET /api/messaging/unread-count       → Get unread count
  PATCH /api/messaging/1/read           → Mark as read
```

**Linking Chain:**
```
Message(1)
  ├── sender_id: 20     → User (sender)
  ├── parent_message_id  → Message (for threading)
  └── MessageParticipant(s)
        └── user_id      → User (participants)
```

---

### Scenario 14: Notifications

**Who:** System → User  
**Goal:** Notify users about important events.

```
Current notification types:
  announcement, grade, assignment, message, deadline, system

How notifications are created:
  ⚠️ Currently MANUAL ONLY — no auto-triggers!
  
  Admin sends manually:
    POST /api/notifications/send
    Body: {
      userIds: [20, 21, 22],
      type: "assignment",
      title: "New Assignment Posted",
      body: "Assignment 1 has been published",
      relatedEntityType: "assignment",
      relatedEntityId: 1,
      actionUrl: "/courses/1/assignments/1"
    }

  Or other services call notificationsService.createNotification() internally

User views notifications:
  GET /api/notifications             → Paginated list
  GET /api/notifications/unread-count → Badge count
  PATCH /api/notifications/1/read    → Mark as read
  PATCH /api/notifications/read-all  → Mark all as read

User notification preferences:
  GET /api/notifications/preferences
  PUT /api/notifications/preferences
  Body: { emailEnabled: true, pushEnabled: false, quietHoursStart: "22:00" }
```

**Linking:**
```
Notification(1)
  ├── user_id: 20              → Recipient
  ├── related_entity_type: "assignment"
  ├── related_entity_id: 1     → Generic FK (not ORM-linked)
  └── action_url: "/courses/1/assignments/1"
```

---

### Scenario 15: Schedule & Calendar

**Who:** Instructor creates exams → Students see in calendar

```
Step 1: Instructor creates exam schedule
  POST /api/exams/schedule
  Body: {
    courseId: 1,
    semesterId: 1,
    examType: "midterm",            ← enum: midterm, final, quiz, makeup
    title: "Midterm Exam",
    examDate: "2025-11-01",
    startTime: "09:00",
    durationMinutes: 120,
    location: "Hall A",
    instructions: "Bring calculator"
  }
  
  System checks for conflicts automatically
  Result → exam_id: 1

Step 2: View exam schedules
  GET /api/exams/schedule?semesterId=1
  Students see exams for courses they're enrolled in
  Instructors see exams for courses they teach

Step 3: Calendar events
  POST /api/calendar/events
  Body: {
    courseId: 1,
    eventType: "exam",
    title: "Midterm Exam",
    startTime: "2025-11-01T09:00:00",
    endTime: "2025-11-01T11:00:00",
    reminderMinutes: 60
  }

  ⚠️ Calendar events are NOT auto-created from course schedules
  ⚠️ External calendar sync (Google/Outlook) is NOT implemented (skeleton only)
```

**Linking Chain:**
```
ExamSchedule(1)
  ├── course_id: 1      → Course
  └── semester_id: 1    → Semester

CalendarEvent(1)
  ├── user_id: 10       → User (creator)
  ├── course_id: 1      → Course (optional)
  └── schedule_id: null → CourseSchedule (optional, not auto-linked)
```

---

### Scenario 16: File Management

**Who:** Any user (primarily Instructors)  
**Goal:** Upload, organize, version, and share files.

```
Step 1: Create folder structure
  POST /api/files/folders
  Body: { folderName: "CS201 Materials", parentFolderId: null }
  Result → folder_id: 1

  POST /api/files/folders
  Body: { folderName: "Lecture Notes", parentFolderId: 1 }
  Result → folder_id: 2, parent_folder_id: 1

Step 2: Upload file to folder
  POST /api/files/upload
  Body: { file: <document.pdf>, folderId: 2 }
  Result → file_id: 30, folder_id: 2, uploaded_by: 10

Step 3: File versioning
  POST /api/files/30/versions
  Body: { file: <document_v2.pdf> }
  Result → New version created, old version preserved

Step 4: Share file with specific user or role
  POST /api/files/30/permissions
  Body: { userId: 20, permissionType: "READ" }

Step 5: Browse folder tree
  GET /api/files/folders/1/tree
  Result → Full nested hierarchy of folders and files

Step 6: Download file
  GET /api/files/30/download
```

**Linking Chain:**
```
Folder(1) "CS201 Materials"
  └── Folder(2) "Lecture Notes"     (parent_folder_id: 1)
        └── File(30) "document.pdf" (folder_id: 2)
              ├── uploaded_by: 10    → User
              ├── FileVersion(s)     → version history
              └── FilePermission(s)  → access control
                    ├── user_id/role_id → who has access
                    └── permission_type → READ/WRITE/DELETE/SHARE
```

---

### Scenario 17: Announcements

**Who:** Instructor / Admin  
**Goal:** Broadcast announcements to courses or the whole system.

```
Step 1: Create announcement
  POST /api/announcements
  Body: {
    courseId: 1,                     ← null for system-wide
    title: "Class Cancelled Tomorrow",
    content: "Due to weather conditions...",
    announcementType: "urgent",
    priority: "high",
    targetAudience: "students",
    isPublished: true
  }
  Result → announcement_id: 1, course_id: 1, created_by: 10

Step 2: Schedule for future
  PATCH /api/announcements/1/schedule
  Body: { publishAt: "2025-10-15T08:00:00" }

Step 3: Students view announcements
  GET /api/announcements?courseId=1
  Result → Published announcements for the course, view_count incremented

Step 4: Pin important announcement
  PATCH /api/announcements/1/pin
  → Pinned announcements appear at the top

Step 5: Analytics
  GET /api/announcements/1/analytics
  → View count, engagement metrics
```

---

## 5. How Everything Is Linked — The Big Picture

### Chain 1: Academic Hierarchy
```
Campus ──> Department ──> Course ──> CourseSection ──> CourseSchedule
                │                        │
                └──> Program             └──> Semester
```

### Chain 2: People → Courses
```
User ──(user_roles)──> Role (STUDENT / INSTRUCTOR / TA / ADMIN)
  │
  ├──(course_enrollments)──> CourseSection ──> Course    [Student]
  ├──(course_instructors)──> CourseSection ──> Course    [Instructor]
  └──(course_tas)──────────> CourseSection ──> Course    [TA]
```

### Chain 3: Course → Content
```
Course ──> CourseMaterial ──> File (document/slide)
  │              │
  │              └──> YouTube URL (video)
  │
  └──> LectureSectionLab (course structure)
             └──> CourseMaterial (optional link)
```

### Chain 4: Course → Assessments → Grades
```
Course ──> Assignment ──> AssignmentSubmission ──> Grade
  │                            └── File
  │
  ├──> Quiz ──> QuizQuestion ──> QuizAttempt ──> QuizAnswer ──> Grade
  │                  └── QuizDifficultyLevel
  │
  └──> Lab ──> LabInstruction
         ├──> LabSubmission ──> Grade
         └──> LabAttendance
```

### Chain 5: Course → Communication
```
Course ──> CourseChatThread ──> ChatMessage (discussions)
  │
  ├──> CommunityPost ──> CommunityComment ──> CommunityReaction
  │
  └──> Announcement
```

### Chain 6: Assessment → Grade → GPA
```
AssignmentSubmission.grade ──┐
QuizAttempt.score ───────────┼──> Grade(s) ──> GpaCalculation ──> Transcript
LabSubmission.grade ─────────┘         │
                                       └── GradeComponent ──> RubricCriteria ──> Rubric
```

### Chain 7: Scheduling
```
CourseSection ──> CourseSchedule (weekly class times)
Course ──> ExamSchedule (exams)
User ──> CalendarEvent (personal + course events)
```

### Chain 8: Infrastructure
```
User ──> File (uploads)
File ──> Folder (organization)
File ──> FileVersion (versioning)
File ──> FilePermission (access control)
File ──> CourseMaterial (linked to course content)
File ──> AssignmentSubmission (student work)
File ──> LabSubmission (lab work)
File ──> LabInstruction (lab materials)
```

---

## 6. Gaps & Missing Features

### 🔴 Critical Gaps

| # | Gap | Details | Impact |
|---|-----|---------|--------|
| 1 | **No Auto-Notifications** | When an instructor publishes an assignment, creates a grade, or posts an announcement, NO notification is automatically sent to students. Notifications exist but must be manually triggered via `POST /api/notifications/send` or by calling `createNotification()` in code. | Students won't know about new assignments/grades unless they check manually |
| 2 | **Email Verification Disabled** | `email-verification.entity.ts` exists but on registration `emailVerified` is hardcoded to `true` (auth.service.ts line 71). No verification email is sent, no verification endpoint exists. | Anyone can register with any email address |
| 3 | **No Student Progress Tracking** | There is no table or logic to track which course materials a student has viewed/completed. No `viewed_materials`, `student_progress`, or `completion_tracking` entity exists. | Cannot show completion percentage, cannot identify struggling students |

### 🟡 Medium Gaps

| # | Gap | Details | Impact |
|---|-----|---------|--------|
| 4 | **Missing ORM Relations on Grade** | `grade.entity.ts` has `quiz_id` and `lab_id` as plain columns WITHOUT `@ManyToOne` decorators. Only `assignment_id` has a proper ORM relation. This means you cannot eager-load quiz/lab data when querying grades. | Requires manual JOIN queries for quiz/lab grade details |
| 5 | **Missing ORM Relations (14 total)** | Multiple entities have FK columns without ORM decorators: `notification.user_id`, `notification.announcement_id`, `chat-message.user_id`, `chat-message.endorsed_by`, `lab-submission.user_id`, `lab-submission.file_id`, `lab-attendance.user_id`, `lab-attendance.marked_by`, `scheduled-notification.user_id`, `notification-preference.user_id`, `message-participant.user_id` | Cannot use TypeORM relation features (eager loading, cascading) for these |
| 6 | **Calendar Not Auto-Populated** | Calendar events must be manually created. No auto-generation from course schedules. External calendar sync (Google/Outlook) has only skeleton code with TODO comments. | Students must manually track their schedule |
| 7 | **No Video File Validation** | YouTube upload endpoint (`POST /youtube/upload` and `POST /api/courses/:id/materials/video`) does not validate file type, size, or format before sending to YouTube. | Server could waste bandwidth uploading invalid files to YouTube |
| 8 | **No Course Completion Workflow** | `course_enrollments.status` has a `COMPLETED` value and `completed_at` field, but there is no automated workflow to transition from `enrolled` to `completed` when all requirements are met. | Courses must be manually marked as completed |

### 🟢 Minor Gaps

| # | Gap | Details | Impact |
|---|-----|---------|--------|
| 9 | **No Video Watch Analytics** | YouTube videos are embedded but there's no tracking of how long students watched, whether they completed the video, or view counts on the material level. | Cannot assess student engagement with video content |
| 10 | **Dual Instructor Tracking** | `course_sections` has no direct `instructor_id` column, instructors are tracked via `course_instructors` table (which is correct). However, the original DB schema may have both, creating potential data inconsistency. | Need to verify DB schema matches ORM entities |
| 11 | **No Prerequisite Auto-Check on Material Access** | While enrollment validates prerequisites, there's no check preventing students from accessing materials of courses they haven't enrolled in (only `isPublished` filtering). | Relies on frontend to restrict access |
| 12 | **Discussion Thread Not ORM-Linked to Course** | `course_chat_threads.course_id` exists as a column but the thread entity may not have a full ORM `@ManyToOne` relation to Course. | Cannot eager-load course data with threads |

### Summary of What Works vs What's Missing

| Feature | Implemented? | Auto-Linked? | Notes |
|---------|:---:|:---:|-------|
| Campus/Dept/Course/Section setup | ✅ | ✅ | Full hierarchy |
| Instructor assignment to sections | ✅ | ✅ | Via course_instructors |
| Student enrollment with prereq check | ✅ | ✅ | Schedule conflict detection too |
| YouTube video upload → Course material | ✅ | ✅ | Full integration in materials service |
| Document/Slide upload → Course material | ✅ | ✅ | Via files + materials |
| Course structure (weeks/lectures) | ✅ | ✅ | Links to materials optionally |
| Assignments → Submission → Grading | ✅ | ✅ | Creates grade records |
| Quizzes → Attempt → Auto-grading | ✅ | ✅ | MCQ auto-graded |
| Labs → Submission → Grading | ✅ | ✅ | Includes lab attendance |
| Attendance tracking | ✅ | ✅ | Auto-creates records for enrolled students |
| Grade aggregation → GPA | ✅ | ⚠️ | Works but quiz/lab not ORM-linked |
| Discussions (chat threads) | ✅ | ⚠️ | Missing some ORM relations |
| Community (forum posts) | ✅ | ✅ | Full comment/reaction support |
| Real-time messaging (WebSocket) | ✅ | ✅ | Typing indicators, read receipts |
| Announcements | ✅ | ✅ | Scheduling, pinning, analytics |
| File management | ✅ | ✅ | Versioning, permissions, folders |
| Auto-notifications on events | ❌ | ❌ | Must be manually triggered |
| Email verification | ❌ | ❌ | Entity exists but bypassed |
| Student progress tracking | ❌ | ❌ | Not implemented at all |
| Calendar auto-population | ❌ | ❌ | Manual creation only |
| External calendar sync | ❌ | ❌ | Skeleton code only |
| Video watch analytics | ❌ | ❌ | No tracking |
| Course completion workflow | ❌ | ❌ | Manual status change only |
| YouTube upload file validation | ❌ | ❌ | No validation before upload |

---

> **Document generated from codebase analysis of the EduVerse backend (NestJS + TypeORM + MySQL). All entity names, endpoints, and relationships verified against source code.**
