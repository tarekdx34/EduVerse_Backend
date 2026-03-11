-- ============================================================================
-- Test Users for EduVerse Database
-- ============================================================================
-- This script creates test users with different roles for testing purposes
-- All users have the same password: Pass@123
-- 
-- Users created:
-- 1. amir_student@example.com (Student Role)
-- 2. amir_instructor@example.com (Instructor Role)
-- 3. amir_ta@example.com (Teaching Assistant Role)
-- 4. amir_admin@example.com (Admin Role)
-- 5. amir_itadmin@example.com (IT Admin Role)
-- ============================================================================

-- Note: The user_id values are chosen to avoid conflicts with existing users
-- Starting from 1001 to ensure no collision with existing data

-- ============================================================================
-- INSERT TEST USERS INTO USERS TABLE
-- ============================================================================

INSERT INTO `users` (
    `user_id`, 
    `email`, 
    `password_hash`, 
    `first_name`, 
    `last_name`, 
    `phone`, 
    `profile_picture_url`, 
    `bio`, 
    `social_links`, 
    `campus_id`, 
    `status`, 
    `email_verified`, 
    `last_login_at`, 
    `created_at`, 
    `updated_at`, 
    `deleted_at`
) VALUES
-- Student User
(1001, 'amir_student@example.com', '$2b$10$68IlYWY3NNQBE3zAPuXcLeaGMpP6eXgNYuFJ0YSFa0ykngV756k9e', 'Amir', 'Student', '+20-100-TEST-001', NULL, 'Test student account for development', NULL, 1, 'active', 1, NULL, NOW(), NOW(), NULL),

-- Instructor User
(1002, 'amir_instructor@example.com', '$2b$10$68IlYWY3NNQBE3zAPuXcLeaGMpP6eXgNYuFJ0YSFa0ykngV756k9e', 'Amir', 'Instructor', '+20-100-TEST-002', NULL, 'Test instructor account for development', NULL, 1, 'active', 1, NULL, NOW(), NOW(), NULL),

-- Teaching Assistant User
(1003, 'amir_ta@example.com', '$2b$10$68IlYWY3NNQBE3zAPuXcLeaGMpP6eXgNYuFJ0YSFa0ykngV756k9e', 'Amir', 'TA', '+20-100-TEST-003', NULL, 'Test teaching assistant account for development', NULL, 1, 'active', 1, NULL, NOW(), NOW(), NULL),

-- Admin User
(1004, 'amir_admin@example.com', '$2b$10$68IlYWY3NNQBE3zAPuXcLeaGMpP6eXgNYuFJ0YSFa0ykngV756k9e', 'Amir', 'Admin', '+20-100-TEST-004', NULL, 'Test admin account for development', NULL, 1, 'active', 1, NULL, NOW(), NOW(), NULL),

-- IT Admin User
(1005, 'amir_itadmin@example.com', '$2b$10$68IlYWY3NNQBE3zAPuXcLeaGMpP6eXgNYuFJ0YSFa0ykngV756k9e', 'Amir', 'ITAdmin', '+20-100-TEST-005', NULL, 'Test IT admin account for development', NULL, 1, 'active', 1, NULL, NOW(), NOW(), NULL);

-- ============================================================================
-- ASSIGN ROLES TO TEST USERS
-- ============================================================================

-- Role IDs Reference:
-- 1 = student
-- 2 = instructor
-- 3 = teaching_assistant
-- 4 = admin
-- 5 = department_head
-- 6 = it_admin

INSERT INTO `user_roles` (
    `user_role_id`, 
    `user_id`, 
    `role_id`, 
    `assigned_at`, 
    `assigned_by`
) VALUES
-- Assign Student Role (role_id = 1)
(1001, 1001, 1, NOW(), 1),

-- Assign Instructor Role (role_id = 2)
(1002, 1002, 2, NOW(), 1),

-- Assign Teaching Assistant Role (role_id = 3)
(1003, 1003, 3, NOW(), 1),

-- Assign Admin Role (role_id = 4)
(1004, 1004, 4, NOW(), 1),

-- Assign IT Admin Role (role_id = 6)
(1005, 1005, 6, NOW(), 1);

-- ============================================================================
-- VERIFICATION QUERIES (Optional - Run these to verify the insertions)
-- ============================================================================

-- Verify all test users were created
SELECT 
    u.user_id,
    u.email,
    u.first_name,
    u.last_name,
    r.role_name,
    u.status,
    u.email_verified
FROM users u
JOIN user_roles ur ON u.user_id = ur.user_id
JOIN roles r ON ur.role_id = r.role_id
WHERE u.email LIKE 'amir_%@example.com'
ORDER BY u.user_id;

-- ============================================================================
-- NOTES:
-- ============================================================================
-- 1. All passwords are hashed using bcrypt with 10 salt rounds
-- 2. Plain text password for all users: Pass@123
-- 3. All users are assigned to campus_id = 1
-- 4. All users are marked as 'active' and 'email_verified'
-- 5. User IDs start from 1001 to avoid conflicts
-- 6. Roles are assigned by user_id = 1 (admin)
-- 
-- To use these accounts:
-- - Login with email: amir_student@example.com, password: Pass@123
-- - Login with email: amir_instructor@example.com, password: Pass@123
-- - Login with email: amir_ta@example.com, password: Pass@123
-- - Login with email: amir_admin@example.com, password: Pass@123
-- - Login with email: amir_itadmin@example.com, password: Pass@123
-- ============================================================================
