-- ============================================================================
-- FEATURE:     Community System Restructure
-- DATE:        2025-07-15
-- DESCRIPTION: Retroactive documentation of all database changes made to
--              support the community system restructure. This includes:
--                - A new `communities` table for global and department-scoped communities
--                - Seeding of the default Global Community (community_id = 1)
--                - Extension of `community_posts` to link posts to communities
--                - Tag system tables (`community_tags`, `community_post_tags`)
--
-- DEPENDENCIES: Requires existing `departments`, `users`, and `community_posts` tables.
--
-- NOTES:
--   - community_id = 1 is the hardcoded Global Community used throughout the app.
--   - Existing posts (pre-restructure) were migrated to the Global Community.
--   - course_id on community_posts was made nullable so posts can belong to a
--     community without being tied to a specific course.
-- ============================================================================


-- ============================================================================
-- SECTION 1: Create `communities` table
-- ----------------------------------------------------------------------------
-- Central table for all communities. Each community is either 'global'
-- (platform-wide, department_id IS NULL) or 'department'-scoped (linked to a
-- specific department). Only one global community is expected (community_id=1).
-- ============================================================================

CREATE TABLE IF NOT EXISTS communities (
  community_id    INT AUTO_INCREMENT PRIMARY KEY,
  name            VARCHAR(255) NOT NULL,
  description     TEXT,
  community_type  ENUM('global', 'department') NOT NULL DEFAULT 'global',
  department_id   INT NULL,
  cover_image_url VARCHAR(500) NULL,
  is_active       BOOLEAN NOT NULL DEFAULT TRUE,
  created_by      INT NOT NULL,
  created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  FOREIGN KEY (department_id) REFERENCES departments(department_id) ON DELETE SET NULL,
  FOREIGN KEY (created_by)    REFERENCES users(user_id)             ON DELETE CASCADE,

  INDEX idx_community_type (community_type),
  INDEX idx_department_id  (department_id)
);


-- ============================================================================
-- SECTION 2: Seed the Global Community
-- ----------------------------------------------------------------------------
-- Insert a single platform-wide community that acts as the default community.
-- All users have access to this community regardless of department.
-- community_id = 1 is referenced as a constant in application code.
-- created_by = 1 assumes user_id 1 is the system/admin user.
-- ============================================================================

INSERT INTO communities (name, description, community_type, department_id, created_by)
VALUES ('Global Community', 'Platform-wide community for all users', 'global', NULL, 1);


-- ============================================================================
-- SECTION 3: Extend `community_posts` table
-- ----------------------------------------------------------------------------
-- Link every post to a community. Steps:
--   a) Add the community_id column (nullable initially for migration safety).
--   b) Add a foreign key constraint to the communities table.
--   c) Make course_id nullable — posts in a community don't require a course.
--   d) Migrate all existing posts to the Global Community (community_id = 1).
-- ============================================================================

-- 3a. Add community_id column
ALTER TABLE community_posts
  ADD COLUMN community_id INT NULL AFTER post_id;

-- 3b. Add foreign key constraint
ALTER TABLE community_posts
  ADD CONSTRAINT fk_post_community
  FOREIGN KEY (community_id) REFERENCES communities(community_id) ON DELETE CASCADE;

-- 3c. Allow posts without a course (community-only posts)
ALTER TABLE community_posts
  MODIFY COLUMN course_id INT NULL;

-- 3d. Migrate pre-existing posts into the Global Community
UPDATE community_posts
  SET community_id = 1
  WHERE community_id IS NULL;


-- ============================================================================
-- SECTION 4: Create `community_tags` table
-- ----------------------------------------------------------------------------
-- Stores unique tag names that can be attached to community posts.
-- Tags are shared across all communities (not scoped per-community).
-- ============================================================================

CREATE TABLE IF NOT EXISTS community_tags (
  tag_id     INT AUTO_INCREMENT PRIMARY KEY,
  name       VARCHAR(100) NOT NULL UNIQUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================================
-- SECTION 5: Create `community_post_tags` join table
-- ----------------------------------------------------------------------------
-- Many-to-many relationship between posts and tags.
-- Cascading deletes ensure cleanup when either a post or tag is removed.
-- ============================================================================

CREATE TABLE IF NOT EXISTS community_post_tags (
  post_id INT NOT NULL,
  tag_id  INT NOT NULL,

  PRIMARY KEY (post_id, tag_id),

  FOREIGN KEY (post_id) REFERENCES community_posts(post_id) ON DELETE CASCADE,
  FOREIGN KEY (tag_id)  REFERENCES community_tags(tag_id)   ON DELETE CASCADE
);


-- ============================================================================
-- VERIFICATION QUERIES
-- ----------------------------------------------------------------------------
-- Run these after applying the migration to confirm everything is in place.
-- ============================================================================

-- V1. Confirm `communities` table exists and has the expected columns
DESCRIBE communities;

-- V2. Confirm the Global Community was seeded
SELECT community_id, name, community_type, department_id
  FROM communities
  WHERE community_id = 1 AND community_type = 'global';

-- V3. Confirm `community_posts` now has the community_id column
SHOW COLUMNS FROM community_posts LIKE 'community_id';

-- V4. Confirm course_id is nullable
SHOW COLUMNS FROM community_posts LIKE 'course_id';

-- V5. Confirm no orphaned posts (all posts should belong to a community)
SELECT COUNT(*) AS orphaned_posts
  FROM community_posts
  WHERE community_id IS NULL;
-- Expected result: 0

-- V6. Confirm `community_tags` table exists
DESCRIBE community_tags;

-- V7. Confirm `community_post_tags` table exists with composite PK
DESCRIBE community_post_tags;

-- V8. Confirm foreign key constraints are in place
SELECT CONSTRAINT_NAME, TABLE_NAME, REFERENCED_TABLE_NAME
  FROM information_schema.KEY_COLUMN_USAGE
  WHERE TABLE_SCHEMA = DATABASE()
    AND REFERENCED_TABLE_NAME IN ('communities', 'community_posts', 'community_tags')
  ORDER BY TABLE_NAME, CONSTRAINT_NAME;


-- ============================================================================
-- ROLLBACK
-- ----------------------------------------------------------------------------
-- To undo ALL changes from this migration, run the statements below IN ORDER.
-- WARNING: This will permanently delete all community data, tags, and
--          post-community associations. Back up data before proceeding.
-- ============================================================================

-- R1. Drop the join table first (depends on both community_posts and community_tags)
-- DROP TABLE IF EXISTS community_post_tags;

-- R2. Drop the tags table
-- DROP TABLE IF EXISTS community_tags;

-- R3. Remove the community_id column and FK from community_posts
-- ALTER TABLE community_posts DROP FOREIGN KEY fk_post_community;
-- ALTER TABLE community_posts DROP COLUMN community_id;

-- R4. Restore course_id to NOT NULL (only if all rows have a course_id value)
-- ALTER TABLE community_posts MODIFY COLUMN course_id INT NOT NULL;

-- R5. Drop the communities table last (other FKs reference it)
-- DROP TABLE IF EXISTS communities;
