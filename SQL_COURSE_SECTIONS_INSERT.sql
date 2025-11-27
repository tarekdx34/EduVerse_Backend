-- ============================================================
-- INSERT SQL DATA FOR course_sections TABLE
-- ============================================================

-- Table Structure Reference:
-- CREATE TABLE `course_sections` (
--   `section_id` bigint(20) UNSIGNED NOT NULL,
--   `course_id` bigint(20) UNSIGNED NOT NULL,
--   `semester_id` bigint(20) UNSIGNED NOT NULL,
--   `section_number` varchar(10) NOT NULL,
--   `max_capacity` int(11) DEFAULT 50,
--   `current_enrollment` int(11) DEFAULT 0,
--   `location` varchar(100) DEFAULT NULL,
--   `status` enum('open','closed','full','cancelled') DEFAULT 'open',
--   `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
--   `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
-- )

-- ============================================================
-- BASIC INSERT (Single Section)
-- ============================================================

INSERT INTO `course_sections` (
  `section_id`,
  `course_id`,
  `semester_id`,
  `section_number`,
  `max_capacity`,
  `current_enrollment`,
  `location`,
  `status`,
  `created_at`,
  `updated_at`
) VALUES (
  1,
  1,
  1,
  '01',
  40,
  25,
  'Building A, Room 101',
  'open',
  NOW(),
  NOW()
);

-- ============================================================
-- BULK INSERT (Multiple Sections for Different Courses)
-- ============================================================

INSERT INTO `course_sections` (
  `section_id`,
  `course_id`,
  `semester_id`,
  `section_number`,
  `max_capacity`,
  `current_enrollment`,
  `location`,
  `status`,
  `created_at`,
  `updated_at`
) VALUES 
-- Course 1 (Introduction to Programming) - Fall 2024
(1, 1, 1, '01', 40, 35, 'Building A, Room 101', 'open', NOW(), NOW()),
(2, 1, 1, '02', 40, 38, 'Building A, Room 102', 'open', NOW(), NOW()),
(3, 1, 1, '03', 40, 40, 'Building A, Room 103', 'full', NOW(), NOW()),

-- Course 2 (Data Structures) - Fall 2024
(4, 2, 1, '01', 45, 28, 'Building B, Room 201', 'open', NOW(), NOW()),
(5, 2, 1, '02', 45, 42, 'Building B, Room 202', 'open', NOW(), NOW()),

-- Course 3 (Database Systems) - Fall 2024
(6, 3, 1, '01', 35, 30, 'Building B, Room 211', 'open', NOW(), NOW()),

-- Course 4 (Artificial Intelligence) - Fall 2024
(7, 4, 1, '01', 50, 15, 'Building C, Room 301', 'open', NOW(), NOW()),

-- Course 5 (Calculus I) - Fall 2024
(8, 5, 1, '01', 50, 40, 'Building C, Room 302', 'open', NOW(), NOW()),
(9, 5, 1, '02', 50, 38, 'Building C, Room 303', 'open', NOW(), NOW()),

-- Course 6 (Linear Algebra) - Fall 2024
(10, 6, 1, '01', 45, 32, 'Building C, Room 311', 'open', NOW(), NOW()),

-- Course 7 (Physics I) - Fall 2024
(11, 7, 1, '01', 50, 25, 'Building D, Room 401', 'open', NOW(), NOW()),

-- Course 8 (Business Management) - Fall 2024
(12, 8, 1, '01', 60, 45, 'Building D, Room 501', 'open', NOW(), NOW());

-- ============================================================
-- MULTI-SEMESTER SECTIONS (Same Course, Different Semesters)
-- ============================================================

-- Course 1 (Introduction to Programming) - Spring 2025 (semester_id = 2)
INSERT INTO `course_sections` (
  `section_id`,
  `course_id`,
  `semester_id`,
  `section_number`,
  `max_capacity`,
  `current_enrollment`,
  `location`,
  `status`,
  `created_at`,
  `updated_at`
) VALUES 
(13, 1, 2, '01', 40, 18, 'Building A, Room 104', 'open', NOW(), NOW()),
(14, 1, 2, '02', 40, 22, 'Building A, Room 105', 'open', NOW(), NOW()),

-- Course 2 (Data Structures) - Spring 2025
(15, 2, 2, '01', 45, 31, 'Building B, Room 203', 'open', NOW(), NOW()),

-- Course 3 (Database Systems) - Spring 2025
(16, 3, 2, '01', 35, 25, 'Building B, Room 212', 'open', NOW(), NOW()),

-- Course 5 (Calculus I) - Spring 2025
(17, 5, 2, '01', 50, 35, 'Building C, Room 304', 'open', NOW(), NOW());

-- ============================================================
-- SECTIONS WITH DIFFERENT STATUSES
-- ============================================================

-- For testing different section statuses
INSERT INTO `course_sections` (
  `section_id`,
  `course_id`,
  `semester_id`,
  `section_number`,
  `max_capacity`,
  `current_enrollment`,
  `location`,
  `status`,
  `created_at`,
  `updated_at`
) VALUES 
-- OPEN Status
(18, 4, 2, '01', 50, 20, 'Building C, Room 305', 'open', NOW(), NOW()),

-- FULL Status (at max capacity)
(19, 6, 2, '01', 30, 30, 'Building C, Room 312', 'full', NOW(), NOW()),

-- CLOSED Status
(20, 7, 2, '01', 50, 35, 'Building D, Room 402', 'closed', NOW(), NOW()),

-- CANCELLED Status
(21, 8, 2, '01', 60, 0, 'Building D, Room 502', 'cancelled', NOW(), NOW());

-- ============================================================
-- BATCH INSERT (If you need to add many at once)
-- ============================================================

-- Example: Add sections for all courses in Summer 2025 (semester_id = 3)
INSERT INTO `course_sections` (
  `section_id`,
  `course_id`,
  `semester_id`,
  `section_number`,
  `max_capacity`,
  `current_enrollment`,
  `location`,
  `status`,
  `created_at`,
  `updated_at`
) VALUES 
(22, 1, 3, '01', 40, 12, 'Building A, Room 106', 'open', NOW(), NOW()),
(23, 2, 3, '01', 45, 8, 'Building B, Room 204', 'open', NOW(), NOW()),
(24, 3, 3, '01', 35, 15, 'Building B, Room 213', 'open', NOW(), NOW()),
(25, 4, 3, '01', 50, 5, 'Building C, Room 306', 'open', NOW(), NOW()),
(26, 5, 3, '01', 50, 18, 'Building C, Room 307', 'open', NOW(), NOW()),
(27, 6, 3, '01', 45, 10, 'Building C, Room 313', 'open', NOW(), NOW()),
(28, 7, 3, '01', 50, 22, 'Building D, Room 403', 'open', NOW(), NOW()),
(29, 8, 3, '01', 60, 30, 'Building D, Room 503', 'open', NOW(), NOW());

-- ============================================================
-- VERIFY THE INSERTS
-- ============================================================

-- View all sections
SELECT * FROM course_sections;

-- View sections by course
SELECT * FROM course_sections WHERE course_id = 1;

-- View sections by semester
SELECT * FROM course_sections WHERE semester_id = 1;

-- View sections by status
SELECT * FROM course_sections WHERE status = 'open';

-- View full sections
SELECT * FROM course_sections WHERE current_enrollment >= max_capacity;

-- Count sections per course
SELECT 
  course_id, 
  COUNT(*) as total_sections, 
  SUM(current_enrollment) as total_enrolled,
  SUM(max_capacity) as total_capacity
FROM course_sections
GROUP BY course_id;

-- ============================================================
-- IMPORTANT NOTES
-- ============================================================

/*
1. FOREIGN KEY CONSTRAINTS:
   - course_id must exist in the courses table
   - semester_id must exist in the semesters table

2. VALID STATUS VALUES:
   - 'open'      : Section is accepting enrollments
   - 'closed'    : Section is not accepting new enrollments
   - 'full'      : Section has reached max capacity
   - 'cancelled' : Section has been cancelled

3. SECTION_ID:
   - Must be unique
   - Should auto-increment if set as AUTO_INCREMENT
   - Adjust values based on existing data

4. ENROLLMENT RULES:
   - current_enrollment should be <= max_capacity
   - If current_enrollment == max_capacity, consider setting status to 'full'

5. LOCATION FORMAT:
   - Recommended: "Building Name, Room Number"
   - Example: "Building A, Room 101"

6. TIMESTAMPS:
   - NOW() automatically sets current timestamp
   - created_at and updated_at should be the same initially
   - updated_at will update automatically on any record modification
*/

-- ============================================================
-- EXAMPLE: Update section to FULL when capacity is reached
-- ============================================================

UPDATE course_sections 
SET status = 'full' 
WHERE current_enrollment >= max_capacity AND status != 'full';

-- ============================================================
-- EXAMPLE: Auto-close sections for a specific course
-- ============================================================

UPDATE course_sections 
SET status = 'closed' 
WHERE course_id = 1 AND semester_id = 1;

-- ============================================================
-- EXAMPLE: Check for data integrity issues
-- ============================================================

-- Find sections with enrollment exceeding capacity
SELECT 
  section_id,
  course_id,
  max_capacity,
  current_enrollment,
  (current_enrollment - max_capacity) as excess
FROM course_sections
WHERE current_enrollment > max_capacity;

-- Find sections with mismatched status and enrollment
SELECT 
  section_id,
  max_capacity,
  current_enrollment,
  status
FROM course_sections
WHERE (current_enrollment >= max_capacity AND status != 'full')
  OR  (current_enrollment < max_capacity AND status = 'full');
