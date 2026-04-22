-- Migration: Add file upload restrictions to labs table
-- Date: 2026-04-14
-- Description: Adds allowed_file_types and max_file_size_mb columns to labs table

USE eduverse_db;

ALTER TABLE `labs`
  ADD COLUMN `allowed_file_types` VARCHAR(255) NULL COMMENT 'Comma-separated list of allowed file extensions for student submissions',
  ADD COLUMN `max_file_size_mb` FLOAT NULL COMMENT 'Maximum file size in MB for student submissions';
