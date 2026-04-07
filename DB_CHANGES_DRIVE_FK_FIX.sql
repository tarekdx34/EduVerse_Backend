-- =============================================================================
-- DB_CHANGES_DRIVE_FK_FIX.sql
-- Fix: Update file_id FK in assignment_submissions and lab_submissions 
--      to reference drive_files instead of files table
-- Date: 2026-04-07
-- =============================================================================

-- Purpose:
-- The original schema had file_id referencing the local 'files' table.
-- After implementing Google Drive integration, submissions now link to 
-- drive_files.drive_file_id instead. This fix updates the FK constraints.

-- =============================================================================
-- ASSIGNMENT_SUBMISSIONS TABLE
-- =============================================================================

-- Drop old FK referencing files table
ALTER TABLE assignment_submissions 
DROP FOREIGN KEY assignment_submissions_ibfk_3;

-- Add new FK referencing drive_files table
ALTER TABLE assignment_submissions
ADD CONSTRAINT fk_submission_drive_file
FOREIGN KEY (file_id) REFERENCES drive_files(drive_file_id)
ON DELETE SET NULL;

-- =============================================================================
-- LAB_SUBMISSIONS TABLE
-- =============================================================================

-- Drop old FK referencing files table
ALTER TABLE lab_submissions 
DROP FOREIGN KEY lab_submissions_ibfk_3;

-- Add new FK referencing drive_files table
ALTER TABLE lab_submissions
ADD CONSTRAINT fk_lab_submission_drive_file
FOREIGN KEY (file_id) REFERENCES drive_files(drive_file_id)
ON DELETE SET NULL;

-- =============================================================================
-- VERIFICATION QUERIES
-- =============================================================================

-- Verify assignment_submissions FK
SELECT 
    CONSTRAINT_NAME, 
    COLUMN_NAME,
    REFERENCED_TABLE_NAME, 
    REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE 
WHERE TABLE_SCHEMA = DATABASE()
AND TABLE_NAME = 'assignment_submissions' 
AND COLUMN_NAME = 'file_id'
AND REFERENCED_TABLE_NAME IS NOT NULL;

-- Verify lab_submissions FK  
SELECT 
    CONSTRAINT_NAME, 
    COLUMN_NAME,
    REFERENCED_TABLE_NAME, 
    REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE 
WHERE TABLE_SCHEMA = DATABASE()
AND TABLE_NAME = 'lab_submissions' 
AND COLUMN_NAME = 'file_id'
AND REFERENCED_TABLE_NAME IS NOT NULL;
