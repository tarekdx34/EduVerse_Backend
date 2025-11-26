-- Migration: Add email_verifications table
-- Description: Creates table for storing email verification tokens with expiration

CREATE TABLE `email_verifications` (
  `verification_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `verification_token` varchar(255) NOT NULL,
  `expires_at` datetime NOT NULL,
  `used` tinyint(1) DEFAULT 0,
  `used_at` datetime NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_token` (`verification_token`),
  KEY `idx_used_expires` (`used`, `expires_at`),
  CONSTRAINT `fk_email_verifications_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Add index for faster lookups
CREATE UNIQUE INDEX `idx_user_unused_verification` ON `email_verifications` (`user_id`, `used`) WHERE `used` = 0;
