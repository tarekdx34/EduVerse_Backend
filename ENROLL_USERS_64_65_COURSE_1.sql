-- ============================================================================
-- EduVerse Course Enrollment and Assignment Script
-- ============================================================================
-- Purpose: Assign users 64 and 65 to Course ID 1 (Section 1)
--          - User 64 (Instructor) → course_instructors as co-instructor
--          - User 65 (TA) → course_tas as teaching assistant
--          - Both → course_enrollments (if they also need to be enrolled)
-- Date Created: 2026-03-10
-- Target Tables: course_instructors, course_tas, course_enrollments
-- ============================================================================

-- Course Section Details:
-- - Course ID: 1
-- - Section ID: 1
-- - Semester ID: 4
-- - Section Number: 01
-- - Location: Building A, Room 101
-- - Max Capacity: 40
-- - Current Enrollment: 7

-- ============================================================================
-- INSTRUCTOR ASSIGNMENTS
-- ============================================================================

-- Assign User 64 as Co-Instructor for Course 1 (Section 1)
INSERT INTO `course_instructors` (
    `user_id`,
    `section_id`,
    `role`,
    `assigned_at`
) VALUES (
    64,                    -- user_id (Instructor)
    1,                     -- section_id (Course 1, Semester 4, Section 01)
    'co_instructor',       -- role (co_instructor since section 1 already has a primary instructor)
    CURRENT_TIMESTAMP      -- assigned_at
);

-- ============================================================================
-- TEACHING ASSISTANT ASSIGNMENTS
-- ============================================================================

-- Assign User 65 as Teaching Assistant for Course 1 (Section 1)
INSERT INTO `course_tas` (
    `user_id`,
    `section_id`,
    `responsibilities`,
    `assigned_at`
) VALUES (
    65,                    -- user_id (Teaching Assistant)
    1,                     -- section_id (Course 1, Semester 4, Section 01)
    'Grading assignments and holding office hours',  -- responsibilities
    CURRENT_TIMESTAMP      -- assigned_at
);

-- ============================================================================
-- ENROLLMENT INSERTS (OPTIONAL - only if instructors/TAs also need student enrollment)
-- ============================================================================
-- Note: Typically instructors and TAs are NOT enrolled as students in the same course.
-- Uncomment below only if this is required for your use case.

-- Enroll User 64 into Course 1 (Section 1) as student
-- INSERT INTO `course_enrollments` (
--     `user_id`,
--     `section_id`,
--     `program_id`,
--     `enrollment_status`,
--     `enrollment_date`
-- ) VALUES (
--     64,                    -- user_id
--     1,                     -- section_id (Course 1, Semester 4, Section 01)
--     1,                     -- program_id
--     'enrolled',            -- enrollment_status
--     CURRENT_TIMESTAMP      -- enrollment_date
-- );

-- Enroll User 65 into Course 1 (Section 1) as student
-- INSERT INTO `course_enrollments` (
--     `user_id`,
--     `section_id`,
--     `program_id`,
--     `enrollment_status`,
--     `enrollment_date`
-- ) VALUES (
--     65,                    -- user_id
--     1,                     -- section_id (Course 1, Semester 4, Section 01)
--     1,                     -- program_id
--     'enrolled',            -- enrollment_status
--     CURRENT_TIMESTAMP      -- enrollment_date
-- );

-- ============================================================================
-- VERIFICATION QUERIES (Optional - Run after INSERT)
-- ============================================================================

-- Verify instructor assignment
-- SELECT 
--     ci.assignment_id,
--     ci.user_id,
--     u.first_name,
--     u.last_name,
--     u.email,
--     c.course_name,
--     cs.section_number,
--     ci.role,
--     ci.assigned_at
-- FROM course_instructors ci
-- JOIN users u ON ci.user_id = u.user_id
-- JOIN course_sections cs ON ci.section_id = cs.section_id
-- JOIN courses c ON cs.course_id = c.course_id
-- WHERE ci.user_id = 64
-- AND cs.section_id = 1;

-- Verify TA assignment
-- SELECT 
--     ct.assignment_id,
--     ct.user_id,
--     u.first_name,
--     u.last_name,
--     u.email,
--     c.course_name,
--     cs.section_number,
--     ct.responsibilities,
--     ct.assigned_at
-- FROM course_tas ct
-- JOIN users u ON ct.user_id = u.user_id
-- JOIN course_sections cs ON ct.section_id = cs.section_id
-- JOIN courses c ON cs.course_id = c.course_id
-- WHERE ct.user_id = 65
-- AND cs.section_id = 1;

-- Verify student enrollments (if uncommented above)
-- SELECT 
--     e.enrollment_id,
--     e.user_id,
--     u.first_name,
--     u.last_name,
--     c.course_name,
--     cs.section_number,
--     e.enrollment_status,
--     e.enrollment_date
-- FROM course_enrollments e
-- JOIN users u ON e.user_id = u.user_id
-- JOIN course_sections cs ON e.section_id = cs.section_id
-- JOIN courses c ON cs.course_id = c.course_id
-- WHERE e.user_id IN (64, 65)
-- AND cs.section_id = 1
-- ORDER BY e.user_id;

-- ============================================================================
-- END OF SCRIPT
-- ============================================================================
