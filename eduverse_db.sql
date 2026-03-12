-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Mar 10, 2026 at 08:06 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `eduverse_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `achievements`
--

CREATE TABLE `achievements` (
  `achievement_id` int(10) UNSIGNED NOT NULL,
  `achievement_name` varchar(100) NOT NULL,
  `achievement_description` text DEFAULT NULL,
  `achievement_type` enum('score','streak','completion','participation','speed') NOT NULL,
  `criteria` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `reward_points` int(11) DEFAULT 0,
  `reward_badge_id` int(10) UNSIGNED DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `achievements`
--

INSERT INTO `achievements` (`achievement_id`, `achievement_name`, `achievement_description`, `achievement_type`, `criteria`, `reward_points`, `reward_badge_id`, `is_active`, `created_at`) VALUES
(1, 'First Assignment', 'Submit your first assignment', 'completion', '{\"type\": \"assignment_count\", \"value\": 1}', 10, 1, 1, '2025-11-20 13:43:00'),
(2, 'Quiz Champion', 'Score 100% on any quiz', 'score', '{\"type\": \"quiz_score\", \"value\": 100}', 50, 2, 1, '2025-11-20 13:43:00'),
(3, 'Week Perfect', 'Perfect attendance for one week', 'participation', '{\"type\": \"attendance_streak\", \"value\": 5}', 25, 3, 1, '2025-11-20 13:43:00'),
(4, 'Speed Demon', 'Submit assignment 3 days early', 'speed', '{\"type\": \"early_days\", \"value\": 3}', 30, NULL, 1, '2025-11-20 13:43:00');

-- --------------------------------------------------------

--
-- Table structure for table `activity_logs`
--

CREATE TABLE `activity_logs` (
  `log_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `activity_type` enum('login','logout','view','submit','download','upload','chat','quiz','other') NOT NULL,
  `entity_type` varchar(50) DEFAULT NULL,
  `entity_id` bigint(20) UNSIGNED DEFAULT NULL,
  `description` text DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `session_duration_minutes` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `activity_logs`
--

INSERT INTO `activity_logs` (`log_id`, `user_id`, `activity_type`, `entity_type`, `entity_id`, `description`, `ip_address`, `user_agent`, `session_duration_minutes`, `created_at`) VALUES
(1, 7, 'login', NULL, NULL, 'User logged in', '192.168.1.100', NULL, NULL, '2025-11-20 13:43:00'),
(2, 7, 'view', 'course_material', 1, 'Viewed course syllabus', '192.168.1.100', NULL, NULL, '2025-11-20 13:43:00'),
(3, 7, 'submit', 'assignment', 1, 'Submitted Assignment 1', '192.168.1.100', NULL, 45, '2025-11-20 13:43:00'),
(4, 7, 'quiz', 'quiz', 1, 'Completed Quiz 1', '192.168.1.100', NULL, 25, '2025-11-20 13:43:00'),
(5, 8, 'login', NULL, NULL, 'User logged in', '192.168.1.101', NULL, NULL, '2025-11-20 13:43:00'),
(6, 8, 'view', 'course_material', 2, 'Viewed Lecture 1', '192.168.1.101', NULL, NULL, '2025-11-20 13:43:00'),
(7, 8, 'submit', 'assignment', 1, 'Submitted Assignment 1', '192.168.1.101', NULL, 38, '2025-11-20 13:43:00'),
(8, 9, 'login', NULL, NULL, 'User logged in', '192.168.1.102', NULL, NULL, '2025-11-20 13:43:00');

-- --------------------------------------------------------

--
-- Table structure for table `ai_attendance_processing`
--

CREATE TABLE `ai_attendance_processing` (
  `processing_id` bigint(20) UNSIGNED NOT NULL,
  `session_id` bigint(20) UNSIGNED NOT NULL,
  `photo_id` bigint(20) UNSIGNED NOT NULL,
  `status` enum('pending','processing','completed','failed','manual_review') DEFAULT 'pending',
  `detected_faces_count` int(11) DEFAULT 0,
  `matched_students_count` int(11) DEFAULT 0,
  `unmatched_faces_count` int(11) DEFAULT 0,
  `unmatched_faces_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `confidence_scores` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `processing_time_ms` int(11) DEFAULT NULL,
  `error_message` text DEFAULT NULL,
  `manual_review_required` tinyint(1) DEFAULT 0,
  `reviewed_by` bigint(20) UNSIGNED DEFAULT NULL,
  `reviewed_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `completed_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `ai_feedback`
--

CREATE TABLE `ai_feedback` (
  `feedback_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `course_id` bigint(20) UNSIGNED NOT NULL,
  `feedback_type` enum('performance','improvement','strength','recommendation') NOT NULL,
  `feedback_text` text NOT NULL,
  `priority` enum('low','medium','high') DEFAULT 'medium',
  `is_read` tinyint(1) DEFAULT 0,
  `read_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `ai_flashcards`
--

CREATE TABLE `ai_flashcards` (
  `flashcard_id` bigint(20) UNSIGNED NOT NULL,
  `material_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `front_text` text NOT NULL,
  `back_text` text NOT NULL,
  `category` varchar(100) DEFAULT NULL,
  `difficulty` enum('easy','medium','hard') DEFAULT NULL,
  `order_index` int(11) DEFAULT 0,
  `times_reviewed` int(11) DEFAULT 0,
  `last_reviewed_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `ai_grading_results`
--

CREATE TABLE `ai_grading_results` (
  `grading_id` bigint(20) UNSIGNED NOT NULL,
  `submission_id` bigint(20) UNSIGNED DEFAULT NULL,
  `quiz_attempt_id` bigint(20) UNSIGNED DEFAULT NULL,
  `ai_score` decimal(5,2) DEFAULT NULL,
  `max_score` decimal(5,2) DEFAULT NULL,
  `ai_feedback` text DEFAULT NULL,
  `confidence_score` decimal(3,2) DEFAULT NULL,
  `grading_criteria` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `requires_human_review` tinyint(1) DEFAULT 0,
  `human_override_score` decimal(5,2) DEFAULT NULL,
  `processing_time_ms` int(11) DEFAULT NULL,
  `ai_model` varchar(50) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `reviewed_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `ai_quizzes`
--

CREATE TABLE `ai_quizzes` (
  `ai_quiz_id` bigint(20) UNSIGNED NOT NULL,
  `material_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `difficulty_id` int(10) UNSIGNED DEFAULT NULL,
  `quiz_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `question_count` int(11) DEFAULT 10,
  `language` varchar(10) DEFAULT 'en',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `ai_recommendations`
--

CREATE TABLE `ai_recommendations` (
  `recommendation_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `course_id` bigint(20) UNSIGNED NOT NULL,
  `material_id` bigint(20) UNSIGNED DEFAULT NULL,
  `recommendation_type` enum('topic','material','practice','review') NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `reason` text DEFAULT NULL,
  `priority` enum('low','medium','high') DEFAULT 'medium',
  `is_viewed` tinyint(1) DEFAULT 0,
  `is_completed` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `viewed_at` timestamp NULL DEFAULT NULL,
  `completed_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `ai_recommendations`
--

INSERT INTO `ai_recommendations` (`recommendation_id`, `user_id`, `course_id`, `material_id`, `recommendation_type`, `title`, `description`, `reason`, `priority`, `is_viewed`, `is_completed`, `created_at`, `viewed_at`, `completed_at`) VALUES
(4, 9, 2, NULL, 'review', 'Linked List Fundamentals', 'Revisit this topic before the midterm', 'Important for upcoming exam', 'high', 0, 0, '2025-11-20 13:43:00', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `ai_study_plans`
--

CREATE TABLE `ai_study_plans` (
  `plan_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `course_id` bigint(20) UNSIGNED NOT NULL,
  `plan_name` varchar(255) NOT NULL,
  `plan_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `total_hours` int(11) DEFAULT NULL,
  `status` enum('active','completed','abandoned') DEFAULT 'active',
  `progress_percentage` decimal(5,2) DEFAULT 0.00,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `ai_study_plans`
--

INSERT INTO `ai_study_plans` (`plan_id`, `user_id`, `course_id`, `plan_name`, `plan_data`, `start_date`, `end_date`, `total_hours`, `status`, `progress_percentage`, `created_at`, `updated_at`) VALUES
(3, 12, 2, 'Data Structures Mastery', '{\"weeks\": [{\"week\": 1, \"topics\": [\"Arrays\", \"Linked Lists\"], \"hours\": 7}, {\"week\": 2, \"topics\": [\"Stacks\", \"Queues\"], \"hours\": 7}]}', '2025-02-18', '2025-04-01', 28, 'active', 20.00, '2025-11-20 13:43:00', '2025-11-20 13:43:00');

-- --------------------------------------------------------

--
-- Table structure for table `ai_summaries`
--

CREATE TABLE `ai_summaries` (
  `summary_id` bigint(20) UNSIGNED NOT NULL,
  `material_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `summary_text` text NOT NULL,
  `summary_type` enum('short','medium','detailed') DEFAULT 'medium',
  `language` varchar(10) DEFAULT 'en',
  `word_count` int(11) DEFAULT NULL,
  `processing_time_ms` int(11) DEFAULT NULL,
  `ai_model` varchar(50) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `ai_usage_statistics`
--

CREATE TABLE `ai_usage_statistics` (
  `stat_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `feature_type` enum('summary','flashcard','quiz','feedback','chatbot','grading','recommendation','study_plan','voice','ocr','attendance') NOT NULL,
  `feature_id` bigint(20) UNSIGNED DEFAULT NULL,
  `usage_count` int(11) DEFAULT 1,
  `tokens_used` int(11) DEFAULT NULL,
  `processing_time_ms` int(11) DEFAULT NULL,
  `cost_estimate` decimal(10,6) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `ai_usage_statistics`
--

INSERT INTO `ai_usage_statistics` (`stat_id`, `user_id`, `feature_type`, `feature_id`, `usage_count`, `tokens_used`, `processing_time_ms`, `cost_estimate`, `created_at`) VALUES
(1, 7, 'summary', 1, 1, 450, 1250, 0.000225, '2025-11-20 13:43:00'),
(2, 7, 'flashcard', 2, 1, 380, 890, 0.000190, '2025-11-20 13:43:00'),
(3, 7, 'quiz', 1, 1, 520, 1450, 0.000260, '2025-11-20 13:43:00'),
(4, 8, 'summary', 3, 1, 290, 650, 0.000145, '2025-11-20 13:43:00'),
(5, 8, 'chatbot', 1, 4, 1850, 5200, 0.000925, '2025-11-20 13:43:00'),
(6, 9, 'recommendation', 1, 1, 180, 420, 0.000090, '2025-11-20 13:43:00'),
(7, 10, 'grading', 1, 1, 680, 1850, 0.000340, '2025-11-20 13:43:00'),
(8, 11, 'attendance', 2, 1, 920, 2100, 0.000460, '2025-11-20 13:43:00'),
(9, 12, 'study_plan', 1, 1, 1200, 3400, 0.000600, '2025-11-20 13:43:00');

-- --------------------------------------------------------

--
-- Table structure for table `announcements`
--

CREATE TABLE `announcements` (
  `announcement_id` bigint(20) UNSIGNED NOT NULL,
  `course_id` bigint(20) UNSIGNED DEFAULT NULL,
  `created_by` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(255) NOT NULL,
  `content` text NOT NULL,
  `announcement_type` enum('course','department','campus','system') DEFAULT 'course',
  `priority` enum('low','medium','high','urgent') DEFAULT 'medium',
  `target_audience` enum('all','students','instructors','tas','custom') DEFAULT 'all',
  `is_published` tinyint(1) DEFAULT 0,
  `published_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `attachment_file_id` bigint(20) UNSIGNED DEFAULT NULL,
  `view_count` int(11) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `announcements`
--

INSERT INTO `announcements` (`announcement_id`, `course_id`, `created_by`, `title`, `content`, `announcement_type`, `priority`, `target_audience`, `is_published`, `published_at`, `expires_at`, `attachment_file_id`, `view_count`, `created_at`, `updated_at`) VALUES
(1, 1, 8, 'Welcome to CS101!', 'Welcome to Introduction to Computer Science. Looking forward to an exciting semester of learning!', 'course', 'medium', 'all', 1, '2025-01-15 08:00:00', NULL, NULL, 44, '2025-01-15 08:00:00', '2026-03-05 19:16:32'),
(2, 1, 8, 'Assignment 1 Released', 'The first assignment is now available in the course materials section. Due date: February 1st.', 'course', 'high', 'students', 1, '2025-01-20 09:00:00', NULL, NULL, 38, '2025-01-20 09:00:00', '2025-01-20 09:00:00'),
(3, NULL, 1, 'Campus WiFi Maintenance', 'Network maintenance scheduled for this weekend. Expect brief outages.', 'campus', 'medium', 'all', 1, '2025-02-10 06:00:00', NULL, NULL, 0, '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(4, 2, 3, 'Midterm Exam Schedule', 'The midterm exam will be held on March 15, 2025 from 2:00 PM to 4:00 PM.', 'course', 'high', 'students', 1, '2025-02-12 10:00:00', NULL, NULL, 0, '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(5, 1, 8, 'Office Hours Extended', 'Extended office hours this week: Monday 2-4 PM, Wednesday 1-3 PM. Location: Room 301A.', 'course', 'medium', 'students', 1, '2025-02-13 08:00:00', NULL, NULL, 23, '2025-02-13 08:00:00', '2025-02-13 08:00:00');

-- --------------------------------------------------------

--
-- Table structure for table `api_integrations`
--

CREATE TABLE `api_integrations` (
  `integration_id` bigint(20) UNSIGNED NOT NULL,
  `campus_id` bigint(20) UNSIGNED NOT NULL,
  `integration_name` varchar(100) NOT NULL,
  `integration_type` enum('lms','sso','payment','email','sms','ai','storage','other') NOT NULL,
  `api_endpoint` varchar(500) DEFAULT NULL,
  `api_key_encrypted` varchar(500) DEFAULT NULL,
  `configuration` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `last_sync_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `api_integrations`
--

INSERT INTO `api_integrations` (`integration_id`, `campus_id`, `integration_name`, `integration_type`, `api_endpoint`, `api_key_encrypted`, `configuration`, `is_active`, `last_sync_at`, `created_at`, `updated_at`) VALUES
(1, 1, 'Google Workspace SSO', 'sso', 'https://accounts.google.com/o/oauth2/v2/auth', NULL, NULL, 1, '2025-02-15 03:00:00', '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(2, 1, 'SendGrid Email', 'email', 'https://api.sendgrid.com/v3/mail/send', NULL, NULL, 1, '2025-02-15 06:00:00', '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(3, 1, 'AWS S3 Storage', 'storage', 'https://s3.amazonaws.com', NULL, NULL, 1, '2025-02-15 05:30:00', '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(4, 1, 'OpenAI API', 'ai', 'https://api.openai.com/v1', NULL, NULL, 1, '2025-02-15 07:00:00', '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(5, 2, 'Stripe Payment', 'payment', 'https://api.stripe.com/v1', NULL, NULL, 1, '2025-02-14 13:00:00', '2025-11-20 13:43:00', '2025-11-20 13:43:00');

-- --------------------------------------------------------

--
-- Table structure for table `api_rate_limits`
--

CREATE TABLE `api_rate_limits` (
  `limit_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `api_key` varchar(255) DEFAULT NULL,
  `endpoint` varchar(255) DEFAULT NULL,
  `request_count` int(11) DEFAULT 0,
  `window_start` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `window_end` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `max_requests` int(11) DEFAULT 1000,
  `is_blocked` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `api_rate_limits`
--

INSERT INTO `api_rate_limits` (`limit_id`, `user_id`, `api_key`, `endpoint`, `request_count`, `window_start`, `window_end`, `max_requests`, `is_blocked`, `created_at`, `updated_at`) VALUES
(1, 7, NULL, '/api/v1/courses', 45, '2025-02-15 08:00:00', '2025-02-15 09:00:00', 1000, 0, '2025-11-20 13:43:01', '2025-11-20 13:43:01'),
(2, 8, NULL, '/api/v1/assignments', 23, '2025-02-15 08:00:00', '2025-02-15 09:00:00', 1000, 0, '2025-11-20 13:43:01', '2025-11-20 13:43:01'),
(3, NULL, 'api_key_external_123', '/api/v1/users', 850, '2025-02-15 08:00:00', '2025-02-15 09:00:00', 1000, 0, '2025-11-20 13:43:01', '2025-11-20 13:43:01'),
(4, NULL, 'api_key_external_456', '/api/v1/grades', 1005, '2025-02-15 07:00:00', '2025-02-15 08:00:00', 1000, 1, '2025-11-20 13:43:01', '2025-11-20 13:43:01');

-- --------------------------------------------------------

--
-- Table structure for table `assignments`
--

CREATE TABLE `assignments` (
  `assignment_id` bigint(20) UNSIGNED NOT NULL,
  `course_id` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `instructions` text DEFAULT NULL,
  `max_score` decimal(5,2) DEFAULT 100.00,
  `weight` decimal(5,2) DEFAULT 0.00,
  `due_date` timestamp NULL DEFAULT NULL,
  `available_from` timestamp NULL DEFAULT NULL,
  `late_submission_allowed` tinyint(1) DEFAULT 0,
  `late_penalty_percent` decimal(5,2) DEFAULT 0.00,
  `submission_type` enum('file','text','link','multiple') DEFAULT 'file',
  `max_file_size_mb` int(11) DEFAULT 10,
  `allowed_file_types` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `status` enum('draft','published','closed','archived') DEFAULT 'draft',
  `created_by` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `assignments`
--

INSERT INTO `assignments` (`assignment_id`, `course_id`, `title`, `description`, `instructions`, `max_score`, `weight`, `due_date`, `available_from`, `late_submission_allowed`, `late_penalty_percent`, `submission_type`, `max_file_size_mb`, `allowed_file_types`, `status`, `created_by`, `created_at`, `updated_at`, `deleted_at`) VALUES
(1, 1, 'Assignment 1: Programming Basics', 'Write a program that demonstrates basic programming concepts', 'Create a complete program with proper comments and documentation', 100.00, 0.00, '2025-02-01 23:59:59', '2025-01-20 08:00:00', 1, 0.00, 'file', 10, NULL, 'draft', 8, '2025-01-20 08:00:00', '2025-01-20 08:00:00', NULL),
(2, 1, 'Assignment 2: Functions and Modules', 'Implement functions and modules for a simple application', 'Submit your code with test cases', 100.00, 0.00, '2025-02-15 23:59:59', '2025-01-27 08:00:00', 1, 0.00, 'file', 10, NULL, 'draft', 8, '2025-01-27 08:00:00', '2025-01-27 08:00:00', NULL),
(3, 1, 'Updated Assignment Title', 'string', 'string', 150.00, 100.00, '2026-03-01 21:08:59', '2026-02-01 21:08:59', 0, 0.00, 'file', 10, '[\"pdf\",\"docx\",\"zip\"]', 'published', 3, '2025-11-20 13:42:59', '2026-03-05 19:16:23', NULL),
(4, 3, 'Assignment 1: SQL Queries', 'Database query practice', 'Write SQL queries for the given scenarios', 100.00, 15.00, '2025-03-05 21:59:59', '2025-02-14 22:00:00', 0, 0.00, 'text', 10, NULL, 'draft', 3, '2025-11-20 13:42:59', '2025-11-20 13:42:59', NULL),
(5, 3, 'Midterm Quiz', 'Comprehensive quiz covering weeks 1-6', 'Answer all questions to the best of your ability', 50.00, 0.00, '2025-03-01 23:59:59', '2025-02-01 08:00:00', 0, 0.00, 'text', 10, NULL, 'draft', 10, '2025-02-01 08:00:00', '2025-02-01 08:00:00', NULL),
(6, 5, 'Lab Assignment 1: OOP Design', 'Design and implement OOP concepts in a project', 'Implement the provided specification', 120.00, 0.00, '2025-02-10 23:59:59', '2025-01-25 08:00:00', 1, 0.00, 'file', 10, NULL, 'draft', 12, '2025-01-25 08:00:00', '2025-01-25 08:00:00', NULL),
(7, 6, 'Assignment 1: SQL Queries', 'Write SQL queries to retrieve and manipulate data', 'Write queries following best practices', 100.00, 0.00, '2025-02-05 23:59:59', '2025-01-28 08:00:00', 1, 0.00, 'file', 10, NULL, 'draft', 14, '2025-01-28 08:00:00', '2025-01-28 08:00:00', NULL),
(8, 7, 'Project: Web Application', 'Build a complete web application using modern frameworks', 'Follow the project specification document', 200.00, 0.00, '2025-03-15 23:59:59', '2025-02-01 08:00:00', 1, 0.00, 'file', 10, NULL, 'draft', 15, '2025-02-01 08:00:00', '2025-02-01 08:00:00', NULL),
(9, 9, 'Problem Set 1: Statistical Analysis', 'Solve statistical problems using real datasets', 'Show all work and calculations', 100.00, 0.00, '2025-02-08 23:59:59', '2025-01-30 08:00:00', 1, 0.00, 'file', 10, NULL, 'draft', 16, '2025-01-30 08:00:00', '2025-01-30 08:00:00', NULL),
(10, 10, 'Essay: Literary Analysis', 'Write a comprehensive literary analysis essay', 'Submit as PDF with proper formatting', 100.00, 0.00, '2025-02-12 23:59:59', '2025-01-31 08:00:00', 1, 0.00, 'file', 10, NULL, 'draft', 17, '2025-01-31 08:00:00', '2025-01-31 08:00:00', NULL),
(11, 1, 'Homework 1', 'string', 'string', 100.00, 100.00, '2026-03-01 21:08:59', '2026-03-02 21:08:59', 0, 0.00, 'file', 10, '[\"pdf\",\"docx\",\"zip\"]', 'draft', 56, '2026-03-01 21:09:28', '2026-03-01 21:09:28', NULL),
(12, 1, 'Test Assignment', 'A test', 'Do this', 100.00, 10.00, '2026-06-01 23:59:59', NULL, 0, 0.00, 'file', 10, NULL, 'draft', 58, '2026-03-02 13:31:32', '2026-03-02 13:31:32', NULL),
(13, 1, 'AutoAssign', 'Test', 'Do', 100.00, 10.00, '2026-12-01 23:59:59', NULL, 0, 0.00, 'file', 10, NULL, 'draft', 58, '2026-03-02 13:50:32', '2026-03-02 13:50:32', NULL),
(14, 1, 'Bad', 'x', NULL, 100.00, 0.00, NULL, NULL, 0, 0.00, 'file', 10, NULL, 'draft', 57, '2026-03-02 13:50:33', '2026-03-02 13:50:33', NULL),
(15, 1, 'Postman Test Assignment', 'An assignment created from Postman', 'Complete the tasks listed below', 100.00, 15.00, '2026-06-15 23:59:59', '2026-06-01 00:00:00', 1, 10.00, 'file', 10, '[\"pdf\",\"docx\",\"zip\"]', 'published', 58, '2026-03-02 23:31:42', '2026-03-02 23:31:42', NULL),
(16, 1, 'Postman Test Assignment', 'An assignment created from Postman', 'Complete the tasks listed below', 100.00, 15.00, '2026-06-15 23:59:59', '2026-06-01 00:00:00', 1, 10.00, 'file', 10, '[\"pdf\",\"docx\",\"zip\"]', 'published', 58, '2026-03-02 23:51:56', '2026-03-02 23:51:56', NULL),
(17, 1, 'Postman Test Assignment', 'An assignment created from Postman', 'Complete the tasks listed below', 100.00, 15.00, '2026-06-15 23:59:59', '2026-06-01 00:00:00', 1, 10.00, 'file', 10, '[\"pdf\",\"docx\",\"zip\"]', 'published', 58, '2026-03-03 00:23:17', '2026-03-03 00:23:17', NULL),
(18, 1, 'Postman Test Assignment', 'An assignment created from Postman', 'Complete the tasks listed below', 100.00, 15.00, '2026-06-15 23:59:59', '2026-06-01 00:00:00', 1, 10.00, 'file', 10, '[\"pdf\",\"docx\",\"zip\"]', 'published', 58, '2026-03-03 18:34:02', '2026-03-03 18:34:02', NULL),
(19, 1, 'Postman Test Assignment', 'An assignment created from Postman', 'Complete the tasks listed below', 100.00, 15.00, '2026-06-15 23:59:59', '2026-06-01 00:00:00', 1, 10.00, 'file', 10, '[\"pdf\",\"docx\",\"zip\"]', 'published', 58, '2026-03-05 19:16:23', '2026-03-05 19:16:23', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `assignment_submissions`
--

CREATE TABLE `assignment_submissions` (
  `submission_id` bigint(20) UNSIGNED NOT NULL,
  `assignment_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `file_id` bigint(20) UNSIGNED DEFAULT NULL,
  `submission_text` text DEFAULT NULL,
  `submission_link` varchar(500) DEFAULT NULL,
  `submitted_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `is_late` tinyint(1) DEFAULT 0,
  `attempt_number` int(11) DEFAULT 1,
  `status` enum('submitted','graded','returned','resubmit') DEFAULT 'submitted'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `assignment_submissions`
--

INSERT INTO `assignment_submissions` (`submission_id`, `assignment_id`, `user_id`, `file_id`, `submission_text`, `submission_link`, `submitted_at`, `is_late`, `attempt_number`, `status`) VALUES
(16, 1, 21, NULL, 'Submitted assignment 1 - programming basics', NULL, '2025-01-31 15:30:00', 0, 1, 'graded'),
(17, 1, 22, NULL, 'Submitted assignment 1 - programming basics', NULL, '2025-01-31 16:00:00', 0, 1, 'graded'),
(18, 1, 23, NULL, 'Submitted assignment 1 - programming basics', NULL, '2025-01-29 12:00:00', 0, 1, 'graded'),
(19, 1, 24, NULL, 'Submitted assignment 1 - programming basics', NULL, '2025-02-01 23:50:00', 0, 1, 'graded'),
(20, 1, 25, NULL, 'Submitted assignment 1 - programming basics', NULL, '2025-01-30 18:00:00', 0, 1, 'graded'),
(21, 2, 23, NULL, 'Submitted assignment 2 - functions and modules', NULL, '2025-02-14 10:30:00', 0, 1, 'submitted'),
(22, 2, 25, NULL, 'Submitted assignment 2 - functions and modules', NULL, '2025-02-13 14:00:00', 0, 1, 'submitted'),
(23, 4, 21, NULL, 'Submitted project 1 - data structures implementation', NULL, '2025-02-18 17:00:00', 0, 1, 'submitted'),
(24, 4, 23, NULL, 'Submitted project 1 - data structures implementation', NULL, '2025-02-19 12:00:00', 0, 1, 'submitted'),
(25, 4, 25, NULL, 'Submitted project 1 - data structures implementation', NULL, '2025-02-17 09:00:00', 0, 1, 'submitted');

-- --------------------------------------------------------

--
-- Table structure for table `attendance_photos`
--

CREATE TABLE `attendance_photos` (
  `photo_id` bigint(20) UNSIGNED NOT NULL,
  `session_id` bigint(20) UNSIGNED NOT NULL,
  `file_id` bigint(20) UNSIGNED NOT NULL,
  `uploaded_by` bigint(20) UNSIGNED NOT NULL,
  `photo_type` enum('class_photo','individual','video_frame') DEFAULT 'class_photo',
  `capture_timestamp` timestamp NOT NULL DEFAULT current_timestamp(),
  `processing_status` enum('pending','processing','completed','failed') DEFAULT 'pending'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `attendance_records`
--

CREATE TABLE `attendance_records` (
  `record_id` bigint(20) UNSIGNED NOT NULL,
  `session_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `attendance_status` enum('present','absent','late','excused') DEFAULT 'absent',
  `check_in_time` timestamp NULL DEFAULT NULL,
  `marked_by` enum('manual','ai','self') DEFAULT 'manual',
  `confidence_score` decimal(5,4) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `attendance_records`
--

INSERT INTO `attendance_records` (`record_id`, `session_id`, `user_id`, `attendance_status`, `check_in_time`, `marked_by`, `confidence_score`, `notes`, `updated_at`) VALUES
(1, 1, 21, 'present', '2025-02-03 08:58:00', 'manual', NULL, NULL, '2026-03-01 14:55:40'),
(2, 1, 22, 'present', '2025-02-03 09:02:00', 'manual', NULL, NULL, '2026-03-01 14:55:40'),
(3, 1, 23, 'present', '2025-02-03 09:00:00', 'manual', NULL, NULL, '2026-03-01 14:55:40'),
(4, 1, 24, 'absent', NULL, 'manual', NULL, NULL, '2026-03-01 14:55:40'),
(5, 1, 25, 'present', '2025-02-03 09:05:00', 'manual', NULL, NULL, '2026-03-01 14:55:40'),
(6, 2, 21, 'present', '2025-02-05 09:00:00', 'manual', NULL, NULL, '2026-03-01 14:55:40'),
(7, 2, 22, 'present', '2025-02-05 09:03:00', 'manual', NULL, NULL, '2026-03-01 14:55:40'),
(8, 2, 23, 'present', '2025-02-05 09:00:00', 'manual', NULL, NULL, '2026-03-01 14:55:40'),
(9, 2, 24, 'late', '2025-02-05 09:15:00', 'manual', NULL, NULL, '2026-03-01 14:55:40'),
(10, 2, 25, 'present', '2025-02-05 08:58:00', 'manual', NULL, NULL, '2026-03-01 14:55:40'),
(17, 11, 7, 'absent', NULL, 'manual', NULL, NULL, '2026-03-02 14:05:42'),
(18, 11, 8, 'absent', NULL, 'manual', NULL, NULL, '2026-03-02 14:05:42'),
(19, 11, 9, 'absent', NULL, 'manual', NULL, NULL, '2026-03-02 14:05:42'),
(20, 11, 10, 'absent', NULL, 'manual', NULL, NULL, '2026-03-02 14:05:42'),
(21, 11, 11, 'absent', NULL, 'manual', NULL, NULL, '2026-03-02 14:05:42'),
(22, 11, 25, 'absent', NULL, 'manual', NULL, NULL, '2026-03-02 14:05:42'),
(23, 11, 30, 'absent', NULL, 'manual', NULL, NULL, '2026-03-02 14:05:42'),
(24, 11, 34, 'absent', NULL, 'manual', NULL, NULL, '2026-03-02 14:05:42'),
(25, 11, 13, 'absent', NULL, 'manual', NULL, NULL, '2026-03-02 14:05:42'),
(26, 11, 14, 'absent', NULL, 'manual', NULL, NULL, '2026-03-02 14:05:42'),
(27, 11, 15, 'absent', NULL, 'manual', NULL, NULL, '2026-03-02 14:05:42'),
(28, 11, 16, 'absent', NULL, 'manual', NULL, NULL, '2026-03-02 14:05:42'),
(29, 11, 21, 'absent', NULL, 'manual', NULL, NULL, '2026-03-02 14:05:42'),
(30, 11, 22, 'absent', NULL, 'manual', NULL, NULL, '2026-03-02 14:05:42'),
(31, 11, 23, 'absent', NULL, 'manual', NULL, NULL, '2026-03-02 14:05:42'),
(32, 11, 24, 'absent', NULL, 'manual', NULL, NULL, '2026-03-02 14:05:42'),
(33, 11, 26, 'absent', NULL, 'manual', NULL, NULL, '2026-03-02 14:05:42'),
(34, 11, 27, 'absent', NULL, 'manual', NULL, NULL, '2026-03-02 14:05:42'),
(35, 11, 28, 'absent', NULL, 'manual', NULL, NULL, '2026-03-02 14:05:42'),
(36, 11, 29, 'absent', NULL, 'manual', NULL, NULL, '2026-03-02 14:05:42'),
(37, 12, 7, 'absent', NULL, 'manual', NULL, NULL, '2026-03-02 14:06:47'),
(38, 12, 8, 'absent', NULL, 'manual', NULL, NULL, '2026-03-02 14:06:47'),
(39, 12, 9, 'absent', NULL, 'manual', NULL, NULL, '2026-03-02 14:06:47'),
(40, 12, 10, 'absent', NULL, 'manual', NULL, NULL, '2026-03-02 14:06:47'),
(41, 12, 11, 'absent', NULL, 'manual', NULL, NULL, '2026-03-02 14:06:47'),
(42, 12, 25, 'absent', NULL, 'manual', NULL, NULL, '2026-03-02 14:06:47'),
(43, 12, 30, 'absent', NULL, 'manual', NULL, NULL, '2026-03-02 14:06:47'),
(44, 12, 34, 'absent', NULL, 'manual', NULL, NULL, '2026-03-02 14:06:47'),
(45, 12, 13, 'absent', NULL, 'manual', NULL, NULL, '2026-03-02 14:06:47'),
(46, 12, 14, 'absent', NULL, 'manual', NULL, NULL, '2026-03-02 14:06:47'),
(47, 12, 15, 'absent', NULL, 'manual', NULL, NULL, '2026-03-02 14:06:47'),
(48, 12, 16, 'absent', NULL, 'manual', NULL, NULL, '2026-03-02 14:06:47'),
(49, 12, 21, 'absent', NULL, 'manual', NULL, NULL, '2026-03-02 14:06:47'),
(50, 12, 22, 'absent', NULL, 'manual', NULL, NULL, '2026-03-02 14:06:47'),
(51, 12, 23, 'absent', NULL, 'manual', NULL, NULL, '2026-03-02 14:06:47'),
(52, 12, 24, 'absent', NULL, 'manual', NULL, NULL, '2026-03-02 14:06:47'),
(53, 12, 26, 'absent', NULL, 'manual', NULL, NULL, '2026-03-02 14:06:47'),
(54, 12, 27, 'absent', NULL, 'manual', NULL, NULL, '2026-03-02 14:06:47'),
(55, 12, 28, 'absent', NULL, 'manual', NULL, NULL, '2026-03-02 14:06:47'),
(56, 12, 29, 'absent', NULL, 'manual', NULL, NULL, '2026-03-02 14:06:47'),
(57, 13, 7, 'absent', NULL, 'manual', NULL, NULL, '2026-03-02 14:06:53'),
(58, 13, 8, 'absent', NULL, 'manual', NULL, NULL, '2026-03-02 14:06:53'),
(59, 13, 9, 'absent', NULL, 'manual', NULL, NULL, '2026-03-02 14:06:53'),
(60, 13, 10, 'absent', NULL, 'manual', NULL, NULL, '2026-03-02 14:06:53'),
(61, 13, 11, 'absent', NULL, 'manual', NULL, NULL, '2026-03-02 14:06:53'),
(62, 13, 25, 'absent', NULL, 'manual', NULL, NULL, '2026-03-02 14:06:53'),
(63, 13, 30, 'absent', NULL, 'manual', NULL, NULL, '2026-03-02 14:06:53'),
(64, 13, 34, 'absent', NULL, 'manual', NULL, NULL, '2026-03-02 14:06:53'),
(65, 13, 13, 'absent', NULL, 'manual', NULL, NULL, '2026-03-02 14:06:53'),
(66, 13, 14, 'absent', NULL, 'manual', NULL, NULL, '2026-03-02 14:06:53'),
(67, 13, 15, 'absent', NULL, 'manual', NULL, NULL, '2026-03-02 14:06:53'),
(68, 13, 16, 'absent', NULL, 'manual', NULL, NULL, '2026-03-02 14:06:53'),
(69, 13, 21, 'absent', NULL, 'manual', NULL, NULL, '2026-03-02 14:06:53'),
(70, 13, 22, 'absent', NULL, 'manual', NULL, NULL, '2026-03-02 14:06:53'),
(71, 13, 23, 'absent', NULL, 'manual', NULL, NULL, '2026-03-02 14:06:53'),
(72, 13, 24, 'absent', NULL, 'manual', NULL, NULL, '2026-03-02 14:06:53'),
(73, 13, 26, 'absent', NULL, 'manual', NULL, NULL, '2026-03-02 14:06:53'),
(74, 13, 27, 'absent', NULL, 'manual', NULL, NULL, '2026-03-02 14:06:53'),
(75, 13, 28, 'absent', NULL, 'manual', NULL, NULL, '2026-03-02 14:06:53'),
(76, 13, 29, 'absent', NULL, 'manual', NULL, NULL, '2026-03-02 14:06:53'),
(77, 14, 7, 'late', NULL, 'manual', NULL, 'Came in late', '2026-03-02 14:08:07'),
(78, 14, 8, 'absent', NULL, 'manual', NULL, NULL, '2026-03-02 14:07:07'),
(79, 14, 9, 'absent', NULL, 'manual', NULL, NULL, '2026-03-02 14:07:07'),
(80, 14, 10, 'absent', NULL, 'manual', NULL, NULL, '2026-03-02 14:07:07'),
(81, 14, 11, 'absent', NULL, 'manual', NULL, NULL, '2026-03-02 14:07:07'),
(82, 14, 25, 'absent', NULL, 'manual', NULL, NULL, '2026-03-02 14:07:07'),
(83, 14, 30, 'absent', NULL, 'manual', NULL, NULL, '2026-03-02 14:07:07'),
(84, 14, 34, 'absent', NULL, 'manual', NULL, NULL, '2026-03-02 14:07:07'),
(85, 14, 13, 'absent', NULL, 'manual', NULL, NULL, '2026-03-02 14:07:07'),
(86, 14, 14, 'absent', NULL, 'manual', NULL, NULL, '2026-03-02 14:07:07'),
(87, 14, 15, 'absent', NULL, 'manual', NULL, NULL, '2026-03-02 14:07:07'),
(88, 14, 16, 'absent', NULL, 'manual', NULL, NULL, '2026-03-02 14:07:07'),
(89, 14, 21, 'absent', NULL, 'manual', NULL, NULL, '2026-03-02 14:07:07'),
(90, 14, 22, 'absent', NULL, 'manual', NULL, NULL, '2026-03-02 14:07:07'),
(91, 14, 23, 'absent', NULL, 'manual', NULL, NULL, '2026-03-02 14:07:07'),
(92, 14, 24, 'absent', NULL, 'manual', NULL, NULL, '2026-03-02 14:07:07'),
(93, 14, 26, 'absent', NULL, 'manual', NULL, NULL, '2026-03-02 14:07:07'),
(94, 14, 27, 'absent', NULL, 'manual', NULL, NULL, '2026-03-02 14:07:07'),
(95, 14, 28, 'absent', NULL, 'manual', NULL, NULL, '2026-03-02 14:07:07'),
(96, 14, 29, 'absent', NULL, 'manual', NULL, NULL, '2026-03-02 14:07:07'),
(97, 14, 57, 'present', NULL, 'manual', NULL, NULL, '2026-03-02 14:08:05'),
(118, 17, 57, 'late', NULL, 'manual', NULL, 'Arrived 10 min late', '2026-03-02 23:42:38'),
(119, 17, 58, 'present', NULL, 'manual', NULL, NULL, '2026-03-02 23:42:38'),
(120, 17, 59, 'absent', NULL, 'manual', NULL, 'No show', '2026-03-02 23:42:38'),
(121, 18, 57, 'late', NULL, 'manual', NULL, 'Arrived 10 min late', '2026-03-02 23:47:21'),
(122, 18, 58, 'present', NULL, 'manual', NULL, NULL, '2026-03-02 23:47:21'),
(123, 18, 59, 'absent', NULL, 'manual', NULL, 'No show', '2026-03-02 23:47:21');

-- --------------------------------------------------------

--
-- Table structure for table `attendance_sessions`
--

CREATE TABLE `attendance_sessions` (
  `session_id` bigint(20) UNSIGNED NOT NULL,
  `section_id` bigint(20) UNSIGNED NOT NULL,
  `session_date` date NOT NULL,
  `session_type` enum('lecture','lab','tutorial','exam') DEFAULT 'lecture',
  `instructor_id` bigint(20) UNSIGNED NOT NULL,
  `start_time` time DEFAULT NULL,
  `end_time` time DEFAULT NULL,
  `location` varchar(100) DEFAULT NULL,
  `total_students` int(11) DEFAULT 0,
  `present_count` int(11) DEFAULT 0,
  `absent_count` int(11) DEFAULT 0,
  `status` enum('scheduled','in_progress','completed','cancelled') DEFAULT 'scheduled',
  `notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `attendance_sessions`
--

INSERT INTO `attendance_sessions` (`session_id`, `section_id`, `session_date`, `session_type`, `instructor_id`, `start_time`, `end_time`, `location`, `total_students`, `present_count`, `absent_count`, `status`, `notes`, `created_at`, `updated_at`) VALUES
(1, 1, '2025-02-03', 'lecture', 8, '09:00:00', '10:30:00', NULL, 0, 0, 0, 'completed', NULL, '2025-02-03 08:00:00', '2026-03-01 14:55:40'),
(2, 1, '2025-02-05', 'lecture', 8, '09:00:00', '10:30:00', NULL, 0, 0, 0, 'completed', NULL, '2025-02-05 08:00:00', '2026-03-01 14:55:40'),
(3, 1, '2025-02-10', 'lecture', 8, '09:00:00', '10:30:00', NULL, 0, 0, 0, 'completed', NULL, '2025-02-10 08:00:00', '2026-03-01 14:55:40'),
(4, 2, '2025-02-04', 'lecture', 9, '11:00:00', '12:30:00', NULL, 0, 0, 0, 'completed', NULL, '2025-02-04 08:00:00', '2026-03-01 14:55:40'),
(5, 2, '2025-02-06', 'lecture', 9, '11:00:00', '12:30:00', NULL, 0, 0, 0, 'completed', NULL, '2025-02-06 08:00:00', '2026-03-01 14:55:40'),
(6, 3, '2025-02-03', 'lecture', 10, '13:00:00', '14:30:00', NULL, 0, 0, 0, 'completed', NULL, '2025-02-03 08:00:00', '2026-03-01 14:55:40'),
(7, 3, '2025-02-05', 'lecture', 10, '13:00:00', '14:30:00', NULL, 0, 0, 0, 'completed', NULL, '2025-02-05 08:00:00', '2026-03-01 14:55:40'),
(8, 5, '2025-02-03', 'lab', 12, '15:00:00', '16:30:00', NULL, 0, 0, 0, 'completed', NULL, '2025-02-03 08:00:00', '2026-03-01 14:55:40'),
(9, 9, '2025-02-04', 'lecture', 16, '14:00:00', '15:00:00', NULL, 0, 0, 0, 'completed', NULL, '2025-02-04 08:00:00', '2026-03-01 14:55:40'),
(10, 10, '2025-02-05', 'lecture', 17, '13:00:00', '14:00:00', NULL, 0, 0, 0, 'completed', NULL, '2025-02-05 08:00:00', '2026-03-01 14:55:40'),
(11, 1, '2026-03-02', 'lecture', 58, '09:00:00', '10:30:00', NULL, 20, 0, 20, 'scheduled', 'Test session', '2026-03-02 14:05:42', '2026-03-02 14:05:42'),
(12, 1, '2026-03-15', 'lecture', 58, '09:00:00', '10:30:00', NULL, 20, 0, 20, 'scheduled', 'Retest session', '2026-03-02 14:06:47', '2026-03-02 14:06:47'),
(13, 1, '2026-03-16', 'lab', 58, NULL, NULL, NULL, 20, 0, 20, 'scheduled', NULL, '2026-03-02 14:06:53', '2026-03-02 14:06:53'),
(14, 1, '2026-03-20', 'lecture', 58, '09:00:00', '10:30:00', NULL, 20, 2, 19, 'completed', 'Updated retest', '2026-03-02 14:07:07', '2026-03-02 14:08:14'),
(16, 11, '2026-03-02', 'lecture', 58, '09:00:00', '10:30:00', 'Room A101', 0, 0, 0, 'scheduled', 'Week 1 intro lecture', '2026-03-02 23:33:32', '2026-03-02 23:33:32'),
(17, 11, '2026-03-02', 'lecture', 58, '09:00:00', '10:30:00', 'Room B202', 0, 2, 1, 'completed', 'Updated notes', '2026-03-02 23:42:38', '2026-03-02 23:42:39'),
(18, 11, '2026-03-02', 'lecture', 58, '09:00:00', '10:30:00', 'Room B202', 0, 2, 1, 'completed', 'Updated notes', '2026-03-02 23:47:21', '2026-03-02 23:47:22'),
(19, 11, '2026-03-02', 'lecture', 58, '09:00:00', '10:30:00', 'Room A101', 0, 0, 0, 'scheduled', 'Week 1 intro lecture', '2026-03-02 23:51:58', '2026-03-02 23:51:58'),
(20, 11, '2026-03-02', 'lecture', 58, '09:00:00', '10:30:00', 'Room A101', 0, 0, 0, 'scheduled', 'Week 1 intro lecture', '2026-03-03 00:23:19', '2026-03-03 00:23:19'),
(21, 11, '2026-03-02', 'lecture', 58, '09:00:00', '10:30:00', 'Room A101', 0, 0, 0, 'scheduled', 'Week 1 intro lecture', '2026-03-03 18:34:04', '2026-03-03 18:34:04'),
(22, 11, '2026-03-02', 'lecture', 58, '09:00:00', '10:30:00', 'Room A101', 0, 0, 0, 'scheduled', 'Week 1 intro lecture', '2026-03-05 19:16:25', '2026-03-05 19:16:25');

-- --------------------------------------------------------

--
-- Table structure for table `audit_logs`
--

CREATE TABLE `audit_logs` (
  `log_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `action_type` varchar(50) NOT NULL,
  `entity_type` varchar(50) DEFAULT NULL,
  `entity_id` bigint(20) UNSIGNED DEFAULT NULL,
  `old_values` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `new_values` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `description` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `audit_logs`
--

INSERT INTO `audit_logs` (`log_id`, `user_id`, `action_type`, `entity_type`, `entity_id`, `old_values`, `new_values`, `ip_address`, `user_agent`, `description`, `created_at`) VALUES
(1, 1, 'CREATE', 'user', 7, NULL, '{\"email\": \"alice.student@campus.edu\", \"role\": \"student\"}', '192.168.1.1', NULL, 'Created new student account', '2025-11-20 13:43:00'),
(2, 2, 'UPDATE', 'grade', 1, '{\"score\": 0}', '{\"score\": 95}', '192.168.1.50', NULL, 'Graded assignment submission', '2025-11-20 13:43:00'),
(3, 1, 'UPDATE', 'system_settings', 8, '{\"value\": \"false\"}', '{\"value\": \"true\"}', '192.168.1.1', NULL, 'Enabled AI features', '2025-11-20 13:43:00'),
(4, 2, 'CREATE', 'assignment', 1, NULL, '{\"title\": \"Assignment 1: Hello World\"}', '192.168.1.50', NULL, 'Created new assignment', '2025-11-20 13:43:00'),
(5, 1, 'DELETE', 'user', 99, '{\"email\": \"test@campus.edu\"}', NULL, '192.168.1.1', NULL, 'Deleted test account', '2025-11-20 13:43:00');

-- --------------------------------------------------------

--
-- Table structure for table `badges`
--

CREATE TABLE `badges` (
  `badge_id` int(10) UNSIGNED NOT NULL,
  `badge_name` varchar(100) NOT NULL,
  `badge_description` text DEFAULT NULL,
  `badge_icon_url` varchar(500) DEFAULT NULL,
  `badge_category` enum('achievement','milestone','special','course') DEFAULT 'achievement',
  `rarity` enum('common','rare','epic','legendary') DEFAULT 'common',
  `points_reward` int(11) DEFAULT 0,
  `criteria` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `badges`
--

INSERT INTO `badges` (`badge_id`, `badge_name`, `badge_description`, `badge_icon_url`, `badge_category`, `rarity`, `points_reward`, `criteria`, `is_active`, `created_at`) VALUES
(1, 'First Steps', 'Complete your first assignment', NULL, 'achievement', 'common', 10, NULL, 1, '2025-11-20 13:43:00'),
(2, 'Quiz Master', 'Score 100% on a quiz', NULL, 'achievement', 'rare', 50, NULL, 1, '2025-11-20 13:43:00'),
(3, 'Perfect Attendance', 'Attend all classes in a week', NULL, 'milestone', 'rare', 25, NULL, 1, '2025-11-20 13:43:00'),
(4, 'Early Bird', 'Submit 5 assignments early', NULL, 'achievement', 'epic', 100, NULL, 1, '2025-11-20 13:43:00'),
(5, 'Helpful Peer', 'Complete 10 peer reviews', NULL, 'achievement', 'rare', 50, NULL, 1, '2025-11-20 13:43:00'),
(6, 'Level 5', 'Reach level 5', NULL, 'milestone', 'epic', 75, NULL, 1, '2025-11-20 13:43:00'),
(7, 'Overachiever', 'Score above 95% average', NULL, 'achievement', 'legendary', 200, NULL, 1, '2025-11-20 13:43:00'),
(8, 'Consistent Learner', 'Maintain 30-day streak', NULL, 'milestone', 'epic', 150, NULL, 1, '2025-11-20 13:43:00');

-- --------------------------------------------------------

--
-- Table structure for table `branding_settings`
--

CREATE TABLE `branding_settings` (
  `branding_id` bigint(20) UNSIGNED NOT NULL,
  `campus_id` bigint(20) UNSIGNED NOT NULL,
  `logo_url` varchar(500) DEFAULT NULL,
  `favicon_url` varchar(500) DEFAULT NULL,
  `primary_color` varchar(7) DEFAULT '#007bff',
  `secondary_color` varchar(7) DEFAULT '#6c757d',
  `custom_css` text DEFAULT NULL,
  `email_header_html` text DEFAULT NULL,
  `email_footer_html` text DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `branding_settings`
--

INSERT INTO `branding_settings` (`branding_id`, `campus_id`, `logo_url`, `favicon_url`, `primary_color`, `secondary_color`, `custom_css`, `email_header_html`, `email_footer_html`, `updated_at`) VALUES
(1, 1, '/assets/logos/main_campus_logo.png', '/assets/favicons/main_campus.ico', '#007bff', '#6c757d', NULL, NULL, NULL, '2025-11-20 13:43:00'),
(2, 2, '/assets/logos/downtown_campus_logo.png', '/assets/favicons/downtown_campus.ico', '#28a745', '#6c757d', NULL, NULL, NULL, '2025-11-20 13:43:00'),
(3, 3, '/assets/logos/online_campus_logo.png', '/assets/favicons/online_campus.ico', '#17a2b8', '#6c757d', NULL, NULL, NULL, '2025-11-20 13:43:00');

-- --------------------------------------------------------

--
-- Table structure for table `calendar_events`
--

CREATE TABLE `calendar_events` (
  `event_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `course_id` bigint(20) UNSIGNED DEFAULT NULL,
  `event_type` enum('lecture','lab','exam','assignment','quiz','meeting','custom') NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `location` varchar(255) DEFAULT NULL,
  `color` varchar(7) DEFAULT NULL,
  `start_time` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `end_time` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `schedule_id` bigint(20) UNSIGNED DEFAULT NULL,
  `exam_id` bigint(20) UNSIGNED DEFAULT NULL,
  `is_recurring` tinyint(1) DEFAULT 0,
  `recurrence_pattern` varchar(100) DEFAULT NULL,
  `reminder_minutes` int(11) DEFAULT 30,
  `status` enum('scheduled','completed','cancelled') DEFAULT 'scheduled',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `calendar_integrations`
--

CREATE TABLE `calendar_integrations` (
  `integration_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `calendar_type` enum('google','outlook','ical') DEFAULT NULL,
  `access_token_encrypted` varchar(500) DEFAULT NULL,
  `refresh_token_encrypted` varchar(500) DEFAULT NULL,
  `last_sync` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `sync_status` enum('active','error','disabled') DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `calendar_integrations`
--

INSERT INTO `calendar_integrations` (`integration_id`, `user_id`, `calendar_type`, `access_token_encrypted`, `refresh_token_encrypted`, `last_sync`, `sync_status`, `created_at`, `updated_at`) VALUES
(1, 7, 'google', NULL, NULL, '2025-02-15 04:00:00', 'active', '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(2, 8, 'outlook', NULL, NULL, '2025-02-15 04:15:00', 'active', '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(3, 9, 'google', NULL, NULL, '2025-02-14 16:30:00', 'error', '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(4, 10, 'ical', NULL, NULL, '2025-02-15 04:30:00', 'active', '2025-11-20 13:43:00', '2025-11-20 13:43:00');

-- --------------------------------------------------------

--
-- Table structure for table `campuses`
--

CREATE TABLE `campuses` (
  `campus_id` bigint(20) UNSIGNED NOT NULL,
  `campus_name` varchar(200) NOT NULL,
  `campus_code` varchar(20) NOT NULL,
  `address` text DEFAULT NULL,
  `city` varchar(100) DEFAULT NULL,
  `country` varchar(100) DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `timezone` varchar(50) DEFAULT 'UTC',
  `status` enum('active','inactive') DEFAULT 'active',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `campuses`
--

INSERT INTO `campuses` (`campus_id`, `campus_name`, `campus_code`, `address`, `city`, `country`, `phone`, `email`, `timezone`, `status`, `created_at`, `updated_at`) VALUES
(1, 'Updated Campus Name', 'MC001', '123 University Ave', 'New York', 'USA', '+1-555-0100', 'info@maincampus.edu', 'America/New_York', 'active', '2025-11-20 13:42:59', '2026-03-02 23:28:34'),
(2, 'Downtown Campus', 'DC002', '456 Downtown St', 'Los Angeles', 'USA', '+1-555-0200', 'info@downtown.edu', 'America/Los_Angeles', 'active', '2025-11-20 13:42:59', '2025-11-20 13:42:59'),
(3, 'Online Campus', 'OC003', '789 Virtual Plaza', 'Chicago', 'USA', '+1-555-0300', 'info@online.edu', 'America/Chicago', 'active', '2025-11-20 13:42:59', '2025-11-20 13:42:59'),
(4, 'Main Campus Updated', 'MAIN2', '456 University Ave', 'Boston', 'USA', '+1-555-0456', 'main2@university.edu', 'America/Boston', 'inactive', '2025-11-26 18:16:28', '2025-11-26 18:22:21'),
(14, 'Test Campus Z', 'TCZ', '123 St', 'NYC', 'US', '555-1234', NULL, 'UTC', 'active', '2026-03-02 13:29:51', '2026-03-02 13:29:51'),
(15, 'AutoTest', 'AT1', NULL, NULL, NULL, NULL, NULL, 'UTC', 'active', '2026-03-02 13:49:12', '2026-03-02 13:49:12'),
(16, 'Test Campus', 'TC01', '123 Test St', 'Cairo', 'Egypt', '+20 123 456 7890', 'campus@test.com', 'Africa/Cairo', 'active', '2026-03-02 23:28:34', '2026-03-02 23:28:34');

-- --------------------------------------------------------

--
-- Table structure for table `certificates`
--

CREATE TABLE `certificates` (
  `certificate_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `course_id` bigint(20) UNSIGNED NOT NULL,
  `certificate_number` varchar(100) DEFAULT NULL,
  `certificate_type` enum('completion','excellence','participation') DEFAULT NULL,
  `issue_date` date DEFAULT NULL,
  `expiry_date` date DEFAULT NULL,
  `file_id` bigint(20) UNSIGNED DEFAULT NULL,
  `verification_hash` varchar(255) DEFAULT NULL,
  `is_verified` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `chatbot_conversations`
--

CREATE TABLE `chatbot_conversations` (
  `conversation_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `course_id` bigint(20) UNSIGNED DEFAULT NULL,
  `conversation_title` varchar(255) DEFAULT NULL,
  `context_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `status` enum('active','archived','deleted') DEFAULT 'active',
  `started_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `last_message_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `chatbot_conversations`
--

INSERT INTO `chatbot_conversations` (`conversation_id`, `user_id`, `course_id`, `conversation_title`, `context_data`, `status`, `started_at`, `last_message_at`) VALUES
(1, 7, NULL, 'Help with Assignment 1', NULL, 'active', '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(2, 8, NULL, 'Python Syntax Questions', NULL, 'active', '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(3, 9, 2, 'Data Structures Explanation', NULL, 'archived', '2025-11-20 13:43:00', '2025-11-20 13:43:00');

-- --------------------------------------------------------

--
-- Table structure for table `chatbot_messages`
--

CREATE TABLE `chatbot_messages` (
  `message_id` bigint(20) UNSIGNED NOT NULL,
  `conversation_id` bigint(20) UNSIGNED NOT NULL,
  `sender_type` enum('user','bot') NOT NULL,
  `message_text` text NOT NULL,
  `message_metadata` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `intent` varchar(100) DEFAULT NULL,
  `confidence_score` decimal(3,2) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `chatbot_messages`
--

INSERT INTO `chatbot_messages` (`message_id`, `conversation_id`, `sender_type`, `message_text`, `message_metadata`, `intent`, `confidence_score`, `created_at`) VALUES
(1, 1, 'user', 'How do I start Assignment 1?', NULL, 'help_request', 0.95, '2025-11-20 13:43:00'),
(2, 1, 'bot', 'To start Assignment 1, first review the assignment instructions in the course materials. You need to create a Python program that prints \"Hello World\". Would you like help with setting up your Python environment?', NULL, 'help_response', NULL, '2025-11-20 13:43:00'),
(3, 1, 'user', 'Yes, how do I install Python?', NULL, 'help_request', 0.92, '2025-11-20 13:43:00'),
(4, 1, 'bot', 'Here are the steps to install Python: 1) Visit python.org, 2) Download Python 3.11 or later, 3) Run the installer, 4) Check \"Add Python to PATH\", 5) Verify installation by opening terminal and typing \"python --version\".', NULL, 'help_response', NULL, '2025-11-20 13:43:00'),
(5, 2, 'user', 'What is the difference between a list and a tuple?', NULL, 'concept_question', 0.89, '2025-11-20 13:43:00'),
(6, 2, 'bot', 'Great question! Lists are mutable (can be modified) and use square brackets [], while tuples are immutable (cannot be modified) and use parentheses (). Lists: [1,2,3], Tuples: (1,2,3)', NULL, 'explanation', NULL, '2025-11-20 13:43:00');

-- --------------------------------------------------------

--
-- Table structure for table `chat_messages`
--

CREATE TABLE `chat_messages` (
  `message_id` bigint(20) UNSIGNED NOT NULL,
  `thread_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `message_text` text NOT NULL,
  `parent_message_id` bigint(20) UNSIGNED DEFAULT NULL,
  `is_answer` tinyint(1) DEFAULT 0,
  `is_endorsed` tinyint(1) DEFAULT 0,
  `endorsed_by` bigint(20) UNSIGNED DEFAULT NULL,
  `upvote_count` int(11) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `chat_messages`
--

INSERT INTO `chat_messages` (`message_id`, `thread_id`, `user_id`, `message_text`, `parent_message_id`, `is_answer`, `is_endorsed`, `endorsed_by`, `upvote_count`, `created_at`, `updated_at`) VALUES
(6, 3, 13, 'Here is a great YouTube playlist for data structures: [link]', NULL, 0, 0, NULL, 7, '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(9, 5, 58, 'I have uploaded the lecture slides to the course files. Check Chapter 5 section for detailed notes.', NULL, 0, 0, NULL, 0, '2026-03-03 18:24:42', '2026-03-03 18:24:42'),
(10, 5, 57, 'Thank you professor! I found the slides very helpful.', 9, 0, 0, NULL, 0, '2026-03-03 18:24:43', '2026-03-03 18:24:43'),
(11, 6, 58, 'Great initiative! Focus on the key theorems from Chapter 7 as they carry the most weight.', NULL, 1, 1, 58, 0, '2026-03-03 18:26:57', '2026-03-05 19:16:31'),
(12, 6, 57, 'Thanks professor! Will definitely prioritize Chapter 7.', 11, 0, 0, NULL, 0, '2026-03-03 18:26:58', '2026-03-03 18:26:58'),
(13, 6, 58, 'I recommend using an adjacency list for sparse graphs and a matrix for dense ones. BFS is optimal for shortest path.', NULL, 0, 0, NULL, 0, '2026-03-03 18:34:12', '2026-03-03 18:34:12'),
(14, 6, 57, 'Would a priority queue help with Dijkstras implementation?', 11, 0, 0, NULL, 0, '2026-03-03 18:34:12', '2026-03-03 18:34:12'),
(15, 6, 60, 'OH', NULL, 0, 0, NULL, 0, '2026-03-10 17:28:42', '2026-03-10 17:28:42');

-- --------------------------------------------------------

--
-- Table structure for table `collaborative_grading`
--

CREATE TABLE `collaborative_grading` (
  `collab_id` bigint(20) UNSIGNED NOT NULL,
  `assignment_id` bigint(20) UNSIGNED NOT NULL,
  `submission_id` bigint(20) UNSIGNED NOT NULL,
  `grader_1_id` bigint(20) UNSIGNED NOT NULL,
  `grader_2_id` bigint(20) UNSIGNED DEFAULT NULL,
  `grader_1_score` decimal(5,2) DEFAULT NULL,
  `grader_2_score` decimal(5,2) DEFAULT NULL,
  `final_score` decimal(5,2) DEFAULT NULL,
  `resolution_method` enum('average','higher','manual','grader_1') DEFAULT 'average',
  `status` enum('pending','in_progress','completed','disputed') DEFAULT 'pending',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `completed_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `communities`
--

CREATE TABLE `communities` (
  `community_id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `community_type` enum('global','department') NOT NULL,
  `department_id` bigint(20) UNSIGNED DEFAULT NULL,
  `cover_image_url` varchar(500) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_by` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `communities`
--

INSERT INTO `communities` (`community_id`, `name`, `description`, `community_type`, `department_id`, `cover_image_url`, `is_active`, `created_by`, `created_at`, `updated_at`) VALUES
(1, 'Global Community', 'Platform-wide community for all users', 'global', NULL, NULL, 1, 1, '2026-03-10 18:48:58', '2026-03-10 18:48:58'),
(2, 'Math Cohort 2026', 'Updated: Math department community for the 2026 cohort students', 'department', 2, NULL, 1, 59, '2026-03-10 19:04:02', '2026-03-10 19:05:33'),
(3, 'Mechanical Engineering General', 'ME community', 'department', 5, NULL, 1, 59, '2026-03-10 19:04:27', '2026-03-10 19:04:27');

-- --------------------------------------------------------

--
-- Table structure for table `community_posts`
--

CREATE TABLE `community_posts` (
  `post_id` bigint(20) UNSIGNED NOT NULL,
  `course_id` bigint(20) UNSIGNED DEFAULT NULL,
  `community_id` bigint(20) UNSIGNED DEFAULT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(255) NOT NULL,
  `content` text NOT NULL,
  `post_type` enum('discussion','question','announcement','resource') DEFAULT 'discussion',
  `is_pinned` tinyint(1) DEFAULT 0,
  `is_locked` tinyint(1) DEFAULT 0,
  `view_count` int(11) DEFAULT 0,
  `upvote_count` int(11) DEFAULT 0,
  `reply_count` int(11) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `community_posts`
--

INSERT INTO `community_posts` (`post_id`, `course_id`, `community_id`, `user_id`, `title`, `content`, `post_type`, `is_pinned`, `is_locked`, `view_count`, `upvote_count`, `reply_count`, `created_at`, `updated_at`) VALUES
(3, NULL, 1, 12, 'Study Group for Midterm', 'Anyone interested in forming a study group for the upcoming midterm? We can meet on weekends.', 'discussion', 0, 0, 44, 10, 6, '2025-11-20 13:43:00', '2026-03-10 18:49:07'),
(7, NULL, 1, 58, 'Post 1 Trying to test the posts', 'Post 1 Content', 'announcement', 0, 0, 8, 4, 2, '2026-03-10 17:25:16', '2026-03-10 18:49:07'),
(8, NULL, 1, 57, 'First Tagged Post', 'Testing tags system', 'discussion', 0, 0, 0, 0, 0, '2026-03-10 19:04:01', '2026-03-10 19:04:01'),
(9, NULL, 2, 57, 'Math Study Group', 'Anyone want to study linear algebra?', 'discussion', 0, 0, 0, 0, 0, '2026-03-10 19:04:33', '2026-03-10 19:04:33');

-- --------------------------------------------------------

--
-- Table structure for table `community_post_comments`
--

CREATE TABLE `community_post_comments` (
  `comment_id` bigint(20) UNSIGNED NOT NULL,
  `post_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `comment_text` text NOT NULL,
  `parent_comment_id` bigint(20) UNSIGNED DEFAULT NULL,
  `upvote_count` int(11) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `community_post_comments`
--

INSERT INTO `community_post_comments` (`comment_id`, `post_id`, `user_id`, `comment_text`, `parent_comment_id`, `upvote_count`, `created_at`, `updated_at`) VALUES
(8, 3, 57, 'My comment', NULL, 0, '2026-03-10 17:20:31', '2026-03-10 17:20:31'),
(9, 7, 58, 'Hi guys', NULL, 0, '2026-03-10 17:25:34', '2026-03-10 17:25:34'),
(10, 7, 60, 'Done', NULL, 0, '2026-03-10 17:25:52', '2026-03-10 17:25:52');

-- --------------------------------------------------------

--
-- Table structure for table `community_post_reactions`
--

CREATE TABLE `community_post_reactions` (
  `reaction_id` bigint(20) UNSIGNED NOT NULL,
  `post_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `reaction_type` enum('like','helpful','insightful','thanks') DEFAULT 'like',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `community_post_reactions`
--

INSERT INTO `community_post_reactions` (`reaction_id`, `post_id`, `user_id`, `reaction_type`, `created_at`) VALUES
(15, 3, 57, 'like', '2026-03-10 17:20:23'),
(16, 3, 57, 'helpful', '2026-03-10 17:20:24'),
(17, 7, 58, 'like', '2026-03-10 17:25:21'),
(18, 7, 58, 'insightful', '2026-03-10 17:25:23'),
(19, 7, 58, 'thanks', '2026-03-10 17:25:24'),
(20, 7, 58, 'helpful', '2026-03-10 17:25:25');

-- --------------------------------------------------------

--
-- Table structure for table `community_post_tags`
--

CREATE TABLE `community_post_tags` (
  `post_id` bigint(20) UNSIGNED NOT NULL,
  `tag_id` bigint(20) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `community_post_tags`
--

INSERT INTO `community_post_tags` (`post_id`, `tag_id`) VALUES
(8, 1),
(8, 2),
(9, 3),
(9, 4);

-- --------------------------------------------------------

--
-- Table structure for table `community_tags`
--

CREATE TABLE `community_tags` (
  `tag_id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(50) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `community_tags`
--

INSERT INTO `community_tags` (`tag_id`, `name`, `created_at`) VALUES
(1, 'study-tips', '2026-03-10 19:04:00'),
(2, 'exam-prep', '2026-03-10 19:04:01'),
(3, 'math', '2026-03-10 19:04:33'),
(4, 'study-group', '2026-03-10 19:04:33');

-- --------------------------------------------------------

--
-- Table structure for table `content_translations`
--

CREATE TABLE `content_translations` (
  `translation_id` bigint(20) UNSIGNED NOT NULL,
  `entity_type` enum('course','material','assignment','quiz','announcement','instruction') NOT NULL,
  `entity_id` bigint(20) UNSIGNED NOT NULL,
  `field_name` varchar(100) NOT NULL,
  `language_code` varchar(10) NOT NULL,
  `translated_content` text NOT NULL,
  `translator_type` enum('human','ai','system') DEFAULT 'human',
  `translator_id` bigint(20) UNSIGNED DEFAULT NULL,
  `quality_score` decimal(3,2) DEFAULT NULL,
  `is_verified` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `content_translations`
--

INSERT INTO `content_translations` (`translation_id`, `entity_type`, `entity_id`, `field_name`, `language_code`, `translated_content`, `translator_type`, `translator_id`, `quality_score`, `is_verified`, `created_at`, `updated_at`) VALUES
(1, 'course', 1, 'course_name', 'es', 'Introducci??n a la Programaci??n', 'ai', NULL, 0.95, 1, '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(2, 'course', 1, 'course_description', 'es', 'Conceptos b??sicos de programaci??n usando Python', 'ai', NULL, 0.92, 1, '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(3, 'assignment', 1, 'title', 'es', 'Tarea 1: Hola Mundo', 'ai', NULL, 0.98, 1, '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(4, 'announcement', 1, 'title', 'fr', 'D??but du cours', 'human', NULL, 1.00, 1, '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(5, 'material', 1, 'title', 'ar', '???????? ????????????', 'ai', NULL, 0.88, 0, '2025-11-20 13:43:00', '2025-11-20 13:43:00');

-- --------------------------------------------------------

--
-- Table structure for table `courses`
--

CREATE TABLE `courses` (
  `course_id` bigint(20) UNSIGNED NOT NULL,
  `department_id` bigint(20) UNSIGNED NOT NULL,
  `course_name` varchar(200) NOT NULL,
  `course_code` varchar(20) NOT NULL,
  `course_description` text DEFAULT NULL,
  `credits` int(11) DEFAULT 3,
  `level` enum('freshman','sophomore','junior','senior','graduate') DEFAULT NULL,
  `syllabus_url` varchar(500) DEFAULT NULL,
  `status` enum('active','inactive','archived') DEFAULT 'active',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `courses`
--

INSERT INTO `courses` (`course_id`, `department_id`, `course_name`, `course_code`, `course_description`, `credits`, `level`, `syllabus_url`, `status`, `created_at`, `updated_at`, `deleted_at`) VALUES
(1, 1, 'Updated Course Name', 'CS101', 'Basic programming concepts using Python', 3, 'freshman', NULL, 'active', '2025-11-27 18:18:48', '2026-03-02 23:29:23', NULL),
(2, 1, 'Data Structures', 'CS201', 'Fundamental data structures and algorithms', 3, 'sophomore', 'https://example.com/amir.pdf', 'active', '2025-11-20 13:42:59', '2025-11-29 00:27:15', NULL),
(3, 1, 'Database Systems', 'CS301', 'Database design and SQL', 3, 'junior', NULL, 'active', '2025-11-20 13:42:59', '2025-11-20 13:42:59', NULL),
(4, 1, 'Artificial Intelligence', 'CS401', 'Introduction to AI and machine learning', 4, 'senior', NULL, 'active', '2025-11-20 13:42:59', '2025-11-20 13:42:59', NULL),
(5, 2, 'Calculus I', 'MATH101', 'Differential calculus', 4, 'freshman', NULL, 'active', '2025-11-20 13:42:59', '2025-11-20 13:42:59', NULL),
(6, 2, 'Linear Algebra', 'MATH201', 'Matrices and vector spaces', 3, 'sophomore', NULL, 'active', '2025-11-20 13:42:59', '2025-11-20 13:42:59', NULL),
(7, 3, 'Physics I', 'PHY101', 'Classical mechanics', 4, 'freshman', NULL, 'active', '2025-11-20 13:42:59', '2025-11-20 13:42:59', NULL),
(8, 4, 'Business Management', 'BUS101', 'Introduction to business management', 3, 'freshman', NULL, 'active', '2025-11-20 13:42:59', '2025-11-20 13:42:59', NULL),
(9, 3, 'Principles of Management', 'BUS101', 'Fundamentals of business management and organizational behavior', 3, 'freshman', '/uploads/syllabi/BUS101.pdf', 'active', '2024-09-01 08:00:00', '2024-09-01 08:00:00', NULL),
(10, 3, 'Business Finance', 'BUS202', 'Financial analysis, investment decisions, and capital budgeting', 3, 'sophomore', '/uploads/syllabi/BUS202.pdf', 'active', '2024-09-01 08:00:00', '2024-09-01 08:00:00', NULL),
(11, 4, 'Statistics for Data Science', 'DS101', 'Probability, hypothesis testing, statistical inference', 3, 'freshman', '/uploads/syllabi/DS101.pdf', 'active', '2024-09-01 08:00:00', '2024-09-01 08:00:00', NULL),
(12, 1, 'Introduction to Programming', 'CS1001', 'Basic programming concepts - prerequisite course', 3, 'freshman', NULL, 'active', '2025-11-27 18:02:54', '2025-11-27 18:02:54', NULL),
(13, 5, 'English Literature I', 'AH101', 'Classic works of English literature from Renaissance to 19th century', 3, 'freshman', '/uploads/syllabi/AH101.pdf', 'active', '2024-09-01 08:00:00', '2024-09-01 08:00:00', NULL),
(14, 5, 'Arabic Language Skills', 'AH102', 'Advanced Arabic grammar, writing, and communication', 3, 'freshman', '/uploads/syllabi/AH102.pdf', 'active', '2024-09-01 08:00:00', '2024-09-01 08:00:00', NULL),
(15, 6, 'Calculus I', 'SCI101', 'Differential and integral calculus', 4, 'freshman', '/uploads/syllabi/SCI101.pdf', 'active', '2024-09-01 08:00:00', '2024-09-01 08:00:00', NULL),
(16, 1, 'intro to digital', 'CS2024', 'Study of advanced data structures and algorithm optimization techniques', 4, 'junior', 'https://example.com/syllabus-advanced.pdf', 'inactive', '2025-11-27 18:13:14', '2025-11-27 18:14:45', '2025-11-27 18:14:45'),
(17, 1, 'Electro 4', 'EEE2026', 'Study of advanced electro 4', 2, 'junior', 'https://example.com/syllabus-advanced.pdf', 'active', '2025-11-30 15:49:58', '2025-11-30 15:52:42', '2025-11-30 15:52:42'),
(18, 3, 'Strategic Management', 'BUS401', 'Corporate strategy and competitive analysis', 3, 'senior', '/uploads/syllabi/BUS401.pdf', 'active', '2024-09-01 08:00:00', '2024-09-01 08:00:00', NULL),
(19, 1, 'Test Course Z2', 'TCZ2', 'A test course', 3, 'freshman', NULL, 'active', '2026-03-02 13:31:15', '2026-03-02 13:31:15', NULL),
(20, 1, 'Auto Course', 'AC99', 'Test', 3, 'freshman', NULL, 'active', '2026-03-02 13:50:13', '2026-03-02 13:50:13', NULL),
(21, 1, 'Test Course', 'TC101', 'A test course for postman', 3, 'senior', NULL, 'active', '2026-03-03 18:35:43', '2026-03-03 18:35:43', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `course_analytics`
--

CREATE TABLE `course_analytics` (
  `analytics_id` bigint(20) UNSIGNED NOT NULL,
  `course_id` bigint(20) UNSIGNED NOT NULL,
  `instructor_id` bigint(20) UNSIGNED NOT NULL,
  `total_students` int(11) DEFAULT 0,
  `active_students` int(11) DEFAULT 0,
  `average_grade` decimal(5,2) DEFAULT NULL,
  `average_attendance` decimal(5,2) DEFAULT NULL,
  `completion_rate` decimal(5,2) DEFAULT NULL,
  `engagement_score` decimal(5,2) DEFAULT NULL,
  `calculation_date` date NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `course_analytics`
--

INSERT INTO `course_analytics` (`analytics_id`, `course_id`, `instructor_id`, `total_students`, `active_students`, `average_grade`, `average_attendance`, `completion_rate`, `engagement_score`, `calculation_date`, `created_at`) VALUES
(2, 2, 3, 12, 11, 82.75, 88.50, 72.30, 84.10, '2025-02-15', '2025-11-20 13:43:01'),
(3, 3, 3, 10, 10, 87.20, 95.00, 85.40, 91.30, '2025-02-15', '2025-11-20 13:43:01');

-- --------------------------------------------------------

--
-- Table structure for table `course_chat_threads`
--

CREATE TABLE `course_chat_threads` (
  `thread_id` bigint(20) UNSIGNED NOT NULL,
  `course_id` bigint(20) UNSIGNED NOT NULL,
  `created_by` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `status` enum('open','answered','closed') DEFAULT 'open',
  `is_pinned` tinyint(1) DEFAULT 0,
  `is_locked` tinyint(1) DEFAULT 0,
  `view_count` int(11) DEFAULT 0,
  `reply_count` int(11) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `course_chat_threads`
--

INSERT INTO `course_chat_threads` (`thread_id`, `course_id`, `created_by`, `title`, `description`, `status`, `is_pinned`, `is_locked`, `view_count`, `reply_count`, `created_at`, `updated_at`) VALUES
(3, 2, 12, 'Data Structures Study Tips', 'Share study resources and tips', 'open', 0, 0, 57, 15, '2025-11-20 13:43:00', '2026-03-10 17:28:50'),
(5, 1, 57, 'Help with Midterm Review - Chapter 5', 'Can anyone share their notes on Chapter 5? I missed the lecture and need help understanding the key concepts.', 'open', 0, 0, 2, 2, '2026-03-03 18:24:20', '2026-03-10 17:28:48'),
(6, 1, 57, 'Tips for Final Project - Data Structures & Algorithms', 'Updated: Including both data structures and algorithm choices for the graph module.', 'open', 1, 0, 6, 5, '2026-03-03 18:26:52', '2026-03-10 17:28:47'),
(8, 1, 57, 'Tips for Final Project - Data Structures', 'What data structures would you recommend for implementing the graph traversal module?', 'open', 0, 0, 0, 0, '2026-03-03 18:34:11', '2026-03-03 18:34:11'),
(10, 1, 57, 'Temporary Thread - Delete Test', 'This thread can be safely deleted for testing purposes.', 'open', 0, 0, 3, 0, '2026-03-03 18:43:55', '2026-03-03 18:44:57'),
(11, 1, 57, 'Tips for Final Project - Data Structures', 'What data structures would you recommend for implementing the graph traversal module?', 'open', 0, 0, 1, 0, '2026-03-05 19:16:30', '2026-03-10 17:28:46');

-- --------------------------------------------------------

--
-- Table structure for table `course_enrollments`
--

CREATE TABLE `course_enrollments` (
  `enrollment_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `section_id` bigint(20) UNSIGNED NOT NULL,
  `program_id` bigint(20) UNSIGNED DEFAULT NULL,
  `enrollment_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `enrollment_status` enum('enrolled','dropped','completed','withdrawn') DEFAULT 'enrolled',
  `grade` varchar(5) DEFAULT NULL,
  `final_score` decimal(5,2) DEFAULT NULL,
  `dropped_at` timestamp NULL DEFAULT NULL,
  `completed_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `course_enrollments`
--

INSERT INTO `course_enrollments` (`enrollment_id`, `user_id`, `section_id`, `program_id`, `enrollment_date`, `enrollment_status`, `grade`, `final_score`, `dropped_at`, `completed_at`, `updated_at`) VALUES
(62, 7, 1, 1, '2025-09-01 07:00:00', 'enrolled', NULL, NULL, NULL, NULL, '2025-11-30 16:28:28'),
(63, 8, 1, 1, '2025-09-01 07:15:00', 'enrolled', NULL, NULL, NULL, NULL, '2025-11-30 16:28:28'),
(64, 9, 1, 1, '2025-09-01 07:30:00', 'enrolled', NULL, NULL, NULL, NULL, '2025-11-30 16:28:28'),
(65, 10, 1, 1, '2025-09-01 08:00:00', 'enrolled', NULL, NULL, NULL, NULL, '2025-11-30 16:28:28'),
(66, 11, 1, 1, '2025-09-01 08:15:00', 'enrolled', NULL, NULL, NULL, NULL, '2025-11-30 16:28:28'),
(67, 25, 1, 1, '2025-09-01 11:00:00', 'enrolled', NULL, NULL, NULL, NULL, '2025-11-30 16:28:28'),
(68, 30, 1, 1, '2025-09-01 11:30:00', 'enrolled', NULL, NULL, NULL, NULL, '2025-11-30 16:28:28'),
(69, 34, 1, 1, '2025-11-12 13:00:00', 'dropped', NULL, NULL, '2025-11-30 16:39:49', NULL, '2025-11-30 16:39:48'),
(70, 12, 9, 1, '2025-09-01 07:45:00', 'enrolled', NULL, NULL, NULL, NULL, '2025-11-30 16:28:28'),
(71, 13, 9, 1, '2025-09-01 08:00:00', 'enrolled', NULL, NULL, NULL, NULL, '2025-11-30 16:28:28'),
(72, 14, 9, 1, '2025-09-01 08:15:00', 'enrolled', NULL, NULL, NULL, NULL, '2025-11-30 16:28:28'),
(73, 15, 9, 1, '2025-09-01 08:30:00', 'enrolled', NULL, NULL, NULL, NULL, '2025-11-30 16:28:28'),
(74, 16, 9, 1, '2025-09-01 08:45:00', 'enrolled', NULL, NULL, NULL, NULL, '2025-11-30 16:28:28'),
(75, 9, 10, 1, '2025-09-01 07:30:00', 'enrolled', NULL, NULL, NULL, NULL, '2025-11-30 16:28:28'),
(76, 10, 10, 1, '2025-09-01 08:00:00', 'enrolled', NULL, NULL, NULL, NULL, '2025-11-30 16:28:28'),
(77, 11, 10, 1, '2025-09-01 08:15:00', 'enrolled', NULL, NULL, NULL, NULL, '2025-11-30 16:28:28'),
(78, 12, 10, 1, '2025-09-01 07:45:00', 'enrolled', NULL, NULL, NULL, NULL, '2025-11-30 16:28:28'),
(79, 16, 10, 1, '2025-09-01 09:00:00', 'enrolled', NULL, NULL, NULL, NULL, '2025-11-30 16:28:28'),
(80, 25, 10, 1, '2025-09-01 11:00:00', 'enrolled', NULL, NULL, NULL, NULL, '2025-11-30 16:28:28'),
(81, 30, 10, 1, '2025-09-01 11:30:00', 'enrolled', NULL, NULL, NULL, NULL, '2025-11-30 16:28:28'),
(82, 13, 1, 1, '2025-09-01 08:00:00', 'dropped', NULL, NULL, '2025-09-15 13:00:00', NULL, '2025-11-30 16:28:28'),
(83, 14, 1, 1, '2025-09-01 08:15:00', 'dropped', NULL, NULL, '2025-09-20 11:00:00', NULL, '2025-11-30 16:28:28'),
(84, 15, 1, 1, '2025-09-01 08:30:00', 'withdrawn', NULL, NULL, NULL, NULL, '2025-11-30 16:28:28'),
(85, 16, 1, 1, '2025-09-01 09:00:00', 'withdrawn', NULL, NULL, NULL, NULL, '2025-11-30 16:28:28'),
(86, 7, 10, 1, '2025-09-01 07:00:00', 'enrolled', NULL, NULL, NULL, NULL, '2025-11-30 16:28:28'),
(87, 8, 10, 1, '2025-09-01 07:15:00', 'enrolled', NULL, NULL, NULL, NULL, '2025-11-30 16:28:28'),
(88, 34, 9, 1, '2025-09-01 12:00:00', 'enrolled', NULL, NULL, NULL, NULL, '2025-11-30 16:28:28'),
(185, 21, 1, 1, '2026-03-01 14:55:40', 'enrolled', NULL, NULL, NULL, NULL, '2026-03-01 14:55:40'),
(186, 22, 1, 1, '2026-03-01 14:55:40', 'enrolled', NULL, NULL, NULL, NULL, '2026-03-01 14:55:40'),
(187, 23, 1, 1, '2026-03-01 14:55:40', 'enrolled', NULL, NULL, NULL, NULL, '2026-03-01 14:55:40'),
(188, 24, 1, 1, '2026-03-01 14:55:40', 'enrolled', NULL, NULL, NULL, NULL, '2026-03-01 14:55:40'),
(189, 26, 1, 1, '2026-03-01 14:55:40', 'enrolled', NULL, NULL, NULL, NULL, '2026-03-01 14:55:40'),
(190, 27, 1, 1, '2026-03-01 14:55:40', 'enrolled', NULL, NULL, NULL, NULL, '2026-03-01 14:55:40'),
(191, 28, 1, 1, '2026-03-01 14:55:40', 'enrolled', NULL, NULL, NULL, NULL, '2026-03-01 14:55:40'),
(192, 29, 1, 1, '2026-03-01 14:55:40', 'enrolled', NULL, NULL, NULL, NULL, '2026-03-01 14:55:40'),
(193, 31, 2, 1, '2026-03-01 14:55:40', 'enrolled', NULL, NULL, NULL, NULL, '2026-03-01 14:55:40'),
(194, 32, 2, 1, '2026-03-01 14:55:40', 'enrolled', NULL, NULL, NULL, NULL, '2026-03-01 14:55:40'),
(195, 33, 2, 1, '2026-03-01 14:55:40', 'enrolled', NULL, NULL, NULL, NULL, '2026-03-01 14:55:40'),
(196, 34, 2, 1, '2026-03-01 14:55:40', 'enrolled', NULL, NULL, NULL, NULL, '2026-03-01 14:55:40'),
(197, 35, 2, 1, '2026-03-01 14:55:40', 'enrolled', NULL, NULL, NULL, NULL, '2026-03-01 14:55:40'),
(198, 36, 2, 1, '2026-03-01 14:55:40', 'enrolled', NULL, NULL, NULL, NULL, '2026-03-01 14:55:40'),
(199, 37, 2, 1, '2026-03-01 14:55:40', 'enrolled', NULL, NULL, NULL, NULL, '2026-03-01 14:55:40'),
(200, 38, 2, 1, '2026-03-01 14:55:40', 'enrolled', NULL, NULL, NULL, NULL, '2026-03-01 14:55:40'),
(201, 39, 2, 1, '2026-03-01 14:55:40', 'enrolled', NULL, NULL, NULL, NULL, '2026-03-01 14:55:40'),
(202, 40, 2, 1, '2026-03-01 14:55:40', 'enrolled', NULL, NULL, NULL, NULL, '2026-03-01 14:55:40'),
(203, 21, 3, 1, '2026-03-01 14:55:40', 'enrolled', NULL, NULL, NULL, NULL, '2026-03-01 14:55:40'),
(204, 23, 3, 1, '2026-03-01 14:55:40', 'enrolled', NULL, NULL, NULL, NULL, '2026-03-01 14:55:40'),
(205, 25, 3, 1, '2026-03-01 14:55:40', 'enrolled', NULL, NULL, NULL, NULL, '2026-03-01 14:55:40'),
(206, 27, 3, 1, '2026-03-01 14:55:40', 'enrolled', NULL, NULL, NULL, NULL, '2026-03-01 14:55:40'),
(207, 29, 3, 1, '2026-03-01 14:55:40', 'enrolled', NULL, NULL, NULL, NULL, '2026-03-01 14:55:40'),
(208, 32, 3, 1, '2026-03-01 14:55:40', 'enrolled', NULL, NULL, NULL, NULL, '2026-03-01 14:55:40'),
(209, 34, 3, 1, '2026-03-01 14:55:40', 'enrolled', NULL, NULL, NULL, NULL, '2026-03-01 14:55:40'),
(210, 36, 3, 1, '2026-03-01 14:55:40', 'enrolled', NULL, NULL, NULL, NULL, '2026-03-01 14:55:40'),
(211, 38, 3, 1, '2026-03-01 14:55:40', 'enrolled', NULL, NULL, NULL, NULL, '2026-03-01 14:55:40'),
(212, 40, 3, 1, '2026-03-01 14:55:40', 'enrolled', NULL, NULL, NULL, NULL, '2026-03-01 14:55:40'),
(213, 22, 4, 1, '2026-03-01 14:55:40', 'enrolled', NULL, NULL, NULL, NULL, '2026-03-01 14:55:40'),
(214, 24, 4, 1, '2026-03-01 14:55:40', 'enrolled', NULL, NULL, NULL, NULL, '2026-03-01 14:55:40'),
(215, 26, 4, 1, '2026-03-01 14:55:40', 'enrolled', NULL, NULL, NULL, NULL, '2026-03-01 14:55:40'),
(216, 28, 4, 1, '2026-03-01 14:55:40', 'enrolled', NULL, NULL, NULL, NULL, '2026-03-01 14:55:40'),
(217, 30, 4, 1, '2026-03-01 14:55:40', 'enrolled', NULL, NULL, NULL, NULL, '2026-03-01 14:55:40'),
(218, 31, 4, 1, '2026-03-01 14:55:40', 'enrolled', NULL, NULL, NULL, NULL, '2026-03-01 14:55:40'),
(219, 33, 4, 1, '2026-03-01 14:55:40', 'enrolled', NULL, NULL, NULL, NULL, '2026-03-01 14:55:40'),
(220, 35, 4, 1, '2026-03-01 14:55:40', 'enrolled', NULL, NULL, NULL, NULL, '2026-03-01 14:55:40'),
(221, 37, 4, 1, '2026-03-01 14:55:40', 'enrolled', NULL, NULL, NULL, NULL, '2026-03-01 14:55:40'),
(222, 39, 4, 1, '2026-03-01 14:55:40', 'enrolled', NULL, NULL, NULL, NULL, '2026-03-01 14:55:40'),
(223, 21, 5, 1, '2026-03-01 14:55:40', 'enrolled', NULL, NULL, NULL, NULL, '2026-03-01 14:55:40'),
(224, 23, 5, 1, '2026-03-01 14:55:40', 'enrolled', NULL, NULL, NULL, NULL, '2026-03-01 14:55:40'),
(225, 25, 5, 1, '2026-03-01 14:55:40', 'enrolled', NULL, NULL, NULL, NULL, '2026-03-01 14:55:40'),
(226, 27, 5, 1, '2026-03-01 14:55:40', 'enrolled', NULL, NULL, NULL, NULL, '2026-03-01 14:55:40'),
(227, 29, 5, 1, '2026-03-01 14:55:40', 'enrolled', NULL, NULL, NULL, NULL, '2026-03-01 14:55:40'),
(228, 32, 5, 1, '2026-03-01 14:55:40', 'enrolled', NULL, NULL, NULL, NULL, '2026-03-01 14:55:40'),
(229, 34, 5, 1, '2026-03-01 14:55:40', 'enrolled', NULL, NULL, NULL, NULL, '2026-03-01 14:55:40'),
(230, 36, 5, 1, '2026-03-01 14:55:40', 'enrolled', NULL, NULL, NULL, NULL, '2026-03-01 14:55:40'),
(231, 57, 7, NULL, '2026-03-04 14:13:13', 'enrolled', NULL, NULL, NULL, NULL, '2026-03-04 14:13:13'),
(232, 57, 8, NULL, '2026-03-04 14:13:22', 'enrolled', NULL, NULL, NULL, NULL, '2026-03-04 14:13:22');

-- --------------------------------------------------------

--
-- Table structure for table `course_instructors`
--

CREATE TABLE `course_instructors` (
  `assignment_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `section_id` bigint(20) UNSIGNED NOT NULL,
  `role` enum('primary','co_instructor','guest') DEFAULT 'primary',
  `assigned_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `course_instructors`
--

INSERT INTO `course_instructors` (`assignment_id`, `user_id`, `section_id`, `role`, `assigned_at`) VALUES
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

-- --------------------------------------------------------

--
-- Table structure for table `course_materials`
--

CREATE TABLE `course_materials` (
  `material_id` bigint(20) UNSIGNED NOT NULL,
  `course_id` bigint(20) UNSIGNED NOT NULL,
  `file_id` bigint(20) UNSIGNED DEFAULT NULL,
  `material_type` enum('lecture','slide','video','reading','link','document') DEFAULT 'document',
  `title` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `external_url` varchar(500) DEFAULT NULL,
  `order_index` int(11) DEFAULT 0,
  `uploaded_by` bigint(20) UNSIGNED NOT NULL,
  `is_published` tinyint(1) DEFAULT 1,
  `published_at` timestamp NULL DEFAULT NULL,
  `view_count` int(11) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `course_materials`
--

INSERT INTO `course_materials` (`material_id`, `course_id`, `file_id`, `material_type`, `title`, `description`, `external_url`, `order_index`, `uploaded_by`, `is_published`, `published_at`, `view_count`, `created_at`, `updated_at`) VALUES
(4, 2, 4, 'document', 'Course Syllabus', 'CS201 Spring 2025 Syllabus', NULL, 1, 3, 1, NULL, 0, '2025-11-20 13:42:59', '2025-11-20 13:42:59');

-- --------------------------------------------------------

--
-- Table structure for table `course_prerequisites`
--

CREATE TABLE `course_prerequisites` (
  `prerequisite_id` bigint(20) UNSIGNED NOT NULL,
  `course_id` bigint(20) UNSIGNED NOT NULL,
  `prerequisite_course_id` bigint(20) UNSIGNED NOT NULL,
  `is_mandatory` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `course_prerequisites`
--

INSERT INTO `course_prerequisites` (`prerequisite_id`, `course_id`, `prerequisite_course_id`, `is_mandatory`, `created_at`) VALUES
(1, 2, 1, 1, '2024-09-01 08:00:00'),
(2, 3, 2, 1, '2025-11-20 13:42:59'),
(3, 4, 2, 1, '2025-11-20 13:42:59'),
(4, 6, 5, 1, '2025-11-20 13:42:59'),
(5, 8, 5, 1, '2025-11-27 17:54:45'),
(6, 1, 5, 1, '2025-11-27 18:22:51'),
(7, 1, 4, 1, '2025-11-30 15:56:30'),
(8, 3, 1, 1, '2026-03-02 23:29:24');

-- --------------------------------------------------------

--
-- Table structure for table `course_schedules`
--

CREATE TABLE `course_schedules` (
  `schedule_id` bigint(20) UNSIGNED NOT NULL,
  `section_id` bigint(20) UNSIGNED NOT NULL,
  `day_of_week` enum('monday','tuesday','wednesday','thursday','friday','saturday','sunday') DEFAULT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  `room` varchar(50) DEFAULT NULL,
  `building` varchar(100) DEFAULT NULL,
  `schedule_type` enum('lecture','lab','tutorial','exam') DEFAULT 'lecture',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `course_schedules`
--

INSERT INTO `course_schedules` (`schedule_id`, `section_id`, `day_of_week`, `start_time`, `end_time`, `room`, `building`, `schedule_type`, `created_at`) VALUES
(1, 1, 'monday', '09:00:00', '10:30:00', '101', 'Building A', 'lecture', '2024-12-15 10:00:00'),
(2, 1, 'wednesday', '09:00:00', '10:30:00', '101', 'Building A', 'lecture', '2024-12-15 10:00:00'),
(3, 2, 'tuesday', '11:00:00', '12:30:00', '102', 'Building A', 'lecture', '2024-12-15 10:00:00'),
(4, 2, 'thursday', '11:00:00', '12:30:00', '102', 'Building A', 'lecture', '2024-12-15 10:00:00'),
(5, 3, 'monday', '13:00:00', '14:30:00', '201', 'Building B', 'lab', '2024-12-15 10:00:00'),
(6, 3, 'wednesday', '13:00:00', '14:30:00', '201', 'Building B', 'lab', '2024-12-15 10:00:00'),
(7, 4, 'tuesday', '14:00:00', '15:30:00', '202', 'Building B', 'tutorial', '2024-12-15 10:00:00'),
(8, 4, 'thursday', '14:00:00', '15:30:00', '202', 'Building B', 'tutorial', '2024-12-15 10:00:00'),
(9, 5, 'monday', '15:00:00', '16:30:00', '301', 'Lab Building', 'exam', '2024-12-15 10:00:00'),
(10, 9, 'tuesday', '14:00:00', '15:30:00', '320', 'Building C', 'lecture', '2025-11-27 18:28:26'),
(11, 1, 'monday', '14:00:00', '15:30:00', '355', 'Building C', 'lecture', '2025-11-27 18:30:21'),
(12, 2, 'monday', '09:00:00', '10:30:00', '101', 'Building A', 'lecture', '2026-03-01 21:05:48'),
(13, 1, 'monday', '11:00:00', '12:30:00', '102', 'Main', 'lecture', '2026-03-02 13:31:16'),
(14, 1, 'tuesday', '14:00:00', '15:30:00', '201', NULL, 'lecture', '2026-03-02 13:50:19');

-- --------------------------------------------------------

--
-- Table structure for table `course_sections`
--

CREATE TABLE `course_sections` (
  `section_id` bigint(20) UNSIGNED NOT NULL,
  `course_id` bigint(20) UNSIGNED NOT NULL,
  `semester_id` bigint(20) UNSIGNED NOT NULL,
  `section_number` varchar(10) NOT NULL,
  `max_capacity` int(11) DEFAULT 50,
  `current_enrollment` int(11) DEFAULT 0,
  `location` varchar(100) DEFAULT NULL,
  `status` enum('open','closed','full','cancelled') DEFAULT 'open',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `course_sections`
--

INSERT INTO `course_sections` (`section_id`, `course_id`, `semester_id`, `section_number`, `max_capacity`, `current_enrollment`, `location`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 4, '01', 40, 7, 'Building A, Room 101', 'open', '2025-11-27 18:20:49', '2025-11-30 16:39:48'),
(2, 1, 2, '02', 50, 48, 'Room 102B', 'full', '2024-12-15 10:00:00', '2025-02-15 09:30:00'),
(3, 2, 2, '01', 40, 35, 'Room 201A', 'open', '2024-12-15 10:00:00', '2025-02-15 09:30:00'),
(4, 2, 2, '02', 40, 38, 'Room 202B', 'open', '2024-12-15 10:00:00', '2025-02-15 09:30:00'),
(5, 3, 2, '01', 45, 40, 'Lab 301', 'open', '2024-12-15 10:00:00', '2025-02-15 09:30:00'),
(6, 4, 2, '01', 35, 32, 'Room 401A', 'open', '2024-12-15 10:00:00', '2025-02-15 09:30:00'),
(7, 5, 2, '01', 40, 39, 'Room 501A', 'open', '2024-12-15 10:00:00', '2026-03-04 14:13:13'),
(8, 9, 2, '01', 50, 46, 'Room 601A', 'open', '2024-12-15 10:00:00', '2026-03-04 14:13:22'),
(9, 2, 3, '2', 50, 6, 'Building C, Room 320', 'open', '2025-11-27 18:25:02', '2025-11-30 16:13:44'),
(10, 1, 3, '2', 45, 9, 'Building B, Room 215', 'open', '2025-11-30 16:00:35', '2025-11-30 16:13:44'),
(11, 1, 1, '1', 35, 0, 'Room B202', 'open', '2026-03-02 13:30:09', '2026-03-05 19:16:22'),
(12, 1, 1, '2', 30, 0, NULL, 'open', '2026-03-02 13:50:17', '2026-03-02 13:50:17'),
(13, 1, 1, '3', 30, 0, 'Room A101', 'open', '2026-03-02 23:30:18', '2026-03-02 23:30:18'),
(14, 1, 1, '4', 30, 0, 'Room A101', 'open', '2026-03-02 23:51:54', '2026-03-02 23:51:54'),
(15, 1, 1, '5', 30, 0, 'Room A101', 'open', '2026-03-03 00:23:16', '2026-03-03 00:23:16'),
(16, 1, 1, '6', 30, 0, 'Room A101', 'open', '2026-03-03 18:34:00', '2026-03-03 18:34:00'),
(17, 1, 1, '7', 30, 0, 'Room A101', 'open', '2026-03-05 19:16:21', '2026-03-05 19:16:21');

-- --------------------------------------------------------

--
-- Table structure for table `course_tas`
--

CREATE TABLE `course_tas` (
  `assignment_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `section_id` bigint(20) UNSIGNED NOT NULL,
  `responsibilities` text DEFAULT NULL,
  `assigned_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `course_tas`
--

INSERT INTO `course_tas` (`assignment_id`, `user_id`, `section_id`, `responsibilities`, `assigned_at`) VALUES
(1, 18, 1, 'Grading assignments and leading lab sessions', '2024-12-15 10:00:00'),
(2, 19, 2, 'Grading assignments and holding office hours', '2024-12-15 10:00:00'),
(3, 18, 3, 'Grading assignments and leading lab sessions', '2024-12-15 10:00:00'),
(4, 20, 4, 'Grading assignments and proctoring quizzes', '2024-12-15 10:00:00'),
(5, 19, 5, 'Grading assignments and holding office hours', '2024-12-15 10:00:00');

-- --------------------------------------------------------

--
-- Table structure for table `daily_streaks`
--

CREATE TABLE `daily_streaks` (
  `streak_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `current_streak` int(11) DEFAULT 0,
  `longest_streak` int(11) DEFAULT 0,
  `last_activity_date` date DEFAULT NULL,
  `streak_start_date` date DEFAULT NULL,
  `total_active_days` int(11) DEFAULT 0,
  `streak_status` enum('active','broken','frozen') DEFAULT 'active',
  `freeze_count` int(11) DEFAULT 0,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `daily_streaks`
--

INSERT INTO `daily_streaks` (`streak_id`, `user_id`, `current_streak`, `longest_streak`, `last_activity_date`, `streak_start_date`, `total_active_days`, `streak_status`, `freeze_count`, `updated_at`) VALUES
(1, 7, 15, 15, '2025-02-15', '2025-02-01', 15, 'active', 0, '2025-11-20 13:43:00'),
(2, 8, 12, 12, '2025-02-15', '2025-02-04', 12, 'active', 0, '2025-11-20 13:43:00'),
(3, 9, 8, 10, '2025-02-15', '2025-02-08', 20, 'active', 1, '2025-11-20 13:43:00'),
(4, 10, 5, 7, '2025-02-15', '2025-02-11', 15, 'active', 0, '2025-11-20 13:43:00'),
(5, 11, 3, 5, '2025-02-15', '2025-02-13', 10, 'active', 0, '2025-11-20 13:43:00');

-- --------------------------------------------------------

--
-- Table structure for table `deadline_reminders`
--

CREATE TABLE `deadline_reminders` (
  `reminder_id` bigint(20) UNSIGNED NOT NULL,
  `task_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `reminder_time` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `reminder_type` enum('email','push','sms','in_app') DEFAULT 'in_app',
  `status` enum('pending','sent','failed') DEFAULT 'pending',
  `sent_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `deadline_reminders`
--

INSERT INTO `deadline_reminders` (`reminder_id`, `task_id`, `user_id`, `reminder_time`, `reminder_type`, `status`, `sent_at`, `created_at`) VALUES
(4, 5, 8, '2025-02-18 07:00:00', 'email', 'sent', '2025-02-18 07:00:15', '2025-11-20 13:43:00'),
(5, 6, 9, '2025-03-13 07:00:00', 'push', 'pending', NULL, '2025-11-20 13:43:00');

-- --------------------------------------------------------

--
-- Table structure for table `departments`
--

CREATE TABLE `departments` (
  `department_id` bigint(20) UNSIGNED NOT NULL,
  `campus_id` bigint(20) UNSIGNED NOT NULL,
  `department_name` varchar(200) NOT NULL,
  `department_code` varchar(20) NOT NULL,
  `head_of_department_id` bigint(20) UNSIGNED DEFAULT NULL,
  `description` text DEFAULT NULL,
  `status` enum('active','inactive') DEFAULT 'active',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `departments`
--

INSERT INTO `departments` (`department_id`, `campus_id`, `department_name`, `department_code`, `head_of_department_id`, `description`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 'Updated Department', 'CS', NULL, 'Department of Computer Science and Engineering', 'active', '2025-11-20 13:42:59', '2026-03-05 19:16:19'),
(2, 1, 'Mathematics', 'MATH', NULL, 'Department of Mathematics', 'active', '2025-11-20 13:42:59', '2025-11-20 13:42:59'),
(3, 1, 'Physics', 'PHY', NULL, 'Department of Physics', 'active', '2025-11-20 13:42:59', '2025-11-20 13:42:59'),
(4, 2, 'Business Administration', 'BUS', NULL, 'School of Business', 'active', '2025-11-20 13:42:59', '2025-11-20 13:42:59'),
(5, 2, 'Engineering', 'ENG', NULL, 'School of Engineering', 'active', '2025-11-20 13:42:59', '2025-11-20 13:42:59'),
(6, 3, 'Science', 'SCI', NULL, 'Department of mathematics, physics, and chemistry', 'active', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(14, 1, 'Test Dept Z', 'TDZ', NULL, 'Test', 'active', '2026-03-02 13:29:52', '2026-03-02 13:29:52'),
(15, 1, 'AutoDept', 'AD1', NULL, NULL, 'active', '2026-03-02 13:49:17', '2026-03-02 13:49:17'),
(16, 1, 'Test Department', 'TD01', NULL, 'A test department', 'active', '2026-03-02 23:28:49', '2026-03-02 23:28:49');

-- --------------------------------------------------------

--
-- Table structure for table `device_tokens`
--

CREATE TABLE `device_tokens` (
  `token_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `device_token` varchar(255) NOT NULL,
  `device_type` enum('ios','android','web') DEFAULT NULL,
  `device_name` varchar(100) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `last_used` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `device_tokens`
--

INSERT INTO `device_tokens` (`token_id`, `user_id`, `device_token`, `device_type`, `device_name`, `is_active`, `last_used`, `created_at`) VALUES
(1, 7, 'fcm_token_alice_phone_12345', 'android', 'Alice Phone', 1, '2025-02-15 06:30:00', '2025-11-20 13:43:00'),
(2, 7, 'fcm_token_alice_tablet_67890', '', 'Alice Tablet', 1, '2025-02-14 18:15:00', '2025-11-20 13:43:00'),
(3, 8, 'apns_token_bob_iphone_abcde', 'ios', 'Bob iPhone 13', 1, '2025-02-15 05:45:00', '2025-11-20 13:43:00'),
(4, 9, 'fcm_token_carol_android_fghij', 'android', 'Carol Galaxy S21', 1, '2025-02-15 07:00:00', '2025-11-20 13:43:00'),
(5, 10, 'web_push_token_david_chrome', 'web', 'Chrome on Windows', 1, '2025-02-15 08:30:00', '2025-11-20 13:43:00');

-- --------------------------------------------------------

--
-- Table structure for table `email_verifications`
--

CREATE TABLE `email_verifications` (
  `verification_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `verification_token` varchar(255) NOT NULL,
  `expires_at` datetime NOT NULL,
  `used` tinyint(1) DEFAULT 0,
  `used_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `email_verifications`
--

INSERT INTO `email_verifications` (`verification_id`, `user_id`, `verification_token`, `expires_at`, `used`, `used_at`, `created_at`) VALUES
(1, 25, '5d07adec255c200238f6eaa009c3b46f9896bb02ce146733c8cf2d742b9f0711', '2025-11-27 17:22:14', 1, '2025-11-26 17:23:27', '2025-11-26 15:22:14'),
(6, 29, '21835f50cc20c446f178a8c94498092b0891812a8e99e493456119faef097fd9', '2025-11-27 20:02:35', 1, '2025-11-26 20:03:48', '2025-11-26 18:02:35'),
(7, 30, '1232f414678fdff80cafc79ff0c80c37fe239fa37b01ddff305ce46e12538fa3', '2025-11-28 01:31:32', 1, '2025-11-27 01:33:39', '2025-11-26 23:31:32'),
(10, 33, '420bf068e218a74d45eeae1f71e894af89d642b5c26abc0e125e37deab55c81d', '2025-11-28 02:32:35', 1, '2025-11-27 02:36:26', '2025-11-27 00:32:35'),
(11, 33, 'e3e106fdf64b97aa98d2aa32913f0848e3be99cc0e56da772d0a1fed775b95fe', '2025-11-28 02:36:26', 1, '2025-11-27 02:36:43', '2025-11-27 00:36:26'),
(12, 34, 'd29afa104b8d7a7700c047ee8732a9edae9c77c8b4fb2b3856d25f60bca755a8', '2025-12-01 18:08:06', 0, NULL, '2025-11-30 16:08:06'),
(13, 35, '3435b074bbdebb93a84a2af96d393d94ccdddbc778909051c6d8533a5e0a877f', '2026-02-26 21:01:55', 0, NULL, '2026-02-25 19:01:54'),
(14, 36, '2fa8c3e006a12edaf0294cf86bdc49c6cf2a8f1792016bcfabcb008018eb77e0', '2026-02-26 21:02:43', 0, NULL, '2026-02-25 19:02:43');

-- --------------------------------------------------------

--
-- Table structure for table `exam_schedules`
--

CREATE TABLE `exam_schedules` (
  `exam_id` bigint(20) UNSIGNED NOT NULL,
  `course_id` bigint(20) UNSIGNED NOT NULL,
  `semester_id` bigint(20) UNSIGNED NOT NULL,
  `exam_type` enum('midterm','final','quiz','makeup') NOT NULL,
  `title` varchar(255) DEFAULT NULL,
  `exam_date` date NOT NULL,
  `start_time` time NOT NULL,
  `duration_minutes` int(11) NOT NULL,
  `location` varchar(255) DEFAULT NULL,
  `instructions` text DEFAULT NULL,
  `status` enum('scheduled','in_progress','completed','cancelled','postponed') DEFAULT 'scheduled',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `export_history`
--

CREATE TABLE `export_history` (
  `export_id` bigint(20) UNSIGNED NOT NULL,
  `report_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `export_format` enum('pdf','excel','csv','json') NOT NULL,
  `file_id` bigint(20) UNSIGNED DEFAULT NULL,
  `exported_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `face_recognition_data`
--

CREATE TABLE `face_recognition_data` (
  `face_data_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `face_encoding` blob NOT NULL,
  `sample_image_url` varchar(500) DEFAULT NULL,
  `confidence_threshold` decimal(3,2) DEFAULT 0.75,
  `enrollment_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `last_updated` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `status` enum('active','pending','failed','disabled') DEFAULT 'pending'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `face_recognition_data`
--

INSERT INTO `face_recognition_data` (`face_data_id`, `user_id`, `face_encoding`, `sample_image_url`, `confidence_threshold`, `enrollment_date`, `last_updated`, `status`) VALUES
(1, 7, 0x89504e470d0a1a0a0000, '/uploads/face_samples/user_7_sample.jpg', 0.85, '2025-01-20 08:00:00', '2025-11-20 13:43:00', 'active'),
(2, 8, 0x89504e470d0a1a0a0001, '/uploads/face_samples/user_8_sample.jpg', 0.80, '2025-01-20 08:15:00', '2025-11-20 13:43:00', 'active'),
(3, 9, 0x89504e470d0a1a0a0002, '/uploads/face_samples/user_9_sample.jpg', 0.82, '2025-01-20 08:30:00', '2025-11-20 13:43:00', 'active'),
(4, 10, 0x89504e470d0a1a0a0003, '/uploads/face_samples/user_10_sample.jpg', 0.75, '2025-01-20 08:45:00', '2025-11-20 13:43:00', 'active'),
(5, 11, 0x89504e470d0a1a0a0004, '/uploads/face_samples/user_11_sample.jpg', 0.78, '2025-01-20 09:00:00', '2025-11-20 13:43:00', 'pending');

-- --------------------------------------------------------

--
-- Table structure for table `feedback_responses`
--

CREATE TABLE `feedback_responses` (
  `response_id` bigint(20) UNSIGNED NOT NULL,
  `feedback_id` bigint(20) UNSIGNED DEFAULT NULL,
  `ticket_id` bigint(20) UNSIGNED DEFAULT NULL,
  `responder_id` bigint(20) UNSIGNED NOT NULL,
  `response_text` text NOT NULL,
  `is_internal_note` tinyint(1) DEFAULT 0,
  `attachments` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `feedback_responses`
--

INSERT INTO `feedback_responses` (`response_id`, `feedback_id`, `ticket_id`, `responder_id`, `response_text`, `is_internal_note`, `attachments`, `created_at`) VALUES
(1, 1, 1, 1, 'Thank you for reporting this issue. We have identified the problem with file upload validation. Could you please try again?', 0, NULL, '2025-11-20 13:43:00'),
(2, 1, 1, 7, 'It works now! Thank you so much!', 0, NULL, '2025-11-20 13:43:00'),
(3, 4, 2, 1, 'Your quiz grade has been updated. There was a delay in the automated grading system. Please check your gradebook now.', 0, NULL, '2025-11-20 13:43:00'),
(4, NULL, 3, 1, 'I have manually sent you a password reset link to your registered email. Please check your spam folder as well.', 0, NULL, '2025-11-20 13:43:00'),
(5, 2, NULL, 1, 'Great suggestion! We are working on implementing dark mode in the next update.', 0, NULL, '2025-11-20 13:43:00');

-- --------------------------------------------------------

--
-- Table structure for table `files`
--

CREATE TABLE `files` (
  `file_id` bigint(20) UNSIGNED NOT NULL,
  `file_name` varchar(255) NOT NULL,
  `original_filename` varchar(255) NOT NULL,
  `file_path` varchar(500) NOT NULL,
  `file_size` bigint(20) UNSIGNED DEFAULT NULL,
  `mime_type` varchar(100) DEFAULT NULL,
  `file_extension` varchar(10) DEFAULT NULL,
  `uploaded_by` bigint(20) UNSIGNED NOT NULL,
  `folder_id` bigint(20) UNSIGNED DEFAULT NULL,
  `checksum` varchar(64) DEFAULT NULL,
  `download_count` int(11) DEFAULT 0,
  `is_public` tinyint(1) DEFAULT 0,
  `status` enum('active','processing','archived','deleted') DEFAULT 'active',
  `uploaded_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `files`
--

INSERT INTO `files` (`file_id`, `file_name`, `original_filename`, `file_path`, `file_size`, `mime_type`, `file_extension`, `uploaded_by`, `folder_id`, `checksum`, `download_count`, `is_public`, `status`, `uploaded_at`, `updated_at`, `deleted_at`) VALUES
(1, 'cs101_syllabus.pdf', 'CS101_Syllabus.pdf', '/course_materials/cs101/syllabus.pdf', 524288, 'application/pdf', 'pdf', 2, 2, NULL, 0, 1, 'active', '2025-11-20 13:42:59', '2025-11-20 13:42:59', NULL),
(2, 'cs101_lecture1.pdf', 'Lecture_1_Introduction.pdf', '/course_materials/cs101/lecture1.pdf', 1048576, 'application/pdf', 'pdf', 2, 2, NULL, 0, 1, 'active', '2025-11-20 13:42:59', '2025-11-20 13:42:59', NULL),
(3, 'cs101_lecture2.pdf', 'Lecture_2_Variables.pdf', '/course_materials/cs101/lecture2.pdf', 892467, 'application/pdf', 'pdf', 2, 2, NULL, 0, 1, 'active', '2025-11-20 13:42:59', '2025-11-20 13:42:59', NULL),
(4, 'cs201_syllabus.pdf', 'CS201_Syllabus.pdf', '/course_materials/cs201/syllabus.pdf', 612453, 'application/pdf', 'pdf', 3, 3, NULL, 0, 1, 'active', '2025-11-20 13:42:59', '2025-11-20 13:42:59', NULL),
(5, 'assignment1_spec.pdf', 'Assignment_1_Specifications.pdf', '/assignments/cs101/assign1.pdf', 234567, 'application/pdf', 'pdf', 2, 4, NULL, 0, 0, 'active', '2025-11-20 13:42:59', '2025-11-20 13:42:59', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `file_permissions`
--

CREATE TABLE `file_permissions` (
  `permission_id` bigint(20) UNSIGNED NOT NULL,
  `file_id` bigint(20) UNSIGNED DEFAULT NULL,
  `folder_id` bigint(20) UNSIGNED DEFAULT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `role_id` int(10) UNSIGNED DEFAULT NULL,
  `permission_type` enum('read','write','delete','share') NOT NULL,
  `granted_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `granted_by` bigint(20) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `file_versions`
--

CREATE TABLE `file_versions` (
  `version_id` bigint(20) UNSIGNED NOT NULL,
  `file_id` bigint(20) UNSIGNED NOT NULL,
  `version_number` int(11) NOT NULL,
  `file_path` varchar(500) NOT NULL,
  `file_size` bigint(20) UNSIGNED DEFAULT NULL,
  `uploaded_by` bigint(20) UNSIGNED NOT NULL,
  `change_description` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `folders`
--

CREATE TABLE `folders` (
  `folder_id` bigint(20) UNSIGNED NOT NULL,
  `folder_name` varchar(255) NOT NULL,
  `parent_folder_id` bigint(20) UNSIGNED DEFAULT NULL,
  `created_by` bigint(20) UNSIGNED NOT NULL,
  `path` text DEFAULT NULL,
  `level` int(11) DEFAULT 0,
  `is_system_folder` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `folders`
--

INSERT INTO `folders` (`folder_id`, `folder_name`, `parent_folder_id`, `created_by`, `path`, `level`, `is_system_folder`, `created_at`, `updated_at`) VALUES
(1, 'Course Materials', NULL, 1, '/course_materials', 0, 1, '2025-11-20 13:42:59', '2025-11-20 13:42:59'),
(2, 'CS101 Materials', NULL, 2, '/course_materials/cs101', 1, 0, '2025-11-20 13:42:59', '2025-11-20 13:42:59'),
(3, 'CS201 Materials', NULL, 3, '/course_materials/cs201', 1, 0, '2025-11-20 13:42:59', '2025-11-20 13:42:59'),
(4, 'Assignments', NULL, 1, '/assignments', 0, 1, '2025-11-20 13:42:59', '2025-11-20 13:42:59'),
(5, 'Student Submissions', NULL, 1, '/student_submissions', 0, 1, '2025-11-20 13:42:59', '2025-11-20 13:42:59'),
(7, 'MergeTestFolder', NULL, 59, NULL, 0, 0, '2026-03-02 14:05:02', '2026-03-02 14:05:02'),
(8, 'Lecture Notes', NULL, 59, NULL, 0, 0, '2026-03-02 23:33:11', '2026-03-02 23:33:11'),
(9, 'Test PM Folder', NULL, 59, NULL, 0, 0, '2026-03-02 23:42:38', '2026-03-02 23:42:38'),
(10, 'Test PM Folder', NULL, 59, NULL, 0, 0, '2026-03-02 23:47:21', '2026-03-02 23:47:21'),
(11, 'Lecture Notes', NULL, 59, NULL, 0, 0, '2026-03-02 23:51:58', '2026-03-02 23:51:58'),
(12, 'Lecture Notes', NULL, 59, NULL, 0, 0, '2026-03-03 00:23:19', '2026-03-03 00:23:19'),
(13, 'Lecture Notes', NULL, 59, NULL, 0, 0, '2026-03-03 18:34:04', '2026-03-03 18:34:04'),
(14, 'Lecture Notes', NULL, 59, NULL, 0, 0, '2026-03-05 19:16:25', '2026-03-05 19:16:25');

-- --------------------------------------------------------

--
-- Table structure for table `forum_categories`
--

CREATE TABLE `forum_categories` (
  `category_id` bigint(20) UNSIGNED NOT NULL,
  `course_id` bigint(20) UNSIGNED NOT NULL,
  `category_name` varchar(255) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `order_index` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `forum_categories`
--

INSERT INTO `forum_categories` (`category_id`, `course_id`, `category_name`, `description`, `order_index`, `created_at`) VALUES
(4, 2, 'General Discussion', 'General CS201 discussions', 1, '2025-11-20 13:43:00'),
(5, 2, 'Project Discussions', 'Discuss course projects', 2, '2025-11-20 13:43:00'),
(6, 1, 'Test Category', 'A test forum category', 5, '2026-03-05 19:16:32');

-- --------------------------------------------------------

--
-- Table structure for table `generated_reports`
--

CREATE TABLE `generated_reports` (
  `report_id` bigint(20) UNSIGNED NOT NULL,
  `template_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `report_name` varchar(255) NOT NULL,
  `report_type` varchar(50) NOT NULL,
  `filters` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `file_id` bigint(20) UNSIGNED DEFAULT NULL,
  `generation_status` enum('pending','processing','completed','failed') DEFAULT 'pending',
  `generated_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `generated_reports`
--

INSERT INTO `generated_reports` (`report_id`, `template_id`, `user_id`, `report_name`, `report_type`, `filters`, `file_id`, `generation_status`, `generated_at`, `created_at`) VALUES
(1, 1, 2, 'Alice Anderson Progress Report - Spring 2025', 'student', '{\"user_id\": 7, \"semester_id\": 2}', NULL, 'completed', '2025-02-15 08:00:00', '2025-11-20 13:43:00'),
(2, 2, 2, 'CS101 Section A Analytics', 'course', '{\"section_id\": 1, \"semester_id\": 2}', NULL, 'completed', '2025-02-14 13:30:00', '2025-11-20 13:43:00'),
(3, 3, 2, 'CS101 Attendance Report - February', 'attendance', '{\"section_id\": 1, \"month\": \"2025-02\"}', NULL, 'completed', '2025-02-28 07:00:00', '2025-11-20 13:43:00'),
(4, 4, 3, 'CS201 Grade Distribution', 'grade', '{\"course_id\": 2, \"semester_id\": 2}', NULL, 'pending', NULL, '2025-11-20 13:43:00');

-- --------------------------------------------------------

--
-- Table structure for table `gpa_calculations`
--

CREATE TABLE `gpa_calculations` (
  `gpa_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `semester_id` bigint(20) UNSIGNED DEFAULT NULL,
  `calculation_type` enum('semester','cumulative') DEFAULT 'semester',
  `gpa` decimal(3,2) NOT NULL,
  `total_credits` int(11) DEFAULT NULL,
  `total_points` decimal(10,2) DEFAULT NULL,
  `calculated_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `gpa_calculations`
--

INSERT INTO `gpa_calculations` (`gpa_id`, `user_id`, `semester_id`, `calculation_type`, `gpa`, `total_credits`, `total_points`, `calculated_at`) VALUES
(4, 7, NULL, 'cumulative', 3.78, 45, 170.10, '2025-02-15 21:59:59'),
(5, 8, NULL, 'cumulative', 3.52, 42, 147.84, '2025-02-15 21:59:59');

-- --------------------------------------------------------

--
-- Table structure for table `grades`
--

CREATE TABLE `grades` (
  `grade_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `course_id` bigint(20) UNSIGNED NOT NULL,
  `assignment_id` bigint(20) UNSIGNED DEFAULT NULL,
  `quiz_id` bigint(20) UNSIGNED DEFAULT NULL,
  `lab_id` bigint(20) UNSIGNED DEFAULT NULL,
  `grade_type` enum('assignment','quiz','lab','exam','participation','final') NOT NULL,
  `score` decimal(5,2) NOT NULL,
  `max_score` decimal(5,2) NOT NULL,
  `percentage` decimal(5,2) DEFAULT NULL,
  `letter_grade` varchar(5) DEFAULT NULL,
  `feedback` text DEFAULT NULL,
  `graded_by` bigint(20) UNSIGNED DEFAULT NULL,
  `graded_at` timestamp NULL DEFAULT NULL,
  `is_published` tinyint(1) DEFAULT 0,
  `published_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `grades`
--

INSERT INTO `grades` (`grade_id`, `user_id`, `course_id`, `assignment_id`, `quiz_id`, `lab_id`, `grade_type`, `score`, `max_score`, `percentage`, `letter_grade`, `feedback`, `graded_by`, `graded_at`, `is_published`, `published_at`, `created_at`, `updated_at`) VALUES
(6, 21, 1, 1, NULL, NULL, 'assignment', 92.00, 100.00, 92.00, 'A', 'Great work! Well-structured code.', 8, '2025-02-01 10:00:00', 1, NULL, '2026-03-01 14:55:40', '2026-03-01 14:55:40'),
(7, 22, 1, 1, NULL, NULL, 'assignment', 88.00, 100.00, 88.00, 'B+', 'Good solution. Need improvement in error handling.', 8, '2025-02-01 10:00:00', 1, NULL, '2026-03-01 14:55:40', '2026-03-01 14:55:40'),
(8, 23, 1, 1, NULL, NULL, 'assignment', 95.00, 100.00, 95.00, 'A', 'Excellent! Clean code and thorough testing.', 8, '2025-02-01 10:00:00', 1, NULL, '2026-03-01 14:55:40', '2026-03-01 14:55:40'),
(9, 24, 1, 1, NULL, NULL, 'assignment', 85.00, 100.00, 85.00, 'B', 'Acceptable solution but could be optimized.', 8, '2025-02-02 09:00:00', 1, NULL, '2026-03-01 14:55:40', '2026-03-01 14:55:40'),
(10, 25, 1, 1, NULL, NULL, 'assignment', 90.00, 100.00, 90.00, 'A-', 'Good job overall.', 8, '2025-02-01 10:00:00', 1, NULL, '2026-03-01 14:55:40', '2026-03-01 14:55:40'),
(11, 21, 1, NULL, NULL, NULL, 'quiz', 18.00, 20.00, 90.00, 'A-', 'Well done on the quiz!', 8, '2025-02-03 10:30:00', 1, NULL, '2026-03-01 14:55:40', '2026-03-01 14:55:40'),
(12, 22, 1, NULL, NULL, NULL, 'quiz', 16.00, 20.00, 80.00, 'B-', 'Good effort. Review control flow concepts.', 8, '2025-02-03 10:30:00', 1, NULL, '2026-03-01 14:55:40', '2026-03-01 14:55:40'),
(13, 23, 1, NULL, NULL, NULL, 'quiz', 19.00, 20.00, 95.00, 'A', 'Perfect score! Excellent understanding.', 8, '2025-02-03 10:30:00', 1, NULL, '2026-03-01 14:55:40', '2026-03-01 14:55:40'),
(14, 24, 1, NULL, NULL, NULL, 'quiz', 15.00, 20.00, 75.00, 'C+', 'Needs improvement. Review material.', 8, '2025-02-03 10:30:00', 1, NULL, '2026-03-01 14:55:40', '2026-03-01 14:55:40'),
(15, 25, 1, NULL, NULL, NULL, 'quiz', 17.00, 20.00, 85.00, 'B+', 'Good work on the quiz.', 8, '2025-02-03 10:30:00', 1, NULL, '2026-03-01 14:55:40', '2026-03-01 14:55:40');

-- --------------------------------------------------------

--
-- Table structure for table `grade_components`
--

CREATE TABLE `grade_components` (
  `component_id` bigint(20) UNSIGNED NOT NULL,
  `grade_id` bigint(20) UNSIGNED NOT NULL,
  `rubric_id` bigint(20) UNSIGNED DEFAULT NULL,
  `criterion_name` varchar(255) NOT NULL,
  `points_earned` decimal(5,2) NOT NULL,
  `max_points` decimal(5,2) NOT NULL,
  `feedback` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `image_text_extractions`
--

CREATE TABLE `image_text_extractions` (
  `extraction_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `image_file_id` bigint(20) UNSIGNED NOT NULL,
  `extracted_text` text NOT NULL,
  `language` varchar(10) DEFAULT 'en',
  `confidence_score` decimal(3,2) DEFAULT NULL,
  `processing_status` enum('pending','completed','failed') DEFAULT 'completed',
  `processing_time_ms` int(11) DEFAULT NULL,
  `ai_model` varchar(50) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `image_text_extractions`
--

INSERT INTO `image_text_extractions` (`extraction_id`, `user_id`, `image_file_id`, `extracted_text`, `language`, `confidence_score`, `processing_status`, `processing_time_ms`, `ai_model`, `created_at`) VALUES
(1, 7, 3, 'Variables in Python: int, float, str, bool. Variable naming conventions: use lowercase with underscores.', 'en', 0.89, 'completed', 1800, 'tesseract-ocr', '2025-11-20 13:43:00'),
(2, 8, 2, 'Lecture 1: Introduction to Programming. Topics: What is programming? Programming languages. Python basics.', 'en', 0.92, 'completed', 2200, 'tesseract-ocr', '2025-11-20 13:43:00');

-- --------------------------------------------------------

--
-- Table structure for table `labs`
--

CREATE TABLE `labs` (
  `lab_id` bigint(20) UNSIGNED NOT NULL,
  `course_id` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `lab_number` int(11) DEFAULT NULL,
  `due_date` timestamp NULL DEFAULT NULL,
  `available_from` timestamp NULL DEFAULT NULL,
  `max_score` decimal(5,2) DEFAULT 100.00,
  `weight` decimal(5,2) DEFAULT 0.00,
  `status` enum('draft','published','closed','archived') DEFAULT 'draft',
  `created_by` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `labs`
--

INSERT INTO `labs` (`lab_id`, `course_id`, `title`, `description`, `lab_number`, `due_date`, `available_from`, `max_score`, `weight`, `status`, `created_by`, `created_at`, `updated_at`) VALUES
(3, 2, 'Lab 1: Array Implementation', 'Implement dynamic arrays', 1, '2025-03-01 21:59:59', '2025-02-14 22:00:00', 100.00, 10.00, 'draft', 3, '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(4, 1, 'Data Structures Lab 1 (Updated)', 'Updated description', 1, '2026-04-01 23:59:59', '2026-03-01 00:00:00', 100.00, 10.00, 'published', 58, '2026-03-03 00:09:55', '2026-03-03 00:09:58'),
(7, 1, 'Data Structures Lab 1', 'Binary tree traversal lab', 1, '2026-04-01 23:59:59', '2026-03-01 00:00:00', 100.00, 10.00, 'published', 58, '2026-03-03 00:26:01', '2026-03-03 00:26:01'),
(8, 1, 'Data Structures Lab 1', 'Binary tree traversal lab', 1, '2026-04-01 23:59:59', '2026-03-01 00:00:00', 100.00, 10.00, 'published', 58, '2026-03-03 18:34:08', '2026-03-03 18:34:08'),
(9, 1, 'Data Structures Lab 1', 'Binary tree traversal lab', 1, '2026-04-01 23:59:59', '2026-03-01 00:00:00', 100.00, 10.00, 'published', 58, '2026-03-05 19:16:28', '2026-03-05 19:16:28');

-- --------------------------------------------------------

--
-- Table structure for table `lab_attendance`
--

CREATE TABLE `lab_attendance` (
  `attendance_id` bigint(20) UNSIGNED NOT NULL,
  `lab_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `attendance_status` enum('present','absent','excused','late') DEFAULT 'absent',
  `check_in_time` timestamp NULL DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `marked_by` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `lab_attendance`
--

INSERT INTO `lab_attendance` (`attendance_id`, `lab_id`, `user_id`, `attendance_status`, `check_in_time`, `notes`, `marked_by`, `created_at`) VALUES
(7, 4, 57, 'present', '2026-03-03 00:10:05', 'On time', 58, '2026-03-03 00:10:05'),
(8, 7, 57, 'present', '2026-03-03 00:27:50', 'On time', 58, '2026-03-03 00:27:50');

-- --------------------------------------------------------

--
-- Table structure for table `lab_instructions`
--

CREATE TABLE `lab_instructions` (
  `instruction_id` bigint(20) UNSIGNED NOT NULL,
  `lab_id` bigint(20) UNSIGNED NOT NULL,
  `file_id` bigint(20) UNSIGNED DEFAULT NULL,
  `instruction_text` text DEFAULT NULL,
  `order_index` int(11) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `lab_instructions`
--

INSERT INTO `lab_instructions` (`instruction_id`, `lab_id`, `file_id`, `instruction_text`, `order_index`, `created_at`) VALUES
(7, 3, NULL, 'Implement a dynamic array class with push, pop, and resize methods', 1, '2025-11-20 13:43:00'),
(8, 4, NULL, 'Step 1: Implement the binary tree node class', 1, '2026-03-03 00:09:59'),
(9, 7, NULL, 'Step 1: Implement the binary tree node class', 1, '2026-03-03 00:26:30');

-- --------------------------------------------------------

--
-- Table structure for table `lab_submissions`
--

CREATE TABLE `lab_submissions` (
  `submission_id` bigint(20) UNSIGNED NOT NULL,
  `lab_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `file_id` bigint(20) UNSIGNED DEFAULT NULL,
  `submission_text` text DEFAULT NULL,
  `submitted_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `is_late` tinyint(1) DEFAULT 0,
  `status` enum('submitted','graded','returned','resubmit') DEFAULT 'submitted'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `lab_submissions`
--

INSERT INTO `lab_submissions` (`submission_id`, `lab_id`, `user_id`, `file_id`, `submission_text`, `submitted_at`, `is_late`, `status`) VALUES
(5, 4, 57, NULL, 'My binary tree implementation...', '2026-03-03 00:10:01', 0, 'graded'),
(6, 7, 57, NULL, 'My binary tree implementation with inorder, preorder, and postorder traversals.', '2026-03-03 00:26:48', 0, 'submitted');

-- --------------------------------------------------------

--
-- Table structure for table `language_preferences`
--

CREATE TABLE `language_preferences` (
  `preference_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `language_code` varchar(10) DEFAULT 'en',
  `date_format` varchar(20) DEFAULT 'YYYY-MM-DD',
  `time_format` enum('12h','24h') DEFAULT '24h',
  `timezone` varchar(50) DEFAULT 'UTC',
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `language_preferences`
--

INSERT INTO `language_preferences` (`preference_id`, `user_id`, `language_code`, `date_format`, `time_format`, `timezone`, `updated_at`) VALUES
(1, 7, 'en', 'YYYY-MM-DD', '24h', 'America/New_York', '2025-11-20 13:43:00'),
(2, 8, 'en', 'MM/DD/YYYY', '12h', 'America/New_York', '2025-11-20 13:43:00'),
(3, 9, 'en', 'YYYY-MM-DD', '24h', 'America/Los_Angeles', '2025-11-20 13:43:00'),
(4, 10, 'en', 'DD/MM/YYYY', '24h', 'America/Chicago', '2025-11-20 13:43:00'),
(5, 11, 'en', 'YYYY-MM-DD', '12h', 'America/New_York', '2025-11-20 13:43:00'),
(6, 12, 'en', 'MM/DD/YYYY', '24h', 'America/New_York', '2025-11-20 13:43:00');

-- --------------------------------------------------------

--
-- Table structure for table `leaderboards`
--

CREATE TABLE `leaderboards` (
  `leaderboard_id` bigint(20) UNSIGNED NOT NULL,
  `leaderboard_name` varchar(255) NOT NULL,
  `leaderboard_type` enum('global','course','semester','department') NOT NULL,
  `course_id` bigint(20) UNSIGNED DEFAULT NULL,
  `semester_id` bigint(20) UNSIGNED DEFAULT NULL,
  `department_id` bigint(20) UNSIGNED DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `status` enum('active','archived') DEFAULT 'active',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `leaderboard_rankings`
--

CREATE TABLE `leaderboard_rankings` (
  `ranking_id` bigint(20) UNSIGNED NOT NULL,
  `leaderboard_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `rank_position` int(11) NOT NULL,
  `total_points` bigint(20) NOT NULL,
  `previous_rank` int(11) DEFAULT NULL,
  `rank_change` int(11) DEFAULT 0,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `learning_analytics`
--

CREATE TABLE `learning_analytics` (
  `analytics_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `course_id` bigint(20) UNSIGNED NOT NULL,
  `progress_id` bigint(20) UNSIGNED DEFAULT NULL,
  `metric_type` enum('engagement','performance','participation','time') NOT NULL,
  `metric_value` decimal(10,2) NOT NULL,
  `metric_date` date NOT NULL,
  `additional_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `lecture_sections_labs`
--

CREATE TABLE `lecture_sections_labs` (
  `organization_id` bigint(20) UNSIGNED NOT NULL,
  `course_id` bigint(20) UNSIGNED NOT NULL,
  `material_id` bigint(20) UNSIGNED DEFAULT NULL,
  `organization_type` enum('lecture','section','lab','tutorial') DEFAULT NULL,
  `title` varchar(255) NOT NULL,
  `week_number` int(11) DEFAULT NULL,
  `order_index` int(11) DEFAULT 0,
  `description` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `lecture_sections_labs`
--

INSERT INTO `lecture_sections_labs` (`organization_id`, `course_id`, `material_id`, `organization_type`, `title`, `week_number`, `order_index`, `description`, `created_at`) VALUES
(5, 2, NULL, 'lecture', 'Week 1: Arrays Introduction', 1, 1, 'Introduction to arrays and lists', '2025-11-20 13:43:01'),
(6, 2, NULL, 'lab', 'Week 2: Array Operations Lab', 2, 2, 'Hands-on practice with arrays', '2025-11-20 13:43:01');

-- --------------------------------------------------------

--
-- Table structure for table `live_sessions`
--

CREATE TABLE `live_sessions` (
  `session_id` bigint(20) UNSIGNED NOT NULL,
  `course_id` bigint(20) UNSIGNED NOT NULL,
  `instructor_id` bigint(20) UNSIGNED NOT NULL,
  `session_title` varchar(255) DEFAULT NULL,
  `session_url` varchar(500) DEFAULT NULL,
  `start_time` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `end_time` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `recording_file_id` bigint(20) UNSIGNED DEFAULT NULL,
  `participant_count` int(11) DEFAULT 0,
  `status` enum('scheduled','live','ended','cancelled') DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `live_sessions`
--

INSERT INTO `live_sessions` (`session_id`, `course_id`, `instructor_id`, `session_title`, `session_url`, `start_time`, `end_time`, `recording_file_id`, `participant_count`, `status`, `created_at`) VALUES
(2, 2, 3, 'Data Structures Q&A', 'https://meet.campus.edu/cs201-qa-1', '2025-02-22 15:00:00', '2025-02-22 16:00:00', NULL, 8, 'ended', '2025-11-20 13:43:00');

-- --------------------------------------------------------

--
-- Table structure for table `live_session_participants`
--

CREATE TABLE `live_session_participants` (
  `participant_id` bigint(20) UNSIGNED NOT NULL,
  `session_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `joined_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `left_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `participation_score` decimal(5,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `live_session_participants`
--

INSERT INTO `live_session_participants` (`participant_id`, `session_id`, `user_id`, `joined_at`, `left_at`, `participation_score`) VALUES
(4, 2, 12, '2025-02-22 15:00:00', '2025-02-22 16:00:00', 92.00),
(5, 2, 13, '2025-02-22 15:03:00', '2025-02-22 15:45:00', 75.00);

-- --------------------------------------------------------

--
-- Table structure for table `localization_strings`
--

CREATE TABLE `localization_strings` (
  `string_id` bigint(20) UNSIGNED NOT NULL,
  `language_code` varchar(10) NOT NULL,
  `string_key` varchar(255) NOT NULL,
  `string_value` text NOT NULL,
  `context` varchar(100) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `localization_strings`
--

INSERT INTO `localization_strings` (`string_id`, `language_code`, `string_key`, `string_value`, `context`, `created_at`, `updated_at`) VALUES
(1, 'en', 'dashboard.welcome', 'Welcome back', 'dashboard', '2025-11-20 13:43:01', '2025-11-20 13:43:01'),
(2, 'es', 'dashboard.welcome', 'Bienvenido de nuevo', 'dashboard', '2025-11-20 13:43:01', '2025-11-20 13:43:01'),
(3, 'fr', 'dashboard.welcome', 'Bon retour', 'dashboard', '2025-11-20 13:43:01', '2025-11-20 13:43:01'),
(4, 'en', 'course.assignments', 'Assignments', 'courses', '2025-11-20 13:43:01', '2025-11-20 13:43:01'),
(5, 'es', 'course.assignments', 'Tareas', 'courses', '2025-11-20 13:43:01', '2025-11-20 13:43:01'),
(6, 'fr', 'course.assignments', 'Devoirs', 'courses', '2025-11-20 13:43:01', '2025-11-20 13:43:01'),
(7, 'en', 'grade.submitted', 'Grade submitted successfully', 'grading', '2025-11-20 13:43:01', '2025-11-20 13:43:01'),
(8, 'es', 'grade.submitted', 'Calificaci??n enviada exitosamente', 'grading', '2025-11-20 13:43:01', '2025-11-20 13:43:01'),
(9, 'ar', 'dashboard.welcome', '?????????? ????????????', 'dashboard', '2025-11-20 13:43:01', '2025-11-20 13:43:01'),
(10, 'ar', 'course.assignments', '????????????????', 'courses', '2025-11-20 13:43:01', '2025-11-20 13:43:01');

-- --------------------------------------------------------

--
-- Table structure for table `login_attempts`
--

CREATE TABLE `login_attempts` (
  `attempt_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `attempt_status` enum('success','failed','blocked') NOT NULL,
  `failure_reason` varchar(255) DEFAULT NULL,
  `attempted_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `login_attempts`
--

INSERT INTO `login_attempts` (`attempt_id`, `user_id`, `email`, `ip_address`, `user_agent`, `attempt_status`, `failure_reason`, `attempted_at`) VALUES
(1, 7, 'alice.student@campus.edu', '192.168.1.100', NULL, 'success', NULL, '2025-11-20 13:43:00'),
(2, 8, 'bob.student@campus.edu', '192.168.1.101', NULL, 'success', NULL, '2025-11-20 13:43:00'),
(3, NULL, 'wrong@email.com', '192.168.1.200', NULL, 'failed', 'Invalid email', '2025-11-20 13:43:00'),
(4, 9, 'carol.student@campus.edu', '192.168.1.102', NULL, 'failed', 'Wrong password', '2025-11-20 13:43:00'),
(5, 9, 'carol.student@campus.edu', '192.168.1.102', NULL, 'success', NULL, '2025-11-20 13:43:00'),
(6, NULL, 'admin@campus.edu', '203.0.113.45', NULL, 'failed', 'Wrong password', '2025-11-20 13:43:00'),
(7, NULL, 'admin@campus.edu', '203.0.113.45', NULL, 'blocked', 'Too many failed attempts', '2025-11-20 13:43:00');

-- --------------------------------------------------------

--
-- Table structure for table `messages`
--

CREATE TABLE `messages` (
  `message_id` bigint(20) UNSIGNED NOT NULL,
  `sender_id` bigint(20) UNSIGNED NOT NULL,
  `subject` varchar(255) DEFAULT NULL,
  `body` text NOT NULL,
  `message_type` enum('direct','group','announcement') DEFAULT 'direct',
  `parent_message_id` bigint(20) UNSIGNED DEFAULT NULL,
  `reply_to_id` bigint(20) UNSIGNED DEFAULT NULL,
  `read_status` tinyint(1) DEFAULT 0,
  `sent_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `edited_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `messages`
--

INSERT INTO `messages` (`message_id`, `sender_id`, `subject`, `body`, `message_type`, `parent_message_id`, `reply_to_id`, `read_status`, `sent_at`, `edited_at`) VALUES
(1, 2, 'Welcome to CS101', 'Welcome to Introduction to Programming! I look forward to working with you this semester.', 'announcement', NULL, NULL, 0, '2025-11-20 13:43:00', NULL),
(2, 7, 'Question about Assignment 1', 'Professor Smith, I have a question about the first assignment. Can we use external libraries?', 'direct', NULL, NULL, 1, '2025-11-20 13:43:00', NULL),
(3, 2, 'RE: Question about Assignment 1', 'For this assignment, please use only built-in Python functions.', 'direct', NULL, NULL, 0, '2025-11-20 13:43:00', NULL),
(4, 3, 'CS201 Project Groups', 'Please form groups of 3-4 students for the final project.', 'announcement', NULL, NULL, 0, '2025-11-20 13:43:00', NULL),
(5, 22, 'Grade Discussion', 'I would like to discuss my quiz score from last week.', 'direct', NULL, NULL, 0, '2025-02-08 16:20:00', NULL),
(6, 57, NULL, 'Hey instructor, I have a question about Assignment 1.', 'direct', NULL, NULL, 0, '2026-03-03 18:12:53', NULL),
(7, 58, 'CS101 Study Group', 'Welcome to the CS101 Study Group!', 'group', NULL, NULL, 0, '2026-03-03 18:13:00', NULL),
(8, 58, NULL, 'Sure, what is your question about Assignment 1?', 'direct', 6, NULL, 0, '2026-03-03 18:16:50', NULL),
(9, 57, NULL, '__DELETED__', 'direct', 7, NULL, 0, '2026-03-03 18:18:28', NULL),
(10, 57, NULL, 'This message will be deleted for everyone', 'direct', 6, NULL, 0, '2026-03-03 18:18:53', NULL),
(11, 57, NULL, '__DELETED__', 'direct', 6, NULL, 0, '2026-03-03 18:20:17', NULL),
(12, 59, NULL, 'Hi TA, please check lab grades.', 'direct', NULL, NULL, 0, '2026-03-03 18:23:55', NULL),
(13, 59, 'Staff Meeting Room', 'Staff meeting discussion', 'group', NULL, NULL, 0, '2026-03-03 18:23:56', NULL),
(14, 60, NULL, 'Sure, I will check them right away.', 'direct', 12, NULL, 0, '2026-03-03 18:23:59', NULL),
(15, 59, NULL, 'Temporary message for deletion test', 'direct', 12, NULL, 0, '2026-03-03 18:24:01', NULL),
(16, 59, NULL, '__DELETED__', 'direct', 12, NULL, 0, '2026-03-03 18:24:02', NULL),
(17, 57, NULL, 'Hi professor, I have a question about the midterm format.', 'direct', 6, NULL, 0, '2026-03-03 18:34:10', NULL),
(18, 58, 'CS201 Project Team', 'Welcome to our project discussion group!', 'group', NULL, NULL, 0, '2026-03-03 18:34:10', NULL),
(19, 58, NULL, 'The midterm will be multiple choice and short answer. Focus on chapters 3-8.', 'direct', 6, NULL, 0, '2026-03-03 18:34:10', NULL),
(20, 57, '{\"fileId\":1}', 'Here is my draft for review', 'direct', 6, NULL, 0, '2026-03-03 18:34:10', NULL),
(21, 57, NULL, 'Hi professor, I have a question about the midterm format.', 'direct', 6, NULL, 0, '2026-03-05 19:16:29', NULL),
(22, 58, 'CS201 Project Team', 'Welcome to our project discussion group!', 'group', NULL, NULL, 0, '2026-03-05 19:16:29', NULL),
(23, 58, NULL, 'The midterm will be multiple choice and short answer. Focus on chapters 3-8.', 'direct', 6, NULL, 0, '2026-03-05 19:16:30', NULL),
(24, 57, '{\"fileId\":1}', 'Here is my draft for review', 'direct', 6, NULL, 0, '2026-03-05 19:16:30', NULL),
(25, 57, NULL, 'Hello', 'direct', 21, NULL, 0, '2026-03-10 14:21:19', NULL),
(26, 58, NULL, 'Hi', 'direct', 21, NULL, 0, '2026-03-10 14:21:23', NULL),
(27, 57, NULL, 'Why it is sent 2 times for me ?', 'direct', 21, NULL, 0, '2026-03-10 14:21:40', NULL),
(28, 58, NULL, 'Me too idk', 'direct', 21, NULL, 0, '2026-03-10 14:21:45', NULL),
(29, 57, NULL, '__DELETED__', 'direct', 21, NULL, 0, '2026-03-10 14:21:57', NULL),
(30, 58, NULL, 'Oh it is deleted succeffully', 'direct', 21, NULL, 0, '2026-03-10 14:22:21', NULL),
(31, 57, NULL, 'IK wow', 'direct', 21, NULL, 0, '2026-03-10 14:22:27', NULL),
(32, 58, NULL, 'Helelo', 'direct', 21, NULL, 0, '2026-03-10 14:23:00', NULL),
(33, 58, '{\"fileId\":2}', 'How to replay thoo', 'direct', 21, NULL, 0, '2026-03-10 14:23:37', NULL),
(34, 57, NULL, 'Idk', 'direct', 21, NULL, 0, '2026-03-10 14:23:43', NULL),
(35, 57, NULL, 'Hello', 'direct', 21, NULL, 0, '2026-03-10 14:24:55', NULL),
(36, 58, NULL, 'Hi', 'direct', 21, NULL, 0, '2026-03-10 14:24:58', NULL),
(37, 57, NULL, '__DELETED__', 'direct', 21, NULL, 0, '2026-03-10 14:25:06', NULL),
(38, 57, NULL, 'Delete for me', 'direct', 21, NULL, 0, '2026-03-10 14:25:16', NULL),
(39, 57, NULL, 'How to replay', 'direct', 21, NULL, 0, '2026-03-10 14:25:44', NULL),
(40, 57, NULL, '12', 'direct', 21, NULL, 0, '2026-03-10 14:25:54', NULL),
(41, 57, NULL, 'How to know if itis readed or not', 'direct', 21, NULL, 0, '2026-03-10 14:26:19', NULL),
(42, 57, NULL, 'اهلا', 'direct', 21, NULL, 0, '2026-03-10 14:34:11', NULL),
(43, 58, NULL, 'هلا', 'direct', 21, NULL, 0, '2026-03-10 14:34:15', NULL),
(44, 58, NULL, 'ريبلاي', 'direct', 21, NULL, 0, '2026-03-10 14:34:25', NULL),
(45, 57, NULL, 'طب ليه مش بل=ايت', 'direct', 21, NULL, 0, '2026-03-10 14:34:37', NULL),
(46, 57, NULL, 'Replay to this', 'direct', 21, NULL, 0, '2026-03-10 14:34:58', NULL),
(47, 58, NULL, 'Replayed', 'direct', 21, NULL, 0, '2026-03-10 14:35:08', NULL),
(48, 58, NULL, 'why not showing that i replayed ?', 'direct', 21, NULL, 0, '2026-03-10 14:35:16', NULL),
(49, 57, NULL, 'Hi', 'direct', 21, NULL, 0, '2026-03-10 14:37:42', NULL),
(50, 57, NULL, 'Hi', 'direct', 21, NULL, 0, '2026-03-10 14:37:57', NULL),
(51, 58, NULL, 'Hello', 'direct', 21, NULL, 0, '2026-03-10 14:38:00', NULL),
(52, 57, NULL, 'Replay to me', 'direct', 21, NULL, 0, '2026-03-10 14:38:04', NULL),
(53, 58, NULL, 'Replayed', 'direct', 21, NULL, 0, '2026-03-10 14:38:09', NULL),
(54, 57, NULL, 'Still not visulaized', 'direct', 21, NULL, 0, '2026-03-10 14:38:17', NULL),
(55, 57, NULL, '__DELETED__', 'direct', 21, NULL, 0, '2026-03-10 14:38:22', NULL),
(56, 57, NULL, 'DELETE FOR ME ONLY', 'direct', 21, NULL, 0, '2026-03-10 14:38:47', NULL),
(57, 57, NULL, 'hellp', 'direct', 6, NULL, 0, '2026-03-10 14:56:31', NULL),
(58, 57, NULL, 'Hello', 'direct', 6, NULL, 0, '2026-03-10 14:56:46', NULL),
(59, 58, NULL, 'Hi', 'direct', 6, NULL, 0, '2026-03-10 14:56:52', NULL),
(60, 57, NULL, 'لا', 'direct', 6, NULL, 0, '2026-03-10 14:59:44', NULL),
(61, 58, NULL, 'طب ما كدا فرونت اند بس', 'direct', 6, NULL, 0, '2026-03-10 14:59:53', NULL),
(62, 57, NULL, 'Hi', 'direct', 6, NULL, 0, '2026-03-10 15:37:30', NULL),
(63, 57, NULL, '__DELETED__', 'direct', 6, NULL, 0, '2026-03-10 15:37:34', NULL),
(64, 58, NULL, 'Hello Tarek', 'direct', 6, NULL, 0, '2026-03-10 15:37:40', NULL),
(65, 58, NULL, 'GN', 'direct', 6, NULL, 0, '2026-03-10 15:37:58', NULL),
(66, 57, NULL, '__DELETED__', 'direct', 6, NULL, 0, '2026-03-10 15:38:17', NULL),
(67, 58, NULL, 'WRW', 'direct', 6, NULL, 0, '2026-03-10 15:38:20', NULL),
(68, 58, NULL, 'GA', 'direct', 6, NULL, 0, '2026-03-10 15:38:57', NULL),
(69, 57, NULL, '??', 'direct', 6, 68, 0, '2026-03-10 15:39:01', NULL),
(70, 58, NULL, '??', 'direct', 6, 69, 0, '2026-03-10 15:39:04', NULL),
(71, 57, NULL, 'Gn', 'direct', 6, NULL, 0, '2026-03-10 15:39:22', NULL),
(72, 58, NULL, 'GN', 'direct', 6, NULL, 0, '2026-03-10 15:39:25', NULL),
(73, 58, NULL, 'REPLAY TO ME', 'direct', 6, NULL, 0, '2026-03-10 15:39:30', NULL),
(74, 57, NULL, 'Replaying', 'direct', 6, 73, 0, '2026-03-10 15:39:39', NULL),
(75, 58, NULL, 'Delete the message after me for all', 'direct', 6, NULL, 0, '2026-03-10 15:39:53', NULL),
(76, 58, NULL, '__DELETED__', 'direct', 6, NULL, 0, '2026-03-10 15:39:55', NULL),
(77, 58, NULL, 'Delete the message for only me', 'direct', 6, NULL, 0, '2026-03-10 15:40:12', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `message_participants`
--

CREATE TABLE `message_participants` (
  `participant_id` bigint(20) UNSIGNED NOT NULL,
  `message_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `read_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `message_participants`
--

INSERT INTO `message_participants` (`participant_id`, `message_id`, `user_id`, `read_at`, `deleted_at`) VALUES
(1, 1, 7, '2025-02-02 08:30:00', NULL),
(2, 1, 8, '2025-02-02 09:15:00', NULL),
(3, 1, 9, NULL, NULL),
(4, 2, 2, '2025-02-03 12:20:00', NULL),
(5, 3, 7, NULL, NULL),
(6, 3, 8, NULL, NULL),
(7, 4, 23, NULL, NULL),
(8, 4, 8, '2025-02-04 11:00:00', NULL),
(9, 5, 22, '2025-02-08 16:20:00', NULL),
(10, 5, 8, NULL, NULL),
(11, 6, 57, '2026-03-05 19:16:30', NULL),
(12, 6, 58, NULL, NULL),
(13, 7, 58, '2026-03-03 18:13:00', NULL),
(14, 7, 57, '2026-03-03 18:18:38', NULL),
(15, 7, 60, NULL, NULL),
(16, 8, 58, '2026-03-03 18:16:50', NULL),
(17, 8, 57, NULL, '2026-03-05 19:16:30'),
(19, 9, 57, '2026-03-03 18:18:28', '2026-03-03 18:18:39'),
(20, 9, 58, NULL, NULL),
(21, 9, 60, NULL, NULL),
(22, 10, 57, '2026-03-03 18:18:53', NULL),
(23, 10, 58, NULL, NULL),
(24, 11, 57, '2026-03-03 18:20:17', NULL),
(25, 11, 58, NULL, NULL),
(26, 12, 59, '2026-03-03 18:23:55', NULL),
(27, 12, 60, NULL, NULL),
(28, 13, 59, '2026-03-03 18:23:56', NULL),
(29, 13, 57, NULL, NULL),
(30, 13, 58, NULL, NULL),
(31, 13, 60, NULL, NULL),
(32, 14, 60, '2026-03-03 18:23:59', NULL),
(33, 14, 59, '2026-03-03 18:24:00', NULL),
(34, 15, 59, '2026-03-03 18:24:01', '2026-03-03 18:24:03'),
(35, 15, 60, NULL, NULL),
(36, 16, 59, '2026-03-03 18:24:02', NULL),
(37, 16, 60, NULL, NULL),
(38, 17, 57, '2026-03-03 18:34:10', NULL),
(39, 17, 58, NULL, NULL),
(40, 18, 58, '2026-03-03 18:34:10', NULL),
(41, 18, 57, NULL, NULL),
(42, 18, 60, NULL, NULL),
(43, 19, 58, '2026-03-03 18:34:10', NULL),
(44, 19, 57, NULL, NULL),
(45, 20, 57, '2026-03-03 18:34:10', NULL),
(46, 20, 58, NULL, NULL),
(47, 21, 57, '2026-03-05 19:16:29', NULL),
(48, 21, 58, NULL, NULL),
(49, 22, 58, '2026-03-05 19:16:29', NULL),
(50, 22, 57, NULL, NULL),
(51, 22, 60, NULL, NULL),
(52, 23, 58, '2026-03-05 19:16:30', NULL),
(53, 23, 57, NULL, NULL),
(54, 24, 57, '2026-03-05 19:16:30', NULL),
(55, 24, 58, NULL, NULL),
(56, 25, 57, '2026-03-10 14:21:19', NULL),
(57, 25, 58, NULL, NULL),
(58, 26, 58, '2026-03-10 14:21:23', NULL),
(59, 26, 57, NULL, NULL),
(60, 27, 57, '2026-03-10 14:21:40', NULL),
(61, 27, 58, NULL, NULL),
(62, 28, 58, '2026-03-10 14:21:45', NULL),
(63, 28, 57, NULL, NULL),
(64, 29, 57, '2026-03-10 14:21:57', NULL),
(65, 29, 58, NULL, NULL),
(66, 30, 58, '2026-03-10 14:22:21', NULL),
(67, 30, 57, NULL, NULL),
(68, 31, 57, '2026-03-10 14:22:27', '2026-03-10 14:22:33'),
(69, 31, 58, NULL, NULL),
(70, 32, 58, '2026-03-10 14:23:00', NULL),
(71, 32, 57, NULL, NULL),
(72, 33, 58, '2026-03-10 14:23:37', NULL),
(73, 33, 57, NULL, NULL),
(74, 34, 57, '2026-03-10 14:23:43', NULL),
(75, 34, 58, NULL, NULL),
(76, 35, 57, '2026-03-10 14:24:55', NULL),
(77, 35, 58, NULL, NULL),
(78, 36, 58, '2026-03-10 14:24:58', NULL),
(79, 36, 57, NULL, NULL),
(80, 37, 57, '2026-03-10 14:25:06', NULL),
(81, 37, 58, NULL, NULL),
(82, 38, 57, '2026-03-10 14:25:16', '2026-03-10 14:25:20'),
(83, 38, 58, NULL, NULL),
(84, 39, 57, '2026-03-10 14:25:44', NULL),
(85, 39, 58, NULL, NULL),
(86, 40, 57, '2026-03-10 14:25:54', NULL),
(87, 40, 58, NULL, NULL),
(88, 41, 57, '2026-03-10 14:26:19', NULL),
(89, 41, 58, NULL, NULL),
(90, 42, 57, '2026-03-10 14:34:11', NULL),
(91, 42, 58, NULL, NULL),
(92, 43, 58, '2026-03-10 14:34:15', NULL),
(93, 43, 57, NULL, NULL),
(94, 44, 58, '2026-03-10 14:34:25', NULL),
(95, 44, 57, NULL, NULL),
(96, 45, 57, '2026-03-10 14:34:37', NULL),
(97, 45, 58, NULL, NULL),
(98, 46, 57, '2026-03-10 14:34:58', NULL),
(99, 46, 58, NULL, NULL),
(100, 47, 58, '2026-03-10 14:35:08', NULL),
(101, 47, 57, NULL, NULL),
(102, 48, 58, '2026-03-10 14:35:16', NULL),
(103, 48, 57, NULL, NULL),
(104, 49, 57, '2026-03-10 14:37:42', NULL),
(105, 49, 58, NULL, NULL),
(106, 50, 57, '2026-03-10 14:37:57', NULL),
(107, 50, 58, NULL, NULL),
(108, 51, 58, '2026-03-10 14:38:00', NULL),
(109, 51, 57, NULL, NULL),
(110, 52, 57, '2026-03-10 14:38:04', NULL),
(111, 52, 58, NULL, NULL),
(112, 53, 58, '2026-03-10 14:38:09', NULL),
(113, 53, 57, NULL, NULL),
(114, 54, 57, '2026-03-10 14:38:17', NULL),
(115, 54, 58, NULL, NULL),
(116, 55, 57, '2026-03-10 14:38:22', NULL),
(117, 55, 58, NULL, NULL),
(118, 56, 57, '2026-03-10 14:38:47', '2026-03-10 14:38:51'),
(119, 56, 58, NULL, NULL),
(120, 57, 57, '2026-03-10 14:56:31', NULL),
(121, 57, 58, NULL, NULL),
(122, 58, 57, '2026-03-10 14:56:46', NULL),
(123, 58, 58, NULL, NULL),
(124, 59, 58, '2026-03-10 14:56:52', NULL),
(125, 59, 57, NULL, NULL),
(126, 60, 57, '2026-03-10 14:59:44', NULL),
(127, 60, 58, NULL, NULL),
(128, 61, 58, '2026-03-10 14:59:53', NULL),
(129, 61, 57, NULL, NULL),
(130, 62, 57, '2026-03-10 15:37:30', NULL),
(131, 62, 58, NULL, NULL),
(132, 63, 57, '2026-03-10 15:37:34', NULL),
(133, 63, 58, NULL, NULL),
(134, 64, 58, '2026-03-10 15:37:40', NULL),
(135, 64, 57, NULL, NULL),
(136, 65, 58, '2026-03-10 15:37:58', NULL),
(137, 65, 57, NULL, NULL),
(138, 66, 57, '2026-03-10 15:38:17', NULL),
(139, 66, 58, NULL, NULL),
(140, 67, 58, '2026-03-10 15:38:20', NULL),
(141, 67, 57, NULL, NULL),
(142, 68, 58, '2026-03-10 15:38:57', NULL),
(143, 68, 57, NULL, NULL),
(144, 69, 57, '2026-03-10 15:39:01', NULL),
(145, 69, 58, NULL, NULL),
(146, 70, 58, '2026-03-10 15:39:04', NULL),
(147, 70, 57, NULL, NULL),
(148, 71, 57, '2026-03-10 15:39:22', NULL),
(149, 71, 58, NULL, NULL),
(150, 72, 58, '2026-03-10 15:39:25', NULL),
(151, 72, 57, NULL, NULL),
(152, 73, 58, '2026-03-10 15:39:30', NULL),
(153, 73, 57, NULL, NULL),
(154, 74, 57, '2026-03-10 15:39:39', NULL),
(155, 74, 58, NULL, NULL),
(156, 75, 58, '2026-03-10 15:39:53', NULL),
(157, 75, 57, NULL, NULL),
(158, 76, 58, '2026-03-10 15:39:55', NULL),
(159, 76, 57, NULL, NULL),
(160, 77, 58, '2026-03-10 15:40:12', '2026-03-10 15:40:18'),
(161, 77, 57, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `milestone_definitions`
--

CREATE TABLE `milestone_definitions` (
  `milestone_id` int(10) UNSIGNED NOT NULL,
  `badge_id` int(10) UNSIGNED NOT NULL,
  `milestone_type` enum('xp','level','course_completion','grade','streak') NOT NULL,
  `threshold_value` int(11) NOT NULL,
  `description` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `milestone_definitions`
--

INSERT INTO `milestone_definitions` (`milestone_id`, `badge_id`, `milestone_type`, `threshold_value`, `description`) VALUES
(1, 6, 'level', 5, 'Reach level 5'),
(2, 3, 'streak', 7, 'Maintain 7-day learning streak'),
(3, 2, 'grade', 100, 'Score 100% on any assessment'),
(4, 7, 'grade', 95, 'Maintain 95% average across all courses'),
(5, 8, 'streak', 30, 'Maintain 30-day consistent learning streak');

-- --------------------------------------------------------

--
-- Table structure for table `notifications`
--

CREATE TABLE `notifications` (
  `notification_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `notification_type` enum('announcement','grade','assignment','message','deadline','system') NOT NULL,
  `title` varchar(255) NOT NULL,
  `body` text NOT NULL,
  `related_entity_type` varchar(50) DEFAULT NULL,
  `related_entity_id` bigint(20) UNSIGNED DEFAULT NULL,
  `announcement_id` bigint(20) UNSIGNED DEFAULT NULL,
  `is_read` tinyint(1) DEFAULT 0,
  `read_at` timestamp NULL DEFAULT NULL,
  `priority` enum('low','medium','high','urgent') DEFAULT 'medium',
  `action_url` varchar(500) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `notifications`
--

INSERT INTO `notifications` (`notification_id`, `user_id`, `notification_type`, `title`, `body`, `related_entity_type`, `related_entity_id`, `announcement_id`, `is_read`, `read_at`, `priority`, `action_url`, `created_at`) VALUES
(1, 21, '', 'Assignment Due Soon', 'Assignment 1: Programming Basics is due tomorrow.', 'assignment', 1, NULL, 0, NULL, 'medium', NULL, '2025-01-31 08:00:00'),
(2, 7, 'assignment', 'New Assignment Posted', 'Assignment 1 is now available', NULL, NULL, NULL, 1, NULL, 'medium', NULL, '2025-02-01 08:00:00'),
(3, 7, 'grade', 'Grade Posted', 'Your grade for Assignment 1 has been posted', NULL, NULL, NULL, 0, NULL, 'medium', NULL, '2025-02-16 08:00:00'),
(4, 21, 'announcement', 'New Announcement', 'Dr. Ibrahim Ali posted a new announcement in CS101.', 'announcement', 1, NULL, 1, NULL, 'medium', NULL, '2025-01-20 09:05:00'),
(5, 8, 'grade', 'Grade Posted', 'Your grade for Assignment 1 has been posted', NULL, NULL, NULL, 1, NULL, 'medium', NULL, '2025-02-16 08:15:00'),
(6, 9, 'deadline', 'Assignment Due Soon', 'Assignment 1 due in 2 days', NULL, NULL, NULL, 0, NULL, 'high', NULL, '2025-02-13 07:00:00'),
(7, 21, 'message', 'Message Received', 'Dr. Ibrahim Ali replied to your message about Assignment 1.', 'message', 2, NULL, 1, NULL, 'medium', NULL, '2025-01-28 15:50:00'),
(8, 22, 'grade', 'Grade Posted', 'Your grade for Quiz 1 has been posted.', 'quiz', 1, NULL, 0, NULL, 'medium', NULL, '2025-02-03 11:00:00'),
(10, 58, 'announcement', 'Test Notification', 'This is a test notification from admin', NULL, NULL, NULL, 0, NULL, 'high', NULL, '2026-03-03 00:10:09'),
(14, 58, 'announcement', 'Important Announcement', 'All students must submit assignments by Friday', NULL, NULL, NULL, 0, NULL, 'high', '/assignments', '2026-03-03 00:23:24'),
(16, 58, 'announcement', 'Important Announcement', 'All students must submit assignments by Friday', NULL, NULL, NULL, 0, NULL, 'high', '/assignments', '2026-03-03 18:34:09'),
(22, 58, 'announcement', 'Important Announcement', 'All students must submit assignments by Friday', NULL, NULL, NULL, 0, NULL, 'high', '/assignments', '2026-03-05 19:16:29');

-- --------------------------------------------------------

--
-- Table structure for table `notification_preferences`
--

CREATE TABLE `notification_preferences` (
  `preference_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `email_enabled` tinyint(1) DEFAULT 1,
  `push_enabled` tinyint(1) DEFAULT 1,
  `sms_enabled` tinyint(1) DEFAULT 0,
  `announcement_email` tinyint(1) DEFAULT 1,
  `grade_email` tinyint(1) DEFAULT 1,
  `assignment_email` tinyint(1) DEFAULT 1,
  `message_email` tinyint(1) DEFAULT 1,
  `deadline_reminder_days` int(11) DEFAULT 2,
  `quiet_hours_start` time DEFAULT NULL,
  `quiet_hours_end` time DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `notification_preferences`
--

INSERT INTO `notification_preferences` (`preference_id`, `user_id`, `email_enabled`, `push_enabled`, `sms_enabled`, `announcement_email`, `grade_email`, `assignment_email`, `message_email`, `deadline_reminder_days`, `quiet_hours_start`, `quiet_hours_end`, `created_at`, `updated_at`) VALUES
(1, 7, 1, 1, 0, 1, 1, 1, 1, 2, '22:00:00', '07:00:00', '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(2, 8, 1, 0, 0, 1, 1, 0, 1, 3, '23:00:00', '08:00:00', '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(3, 9, 0, 1, 0, 0, 1, 1, 0, 1, '21:00:00', '06:00:00', '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(4, 10, 1, 1, 0, 1, 0, 1, 1, 2, '22:00:00', '07:00:00', '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(5, 11, 1, 1, 1, 1, 1, 1, 1, 5, '23:00:00', '09:00:00', '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(6, 12, 1, 0, 0, 1, 1, 0, 0, 2, '22:00:00', '07:00:00', '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(7, 57, 1, 0, 0, 1, 1, 1, 0, 3, NULL, NULL, '2026-03-03 00:10:14', '2026-03-05 19:16:29');

-- --------------------------------------------------------

--
-- Table structure for table `office_hour_appointments`
--

CREATE TABLE `office_hour_appointments` (
  `appointment_id` bigint(20) UNSIGNED NOT NULL,
  `slot_id` bigint(20) UNSIGNED NOT NULL,
  `student_id` bigint(20) UNSIGNED NOT NULL,
  `appointment_date` date NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  `topic` varchar(255) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `status` enum('booked','confirmed','cancelled','completed','no_show') DEFAULT 'booked',
  `cancelled_by` bigint(20) UNSIGNED DEFAULT NULL,
  `cancelled_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `office_hour_slots`
--

CREATE TABLE `office_hour_slots` (
  `slot_id` bigint(20) UNSIGNED NOT NULL,
  `instructor_id` bigint(20) UNSIGNED NOT NULL,
  `day_of_week` enum('monday','tuesday','wednesday','thursday','friday','saturday','sunday') NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  `location` varchar(255) DEFAULT NULL,
  `mode` enum('in_person','online','hybrid') DEFAULT 'in_person',
  `meeting_url` varchar(500) DEFAULT NULL,
  `max_appointments` int(11) DEFAULT 4,
  `is_recurring` tinyint(1) DEFAULT 1,
  `effective_from` date DEFAULT NULL,
  `effective_until` date DEFAULT NULL,
  `status` enum('active','cancelled','suspended') DEFAULT 'active',
  `notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `offline_sync_queue`
--

CREATE TABLE `offline_sync_queue` (
  `sync_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `entity_type` varchar(50) NOT NULL,
  `entity_id` bigint(20) UNSIGNED DEFAULT NULL,
  `action` enum('create','update','delete') NOT NULL,
  `data_snapshot` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `sync_status` enum('pending','synced','failed','conflict') DEFAULT 'pending',
  `attempt_count` int(11) DEFAULT 0,
  `error_message` text DEFAULT NULL,
  `client_timestamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `synced_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `offline_sync_queue`
--

INSERT INTO `offline_sync_queue` (`sync_id`, `user_id`, `entity_type`, `entity_id`, `action`, `data_snapshot`, `sync_status`, `attempt_count`, `error_message`, `client_timestamp`, `synced_at`, `created_at`) VALUES
(1, 7, 'assignment_submission', 5, 'create', '{\"assignment_id\": 2, \"submission_text\": \"x = 5\\ny = 10\\nprint(x + y)\"}', 'synced', 1, NULL, '2025-02-14 16:30:00', '2025-02-14 16:31:15', '2025-11-20 13:43:00'),
(2, 8, 'activity_log', NULL, 'create', '{\"activity_type\": \"view\", \"entity_type\": \"course_material\", \"entity_id\": 3}', 'synced', 1, NULL, '2025-02-14 17:45:00', '2025-02-14 17:46:03', '2025-11-20 13:43:00'),
(3, 9, 'quiz_answer', 15, 'update', '{\"answer_text\": \"Updated answer\", \"question_id\": 4}', 'pending', 0, NULL, '2025-02-15 08:20:00', NULL, '2025-11-20 13:43:00'),
(4, 10, 'forum_post', NULL, 'create', '{\"title\": \"New question\", \"content\": \"How do I...\"}', 'failed', 2, NULL, '2025-02-15 09:00:00', NULL, '2025-11-20 13:43:00');

-- --------------------------------------------------------

--
-- Table structure for table `password_resets`
--

CREATE TABLE `password_resets` (
  `reset_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `reset_token` varchar(255) NOT NULL,
  `expires_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `used` tinyint(1) DEFAULT 0,
  `used_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `password_resets`
--

INSERT INTO `password_resets` (`reset_id`, `user_id`, `reset_token`, `expires_at`, `used`, `used_at`, `created_at`) VALUES
(6, 59, '82d37db17f4603125601d3d8d0826fa52429f091ab9aebe30edd73b8296838c0', '2026-03-02 14:27:06', 0, NULL, '2026-03-02 13:27:06');

-- --------------------------------------------------------

--
-- Table structure for table `payment_transactions`
--

CREATE TABLE `payment_transactions` (
  `transaction_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `course_id` bigint(20) UNSIGNED DEFAULT NULL,
  `amount` decimal(10,2) DEFAULT NULL,
  `currency` varchar(3) DEFAULT 'USD',
  `payment_method` enum('credit_card','paypal','bank_transfer') DEFAULT NULL,
  `transaction_status` enum('pending','completed','failed','refunded') DEFAULT NULL,
  `payment_gateway_ref` varchar(255) DEFAULT NULL,
  `paid_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `payment_transactions`
--

INSERT INTO `payment_transactions` (`transaction_id`, `user_id`, `course_id`, `amount`, `currency`, `payment_method`, `transaction_status`, `payment_gateway_ref`, `paid_at`, `created_at`) VALUES
(1, 7, NULL, 299.99, 'USD', 'credit_card', 'completed', 'stripe_ch_1234567890', '2025-01-10 13:30:00', '2025-11-20 13:43:01'),
(2, 8, NULL, 299.99, 'USD', 'paypal', 'completed', 'paypal_txn_9876543210', '2025-01-11 08:15:00', '2025-11-20 13:43:01'),
(3, 9, 2, 399.99, 'USD', 'credit_card', 'completed', 'stripe_ch_0987654321', '2025-01-12 12:20:00', '2025-11-20 13:43:01'),
(4, 10, NULL, 299.99, 'USD', 'credit_card', 'failed', 'stripe_ch_1111111111', '2025-11-20 13:43:01', '2025-11-20 13:43:01'),
(5, 11, 3, 349.99, 'USD', 'bank_transfer', 'pending', 'bank_ref_555555', '2025-11-20 13:43:01', '2025-11-20 13:43:01');

-- --------------------------------------------------------

--
-- Table structure for table `peer_reviews`
--

CREATE TABLE `peer_reviews` (
  `review_id` bigint(20) UNSIGNED NOT NULL,
  `submission_id` bigint(20) UNSIGNED NOT NULL,
  `reviewer_id` bigint(20) UNSIGNED NOT NULL,
  `reviewee_id` bigint(20) UNSIGNED NOT NULL,
  `review_text` text DEFAULT NULL,
  `rating` decimal(3,2) DEFAULT NULL,
  `criteria_scores` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `status` enum('pending','submitted','acknowledged') DEFAULT 'pending',
  `submitted_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `performance_metrics`
--

CREATE TABLE `performance_metrics` (
  `metric_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `course_id` bigint(20) UNSIGNED NOT NULL,
  `metric_name` varchar(100) NOT NULL,
  `metric_value` decimal(10,2) NOT NULL,
  `calculation_date` date NOT NULL,
  `trend` enum('improving','stable','declining') DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `permissions`
--

CREATE TABLE `permissions` (
  `permission_id` int(10) UNSIGNED NOT NULL,
  `permission_name` varchar(100) NOT NULL,
  `permission_description` text DEFAULT NULL,
  `module` varchar(50) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `permissions`
--

INSERT INTO `permissions` (`permission_id`, `permission_name`, `permission_description`, `module`, `created_at`) VALUES
(1, 'view_courses', 'View course information', 'courses', '2025-11-20 13:42:59'),
(2, 'enroll_courses', 'Enroll in courses', 'courses', '2025-11-20 13:42:59'),
(3, 'create_courses', 'Create new courses', 'courses', '2025-11-20 13:42:59'),
(4, 'manage_grades', 'Manage student grades', 'grading', '2025-11-20 13:42:59'),
(5, 'take_attendance', 'Mark student attendance', 'attendance', '2025-11-20 13:42:59'),
(6, 'view_reports', 'View analytics reports', 'reports', '2025-11-20 13:42:59'),
(7, 'manage_users', 'Manage user accounts', 'users', '2025-11-20 13:42:59'),
(8, 'system_settings', 'Access system settings', 'admin', '2025-11-20 13:42:59');

-- --------------------------------------------------------

--
-- Table structure for table `points_rules`
--

CREATE TABLE `points_rules` (
  `rule_id` int(10) UNSIGNED NOT NULL,
  `action_type` varchar(50) NOT NULL,
  `points_value` int(11) NOT NULL,
  `description` text DEFAULT NULL,
  `multiplier` decimal(3,2) DEFAULT 1.00,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `points_rules`
--

INSERT INTO `points_rules` (`rule_id`, `action_type`, `points_value`, `description`, `multiplier`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 'quiz_completion', 10, 'Complete a quiz', 1.00, 1, '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(2, 'assignment_submission', 15, 'Submit an assignment on time', 1.00, 1, '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(3, 'perfect_attendance', 5, 'Attend a class session', 1.00, 1, '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(4, 'perfect_score', 50, 'Get 100% on assignment/quiz', 1.50, 1, '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(5, 'early_submission', 20, 'Submit assignment early', 1.00, 1, '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(6, 'daily_login', 2, 'Log in to the platform', 1.00, 1, '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(7, 'forum_post', 5, 'Create a helpful forum post', 1.00, 1, '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(8, 'peer_review', 10, 'Complete a peer review', 1.00, 1, '2025-11-20 13:43:00', '2025-11-20 13:43:00');

-- --------------------------------------------------------

--
-- Table structure for table `programs`
--

CREATE TABLE `programs` (
  `program_id` bigint(20) UNSIGNED NOT NULL,
  `department_id` bigint(20) UNSIGNED NOT NULL,
  `program_name` varchar(200) NOT NULL,
  `program_code` varchar(20) NOT NULL,
  `degree_type` enum('bachelor','master','phd','diploma','certificate') DEFAULT NULL,
  `duration_years` int(11) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `status` enum('active','inactive') DEFAULT 'active',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `programs`
--

INSERT INTO `programs` (`program_id`, `department_id`, `program_name`, `program_code`, `degree_type`, `duration_years`, `description`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 'Updated Program', 'BCS', 'bachelor', 4, 'Undergraduate program in Computer Science', 'active', '2025-11-20 13:42:59', '2026-03-02 23:28:59'),
(2, 1, 'Master of Computer Science', 'MCS', 'master', 2, 'Graduate program in Computer Science', 'active', '2025-11-20 13:42:59', '2025-11-20 13:42:59'),
(3, 2, 'Bachelor of Mathematics', 'BMATH', 'bachelor', 4, 'Undergraduate program in Mathematics', 'active', '2025-11-20 13:42:59', '2025-11-20 13:42:59'),
(4, 4, 'Bachelor of Business Administration', 'BBA', 'bachelor', 4, 'Undergraduate business program', 'active', '2025-11-20 13:42:59', '2025-11-20 13:42:59'),
(5, 5, 'Bachelor of Engineering', 'BE', 'bachelor', 4, 'Undergraduate engineering program', 'active', '2025-11-20 13:42:59', '2025-11-20 13:42:59'),
(6, 3, 'MBA', 'MBA', 'master', 2, 'Master of Business Administration', 'active', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(7, 4, 'BS Data Science', 'BS-DS', 'bachelor', 4, 'Bachelor of Science in Data Science', 'active', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(8, 4, 'Certificate Data Analytics', 'CERT-DA', 'certificate', 1, 'Certificate in Data Analytics', 'active', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(9, 5, 'BA English Literature', 'BA-ENG', 'bachelor', 4, 'Bachelor of Arts in English Literature', 'active', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(10, 5, 'BA Arabic Language', 'BA-AR', 'bachelor', 4, 'Bachelor of Arts in Arabic Language and Culture', 'active', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(11, 6, 'BS Mathematics', 'BS-MATH', 'bachelor', 4, 'Bachelor of Science in Mathematics', 'active', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(12, 6, 'BS Physics', 'BS-PHYS', 'bachelor', 4, 'Bachelor of Science in Physics', 'active', '2024-09-01 08:00:00', '2024-09-01 08:00:00'),
(15, 1, 'Test Prog Z2', 'TPZ2', 'bachelor', 4, NULL, 'active', '2026-03-02 13:31:14', '2026-03-02 13:31:14'),
(16, 1, 'AutoProg', 'AP1', 'bachelor', 4, NULL, 'active', '2026-03-02 13:49:20', '2026-03-02 13:49:20'),
(17, 1, 'Test Program', 'TP01', 'bachelor', 4, 'A test program', 'active', '2026-03-02 23:28:59', '2026-03-02 23:28:59');

-- --------------------------------------------------------

--
-- Table structure for table `quizzes`
--

CREATE TABLE `quizzes` (
  `quiz_id` bigint(20) UNSIGNED NOT NULL,
  `course_id` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `instructions` text DEFAULT NULL,
  `quiz_type` enum('practice','graded','midterm','final') DEFAULT 'graded',
  `time_limit_minutes` int(11) DEFAULT NULL,
  `max_attempts` int(11) DEFAULT 1,
  `passing_score` decimal(5,2) DEFAULT NULL,
  `randomize_questions` tinyint(1) DEFAULT 0,
  `show_correct_answers` tinyint(1) DEFAULT 1,
  `show_answers_after` enum('immediate','after_due','never') DEFAULT 'after_due',
  `available_from` timestamp NULL DEFAULT NULL,
  `available_until` timestamp NULL DEFAULT NULL,
  `weight` decimal(5,2) DEFAULT 0.00,
  `status` enum('draft','published','closed','archived') DEFAULT 'draft',
  `created_by` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `quizzes`
--

INSERT INTO `quizzes` (`quiz_id`, `course_id`, `title`, `description`, `instructions`, `quiz_type`, `time_limit_minutes`, `max_attempts`, `passing_score`, `randomize_questions`, `show_correct_answers`, `show_answers_after`, `available_from`, `available_until`, `weight`, `status`, `created_by`, `created_at`, `updated_at`, `deleted_at`) VALUES
(1, 1, 'Updated Quiz Title', 'Quick assessment of fundamental programming concepts', 'Answer all questions', 'graded', 45, 1, 12.00, 1, 1, 'after_due', NULL, NULL, 10.00, 'published', 8, '2025-01-25 08:00:00', '2026-03-07 18:26:59', NULL),
(2, 1, 'Quiz 2: Control Flow', 'Test knowledge of conditionals and loops', 'Answer all questions', 'graded', 20, 1, 12.00, 1, 1, 'after_due', NULL, NULL, 10.00, 'draft', 8, '2025-02-01 08:00:00', '2025-02-01 08:00:00', NULL),
(3, 2, 'Quiz 1: Arrays and Lists', 'Understanding arrays', NULL, 'graded', 60, 1, 75.00, 0, 1, 'after_due', '2025-02-14 22:00:00', '2025-02-25 21:59:59', 15.00, 'draft', 3, '2025-11-20 13:42:59', '2025-11-20 13:42:59', NULL),
(4, 3, 'Quiz 1: Array and Linked Lists', 'Assessment of array and linked list concepts', 'Answer all questions', 'graded', 20, 1, 15.00, 1, 0, 'after_due', NULL, NULL, 10.00, 'draft', 10, '2025-02-03 08:00:00', '2025-02-03 08:00:00', NULL),
(5, 5, 'Quiz 1: OOP Principles', 'Test understanding of object-oriented programming', 'Answer all questions', 'graded', 25, 1, 12.00, 1, 1, 'after_due', NULL, NULL, 10.00, 'draft', 12, '2025-02-05 08:00:00', '2025-02-05 08:00:00', NULL),
(6, 9, 'Quiz 1: Statistical Concepts', 'Assessment of probability and statistics fundamentals', 'Answer all questions', 'graded', 30, 1, 12.00, 0, 1, 'after_due', NULL, NULL, 10.00, 'draft', 16, '2025-02-07 08:00:00', '2025-02-07 08:00:00', NULL),
(7, 1, 'Updated Merge Quiz', 'Testing', NULL, 'practice', 30, 3, 60.00, 1, 1, 'after_due', '2026-03-01 00:00:00', '2026-12-31 23:59:59', 0.00, 'draft', 58, '2026-03-02 14:10:15', '2026-03-02 14:10:25', '2026-03-02 14:10:25'),
(8, 1, 'Midterm Quiz: Arrays and Data Structures', 'This quiz covers chapters 1-5', 'Answer all questions. No partial credit.', 'graded', 60, 2, 70.00, 0, 1, 'after_due', '2026-03-15 09:00:00', '2026-03-22 23:59:59', 15.00, 'draft', 59, '2026-03-02 14:34:32', '2026-03-02 14:34:32', NULL),
(9, 1, 'Midterm Quiz: Arrays and Data Structures', 'This quiz covers chapters 1-5', 'Answer all questions. No partial credit.', 'graded', 60, 2, 70.00, 0, 1, 'after_due', '2026-03-15 09:00:00', '2026-03-22 23:59:59', 15.00, 'draft', 59, '2026-03-02 14:34:35', '2026-03-02 14:34:35', NULL),
(10, 1, 'PM Test Quiz Fixed', 'A quiz from test', 'Answer all', 'graded', 30, 2, 60.00, 1, 1, 'after_due', '2026-03-01 00:00:00', '2026-06-30 23:59:59', 10.00, 'draft', 58, '2026-03-02 23:44:03', '2026-03-02 23:44:03', NULL),
(11, 1, 'Updated Quiz', 'A quiz from test script', 'Answer all questions', 'graded', 45, 2, 60.00, 1, 1, 'after_due', '2026-03-01 00:00:00', '2026-06-30 23:59:59', 10.00, 'draft', 58, '2026-03-02 23:47:22', '2026-03-02 23:47:22', NULL),
(12, 1, 'Midterm Quiz: Data Structures', 'Covers arrays, linked lists, and trees', 'Answer all questions. Time limit applies.', 'graded', 45, 2, 60.00, 1, 1, 'after_due', '2026-04-01 09:00:00', '2026-04-15 23:59:59', 15.00, 'draft', 58, '2026-03-02 23:52:00', '2026-03-02 23:52:00', NULL),
(13, 1, 'Midterm Quiz: Data Structures', 'Covers arrays, linked lists, and trees', 'Answer all questions. Time limit applies.', 'graded', 45, 2, 60.00, 1, 1, 'after_due', '2026-04-01 09:00:00', '2026-04-15 23:59:59', 15.00, 'draft', 58, '2026-03-03 00:23:21', '2026-03-03 00:23:21', NULL),
(14, 1, 'Midterm Quiz: Data Structures', 'Covers arrays, linked lists, and trees', 'Answer all questions. Time limit applies.', 'graded', 45, 2, 60.00, 1, 1, 'after_due', '2026-04-01 09:00:00', '2026-04-15 23:59:59', 15.00, 'draft', 58, '2026-03-03 18:34:06', '2026-03-03 18:34:06', NULL),
(15, 1, 'Midterm Quiz: Data Structures', 'Covers arrays, linked lists, and trees', 'Answer all questions. Time limit applies.', 'graded', 45, 2, 60.00, 1, 1, 'after_due', '2026-04-01 09:00:00', '2026-04-15 23:59:59', 15.00, 'published', 58, '2026-03-05 19:16:26', '2026-03-07 18:27:08', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `quiz_answers`
--

CREATE TABLE `quiz_answers` (
  `answer_id` bigint(20) UNSIGNED NOT NULL,
  `attempt_id` bigint(20) UNSIGNED NOT NULL,
  `question_id` bigint(20) UNSIGNED NOT NULL,
  `answer_text` text DEFAULT NULL,
  `selected_option` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `is_correct` tinyint(1) DEFAULT NULL,
  `points_earned` decimal(5,2) DEFAULT 0.00,
  `answered_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `quiz_attempts`
--

CREATE TABLE `quiz_attempts` (
  `attempt_id` bigint(20) UNSIGNED NOT NULL,
  `quiz_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `attempt_number` int(11) NOT NULL,
  `started_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `submitted_at` timestamp NULL DEFAULT NULL,
  `score` decimal(5,2) DEFAULT NULL,
  `time_taken_minutes` int(11) DEFAULT NULL,
  `status` enum('in_progress','submitted','graded','abandoned') DEFAULT 'in_progress',
  `ip_address` varchar(45) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `quiz_attempts`
--

INSERT INTO `quiz_attempts` (`attempt_id`, `quiz_id`, `user_id`, `attempt_number`, `started_at`, `submitted_at`, `score`, `time_taken_minutes`, `status`, `ip_address`) VALUES
(5, 1, 57, 1, '2026-03-02 14:09:06', '2026-03-02 14:10:20', 0.00, 1, 'graded', NULL),
(6, 10, 57, 1, '2026-03-02 23:44:03', '2026-03-02 23:44:03', 0.00, 0, 'graded', NULL),
(7, 11, 57, 1, '2026-03-02 23:47:22', '2026-03-02 23:47:22', 0.00, 0, 'graded', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `quiz_difficulty_levels`
--

CREATE TABLE `quiz_difficulty_levels` (
  `difficulty_id` int(10) UNSIGNED NOT NULL,
  `level_name` varchar(50) NOT NULL,
  `difficulty_value` int(11) NOT NULL,
  `description` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `quiz_difficulty_levels`
--

INSERT INTO `quiz_difficulty_levels` (`difficulty_id`, `level_name`, `difficulty_value`, `description`) VALUES
(1, 'Easy', 1, 'Basic level questions'),
(2, 'Medium', 2, 'Intermediate level questions'),
(3, 'Hard', 3, 'Advanced level questions'),
(5, 'Very Hard', 5, 'Expert level - synthesis and evaluation');

-- --------------------------------------------------------

--
-- Table structure for table `quiz_questions`
--

CREATE TABLE `quiz_questions` (
  `question_id` bigint(20) UNSIGNED NOT NULL,
  `quiz_id` bigint(20) UNSIGNED NOT NULL,
  `question_text` text NOT NULL,
  `question_type` enum('mcq','true_false','short_answer','essay','matching') NOT NULL,
  `options` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `correct_answer` text DEFAULT NULL,
  `explanation` text DEFAULT NULL,
  `points` decimal(5,2) DEFAULT 1.00,
  `difficulty_level_id` int(10) UNSIGNED DEFAULT NULL,
  `order_index` int(11) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `quiz_questions`
--

INSERT INTO `quiz_questions` (`question_id`, `quiz_id`, `question_text`, `question_type`, `options`, `correct_answer`, `explanation`, `points`, `difficulty_level_id`, `order_index`, `created_at`, `updated_at`) VALUES
(1, 1, 'Updated: What is the time complexity of binary search?', '', NULL, NULL, NULL, 15.00, NULL, 0, '2025-01-25 08:00:00', '2026-03-05 19:16:27'),
(2, 1, 'Which of the following is not a data type?', '', NULL, NULL, NULL, 4.00, NULL, 1, '2025-01-25 08:00:00', '2026-03-05 19:16:27'),
(3, 1, 'What does IDE stand for?', '', NULL, NULL, NULL, 4.00, NULL, 2, '2025-01-25 08:00:00', '2026-03-05 19:16:27'),
(4, 1, 'True or False: Comments improve code readability.', 'true_false', NULL, NULL, NULL, 4.00, NULL, 3, '2025-01-25 08:00:00', '2026-03-05 19:16:27'),
(5, 3, 'What is the time complexity of accessing an element in an array by index?', 'mcq', '[\"O(1)\", \"O(n)\", \"O(log n)\", \"O(n^2)\"]', '0', 'Array access by index is constant time', 15.00, 2, 1, '2025-11-20 13:42:59', '2025-11-20 13:42:59'),
(6, 2, 'What is the output of the loop: for(int i=0; i<3; i++)?', '', NULL, NULL, NULL, 4.00, NULL, 1, '2025-02-01 08:00:00', '2026-03-01 14:55:40'),
(7, 2, 'Which statement is used to skip an iteration in a loop?', '', NULL, NULL, NULL, 4.00, NULL, 2, '2025-02-01 08:00:00', '2026-03-01 14:55:40'),
(8, 2, 'What is the purpose of an if-else statement?', '', NULL, NULL, NULL, 4.00, NULL, 3, '2025-02-01 08:00:00', '2026-03-01 14:55:40'),
(9, 2, 'True or False: A switch statement can only handle integers.', 'true_false', NULL, NULL, NULL, 4.00, NULL, 4, '2025-02-01 08:00:00', '2026-03-01 14:55:40'),
(10, 2, 'Describe the difference between while and do-while loops.', 'short_answer', NULL, NULL, NULL, 4.00, NULL, 5, '2025-02-01 08:00:00', '2026-03-01 14:55:40'),
(11, 3, 'What is the time complexity of array access?', '', NULL, NULL, NULL, 5.00, NULL, 1, '2025-01-26 08:00:00', '2026-03-01 14:55:40'),
(12, 3, 'Explain how a linked list differs from an array.', 'short_answer', NULL, NULL, NULL, 5.00, NULL, 2, '2025-01-26 08:00:00', '2026-03-01 14:55:40'),
(13, 3, 'What is the advantage of a linked list over an array?', '', NULL, NULL, NULL, 5.00, NULL, 3, '2025-01-26 08:00:00', '2026-03-01 14:55:40'),
(14, 3, 'True or False: Linked lists allow constant-time access to elements.', 'true_false', NULL, NULL, NULL, 5.00, NULL, 4, '2025-01-26 08:00:00', '2026-03-01 14:55:40'),
(15, 4, 'What is encapsulation?', '', NULL, NULL, NULL, 5.00, NULL, 1, '2025-02-03 08:00:00', '2026-03-01 14:55:40'),
(16, 4, 'Describe inheritance with an example.', 'short_answer', NULL, NULL, NULL, 5.00, NULL, 2, '2025-02-03 08:00:00', '2026-03-01 14:55:40'),
(17, 4, 'What are the four pillars of OOP?', '', NULL, NULL, NULL, 5.00, NULL, 3, '2025-02-03 08:00:00', '2026-03-01 14:55:40'),
(18, 4, 'True or False: A class can inherit from multiple classes in Java.', 'true_false', NULL, NULL, NULL, 5.00, NULL, 4, '2025-02-03 08:00:00', '2026-03-01 14:55:40'),
(19, 4, 'What is the difference between a class and an object?', 'short_answer', NULL, NULL, NULL, 5.00, NULL, 5, '2025-02-03 08:00:00', '2026-03-01 14:55:40'),
(21, 10, 'What is binary search complexity?', 'mcq', '[\"O(1)\",\"O(log n)\",\"O(n)\",\"O(n log n)\"]', 'O(log n)', 'Binary search halves the space', 10.00, 1, 0, '2026-03-02 23:44:03', '2026-03-02 23:44:19'),
(22, 11, 'Updated: What is binary search complexity?', 'mcq', '[\"O(1)\",\"O(log n)\",\"O(n)\",\"O(n log n)\"]', 'O(log n)', 'Binary search halves the search space each step', 15.00, 1, 0, '2026-03-02 23:47:22', '2026-03-02 23:47:22'),
(23, 1, 'What is the time complexity of binary search?', 'mcq', '[\"O(1)\",\"O(log n)\",\"O(n)\",\"O(n log n)\"]', 'O(log n)', 'Binary search divides the search space in half each iteration', 10.00, 1, 1, '2026-03-02 23:52:00', '2026-03-02 23:52:00'),
(24, 1, 'What is the time complexity of binary search?', 'mcq', '[\"O(1)\",\"O(log n)\",\"O(n)\",\"O(n log n)\"]', 'O(log n)', 'Binary search divides the search space in half each iteration', 10.00, 1, 1, '2026-03-03 00:23:22', '2026-03-03 00:23:22'),
(25, 1, 'What is the time complexity of binary search?', 'mcq', '[\"O(1)\",\"O(log n)\",\"O(n)\",\"O(n log n)\"]', 'O(log n)', 'Binary search divides the search space in half each iteration', 10.00, 1, 1, '2026-03-03 18:34:06', '2026-03-03 18:34:06'),
(26, 1, 'What is the time complexity of binary search?', 'mcq', '[\"O(1)\",\"O(log n)\",\"O(n)\",\"O(n log n)\"]', 'O(log n)', 'Binary search divides the search space in half each iteration', 10.00, 1, 1, '2026-03-05 19:16:27', '2026-03-05 19:16:27');

-- --------------------------------------------------------

--
-- Table structure for table `report_templates`
--

CREATE TABLE `report_templates` (
  `template_id` bigint(20) UNSIGNED NOT NULL,
  `template_name` varchar(255) NOT NULL,
  `template_type` enum('student','course','attendance','grade','analytics','custom') NOT NULL,
  `template_structure` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `description` text DEFAULT NULL,
  `created_by` bigint(20) UNSIGNED NOT NULL,
  `is_system_template` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `report_templates`
--

INSERT INTO `report_templates` (`template_id`, `template_name`, `template_type`, `template_structure`, `description`, `created_by`, `is_system_template`, `created_at`, `updated_at`) VALUES
(1, 'Student Progress Report', 'student', '{\"sections\": [\"enrollment\", \"grades\", \"attendance\", \"participation\"]}', 'Comprehensive student progress report', 1, 1, '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(2, 'Course Analytics Report', 'course', '{\"sections\": [\"enrollment_stats\", \"grade_distribution\", \"attendance_rate\", \"engagement\"]}', 'Detailed course performance analytics', 1, 1, '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(3, 'Attendance Summary', 'attendance', '{\"sections\": [\"daily_attendance\", \"student_records\", \"trends\"]}', 'Attendance tracking report', 1, 1, '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(4, 'Grade Distribution Report', 'grade', '{\"sections\": [\"grade_breakdown\", \"statistics\", \"comparison\"]}', 'Grade distribution and statistics', 1, 1, '2025-11-20 13:43:00', '2025-11-20 13:43:00');

-- --------------------------------------------------------

--
-- Table structure for table `rewards`
--

CREATE TABLE `rewards` (
  `reward_id` int(10) UNSIGNED NOT NULL,
  `reward_name` varchar(100) NOT NULL,
  `reward_description` text DEFAULT NULL,
  `reward_type` enum('badge','title','avatar','theme','feature_unlock','certificate') NOT NULL,
  `reward_value` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `points_cost` int(11) DEFAULT 0,
  `achievement_id` int(10) UNSIGNED DEFAULT NULL,
  `is_available` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `rewards`
--

INSERT INTO `rewards` (`reward_id`, `reward_name`, `reward_description`, `reward_type`, `reward_value`, `points_cost`, `achievement_id`, `is_available`, `created_at`) VALUES
(1, 'Premium Badge', 'Unlock a premium profile badge', 'badge', NULL, 500, NULL, 1, '2025-11-20 13:43:00'),
(2, 'Custom Title', 'Get a custom profile title', 'title', NULL, 300, NULL, 1, '2025-11-20 13:43:00');

-- --------------------------------------------------------

--
-- Table structure for table `reward_redemptions`
--

CREATE TABLE `reward_redemptions` (
  `redemption_id` bigint(20) UNSIGNED NOT NULL,
  `reward_id` int(10) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `points_spent` int(11) NOT NULL,
  `redemption_status` enum('pending','approved','delivered','rejected','cancelled') DEFAULT 'pending',
  `delivery_details` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `approved_by` bigint(20) UNSIGNED DEFAULT NULL,
  `approved_at` timestamp NULL DEFAULT NULL,
  `redeemed_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `reward_redemptions`
--

INSERT INTO `reward_redemptions` (`redemption_id`, `reward_id`, `user_id`, `points_spent`, `redemption_status`, `delivery_details`, `approved_by`, `approved_at`, `redeemed_at`) VALUES
(1, 1, 7, 500, 'delivered', '{\"reward_type\": \"badge\", \"badge_id\": 7}', 1, '2025-02-10 08:00:00', '2025-02-10 07:30:00'),
(2, 2, 8, 300, 'approved', '{\"reward_type\": \"title\", \"title\": \"Quiz Master\"}', 1, '2025-02-12 12:00:00', '2025-02-12 11:45:00'),
(3, 1, 9, 250, 'pending', '{\"reward_type\": \"badge\", \"badge_id\": 3}', NULL, NULL, '2025-02-14 14:20:00');

-- --------------------------------------------------------

--
-- Table structure for table `roles`
--

CREATE TABLE `roles` (
  `role_id` int(10) UNSIGNED NOT NULL,
  `role_name` varchar(50) NOT NULL,
  `role_description` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `roles`
--

INSERT INTO `roles` (`role_id`, `role_name`, `role_description`, `created_at`) VALUES
(1, 'student', 'Regular student user', '2025-11-20 13:42:59'),
(2, 'instructor', 'Course instructor', '2025-11-20 13:42:59'),
(3, 'teaching_assistant', 'Teaching Assistant', '2025-11-20 13:42:59'),
(4, 'admin', 'System Administrator', '2025-11-20 13:42:59'),
(5, 'department_head', 'Department Head', '2025-11-20 13:42:59'),
(6, 'it_admin', 'IT Administrator', '2026-03-02 13:17:36');

-- --------------------------------------------------------

--
-- Table structure for table `role_permissions`
--

CREATE TABLE `role_permissions` (
  `role_permission_id` bigint(20) UNSIGNED NOT NULL,
  `role_id` int(10) UNSIGNED NOT NULL,
  `permission_id` int(10) UNSIGNED NOT NULL,
  `granted_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `role_permissions`
--

INSERT INTO `role_permissions` (`role_permission_id`, `role_id`, `permission_id`, `granted_at`) VALUES
(3, 2, 1, '2025-11-20 13:42:59'),
(4, 2, 3, '2025-11-20 13:42:59'),
(5, 2, 4, '2025-11-20 13:42:59'),
(6, 2, 5, '2025-11-20 13:42:59'),
(7, 2, 6, '2025-11-20 13:42:59'),
(8, 3, 1, '2025-11-20 13:42:59'),
(9, 3, 4, '2025-11-20 13:42:59'),
(10, 3, 5, '2025-11-20 13:42:59'),
(11, 4, 1, '2025-11-20 13:42:59'),
(12, 4, 2, '2025-11-20 13:42:59'),
(13, 4, 3, '2025-11-20 13:42:59'),
(14, 4, 4, '2025-11-20 13:42:59'),
(15, 4, 5, '2025-11-20 13:42:59'),
(16, 4, 6, '2025-11-20 13:42:59'),
(17, 4, 7, '2025-11-20 13:42:59'),
(18, 4, 8, '2025-11-20 13:42:59'),
(19, 5, 1, '2025-11-20 13:42:59'),
(20, 5, 3, '2025-11-20 13:42:59'),
(21, 5, 4, '2025-11-20 13:42:59'),
(22, 5, 6, '2025-11-20 13:42:59'),
(23, 1, 1, '2026-03-10 18:15:14'),
(24, 1, 2, '2026-03-10 18:15:14');

-- --------------------------------------------------------

--
-- Table structure for table `rubrics`
--

CREATE TABLE `rubrics` (
  `rubric_id` bigint(20) UNSIGNED NOT NULL,
  `course_id` bigint(20) UNSIGNED NOT NULL,
  `rubric_name` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `criteria` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `total_points` decimal(5,2) DEFAULT 100.00,
  `created_by` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `rubrics`
--

INSERT INTO `rubrics` (`rubric_id`, `course_id`, `rubric_name`, `description`, `criteria`, `total_points`, `created_by`, `created_at`, `updated_at`) VALUES
(2, 2, 'Data Structures Project Rubric', 'Rubric for DS projects', '{\"criteria\": [{\"name\": \"Implementation\", \"points\": 50}, {\"name\": \"Efficiency\", \"points\": 25}, {\"name\": \"Documentation\", \"points\": 15}, {\"name\": \"Presentation\", \"points\": 10}]}', 100.00, 3, '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(3, 1, 'Test Rubric Z', 'A rubric', NULL, 100.00, 58, '2026-03-02 13:34:36', '2026-03-02 13:34:36'),
(4, 1, 'AutoRubric', 'Test rubric', NULL, 100.00, 58, '2026-03-02 13:51:17', '2026-03-02 13:51:17'),
(5, 1, 'MergeTest', 'Post-merge', NULL, 100.00, 58, '2026-03-02 14:04:57', '2026-03-02 14:04:57'),
(6, 1, 'Essay Grading Rubric', 'Rubric for evaluating research essays', '[{\"name\":\"Content\",\"maxPoints\":40,\"description\":\"Quality of content\"},{\"name\":\"Grammar\",\"maxPoints\":30,\"description\":\"Writing quality\"},{\"name\":\"Format\",\"maxPoints\":30,\"description\":\"Proper formatting\"}]', 100.00, 58, '2026-03-02 23:32:57', '2026-03-02 23:32:57'),
(7, 1, 'Test Rubric PM', 'Test rubric from postman test', '[{\"name\":\"Content\",\"maxPoints\":40},{\"name\":\"Grammar\",\"maxPoints\":30},{\"name\":\"Format\",\"maxPoints\":30}]', 100.00, 58, '2026-03-02 23:42:38', '2026-03-02 23:42:38'),
(8, 1, 'Test Rubric PM', 'Test rubric from postman test', '[{\"name\":\"Content\",\"maxPoints\":40},{\"name\":\"Grammar\",\"maxPoints\":30},{\"name\":\"Format\",\"maxPoints\":30}]', 100.00, 58, '2026-03-02 23:47:21', '2026-03-02 23:47:21'),
(9, 1, 'Essay Grading Rubric', 'Rubric for evaluating research essays', '[{\"name\":\"Content\",\"maxPoints\":40,\"description\":\"Quality of content\"},{\"name\":\"Grammar\",\"maxPoints\":30,\"description\":\"Writing quality\"},{\"name\":\"Format\",\"maxPoints\":30,\"description\":\"Proper formatting\"}]', 100.00, 58, '2026-03-02 23:51:57', '2026-03-02 23:51:57'),
(10, 1, 'Essay Grading Rubric', 'Rubric for evaluating research essays', '[{\"name\":\"Content\",\"maxPoints\":40,\"description\":\"Quality of content\"},{\"name\":\"Grammar\",\"maxPoints\":30,\"description\":\"Writing quality\"},{\"name\":\"Format\",\"maxPoints\":30,\"description\":\"Proper formatting\"}]', 100.00, 58, '2026-03-03 00:23:19', '2026-03-03 00:23:19'),
(11, 1, 'Essay Grading Rubric', 'Rubric for evaluating research essays', '[{\"name\":\"Content\",\"maxPoints\":40,\"description\":\"Quality of content\"},{\"name\":\"Grammar\",\"maxPoints\":30,\"description\":\"Writing quality\"},{\"name\":\"Format\",\"maxPoints\":30,\"description\":\"Proper formatting\"}]', 100.00, 58, '2026-03-03 18:34:03', '2026-03-03 18:34:03'),
(12, 1, 'Essay Grading Rubric', 'Rubric for evaluating research essays', '[{\"name\":\"Content\",\"maxPoints\":40,\"description\":\"Quality of content\"},{\"name\":\"Grammar\",\"maxPoints\":30,\"description\":\"Writing quality\"},{\"name\":\"Format\",\"maxPoints\":30,\"description\":\"Proper formatting\"}]', 100.00, 58, '2026-03-05 19:16:24', '2026-03-05 19:16:24');

-- --------------------------------------------------------

--
-- Table structure for table `scheduled_notifications`
--

CREATE TABLE `scheduled_notifications` (
  `scheduled_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `notification_type` varchar(50) NOT NULL,
  `title` varchar(255) NOT NULL,
  `body` text NOT NULL,
  `scheduled_for` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `status` enum('pending','sent','failed','cancelled') DEFAULT 'pending',
  `created_by` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `sent_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `scheduled_notifications`
--

INSERT INTO `scheduled_notifications` (`scheduled_id`, `user_id`, `notification_type`, `title`, `body`, `scheduled_for`, `status`, `created_by`, `created_at`, `sent_at`) VALUES
(1, 7, 'deadline_reminder', 'Assignment Due Tomorrow', 'Assignment 2 is due tomorrow at 11:59 PM', '2025-02-27 07:00:00', 'pending', 2, '2025-11-20 13:43:00', NULL),
(2, 8, 'deadline_reminder', 'Quiz Available', 'Quiz 2 is now available. Due date: March 10', '2025-03-01 06:00:00', 'pending', 2, '2025-11-20 13:43:00', NULL),
(3, 9, 'course_update', 'New Material Posted', 'Lecture 5 slides have been uploaded', '2025-02-20 08:00:00', 'sent', 2, '2025-11-20 13:43:00', NULL),
(4, 10, 'grade_available', 'Grade Posted', 'Your grade for Assignment 1 is now available', '2025-02-16 08:00:00', 'sent', 2, '2025-11-20 13:43:00', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `search_history`
--

CREATE TABLE `search_history` (
  `history_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `search_query` varchar(500) NOT NULL,
  `search_filters` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `results_count` int(11) DEFAULT 0,
  `selected_result_id` bigint(20) UNSIGNED DEFAULT NULL,
  `selected_result_type` varchar(50) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `search_history`
--

INSERT INTO `search_history` (`history_id`, `user_id`, `search_query`, `search_filters`, `results_count`, `selected_result_id`, `selected_result_type`, `created_at`) VALUES
(1, 7, 'python loops', '{\"entity_types\": [\"material\", \"post\"]}', 8, 5, 'post', '2025-11-20 13:43:00'),
(2, 7, 'assignment 1', '{\"course_id\": 1}', 3, 1, 'assignment', '2025-11-20 13:43:00'),
(3, 8, 'hello world', '{}', 12, 3, 'assignment', '2025-11-20 13:43:00'),
(4, 9, 'data structures', '{\"entity_types\": [\"course\", \"material\"]}', 15, NULL, NULL, '2025-11-20 13:43:00'),
(5, 10, 'syllabus', '{\"course_id\": 1}', 2, 1, 'material', '2025-11-20 13:43:00');

-- --------------------------------------------------------

--
-- Table structure for table `search_index`
--

CREATE TABLE `search_index` (
  `index_id` bigint(20) UNSIGNED NOT NULL,
  `entity_type` enum('course','material','user','announcement','assignment','quiz','file','post') NOT NULL,
  `entity_id` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(255) DEFAULT NULL,
  `content` text DEFAULT NULL,
  `keywords` text DEFAULT NULL,
  `metadata` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `search_vector` text DEFAULT NULL,
  `visibility` enum('public','students','instructors','private') DEFAULT 'students',
  `campus_id` bigint(20) UNSIGNED DEFAULT NULL,
  `course_id` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `search_index`
--

INSERT INTO `search_index` (`index_id`, `entity_type`, `entity_id`, `title`, `content`, `keywords`, `metadata`, `search_vector`, `visibility`, `campus_id`, `course_id`, `created_at`, `updated_at`) VALUES
(1, 'course', 1, 'Introduction to Programming', 'Basic programming concepts using Python. Learn variables, loops, functions, and more.', 'python, programming, cs101, beginner, coding', NULL, NULL, 'students', 1, 1, '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(2, 'material', 2, 'Lecture 1: Introduction to Programming', 'Overview of programming concepts, what is programming, why learn Python, basic syntax', 'lecture, introduction, python basics, programming concepts', NULL, NULL, 'students', 1, 1, '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(3, 'assignment', 1, 'Assignment 1: Hello World', 'Create your first Python program that prints Hello World', 'assignment, hello world, python, beginner', NULL, NULL, 'students', 1, 1, '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(4, 'announcement', 1, 'Course Start', 'Welcome to CS101! Please review the syllabus', 'welcome, syllabus, course start', NULL, NULL, 'students', 1, 1, '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(5, 'post', 1, 'Help with loops', 'Can someone explain how for loops work in Python?', 'loops, for loop, help, question, python', NULL, NULL, 'students', 1, 1, '2025-11-20 13:43:00', '2025-11-20 13:43:00');

-- --------------------------------------------------------

--
-- Table structure for table `security_logs`
--

CREATE TABLE `security_logs` (
  `log_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `event_type` enum('login','logout','failed_login','password_change','permission_change','suspicious_activity') NOT NULL,
  `severity` enum('low','medium','high','critical') DEFAULT 'medium',
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `details` text DEFAULT NULL,
  `is_resolved` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `security_logs`
--

INSERT INTO `security_logs` (`log_id`, `user_id`, `event_type`, `severity`, `ip_address`, `user_agent`, `details`, `is_resolved`, `created_at`) VALUES
(1, 7, 'login', 'low', '192.168.1.100', NULL, 'Successful login', 1, '2025-11-20 13:43:00'),
(2, 8, 'login', 'low', '192.168.1.101', NULL, 'Successful login', 1, '2025-11-20 13:43:00'),
(3, NULL, 'failed_login', 'medium', '192.168.1.200', NULL, 'Failed login attempt for email: unknown@test.com', 1, '2025-11-20 13:43:00'),
(4, 7, 'password_change', 'low', '192.168.1.100', NULL, 'User changed password', 1, '2025-11-20 13:43:00'),
(5, NULL, 'failed_login', 'high', '203.0.113.45', NULL, 'Multiple failed login attempts detected', 0, '2025-11-20 13:43:00'),
(6, 1, 'permission_change', 'medium', '192.168.1.1', NULL, 'Admin modified user role permissions', 1, '2025-11-20 13:43:00');

-- --------------------------------------------------------

--
-- Table structure for table `semesters`
--

CREATE TABLE `semesters` (
  `semester_id` bigint(20) UNSIGNED NOT NULL,
  `semester_name` varchar(100) NOT NULL,
  `semester_code` varchar(20) NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `registration_start` date DEFAULT NULL,
  `registration_end` date DEFAULT NULL,
  `status` enum('upcoming','active','completed') DEFAULT 'upcoming',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `semesters`
--

INSERT INTO `semesters` (`semester_id`, `semester_name`, `semester_code`, `start_date`, `end_date`, `registration_start`, `registration_end`, `status`, `created_at`) VALUES
(1, 'Fall 2026 Updated', 'FALL2024', '2024-09-01', '2024-12-20', '2024-08-15', '2024-08-31', 'completed', '2024-08-01 00:00:00'),
(2, 'Spring 2025', 'SPR2025', '2025-01-15', '2025-05-30', '2024-12-15', '2025-01-10', 'active', '2024-12-01 00:00:00'),
(3, 'Summer 2025', 'SU2025', '2025-06-01', '2025-08-15', '2025-05-01', '2025-05-25', 'upcoming', '2025-11-20 13:42:59'),
(4, 'Fall 2025', 'F2025', '2025-09-01', '2025-12-31', '2025-08-01', '2025-08-25', 'active', '2025-11-26 18:54:24'),
(7, 'Fall 2027', 'F2027', '2027-09-01', '2027-12-20', '2027-08-01', '2027-08-25', 'upcoming', '2025-11-26 19:28:01'),
(12, 'Fall 2026', 'F26', '2026-09-01', '2026-12-15', '2026-08-01', '2026-08-30', 'upcoming', '2026-03-02 13:29:55'),
(13, 'Auto Sem', 'AS1', '2027-01-01', '2027-05-01', '2026-12-01', '2026-12-31', 'upcoming', '2026-03-02 13:49:23'),
(14, 'Fall 2026', 'F2026', '2026-09-01', '2026-12-31', '2026-08-01', '2026-08-25', 'upcoming', '2026-03-02 23:29:09');

-- --------------------------------------------------------

--
-- Table structure for table `server_monitoring`
--

CREATE TABLE `server_monitoring` (
  `monitor_id` bigint(20) UNSIGNED NOT NULL,
  `server_name` varchar(100) NOT NULL,
  `cpu_usage` decimal(5,2) DEFAULT NULL,
  `memory_usage` decimal(5,2) DEFAULT NULL,
  `disk_usage` decimal(5,2) DEFAULT NULL,
  `status` enum('healthy','warning','critical','down') DEFAULT 'healthy',
  `uptime_seconds` bigint(20) DEFAULT NULL,
  `checked_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `sessions`
--

CREATE TABLE `sessions` (
  `session_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `session_token` varchar(255) NOT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `device_type` enum('web','mobile_ios','mobile_android','tablet','desktop') DEFAULT 'web',
  `expires_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `remember_me` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `sessions`
--

INSERT INTO `sessions` (`session_id`, `user_id`, `session_token`, `ip_address`, `user_agent`, `device_type`, `expires_at`, `created_at`, `remember_me`) VALUES
(3, 17, 'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJhbWlyMTIzQGNhbXB1cy5lZHUiLCJ1c2VySWQiOjE3LCJ0eXBlIjoicmVmcmVzaCIsImlhdCI6MTc2NDAyNjY5MywiZXhwIjoxNzY0NjMxNDkzfQ.dTVCFc4JBCHqkmDxVHDFVIGA9lC4i6gxKEgoRTxhMotnFpABxg18leyHqXa8lCa0w3UjDUmhDb5nGPv5HivZ1g', NULL, NULL, 'web', '2025-12-01 23:24:53', '2025-11-24 23:24:53', 0),
(6, 18, 'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJhbWlyLnVzZXJAY2FtcHVzLmVkdSIsInVzZXJJZCI6MTgsInR5cGUiOiJyZWZyZXNoIiwiaWF0IjoxNzY0MDI3MjE1LCJleHAiOjE3NjQ2MzIwMTV9.2Oyabfn3xjY7uGXALDWwz4qmG3DxwEIqK4iFk04yaEFeyxg25h0sHRSCa6F70eam5EvFzGt5NUoYzfinBvH0Wg', NULL, NULL, 'web', '2025-12-01 23:33:35', '2025-11-24 23:33:35', 0),
(13, 19, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjE5LCJlbWFpbCI6ImFtaXIxMjM0QGNhbXB1cy5lZHUiLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc2NDA5MzY0MSwiZXhwIjoxNzY0Njk4NDQxfQ.Jyu8OKNLHwj6zdhuiayBFJ3mqWT0JMZfiOLY3qNdHRk', '127.0.0.1', 'Thunder Client (https://www.thunderclient.com)', 'desktop', '2025-12-02 18:00:41', '2025-11-25 18:00:41', 0),
(57, 25, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjI1LCJlbWFpbCI6ImFtMzU2NjE0NkBnbWFpbC5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc2NDE3MDY4NywiZXhwIjoxNzY0Nzc1NDg3fQ.5HxOlRDsGhTupfn6oCmbnv01mKg77Zzhxg2Ht3MQBT0', '127.0.0.1', 'Thunder Client (https://www.thunderclient.com)', 'desktop', '2025-12-03 15:24:47', '2025-11-26 15:24:47', 0),
(60, 25, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjI1LCJlbWFpbCI6ImFtMzU2NjE0NkBnbWFpbC5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc2NDE3Mzg3NCwiZXhwIjoxNzY0Nzc4Njc0fQ.BtVUgOvdcFbaLLEj6kYP4Xm96krdJGKQGp1jN2OQjFo', '127.0.0.1', 'PostmanRuntime/7.49.1', 'desktop', '2025-12-03 16:17:54', '2025-11-26 16:17:54', 0),
(61, 25, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjI1LCJlbWFpbCI6ImFtMzU2NjE0NkBnbWFpbC5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc2NDE3OTYxMiwiZXhwIjoxNzY0Nzg0NDEyfQ.5Sq0Y0FarUgt4W3AEhIUbrZaZKSY8zkRU45ZwGhW95U', '127.0.0.1', 'PostmanRuntime/7.49.1', 'desktop', '2025-12-03 17:53:32', '2025-11-26 17:53:32', 0),
(62, 29, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjI5LCJlbWFpbCI6ImFtMzU2NjE0N0BnbWFpbC5jb20iLCJyb2xlcyI6WyJhZG1pbiJdLCJpYXQiOjE3NjQxODAyNDcsImV4cCI6MTc2NDc4NTA0N30.-VOieVPihJLvMNHJbj9_cSItzW9kCZLa5NKB4s_Nfvw', '127.0.0.1', 'PostmanRuntime/7.49.1', 'desktop', '2025-12-03 18:04:07', '2025-11-26 18:04:07', 0),
(63, 29, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjI5LCJlbWFpbCI6ImFtMzU2NjE0N0BnbWFpbC5jb20iLCJyb2xlcyI6WyJhZG1pbiJdLCJpYXQiOjE3NjQxODQ5MDYsImV4cCI6MTc2NDc4OTcwNn0.jLUlH_1BzJM0eXbgtiec_6IFyVKl4FB24k1Vi82_k-Y', '127.0.0.1', 'PostmanRuntime/7.49.1', 'desktop', '2025-12-03 19:21:46', '2025-11-26 19:21:46', 0),
(68, 30, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjMwLCJlbWFpbCI6ImFtMzU2NjE0M0BnbWFpbC5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc2NDIwMzg2MiwiZXhwIjoxNzY0ODA4NjYyfQ.OMFNxg2GN8WeDxbypZBVcDnP6JrM5fHZ_8X71z_h6D0', '192.168.1.3', 'Dart/3.9 (dart:io)', 'desktop', '2025-12-04 00:37:42', '2025-11-27 00:37:42', 0),
(70, 29, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjI5LCJlbWFpbCI6ImFtMzU2NjE0N0BnbWFpbC5jb20iLCJyb2xlcyI6WyJhZG1pbiJdLCJpYXQiOjE3NjQyNjI2OTYsImV4cCI6MTc2NDg2NzQ5Nn0.4UhMJ0d-5lPlvL18DDwH9B1Wfx_BYd-DbcC5Bn3DSb8', '127.0.0.1', 'PostmanRuntime/7.49.1', 'desktop', '2025-12-04 16:58:16', '2025-11-27 16:58:16', 0),
(71, 29, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjI5LCJlbWFpbCI6ImFtMzU2NjE0N0BnbWFpbC5jb20iLCJyb2xlcyI6WyJhZG1pbiJdLCJpYXQiOjE3NjQyNjUxNjYsImV4cCI6MTc2NDg2OTk2Nn0.6K6yofEYOZby2sq8EqAQBYElbSWMdTX7E0zQoSbVhb4', '127.0.0.1', 'PostmanRuntime/7.49.1', 'desktop', '2025-12-04 17:39:26', '2025-11-27 17:39:26', 0),
(72, 29, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjI5LCJlbWFpbCI6ImFtMzU2NjE0N0BnbWFpbC5jb20iLCJyb2xlcyI6WyJhZG1pbiJdLCJpYXQiOjE3NjQyNzMwMTcsImV4cCI6MTc2NDg3NzgxN30.Qs4njygOc58XwoshQk6H-Ghp6AJlaHkp6mta-8BbRF8', '127.0.0.1', 'PostmanRuntime/7.49.1', 'desktop', '2025-12-04 19:50:18', '2025-11-27 19:50:17', 0),
(73, 29, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjI5LCJlbWFpbCI6ImFtMzU2NjE0N0BnbWFpbC5jb20iLCJyb2xlcyI6WyJhZG1pbiJdLCJpYXQiOjE3NjQ1MTc2NzcsImV4cCI6MTc2NTEyMjQ3N30.QTWYpvG_pZUJTKsnoT1Bwv-wOsljbjBsAr0PGx6PU-E', '127.0.0.1', 'PostmanRuntime/7.49.1', 'desktop', '2025-12-07 15:47:58', '2025-11-30 15:47:57', 0),
(74, 25, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjI1LCJlbWFpbCI6ImFtMzU2NjE0NkBnbWFpbC5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc2NDUxODY5OSwiZXhwIjoxNzY1MTIzNDk5fQ.jNoA5aP62LQ3PaLbImvakM-weKxjK4TWV8L-ciucodc', '127.0.0.1', 'PostmanRuntime/7.49.1', 'desktop', '2025-12-07 16:05:00', '2025-11-30 16:04:59', 0),
(75, 29, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjI5LCJlbWFpbCI6ImFtMzU2NjE0N0BnbWFpbC5jb20iLCJyb2xlcyI6WyJhZG1pbiJdLCJpYXQiOjE3NjQ1MTg3NDMsImV4cCI6MTc2NTEyMzU0M30.pcWldW3f_2BMukMzvJ7W3FSu9GmRkEXJAdHFgrg2kJU', '127.0.0.1', 'PostmanRuntime/7.49.1', 'desktop', '2025-12-07 16:05:43', '2025-11-30 16:05:43', 0),
(76, 34, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjM0LCJlbWFpbCI6ImFtaXJfc3R1ZGVudEBjYW1wdXMuZWR1Iiwicm9sZXMiOlsic3R1ZGVudCJdLCJpYXQiOjE3NjQ1MTg5MzMsImV4cCI6MTc2NTEyMzczM30.lea9RdkUal-n0yuoJSk0V6IVBZdW1npMS2szF_S_mYM', '127.0.0.1', 'PostmanRuntime/7.49.1', 'desktop', '2025-12-07 16:08:53', '2025-11-30 16:08:53', 0),
(77, 29, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjI5LCJlbWFpbCI6ImFtMzU2NjE0N0BnbWFpbC5jb20iLCJyb2xlcyI6WyJhZG1pbiJdLCJpYXQiOjE3NjQ1MjA3NjQsImV4cCI6MTc2NTEyNTU2NH0.Je4CVQwAgdJ4D8xc09v0Im3iDiIuJReAX3eIlVHOY5A', '127.0.0.1', 'PostmanRuntime/7.49.1', 'desktop', '2025-12-07 16:39:24', '2025-11-30 16:39:24', 0),
(78, 36, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjM2LCJlbWFpbCI6ImpvaG4uZG9lQGV4YW1wbGUuY29tIiwicm9sZXMiOlsic3R1ZGVudCJdLCJpYXQiOjE3NzIwNDYyNTIsImV4cCI6MTc3MjY1MTA1Mn0.mdvXYoVNU6LLKHUjWmqPQTRTMytD13pRJJ4vgmRB16c', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 'desktop', '2026-03-04 19:04:12', '2026-02-25 19:04:12', 0),
(79, 36, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjM2LCJlbWFpbCI6ImpvaG4uZG9lQGV4YW1wbGUuY29tIiwicm9sZXMiOlsic3R1ZGVudCJdLCJpYXQiOjE3NzIwNTAyNzQsImV4cCI6MTc3MjY1NTA3NH0.cbFdJWpQVM2tMCVcczIUJGcYqZrAH1SulzVLX9e9Lks', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 'desktop', '2026-03-04 20:11:14', '2026-02-25 20:11:14', 0),
(80, 56, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU2LCJlbWFpbCI6ImFkbWludGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJhZG1pbiJdLCJpYXQiOjE3NzIzODI4MjgsImV4cCI6MTc3Mjk4NzYyOH0.mwUp2Z_FXBSPWy4Mv5EGWqs8r5SYP7fn0l0-9qeZ9Yg', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 'desktop', '2026-03-08 16:33:48', '2026-03-01 16:33:48', 0),
(81, 56, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU2LCJlbWFpbCI6ImFkbWludGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJhZG1pbiJdLCJpYXQiOjE3NzIzOTkwMDMsImV4cCI6MTc3MzAwMzgwM30.-wZ1fnzgbIgErm9zeDCY8d8bJkTLWQLqF3JcSMrTMwI', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 'desktop', '2026-03-08 21:03:23', '2026-03-01 21:03:23', 0),
(82, 56, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU2LCJlbWFpbCI6ImFkbWludGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJhZG1pbiJdLCJpYXQiOjE3NzIzOTk3MTUsImV4cCI6MTc3MzAwNDUxNX0.qzUcx45Odur_uc_kw3EIf8x8xR3Vp27nnL6b4X6CcwM', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 'desktop', '2026-03-08 21:15:15', '2026-03-01 21:15:15', 0),
(83, 56, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU2LCJlbWFpbCI6ImFkbWludGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJhZG1pbiJdLCJpYXQiOjE3NzI0MDAwMzksImV4cCI6MTc3MzAwNDgzOX0.TC1w_AEr4Sdk4XgKB7y9Id87kDn8R92a3KA_L7eBZ40', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 'desktop', '2026-03-08 21:20:39', '2026-03-01 21:20:39', 0),
(84, 56, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU2LCJlbWFpbCI6ImFkbWludGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJhZG1pbiJdLCJpYXQiOjE3NzI0NTczNDIsImV4cCI6MTc3MzA2MjE0Mn0.DG-Gz75Hl0e1wk42Vhq3UbxJ2wZdE4JyYlqhrWLhcJo', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:15:42', '2026-03-02 13:15:42', 0),
(85, 56, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU2LCJlbWFpbCI6ImFkbWludGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJhZG1pbiJdLCJpYXQiOjE3NzI0NTczNjAsImV4cCI6MTc3MzA2MjE2MH0.q-B1Wai6zRRkKov2C97DuwoqtqFW56OFkp1tf3COMaY', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:16:00', '2026-03-02 13:16:00', 0),
(86, 56, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU2LCJlbWFpbCI6ImFkbWludGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJhZG1pbiJdLCJpYXQiOjE3NzI0NTc0MzIsImV4cCI6MTc3MzA2MjIzMn0.ZVVluOsp3Pe3ofUAQt2wo6T3pKQdUwSTlki72gFai5Y', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:17:12', '2026-03-02 13:17:12', 0),
(87, 56, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU2LCJlbWFpbCI6ImFkbWludGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJhZG1pbiJdLCJpYXQiOjE3NzI0NTc0NTUsImV4cCI6MTc3MzA2MjI1NX0.wWV6KgCFtQG8IoZUQ0maASkuuA1oaraR4EAHA2vU9_0', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:17:35', '2026-03-02 13:17:35', 0),
(88, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjQ1NzU0MSwiZXhwIjoxNzczMDYyMzQxfQ.Pk1-QGtFJ8u5kDp95n0KGN8MKTERqs6B0JU5YqEWXu8', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:19:01', '2026-03-02 13:19:01', 0),
(89, 58, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjQ1NzU0MiwiZXhwIjoxNzczMDYyMzQyfQ.kT-TXy0EvBXvaD_s72bXPv9fojopnLxUB871_ZTos6I', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:19:02', '2026-03-02 13:19:02', 0),
(90, 59, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNDU3NTQzLCJleHAiOjE3NzMwNjIzNDN9.YctRyFG-bJ9AMgGlkwLmN-UfAgxN0mzHCc1whe7J8po', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:19:03', '2026-03-02 13:19:03', 0),
(91, 60, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MjQ1NzU0NSwiZXhwIjoxNzczMDYyMzQ1fQ.5wXxyK-p2dILps__7SxwZiMnPbyHCpnwb5yJMejbrRQ', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:19:05', '2026-03-02 13:19:05', 0),
(92, 61, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzcyNDU3NTQ2LCJleHAiOjE3NzMwNjIzNDZ9.Epf4YqXyrkKSxDQ4XIQ5X18simAzm-iyGOy2WcADt7I', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:19:06', '2026-03-02 13:19:06', 0),
(93, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjQ1NzU3NSwiZXhwIjoxNzczMDYyMzc1fQ.szAOtYQNxy4m12Xx2wbs4sLkwUTmqoFfZNGsmXYyKNo', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:19:35', '2026-03-02 13:19:35', 0),
(94, 58, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjQ1NzU3NiwiZXhwIjoxNzczMDYyMzc2fQ.CTd2DU3gFlAzuGMuXaLa7gfcuc3KPCHEudOze7KL45Q', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:19:36', '2026-03-02 13:19:36', 0),
(95, 59, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNDU3NTc3LCJleHAiOjE3NzMwNjIzNzd9.y8m9TcHCMLy2-rhmURQlCduv7Ev4X5M9cpWbrvf05gA', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:19:37', '2026-03-02 13:19:37', 0),
(96, 60, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MjQ1NzU3OCwiZXhwIjoxNzczMDYyMzc4fQ.5NjZQ4_q9Eyn3sORIx5e2UAZXjMxaU_v-2ZfsUCGZ7c', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:19:38', '2026-03-02 13:19:38', 0),
(97, 61, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzcyNDU3NTc5LCJleHAiOjE3NzMwNjIzNzl9.i4vB6DEEXvhyTRYFiTeOa7GYbVTURS33HnRbH-K64-k', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:19:39', '2026-03-02 13:19:39', 0),
(98, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjQ1NzU4MCwiZXhwIjoxNzczMDYyMzgwfQ.dabDAEyusDQ0hAm3AYD_237EmE-bJhsMLz_cuhbXdRk', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:19:40', '2026-03-02 13:19:40', 0),
(100, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjQ1NzU4NSwiZXhwIjoxNzczMDYyMzg1fQ.fcWiH6Ruelqp3RW1ownzAOrktTlSDcJOxWsXx9sZCG4', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:19:45', '2026-03-02 13:19:45', 0),
(102, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjQ1NzU4OSwiZXhwIjoxNzczMDYyMzg5fQ.P0VG7CCyluCDiO6pJmne-MSi_MGlItd1SDgAB4EgxlQ', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:19:49', '2026-03-02 13:19:49', 0),
(103, 59, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNDU3NjEwLCJleHAiOjE3NzMwNjI0MTB9.BJBGBx3E8nTe48l-F64xY3eUgV3KMQfU0RpsIbayKts', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:20:10', '2026-03-02 13:20:10', 0),
(104, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjQ1NzYxMSwiZXhwIjoxNzczMDYyNDExfQ.D5BwQCTKKjOppR9aIl7OnMKfUx7gnh_zgF7fFuVFhWQ', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:20:11', '2026-03-02 13:20:11', 0),
(105, 61, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzcyNDU3NjEyLCJleHAiOjE3NzMwNjI0MTJ9.BWOdvZybSXY02RCDutG_2RA5-MsryCDq6hVLEYEB5ok', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:20:12', '2026-03-02 13:20:12', 0),
(106, 59, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNDU3NjczLCJleHAiOjE3NzMwNjI0NzN9.pOI5BzK9H3mCOEK10-SF1Q3qxMiekQHGVwgyuc9NWeU', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:21:13', '2026-03-02 13:21:13', 0),
(107, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjQ1NzY3NCwiZXhwIjoxNzczMDYyNDc0fQ.mgqDtlLTDPiaQAsT1B5e_9kEEbIk5vq2RYIbfd8FDgw', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:21:14', '2026-03-02 13:21:14', 0),
(108, 58, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjQ1NzY3NSwiZXhwIjoxNzczMDYyNDc1fQ.lxyWJDcc52TBbLfaIs19QOsmsGMbcL84jZsxIl_oRRU', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:21:15', '2026-03-02 13:21:15', 0),
(109, 60, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MjQ1NzY3NiwiZXhwIjoxNzczMDYyNDc2fQ.c9uG5yBbtYooOd-Ep6rVQP6l_cza3doBLgIXHWYTaUU', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:21:16', '2026-03-02 13:21:16', 0),
(110, 61, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzcyNDU3Njc3LCJleHAiOjE3NzMwNjI0Nzd9.5P-So3BzhXESkIHFtIP5TBIUlJs-7Uh74MpdjP5Ko0k', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:21:17', '2026-03-02 13:21:17', 0),
(111, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjQ1Nzk4MiwiZXhwIjoxNzczMDYyNzgyfQ.ENt68zQp9sbwnJIJhfvX_yVcE5tsIppZUTWslD-ZROg', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:26:22', '2026-03-02 13:26:22', 0),
(112, 58, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjQ1Nzk4MywiZXhwIjoxNzczMDYyNzgzfQ.TM6MiyoiQmEkBrEx3vljTN0J1HPSFXeHbyZktpm4VwE', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:26:23', '2026-03-02 13:26:23', 0),
(113, 59, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNDU3OTg0LCJleHAiOjE3NzMwNjI3ODR9.yzXNGiVJMzh8ZnzKd_6AUoU7hqRgeQ169liogLA4uWU', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:26:24', '2026-03-02 13:26:24', 0),
(114, 60, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MjQ1Nzk4NSwiZXhwIjoxNzczMDYyNzg1fQ.3aQWOAMw610yq1ejND3As9O3bFvW6j7E7943AF5lw9k', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:26:25', '2026-03-02 13:26:25', 0),
(115, 61, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzcyNDU3OTg2LCJleHAiOjE3NzMwNjI3ODZ9.wYsfn8IP0GB1pJS9EF-c4pGGCQS_uRXysp8NuM8pjho', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:26:26', '2026-03-02 13:26:26', 0),
(116, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjQ1ODAxNSwiZXhwIjoxNzczMDYyODE1fQ.mtMlLNgV_BqrMcZCTX5gQaV_kjqxQnYqh1ggfhqNMys', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:26:55', '2026-03-02 13:26:55', 0),
(117, 58, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjQ1ODAxNiwiZXhwIjoxNzczMDYyODE2fQ.dJR2KFPk81ACf5E0BD7r8qVxIsX0wCx6uvM5XSe_aDU', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:26:56', '2026-03-02 13:26:56', 0),
(118, 59, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNDU4MDE3LCJleHAiOjE3NzMwNjI4MTd9._JtPX6P9xBtft1AzxKZB3jw5RVYaCQbl7FYuV-qYkbA', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:26:57', '2026-03-02 13:26:57', 0),
(119, 60, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MjQ1ODAxOCwiZXhwIjoxNzczMDYyODE4fQ.s_iGGwKJFvCEj0MfK4R5sCQpMI_hmSNGyozZQ6_DTvc', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:26:58', '2026-03-02 13:26:58', 0),
(120, 61, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzcyNDU4MDIwLCJleHAiOjE3NzMwNjI4MjB9.14ikw8qmjfGYzUB46G-U5m4c1axJKLzeSsO5FyNp1Hc', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:27:00', '2026-03-02 13:27:00', 0),
(121, 59, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNDU4MDIyLCJleHAiOjE3NzMwNjI4MjJ9.XFTg2dvLrJBDzVjbc2f-rfETOvxNMmjT0S42WKLRxWM', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:27:02', '2026-03-02 13:27:02', 0),
(123, 59, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNDU4MDI1LCJleHAiOjE3NzMwNjI4MjV9.MBvenZ8of-ZATv2kG6N8oTfwdAQhP6ReTbfcTCa1Qz8', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:27:05', '2026-03-02 13:27:05', 0),
(124, 59, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNDU4MDU4LCJleHAiOjE3NzMwNjI4NTh9.RrfC4O4AxgpM52W_Ziy41v4e_LoDDhYVUl-Ql4056rc', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:27:38', '2026-03-02 13:27:38', 0),
(125, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjQ1ODEwMiwiZXhwIjoxNzczMDYyOTAyfQ.nWFDZm5LOFxkw2nJGtuUov3WshoFcEEAZUq4tPRAIvM', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:28:22', '2026-03-02 13:28:22', 0),
(126, 58, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjQ1ODEwMywiZXhwIjoxNzczMDYyOTAzfQ.FglPBPPBH7nfQBDbOe4ATwYwCkMUe-dZW0UHyhnwilA', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:28:23', '2026-03-02 13:28:23', 0),
(127, 59, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNDU4MTA0LCJleHAiOjE3NzMwNjI5MDR9.zQN36WBhyqdJaB34vs0Des643YQ9kktEdCdGc648x88', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:28:24', '2026-03-02 13:28:24', 0),
(128, 60, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MjQ1ODEwNSwiZXhwIjoxNzczMDYyOTA1fQ.Jbu5JJzEh9jyJcLvkNutoMetopqwQ9FHREH8jctfX4s', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:28:25', '2026-03-02 13:28:25', 0),
(129, 61, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzcyNDU4MTA2LCJleHAiOjE3NzMwNjI5MDZ9.xxnuVIYPJDGE6LEcKV1Qb54hBxIRxpVtQuu2lnOrqUY', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:28:26', '2026-03-02 13:28:26', 0),
(130, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjQ1ODE4NiwiZXhwIjoxNzczMDYyOTg2fQ.8ANquPJfrQYyP1ufWFKKt1clGDQuo1fY_hCU6_coPb8', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:29:46', '2026-03-02 13:29:46', 0),
(131, 58, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjQ1ODE4NywiZXhwIjoxNzczMDYyOTg3fQ.vkxq0Z_vcz0VFDpop2y25PgWlWEl6HPfHnRquBlOnQs', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:29:47', '2026-03-02 13:29:47', 0),
(132, 59, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNDU4MTg4LCJleHAiOjE3NzMwNjI5ODh9.R5i8NwvgX_tC8YNyuPbuSwYUud71Ktuut8wPcWkxNa0', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:29:48', '2026-03-02 13:29:48', 0),
(133, 60, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MjQ1ODE4OSwiZXhwIjoxNzczMDYyOTg5fQ.SfPouYynNA4bTT7poH1jRhMukqitetQYeCIMWcrwdlk', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:29:49', '2026-03-02 13:29:49', 0),
(134, 61, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzcyNDU4MTkwLCJleHAiOjE3NzMwNjI5OTB9.3E08UPLeH36Z8KFirxwYUOjMYuh08xiAykYLhltt87s', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:29:50', '2026-03-02 13:29:50', 0),
(135, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjQ1ODI2OCwiZXhwIjoxNzczMDYzMDY4fQ.npGKlX-Orcn1W8egIVgLslSSFM-iTQVgIVfb4XIh7dE', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:31:08', '2026-03-02 13:31:08', 0),
(136, 58, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjQ1ODI3MCwiZXhwIjoxNzczMDYzMDcwfQ.gx6TS_utIOkGyNDbnVwVY1rVo2Rcqcapk_Y7VfhsV20', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:31:10', '2026-03-02 13:31:10', 0),
(137, 59, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNDU4MjcxLCJleHAiOjE3NzMwNjMwNzF9.xOkZSrC1YYALcfgdb4BeYIMNOn20ynOMCdfdOLNFBwk', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:31:11', '2026-03-02 13:31:11', 0),
(138, 60, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MjQ1ODI3MiwiZXhwIjoxNzczMDYzMDcyfQ.9LParNysweYTwkWp-P04Tz7_mZb5ASEZS2ogWQfwDAY', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:31:12', '2026-03-02 13:31:12', 0),
(139, 61, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzcyNDU4MjczLCJleHAiOjE3NzMwNjMwNzN9.AWNFNy0JBYktWvEVHN5mgX7V6Fbx_cct9838H0Qa0O8', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:31:13', '2026-03-02 13:31:13', 0),
(140, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjQ1ODMzNSwiZXhwIjoxNzczMDYzMTM1fQ.RRmntGmYLwUpqT5PzHo5P-wXP0P1Ah8Kf0jv3gO0d_E', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:32:15', '2026-03-02 13:32:15', 0),
(141, 58, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjQ1ODMzNiwiZXhwIjoxNzczMDYzMTM2fQ.Zpor2RBtCgJTZSuaumuZhRmef3IqIFWsQ37xMjGyOGQ', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:32:16', '2026-03-02 13:32:16', 0),
(142, 59, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNDU4MzM3LCJleHAiOjE3NzMwNjMxMzd9.1DK98HsuxAMFfgJQ211oFzsT6k3mDQxe_jvv4SfYRcE', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:32:17', '2026-03-02 13:32:17', 0),
(143, 60, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MjQ1ODMzOCwiZXhwIjoxNzczMDYzMTM4fQ.CBWImHCs5mNGguJoAMqnfRU4oNZSCw-o33Zwr20GzlM', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:32:18', '2026-03-02 13:32:18', 0),
(144, 61, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzcyNDU4MzM5LCJleHAiOjE3NzMwNjMxMzl9.xef3Rwt29owN0tkOwz4OLyaZjYYzi8953IV3VfrbEw4', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:32:19', '2026-03-02 13:32:19', 0),
(145, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjQ1ODQ3MSwiZXhwIjoxNzczMDYzMjcxfQ.s-4GllGdMj0W2AxrhzNrV8pncDFcg9obRlOz2uh8OiE', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:34:31', '2026-03-02 13:34:31', 0),
(146, 58, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjQ1ODQ3MiwiZXhwIjoxNzczMDYzMjcyfQ.od--UovKqLmk-2rmk3fjCaIK_6517_zPgv_jN4FbNQI', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:34:32', '2026-03-02 13:34:32', 0),
(147, 59, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNDU4NDczLCJleHAiOjE3NzMwNjMyNzN9.PsAxTeZciWqpI4bEC8Nt8lP3gy3HrGwGzZvweWgAXqg', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:34:33', '2026-03-02 13:34:33', 0),
(148, 60, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MjQ1ODQ3NCwiZXhwIjoxNzczMDYzMjc0fQ.6mZYD1OulOAAImXGrSQraQknUz6eQcmQr_rikc-ORuQ', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:34:34', '2026-03-02 13:34:34', 0),
(149, 61, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzcyNDU4NDc1LCJleHAiOjE3NzMwNjMyNzV9.RnuY__lxGNOTFabgJw6VkL6M-89iD1HOrW2WoiUMBj8', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:34:35', '2026-03-02 13:34:35', 0),
(150, 58, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjQ1ODQ5NiwiZXhwIjoxNzczMDYzMjk2fQ.zxBnZnSn40-JNKGDyc7liZtel-0FoLIb7dS4rGEt7Gg', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:34:56', '2026-03-02 13:34:56', 0),
(151, 59, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNDU4NDk5LCJleHAiOjE3NzMwNjMyOTl9.jg8ytxOIilv_liCtRZmBUP-YFqfRJwLgAYUGmAUxPkg', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:34:59', '2026-03-02 13:34:59', 0),
(152, 59, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNDU5MTA3LCJleHAiOjE3NzMwNjM5MDd9.3cTCamjP8CIs4V6QQyPnHS9lvdXiaprILZHznTI83q4', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:45:07', '2026-03-02 13:45:07', 0),
(153, 59, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNDU5MTE3LCJleHAiOjE3NzMwNjM5MTd9.a-wn85SVilm1W6sBrGda79UVRprzB8NsAQCMs0295fw', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:45:17', '2026-03-02 13:45:17', 0),
(154, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjQ1OTMyOSwiZXhwIjoxNzczMDY0MTI5fQ.42V8Ox7hTEcNkiuIhyXSk7GHnscaHRDtoOeJD2Fjldw', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:48:49', '2026-03-02 13:48:49', 0),
(155, 58, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjQ1OTMzMCwiZXhwIjoxNzczMDY0MTMwfQ.8N3TcKta0n__3z0DSecx7JV5HOPz4PUva7Jw8mrb5Ik', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:48:50', '2026-03-02 13:48:50', 0),
(156, 59, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNDU5MzMxLCJleHAiOjE3NzMwNjQxMzF9.5rXS1Bog5XkhI474yKqMgctNdFaetrByXFbDyg-DB6A', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:48:51', '2026-03-02 13:48:51', 0),
(157, 60, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MjQ1OTMzMiwiZXhwIjoxNzczMDY0MTMyfQ.X1Viv9HkFImQbupphM8WLihQZiQDi8KcmQw8fKNQ-kc', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:48:52', '2026-03-02 13:48:52', 0),
(158, 61, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzcyNDU5MzMzLCJleHAiOjE3NzMwNjQxMzN9.B6bvOCg4P5J5zl9LDzrKsxNDz6ex7buN6NcZ9tXriB0', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:48:53', '2026-03-02 13:48:53', 0),
(159, 59, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNDU5MzM0LCJleHAiOjE3NzMwNjQxMzR9.IsOMY1xbVp8DlFwP3LHFMKD7gRxgqYTbh14wEIBcCZQ', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:48:54', '2026-03-02 13:48:54', 0),
(160, 59, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNDU5MzM3LCJleHAiOjE3NzMwNjQxMzd9.pur4ZKvmFB8Bksrx67QNt2AC4OW7rDPWywcudHKZ9c0', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:48:57', '2026-03-02 13:48:57', 0),
(161, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50IiwiaW5zdHJ1Y3RvciJdLCJpYXQiOjE3NzI0NTk0MDMsImV4cCI6MTc3MzA2NDIwM30.YbLv-gX9xBfFD7LrZwNbZJTfgSVEiTLfvX5IN3eChv8', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:50:03', '2026-03-02 13:50:03', 0),
(162, 58, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjQ1OTQwNSwiZXhwIjoxNzczMDY0MjA1fQ.PinnDX0_gIKwHIebnvvQ1Gct-U9nHBf6I5mo3i6ug1w', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:50:05', '2026-03-02 13:50:05', 0),
(163, 59, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNDU5NDA2LCJleHAiOjE3NzMwNjQyMDZ9.EmdYlE2-esGZhpIfJX514CP_RFA6_bZH8wO2IluHoYU', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:50:06', '2026-03-02 13:50:06', 0),
(164, 60, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MjQ1OTQwNywiZXhwIjoxNzczMDY0MjA3fQ.JBH-TpbL8tmWt_hK7wY9MTNgtSZUB-5ocH2TpxBY8II', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:50:07', '2026-03-02 13:50:07', 0),
(165, 61, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzcyNDU5NDA4LCJleHAiOjE3NzMwNjQyMDh9.eSlyY_96QSSZP8wj7EPA-DVib39XHhpI38qpvf4G1xU', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:50:08', '2026-03-02 13:50:08', 0),
(166, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50IiwiaW5zdHJ1Y3RvciJdLCJpYXQiOjE3NzI0NTk0NjMsImV4cCI6MTc3MzA2NDI2M30.Ou1OxNwxs7KxUx2ubEe13VKSxyzlkEjZsG2XCrN9Bz4', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:51:03', '2026-03-02 13:51:03', 0),
(167, 58, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjQ1OTQ2NCwiZXhwIjoxNzczMDY0MjY0fQ.2fvjZUezO8ISd2n_hkgaplkgZZhCrPPNkoH6mWHJixE', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:51:04', '2026-03-02 13:51:04', 0),
(168, 59, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNDU5NDY1LCJleHAiOjE3NzMwNjQyNjV9.9zwTLCgRB3xjcRR-d64i6gazF2V3yTj-jwSf32kaRIM', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:51:05', '2026-03-02 13:51:05', 0),
(169, 60, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MjQ1OTQ2NywiZXhwIjoxNzczMDY0MjY3fQ.TnlFpr10pa60WUq_YCrUI_AvXITsahvh2vT1hYUoiH0', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:51:07', '2026-03-02 13:51:07', 0),
(170, 61, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzcyNDU5NDY4LCJleHAiOjE3NzMwNjQyNjh9.nMlKKIM-Ncmm6C1ERTGGSEvJ18_X9SsLmtqX059HIGo', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:51:08', '2026-03-02 13:51:08', 0),
(171, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50IiwiaW5zdHJ1Y3RvciJdLCJpYXQiOjE3NzI0NTk2MzIsImV4cCI6MTc3MzA2NDQzMn0.7djQ2ZacNr7I2aHrtYgKF4l3njdk2crOlDh-OnFSOGY', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:53:52', '2026-03-02 13:53:52', 0),
(172, 59, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNDU5NjUxLCJleHAiOjE3NzMwNjQ0NTF9.3N7K5hW4CaF36mSUT_rCxS3Ow6hzT42UKp9rg8JIXdA', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:54:11', '2026-03-02 13:54:11', 0),
(173, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjQ1OTY1MywiZXhwIjoxNzczMDY0NDUzfQ.ljb3lEniXfdJn_Nu61u4ZuqxXashYTnC1wSfB9t7BYA', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:54:13', '2026-03-02 13:54:13', 0),
(174, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjQ1OTY3OCwiZXhwIjoxNzczMDY0NDc4fQ.VhG6r7R62deapTGuWLKyMCmb67z8pigGGyVvA-tVtZs', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:54:38', '2026-03-02 13:54:38', 0),
(175, 58, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjQ1OTY3OSwiZXhwIjoxNzczMDY0NDc5fQ.F4q0oiB7AORj4UPzK-hBpjs14tk2J7Jv3NK5ZtJkFoI', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:54:39', '2026-03-02 13:54:39', 0),
(176, 59, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNDU5NjgwLCJleHAiOjE3NzMwNjQ0ODB9.NZ6MdPSkBoS8rqYfgLniIz41KYaDVQX7uXUPj6XIKPQ', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:54:40', '2026-03-02 13:54:40', 0),
(177, 59, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNDU5NzM4LCJleHAiOjE3NzMwNjQ1Mzh9.2KyCcqCZqpSeg4p-Zpe0uFgPX5muuMDlBim0vhjSmvQ', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 13:55:38', '2026-03-02 13:55:38', 0),
(178, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjQ2MDI1MCwiZXhwIjoxNzczMDY1MDUwfQ.8WI-0AjH6c0tgBT9A_BK5eKj6iv3d8V6Z_HSWrpIdnE', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 14:04:10', '2026-03-02 14:04:10', 0),
(179, 58, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjQ2MDI1MiwiZXhwIjoxNzczMDY1MDUyfQ.koC88F_q0Zz2N8dNOLD0eSion03K6q8-fRWpeG2Y9kY', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 14:04:12', '2026-03-02 14:04:12', 0),
(180, 59, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNDYwMjUzLCJleHAiOjE3NzMwNjUwNTN9.B4sti42V8xEKJ6W1oZY98SxDxFKXAI1SGdyQnbZS-Co', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 14:04:13', '2026-03-02 14:04:13', 0),
(181, 60, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MjQ2MDI1NCwiZXhwIjoxNzczMDY1MDU0fQ.35FmlsSb4wpIUTK8m50RRAP1JGLHH85PgQKCV4lOPKU', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 14:04:14', '2026-03-02 14:04:14', 0),
(182, 61, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzcyNDYwMjU1LCJleHAiOjE3NzMwNjUwNTV9.8oDVVxfewDDmJwK0OahnGp4fFGgsUQOE1m0kJqU8i3I', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 14:04:15', '2026-03-02 14:04:15', 0),
(183, 59, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNDYwMjU2LCJleHAiOjE3NzMwNjUwNTZ9.bGsqwE_v-cb4YFOJXzfZm_KSahluE4tahpD9A__-Bng', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 14:04:16', '2026-03-02 14:04:16', 0),
(184, 59, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNDYwMjU5LCJleHAiOjE3NzMwNjUwNTl9.-zBpfcry7zurNLLcoAnNLpmsdA01wlbPkbOxTpKUhKs', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 14:04:19', '2026-03-02 14:04:19', 0),
(185, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjQ2MDMzNiwiZXhwIjoxNzczMDY1MTM2fQ.CYhBoQwjlyR9HhuYbyrT1tTBXyeoKfm6C_9vX1f4gNw', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 14:05:36', '2026-03-02 14:05:36', 0),
(186, 58, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjQ2MDMzNywiZXhwIjoxNzczMDY1MTM3fQ.W4q4q994_GmON9v1vhOtivKswxfQuK3jWsG8Kw9Ie3E', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 14:05:37', '2026-03-02 14:05:37', 0),
(187, 59, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNDYwMzM4LCJleHAiOjE3NzMwNjUxMzh9.gWzOD3qoziAXAPEl4anOaXzJt-7QIY1SW4tK_eBPT6k', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 14:05:38', '2026-03-02 14:05:38', 0),
(188, 60, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MjQ2MDM0MCwiZXhwIjoxNzczMDY1MTQwfQ.h2cIduQS0lg5y7RhVAdF3GCSnYo93Ujet1cdJNWCcyI', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 14:05:40', '2026-03-02 14:05:40', 0),
(189, 61, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzcyNDYwMzQxLCJleHAiOjE3NzMwNjUxNDF9.fRw_JMspiO9LoSxv69p9_SgMRBSmY9AFMogaR7T2m68', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 14:05:41', '2026-03-02 14:05:41', 0),
(190, 58, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjQ2MDQwNiwiZXhwIjoxNzczMDY1MjA2fQ.dq4Hh86dYUCqEFZNQUFzdHogiZ2RGVzOC7Bge_oKfoE', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 14:06:46', '2026-03-02 14:06:46', 0),
(191, 58, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjQ2MDQyNiwiZXhwIjoxNzczMDY1MjI2fQ.cHemDIySwY7zQ5B5VQ5RuiXKUDxDL88PJTuZfjupwKw', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 14:07:06', '2026-03-02 14:07:06', 0),
(192, 58, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjQ2MDQzNiwiZXhwIjoxNzczMDY1MjM2fQ.mWVrUk6ZvCpvoOC3kChagducxcxileZkaQht9DYT9P4', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 14:07:16', '2026-03-02 14:07:16', 0),
(193, 58, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjQ2MDQ0NiwiZXhwIjoxNzczMDY1MjQ2fQ.JBg_hSRzWLjFMBnNpguUChTe0gnfVC-Xp_54qusT4WQ', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 14:07:26', '2026-03-02 14:07:26', 0);
INSERT INTO `sessions` (`session_id`, `user_id`, `session_token`, `ip_address`, `user_agent`, `device_type`, `expires_at`, `created_at`, `remember_me`) VALUES
(194, 58, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjQ2MDQ3OSwiZXhwIjoxNzczMDY1Mjc5fQ.SR9Otm58226bB3DMsr_nHw9I_EUToc2_w2KKfXp0E_o', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 14:07:59', '2026-03-02 14:07:59', 0),
(195, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjQ2MDQ4MCwiZXhwIjoxNzczMDY1MjgwfQ.SqVCuLF51w4GrQqR5qFU_KfAD97Akqy7cAYAfXkRkWk', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 14:08:00', '2026-03-02 14:08:00', 0),
(196, 59, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNDYwNDgxLCJleHAiOjE3NzMwNjUyODF9.K3Ie0ywTyVugF46f48G1iW9s5NEhoYZvLRRbVsj_tYQ', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 14:08:01', '2026-03-02 14:08:01', 0),
(197, 58, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjQ2MDUzNywiZXhwIjoxNzczMDY1MzM3fQ.F-jNRKc9W-6aVa7DFf0wgCwXwFEOAjYN53uuov0J0Tg', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 14:08:57', '2026-03-02 14:08:57', 0),
(198, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjQ2MDUzOCwiZXhwIjoxNzczMDY1MzM4fQ.gQc_AlmLG_RSDhckbvnLpKx6Dkg7VrpkyhT2XWwEHwk', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 14:08:58', '2026-03-02 14:08:58', 0),
(199, 59, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNDYwNTM5LCJleHAiOjE3NzMwNjUzMzl9.SnFgRHPKrs8RiQxTMCYKyAQj1-oD5QTLVX4fslfXqeE', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 14:08:59', '2026-03-02 14:08:59', 0),
(200, 58, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjQ2MDYxMywiZXhwIjoxNzczMDY1NDEzfQ.f1uwEUAYji2CY19JbmQx_BQB11zyNWAaA8TjGj-Aw-A', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 14:10:13', '2026-03-02 14:10:13', 0),
(201, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjQ2MDYxNCwiZXhwIjoxNzczMDY1NDE0fQ.uyEAWXygIoPXYMr4OIOgdoWE2sU5yviS0yGEsZaLVzA', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 14:10:14', '2026-03-02 14:10:14', 0),
(202, 58, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjQ2MDY1MiwiZXhwIjoxNzczMDY1NDUyfQ.7NMsjG17GYQAyg7594QHHb2yLZXLgFQ0D_a96nvzdzc', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 14:10:52', '2026-03-02 14:10:52', 0),
(203, 58, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjQ2MDY3MCwiZXhwIjoxNzczMDY1NDcwfQ.6XYfDFdpZoNf-wyEZ6DjanbBLlr44xjNbIgYGDlK6IU', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-09 14:11:10', '2026-03-02 14:11:10', 0),
(204, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjQ2MTc4NywiZXhwIjoxNzczMDY2NTg3fQ.Kfg8lPw4LE7crt35xwdboxj3CNhC21Sy8ILflv8OoiU', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 'desktop', '2026-03-09 14:29:47', '2026-03-02 14:29:47', 0),
(205, 59, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNDYxODg4LCJleHAiOjE3NzMwNjY2ODh9.6wJB3EIlsHUztlcYLtUwQf-7_32epMRVHWZjXot2PA4', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 'desktop', '2026-03-09 14:31:28', '2026-03-02 14:31:28', 0),
(206, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjQ5MzkzMywiZXhwIjoxNzczMDk4NzMzfQ.ugxvp8JR0bfvWYV_1y5tVFP5GTsDGHnpYMKRFHe0Vl4', '127.0.0.1', 'PostmanRuntime/7.49.1', 'desktop', '2026-03-09 23:25:33', '2026-03-02 23:25:33', 0),
(207, 58, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjQ5NDAwMCwiZXhwIjoxNzczMDk4ODAwfQ.W3fzVJ_FsUKc-XJxgwHt3SykzUltBv6ClvnR01SNWeA', '127.0.0.1', 'PostmanRuntime/7.49.1', 'desktop', '2026-03-09 23:26:40', '2026-03-02 23:26:40', 0),
(208, 59, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNDk0MDE1LCJleHAiOjE3NzMwOTg4MTV9.pEu0eY5w1TJSQAhq6QlZSs48o1fNP9VkaKo8qIa17iU', '127.0.0.1', 'PostmanRuntime/7.49.1', 'desktop', '2026-03-09 23:26:55', '2026-03-02 23:26:55', 0),
(209, 60, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MjQ5NDAzMCwiZXhwIjoxNzczMDk4ODMwfQ.gc6BfnADZxsih3G6_6ZO3dVB2vz8kCuakn49996GCF0', '127.0.0.1', 'PostmanRuntime/7.49.1', 'desktop', '2026-03-09 23:27:10', '2026-03-02 23:27:10', 0),
(210, 61, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzcyNDk0MDQ1LCJleHAiOjE3NzMwOTg4NDV9.SeZgTlxobYGTg-DhCvmKjLrijrVEBO0FaFDM1lWyS9Y', '127.0.0.1', 'PostmanRuntime/7.49.1', 'desktop', '2026-03-09 23:27:25', '2026-03-02 23:27:25', 0),
(211, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjQ5NDk1NywiZXhwIjoxNzczMDk5NzU3fQ.fFJc9XrbcRYPZSLeFnBaT7VgM-OdcZ7zlaFqOZaUpRc', '127.0.0.1', NULL, '', '2026-03-09 23:42:37', '2026-03-02 23:42:37', 0),
(212, 58, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjQ5NDk1NywiZXhwIjoxNzczMDk5NzU3fQ.dnxlxXFNaTuTod8xFZ_b-doYMB5jz779_XFmVaCs3Ec', '127.0.0.1', NULL, '', '2026-03-09 23:42:37', '2026-03-02 23:42:37', 0),
(213, 59, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNDk0OTU3LCJleHAiOjE3NzMwOTk3NTd9.ta0C13xHdjVy-YTLFgFR56twhCIpFiuOV5yaTvDDSl0', '127.0.0.1', NULL, '', '2026-03-09 23:42:37', '2026-03-02 23:42:37', 0),
(214, 60, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MjQ5NDk1OCwiZXhwIjoxNzczMDk5NzU4fQ.iSemHapJbRh7KO6i1i2YHFE3FBnz0z65SP1uHxvlA9M', '127.0.0.1', NULL, '', '2026-03-09 23:42:38', '2026-03-02 23:42:38', 0),
(215, 61, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzcyNDk0OTU4LCJleHAiOjE3NzMwOTk3NTh9.2BGIcrG5W3pEVKZIqLQrXnklU3B1dkovlx7SeRyz9g4', '127.0.0.1', NULL, '', '2026-03-09 23:42:38', '2026-03-02 23:42:38', 0),
(216, 58, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjQ5NTAxMCwiZXhwIjoxNzczMDk5ODEwfQ.4JRPF_rk62ISnW10Px1pzrZCAycaYvw-a-bbL-RGaoU', '127.0.0.1', NULL, '', '2026-03-09 23:43:30', '2026-03-02 23:43:30', 0),
(217, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjQ5NTAxMCwiZXhwIjoxNzczMDk5ODEwfQ.pxjgspo8Kpcq-I3-yRizxdwkil-QoGsZzsjJ2ls7Uak', '127.0.0.1', NULL, '', '2026-03-09 23:43:30', '2026-03-02 23:43:30', 0),
(218, 58, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjQ5NTA0MywiZXhwIjoxNzczMDk5ODQzfQ.ZVEI0xKcbCQttCrL_jDn0FwrRcH7gfyP2nhTeXo8L8s', '127.0.0.1', NULL, '', '2026-03-09 23:44:03', '2026-03-02 23:44:03', 0),
(219, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjQ5NTA0MywiZXhwIjoxNzczMDk5ODQzfQ.hLY7TclThJjWx4AX50R0RlXCrXmwkdsAcuz-_er14Ik', '127.0.0.1', NULL, '', '2026-03-09 23:44:03', '2026-03-02 23:44:03', 0),
(220, 58, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjQ5NTA1OSwiZXhwIjoxNzczMDk5ODU5fQ.ICPJPd5OnNElGPWZ1Q_o9JKsObA3Z3Vm5jbq5TRiIxM', '127.0.0.1', NULL, '', '2026-03-09 23:44:19', '2026-03-02 23:44:19', 0),
(221, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjQ5NTI0MCwiZXhwIjoxNzczMTAwMDQwfQ.gKO4L31TDPmGqlEA9GvJy1hLcY9KLoqG28Gfx9hS4TU', '127.0.0.1', NULL, '', '2026-03-09 23:47:20', '2026-03-02 23:47:20', 0),
(222, 58, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjQ5NTI0MCwiZXhwIjoxNzczMTAwMDQwfQ.c7JlXXF170LFoDaL_YG4FQCRA5aB3G1U2l5ndy8HKaQ', '127.0.0.1', NULL, '', '2026-03-09 23:47:20', '2026-03-02 23:47:20', 0),
(223, 59, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNDk1MjQxLCJleHAiOjE3NzMxMDAwNDF9.DKmiUKx-_MA3XOYqZHYFJLd3H9LIBVH5GqpygqNzGeY', '127.0.0.1', NULL, '', '2026-03-09 23:47:21', '2026-03-02 23:47:21', 0),
(224, 60, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MjQ5NTI0MSwiZXhwIjoxNzczMTAwMDQxfQ.6GscVl5NMmnsPYOSoNrKkGhjs0EcRA0E9WDRBzKIPVo', '127.0.0.1', NULL, '', '2026-03-09 23:47:21', '2026-03-02 23:47:21', 0),
(225, 61, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzcyNDk1MjQxLCJleHAiOjE3NzMxMDAwNDF9.kJckShzNuMsd95Mgw3PY-F7ALycWBC61SSb7nOvQ0cA', '127.0.0.1', NULL, '', '2026-03-09 23:47:21', '2026-03-02 23:47:21', 0),
(226, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjQ5NTM4MCwiZXhwIjoxNzczMTAwMTgwfQ.dK2sdRrjmObsmhPOlrA8hgzxfKwwevlKaoSBCWovRf8', '127.0.0.1', 'PostmanRuntime/7.51.1', 'desktop', '2026-03-09 23:49:40', '2026-03-02 23:49:40', 0),
(227, 58, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjQ5NTM5OSwiZXhwIjoxNzczMTAwMTk5fQ.wCS1XWq5MAXhcZ13qISNoi0Z1bPH93QWsZfGNePs4-A', '127.0.0.1', 'PostmanRuntime/7.51.1', 'desktop', '2026-03-09 23:49:59', '2026-03-02 23:49:59', 0),
(228, 59, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNDk1NDExLCJleHAiOjE3NzMxMDAyMTF9.-BkjiWiI8X7QDIfFvH-t_TgNlzjTxj2fLZBnysEvWOQ', '127.0.0.1', 'PostmanRuntime/7.51.1', 'desktop', '2026-03-09 23:50:11', '2026-03-02 23:50:11', 0),
(229, 60, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MjQ5NTQ0MywiZXhwIjoxNzczMTAwMjQzfQ.35suJaBXCxBeDlEoHqNdokSucbz38aCf7WxCMbtOfC4', '127.0.0.1', 'PostmanRuntime/7.51.1', 'desktop', '2026-03-09 23:50:43', '2026-03-02 23:50:43', 0),
(230, 61, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzcyNDk1NDYwLCJleHAiOjE3NzMxMDAyNjB9.bZY1lQYaHZLNInLGS7CGyuJQxo1fIxXB4EkKd5ZyZx8', '127.0.0.1', 'PostmanRuntime/7.51.1', 'desktop', '2026-03-09 23:51:00', '2026-03-02 23:51:00', 0),
(231, 59, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNDk2NTkxLCJleHAiOjE3NzMxMDEzOTF9.MGweTB98iD3_jr3ErO5ami6rR6OyX2Hk6OCivv7QIMg', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-10 00:09:51', '2026-03-03 00:09:51', 0),
(232, 58, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjQ5NjU5MiwiZXhwIjoxNzczMTAxMzkyfQ.b6FGQqhoLyQPAwA7hfBT7gX2y9AC_gKeJl3-sjTvuIU', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-10 00:09:52', '2026-03-03 00:09:52', 0),
(233, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjQ5NjU5MywiZXhwIjoxNzczMTAxMzkzfQ.QYR2oSWIpzy84lbnWLeuI_BaE-3t7iS5JwyqlWAV9Lg', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-10 00:09:53', '2026-03-03 00:09:53', 0),
(234, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjQ5NjY0MCwiZXhwIjoxNzczMTAxNDQwfQ.EqIVxOk7Qy88_0Js1M7KXl4i91rrivc5wyMdgiVJViM', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-10 00:10:40', '2026-03-03 00:10:40', 0),
(235, 59, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNDk2NjQxLCJleHAiOjE3NzMxMDE0NDF9.Im8nTQj1Th3XV0PbqoyI1hyDFevn_p_LIPeIyAX518c', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-10 00:10:41', '2026-03-03 00:10:41', 0),
(236, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjQ5NzMxOCwiZXhwIjoxNzczMTAyMTE4fQ.5lILfFZ3CNqafhC26t9OOX3PRCEV_D2_VP7W1n8_me8', '127.0.0.1', 'PostmanRuntime/7.51.1', 'desktop', '2026-03-10 00:21:58', '2026-03-03 00:21:58', 0),
(237, 58, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjQ5NzMxOCwiZXhwIjoxNzczMTAyMTE4fQ.4htjJZ-dHtiqxEbTkddBZASovcSienjCWn_ZRABuer8', '127.0.0.1', 'PostmanRuntime/7.51.1', 'desktop', '2026-03-10 00:21:58', '2026-03-03 00:21:58', 0),
(238, 59, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNDk3MzE4LCJleHAiOjE3NzMxMDIxMTh9.Kg1463tQsOfxZRitcIs6XIiF_siFHfhDZHHjzguAK94', '127.0.0.1', 'PostmanRuntime/7.51.1', 'desktop', '2026-03-10 00:21:58', '2026-03-03 00:21:58', 0),
(239, 60, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MjQ5NzMxOCwiZXhwIjoxNzczMTAyMTE4fQ.rC9QTa2mniUxvaO7qsAc7oC80gk0cU21AK95kIaU_vw', '127.0.0.1', 'PostmanRuntime/7.51.1', 'desktop', '2026-03-10 00:21:58', '2026-03-03 00:21:59', 0),
(240, 61, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzcyNDk3MzE5LCJleHAiOjE3NzMxMDIxMTl9.EtYHz0SKrvkUSd0tYHo6ZNlo_9bSIfZ3LAAYwUdFAnE', '127.0.0.1', 'PostmanRuntime/7.51.1', 'desktop', '2026-03-10 00:21:59', '2026-03-03 00:21:59', 0),
(241, 59, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNTYxNDY4LCJleHAiOjE3NzMxNjYyNjh9.xookekgvYWKrbITlRXabDPNLcFEdmcPv2HIaGTdc1PE', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-10 18:11:08', '2026-03-03 18:11:08', 0),
(242, 59, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNTYxNDc0LCJleHAiOjE3NzMxNjYyNzR9.gd3JOa9st32ug4ms2RQlt5SsaRn0kOCmyGF3KqIn1bc', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-10 18:11:14', '2026-03-03 18:11:14', 0),
(243, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjU2MTQ4NCwiZXhwIjoxNzczMTY2Mjg0fQ.TeQEl2ABPoIxmDn0qm-pUGq2ztDZBeVfhOPNihHq6dE', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-10 18:11:24', '2026-03-03 18:11:24', 0),
(244, 58, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjU2MTQ4NSwiZXhwIjoxNzczMTY2Mjg1fQ.6HzM2Ok10vTeT0dWeTcUYMqAbF6P5VRbumFyhEpCERM', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-10 18:11:25', '2026-03-03 18:11:25', 0),
(245, 59, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNTYxNDg2LCJleHAiOjE3NzMxNjYyODZ9.M3fY6heNGwToTFn26lcr-OY-9W-_W5wMuKHvpBfLvi8', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-10 18:11:26', '2026-03-03 18:11:26', 0),
(246, 60, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MjU2MTQ4NywiZXhwIjoxNzczMTY2Mjg3fQ.epYDKupTKKjO_bBGadqNAEt7l70s8CZunjcFxMGxa3g', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-10 18:11:27', '2026-03-03 18:11:27', 0),
(247, 61, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzcyNTYxNDg4LCJleHAiOjE3NzMxNjYyODh9.E5Xrpolgty1CF00KYjQH0MazBngDGYQLHeC0pN4xm-A', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-10 18:11:28', '2026-03-03 18:11:28', 0),
(248, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjU2MTY4MiwiZXhwIjoxNzczMTY2NDgyfQ.-brZNhhdbhLCSdQf2cjHqhj7ZllZsmkQGXFn3DGIW9g', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-10 18:14:42', '2026-03-03 18:14:42', 0),
(249, 58, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjU2MTY4MywiZXhwIjoxNzczMTY2NDgzfQ.gbI579cMApasc98ra8DP3JX9sAfj9FUVkXQ_BgtJrwQ', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-10 18:14:43', '2026-03-03 18:14:43', 0),
(250, 59, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNTYxNjg0LCJleHAiOjE3NzMxNjY0ODR9.1Elo7GZTUrOKSfRYzOle7Flw5KHAaFW--c1d4CxJGiM', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-10 18:14:44', '2026-03-03 18:14:44', 0),
(251, 60, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MjU2MTY4NSwiZXhwIjoxNzczMTY2NDg1fQ.g28hRe9jBb9izv_3OCqMW-VYIIfHaP4cjAQSVNJDSks', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-10 18:14:45', '2026-03-03 18:14:45', 0),
(252, 61, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzcyNTYxNjg2LCJleHAiOjE3NzMxNjY0ODZ9.ZAXtjgTr3ge6EHD5vy0CuPD12lRhqAYpGPD_-_E7pLI', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-10 18:14:46', '2026-03-03 18:14:46', 0),
(253, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjU2MTc5NiwiZXhwIjoxNzczMTY2NTk2fQ.DubARO9p5hYKbu9pN8-7ZHNgZaUh59gQMhQ0gWak_30', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-10 18:16:36', '2026-03-03 18:16:36', 0),
(254, 58, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjU2MTc5NywiZXhwIjoxNzczMTY2NTk3fQ.f1o0hPHOE9aT3e4O5vXPvSF5yf8Fus8AXGH7ZvjI1JQ', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-10 18:16:37', '2026-03-03 18:16:37', 0),
(255, 59, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNTYxNzk4LCJleHAiOjE3NzMxNjY1OTh9.a0iC9EZJKZlgnm5ph-jV4u79v6yo_vg_Zs0pwQcOsX0', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-10 18:16:38', '2026-03-03 18:16:38', 0),
(256, 60, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MjU2MTc5OSwiZXhwIjoxNzczMTY2NTk5fQ.Gu3bbg9SeetSVaRqVMikKKrEQj3qJJuR8DQGYbMcIHE', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-10 18:16:39', '2026-03-03 18:16:39', 0),
(257, 61, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzcyNTYxODAwLCJleHAiOjE3NzMxNjY2MDB9.2H_qfQe5v9kwYmU2MLDolCFSbN_tx7oY5A0rdxl5dLA', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-10 18:16:40', '2026-03-03 18:16:40', 0),
(258, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjU2MTkwMiwiZXhwIjoxNzczMTY2NzAyfQ.aQWgdxmDSDz5g4u_oZSsUyjHMdbG1P6Rq0VXGStTR-Q', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-10 18:18:22', '2026-03-03 18:18:22', 0),
(259, 58, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjU2MTkwMywiZXhwIjoxNzczMTY2NzAzfQ.0Rg5H1gSNBtPeS1yz83DeZGAF9awtVmI77cYXU-lZfE', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-10 18:18:23', '2026-03-03 18:18:23', 0),
(260, 59, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNTYxOTA1LCJleHAiOjE3NzMxNjY3MDV9.OMr0weCvZKzOoxvGUiniEe5hDh0UKFvn1-b1m_IiY0E', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-10 18:18:25', '2026-03-03 18:18:25', 0),
(261, 60, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MjU2MTkwNiwiZXhwIjoxNzczMTY2NzA2fQ.rcX5oqqFuyYqMd6XGj1ZDHqqVPQBgToxRJrKaVZWLzI', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-10 18:18:26', '2026-03-03 18:18:26', 0),
(262, 61, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzcyNTYxOTA3LCJleHAiOjE3NzMxNjY3MDd9.9V6H_bRzo7PUieFC_Ob1irepG_XWJuAQ0OGCoZ93DQA', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-10 18:18:27', '2026-03-03 18:18:27', 0),
(263, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjU2MjAxMSwiZXhwIjoxNzczMTY2ODExfQ._29Nw7C6lXe9mOIfq8eD-Tvpac1fMFMgMIqPSWxWz-g', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-10 18:20:11', '2026-03-03 18:20:11', 0),
(264, 58, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjU2MjAxMywiZXhwIjoxNzczMTY2ODEzfQ.C2k8tM3E9bS7ezx7tFrlWxPsL95uBeaTulIRlu_ZE4k', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-10 18:20:13', '2026-03-03 18:20:13', 0),
(265, 59, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNTYyMDE0LCJleHAiOjE3NzMxNjY4MTR9.Hqa-Asa0u5gKAu2wi6FMeKboW7N2vxh-EzOzamL-NT0', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-10 18:20:14', '2026-03-03 18:20:14', 0),
(266, 60, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MjU2MjAxNSwiZXhwIjoxNzczMTY2ODE1fQ.0n7cM1LZDfNbMOkZMSaHQ4zAjkaCE2feznDdqrwK8Vk', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-10 18:20:15', '2026-03-03 18:20:15', 0),
(267, 61, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzcyNTYyMDE2LCJleHAiOjE3NzMxNjY4MTZ9.df9HQdscgd8acbdwnsXFyfop8_k3jzV0Kdj-NDcQGM0', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-10 18:20:16', '2026-03-03 18:20:16', 0),
(268, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjU2MjEwMywiZXhwIjoxNzczMTY2OTAzfQ.alZoLx1VsXsBHgU4_MLd0g6kZu9ZbKpCy0_B1pumgFs', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-10 18:21:43', '2026-03-03 18:21:43', 0),
(269, 58, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjU2MjEwNCwiZXhwIjoxNzczMTY2OTA0fQ.qnjmCGWah-Jt39m2_V8iulY7wYDFLgaXp_mMlpI5Zts', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-10 18:21:44', '2026-03-03 18:21:44', 0),
(270, 59, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNTYyMTA1LCJleHAiOjE3NzMxNjY5MDV9.h6ClI3MWuylbA5cl47YNFQCSMmk0_TyGuCANuErtqvg', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-10 18:21:45', '2026-03-03 18:21:45', 0),
(271, 60, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MjU2MjEwNiwiZXhwIjoxNzczMTY2OTA2fQ.0qSMlzQqtJkjtMTT1Dos76me50hkgIAYeevzSYqwom8', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-10 18:21:46', '2026-03-03 18:21:46', 0),
(272, 61, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzcyNTYyMTA3LCJleHAiOjE3NzMxNjY5MDd9.qOHXUUiEFIkEY1h9i-CnuEOUT3m_GO4lVf5-OTRZf-k', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-10 18:21:47', '2026-03-03 18:21:47', 0),
(273, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjU2MjE5OSwiZXhwIjoxNzczMTY2OTk5fQ.irgiTfdQ1BE-WUdfv7PRdnbIqrXxQvGJfQ47eTWxegE', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-10 18:23:19', '2026-03-03 18:23:19', 0),
(274, 58, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjU2MjIwMCwiZXhwIjoxNzczMTY3MDAwfQ.rxvbVdfBDLgqfCTfvDpD29hJg_taTXYGONbV711zSMY', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-10 18:23:20', '2026-03-03 18:23:20', 0),
(275, 59, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNTYyMjAxLCJleHAiOjE3NzMxNjcwMDF9.iQTmN0mzl6V-2IwA_7b1IMTQKd3NS58rWLo-ce0kRIU', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-10 18:23:21', '2026-03-03 18:23:21', 0),
(276, 60, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MjU2MjIwMiwiZXhwIjoxNzczMTY3MDAyfQ.j5uB2j_TTKAfQwYFNUQNrjM_Pr5RLTt6V9ZibtEhroY', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-10 18:23:22', '2026-03-03 18:23:22', 0),
(277, 61, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzcyNTYyMjAzLCJleHAiOjE3NzMxNjcwMDN9.1Kk_O7YtBLGI8QjDKY6CCYB51FVFxK3ae-N1QA0amqM', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-10 18:23:23', '2026-03-03 18:23:23', 0),
(278, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjU2MjQwNywiZXhwIjoxNzczMTY3MjA3fQ.CHLrU6BPbw5gPt5ZAciB6ZBtr73GuOR95FCOqAS2ync', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-10 18:26:47', '2026-03-03 18:26:47', 0),
(279, 58, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjU2MjQwOCwiZXhwIjoxNzczMTY3MjA4fQ.5EtdxYXtyv64tfsTaAkUPz3NDjR0Ud6TE4yKgKSj-hA', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-10 18:26:48', '2026-03-03 18:26:48', 0),
(280, 59, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNTYyNDA5LCJleHAiOjE3NzMxNjcyMDl9.AP2Uk5FeeWXcGTMQrQwo4PyXbuwc897PRmzPdmMaxMU', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-10 18:26:49', '2026-03-03 18:26:49', 0),
(281, 60, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MjU2MjQxMCwiZXhwIjoxNzczMTY3MjEwfQ.eHbZHP53rRqaj9QhiVzp2hMZVz_O9OWpB-uvCBUbq60', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-10 18:26:50', '2026-03-03 18:26:50', 0),
(282, 61, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzcyNTYyNDExLCJleHAiOjE3NzMxNjcyMTF9.72goPQbkKPEa1lspA5oVMdBZcsPRfOciw25jIewlIxw', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-10 18:26:51', '2026-03-03 18:26:51', 0),
(283, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjU2MjcxNiwiZXhwIjoxNzczMTY3NTE2fQ.SgLO77OOo1F0Rvk7EfifQpAZFeZHYbAq5gdLjZihT00', '127.0.0.1', 'PostmanRuntime/7.51.1', 'desktop', '2026-03-10 18:31:56', '2026-03-03 18:31:56', 0),
(284, 58, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjU2MjcxNiwiZXhwIjoxNzczMTY3NTE2fQ.7S06HxqPgOk4F5P_CrJcoeHdPSagN3TAw6Q4dnhCPUs', '127.0.0.1', 'PostmanRuntime/7.51.1', 'desktop', '2026-03-10 18:31:56', '2026-03-03 18:31:56', 0),
(285, 59, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNTYyNzE2LCJleHAiOjE3NzMxNjc1MTZ9.zKPvGzUhR0aM4CVuJHRqrSRbbB0d6rJ9I63vEAuxGSw', '127.0.0.1', 'PostmanRuntime/7.51.1', 'desktop', '2026-03-10 18:31:56', '2026-03-03 18:31:56', 0),
(286, 60, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MjU2MjcxNiwiZXhwIjoxNzczMTY3NTE2fQ.2w3xDrx9_32SAAVVQ13Z5XVOAfWUW8GAu-Zl1of9E7Q', '127.0.0.1', 'PostmanRuntime/7.51.1', 'desktop', '2026-03-10 18:31:56', '2026-03-03 18:31:56', 0),
(287, 61, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzcyNTYyNzE3LCJleHAiOjE3NzMxNjc1MTd9.DeIHjKWuxddoIYXJgXcQx4UIAZyUVlpECfRW8XuoJ5w', '127.0.0.1', 'PostmanRuntime/7.51.1', 'desktop', '2026-03-10 18:31:57', '2026-03-03 18:31:57', 0),
(288, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjU2MzI5OCwiZXhwIjoxNzczMTY4MDk4fQ.qurTq0xBIoiuiiVulKE1lXoE8rh4fD02cDfHuAD8ER8', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-10 18:41:38', '2026-03-03 18:41:38', 0),
(289, 58, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjU2MzI5OSwiZXhwIjoxNzczMTY4MDk5fQ.dXIB_SLoFc4I6d2LFOw2W9rJodBRIt3FTim5oMMQYas', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-10 18:41:39', '2026-03-03 18:41:39', 0),
(290, 59, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNTYzMzAwLCJleHAiOjE3NzMxNjgxMDB9.aHppv02ayyP5U8Rc3s_iZUQu2RfWuRA7roHcTRy8kZk', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-10 18:41:40', '2026-03-03 18:41:40', 0),
(291, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjU2MzQ3NCwiZXhwIjoxNzczMTY4Mjc0fQ.rUUgt3PNxg-DWnhPIHbSX7tNN1S7LQIjb-o_BPsguCM', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-10 18:44:34', '2026-03-03 18:44:34', 0),
(292, 58, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjU2MzQ3NSwiZXhwIjoxNzczMTY4Mjc1fQ.80ti5Y-Q3GCS2kegglhoUCI8-No_PhiWqwXqHjFlHjM', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-10 18:44:35', '2026-03-03 18:44:35', 0),
(293, 59, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNTYzNDc2LCJleHAiOjE3NzMxNjgyNzZ9.YnVdxDRD3AJ3uzhtNQbKGLIMLRj9u2X7je-ohjJ4jko', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-10 18:44:36', '2026-03-03 18:44:36', 0),
(294, 60, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MjU2MzQ3NywiZXhwIjoxNzczMTY4Mjc3fQ.XP4ow6zpU_b5I2NuIyhu9le5_WLypxM8QFJp4F2YWPs', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-10 18:44:37', '2026-03-03 18:44:37', 0),
(295, 61, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzcyNTYzNDc4LCJleHAiOjE3NzMxNjgyNzh9.dYQdphzyLRPhh02egW2gUhDG-fa2Y_ST1ZIIwSxXmag', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-10 18:44:38', '2026-03-03 18:44:38', 0),
(296, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjU5MDE2NSwiZXhwIjoxNzczMTk0OTY1fQ.--0JxBcXPMgoN3LOvbG6O81nIwGaPooHvgzHQpoz2N8', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 'desktop', '2026-03-11 02:09:25', '2026-03-04 02:09:25', 0),
(297, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjYzMzUzMCwiZXhwIjoxNzczMjM4MzMwfQ.hdCDI6mxpS1gLJ9YILpqQVpI3xZ16TAaNXN8D6lb2po', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 'desktop', '2026-03-11 14:12:10', '2026-03-04 14:12:10', 0),
(298, 58, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjYzMzc5MywiZXhwIjoxNzczMjM4NTkzfQ.4iDLxd-eBjuHu2W349k_BhMEvOm6RMOCX5DZRNUK344', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 'desktop', '2026-03-11 14:16:33', '2026-03-04 14:16:33', 0),
(299, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjYzNTQzNiwiZXhwIjoxNzczMjQwMjM2fQ.lAR9rMF-ju48X5vWN5wYcYMBXwfilmH8Jy22ZswNQ5w', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 'desktop', '2026-03-11 14:43:56', '2026-03-04 14:43:56', 0),
(300, 58, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjYzNTUwNywiZXhwIjoxNzczMjQwMzA3fQ.q70jA8tY2LymieLUys_W8MOuc6CsZEDJuTJA4G1Fkj4', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 'desktop', '2026-03-11 14:45:07', '2026-03-04 14:45:07', 0),
(301, 59, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNjM1NTc0LCJleHAiOjE3NzMyNDAzNzR9.iFY8AvbIujRP_SviiuClGR73oE1OP7tdPPqfniR9FJA', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 'desktop', '2026-03-11 14:46:14', '2026-03-04 14:46:14', 0),
(302, 60, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MjYzNTYxMCwiZXhwIjoxNzczMjQwNDEwfQ.MzRbWHoYbMvBbsrbq4zkX_OvVfS-Eap0G7gUNhzUsuw', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 'desktop', '2026-03-11 14:46:50', '2026-03-04 14:46:50', 0),
(303, 61, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzcyNjM1Njk2LCJleHAiOjE3NzMyNDA0OTZ9.BvXgmp6O7Q__5p1uJYN7tgt2ao-7G6xNcKeVXXqkoag', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 'desktop', '2026-03-11 14:48:16', '2026-03-04 14:48:16', 0),
(304, 60, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MjYzNjcwOSwiZXhwIjoxNzczMjQxNTA5fQ.B2pJyriF9tV7JUP4jK8VuyEbzgDrtlHAlnM8zIQJ_6E', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 'desktop', '2026-03-11 15:05:09', '2026-03-04 15:05:09', 0),
(305, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjYzNjc2OSwiZXhwIjoxNzczMjQxNTY5fQ.QrlUZKBiPXFbGgP4j4WbJC02DvOTC07AkYkCsC1C1QA', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 'desktop', '2026-03-11 15:06:09', '2026-03-04 15:06:09', 0),
(306, 59, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNjM2OTE0LCJleHAiOjE3NzMyNDE3MTR9.uPEZ5oj4miZqL4oa-GiVwi9yKFAiew61XXCKlqk1KhI', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 'desktop', '2026-03-11 15:08:34', '2026-03-04 15:08:34', 0),
(307, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjczODA3NywiZXhwIjoxNzczMzQyODc3fQ.UvGKNnUPhX3I32ZgdTVdNXt5JaRVInqQne5mlAGPhJA', '127.0.0.1', 'PostmanRuntime/7.51.1', 'desktop', '2026-03-12 19:14:37', '2026-03-05 19:14:37', 0),
(308, 58, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjczODA3NywiZXhwIjoxNzczMzQyODc3fQ.ATLKgcqksHkS5ghP35iRLkO4iJPa2yFULfcAEq9Sf1o', '127.0.0.1', 'PostmanRuntime/7.51.1', 'desktop', '2026-03-12 19:14:37', '2026-03-05 19:14:37', 0),
(309, 59, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNzM4MDc3LCJleHAiOjE3NzMzNDI4Nzd9.-FMZoEZHO-zKFdXxnxrkTYdLl0mSkXk9RU6kfS7_nss', '127.0.0.1', 'PostmanRuntime/7.51.1', 'desktop', '2026-03-12 19:14:37', '2026-03-05 19:14:37', 0),
(310, 60, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MjczODA3NywiZXhwIjoxNzczMzQyODc3fQ.QE9blGikSgmjhP1Y9CtkSii_p29Sm4ayv0m7YJW4CRk', '127.0.0.1', 'PostmanRuntime/7.51.1', 'desktop', '2026-03-12 19:14:37', '2026-03-05 19:14:37', 0),
(311, 61, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzcyNzM4MDc3LCJleHAiOjE3NzMzNDI4Nzd9.PiH8FuN6cRgKxgHYQ5v4UU_c6wowgt7NX_cgiOeHq6U', '127.0.0.1', 'PostmanRuntime/7.51.1', 'desktop', '2026-03-12 19:14:37', '2026-03-05 19:14:37', 0),
(312, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjkxMTU0OSwiZXhwIjoxNzczNTE2MzQ5fQ.F1JusMWAfVl2Mwv79owOVwRzB8jBVXnmPQo-JTYWA_E', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 'desktop', '2026-03-14 19:25:49', '2026-03-07 19:25:49', 0),
(313, 60, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MjkxMTU3MCwiZXhwIjoxNzczNTE2MzcwfQ.liCIx_OEr_ugzY7pr-iWAgTFGNy6HtJqLGJb8BTkboU', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 'desktop', '2026-03-14 19:26:10', '2026-03-07 19:26:10', 0),
(314, 59, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyOTExNTkxLCJleHAiOjE3NzM1MTYzOTF9.oftvdhYSIGqUDuRy_gZpVIwNesgjdhmEfDWQETqbsuo', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 'desktop', '2026-03-14 19:26:31', '2026-03-07 19:26:31', 0),
(315, 61, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzcyOTExNjg3LCJleHAiOjE3NzM1MTY0ODd9.WYOM66cEVcMSglv_iyiinW9TKYcufVkO2dlUV5cyjX4', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 'desktop', '2026-03-14 19:28:07', '2026-03-07 19:28:07', 0),
(316, 58, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjkxMTc0NiwiZXhwIjoxNzczNTE2NTQ2fQ.Fcf7dYGd1veT8IIRHKgLv5rQKX9Oa6ABF4RrXdHMctg', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 'desktop', '2026-03-14 19:29:06', '2026-03-07 19:29:06', 0),
(317, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjkxMTc4NiwiZXhwIjoxNzczNTE2NTg2fQ.lSCiNlUOAtiM4LcZz1JsFV1a-kJLNEL0hKfBqHjZmLk', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 'desktop', '2026-03-14 19:29:46', '2026-03-07 19:29:46', 0),
(318, 60, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MjkxMjAxMCwiZXhwIjoxNzczNTE2ODEwfQ.u8c5CxXSdE0wB9Jb93cCrNIbnvvul5dCkB71B_wEvMc', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 'desktop', '2026-03-14 19:33:30', '2026-03-07 19:33:30', 0),
(319, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjkxMjAzNywiZXhwIjoxNzczNTE2ODM3fQ.5aEJthyB-0kInni6Ez9Kiaatxft4y65_rTOC4lt_Vdo', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 'desktop', '2026-03-14 19:33:57', '2026-03-07 19:33:57', 0),
(320, 61, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzcyOTEyMDU0LCJleHAiOjE3NzM1MTY4NTR9.YdLlIkqNkZB-oz3EeZRm4Iw1j3_J_r61QR4wNmBfBp4', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 'desktop', '2026-03-14 19:34:14', '2026-03-07 19:34:14', 0),
(321, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjkxMzgyMCwiZXhwIjoxNzczNTE4NjIwfQ.8GVcJlBmV03lKWEA4X_zGXM_qc31n0neQnJryOEDa2g', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-14 20:03:40', '2026-03-07 20:03:40', 0),
(322, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjkxNDM3MCwiZXhwIjoxNzczNTE5MTcwfQ.dER_XTeZWDnFe2aa1P5vvGeoNP2DZ8u3XodU0n3L6yI', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 'desktop', '2026-03-14 20:12:50', '2026-03-07 20:12:50', 0),
(323, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzE0ODk1MywiZXhwIjoxNzczNzUzNzUzfQ.Q4s5HgpfHQ51Z44HZiIqLQ4Coxn3twjo4F_dyIlHL_w', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 'desktop', '2026-03-17 13:22:33', '2026-03-10 13:22:33', 0),
(324, 59, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzczMTQ5MjkzLCJleHAiOjE3NzM3NTQwOTN9.ISJK4iaTLUmjPN7jZYs64C-lk9Gh5Gk5aSr7tySAEJo', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 'desktop', '2026-03-17 13:28:13', '2026-03-10 13:28:13', 0),
(325, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzE1MTE4MCwiZXhwIjoxNzczNzU1OTgwfQ.6Qbk1ztrPM1MJ_nSmdOPt4-O_8KBWHXXBjMd7QlKnQk', '127.0.0.1', 'axios/1.13.2', 'desktop', '2026-03-17 13:59:40', '2026-03-10 13:59:40', 0),
(326, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzE1MTUwNywiZXhwIjoxNzczNzU2MzA3fQ.zvcEfT_NXP1XBkzu3vaWsMTA7d2xtd7LUzaQN0N7hvs', '127.0.0.1', 'axios/1.13.2', 'desktop', '2026-03-17 14:05:07', '2026-03-10 14:05:07', 0);
INSERT INTO `sessions` (`session_id`, `user_id`, `session_token`, `ip_address`, `user_agent`, `device_type`, `expires_at`, `created_at`, `remember_me`) VALUES
(327, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzE1MTU1MywiZXhwIjoxNzczNzU2MzUzfQ.1bDpPNqGar07-I4c5z6QKV4NAmpmIQY1863mIz2-seI', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-17 14:05:53', '2026-03-10 14:05:53', 0),
(328, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzE1MTgyNSwiZXhwIjoxNzczNzU2NjI1fQ.P1Wo6WthMTbPbdnBELrYobIY-iNTj6WYrLc6SxAyvYU', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-17 14:10:25', '2026-03-10 14:10:25', 0),
(329, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzE1MjA3NSwiZXhwIjoxNzczNzU2ODc1fQ.wBINDbNLBRASNGAzyMSXMQxlvF9c4fQOtHm0-YuqXmo', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 'desktop', '2026-03-17 14:14:35', '2026-03-10 14:14:35', 0),
(330, 58, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MzE1MjA3OSwiZXhwIjoxNzczNzU2ODc5fQ.cD1ES2SGZmLqbDa-thegF8dP_ekIm-wyRFheTkmzMNc', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 'desktop', '2026-03-17 14:14:39', '2026-03-10 14:14:39', 0),
(331, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzE1MjQ1OSwiZXhwIjoxNzczNzU3MjU5fQ.a2jNMMHU2lS41FOf-D-UeQkW5e3FNsb57qxBEAGGM84', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 'desktop', '2026-03-17 14:20:59', '2026-03-10 14:20:59', 0),
(332, 58, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MzE1MjQ3MiwiZXhwIjoxNzczNzU3MjcyfQ.g7YqAKcO5V1Lkc0YfLdG_NBC7kuteWY35BG3qJje9-4', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 'desktop', '2026-03-17 14:21:12', '2026-03-10 14:21:12', 0),
(333, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzE1MjY4NiwiZXhwIjoxNzczNzU3NDg2fQ.9AprDer9pp-iFvg2tl_4MHuLv59RG3sHOYuJNkxikIo', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 'desktop', '2026-03-17 14:24:46', '2026-03-10 14:24:46', 0),
(334, 58, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MzE1MjY4OSwiZXhwIjoxNzczNzU3NDg5fQ.q-xaynH5EWUChH6s5XyFA76sCYfbtg7Qskqwdy3xHHQ', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 'desktop', '2026-03-17 14:24:49', '2026-03-10 14:24:49', 0),
(335, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzE1Mjg3MywiZXhwIjoxNzczNzU3NjczfQ.AIHCS9rxInoBW3WxZ2I8K3lIpS9Q0AuWNy98BVkvKv8', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 'desktop', '2026-03-17 14:27:53', '2026-03-10 14:27:53', 0),
(336, 58, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MzE1Mjg3NCwiZXhwIjoxNzczNzU3Njc0fQ.kOLYnvQv-qMOgbeNKfycmg0SXyRAHVxluzeeWzC551A', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 'desktop', '2026-03-17 14:27:54', '2026-03-10 14:27:54', 0),
(337, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzE1MzIzNCwiZXhwIjoxNzczNzU4MDM0fQ.p7MHVdPoP1ZLrDCy4N7HFa0hzB7dKbcN2nrTAi4hOlg', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 'desktop', '2026-03-17 14:33:54', '2026-03-10 14:33:54', 0),
(338, 58, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MzE1MzIzOCwiZXhwIjoxNzczNzU4MDM4fQ.m64T-hsmijYXBjbG6Tyn8Hy82z46ADsT5nzziFQY7KU', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 'desktop', '2026-03-17 14:33:58', '2026-03-10 14:33:58', 0),
(339, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzE1MzQ1MywiZXhwIjoxNzczNzU4MjUzfQ.oo6LIjqE7ICNxDz8derVGwQQ7kHDepxa4n25o53pa8c', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 'desktop', '2026-03-17 14:37:33', '2026-03-10 14:37:33', 0),
(340, 58, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MzE1MzQ1NSwiZXhwIjoxNzczNzU4MjU1fQ.XaiGBEkaZyRhPSNU95Pex2Lwn0Lo0Wc7xTygTqBnAFE', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 'desktop', '2026-03-17 14:37:35', '2026-03-10 14:37:35', 0),
(341, 58, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MzE1MzQ2NywiZXhwIjoxNzczNzU4MjY3fQ.QK1W0cLh-ZC1Y4AFvkuxV2QDyLNolF4oOINXVVECAkc', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 'desktop', '2026-03-17 14:37:47', '2026-03-10 14:37:47', 0),
(342, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzE1NDU3MSwiZXhwIjoxNzczNzU5MzcxfQ.tKXXUqf5iOxFjBz-5_8QbRD6wRxaVi36IMbairdabLM', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 'desktop', '2026-03-17 14:56:11', '2026-03-10 14:56:11', 0),
(343, 58, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MzE1NDU3MSwiZXhwIjoxNzczNzU5MzcxfQ.b_M0SHOI2no5DGMHZ2WZt5i99QnNlI00bamobTvMOq8', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 'desktop', '2026-03-17 14:56:11', '2026-03-10 14:56:11', 0),
(344, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzE1NzAzMywiZXhwIjoxNzczNzYxODMzfQ.PAPS9zRVD0btY1GC4YCDnsNicbWvyzPgB29hOO5_HVY', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 'desktop', '2026-03-17 15:37:13', '2026-03-10 15:37:13', 0),
(345, 58, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MzE1NzAzNSwiZXhwIjoxNzczNzYxODM1fQ.fMKwuVhXrmJxWzjyA3RsgXsAsV3NR9rnX_QEMf7aCEk', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 'desktop', '2026-03-17 15:37:15', '2026-03-10 15:37:15', 0),
(346, 58, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MzE1NzMxNCwiZXhwIjoxNzczNzYyMTE0fQ.lrWCdn17BupF6FKsy1_qHnAseHNbVLWO6FwDkZKFQzU', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 'desktop', '2026-03-17 15:41:54', '2026-03-10 15:41:54', 0),
(347, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzE1NzM4MSwiZXhwIjoxNzczNzYyMTgxfQ.2ujJdnGFn_73cPfxagmQj9DZkJiTLgg9Oe_EEMEWuPg', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 'desktop', '2026-03-17 15:43:01', '2026-03-10 15:43:01', 0),
(348, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzE2MzIxMywiZXhwIjoxNzczNzY4MDEzfQ.gduVvB_FQn7eT1gRJtXDNi8CMbTstOiwwBmM5u2UakQ', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 'desktop', '2026-03-17 17:20:13', '2026-03-10 17:20:13', 0),
(349, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzE2MzQ2NSwiZXhwIjoxNzczNzY4MjY1fQ.uYX9XA6w8TROaC54dnRek4vP1E7ZnsqMIRm5OEJ8gis', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 'desktop', '2026-03-17 17:24:25', '2026-03-10 17:24:25', 0),
(350, 58, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MzE2MzQ4MCwiZXhwIjoxNzczNzY4MjgwfQ.AD37KrPvFMCq6z_08mW4ugNfJL7dvJ3jqNf7vVJHVpk', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 'desktop', '2026-03-17 17:24:40', '2026-03-10 17:24:40', 0),
(351, 60, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MzE2MzU0MSwiZXhwIjoxNzczNzY4MzQxfQ.fejWvj9i6BAY1bK5scZMy1WoZqyidKzX791TqGQ3jJM', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 'desktop', '2026-03-17 17:25:41', '2026-03-10 17:25:41', 0),
(352, 59, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzczMTY1OTg2LCJleHAiOjE3NzM3NzA3ODZ9.cfvq5jNTaVZ1ENiIz0sPijnH9uCtDUGBp3OuGlLzaM0', '127.0.0.1', 'curl/8.14.1', 'desktop', '2026-03-17 18:06:26', '2026-03-10 18:06:26', 0),
(353, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzE2NTk4NywiZXhwIjoxNzczNzcwNzg3fQ.0o-qE0LnKkWozPay5coN-l8HAyC7de9MHAryRXBNyY0', '127.0.0.1', 'curl/8.14.1', 'desktop', '2026-03-17 18:06:27', '2026-03-10 18:06:27', 0),
(354, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzE2NjAxMywiZXhwIjoxNzczNzcwODEzfQ.KLP7YVkwvYxTEdkhyWx5kXBQZdXDNAcxAAxMJHK7MZ0', '127.0.0.1', 'curl/8.14.1', 'desktop', '2026-03-17 18:06:53', '2026-03-10 18:06:53', 0),
(355, 59, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzczMTY2NDQzLCJleHAiOjE3NzM3NzEyNDN9.sejiKRPx5kTD6jCMP0rarN7HXKvDCDYMgqIQFAd63VI', '127.0.0.1', 'curl/8.14.1', 'desktop', '2026-03-17 18:14:03', '2026-03-10 18:14:03', 0),
(356, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzE2NjQ0MywiZXhwIjoxNzczNzcxMjQzfQ.6snYGE1GN2uTCklZ0WRZi3NJjBwgK6CgT0N80DC6rLE', '127.0.0.1', 'curl/8.14.1', 'desktop', '2026-03-17 18:14:03', '2026-03-10 18:14:03', 0),
(357, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzE2NjQ2MiwiZXhwIjoxNzczNzcxMjYyfQ.fjqcYIUobJE9Wpe6B53PrvZ03IaiXcmkGFhEHQ8Ud8I', '127.0.0.1', 'curl/8.14.1', 'desktop', '2026-03-17 18:14:22', '2026-03-10 18:14:22', 0),
(358, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzE2NjQ2MywiZXhwIjoxNzczNzcxMjYzfQ.fmpzQEFcypjnNwmD6qnuzOr0EkySL0WWE8oAbF4Ll5I', '127.0.0.1', 'curl/8.14.1', 'desktop', '2026-03-17 18:14:23', '2026-03-10 18:14:23', 0),
(359, 61, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzczMTY2NTEzLCJleHAiOjE3NzM3NzEzMTN9.pS43OMZPA_kpU_o-EuI_lgHr016L_JqyumayAFCl_Tk', '127.0.0.1', 'curl/8.14.1', 'desktop', '2026-03-17 18:15:13', '2026-03-10 18:15:13', 0),
(360, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzE2OTE5MSwiZXhwIjoxNzczNzczOTkxfQ.nQhfO7vr0fkjPwirbBPv1Mx5Mc77hruzGQDMt663M90', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-17 18:59:51', '2026-03-10 18:59:51', 0),
(361, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzE2OTI5MCwiZXhwIjoxNzczNzc0MDkwfQ.g-JALTlLCKgzNEtd9UpiEFXZt7YjoyKplLPt4-Luw3M', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-17 19:01:30', '2026-03-10 19:01:30', 0),
(362, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzE2OTQxNSwiZXhwIjoxNzczNzc0MjE1fQ.Ctuc5jw51QtobG5JinaAp8KQp7l3GLQkunH4OvA8LPM', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-17 19:03:35', '2026-03-10 19:03:35', 0),
(363, 59, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzczMTY5NDM4LCJleHAiOjE3NzM3NzQyMzh9.zTwWbjK3NLKfaFRmDDHEs6drYPe-XkqxGkalQA0xgrc', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-17 19:03:58', '2026-03-10 19:03:58', 0),
(364, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzE2OTQzOSwiZXhwIjoxNzczNzc0MjM5fQ.P7t8DNlR9P-vKE4hLotAkTt-q-jXHbQFJYVjdl4ukPE', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-17 19:03:59', '2026-03-10 19:03:59', 0),
(365, 59, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzczMTY5NDY2LCJleHAiOjE3NzM3NzQyNjZ9.Muju8TTqS9H39LEOLM_UHAwDLhCYdZnJ0pAStHUodbs', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-17 19:04:26', '2026-03-10 19:04:26', 0),
(366, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzE2OTQ2OCwiZXhwIjoxNzczNzc0MjY4fQ.9wwMj0-QYSyxQ76MhNcZFagMHlNGxqaqCXRfId-qEck', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-17 19:04:28', '2026-03-10 19:04:28', 0),
(367, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzE2OTUwNiwiZXhwIjoxNzczNzc0MzA2fQ.b2zbc_Zreg4qpyy5omyyEj_JgEE6jp2lLt6pfoy46jE', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-17 19:05:06', '2026-03-10 19:05:06', 0),
(368, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzE2OTUyOCwiZXhwIjoxNzczNzc0MzI4fQ.jg7N7cuPPZCxDufT0N_3yjATonJYor_xg8KQbSRwhe8', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-17 19:05:28', '2026-03-10 19:05:28', 0),
(369, 59, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzczMTY5NTMyLCJleHAiOjE3NzM3NzQzMzJ9.BoZcyTQkAbQYbzCE4ZNGuLSofsYWI9ItRmFxJMg_oWw', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-17 19:05:32', '2026-03-10 19:05:32', 0),
(370, 57, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzE2OTU1OSwiZXhwIjoxNzczNzc0MzU5fQ.KKKpGpNSmY1k4gGM3AxteetB9m0IBMzVh1G02H5jqXU', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-17 19:05:59', '2026-03-10 19:05:59', 0),
(371, 59, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzczMTY5NTYyLCJleHAiOjE3NzM3NzQzNjJ9.k9hIuUgmNIx-vHjySCHaItGtleSjCyBrn1gbM2SvXz0', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4', 'desktop', '2026-03-17 19:06:02', '2026-03-10 19:06:02', 0);

-- --------------------------------------------------------

--
-- Table structure for table `ssl_certificates`
--

CREATE TABLE `ssl_certificates` (
  `cert_id` bigint(20) UNSIGNED NOT NULL,
  `campus_id` bigint(20) UNSIGNED NOT NULL,
  `domain_name` varchar(255) NOT NULL,
  `certificate_path` varchar(500) DEFAULT NULL,
  `private_key_path` varchar(500) DEFAULT NULL,
  `issuer` varchar(255) DEFAULT NULL,
  `valid_from` date NOT NULL,
  `valid_until` date NOT NULL,
  `status` enum('active','expiring_soon','expired','revoked') DEFAULT 'active',
  `auto_renew` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `ssl_certificates`
--

INSERT INTO `ssl_certificates` (`cert_id`, `campus_id`, `domain_name`, `certificate_path`, `private_key_path`, `issuer`, `valid_from`, `valid_until`, `status`, `auto_renew`, `created_at`, `updated_at`) VALUES
(1, 1, 'main.campus.edu', '/etc/ssl/certs/main_campus.crt', '/etc/ssl/private/main_campus.key', 'Let\'s Encrypt', '2025-01-01', '2025-12-31', 'active', 1, '2025-11-20 13:43:01', '2025-11-20 13:43:01'),
(2, 2, 'downtown.campus.edu', '/etc/ssl/certs/downtown.crt', '/etc/ssl/private/downtown.key', 'DigiCert', '2024-06-01', '2025-05-31', 'expiring_soon', 1, '2025-11-20 13:43:01', '2025-11-20 13:43:01'),
(3, 3, 'online.campus.edu', '/etc/ssl/certs/online.crt', '/etc/ssl/private/online.key', 'Let\'s Encrypt', '2025-02-01', '2026-01-31', 'active', 1, '2025-11-20 13:43:01', '2025-11-20 13:43:01');

-- --------------------------------------------------------

--
-- Table structure for table `student_progress`
--

CREATE TABLE `student_progress` (
  `progress_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `course_id` bigint(20) UNSIGNED NOT NULL,
  `enrollment_id` bigint(20) UNSIGNED NOT NULL,
  `completion_percentage` decimal(5,2) DEFAULT 0.00,
  `materials_viewed` int(11) DEFAULT 0,
  `total_materials` int(11) DEFAULT 0,
  `assignments_completed` int(11) DEFAULT 0,
  `total_assignments` int(11) DEFAULT 0,
  `quizzes_completed` int(11) DEFAULT 0,
  `total_quizzes` int(11) DEFAULT 0,
  `average_score` decimal(5,2) DEFAULT NULL,
  `time_spent_minutes` int(11) DEFAULT 0,
  `last_activity_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `student_tasks`
--

CREATE TABLE `student_tasks` (
  `task_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `task_type` enum('assignment','quiz','lab','study','custom') NOT NULL,
  `assignment_id` bigint(20) UNSIGNED DEFAULT NULL,
  `quiz_id` bigint(20) UNSIGNED DEFAULT NULL,
  `lab_id` bigint(20) UNSIGNED DEFAULT NULL,
  `title` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `due_date` timestamp NULL DEFAULT NULL,
  `priority` enum('low','medium','high') DEFAULT 'medium',
  `status` enum('pending','in_progress','completed','overdue') DEFAULT 'pending',
  `completion_percentage` int(11) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `student_tasks`
--

INSERT INTO `student_tasks` (`task_id`, `user_id`, `task_type`, `assignment_id`, `quiz_id`, `lab_id`, `title`, `description`, `due_date`, `priority`, `status`, `completion_percentage`, `created_at`, `updated_at`) VALUES
(5, 8, 'custom', NULL, NULL, NULL, 'Review lecture notes', 'Go through weeks 1-3', '2025-02-20 21:59:59', 'medium', 'in_progress', 75, '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(6, 9, 'study', NULL, NULL, NULL, 'Prepare for midterm', 'Review all materials', '2025-03-15 21:59:59', 'high', 'in_progress', 40, '2025-11-20 13:43:00', '2025-11-20 13:43:00');

-- --------------------------------------------------------

--
-- Table structure for table `study_groups`
--

CREATE TABLE `study_groups` (
  `group_id` bigint(20) UNSIGNED NOT NULL,
  `course_id` bigint(20) UNSIGNED NOT NULL,
  `group_name` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `created_by` bigint(20) UNSIGNED NOT NULL,
  `max_members` int(11) DEFAULT 10,
  `current_members` int(11) DEFAULT 1,
  `is_public` tinyint(1) DEFAULT 1,
  `meeting_schedule` varchar(255) DEFAULT NULL,
  `status` enum('active','inactive','archived') DEFAULT 'active',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `study_groups`
--

INSERT INTO `study_groups` (`group_id`, `course_id`, `group_name`, `description`, `created_by`, `max_members`, `current_members`, `is_public`, `meeting_schedule`, `status`, `created_at`, `updated_at`) VALUES
(2, 2, 'Data Structures Masters', 'Advanced study group for CS201', 12, 5, 3, 1, 'Monday & Wednesday 5-7 PM', 'active', '2025-11-20 13:43:00', '2025-11-20 13:43:00');

-- --------------------------------------------------------

--
-- Table structure for table `study_group_members`
--

CREATE TABLE `study_group_members` (
  `member_id` bigint(20) UNSIGNED NOT NULL,
  `group_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `role` enum('creator','moderator','member') DEFAULT 'member',
  `joined_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `study_group_members`
--

INSERT INTO `study_group_members` (`member_id`, `group_id`, `user_id`, `role`, `joined_at`) VALUES
(5, 2, 12, 'creator', '2025-11-20 13:43:00'),
(6, 2, 13, 'member', '2025-11-20 13:43:00'),
(7, 2, 14, 'member', '2025-11-20 13:43:00');

-- --------------------------------------------------------

--
-- Table structure for table `subscription_plans`
--

CREATE TABLE `subscription_plans` (
  `plan_id` bigint(20) UNSIGNED NOT NULL,
  `plan_name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `price` decimal(10,2) NOT NULL,
  `currency` varchar(3) DEFAULT 'USD',
  `billing_cycle` enum('monthly','quarterly','yearly') DEFAULT 'monthly',
  `features` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`features`)),
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `support_tickets`
--

CREATE TABLE `support_tickets` (
  `ticket_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `feedback_id` bigint(20) UNSIGNED DEFAULT NULL,
  `ticket_number` varchar(50) NOT NULL,
  `subject` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `category` enum('technical','academic','account','payment','general') NOT NULL,
  `priority` enum('low','medium','high','urgent') DEFAULT 'medium',
  `status` enum('open','in_progress','waiting_user','waiting_admin','resolved','closed') DEFAULT 'open',
  `assigned_to` bigint(20) UNSIGNED DEFAULT NULL,
  `resolution` text DEFAULT NULL,
  `first_response_at` timestamp NULL DEFAULT NULL,
  `resolved_at` timestamp NULL DEFAULT NULL,
  `closed_at` timestamp NULL DEFAULT NULL,
  `satisfaction_rating` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `support_tickets`
--

INSERT INTO `support_tickets` (`ticket_id`, `user_id`, `feedback_id`, `ticket_number`, `subject`, `description`, `category`, `priority`, `status`, `assigned_to`, `resolution`, `first_response_at`, `resolved_at`, `closed_at`, `satisfaction_rating`, `created_at`, `updated_at`) VALUES
(1, 7, 1, 'TKT-2025-001', 'Cannot submit assignment', 'Student unable to upload file for assignment submission', 'technical', 'high', 'resolved', 1, NULL, '2025-02-10 08:30:00', '2025-02-10 12:45:00', NULL, 5, '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(2, 10, 4, 'TKT-2025-002', 'Grade not updated', 'Quiz grade not reflected in gradebook', 'academic', 'medium', 'resolved', 1, NULL, '2025-02-12 07:15:00', '2025-02-12 14:20:00', NULL, 4, '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(3, 12, NULL, 'TKT-2025-003', 'Reset password not working', 'Password reset email not arriving', 'account', 'high', 'in_progress', 1, NULL, '2025-02-14 09:00:00', NULL, NULL, NULL, '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(4, 13, NULL, 'TKT-2025-004', 'Course enrollment issue', 'Cannot enroll in CS301 - shows full but seats available', 'academic', 'medium', 'open', NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-20 13:43:00', '2025-11-20 13:43:00');

-- --------------------------------------------------------

--
-- Table structure for table `system_errors`
--

CREATE TABLE `system_errors` (
  `error_id` bigint(20) UNSIGNED NOT NULL,
  `error_code` varchar(50) DEFAULT NULL,
  `error_message` text NOT NULL,
  `error_type` enum('application','database','api','security','system') NOT NULL,
  `severity` enum('low','medium','high','critical') DEFAULT 'medium',
  `stack_trace` text DEFAULT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `request_url` varchar(500) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `is_resolved` tinyint(1) DEFAULT 0,
  `resolved_by` bigint(20) UNSIGNED DEFAULT NULL,
  `resolved_at` timestamp NULL DEFAULT NULL,
  `resolution_notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `system_settings`
--

CREATE TABLE `system_settings` (
  `setting_id` int(10) UNSIGNED NOT NULL,
  `setting_key` varchar(100) NOT NULL,
  `setting_value` text NOT NULL,
  `setting_type` enum('string','number','boolean','json') DEFAULT 'string',
  `category` varchar(50) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `is_public` tinyint(1) DEFAULT 0,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `system_settings`
--

INSERT INTO `system_settings` (`setting_id`, `setting_key`, `setting_value`, `setting_type`, `category`, `description`, `is_public`, `updated_at`) VALUES
(1, 'platform_name', 'CampusOne AI', 'string', 'general', 'Platform display name', 1, '2025-11-20 13:43:00'),
(2, 'max_file_upload_size', '52428800', 'number', 'files', 'Maximum file upload size in bytes (50MB)', 0, '2025-11-20 13:43:00'),
(3, 'session_timeout_minutes', '120', 'number', 'security', 'Session timeout duration', 0, '2025-11-20 13:43:00'),
(4, 'enable_ai_features', 'true', 'boolean', 'features', 'Enable AI-powered features', 0, '2025-11-20 13:43:00'),
(5, 'enable_gamification', 'true', 'boolean', 'features', 'Enable gamification system', 1, '2025-11-20 13:43:00'),
(6, 'default_language', 'en', 'string', 'localization', 'Default platform language', 1, '2025-11-20 13:43:00'),
(7, 'enable_face_recognition', 'true', 'boolean', 'features', 'Enable face recognition for attendance', 0, '2025-11-20 13:43:00'),
(8, 'maintenance_mode', 'false', 'boolean', 'system', 'System maintenance mode', 0, '2025-11-20 13:43:00'),
(9, 'max_login_attempts', '5', 'number', 'security', 'Maximum failed login attempts before lockout', 0, '2025-11-20 13:43:00'),
(10, 'password_min_length', '8', 'number', 'security', 'Minimum password length', 0, '2025-11-20 13:43:00');

-- --------------------------------------------------------

--
-- Table structure for table `task_completion`
--

CREATE TABLE `task_completion` (
  `completion_id` bigint(20) UNSIGNED NOT NULL,
  `task_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `completed_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `time_taken_minutes` int(11) DEFAULT NULL,
  `notes` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `ta_instructor_access`
--

CREATE TABLE `ta_instructor_access` (
  `access_id` bigint(20) UNSIGNED NOT NULL,
  `instructor_id` bigint(20) UNSIGNED NOT NULL,
  `ta_id` bigint(20) UNSIGNED NOT NULL,
  `section_id` bigint(20) UNSIGNED NOT NULL,
  `access_level` enum('view','grade','edit','full') DEFAULT 'grade',
  `can_upload_materials` tinyint(1) DEFAULT 0,
  `can_create_assignments` tinyint(1) DEFAULT 0,
  `can_grade_assignments` tinyint(1) DEFAULT 1,
  `can_manage_attendance` tinyint(1) DEFAULT 1,
  `can_send_announcements` tinyint(1) DEFAULT 0,
  `granted_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `revoked_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `theme_preferences`
--

CREATE TABLE `theme_preferences` (
  `preference_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `theme_mode` enum('light','dark','auto') DEFAULT 'light',
  `primary_color` varchar(7) DEFAULT '#007bff',
  `font_size` enum('small','medium','large') DEFAULT 'medium',
  `layout_density` enum('comfortable','compact') DEFAULT 'comfortable',
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `theme_preferences`
--

INSERT INTO `theme_preferences` (`preference_id`, `user_id`, `theme_mode`, `primary_color`, `font_size`, `layout_density`, `updated_at`) VALUES
(1, 7, 'dark', '#007bff', 'medium', 'comfortable', '2025-11-20 13:43:00'),
(2, 8, 'light', '#28a745', 'medium', 'compact', '2025-11-20 13:43:00'),
(3, 9, 'auto', '#007bff', 'large', 'comfortable', '2025-11-20 13:43:00'),
(4, 10, 'light', '#dc3545', 'small', 'comfortable', '2025-11-20 13:43:00'),
(5, 11, 'dark', '#ffc107', 'medium', 'compact', '2025-11-20 13:43:00'),
(6, 12, 'light', '#007bff', 'medium', 'comfortable', '2025-11-20 13:43:00');

-- --------------------------------------------------------

--
-- Table structure for table `two_factor_auth`
--

CREATE TABLE `two_factor_auth` (
  `auth_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `secret_key` varchar(255) NOT NULL,
  `enabled` tinyint(1) DEFAULT 0,
  `backup_codes` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `email` varchar(255) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `first_name` varchar(100) NOT NULL,
  `last_name` varchar(100) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `profile_picture_url` varchar(500) DEFAULT NULL,
  `bio` text DEFAULT NULL,
  `social_links` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`social_links`)),
  `campus_id` bigint(20) UNSIGNED DEFAULT NULL,
  `status` enum('active','inactive','suspended','pending') DEFAULT 'active',
  `email_verified` tinyint(1) DEFAULT 0,
  `last_login_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`user_id`, `email`, `password_hash`, `first_name`, `last_name`, `phone`, `profile_picture_url`, `bio`, `social_links`, `campus_id`, `status`, `email_verified`, `last_login_at`, `created_at`, `updated_at`, `deleted_at`) VALUES
(1, 'admin@campus.edu', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'John', 'Admin', '+1-555-1001', NULL, NULL, NULL, 1, 'active', 1, NULL, '2025-11-20 13:42:59', '2025-11-20 13:42:59', NULL),
(2, 'prof.smith@campus.edu', '$2b$10$BtLRojkSErhQ3Tq8e519k.zWzNU9y8y8rFecMQFGboSBTgpXaeZTC', 'Robert', 'Smith', '+1-555-1002', NULL, NULL, NULL, 1, 'active', 1, NULL, '2025-11-20 13:42:59', '2026-03-02 14:33:23', '2026-03-02 14:33:23'),
(3, 'prof.johnson@campus.edu', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Emily', 'Johnson', '+1-555-1003', NULL, NULL, NULL, 1, 'active', 1, NULL, '2025-11-20 13:42:59', '2025-11-20 13:42:59', NULL),
(4, 'prof.williams@campus.edu', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Michael', 'Williams', '+1-555-1004', NULL, NULL, NULL, 1, 'active', 1, NULL, '2025-11-20 13:42:59', '2025-11-20 13:42:59', NULL),
(5, 'ta.brown@campus.edu', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Sarah', 'Brown', '+1-555-1005', NULL, NULL, NULL, 1, 'active', 1, NULL, '2025-11-20 13:42:59', '2025-11-20 13:42:59', NULL),
(6, 'ta.davis@campus.edu', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'James', 'Davis', '+1-555-1006', NULL, NULL, NULL, 1, 'active', 1, NULL, '2025-11-20 13:42:59', '2025-11-20 13:42:59', NULL),
(7, 'alice.student@campus.edu', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Alice', 'Anderson', '+1-555-2001', NULL, NULL, NULL, 1, 'active', 1, NULL, '2025-11-20 13:42:59', '2025-11-20 13:42:59', NULL),
(8, 'bob.student@campus.edu', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Bob', 'Martinez', '+1-555-2002', NULL, NULL, NULL, 1, 'active', 1, NULL, '2025-11-20 13:42:59', '2025-11-20 13:42:59', NULL),
(9, 'carol.student@campus.edu', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Carol', 'Garcia', '+1-555-2003', NULL, NULL, NULL, 1, 'active', 1, NULL, '2025-11-20 13:42:59', '2025-11-20 13:42:59', NULL),
(10, 'david.student@campus.edu', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'David', 'Rodriguez', '+1-555-2004', NULL, NULL, NULL, 1, 'active', 1, NULL, '2025-11-20 13:42:59', '2025-11-20 13:42:59', NULL),
(11, 'emma.student@campus.edu', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Emma', 'Wilson', '+1-555-2005', NULL, NULL, NULL, 1, 'active', 1, NULL, '2025-11-20 13:42:59', '2025-11-20 13:42:59', NULL),
(12, 'frank.student@campus.edu', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Frank', 'Lopez', '+1-555-2006', NULL, NULL, NULL, 1, 'active', 1, NULL, '2025-11-20 13:42:59', '2025-11-20 13:42:59', NULL),
(13, 'grace.student@campus.edu', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Grace', 'Lee', '+1-555-2007', NULL, NULL, NULL, 1, 'active', 1, NULL, '2025-11-20 13:42:59', '2025-11-20 13:42:59', NULL),
(14, 'henry.student@campus.edu', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Henry', 'Walker', '+1-555-2008', NULL, NULL, NULL, 1, 'active', 1, NULL, '2025-11-20 13:42:59', '2025-11-20 13:42:59', NULL),
(15, 'ivy.student@campus.edu', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Ivy', 'Hall', '+1-555-2009', NULL, NULL, NULL, 1, 'active', 1, NULL, '2025-11-20 13:42:59', '2025-11-20 13:42:59', NULL),
(16, 'jack.student@campus.edu', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Jack', 'Allen', '+1-555-2010', NULL, NULL, NULL, 1, 'active', 1, NULL, '2025-11-20 13:42:59', '2025-11-20 13:42:59', NULL),
(17, 'amir123@campus.edu', '$2a$12$C311w/5Myorf1.zx35NarOlekceRfdFvjGr1xUgx0s4GHxky4JaQa', 'Amir', 'Doe', '+1234567890', NULL, NULL, NULL, 1, 'active', 1, '2025-11-24 23:24:53', '2025-11-24 23:02:53', '2025-11-24 23:24:53', NULL),
(18, 'amir.user@campus.edu', '$2a$12$Rq1HOfy3QufvhHKiKrGQFeqyHsX896gCod41jJF1r.XNUUIeQMd4i', 'Test', 'amir2', '+1234567800', NULL, NULL, NULL, 1, 'active', 1, '2025-11-24 23:33:35', '2025-11-24 23:29:12', '2025-11-24 23:33:35', NULL),
(19, 'amir1234@campus.edu', '$2b$10$Z0TxzhBdcMLt2YuGEbPmTe/nYpEvVPw6I8E7h7cHUaS79NpKv.Lwq', 'Amir', 'Mohamed', '+125451526', NULL, NULL, NULL, 1, 'active', 1, '2025-11-25 18:00:40', '2025-11-25 02:17:12', '2025-11-25 18:00:41', NULL),
(20, 'ta.salim.noor@eduverse.edu.eg', '$2y$10$N9qo8uLOickgx2ZMRZoMye', 'Salim', 'Noor', '+20-100-444-0003', NULL, NULL, NULL, 2, 'active', 1, '2025-02-13 15:20:00', '2024-09-01 08:00:00', '2024-09-01 08:00:00', NULL),
(21, 'student.ali.youssef@eduverse.edu.eg', '$2y$10$N9qo8uLOickgx2ZMRZoMye', 'Ali', 'Youssef', '+20-100-555-0001', NULL, NULL, NULL, 1, 'active', 1, '2025-02-15 17:45:00', '2024-09-01 08:00:00', '2024-09-01 08:00:00', NULL),
(22, 'student.maya.ibrahim@eduverse.edu.eg', '$2y$10$N9qo8uLOickgx2ZMRZoMye', 'Maya', 'Ibrahim', '+20-100-555-0002', NULL, NULL, NULL, 1, 'active', 1, '2025-02-15 16:30:00', '2024-09-01 08:00:00', '2024-09-01 08:00:00', NULL),
(23, 'student.zain.ahmed@eduverse.edu.eg', '$2y$10$N9qo8uLOickgx2ZMRZoMye', 'Zain', 'Ahmed', '+20-100-555-0003', NULL, NULL, NULL, 1, 'active', 1, '2025-02-15 18:00:00', '2024-09-01 08:00:00', '2024-09-01 08:00:00', NULL),
(24, 'student.hana.khalil@eduverse.edu.eg', '$2y$10$N9qo8uLOickgx2ZMRZoMye', 'Hana', 'Khalil', '+20-100-555-0004', NULL, NULL, NULL, 1, 'active', 1, '2025-02-14 17:15:00', '2024-09-01 08:00:00', '2024-09-01 08:00:00', NULL),
(25, 'am3566146@gmail.com', '$2b$10$lqumSGY0jP1eCtbxIlQQveE1nD7m37YU9jJRrwoGoDlBenDS1EQqi', 'Amir', 'Hamdi', '+201234567890', NULL, NULL, NULL, NULL, 'active', 1, '2025-11-30 16:05:00', '2025-11-26 15:22:14', '2025-11-30 16:04:59', NULL),
(26, 'student.mariam.fahmy@eduverse.edu.eg', '$2y$10$N9qo8uLOickgx2ZMRZoMye', 'Mariam', 'Fahmy', '+20-100-555-0006', NULL, NULL, NULL, 1, 'active', 1, '2025-02-13 18:20:00', '2024-09-01 08:00:00', '2024-09-01 08:00:00', NULL),
(27, 'student.rashid.nour@eduverse.edu.eg', '$2y$10$N9qo8uLOickgx2ZMRZoMye', 'Rashid', 'Nour', '+20-100-555-0007', NULL, NULL, NULL, 1, 'active', 1, '2025-02-13 17:00:00', '2024-09-01 08:00:00', '2024-09-01 08:00:00', NULL),
(28, 'student.sara.aziz@eduverse.edu.eg', '$2y$10$N9qo8uLOickgx2ZMRZoMye', 'Sara', 'Aziz', '+20-100-555-0008', NULL, NULL, NULL, 2, 'active', 1, '2025-02-15 15:30:00', '2024-09-01 08:00:00', '2024-09-01 08:00:00', NULL),
(29, 'am3566147@gmail.com', '$2b$10$oplLjPdOuM19aeyZg9CQJuhUoiQxN00m2LjMTGd4.IDrIs2WI/nUC', 'John', 'Doe', NULL, NULL, NULL, NULL, NULL, 'active', 1, '2025-11-30 16:39:24', '2025-11-26 18:02:35', '2025-11-30 16:39:24', NULL),
(30, 'am3566143@gmail.com', '$2b$10$1ZlE/jNftUxyDDR5b6Kd2eLR3IB5ZUN9LCrVDU9E0zsMP5mfy4/q.', 'Amir', 'Hamdi', '+2015464646445', NULL, NULL, NULL, NULL, 'active', 1, '2025-11-27 00:40:27', '2025-11-26 23:31:32', '2025-11-27 00:40:27', NULL),
(31, 'student.amr.shaker@eduverse.edu.eg', '$2y$10$N9qo8uLOickgx2ZMRZoMye', 'Amr', 'Shaker', '+20-100-555-0011', NULL, NULL, NULL, 2, 'active', 1, '2025-02-13 16:30:00', '2024-09-01 08:00:00', '2024-09-01 08:00:00', NULL),
(32, 'student.dalal.hassan@eduverse.edu.eg', '$2y$10$N9qo8uLOickgx2ZMRZoMye', 'Dalal', 'Hassan', '+20-100-555-0012', NULL, NULL, NULL, 1, 'active', 1, '2025-02-12 17:45:00', '2024-09-01 08:00:00', '2024-09-01 08:00:00', NULL),
(33, 'amirhamdidx720@gmail.com', '$2b$10$pl4Dx6LsyXtolFjT3s.X5u.mYMJSYrkM98nDz1IkuCck.O7d3cl52', 'Amir', 'Hamdi', NULL, NULL, NULL, NULL, NULL, 'active', 1, '2025-11-27 00:36:46', '2025-11-27 00:32:35', '2025-11-27 00:36:46', NULL),
(34, 'amir_student@campus.edu', '$2b$10$pmCL5b.Hv9aPeH9MBxHEHuB4YQiZyMz5tZTIEh6xjRDUUB/K5hqaK', 'Amir', 'Strudent', NULL, NULL, NULL, NULL, NULL, 'active', 1, '2025-11-30 16:08:53', '2025-11-30 16:08:06', '2025-11-30 16:08:53', NULL),
(35, 'amir@edu.com', '$2b$10$wPRxhFVeedYmnpkDJWzgZuUH4qn2cjd9zF65tCSfrUnSRbjleFhOS', 'Test', 'User', '+20201234567', NULL, NULL, NULL, NULL, 'pending', 0, NULL, '2026-02-25 19:01:54', '2026-02-25 19:01:54', NULL),
(36, 'john.doe@example.com', '$2b$10$HNLv5bD5GbRDJzyOlJr0FuP5A6ibEUhKWkKbbm/ytOhFTffEmy8VG', 'John', 'Doe', '+1234567890', NULL, NULL, NULL, NULL, 'active', 1, '2026-02-25 20:11:14', '2026-02-25 19:02:43', '2026-02-25 20:11:14', NULL),
(37, 'student.fouad.ali@eduverse.edu.eg', '$2y$10$N9qo8uLOickgx2ZMRZoMye', 'Fouad', 'Ali', '+20-100-555-0017', NULL, NULL, NULL, 3, 'active', 1, '2025-02-15 19:00:00', '2024-09-01 08:00:00', '2024-09-01 08:00:00', NULL),
(38, 'student.lina.noor@eduverse.edu.eg', '$2y$10$N9qo8uLOickgx2ZMRZoMye', 'Lina', 'Noor', '+20-100-555-0018', NULL, NULL, NULL, 3, 'active', 1, '2025-02-14 18:45:00', '2024-09-01 08:00:00', '2024-09-01 08:00:00', NULL),
(39, 'student.sami.aziz@eduverse.edu.eg', '$2y$10$N9qo8uLOickgx2ZMRZoMye', 'Sami', 'Aziz', '+20-100-555-0019', NULL, NULL, NULL, 3, 'active', 1, '2025-02-13 19:20:00', '2024-09-01 08:00:00', '2024-09-01 08:00:00', NULL),
(40, 'student.joud.mohammad@eduverse.edu.eg', '$2y$10$N9qo8uLOickgx2ZMRZoMye', 'Joud', 'Mohammad', '+20-100-555-0020', NULL, NULL, NULL, 1, 'active', 1, '2025-02-12 18:30:00', '2024-09-01 08:00:00', '2024-09-01 08:00:00', NULL),
(41, 'student.rayan.saleh@eduverse.edu.eg', '$2y$10$N9qo8uLOickgx2ZMRZoMye', 'Rayan', 'Saleh', '+20-100-555-0021', NULL, NULL, NULL, 1, 'active', 1, '2025-02-11 19:00:00', '2024-09-01 08:00:00', '2024-09-01 08:00:00', NULL),
(42, 'student.ghada.hussein@eduverse.edu.eg', '$2y$10$N9qo8uLOickgx2ZMRZoMye', 'Ghada', 'Hussein', '+20-100-555-0022', NULL, NULL, NULL, 2, 'active', 1, '2025-02-10 17:45:00', '2024-09-01 08:00:00', '2024-09-01 08:00:00', NULL),
(43, 'student.tariq.samir@eduverse.edu.eg', '$2y$10$N9qo8uLOickgx2ZMRZoMye', 'Tariq', 'Samir', '+20-100-555-0023', NULL, NULL, NULL, 2, 'active', 1, '2025-02-09 18:00:00', '2024-09-01 08:00:00', '2024-09-01 08:00:00', NULL),
(44, 'student.souad.noor@eduverse.edu.eg', '$2y$10$N9qo8uLOickgx2ZMRZoMye', 'Souad', 'Noor', '+20-100-555-0024', NULL, NULL, NULL, 2, 'active', 1, '2025-02-08 17:15:00', '2024-09-01 08:00:00', '2024-09-01 08:00:00', NULL),
(45, 'student.walid.ahmed@eduverse.edu.eg', '$2y$10$N9qo8uLOickgx2ZMRZoMye', 'Walid', 'Ahmed', '+20-100-555-0025', NULL, NULL, NULL, 1, 'active', 1, '2025-02-07 19:30:00', '2024-09-01 08:00:00', '2024-09-01 08:00:00', NULL),
(46, 'student.yasmine.khalil@eduverse.edu.eg', '$2y$10$N9qo8uLOickgx2ZMRZoMye', 'Yasmine', 'Khalil', '+20-100-555-0026', NULL, NULL, NULL, 1, 'active', 1, '2025-02-06 16:45:00', '2024-09-01 08:00:00', '2024-09-01 08:00:00', NULL),
(47, 'student.ismail.ahmed@eduverse.edu.eg', '$2y$10$N9qo8uLOickgx2ZMRZoMye', 'Ismail', 'Ahmed', '+20-100-555-0027', NULL, NULL, NULL, 3, 'active', 1, '2025-02-15 20:00:00', '2024-09-01 08:00:00', '2024-09-01 08:00:00', NULL),
(48, 'student.zainab.saleh@eduverse.edu.eg', '$2y$10$N9qo8uLOickgx2ZMRZoMye', 'Zainab', 'Saleh', '+20-100-555-0028', NULL, NULL, NULL, 3, 'active', 1, '2025-02-14 19:15:00', '2024-09-01 08:00:00', '2024-09-01 08:00:00', NULL),
(49, 'student.jamal.abdel@eduverse.edu.eg', '$2y$10$N9qo8uLOickgx2ZMRZoMye', 'Jamal', 'Abdel', '+20-100-555-0029', NULL, NULL, NULL, 3, 'active', 1, '2025-02-13 18:45:00', '2024-09-01 08:00:00', '2024-09-01 08:00:00', NULL),
(50, 'student.haya.ibrahim@eduverse.edu.eg', '$2y$10$N9qo8uLOickgx2ZMRZoMye', 'Haya', 'Ibrahim', '+20-100-555-0030', NULL, NULL, NULL, 1, 'active', 1, '2025-02-12 19:00:00', '2024-09-01 08:00:00', '2024-09-01 08:00:00', NULL),
(51, 'admin.ahmed@eduverse.edu.eg', '$2y$10$N9qo8uLOickgx2ZMRZoMye', 'Ahmed', 'Hassan', '+20-100-111-0001', NULL, NULL, NULL, 1, 'active', 1, '2025-02-15 07:00:00', '2024-09-01 05:00:00', '2024-09-01 05:00:00', NULL),
(52, 'admin.fatima@eduverse.edu.eg', '$2y$10$N9qo8uLOickgx2ZMRZoMye', 'Fatima', 'Khalil', '+20-100-111-0002', NULL, NULL, NULL, 1, 'active', 1, '2025-02-14 12:30:00', '2024-09-01 05:00:00', '2024-09-01 05:00:00', NULL),
(53, 'admin.karim@eduverse.edu.eg', '$2y$10$N9qo8uLOickgx2ZMRZoMye', 'Karim', 'Mohamed', '+20-100-111-0003', NULL, NULL, NULL, 2, 'active', 1, '2025-02-13 09:15:00', '2024-09-01 05:00:00', '2024-09-01 05:00:00', NULL),
(56, 'admintarek@example.com', '$2b$10$Q2Np7QKr5aDtpwBYgf4Zi.5SaZ1GtMs8Y.C7xgP4d5FyVmwMUoJae', 'John', 'Doe', '+1234567890', NULL, NULL, NULL, NULL, 'active', 1, '2026-03-02 13:17:35', '2026-03-01 16:32:28', '2026-03-02 13:17:35', NULL),
(57, 'student.tarek@example.com', '$2b$10$LSP94K9E4dItX.1SlHzY4.8X.m3GokWgyGQWppzI9S6ARrpEgjp4.', 'StudentUpdated', 'Tarek', NULL, NULL, 'Test bio from Sprint 3 testing', '{\"github\":\"https://github.com/test\"}', NULL, 'active', 1, '2026-03-10 19:05:59', '2026-03-02 13:17:13', '2026-03-10 19:05:59', NULL),
(58, 'instructor.tarek@example.com', '$2b$10$RU6fgXm2NqYTHxolk6QWHOq2/dQ9FPu/vYL5QCMHYLgiALcvaOdJi', 'Tarek', 'Instructor', NULL, NULL, NULL, NULL, NULL, 'active', 1, '2026-03-10 17:24:40', '2026-03-02 13:17:14', '2026-03-10 17:24:40', NULL),
(59, 'admin.tarek@example.com', '$2b$10$P3HIhwwNVVYRTY8dM9bUU.E1jfyQAI4qOv8MId8cozPNVI2OSBJtK', 'Tarek', 'Admin', NULL, NULL, NULL, NULL, NULL, 'active', 1, '2026-03-10 19:06:02', '2026-03-02 13:17:15', '2026-03-10 19:06:02', NULL),
(60, 'ta.tarek@example.com', '$2b$10$ZNeL4pilwwieU42jvS.e2OfgCamtEX6UZF.8/wPp./gjN6GY7b/Z.', 'Tarek', 'TA', NULL, NULL, NULL, NULL, NULL, 'active', 1, '2026-03-10 17:25:41', '2026-03-02 13:18:41', '2026-03-10 17:25:41', NULL),
(61, 'it_admin.tarek@example.com', '$2b$10$EJkScTvamvd/ThfdVedTvuS9eY2484LRX7U5B31nbyC44DZBrRbwG', 'Tarek', 'ITAdmin', NULL, NULL, NULL, NULL, NULL, 'active', 1, '2026-03-10 18:15:13', '2026-03-02 13:18:42', '2026-03-10 18:15:13', NULL),
(62, 'testdel999@example.com', '$2b$10$iSkjrSWfZz9mc.DDwM3tTuMmxbH5tiEc7EGtTVi5ZegO8ktZ2fxKi', 'Test', 'Del', NULL, NULL, NULL, NULL, NULL, 'active', 1, NULL, '2026-03-02 13:27:01', '2026-03-02 13:27:01', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `user_badges`
--

CREATE TABLE `user_badges` (
  `user_badge_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `badge_id` int(10) UNSIGNED NOT NULL,
  `earned_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `display_on_profile` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `user_badges`
--

INSERT INTO `user_badges` (`user_badge_id`, `user_id`, `badge_id`, `earned_at`, `display_on_profile`) VALUES
(1, 7, 1, '2025-11-20 13:43:00', 1),
(2, 7, 2, '2025-11-20 13:43:00', 1),
(3, 7, 3, '2025-11-20 13:43:00', 1),
(4, 8, 1, '2025-11-20 13:43:00', 1),
(5, 8, 3, '2025-11-20 13:43:00', 1),
(6, 9, 1, '2025-11-20 13:43:00', 1),
(7, 10, 1, '2025-11-20 13:43:00', 1);

-- --------------------------------------------------------

--
-- Table structure for table `user_feedback`
--

CREATE TABLE `user_feedback` (
  `feedback_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `feedback_type` enum('bug','feature_request','complaint','suggestion','praise','other') NOT NULL,
  `category` varchar(50) DEFAULT NULL,
  `subject` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `priority` enum('low','medium','high','urgent') DEFAULT 'medium',
  `status` enum('new','in_review','in_progress','resolved','closed','rejected') DEFAULT 'new',
  `attachments` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `browser_info` text DEFAULT NULL,
  `page_url` varchar(500) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `user_feedback`
--

INSERT INTO `user_feedback` (`feedback_id`, `user_id`, `feedback_type`, `category`, `subject`, `description`, `priority`, `status`, `attachments`, `browser_info`, `page_url`, `created_at`, `updated_at`) VALUES
(1, 7, 'bug', 'assignments', 'Cannot submit assignment', 'Getting error when trying to upload file for Assignment 1', 'high', 'resolved', NULL, 'Chrome 120.0.0 / Windows 10', '/courses/1/assignments/1', '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(2, 8, 'feature_request', 'ui', 'Dark mode needed', 'Would love to have a dark mode option for late night studying', 'medium', 'in_progress', NULL, 'Firefox 121.0 / macOS', '/settings', '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(3, 9, 'suggestion', 'gamification', 'More badge types', 'Suggest adding badges for forum participation and helping peers', 'low', 'new', NULL, 'Safari 17.0 / iOS', '/profile/badges', '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(4, 10, 'complaint', 'grading', 'Grade not updated', 'My quiz grade has not been updated for 3 days', 'medium', 'resolved', NULL, 'Chrome 120.0.0 / Windows 11', '/courses/1/grades', '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(5, 11, 'praise', 'general', 'Great platform!', 'Really enjoying the AI features and clean interface', 'low', 'closed', NULL, 'Edge 120.0.0 / Windows 10', '/dashboard', '2025-11-20 13:43:00', '2025-11-20 13:43:00');

-- --------------------------------------------------------

--
-- Table structure for table `user_levels`
--

CREATE TABLE `user_levels` (
  `level_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `current_level` int(11) DEFAULT 1,
  `total_xp` bigint(20) DEFAULT 0,
  `xp_to_next_level` int(11) DEFAULT 100,
  `tier` enum('bronze','silver','gold','platinum','diamond') DEFAULT 'bronze',
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `user_levels`
--

INSERT INTO `user_levels` (`level_id`, `user_id`, `current_level`, `total_xp`, `xp_to_next_level`, `tier`, `updated_at`) VALUES
(1, 7, 3, 320, 150, 'silver', '2025-11-20 13:43:00'),
(2, 8, 2, 180, 120, 'bronze', '2025-11-20 13:43:00'),
(3, 9, 2, 150, 120, 'bronze', '2025-11-20 13:43:00'),
(4, 10, 1, 85, 100, 'bronze', '2025-11-20 13:43:00'),
(5, 11, 1, 65, 100, 'bronze', '2025-11-20 13:43:00'),
(6, 12, 1, 45, 100, 'bronze', '2025-11-20 13:43:00'),
(7, 13, 1, 30, 100, 'bronze', '2025-11-20 13:43:00'),
(8, 14, 1, 25, 100, 'bronze', '2025-11-20 13:43:00'),
(9, 15, 1, 20, 100, 'bronze', '2025-11-20 13:43:00'),
(10, 16, 1, 15, 100, 'bronze', '2025-11-20 13:43:00');

-- --------------------------------------------------------

--
-- Table structure for table `user_preferences`
--

CREATE TABLE `user_preferences` (
  `preference_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `language` varchar(10) NOT NULL DEFAULT 'en',
  `theme` varchar(20) NOT NULL DEFAULT 'light',
  `email_notifications` tinyint(1) NOT NULL DEFAULT 1,
  `push_notifications` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `user_preferences`
--

INSERT INTO `user_preferences` (`preference_id`, `user_id`, `language`, `theme`, `email_notifications`, `push_notifications`, `created_at`, `updated_at`) VALUES
(1, 57, 'ar', 'dark', 1, 1, '2026-03-10 18:14:04', '2026-03-10 18:14:04');

-- --------------------------------------------------------

--
-- Table structure for table `user_roles`
--

CREATE TABLE `user_roles` (
  `user_role_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `role_id` int(10) UNSIGNED NOT NULL,
  `assigned_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `assigned_by` bigint(20) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `user_roles`
--

INSERT INTO `user_roles` (`user_role_id`, `user_id`, `role_id`, `assigned_at`, `assigned_by`) VALUES
(1, 1, 4, '2025-11-20 13:42:59', 1),
(2, 2, 2, '2025-11-20 13:42:59', 1),
(3, 3, 2, '2025-11-20 13:42:59', 1),
(4, 4, 2, '2025-11-20 13:42:59', 1),
(5, 5, 3, '2025-11-20 13:42:59', 1),
(6, 6, 3, '2025-11-20 13:42:59', 1),
(7, 7, 1, '2025-11-20 13:42:59', 1),
(8, 8, 1, '2025-11-20 13:42:59', 1),
(9, 9, 1, '2025-11-20 13:42:59', 1),
(10, 10, 1, '2025-11-20 13:42:59', 1),
(11, 11, 1, '2025-11-20 13:42:59', 1),
(12, 12, 1, '2025-11-20 13:42:59', 1),
(13, 13, 1, '2025-11-20 13:42:59', 1),
(14, 14, 1, '2025-11-20 13:42:59', 1),
(15, 15, 1, '2025-11-20 13:42:59', 1),
(16, 16, 1, '2025-11-20 13:42:59', 1),
(17, 17, 1, '2025-11-24 23:02:53', NULL),
(18, 18, 1, '2025-11-24 23:29:13', NULL),
(19, 19, 1, '2025-11-25 02:17:12', NULL),
(25, 25, 1, '2025-11-26 15:22:14', NULL),
(29, 29, 4, '2025-11-26 18:02:35', NULL),
(30, 1, 5, '2025-11-26 18:11:25', NULL),
(32, 1, 3, '2025-11-26 18:12:12', NULL),
(35, 1, 2, '2025-11-26 18:12:56', NULL),
(36, 30, 1, '2025-11-26 23:31:32', NULL),
(39, 33, 1, '2025-11-27 00:32:35', NULL),
(40, 34, 1, '2025-11-30 16:08:06', NULL),
(41, 35, 1, '2026-02-25 19:01:54', NULL),
(42, 36, 1, '2026-02-25 19:02:43', NULL),
(46, 56, 4, '2026-03-01 16:32:28', NULL),
(47, 57, 1, '2026-03-02 13:17:13', NULL),
(48, 58, 2, '2026-03-02 13:17:14', NULL),
(49, 59, 4, '2026-03-02 13:17:15', NULL),
(50, 60, 3, '2026-03-02 13:18:41', NULL),
(51, 61, 6, '2026-03-02 13:18:42', NULL),
(52, 62, 1, '2026-03-02 13:27:01', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `user_subscriptions`
--

CREATE TABLE `user_subscriptions` (
  `subscription_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `plan_id` bigint(20) UNSIGNED NOT NULL,
  `status` enum('active','cancelled','expired','suspended') DEFAULT 'active',
  `started_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `expires_at` timestamp NULL DEFAULT NULL,
  `cancelled_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `voice_recordings`
--

CREATE TABLE `voice_recordings` (
  `recording_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `course_id` bigint(20) UNSIGNED DEFAULT NULL,
  `file_id` bigint(20) UNSIGNED NOT NULL,
  `transcription_id` bigint(20) UNSIGNED DEFAULT NULL,
  `duration_seconds` int(11) DEFAULT NULL,
  `recording_type` enum('lecture','note','question','answer') DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `voice_transcriptions`
--

CREATE TABLE `voice_transcriptions` (
  `transcription_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `audio_file_id` bigint(20) UNSIGNED DEFAULT NULL,
  `transcribed_text` text NOT NULL,
  `language` varchar(10) DEFAULT 'en',
  `confidence_score` decimal(3,2) DEFAULT NULL,
  `duration_seconds` int(11) DEFAULT NULL,
  `processing_time_ms` int(11) DEFAULT NULL,
  `ai_model` varchar(50) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `voice_transcriptions`
--

INSERT INTO `voice_transcriptions` (`transcription_id`, `user_id`, `audio_file_id`, `transcribed_text`, `language`, `confidence_score`, `duration_seconds`, `processing_time_ms`, `ai_model`, `created_at`) VALUES
(1, 7, 5, 'Remember to review chapter 3 before the midterm. Focus on loop structures and function definitions.', 'en', 0.94, 180, 2500, 'whisper-1', '2025-11-20 13:43:00'),
(2, 8, 5, 'Question about assignment: How do we handle edge cases in the input validation?', 'en', 0.91, 240, 3100, 'whisper-1', '2025-11-20 13:43:00');

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_course_performance`
-- (See below for the actual view)
--
CREATE TABLE `v_course_performance` (
`course_id` bigint(20) unsigned
,`course_name` varchar(200)
,`course_code` varchar(20)
,`section_id` bigint(20) unsigned
,`section_number` varchar(10)
,`total_students` bigint(21)
,`avg_completion` decimal(9,6)
,`avg_grade` decimal(9,6)
,`total_assignments` bigint(21)
,`total_quizzes` bigint(21)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_student_dashboard`
-- (See below for the actual view)
--
CREATE TABLE `v_student_dashboard` (
`user_id` bigint(20) unsigned
,`first_name` varchar(100)
,`last_name` varchar(100)
,`email` varchar(255)
,`profile_picture_url` varchar(500)
,`current_level` int(11)
,`total_xp` bigint(20)
,`enrolled_courses` bigint(21)
,`pending_tasks` bigint(21)
,`unread_notifications` bigint(21)
,`current_streak` int(11)
);

-- --------------------------------------------------------

--
-- Table structure for table `weak_topics_analysis`
--

CREATE TABLE `weak_topics_analysis` (
  `analysis_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `course_id` bigint(20) UNSIGNED NOT NULL,
  `topic_name` varchar(255) NOT NULL,
  `weakness_score` decimal(5,2) NOT NULL,
  `attempt_count` int(11) DEFAULT 0,
  `success_rate` decimal(5,2) DEFAULT 0.00,
  `last_attempted_at` timestamp NULL DEFAULT NULL,
  `recommendation_generated` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `weak_topics_analysis`
--

INSERT INTO `weak_topics_analysis` (`analysis_id`, `user_id`, `course_id`, `topic_name`, `weakness_score`, `attempt_count`, `success_rate`, `last_attempted_at`, `recommendation_generated`, `created_at`, `updated_at`) VALUES
(3, 9, 2, 'Linked List Operations', 58.00, 4, 48.00, '2025-02-15 12:45:00', 1, '2025-11-20 13:43:00', '2025-11-20 13:43:00');

-- --------------------------------------------------------

--
-- Table structure for table `xp_transactions`
--

CREATE TABLE `xp_transactions` (
  `transaction_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `source_type` enum('quiz','assignment','lab','attendance','login','streak','achievement','manual') NOT NULL,
  `source_id` bigint(20) UNSIGNED DEFAULT NULL,
  `rule_id` int(10) UNSIGNED DEFAULT NULL,
  `points_earned` int(11) NOT NULL,
  `multiplier` decimal(3,2) DEFAULT 1.00,
  `description` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `xp_transactions`
--

INSERT INTO `xp_transactions` (`transaction_id`, `user_id`, `source_type`, `source_id`, `rule_id`, `points_earned`, `multiplier`, `description`, `created_at`) VALUES
(1, 7, 'quiz', 1, 1, 10, 1.00, 'Completed Quiz 1: Python Basics', '2025-11-20 13:43:00'),
(2, 7, 'assignment', 1, 4, 75, 1.50, 'Perfect score on Assignment 1', '2025-11-20 13:43:00'),
(3, 7, 'attendance', 1, 3, 5, 1.00, 'Attended lecture on 2025-02-03', '2025-11-20 13:43:00'),
(4, 8, 'quiz', 1, 1, 10, 1.00, 'Completed Quiz 1: Python Basics', '2025-11-20 13:43:00'),
(5, 8, 'assignment', 1, 2, 15, 1.00, 'Submitted Assignment 1', '2025-11-20 13:43:00'),
(6, 8, 'attendance', 1, 3, 5, 1.00, 'Attended lecture on 2025-02-03', '2025-11-20 13:43:00'),
(7, 9, 'attendance', 1, 3, 5, 1.00, 'Attended lecture on 2025-02-03', '2025-11-20 13:43:00'),
(8, 10, 'assignment', 1, 2, 15, 1.00, 'Submitted Assignment 1', '2025-11-20 13:43:00'),
(9, 11, 'attendance', 1, 3, 5, 1.00, 'Attended lecture on 2025-02-03', '2025-11-20 13:43:00');

-- --------------------------------------------------------

--
-- Structure for view `v_course_performance`
--
DROP TABLE IF EXISTS `v_course_performance`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_course_performance`  AS SELECT `c`.`course_id` AS `course_id`, `c`.`course_name` AS `course_name`, `c`.`course_code` AS `course_code`, `cs`.`section_id` AS `section_id`, `cs`.`section_number` AS `section_number`, count(distinct `ce`.`user_id`) AS `total_students`, avg(`sp`.`completion_percentage`) AS `avg_completion`, avg(`g`.`percentage`) AS `avg_grade`, count(distinct `a`.`assignment_id`) AS `total_assignments`, count(distinct `q`.`quiz_id`) AS `total_quizzes` FROM ((((((`courses` `c` join `course_sections` `cs` on(`c`.`course_id` = `cs`.`course_id`)) left join `course_enrollments` `ce` on(`cs`.`section_id` = `ce`.`section_id`)) left join `student_progress` `sp` on(`ce`.`user_id` = `sp`.`user_id` and `c`.`course_id` = `sp`.`course_id`)) left join `grades` `g` on(`ce`.`user_id` = `g`.`user_id` and `c`.`course_id` = `g`.`course_id`)) left join `assignments` `a` on(`c`.`course_id` = `a`.`course_id`)) left join `quizzes` `q` on(`c`.`course_id` = `q`.`quiz_id`)) WHERE `c`.`status` = 'active' GROUP BY `c`.`course_id`, `cs`.`section_id` ;

-- --------------------------------------------------------

--
-- Structure for view `v_student_dashboard`
--
DROP TABLE IF EXISTS `v_student_dashboard`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_student_dashboard`  AS SELECT `u`.`user_id` AS `user_id`, `u`.`first_name` AS `first_name`, `u`.`last_name` AS `last_name`, `u`.`email` AS `email`, `u`.`profile_picture_url` AS `profile_picture_url`, `ul`.`current_level` AS `current_level`, `ul`.`total_xp` AS `total_xp`, count(distinct `ce`.`enrollment_id`) AS `enrolled_courses`, count(distinct `st`.`task_id`) AS `pending_tasks`, count(distinct `n`.`notification_id`) AS `unread_notifications`, `ds`.`current_streak` AS `current_streak` FROM (((((`users` `u` left join `user_levels` `ul` on(`u`.`user_id` = `ul`.`user_id`)) left join `course_enrollments` `ce` on(`u`.`user_id` = `ce`.`user_id` and `ce`.`enrollment_status` = 'enrolled')) left join `student_tasks` `st` on(`u`.`user_id` = `st`.`user_id` and `st`.`status` in ('pending','in_progress'))) left join `notifications` `n` on(`u`.`user_id` = `n`.`user_id` and `n`.`is_read` = 0)) left join `daily_streaks` `ds` on(`u`.`user_id` = `ds`.`user_id`)) WHERE `u`.`status` = 'active' GROUP BY `u`.`user_id` ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `achievements`
--
ALTER TABLE `achievements`
  ADD PRIMARY KEY (`achievement_id`),
  ADD UNIQUE KEY `achievement_name` (`achievement_name`),
  ADD KEY `reward_badge_id` (`reward_badge_id`);

--
-- Indexes for table `activity_logs`
--
ALTER TABLE `activity_logs`
  ADD PRIMARY KEY (`log_id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_type` (`activity_type`),
  ADD KEY `idx_date` (`created_at`),
  ADD KEY `idx_user_type_date` (`user_id`,`activity_type`,`created_at`),
  ADD KEY `idx_entity` (`entity_type`,`entity_id`);

--
-- Indexes for table `ai_attendance_processing`
--
ALTER TABLE `ai_attendance_processing`
  ADD PRIMARY KEY (`processing_id`),
  ADD KEY `reviewed_by` (`reviewed_by`),
  ADD KEY `idx_session` (`session_id`),
  ADD KEY `idx_photo` (`photo_id`),
  ADD KEY `idx_status` (`status`);

--
-- Indexes for table `ai_feedback`
--
ALTER TABLE `ai_feedback`
  ADD PRIMARY KEY (`feedback_id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_course` (`course_id`),
  ADD KEY `idx_read` (`is_read`);

--
-- Indexes for table `ai_flashcards`
--
ALTER TABLE `ai_flashcards`
  ADD PRIMARY KEY (`flashcard_id`),
  ADD KEY `idx_material` (`material_id`),
  ADD KEY `idx_user` (`user_id`);

--
-- Indexes for table `ai_grading_results`
--
ALTER TABLE `ai_grading_results`
  ADD PRIMARY KEY (`grading_id`),
  ADD KEY `idx_submission` (`submission_id`),
  ADD KEY `idx_quiz_attempt` (`quiz_attempt_id`),
  ADD KEY `idx_review` (`requires_human_review`);

--
-- Indexes for table `ai_quizzes`
--
ALTER TABLE `ai_quizzes`
  ADD PRIMARY KEY (`ai_quiz_id`),
  ADD KEY `difficulty_id` (`difficulty_id`),
  ADD KEY `idx_material` (`material_id`),
  ADD KEY `idx_user` (`user_id`);

--
-- Indexes for table `ai_recommendations`
--
ALTER TABLE `ai_recommendations`
  ADD PRIMARY KEY (`recommendation_id`),
  ADD KEY `material_id` (`material_id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_course` (`course_id`),
  ADD KEY `idx_viewed` (`is_viewed`);

--
-- Indexes for table `ai_study_plans`
--
ALTER TABLE `ai_study_plans`
  ADD PRIMARY KEY (`plan_id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_course` (`course_id`),
  ADD KEY `idx_status` (`status`);

--
-- Indexes for table `ai_summaries`
--
ALTER TABLE `ai_summaries`
  ADD PRIMARY KEY (`summary_id`),
  ADD KEY `idx_material` (`material_id`),
  ADD KEY `idx_user` (`user_id`);

--
-- Indexes for table `ai_usage_statistics`
--
ALTER TABLE `ai_usage_statistics`
  ADD PRIMARY KEY (`stat_id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_feature` (`feature_type`),
  ADD KEY `idx_date` (`created_at`);

--
-- Indexes for table `announcements`
--
ALTER TABLE `announcements`
  ADD PRIMARY KEY (`announcement_id`),
  ADD KEY `attachment_file_id` (`attachment_file_id`),
  ADD KEY `idx_course` (`course_id`),
  ADD KEY `idx_creator` (`created_by`),
  ADD KEY `idx_published` (`is_published`);

--
-- Indexes for table `api_integrations`
--
ALTER TABLE `api_integrations`
  ADD PRIMARY KEY (`integration_id`),
  ADD KEY `idx_campus` (`campus_id`),
  ADD KEY `idx_type` (`integration_type`);

--
-- Indexes for table `api_rate_limits`
--
ALTER TABLE `api_rate_limits`
  ADD PRIMARY KEY (`limit_id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_api_key` (`api_key`),
  ADD KEY `idx_endpoint` (`endpoint`),
  ADD KEY `idx_window` (`window_start`,`window_end`);

--
-- Indexes for table `assignments`
--
ALTER TABLE `assignments`
  ADD PRIMARY KEY (`assignment_id`),
  ADD KEY `created_by` (`created_by`),
  ADD KEY `idx_course` (`course_id`),
  ADD KEY `idx_due_date` (`due_date`);

--
-- Indexes for table `assignment_submissions`
--
ALTER TABLE `assignment_submissions`
  ADD PRIMARY KEY (`submission_id`),
  ADD KEY `file_id` (`file_id`),
  ADD KEY `idx_assignment` (`assignment_id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_user_assignment` (`user_id`,`assignment_id`),
  ADD KEY `idx_assignment_status` (`assignment_id`,`status`),
  ADD KEY `idx_submitted_date` (`submitted_at`);

--
-- Indexes for table `attendance_photos`
--
ALTER TABLE `attendance_photos`
  ADD PRIMARY KEY (`photo_id`),
  ADD KEY `file_id` (`file_id`),
  ADD KEY `uploaded_by` (`uploaded_by`),
  ADD KEY `idx_session` (`session_id`),
  ADD KEY `idx_status` (`processing_status`);

--
-- Indexes for table `attendance_records`
--
ALTER TABLE `attendance_records`
  ADD PRIMARY KEY (`record_id`),
  ADD UNIQUE KEY `unique_session_user` (`session_id`,`user_id`),
  ADD KEY `idx_session` (`session_id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_status` (`attendance_status`),
  ADD KEY `idx_session_status` (`session_id`,`attendance_status`),
  ADD KEY `idx_user_date` (`user_id`,`check_in_time`);

--
-- Indexes for table `attendance_sessions`
--
ALTER TABLE `attendance_sessions`
  ADD PRIMARY KEY (`session_id`),
  ADD KEY `idx_section` (`section_id`),
  ADD KEY `idx_date` (`session_date`),
  ADD KEY `idx_instructor` (`instructor_id`);

--
-- Indexes for table `audit_logs`
--
ALTER TABLE `audit_logs`
  ADD PRIMARY KEY (`log_id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_action` (`action_type`),
  ADD KEY `idx_entity` (`entity_type`,`entity_id`),
  ADD KEY `idx_date` (`created_at`);

--
-- Indexes for table `badges`
--
ALTER TABLE `badges`
  ADD PRIMARY KEY (`badge_id`),
  ADD UNIQUE KEY `badge_name` (`badge_name`);

--
-- Indexes for table `branding_settings`
--
ALTER TABLE `branding_settings`
  ADD PRIMARY KEY (`branding_id`),
  ADD UNIQUE KEY `campus_id` (`campus_id`);

--
-- Indexes for table `calendar_events`
--
ALTER TABLE `calendar_events`
  ADD PRIMARY KEY (`event_id`),
  ADD KEY `schedule_id` (`schedule_id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_course` (`course_id`),
  ADD KEY `idx_start` (`start_time`);

--
-- Indexes for table `calendar_integrations`
--
ALTER TABLE `calendar_integrations`
  ADD PRIMARY KEY (`integration_id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_status` (`sync_status`);

--
-- Indexes for table `campuses`
--
ALTER TABLE `campuses`
  ADD PRIMARY KEY (`campus_id`),
  ADD UNIQUE KEY `campus_code` (`campus_code`),
  ADD KEY `idx_code` (`campus_code`),
  ADD KEY `idx_status` (`status`);

--
-- Indexes for table `certificates`
--
ALTER TABLE `certificates`
  ADD PRIMARY KEY (`certificate_id`),
  ADD UNIQUE KEY `certificate_number` (`certificate_number`),
  ADD KEY `file_id` (`file_id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_course` (`course_id`),
  ADD KEY `idx_cert_number` (`certificate_number`);

--
-- Indexes for table `chatbot_conversations`
--
ALTER TABLE `chatbot_conversations`
  ADD PRIMARY KEY (`conversation_id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_course` (`course_id`),
  ADD KEY `idx_status` (`status`);

--
-- Indexes for table `chatbot_messages`
--
ALTER TABLE `chatbot_messages`
  ADD PRIMARY KEY (`message_id`),
  ADD KEY `idx_conversation` (`conversation_id`),
  ADD KEY `idx_sender` (`sender_type`);

--
-- Indexes for table `chat_messages`
--
ALTER TABLE `chat_messages`
  ADD PRIMARY KEY (`message_id`),
  ADD KEY `parent_message_id` (`parent_message_id`),
  ADD KEY `endorsed_by` (`endorsed_by`),
  ADD KEY `idx_thread` (`thread_id`),
  ADD KEY `idx_user` (`user_id`);

--
-- Indexes for table `collaborative_grading`
--
ALTER TABLE `collaborative_grading`
  ADD PRIMARY KEY (`collab_id`),
  ADD KEY `submission_id` (`submission_id`),
  ADD KEY `grader_1_id` (`grader_1_id`),
  ADD KEY `grader_2_id` (`grader_2_id`),
  ADD KEY `idx_assignment` (`assignment_id`),
  ADD KEY `idx_status` (`status`);

--
-- Indexes for table `communities`
--
ALTER TABLE `communities`
  ADD PRIMARY KEY (`community_id`),
  ADD KEY `idx_community_type` (`community_type`),
  ADD KEY `idx_department` (`department_id`),
  ADD KEY `communities_creator_fk` (`created_by`);

--
-- Indexes for table `community_posts`
--
ALTER TABLE `community_posts`
  ADD PRIMARY KEY (`post_id`),
  ADD KEY `idx_course` (`course_id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_community` (`community_id`);

--
-- Indexes for table `community_post_comments`
--
ALTER TABLE `community_post_comments`
  ADD PRIMARY KEY (`comment_id`),
  ADD KEY `parent_comment_id` (`parent_comment_id`),
  ADD KEY `idx_post` (`post_id`),
  ADD KEY `idx_user` (`user_id`);

--
-- Indexes for table `community_post_reactions`
--
ALTER TABLE `community_post_reactions`
  ADD PRIMARY KEY (`reaction_id`),
  ADD UNIQUE KEY `unique_post_user_reaction` (`post_id`,`user_id`,`reaction_type`),
  ADD KEY `idx_post` (`post_id`),
  ADD KEY `idx_user` (`user_id`);

--
-- Indexes for table `community_post_tags`
--
ALTER TABLE `community_post_tags`
  ADD PRIMARY KEY (`post_id`,`tag_id`),
  ADD KEY `post_tags_tag_fk` (`tag_id`);

--
-- Indexes for table `community_tags`
--
ALTER TABLE `community_tags`
  ADD PRIMARY KEY (`tag_id`),
  ADD UNIQUE KEY `unique_tag_name` (`name`);

--
-- Indexes for table `content_translations`
--
ALTER TABLE `content_translations`
  ADD PRIMARY KEY (`translation_id`),
  ADD UNIQUE KEY `unique_entity_field_lang` (`entity_type`,`entity_id`,`field_name`,`language_code`),
  ADD KEY `translator_id` (`translator_id`),
  ADD KEY `idx_entity` (`entity_type`,`entity_id`),
  ADD KEY `idx_language` (`language_code`);

--
-- Indexes for table `courses`
--
ALTER TABLE `courses`
  ADD PRIMARY KEY (`course_id`),
  ADD UNIQUE KEY `unique_course_code` (`department_id`,`course_code`),
  ADD KEY `idx_department` (`department_id`),
  ADD KEY `idx_status` (`status`);

--
-- Indexes for table `course_analytics`
--
ALTER TABLE `course_analytics`
  ADD PRIMARY KEY (`analytics_id`),
  ADD KEY `idx_course` (`course_id`),
  ADD KEY `idx_instructor` (`instructor_id`),
  ADD KEY `idx_date` (`calculation_date`);

--
-- Indexes for table `course_chat_threads`
--
ALTER TABLE `course_chat_threads`
  ADD PRIMARY KEY (`thread_id`),
  ADD KEY `idx_course` (`course_id`),
  ADD KEY `idx_creator` (`created_by`);

--
-- Indexes for table `course_enrollments`
--
ALTER TABLE `course_enrollments`
  ADD PRIMARY KEY (`enrollment_id`),
  ADD UNIQUE KEY `unique_enrollment` (`user_id`,`section_id`),
  ADD KEY `program_id` (`program_id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_section` (`section_id`),
  ADD KEY `idx_status` (`enrollment_status`),
  ADD KEY `idx_user_status` (`user_id`,`enrollment_status`),
  ADD KEY `idx_section_status` (`section_id`,`enrollment_status`),
  ADD KEY `idx_composite_lookup` (`user_id`,`section_id`,`enrollment_status`);

--
-- Indexes for table `course_instructors`
--
ALTER TABLE `course_instructors`
  ADD PRIMARY KEY (`assignment_id`),
  ADD UNIQUE KEY `unique_instructor_section` (`user_id`,`section_id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_section` (`section_id`);

--
-- Indexes for table `course_materials`
--
ALTER TABLE `course_materials`
  ADD PRIMARY KEY (`material_id`),
  ADD KEY `uploaded_by` (`uploaded_by`),
  ADD KEY `idx_course` (`course_id`),
  ADD KEY `idx_file` (`file_id`),
  ADD KEY `idx_type` (`material_type`);

--
-- Indexes for table `course_prerequisites`
--
ALTER TABLE `course_prerequisites`
  ADD PRIMARY KEY (`prerequisite_id`),
  ADD UNIQUE KEY `unique_prerequisite` (`course_id`,`prerequisite_course_id`),
  ADD KEY `prerequisite_course_id` (`prerequisite_course_id`);

--
-- Indexes for table `course_schedules`
--
ALTER TABLE `course_schedules`
  ADD PRIMARY KEY (`schedule_id`),
  ADD KEY `idx_section` (`section_id`);

--
-- Indexes for table `course_sections`
--
ALTER TABLE `course_sections`
  ADD PRIMARY KEY (`section_id`),
  ADD UNIQUE KEY `unique_section` (`course_id`,`semester_id`,`section_number`),
  ADD KEY `idx_course` (`course_id`),
  ADD KEY `idx_semester` (`semester_id`);

--
-- Indexes for table `course_tas`
--
ALTER TABLE `course_tas`
  ADD PRIMARY KEY (`assignment_id`),
  ADD UNIQUE KEY `unique_ta_section` (`user_id`,`section_id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_section` (`section_id`);

--
-- Indexes for table `daily_streaks`
--
ALTER TABLE `daily_streaks`
  ADD PRIMARY KEY (`streak_id`),
  ADD UNIQUE KEY `user_id` (`user_id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_streak` (`current_streak`);

--
-- Indexes for table `deadline_reminders`
--
ALTER TABLE `deadline_reminders`
  ADD PRIMARY KEY (`reminder_id`),
  ADD KEY `idx_task` (`task_id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_status` (`status`);

--
-- Indexes for table `departments`
--
ALTER TABLE `departments`
  ADD PRIMARY KEY (`department_id`),
  ADD UNIQUE KEY `unique_dept_code` (`campus_id`,`department_code`),
  ADD KEY `head_of_department_id` (`head_of_department_id`),
  ADD KEY `idx_campus` (`campus_id`);

--
-- Indexes for table `device_tokens`
--
ALTER TABLE `device_tokens`
  ADD PRIMARY KEY (`token_id`),
  ADD UNIQUE KEY `unique_user_token` (`user_id`,`device_token`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_active` (`is_active`);

--
-- Indexes for table `email_verifications`
--
ALTER TABLE `email_verifications`
  ADD PRIMARY KEY (`verification_id`),
  ADD KEY `idx_user_id` (`user_id`),
  ADD KEY `idx_token` (`verification_token`),
  ADD KEY `idx_used_expires` (`used`,`expires_at`);

--
-- Indexes for table `exam_schedules`
--
ALTER TABLE `exam_schedules`
  ADD PRIMARY KEY (`exam_id`),
  ADD KEY `idx_course` (`course_id`),
  ADD KEY `idx_semester` (`semester_id`),
  ADD KEY `idx_date` (`exam_date`);

--
-- Indexes for table `export_history`
--
ALTER TABLE `export_history`
  ADD PRIMARY KEY (`export_id`),
  ADD KEY `file_id` (`file_id`),
  ADD KEY `idx_report` (`report_id`),
  ADD KEY `idx_user` (`user_id`);

--
-- Indexes for table `face_recognition_data`
--
ALTER TABLE `face_recognition_data`
  ADD PRIMARY KEY (`face_data_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Indexes for table `feedback_responses`
--
ALTER TABLE `feedback_responses`
  ADD PRIMARY KEY (`response_id`),
  ADD KEY `idx_feedback` (`feedback_id`),
  ADD KEY `idx_ticket` (`ticket_id`),
  ADD KEY `idx_responder` (`responder_id`);

--
-- Indexes for table `files`
--
ALTER TABLE `files`
  ADD PRIMARY KEY (`file_id`),
  ADD KEY `idx_uploader` (`uploaded_by`),
  ADD KEY `idx_folder` (`folder_id`),
  ADD KEY `idx_checksum` (`checksum`),
  ADD KEY `idx_uploader_status` (`uploaded_by`,`status`),
  ADD KEY `idx_folder_status` (`folder_id`,`status`);

--
-- Indexes for table `file_permissions`
--
ALTER TABLE `file_permissions`
  ADD PRIMARY KEY (`permission_id`),
  ADD KEY `granted_by` (`granted_by`),
  ADD KEY `idx_file` (`file_id`),
  ADD KEY `idx_folder` (`folder_id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_role` (`role_id`);

--
-- Indexes for table `file_versions`
--
ALTER TABLE `file_versions`
  ADD PRIMARY KEY (`version_id`),
  ADD UNIQUE KEY `unique_file_version` (`file_id`,`version_number`),
  ADD KEY `uploaded_by` (`uploaded_by`),
  ADD KEY `idx_file` (`file_id`);

--
-- Indexes for table `folders`
--
ALTER TABLE `folders`
  ADD PRIMARY KEY (`folder_id`),
  ADD KEY `idx_parent` (`parent_folder_id`),
  ADD KEY `idx_creator` (`created_by`);

--
-- Indexes for table `forum_categories`
--
ALTER TABLE `forum_categories`
  ADD PRIMARY KEY (`category_id`),
  ADD KEY `idx_course` (`course_id`);

--
-- Indexes for table `generated_reports`
--
ALTER TABLE `generated_reports`
  ADD PRIMARY KEY (`report_id`),
  ADD KEY `template_id` (`template_id`),
  ADD KEY `file_id` (`file_id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_status` (`generation_status`);

--
-- Indexes for table `gpa_calculations`
--
ALTER TABLE `gpa_calculations`
  ADD PRIMARY KEY (`gpa_id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_semester` (`semester_id`);

--
-- Indexes for table `grades`
--
ALTER TABLE `grades`
  ADD PRIMARY KEY (`grade_id`),
  ADD KEY `assignment_id` (`assignment_id`),
  ADD KEY `quiz_id` (`quiz_id`),
  ADD KEY `lab_id` (`lab_id`),
  ADD KEY `graded_by` (`graded_by`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_course` (`course_id`),
  ADD KEY `idx_type` (`grade_type`),
  ADD KEY `idx_published` (`is_published`),
  ADD KEY `idx_user_course` (`user_id`,`course_id`),
  ADD KEY `idx_course_published` (`course_id`,`is_published`),
  ADD KEY `idx_user_published` (`user_id`,`is_published`);

--
-- Indexes for table `grade_components`
--
ALTER TABLE `grade_components`
  ADD PRIMARY KEY (`component_id`),
  ADD KEY `rubric_id` (`rubric_id`),
  ADD KEY `idx_grade` (`grade_id`);

--
-- Indexes for table `image_text_extractions`
--
ALTER TABLE `image_text_extractions`
  ADD PRIMARY KEY (`extraction_id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_file` (`image_file_id`),
  ADD KEY `idx_status` (`processing_status`);

--
-- Indexes for table `labs`
--
ALTER TABLE `labs`
  ADD PRIMARY KEY (`lab_id`),
  ADD KEY `created_by` (`created_by`),
  ADD KEY `idx_course` (`course_id`),
  ADD KEY `idx_due_date` (`due_date`);

--
-- Indexes for table `lab_attendance`
--
ALTER TABLE `lab_attendance`
  ADD PRIMARY KEY (`attendance_id`),
  ADD UNIQUE KEY `unique_lab_user` (`lab_id`,`user_id`),
  ADD KEY `marked_by` (`marked_by`),
  ADD KEY `idx_lab` (`lab_id`),
  ADD KEY `idx_user` (`user_id`);

--
-- Indexes for table `lab_instructions`
--
ALTER TABLE `lab_instructions`
  ADD PRIMARY KEY (`instruction_id`),
  ADD KEY `file_id` (`file_id`),
  ADD KEY `idx_lab` (`lab_id`);

--
-- Indexes for table `lab_submissions`
--
ALTER TABLE `lab_submissions`
  ADD PRIMARY KEY (`submission_id`),
  ADD KEY `file_id` (`file_id`),
  ADD KEY `idx_lab` (`lab_id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_status` (`status`);

--
-- Indexes for table `language_preferences`
--
ALTER TABLE `language_preferences`
  ADD PRIMARY KEY (`preference_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Indexes for table `leaderboards`
--
ALTER TABLE `leaderboards`
  ADD PRIMARY KEY (`leaderboard_id`),
  ADD KEY `department_id` (`department_id`),
  ADD KEY `idx_type` (`leaderboard_type`),
  ADD KEY `idx_course` (`course_id`),
  ADD KEY `idx_semester` (`semester_id`);

--
-- Indexes for table `leaderboard_rankings`
--
ALTER TABLE `leaderboard_rankings`
  ADD PRIMARY KEY (`ranking_id`),
  ADD UNIQUE KEY `unique_leaderboard_user` (`leaderboard_id`,`user_id`),
  ADD KEY `idx_leaderboard` (`leaderboard_id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_rank` (`rank_position`);

--
-- Indexes for table `learning_analytics`
--
ALTER TABLE `learning_analytics`
  ADD PRIMARY KEY (`analytics_id`),
  ADD KEY `progress_id` (`progress_id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_course` (`course_id`),
  ADD KEY `idx_date` (`metric_date`);

--
-- Indexes for table `lecture_sections_labs`
--
ALTER TABLE `lecture_sections_labs`
  ADD PRIMARY KEY (`organization_id`),
  ADD KEY `material_id` (`material_id`),
  ADD KEY `idx_course` (`course_id`),
  ADD KEY `idx_type` (`organization_type`);

--
-- Indexes for table `live_sessions`
--
ALTER TABLE `live_sessions`
  ADD PRIMARY KEY (`session_id`),
  ADD KEY `recording_file_id` (`recording_file_id`),
  ADD KEY `idx_course` (`course_id`),
  ADD KEY `idx_instructor` (`instructor_id`),
  ADD KEY `idx_status` (`status`);

--
-- Indexes for table `live_session_participants`
--
ALTER TABLE `live_session_participants`
  ADD PRIMARY KEY (`participant_id`),
  ADD UNIQUE KEY `unique_session_user` (`session_id`,`user_id`),
  ADD KEY `idx_session` (`session_id`),
  ADD KEY `idx_user` (`user_id`);

--
-- Indexes for table `localization_strings`
--
ALTER TABLE `localization_strings`
  ADD PRIMARY KEY (`string_id`),
  ADD UNIQUE KEY `unique_lang_key` (`language_code`,`string_key`),
  ADD KEY `idx_language` (`language_code`);

--
-- Indexes for table `login_attempts`
--
ALTER TABLE `login_attempts`
  ADD PRIMARY KEY (`attempt_id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_email` (`email`),
  ADD KEY `idx_ip` (`ip_address`),
  ADD KEY `idx_date` (`attempted_at`);

--
-- Indexes for table `messages`
--
ALTER TABLE `messages`
  ADD PRIMARY KEY (`message_id`),
  ADD KEY `parent_message_id` (`parent_message_id`),
  ADD KEY `idx_sender` (`sender_id`),
  ADD KEY `idx_sent` (`sent_at`),
  ADD KEY `idx_sender_type` (`sender_id`,`message_type`),
  ADD KEY `idx_sent_read` (`sent_at`,`read_status`),
  ADD KEY `fk_messages_reply_to` (`reply_to_id`);

--
-- Indexes for table `message_participants`
--
ALTER TABLE `message_participants`
  ADD PRIMARY KEY (`participant_id`),
  ADD UNIQUE KEY `unique_message_user` (`message_id`,`user_id`),
  ADD KEY `idx_message` (`message_id`),
  ADD KEY `idx_user` (`user_id`);

--
-- Indexes for table `milestone_definitions`
--
ALTER TABLE `milestone_definitions`
  ADD PRIMARY KEY (`milestone_id`),
  ADD KEY `idx_badge` (`badge_id`);

--
-- Indexes for table `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`notification_id`),
  ADD KEY `announcement_id` (`announcement_id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_read` (`is_read`),
  ADD KEY `idx_type` (`notification_type`),
  ADD KEY `idx_user_read_type` (`user_id`,`is_read`,`notification_type`),
  ADD KEY `idx_user_date` (`user_id`,`created_at`);

--
-- Indexes for table `notification_preferences`
--
ALTER TABLE `notification_preferences`
  ADD PRIMARY KEY (`preference_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Indexes for table `office_hour_appointments`
--
ALTER TABLE `office_hour_appointments`
  ADD PRIMARY KEY (`appointment_id`),
  ADD KEY `fk_appointment_slot` (`slot_id`),
  ADD KEY `fk_appointment_student` (`student_id`);

--
-- Indexes for table `office_hour_slots`
--
ALTER TABLE `office_hour_slots`
  ADD PRIMARY KEY (`slot_id`),
  ADD KEY `fk_office_hours_instructor` (`instructor_id`);

--
-- Indexes for table `offline_sync_queue`
--
ALTER TABLE `offline_sync_queue`
  ADD PRIMARY KEY (`sync_id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_status` (`sync_status`),
  ADD KEY `idx_entity` (`entity_type`,`entity_id`);

--
-- Indexes for table `password_resets`
--
ALTER TABLE `password_resets`
  ADD PRIMARY KEY (`reset_id`),
  ADD KEY `idx_token` (`reset_token`),
  ADD KEY `idx_user` (`user_id`);

--
-- Indexes for table `payment_transactions`
--
ALTER TABLE `payment_transactions`
  ADD PRIMARY KEY (`transaction_id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_course` (`course_id`),
  ADD KEY `idx_status` (`transaction_status`);

--
-- Indexes for table `peer_reviews`
--
ALTER TABLE `peer_reviews`
  ADD PRIMARY KEY (`review_id`),
  ADD KEY `idx_submission` (`submission_id`),
  ADD KEY `idx_reviewer` (`reviewer_id`),
  ADD KEY `idx_reviewee` (`reviewee_id`);

--
-- Indexes for table `performance_metrics`
--
ALTER TABLE `performance_metrics`
  ADD PRIMARY KEY (`metric_id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_course` (`course_id`),
  ADD KEY `idx_date` (`calculation_date`);

--
-- Indexes for table `permissions`
--
ALTER TABLE `permissions`
  ADD PRIMARY KEY (`permission_id`),
  ADD UNIQUE KEY `permission_name` (`permission_name`);

--
-- Indexes for table `points_rules`
--
ALTER TABLE `points_rules`
  ADD PRIMARY KEY (`rule_id`),
  ADD UNIQUE KEY `action_type` (`action_type`);

--
-- Indexes for table `programs`
--
ALTER TABLE `programs`
  ADD PRIMARY KEY (`program_id`),
  ADD UNIQUE KEY `unique_program_code` (`department_id`,`program_code`),
  ADD KEY `idx_department` (`department_id`);

--
-- Indexes for table `quizzes`
--
ALTER TABLE `quizzes`
  ADD PRIMARY KEY (`quiz_id`),
  ADD KEY `created_by` (`created_by`),
  ADD KEY `idx_course` (`course_id`),
  ADD KEY `idx_available` (`available_from`,`available_until`);

--
-- Indexes for table `quiz_answers`
--
ALTER TABLE `quiz_answers`
  ADD PRIMARY KEY (`answer_id`),
  ADD UNIQUE KEY `unique_attempt_question` (`attempt_id`,`question_id`),
  ADD KEY `question_id` (`question_id`),
  ADD KEY `idx_attempt` (`attempt_id`);

--
-- Indexes for table `quiz_attempts`
--
ALTER TABLE `quiz_attempts`
  ADD PRIMARY KEY (`attempt_id`),
  ADD KEY `idx_quiz` (`quiz_id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_user_quiz_status` (`user_id`,`quiz_id`,`status`),
  ADD KEY `idx_quiz_date` (`quiz_id`,`started_at`);

--
-- Indexes for table `quiz_difficulty_levels`
--
ALTER TABLE `quiz_difficulty_levels`
  ADD PRIMARY KEY (`difficulty_id`),
  ADD UNIQUE KEY `level_name` (`level_name`);

--
-- Indexes for table `quiz_questions`
--
ALTER TABLE `quiz_questions`
  ADD PRIMARY KEY (`question_id`),
  ADD KEY `difficulty_level_id` (`difficulty_level_id`),
  ADD KEY `idx_quiz` (`quiz_id`);

--
-- Indexes for table `report_templates`
--
ALTER TABLE `report_templates`
  ADD PRIMARY KEY (`template_id`),
  ADD KEY `created_by` (`created_by`),
  ADD KEY `idx_type` (`template_type`);

--
-- Indexes for table `rewards`
--
ALTER TABLE `rewards`
  ADD PRIMARY KEY (`reward_id`),
  ADD KEY `achievement_id` (`achievement_id`);

--
-- Indexes for table `reward_redemptions`
--
ALTER TABLE `reward_redemptions`
  ADD PRIMARY KEY (`redemption_id`),
  ADD KEY `approved_by` (`approved_by`),
  ADD KEY `idx_reward` (`reward_id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_status` (`redemption_status`);

--
-- Indexes for table `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`role_id`),
  ADD UNIQUE KEY `role_name` (`role_name`);

--
-- Indexes for table `role_permissions`
--
ALTER TABLE `role_permissions`
  ADD PRIMARY KEY (`role_permission_id`),
  ADD UNIQUE KEY `unique_role_permission` (`role_id`,`permission_id`),
  ADD KEY `permission_id` (`permission_id`);

--
-- Indexes for table `rubrics`
--
ALTER TABLE `rubrics`
  ADD PRIMARY KEY (`rubric_id`),
  ADD KEY `created_by` (`created_by`),
  ADD KEY `idx_course` (`course_id`);

--
-- Indexes for table `scheduled_notifications`
--
ALTER TABLE `scheduled_notifications`
  ADD PRIMARY KEY (`scheduled_id`),
  ADD KEY `created_by` (`created_by`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_scheduled` (`scheduled_for`),
  ADD KEY `idx_status` (`status`);

--
-- Indexes for table `search_history`
--
ALTER TABLE `search_history`
  ADD PRIMARY KEY (`history_id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_query` (`search_query`(255)),
  ADD KEY `idx_date` (`created_at`);

--
-- Indexes for table `search_index`
--
ALTER TABLE `search_index`
  ADD PRIMARY KEY (`index_id`),
  ADD KEY `idx_entity` (`entity_type`,`entity_id`),
  ADD KEY `idx_campus` (`campus_id`),
  ADD KEY `idx_course` (`course_id`);
ALTER TABLE `search_index` ADD FULLTEXT KEY `idx_search` (`title`,`content`,`keywords`);

--
-- Indexes for table `security_logs`
--
ALTER TABLE `security_logs`
  ADD PRIMARY KEY (`log_id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_event` (`event_type`),
  ADD KEY `idx_severity` (`severity`),
  ADD KEY `idx_date` (`created_at`);

--
-- Indexes for table `semesters`
--
ALTER TABLE `semesters`
  ADD PRIMARY KEY (`semester_id`),
  ADD UNIQUE KEY `semester_code` (`semester_code`),
  ADD KEY `idx_code` (`semester_code`),
  ADD KEY `idx_dates` (`start_date`,`end_date`);

--
-- Indexes for table `server_monitoring`
--
ALTER TABLE `server_monitoring`
  ADD PRIMARY KEY (`monitor_id`),
  ADD KEY `idx_server` (`server_name`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_checked` (`checked_at`);

--
-- Indexes for table `sessions`
--
ALTER TABLE `sessions`
  ADD PRIMARY KEY (`session_id`),
  ADD UNIQUE KEY `session_token` (`session_token`),
  ADD KEY `idx_token` (`session_token`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_expires` (`expires_at`);

--
-- Indexes for table `ssl_certificates`
--
ALTER TABLE `ssl_certificates`
  ADD PRIMARY KEY (`cert_id`),
  ADD KEY `idx_campus` (`campus_id`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_expiry` (`valid_until`);

--
-- Indexes for table `student_progress`
--
ALTER TABLE `student_progress`
  ADD PRIMARY KEY (`progress_id`),
  ADD UNIQUE KEY `unique_user_course` (`user_id`,`course_id`),
  ADD KEY `enrollment_id` (`enrollment_id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_course` (`course_id`),
  ADD KEY `idx_user_course_completion` (`user_id`,`course_id`,`completion_percentage`);

--
-- Indexes for table `student_tasks`
--
ALTER TABLE `student_tasks`
  ADD PRIMARY KEY (`task_id`),
  ADD KEY `assignment_id` (`assignment_id`),
  ADD KEY `quiz_id` (`quiz_id`),
  ADD KEY `lab_id` (`lab_id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_due_date` (`due_date`);

--
-- Indexes for table `study_groups`
--
ALTER TABLE `study_groups`
  ADD PRIMARY KEY (`group_id`),
  ADD KEY `idx_course` (`course_id`),
  ADD KEY `idx_creator` (`created_by`);

--
-- Indexes for table `study_group_members`
--
ALTER TABLE `study_group_members`
  ADD PRIMARY KEY (`member_id`),
  ADD UNIQUE KEY `unique_group_user` (`group_id`,`user_id`),
  ADD KEY `idx_group` (`group_id`),
  ADD KEY `idx_user` (`user_id`);

--
-- Indexes for table `subscription_plans`
--
ALTER TABLE `subscription_plans`
  ADD PRIMARY KEY (`plan_id`);

--
-- Indexes for table `support_tickets`
--
ALTER TABLE `support_tickets`
  ADD PRIMARY KEY (`ticket_id`),
  ADD UNIQUE KEY `ticket_number` (`ticket_number`),
  ADD KEY `feedback_id` (`feedback_id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_ticket_number` (`ticket_number`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_assigned` (`assigned_to`);

--
-- Indexes for table `system_errors`
--
ALTER TABLE `system_errors`
  ADD PRIMARY KEY (`error_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `resolved_by` (`resolved_by`),
  ADD KEY `idx_type` (`error_type`),
  ADD KEY `idx_severity` (`severity`),
  ADD KEY `idx_resolved` (`is_resolved`),
  ADD KEY `idx_date` (`created_at`);

--
-- Indexes for table `system_settings`
--
ALTER TABLE `system_settings`
  ADD PRIMARY KEY (`setting_id`),
  ADD UNIQUE KEY `setting_key` (`setting_key`);

--
-- Indexes for table `task_completion`
--
ALTER TABLE `task_completion`
  ADD PRIMARY KEY (`completion_id`),
  ADD UNIQUE KEY `task_id` (`task_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `ta_instructor_access`
--
ALTER TABLE `ta_instructor_access`
  ADD PRIMARY KEY (`access_id`),
  ADD KEY `idx_instructor` (`instructor_id`),
  ADD KEY `idx_ta` (`ta_id`),
  ADD KEY `idx_section` (`section_id`);

--
-- Indexes for table `theme_preferences`
--
ALTER TABLE `theme_preferences`
  ADD PRIMARY KEY (`preference_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Indexes for table `two_factor_auth`
--
ALTER TABLE `two_factor_auth`
  ADD PRIMARY KEY (`auth_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `idx_email` (`email`),
  ADD KEY `idx_campus` (`campus_id`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_email_status` (`email`,`status`),
  ADD KEY `idx_campus_status` (`campus_id`,`status`);

--
-- Indexes for table `user_badges`
--
ALTER TABLE `user_badges`
  ADD PRIMARY KEY (`user_badge_id`),
  ADD UNIQUE KEY `unique_user_badge` (`user_id`,`badge_id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_badge` (`badge_id`);

--
-- Indexes for table `user_feedback`
--
ALTER TABLE `user_feedback`
  ADD PRIMARY KEY (`feedback_id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_type` (`feedback_type`),
  ADD KEY `idx_status` (`status`);

--
-- Indexes for table `user_levels`
--
ALTER TABLE `user_levels`
  ADD PRIMARY KEY (`level_id`),
  ADD UNIQUE KEY `user_id` (`user_id`),
  ADD KEY `idx_level` (`current_level`),
  ADD KEY `idx_tier` (`tier`);

--
-- Indexes for table `user_preferences`
--
ALTER TABLE `user_preferences`
  ADD PRIMARY KEY (`preference_id`),
  ADD UNIQUE KEY `uq_user_preferences_user_id` (`user_id`);

--
-- Indexes for table `user_roles`
--
ALTER TABLE `user_roles`
  ADD PRIMARY KEY (`user_role_id`),
  ADD UNIQUE KEY `unique_user_role` (`user_id`,`role_id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_role` (`role_id`);

--
-- Indexes for table `user_subscriptions`
--
ALTER TABLE `user_subscriptions`
  ADD PRIMARY KEY (`subscription_id`),
  ADD KEY `fk_subscription_user` (`user_id`),
  ADD KEY `fk_subscription_plan` (`plan_id`);

--
-- Indexes for table `voice_recordings`
--
ALTER TABLE `voice_recordings`
  ADD PRIMARY KEY (`recording_id`),
  ADD KEY `file_id` (`file_id`),
  ADD KEY `transcription_id` (`transcription_id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_course` (`course_id`);

--
-- Indexes for table `voice_transcriptions`
--
ALTER TABLE `voice_transcriptions`
  ADD PRIMARY KEY (`transcription_id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_file` (`audio_file_id`);

--
-- Indexes for table `weak_topics_analysis`
--
ALTER TABLE `weak_topics_analysis`
  ADD PRIMARY KEY (`analysis_id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_course` (`course_id`);

--
-- Indexes for table `xp_transactions`
--
ALTER TABLE `xp_transactions`
  ADD PRIMARY KEY (`transaction_id`),
  ADD KEY `rule_id` (`rule_id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_source` (`source_type`,`source_id`),
  ADD KEY `idx_date` (`created_at`),
  ADD KEY `idx_user_date` (`user_id`,`created_at`),
  ADD KEY `idx_source_composite` (`source_type`,`source_id`,`user_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `achievements`
--
ALTER TABLE `achievements`
  MODIFY `achievement_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `activity_logs`
--
ALTER TABLE `activity_logs`
  MODIFY `log_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `ai_attendance_processing`
--
ALTER TABLE `ai_attendance_processing`
  MODIFY `processing_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `ai_feedback`
--
ALTER TABLE `ai_feedback`
  MODIFY `feedback_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `ai_flashcards`
--
ALTER TABLE `ai_flashcards`
  MODIFY `flashcard_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `ai_grading_results`
--
ALTER TABLE `ai_grading_results`
  MODIFY `grading_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `ai_quizzes`
--
ALTER TABLE `ai_quizzes`
  MODIFY `ai_quiz_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `ai_recommendations`
--
ALTER TABLE `ai_recommendations`
  MODIFY `recommendation_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `ai_study_plans`
--
ALTER TABLE `ai_study_plans`
  MODIFY `plan_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `ai_summaries`
--
ALTER TABLE `ai_summaries`
  MODIFY `summary_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `ai_usage_statistics`
--
ALTER TABLE `ai_usage_statistics`
  MODIFY `stat_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `announcements`
--
ALTER TABLE `announcements`
  MODIFY `announcement_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `api_integrations`
--
ALTER TABLE `api_integrations`
  MODIFY `integration_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `api_rate_limits`
--
ALTER TABLE `api_rate_limits`
  MODIFY `limit_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `assignments`
--
ALTER TABLE `assignments`
  MODIFY `assignment_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT for table `assignment_submissions`
--
ALTER TABLE `assignment_submissions`
  MODIFY `submission_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- AUTO_INCREMENT for table `attendance_photos`
--
ALTER TABLE `attendance_photos`
  MODIFY `photo_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `attendance_records`
--
ALTER TABLE `attendance_records`
  MODIFY `record_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=124;

--
-- AUTO_INCREMENT for table `attendance_sessions`
--
ALTER TABLE `attendance_sessions`
  MODIFY `session_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT for table `audit_logs`
--
ALTER TABLE `audit_logs`
  MODIFY `log_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `badges`
--
ALTER TABLE `badges`
  MODIFY `badge_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `branding_settings`
--
ALTER TABLE `branding_settings`
  MODIFY `branding_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `calendar_events`
--
ALTER TABLE `calendar_events`
  MODIFY `event_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `calendar_integrations`
--
ALTER TABLE `calendar_integrations`
  MODIFY `integration_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `campuses`
--
ALTER TABLE `campuses`
  MODIFY `campus_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT for table `certificates`
--
ALTER TABLE `certificates`
  MODIFY `certificate_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `chatbot_conversations`
--
ALTER TABLE `chatbot_conversations`
  MODIFY `conversation_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `chatbot_messages`
--
ALTER TABLE `chatbot_messages`
  MODIFY `message_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `chat_messages`
--
ALTER TABLE `chat_messages`
  MODIFY `message_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `collaborative_grading`
--
ALTER TABLE `collaborative_grading`
  MODIFY `collab_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `communities`
--
ALTER TABLE `communities`
  MODIFY `community_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `community_posts`
--
ALTER TABLE `community_posts`
  MODIFY `post_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `community_post_comments`
--
ALTER TABLE `community_post_comments`
  MODIFY `comment_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `community_post_reactions`
--
ALTER TABLE `community_post_reactions`
  MODIFY `reaction_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT for table `community_tags`
--
ALTER TABLE `community_tags`
  MODIFY `tag_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `content_translations`
--
ALTER TABLE `content_translations`
  MODIFY `translation_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `courses`
--
ALTER TABLE `courses`
  MODIFY `course_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT for table `course_analytics`
--
ALTER TABLE `course_analytics`
  MODIFY `analytics_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `course_chat_threads`
--
ALTER TABLE `course_chat_threads`
  MODIFY `thread_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `course_enrollments`
--
ALTER TABLE `course_enrollments`
  MODIFY `enrollment_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=233;

--
-- AUTO_INCREMENT for table `course_instructors`
--
ALTER TABLE `course_instructors`
  MODIFY `assignment_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `course_materials`
--
ALTER TABLE `course_materials`
  MODIFY `material_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `course_prerequisites`
--
ALTER TABLE `course_prerequisites`
  MODIFY `prerequisite_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `course_schedules`
--
ALTER TABLE `course_schedules`
  MODIFY `schedule_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `course_sections`
--
ALTER TABLE `course_sections`
  MODIFY `section_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT for table `course_tas`
--
ALTER TABLE `course_tas`
  MODIFY `assignment_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `daily_streaks`
--
ALTER TABLE `daily_streaks`
  MODIFY `streak_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `deadline_reminders`
--
ALTER TABLE `deadline_reminders`
  MODIFY `reminder_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `departments`
--
ALTER TABLE `departments`
  MODIFY `department_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT for table `device_tokens`
--
ALTER TABLE `device_tokens`
  MODIFY `token_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `email_verifications`
--
ALTER TABLE `email_verifications`
  MODIFY `verification_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT for table `exam_schedules`
--
ALTER TABLE `exam_schedules`
  MODIFY `exam_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `export_history`
--
ALTER TABLE `export_history`
  MODIFY `export_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `face_recognition_data`
--
ALTER TABLE `face_recognition_data`
  MODIFY `face_data_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `feedback_responses`
--
ALTER TABLE `feedback_responses`
  MODIFY `response_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `files`
--
ALTER TABLE `files`
  MODIFY `file_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `file_permissions`
--
ALTER TABLE `file_permissions`
  MODIFY `permission_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `file_versions`
--
ALTER TABLE `file_versions`
  MODIFY `version_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `folders`
--
ALTER TABLE `folders`
  MODIFY `folder_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `forum_categories`
--
ALTER TABLE `forum_categories`
  MODIFY `category_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `generated_reports`
--
ALTER TABLE `generated_reports`
  MODIFY `report_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `gpa_calculations`
--
ALTER TABLE `gpa_calculations`
  MODIFY `gpa_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `grades`
--
ALTER TABLE `grades`
  MODIFY `grade_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `grade_components`
--
ALTER TABLE `grade_components`
  MODIFY `component_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `image_text_extractions`
--
ALTER TABLE `image_text_extractions`
  MODIFY `extraction_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `labs`
--
ALTER TABLE `labs`
  MODIFY `lab_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `lab_attendance`
--
ALTER TABLE `lab_attendance`
  MODIFY `attendance_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `lab_instructions`
--
ALTER TABLE `lab_instructions`
  MODIFY `instruction_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `lab_submissions`
--
ALTER TABLE `lab_submissions`
  MODIFY `submission_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `language_preferences`
--
ALTER TABLE `language_preferences`
  MODIFY `preference_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `leaderboards`
--
ALTER TABLE `leaderboards`
  MODIFY `leaderboard_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `leaderboard_rankings`
--
ALTER TABLE `leaderboard_rankings`
  MODIFY `ranking_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `learning_analytics`
--
ALTER TABLE `learning_analytics`
  MODIFY `analytics_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `lecture_sections_labs`
--
ALTER TABLE `lecture_sections_labs`
  MODIFY `organization_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `live_sessions`
--
ALTER TABLE `live_sessions`
  MODIFY `session_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `live_session_participants`
--
ALTER TABLE `live_session_participants`
  MODIFY `participant_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `localization_strings`
--
ALTER TABLE `localization_strings`
  MODIFY `string_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `login_attempts`
--
ALTER TABLE `login_attempts`
  MODIFY `attempt_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `messages`
--
ALTER TABLE `messages`
  MODIFY `message_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=78;

--
-- AUTO_INCREMENT for table `message_participants`
--
ALTER TABLE `message_participants`
  MODIFY `participant_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=162;

--
-- AUTO_INCREMENT for table `milestone_definitions`
--
ALTER TABLE `milestone_definitions`
  MODIFY `milestone_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `notifications`
--
ALTER TABLE `notifications`
  MODIFY `notification_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT for table `notification_preferences`
--
ALTER TABLE `notification_preferences`
  MODIFY `preference_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `office_hour_appointments`
--
ALTER TABLE `office_hour_appointments`
  MODIFY `appointment_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `office_hour_slots`
--
ALTER TABLE `office_hour_slots`
  MODIFY `slot_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `offline_sync_queue`
--
ALTER TABLE `offline_sync_queue`
  MODIFY `sync_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `password_resets`
--
ALTER TABLE `password_resets`
  MODIFY `reset_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `payment_transactions`
--
ALTER TABLE `payment_transactions`
  MODIFY `transaction_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `peer_reviews`
--
ALTER TABLE `peer_reviews`
  MODIFY `review_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `performance_metrics`
--
ALTER TABLE `performance_metrics`
  MODIFY `metric_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `permissions`
--
ALTER TABLE `permissions`
  MODIFY `permission_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `points_rules`
--
ALTER TABLE `points_rules`
  MODIFY `rule_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `programs`
--
ALTER TABLE `programs`
  MODIFY `program_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT for table `quizzes`
--
ALTER TABLE `quizzes`
  MODIFY `quiz_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `quiz_answers`
--
ALTER TABLE `quiz_answers`
  MODIFY `answer_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `quiz_attempts`
--
ALTER TABLE `quiz_attempts`
  MODIFY `attempt_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `quiz_difficulty_levels`
--
ALTER TABLE `quiz_difficulty_levels`
  MODIFY `difficulty_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `quiz_questions`
--
ALTER TABLE `quiz_questions`
  MODIFY `question_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- AUTO_INCREMENT for table `report_templates`
--
ALTER TABLE `report_templates`
  MODIFY `template_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `rewards`
--
ALTER TABLE `rewards`
  MODIFY `reward_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `reward_redemptions`
--
ALTER TABLE `reward_redemptions`
  MODIFY `redemption_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `roles`
--
ALTER TABLE `roles`
  MODIFY `role_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `role_permissions`
--
ALTER TABLE `role_permissions`
  MODIFY `role_permission_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;

--
-- AUTO_INCREMENT for table `rubrics`
--
ALTER TABLE `rubrics`
  MODIFY `rubric_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `scheduled_notifications`
--
ALTER TABLE `scheduled_notifications`
  MODIFY `scheduled_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `search_history`
--
ALTER TABLE `search_history`
  MODIFY `history_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `search_index`
--
ALTER TABLE `search_index`
  MODIFY `index_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `security_logs`
--
ALTER TABLE `security_logs`
  MODIFY `log_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `semesters`
--
ALTER TABLE `semesters`
  MODIFY `semester_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `server_monitoring`
--
ALTER TABLE `server_monitoring`
  MODIFY `monitor_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `sessions`
--
ALTER TABLE `sessions`
  MODIFY `session_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=372;

--
-- AUTO_INCREMENT for table `ssl_certificates`
--
ALTER TABLE `ssl_certificates`
  MODIFY `cert_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `student_progress`
--
ALTER TABLE `student_progress`
  MODIFY `progress_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `student_tasks`
--
ALTER TABLE `student_tasks`
  MODIFY `task_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `study_groups`
--
ALTER TABLE `study_groups`
  MODIFY `group_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `study_group_members`
--
ALTER TABLE `study_group_members`
  MODIFY `member_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `subscription_plans`
--
ALTER TABLE `subscription_plans`
  MODIFY `plan_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `support_tickets`
--
ALTER TABLE `support_tickets`
  MODIFY `ticket_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `system_errors`
--
ALTER TABLE `system_errors`
  MODIFY `error_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `system_settings`
--
ALTER TABLE `system_settings`
  MODIFY `setting_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `task_completion`
--
ALTER TABLE `task_completion`
  MODIFY `completion_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `ta_instructor_access`
--
ALTER TABLE `ta_instructor_access`
  MODIFY `access_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `theme_preferences`
--
ALTER TABLE `theme_preferences`
  MODIFY `preference_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `two_factor_auth`
--
ALTER TABLE `two_factor_auth`
  MODIFY `auth_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `user_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=63;

--
-- AUTO_INCREMENT for table `user_badges`
--
ALTER TABLE `user_badges`
  MODIFY `user_badge_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `user_feedback`
--
ALTER TABLE `user_feedback`
  MODIFY `feedback_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `user_levels`
--
ALTER TABLE `user_levels`
  MODIFY `level_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `user_preferences`
--
ALTER TABLE `user_preferences`
  MODIFY `preference_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `user_roles`
--
ALTER TABLE `user_roles`
  MODIFY `user_role_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=54;

--
-- AUTO_INCREMENT for table `user_subscriptions`
--
ALTER TABLE `user_subscriptions`
  MODIFY `subscription_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `voice_recordings`
--
ALTER TABLE `voice_recordings`
  MODIFY `recording_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `voice_transcriptions`
--
ALTER TABLE `voice_transcriptions`
  MODIFY `transcription_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `weak_topics_analysis`
--
ALTER TABLE `weak_topics_analysis`
  MODIFY `analysis_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `xp_transactions`
--
ALTER TABLE `xp_transactions`
  MODIFY `transaction_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `achievements`
--
ALTER TABLE `achievements`
  ADD CONSTRAINT `achievements_ibfk_1` FOREIGN KEY (`reward_badge_id`) REFERENCES `badges` (`badge_id`) ON DELETE SET NULL;

--
-- Constraints for table `activity_logs`
--
ALTER TABLE `activity_logs`
  ADD CONSTRAINT `activity_logs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `ai_attendance_processing`
--
ALTER TABLE `ai_attendance_processing`
  ADD CONSTRAINT `ai_attendance_processing_ibfk_1` FOREIGN KEY (`session_id`) REFERENCES `attendance_sessions` (`session_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `ai_attendance_processing_ibfk_2` FOREIGN KEY (`photo_id`) REFERENCES `attendance_photos` (`photo_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `ai_attendance_processing_ibfk_3` FOREIGN KEY (`reviewed_by`) REFERENCES `users` (`user_id`) ON DELETE SET NULL;

--
-- Constraints for table `ai_feedback`
--
ALTER TABLE `ai_feedback`
  ADD CONSTRAINT `ai_feedback_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `ai_feedback_ibfk_2` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`) ON DELETE CASCADE;

--
-- Constraints for table `ai_flashcards`
--
ALTER TABLE `ai_flashcards`
  ADD CONSTRAINT `ai_flashcards_ibfk_1` FOREIGN KEY (`material_id`) REFERENCES `course_materials` (`material_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `ai_flashcards_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `ai_grading_results`
--
ALTER TABLE `ai_grading_results`
  ADD CONSTRAINT `ai_grading_results_ibfk_1` FOREIGN KEY (`submission_id`) REFERENCES `assignment_submissions` (`submission_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `ai_grading_results_ibfk_2` FOREIGN KEY (`quiz_attempt_id`) REFERENCES `quiz_attempts` (`attempt_id`) ON DELETE CASCADE;

--
-- Constraints for table `ai_quizzes`
--
ALTER TABLE `ai_quizzes`
  ADD CONSTRAINT `ai_quizzes_ibfk_1` FOREIGN KEY (`material_id`) REFERENCES `course_materials` (`material_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `ai_quizzes_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `ai_quizzes_ibfk_3` FOREIGN KEY (`difficulty_id`) REFERENCES `quiz_difficulty_levels` (`difficulty_id`) ON DELETE SET NULL;

--
-- Constraints for table `ai_recommendations`
--
ALTER TABLE `ai_recommendations`
  ADD CONSTRAINT `ai_recommendations_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `ai_recommendations_ibfk_2` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `ai_recommendations_ibfk_3` FOREIGN KEY (`material_id`) REFERENCES `course_materials` (`material_id`) ON DELETE SET NULL;

--
-- Constraints for table `ai_study_plans`
--
ALTER TABLE `ai_study_plans`
  ADD CONSTRAINT `ai_study_plans_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `ai_study_plans_ibfk_2` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`) ON DELETE CASCADE;

--
-- Constraints for table `ai_summaries`
--
ALTER TABLE `ai_summaries`
  ADD CONSTRAINT `ai_summaries_ibfk_1` FOREIGN KEY (`material_id`) REFERENCES `course_materials` (`material_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `ai_summaries_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `ai_usage_statistics`
--
ALTER TABLE `ai_usage_statistics`
  ADD CONSTRAINT `ai_usage_statistics_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `announcements`
--
ALTER TABLE `announcements`
  ADD CONSTRAINT `announcements_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `announcements_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `announcements_ibfk_3` FOREIGN KEY (`attachment_file_id`) REFERENCES `files` (`file_id`) ON DELETE SET NULL;

--
-- Constraints for table `api_integrations`
--
ALTER TABLE `api_integrations`
  ADD CONSTRAINT `api_integrations_ibfk_1` FOREIGN KEY (`campus_id`) REFERENCES `campuses` (`campus_id`) ON DELETE CASCADE;

--
-- Constraints for table `api_rate_limits`
--
ALTER TABLE `api_rate_limits`
  ADD CONSTRAINT `api_rate_limits_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `assignments`
--
ALTER TABLE `assignments`
  ADD CONSTRAINT `assignments_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `assignments_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `assignment_submissions`
--
ALTER TABLE `assignment_submissions`
  ADD CONSTRAINT `assignment_submissions_ibfk_1` FOREIGN KEY (`assignment_id`) REFERENCES `assignments` (`assignment_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `assignment_submissions_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `assignment_submissions_ibfk_3` FOREIGN KEY (`file_id`) REFERENCES `files` (`file_id`) ON DELETE SET NULL;

--
-- Constraints for table `attendance_photos`
--
ALTER TABLE `attendance_photos`
  ADD CONSTRAINT `attendance_photos_ibfk_1` FOREIGN KEY (`session_id`) REFERENCES `attendance_sessions` (`session_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `attendance_photos_ibfk_2` FOREIGN KEY (`file_id`) REFERENCES `files` (`file_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `attendance_photos_ibfk_3` FOREIGN KEY (`uploaded_by`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `attendance_records`
--
ALTER TABLE `attendance_records`
  ADD CONSTRAINT `attendance_records_ibfk_1` FOREIGN KEY (`session_id`) REFERENCES `attendance_sessions` (`session_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `attendance_records_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `attendance_sessions`
--
ALTER TABLE `attendance_sessions`
  ADD CONSTRAINT `attendance_sessions_ibfk_1` FOREIGN KEY (`section_id`) REFERENCES `course_sections` (`section_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `attendance_sessions_ibfk_2` FOREIGN KEY (`instructor_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `audit_logs`
--
ALTER TABLE `audit_logs`
  ADD CONSTRAINT `audit_logs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL;

--
-- Constraints for table `branding_settings`
--
ALTER TABLE `branding_settings`
  ADD CONSTRAINT `branding_settings_ibfk_1` FOREIGN KEY (`campus_id`) REFERENCES `campuses` (`campus_id`) ON DELETE CASCADE;

--
-- Constraints for table `calendar_events`
--
ALTER TABLE `calendar_events`
  ADD CONSTRAINT `calendar_events_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `calendar_events_ibfk_2` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `calendar_events_ibfk_3` FOREIGN KEY (`schedule_id`) REFERENCES `course_schedules` (`schedule_id`) ON DELETE CASCADE;

--
-- Constraints for table `calendar_integrations`
--
ALTER TABLE `calendar_integrations`
  ADD CONSTRAINT `calendar_integrations_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `certificates`
--
ALTER TABLE `certificates`
  ADD CONSTRAINT `certificates_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `certificates_ibfk_2` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `certificates_ibfk_3` FOREIGN KEY (`file_id`) REFERENCES `files` (`file_id`) ON DELETE SET NULL;

--
-- Constraints for table `chatbot_conversations`
--
ALTER TABLE `chatbot_conversations`
  ADD CONSTRAINT `chatbot_conversations_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `chatbot_conversations_ibfk_2` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`) ON DELETE SET NULL;

--
-- Constraints for table `chatbot_messages`
--
ALTER TABLE `chatbot_messages`
  ADD CONSTRAINT `chatbot_messages_ibfk_1` FOREIGN KEY (`conversation_id`) REFERENCES `chatbot_conversations` (`conversation_id`) ON DELETE CASCADE;

--
-- Constraints for table `chat_messages`
--
ALTER TABLE `chat_messages`
  ADD CONSTRAINT `chat_messages_ibfk_1` FOREIGN KEY (`thread_id`) REFERENCES `course_chat_threads` (`thread_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `chat_messages_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `chat_messages_ibfk_3` FOREIGN KEY (`parent_message_id`) REFERENCES `chat_messages` (`message_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `chat_messages_ibfk_4` FOREIGN KEY (`endorsed_by`) REFERENCES `users` (`user_id`) ON DELETE SET NULL;

--
-- Constraints for table `collaborative_grading`
--
ALTER TABLE `collaborative_grading`
  ADD CONSTRAINT `collaborative_grading_ibfk_1` FOREIGN KEY (`assignment_id`) REFERENCES `assignments` (`assignment_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `collaborative_grading_ibfk_2` FOREIGN KEY (`submission_id`) REFERENCES `assignment_submissions` (`submission_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `collaborative_grading_ibfk_3` FOREIGN KEY (`grader_1_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `collaborative_grading_ibfk_4` FOREIGN KEY (`grader_2_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `communities`
--
ALTER TABLE `communities`
  ADD CONSTRAINT `communities_creator_fk` FOREIGN KEY (`created_by`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `communities_dept_fk` FOREIGN KEY (`department_id`) REFERENCES `departments` (`department_id`) ON DELETE CASCADE;

--
-- Constraints for table `community_posts`
--
ALTER TABLE `community_posts`
  ADD CONSTRAINT `community_posts_community_fk` FOREIGN KEY (`community_id`) REFERENCES `communities` (`community_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `community_posts_course_fk` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `community_posts_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `community_post_comments`
--
ALTER TABLE `community_post_comments`
  ADD CONSTRAINT `community_post_comments_ibfk_1` FOREIGN KEY (`post_id`) REFERENCES `community_posts` (`post_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `community_post_comments_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `community_post_comments_ibfk_3` FOREIGN KEY (`parent_comment_id`) REFERENCES `community_post_comments` (`comment_id`) ON DELETE CASCADE;

--
-- Constraints for table `community_post_reactions`
--
ALTER TABLE `community_post_reactions`
  ADD CONSTRAINT `community_post_reactions_ibfk_1` FOREIGN KEY (`post_id`) REFERENCES `community_posts` (`post_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `community_post_reactions_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `community_post_tags`
--
ALTER TABLE `community_post_tags`
  ADD CONSTRAINT `post_tags_post_fk` FOREIGN KEY (`post_id`) REFERENCES `community_posts` (`post_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `post_tags_tag_fk` FOREIGN KEY (`tag_id`) REFERENCES `community_tags` (`tag_id`) ON DELETE CASCADE;

--
-- Constraints for table `content_translations`
--
ALTER TABLE `content_translations`
  ADD CONSTRAINT `content_translations_ibfk_1` FOREIGN KEY (`translator_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL;

--
-- Constraints for table `courses`
--
ALTER TABLE `courses`
  ADD CONSTRAINT `courses_ibfk_1` FOREIGN KEY (`department_id`) REFERENCES `departments` (`department_id`) ON DELETE CASCADE;

--
-- Constraints for table `course_analytics`
--
ALTER TABLE `course_analytics`
  ADD CONSTRAINT `course_analytics_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `course_analytics_ibfk_2` FOREIGN KEY (`instructor_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `course_chat_threads`
--
ALTER TABLE `course_chat_threads`
  ADD CONSTRAINT `course_chat_threads_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `course_chat_threads_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `course_enrollments`
--
ALTER TABLE `course_enrollments`
  ADD CONSTRAINT `course_enrollments_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `course_enrollments_ibfk_2` FOREIGN KEY (`section_id`) REFERENCES `course_sections` (`section_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `course_enrollments_ibfk_3` FOREIGN KEY (`program_id`) REFERENCES `programs` (`program_id`) ON DELETE SET NULL;

--
-- Constraints for table `course_instructors`
--
ALTER TABLE `course_instructors`
  ADD CONSTRAINT `course_instructors_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `course_instructors_ibfk_2` FOREIGN KEY (`section_id`) REFERENCES `course_sections` (`section_id`) ON DELETE CASCADE;

--
-- Constraints for table `course_materials`
--
ALTER TABLE `course_materials`
  ADD CONSTRAINT `course_materials_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `course_materials_ibfk_2` FOREIGN KEY (`file_id`) REFERENCES `files` (`file_id`) ON DELETE SET NULL,
  ADD CONSTRAINT `course_materials_ibfk_3` FOREIGN KEY (`uploaded_by`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `course_prerequisites`
--
ALTER TABLE `course_prerequisites`
  ADD CONSTRAINT `course_prerequisites_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `course_prerequisites_ibfk_2` FOREIGN KEY (`prerequisite_course_id`) REFERENCES `courses` (`course_id`) ON DELETE CASCADE;

--
-- Constraints for table `course_schedules`
--
ALTER TABLE `course_schedules`
  ADD CONSTRAINT `course_schedules_ibfk_1` FOREIGN KEY (`section_id`) REFERENCES `course_sections` (`section_id`) ON DELETE CASCADE;

--
-- Constraints for table `course_sections`
--
ALTER TABLE `course_sections`
  ADD CONSTRAINT `course_sections_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `course_sections_ibfk_2` FOREIGN KEY (`semester_id`) REFERENCES `semesters` (`semester_id`) ON DELETE CASCADE;

--
-- Constraints for table `course_tas`
--
ALTER TABLE `course_tas`
  ADD CONSTRAINT `course_tas_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `course_tas_ibfk_2` FOREIGN KEY (`section_id`) REFERENCES `course_sections` (`section_id`) ON DELETE CASCADE;

--
-- Constraints for table `daily_streaks`
--
ALTER TABLE `daily_streaks`
  ADD CONSTRAINT `daily_streaks_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `deadline_reminders`
--
ALTER TABLE `deadline_reminders`
  ADD CONSTRAINT `deadline_reminders_ibfk_1` FOREIGN KEY (`task_id`) REFERENCES `student_tasks` (`task_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `deadline_reminders_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `departments`
--
ALTER TABLE `departments`
  ADD CONSTRAINT `departments_ibfk_1` FOREIGN KEY (`campus_id`) REFERENCES `campuses` (`campus_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `departments_ibfk_2` FOREIGN KEY (`head_of_department_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL;

--
-- Constraints for table `device_tokens`
--
ALTER TABLE `device_tokens`
  ADD CONSTRAINT `device_tokens_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `email_verifications`
--
ALTER TABLE `email_verifications`
  ADD CONSTRAINT `fk_email_verifications_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `exam_schedules`
--
ALTER TABLE `exam_schedules`
  ADD CONSTRAINT `exam_schedules_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `exam_schedules_ibfk_2` FOREIGN KEY (`semester_id`) REFERENCES `semesters` (`semester_id`) ON DELETE CASCADE;

--
-- Constraints for table `export_history`
--
ALTER TABLE `export_history`
  ADD CONSTRAINT `export_history_ibfk_1` FOREIGN KEY (`report_id`) REFERENCES `generated_reports` (`report_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `export_history_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `export_history_ibfk_3` FOREIGN KEY (`file_id`) REFERENCES `files` (`file_id`) ON DELETE SET NULL;

--
-- Constraints for table `face_recognition_data`
--
ALTER TABLE `face_recognition_data`
  ADD CONSTRAINT `face_recognition_data_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `feedback_responses`
--
ALTER TABLE `feedback_responses`
  ADD CONSTRAINT `feedback_responses_ibfk_1` FOREIGN KEY (`feedback_id`) REFERENCES `user_feedback` (`feedback_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `feedback_responses_ibfk_2` FOREIGN KEY (`ticket_id`) REFERENCES `support_tickets` (`ticket_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `feedback_responses_ibfk_3` FOREIGN KEY (`responder_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `files`
--
ALTER TABLE `files`
  ADD CONSTRAINT `files_ibfk_1` FOREIGN KEY (`uploaded_by`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `files_ibfk_2` FOREIGN KEY (`folder_id`) REFERENCES `folders` (`folder_id`) ON DELETE SET NULL;

--
-- Constraints for table `file_permissions`
--
ALTER TABLE `file_permissions`
  ADD CONSTRAINT `file_permissions_ibfk_1` FOREIGN KEY (`file_id`) REFERENCES `files` (`file_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `file_permissions_ibfk_2` FOREIGN KEY (`folder_id`) REFERENCES `folders` (`folder_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `file_permissions_ibfk_3` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `file_permissions_ibfk_4` FOREIGN KEY (`role_id`) REFERENCES `roles` (`role_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `file_permissions_ibfk_5` FOREIGN KEY (`granted_by`) REFERENCES `users` (`user_id`) ON DELETE SET NULL;

--
-- Constraints for table `file_versions`
--
ALTER TABLE `file_versions`
  ADD CONSTRAINT `file_versions_ibfk_1` FOREIGN KEY (`file_id`) REFERENCES `files` (`file_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `file_versions_ibfk_2` FOREIGN KEY (`uploaded_by`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `folders`
--
ALTER TABLE `folders`
  ADD CONSTRAINT `folders_ibfk_1` FOREIGN KEY (`parent_folder_id`) REFERENCES `folders` (`folder_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `folders_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `forum_categories`
--
ALTER TABLE `forum_categories`
  ADD CONSTRAINT `forum_categories_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`) ON DELETE CASCADE;

--
-- Constraints for table `generated_reports`
--
ALTER TABLE `generated_reports`
  ADD CONSTRAINT `generated_reports_ibfk_1` FOREIGN KEY (`template_id`) REFERENCES `report_templates` (`template_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `generated_reports_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `generated_reports_ibfk_3` FOREIGN KEY (`file_id`) REFERENCES `files` (`file_id`) ON DELETE SET NULL;

--
-- Constraints for table `gpa_calculations`
--
ALTER TABLE `gpa_calculations`
  ADD CONSTRAINT `gpa_calculations_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `gpa_calculations_ibfk_2` FOREIGN KEY (`semester_id`) REFERENCES `semesters` (`semester_id`) ON DELETE CASCADE;

--
-- Constraints for table `grades`
--
ALTER TABLE `grades`
  ADD CONSTRAINT `grades_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `grades_ibfk_2` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `grades_ibfk_3` FOREIGN KEY (`assignment_id`) REFERENCES `assignments` (`assignment_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `grades_ibfk_4` FOREIGN KEY (`quiz_id`) REFERENCES `quizzes` (`quiz_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `grades_ibfk_5` FOREIGN KEY (`lab_id`) REFERENCES `labs` (`lab_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `grades_ibfk_6` FOREIGN KEY (`graded_by`) REFERENCES `users` (`user_id`) ON DELETE SET NULL;

--
-- Constraints for table `grade_components`
--
ALTER TABLE `grade_components`
  ADD CONSTRAINT `grade_components_ibfk_1` FOREIGN KEY (`grade_id`) REFERENCES `grades` (`grade_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `grade_components_ibfk_2` FOREIGN KEY (`rubric_id`) REFERENCES `rubrics` (`rubric_id`) ON DELETE SET NULL;

--
-- Constraints for table `image_text_extractions`
--
ALTER TABLE `image_text_extractions`
  ADD CONSTRAINT `image_text_extractions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `image_text_extractions_ibfk_2` FOREIGN KEY (`image_file_id`) REFERENCES `files` (`file_id`) ON DELETE CASCADE;

--
-- Constraints for table `labs`
--
ALTER TABLE `labs`
  ADD CONSTRAINT `labs_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `labs_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `lab_attendance`
--
ALTER TABLE `lab_attendance`
  ADD CONSTRAINT `lab_attendance_ibfk_1` FOREIGN KEY (`lab_id`) REFERENCES `labs` (`lab_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `lab_attendance_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `lab_attendance_ibfk_3` FOREIGN KEY (`marked_by`) REFERENCES `users` (`user_id`) ON DELETE SET NULL;

--
-- Constraints for table `lab_instructions`
--
ALTER TABLE `lab_instructions`
  ADD CONSTRAINT `lab_instructions_ibfk_1` FOREIGN KEY (`lab_id`) REFERENCES `labs` (`lab_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `lab_instructions_ibfk_2` FOREIGN KEY (`file_id`) REFERENCES `files` (`file_id`) ON DELETE SET NULL;

--
-- Constraints for table `lab_submissions`
--
ALTER TABLE `lab_submissions`
  ADD CONSTRAINT `lab_submissions_ibfk_1` FOREIGN KEY (`lab_id`) REFERENCES `labs` (`lab_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `lab_submissions_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `lab_submissions_ibfk_3` FOREIGN KEY (`file_id`) REFERENCES `files` (`file_id`) ON DELETE SET NULL;

--
-- Constraints for table `language_preferences`
--
ALTER TABLE `language_preferences`
  ADD CONSTRAINT `language_preferences_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `leaderboards`
--
ALTER TABLE `leaderboards`
  ADD CONSTRAINT `leaderboards_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `leaderboards_ibfk_2` FOREIGN KEY (`semester_id`) REFERENCES `semesters` (`semester_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `leaderboards_ibfk_3` FOREIGN KEY (`department_id`) REFERENCES `departments` (`department_id`) ON DELETE CASCADE;

--
-- Constraints for table `leaderboard_rankings`
--
ALTER TABLE `leaderboard_rankings`
  ADD CONSTRAINT `leaderboard_rankings_ibfk_1` FOREIGN KEY (`leaderboard_id`) REFERENCES `leaderboards` (`leaderboard_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `leaderboard_rankings_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `learning_analytics`
--
ALTER TABLE `learning_analytics`
  ADD CONSTRAINT `learning_analytics_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `learning_analytics_ibfk_2` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `learning_analytics_ibfk_3` FOREIGN KEY (`progress_id`) REFERENCES `student_progress` (`progress_id`) ON DELETE CASCADE;

--
-- Constraints for table `lecture_sections_labs`
--
ALTER TABLE `lecture_sections_labs`
  ADD CONSTRAINT `lecture_sections_labs_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `lecture_sections_labs_ibfk_2` FOREIGN KEY (`material_id`) REFERENCES `course_materials` (`material_id`) ON DELETE SET NULL;

--
-- Constraints for table `live_sessions`
--
ALTER TABLE `live_sessions`
  ADD CONSTRAINT `live_sessions_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `live_sessions_ibfk_2` FOREIGN KEY (`instructor_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `live_sessions_ibfk_3` FOREIGN KEY (`recording_file_id`) REFERENCES `files` (`file_id`) ON DELETE SET NULL;

--
-- Constraints for table `live_session_participants`
--
ALTER TABLE `live_session_participants`
  ADD CONSTRAINT `live_session_participants_ibfk_1` FOREIGN KEY (`session_id`) REFERENCES `live_sessions` (`session_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `live_session_participants_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `login_attempts`
--
ALTER TABLE `login_attempts`
  ADD CONSTRAINT `login_attempts_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `messages`
--
ALTER TABLE `messages`
  ADD CONSTRAINT `fk_messages_reply_to` FOREIGN KEY (`reply_to_id`) REFERENCES `messages` (`message_id`) ON DELETE SET NULL,
  ADD CONSTRAINT `messages_ibfk_1` FOREIGN KEY (`sender_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `messages_ibfk_2` FOREIGN KEY (`parent_message_id`) REFERENCES `messages` (`message_id`) ON DELETE CASCADE;

--
-- Constraints for table `message_participants`
--
ALTER TABLE `message_participants`
  ADD CONSTRAINT `message_participants_ibfk_1` FOREIGN KEY (`message_id`) REFERENCES `messages` (`message_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `message_participants_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `milestone_definitions`
--
ALTER TABLE `milestone_definitions`
  ADD CONSTRAINT `milestone_definitions_ibfk_1` FOREIGN KEY (`badge_id`) REFERENCES `badges` (`badge_id`) ON DELETE CASCADE;

--
-- Constraints for table `notifications`
--
ALTER TABLE `notifications`
  ADD CONSTRAINT `notifications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `notifications_ibfk_2` FOREIGN KEY (`announcement_id`) REFERENCES `announcements` (`announcement_id`) ON DELETE CASCADE;

--
-- Constraints for table `notification_preferences`
--
ALTER TABLE `notification_preferences`
  ADD CONSTRAINT `notification_preferences_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `office_hour_appointments`
--
ALTER TABLE `office_hour_appointments`
  ADD CONSTRAINT `fk_appointment_slot` FOREIGN KEY (`slot_id`) REFERENCES `office_hour_slots` (`slot_id`),
  ADD CONSTRAINT `fk_appointment_student` FOREIGN KEY (`student_id`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `office_hour_slots`
--
ALTER TABLE `office_hour_slots`
  ADD CONSTRAINT `fk_office_hours_instructor` FOREIGN KEY (`instructor_id`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `offline_sync_queue`
--
ALTER TABLE `offline_sync_queue`
  ADD CONSTRAINT `offline_sync_queue_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `password_resets`
--
ALTER TABLE `password_resets`
  ADD CONSTRAINT `password_resets_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `payment_transactions`
--
ALTER TABLE `payment_transactions`
  ADD CONSTRAINT `payment_transactions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `payment_transactions_ibfk_2` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`) ON DELETE SET NULL;

--
-- Constraints for table `peer_reviews`
--
ALTER TABLE `peer_reviews`
  ADD CONSTRAINT `peer_reviews_ibfk_1` FOREIGN KEY (`submission_id`) REFERENCES `assignment_submissions` (`submission_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `peer_reviews_ibfk_2` FOREIGN KEY (`reviewer_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `peer_reviews_ibfk_3` FOREIGN KEY (`reviewee_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `performance_metrics`
--
ALTER TABLE `performance_metrics`
  ADD CONSTRAINT `performance_metrics_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `performance_metrics_ibfk_2` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`) ON DELETE CASCADE;

--
-- Constraints for table `programs`
--
ALTER TABLE `programs`
  ADD CONSTRAINT `programs_ibfk_1` FOREIGN KEY (`department_id`) REFERENCES `departments` (`department_id`) ON DELETE CASCADE;

--
-- Constraints for table `quizzes`
--
ALTER TABLE `quizzes`
  ADD CONSTRAINT `quizzes_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `quizzes_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `quiz_answers`
--
ALTER TABLE `quiz_answers`
  ADD CONSTRAINT `quiz_answers_ibfk_1` FOREIGN KEY (`attempt_id`) REFERENCES `quiz_attempts` (`attempt_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `quiz_answers_ibfk_2` FOREIGN KEY (`question_id`) REFERENCES `quiz_questions` (`question_id`) ON DELETE CASCADE;

--
-- Constraints for table `quiz_attempts`
--
ALTER TABLE `quiz_attempts`
  ADD CONSTRAINT `quiz_attempts_ibfk_1` FOREIGN KEY (`quiz_id`) REFERENCES `quizzes` (`quiz_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `quiz_attempts_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `quiz_questions`
--
ALTER TABLE `quiz_questions`
  ADD CONSTRAINT `quiz_questions_ibfk_1` FOREIGN KEY (`quiz_id`) REFERENCES `quizzes` (`quiz_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `quiz_questions_ibfk_2` FOREIGN KEY (`difficulty_level_id`) REFERENCES `quiz_difficulty_levels` (`difficulty_id`) ON DELETE SET NULL;

--
-- Constraints for table `report_templates`
--
ALTER TABLE `report_templates`
  ADD CONSTRAINT `report_templates_ibfk_1` FOREIGN KEY (`created_by`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `rewards`
--
ALTER TABLE `rewards`
  ADD CONSTRAINT `rewards_ibfk_1` FOREIGN KEY (`achievement_id`) REFERENCES `achievements` (`achievement_id`) ON DELETE SET NULL;

--
-- Constraints for table `reward_redemptions`
--
ALTER TABLE `reward_redemptions`
  ADD CONSTRAINT `reward_redemptions_ibfk_1` FOREIGN KEY (`reward_id`) REFERENCES `rewards` (`reward_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `reward_redemptions_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `reward_redemptions_ibfk_3` FOREIGN KEY (`approved_by`) REFERENCES `users` (`user_id`) ON DELETE SET NULL;

--
-- Constraints for table `role_permissions`
--
ALTER TABLE `role_permissions`
  ADD CONSTRAINT `role_permissions_ibfk_1` FOREIGN KEY (`role_id`) REFERENCES `roles` (`role_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `role_permissions_ibfk_2` FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`permission_id`) ON DELETE CASCADE;

--
-- Constraints for table `rubrics`
--
ALTER TABLE `rubrics`
  ADD CONSTRAINT `rubrics_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `rubrics_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `scheduled_notifications`
--
ALTER TABLE `scheduled_notifications`
  ADD CONSTRAINT `scheduled_notifications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `scheduled_notifications_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `search_history`
--
ALTER TABLE `search_history`
  ADD CONSTRAINT `search_history_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `security_logs`
--
ALTER TABLE `security_logs`
  ADD CONSTRAINT `security_logs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL;

--
-- Constraints for table `sessions`
--
ALTER TABLE `sessions`
  ADD CONSTRAINT `sessions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `ssl_certificates`
--
ALTER TABLE `ssl_certificates`
  ADD CONSTRAINT `ssl_certificates_ibfk_1` FOREIGN KEY (`campus_id`) REFERENCES `campuses` (`campus_id`) ON DELETE CASCADE;

--
-- Constraints for table `student_progress`
--
ALTER TABLE `student_progress`
  ADD CONSTRAINT `student_progress_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `student_progress_ibfk_2` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `student_progress_ibfk_3` FOREIGN KEY (`enrollment_id`) REFERENCES `course_enrollments` (`enrollment_id`) ON DELETE CASCADE;

--
-- Constraints for table `student_tasks`
--
ALTER TABLE `student_tasks`
  ADD CONSTRAINT `student_tasks_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `student_tasks_ibfk_2` FOREIGN KEY (`assignment_id`) REFERENCES `assignments` (`assignment_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `student_tasks_ibfk_3` FOREIGN KEY (`quiz_id`) REFERENCES `quizzes` (`quiz_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `student_tasks_ibfk_4` FOREIGN KEY (`lab_id`) REFERENCES `labs` (`lab_id`) ON DELETE CASCADE;

--
-- Constraints for table `study_groups`
--
ALTER TABLE `study_groups`
  ADD CONSTRAINT `study_groups_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `study_groups_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `study_group_members`
--
ALTER TABLE `study_group_members`
  ADD CONSTRAINT `study_group_members_ibfk_1` FOREIGN KEY (`group_id`) REFERENCES `study_groups` (`group_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `study_group_members_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `support_tickets`
--
ALTER TABLE `support_tickets`
  ADD CONSTRAINT `support_tickets_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `support_tickets_ibfk_2` FOREIGN KEY (`feedback_id`) REFERENCES `user_feedback` (`feedback_id`) ON DELETE SET NULL,
  ADD CONSTRAINT `support_tickets_ibfk_3` FOREIGN KEY (`assigned_to`) REFERENCES `users` (`user_id`) ON DELETE SET NULL;

--
-- Constraints for table `system_errors`
--
ALTER TABLE `system_errors`
  ADD CONSTRAINT `system_errors_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL,
  ADD CONSTRAINT `system_errors_ibfk_2` FOREIGN KEY (`resolved_by`) REFERENCES `users` (`user_id`) ON DELETE SET NULL;

--
-- Constraints for table `task_completion`
--
ALTER TABLE `task_completion`
  ADD CONSTRAINT `task_completion_ibfk_1` FOREIGN KEY (`task_id`) REFERENCES `student_tasks` (`task_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `task_completion_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `ta_instructor_access`
--
ALTER TABLE `ta_instructor_access`
  ADD CONSTRAINT `ta_instructor_access_ibfk_1` FOREIGN KEY (`instructor_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `ta_instructor_access_ibfk_2` FOREIGN KEY (`ta_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `ta_instructor_access_ibfk_3` FOREIGN KEY (`section_id`) REFERENCES `course_sections` (`section_id`) ON DELETE CASCADE;

--
-- Constraints for table `theme_preferences`
--
ALTER TABLE `theme_preferences`
  ADD CONSTRAINT `theme_preferences_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `two_factor_auth`
--
ALTER TABLE `two_factor_auth`
  ADD CONSTRAINT `two_factor_auth_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `user_badges`
--
ALTER TABLE `user_badges`
  ADD CONSTRAINT `user_badges_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `user_badges_ibfk_2` FOREIGN KEY (`badge_id`) REFERENCES `badges` (`badge_id`) ON DELETE CASCADE;

--
-- Constraints for table `user_feedback`
--
ALTER TABLE `user_feedback`
  ADD CONSTRAINT `user_feedback_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `user_levels`
--
ALTER TABLE `user_levels`
  ADD CONSTRAINT `user_levels_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `user_preferences`
--
ALTER TABLE `user_preferences`
  ADD CONSTRAINT `fk_user_preferences_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE;

--
-- Constraints for table `user_roles`
--
ALTER TABLE `user_roles`
  ADD CONSTRAINT `user_roles_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `user_roles_ibfk_2` FOREIGN KEY (`role_id`) REFERENCES `roles` (`role_id`) ON DELETE CASCADE;

--
-- Constraints for table `user_subscriptions`
--
ALTER TABLE `user_subscriptions`
  ADD CONSTRAINT `fk_subscription_plan` FOREIGN KEY (`plan_id`) REFERENCES `subscription_plans` (`plan_id`),
  ADD CONSTRAINT `fk_subscription_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `voice_recordings`
--
ALTER TABLE `voice_recordings`
  ADD CONSTRAINT `voice_recordings_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `voice_recordings_ibfk_2` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `voice_recordings_ibfk_3` FOREIGN KEY (`file_id`) REFERENCES `files` (`file_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `voice_recordings_ibfk_4` FOREIGN KEY (`transcription_id`) REFERENCES `voice_transcriptions` (`transcription_id`) ON DELETE SET NULL;

--
-- Constraints for table `voice_transcriptions`
--
ALTER TABLE `voice_transcriptions`
  ADD CONSTRAINT `voice_transcriptions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `voice_transcriptions_ibfk_2` FOREIGN KEY (`audio_file_id`) REFERENCES `files` (`file_id`) ON DELETE SET NULL;

--
-- Constraints for table `weak_topics_analysis`
--
ALTER TABLE `weak_topics_analysis`
  ADD CONSTRAINT `weak_topics_analysis_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `weak_topics_analysis_ibfk_2` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`) ON DELETE CASCADE;

--
-- Constraints for table `xp_transactions`
--
ALTER TABLE `xp_transactions`
  ADD CONSTRAINT `xp_transactions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `xp_transactions_ibfk_2` FOREIGN KEY (`rule_id`) REFERENCES `points_rules` (`rule_id`) ON DELETE SET NULL;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
