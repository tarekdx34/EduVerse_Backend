-- ============================================
-- Campus Events System
-- Date: 2026-04-07
-- Description: University-wide and department-level event management
-- ============================================

-- Table: campus_events
-- Purpose: Store campus-wide and department-level events
DROP TABLE IF EXISTS `campus_event_registrations`;
DROP TABLE IF EXISTS `campus_events`;

CREATE TABLE `campus_events` (
  `event_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `description` text,
  `event_type` enum('university_wide', 'department', 'campus', 'program') NOT NULL DEFAULT 'university_wide',
  `scope_id` bigint UNSIGNED NULL COMMENT 'department_id, campus_id, or program_id based on event_type',
  `start_datetime` datetime NOT NULL,
  `end_datetime` datetime NOT NULL,
  `location` varchar(255) DEFAULT NULL,
  `building` varchar(100) DEFAULT NULL,
  `room` varchar(100) DEFAULT NULL,
  `organizer_id` bigint UNSIGNED NOT NULL COMMENT 'User who created the event',
  `is_mandatory` tinyint(1) NOT NULL DEFAULT 0,
  `registration_required` tinyint(1) NOT NULL DEFAULT 0,
  `max_attendees` int DEFAULT NULL,
  `color` varchar(7) DEFAULT '#10B981' COMMENT 'Hex color for calendar display',
  `status` enum('draft', 'published', 'cancelled', 'completed') NOT NULL DEFAULT 'draft',
  `tags` json DEFAULT NULL COMMENT 'Event tags/categories',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`event_id`),
  KEY `idx_event_type` (`event_type`),
  KEY `idx_scope` (`event_type`, `scope_id`),
  KEY `idx_datetime` (`start_datetime`, `end_datetime`),
  KEY `idx_status` (`status`),
  KEY `idx_organizer` (`organizer_id`),
  KEY `fk_campus_events_organizer` (`organizer_id`),
  CONSTRAINT `fk_campus_events_organizer` FOREIGN KEY (`organizer_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table: campus_event_registrations
-- Purpose: Track user registrations for events that require registration
CREATE TABLE `campus_event_registrations` (
  `registration_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `event_id` bigint UNSIGNED NOT NULL,
  `user_id` bigint UNSIGNED NOT NULL,
  `status` enum('registered', 'attended', 'cancelled', 'no_show') NOT NULL DEFAULT 'registered',
  `notes` text DEFAULT NULL COMMENT 'Optional registration notes',
  `registered_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`registration_id`),
  UNIQUE KEY `unique_registration` (`event_id`, `user_id`),
  KEY `idx_event` (`event_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_status` (`status`),
  CONSTRAINT `fk_event_reg_event` FOREIGN KEY (`event_id`) REFERENCES `campus_events` (`event_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_event_reg_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Sample data for testing
INSERT INTO `campus_events` 
  (`title`, `description`, `event_type`, `scope_id`, `start_datetime`, `end_datetime`, 
   `location`, `building`, `room`, `organizer_id`, `is_mandatory`, `registration_required`, 
   `max_attendees`, `color`, `status`)
VALUES
  ('Spring Fun Day', 'Annual spring celebration with activities, food, and entertainment for all students and faculty.', 
   'university_wide', NULL, '2026-04-20 10:00:00', '2026-04-20 17:00:00', 
   'Main Campus Grounds', 'Outdoor', NULL, 1, 0, 0, NULL, '#F59E0B', 'published'),
  
  ('CS Department Workshop: AI in Education', 'Workshop on integrating AI tools in teaching and learning.', 
   'department', 1, '2026-04-15 14:00:00', '2026-04-15 16:00:00', 
   'Department Auditorium', 'Engineering Building', 'Room 301', 1, 0, 1, 50, '#3B82F6', 'published'),
  
  ('Career Fair 2026', 'Annual career fair with 50+ companies recruiting students for internships and full-time positions.', 
   'university_wide', NULL, '2026-04-25 09:00:00', '2026-04-25 16:00:00', 
   'Sports Complex Hall', 'Sports Complex', NULL, 1, 0, 0, NULL, '#10B981', 'published'),
  
  ('Graduate Research Symposium', 'Showcase of graduate student research across all departments.', 
   'university_wide', NULL, '2026-04-30 09:00:00', '2026-04-30 17:00:00', 
   'Conference Center', 'Main Building', 'Hall A', 1, 0, 1, 200, '#8B5CF6', 'published');

-- Indexes for performance
CREATE INDEX idx_datetime_status ON campus_events(start_datetime, status);
CREATE INDEX idx_registration_status ON campus_event_registrations(event_id, status);

-- Comments
ALTER TABLE `campus_events` COMMENT = 'Campus-wide and department-level events like fun days, seminars, workshops';
ALTER TABLE `campus_event_registrations` COMMENT = 'User registrations for events requiring sign-up';
