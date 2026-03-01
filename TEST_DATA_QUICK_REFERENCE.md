# Test Data Quick Reference

## Summary Statistics

| Component | Count | Details |
|-----------|-------|---------|
| **Users** | 50+ | 5 Admins, 2 IT Admins, 10 Instructors, 3 TAs, 30 Students |
| **Campuses** | 3 | Main, Downtown, Online |
| **Departments** | 6 | CS, Engineering, Business, Data Science, Arts, Science |
| **Programs** | 12 | Mix of Bachelor, Master, Diploma, Certificate |
| **Semesters** | 4 | Fall 2024, Spring 2025 (active), Summer 2025, Fall 2025 |
| **Courses** | 18 | CS, Engineering, Business, Data Science, Arts, Science |
| **Course Sections** | 10 | Multiple sections per course |
| **Course Schedules** | 10 | MWF and TTh patterns |
| **Prerequisites** | 7 | Prerequisite chains established |
| **Enrollments** | 48 | ~10 students per section |
| **Instructors** | 10 | Assigned to sections |
| **TAs** | 5 | Supporting courses |
| **Assignments** | 10 | Homework, projects, labs, quizzes |
| **Submissions** | 10 | Mix of graded and pending |
| **Quizzes** | 6 | With time limits and point values |
| **Quiz Questions** | 19 | MC, T/F, Short Answer types |
| **Attendance Sessions** | 10 | Class and lab sessions |
| **Attendance Records** | 10 | Present, late, absent statuses |
| **Grades** | 10 | Assignment and quiz scores |
| **Announcements** | 5 | Course and campus-wide |
| **Messages** | 5 | Two-way conversations |
| **Message Participants** | 10 | Thread participants |
| **Notifications** | 8 | Various notification types |

## Test User Accounts

### Admin Users
```
admin.ahmed@eduverse.edu.eg (ID: 1)
admin.fatima@eduverse.edu.eg (ID: 2)
admin.karim@eduverse.edu.eg (ID: 3)
admin.leila@eduverse.edu.eg (ID: 4)
admin.samir@eduverse.edu.eg (ID: 5)
```

### IT Admin Users
```
itadmin.hani@eduverse.edu.eg (ID: 6)
itadmin.dina@eduverse.edu.eg (ID: 7)
```

### Instructor Users
```
dr.ibrahim.ali@eduverse.edu.eg (ID: 8) - CS101, teaches Section 01
prof.amira.hussein@eduverse.edu.eg (ID: 9) - CS101, teaches Section 02
dr.tamer.zahran@eduverse.edu.eg (ID: 10) - CS201, teaches Section 01
prof.noor.rashid@eduverse.edu.eg (ID: 11) - BUS101
dr.youssef.shaker@eduverse.edu.eg (ID: 12) - CS202, teaches Section 01
prof.huda.amin@eduverse.edu.eg (ID: 13) - CS201, teaches Section 02
dr.adel.fathy@eduverse.edu.eg (ID: 14) - CS301
prof.rania.ahmed@eduverse.edu.eg (ID: 15) - CS302
dr.moustafa.ali@eduverse.edu.eg (ID: 16) - DS101
prof.yasmine.salem@eduverse.edu.eg (ID: 17) - AH101
```

### TA Users
```
ta.omar.hassan@eduverse.edu.eg (ID: 18) - Supports CS101 sections
ta.layla.karim@eduverse.edu.eg (ID: 19) - Supports CS101 & CS201
ta.salim.noor@eduverse.edu.eg (ID: 20) - Supports CS201
```

### Student Users (IDs 21-50)
```
student.ali.youssef@eduverse.edu.eg (ID: 21)
student.maya.ibrahim@eduverse.edu.eg (ID: 22)
student.zain.ahmed@eduverse.edu.eg (ID: 23)
... (17 more students)
```

**All users**:
- Password: `password123`
- Password Hash: `$2y$10$N9qo8uLOickgx2ZMRZoMye`
- Email verified: Yes
- Status: Active
- Last login: Feb 6-15, 2025

## Data by Campus

### Campus 1: Main Campus (ID: 1)
- Users: 20
- Departments: 3 (CS, Engineering, Business)
- Active sections: 6
- Key courses: CS101, CS201, CS202, ENG101, BUS101

### Campus 2: Downtown Campus (ID: 2)
- Users: 18
- Departments: 2 (Data Science, Arts & Humanities)
- Active sections: 3
- Key courses: DS101, DS201, AH101, AH102

### Campus 3: Online Campus (ID: 3)
- Users: 12
- Departments: 1 (Science)
- Active sections: 1
- Key courses: SCI101, SCI102

## Active Course Sections (Spring 2025)

| Section | Course | Instructor | Capacity | Enrolled | Status |
|---------|--------|-----------|----------|----------|--------|
| CS101-01 | Intro to CS | Dr. Ibrahim Ali (ID: 8) | 50 | 45 | Open |
| CS101-02 | Intro to CS | Prof. Amira Hussein (ID: 9) | 50 | 48 | Full |
| CS201-01 | Data Structures | Dr. Tamer Zahran (ID: 10) | 40 | 35 | Open |
| CS201-02 | Data Structures | Prof. Huda Amin (ID: 13) | 40 | 38 | Open |
| CS202-01 | OOP | Dr. Youssef Shaker (ID: 12) | 45 | 40 | Open |
| CS301-01 | Database Systems | Dr. Adel Fathy (ID: 14) | 35 | 32 | Open |
| CS302-01 | Web Development | Prof. Rania Ahmed (ID: 15) | 40 | 38 | Open |
| BUS101-01 | Principles of Mgmt | Prof. Noor Rashid (ID: 11) | 50 | 45 | Open |
| DS101-01 | Statistics | Dr. Moustafa Ali (ID: 16) | 45 | 42 | Open |
| AH101-01 | English Literature | Prof. Yasmine Salem (ID: 17) | 35 | 28 | Open |

## Sample Queries

### Get all students enrolled in CS101
```sql
SELECT u.user_id, u.first_name, u.last_name, u.email
FROM users u
JOIN course_enrollments ce ON u.user_id = ce.student_id
JOIN course_sections cs ON ce.section_id = cs.section_id
JOIN courses c ON cs.course_id = c.course_id
WHERE c.course_code = 'CS101' AND ce.status = 'enrolled';
```

### Get instructor's section enrollment summary
```sql
SELECT c.course_name, cs.section_number, COUNT(ce.student_id) as enrolled
FROM course_sections cs
JOIN courses c ON cs.course_id = c.course_id
JOIN course_instructors ci ON cs.section_id = ci.section_id
LEFT JOIN course_enrollments ce ON cs.section_id = ce.section_id
WHERE ci.instructor_user_id = 8  -- Dr. Ibrahim Ali
GROUP BY cs.section_id;
```

### Get pending assignments for student
```sql
SELECT a.assignment_title, a.total_points, a.due_date
FROM assignments a
WHERE a.section_id IN (
  SELECT section_id FROM course_enrollments WHERE student_id = 21
)
AND a.assignment_id NOT IN (
  SELECT assignment_id FROM assignment_submissions WHERE student_id = 21
);
```

### Get student's current grades
```sql
SELECT g.component_type, a.assignment_title, g.score, g.max_score, g.letter_grade
FROM grades g
LEFT JOIN assignments a ON g.component_id = a.assignment_id
WHERE g.student_id = 21 AND g.section_id IN (
  SELECT section_id FROM course_enrollments WHERE student_id = 21
)
ORDER BY g.graded_at DESC;
```

### Get classroom schedule for a day
```sql
SELECT 
  c.course_code,
  cs.section_number,
  cs2.start_time,
  cs2.end_time,
  cs2.building,
  cs2.room_number
FROM course_schedules cs2
JOIN course_sections cs ON cs2.section_id = cs.section_id
JOIN courses c ON cs.course_id = c.course_id
WHERE cs2.day_of_week = 'Monday'
ORDER BY cs2.start_time;
```

## Import Instructions

### Option 1: Command Line
```bash
mysql -u root -p eduverse_db < COMPREHENSIVE_TEST_DATA.sql
```

### Option 2: From MySQL Console
```sql
USE eduverse_db;
SOURCE COMPREHENSIVE_TEST_DATA.sql;
```

### Option 3: MySQL Workbench
1. File → Open SQL Script
2. Select COMPREHENSIVE_TEST_DATA.sql
3. Execute (Ctrl+Shift+Enter)

## Verify Import Success

```sql
-- Check total records imported
SELECT 'Users' as table_name, COUNT(*) as count FROM users
UNION
SELECT 'Courses', COUNT(*) FROM courses
UNION
SELECT 'Enrollments', COUNT(*) FROM course_enrollments
UNION
SELECT 'Assignments', COUNT(*) FROM assignments
UNION
SELECT 'Submissions', COUNT(*) FROM assignment_submissions
UNION
SELECT 'Quizzes', COUNT(*) FROM quizzes
UNION
SELECT 'Grades', COUNT(*) FROM grades;

-- Verify relationships
SELECT COUNT(*) as enrollment_count FROM course_enrollments;  -- Should be 48
SELECT COUNT(*) as assignment_count FROM assignments;  -- Should be 10
SELECT COUNT(*) as grade_count FROM grades;  -- Should be 10
```

## Testing Scenarios

### Student Workflow
1. Login as `student.ali.youssef@eduverse.edu.eg`
2. View enrolled courses (3-5 courses)
3. View assignments and due dates
4. View grades and quiz results
5. Check attendance record
6. Read announcements
7. Send message to instructor

### Instructor Workflow
1. Login as `dr.ibrahim.ali@eduverse.edu.eg`
2. View sections (2 sections: CS101-01, CS101-02)
3. View enrolled students (45-48 per section)
4. View student submissions
5. Grade assignments/quizzes
6. Post announcements
7. Take attendance

### Admin Workflow
1. Login as `admin.ahmed@eduverse.edu.eg`
2. View all users (50+)
3. View all campuses (3)
4. View all departments (6)
5. View course offerings (18)
6. View enrollment statistics
7. Manage system announcements

## Notes

- All data is interconnected and realistic
- Test data supports multiple concurrent scenarios
- Data uses Feb 2025 timestamps (can be updated to current date)
- No actual personal data (all fictitious)
- Safe for production database testing
- Ready for performance testing and load simulation

---

**For full details, see**: TEST_DATA_README.md
