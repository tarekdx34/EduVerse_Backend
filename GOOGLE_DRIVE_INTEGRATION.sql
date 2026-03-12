-- ============================================================================
-- GOOGLE DRIVE INTEGRATION - DATABASE MIGRATION
-- ============================================================================
-- This file creates the database schema for Google Drive integration
-- Run this BEFORE starting the backend after implementing the Drive module
-- ============================================================================

-- ============================================================================
-- PHASE 1: CREATE DRIVE FOLDERS TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS `drive_folders` (
  `drive_folder_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `drive_id` VARCHAR(100) NOT NULL COMMENT 'Google Drive folder ID',
  `folder_type` ENUM(
    'root',
    'department',
    'academic_year',
    'semester',
    'course',
    'course_general',
    'course_lectures',
    'course_labs',
    'course_assignments',
    'course_projects',
    'lecture_week',
    'lab',
    'lab_instructions',
    'lab_ta_materials',
    'lab_submissions',
    'lab_student_submission',
    'assignment',
    'assignment_instructions',
    'assignment_submissions',
    'assignment_student_submission',
    'project',
    'project_instructions',
    'project_ta_materials',
    'project_submissions',
    'project_group_submission'
  ) NOT NULL,
  `parent_drive_folder_id` BIGINT UNSIGNED NULL COMMENT 'Self-referencing FK to parent folder',
  `entity_type` ENUM('department', 'semester', 'course', 'lab', 'assignment', 'project', 'user', 'group') NULL COMMENT 'Type of entity this folder represents',
  `entity_id` BIGINT UNSIGNED NULL COMMENT 'ID of the related entity (course_id, lab_id, etc.)',
  `folder_name` VARCHAR(255) NOT NULL COMMENT 'Human-readable folder name',
  `folder_path` VARCHAR(1000) NULL COMMENT 'Full path for reference (e.g., EduVerse/CS/2024-2025/Fall)',
  `created_by` BIGINT UNSIGNED NOT NULL COMMENT 'User who created this folder',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  PRIMARY KEY (`drive_folder_id`),
  UNIQUE KEY `uk_drive_id` (`drive_id`),
  KEY `idx_folder_type` (`folder_type`),
  KEY `idx_parent` (`parent_drive_folder_id`),
  KEY `idx_entity` (`entity_type`, `entity_id`),
  KEY `idx_created_by` (`created_by`),
  
  CONSTRAINT `fk_drive_folders_parent` 
    FOREIGN KEY (`parent_drive_folder_id`) 
    REFERENCES `drive_folders` (`drive_folder_id`) 
    ON DELETE CASCADE,
  CONSTRAINT `fk_drive_folders_created_by` 
    FOREIGN KEY (`created_by`) 
    REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Maps Google Drive folders to entities (courses, labs, etc.)';

-- ============================================================================
-- PHASE 2: CREATE DRIVE FILES TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS `drive_files` (
  `drive_file_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `drive_id` VARCHAR(100) NOT NULL COMMENT 'Google Drive file ID',
  `drive_folder_id` BIGINT UNSIGNED NOT NULL COMMENT 'Parent folder in drive_folders',
  `local_file_id` BIGINT UNSIGNED NULL COMMENT 'FK to local files table (redundant backup)',
  `file_name` VARCHAR(255) NOT NULL COMMENT 'File name in Google Drive',
  `original_file_name` VARCHAR(255) NOT NULL COMMENT 'Original uploaded file name',
  `mime_type` VARCHAR(100) NOT NULL,
  `file_size` BIGINT UNSIGNED NOT NULL COMMENT 'File size in bytes',
  `web_view_link` VARCHAR(500) NULL COMMENT 'Google Drive view link',
  `web_content_link` VARCHAR(500) NULL COMMENT 'Direct download link',
  `thumbnail_link` VARCHAR(500) NULL COMMENT 'Thumbnail URL if available',
  `entity_type` ENUM(
    'course_material',
    'lab_instruction',
    'lab_ta_material',
    'lab_submission',
    'assignment_instruction',
    'assignment_submission',
    'project_instruction',
    'project_ta_material',
    'project_submission'
  ) NULL COMMENT 'Type of entity this file belongs to',
  `entity_id` BIGINT UNSIGNED NULL COMMENT 'ID of the related entity',
  `version_number` INT DEFAULT 1 COMMENT 'Version number for file updates',
  `uploaded_by` BIGINT UNSIGNED NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  PRIMARY KEY (`drive_file_id`),
  UNIQUE KEY `uk_drive_id` (`drive_id`),
  KEY `idx_drive_folder` (`drive_folder_id`),
  KEY `idx_local_file` (`local_file_id`),
  KEY `idx_entity` (`entity_type`, `entity_id`),
  KEY `idx_uploaded_by` (`uploaded_by`),
  
  CONSTRAINT `fk_drive_files_folder` 
    FOREIGN KEY (`drive_folder_id`) 
    REFERENCES `drive_folders` (`drive_folder_id`) 
    ON DELETE CASCADE,
  CONSTRAINT `fk_drive_files_local` 
    FOREIGN KEY (`local_file_id`) 
    REFERENCES `files` (`file_id`) 
    ON DELETE SET NULL,
  CONSTRAINT `fk_drive_files_uploaded_by` 
    FOREIGN KEY (`uploaded_by`) 
    REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Tracks files uploaded to Google Drive';

-- ============================================================================
-- PHASE 3: ADD DRIVE FILE ID TO EXISTING TABLES
-- ============================================================================

-- Add drive_file_id to course_materials table
ALTER TABLE `course_materials` 
ADD COLUMN `drive_file_id` BIGINT UNSIGNED NULL COMMENT 'Reference to Google Drive file' AFTER `file_id`,
ADD KEY `idx_drive_file` (`drive_file_id`),
ADD CONSTRAINT `fk_course_materials_drive_file` 
  FOREIGN KEY (`drive_file_id`) 
  REFERENCES `drive_files` (`drive_file_id`) 
  ON DELETE SET NULL;

-- Add drive_file_id to lab_instructions table
ALTER TABLE `lab_instructions` 
ADD COLUMN `drive_file_id` BIGINT UNSIGNED NULL COMMENT 'Reference to Google Drive file' AFTER `file_id`,
ADD KEY `idx_lab_instructions_drive_file` (`drive_file_id`),
ADD CONSTRAINT `fk_lab_instructions_drive_file` 
  FOREIGN KEY (`drive_file_id`) 
  REFERENCES `drive_files` (`drive_file_id`) 
  ON DELETE SET NULL;

-- Add drive_file_id to lab_submissions table
ALTER TABLE `lab_submissions` 
ADD COLUMN `drive_file_id` BIGINT UNSIGNED NULL COMMENT 'Reference to Google Drive file' AFTER `file_id`,
ADD KEY `idx_lab_submissions_drive_file` (`drive_file_id`),
ADD CONSTRAINT `fk_lab_submissions_drive_file` 
  FOREIGN KEY (`drive_file_id`) 
  REFERENCES `drive_files` (`drive_file_id`) 
  ON DELETE SET NULL;

-- Add drive_file_id to assignment_submissions table
ALTER TABLE `assignment_submissions` 
ADD COLUMN `drive_file_id` BIGINT UNSIGNED NULL COMMENT 'Reference to Google Drive file' AFTER `file_id`,
ADD KEY `idx_assignment_submissions_drive_file` (`drive_file_id`),
ADD CONSTRAINT `fk_assignment_submissions_drive_file` 
  FOREIGN KEY (`drive_file_id`) 
  REFERENCES `drive_files` (`drive_file_id`) 
  ON DELETE SET NULL;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Verify drive_folders table was created
SELECT 'drive_folders table created' AS status 
WHERE EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'drive_folders');

-- Verify drive_files table was created
SELECT 'drive_files table created' AS status 
WHERE EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'drive_files');

-- Verify columns were added
SELECT 'course_materials.drive_file_id added' AS status 
WHERE EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'course_materials' AND column_name = 'drive_file_id');

SELECT 'lab_instructions.drive_file_id added' AS status 
WHERE EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'lab_instructions' AND column_name = 'drive_file_id');

SELECT 'lab_submissions.drive_file_id added' AS status 
WHERE EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'lab_submissions' AND column_name = 'drive_file_id');

SELECT 'assignment_submissions.drive_file_id added' AS status 
WHERE EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'assignment_submissions' AND column_name = 'drive_file_id');

-- ============================================================================
-- ROLLBACK SCRIPT (Use if needed to undo changes)
-- ============================================================================
/*
-- Remove foreign keys first
ALTER TABLE `assignment_submissions` DROP FOREIGN KEY `fk_assignment_submissions_drive_file`;
ALTER TABLE `lab_submissions` DROP FOREIGN KEY `fk_lab_submissions_drive_file`;
ALTER TABLE `lab_instructions` DROP FOREIGN KEY `fk_lab_instructions_drive_file`;
ALTER TABLE `course_materials` DROP FOREIGN KEY `fk_course_materials_drive_file`;

-- Remove columns
ALTER TABLE `assignment_submissions` DROP COLUMN `drive_file_id`;
ALTER TABLE `lab_submissions` DROP COLUMN `drive_file_id`;
ALTER TABLE `lab_instructions` DROP COLUMN `drive_file_id`;
ALTER TABLE `course_materials` DROP COLUMN `drive_file_id`;

-- Drop tables (order matters due to foreign keys)
DROP TABLE IF EXISTS `drive_files`;
DROP TABLE IF EXISTS `drive_folders`;
*/
