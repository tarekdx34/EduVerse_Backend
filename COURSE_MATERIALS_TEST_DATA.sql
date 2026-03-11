-- ================================================================
-- COURSE MATERIALS MODULE - TEST DATA
-- ================================================================
-- Mock data for testing course materials endpoints
-- 
-- Test Users:
-- - Instructor: prof.smith@campus.edu (user_id: 2) - assigned to course 1
-- - TA: ta.brown@campus.edu (user_id: 5) - assigned to course 1  
-- - Student: alice.student@campus.edu (user_id: 7)
-- - Admin: admin@campus.edu (user_id: 1)
-- ================================================================

USE eduverse_db;

-- ================================================================
-- STEP 1: Ensure instructor is assigned to course 1
-- ================================================================

-- Check/create section for course 1 if needed
INSERT INTO course_sections (course_id, semester_id, max_capacity, current_enrollment)
SELECT 1, 1, 30, 15
WHERE NOT EXISTS (
    SELECT 1 FROM course_sections WHERE course_id = 1
);

-- Get section_id for course 1
SET @section_id = (SELECT section_id FROM course_sections WHERE course_id = 1 LIMIT 1);

-- Assign instructor (user_id: 2 - prof.smith) to course 1
INSERT INTO course_instructors (user_id, section_id, role, assigned_at)
SELECT 2, @section_id, 'primary', NOW()
WHERE NOT EXISTS (
    SELECT 1 FROM course_instructors WHERE user_id = 2 AND section_id = @section_id
);

-- Assign TA (user_id: 5 - ta.brown) to course 1
INSERT INTO course_tas (user_id, section_id, assigned_at)
SELECT 5, @section_id, NOW()
WHERE NOT EXISTS (
    SELECT 1 FROM course_tas WHERE user_id = 5 AND section_id = @section_id
);

-- ================================================================
-- STEP 2: Insert test course materials for various scenarios
-- ================================================================

-- Material 1: Published lecture for Week 1
INSERT INTO course_materials (course_id, material_type, title, description, external_url, order_index, week_number, uploaded_by, is_published, published_at, view_count, download_count)
VALUES (1, 'lecture', 'Week 1: Introduction to Programming', 'Overview of programming concepts and course structure', NULL, 1, 1, 2, 1, NOW(), 25, 10);

-- Material 2: Published slides for Week 1
INSERT INTO course_materials (course_id, material_type, title, description, external_url, order_index, week_number, uploaded_by, is_published, published_at, view_count, download_count)
VALUES (1, 'slide', 'Week 1: Presentation Slides', 'Accompanying slides for week 1 lecture', 'https://slides.example.com/week1', 2, 1, 2, 1, NOW(), 18, 5);

-- Material 3: Published video for Week 1
INSERT INTO course_materials (course_id, material_type, title, description, external_url, order_index, week_number, uploaded_by, is_published, published_at, view_count, download_count)
VALUES (1, 'video', 'Week 1: Video Tutorial', 'Hands-on coding demonstration', 'https://www.youtube.com/embed/dQw4w9WgXcQ', 3, 1, 2, 1, NOW(), 45, 0);

-- Material 4: Published reading for Week 2
INSERT INTO course_materials (course_id, material_type, title, description, external_url, order_index, week_number, uploaded_by, is_published, published_at, view_count, download_count)
VALUES (1, 'reading', 'Week 2: Variables and Data Types', 'Chapter 2 from textbook', 'https://textbook.example.com/chapter2', 1, 2, 2, 1, NOW(), 12, 3);

-- Material 5: Unpublished (draft) document for Week 2
INSERT INTO course_materials (course_id, material_type, title, description, external_url, order_index, week_number, uploaded_by, is_published, published_at, view_count, download_count)
VALUES (1, 'document', 'Week 2: Lab Exercises (DRAFT)', 'Practice exercises - not yet ready', NULL, 2, 2, 5, 0, NULL, 2, 0);

-- Material 6: Published link for Week 3
INSERT INTO course_materials (course_id, material_type, title, description, external_url, order_index, week_number, uploaded_by, is_published, published_at, view_count, download_count)
VALUES (1, 'link', 'Week 3: External Resources', 'Additional learning resources', 'https://resources.example.com/week3', 1, 3, 2, 1, NOW(), 8, 0);

-- Material 7: Published document with file (simulated)
INSERT INTO course_materials (course_id, material_type, title, description, external_url, order_index, week_number, uploaded_by, is_published, published_at, view_count, download_count)
VALUES (1, 'document', 'Course Syllabus', 'Complete course syllabus and schedule', NULL, 0, NULL, 2, 1, NOW(), 100, 50);

-- Material 8: Material with 'other' type
INSERT INTO course_materials (course_id, material_type, title, description, external_url, order_index, week_number, uploaded_by, is_published, published_at, view_count, download_count)
VALUES (1, 'other', 'Supplementary Material', 'Miscellaneous course content', 'https://misc.example.com', 99, NULL, 2, 1, NOW(), 5, 1);

-- ================================================================
-- STEP 3: Insert test course structure items
-- ================================================================

-- Week 1 structure
INSERT INTO lecture_sections_labs (course_id, organization_type, title, description, week_number, order_index)
VALUES (1, 'lecture', 'Week 1 Lecture: Introduction', 'Course introduction and overview', 1, 1);

INSERT INTO lecture_sections_labs (course_id, organization_type, title, description, week_number, order_index)
VALUES (1, 'lab', 'Week 1 Lab: Setup', 'Development environment setup', 1, 2);

-- Week 2 structure
INSERT INTO lecture_sections_labs (course_id, organization_type, title, description, week_number, order_index)
VALUES (1, 'lecture', 'Week 2 Lecture: Variables', 'Variables and data types', 2, 1);

INSERT INTO lecture_sections_labs (course_id, organization_type, title, description, week_number, order_index)
VALUES (1, 'section', 'Week 2 Discussion: Best Practices', 'Discussion on coding standards', 2, 2);

-- Week 3 structure
INSERT INTO lecture_sections_labs (course_id, organization_type, title, description, week_number, order_index)
VALUES (1, 'lecture', 'Week 3 Lecture: Control Flow', 'If statements and loops', 3, 1);

INSERT INTO lecture_sections_labs (course_id, organization_type, title, description, week_number, order_index)
VALUES (1, 'tutorial', 'Week 3 Tutorial: Practice', 'Guided practice session', 3, 2);

-- ================================================================
-- STEP 4: Insert tracking data (optional - for analytics testing)
-- ================================================================

-- Only insert if tables exist (from migration)
INSERT INTO material_views (material_id, user_id, viewed_at)
SELECT m.material_id, 7, DATE_SUB(NOW(), INTERVAL FLOOR(RAND()*30) DAY)
FROM course_materials m WHERE m.course_id = 1 AND m.is_published = 1
LIMIT 5;

INSERT INTO material_downloads (material_id, user_id, downloaded_at)
SELECT m.material_id, 7, DATE_SUB(NOW(), INTERVAL FLOOR(RAND()*30) DAY)
FROM course_materials m WHERE m.course_id = 1 AND m.is_published = 1 AND m.material_type IN ('document', 'slide')
LIMIT 3;

-- ================================================================
-- VERIFICATION QUERIES
-- ================================================================

-- Check materials count
SELECT COUNT(*) as total_materials, 
       SUM(is_published) as published,
       COUNT(*) - SUM(is_published) as drafts
FROM course_materials WHERE course_id = 1;

-- Check materials by week
SELECT week_number, COUNT(*) as count 
FROM course_materials 
WHERE course_id = 1 
GROUP BY week_number ORDER BY week_number;

-- Check structure items
SELECT organization_type, COUNT(*) as count 
FROM lecture_sections_labs 
WHERE course_id = 1 
GROUP BY organization_type;

-- Verify instructor assignment
SELECT ci.user_id, u.email, c.course_name
FROM course_instructors ci
JOIN users u ON ci.user_id = u.user_id
JOIN course_sections cs ON ci.section_id = cs.section_id
JOIN courses c ON cs.course_id = c.course_id
WHERE ci.user_id = 2;

SELECT 'Test data insertion complete!' AS status;
