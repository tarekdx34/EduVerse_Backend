-- ============================================================
-- VERIFICATION QUERIES FOR TEST DATA
-- ============================================================
-- Use these queries to verify the test data was imported correctly
-- and to explore the database structure
-- ============================================================

-- ============================================================
-- BASIC VERIFICATION
-- ============================================================

-- 1. Count records in each table
SELECT 'Users' as table_name, COUNT(*) as count FROM users
UNION ALL
SELECT 'Campuses', COUNT(*) FROM campuses
UNION ALL
SELECT 'Departments', COUNT(*) FROM departments
UNION ALL
SELECT 'Programs', COUNT(*) FROM programs
UNION ALL
SELECT 'Semesters', COUNT(*) FROM semesters
UNION ALL
SELECT 'Courses', COUNT(*) FROM courses
UNION ALL
SELECT 'Course Sections', COUNT(*) FROM course_sections
UNION ALL
SELECT 'Course Schedules', COUNT(*) FROM course_schedules
UNION ALL
SELECT 'Course Prerequisites', COUNT(*) FROM course_prerequisites
UNION ALL
SELECT 'Course Enrollments', COUNT(*) FROM course_enrollments
UNION ALL
SELECT 'Course Instructors', COUNT(*) FROM course_instructors
UNION ALL
SELECT 'Course TAs', COUNT(*) FROM course_tas
UNION ALL
SELECT 'Assignments', COUNT(*) FROM assignments
UNION ALL
SELECT 'Assignment Submissions', COUNT(*) FROM assignment_submissions
UNION ALL
SELECT 'Quizzes', COUNT(*) FROM quizzes
UNION ALL
SELECT 'Quiz Questions', COUNT(*) FROM quiz_questions
UNION ALL
SELECT 'Attendance Sessions', COUNT(*) FROM attendance_sessions
UNION ALL
SELECT 'Attendance Records', COUNT(*) FROM attendance_records
UNION ALL
SELECT 'Grades', COUNT(*) FROM grades
UNION ALL
SELECT 'Announcements', COUNT(*) FROM announcements
UNION ALL
SELECT 'Messages', COUNT(*) FROM messages
UNION ALL
SELECT 'Message Participants', COUNT(*) FROM message_participants
UNION ALL
SELECT 'Notifications', COUNT(*) FROM notifications;

-- ============================================================
-- USER DATA VERIFICATION
-- ============================================================

-- 2. User count by role (requires joining with user_roles if available)
SELECT 
  u.status,
  COUNT(*) as user_count,
  u.campus_id
FROM users u
GROUP BY u.campus_id, u.status
ORDER BY u.campus_id;

-- 3. Sample of all users
SELECT user_id, email, first_name, last_name, campus_id, status, created_at
FROM users
ORDER BY user_id
LIMIT 10;

-- 4. Verify admin users exist
SELECT user_id, email, first_name, last_name
FROM users
WHERE email LIKE 'admin%@eduverse.edu.eg'
ORDER BY user_id;

-- 5. Verify instructor users
SELECT user_id, email, first_name, last_name
FROM users
WHERE email LIKE 'dr.%@eduverse.edu.eg' OR email LIKE 'prof.%@eduverse.edu.eg'
ORDER BY user_id;

-- 6. Verify student users count
SELECT COUNT(*) as total_students
FROM users
WHERE email LIKE 'student.%@eduverse.edu.eg';

-- ============================================================
-- CAMPUS & STRUCTURE VERIFICATION
-- ============================================================

-- 7. Campus overview
SELECT 
  c.campus_id,
  c.campus_name,
  c.campus_code,
  COUNT(DISTINCT u.user_id) as user_count,
  COUNT(DISTINCT d.department_id) as department_count
FROM campuses c
LEFT JOIN users u ON c.campus_id = u.campus_id
LEFT JOIN departments d ON c.campus_id = d.campus_id
GROUP BY c.campus_id, c.campus_name, c.campus_code;

-- 8. Departments by campus
SELECT 
  c.campus_name,
  d.department_name,
  d.department_code,
  COUNT(DISTINCT p.program_id) as program_count
FROM campuses c
LEFT JOIN departments d ON c.campus_id = d.campus_id
LEFT JOIN programs p ON d.department_id = p.department_id
GROUP BY c.campus_id, d.department_id
ORDER BY c.campus_name, d.department_name;

-- 9. Programs overview
SELECT 
  d.department_name,
  p.program_name,
  p.program_code,
  p.degree_type,
  p.duration_years
FROM programs p
JOIN departments d ON p.department_id = d.department_id
ORDER BY d.department_name, p.program_name;

-- ============================================================
-- ACADEMIC STRUCTURE VERIFICATION
-- ============================================================

-- 10. Semester overview
SELECT 
  semester_id,
  semester_name,
  semester_code,
  start_date,
  end_date,
  status
FROM semesters
ORDER BY start_date;

-- 11. Courses by department
SELECT 
  d.department_name,
  c.course_code,
  c.course_name,
  c.credits,
  c.level,
  COUNT(DISTINCT cs.section_id) as section_count
FROM courses c
JOIN departments d ON c.department_id = d.department_id
LEFT JOIN course_sections cs ON c.course_id = cs.course_id
GROUP BY c.course_id, c.course_code, c.course_name, d.department_name, c.credits, c.level
ORDER BY d.department_name, c.course_code;

-- 12. Course sections with enrollment
SELECT 
  c.course_code,
  c.course_name,
  cs.section_number,
  cs.max_capacity,
  cs.current_enrollment,
  COUNT(ce.enrollment_id) as actual_enrolled,
  cs.status,
  sem.semester_name
FROM course_sections cs
JOIN courses c ON cs.course_id = c.course_id
JOIN semesters sem ON cs.semester_id = sem.semester_id
LEFT JOIN course_enrollments ce ON cs.section_id = ce.section_id AND ce.status = 'enrolled'
GROUP BY cs.section_id
ORDER BY c.course_code, cs.section_number;

-- 13. Course prerequisites chain
SELECT 
  c.course_code as course,
  c.course_name,
  pc.course_code as prerequisite_code,
  pc.course_name as prerequisite_name
FROM course_prerequisites cp
JOIN courses c ON cp.course_id = c.course_id
JOIN courses pc ON cp.prerequisite_course_id = pc.course_id
ORDER BY c.course_code;

-- 14. Course meeting times (schedule)
SELECT 
  c.course_code,
  c.course_name,
  cs.section_number,
  sched.day_of_week,
  sched.start_time,
  sched.end_time,
  sched.building,
  sched.room_number
FROM course_schedules sched
JOIN course_sections cs ON sched.section_id = cs.section_id
JOIN courses c ON cs.course_id = c.course_id
ORDER BY c.course_code, cs.section_number, 
  FIELD(sched.day_of_week, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'),
  sched.start_time;

-- ============================================================
-- ENROLLMENT VERIFICATION
-- ============================================================

-- 15. Enrollment summary
SELECT 
  'CS101' as course,
  cs.section_number,
  COUNT(ce.enrollment_id) as enrolled_students,
  cs.max_capacity as capacity
FROM course_enrollments ce
JOIN course_sections cs ON ce.section_id = cs.section_id
JOIN courses c ON cs.course_id = c.course_id
WHERE c.course_code = 'CS101'
GROUP BY cs.section_id;

-- 16. Student enrollments
SELECT 
  u.first_name,
  u.last_name,
  u.email,
  c.course_code,
  c.course_name,
  cs.section_number,
  ce.status,
  ce.enrollment_date
FROM course_enrollments ce
JOIN users u ON ce.student_id = u.user_id
JOIN course_sections cs ON ce.section_id = cs.section_id
JOIN courses c ON cs.course_id = c.course_id
WHERE u.user_id IN (21, 22, 23, 24, 25)  -- Sample students
ORDER BY u.last_name, c.course_code;

-- 17. Instructor assignments
SELECT 
  u.first_name,
  u.last_name,
  u.email,
  c.course_code,
  c.course_name,
  cs.section_number,
  COUNT(ce.enrollment_id) as student_count
FROM course_instructors ci
JOIN users u ON ci.instructor_user_id = u.user_id
JOIN course_sections cs ON ci.section_id = cs.section_id
JOIN courses c ON cs.course_id = c.course_id
LEFT JOIN course_enrollments ce ON cs.section_id = ce.section_id AND ce.status = 'enrolled'
GROUP BY ci.instructor_id
ORDER BY u.last_name, c.course_code;

-- 18. TA assignments
SELECT 
  u.first_name,
  u.last_name,
  u.email,
  c.course_code,
  c.course_name,
  cs.section_number
FROM course_tas cta
JOIN users u ON cta.ta_user_id = u.user_id
JOIN course_sections cs ON cta.section_id = cs.section_id
JOIN courses c ON cs.course_id = c.course_id
ORDER BY u.last_name, c.course_code;

-- ============================================================
-- ASSIGNMENT VERIFICATION
-- ============================================================

-- 19. Assignments summary
SELECT 
  c.course_code,
  a.assignment_title,
  a.assignment_type,
  a.total_points,
  a.due_date,
  COUNT(DISTINCT asub.submission_id) as submissions_received
FROM assignments a
JOIN course_sections cs ON a.section_id = cs.section_id
JOIN courses c ON cs.course_id = c.course_id
LEFT JOIN assignment_submissions asub ON a.assignment_id = asub.assignment_id
GROUP BY a.assignment_id
ORDER BY a.due_date;

-- 20. Assignment submissions status
SELECT 
  c.course_code,
  a.assignment_title,
  COUNT(DISTINCT asub.submission_id) as submissions,
  SUM(CASE WHEN asub.graded = 1 THEN 1 ELSE 0 END) as graded_count,
  AVG(asub.grade_score) as avg_grade
FROM assignments a
JOIN course_sections cs ON a.section_id = cs.section_id
JOIN courses c ON cs.course_id = c.course_id
LEFT JOIN assignment_submissions asub ON a.assignment_id = asub.assignment_id
GROUP BY a.assignment_id
ORDER BY a.due_date;

-- 21. Student submission status for assignment 1
SELECT 
  u.first_name,
  u.last_name,
  CASE WHEN asub.submission_id IS NOT NULL THEN 'Submitted' ELSE 'Not Submitted' END as status,
  asub.grade_score,
  asub.graded,
  asub.submitted_at
FROM users u
JOIN course_enrollments ce ON u.user_id = ce.student_id
LEFT JOIN assignment_submissions asub ON u.user_id = asub.student_id AND asub.assignment_id = 1
WHERE ce.section_id = 1
ORDER BY u.last_name;

-- ============================================================
-- QUIZ VERIFICATION
-- ============================================================

-- 22. Quiz overview
SELECT 
  c.course_code,
  q.quiz_title,
  q.total_points,
  q.time_limit_minutes,
  q.passing_score,
  COUNT(DISTINCT qq.question_id) as question_count
FROM quizzes q
JOIN course_sections cs ON q.section_id = cs.section_id
JOIN courses c ON cs.course_id = c.course_id
LEFT JOIN quiz_questions qq ON q.quiz_id = qq.quiz_id
GROUP BY q.quiz_id
ORDER BY c.course_code, q.quiz_id;

-- 23. Quiz questions detail
SELECT 
  c.course_code,
  q.quiz_title,
  qq.question_id,
  qq.question_text,
  qq.question_type,
  qq.points,
  qq.order_position
FROM quiz_questions qq
JOIN quizzes q ON qq.quiz_id = q.quiz_id
JOIN course_sections cs ON q.section_id = cs.section_id
JOIN courses c ON cs.course_id = c.course_id
ORDER BY c.course_code, q.quiz_id, qq.order_position;

-- ============================================================
-- ATTENDANCE VERIFICATION
-- ============================================================

-- 24. Attendance sessions
SELECT 
  c.course_code,
  c.course_name,
  asess.session_date,
  asess.start_time,
  asess.end_time,
  asess.attendance_type,
  COUNT(ar.record_id) as attendance_records
FROM attendance_sessions asess
JOIN course_sections cs ON asess.section_id = cs.section_id
JOIN courses c ON cs.course_id = c.course_id
LEFT JOIN attendance_records ar ON asess.session_id = ar.session_id
GROUP BY asess.session_id
ORDER BY asess.session_date, asess.start_time;

-- 25. Attendance by student
SELECT 
  u.first_name,
  u.last_name,
  c.course_code,
  COUNT(ar.record_id) as attendance_records,
  SUM(CASE WHEN ar.status = 'present' THEN 1 ELSE 0 END) as present,
  SUM(CASE WHEN ar.status = 'late' THEN 1 ELSE 0 END) as late,
  SUM(CASE WHEN ar.status = 'absent' THEN 1 ELSE 0 END) as absent
FROM attendance_records ar
JOIN attendance_sessions asess ON ar.session_id = asess.session_id
JOIN course_sections cs ON asess.section_id = cs.section_id
JOIN courses c ON cs.course_id = c.course_id
JOIN users u ON ar.student_id = u.user_id
GROUP BY u.user_id, c.course_id
ORDER BY u.last_name, c.course_code;

-- ============================================================
-- GRADES VERIFICATION
-- ============================================================

-- 26. Grade distribution
SELECT 
  c.course_code,
  g.letter_grade,
  COUNT(g.grade_id) as count,
  ROUND(AVG(g.percentage), 2) as avg_percentage,
  MIN(g.percentage) as min_percentage,
  MAX(g.percentage) as max_percentage
FROM grades g
JOIN course_sections cs ON g.section_id = cs.section_id
JOIN courses c ON cs.course_id = c.course_id
GROUP BY c.course_id, g.letter_grade
ORDER BY c.course_code, g.letter_grade;

-- 27. Student grades summary
SELECT 
  u.first_name,
  u.last_name,
  c.course_code,
  COUNT(g.grade_id) as total_grades,
  ROUND(AVG(g.percentage), 2) as avg_score,
  MAX(g.letter_grade) as current_grade
FROM grades g
JOIN users u ON g.student_id = u.user_id
JOIN course_sections cs ON g.section_id = cs.section_id
JOIN courses c ON cs.course_id = c.course_id
GROUP BY u.user_id, c.course_id
ORDER BY u.last_name, c.course_code;

-- ============================================================
-- COMMUNICATION VERIFICATION
-- ============================================================

-- 28. Announcements overview
SELECT 
  a.announcement_id,
  a.title,
  CASE WHEN a.course_id IS NOT NULL 
    THEN CONCAT('Course: ', c.course_code)
    ELSE 'Campus-wide'
  END as scope,
  a.announcement_type,
  a.priority,
  a.is_published,
  a.view_count,
  a.published_at
FROM announcements a
LEFT JOIN courses c ON a.course_id = c.course_id
ORDER BY a.published_at DESC;

-- 29. Messages conversation threads
SELECT 
  m.message_id,
  m.subject,
  u_sender.first_name as sender_first,
  u_sender.last_name as sender_last,
  COUNT(DISTINCT mp.user_id) - 1 as recipient_count,
  m.created_at
FROM messages m
JOIN users u_sender ON m.sender_id = u_sender.user_id
LEFT JOIN message_participants mp ON m.message_id = mp.message_id
GROUP BY m.message_id
ORDER BY m.created_at DESC;

-- 30. Notifications for a user (e.g., student 21)
SELECT 
  n.notification_id,
  n.title,
  n.message,
  n.notification_type,
  n.is_read,
  n.created_at
FROM notifications n
WHERE n.user_id = 21
ORDER BY n.created_at DESC;

-- ============================================================
-- ADVANCED QUERIES
-- ============================================================

-- 31. Full course dashboard for instructor
SELECT 
  c.course_code,
  c.course_name,
  cs.section_number,
  COUNT(DISTINCT ce.student_id) as enrolled_students,
  COUNT(DISTINCT a.assignment_id) as assignments,
  COUNT(DISTINCT q.quiz_id) as quizzes,
  COUNT(DISTINCT asess.session_id) as sessions
FROM course_sections cs
JOIN courses c ON cs.course_id = c.course_id
LEFT JOIN course_enrollments ce ON cs.section_id = ce.section_id AND ce.status = 'enrolled'
LEFT JOIN assignments a ON cs.section_id = a.section_id
LEFT JOIN quizzes q ON cs.section_id = q.section_id
LEFT JOIN attendance_sessions asess ON cs.section_id = asess.section_id
WHERE cs.section_id IN (
  SELECT section_id FROM course_instructors WHERE instructor_user_id = 8
)
GROUP BY cs.section_id;

-- 32. Student performance summary
SELECT 
  u.first_name,
  u.last_name,
  COUNT(DISTINCT ce.section_id) as courses_enrolled,
  COUNT(DISTINCT a.assignment_id) as assigned_work,
  COUNT(DISTINCT asub.submission_id) as submissions,
  ROUND(AVG(g.percentage), 2) as avg_grade,
  COUNT(DISTINCT ar.record_id) as attendance_records
FROM users u
LEFT JOIN course_enrollments ce ON u.user_id = ce.student_id
LEFT JOIN assignments a ON ce.section_id = a.section_id
LEFT JOIN assignment_submissions asub ON u.user_id = asub.student_id AND a.assignment_id = asub.assignment_id
LEFT JOIN grades g ON u.user_id = g.student_id
LEFT JOIN attendance_records ar ON u.user_id = ar.student_id
WHERE u.email LIKE 'student%'
GROUP BY u.user_id
ORDER BY u.last_name
LIMIT 10;

-- 33. Course readiness check (has sections, instructors, schedules)
SELECT 
  c.course_code,
  c.course_name,
  COUNT(DISTINCT cs.section_id) as sections,
  SUM(CASE WHEN ci.instructor_id IS NOT NULL THEN 1 ELSE 0 END) as instructors_assigned,
  SUM(CASE WHEN sched.schedule_id IS NOT NULL THEN 1 ELSE 0 END) as schedules_created,
  SUM(CASE WHEN a.assignment_id IS NOT NULL THEN 1 ELSE 0 END) as assignments,
  COUNT(DISTINCT ce.student_id) as enrolled_students
FROM courses c
LEFT JOIN course_sections cs ON c.course_id = cs.course_id
LEFT JOIN course_instructors ci ON cs.section_id = ci.section_id
LEFT JOIN course_schedules sched ON cs.section_id = sched.section_id
LEFT JOIN assignments a ON cs.section_id = a.section_id
LEFT JOIN course_enrollments ce ON cs.section_id = ce.section_id AND ce.status = 'enrolled'
GROUP BY c.course_id
ORDER BY c.course_code;

-- ============================================================
-- DATA INTEGRITY CHECKS
-- ============================================================

-- 34. Check for orphaned enrollments
SELECT COUNT(*) as orphaned_enrollments
FROM course_enrollments ce
WHERE NOT EXISTS (SELECT 1 FROM course_sections WHERE section_id = ce.section_id)
   OR NOT EXISTS (SELECT 1 FROM users WHERE user_id = ce.student_id);

-- 35. Check for students not enrolled in any course
SELECT u.user_id, u.first_name, u.last_name, u.email
FROM users u
WHERE u.email LIKE 'student%'
  AND NOT EXISTS (SELECT 1 FROM course_enrollments WHERE student_id = u.user_id);

-- 36. Check for courses with no sections
SELECT c.course_id, c.course_code, c.course_name
FROM courses c
WHERE NOT EXISTS (SELECT 1 FROM course_sections WHERE course_id = c.course_id);

-- 37. Check for instructors not assigned to any section
SELECT u.user_id, u.first_name, u.last_name, u.email
FROM users u
WHERE u.email LIKE 'dr.%@%' OR u.email LIKE 'prof.%@%'
  AND NOT EXISTS (SELECT 1 FROM course_instructors WHERE instructor_user_id = u.user_id);

-- ============================================================
-- END OF VERIFICATION QUERIES
-- ============================================================
