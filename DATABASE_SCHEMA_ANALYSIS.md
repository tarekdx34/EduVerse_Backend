# 📊 EduVerse Database Schema Analysis - Complete Overview

**Database Name**: `edu`  
**Engine**: InnoDB  
**Charset**: utf8mb4  
**Collation**: utf8mb4_unicode_ci  
**Total Tables**: 130+

---

## 🎯 **Core User Management System**

### **USERS Table**
```sql
user_id (PK) | email (UNIQUE) | password_hash | first_name | last_name | phone
profile_picture_url | campus_id (FK) | status (active/inactive/suspended/pending)
email_verified (boolean) | last_login_at | created_at | updated_at | deleted_at (soft delete)
```

**Current Data**: 16 users (1 admin, 4 instructors, 2 TAs, 9 students)
- User IDs: 1-16
- Status: All active
- Email verified: All YES except user 1
- Soft delete: Supported

### **ROLES Table**
```sql
role_id (PK) | role_name (UNIQUE ENUM) | role_description | created_at
```

**Available Roles**:
1. `student` - Regular student user
2. `instructor` - Course instructor
3. `teaching_assistant` - Teaching Assistant  
4. `admin` - System Administrator
5. `department_head` - Department Head

### **USER_ROLES Junction Table**
```sql
user_role_id (PK) | user_id (FK) | role_id (FK) | assigned_at | assigned_by
```

**Current Assignments** (16 total):
- User 1 → Role 4 (admin)
- Users 2-4 → Role 2 (instructor)
- Users 5-6 → Role 3 (teaching_assistant)
- Users 7-16 → Role 1 (student)

### **PERMISSIONS Table**
```sql
permission_id (PK) | permission_name (UNIQUE) | permission_description | module | created_at
```

**Current Permissions** (8 total):
1. `view_courses` - View course information (module: courses)
2. `enroll_courses` - Enroll in courses (module: courses)
3. `create_courses` - Create new courses (module: courses)
4. `manage_grades` - Manage student grades (module: grading)
5. `take_attendance` - Mark student attendance (module: attendance)
6. `view_reports` - View analytics reports (module: reports)
7. `manage_users` - Manage user accounts (module: users)
8. `system_settings` - Access system settings (module: admin)

### **ROLE_PERMISSIONS Junction Table**
```sql
role_permission_id (PK) | role_id (FK) | permission_id (FK) | granted_at
```

**Role Permission Mapping** (22 total):

**Student Role (1)**:
- view_courses
- enroll_courses

**Instructor Role (2)**:
- view_courses
- create_courses
- manage_grades
- take_attendance
- view_reports

**TA Role (3)**:
- view_courses
- manage_grades
- take_attendance

**Admin Role (4)**:
- view_courses, enroll_courses, create_courses, manage_grades
- take_attendance, view_reports, manage_users, system_settings
*(ALL PERMISSIONS)*

**Department Head Role (5)**:
- view_courses
- create_courses
- manage_grades
- view_reports

---

## 📚 **Academic Structure**

### **CAMPUSES** (Multi-campus support)
- 3 campuses with IDs: 1, 2, 3

### **DEPARTMENTS**
- Computer Science
- Mathematics
- Physics
- etc.

### **PROGRAMS** 
- Bachelor of Science in Computer Science
- Bachelor of Arts in Mathematics
- etc.

### **COURSES** (3 courses created)
1. **CS101** - Introduction to Programming (Spring 2025)
2. **CS201** - Data Structures (Spring 2025)
3. **MATH101** - Calculus I (Spring 2025)

### **COURSE_SECTIONS** (4 sections)
- CS101-01, CS101-02 (2 sections)
- CS201-01 (1 section)
- MATH101-01 (1 section)

### **SEMESTERS** (3 semesters)
- Fall 2024 (completed)
- Spring 2025 (active)
- Summer 2025 (upcoming)

### **COURSE_ENROLLMENTS** (4 enrollments)
- Student enrollments with status tracking

---

## 📝 **Academic Content**

### **COURSE_MATERIALS** (5 materials)
- Lecture slides, syllabus, assignments

### **ASSIGNMENTS** (4 assignments)
- Assignment 1, 2, 3, 4 with due dates

### **QUIZZES** (3 quizzes)
- Quiz 1: Python Basics
- Quiz 2: Control Structures
- Quiz 3: Arrays and Lists

### **LABS** 
- Lab practical sessions

---

## 🎓 **Academic Performance**

### **GRADES** (13 grades recorded)
- Assignment and quiz grades
- Score range: 60-95
- Status: graded, pending

### **STUDENT_PROGRESS** (6 records)
- Progress per course
- Completion percentage: 40-65%
- Average scores: 72-90

### **ATTENDANCE_RECORDS** (Multiple records)
- Student attendance tracking
- Status: present, absent, late

### **QUIZ_ATTEMPTS** (4 attempts)
- Quiz 1: Multiple attempts by students 7-10
- Scores: 75-90
- Time taken: 25-30 minutes

---

## 💬 **Communication & Collaboration**

### **CHAT_MESSAGES**
- Direct messaging between users

### **ANNOUNCEMENTS**
- Course announcements

### **COMMUNITY_POSTS**
- Forum discussions

### **STUDY_GROUPS** (3 groups)
- CS101 Evening Study Group (4 members)
- Data Structures Masters (3 members)
- Weekend Warriors (5 members)

---

## 📊 **Analytics & Reporting**

### **LEARNING_ANALYTICS**
- Comprehensive learning data

### **PERFORMANCE_METRICS** (7 metrics)
- Overall grades
- Assignment averages
- Quiz averages
- Trends: improving, stable, declining

### **LEADERBOARDS**
- Student rankings and scores

### **ACTIVITY_LOGS** (8 entries)
- User activities tracked
- Login, view, submit, quiz completion

---

## 🔐 **Security & Authentication**

### **SESSIONS**
- User session tracking
- Token management
- IP address, user agent
- Device type tracking

### **PASSWORD_RESETS**
- Password reset tokens
- Expiration tracking

### **TWO_FACTOR_AUTH**
- Secret key storage
- Backup codes

### **SECURITY_LOGS** (6 entries)
- Login events
- Failed login attempts
- Password changes
- Permission changes

### **LOGIN_ATTEMPTS**
- Failed login tracking

---

## 🎮 **Gamification System**

### **BADGES** (Multiple badges)
- Achievement badges
- User badge assignments

### **ACHIEVEMENTS** (4 achievements)
- First Assignment
- Quiz Champion
- Week Perfect
- Speed Demon

### **DAILY_STREAKS**
- Student participation streaks

### **USER_LEVELS** (10 level records)
- Current levels: 1-3
- Tiers: bronze, silver, gold, platinum, diamond
- XP tracking

### **LEADERBOARDS** (Rankings)
- Student rankings based on performance

### **POINTS_RULES** (9 rules)
- Quiz completion: 10 points
- Assignment submission: 15 points
- Forum post: 5 points
- etc.

---

## 📁 **File Management**

### **FILES**
- File uploads and storage

### **FOLDERS**
- File organization

### **FILE_VERSIONS**
- Version control for files

---

## 🤖 **AI Features**

### **AI_SUMMARIES**
- Generated summaries of lectures

### **AI_QUIZZES**
- AI-generated quiz questions

### **AI_STUDY_PLANS**
- Personalized study plans

### **AI_FLASHCARDS**
- Adaptive flashcard system

### **AI_GRADING_RESULTS**
- AI-assisted grading

### **AI_RECOMMENDATIONS**
- Personalized learning recommendations

### **AI_FEEDBACK**
- Automated feedback generation

### **FACE_RECOGNITION_DATA**
- Biometric data for attendance

### **AI_ATTENDANCE_PROCESSING**
- AI processing of attendance photos

---

## 📞 **Support & Feedback**

### **SUPPORT_TICKETS** (4 tickets)
- Technical, academic, account issues
- Status tracking: open, in_progress, resolved

### **USER_FEEDBACK** (5 feedback entries)
- Bug reports, feature requests, suggestions

---

## 📧 **Notifications**

### **NOTIFICATIONS**
- User notifications

### **NOTIFICATION_PREFERENCES** (6 preferences)
- Email, push, SMS preferences
- Quiet hours configuration

### **SCHEDULED_NOTIFICATIONS** (4 scheduled)
- Deadline reminders
- Course updates
- Grade notifications

---

## 🌍 **Localization & UI**

### **LANGUAGE_PREFERENCES**
- User language selection

### **LOCALIZATION_STRINGS**
- Multi-language support

### **THEME_PREFERENCES** (6 preferences)
- Light/Dark mode
- Font size options
- Layout density

---

## 📱 **Mobile & Offline**

### **DEVICE_TOKENS**
- Push notification tokens

### **OFFLINE_SYNC_QUEUE** (4 items)
- Offline data sync

---

## 🔍 **Search & Indexing**

### **SEARCH_HISTORY** (5 entries)
- User search queries

### **SEARCH_INDEX** (5 entries)
- Searchable content index

---

## 📊 **Database Statistics**

| Category | Count |
|----------|-------|
| **Total Tables** | 130+ |
| **Users** | 16 |
| **Roles** | 5 |
| **Permissions** | 8 |
| **Courses** | 3 |
| **Enrollments** | 4 |
| **Assignments** | 4 |
| **Quizzes** | 3 |
| **Activity Logs** | 8 |
| **Badges** | Multiple |

---

## ✅ **Key Database Features**

1. ✅ **Multi-campus support** - Multiple campus locations
2. ✅ **Role-based access control** - 5 predefined roles
3. ✅ **Permission management** - Granular permissions by module
4. ✅ **Soft delete** - Deleted_at field for users
5. ✅ **Audit logging** - Security and activity logs
6. ✅ **Gamification** - Points, badges, levels
7. ✅ **AI features** - Summaries, quizzes, recommendations
8. ✅ **Multi-language** - Localization support
9. ✅ **Session management** - Device and IP tracking
10. ✅ **File management** - Version control
11. ✅ **Offline sync** - Mobile offline support
12. ✅ **Search indexing** - Full-text search capability
13. ✅ **Attendance** - AI-powered face recognition
14. ✅ **Notifications** - Multiple delivery channels

---

## 🔗 **Important Relationships**

```
users (1) ──→ (many) user_roles ←── (1) roles
              (many) user_roles ──→ (1) permissions

courses (1) ──→ (many) course_sections
           (1) ──→ (many) course_enrollments
           
course_enrollments (many) ──→ (1) users
                 ──→ (1) courses

assignments (1) ──→ (many) assignment_submissions ←── (1) users
quizzes (1) ──→ (many) quiz_attempts ←── (1) users
```

---

## 🚀 **Your User Management & RBAC Implementation**

**Your implementation** integrates seamlessly with:
- ✅ Users table (user_id, email, first_name, last_name, status, etc.)
- ✅ Roles table (5 predefined roles)
- ✅ Permissions table (8 permissions)
- ✅ User_roles junction table (role assignment)
- ✅ Role_permissions junction table (permission assignment)

**Enhancements in your code**:
- ✅ Email verification (NEW - email_verified field)
- ✅ Pagination & filtering
- ✅ Full-text search
- ✅ Soft delete support
- ✅ RBAC guards and decorators

---

## 📝 **Important Notes**

1. **Data Types**: 
   - User IDs are `bigint(20) UNSIGNED` - supports billions of users
   - Roles use `int(10) UNSIGNED` - limited to 5 roles currently
   - Permissions use `int(10) UNSIGNED`

2. **Naming Conventions**:
   - Table names: `snake_case`
   - Column names: `snake_case`
   - Foreign keys: `table_name_id` (e.g., `user_id`, `role_id`)

3. **Field Lengths**:
   - Email: 255 chars
   - Passwords: 255 chars (bcrypt hash)
   - Name fields: 100 chars each
   - URLs: 500 chars

4. **Status Values** (User):
   - `active` - User can login
   - `inactive` - User temporarily disabled
   - `suspended` - User banned
   - `pending` - Email not verified (your email verification)

5. **Timestamps**:
   - All tables have `created_at`
   - Most have `updated_at` for change tracking

---

**Your implementation perfectly aligns with the existing database schema!** 🎯
