-- ============================================================
-- EduVerse Database Schema Updates
-- Generated from three-way analysis (Frontend ↔ Plan ↔ DB)
-- Run this in phpMyAdmin after backing up your database
-- ============================================================

-- ============================================================
-- 1. Add status columns for draft/publish workflow
-- ============================================================
ALTER TABLE `assignments` ADD COLUMN `status` ENUM('draft','published','closed','archived') DEFAULT 'draft' AFTER `allowed_file_types`;

ALTER TABLE `labs` ADD COLUMN `status` ENUM('draft','published','closed','archived') DEFAULT 'draft' AFTER `weight`;

ALTER TABLE `quizzes` ADD COLUMN `status` ENUM('draft','published','closed','archived') DEFAULT 'draft' AFTER `weight`;

-- ============================================================
-- 2. Add title and status to exam_schedules
-- ============================================================
ALTER TABLE `exam_schedules` ADD COLUMN `title` VARCHAR(255) DEFAULT NULL AFTER `exam_type`;
ALTER TABLE `exam_schedules` ADD COLUMN `status` ENUM('scheduled','in_progress','completed','cancelled','postponed') DEFAULT 'scheduled' AFTER `instructions`;

-- ============================================================
-- 3. Add status to discussion threads
-- ============================================================
ALTER TABLE `course_chat_threads` ADD COLUMN `status` ENUM('open','answered','closed') DEFAULT 'open' AFTER `description`;

-- ============================================================
-- 4. Add color to calendar events (for frontend display)
-- ============================================================
ALTER TABLE `calendar_events` ADD COLUMN `color` VARCHAR(7) DEFAULT NULL AFTER `location`;

-- ============================================================
-- 5. Add view_count to course materials
-- ============================================================
ALTER TABLE `course_materials` ADD COLUMN `view_count` INT(11) DEFAULT 0 AFTER `download_count`;

-- ============================================================
-- 6. Create Office Hours tables (Phase 11)
-- Roles: INSTRUCTOR/ADMIN/IT_ADMIN manage slots, STUDENT books
-- ============================================================
CREATE TABLE IF NOT EXISTS `office_hour_slots` (
  `slot_id` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `instructor_id` BIGINT(20) UNSIGNED NOT NULL,
  `day_of_week` ENUM('monday','tuesday','wednesday','thursday','friday','saturday','sunday') NOT NULL,
  `start_time` TIME NOT NULL,
  `end_time` TIME NOT NULL,
  `location` VARCHAR(255) DEFAULT NULL,
  `mode` ENUM('in_person','online','hybrid') DEFAULT 'in_person',
  `meeting_url` VARCHAR(500) DEFAULT NULL,
  `max_appointments` INT(11) DEFAULT 4,
  `is_recurring` TINYINT(1) DEFAULT 1,
  `effective_from` DATE DEFAULT NULL,
  `effective_until` DATE DEFAULT NULL,
  `status` ENUM('active','cancelled','suspended') DEFAULT 'active',
  `notes` TEXT DEFAULT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`slot_id`),
  KEY `fk_office_hours_instructor` (`instructor_id`),
  CONSTRAINT `fk_office_hours_instructor` FOREIGN KEY (`instructor_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `office_hour_appointments` (
  `appointment_id` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `slot_id` BIGINT(20) UNSIGNED NOT NULL,
  `student_id` BIGINT(20) UNSIGNED NOT NULL,
  `appointment_date` DATE NOT NULL,
  `start_time` TIME NOT NULL,
  `end_time` TIME NOT NULL,
  `topic` VARCHAR(255) DEFAULT NULL,
  `notes` TEXT DEFAULT NULL,
  `status` ENUM('booked','confirmed','cancelled','completed','no_show') DEFAULT 'booked',
  `cancelled_by` BIGINT(20) UNSIGNED DEFAULT NULL,
  `cancelled_at` TIMESTAMP NULL DEFAULT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`appointment_id`),
  KEY `fk_appointment_slot` (`slot_id`),
  KEY `fk_appointment_student` (`student_id`),
  CONSTRAINT `fk_appointment_slot` FOREIGN KEY (`slot_id`) REFERENCES `office_hour_slots` (`slot_id`),
  CONSTRAINT `fk_appointment_student` FOREIGN KEY (`student_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 7. Create Subscription tables (Phase 10)
-- ============================================================
CREATE TABLE IF NOT EXISTS `subscription_plans` (
  `plan_id` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `plan_name` VARCHAR(100) NOT NULL,
  `description` TEXT DEFAULT NULL,
  `price` DECIMAL(10,2) NOT NULL,
  `currency` VARCHAR(3) DEFAULT 'USD',
  `billing_cycle` ENUM('monthly','quarterly','yearly') DEFAULT 'monthly',
  `features` LONGTEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`features`)),
  `is_active` TINYINT(1) DEFAULT 1,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`plan_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `user_subscriptions` (
  `subscription_id` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT(20) UNSIGNED NOT NULL,
  `plan_id` BIGINT(20) UNSIGNED NOT NULL,
  `status` ENUM('active','cancelled','expired','suspended') DEFAULT 'active',
  `started_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `expires_at` TIMESTAMP NULL DEFAULT NULL,
  `cancelled_at` TIMESTAMP NULL DEFAULT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`subscription_id`),
  KEY `fk_subscription_user` (`user_id`),
  KEY `fk_subscription_plan` (`plan_id`),
  CONSTRAINT `fk_subscription_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
  CONSTRAINT `fk_subscription_plan` FOREIGN KEY (`plan_id`) REFERENCES `subscription_plans` (`plan_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
