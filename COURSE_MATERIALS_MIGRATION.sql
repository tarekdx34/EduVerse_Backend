-- ================================================================
-- COURSE MATERIALS MODULE - DATABASE MIGRATION SCRIPT
-- ================================================================
-- This script adds missing columns to align the database with the
-- updated TypeORM entities for the Course Materials module.
-- 
-- IMPORTANT: Run this script BEFORE starting the application with
-- the updated entities, as TypeORM may try to auto-sync and fail.
-- 
-- Date: 2026-03-10
-- ================================================================

USE eduverse_db;

-- ================================================================
-- PHASE 1: course_materials table updates
-- ================================================================

-- 1.1 Add download_count column (if not exists)
-- Tracks number of times the material has been downloaded
SET @column_exists = (
    SELECT COUNT(*) 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_SCHEMA = 'eduverse_db' 
    AND TABLE_NAME = 'course_materials' 
    AND COLUMN_NAME = 'download_count'
);

SET @sql = IF(@column_exists = 0, 
    'ALTER TABLE course_materials ADD COLUMN download_count INT DEFAULT 0 AFTER view_count',
    'SELECT "Column download_count already exists" AS status');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 1.2 Add week_number column (if not exists)
-- Allows materials to be organized by course week
SET @column_exists = (
    SELECT COUNT(*) 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_SCHEMA = 'eduverse_db' 
    AND TABLE_NAME = 'course_materials' 
    AND COLUMN_NAME = 'week_number'
);

SET @sql = IF(@column_exists = 0, 
    'ALTER TABLE course_materials ADD COLUMN week_number INT NULL AFTER order_index',
    'SELECT "Column week_number already exists" AS status');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 1.3 Add index on week_number for efficient filtering
SET @index_exists = (
    SELECT COUNT(*) 
    FROM INFORMATION_SCHEMA.STATISTICS 
    WHERE TABLE_SCHEMA = 'eduverse_db' 
    AND TABLE_NAME = 'course_materials' 
    AND INDEX_NAME = 'idx_materials_week_number'
);

SET @sql = IF(@index_exists = 0, 
    'CREATE INDEX idx_materials_week_number ON course_materials(course_id, week_number)',
    'SELECT "Index idx_materials_week_number already exists" AS status');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 1.4 Update material_type enum to include 'other'
-- Note: This modifies the enum definition
ALTER TABLE course_materials 
MODIFY COLUMN material_type ENUM('lecture', 'slide', 'video', 'reading', 'link', 'document', 'other') 
DEFAULT 'document';

-- 1.5 Fix is_published default to 0 (draft by default per spec)
ALTER TABLE course_materials 
MODIFY COLUMN is_published TINYINT(1) DEFAULT 0;

-- ================================================================
-- PHASE 2: lecture_sections_labs table updates
-- ================================================================

-- 2.1 Add updated_at column (if not exists)
SET @column_exists = (
    SELECT COUNT(*) 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_SCHEMA = 'eduverse_db' 
    AND TABLE_NAME = 'lecture_sections_labs' 
    AND COLUMN_NAME = 'updated_at'
);

SET @sql = IF(@column_exists = 0, 
    'ALTER TABLE lecture_sections_labs ADD COLUMN updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP',
    'SELECT "Column updated_at already exists" AS status');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ================================================================
-- PHASE 3: Create granular tracking tables (OPTIONAL)
-- These tables allow tracking individual views/downloads by user
-- Comment out if you don't need detailed analytics
-- ================================================================

-- 3.1 Create material_views table
CREATE TABLE IF NOT EXISTS material_views (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    material_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
    viewed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (material_id) REFERENCES course_materials(material_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_material_views_material (material_id),
    INDEX idx_material_views_user (user_id),
    INDEX idx_material_views_time (viewed_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3.2 Create material_downloads table
CREATE TABLE IF NOT EXISTS material_downloads (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    material_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
    downloaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (material_id) REFERENCES course_materials(material_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_material_downloads_material (material_id),
    INDEX idx_material_downloads_user (user_id),
    INDEX idx_material_downloads_time (downloaded_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ================================================================
-- VERIFICATION QUERIES
-- Run these to verify the changes were applied correctly
-- ================================================================

-- Verify course_materials columns
SELECT 
    COLUMN_NAME, 
    DATA_TYPE, 
    COLUMN_TYPE, 
    IS_NULLABLE, 
    COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'eduverse_db' 
AND TABLE_NAME = 'course_materials'
ORDER BY ORDINAL_POSITION;

-- Verify lecture_sections_labs columns
SELECT 
    COLUMN_NAME, 
    DATA_TYPE, 
    COLUMN_TYPE, 
    IS_NULLABLE, 
    COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'eduverse_db' 
AND TABLE_NAME = 'lecture_sections_labs'
ORDER BY ORDINAL_POSITION;

-- Verify new tracking tables exist
SELECT TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'eduverse_db' 
AND TABLE_NAME IN ('material_views', 'material_downloads');

-- ================================================================
-- MIGRATION COMPLETE
-- ================================================================
SELECT 'Course Materials module database migration completed successfully!' AS status;
