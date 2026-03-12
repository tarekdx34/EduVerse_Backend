# EduVerse Comprehensive Test Data

## Overview

This document describes the comprehensive test data generated for the EduVerse database. The data is organized in 5 priority levels following a hierarchical structure where foundational data is created first, followed by academic structure, enrollments, activities, and finally communication features.

**File**: `COMPREHENSIVE_TEST_DATA.sql`

## Quick Start

### Execute the Test Data Script

```bash
# Using MySQL CLI
mysql -u root -p eduverse_db < COMPREHENSIVE_TEST_DATA.sql

# Or from within MySQL
mysql> USE eduverse_db;
mysql> SOURCE COMPREHENSIVE_TEST_DATA.sql;
```

### Reset and Reimport

The script uses `INSERT IGNORE` statements, making it safe to run multiple times. To completely reset:

```bash
# Delete all test data first
mysql> TRUNCATE TABLE notifications;
mysql> TRUNCATE TABLE message_participants;
mysql> TRUNCATE TABLE messages;
mysql> TRUNCATE TABLE announcements;
mysql> TRUNCATE TABLE grades;
mysql> TRUNCATE TABLE attendance_records;
mysql> TRUNCATE TABLE attendance_sessions;
mysql> TRUNCATE TABLE quiz_questions;
mysql> TRUNCATE TABLE quizzes;
mysql> TRUNCATE TABLE assignment_submissions;
mysql> TRUNCATE TABLE assignments;
mysql> TRUNCATE TABLE course_tas;
mysql> TRUNCATE TABLE course_instructors;
mysql> TRUNCATE TABLE course_enrollments;
mysql> TRUNCATE TABLE course_prerequisites;
mysql> TRUNCATE TABLE course_schedules;
mysql> TRUNCATE TABLE course_sections;
mysql> TRUNCATE TABLE courses;
mysql> TRUNCATE TABLE user_roles;
mysql> TRUNCATE TABLE users;
mysql> TRUNCATE TABLE programs;
mysql> TRUNCATE TABLE departments;
mysql> TRUNCATE TABLE semesters;
mysql> TRUNCATE TABLE campuses;

# Then run the script again
```

---

## Data Structure

### Priority 1: Core Data (Foundation)

#### Users (50+)
- **5 Admin Users**: System administrators with full access
- **2 IT Admin Users**: IT support staff
- **10 Instructors**: Faculty members teaching courses (Dr./Prof.)
- **3 TAs**: Teaching assistants
- **30 Students**: Undergraduate and graduate students

**Distribution**:
- Campus 1 (Main): 20 users
- Campus 2 (Downtown): 18 users
- Campus 3 (Online): 12 users

**Test Credentials**:
- Email pattern: `role.firstname@eduverse.edu.eg`
- Password hash: `$2y$10$N9qo8uLOickgx2ZMRZoMye` (bcrypt hash of 'password123')
- Status: All active with verified emails
- Last login: Recent dates (Feb 11-15, 2025)

#### Campuses (3)
1. **Main Campus** (MAIN)
   - Cairo, Egypt
   - Primary location with largest user base
   
2. **Downtown Campus** (DT)
   - Giza, Egypt
   - Secondary location
   
3. **Online Campus** (ONLINE)
   - Virtual/Global
   - For distance learning students

#### Departments (6)
- Computer Science (CS) - Main Campus
- Engineering (ENG) - Main Campus
- Business Administration (BUS) - Main Campus
- Data Science (DS) - Downtown Campus
- Arts and Humanities (AH) - Downtown Campus
- Science (SCI) - Online Campus

#### Programs (12)
- **Computer Science**: BS (4 yrs), MS (2 yrs)
- **Engineering**: BS Mechanical (4 yrs), MS Electrical (2 yrs)
- **Business**: BS Administration (4 yrs), MBA (2 yrs)
- **Data Science**: BS Data Science (4 yrs), Certificate (1 yr)
- **Arts**: BA English (4 yrs), BA Arabic (4 yrs)
- **Science**: BS Mathematics (4 yrs), BS Physics (4 yrs)

#### Semesters (4)
- Fall 2024 (completed)
- Spring 2025 (active) - Current semester for test data
- Summer 2025 (upcoming)
- Fall 2025 (upcoming)

---

### Priority 2: Academic Structure

#### Courses (18)
Diverse courses across all departments covering:

**Computer Science**:
- CS101: Introduction to Computer Science (Freshman)
- CS201: Data Structures (Sophomore)
- CS202: Object-Oriented Programming (Sophomore)
- CS301: Database Systems (Junior)
- CS302: Web Development (Junior)
- CS401: Algorithms and Complexity (Senior)

**Engineering**:
- ENG101: Engineering Mathematics I (Freshman)
- ENG201: Circuit Analysis (Sophomore)
- ENG202: Thermodynamics (Sophomore)

**Business**:
- BUS101: Principles of Management (Freshman)
- BUS202: Business Finance (Sophomore)
- BUS401: Strategic Management (Senior)

**Data Science**:
- DS101: Statistics for Data Science (Freshman)
- DS201: Machine Learning Basics (Sophomore)

**Arts & Humanities**:
- AH101: English Literature I (Freshman)
- AH102: Arabic Language Skills (Freshman)

**Science**:
- SCI101: Calculus I (Freshman)
- SCI102: General Physics I (Freshman)

**Credits**: 3-4 credits per course

#### Course Sections (10)
Multiple sections per course to demonstrate:
- Multiple instructors
- Different capacities
- Varying enrollment levels
- Mixed enrollment status (open, full, closed)

**Example**: CS101 has 2 sections
- Section 01: 45/50 students enrolled
- Section 02: 48/50 students enrolled (full)

#### Course Schedules (10)
Meeting times demonstrate:
- Monday/Wednesday/Friday patterns
- Tuesday/Thursday patterns
- Various time slots (9:00-10:30, 11:00-12:30, 13:00-14:30, etc.)
- Different buildings and rooms

#### Course Prerequisites (7)
Prerequisite chains showing progression:
- CS101 → CS201 (Data Structures requires Introduction)
- CS101 → CS202 (OOP requires Introduction)
- CS201 → CS301 (Database requires Data Structures)
- CS201 → CS401 (Algorithms requires Data Structures)
- CS202 → CS302 (Web Dev requires OOP)
- ENG101 → ENG201 (Circuits requires Math)
- DS101 → DS201 (ML requires Statistics)

---

### Priority 3: Enrollments & Assignments

#### Course Enrollments (48)
Students enrolled across sections:
- Each CS101 section has 45-48 enrolled students
- Each CS201 section has 35-38 enrolled students
- Cross-campus student distribution
- Enrollment status: All "enrolled"
- Grades not yet assigned (ongoing semester)

#### Course Instructors (10)
Each section has assigned instructor:
- Instructors teaching 1-2 sections
- Dr. Ibrahim Ali (ID 8): CS101 Section 01
- Prof. Amira Hussein (ID 9): CS101 Section 02
- Distribution across departments

#### Course TAs (5)
Teaching assistants assigned to support:
- Some TAs assist multiple sections
- Omar Hassan, Layla Karim, Salim Noor
- Support hours during lab and recitation sessions

#### Assignments (10)
Diverse assignment types:
- **Homework**: Programming basics, SQL queries (100 pts)
- **Projects**: Data structures, web applications (150-200 pts)
- **Lab**: OOP design implementation (120 pts)
- **Quizzes**: Midterm assessments (50 pts)
- **Essays**: Literary analysis (100 pts)

**Due Dates**: Spread across February-March 2025

#### Assignment Submissions (10)
Student submissions showing:
- On-time submissions with grades (92-95/100)
- Graded submissions with instructor feedback
- Recent pending submissions (not yet graded)
- Realistic feedback comments

---

### Priority 4: Academic Activities

#### Quizzes (6)
- Quiz 1-2: CS101 (Intro concepts, Control flow)
- Quiz 1: CS201 (Arrays & Linked Lists)
- Quiz 1: CS202 (OOP Principles)
- Quiz 1: DS101 (Statistical Concepts)

**Quiz Features**:
- Time limits: 15-30 minutes
- Points: 20-25
- Shuffle questions: Enabled/Disabled
- Show answers: Yes/No variation

#### Quiz Questions (19)
Question variety:
- Multiple choice (common)
- True/False (quick assessment)
- Short answer (concept explanation)
- Points: 4-5 per question

**Examples**:
- "What is a variable in programming?"
- "Explain what polymorphism means"
- "Describe inheritance with an example"

#### Attendance Sessions (10)
Session details:
- Class sessions (regular classes)
- Lab sessions (practical work)
- Scheduled across week Feb 3-10, 2025
- Duration: 1-1.5 hours

#### Attendance Records (10)
Student attendance tracking:
- **Present**: 7 records (with check-in/out times)
- **Late**: 1 record (arrival after class start)
- **Absent**: 1 record
- **Not marked**: 1 record (missing data)

Realistic check-in patterns (before/at class start)

#### Grades (10)
Component-based grading:
- Assignment grades: 85-95
- Quiz grades: 75-95
- Letter grades assigned (A, A-, B+, B, B-, C+)
- Percentage calculated (75-95%)
- Grader information tracked
- Grading dates in Feb 2025

---

### Priority 5: Communication

#### Announcements (5)
Course and campus-wide announcements:
1. Course welcome announcement
2. Assignment release notice
3. Campus WiFi maintenance alert
4. Midterm exam schedule
5. Office hours extension

**Properties**:
- Priority levels: medium, high
- Target audience: all, students, instructors
- Published: Yes
- View counts: 23-120 views
- Published dates: Jan 15 - Feb 13, 2025

#### Messages (5)
Two-way conversations:
1. "Questions about Assignment 1" with reply
2. "Course Material Request" with reply
3. "Grade Discussion" (awaiting reply)

**Message Flow**:
- Student → Instructor
- Instructor → Student (reply)
- Topics: coursework, materials, grades

#### Message Participants (10)
Message thread participation:
- Sender and recipient links
- Read/unread status tracking
- Participant timestamps

#### Notifications (8)
System notifications for users:
- **Reminder**: Assignment due soon (2)
- **Grade**: Grade posted (2)
- **Announcement**: New course announcement (1)
- **Warning**: Attendance alert (1)
- **Info**: Quiz available (1)
- **Message**: Message received (1)

**Read Status**: Mix of read and unread (real engagement pattern)

---

## Data Characteristics

### Realistic Elements

1. **Names**: Mix of Arabic (Ahmed, Fatima, Karim) and English names
2. **Email Format**: Professional institutional email pattern
3. **Timestamps**: Chronological progression through semester (Jan-Feb 2025)
4. **Phone Numbers**: Egyptian country code format (+20-100-xxx-xxxx)
5. **Status Values**: Realistic status enums (active, enrolled, submitted, etc.)
6. **Grade Patterns**: Realistic score distributions (75-95 range)

### Interconnected Data

- Students enrolled in courses taught by instructors
- Assignments created in courses where students are enrolled
- Grades recorded for submissions from enrolled students
- Attendance tracked for enrolled students
- Notifications sent to relevant users

### Test Scenarios Supported

1. **Student Dashboard**
   - 48 course enrollments
   - 10 assignment submissions
   - 8 personal notifications
   - 3 messages in conversation

2. **Instructor Dashboard**
   - 10 sections with students
   - 10 assignments to grade
   - 10 attendance records to review
   - 5 messages from students

3. **Admin Dashboard**
   - 50 users across 3 campuses
   - 6 departments
   - 12 programs
   - 4 semesters

4. **Analytics**
   - Course enrollment trends
   - Grade distribution data
   - Attendance patterns
   - Assignment submission tracking

---

## Default Login Credentials

All test users share the same password:

```
Password: password123
Hash: $2y$10$N9qo8uLOickgx2ZMRZoMye (bcrypt)
```

### Sample Users to Test

**Admins**:
```
Email: admin.ahmed@eduverse.edu.eg
Email: admin.fatima@eduverse.edu.eg
```

**Instructors**:
```
Email: dr.ibrahim.ali@eduverse.edu.eg
Email: prof.amira.hussein@eduverse.edu.eg
```

**Students**:
```
Email: student.ali.youssef@eduverse.edu.eg
Email: student.maya.ibrahim@eduverse.edu.eg
Email: student.zain.ahmed@eduverse.edu.eg
```

**TAs**:
```
Email: ta.omar.hassan@eduverse.edu.eg
Email: ta.layla.karim@eduverse.edu.eg
```

---

## Database Constraints Respected

All INSERT statements respect:
- Primary key constraints (no duplicate IDs)
- Foreign key relationships (campus_id, department_id, section_id, etc.)
- Unique constraints (email, campus_code, program_code, etc.)
- Enum values (status, role, priority, etc.)
- Data types and field lengths
- Nullable vs. NOT NULL constraints

Using `INSERT IGNORE` ensures safe re-execution without errors.

---

## Scale and Performance

- **Total Records**: 300+ across 23 tables
- **User Distribution**: Even across campuses
- **Enrollment Ratio**: ~10 students per section
- **Data Density**: Moderate (suitable for testing UI without overwhelming)

This scale is:
- ✅ Large enough to test pagination
- ✅ Large enough for realistic queries
- ✅ Small enough for quick data loading
- ✅ Suitable for development and QA testing

---

## Future Enhancements

To expand the test data:

1. Add more course sections (20-30 total)
2. Increase student enrollments (200+ total)
3. Add complete grade records (all assignments graded)
4. Include peer review submissions
5. Add study group participation
6. Add more quiz attempts and grades
7. Expand message threads
8. Add system activity logs

---

## Troubleshooting

### Import Fails with Foreign Key Error
Ensure tables are imported in the correct order (this script respects dependencies)

### Duplicate Email Error
The script uses `INSERT IGNORE`, so duplicates won't cause failure. If needed, clear users table first:
```sql
TRUNCATE TABLE users;
```

### Data Not Appearing
Verify the import completed:
```sql
SELECT COUNT(*) FROM users;
SELECT COUNT(*) FROM courses;
SELECT COUNT(*) FROM course_enrollments;
```

---

## Notes

- All test data uses realistic but fictitious names and email addresses
- No actual personal information is included
- All timestamps are set to Feb 2025 (adjustable for current term)
- The data follows a consistent academic calendar structure
- Ready for immediate use in development, testing, and demos

---

**Version**: 1.0  
**Last Updated**: February 2025  
**Generated For**: EduVerse Educational Management System
