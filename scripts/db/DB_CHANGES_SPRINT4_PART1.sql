-- ==============================================================================
-- Sprint 4 Dev A: Database Changes (Phase 9.1 & 9.2)
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. ALTER existing `security_logs` table
-- ------------------------------------------------------------------------------
ALTER TABLE `security_logs`
MODIFY COLUMN `event_type` ENUM(
    'login', 'logout', 'failed_login', 'password_change', 'permission_change', 
    'suspicious_activity', 'login_success', 'login_failure', 'role_change', 
    'account_locked', 'ip_blocked', 'session_hijack', 'brute_force'
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
ADD COLUMN `location` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL AFTER `ip_address`,
ADD COLUMN `metadata` json DEFAULT NULL AFTER `details`;

-- ------------------------------------------------------------------------------
-- 2. CREATE `blocked_ips` table (Missing from DB)
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `blocked_ips` (
  `ip_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci NOT NULL,
  `reason` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `blocked_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `expires_at` timestamp NULL DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`ip_id`),
  UNIQUE KEY `idx_ip_address` (`ip_address`),
  KEY `idx_is_active` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------------------------
-- 3. ALTER `system_settings` table
-- ------------------------------------------------------------------------------
ALTER TABLE `system_settings`
ADD COLUMN `updated_by` bigint(20) unsigned DEFAULT NULL AFTER `is_public`,
ADD COLUMN `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP AFTER `updated_by`,
ADD CONSTRAINT `system_settings_ibfk_updated_by` FOREIGN KEY (`updated_by`) REFERENCES `users` (`user_id`) ON DELETE SET NULL;

-- ------------------------------------------------------------------------------
-- 4. ALTER `branding_settings` table
-- ------------------------------------------------------------------------------
ALTER TABLE `branding_settings`
ADD COLUMN `updated_by` bigint(20) unsigned DEFAULT NULL AFTER `email_footer_html`,
ADD CONSTRAINT `branding_settings_ibfk_updated_by` FOREIGN KEY (`updated_by`) REFERENCES `users` (`user_id`) ON DELETE SET NULL;

-- ------------------------------------------------------------------------------
-- 5. ALTER `api_integrations` table
-- ------------------------------------------------------------------------------
ALTER TABLE `api_integrations`
ADD COLUMN `api_secret_encrypted` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL AFTER `api_key_encrypted`,
ADD COLUMN `health_status` enum('healthy','degraded','down') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'healthy' AFTER `is_active`,
ADD COLUMN `created_by` bigint(20) unsigned DEFAULT NULL AFTER `last_sync_at`,
ADD COLUMN `updated_by` bigint(20) unsigned DEFAULT NULL AFTER `created_by`,
ADD CONSTRAINT `api_integrations_ibfk_created_by` FOREIGN KEY (`created_by`) REFERENCES `users` (`user_id`) ON DELETE SET NULL,
ADD CONSTRAINT `api_integrations_ibfk_updated_by` FOREIGN KEY (`updated_by`) REFERENCES `users` (`user_id`) ON DELETE SET NULL;

-- ------------------------------------------------------------------------------
-- 6. ALTER `api_rate_limits` table
-- ------------------------------------------------------------------------------
ALTER TABLE `api_rate_limits`
ADD COLUMN `window_seconds` int DEFAULT 60 AFTER `max_requests`;
