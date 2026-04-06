-- =========================================================================
-- DATABASE MIGRATION: Grading System Fix
-- =========================================================================
-- This migration adds missing columns to submission tables and quiz status
-- to properly integrate all assessment grading with the central grades table.
--
-- Run this migration BEFORE deploying the updated backend code.
-- =========================================================================

-- =========================================================================
-- 1. Add score/feedback columns to assignment_submissions
-- =========================================================================
-- These columns persist the grade on the submission record
-- in addition to the central grades table.

-- Check if columns exist before adding
SET @col_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
  WHERE TABLE_SCHEMA = 'eduverse_db' AND TABLE_NAME = 'assignment_submissions' AND COLUMN_NAME = 'score');

SET @sql = IF(@col_exists = 0, 
  'ALTER TABLE assignment_submissions 
   ADD COLUMN score DECIMAL(5,2) NULL COMMENT ''Score achieved (0-100)'' AFTER submission_link,
   ADD COLUMN feedback TEXT NULL COMMENT ''Grader feedback'' AFTER score,
   ADD COLUMN graded_by BIGINT UNSIGNED NULL COMMENT ''User who graded'' AFTER feedback,
   ADD COLUMN graded_at TIMESTAMP NULL COMMENT ''When graded'' AFTER graded_by',
  'SELECT ''Columns already exist in assignment_submissions'' AS message');

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Add foreign key for grader
ALTER TABLE assignment_submissions
ADD CONSTRAINT fk_assignment_submission_grader 
FOREIGN KEY (graded_by) REFERENCES users(user_id) ON DELETE SET NULL;

-- =========================================================================
-- 2. Add score/feedback columns to lab_submissions
-- =========================================================================
-- Previously lab grading only changed status, now it persists scores.

-- Check if columns exist before adding
SET @col_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
  WHERE TABLE_SCHEMA = 'eduverse_db' AND TABLE_NAME = 'lab_submissions' AND COLUMN_NAME = 'score');

SET @sql = IF(@col_exists = 0, 
  'ALTER TABLE lab_submissions 
   ADD COLUMN score DECIMAL(5,2) NULL COMMENT ''Score achieved (0-100)'' AFTER status,
   ADD COLUMN feedback TEXT NULL COMMENT ''Grader feedback'' AFTER score,
   ADD COLUMN graded_by BIGINT UNSIGNED NULL COMMENT ''User who graded'' AFTER feedback,
   ADD COLUMN graded_at TIMESTAMP NULL COMMENT ''When graded'' AFTER graded_by',
  'SELECT ''Columns already exist in lab_submissions'' AS message');

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Add foreign key for grader
ALTER TABLE lab_submissions
ADD CONSTRAINT fk_lab_submission_grader 
FOREIGN KEY (graded_by) REFERENCES users(user_id) ON DELETE SET NULL;

-- =========================================================================
-- 3. Add status column to quizzes
-- =========================================================================
-- Quizzes now have explicit status like assignments/labs.

-- Check if status column exists before adding
SET @col_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
  WHERE TABLE_SCHEMA = 'eduverse_db' AND TABLE_NAME = 'quizzes' AND COLUMN_NAME = 'status');

SET @sql = IF(@col_exists = 0, 
  'ALTER TABLE quizzes
   ADD COLUMN status ENUM(''draft'', ''published'', ''closed'', ''archived'') 
   NOT NULL DEFAULT ''draft'' COMMENT ''Quiz visibility/availability status'' AFTER description',
  'SELECT ''Status column already exists in quizzes'' AS message');

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Set all existing quizzes to published (assuming they were already in use)
UPDATE quizzes SET status = 'published' WHERE status = 'draft';

-- =========================================================================
-- VERIFICATION QUERIES
-- =========================================================================
-- Run these to confirm the changes were applied:

-- SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE 
-- FROM INFORMATION_SCHEMA.COLUMNS 
-- WHERE TABLE_NAME = 'assignment_submissions' 
-- AND COLUMN_NAME IN ('score', 'feedback', 'graded_by', 'graded_at');

-- SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE 
-- FROM INFORMATION_SCHEMA.COLUMNS 
-- WHERE TABLE_NAME = 'lab_submissions' 
-- AND COLUMN_NAME IN ('score', 'feedback', 'graded_by', 'graded_at');

-- SELECT COLUMN_NAME, COLUMN_TYPE 
-- FROM INFORMATION_SCHEMA.COLUMNS 
-- WHERE TABLE_NAME = 'quizzes' AND COLUMN_NAME = 'status';

-- =========================================================================
-- ROLLBACK (if needed)
-- =========================================================================
-- ALTER TABLE assignment_submissions DROP FOREIGN KEY fk_assignment_submission_grader;
-- ALTER TABLE assignment_submissions DROP COLUMN score, DROP COLUMN feedback, DROP COLUMN graded_by, DROP COLUMN graded_at;

-- ALTER TABLE lab_submissions DROP FOREIGN KEY fk_lab_submission_grader;
-- ALTER TABLE lab_submissions DROP COLUMN score, DROP COLUMN feedback, DROP COLUMN graded_by, DROP COLUMN graded_at;

-- ALTER TABLE quizzes DROP COLUMN status;
