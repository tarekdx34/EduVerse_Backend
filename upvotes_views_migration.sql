-- Migration Script for Views and Upvotes

-- 1. Create table for Community Post Views (Unique per user)
CREATE TABLE IF NOT EXISTS `community_post_views` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `post_id` BIGINT UNSIGNED NOT NULL,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `viewed_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_unique_post_view` (`post_id`, `user_id`),
  CONSTRAINT `fk_cpv_post_id` FOREIGN KEY (`post_id`) REFERENCES `community_posts` (`post_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_cpv_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. Create table for Discussion Thread Views (Unique per user)
CREATE TABLE IF NOT EXISTS `course_chat_thread_views` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `thread_id` BIGINT UNSIGNED NOT NULL,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `viewed_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_unique_thread_view` (`thread_id`, `user_id`),
  CONSTRAINT `fk_cctv_thread_id` FOREIGN KEY (`thread_id`) REFERENCES `course_chat_threads` (`thread_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_cctv_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. Create table for Chat Message Upvotes (Replies)
CREATE TABLE IF NOT EXISTS `chat_message_upvotes` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `message_id` BIGINT UNSIGNED NOT NULL,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `created_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_unique_message_upvote` (`message_id`, `user_id`),
  CONSTRAINT `fk_cmu_message_id` FOREIGN KEY (`message_id`) REFERENCES `chat_messages` (`message_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_cmu_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- NOTE: `CommunityReaction` table already exists for community post upvotes. We will just add a new enum value 'upvote' to `reaction_type`.
ALTER TABLE `community_post_reactions` 
MODIFY COLUMN `reaction_type` ENUM('like', 'helpful', 'insightful', 'thanks', 'upvote') NOT NULL DEFAULT 'upvote';
