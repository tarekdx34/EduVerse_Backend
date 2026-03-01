-- ============================================================
-- COMPREHENSIVE EDUVERSE DATABASE TEST DATA
-- Generated with realistic, interconnected test data
-- ============================================================

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";
SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT;
SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS;
SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION;
SET NAMES utf8mb4;

-- ============================================================
-- PRIORITY 1: CORE DATA (Foundation)
-- ============================================================

-- ============================================================
-- TABLE: CAMPUSES
-- ============================================================
INSERT IGNORE INTO `campuses` (`campus_id`, `campus_name`, `campus_code`, `address`, `city`, `country`, `phone`, `email`, `timezone`, `status`, `created_at`, `updated_at`) VALUES
(1, 'Main Campus', 'MAIN', '123 University Avenue', 'Cairo', 'Egypt', '+20-100-123-4567', 'main@eduverse.edu.eg', 'Africa/Cairo', 'active', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(2, 'Downtown Campus', 'DT', '456 Business District', 'Giza', 'Egypt', '+20-100-234-5678', 'downtown@eduverse.edu.eg', 'Africa/Cairo', 'active', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(3, 'Online Campus', 'ONLINE', 'Virtual', 'Worldwide', 'Egypt', '+20-100-999-0000', 'online@eduverse.edu.eg', 'UTC', 'active', '2024-09-01 08:00:00', '2024-09-01 08:00:00');

-- ============================================================
-- TABLE: DEPARTMENTS
-- ============================================================
INSERT IGNORE INTO `departments` (`department_id`, `campus_id`, `department_name`, `department_code`, `head_of_department_id`, `description`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 'Computer Science', 'CS', NULL, 'Department focused on computing, algorithms, and software development', 'active', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(2, 1, 'Engineering', 'ENG', NULL, 'Department of mechanical, electrical, and civil engineering', 'active', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(3, 1, 'Business Administration', 'BUS', NULL, 'Department of business, management, and entrepreneurship', 'active', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(4, 2, 'Data Science', 'DS', NULL, 'Department focused on data analysis and machine learning', 'active', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(5, 2, 'Arts and Humanities', 'AH', NULL, 'Department of languages, literature, and history', 'active', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(6, 3, 'Science', 'SCI', NULL, 'Department of mathematics, physics, and chemistry', 'active', '2024-09-01 08:00:00', '2024-09-01 08:00:00');

-- ============================================================
-- TABLE: PROGRAMS
-- ============================================================
INSERT IGNORE INTO `programs` (`program_id`, `department_id`, `program_name`, `program_code`, `degree_type`, `duration_years`, `description`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 'BS Computer Science', 'BS-CS', 'bachelor', 4, 'Bachelor of Science in Computer Science', 'active', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(2, 1, 'MS Computer Science', 'MS-CS', 'master', 2, 'Master of Science in Computer Science', 'active', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(3, 2, 'BS Mechanical Engineering', 'BS-ME', 'bachelor', 4, 'Bachelor of Science in Mechanical Engineering', 'active', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(4, 2, 'MS Electrical Engineering', 'MS-EE', 'master', 2, 'Master of Science in Electrical Engineering', 'active', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(5, 3, 'BS Business Administration', 'BS-BUS', 'bachelor', 4, 'Bachelor of Science in Business Administration', 'active', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(6, 3, 'MBA', 'MBA', 'master', 2, 'Master of Business Administration', 'active', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(7, 4, 'BS Data Science', 'BS-DS', 'bachelor', 4, 'Bachelor of Science in Data Science', 'active', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(8, 4, 'Certificate Data Analytics', 'CERT-DA', 'certificate', 1, 'Certificate in Data Analytics', 'active', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(9, 5, 'BA English Literature', 'BA-ENG', 'bachelor', 4, 'Bachelor of Arts in English Literature', 'active', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(10, 5, 'BA Arabic Language', 'BA-AR', 'bachelor', 4, 'Bachelor of Arts in Arabic Language and Culture', 'active', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(11, 6, 'BS Mathematics', 'BS-MATH', 'bachelor', 4, 'Bachelor of Science in Mathematics', 'active', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(12, 6, 'BS Physics', 'BS-PHYS', 'bachelor', 4, 'Bachelor of Science in Physics', 'active', '2024-09-01 08:00:00', '2024-09-01 08:00:00');

-- ============================================================
-- TABLE: SEMESTERS
-- ============================================================
INSERT IGNORE INTO `semesters` (`semester_id`, `semester_name`, `semester_code`, `start_date`, `end_date`, `registration_start`, `registration_end`, `status`, `created_at`) VALUES
(1, 'Fall 2024', 'FALL2024', '2024-09-01', '2024-12-20', '2024-08-15', '2024-08-31', 'completed', '2024-08-01 00:00:00'),
(2, 'Spring 2025', 'SPR2025', '2025-01-15', '2025-05-30', '2024-12-15', '2025-01-10', 'active', '2024-12-01 00:00:00'),
(3, 'Summer 2025', 'SUM2025', '2025-06-01', '2025-08-15', '2025-05-15', '2025-05-31', 'upcoming', '2025-05-01 00:00:00'),
(4, 'Fall 2025', 'FALL2025', '2025-09-01', '2025-12-20', '2025-08-15', '2025-08-31', 'upcoming', '2025-08-01 00:00:00');

-- ============================================================
-- TABLE: USERS (50+ users with various roles)
-- ============================================================
-- Note: Using bcrypt hash of 'password123' for all test users
-- bcrypt hash: $2y$10$N9qo8uLOickgx2ZMRZoMye

-- ADMIN USERS (5)
INSERT IGNORE INTO `users` (`user_id`, `email`, `password_hash`, `first_name`, `last_name`, `phone`, `profile_picture_url`, `campus_id`, `status`, `email_verified`, `last_login_at`, `created_at`, `updated_at`) VALUES
(1, 'admin.ahmed@eduverse.edu.eg', '$2y$10$N9qo8uLOickgx2ZMRZoMye', 'Ahmed', 'Hassan', '+20-100-111-0001', NULL, 1, 'active', 1, '2025-02-15 09:00:00', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(2, 'admin.fatima@eduverse.edu.eg', '$2y$10$N9qo8uLOickgx2ZMRZoMye', 'Fatima', 'Khalil', '+20-100-111-0002', NULL, 1, 'active', 1, '2025-02-14 14:30:00', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(3, 'admin.karim@eduverse.edu.eg', '$2y$10$N9qo8uLOickgx2ZMRZoMye', 'Karim', 'Mohamed', '+20-100-111-0003', NULL, 2, 'active', 1, '2025-02-13 11:15:00', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(4, 'admin.leila@eduverse.edu.eg', '$2y$10$N9qo8uLOickgx2ZMRZoMye', 'Leila', 'Abdullah', '+20-100-111-0004', NULL, 2, 'active', 1, '2025-02-12 16:45:00', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(5, 'admin.samir@eduverse.edu.eg', '$2y$10$N9qo8uLOickgx2ZMRZoMye', 'Samir', 'Nour', '+20-100-111-0005', NULL, 3, 'active', 1, '2025-02-11 10:00:00', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),

-- IT_ADMIN USERS (2)
(6, 'itadmin.hani@eduverse.edu.eg', '$2y$10$N9qo8uLOickgx2ZMRZoMye', 'Hani', 'Samy', '+20-100-222-0001', NULL, 1, 'active', 1, '2025-02-15 08:30:00', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(7, 'itadmin.dina@eduverse.edu.eg', '$2y$10$N9qo8uLOickgx2ZMRZoMye', 'Dina', 'Aziz', '+20-100-222-0002', NULL, 2, 'active', 1, '2025-02-14 09:15:00', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),

-- INSTRUCTORS (10)
(8, 'dr.ibrahim.ali@eduverse.edu.eg', '$2y$10$N9qo8uLOickgx2ZMRZoMye', 'Ibrahim', 'Ali', '+20-100-333-0001', NULL, 1, 'active', 1, '2025-02-15 13:20:00', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(9, 'prof.amira.hussein@eduverse.edu.eg', '$2y$10$N9qo8uLOickgx2ZMRZoMye', 'Amira', 'Hussein', '+20-100-333-0002', NULL, 1, 'active', 1, '2025-02-15 10:45:00', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(10, 'dr.tamer.zahran@eduverse.edu.eg', '$2y$10$N9qo8uLOickgx2ZMRZoMye', 'Tamer', 'Zahran', '+20-100-333-0003', NULL, 1, 'active', 1, '2025-02-14 15:00:00', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(11, 'prof.noor.rashid@eduverse.edu.eg', '$2y$10$N9qo8uLOickgx2ZMRZoMye', 'Noor', 'Rashid', '+20-100-333-0004', NULL, 2, 'active', 1, '2025-02-13 12:30:00', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(12, 'dr.youssef.shaker@eduverse.edu.eg', '$2y$10$N9qo8uLOickgx2ZMRZoMye', 'Youssef', 'Shaker', '+20-100-333-0005', NULL, 2, 'active', 1, '2025-02-12 14:00:00', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(13, 'prof.huda.amin@eduverse.edu.eg', '$2y$10$N9qo8uLOickgx2ZMRZoMye', 'Huda', 'Amin', '+20-100-333-0006', NULL, 1, 'active', 1, '2025-02-15 11:20:00', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(14, 'dr.adel.fathy@eduverse.edu.eg', '$2y$10$N9qo8uLOickgx2ZMRZoMye', 'Adel', 'Fathy', '+20-100-333-0007', NULL, 2, 'active', 1, '2025-02-14 09:50:00', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(15, 'prof.rania.ahmed@eduverse.edu.eg', '$2y$10$N9qo8uLOickgx2ZMRZoMye', 'Rania', 'Ahmed', '+20-100-333-0008', NULL, 1, 'active', 1, '2025-02-13 16:15:00', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(16, 'dr.moustafa.ali@eduverse.edu.eg', '$2y$10$N9qo8uLOickgx2ZMRZoMye', 'Moustafa', 'Ali', '+20-100-333-0009', NULL, 2, 'active', 1, '2025-02-12 13:45:00', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(17, 'prof.yasmine.salem@eduverse.edu.eg', '$2y$10$N9qo8uLOickgx2ZMRZoMye', 'Yasmine', 'Salem', '+20-100-333-0010', NULL, 3, 'active', 1, '2025-02-11 14:30:00', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),

-- TAs (3)
(18, 'ta.omar.hassan@eduverse.edu.eg', '$2y$10$N9qo8uLOickgx2ZMRZoMye', 'Omar', 'Hassan', '+20-100-444-0001', NULL, 1, 'active', 1, '2025-02-15 14:00:00', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(19, 'ta.layla.karim@eduverse.edu.eg', '$2y$10$N9qo8uLOickgx2ZMRZoMye', 'Layla', 'Karim', '+20-100-444-0002', NULL, 1, 'active', 1, '2025-02-14 10:30:00', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(20, 'ta.salim.noor@eduverse.edu.eg', '$2y$10$N9qo8uLOickgx2ZMRZoMye', 'Salim', 'Noor', '+20-100-444-0003', NULL, 2, 'active', 1, '2025-02-13 15:20:00', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),

-- STUDENTS (30)
(21, 'student.ali.youssef@eduverse.edu.eg', '$2y$10$N9qo8uLOickgx2ZMRZoMye', 'Ali', 'Youssef', '+20-100-555-0001', NULL, 1, 'active', 1, '2025-02-15 17:45:00', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(22, 'student.maya.ibrahim@eduverse.edu.eg', '$2y$10$N9qo8uLOickgx2ZMRZoMye', 'Maya', 'Ibrahim', '+20-100-555-0002', NULL, 1, 'active', 1, '2025-02-15 16:30:00', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(23, 'student.zain.ahmed@eduverse.edu.eg', '$2y$10$N9qo8uLOickgx2ZMRZoMye', 'Zain', 'Ahmed', '+20-100-555-0003', NULL, 1, 'active', 1, '2025-02-15 18:00:00', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(24, 'student.hana.khalil@eduverse.edu.eg', '$2y$10$N9qo8uLOickgx2ZMRZoMye', 'Hana', 'Khalil', '+20-100-555-0004', NULL, 1, 'active', 1, '2025-02-14 17:15:00', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(25, 'student.hassan.samir@eduverse.edu.eg', '$2y$10$N9qo8uLOickgx2ZMRZoMye', 'Hassan', 'Samir', '+20-100-555-0005', NULL, 1, 'active', 1, '2025-02-14 16:45:00', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(26, 'student.mariam.fahmy@eduverse.edu.eg', '$2y$10$N9qo8uLOickgx2ZMRZoMye', 'Mariam', 'Fahmy', '+20-100-555-0006', NULL, 1, 'active', 1, '2025-02-13 18:20:00', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(27, 'student.rashid.nour@eduverse.edu.eg', '$2y$10$N9qo8uLOickgx2ZMRZoMye', 'Rashid', 'Nour', '+20-100-555-0007', NULL, 1, 'active', 1, '2025-02-13 17:00:00', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(28, 'student.sara.aziz@eduverse.edu.eg', '$2y$10$N9qo8uLOickgx2ZMRZoMye', 'Sara', 'Aziz', '+20-100-555-0008', NULL, 2, 'active', 1, '2025-02-15 15:30:00', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(29, 'student.karim.fathi@eduverse.edu.eg', '$2y$10$N9qo8uLOickgx2ZMRZoMye', 'Karim', 'Fathi', '+20-100-555-0009', NULL, 2, 'active', 1, '2025-02-15 14:45:00', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(30, 'student.noura.salem@eduverse.edu.eg', '$2y$10$N9qo8uLOickgx2ZMRZoMye', 'Noura', 'Salem', '+20-100-555-0010', NULL, 2, 'active', 1, '2025-02-14 15:15:00', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(31, 'student.amr.shaker@eduverse.edu.eg', '$2y$10$N9qo8uLOickgx2ZMRZoMye', 'Amr', 'Shaker', '+20-100-555-0011', NULL, 2, 'active', 1, '2025-02-13 16:30:00', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(32, 'student.dalal.hassan@eduverse.edu.eg', '$2y$10$N9qo8uLOickgx2ZMRZoMye', 'Dalal', 'Hassan', '+20-100-555-0012', NULL, 1, 'active', 1, '2025-02-12 17:45:00', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(33, 'student.nabil.hussein@eduverse.edu.eg', '$2y$10$N9qo8uLOickgx2ZMRZoMye', 'Nabil', 'Hussein', '+20-100-555-0013', NULL, 1, 'active', 1, '2025-02-12 16:20:00', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(34, 'student.sherine.ibrahim@eduverse.edu.eg', '$2y$10$N9qo8uLOickgx2ZMRZoMye', 'Sherine', 'Ibrahim', '+20-100-555-0014', NULL, 1, 'active', 1, '2025-02-11 17:30:00', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(35, 'student.khaled.ahmed@eduverse.edu.eg', '$2y$10$N9qo8uLOickgx2ZMRZoMye', 'Khaled', 'Ahmed', '+20-100-555-0015', NULL, 2, 'active', 1, '2025-02-11 16:00:00', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(36, 'student.amina.karim@eduverse.edu.eg', '$2y$10$N9qo8uLOickgx2ZMRZoMye', 'Amina', 'Karim', '+20-100-555-0016', NULL, 2, 'active', 1, '2025-02-10 18:15:00', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(37, 'student.fouad.ali@eduverse.edu.eg', '$2y$10$N9qo8uLOickgx2ZMRZoMye', 'Fouad', 'Ali', '+20-100-555-0017', NULL, 3, 'active', 1, '2025-02-15 19:00:00', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(38, 'student.lina.noor@eduverse.edu.eg', '$2y$10$N9qo8uLOickgx2ZMRZoMye', 'Lina', 'Noor', '+20-100-555-0018', NULL, 3, 'active', 1, '2025-02-14 18:45:00', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(39, 'student.sami.aziz@eduverse.edu.eg', '$2y$10$N9qo8uLOickgx2ZMRZoMye', 'Sami', 'Aziz', '+20-100-555-0019', NULL, 3, 'active', 1, '2025-02-13 19:20:00', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(40, 'student.joud.mohammad@eduverse.edu.eg', '$2y$10$N9qo8uLOickgx2ZMRZoMye', 'Joud', 'Mohammad', '+20-100-555-0020', NULL, 1, 'active', 1, '2025-02-12 18:30:00', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(41, 'student.rayan.saleh@eduverse.edu.eg', '$2y$10$N9qo8uLOickgx2ZMRZoMye', 'Rayan', 'Saleh', '+20-100-555-0021', NULL, 1, 'active', 1, '2025-02-11 19:00:00', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(42, 'student.ghada.hussein@eduverse.edu.eg', '$2y$10$N9qo8uLOickgx2ZMRZoMye', 'Ghada', 'Hussein', '+20-100-555-0022', NULL, 2, 'active', 1, '2025-02-10 17:45:00', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(43, 'student.tariq.samir@eduverse.edu.eg', '$2y$10$N9qo8uLOickgx2ZMRZoMye', 'Tariq', 'Samir', '+20-100-555-0023', NULL, 2, 'active', 1, '2025-02-09 18:00:00', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(44, 'student.souad.noor@eduverse.edu.eg', '$2y$10$N9qo8uLOickgx2ZMRZoMye', 'Souad', 'Noor', '+20-100-555-0024', NULL, 2, 'active', 1, '2025-02-08 17:15:00', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(45, 'student.walid.ahmed@eduverse.edu.eg', '$2y$10$N9qo8uLOickgx2ZMRZoMye', 'Walid', 'Ahmed', '+20-100-555-0025', NULL, 1, 'active', 1, '2025-02-07 19:30:00', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(46, 'student.yasmine.khalil@eduverse.edu.eg', '$2y$10$N9qo8uLOickgx2ZMRZoMye', 'Yasmine', 'Khalil', '+20-100-555-0026', NULL, 1, 'active', 1, '2025-02-06 16:45:00', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(47, 'student.ismail.ahmed@eduverse.edu.eg', '$2y$10$N9qo8uLOickgx2ZMRZoMye', 'Ismail', 'Ahmed', '+20-100-555-0027', NULL, 3, 'active', 1, '2025-02-15 20:00:00', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(48, 'student.zainab.saleh@eduverse.edu.eg', '$2y$10$N9qo8uLOickgx2ZMRZoMye', 'Zainab', 'Saleh', '+20-100-555-0028', NULL, 3, 'active', 1, '2025-02-14 19:15:00', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(49, 'student.jamal.abdel@eduverse.edu.eg', '$2y$10$N9qo8uLOickgx2ZMRZoMye', 'Jamal', 'Abdel', '+20-100-555-0029', NULL, 3, 'active', 1, '2025-02-13 18:45:00', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(50, 'student.haya.ibrahim@eduverse.edu.eg', '$2y$10$N9qo8uLOickgx2ZMRZoMye', 'Haya', 'Ibrahim', '+20-100-555-0030', NULL, 1, 'active', 1, '2025-02-12 19:00:00', '2024-09-01 08:00:00', '2024-09-01 08:00:00');

-- ============================================================
-- PRIORITY 2: ACADEMIC STRUCTURE
-- ============================================================

-- ============================================================
-- TABLE: COURSES
-- ============================================================
INSERT IGNORE INTO `courses` (`course_id`, `department_id`, `course_name`, `course_code`, `course_description`, `credits`, `level`, `syllabus_url`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 'Introduction to Computer Science', 'CS101', 'Fundamentals of programming, algorithms, and computational thinking', 3, 'freshman', '/uploads/syllabi/CS101.pdf', 'active', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(2, 1, 'Data Structures', 'CS201', 'Arrays, linked lists, stacks, queues, trees, graphs and their applications', 4, 'sophomore', '/uploads/syllabi/CS201.pdf', 'active', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(3, 1, 'Object-Oriented Programming', 'CS202', 'OOP principles, design patterns, and advanced Java programming', 4, 'sophomore', '/uploads/syllabi/CS202.pdf', 'active', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(4, 1, 'Database Systems', 'CS301', 'Relational databases, SQL, normalization, transaction management', 3, 'junior', '/uploads/syllabi/CS301.pdf', 'active', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(5, 1, 'Web Development', 'CS302', 'Frontend and backend web development using modern frameworks', 3, 'junior', '/uploads/syllabi/CS302.pdf', 'active', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(6, 2, 'Engineering Mathematics I', 'ENG101', 'Calculus and linear algebra for engineers', 4, 'freshman', '/uploads/syllabi/ENG101.pdf', 'active', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(7, 2, 'Circuit Analysis', 'ENG201', 'AC and DC circuit theory, Kirchhoff laws, network analysis', 4, 'sophomore', '/uploads/syllabi/ENG201.pdf', 'active', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(8, 2, 'Thermodynamics', 'ENG202', 'Principles of thermodynamics and heat transfer', 3, 'sophomore', '/uploads/syllabi/ENG202.pdf', 'active', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(9, 3, 'Principles of Management', 'BUS101', 'Fundamentals of business management and organizational behavior', 3, 'freshman', '/uploads/syllabi/BUS101.pdf', 'active', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(10, 3, 'Business Finance', 'BUS202', 'Financial analysis, investment decisions, and capital budgeting', 3, 'sophomore', '/uploads/syllabi/BUS202.pdf', 'active', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(11, 4, 'Statistics for Data Science', 'DS101', 'Probability, hypothesis testing, statistical inference', 3, 'freshman', '/uploads/syllabi/DS101.pdf', 'active', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(12, 4, 'Machine Learning Basics', 'DS201', 'Supervised and unsupervised learning algorithms', 4, 'sophomore', '/uploads/syllabi/DS201.pdf', 'active', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(13, 5, 'English Literature I', 'AH101', 'Classic works of English literature from Renaissance to 19th century', 3, 'freshman', '/uploads/syllabi/AH101.pdf', 'active', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(14, 5, 'Arabic Language Skills', 'AH102', 'Advanced Arabic grammar, writing, and communication', 3, 'freshman', '/uploads/syllabi/AH102.pdf', 'active', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(15, 6, 'Calculus I', 'SCI101', 'Differential and integral calculus', 4, 'freshman', '/uploads/syllabi/SCI101.pdf', 'active', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(16, 6, 'General Physics I', 'SCI102', 'Mechanics, waves, and thermodynamics', 4, 'freshman', '/uploads/syllabi/SCI102.pdf', 'active', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(17, 1, 'Algorithms and Complexity', 'CS401', 'Algorithm design, analysis, and complexity theory', 4, 'senior', '/uploads/syllabi/CS401.pdf', 'active', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(18, 3, 'Strategic Management', 'BUS401', 'Corporate strategy and competitive analysis', 3, 'senior', '/uploads/syllabi/BUS401.pdf', 'active', '2024-09-01 08:00:00', '2024-09-01 08:00:00');

-- ============================================================
-- TABLE: COURSE_SECTIONS
-- ============================================================
INSERT IGNORE INTO `course_sections` (`section_id`, `course_id`, `semester_id`, `section_number`, `max_capacity`, `current_enrollment`, `location`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 2, '01', 50, 45, 'Room 101A', 'open', '2024-12-15 10:00:00', '2025-02-15 09:30:00'),
(2, 1, 2, '02', 50, 48, 'Room 102B', 'full', '2024-12-15 10:00:00', '2025-02-15 09:30:00'),
(3, 2, 2, '01', 40, 35, 'Room 201A', 'open', '2024-12-15 10:00:00', '2025-02-15 09:30:00'),
(4, 2, 2, '02', 40, 38, 'Room 202B', 'open', '2024-12-15 10:00:00', '2025-02-15 09:30:00'),
(5, 3, 2, '01', 45, 40, 'Lab 301', 'open', '2024-12-15 10:00:00', '2025-02-15 09:30:00'),
(6, 4, 2, '01', 35, 32, 'Room 401A', 'open', '2024-12-15 10:00:00', '2025-02-15 09:30:00'),
(7, 5, 2, '01', 40, 38, 'Room 501A', 'open', '2024-12-15 10:00:00', '2025-02-15 09:30:00'),
(8, 9, 2, '01', 50, 45, 'Room 601A', 'open', '2024-12-15 10:00:00', '2025-02-15 09:30:00'),
(9, 11, 2, '01', 45, 42, 'Room 701A', 'open', '2024-12-15 10:00:00', '2025-02-15 09:30:00'),
(10, 13, 2, '01', 35, 28, 'Room 801A', 'open', '2024-12-15 10:00:00', '2025-02-15 09:30:00');

-- ============================================================
-- TABLE: COURSE_SCHEDULES
-- ============================================================
INSERT IGNORE INTO `course_schedules` (`schedule_id`, `section_id`, `day_of_week`, `start_time`, `end_time`, `building`, `room`, `schedule_type`, `created_at`) VALUES
(1, 1, 'Monday', '09:00:00', '10:30:00', 'Building A', '101', 'lecture', '2024-12-15 10:00:00'),
(2, 1, 'Wednesday', '09:00:00', '10:30:00', 'Building A', '101', 'lecture', '2024-12-15 10:00:00'),
(3, 2, 'Tuesday', '11:00:00', '12:30:00', 'Building A', '102', 'lecture', '2024-12-15 10:00:00'),
(4, 2, 'Thursday', '11:00:00', '12:30:00', 'Building A', '102', 'lecture', '2024-12-15 10:00:00'),
(5, 3, 'Monday', '13:00:00', '14:30:00', 'Building B', '201', 'lab', '2024-12-15 10:00:00'),
(6, 3, 'Wednesday', '13:00:00', '14:30:00', 'Building B', '201', 'lab', '2024-12-15 10:00:00'),
(7, 4, 'Tuesday', '14:00:00', '15:30:00', 'Building B', '202', 'tutorial', '2024-12-15 10:00:00'),
(8, 4, 'Thursday', '14:00:00', '15:30:00', 'Building B', '202', 'tutorial', '2024-12-15 10:00:00'),
(9, 5, 'Monday', '15:00:00', '16:30:00', 'Lab Building', '301', 'exam', '2024-12-15 10:00:00'),
(10, 5, 'Wednesday', '15:00:00', '16:30:00', 'Lab Building', '301', 'exam', '2024-12-15 10:00:00');

-- ============================================================
-- TABLE: COURSE_PREREQUISITES
-- ============================================================
INSERT IGNORE INTO `course_prerequisites` (`prerequisite_id`, `course_id`, `prerequisite_course_id`, `created_at`) VALUES
(1, 2, 1, '2024-09-01 08:00:00'),
(2, 3, 1, '2024-09-01 08:00:00'),
(3, 4, 2, '2024-09-01 08:00:00'),
(4, 5, 3, '2024-09-01 08:00:00'),
(5, 17, 2, '2024-09-01 08:00:00'),
(6, 7, 6, '2024-09-01 08:00:00'),
(7, 12, 11, '2024-09-01 08:00:00');

-- ============================================================
-- PRIORITY 3: ENROLLMENTS & ASSIGNMENTS
-- ============================================================

-- ============================================================
-- TABLE: COURSE_ENROLLMENTS (30-50 enrollments)
-- ============================================================
INSERT IGNORE INTO `course_enrollments` (`user_id`, `section_id`, `program_id`, `enrollment_status`) VALUES
(21, 1, 1, 'enrolled'),
(22, 1, 1, 'enrolled'),
(23, 1, 1, 'enrolled'),
(24, 1, 1, 'enrolled'),
(25, 1, 1, 'enrolled'),
(26, 1, 1, 'enrolled'),
(27, 1, 1, 'enrolled'),
(28, 1, 1, 'enrolled'),
(29, 1, 1, 'enrolled'),
(30, 1, 1, 'enrolled'),
(31, 2, 1, 'enrolled'),
(32, 2, 1, 'enrolled'),
(33, 2, 1, 'enrolled'),
(34, 2, 1, 'enrolled'),
(35, 2, 1, 'enrolled'),
(36, 2, 1, 'enrolled'),
(37, 2, 1, 'enrolled'),
(38, 2, 1, 'enrolled'),
(39, 2, 1, 'enrolled'),
(40, 2, 1, 'enrolled'),
(21, 3, 1, 'enrolled'),
(23, 3, 1, 'enrolled'),
(25, 3, 1, 'enrolled'),
(27, 3, 1, 'enrolled'),
(29, 3, 1, 'enrolled'),
(32, 3, 1, 'enrolled'),
(34, 3, 1, 'enrolled'),
(36, 3, 1, 'enrolled'),
(38, 3, 1, 'enrolled'),
(40, 3, 1, 'enrolled'),
(22, 4, 1, 'enrolled'),
(24, 4, 1, 'enrolled'),
(26, 4, 1, 'enrolled'),
(28, 4, 1, 'enrolled'),
(30, 4, 1, 'enrolled'),
(31, 4, 1, 'enrolled'),
(33, 4, 1, 'enrolled'),
(35, 4, 1, 'enrolled'),
(37, 4, 1, 'enrolled'),
(39, 4, 1, 'enrolled'),
(21, 5, 1, 'enrolled'),
(23, 5, 1, 'enrolled'),
(25, 5, 1, 'enrolled'),
(27, 5, 1, 'enrolled'),
(29, 5, 1, 'enrolled'),
(32, 5, 1, 'enrolled'),
(34, 5, 1, 'enrolled'),
(36, 5, 1, 'enrolled');

-- ============================================================
-- TABLE: COURSE_INSTRUCTORS
-- ============================================================
INSERT IGNORE INTO `course_instructors` (`assignment_id`, `user_id`, `section_id`, `role`, `assigned_at`) VALUES
(1, 8, 1, 'primary', '2024-12-15 10:00:00'),
(2, 9, 2, 'primary', '2024-12-15 10:00:00'),
(3, 10, 3, 'primary', '2024-12-15 10:00:00'),
(4, 13, 4, 'primary', '2024-12-15 10:00:00'),
(5, 12, 5, 'primary', '2024-12-15 10:00:00'),
(6, 14, 6, 'primary', '2024-12-15 10:00:00'),
(7, 15, 7, 'primary', '2024-12-15 10:00:00'),
(8, 11, 8, 'primary', '2024-12-15 10:00:00'),
(9, 16, 9, 'primary', '2024-12-15 10:00:00'),
(10, 17, 10, 'primary', '2024-12-15 10:00:00');

-- ============================================================
-- TABLE: COURSE_TAS
-- ============================================================
INSERT IGNORE INTO `course_tas` (`assignment_id`, `user_id`, `section_id`, `responsibilities`, `assigned_at`) VALUES
(1, 18, 1, 'Grading assignments and leading lab sessions', '2024-12-15 10:00:00'),
(2, 19, 2, 'Grading assignments and holding office hours', '2024-12-15 10:00:00'),
(3, 18, 3, 'Grading assignments and leading lab sessions', '2024-12-15 10:00:00'),
(4, 20, 4, 'Grading assignments and proctoring quizzes', '2024-12-15 10:00:00'),
(5, 19, 5, 'Grading assignments and holding office hours', '2024-12-15 10:00:00');

-- ============================================================
-- TABLE: ASSIGNMENTS
-- ============================================================
INSERT IGNORE INTO `assignments` (`assignment_id`, `course_id`, `title`, `description`, `instructions`, `submission_type`, `max_score`, `due_date`, `available_from`, `late_submission_allowed`, `created_by`, `created_at`, `updated_at`) VALUES
(1, 1, 'Assignment 1: Programming Basics', 'Write a program that demonstrates basic programming concepts', 'Create a complete program with proper comments and documentation', 'file', 100.00, '2025-02-01 23:59:59', '2025-01-20 08:00:00', 1, 8, '2025-01-20 08:00:00', '2025-01-20 08:00:00'),
(2, 1, 'Assignment 2: Functions and Modules', 'Implement functions and modules for a simple application', 'Submit your code with test cases', 'file', 100.00, '2025-02-15 23:59:59', '2025-01-27 08:00:00', 1, 8, '2025-01-27 08:00:00', '2025-01-27 08:00:00'),
(3, 2, 'Assignment 1: Programming Basics', 'Write a program that demonstrates basic programming concepts', 'Create a complete program with proper comments and documentation', 'file', 100.00, '2025-02-02 23:59:59', '2025-01-20 08:00:00', 1, 9, '2025-01-20 08:00:00', '2025-01-20 08:00:00'),
(4, 3, 'Assignment 1: Data Structures Implementation', 'Implement and test various data structures', 'Implement at least 3 data structures', 'file', 150.00, '2025-02-20 23:59:59', '2025-01-22 08:00:00', 1, 10, '2025-01-22 08:00:00', '2025-01-22 08:00:00'),
(5, 3, 'Midterm Quiz', 'Comprehensive quiz covering weeks 1-6', 'Answer all questions to the best of your ability', 'text', 50.00, '2025-03-01 23:59:59', '2025-02-01 08:00:00', 0, 10, '2025-02-01 08:00:00', '2025-02-01 08:00:00'),
(6, 5, 'Lab Assignment 1: OOP Design', 'Design and implement OOP concepts in a project', 'Implement the provided specification', 'file', 120.00, '2025-02-10 23:59:59', '2025-01-25 08:00:00', 1, 12, '2025-01-25 08:00:00', '2025-01-25 08:00:00'),
(7, 6, 'Assignment 1: SQL Queries', 'Write SQL queries to retrieve and manipulate data', 'Write queries following best practices', 'file', 100.00, '2025-02-05 23:59:59', '2025-01-28 08:00:00', 1, 14, '2025-01-28 08:00:00', '2025-01-28 08:00:00'),
(8, 7, 'Project: Web Application', 'Build a complete web application using modern frameworks', 'Follow the project specification document', 'file', 200.00, '2025-03-15 23:59:59', '2025-02-01 08:00:00', 1, 15, '2025-02-01 08:00:00', '2025-02-01 08:00:00'),
(9, 9, 'Problem Set 1: Statistical Analysis', 'Solve statistical problems using real datasets', 'Show all work and calculations', 'file', 100.00, '2025-02-08 23:59:59', '2025-01-30 08:00:00', 1, 16, '2025-01-30 08:00:00', '2025-01-30 08:00:00'),
(10, 10, 'Essay: Literary Analysis', 'Write a comprehensive literary analysis essay', 'Submit as PDF with proper formatting', 'file', 100.00, '2025-02-12 23:59:59', '2025-01-31 08:00:00', 1, 17, '2025-01-31 08:00:00', '2025-01-31 08:00:00');

-- ============================================================
-- TABLE: ASSIGNMENT_SUBMISSIONS
-- ============================================================
INSERT IGNORE INTO `assignment_submissions` (`assignment_id`, `user_id`, `submission_text`, `submitted_at`, `status`) VALUES
(1, 21, 'Submitted assignment 1 - programming basics', '2025-01-31 15:30:00', 'graded'),
(1, 22, 'Submitted assignment 1 - programming basics', '2025-01-31 16:00:00', 'graded'),
(1, 23, 'Submitted assignment 1 - programming basics', '2025-01-29 12:00:00', 'graded'),
(1, 24, 'Submitted assignment 1 - programming basics', '2025-02-01 23:50:00', 'graded'),
(1, 25, 'Submitted assignment 1 - programming basics', '2025-01-30 18:00:00', 'graded'),
(2, 23, 'Submitted assignment 2 - functions and modules', '2025-02-14 10:30:00', 'submitted'),
(2, 25, 'Submitted assignment 2 - functions and modules', '2025-02-13 14:00:00', 'submitted'),
(4, 21, 'Submitted project 1 - data structures implementation', '2025-02-18 17:00:00', 'submitted'),
(4, 23, 'Submitted project 1 - data structures implementation', '2025-02-19 12:00:00', 'submitted'),
(4, 25, 'Submitted project 1 - data structures implementation', '2025-02-17 09:00:00', 'submitted');

-- ============================================================
-- PRIORITY 4: ACADEMIC ACTIVITIES
-- ============================================================

-- ============================================================
-- TABLE: QUIZZES
-- ============================================================
INSERT IGNORE INTO `quizzes` (`quiz_id`, `course_id`, `title`, `description`, `instructions`, `quiz_type`, `time_limit_minutes`, `max_attempts`, `passing_score`, `randomize_questions`, `show_correct_answers`, `weight`, `created_by`, `created_at`, `updated_at`) VALUES
(1, 1, 'Quiz 1: Introduction Concepts', 'Quick assessment of fundamental programming concepts', 'Answer all questions', 'graded', 15, 1, 12.00, 1, 1, 10.00, 8, '2025-01-25 08:00:00', '2025-01-25 08:00:00'),
(2, 1, 'Quiz 2: Control Flow', 'Test knowledge of conditionals and loops', 'Answer all questions', 'graded', 20, 1, 12.00, 1, 1, 10.00, 8, '2025-02-01 08:00:00', '2025-02-01 08:00:00'),
(3, 2, 'Quiz 1: Introduction Concepts', 'Quick assessment of fundamental programming concepts', 'Answer all questions', 'graded', 15, 1, 12.00, 1, 1, 10.00, 9, '2025-01-26 08:00:00', '2025-01-26 08:00:00'),
(4, 3, 'Quiz 1: Array and Linked Lists', 'Assessment of array and linked list concepts', 'Answer all questions', 'graded', 20, 1, 15.00, 1, 0, 10.00, 10, '2025-02-03 08:00:00', '2025-02-03 08:00:00'),
(5, 5, 'Quiz 1: OOP Principles', 'Test understanding of object-oriented programming', 'Answer all questions', 'graded', 25, 1, 12.00, 1, 1, 10.00, 12, '2025-02-05 08:00:00', '2025-02-05 08:00:00'),
(6, 9, 'Quiz 1: Statistical Concepts', 'Assessment of probability and statistics fundamentals', 'Answer all questions', 'graded', 30, 1, 12.00, 0, 1, 10.00, 16, '2025-02-07 08:00:00', '2025-02-07 08:00:00');

-- ============================================================
-- TABLE: QUIZ_QUESTIONS
-- ============================================================
INSERT IGNORE INTO `quiz_questions` (`question_id`, `quiz_id`, `question_text`, `question_type`, `points`, `order_index`, `created_at`) VALUES
(1, 1, 'What is a variable in programming?', 'multiple_choice', 4, 1, '2025-01-25 08:00:00'),
(2, 1, 'Which of the following is not a data type?', 'multiple_choice', 4, 2, '2025-01-25 08:00:00'),
(3, 1, 'What does IDE stand for?', 'multiple_choice', 4, 3, '2025-01-25 08:00:00'),
(4, 1, 'True or False: Comments improve code readability.', 'true_false', 4, 4, '2025-01-25 08:00:00'),
(5, 1, 'Explain what polymorphism means in programming.', 'short_answer', 4, 5, '2025-01-25 08:00:00'),
(6, 2, 'What is the output of the loop: for(int i=0; i<3; i++)?', 'multiple_choice', 4, 1, '2025-02-01 08:00:00'),
(7, 2, 'Which statement is used to skip an iteration in a loop?', 'multiple_choice', 4, 2, '2025-02-01 08:00:00'),
(8, 2, 'What is the purpose of an if-else statement?', 'multiple_choice', 4, 3, '2025-02-01 08:00:00'),
(9, 2, 'True or False: A switch statement can only handle integers.', 'true_false', 4, 4, '2025-02-01 08:00:00'),
(10, 2, 'Describe the difference between while and do-while loops.', 'short_answer', 4, 5, '2025-02-01 08:00:00'),
(11, 3, 'What is the time complexity of array access?', 'multiple_choice', 5, 1, '2025-01-26 08:00:00'),
(12, 3, 'Explain how a linked list differs from an array.', 'short_answer', 5, 2, '2025-01-26 08:00:00'),
(13, 3, 'What is the advantage of a linked list over an array?', 'multiple_choice', 5, 3, '2025-01-26 08:00:00'),
(14, 3, 'True or False: Linked lists allow constant-time access to elements.', 'true_false', 5, 4, '2025-01-26 08:00:00'),
(15, 4, 'What is encapsulation?', 'multiple_choice', 5, 1, '2025-02-03 08:00:00'),
(16, 4, 'Describe inheritance with an example.', 'short_answer', 5, 2, '2025-02-03 08:00:00'),
(17, 4, 'What are the four pillars of OOP?', 'multiple_choice', 5, 3, '2025-02-03 08:00:00'),
(18, 4, 'True or False: A class can inherit from multiple classes in Java.', 'true_false', 5, 4, '2025-02-03 08:00:00'),
(19, 4, 'What is the difference between a class and an object?', 'short_answer', 5, 5, '2025-02-03 08:00:00');

-- ============================================================
-- TABLE: ATTENDANCE_SESSIONS
-- ============================================================
INSERT IGNORE INTO `attendance_sessions` (`session_id`, `section_id`, `session_date`, `session_type`, `instructor_id`, `start_time`, `end_time`, `status`, `created_at`) VALUES
(1, 1, '2025-02-03', 'lecture', 8, '09:00:00', '10:30:00', 'completed', '2025-02-03 08:00:00'),
(2, 1, '2025-02-05', 'lecture', 8, '09:00:00', '10:30:00', 'completed', '2025-02-05 08:00:00'),
(3, 1, '2025-02-10', 'lecture', 8, '09:00:00', '10:30:00', 'completed', '2025-02-10 08:00:00'),
(4, 2, '2025-02-04', 'lecture', 9, '11:00:00', '12:30:00', 'completed', '2025-02-04 08:00:00'),
(5, 2, '2025-02-06', 'lecture', 9, '11:00:00', '12:30:00', 'completed', '2025-02-06 08:00:00'),
(6, 3, '2025-02-03', 'lecture', 10, '13:00:00', '14:30:00', 'completed', '2025-02-03 08:00:00'),
(7, 3, '2025-02-05', 'lecture', 10, '13:00:00', '14:30:00', 'completed', '2025-02-05 08:00:00'),
(8, 5, '2025-02-03', 'lab', 12, '15:00:00', '16:30:00', 'completed', '2025-02-03 08:00:00'),
(9, 9, '2025-02-04', 'lecture', 16, '14:00:00', '15:00:00', 'completed', '2025-02-04 08:00:00'),
(10, 10, '2025-02-05', 'lecture', 17, '13:00:00', '14:00:00', 'completed', '2025-02-05 08:00:00');

-- ============================================================
-- TABLE: ATTENDANCE_RECORDS
-- ============================================================
INSERT IGNORE INTO `attendance_records` (`record_id`, `session_id`, `user_id`, `attendance_status`, `check_in_time`) VALUES
(1, 1, 21, 'present', '2025-02-03 08:58:00'),
(2, 1, 22, 'present', '2025-02-03 09:02:00'),
(3, 1, 23, 'present', '2025-02-03 09:00:00'),
(4, 1, 24, 'absent', NULL),
(5, 1, 25, 'present', '2025-02-03 09:05:00'),
(6, 2, 21, 'present', '2025-02-05 09:00:00'),
(7, 2, 22, 'present', '2025-02-05 09:03:00'),
(8, 2, 23, 'present', '2025-02-05 09:00:00'),
(9, 2, 24, 'late', '2025-02-05 09:15:00'),
(10, 2, 25, 'present', '2025-02-05 08:58:00');

-- ============================================================
-- TABLE: GRADES
-- ============================================================
INSERT IGNORE INTO `grades` (`user_id`, `course_id`, `assignment_id`, `grade_type`, `score`, `max_score`, `percentage`, `letter_grade`, `feedback`, `graded_by`, `graded_at`, `is_published`) VALUES
(21, 1, 1, 'assignment', 92.00, 100.00, 92.00, 'A', 'Great work! Well-structured code.', 8, '2025-02-01 10:00:00', 1),
(22, 1, 1, 'assignment', 88.00, 100.00, 88.00, 'B+', 'Good solution. Need improvement in error handling.', 8, '2025-02-01 10:00:00', 1),
(23, 1, 1, 'assignment', 95.00, 100.00, 95.00, 'A', 'Excellent! Clean code and thorough testing.', 8, '2025-02-01 10:00:00', 1),
(24, 1, 1, 'assignment', 85.00, 100.00, 85.00, 'B', 'Acceptable solution but could be optimized.', 8, '2025-02-02 09:00:00', 1),
(25, 1, 1, 'assignment', 90.00, 100.00, 90.00, 'A-', 'Good job overall.', 8, '2025-02-01 10:00:00', 1),
(21, 1, NULL, 'quiz', 18.00, 20.00, 90.00, 'A-', 'Well done on the quiz!', 8, '2025-02-03 10:30:00', 1),
(22, 1, NULL, 'quiz', 16.00, 20.00, 80.00, 'B-', 'Good effort. Review control flow concepts.', 8, '2025-02-03 10:30:00', 1),
(23, 1, NULL, 'quiz', 19.00, 20.00, 95.00, 'A', 'Perfect score! Excellent understanding.', 8, '2025-02-03 10:30:00', 1),
(24, 1, NULL, 'quiz', 15.00, 20.00, 75.00, 'C+', 'Needs improvement. Review material.', 8, '2025-02-03 10:30:00', 1),
(25, 1, NULL, 'quiz', 17.00, 20.00, 85.00, 'B+', 'Good work on the quiz.', 8, '2025-02-03 10:30:00', 1);

-- ============================================================
-- PRIORITY 5: COMMUNICATION
-- ============================================================

-- ============================================================
-- TABLE: ANNOUNCEMENTS
-- ============================================================
INSERT IGNORE INTO `announcements` (`announcement_id`, `course_id`, `created_by`, `title`, `content`, `announcement_type`, `priority`, `target_audience`, `is_published`, `published_at`, `expires_at`, `attachment_file_id`, `view_count`, `created_at`, `updated_at`) VALUES
(1, 1, 8, 'Welcome to CS101!', 'Welcome to Introduction to Computer Science. Looking forward to an exciting semester of learning!', 'course', 'medium', 'all', 1, '2025-01-15 08:00:00', NULL, NULL, 42, '2025-01-15 08:00:00', '2025-01-15 08:00:00'),
(2, 1, 8, 'Assignment 1 Released', 'The first assignment is now available in the course materials section. Due date: February 1st.', 'course', 'high', 'students', 1, '2025-01-20 09:00:00', NULL, NULL, 38, '2025-01-20 09:00:00', '2025-01-20 09:00:00'),
(3, NULL, 1, 'Campus WiFi Maintenance', 'Network maintenance scheduled for this weekend. Expect brief outages.', 'campus', 'medium', 'all', 1, '2025-02-10 06:00:00', NULL, NULL, 120, '2025-02-10 06:00:00', '2025-02-10 06:00:00'),
(4, 2, 10, 'Midterm Exam Schedule', 'The midterm exam will be held on March 15, 2025 from 2:00 PM to 4:00 PM.', 'course', 'high', 'students', 1, '2025-02-12 10:00:00', NULL, NULL, 55, '2025-02-12 10:00:00', '2025-02-12 10:00:00'),
(5, 1, 8, 'Office Hours Extended', 'Extended office hours this week: Monday 2-4 PM, Wednesday 1-3 PM. Location: Room 301A.', 'course', 'medium', 'students', 1, '2025-02-13 08:00:00', NULL, NULL, 23, '2025-02-13 08:00:00', '2025-02-13 08:00:00');

-- ============================================================
-- TABLE: MESSAGES
-- ============================================================
INSERT IGNORE INTO `messages` (`message_id`, `sender_id`, `subject`, `body`, `message_type`, `sent_at`) VALUES
(1, 21, 'Questions about Assignment 1', 'I had some questions about the requirements for assignment 1. Could we schedule a meeting?', 'direct', '2025-01-28 14:30:00'),
(2, 8, 'Re: Questions about Assignment 1', 'Sure! Let''s meet tomorrow at 3 PM in my office.', 'direct', '2025-01-28 15:45:00'),
(3, 23, 'Course Material Request', 'Could you please share the lecture slides from last week''s class?', 'direct', '2025-02-04 10:15:00'),
(4, 8, 'Re: Course Material Request', 'The slides have been uploaded to the course portal.', 'direct', '2025-02-04 11:00:00'),
(5, 22, 'Grade Discussion', 'I would like to discuss my quiz score from last week.', 'direct', '2025-02-08 16:20:00');

-- ============================================================
-- TABLE: MESSAGE_PARTICIPANTS
-- ============================================================
INSERT IGNORE INTO `message_participants` (`participant_id`, `message_id`, `user_id`, `read_at`) VALUES
(1, 1, 21, '2025-01-28 14:30:00'),
(2, 1, 8, NULL),
(3, 2, 21, NULL),
(4, 2, 8, '2025-01-28 15:45:00'),
(5, 3, 23, '2025-02-04 10:15:00'),
(6, 3, 8, NULL),
(7, 4, 23, NULL),
(8, 4, 8, '2025-02-04 11:00:00'),
(9, 5, 22, '2025-02-08 16:20:00'),
(10, 5, 8, NULL);

-- ============================================================
-- TABLE: NOTIFICATIONS
-- ============================================================
INSERT IGNORE INTO `notifications` (`notification_id`, `user_id`, `notification_type`, `title`, `body`, `related_entity_type`, `related_entity_id`, `is_read`, `created_at`) VALUES
(1, 21, 'reminder', 'Assignment Due Soon', 'Assignment 1: Programming Basics is due tomorrow.', 'assignment', 1, 0, '2025-01-31 08:00:00'),
(2, 22, 'reminder', 'Assignment Due Soon', 'Assignment 1: Programming Basics is due today.', 'assignment', 1, 0, '2025-02-01 08:00:00'),
(3, 23, 'grade', 'Grade Posted', 'Your grade for Assignment 1: Programming Basics has been posted.', 'assignment', 1, 1, '2025-02-01 10:30:00'),
(4, 21, 'announcement', 'New Announcement', 'Dr. Ibrahim Ali posted a new announcement in CS101.', 'announcement', 1, 1, '2025-01-20 09:05:00'),
(5, 24, 'warning', 'Attendance Alert', 'You were marked absent in CS101 on February 3rd.', 'attendance', 1, 0, '2025-02-03 11:00:00'),
(6, 25, 'info', 'Quiz Available', 'Quiz 2: Control Flow is now available for CS101.', 'quiz', 2, 0, '2025-02-01 09:00:00'),
(7, 21, 'message', 'Message Received', 'Dr. Ibrahim Ali replied to your message about Assignment 1.', 'message', 2, 1, '2025-01-28 15:50:00'),
(8, 22, 'grade', 'Grade Posted', 'Your grade for Quiz 1 has been posted.', 'quiz', 1, 0, '2025-02-03 11:00:00');

-- ============================================================
-- COMMIT TRANSACTION
-- ============================================================

COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
