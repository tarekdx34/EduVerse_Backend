-- ============================================================================
-- EduVerse Database Schema Fixes
-- Version: 1.0
-- Created: For fixing entity-database mismatches
-- Description: Contains SQL fixes for schema inconsistencies between
--              TypeORM entities and actual database tables
-- ============================================================================

-- ============================================================================
-- Fix 1: Add missing columns to courses table
-- ============================================================================
-- The Course entity (src/modules/courses/entities/course.entity.ts) expects
-- these columns but they may be missing from older database schemas.
--
-- Error message this fixes:
--   "QueryFailedError: Unknown column 'course.instructor_id' in 'field list'"
--
-- This error occurs when accessing endpoints that JOIN to the courses table:
--   - GET /api/labs
--   - GET /api/assignments
--   - Any query with relations: ['course']
-- ============================================================================

-- Check if columns exist before adding (run this to see current state)
-- SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS 
-- WHERE TABLE_SCHEMA = 'eduverse_db' AND TABLE_NAME = 'courses' 
-- AND COLUMN_NAME IN ('instructor_id', 'ta_ids');

-- Add the missing columns
ALTER TABLE courses
ADD COLUMN instructor_id BIGINT UNSIGNED NULL COMMENT 'Primary instructor user ID',
ADD COLUMN ta_ids JSON NULL COMMENT 'Array of TA user IDs';

-- Note: If columns already exist, you'll get an error. That's expected.
-- You can safely ignore "Duplicate column name" errors.

-- ============================================================================
-- Verification Queries
-- ============================================================================

-- Verify the columns were added
SHOW COLUMNS FROM courses WHERE Field IN ('instructor_id', 'ta_ids');

-- Test that labs endpoint query works
SELECT l.*, c.course_code, c.course_name 
FROM labs l
LEFT JOIN courses c ON l.course_id = c.course_id
LIMIT 1;

-- Test that assignments endpoint query works
SELECT a.*, c.course_code, c.course_name
FROM assignments a
LEFT JOIN courses c ON a.course_id = c.course_id
LIMIT 1;

-- ============================================================================
-- Rollback (if needed)
-- ============================================================================
-- WARNING: Only run this if you need to undo the changes
-- 
-- ALTER TABLE courses
-- DROP COLUMN instructor_id,
-- DROP COLUMN ta_ids;
-- ============================================================================
