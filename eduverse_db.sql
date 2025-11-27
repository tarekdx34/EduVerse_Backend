-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Nov 27, 2025 at 05:43 PM
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
  `criteria` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`criteria`)),
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
  `unmatched_faces_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`unmatched_faces_data`)),
  `confidence_scores` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`confidence_scores`)),
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

--
-- Dumping data for table `ai_feedback`
--

INSERT INTO `ai_feedback` (`feedback_id`, `user_id`, `course_id`, `feedback_type`, `feedback_text`, `priority`, `is_read`, `read_at`, `created_at`) VALUES
(1, 7, 1, 'performance', 'Excellent progress! You are performing above average in all assessments. Keep up the great work!', 'medium', 1, NULL, '2025-11-20 13:43:00'),
(2, 8, 1, 'improvement', 'Good work overall. Consider reviewing loop concepts for better understanding.', 'medium', 0, NULL, '2025-11-20 13:43:00'),
(3, 9, 1, 'recommendation', 'You may benefit from additional practice with conditional statements. Check out the extra materials in the resource section.', 'medium', 0, NULL, '2025-11-20 13:43:00'),
(4, 10, 1, 'performance', 'Your attendance is excellent! Try to submit assignments earlier to avoid last-minute rush.', 'low', 0, NULL, '2025-11-20 13:43:00');

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

--
-- Dumping data for table `ai_flashcards`
--

INSERT INTO `ai_flashcards` (`flashcard_id`, `material_id`, `user_id`, `front_text`, `back_text`, `category`, `difficulty`, `order_index`, `times_reviewed`, `last_reviewed_at`, `created_at`) VALUES
(1, 2, 7, 'What is a variable?', 'A variable is a named storage location that holds a value which can be changed during program execution.', 'Basics', 'easy', 1, 3, '2025-02-14 13:00:00', '2025-11-20 13:43:00'),
(2, 2, 7, 'What are the primitive data types in Python?', 'int, float, str, bool', 'Data Types', 'easy', 2, 2, '2025-02-13 08:30:00', '2025-11-20 13:43:00'),
(3, 3, 7, 'How do you declare a string variable in Python?', 'Use quotes: x = \"hello\" or x = \'hello\'', 'Variables', 'easy', 1, 1, '2025-02-12 12:20:00', '2025-11-20 13:43:00'),
(4, 2, 8, 'What is Python?', 'Python is a high-level, interpreted programming language known for its simplicity and readability.', 'Basics', 'easy', 1, 2, '2025-02-11 09:00:00', '2025-11-20 13:43:00');

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
  `grading_criteria` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`grading_criteria`)),
  `requires_human_review` tinyint(1) DEFAULT 0,
  `human_override_score` decimal(5,2) DEFAULT NULL,
  `processing_time_ms` int(11) DEFAULT NULL,
  `ai_model` varchar(50) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `reviewed_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `ai_grading_results`
--

INSERT INTO `ai_grading_results` (`grading_id`, `submission_id`, `quiz_attempt_id`, `ai_score`, `max_score`, `ai_feedback`, `confidence_score`, `grading_criteria`, `requires_human_review`, `human_override_score`, `processing_time_ms`, `ai_model`, `created_at`, `reviewed_at`) VALUES
(1, 5, NULL, 87.50, 100.00, 'Code logic is correct and follows good practices. Minor improvements: Add error handling and more descriptive variable names.', 0.92, NULL, 0, NULL, 1850, 'gpt-4', '2025-11-20 13:43:00', NULL),
(2, NULL, 3, 75.00, 100.00, 'Good understanding of basic concepts. Review conditional statements for improvement.', 0.88, NULL, 0, NULL, 980, 'gpt-4', '2025-11-20 13:43:00', NULL),
(3, 3, NULL, 78.00, 100.00, 'Functional code with room for optimization. Consider edge cases.', 0.85, NULL, 1, NULL, 2100, 'gpt-4', '2025-11-20 13:43:00', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `ai_quizzes`
--

CREATE TABLE `ai_quizzes` (
  `ai_quiz_id` bigint(20) UNSIGNED NOT NULL,
  `material_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `difficulty_id` int(10) UNSIGNED DEFAULT NULL,
  `quiz_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`quiz_data`)),
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
(1, 10, 1, 2, 'review', 'Review: Variables and Data Types', 'Based on your quiz performance, reviewing this topic would be beneficial', 'Low score on related quiz questions', 'high', 1, 0, '2025-11-20 13:43:00', NULL, NULL),
(2, 11, 1, 3, 'practice', 'Practice: String Operations', 'Additional practice recommended for better understanding', 'Identified as potential weak area', 'medium', 0, 0, '2025-11-20 13:43:00', NULL, NULL),
(3, 7, 1, NULL, 'material', 'Advanced Python Resources', 'Ready for more advanced material based on your excellent progress', 'High performance across all assessments', 'low', 1, 1, '2025-11-20 13:43:00', NULL, NULL),
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
  `plan_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`plan_data`)),
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
(1, 7, 1, 'Midterm Preparation Plan', '{\"weeks\": [{\"week\": 1, \"topics\": [\"Variables\", \"Loops\"], \"hours\": 5}, {\"week\": 2, \"topics\": [\"Functions\", \"Lists\"], \"hours\": 6}]}', '2025-02-20', '2025-03-15', 22, 'active', 35.50, '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(2, 10, 1, 'Catch-up Study Plan', '{\"weeks\": [{\"week\": 1, \"topics\": [\"Review all lectures\"], \"hours\": 8}, {\"week\": 2, \"topics\": [\"Complete missing assignments\"], \"hours\": 10}]}', '2025-02-15', '2025-03-01', 18, 'active', 55.00, '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
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

--
-- Dumping data for table `ai_summaries`
--

INSERT INTO `ai_summaries` (`summary_id`, `material_id`, `user_id`, `summary_text`, `summary_type`, `language`, `word_count`, `processing_time_ms`, `ai_model`, `created_at`) VALUES
(1, 2, 7, 'This lecture introduces fundamental programming concepts including variables, data types, control structures, and basic syntax. Key topics covered: variable declaration, arithmetic operations, and program structure.', 'medium', 'en', 35, 1250, 'gpt-4', '2025-11-20 13:43:00'),
(2, 3, 7, 'Overview of Python variables and data types. Covers integers, floats, strings, and booleans. Explains type conversion and variable naming conventions.', 'short', 'en', 22, 890, 'gpt-4', '2025-11-20 13:43:00'),
(3, 2, 8, 'Comprehensive introduction to programming fundamentals with focus on Python syntax and basic operations.', 'short', 'en', 15, 650, 'gpt-4', '2025-11-20 13:43:00');

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
(1, 1, 2, 'Course Start', 'Welcome to CS101! Please review the syllabus and complete the introductory quiz.', 'course', 'high', 'students', 1, '2025-01-15 07:00:00', NULL, NULL, 0, '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(2, 1, 2, 'Assignment 1 Posted', 'Assignment 1 is now available. Due date: February 15, 2025.', 'course', 'medium', 'students', 1, '2025-02-01 08:00:00', NULL, NULL, 0, '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(3, NULL, 1, 'Campus WiFi Maintenance', 'Network maintenance scheduled for this weekend. Expect brief outages.', 'campus', 'medium', 'all', 1, '2025-02-10 06:00:00', NULL, NULL, 0, '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(4, 2, 3, 'Midterm Exam Schedule', 'The midterm exam will be held on March 15, 2025 from 2:00 PM to 4:00 PM.', 'course', 'high', 'students', 1, '2025-02-12 10:00:00', NULL, NULL, 0, '2025-11-20 13:43:00', '2025-11-20 13:43:00');

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
  `configuration` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`configuration`)),
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
  `allowed_file_types` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`allowed_file_types`)),
  `created_by` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `assignments`
--

INSERT INTO `assignments` (`assignment_id`, `course_id`, `title`, `description`, `instructions`, `max_score`, `weight`, `due_date`, `available_from`, `late_submission_allowed`, `late_penalty_percent`, `submission_type`, `max_file_size_mb`, `allowed_file_types`, `created_by`, `created_at`, `updated_at`, `deleted_at`) VALUES
(1, 1, 'Assignment 1: Hello World', 'Create your first Python program', 'Write a program that prints Hello World', 100.00, 10.00, '2025-02-15 21:59:59', '2025-01-31 22:00:00', 1, 10.00, 'file', 10, NULL, 2, '2025-11-20 13:42:59', '2025-11-20 13:42:59', NULL),
(2, 1, 'Assignment 2: Variables Practice', 'Practice with variables and data types', 'Complete the exercises in the assignment document', 100.00, 15.00, '2025-02-28 21:59:59', '2025-02-14 22:00:00', 1, 10.00, 'file', 10, NULL, 2, '2025-11-20 13:42:59', '2025-11-20 13:42:59', NULL),
(3, 2, 'Assignment 1: Linked Lists', 'Implement a linked list', 'Create a linked list class with basic operations', 100.00, 20.00, '2025-03-10 21:59:59', '2025-02-19 22:00:00', 1, 15.00, 'file', 10, NULL, 3, '2025-11-20 13:42:59', '2025-11-20 13:42:59', NULL),
(4, 3, 'Assignment 1: SQL Queries', 'Database query practice', 'Write SQL queries for the given scenarios', 100.00, 15.00, '2025-03-05 21:59:59', '2025-02-14 22:00:00', 0, 0.00, 'text', 10, NULL, 3, '2025-11-20 13:42:59', '2025-11-20 13:42:59', NULL);

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
(1, 1, 7, NULL, 'print(\"Hello World\")', NULL, '2025-11-20 13:42:59', 0, 1, 'graded'),
(2, 1, 8, NULL, 'print(\"Hello World\")', NULL, '2025-11-20 13:42:59', 0, 1, 'graded'),
(3, 1, 9, NULL, 'print(\"Hello, World!\")', NULL, '2025-11-20 13:42:59', 0, 1, 'submitted'),
(4, 1, 10, NULL, 'print(\"Hello World\")', NULL, '2025-11-20 13:42:59', 1, 1, 'graded'),
(5, 2, 7, NULL, 'x = 5\ny = 10\nprint(x + y)', NULL, '2025-11-20 13:42:59', 0, 1, 'submitted');

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
  `old_values` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`old_values`)),
  `new_values` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`new_values`)),
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
  `criteria` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`criteria`)),
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

--
-- Dumping data for table `calendar_events`
--

INSERT INTO `calendar_events` (`event_id`, `user_id`, `course_id`, `event_type`, `title`, `description`, `location`, `start_time`, `end_time`, `schedule_id`, `exam_id`, `is_recurring`, `recurrence_pattern`, `reminder_minutes`, `status`, `created_at`, `updated_at`) VALUES
(1, 7, 1, 'lecture', 'CS101 Lecture', 'Introduction to Programming', 'Room 101', '2025-02-17 07:00:00', '2025-02-17 08:30:00', NULL, NULL, 0, NULL, 30, 'scheduled', '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(2, 7, 1, 'assignment', 'Assignment 2 Due', 'Variables Practice Assignment', 'Online', '2025-02-28 21:59:59', '2025-02-28 21:59:59', NULL, NULL, 0, NULL, 2880, 'scheduled', '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(3, 7, 1, 'quiz', 'Quiz 2', 'Control Structures Quiz', 'Online', '2025-03-09 22:00:00', '2025-03-10 21:59:59', NULL, NULL, 0, NULL, 1440, 'scheduled', '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(4, 8, 1, 'lecture', 'CS101 Lecture', 'Introduction to Programming', 'Room 102', '2025-02-18 12:00:00', '2025-02-18 13:30:00', NULL, NULL, 0, NULL, 30, 'scheduled', '2025-11-20 13:43:00', '2025-11-20 13:43:00');

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
(1, 'Main Campus', 'MC001', '123 University Ave', 'New York', 'USA', '+1-555-0100', 'info@maincampus.edu', 'America/New_York', 'active', '2025-11-20 13:42:59', '2025-11-20 13:42:59'),
(2, 'Downtown Campus', 'DC002', '456 Downtown St', 'Los Angeles', 'USA', '+1-555-0200', 'info@downtown.edu', 'America/Los_Angeles', 'active', '2025-11-20 13:42:59', '2025-11-20 13:42:59'),
(3, 'Online Campus', 'OC003', '789 Virtual Plaza', 'Chicago', 'USA', '+1-555-0300', 'info@online.edu', 'America/Chicago', 'active', '2025-11-20 13:42:59', '2025-11-20 13:42:59'),
(4, 'Main Campus Updated', 'MAIN2', '456 University Ave', 'Boston', 'USA', '+1-555-0456', 'main2@university.edu', 'America/Boston', 'inactive', '2025-11-26 18:16:28', '2025-11-26 18:22:21');

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

--
-- Dumping data for table `certificates`
--

INSERT INTO `certificates` (`certificate_id`, `user_id`, `course_id`, `certificate_number`, `certificate_type`, `issue_date`, `expiry_date`, `file_id`, `verification_hash`, `is_verified`, `created_at`) VALUES
(1, 7, 1, 'CERT-CS101-2025-001', 'excellence', '2025-05-20', NULL, NULL, 'a1b2c3d4e5f6g7h8i9j0', 1, '2025-11-20 13:43:00'),
(2, 8, 1, 'CERT-CS101-2025-002', 'completion', '2025-05-20', NULL, NULL, 'b2c3d4e5f6g7h8i9j0k1', 1, '2025-11-20 13:43:00');

-- --------------------------------------------------------

--
-- Table structure for table `chatbot_conversations`
--

CREATE TABLE `chatbot_conversations` (
  `conversation_id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `course_id` bigint(20) UNSIGNED DEFAULT NULL,
  `conversation_title` varchar(255) DEFAULT NULL,
  `context_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`context_data`)),
  `status` enum('active','archived','deleted') DEFAULT 'active',
  `started_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `last_message_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `chatbot_conversations`
--

INSERT INTO `chatbot_conversations` (`conversation_id`, `user_id`, `course_id`, `conversation_title`, `context_data`, `status`, `started_at`, `last_message_at`) VALUES
(1, 7, 1, 'Help with Assignment 1', NULL, 'active', '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(2, 8, 1, 'Python Syntax Questions', NULL, 'active', '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
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
  `message_metadata` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`message_metadata`)),
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
(1, 1, 7, 'Can someone explain what the output should look like for Assignment 1?', NULL, 0, 0, NULL, 5, '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(2, 1, 5, 'The output should simply be: Hello World (without quotes)', 1, 1, 1, 2, 8, '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(3, 1, 8, 'Thanks! That helps clarify things.', 1, 0, 0, NULL, 2, '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(4, 2, 9, 'What is the difference between a list and an array in Python?', NULL, 0, 0, NULL, 3, '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(5, 2, 2, 'In Python, lists are built-in and more flexible, while arrays require the array module and are more memory efficient for numerical data.', 4, 1, 1, 2, 12, '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(6, 3, 13, 'Here is a great YouTube playlist for data structures: [link]', NULL, 0, 0, NULL, 7, '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(7, 4, 10, 'Getting error: Python not recognized. Help!', NULL, 0, 0, NULL, 4, '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(8, 4, 5, 'Did you check the \"Add Python to PATH\" option during installation?', 7, 1, 0, NULL, 6, '2025-11-20 13:43:00', '2025-11-20 13:43:00');

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

--
-- Dumping data for table `collaborative_grading`
--

INSERT INTO `collaborative_grading` (`collab_id`, `assignment_id`, `submission_id`, `grader_1_id`, `grader_2_id`, `grader_1_score`, `grader_2_score`, `final_score`, `resolution_method`, `status`, `created_at`, `completed_at`) VALUES
(1, 1, 1, 2, 5, 95.00, 93.00, 95.00, 'grader_1', 'completed', '2025-11-20 13:43:00', '2025-02-16 08:00:00'),
(2, 1, 2, 2, 5, 88.00, 90.00, 89.00, 'average', 'completed', '2025-11-20 13:43:00', '2025-02-16 08:15:00'),
(3, 2, 5, 2, 5, 85.00, 87.00, 86.00, 'average', 'in_progress', '2025-11-20 13:43:00', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `community_posts`
--

CREATE TABLE `community_posts` (
  `post_id` bigint(20) UNSIGNED NOT NULL,
  `course_id` bigint(20) UNSIGNED NOT NULL,
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

INSERT INTO `community_posts` (`post_id`, `course_id`, `user_id`, `title`, `content`, `post_type`, `is_pinned`, `is_locked`, `view_count`, `upvote_count`, `reply_count`, `created_at`, `updated_at`) VALUES
(1, 1, 7, 'Help with loops', 'Can someone explain how for loops work in Python? I am confused about the range function.', 'question', 0, 0, 45, 5, 3, '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(2, 1, 8, 'Great course!', 'Really enjoying this course so far. Professor Smith explains concepts very clearly!', 'discussion', 0, 0, 23, 12, 2, '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(3, 2, 12, 'Study Group for Midterm', 'Anyone interested in forming a study group for the upcoming midterm? We can meet on weekends.', 'discussion', 0, 0, 38, 8, 5, '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(4, 1, 2, 'Assignment 1 Tips', 'Here are some tips for Assignment 1: 1) Start early, 2) Test your code thoroughly, 3) Follow PEP 8 style guide', 'announcement', 1, 0, 102, 25, 1, '2025-11-20 13:43:00', '2025-11-20 13:43:00');

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
(1, 1, 9, 'The range function generates a sequence of numbers. range(5) gives you 0,1,2,3,4. You can use it like: for i in range(5): print(i)', NULL, 5, '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(2, 1, 5, 'Check out this tutorial: https://realpython.com/python-for-loop/. It explains loops very well!', NULL, 3, '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(3, 1, 7, 'Thanks! That helps a lot!', NULL, 1, '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(4, 2, 9, 'I agree! The lectures are very well structured.', NULL, 2, '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(5, 4, 7, 'Thank you for the tips, Professor!', NULL, 1, '2025-11-20 13:43:00', '2025-11-20 13:43:00');

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
(1, 1, 8, 'helpful', '2025-11-20 13:43:00'),
(2, 1, 9, 'like', '2025-11-20 13:43:00'),
(3, 1, 10, 'helpful', '2025-11-20 13:43:00'),
(4, 2, 7, 'like', '2025-11-20 13:43:00'),
(5, 2, 9, 'like', '2025-11-20 13:43:00'),
(6, 2, 10, 'insightful', '2025-11-20 13:43:00'),
(7, 4, 7, 'helpful', '2025-11-20 13:43:00'),
(8, 4, 8, 'helpful', '2025-11-20 13:43:00'),
(9, 4, 9, 'thanks', '2025-11-20 13:43:00');

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
(1, 1, 'Introduction to Programming', 'CS101', 'Basic programming concepts using Python', 3, 'freshman', NULL, 'active', '2025-11-20 13:42:59', '2025-11-20 13:42:59', NULL),
(2, 1, 'Data Structures', 'CS201', 'Fundamental data structures and algorithms', 4, 'sophomore', NULL, 'active', '2025-11-20 13:42:59', '2025-11-20 13:42:59', NULL),
(3, 1, 'Database Systems', 'CS301', 'Database design and SQL', 3, 'junior', NULL, 'active', '2025-11-20 13:42:59', '2025-11-20 13:42:59', NULL),
(4, 1, 'Artificial Intelligence', 'CS401', 'Introduction to AI and machine learning', 4, 'senior', NULL, 'active', '2025-11-20 13:42:59', '2025-11-20 13:42:59', NULL),
(5, 2, 'Calculus I', 'MATH101', 'Differential calculus', 4, 'freshman', NULL, 'active', '2025-11-20 13:42:59', '2025-11-20 13:42:59', NULL),
(6, 2, 'Linear Algebra', 'MATH201', 'Matrices and vector spaces', 3, 'sophomore', NULL, 'active', '2025-11-20 13:42:59', '2025-11-20 13:42:59', NULL),
(7, 3, 'Physics I', 'PHY101', 'Classical mechanics', 4, 'freshman', NULL, 'active', '2025-11-20 13:42:59', '2025-11-20 13:42:59', NULL),
(8, 4, 'Business Management', 'BUS101', 'Introduction to business management', 3, 'freshman', NULL, 'active', '2025-11-20 13:42:59', '2025-11-20 13:42:59', NULL);

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
(1, 1, 2, 15, 14, 85.50, 92.30, 78.50, 88.20, '2025-02-15', '2025-11-20 13:43:01'),
(2, 2, 3, 12, 11, 82.75, 88.50, 72.30, 84.10, '2025-02-15', '2025-11-20 13:43:01'),
(3, 3, 3, 10, 10, 87.20, 95.00, 85.40, 91.30, '2025-02-15', '2025-11-20 13:43:01'),
(4, 1, 2, 15, 15, 83.20, 89.50, 75.20, 86.50, '2025-02-01', '2025-11-20 13:43:01');

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

INSERT INTO `course_chat_threads` (`thread_id`, `course_id`, `created_by`, `title`, `description`, `is_pinned`, `is_locked`, `view_count`, `reply_count`, `created_at`, `updated_at`) VALUES
(1, 1, 7, 'Assignment 1 Discussion', 'Questions and help for Assignment 1', 0, 0, 78, 12, '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(2, 1, 2, 'General Q&A - Week 1', 'Questions from Week 1 lectures', 1, 0, 145, 8, '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(3, 2, 12, 'Data Structures Study Tips', 'Share study resources and tips', 0, 0, 56, 15, '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(4, 1, 8, 'Python installation help', 'Help with setting up Python environment', 0, 0, 34, 6, '2025-11-20 13:43:00', '2025-11-20 13:43:00');

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
  `completed_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `course_materials`
--

INSERT INTO `course_materials` (`material_id`, `course_id`, `file_id`, `material_type`, `title`, `description`, `external_url`, `order_index`, `uploaded_by`, `is_published`, `published_at`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 'document', 'Course Syllabus', 'CS101 Fall 2025 Syllabus', NULL, 1, 2, 1, NULL, '2025-11-20 13:42:59', '2025-11-20 13:42:59'),
(2, 1, 2, 'lecture', 'Lecture 1: Introduction to Programming', 'Overview of programming concepts', NULL, 2, 2, 1, NULL, '2025-11-20 13:42:59', '2025-11-20 13:42:59'),
(3, 1, 3, 'lecture', 'Lecture 2: Variables and Data Types', 'Understanding variables in Python', NULL, 3, 2, 1, NULL, '2025-11-20 13:42:59', '2025-11-20 13:42:59'),
(4, 2, 4, 'document', 'Course Syllabus', 'CS201 Spring 2025 Syllabus', NULL, 1, 3, 1, NULL, '2025-11-20 13:42:59', '2025-11-20 13:42:59'),
(5, 1, NULL, 'video', 'Introduction Video', 'Welcome to CS101', NULL, 0, 2, 1, NULL, '2025-11-20 13:42:59', '2025-11-20 13:42:59');

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
(1, 2, 1, 1, '2025-11-20 13:42:59'),
(2, 3, 2, 1, '2025-11-20 13:42:59'),
(3, 4, 2, 1, '2025-11-20 13:42:59'),
(4, 6, 5, 1, '2025-11-20 13:42:59');

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
(1, 2, 7, '2025-02-26 07:00:00', 'email', 'pending', NULL, '2025-11-20 13:43:00'),
(2, 2, 7, '2025-02-27 07:00:00', 'push', 'pending', NULL, '2025-11-20 13:43:00'),
(3, 3, 7, '2025-03-08 07:00:00', 'in_app', 'pending', NULL, '2025-11-20 13:43:00'),
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
(1, 1, 'Computer Science', 'CS', NULL, 'Department of Computer Science and Engineering', 'active', '2025-11-20 13:42:59', '2025-11-20 13:42:59'),
(2, 1, 'Mathematics', 'MATH', NULL, 'Department of Mathematics', 'active', '2025-11-20 13:42:59', '2025-11-20 13:42:59'),
(3, 1, 'Physics', 'PHY', NULL, 'Department of Physics', 'active', '2025-11-20 13:42:59', '2025-11-20 13:42:59'),
(4, 2, 'Business Administration', 'BUS', NULL, 'School of Business', 'active', '2025-11-20 13:42:59', '2025-11-20 13:42:59'),
(5, 2, 'Engineering', 'ENG', NULL, 'School of Engineering', 'active', '2025-11-20 13:42:59', '2025-11-20 13:42:59');

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
(11, 33, 'e3e106fdf64b97aa98d2aa32913f0848e3be99cc0e56da772d0a1fed775b95fe', '2025-11-28 02:36:26', 1, '2025-11-27 02:36:43', '2025-11-27 00:36:26');

-- --------------------------------------------------------

--
-- Table structure for table `exam_schedules`
--

CREATE TABLE `exam_schedules` (
  `exam_id` bigint(20) UNSIGNED NOT NULL,
  `course_id` bigint(20) UNSIGNED NOT NULL,
  `semester_id` bigint(20) UNSIGNED NOT NULL,
  `exam_type` enum('midterm','final','quiz','makeup') NOT NULL,
  `exam_date` date NOT NULL,
  `start_time` time NOT NULL,
  `duration_minutes` int(11) NOT NULL,
  `location` varchar(255) DEFAULT NULL,
  `instructions` text DEFAULT NULL,
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
  `attachments` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`attachments`)),
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
(5, 'Student Submissions', NULL, 1, '/student_submissions', 0, 1, '2025-11-20 13:42:59', '2025-11-20 13:42:59');

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
(1, 1, 'General Discussion', 'General questions and discussions about CS101', 1, '2025-11-20 13:43:00'),
(2, 1, 'Assignment Help', 'Get help with assignments', 2, '2025-11-20 13:43:00'),
(3, 1, 'Resources', 'Share helpful resources and materials', 3, '2025-11-20 13:43:00'),
(4, 2, 'General Discussion', 'General CS201 discussions', 1, '2025-11-20 13:43:00'),
(5, 2, 'Project Discussions', 'Discuss course projects', 2, '2025-11-20 13:43:00');

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
  `filters` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`filters`)),
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
(1, 7, 1, 1, NULL, NULL, 'assignment', 95.00, 100.00, 95.00, 'A', 'Excellent work!', 2, '2025-02-16 08:00:00', 1, NULL, '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(2, 8, 1, 1, NULL, NULL, 'assignment', 88.00, 100.00, 88.00, 'B+', 'Good job!', 2, '2025-02-16 08:15:00', 1, NULL, '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(3, 10, 1, 1, NULL, NULL, 'assignment', 72.00, 100.00, 72.00, 'C', 'Late submission - 10% penalty applied', 2, '2025-02-17 07:00:00', 1, NULL, '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(4, 7, 1, NULL, NULL, NULL, 'quiz', 85.00, 100.00, 85.00, 'B+', 'Well done on the quiz', 2, '2025-02-12 09:00:00', 1, NULL, '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(5, 8, 1, NULL, NULL, NULL, 'quiz', 90.00, 100.00, 90.00, 'A-', 'Great performance', 2, '2025-02-12 13:00:00', 1, NULL, '2025-11-20 13:43:00', '2025-11-20 13:43:00');

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

--
-- Dumping data for table `grade_components`
--

INSERT INTO `grade_components` (`component_id`, `grade_id`, `rubric_id`, `criterion_name`, `points_earned`, `max_points`, `feedback`) VALUES
(1, 1, 1, 'Correctness', 40.00, 40.00, 'Program runs perfectly and handles all test cases'),
(2, 1, 1, 'Code Quality', 28.00, 30.00, 'Code is clean but could use better variable naming'),
(3, 1, 1, 'Documentation', 18.00, 20.00, 'Good comments, could add more function descriptions'),
(4, 1, 1, 'Testing', 9.00, 10.00, 'Most edge cases covered'),
(5, 2, 1, 'Correctness', 35.00, 40.00, 'Minor logic error in one test case'),
(6, 2, 1, 'Code Quality', 26.00, 30.00, 'Good structure overall'),
(7, 2, 1, 'Documentation', 18.00, 20.00, 'Adequate documentation'),
(8, 2, 1, 'Testing', 9.00, 10.00, 'Good test coverage');

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
  `created_by` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `labs`
--

INSERT INTO `labs` (`lab_id`, `course_id`, `title`, `description`, `lab_number`, `due_date`, `available_from`, `max_score`, `weight`, `created_by`, `created_at`, `updated_at`) VALUES
(1, 1, 'Lab 1: Python Setup', 'Install Python and run your first program', 1, '2025-02-08 21:59:59', '2025-01-31 22:00:00', 50.00, 5.00, 2, '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(2, 1, 'Lab 2: Working with Lists', 'Practice list operations', 2, '2025-02-22 21:59:59', '2025-02-14 22:00:00', 75.00, 7.50, 2, '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(3, 2, 'Lab 1: Array Implementation', 'Implement dynamic arrays', 1, '2025-03-01 21:59:59', '2025-02-14 22:00:00', 100.00, 10.00, 3, '2025-11-20 13:43:00', '2025-11-20 13:43:00');

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
(1, 1, 7, 'present', '2025-02-05 12:00:00', 'Completed lab successfully', 5, '2025-11-20 13:43:01'),
(2, 1, 8, 'present', '2025-02-05 12:05:00', 'Good work', 5, '2025-11-20 13:43:01'),
(3, 1, 9, 'present', '2025-02-05 12:02:00', NULL, 5, '2025-11-20 13:43:01'),
(4, 1, 10, 'late', '2025-02-05 12:20:00', 'Arrived 20 minutes late', 5, '2025-11-20 13:43:01'),
(5, 2, 7, 'present', '2025-02-19 12:00:00', NULL, 5, '2025-11-20 13:43:01'),
(6, 2, 8, 'absent', NULL, 'Did not attend', 5, '2025-11-20 13:43:01');

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
(1, 1, 5, '1. Download and install Python 3.11 from python.org', 1, '2025-11-20 13:43:00'),
(2, 1, NULL, '2. Open a terminal or command prompt', 2, '2025-11-20 13:43:00'),
(3, 1, NULL, '3. Type \"python --version\" to verify installation', 3, '2025-11-20 13:43:00'),
(4, 1, NULL, '4. Create a file named hello.py with the code: print(\"Hello World\")', 4, '2025-11-20 13:43:00'),
(5, 1, NULL, '5. Run the program using: python hello.py', 5, '2025-11-20 13:43:00'),
(6, 2, 5, 'Complete the exercises in the attached worksheet', 1, '2025-11-20 13:43:00'),
(7, 3, NULL, 'Implement a dynamic array class with push, pop, and resize methods', 1, '2025-11-20 13:43:00');

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
(1, 1, 7, NULL, 'Successfully installed Python 3.11 and ran hello world program', '2025-11-20 13:43:00', 0, 'graded'),
(2, 1, 8, NULL, 'Installed Python and verified installation', '2025-11-20 13:43:00', 0, 'graded'),
(3, 1, 9, NULL, 'Python setup complete', '2025-11-20 13:43:00', 0, 'graded'),
(4, 1, 10, NULL, 'Installation successful', '2025-11-20 13:43:00', 0, 'submitted');

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
  `additional_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`additional_data`)),
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
(1, 1, 1, 'lecture', 'Week 1: Course Introduction', 1, 1, 'Overview of the course, syllabus, and expectations', '2025-11-20 13:43:01'),
(2, 1, 2, 'lecture', 'Week 1: Programming Basics', 1, 2, 'Introduction to programming concepts', '2025-11-20 13:43:01'),
(3, 1, 3, 'lecture', 'Week 2: Variables and Data Types', 2, 3, 'Understanding variables in Python', '2025-11-20 13:43:01'),
(4, 1, NULL, 'lab', 'Week 1: Lab - Python Setup', 1, 4, 'Setting up Python environment', '2025-11-20 13:43:01'),
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
(1, 1, 2, 'CS101 Live Review Session', 'https://meet.campus.edu/cs101-review-1', '2025-02-20 16:00:00', '2025-02-20 17:30:00', NULL, 15, 'ended', '2025-11-20 13:43:00'),
(2, 2, 3, 'Data Structures Q&A', 'https://meet.campus.edu/cs201-qa-1', '2025-02-22 15:00:00', '2025-02-22 16:00:00', NULL, 8, 'ended', '2025-11-20 13:43:00'),
(3, 1, 2, 'Midterm Preparation', 'https://meet.campus.edu/cs101-midterm', '2025-03-05 17:00:00', '2025-03-05 19:00:00', NULL, 0, 'scheduled', '2025-11-20 13:43:00');

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
(1, 1, 7, '2025-02-20 16:02:00', '2025-02-20 17:28:00', 95.00),
(2, 1, 8, '2025-02-20 16:05:00', '2025-02-20 17:30:00', 88.00),
(3, 1, 9, '2025-02-20 16:01:00', '2025-02-20 17:15:00', 82.00),
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
  `read_status` tinyint(1) DEFAULT 0,
  `sent_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `messages`
--

INSERT INTO `messages` (`message_id`, `sender_id`, `subject`, `body`, `message_type`, `parent_message_id`, `read_status`, `sent_at`) VALUES
(1, 2, 'Welcome to CS101', 'Welcome to Introduction to Programming! I look forward to working with you this semester.', 'announcement', NULL, 0, '2025-11-20 13:43:00'),
(2, 7, 'Question about Assignment 1', 'Professor Smith, I have a question about the first assignment. Can we use external libraries?', 'direct', NULL, 1, '2025-11-20 13:43:00'),
(3, 2, 'RE: Question about Assignment 1', 'For this assignment, please use only built-in Python functions.', 'direct', NULL, 0, '2025-11-20 13:43:00'),
(4, 3, 'CS201 Project Groups', 'Please form groups of 3-4 students for the final project.', 'announcement', NULL, 0, '2025-11-20 13:43:00');

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
(5, 3, 7, NULL, NULL);

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
(1, 7, 'announcement', 'New Course Announcement', 'Course Start: Welcome to CS101!', NULL, NULL, 1, 1, NULL, 'high', NULL, '2025-01-15 07:00:00'),
(2, 7, 'assignment', 'New Assignment Posted', 'Assignment 1 is now available', NULL, NULL, NULL, 1, NULL, 'medium', NULL, '2025-02-01 08:00:00'),
(3, 7, 'grade', 'Grade Posted', 'Your grade for Assignment 1 has been posted', NULL, NULL, NULL, 0, NULL, 'medium', NULL, '2025-02-16 08:00:00'),
(4, 8, 'announcement', 'New Course Announcement', 'Course Start: Welcome to CS101!', NULL, NULL, 1, 1, NULL, 'high', NULL, '2025-01-15 07:00:00'),
(5, 8, 'grade', 'Grade Posted', 'Your grade for Assignment 1 has been posted', NULL, NULL, NULL, 1, NULL, 'medium', NULL, '2025-02-16 08:15:00'),
(6, 9, 'deadline', 'Assignment Due Soon', 'Assignment 1 due in 2 days', NULL, NULL, NULL, 0, NULL, 'high', NULL, '2025-02-13 07:00:00');

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
(6, 12, 1, 0, 0, 1, 1, 0, 0, 2, '22:00:00', '07:00:00', '2025-11-20 13:43:00', '2025-11-20 13:43:00');

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
  `data_snapshot` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`data_snapshot`)),
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
(1, 7, 1, 299.99, 'USD', 'credit_card', 'completed', 'stripe_ch_1234567890', '2025-01-10 13:30:00', '2025-11-20 13:43:01'),
(2, 8, 1, 299.99, 'USD', 'paypal', 'completed', 'paypal_txn_9876543210', '2025-01-11 08:15:00', '2025-11-20 13:43:01'),
(3, 9, 2, 399.99, 'USD', 'credit_card', 'completed', 'stripe_ch_0987654321', '2025-01-12 12:20:00', '2025-11-20 13:43:01'),
(4, 10, 1, 299.99, 'USD', 'credit_card', 'failed', 'stripe_ch_1111111111', '2025-11-20 13:43:01', '2025-11-20 13:43:01'),
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
  `criteria_scores` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`criteria_scores`)),
  `status` enum('pending','submitted','acknowledged') DEFAULT 'pending',
  `submitted_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `peer_reviews`
--

INSERT INTO `peer_reviews` (`review_id`, `submission_id`, `reviewer_id`, `reviewee_id`, `review_text`, `rating`, `criteria_scores`, `status`, `submitted_at`, `created_at`) VALUES
(1, 1, 8, 7, 'Excellent work! Code is clean and well-commented. The logic is correct and output matches requirements perfectly.', 4.80, NULL, 'submitted', '2025-02-16 12:30:00', '2025-11-20 13:43:00'),
(2, 2, 9, 8, 'Good job! Code works correctly. Suggestion: Add more comments to explain your approach.', 4.20, NULL, 'submitted', '2025-02-16 13:45:00', '2025-11-20 13:43:00'),
(3, 3, 10, 9, 'Code functions properly but could be more efficient. Consider using built-in functions.', 3.80, NULL, 'submitted', '2025-02-17 08:20:00', '2025-11-20 13:43:00'),
(4, 1, 9, 7, 'Great submission! Very readable code with proper formatting.', 4.90, NULL, 'submitted', '2025-02-16 14:00:00', '2025-11-20 13:43:00');

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

--
-- Dumping data for table `performance_metrics`
--

INSERT INTO `performance_metrics` (`metric_id`, `user_id`, `course_id`, `metric_name`, `metric_value`, `calculation_date`, `trend`, `created_at`) VALUES
(1, 7, 1, 'overall_grade', 91.25, '2025-02-15', 'improving', '2025-11-20 13:43:00'),
(2, 7, 1, 'assignment_average', 95.00, '2025-02-15', 'stable', '2025-11-20 13:43:00'),
(3, 7, 1, 'quiz_average', 85.00, '2025-02-15', 'improving', '2025-11-20 13:43:00'),
(4, 8, 1, 'overall_grade', 87.50, '2025-02-15', 'stable', '2025-11-20 13:43:00'),
(5, 9, 1, 'overall_grade', 75.00, '2025-02-15', 'declining', '2025-11-20 13:43:00'),
(6, 10, 1, 'overall_grade', 72.00, '2025-02-15', 'improving', '2025-11-20 13:43:00');

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
(1, 1, 'Bachelor of Computer Science', 'BCS', 'bachelor', 4, 'Undergraduate program in Computer Science', 'active', '2025-11-20 13:42:59', '2025-11-20 13:42:59'),
(2, 1, 'Master of Computer Science', 'MCS', 'master', 2, 'Graduate program in Computer Science', 'active', '2025-11-20 13:42:59', '2025-11-20 13:42:59'),
(3, 2, 'Bachelor of Mathematics', 'BMATH', 'bachelor', 4, 'Undergraduate program in Mathematics', 'active', '2025-11-20 13:42:59', '2025-11-20 13:42:59'),
(4, 4, 'Bachelor of Business Administration', 'BBA', 'bachelor', 4, 'Undergraduate business program', 'active', '2025-11-20 13:42:59', '2025-11-20 13:42:59'),
(5, 5, 'Bachelor of Engineering', 'BE', 'bachelor', 4, 'Undergraduate engineering program', 'active', '2025-11-20 13:42:59', '2025-11-20 13:42:59');

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
  `created_by` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `quizzes`
--

INSERT INTO `quizzes` (`quiz_id`, `course_id`, `title`, `description`, `instructions`, `quiz_type`, `time_limit_minutes`, `max_attempts`, `passing_score`, `randomize_questions`, `show_correct_answers`, `show_answers_after`, `available_from`, `available_until`, `weight`, `created_by`, `created_at`, `updated_at`, `deleted_at`) VALUES
(1, 1, 'Quiz 1: Python Basics', 'Test your knowledge of Python fundamentals', NULL, 'graded', 30, 2, 70.00, 1, 1, 'after_due', '2025-02-09 22:00:00', '2025-02-20 21:59:59', 10.00, 2, '2025-11-20 13:42:59', '2025-11-20 13:42:59', NULL),
(2, 1, 'Quiz 2: Control Structures', 'If statements and loops', NULL, 'graded', 45, 1, 70.00, 1, 1, 'after_due', '2025-02-28 22:00:00', '2025-03-10 21:59:59', 10.00, 2, '2025-11-20 13:42:59', '2025-11-20 13:42:59', NULL),
(3, 2, 'Quiz 1: Arrays and Lists', 'Understanding arrays', NULL, 'graded', 60, 1, 75.00, 0, 1, 'after_due', '2025-02-14 22:00:00', '2025-02-25 21:59:59', 15.00, 3, '2025-11-20 13:42:59', '2025-11-20 13:42:59', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `quiz_answers`
--

CREATE TABLE `quiz_answers` (
  `answer_id` bigint(20) UNSIGNED NOT NULL,
  `attempt_id` bigint(20) UNSIGNED NOT NULL,
  `question_id` bigint(20) UNSIGNED NOT NULL,
  `answer_text` text DEFAULT NULL,
  `selected_option` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`selected_option`)),
  `is_correct` tinyint(1) DEFAULT NULL,
  `points_earned` decimal(5,2) DEFAULT 0.00,
  `answered_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `quiz_answers`
--

INSERT INTO `quiz_answers` (`answer_id`, `attempt_id`, `question_id`, `answer_text`, `selected_option`, `is_correct`, `points_earned`, `answered_at`) VALUES
(1, 1, 1, NULL, '0', 1, 10.00, '2025-11-20 13:43:00'),
(2, 1, 2, NULL, '0', 1, 10.00, '2025-11-20 13:43:00'),
(3, 1, 3, NULL, '0', 1, 5.00, '2025-11-20 13:43:00'),
(4, 2, 1, NULL, '0', 1, 10.00, '2025-11-20 13:43:00'),
(5, 2, 2, NULL, '0', 1, 10.00, '2025-11-20 13:43:00'),
(6, 2, 3, NULL, '0', 1, 5.00, '2025-11-20 13:43:00');

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
(1, 1, 7, 1, '2025-11-20 13:42:59', '2025-02-12 08:30:00', 85.00, 25, 'graded', NULL),
(2, 1, 8, 1, '2025-11-20 13:42:59', '2025-02-12 12:15:00', 90.00, 28, 'graded', NULL),
(3, 1, 9, 1, '2025-11-20 13:42:59', '2025-02-13 07:45:00', 75.00, 30, 'graded', NULL),
(4, 1, 10, 1, '2025-11-20 13:42:59', NULL, NULL, NULL, 'in_progress', NULL);

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
(3, 'Hard', 3, 'Advanced level questions');

-- --------------------------------------------------------

--
-- Table structure for table `quiz_questions`
--

CREATE TABLE `quiz_questions` (
  `question_id` bigint(20) UNSIGNED NOT NULL,
  `quiz_id` bigint(20) UNSIGNED NOT NULL,
  `question_text` text NOT NULL,
  `question_type` enum('mcq','true_false','short_answer','essay','matching') NOT NULL,
  `options` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`options`)),
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
(1, 1, 'What is the correct way to create a variable in Python?', 'mcq', '[\"x = 5\", \"var x = 5\", \"int x = 5\", \"x := 5\"]', '0', 'In Python, variables are created with simple assignment', 10.00, 1, 1, '2025-11-20 13:42:59', '2025-11-20 13:42:59'),
(2, 1, 'Which data type is used for text in Python?', 'mcq', '[\"string\", \"text\", \"char\", \"varchar\"]', '0', 'Python uses str (string) type for text', 10.00, 1, 2, '2025-11-20 13:42:59', '2025-11-20 13:42:59'),
(3, 1, 'Python is case-sensitive', 'true_false', '[\"True\", \"False\"]', '0', 'Python distinguishes between uppercase and lowercase', 5.00, 1, 3, '2025-11-20 13:42:59', '2025-11-20 13:42:59'),
(4, 2, 'Which keyword is used for conditional statements?', 'mcq', '[\"if\", \"when\", \"check\", \"condition\"]', '0', 'if keyword is used for conditionals', 10.00, 1, 1, '2025-11-20 13:42:59', '2025-11-20 13:42:59'),
(5, 3, 'What is the time complexity of accessing an element in an array by index?', 'mcq', '[\"O(1)\", \"O(n)\", \"O(log n)\", \"O(n^2)\"]', '0', 'Array access by index is constant time', 15.00, 2, 1, '2025-11-20 13:42:59', '2025-11-20 13:42:59');

-- --------------------------------------------------------

--
-- Table structure for table `report_templates`
--

CREATE TABLE `report_templates` (
  `template_id` bigint(20) UNSIGNED NOT NULL,
  `template_name` varchar(255) NOT NULL,
  `template_type` enum('student','course','attendance','grade','analytics','custom') NOT NULL,
  `template_structure` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`template_structure`)),
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
  `reward_value` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`reward_value`)),
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
  `delivery_details` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`delivery_details`)),
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
(5, 'department_head', 'Department Head', '2025-11-20 13:42:59');

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
(1, 1, 1, '2025-11-20 13:42:59'),
(2, 1, 2, '2025-11-20 13:42:59'),
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
(22, 5, 6, '2025-11-20 13:42:59');

-- --------------------------------------------------------

--
-- Table structure for table `rubrics`
--

CREATE TABLE `rubrics` (
  `rubric_id` bigint(20) UNSIGNED NOT NULL,
  `course_id` bigint(20) UNSIGNED NOT NULL,
  `rubric_name` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `criteria` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`criteria`)),
  `total_points` decimal(5,2) DEFAULT 100.00,
  `created_by` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `rubrics`
--

INSERT INTO `rubrics` (`rubric_id`, `course_id`, `rubric_name`, `description`, `criteria`, `total_points`, `created_by`, `created_at`, `updated_at`) VALUES
(1, 1, 'Programming Assignment Rubric', 'Standard rubric for coding assignments', '{\"criteria\": [{\"name\": \"Correctness\", \"points\": 40}, {\"name\": \"Code Quality\", \"points\": 30}, {\"name\": \"Documentation\", \"points\": 20}, {\"name\": \"Testing\", \"points\": 10}]}', 100.00, 2, '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(2, 2, 'Data Structures Project Rubric', 'Rubric for DS projects', '{\"criteria\": [{\"name\": \"Implementation\", \"points\": 50}, {\"name\": \"Efficiency\", \"points\": 25}, {\"name\": \"Documentation\", \"points\": 15}, {\"name\": \"Presentation\", \"points\": 10}]}', 100.00, 3, '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(3, 1, 'Lab Report Rubric', 'Standard lab report grading', '{\"criteria\": [{\"name\": \"Completion\", \"points\": 30}, {\"name\": \"Analysis\", \"points\": 40}, {\"name\": \"Writing\", \"points\": 30}]}', 100.00, 2, '2025-11-20 13:43:00', '2025-11-20 13:43:00');

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
  `search_filters` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`search_filters`)),
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
  `metadata` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`metadata`)),
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
(3, 'Summer 2025', 'SU2025', '2025-06-01', '2025-08-15', '2025-05-01', '2025-05-25', 'upcoming', '2025-11-20 13:42:59'),
(4, 'Fall 2025', 'F2025', '2025-09-01', '2025-12-31', '2025-08-01', '2025-08-25', 'active', '2025-11-26 18:54:24'),
(7, 'Fall 2027', 'F2027', '2027-09-01', '2027-12-20', '2027-08-01', '2027-08-25', 'upcoming', '2025-11-26 19:28:01');

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
(68, 30, 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjMwLCJlbWFpbCI6ImFtMzU2NjE0M0BnbWFpbC5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc2NDIwMzg2MiwiZXhwIjoxNzY0ODA4NjYyfQ.OMFNxg2GN8WeDxbypZBVcDnP6JrM5fHZ_8X71z_h6D0', '192.168.1.3', 'Dart/3.9 (dart:io)', 'desktop', '2025-12-04 00:37:42', '2025-11-27 00:37:42', 0);

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
(1, 7, 'assignment', 1, NULL, NULL, 'Complete Assignment 1', 'Submit Hello World program', '2025-02-15 21:59:59', 'high', 'completed', 100, '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(2, 7, 'assignment', 2, NULL, NULL, 'Complete Assignment 2', 'Variables practice', '2025-02-28 21:59:59', 'high', 'in_progress', 60, '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(3, 7, 'quiz', NULL, 2, NULL, 'Take Quiz 2', 'Control Structures quiz', '2025-03-10 21:59:59', 'medium', 'pending', 0, '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(4, 8, 'assignment', 1, NULL, NULL, 'Complete Assignment 1', 'Submit Hello World program', '2025-02-15 21:59:59', 'high', 'completed', 100, '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
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
(1, 1, 'CS101 Evening Study Group', 'Study group meeting Tuesday and Thursday evenings', 7, 6, 4, 1, 'Tuesday & Thursday 6-8 PM', 'active', '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(2, 2, 'Data Structures Masters', 'Advanced study group for CS201', 12, 5, 3, 1, 'Monday & Wednesday 5-7 PM', 'active', '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(3, 1, 'Weekend Warriors', 'Weekend study sessions', 9, 8, 5, 1, 'Saturday 10 AM - 2 PM', 'active', '2025-11-20 13:43:00', '2025-11-20 13:43:00');

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
(1, 1, 7, 'creator', '2025-11-20 13:43:00'),
(2, 1, 8, 'member', '2025-11-20 13:43:00'),
(3, 1, 9, 'moderator', '2025-11-20 13:43:00'),
(4, 1, 10, 'member', '2025-11-20 13:43:00'),
(5, 2, 12, 'creator', '2025-11-20 13:43:00'),
(6, 2, 13, 'member', '2025-11-20 13:43:00'),
(7, 2, 14, 'member', '2025-11-20 13:43:00'),
(8, 3, 9, 'creator', '2025-11-20 13:43:00'),
(9, 3, 10, 'member', '2025-11-20 13:43:00'),
(10, 3, 11, 'member', '2025-11-20 13:43:00'),
(11, 3, 7, 'member', '2025-11-20 13:43:00'),
(12, 3, 8, 'member', '2025-11-20 13:43:00');

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

--
-- Dumping data for table `task_completion`
--

INSERT INTO `task_completion` (`completion_id`, `task_id`, `user_id`, `completed_at`, `time_taken_minutes`, `notes`) VALUES
(1, 1, 7, '2025-02-14 18:30:00', 120, 'Completed ahead of schedule. Found it straightforward.'),
(2, 4, 8, '2025-02-14 20:15:00', 95, 'Good assignment, learned a lot about print statements.');

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
  `backup_codes` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`backup_codes`)),
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

INSERT INTO `users` (`user_id`, `email`, `password_hash`, `first_name`, `last_name`, `phone`, `profile_picture_url`, `campus_id`, `status`, `email_verified`, `last_login_at`, `created_at`, `updated_at`, `deleted_at`) VALUES
(1, 'admin@campus.edu', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'John', 'Admin', '+1-555-1001', NULL, 1, 'active', 1, NULL, '2025-11-20 13:42:59', '2025-11-20 13:42:59', NULL),
(2, 'prof.smith@campus.edu', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Robert', 'Smith', '+1-555-1002', NULL, 1, 'active', 1, NULL, '2025-11-20 13:42:59', '2025-11-20 13:42:59', NULL),
(3, 'prof.johnson@campus.edu', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Emily', 'Johnson', '+1-555-1003', NULL, 1, 'active', 1, NULL, '2025-11-20 13:42:59', '2025-11-20 13:42:59', NULL),
(4, 'prof.williams@campus.edu', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Michael', 'Williams', '+1-555-1004', NULL, 1, 'active', 1, NULL, '2025-11-20 13:42:59', '2025-11-20 13:42:59', NULL),
(5, 'ta.brown@campus.edu', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Sarah', 'Brown', '+1-555-1005', NULL, 1, 'active', 1, NULL, '2025-11-20 13:42:59', '2025-11-20 13:42:59', NULL),
(6, 'ta.davis@campus.edu', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'James', 'Davis', '+1-555-1006', NULL, 1, 'active', 1, NULL, '2025-11-20 13:42:59', '2025-11-20 13:42:59', NULL),
(7, 'alice.student@campus.edu', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Alice', 'Anderson', '+1-555-2001', NULL, 1, 'active', 1, NULL, '2025-11-20 13:42:59', '2025-11-20 13:42:59', NULL),
(8, 'bob.student@campus.edu', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Bob', 'Martinez', '+1-555-2002', NULL, 1, 'active', 1, NULL, '2025-11-20 13:42:59', '2025-11-20 13:42:59', NULL),
(9, 'carol.student@campus.edu', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Carol', 'Garcia', '+1-555-2003', NULL, 1, 'active', 1, NULL, '2025-11-20 13:42:59', '2025-11-20 13:42:59', NULL),
(10, 'david.student@campus.edu', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'David', 'Rodriguez', '+1-555-2004', NULL, 1, 'active', 1, NULL, '2025-11-20 13:42:59', '2025-11-20 13:42:59', NULL),
(11, 'emma.student@campus.edu', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Emma', 'Wilson', '+1-555-2005', NULL, 1, 'active', 1, NULL, '2025-11-20 13:42:59', '2025-11-20 13:42:59', NULL),
(12, 'frank.student@campus.edu', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Frank', 'Lopez', '+1-555-2006', NULL, 1, 'active', 1, NULL, '2025-11-20 13:42:59', '2025-11-20 13:42:59', NULL),
(13, 'grace.student@campus.edu', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Grace', 'Lee', '+1-555-2007', NULL, 1, 'active', 1, NULL, '2025-11-20 13:42:59', '2025-11-20 13:42:59', NULL),
(14, 'henry.student@campus.edu', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Henry', 'Walker', '+1-555-2008', NULL, 1, 'active', 1, NULL, '2025-11-20 13:42:59', '2025-11-20 13:42:59', NULL),
(15, 'ivy.student@campus.edu', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Ivy', 'Hall', '+1-555-2009', NULL, 1, 'active', 1, NULL, '2025-11-20 13:42:59', '2025-11-20 13:42:59', NULL),
(16, 'jack.student@campus.edu', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Jack', 'Allen', '+1-555-2010', NULL, 1, 'active', 1, NULL, '2025-11-20 13:42:59', '2025-11-20 13:42:59', NULL),
(17, 'amir123@campus.edu', '$2a$12$C311w/5Myorf1.zx35NarOlekceRfdFvjGr1xUgx0s4GHxky4JaQa', 'Amir', 'Doe', '+1234567890', NULL, 1, 'active', 1, '2025-11-24 23:24:53', '2025-11-24 23:02:53', '2025-11-24 23:24:53', NULL),
(18, 'amir.user@campus.edu', '$2a$12$Rq1HOfy3QufvhHKiKrGQFeqyHsX896gCod41jJF1r.XNUUIeQMd4i', 'Test', 'amir2', '+1234567800', NULL, 1, 'active', 1, '2025-11-24 23:33:35', '2025-11-24 23:29:12', '2025-11-24 23:33:35', NULL),
(19, 'amir1234@campus.edu', '$2b$10$Z0TxzhBdcMLt2YuGEbPmTe/nYpEvVPw6I8E7h7cHUaS79NpKv.Lwq', 'Amir', 'Mohamed', '+125451526', NULL, 1, 'active', 1, '2025-11-25 18:00:40', '2025-11-25 02:17:12', '2025-11-25 18:00:41', NULL),
(25, 'am3566146@gmail.com', '$2b$10$lqumSGY0jP1eCtbxIlQQveE1nD7m37YU9jJRrwoGoDlBenDS1EQqi', 'Amir', 'Hamdi', '+201234567890', NULL, NULL, 'active', 1, '2025-11-26 17:53:32', '2025-11-26 15:22:14', '2025-11-26 17:53:32', NULL),
(29, 'am3566147@gmail.com', '$2b$10$oplLjPdOuM19aeyZg9CQJuhUoiQxN00m2LjMTGd4.IDrIs2WI/nUC', 'John', 'Doe', NULL, NULL, NULL, 'active', 1, '2025-11-26 23:34:17', '2025-11-26 18:02:35', '2025-11-26 23:34:17', NULL),
(30, 'am3566143@gmail.com', '$2b$10$1ZlE/jNftUxyDDR5b6Kd2eLR3IB5ZUN9LCrVDU9E0zsMP5mfy4/q.', 'Amir', 'Hamdi', '+2015464646445', NULL, NULL, 'active', 1, '2025-11-27 00:40:27', '2025-11-26 23:31:32', '2025-11-27 00:40:27', NULL),
(33, 'amirhamdidx720@gmail.com', '$2b$10$pl4Dx6LsyXtolFjT3s.X5u.mYMJSYrkM98nDz1IkuCck.O7d3cl52', 'Amir', 'Hamdi', NULL, NULL, NULL, 'active', 1, '2025-11-27 00:36:46', '2025-11-27 00:32:35', '2025-11-27 00:36:46', NULL);

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
  `attachments` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`attachments`)),
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
(39, 33, 1, '2025-11-27 00:32:35', NULL);

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

--
-- Dumping data for table `voice_recordings`
--

INSERT INTO `voice_recordings` (`recording_id`, `user_id`, `course_id`, `file_id`, `transcription_id`, `duration_seconds`, `recording_type`, `created_at`) VALUES
(1, 7, 1, 5, NULL, 180, 'note', '2025-11-20 13:43:00'),
(2, 8, 1, 5, NULL, 240, 'question', '2025-11-20 13:43:00'),
(3, 2, 1, 5, NULL, 3600, 'lecture', '2025-11-20 13:43:00');

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
(1, 10, 1, 'Loop Structures', 65.00, 3, 55.00, '2025-02-14 13:30:00', 1, '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(2, 11, 1, 'String Manipulation', 70.00, 2, 60.00, '2025-02-13 08:20:00', 1, '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(3, 9, 2, 'Linked List Operations', 58.00, 4, 48.00, '2025-02-15 12:45:00', 1, '2025-11-20 13:43:00', '2025-11-20 13:43:00'),
(4, 13, 1, 'Function Parameters', 72.00, 2, 65.00, '2025-02-12 07:15:00', 0, '2025-11-20 13:43:00', '2025-11-20 13:43:00');

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
-- Indexes for table `community_posts`
--
ALTER TABLE `community_posts`
  ADD PRIMARY KEY (`post_id`),
  ADD KEY `idx_course` (`course_id`),
  ADD KEY `idx_user` (`user_id`);

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
  ADD KEY `idx_sent_read` (`sent_at`,`read_status`);

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
-- Indexes for table `user_roles`
--
ALTER TABLE `user_roles`
  ADD PRIMARY KEY (`user_role_id`),
  ADD UNIQUE KEY `unique_user_role` (`user_id`,`role_id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_role` (`role_id`);

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
  MODIFY `processing_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

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
  MODIFY `grading_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

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
  MODIFY `announcement_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

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
  MODIFY `assignment_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `assignment_submissions`
--
ALTER TABLE `assignment_submissions`
  MODIFY `submission_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `attendance_photos`
--
ALTER TABLE `attendance_photos`
  MODIFY `photo_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `attendance_records`
--
ALTER TABLE `attendance_records`
  MODIFY `record_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT for table `attendance_sessions`
--
ALTER TABLE `attendance_sessions`
  MODIFY `session_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

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
  MODIFY `event_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `calendar_integrations`
--
ALTER TABLE `calendar_integrations`
  MODIFY `integration_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `campuses`
--
ALTER TABLE `campuses`
  MODIFY `campus_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

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
  MODIFY `message_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `collaborative_grading`
--
ALTER TABLE `collaborative_grading`
  MODIFY `collab_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `community_posts`
--
ALTER TABLE `community_posts`
  MODIFY `post_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `community_post_comments`
--
ALTER TABLE `community_post_comments`
  MODIFY `comment_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `community_post_reactions`
--
ALTER TABLE `community_post_reactions`
  MODIFY `reaction_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `content_translations`
--
ALTER TABLE `content_translations`
  MODIFY `translation_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `courses`
--
ALTER TABLE `courses`
  MODIFY `course_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `course_analytics`
--
ALTER TABLE `course_analytics`
  MODIFY `analytics_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `course_chat_threads`
--
ALTER TABLE `course_chat_threads`
  MODIFY `thread_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `course_enrollments`
--
ALTER TABLE `course_enrollments`
  MODIFY `enrollment_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=35;

--
-- AUTO_INCREMENT for table `course_instructors`
--
ALTER TABLE `course_instructors`
  MODIFY `assignment_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `course_materials`
--
ALTER TABLE `course_materials`
  MODIFY `material_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `course_prerequisites`
--
ALTER TABLE `course_prerequisites`
  MODIFY `prerequisite_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `course_schedules`
--
ALTER TABLE `course_schedules`
  MODIFY `schedule_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `course_sections`
--
ALTER TABLE `course_sections`
  MODIFY `section_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `course_tas`
--
ALTER TABLE `course_tas`
  MODIFY `assignment_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

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
  MODIFY `department_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `device_tokens`
--
ALTER TABLE `device_tokens`
  MODIFY `token_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `email_verifications`
--
ALTER TABLE `email_verifications`
  MODIFY `verification_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

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
  MODIFY `folder_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `forum_categories`
--
ALTER TABLE `forum_categories`
  MODIFY `category_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

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
  MODIFY `grade_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

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
  MODIFY `lab_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `lab_attendance`
--
ALTER TABLE `lab_attendance`
  MODIFY `attendance_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `lab_instructions`
--
ALTER TABLE `lab_instructions`
  MODIFY `instruction_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `lab_submissions`
--
ALTER TABLE `lab_submissions`
  MODIFY `submission_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

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
  MODIFY `analytics_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

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
  MODIFY `message_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `message_participants`
--
ALTER TABLE `message_participants`
  MODIFY `participant_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `milestone_definitions`
--
ALTER TABLE `milestone_definitions`
  MODIFY `milestone_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `notifications`
--
ALTER TABLE `notifications`
  MODIFY `notification_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `notification_preferences`
--
ALTER TABLE `notification_preferences`
  MODIFY `preference_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `offline_sync_queue`
--
ALTER TABLE `offline_sync_queue`
  MODIFY `sync_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `password_resets`
--
ALTER TABLE `password_resets`
  MODIFY `reset_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `payment_transactions`
--
ALTER TABLE `payment_transactions`
  MODIFY `transaction_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `peer_reviews`
--
ALTER TABLE `peer_reviews`
  MODIFY `review_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

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
  MODIFY `program_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `quizzes`
--
ALTER TABLE `quizzes`
  MODIFY `quiz_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `quiz_answers`
--
ALTER TABLE `quiz_answers`
  MODIFY `answer_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `quiz_attempts`
--
ALTER TABLE `quiz_attempts`
  MODIFY `attempt_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `quiz_difficulty_levels`
--
ALTER TABLE `quiz_difficulty_levels`
  MODIFY `difficulty_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `quiz_questions`
--
ALTER TABLE `quiz_questions`
  MODIFY `question_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

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
  MODIFY `role_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `role_permissions`
--
ALTER TABLE `role_permissions`
  MODIFY `role_permission_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT for table `rubrics`
--
ALTER TABLE `rubrics`
  MODIFY `rubric_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

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
  MODIFY `semester_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `server_monitoring`
--
ALTER TABLE `server_monitoring`
  MODIFY `monitor_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `sessions`
--
ALTER TABLE `sessions`
  MODIFY `session_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=70;

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
  MODIFY `user_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=34;

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
-- AUTO_INCREMENT for table `user_roles`
--
ALTER TABLE `user_roles`
  MODIFY `user_role_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=40;

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
-- Constraints for table `community_posts`
--
ALTER TABLE `community_posts`
  ADD CONSTRAINT `community_posts_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`) ON DELETE CASCADE,
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
-- Constraints for table `user_roles`
--
ALTER TABLE `user_roles`
  ADD CONSTRAINT `user_roles_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `user_roles_ibfk_2` FOREIGN KEY (`role_id`) REFERENCES `roles` (`role_id`) ON DELETE CASCADE;

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
