-- ============================================================================
-- Test Schedule Data for Full Schedule Testing
-- ============================================================================
-- Creates comprehensive schedules for:
--   1. student.tarek@example.com (user_id: 57)
--   2. instructor.tarek@example.com (user_id: 58)
--   3. ta.tarek@example.com (user_id: 60)
-- ============================================================================

-- Clean up existing test data first
DELETE FROM office_hour_appointments WHERE slot_id IN (SELECT slot_id FROM office_hour_slots WHERE instructor_id IN (58, 60));
DELETE FROM office_hour_slots WHERE instructor_id IN (58, 60);
DELETE FROM course_schedules WHERE section_id IN (1, 2, 3, 4);
DELETE FROM exam_schedules WHERE course_id IN (1, 2);
DELETE FROM calendar_events WHERE user_id IN (57, 58, 60);
DELETE FROM course_enrollments WHERE user_id = 57 AND section_id IN (1, 2, 3, 4);

-- ============================================================================
-- STUDENT SCHEDULE: student.tarek@example.com (user_id: 57)
-- Enrolled in 4 sections with different instructors
-- ============================================================================

-- Enroll student in 4 sections
INSERT INTO student_sections (user_id, section_id, enrollment_status, enrolled_at) VALUES
(57, 1, 'enrolled', NOW()),
(57, 2, 'enrolled', NOW()),
(57, 3, 'enrolled', NOW()),
(57, 4, 'enrolled', NOW());

-- ============================================================================
-- INSTRUCTOR SCHEDULE: instructor.tarek@example.com (user_id: 58)
-- Teaching sections 1 and 2
-- ============================================================================

INSERT INTO section_instructors (section_id, user_id, role, assigned_at) VALUES
(1, 58, 'instructor', NOW()),
(2, 58, 'instructor', NOW());

-- ============================================================================
-- TA SCHEDULE: ta.tarek@example.com (user_id: 60)
-- Assisting in sections 3 and 4
-- ============================================================================

INSERT INTO section_instructors (section_id, user_id, role, assigned_at) VALUES
(3, 60, 'teaching_assistant', NOW()),
(4, 60, 'teaching_assistant', NOW());

-- ============================================================================
-- COURSE SCHEDULES (Lectures, Labs, Tutorials)
-- ============================================================================

-- Section 1: Database Systems (Instructor: 58, Student: 57)
-- MW 09:00-11:00 Lecture + F 14:00-16:00 Lab
INSERT INTO course_schedules (section_id, day_of_week, start_time, end_time, building, room, schedule_type) VALUES
(1, 'monday', '09:00:00', '11:00:00', 'Engineering Building', 'Room 101', 'lecture'),
(1, 'wednesday', '09:00:00', '11:00:00', 'Engineering Building', 'Room 101', 'lecture'),
(1, 'friday', '14:00:00', '16:00:00', 'Computer Lab Building', 'Lab 203', 'lab');

-- Section 2: Software Engineering (Instructor: 58, Student: 57)
-- TTh 11:00-12:30 Lecture + M 16:00-18:00 Tutorial
INSERT INTO course_schedules (section_id, day_of_week, start_time, end_time, building, room, schedule_type) VALUES
(2, 'tuesday', '11:00:00', '12:30:00', 'Engineering Building', 'Room 205', 'lecture'),
(2, 'thursday', '11:00:00', '12:30:00', 'Engineering Building', 'Room 205', 'lecture'),
(2, 'monday', '16:00:00', '18:00:00', 'Engineering Building', 'Room 301', 'tutorial');

-- Section 3: Data Structures (TA: 60, Student: 57)
-- MW 13:00-14:30 Lecture + Th 14:00-16:00 Lab
INSERT INTO course_schedules (section_id, day_of_week, start_time, end_time, building, room, schedule_type) VALUES
(3, 'monday', '13:00:00', '14:30:00', 'Science Building', 'Room 102', 'lecture'),
(3, 'wednesday', '13:00:00', '14:30:00', 'Science Building', 'Room 102', 'lecture'),
(3, 'thursday', '14:00:00', '16:00:00', 'Computer Lab Building', 'Lab 105', 'lab');

-- Section 4: Computer Networks (TA: 60, Student: 57)
-- TTh 09:00-10:30 Lecture + F 10:00-12:00 Lab
INSERT INTO course_schedules (section_id, day_of_week, start_time, end_time, building, room, schedule_type) VALUES
(4, 'tuesday', '09:00:00', '10:30:00', 'Engineering Building', 'Room 303', 'lecture'),
(4, 'thursday', '09:00:00', '10:30:00', 'Engineering Building', 'Room 303', 'lecture'),
(4, 'friday', '10:00:00', '12:00:00', 'Computer Lab Building', 'Lab 201', 'lab');

-- ============================================================================
-- EXAM SCHEDULES
-- ============================================================================

-- Midterm Exams (April 15-18, 2026)
-- Section 1: course_id=1, Section 2: course_id=1, Section 3: course_id=2, Section 4: course_id=2
INSERT INTO exam_schedules (course_id, semester_id, exam_type, title, exam_date, start_time, duration_minutes, location) VALUES
(1, 4, 'midterm', 'CS101 Midterm Exam - Section 1', '2026-04-15', '09:00:00', 120, 'Exam Hall A - Hall 1'),
(1, 4, 'midterm', 'CS101 Midterm Exam - Section 2', '2026-04-16', '13:00:00', 120, 'Exam Hall B - Hall 2'),
(2, 4, 'midterm', 'Data Structures Midterm - Section 1', '2026-04-17', '09:00:00', 120, 'Exam Hall A - Hall 3'),
(2, 4, 'midterm', 'Data Structures Midterm - Section 2', '2026-04-18', '13:00:00', 120, 'Exam Hall B - Hall 4');

-- Final Exams (May 20-23, 2026)
INSERT INTO exam_schedules (course_id, semester_id, exam_type, title, exam_date, start_time, duration_minutes, location) VALUES
(1, 4, 'final', 'CS101 Final Exam - Section 1', '2026-05-20', '09:00:00', 180, 'Exam Hall A - Hall 1'),
(1, 4, 'final', 'CS101 Final Exam - Section 2', '2026-05-21', '13:00:00', 180, 'Exam Hall B - Hall 2'),
(2, 4, 'final', 'Data Structures Final - Section 1', '2026-05-22', '09:00:00', 180, 'Exam Hall A - Hall 3'),
(2, 4, 'final', 'Data Structures Final - Section 2', '2026-05-23', '13:00:00', 180, 'Exam Hall B - Hall 4');

-- ============================================================================
-- OFFICE HOURS
-- ============================================================================

-- Instructor Office Hours (instructor.tarek@example.com, user_id: 58)
-- Tuesday & Thursday 14:00-16:00
INSERT INTO office_hour_slots (instructor_id, day_of_week, start_time, end_time, location, max_appointments, mode, is_recurring, status) VALUES
(58, 'tuesday', '14:00:00', '16:00:00', 'Engineering Building, Office 205', 4, 'in_person', 1, 'active'),
(58, 'thursday', '14:00:00', '16:00:00', 'Engineering Building, Office 205', 4, 'in_person', 1, 'active');

-- TA Office Hours (ta.tarek@example.com, user_id: 60)
-- Monday & Wednesday 15:00-17:00
INSERT INTO office_hour_slots (instructor_id, day_of_week, start_time, end_time, location, max_appointments, mode, is_recurring, status) VALUES
(60, 'monday', '15:00:00', '17:00:00', 'Computer Lab Building, TA Room 101', 4, 'in_person', 1, 'active'),
(60, 'wednesday', '15:00:00', '17:00:00', 'Computer Lab Building, TA Room 101', 4, 'in_person', 1, 'active');

-- ============================================================================
-- CALENDAR EVENTS (Personal/Academic)
-- ============================================================================

-- Student personal events
INSERT INTO calendar_events (user_id, title, description, event_date, start_time, end_time, location, event_type, color, status) VALUES
(57, 'Study Group - Database', 'Group study session for midterm prep', '2026-04-12', '18:00:00', '20:00:00', 'Library Room 301', 'meeting', '#FF5733', 'confirmed'),
(57, 'Career Workshop', 'Resume building workshop', '2026-04-14', '15:00:00', '17:00:00', 'Career Center', 'other', '#3498DB', 'confirmed');

-- Instructor academic events
INSERT INTO calendar_events (user_id, title, description, event_date, start_time, end_time, location, event_type, color, status) VALUES
(58, 'Faculty Meeting', 'Monthly department meeting', '2026-04-10', '13:00:00', '15:00:00', 'Admin Building, Conference Room', 'meeting', '#9B59B6', 'confirmed'),
(58, 'Research Presentation', 'Present research findings', '2026-04-19', '10:00:00', '12:00:00', 'Research Center, Auditorium', 'seminar', '#E74C3C', 'confirmed');

-- TA events
INSERT INTO calendar_events (user_id, title, description, event_date, start_time, end_time, location, event_type, color, status) VALUES
(60, 'TA Training', 'Grading guidelines workshop', '2026-04-11', '14:00:00', '16:00:00', 'Teaching Center', 'other', '#1ABC9C', 'confirmed'),
(60, 'Lab Preparation', 'Prepare lab equipment for next session', '2026-04-13', '09:00:00', '11:00:00', 'Computer Lab Building, Lab 105', 'other', '#F39C12', 'confirmed');

-- ============================================================================
-- CAMPUS EVENTS (Already created in previous migration, just adding registrations)
-- ============================================================================

-- Register all three users for Fun Day (campus_event_id: 1)
INSERT INTO campus_event_registrations (event_id, user_id, registration_status, notes, registered_at) VALUES
(1, 57, 'registered', 'Looking forward to it!', NOW()),
(1, 58, 'registered', 'Will join after morning class', NOW()),
(1, 60, 'registered', NULL, NOW());

-- Register student for Career Fair (campus_event_id: 3)
INSERT INTO campus_event_registrations (event_id, user_id, registration_status, notes, registered_at) VALUES
(3, 57, 'registered', 'Interested in tech companies', NOW());

-- Register instructor for Research Symposium (campus_event_id: 4)
INSERT INTO campus_event_registrations (event_id, user_id, registration_status, notes, registered_at) VALUES
(4, 58, 'registered', 'Will present a paper', NOW());

-- ============================================================================
-- SUMMARY
-- ============================================================================
-- 
-- Student (user_id: 57) Schedule:
--   Monday:    09:00-11:00 Database Lecture, 13:00-14:30 Data Structures, 16:00-18:00 SE Tutorial
--   Tuesday:   09:00-10:30 Networks Lecture, 11:00-12:30 SE Lecture
--   Wednesday: 09:00-11:00 Database Lecture, 13:00-14:30 Data Structures
--   Thursday:  09:00-10:30 Networks Lecture, 11:00-12:30 SE Lecture, 14:00-16:00 Data Structures Lab
--   Friday:    10:00-12:00 Networks Lab, 14:00-16:00 Database Lab
--   Exams: 4 midterms (Apr 15-18), 4 finals (May 20-23)
--   Campus Events: Fun Day (Apr 20), Career Fair (Apr 25)
--   Personal Events: Study Group (Apr 12), Career Workshop (Apr 14)
--
-- Instructor (user_id: 58) Schedule:
--   Monday:    09:00-11:00 Database Lecture, 16:00-18:00 SE Tutorial
--   Tuesday:   11:00-12:30 SE Lecture, 14:00-16:00 Office Hours
--   Wednesday: 09:00-11:00 Database Lecture
--   Thursday:  11:00-12:30 SE Lecture, 14:00-16:00 Office Hours
--   Friday:    14:00-16:00 Database Lab
--   Campus Events: Fun Day (Apr 20), Research Symposium (May 5)
--   Personal Events: Faculty Meeting (Apr 10), Research Presentation (Apr 19)
--
-- TA (user_id: 60) Schedule:
--   Monday:    13:00-14:30 Data Structures Lecture, 15:00-17:00 Office Hours
--   Tuesday:   09:00-10:30 Networks Lecture
--   Wednesday: 13:00-14:30 Data Structures Lecture, 15:00-17:00 Office Hours
--   Thursday:  09:00-10:30 Networks Lecture, 14:00-16:00 Data Structures Lab
--   Friday:    10:00-12:00 Networks Lab
--   Campus Events: Fun Day (Apr 20)
--   Personal Events: TA Training (Apr 11), Lab Preparation (Apr 13)
--
-- ============================================================================

SELECT 'Test schedule data inserted successfully!' AS Status;
