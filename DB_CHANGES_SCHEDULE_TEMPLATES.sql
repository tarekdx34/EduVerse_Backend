-- ============================================
-- Schedule Templates System
-- Date: 2026-04-07
-- Description: Reusable schedule templates for bulk assignment to course sections
-- ============================================

-- Table: schedule_templates
-- Purpose: Store reusable schedule patterns
DROP TABLE IF EXISTS `schedule_template_slots`;
DROP TABLE IF EXISTS `schedule_templates`;

CREATE TABLE `schedule_templates` (
  `template_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `description` text,
  `department_id` bigint UNSIGNED NULL COMMENT 'NULL = university-wide template',
  `schedule_type` enum('LECTURE', 'LAB', 'TUTORIAL', 'HYBRID') NOT NULL DEFAULT 'LECTURE',
  `created_by` bigint UNSIGNED NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`template_id`),
  KEY `idx_department` (`department_id`),
  KEY `idx_active` (`is_active`),
  KEY `idx_created_by` (`created_by`),
  KEY `idx_schedule_type` (`schedule_type`),
  CONSTRAINT `fk_template_department` FOREIGN KEY (`department_id`) REFERENCES `departments` (`department_id`) ON DELETE SET NULL,
  CONSTRAINT `fk_template_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table: schedule_template_slots
-- Purpose: Individual time slots within a template
CREATE TABLE `schedule_template_slots` (
  `slot_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `template_id` bigint UNSIGNED NOT NULL,
  `day_of_week` enum('MONDAY','TUESDAY','WEDNESDAY','THURSDAY','FRIDAY','SATURDAY','SUNDAY') NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  `slot_type` enum('LECTURE', 'LAB', 'TUTORIAL') NOT NULL,
  `duration_minutes` int NOT NULL COMMENT 'Calculated from start/end time',
  `building` varchar(100) DEFAULT NULL,
  `room` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`slot_id`),
  KEY `idx_template` (`template_id`),
  KEY `idx_day_time` (`day_of_week`, `start_time`),
  CONSTRAINT `fk_slot_template` FOREIGN KEY (`template_id`) REFERENCES `schedule_templates` (`template_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Sample data for testing
INSERT INTO `schedule_templates` 
  (`name`, `description`, `department_id`, `schedule_type`, `created_by`, `is_active`)
VALUES
  ('MW 2-Hour Lecture Pattern', 'Standard Monday-Wednesday 2-hour lecture schedule', 
   1, 'LECTURE', 1, 1),
  
  ('TTh 90-Min Lab Pattern', 'Tuesday-Thursday 90-minute lab schedule', 
   1, 'LAB', 1, 1),
  
  ('MWF 1-Hour Discussion', 'Monday-Wednesday-Friday 1-hour discussion/tutorial pattern', 
   NULL, 'TUTORIAL', 1, 1);

-- Sample slots for MW 2-Hour Lecture Pattern (template_id = 1)
INSERT INTO `schedule_template_slots`
  (`template_id`, `day_of_week`, `start_time`, `end_time`, `slot_type`, `duration_minutes`)
VALUES
  (1, 'MONDAY', '09:00:00', '11:00:00', 'LECTURE', 120),
  (1, 'WEDNESDAY', '09:00:00', '11:00:00', 'LECTURE', 120);

-- Sample slots for TTh Lab Pattern (template_id = 2)
INSERT INTO `schedule_template_slots`
  (`template_id`, `day_of_week`, `start_time`, `end_time`, `slot_type`, `duration_minutes`)
VALUES
  (2, 'TUESDAY', '14:00:00', '15:30:00', 'LAB', 90),
  (2, 'THURSDAY', '14:00:00', '15:30:00', 'LAB', 90);

-- Sample slots for MWF Discussion (template_id = 3)
INSERT INTO `schedule_template_slots`
  (`template_id`, `day_of_week`, `start_time`, `end_time`, `slot_type`, `duration_minutes`)
VALUES
  (3, 'MONDAY', '10:00:00', '11:00:00', 'TUTORIAL', 60),
  (3, 'WEDNESDAY', '10:00:00', '11:00:00', 'TUTORIAL', 60),
  (3, 'FRIDAY', '10:00:00', '11:00:00', 'TUTORIAL', 60);

-- Indexes for performance
CREATE INDEX idx_active_dept ON schedule_templates(is_active, department_id);
CREATE INDEX idx_template_type ON schedule_template_slots(template_id, slot_type);

-- Comments
ALTER TABLE `schedule_templates` COMMENT = 'Reusable schedule templates for bulk course scheduling';
ALTER TABLE `schedule_template_slots` COMMENT = 'Individual time slots within schedule templates';
