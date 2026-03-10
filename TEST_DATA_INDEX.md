# EduVerse Test Data Suite - Complete Index

## 📦 What You Have

A complete, production-ready test data suite for the EduVerse educational management system database. This suite includes realistic data across 23 database tables with 300+ records organized in a hierarchical structure.

---

## 📂 Files Included

### 1. **COMPREHENSIVE_TEST_DATA.sql** (47.3 KB, 423 lines)
The main SQL script containing all INSERT statements.

**Contains:**
- 50+ users across 5 role types
- 3 campuses with full hierarchy
- 6 departments and 12 programs
- 4 semesters with realistic dates
- 18 courses with 10 sections
- Complete scheduling data
- 48 course enrollments
- 10 assignments with submissions
- 6 quizzes with 19 questions
- Attendance tracking (10 sessions, 10 records)
- Grade records for assessments
- Communication system data (announcements, messages, notifications)

**How to use:**
```bash
mysql -u root -p eduverse_db < COMPREHENSIVE_TEST_DATA.sql
```

Or within MySQL:
```sql
USE eduverse_db;
SOURCE COMPREHENSIVE_TEST_DATA.sql;
```

**Features:**
- ✅ Uses `INSERT IGNORE` for safe re-execution
- ✅ Respects all foreign key constraints
- ✅ Includes transaction handling
- ✅ Proper UTF-8 character set support
- ✅ Chronological data with realistic timestamps

---

### 2. **TEST_DATA_README.md** (13.5 KB, 384 lines)
Comprehensive documentation explaining all test data.

**Sections:**
1. **Overview** - Quick description and file location
2. **Quick Start** - Import instructions and reset procedures
3. **Data Structure** - Detailed breakdown of all 5 priority levels
   - Priority 1: Core Data (Users, Campuses, Departments, Programs, Semesters)
   - Priority 2: Academic Structure (Courses, Sections, Schedules, Prerequisites)
   - Priority 3: Enrollments & Assignments (Enrollments, Instructors, TAs, Assignments)
   - Priority 4: Academic Activities (Quizzes, Attendance, Grades)
   - Priority 5: Communication (Announcements, Messages, Notifications)
4. **Data Characteristics** - Realistic elements and interconnections
5. **Default Login Credentials** - Sample users for testing
6. **Database Constraints** - What's respected in the data
7. **Scale and Performance** - Data volume and testing suitability
8. **Future Enhancements** - Ideas for expanding the data
9. **Troubleshooting** - Common issues and solutions

**Best for:** Understanding the complete data structure and design

---

### 3. **TEST_DATA_QUICK_REFERENCE.md** (8.4 KB, 227 lines)
Quick lookup guide for common tasks.

**Contents:**
- **Summary Statistics Table** - All counts at a glance
- **Test User Accounts** - All 50+ users with roles
- **Data by Campus** - Distribution across locations
- **Active Course Sections** - Enrollment and status table
- **Sample Queries** - Ready-to-use SQL examples
- **Import Instructions** - 3 different methods
- **Verify Import Success** - Verification queries
- **Testing Scenarios** - Student, Instructor, and Admin workflows
- **Notes** - Key information

**Best for:** Quick lookups and getting started immediately

---

### 4. **VERIFICATION_QUERIES.sql** (17.7 KB, 511 lines)
37 SQL queries to verify and explore the test data.

**Query Categories:**
1. **Basic Verification** (4 queries)
   - Record counts by table
   
2. **User Data Verification** (4 queries)
   - User counts by role
   - Admin, instructor, student lists
   
3. **Campus & Structure Verification** (3 queries)
   - Campus overview with hierarchy
   - Departments by campus
   - Programs listing
   
4. **Academic Structure Verification** (5 queries)
   - Semester overview
   - Courses by department
   - Sections with enrollment
   - Prerequisites chain
   - Meeting schedules
   
5. **Enrollment Verification** (4 queries)
   - Enrollment summary
   - Student enrollments
   - Instructor assignments
   - TA assignments
   
6. **Assignment Verification** (3 queries)
   - Assignments summary
   - Submission status
   - Student submission tracking
   
7. **Quiz Verification** (2 queries)
   - Quiz overview
   - Question details
   
8. **Attendance Verification** (2 queries)
   - Sessions overview
   - Attendance by student
   
9. **Grades Verification** (2 queries)
   - Grade distribution
   - Student grades summary
   
10. **Communication Verification** (3 queries)
    - Announcements overview
    - Message threads
    - Notifications for users
    
11. **Advanced Queries** (3 queries)
    - Full instructor dashboard
    - Student performance summary
    - Course readiness check
    
12. **Data Integrity Checks** (4 queries)
    - Orphaned enrollments
    - Unenrolled students
    - Courses without sections
    - Unassigned instructors

**Best for:** Exploring data, validating integrity, and reporting

---

## 🚀 Getting Started

### Step 1: Import the Data
```bash
# Option A: Command line
mysql -u root -p eduverse_db < COMPREHENSIVE_TEST_DATA.sql

# Option B: Within MySQL
mysql -u root -p
mysql> USE eduverse_db;
mysql> SOURCE COMPREHENSIVE_TEST_DATA.sql;

# Option C: MySQL Workbench
File → Open SQL Script → COMPREHENSIVE_TEST_DATA.sql → Execute
```

### Step 2: Verify Import
```sql
-- Quick verification
SELECT COUNT(*) FROM users;           -- Should show 50+
SELECT COUNT(*) FROM courses;         -- Should show 18
SELECT COUNT(*) FROM course_enrollments;  -- Should show 48

-- Full verification with stats
SELECT 'Users' as table_name, COUNT(*) as count FROM users
UNION ALL
SELECT 'Courses', COUNT(*) FROM courses
UNION ALL
SELECT 'Enrollments', COUNT(*) FROM course_enrollments
UNION ALL
SELECT 'Assignments', COUNT(*) FROM assignments
UNION ALL
SELECT 'Grades', COUNT(*) FROM grades;
```

### Step 3: Test Login
```
Email: student.ali.youssef@eduverse.edu.eg
Password: password123
(All users use this same password)
```

---

## 📊 Data Summary

| Category | Count | Examples |
|----------|-------|----------|
| **Users** | 50+ | Admin, IT Admin, Instructor, TA, Student |
| **Campuses** | 3 | Main, Downtown, Online |
| **Departments** | 6 | CS, Engineering, Business, Data Science, Arts, Science |
| **Programs** | 12 | BS/MS Computer Science, BS/MS Engineering, etc. |
| **Semesters** | 4 | Fall 2024, Spring 2025 (active), Summer 2025, Fall 2025 |
| **Courses** | 18 | CS101, CS201, ENG101, BUS202, etc. |
| **Sections** | 10 | Multiple sections per course |
| **Enrollments** | 48 | ~10 students per section |
| **Assignments** | 10 | Homework, projects, labs, quizzes |
| **Submissions** | 10 | Mix of graded and pending |
| **Quizzes** | 6 | Assessments with questions |
| **Quiz Questions** | 19 | Multiple types (MC, T/F, Short Answer) |
| **Attendance** | 10 sessions, 10 records | Class & lab sessions |
| **Grades** | 10 | Assignment & quiz scores |
| **Announcements** | 5 | Course & campus-wide |
| **Messages** | 5 | Two-way conversations |
| **Notifications** | 8 | Various types (reminder, grade, alert) |

---

## 🎯 Common Use Cases

### For Frontend Developers
1. Use TEST_DATA_QUICK_REFERENCE.md for user accounts
2. Import data and test UI with real content
3. Use VERIFICATION_QUERIES.sql to understand data relationships

### For Backend Developers
1. Read TEST_DATA_README.md for schema understanding
2. Run VERIFICATION_QUERIES.sql to validate API responses
3. Use sample queries for API testing

### For QA Engineers
1. Use sample user accounts for testing different roles
2. Verify data integrity with VERIFICATION_QUERIES.sql
3. Test workflows (student enrollment, grade submission, etc.)

### For Data Analysts
1. Use advanced queries from VERIFICATION_QUERIES.sql
2. Generate reports and dashboards
3. Test analytics and reporting features

---

## 🔐 Test Credentials

All test users use the same password:

```
Password: password123
Hash: $2y$10$N9qo8uLOickgx2ZMRZoMye (bcrypt)
```

### Sample Accounts
- **Admin**: `admin.ahmed@eduverse.edu.eg`
- **Instructor**: `dr.ibrahim.ali@eduverse.edu.eg`
- **Student**: `student.ali.youssef@eduverse.edu.eg`
- **TA**: `ta.omar.hassan@eduverse.edu.eg`

See TEST_DATA_QUICK_REFERENCE.md for complete user list.

---

## ✨ Key Features

- ✅ **Realistic Names**: Arabic and English names
- ✅ **Interconnected Data**: All relationships properly established
- ✅ **Hierarchical Structure**: From campus → department → program → course → section
- ✅ **Complete Workflows**: From enrollment → assignment → submission → grading
- ✅ **Multiple Scenarios**: Support student, instructor, admin, and TA workflows
- ✅ **Proper Constraints**: Respects all foreign keys and unique constraints
- ✅ **Idempotent**: Safe to run multiple times (uses INSERT IGNORE)
- ✅ **Realistic Timestamps**: February 2025 (adjustable)
- ✅ **Diverse Data Types**: All field types represented
- ✅ **Production Ready**: Can be used for development, testing, and demos

---

## 🔍 Data Quality Checks

Before using the data in production, verify:

```sql
-- 1. No orphaned records
SELECT COUNT(*) FROM course_enrollments 
WHERE student_id NOT IN (SELECT user_id FROM users);

-- 2. All enrollments reference valid sections
SELECT COUNT(*) FROM course_enrollments 
WHERE section_id NOT IN (SELECT section_id FROM course_sections);

-- 3. All grades have valid students and sections
SELECT COUNT(*) FROM grades 
WHERE student_id NOT IN (SELECT user_id FROM users)
   OR section_id NOT IN (SELECT section_id FROM course_sections);

-- 4. Email uniqueness
SELECT COUNT(*) FROM users 
GROUP BY email HAVING COUNT(*) > 1;
```

---

## 📈 Scale Information

**Current Size:**
- 50+ records in users table
- ~300 total records across all tables
- ~65 KB uncompressed SQL file

**Suitable For:**
- ✅ Development environments
- ✅ QA and testing
- ✅ Demo environments
- ✅ Performance benchmarks
- ✅ Feature development testing

**Not Suitable For:**
- ❌ Load testing (need 1000+ records)
- ❌ Production databases (use real data)
- ❌ Big data analysis (need larger dataset)

---

## 🔧 Troubleshooting

### Import Fails with Foreign Key Error
**Cause**: Tables referenced before creation
**Solution**: Verify the script runs in order (it does by default)

### Duplicate Email Error
**Cause**: User already exists in database
**Solution**: Script uses `INSERT IGNORE`, won't error. To reset:
```sql
TRUNCATE TABLE notifications;
TRUNCATE TABLE messages;
-- ... (truncate all dependent tables)
TRUNCATE TABLE users;
```

### Data Not Appearing
**Cause**: Import didn't complete
**Solution**: Check MySQL output for errors, verify file path, check permissions

### Wrong Data Counts
**Cause**: Partial import or filtered import
**Solution**: Review import output for errors, verify all tables exist

---

## 📚 How to Use Each File

| File | Purpose | When to Use |
|------|---------|------------|
| COMPREHENSIVE_TEST_DATA.sql | Import data | First time setup |
| TEST_DATA_README.md | Understand structure | Learning the system |
| TEST_DATA_QUICK_REFERENCE.md | Quick lookup | During development |
| VERIFICATION_QUERIES.sql | Explore/validate | Testing & debugging |

---

## 🎓 Learning Path

1. **Start Here**: Read TEST_DATA_README.md (10 min)
2. **Import Data**: Run COMPREHENSIVE_TEST_DATA.sql (2 min)
3. **Verify**: Run basic queries from VERIFICATION_QUERIES.sql (5 min)
4. **Explore**: Use queries from TEST_DATA_QUICK_REFERENCE.md (10 min)
5. **Test**: Login with sample accounts and test features (ongoing)

---

## 💡 Tips & Tricks

### Quickly See What's There
```sql
-- Top 3 tables for each type
SELECT * FROM users LIMIT 3;
SELECT * FROM courses LIMIT 3;
SELECT * FROM course_enrollments LIMIT 3;
```

### Find Your Test User
```sql
-- Find all student accounts
SELECT user_id, email, first_name, last_name 
FROM users 
WHERE email LIKE 'student%' 
ORDER BY user_id;
```

### See Complete Course Info
```sql
-- Get full picture for a course
SELECT 
  c.course_name,
  COUNT(DISTINCT ce.student_id) as students,
  COUNT(DISTINCT a.assignment_id) as assignments,
  COUNT(DISTINCT g.grade_id) as grades
FROM courses c
LEFT JOIN course_sections cs ON c.course_id = cs.course_id
LEFT JOIN course_enrollments ce ON cs.section_id = ce.section_id
LEFT JOIN assignments a ON cs.section_id = a.section_id
LEFT JOIN grades g ON cs.section_id = g.section_id
WHERE c.course_code = 'CS101'
GROUP BY c.course_id;
```

---

## 📞 Support

For issues or questions:
1. Check TEST_DATA_README.md → Troubleshooting section
2. Review VERIFICATION_QUERIES.sql for data validation
3. Verify import succeeded with provided queries
4. Check MySQL error logs for detailed messages

---

## 📝 Version History

**Version 1.0** (February 2025)
- Initial comprehensive test data suite
- 23 tables, 300+ records
- 5 priority levels of data
- Full documentation

---

## 📄 File Locations

All files are located in:
```
D:\Graduation Project\Backend\eduverse-backend\
```

Quick access:
- `COMPREHENSIVE_TEST_DATA.sql` - Main import file
- `TEST_DATA_README.md` - Full documentation
- `TEST_DATA_QUICK_REFERENCE.md` - Quick reference
- `VERIFICATION_QUERIES.sql` - Verification queries

---

**Happy Testing! 🚀**

For the most detailed information, see TEST_DATA_README.md
For quick lookups, see TEST_DATA_QUICK_REFERENCE.md
For data exploration, use VERIFICATION_QUERIES.sql
