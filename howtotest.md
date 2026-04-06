# EduVerse Frontend Integration Master Plan — Test-First Edition

**Last Updated**: 2026-03-15  
**Stack**: React (Vite) + NestJS Backend | **Base URL**: `http://localhost:8081`

---

## ✅ COMPLETED

- Phase 0 — Infrastructure
- Phase 1 — Auth + Layout + All 4 dashboard shells
- Phase 8 — WebSocket Messaging
- Course Management — Create/Edit/Delete course, multi-step modal (section + schedule + staff), instructor/TA assignment + display

---

## METHODOLOGY — TEST BEFORE INTEGRATING

Every task follows this exact workflow before writing a single line of frontend code:

### Step 1 — Test the endpoint

Paste into browser console (replace TOKEN):

```javascript
fetch('http://localhost:8081/api/ENDPOINT', {
  headers: { Authorization: 'Bearer TOKEN' },
})
  .then((r) => r.json())
  .then((d) => console.log(JSON.stringify(d, null, 2)));
```

For POST endpoints:

```javascript
fetch('http://localhost:8081/api/ENDPOINT', {
  method: 'POST',
  headers: {
    Authorization: 'Bearer TOKEN',
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({ ...payload }),
})
  .then((r) => r.json())
  .then((d) => console.log(JSON.stringify(d, null, 2)));
```

### Step 2 — Check the DB if needed

```sql
SELECT * FROM table_name LIMIT 5;
DESCRIBE table_name;
```

### Step 3 — Verify shape + decide

- Does it return the right fields?
- Is pagination wrapped in `{ data: [], total, page }` or flat array?
- Are IDs `id` or `courseId` or `userId`?
- Does it need a backend fix before frontend work starts?

### Step 4 — Write the Copilot prompt with real shapes

Only after steps 1-3, write the integration prompt with actual field names.

---

## NEXT UP — Phase 3: Student Enrollment Flow

### TASK: COURSE-03 — My Courses Sidebar

**Test first:**

```javascript
// Test 1: get my enrolled courses (log in as student first)
fetch('http://localhost:8081/api/enrollments/my-courses', {
  headers: { Authorization: 'Bearer STUDENT_TOKEN' },
})
  .then((r) => r.json())
  .then((d) => console.log(JSON.stringify(d, null, 2)));
```

```sql
-- Check enrollment table structure
SELECT * FROM course_enrollments LIMIT 5;
SELECT e.*, c.name, c.code FROM course_enrollments e
JOIN courses c ON e.course_id = c.id
WHERE e.user_id = 57 LIMIT 5;
```

**After testing** → Build `<MyCoursesSidebar />` with real field names.

---

### TASK: COURSE-04 — Available Courses

**Test first:**

```javascript
fetch('http://localhost:8081/api/enrollments/available', {
  headers: { Authorization: 'Bearer STUDENT_TOKEN' },
})
  .then((r) => r.json())
  .then((d) => console.log(JSON.stringify(d, null, 2)));
```

```sql
SELECT * FROM course_sections WHERE status = 'open' LIMIT 5;
```

**After testing** → Build `<AvailableCoursesPage />`.

---

### TASK: COURSE-05 — Enroll in Course

**Test first:**

```javascript
// Test enrollment
fetch('http://localhost:8081/api/enrollments/register', {
  method: 'POST',
  headers: {
    Authorization: 'Bearer STUDENT_TOKEN',
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({ sectionId: 1 }),
})
  .then((r) => r.json())
  .then((d) => console.log(JSON.stringify(d, null, 2)));
```

```sql
-- Check prerequisites table
SELECT * FROM course_prerequisites LIMIT 5;
-- Check if student meets prerequisites
SELECT * FROM course_enrollments WHERE user_id = 57;
```

**After testing** → Build `<EnrollButton />` with section picker modal.

---

### TASK: COURSE-06 — Drop Course

**Test first:**

```javascript
// Find enrollment ID first
fetch('http://localhost:8081/api/enrollments/my-courses', {
  headers: { Authorization: 'Bearer STUDENT_TOKEN' },
})
  .then((r) => r.json())
  .then((d) =>
    console.log(
      'enrollment IDs:',
      d.map((e) => e.enrollmentId || e.id),
    ),
  );

// Then test drop
fetch('http://localhost:8081/api/enrollments/ENROLLMENT_ID', {
  method: 'DELETE',
  headers: { Authorization: 'Bearer STUDENT_TOKEN' },
})
  .then((r) => r.json())
  .then(console.log);
```

**After testing** → Build `<DropCourseButton />`.

---

### TASK: COURSE-07 — Student Roster (Instructor view)

**Test first:**

```javascript
fetch('http://localhost:8081/api/enrollments/section/1/students', {
  headers: { Authorization: 'Bearer ADMIN_TOKEN' },
})
  .then((r) => r.json())
  .then((d) => console.log(JSON.stringify(d, null, 2)));
```

```sql
SELECT e.*, u.first_name, u.last_name, u.email
FROM course_enrollments e
JOIN users u ON e.user_id = u.user_id
WHERE e.section_id = 1;
```

**After testing** → Build `<StudentRosterTable />`.

---

### TASK: COURSE-08 — Waitlist

**Test first:**

```javascript
fetch('http://localhost:8081/api/enrollments/section/1/waitlist', {
  headers: { Authorization: 'Bearer ADMIN_TOKEN' },
})
  .then((r) => r.json())
  .then((d) => console.log(JSON.stringify(d, null, 2)));
```

**After testing** → Build `<WaitlistTable />`.

---

### TASK: COURSE-09 — Section Schedule View

**Test first:**

```javascript
fetch('http://localhost:8081/api/schedules/section/1', {
  headers: { Authorization: 'Bearer ADMIN_TOKEN' },
})
  .then((r) => r.json())
  .then((d) => console.log(JSON.stringify(d, null, 2)));
```

**After testing** → Build `<SectionScheduleView />`.

---

## Phase 4 — Course Materials + Structure

### TASK: MAT-01 — Course Structure

**Test first:**

```javascript
fetch('http://localhost:8081/api/courses/1/structure', {
  headers: { Authorization: 'Bearer ADMIN_TOKEN' },
})
  .then((r) => r.json())
  .then((d) => console.log(JSON.stringify(d, null, 2)));
```

```sql
SELECT * FROM lecture_section_labs WHERE course_id = 1 LIMIT 5;
```

---

### TASK: MAT-02 — Materials List

**Test first:**

```javascript
// As admin
fetch('http://localhost:8081/api/courses/1/materials', {
  headers: { Authorization: 'Bearer ADMIN_TOKEN' },
})
  .then((r) => r.json())
  .then((d) => console.log(JSON.stringify(d, null, 2)));

// As student (should only see published)
fetch('http://localhost:8081/api/courses/1/materials', {
  headers: { Authorization: 'Bearer STUDENT_TOKEN' },
})
  .then((r) => r.json())
  .then((d) => console.log(JSON.stringify(d, null, 2)));
```

```sql
SELECT * FROM course_materials WHERE course_id = 1 LIMIT 5;
```

---

### TASK: MAT-03 — Video Player (YouTube embed)

**Test first:**

```javascript
// Find a material with materialType = 'video'
fetch('http://localhost:8081/api/courses/1/materials', {
  headers: { Authorization: 'Bearer ADMIN_TOKEN' },
})
  .then((r) => r.json())
  .then((d) =>
    console.log(
      'video materials:',
      d.filter((m) => m.materialType === 'video'),
    ),
  );

// Get embed URL for a video material
fetch('http://localhost:8081/api/courses/1/materials/23/embed', {
  headers: { Authorization: 'Bearer ADMIN_TOKEN' },
})
  .then((r) => r.json())
  .then(console.log);
```

---

### TASK: MAT-04 — File Download

**Test first:**

```javascript
// Find a material with a fileId
fetch('http://localhost:8081/api/courses/2/materials/4/download', {
  headers: { Authorization: 'Bearer ADMIN_TOKEN' },
}).then((r) =>
  console.log('status:', r.status, 'type:', r.headers.get('content-type')),
);
```

---

### TASK: MAT-05 — File Upload

**Test first (check multer field name):**

```javascript
const formData = new FormData();
// Create a test file
const blob = new Blob(['test content'], { type: 'text/plain' });
formData.append('file', blob, 'test.txt');
formData.append('title', 'Test Upload');
formData.append('materialType', 'document');
formData.append('weekNumber', '1');

fetch('http://localhost:8081/api/courses/1/materials', {
  method: 'POST',
  headers: { Authorization: 'Bearer ADMIN_TOKEN' },
  body: formData,
})
  .then((r) => r.json())
  .then(console.log);
```

---

### TASK: MAT-06 — Video Upload (YouTube)

**Test first:**

```javascript
// Check if YouTube is configured
fetch('http://localhost:8081/youtube/auth', {
  headers: { Authorization: 'Bearer ADMIN_TOKEN' },
})
  .then((r) => r.json())
  .then(console.log);
```

```sql
-- Check if YouTube tokens are stored
SELECT * FROM youtube_tokens LIMIT 1;
-- or check env
```

---

## Phase 5 — Assignments + Quizzes + Labs

### TASK: ASGN-01 — Assignments List

**Test first:**

```javascript
fetch('http://localhost:8081/api/assignments?courseId=1', {
  headers: { Authorization: 'Bearer ADMIN_TOKEN' },
})
  .then((r) => r.json())
  .then((d) => console.log(JSON.stringify(d, null, 2)));
```

```sql
SELECT * FROM assignments WHERE course_id = 1 LIMIT 5;
```

---

### TASK: ASGN-02 — Assignment Detail

**Test first:**

```javascript
fetch('http://localhost:8081/api/assignments/1', {
  headers: { Authorization: 'Bearer ADMIN_TOKEN' },
})
  .then((r) => r.json())
  .then((d) => console.log(JSON.stringify(d, null, 2)));
```

---

### TASK: ASGN-03 — Submit Assignment

**Test first:**

```javascript
// Test text submission first (no file)
fetch('http://localhost:8081/api/assignments/1/submit', {
  method: 'POST',
  headers: {
    Authorization: 'Bearer STUDENT_TOKEN',
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({ submissionText: 'Test submission' }),
})
  .then((r) => r.json())
  .then(console.log);
```

```sql
SELECT * FROM assignment_submissions WHERE assignment_id = 1 LIMIT 5;
```

---

### TASK: ASGN-04 — My Submission

**Test first:**

```javascript
fetch('http://localhost:8081/api/assignments/1/submissions/my', {
  headers: { Authorization: 'Bearer STUDENT_TOKEN' },
})
  .then((r) => r.json())
  .then((d) => console.log(JSON.stringify(d, null, 2)));
```

---

### TASK: ASGN-05+06 — All Submissions + Grade

**Test first:**

```javascript
// List all submissions
fetch('http://localhost:8081/api/assignments/1/submissions', {
  headers: { Authorization: 'Bearer ADMIN_TOKEN' },
})
  .then((r) => r.json())
  .then((d) => console.log(JSON.stringify(d, null, 2)));

// Grade a submission (find submissionId first)
fetch('http://localhost:8081/api/assignments/1/submissions/1/grade', {
  method: 'PATCH',
  headers: {
    Authorization: 'Bearer ADMIN_TOKEN',
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({ score: 85, feedback: 'Good work', letterGrade: 'A' }),
})
  .then((r) => r.json())
  .then(console.log);
```

---

### TASK: QUIZ-01 — Quiz List

**Test first:**

```javascript
fetch('http://localhost:8081/quizzes?courseId=1', {
  headers: { Authorization: 'Bearer ADMIN_TOKEN' },
})
  .then((r) => r.json())
  .then((d) => console.log(JSON.stringify(d, null, 2)));
```

```sql
SELECT * FROM quizzes WHERE course_id = 1 LIMIT 5;
```

---

### TASK: QUIZ-02+03 — Quiz Attempt + Submit

**Test first:**

```javascript
// Start attempt
fetch('http://localhost:8081/quizzes/1/attempts/start', {
  method: 'POST',
  headers: {
    Authorization: 'Bearer STUDENT_TOKEN',
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({}),
})
  .then((r) => r.json())
  .then((d) => {
    console.log('attempt:', JSON.stringify(d, null, 2));
    window._attemptId = d.attemptId || d.id;
  });

// Submit attempt (use attemptId from above)
fetch(`http://localhost:8081/quizzes/attempts/${window._attemptId}/submit`, {
  method: 'POST',
  headers: {
    Authorization: 'Bearer STUDENT_TOKEN',
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({ answers: [] }),
})
  .then((r) => r.json())
  .then(console.log);
```

---

### TASK: LAB-01+02 — Labs List + Detail

**Test first:**

```javascript
fetch('http://localhost:8081/api/labs?courseId=1', {
  headers: { Authorization: 'Bearer ADMIN_TOKEN' },
})
  .then((r) => r.json())
  .then((d) => console.log(JSON.stringify(d, null, 2)));

fetch('http://localhost:8081/api/labs/3/instructions', {
  headers: { Authorization: 'Bearer ADMIN_TOKEN' },
})
  .then((r) => r.json())
  .then((d) => console.log(JSON.stringify(d, null, 2)));
```

---

## Phase 6 — Grades + Attendance

### TASK: GRADE-01 — My Grades

**Test first:**

```javascript
fetch('http://localhost:8081/api/grades/my', {
  headers: { Authorization: 'Bearer STUDENT_TOKEN' },
})
  .then((r) => r.json())
  .then((d) => console.log(JSON.stringify(d, null, 2)));
```

```sql
SELECT g.*, c.name as course_name
FROM grades g
JOIN courses c ON g.course_id = c.id
WHERE g.user_id = 57 LIMIT 10;
```

---

### TASK: GRADE-02 — GPA Widget

**Test first:**

```javascript
fetch('http://localhost:8081/api/grades/gpa/57', {
  headers: { Authorization: 'Bearer ADMIN_TOKEN' },
})
  .then((r) => r.json())
  .then((d) => console.log(JSON.stringify(d, null, 2)));
```

---

### TASK: GRADE-03 — Transcript

**Test first:**

```javascript
fetch('http://localhost:8081/api/grades/transcript/57', {
  headers: { Authorization: 'Bearer ADMIN_TOKEN' },
})
  .then((r) => r.json())
  .then((d) => console.log(JSON.stringify(d, null, 2)));
```

---

### TASK: ATT-01+02 — Attendance Sessions

**Test first:**

```javascript
// Create session
fetch('http://localhost:8081/attendance/sessions', {
  method: 'POST',
  headers: {
    Authorization: 'Bearer ADMIN_TOKEN',
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    sectionId: 1,
    sessionDate: '2026-03-15',
    sessionType: 'lecture',
    startTime: '09:00:00',
    endTime: '10:30:00',
  }),
})
  .then((r) => r.json())
  .then(console.log);

// List sessions
fetch('http://localhost:8081/attendance/sessions?sectionId=1', {
  headers: { Authorization: 'Bearer ADMIN_TOKEN' },
})
  .then((r) => r.json())
  .then((d) => console.log(JSON.stringify(d, null, 2)));
```

```sql
SELECT * FROM attendance_sessions LIMIT 5;
DESCRIBE attendance_sessions;
```

---

### TASK: ATT-03 — Batch Attendance

**Test first:**

```javascript
fetch('http://localhost:8081/attendance/records/batch', {
  method: 'POST',
  headers: {
    Authorization: 'Bearer ADMIN_TOKEN',
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    sessionId: 1,
    records: [
      { userId: 57, status: 'present' },
      { userId: 63, status: 'absent' },
    ],
  }),
})
  .then((r) => r.json())
  .then(console.log);
```

```sql
DESCRIBE attendance_records;
```

---

### TASK: ATT-04 — My Attendance (Student)

**Test first:**

```javascript
fetch('http://localhost:8081/attendance/my', {
  headers: { Authorization: 'Bearer STUDENT_TOKEN' },
})
  .then((r) => r.json())
  .then((d) => console.log(JSON.stringify(d, null, 2)));
```

---

## Phase 7 — Announcements + Discussions + Schedule

### TASK: ANN-01+02 — Announcements

**Test first:**

```javascript
// List
fetch('http://localhost:8081/api/announcements', {
  headers: { Authorization: 'Bearer ADMIN_TOKEN' },
})
  .then((r) => r.json())
  .then((d) => console.log(JSON.stringify(d[0], null, 2)));

// Create
fetch('http://localhost:8081/api/announcements', {
  method: 'POST',
  headers: {
    Authorization: 'Bearer ADMIN_TOKEN',
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    title: 'Test Announcement',
    content: 'Test content',
    courseId: 1,
    priority: 'medium',
  }),
})
  .then((r) => r.json())
  .then(console.log);
```

---

### TASK: DISC-01+02 — Discussions

**Test first:**

```javascript
fetch('http://localhost:8081/api/discussions?courseId=1', {
  headers: { Authorization: 'Bearer ADMIN_TOKEN' },
})
  .then((r) => r.json())
  .then((d) => console.log(JSON.stringify(d, null, 2)));

fetch('http://localhost:8081/api/discussions/3', {
  headers: { Authorization: 'Bearer ADMIN_TOKEN' },
})
  .then((r) => r.json())
  .then((d) => console.log(JSON.stringify(d, null, 2)));
```

---

### TASK: SCHED-01+02 — Schedule

**Test first:**

```javascript
fetch('http://localhost:8081/api/schedule/my/daily', {
  headers: { Authorization: 'Bearer STUDENT_TOKEN' },
})
  .then((r) => r.json())
  .then((d) => console.log(JSON.stringify(d, null, 2)));

fetch('http://localhost:8081/api/schedule/my/weekly', {
  headers: { Authorization: 'Bearer STUDENT_TOKEN' },
})
  .then((r) => r.json())
  .then((d) => console.log(JSON.stringify(d, null, 2)));
```

---

## Phase 9 — Notifications + Files + Community

### TASK: NOTIF-01+02 — Notifications

**Test first:**

```javascript
fetch('http://localhost:8081/api/notifications/unread-count', {
  headers: { Authorization: 'Bearer STUDENT_TOKEN' },
})
  .then((r) => r.json())
  .then(console.log);

fetch('http://localhost:8081/api/notifications', {
  headers: { Authorization: 'Bearer STUDENT_TOKEN' },
})
  .then((r) => r.json())
  .then((d) => console.log(JSON.stringify(d, null, 2)));
```

```sql
SELECT * FROM notifications WHERE user_id = 57 LIMIT 5;
DESCRIBE notifications;
```

---

### TASK: FILES-01+02 — Files

**Test first:**

```javascript
fetch('http://localhost:8081/api/files/recent', {
  headers: { Authorization: 'Bearer ADMIN_TOKEN' },
})
  .then((r) => r.json())
  .then((d) => console.log(JSON.stringify(d, null, 2)));

fetch('http://localhost:8081/api/files/folders/1', {
  headers: { Authorization: 'Bearer ADMIN_TOKEN' },
})
  .then((r) => r.json())
  .then((d) => console.log(JSON.stringify(d, null, 2)));
```

```sql
SELECT * FROM files LIMIT 5;
SELECT * FROM folders LIMIT 5;
DESCRIBE files;
```

---

### TASK: COMM-01+02 — Community

**Test first:**

```javascript
fetch('http://localhost:8081/api/community/global', {
  headers: { Authorization: 'Bearer ADMIN_TOKEN' },
})
  .then((r) => r.json())
  .then((d) => console.log(JSON.stringify(d, null, 2)));

fetch('http://localhost:8081/api/community/communities', {
  headers: { Authorization: 'Bearer ADMIN_TOKEN' },
})
  .then((r) => r.json())
  .then((d) => console.log(JSON.stringify(d, null, 2)));
```

---

## Phase 10 — Analytics + Reports + Search

### TASK: ANAL-01 — Analytics Dashboard

**Test first:**

```javascript
fetch('http://localhost:8081/api/analytics/dashboard', {
  headers: { Authorization: 'Bearer ADMIN_TOKEN' },
})
  .then((r) => r.json())
  .then((d) => console.log(JSON.stringify(d, null, 2)));

fetch('http://localhost:8081/api/analytics/courses/1', {
  headers: { Authorization: 'Bearer ADMIN_TOKEN' },
})
  .then((r) => r.json())
  .then((d) => console.log(JSON.stringify(d, null, 2)));
```

---

### TASK: SEARCH-01 — Global Search

**Test first:**

```javascript
fetch('http://localhost:8081/api/search?query=programming&page=1&limit=10', {
  headers: { Authorization: 'Bearer ADMIN_TOKEN' },
})
  .then((r) => r.json())
  .then((d) => console.log(JSON.stringify(d, null, 2)));
```

```sql
SELECT * FROM search_index LIMIT 5;
```

---

## Phase 11 — Tasks + Google Drive + YouTube

### TASK: TASKS-01+02 — Tasks

**Test first:**

```javascript
fetch('http://localhost:8081/api/tasks?page=1&limit=10', {
  headers: { Authorization: 'Bearer STUDENT_TOKEN' },
})
  .then((r) => r.json())
  .then((d) => console.log(JSON.stringify(d, null, 2)));

fetch('http://localhost:8081/api/tasks/upcoming?days=7', {
  headers: { Authorization: 'Bearer STUDENT_TOKEN' },
})
  .then((r) => r.json())
  .then((d) => console.log(JSON.stringify(d, null, 2)));
```

```sql
SELECT * FROM student_tasks WHERE user_id = 57 LIMIT 5;
DESCRIBE student_tasks;
```

---

## HOW TO USE THIS PLAN

For each task:

1. **Run the test snippets** in the browser console
2. **Run the SQL queries** in your MySQL client
3. **Share the output** here — I'll give you an exact Copilot prompt with real field names
4. **Paste the prompt** into Copilot Chat and implement
5. **Mark the task done** and move to the next one

Start with **COURSE-03** (My Courses Sidebar). Run the test, share the output.

---

## Test Accounts

| Role       | Email                        | Password      |
| ---------- | ---------------------------- | ------------- |
| Admin      | admin.tarek@example.com      | SecureP@ss123 |
| Instructor | instructor.tarek@example.com | SecureP@ss123 |
| Student    | student.tarek@example.com    | SecureP@ss123 |
| TA         | ta.tarek@example.com         | SecureP@ss123 |

## Endpoint Prefix Watch ⚠️

These do NOT use `/api/` prefix:

- Quizzes → `/quizzes/`
- Attendance → `/attendance/`
- YouTube → `/youtube/`
- Google Drive → `/google-drive/`
