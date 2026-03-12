-- ============================================================================
-- Mock Data for Schedule Module (Enhanced) + Course Materials Module
-- For testing with Dev C Sprint 2 implementation
-- ============================================================================
-- Test User IDs:
-- Student: 51 (amir_student@example.com)
-- Instructor: 53 (amir_instructor@example.com)
-- Admin: 54 (amir_admin@example.com)
-- TA: 55 (amir_ta@example.com)
-- ============================================================================

-- ============================================================================
-- 1. COURSE ASSIGNMENTS (Required for ownership checks)
-- ============================================================================

-- Assign instructor (user_id: 53) to sections of courses 1, 2, 3
-- Table columns: assignment_id, user_id, section_id, role (enum: primary, co_instructor, guest), assigned_at
INSERT INTO course_instructors (user_id, section_id, role)
VALUES 
  (53, 1, 'primary'),        -- Course 1, Section 1
  (53, 2, 'primary'),        -- Course 1, Section 2
  (53, 3, 'co_instructor'),  -- Course 2, Section 3
  (53, 5, 'co_instructor')   -- Course 3, Section 5
ON DUPLICATE KEY UPDATE role = VALUES(role);

-- Assign TA (user_id: 55) to sections of courses 1, 2
-- Table columns: assignment_id, user_id, section_id, responsibilities, assigned_at
INSERT INTO course_tas (user_id, section_id, responsibilities)
VALUES 
  (55, 1, 'grading, lab_assistance'),  -- Course 1, Section 1
  (55, 3, 'grading'),                   -- Course 2, Section 3
  (55, 5, 'lab_assistance')             -- Course 3, Section 5
ON DUPLICATE KEY UPDATE responsibilities = VALUES(responsibilities);

-- Enroll student (user_id: 51) in sections of courses 1, 2, 3
-- Table columns: enrollment_id, user_id, section_id, program_id, enrollment_date, enrollment_status, grade, final_score, etc.
INSERT INTO course_enrollments (user_id, section_id, enrollment_status)
VALUES 
  (51, 1, 'enrolled'),   -- Course 1, Section 1
  (51, 3, 'enrolled'),   -- Course 2, Section 3
  (51, 5, 'enrolled')    -- Course 3, Section 5
ON DUPLICATE KEY UPDATE enrollment_status = VALUES(enrollment_status);

-- ============================================================================
-- 2. EXAM SCHEDULES
-- ============================================================================

INSERT INTO exam_schedules (course_id, semester_id, exam_type, title, exam_date, start_time, duration_minutes, location, instructions, status)
VALUES
  -- Course 1 Exams (Programming 101)
  (1, 2, 'midterm', 'CS101 Midterm Exam', '2025-03-15', '09:00:00', 120, 'Hall A', 'Bring student ID. No electronic devices allowed.', 'scheduled'),
  (1, 2, 'final', 'CS101 Final Exam', '2025-05-20', '14:00:00', 180, 'Hall A', 'Comprehensive exam covering all semester topics.', 'scheduled'),
  (1, 2, 'quiz', 'CS101 Quiz 1 - Variables', '2025-02-10', '10:30:00', 30, 'Room 101', 'Short quiz on variables and data types.', 'completed'),
  
  -- Course 2 Exams (Data Structures)
  (2, 2, 'midterm', 'DS200 Midterm Exam', '2025-03-18', '10:00:00', 150, 'Hall B', 'Open book exam. One cheat sheet allowed.', 'scheduled'),
  (2, 2, 'final', 'DS200 Final Exam', '2025-05-22', '09:00:00', 180, 'Hall B', 'Covers arrays, linked lists, trees, and graphs.', 'scheduled'),
  
  -- Course 3 Exams (Database Systems)
  (3, 2, 'midterm', 'DB301 Midterm - SQL Basics', '2025-03-20', '14:00:00', 120, 'Computer Lab 1', 'Practical SQL exam on lab computers.', 'scheduled'),
  (3, 2, 'final', 'DB301 Final Exam', '2025-05-25', '10:00:00', 180, 'Hall C', 'Theory and practical components.', 'scheduled')
ON DUPLICATE KEY UPDATE title = VALUES(title);

-- ============================================================================
-- 3. CALENDAR EVENTS
-- Note: status enum is (scheduled, completed, cancelled), not 'active'
-- ============================================================================

-- Student events (user_id: 51)
INSERT INTO calendar_events (user_id, course_id, event_type, title, description, start_time, end_time, location, color, is_recurring, reminder_minutes, status)
VALUES
  (51, NULL, 'custom', 'Study Group Meeting', 'Weekly study session with classmates', '2025-02-15 18:00:00', '2025-02-15 20:00:00', 'Library Room 3', '#4CAF50', 1, 30, 'scheduled'),
  (51, 1, 'assignment', 'CS101 Assignment 1 Due', 'Variables and loops assignment', '2025-02-20 23:59:00', '2025-02-20 23:59:00', NULL, '#FF5722', 0, 60, 'scheduled'),
  (51, 2, 'assignment', 'DS200 Lab Report Due', 'Linked list implementation report', '2025-02-25 17:00:00', '2025-02-25 17:00:00', NULL, '#2196F3', 0, 120, 'scheduled')
ON DUPLICATE KEY UPDATE title = VALUES(title);

-- Instructor events (user_id: 53)
INSERT INTO calendar_events (user_id, course_id, event_type, title, description, start_time, end_time, location, color, is_recurring, reminder_minutes, status)
VALUES
  (53, 1, 'lecture', 'CS101 Lecture - Week 5', 'Control flow and loops', '2025-02-17 09:00:00', '2025-02-17 10:30:00', 'Room 101', '#3F51B5', 1, 15, 'scheduled'),
  (53, 1, 'meeting', 'Office Hours', 'Weekly student consultation', '2025-02-18 14:00:00', '2025-02-18 16:00:00', 'Office 305', '#9C27B0', 1, 10, 'scheduled'),
  (53, 2, 'lecture', 'DS200 Lecture - Trees', 'Binary trees and traversal', '2025-02-19 11:00:00', '2025-02-19 12:30:00', 'Room 202', '#3F51B5', 0, 15, 'scheduled'),
  (53, NULL, 'meeting', 'Department Meeting', 'Monthly faculty meeting', '2025-02-20 15:00:00', '2025-02-20 17:00:00', 'Conference Room A', '#607D8B', 0, 30, 'scheduled')
ON DUPLICATE KEY UPDATE title = VALUES(title);

-- TA events (user_id: 55)
INSERT INTO calendar_events (user_id, course_id, event_type, title, description, start_time, end_time, location, color, is_recurring, reminder_minutes, status)
VALUES
  (55, 1, 'lab', 'CS101 Lab Session', 'Hands-on programming practice', '2025-02-16 14:00:00', '2025-02-16 16:00:00', 'Computer Lab 2', '#00BCD4', 1, 15, 'scheduled'),
  (55, 2, 'lab', 'DS200 Lab - Linked Lists', 'Implementing singly linked list', '2025-02-18 10:00:00', '2025-02-18 12:00:00', 'Computer Lab 1', '#00BCD4', 0, 15, 'scheduled')
ON DUPLICATE KEY UPDATE title = VALUES(title);

-- Admin events (user_id: 54)
INSERT INTO calendar_events (user_id, course_id, event_type, title, description, start_time, end_time, location, color, is_recurring, reminder_minutes, status)
VALUES
  (54, NULL, 'meeting', 'Academic Board Meeting', 'Quarterly academic review', '2025-02-21 09:00:00', '2025-02-21 12:00:00', 'Board Room', '#F44336', 0, 60, 'scheduled'),
  (54, NULL, 'custom', 'Exam Schedule Review', 'Review and approve exam schedules', '2025-02-22 10:00:00', '2025-02-22 11:30:00', 'Office', '#795548', 0, 30, 'scheduled')
ON DUPLICATE KEY UPDATE title = VALUES(title);

-- ============================================================================
-- 4. CALENDAR INTEGRATIONS
-- ============================================================================

INSERT INTO calendar_integrations (user_id, calendar_type, sync_status)
VALUES
  (51, 'google', 'active'),
  (53, 'outlook', 'active'),
  (54, 'google', 'disabled')
ON DUPLICATE KEY UPDATE sync_status = VALUES(sync_status);

-- ============================================================================
-- 5. COURSE MATERIALS (Uploaded by instructor user_id: 53)
-- Note: download_count column doesn't exist in the actual table
-- ============================================================================

INSERT INTO course_materials (course_id, title, description, material_type, external_url, order_index, uploaded_by, is_published, published_at, view_count)
VALUES
  -- Course 1 Materials (Programming 101)
  (1, 'Week 1: Introduction to Programming', 'Course overview and programming basics', 'lecture', 'https://example.com/cs101/week1-intro.pdf', 1, 53, 1, NOW(), 120),
  (1, 'Week 1 Slides: Getting Started', 'Presentation slides for week 1', 'slide', 'https://example.com/cs101/week1-slides.pptx', 2, 53, 1, NOW(), 95),
  (1, 'Week 2: Variables and Data Types', 'Understanding variables, integers, strings', 'lecture', 'https://example.com/cs101/week2-variables.pdf', 3, 53, 1, NOW(), 130),
  (1, 'Python Tutorial Video', 'Introduction to Python programming', 'video', 'https://www.youtube.com/embed/dQw4w9WgXcQ', 4, 53, 1, NOW(), 85),
  (1, 'Week 3: Control Flow (DRAFT)', 'If-else statements and loops - Not yet published', 'lecture', 'https://example.com/cs101/week3-control.pdf', 5, 53, 0, NULL, 0),
  (1, 'Python Official Documentation', 'Link to official Python docs', 'link', 'https://docs.python.org/3/', 6, 53, 1, NOW(), 67),
  
  -- Course 2 Materials (Data Structures)
  (2, 'Arrays and Memory', 'Understanding array storage and access', 'lecture', 'https://example.com/ds200/arrays.pdf', 1, 53, 1, NOW(), 78),
  (2, 'Linked Lists Explained', 'Comprehensive guide to linked lists', 'document', 'https://example.com/ds200/linked-lists.pdf', 2, 53, 1, NOW(), 72),
  (2, 'Data Structures Video Lecture', 'Video covering basic structures', 'video', 'https://www.youtube.com/embed/RBSGKlAvoiM', 3, 53, 1, NOW(), 55),
  
  -- Course 3 Materials (Database Systems)
  (3, 'Introduction to SQL', 'SQL basics and SELECT statements', 'lecture', 'https://example.com/db301/sql-intro.pdf', 1, 53, 1, NOW(), 65),
  (3, 'Database Design Best Practices', 'Normalization and schema design', 'reading', 'https://example.com/db301/design.pdf', 2, 53, 1, NOW(), 45)
ON DUPLICATE KEY UPDATE title = VALUES(title);

-- ============================================================================
-- 6. LECTURE SECTIONS LABS (Course Structure)
-- ============================================================================

INSERT INTO lecture_sections_labs (course_id, organization_type, title, description, week_number, order_index)
VALUES
  -- Course 1 Structure
  (1, 'lecture', 'Introduction to Programming', 'Overview of programming concepts and course goals', 1, 0),
  (1, 'lab', 'Setting Up Development Environment', 'Install Python and IDE setup', 1, 1),
  (1, 'lecture', 'Variables and Data Types', 'Understanding variables, integers, floats, strings', 2, 0),
  (1, 'lab', 'Working with Variables', 'Hands-on practice with variable declarations', 2, 1),
  (1, 'section', 'Variables Review Session', 'Q&A and practice problems', 2, 2),
  (1, 'lecture', 'Control Flow: Conditionals', 'If-else statements and boolean logic', 3, 0),
  (1, 'lab', 'Conditional Programming', 'Building programs with decisions', 3, 1),
  (1, 'lecture', 'Loops: For and While', 'Iteration and loop control', 4, 0),
  (1, 'lab', 'Loop Exercises', 'Practice with various loop patterns', 4, 1),
  
  -- Course 2 Structure
  (2, 'lecture', 'Arrays and Memory Management', 'How arrays work in memory', 1, 0),
  (2, 'lab', 'Array Operations', 'Implementing array algorithms', 1, 1),
  (2, 'lecture', 'Linked Lists', 'Nodes, pointers, and list operations', 2, 0),
  (2, 'lab', 'Building a Linked List', 'Implement singly linked list from scratch', 2, 1),
  (2, 'section', 'Data Structures Comparison', 'Arrays vs Linked Lists discussion', 2, 2),
  
  -- Course 3 Structure
  (3, 'lecture', 'Database Fundamentals', 'Introduction to relational databases', 1, 0),
  (3, 'lab', 'SQL Basics', 'Writing your first SELECT queries', 1, 1),
  (3, 'lecture', 'Database Design', 'Normalization and ER diagrams', 2, 0),
  (3, 'lab', 'Designing a Schema', 'Create tables with relationships', 2, 1)
ON DUPLICATE KEY UPDATE title = VALUES(title);

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Verify instructor assignments
SELECT 'Instructor Assignments' as check_type, COUNT(*) as count FROM course_instructors WHERE user_id = 53;

-- Verify TA assignments  
SELECT 'TA Assignments' as check_type, COUNT(*) as count FROM course_tas WHERE user_id = 55;

-- Verify student enrollments
SELECT 'Student Enrollments' as check_type, COUNT(*) as count FROM course_enrollments WHERE user_id = 51;

-- Verify exam schedules
SELECT 'Exam Schedules' as check_type, COUNT(*) as count FROM exam_schedules;

-- Verify calendar events
SELECT 'Calendar Events' as check_type, COUNT(*) as count FROM calendar_events;

-- Verify course materials
SELECT 'Course Materials' as check_type, COUNT(*) as count FROM course_materials;

-- Verify course structure
SELECT 'Course Structure Items' as check_type, COUNT(*) as count FROM lecture_sections_labs;

SELECT '✅ Mock data inserted successfully!' as status;
