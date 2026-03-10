-- ============================================================
-- FIX: Check existing courses first
-- ============================================================

-- Step 1: View all existing courses
SELECT * FROM courses WHERE deleted_at IS NULL;

-- Step 2: Check semesters
SELECT * FROM semesters;

-- Step 3: If no courses exist, you need to create them first
-- Example: Create Course 1
INSERT INTO `courses` (
  `course_id`,
  `department_id`,
  `course_name`,
  `course_code`,
  `course_description`,
  `credits`,
  `level`,
  `syllabus_url`,
  `status`,
  `created_at`,
  `updated_at`,
  `deleted_at`
) VALUES (
  1,
  1,
  'Introduction to Programming',
  'CS101',
  'Basic programming concepts using Python',
  3,
  'freshman',
  NULL,
  'active',
  NOW(),
  NOW(),
  NULL
);

-- ============================================================
-- Then insert sections using EXISTING course IDs
-- ============================================================

-- First, check what course IDs exist
SELECT course_id, course_code, course_name FROM courses;

-- Replace 1, 2, 3 etc with ACTUAL course IDs from your database

-- Example: If course_id = 5 exists, use that
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
  5,  -- Use actual course ID that exists
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
-- SOLUTION: Get existing course IDs and use them
-- ============================================================

-- Query to find actual course IDs
SELECT 
  course_id,
  course_code,
  course_name,
  department_id
FROM courses 
WHERE deleted_at IS NULL
LIMIT 10;

-- Then use the course_id values shown in the result above
-- For example, if result shows course_id = 5, use:
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
-- Replace 5 with your actual course_id
(1, 5, 1, '01', 40, 25, 'Building A, Room 101', 'open', NOW(), NOW()),
(2, 5, 1, '02', 40, 30, 'Building A, Room 102', 'open', NOW(), NOW()),
(3, 5, 1, '03', 40, 38, 'Building A, Room 103', 'open', NOW(), NOW());

-- ============================================================
-- WORKING EXAMPLE (assuming courses exist)
-- ============================================================

-- Step 1: Check existing courses
SELECT course_id FROM courses WHERE deleted_at IS NULL;

-- Step 2: Check existing semesters
SELECT semester_id FROM semesters;

-- Step 3: Insert sections with VALID foreign keys
-- Change the IDs based on what Step 1 & 2 return

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
-- For each real course_id from Step 1
(100, 5, 1, '01', 40, 25, 'Building A, Room 101', 'open', NOW(), NOW()),
(101, 5, 2, '02', 40, 30, 'Building A, Room 102', 'open', NOW(), NOW()),
(102, 6, 1, '01', 45, 35, 'Building B, Room 201', 'open', NOW(), NOW());

-- ============================================================
-- TROUBLESHOOTING: Check foreign key constraints
-- ============================================================

-- Check if course_id = 1 exists
SELECT COUNT(*) FROM courses WHERE course_id = 1;

-- If result is 0, course doesn't exist - create it first or use different ID

-- Check if semester_id = 1 exists
SELECT COUNT(*) FROM semesters WHERE semester_id = 1;

-- If result is 0, semester doesn't exist - create it first or use different ID

-- ============================================================
-- ERROR FIX SUMMARY
-- ============================================================

/*
ERROR: #1452 - Cannot add or update a child row: a foreign key constraint fails

CAUSE: The course_id or semester_id you're trying to insert doesn't exist in their parent tables

SOLUTION:
1. Run: SELECT course_id FROM courses;
2. Run: SELECT semester_id FROM semesters;
3. Use the IDs that appear in the results
4. Replace 1, 2, 3 with actual existing IDs
5. Try the INSERT again

EXAMPLE:
If courses query returns: 5, 6, 7
And semesters query returns: 1, 2

Then use:
INSERT INTO course_sections VALUES (1, 5, 1, ...)  ← Uses course_id=5, semester_id=1
*/
