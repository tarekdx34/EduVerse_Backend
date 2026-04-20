-- ============================================
-- Student Progress Tracking Support
-- Date: 2026-04-20
-- Description: Track unique per-student material views per course
-- ============================================

CREATE TABLE IF NOT EXISTS `student_material_views` (
  `view_id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` bigint UNSIGNED NOT NULL,
  `course_id` bigint UNSIGNED NOT NULL,
  `material_id` bigint UNSIGNED NOT NULL,
  `views_count` int NOT NULL DEFAULT 1,
  `first_viewed_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `last_viewed_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`view_id`),
  UNIQUE KEY `UQ_student_material_views_user_material` (`user_id`, `material_id`),
  KEY `IDX_student_material_views_user_course` (`user_id`, `course_id`),
  KEY `IDX_student_material_views_material` (`material_id`),
  CONSTRAINT `FK_student_material_views_user`
    FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `FK_student_material_views_course`
    FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`) ON DELETE CASCADE,
  CONSTRAINT `FK_student_material_views_material`
    FOREIGN KEY (`material_id`) REFERENCES `course_materials` (`material_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
