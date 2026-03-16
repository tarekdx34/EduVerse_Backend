-- MySQL dump 10.13  Distrib 8.4.6, for Win64 (x86_64)
--
-- Host: localhost    Database: eduverse_db
-- ------------------------------------------------------
-- Server version	8.4.7

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `achievements`
--

DROP TABLE IF EXISTS `achievements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `achievements` (
  `achievement_id` int unsigned NOT NULL AUTO_INCREMENT,
  `achievement_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `achievement_description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `achievement_type` enum('score','streak','completion','participation','speed') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `criteria` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `reward_points` int DEFAULT '0',
  `reward_badge_id` int unsigned DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`achievement_id`),
  UNIQUE KEY `achievement_name` (`achievement_name`),
  KEY `reward_badge_id` (`reward_badge_id`),
  CONSTRAINT `achievements_ibfk_1` FOREIGN KEY (`reward_badge_id`) REFERENCES `badges` (`badge_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `achievements`
--

LOCK TABLES `achievements` WRITE;
/*!40000 ALTER TABLE `achievements` DISABLE KEYS */;
INSERT INTO `achievements` VALUES (1,'First Assignment','Submit your first assignment','completion','{\"type\": \"assignment_count\", \"value\": 1}',10,1,1,'2025-11-20 13:43:00'),(2,'Quiz Champion','Score 100% on any quiz','score','{\"type\": \"quiz_score\", \"value\": 100}',50,2,1,'2025-11-20 13:43:00'),(3,'Week Perfect','Perfect attendance for one week','participation','{\"type\": \"attendance_streak\", \"value\": 5}',25,3,1,'2025-11-20 13:43:00'),(4,'Speed Demon','Submit assignment 3 days early','speed','{\"type\": \"early_days\", \"value\": 3}',30,NULL,1,'2025-11-20 13:43:00');
/*!40000 ALTER TABLE `achievements` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `activity_logs`
--

DROP TABLE IF EXISTS `activity_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `activity_logs` (
  `log_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `activity_type` enum('login','logout','view','submit','download','upload','chat','quiz','other') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `entity_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `entity_id` bigint unsigned DEFAULT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `ip_address` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `session_duration_minutes` int DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`log_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_type` (`activity_type`),
  KEY `idx_date` (`created_at`),
  KEY `idx_user_type_date` (`user_id`,`activity_type`,`created_at`),
  KEY `idx_entity` (`entity_type`,`entity_id`),
  CONSTRAINT `activity_logs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `activity_logs`
--

LOCK TABLES `activity_logs` WRITE;
/*!40000 ALTER TABLE `activity_logs` DISABLE KEYS */;
INSERT INTO `activity_logs` VALUES (1,7,'login',NULL,NULL,'User logged in','192.168.1.100',NULL,NULL,'2025-11-20 13:43:00'),(2,7,'view','course_material',1,'Viewed course syllabus','192.168.1.100',NULL,NULL,'2025-11-20 13:43:00'),(3,7,'submit','assignment',1,'Submitted Assignment 1','192.168.1.100',NULL,45,'2025-11-20 13:43:00'),(4,7,'quiz','quiz',1,'Completed Quiz 1','192.168.1.100',NULL,25,'2025-11-20 13:43:00'),(5,8,'login',NULL,NULL,'User logged in','192.168.1.101',NULL,NULL,'2025-11-20 13:43:00'),(6,8,'view','course_material',2,'Viewed Lecture 1','192.168.1.101',NULL,NULL,'2025-11-20 13:43:00'),(7,8,'submit','assignment',1,'Submitted Assignment 1','192.168.1.101',NULL,38,'2025-11-20 13:43:00'),(8,9,'login',NULL,NULL,'User logged in','192.168.1.102',NULL,NULL,'2025-11-20 13:43:00'),(9,57,'login',NULL,NULL,'User logged in','192.168.1.100',NULL,NULL,'2026-03-11 18:12:04'),(10,57,'view','course',1,'Viewed course materials','192.168.1.100',NULL,45,'2026-03-11 18:12:04'),(11,57,'submit','assignment',1,'Submitted Assignment 1','192.168.1.100',NULL,NULL,'2026-03-11 18:12:04'),(12,57,'quiz','quiz',1,'Completed Quiz 1','192.168.1.100',NULL,30,'2026-03-11 18:12:04'),(13,57,'download','material',1,'Downloaded lecture slides','192.168.1.100',NULL,NULL,'2026-03-11 18:12:04'),(14,57,'view','course',2,'Viewed course page','192.168.1.100',NULL,20,'2026-03-11 18:12:04');
/*!40000 ALTER TABLE `activity_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ai_attendance_processing`
--

DROP TABLE IF EXISTS `ai_attendance_processing`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ai_attendance_processing` (
  `processing_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `session_id` bigint unsigned NOT NULL,
  `photo_id` bigint unsigned NOT NULL,
  `status` enum('pending','processing','completed','failed','manual_review') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  `detected_faces_count` int DEFAULT '0',
  `matched_students_count` int DEFAULT '0',
  `unmatched_faces_count` int DEFAULT '0',
  `unmatched_faces_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `confidence_scores` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `processing_time_ms` int DEFAULT NULL,
  `error_message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `manual_review_required` tinyint(1) DEFAULT '0',
  `reviewed_by` bigint unsigned DEFAULT NULL,
  `reviewed_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `completed_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`processing_id`),
  KEY `reviewed_by` (`reviewed_by`),
  KEY `idx_session` (`session_id`),
  KEY `idx_photo` (`photo_id`),
  KEY `idx_status` (`status`),
  CONSTRAINT `ai_attendance_processing_ibfk_1` FOREIGN KEY (`session_id`) REFERENCES `attendance_sessions` (`session_id`) ON DELETE CASCADE,
  CONSTRAINT `ai_attendance_processing_ibfk_2` FOREIGN KEY (`photo_id`) REFERENCES `attendance_photos` (`photo_id`) ON DELETE CASCADE,
  CONSTRAINT `ai_attendance_processing_ibfk_3` FOREIGN KEY (`reviewed_by`) REFERENCES `users` (`user_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ai_attendance_processing`
--

LOCK TABLES `ai_attendance_processing` WRITE;
/*!40000 ALTER TABLE `ai_attendance_processing` DISABLE KEYS */;
/*!40000 ALTER TABLE `ai_attendance_processing` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ai_feedback`
--

DROP TABLE IF EXISTS `ai_feedback`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ai_feedback` (
  `feedback_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `course_id` bigint unsigned NOT NULL,
  `feedback_type` enum('performance','improvement','strength','recommendation') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `feedback_text` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `priority` enum('low','medium','high') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'medium',
  `is_read` tinyint(1) DEFAULT '0',
  `read_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`feedback_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_course` (`course_id`),
  KEY `idx_read` (`is_read`),
  CONSTRAINT `ai_feedback_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `ai_feedback_ibfk_2` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ai_feedback`
--

LOCK TABLES `ai_feedback` WRITE;
/*!40000 ALTER TABLE `ai_feedback` DISABLE KEYS */;
/*!40000 ALTER TABLE `ai_feedback` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ai_flashcards`
--

DROP TABLE IF EXISTS `ai_flashcards`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ai_flashcards` (
  `flashcard_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `material_id` bigint unsigned NOT NULL,
  `user_id` bigint unsigned NOT NULL,
  `front_text` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `back_text` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `category` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `difficulty` enum('easy','medium','hard') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `order_index` int DEFAULT '0',
  `times_reviewed` int DEFAULT '0',
  `last_reviewed_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`flashcard_id`),
  KEY `idx_material` (`material_id`),
  KEY `idx_user` (`user_id`),
  CONSTRAINT `ai_flashcards_ibfk_1` FOREIGN KEY (`material_id`) REFERENCES `course_materials` (`material_id`) ON DELETE CASCADE,
  CONSTRAINT `ai_flashcards_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ai_flashcards`
--

LOCK TABLES `ai_flashcards` WRITE;
/*!40000 ALTER TABLE `ai_flashcards` DISABLE KEYS */;
/*!40000 ALTER TABLE `ai_flashcards` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ai_grading_results`
--

DROP TABLE IF EXISTS `ai_grading_results`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ai_grading_results` (
  `grading_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `submission_id` bigint unsigned DEFAULT NULL,
  `quiz_attempt_id` bigint unsigned DEFAULT NULL,
  `ai_score` decimal(5,2) DEFAULT NULL,
  `max_score` decimal(5,2) DEFAULT NULL,
  `ai_feedback` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `confidence_score` decimal(3,2) DEFAULT NULL,
  `grading_criteria` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `requires_human_review` tinyint(1) DEFAULT '0',
  `human_override_score` decimal(5,2) DEFAULT NULL,
  `processing_time_ms` int DEFAULT NULL,
  `ai_model` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `reviewed_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`grading_id`),
  KEY `idx_submission` (`submission_id`),
  KEY `idx_quiz_attempt` (`quiz_attempt_id`),
  KEY `idx_review` (`requires_human_review`),
  CONSTRAINT `ai_grading_results_ibfk_1` FOREIGN KEY (`submission_id`) REFERENCES `assignment_submissions` (`submission_id`) ON DELETE CASCADE,
  CONSTRAINT `ai_grading_results_ibfk_2` FOREIGN KEY (`quiz_attempt_id`) REFERENCES `quiz_attempts` (`attempt_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ai_grading_results`
--

LOCK TABLES `ai_grading_results` WRITE;
/*!40000 ALTER TABLE `ai_grading_results` DISABLE KEYS */;
/*!40000 ALTER TABLE `ai_grading_results` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ai_quizzes`
--

DROP TABLE IF EXISTS `ai_quizzes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ai_quizzes` (
  `ai_quiz_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `material_id` bigint unsigned NOT NULL,
  `user_id` bigint unsigned NOT NULL,
  `difficulty_id` int unsigned DEFAULT NULL,
  `quiz_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `question_count` int DEFAULT '10',
  `language` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'en',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ai_quiz_id`),
  KEY `difficulty_id` (`difficulty_id`),
  KEY `idx_material` (`material_id`),
  KEY `idx_user` (`user_id`),
  CONSTRAINT `ai_quizzes_ibfk_1` FOREIGN KEY (`material_id`) REFERENCES `course_materials` (`material_id`) ON DELETE CASCADE,
  CONSTRAINT `ai_quizzes_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `ai_quizzes_ibfk_3` FOREIGN KEY (`difficulty_id`) REFERENCES `quiz_difficulty_levels` (`difficulty_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ai_quizzes`
--

LOCK TABLES `ai_quizzes` WRITE;
/*!40000 ALTER TABLE `ai_quizzes` DISABLE KEYS */;
/*!40000 ALTER TABLE `ai_quizzes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ai_recommendations`
--

DROP TABLE IF EXISTS `ai_recommendations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ai_recommendations` (
  `recommendation_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `course_id` bigint unsigned NOT NULL,
  `material_id` bigint unsigned DEFAULT NULL,
  `recommendation_type` enum('topic','material','practice','review') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `reason` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `priority` enum('low','medium','high') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'medium',
  `is_viewed` tinyint(1) DEFAULT '0',
  `is_completed` tinyint(1) DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `viewed_at` timestamp NULL DEFAULT NULL,
  `completed_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`recommendation_id`),
  KEY `material_id` (`material_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_course` (`course_id`),
  KEY `idx_viewed` (`is_viewed`),
  CONSTRAINT `ai_recommendations_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `ai_recommendations_ibfk_2` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`) ON DELETE CASCADE,
  CONSTRAINT `ai_recommendations_ibfk_3` FOREIGN KEY (`material_id`) REFERENCES `course_materials` (`material_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ai_recommendations`
--

LOCK TABLES `ai_recommendations` WRITE;
/*!40000 ALTER TABLE `ai_recommendations` DISABLE KEYS */;
INSERT INTO `ai_recommendations` VALUES (4,9,2,NULL,'review','Linked List Fundamentals','Revisit this topic before the midterm','Important for upcoming exam','high',0,0,'2025-11-20 13:43:00',NULL,NULL);
/*!40000 ALTER TABLE `ai_recommendations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ai_study_plans`
--

DROP TABLE IF EXISTS `ai_study_plans`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ai_study_plans` (
  `plan_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `course_id` bigint unsigned NOT NULL,
  `plan_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `plan_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `total_hours` int DEFAULT NULL,
  `status` enum('active','completed','abandoned') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'active',
  `progress_percentage` decimal(5,2) DEFAULT '0.00',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`plan_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_course` (`course_id`),
  KEY `idx_status` (`status`),
  CONSTRAINT `ai_study_plans_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `ai_study_plans_ibfk_2` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ai_study_plans`
--

LOCK TABLES `ai_study_plans` WRITE;
/*!40000 ALTER TABLE `ai_study_plans` DISABLE KEYS */;
INSERT INTO `ai_study_plans` VALUES (3,12,2,'Data Structures Mastery','{\"weeks\": [{\"week\": 1, \"topics\": [\"Arrays\", \"Linked Lists\"], \"hours\": 7}, {\"week\": 2, \"topics\": [\"Stacks\", \"Queues\"], \"hours\": 7}]}','2025-02-18','2025-04-01',28,'active',20.00,'2025-11-20 13:43:00','2025-11-20 13:43:00');
/*!40000 ALTER TABLE `ai_study_plans` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ai_summaries`
--

DROP TABLE IF EXISTS `ai_summaries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ai_summaries` (
  `summary_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `material_id` bigint unsigned NOT NULL,
  `user_id` bigint unsigned NOT NULL,
  `summary_text` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `summary_type` enum('short','medium','detailed') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'medium',
  `language` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'en',
  `word_count` int DEFAULT NULL,
  `processing_time_ms` int DEFAULT NULL,
  `ai_model` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`summary_id`),
  KEY `idx_material` (`material_id`),
  KEY `idx_user` (`user_id`),
  CONSTRAINT `ai_summaries_ibfk_1` FOREIGN KEY (`material_id`) REFERENCES `course_materials` (`material_id`) ON DELETE CASCADE,
  CONSTRAINT `ai_summaries_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ai_summaries`
--

LOCK TABLES `ai_summaries` WRITE;
/*!40000 ALTER TABLE `ai_summaries` DISABLE KEYS */;
/*!40000 ALTER TABLE `ai_summaries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ai_usage_statistics`
--

DROP TABLE IF EXISTS `ai_usage_statistics`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ai_usage_statistics` (
  `stat_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `feature_type` enum('summary','flashcard','quiz','feedback','chatbot','grading','recommendation','study_plan','voice','ocr','attendance') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `feature_id` bigint unsigned DEFAULT NULL,
  `usage_count` int DEFAULT '1',
  `tokens_used` int DEFAULT NULL,
  `processing_time_ms` int DEFAULT NULL,
  `cost_estimate` decimal(10,6) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`stat_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_feature` (`feature_type`),
  KEY `idx_date` (`created_at`),
  CONSTRAINT `ai_usage_statistics_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ai_usage_statistics`
--

LOCK TABLES `ai_usage_statistics` WRITE;
/*!40000 ALTER TABLE `ai_usage_statistics` DISABLE KEYS */;
INSERT INTO `ai_usage_statistics` VALUES (1,7,'summary',1,1,450,1250,0.000225,'2025-11-20 13:43:00'),(2,7,'flashcard',2,1,380,890,0.000190,'2025-11-20 13:43:00'),(3,7,'quiz',1,1,520,1450,0.000260,'2025-11-20 13:43:00'),(4,8,'summary',3,1,290,650,0.000145,'2025-11-20 13:43:00'),(5,8,'chatbot',1,4,1850,5200,0.000925,'2025-11-20 13:43:00'),(6,9,'recommendation',1,1,180,420,0.000090,'2025-11-20 13:43:00'),(7,10,'grading',1,1,680,1850,0.000340,'2025-11-20 13:43:00'),(8,11,'attendance',2,1,920,2100,0.000460,'2025-11-20 13:43:00'),(9,12,'study_plan',1,1,1200,3400,0.000600,'2025-11-20 13:43:00');
/*!40000 ALTER TABLE `ai_usage_statistics` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `announcements`
--

DROP TABLE IF EXISTS `announcements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `announcements` (
  `announcement_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `course_id` bigint unsigned DEFAULT NULL,
  `created_by` bigint unsigned NOT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `announcement_type` enum('course','department','campus','system') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'course',
  `priority` enum('low','medium','high','urgent') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'medium',
  `target_audience` enum('all','students','instructors','tas','custom') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'all',
  `is_published` tinyint(1) DEFAULT '0',
  `published_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `attachment_file_id` bigint unsigned DEFAULT NULL,
  `view_count` int DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`announcement_id`),
  KEY `attachment_file_id` (`attachment_file_id`),
  KEY `idx_course` (`course_id`),
  KEY `idx_creator` (`created_by`),
  KEY `idx_published` (`is_published`),
  CONSTRAINT `announcements_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`) ON DELETE CASCADE,
  CONSTRAINT `announcements_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `announcements_ibfk_3` FOREIGN KEY (`attachment_file_id`) REFERENCES `files` (`file_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `announcements`
--

LOCK TABLES `announcements` WRITE;
/*!40000 ALTER TABLE `announcements` DISABLE KEYS */;
INSERT INTO `announcements` VALUES (1,1,8,'Updated: Welcome to CS101!','Updated announcement content.','course','medium','all',1,'2026-03-16 22:31:28',NULL,NULL,99,'2025-01-15 08:00:00','2026-03-16 22:31:27'),(2,1,8,'Assignment 1 Released','The first assignment is now available in the course materials section. Due date: February 1st.','course','high','students',1,'2025-01-20 09:00:00',NULL,NULL,38,'2025-01-20 09:00:00','2025-01-20 09:00:00'),(3,NULL,1,'Campus WiFi Maintenance','Network maintenance scheduled for this weekend. Expect brief outages.','campus','medium','all',1,'2025-02-10 06:00:00',NULL,NULL,0,'2025-11-20 13:43:00','2025-11-20 13:43:00'),(4,2,3,'Midterm Exam Schedule','The midterm exam will be held on March 15, 2025 from 2:00 PM to 4:00 PM.','course','high','students',1,'2025-02-12 10:00:00',NULL,NULL,0,'2025-11-20 13:43:00','2025-11-20 13:43:00'),(5,1,8,'Office Hours Extended','Extended office hours this week: Monday 2-4 PM, Wednesday 1-3 PM. Location: Room 301A.','course','medium','students',1,'2025-02-13 08:00:00',NULL,NULL,23,'2025-02-13 08:00:00','2025-02-13 08:00:00'),(7,1,59,'API Dog Test Announcement','This is a test announcement from API Dog.','course','medium','all',0,NULL,NULL,NULL,0,'2026-03-11 17:20:02','2026-03-11 17:20:02'),(8,1,59,'API Dog Test Announcement','This is a test announcement from API Dog.','course','medium','all',0,NULL,NULL,NULL,0,'2026-03-11 17:37:48','2026-03-11 17:37:48'),(9,1,59,'API Dog Test Announcement','This is a test announcement from API Dog.','course','medium','all',0,NULL,NULL,NULL,0,'2026-03-14 15:17:44','2026-03-14 15:17:44'),(10,1,59,'API Dog Test Announcement','This is a test announcement from API Dog.','course','medium','all',0,NULL,NULL,NULL,0,'2026-03-14 15:36:01','2026-03-14 15:36:01'),(11,1,59,'API Dog Test Announcement','This is a test announcement from API Dog.','course','medium','all',0,NULL,NULL,NULL,0,'2026-03-14 15:40:41','2026-03-14 15:40:41'),(12,1,59,'API Dog Test Announcement','This is a test announcement from API Dog.','course','medium','all',0,NULL,NULL,NULL,0,'2026-03-14 16:06:04','2026-03-14 16:06:04'),(13,1,59,'API Dog Test Announcement','This is a test announcement from API Dog.','course','medium','all',0,NULL,NULL,NULL,0,'2026-03-16 20:19:02','2026-03-16 20:19:02'),(14,1,59,'API Dog Test Announcement','This is a test announcement from API Dog.','course','medium','all',0,NULL,NULL,NULL,0,'2026-03-16 20:20:08','2026-03-16 20:20:08'),(15,1,59,'API Dog Test Announcement','This is a test announcement from API Dog.','course','medium','all',0,NULL,NULL,NULL,0,'2026-03-16 20:32:49','2026-03-16 20:32:49'),(16,1,59,'API Dog Test Announcement','This is a test announcement from API Dog.','course','medium','all',0,NULL,NULL,NULL,0,'2026-03-16 20:45:15','2026-03-16 20:45:15'),(17,1,59,'API Dog Test Announcement','This is a test announcement from API Dog.','course','medium','all',0,NULL,NULL,NULL,0,'2026-03-16 20:53:51','2026-03-16 20:53:51'),(18,1,59,'API Dog Test Announcement','This is a test announcement from API Dog.','course','medium','all',0,NULL,NULL,NULL,0,'2026-03-16 22:31:27','2026-03-16 22:31:27');
/*!40000 ALTER TABLE `announcements` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `api_integrations`
--

DROP TABLE IF EXISTS `api_integrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `api_integrations` (
  `integration_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `campus_id` bigint unsigned NOT NULL,
  `integration_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `integration_type` enum('lms','sso','payment','email','sms','ai','storage','other') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `api_endpoint` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `api_key_encrypted` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `api_secret_encrypted` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `configuration` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `is_active` tinyint(1) DEFAULT '1',
  `health_status` enum('healthy','degraded','down') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'healthy',
  `last_sync_at` timestamp NULL DEFAULT NULL,
  `created_by` bigint unsigned DEFAULT NULL,
  `updated_by` bigint unsigned DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`integration_id`),
  KEY `idx_campus` (`campus_id`),
  KEY `idx_type` (`integration_type`),
  KEY `api_integrations_ibfk_created_by` (`created_by`),
  KEY `api_integrations_ibfk_updated_by` (`updated_by`),
  CONSTRAINT `api_integrations_ibfk_1` FOREIGN KEY (`campus_id`) REFERENCES `campuses` (`campus_id`) ON DELETE CASCADE,
  CONSTRAINT `api_integrations_ibfk_created_by` FOREIGN KEY (`created_by`) REFERENCES `users` (`user_id`) ON DELETE SET NULL,
  CONSTRAINT `api_integrations_ibfk_updated_by` FOREIGN KEY (`updated_by`) REFERENCES `users` (`user_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `api_integrations`
--

LOCK TABLES `api_integrations` WRITE;
/*!40000 ALTER TABLE `api_integrations` DISABLE KEYS */;
INSERT INTO `api_integrations` VALUES (2,1,'SendGrid Email','email','https://api.sendgrid.com/v3/mail/send',NULL,NULL,NULL,1,'healthy','2026-03-16 21:00:29',NULL,NULL,'2025-11-20 13:43:00','2026-03-16 21:00:29'),(3,1,'AWS S3 Storage','storage','https://s3.amazonaws.com',NULL,NULL,NULL,1,'healthy','2025-02-15 05:30:00',NULL,NULL,'2025-11-20 13:43:00','2025-11-20 13:43:00'),(4,1,'OpenAI API','ai','https://api.openai.com/v1',NULL,NULL,NULL,1,'healthy','2025-02-15 07:00:00',NULL,NULL,'2025-11-20 13:43:00','2025-11-20 13:43:00'),(5,2,'Stripe Payment','payment','https://api.stripe.com/v1',NULL,NULL,NULL,1,'healthy','2025-02-14 13:00:00',NULL,NULL,'2025-11-20 13:43:00','2025-11-20 13:43:00'),(6,1,'Canvas LMS','lms','https://canvas.example.com','s3cr3t','s3cr3t2','{}',1,'healthy',NULL,67,67,'2026-03-16 20:59:23','2026-03-16 20:59:23');
/*!40000 ALTER TABLE `api_integrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `api_rate_limits`
--

DROP TABLE IF EXISTS `api_rate_limits`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `api_rate_limits` (
  `limit_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned DEFAULT NULL,
  `api_key` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `endpoint` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `request_count` int DEFAULT '0',
  `window_start` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `window_end` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `max_requests` int DEFAULT '1000',
  `window_seconds` int DEFAULT '60',
  `is_blocked` tinyint(1) DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`limit_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_api_key` (`api_key`),
  KEY `idx_endpoint` (`endpoint`),
  KEY `idx_window` (`window_start`,`window_end`),
  CONSTRAINT `api_rate_limits_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `api_rate_limits`
--

LOCK TABLES `api_rate_limits` WRITE;
/*!40000 ALTER TABLE `api_rate_limits` DISABLE KEYS */;
INSERT INTO `api_rate_limits` VALUES (1,7,NULL,'/api/v1/courses',45,'2025-02-15 08:00:00','2025-02-15 09:00:00',1000,60,0,'2025-11-20 13:43:01','2025-11-20 13:43:01'),(2,8,NULL,'/api/v1/assignments',23,'2025-02-15 08:00:00','2025-02-15 09:00:00',1000,60,0,'2025-11-20 13:43:01','2025-11-20 13:43:01'),(3,NULL,'api_key_external_123','/api/v1/users',850,'2025-02-15 08:00:00','2025-02-15 09:00:00',1000,60,0,'2025-11-20 13:43:01','2025-11-20 13:43:01'),(4,NULL,'api_key_external_456','/api/v1/grades',1005,'2025-02-15 07:00:00','2025-02-15 08:00:00',1000,60,1,'2025-11-20 13:43:01','2025-11-20 13:43:01');
/*!40000 ALTER TABLE `api_rate_limits` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `assignment_submissions`
--

DROP TABLE IF EXISTS `assignment_submissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `assignment_submissions` (
  `submission_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `assignment_id` bigint unsigned NOT NULL,
  `user_id` bigint unsigned NOT NULL,
  `file_id` bigint unsigned DEFAULT NULL,
  `submission_text` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `submission_link` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `submitted_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `is_late` tinyint(1) DEFAULT '0',
  `attempt_number` int DEFAULT '1',
  `status` enum('submitted','graded','returned','resubmit') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'submitted',
  PRIMARY KEY (`submission_id`),
  KEY `file_id` (`file_id`),
  KEY `idx_assignment` (`assignment_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_status` (`status`),
  KEY `idx_user_assignment` (`user_id`,`assignment_id`),
  KEY `idx_assignment_status` (`assignment_id`,`status`),
  KEY `idx_submitted_date` (`submitted_at`),
  CONSTRAINT `assignment_submissions_ibfk_1` FOREIGN KEY (`assignment_id`) REFERENCES `assignments` (`assignment_id`) ON DELETE CASCADE,
  CONSTRAINT `assignment_submissions_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `assignment_submissions_ibfk_3` FOREIGN KEY (`file_id`) REFERENCES `files` (`file_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `assignment_submissions`
--

LOCK TABLES `assignment_submissions` WRITE;
/*!40000 ALTER TABLE `assignment_submissions` DISABLE KEYS */;
INSERT INTO `assignment_submissions` VALUES (16,1,21,NULL,'Submitted assignment 1 - programming basics',NULL,'2025-01-31 15:30:00',0,1,'graded'),(17,1,22,NULL,'Submitted assignment 1 - programming basics',NULL,'2025-01-31 16:00:00',0,1,'graded'),(18,1,23,NULL,'Submitted assignment 1 - programming basics',NULL,'2025-01-29 12:00:00',0,1,'graded'),(19,1,24,NULL,'Submitted assignment 1 - programming basics',NULL,'2025-02-01 23:50:00',0,1,'graded'),(20,1,25,NULL,'Submitted assignment 1 - programming basics',NULL,'2025-01-30 18:00:00',0,1,'graded'),(21,2,23,NULL,'Submitted assignment 2 - functions and modules',NULL,'2025-02-14 10:30:00',0,1,'submitted'),(22,2,25,NULL,'Submitted assignment 2 - functions and modules',NULL,'2025-02-13 14:00:00',0,1,'submitted'),(23,4,21,NULL,'Submitted project 1 - data structures implementation',NULL,'2025-02-18 17:00:00',0,1,'submitted'),(24,4,23,NULL,'Submitted project 1 - data structures implementation',NULL,'2025-02-19 12:00:00',0,1,'submitted'),(25,4,25,NULL,'Submitted project 1 - data structures implementation',NULL,'2025-02-17 09:00:00',0,1,'submitted');
/*!40000 ALTER TABLE `assignment_submissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `assignments`
--

DROP TABLE IF EXISTS `assignments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `assignments` (
  `assignment_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `course_id` bigint unsigned NOT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `instructions` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `max_score` decimal(5,2) DEFAULT '100.00',
  `weight` decimal(5,2) DEFAULT '0.00',
  `due_date` timestamp NULL DEFAULT NULL,
  `available_from` timestamp NULL DEFAULT NULL,
  `late_submission_allowed` tinyint(1) DEFAULT '0',
  `late_penalty_percent` decimal(5,2) DEFAULT '0.00',
  `submission_type` enum('file','text','link','multiple') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'file',
  `max_file_size_mb` int DEFAULT '10',
  `allowed_file_types` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `status` enum('draft','published','closed','archived') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'draft',
  `created_by` bigint unsigned NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`assignment_id`),
  KEY `created_by` (`created_by`),
  KEY `idx_course` (`course_id`),
  KEY `idx_due_date` (`due_date`),
  CONSTRAINT `assignments_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`) ON DELETE CASCADE,
  CONSTRAINT `assignments_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `assignments`
--

LOCK TABLES `assignments` WRITE;
/*!40000 ALTER TABLE `assignments` DISABLE KEYS */;
INSERT INTO `assignments` VALUES (1,1,'Updated Assignment Title','Write a program that demonstrates basic programming concepts','Create a complete program with proper comments and documentation',100.00,0.00,'2025-02-01 23:59:59','2025-01-20 08:00:00',1,0.00,'file',10,NULL,'draft',8,'2025-01-20 08:00:00','2026-03-11 17:20:03',NULL),(2,1,'Assignment 2: Functions and Modules','Implement functions and modules for a simple application','Submit your code with test cases',100.00,0.00,'2025-02-15 23:59:59','2025-01-27 08:00:00',1,0.00,'file',10,NULL,'draft',8,'2025-01-27 08:00:00','2025-01-27 08:00:00',NULL),(3,1,'Updated Assignment Title','string','string',150.00,100.00,'2026-03-01 21:08:59','2026-02-01 21:08:59',0,0.00,'file',10,'[\"pdf\",\"docx\",\"zip\"]','published',3,'2025-11-20 13:42:59','2026-03-05 19:16:23',NULL),(4,3,'Assignment 1: SQL Queries','Database query practice','Write SQL queries for the given scenarios',100.00,15.00,'2025-03-05 21:59:59','2025-02-14 22:00:00',0,0.00,'text',10,NULL,'draft',3,'2025-11-20 13:42:59','2025-11-20 13:42:59',NULL),(5,3,'Midterm Quiz','Comprehensive quiz covering weeks 1-6','Answer all questions to the best of your ability',50.00,0.00,'2025-03-01 23:59:59','2025-02-01 08:00:00',0,0.00,'text',10,NULL,'draft',10,'2025-02-01 08:00:00','2025-02-01 08:00:00',NULL),(6,5,'Lab Assignment 1: OOP Design','Design and implement OOP concepts in a project','Implement the provided specification',120.00,0.00,'2025-02-10 23:59:59','2025-01-25 08:00:00',1,0.00,'file',10,NULL,'draft',12,'2025-01-25 08:00:00','2025-01-25 08:00:00',NULL),(7,6,'Assignment 1: SQL Queries','Write SQL queries to retrieve and manipulate data','Write queries following best practices',100.00,0.00,'2025-02-05 23:59:59','2025-01-28 08:00:00',1,0.00,'file',10,NULL,'draft',14,'2025-01-28 08:00:00','2025-01-28 08:00:00',NULL),(8,7,'Project: Web Application','Build a complete web application using modern frameworks','Follow the project specification document',200.00,0.00,'2025-03-15 23:59:59','2025-02-01 08:00:00',1,0.00,'file',10,NULL,'draft',15,'2025-02-01 08:00:00','2025-02-01 08:00:00',NULL),(9,9,'Problem Set 1: Statistical Analysis','Solve statistical problems using real datasets','Show all work and calculations',100.00,0.00,'2025-02-08 23:59:59','2025-01-30 08:00:00',1,0.00,'file',10,NULL,'draft',16,'2025-01-30 08:00:00','2025-01-30 08:00:00',NULL),(10,10,'Essay: Literary Analysis','Write a comprehensive literary analysis essay','Submit as PDF with proper formatting',100.00,0.00,'2025-02-12 23:59:59','2025-01-31 08:00:00',1,0.00,'file',10,NULL,'draft',17,'2025-01-31 08:00:00','2025-01-31 08:00:00',NULL),(11,1,'Homework 1','string','string',100.00,100.00,'2026-03-01 21:08:59','2026-03-02 21:08:59',0,0.00,'file',10,'[\"pdf\",\"docx\",\"zip\"]','draft',56,'2026-03-01 21:09:28','2026-03-01 21:09:28',NULL),(12,1,'Test Assignment','A test','Do this',100.00,10.00,'2026-06-01 23:59:59',NULL,0,0.00,'file',10,NULL,'draft',58,'2026-03-02 13:31:32','2026-03-02 13:31:32',NULL),(13,1,'AutoAssign','Test','Do',100.00,10.00,'2026-12-01 23:59:59',NULL,0,0.00,'file',10,NULL,'draft',58,'2026-03-02 13:50:32','2026-03-02 13:50:32',NULL),(14,1,'Bad','x',NULL,100.00,0.00,NULL,NULL,0,0.00,'file',10,NULL,'draft',57,'2026-03-02 13:50:33','2026-03-02 13:50:33',NULL),(15,1,'Postman Test Assignment','An assignment created from Postman','Complete the tasks listed below',100.00,15.00,'2026-06-15 23:59:59','2026-06-01 00:00:00',1,10.00,'file',10,'[\"pdf\",\"docx\",\"zip\"]','published',58,'2026-03-02 23:31:42','2026-03-02 23:31:42',NULL),(16,1,'Postman Test Assignment','An assignment created from Postman','Complete the tasks listed below',100.00,15.00,'2026-06-15 23:59:59','2026-06-01 00:00:00',1,10.00,'file',10,'[\"pdf\",\"docx\",\"zip\"]','published',58,'2026-03-02 23:51:56','2026-03-02 23:51:56',NULL),(17,1,'Postman Test Assignment','An assignment created from Postman','Complete the tasks listed below',100.00,15.00,'2026-06-15 23:59:59','2026-06-01 00:00:00',1,10.00,'file',10,'[\"pdf\",\"docx\",\"zip\"]','published',58,'2026-03-03 00:23:17','2026-03-03 00:23:17',NULL),(18,1,'Postman Test Assignment','An assignment created from Postman','Complete the tasks listed below',100.00,15.00,'2026-06-15 23:59:59','2026-06-01 00:00:00',1,10.00,'file',10,'[\"pdf\",\"docx\",\"zip\"]','published',58,'2026-03-03 18:34:02','2026-03-03 18:34:02',NULL),(19,1,'Postman Test Assignment','An assignment created from Postman','Complete the tasks listed below',100.00,15.00,'2026-06-15 23:59:59','2026-06-01 00:00:00',1,10.00,'file',10,'[\"pdf\",\"docx\",\"zip\"]','published',58,'2026-03-05 19:16:23','2026-03-05 19:16:23',NULL),(20,1,'API Dog Test Assignment','Test assignment from API Dog',NULL,100.00,0.00,NULL,NULL,0,0.00,'file',10,NULL,'draft',59,'2026-03-11 17:37:49','2026-03-11 17:37:49',NULL),(21,1,'API Dog Test Assignment','Test assignment from API Dog',NULL,100.00,0.00,NULL,NULL,0,0.00,'file',10,NULL,'draft',59,'2026-03-14 15:36:02','2026-03-14 15:36:02',NULL),(22,1,'API Dog Test Assignment','Test assignment from API Dog',NULL,100.00,0.00,NULL,NULL,0,0.00,'file',10,NULL,'draft',59,'2026-03-14 15:40:42','2026-03-14 15:40:42',NULL),(23,1,'API Dog Test Assignment','Test assignment from API Dog',NULL,100.00,0.00,NULL,NULL,0,0.00,'file',10,NULL,'draft',59,'2026-03-14 16:06:04','2026-03-14 16:06:04',NULL),(24,1,'API Dog Test Assignment','Test assignment from API Dog',NULL,100.00,0.00,NULL,NULL,0,0.00,'file',10,NULL,'draft',59,'2026-03-16 20:19:03','2026-03-16 20:19:03',NULL),(25,1,'API Dog Test Assignment','Test assignment from API Dog',NULL,100.00,0.00,NULL,NULL,0,0.00,'file',10,NULL,'draft',59,'2026-03-16 20:20:08','2026-03-16 20:20:08',NULL),(26,1,'API Dog Test Assignment','Test assignment from API Dog',NULL,100.00,0.00,NULL,NULL,0,0.00,'file',10,NULL,'draft',59,'2026-03-16 20:32:50','2026-03-16 20:32:50',NULL),(27,1,'API Dog Test Assignment','Test assignment from API Dog',NULL,100.00,0.00,NULL,NULL,0,0.00,'file',10,NULL,'draft',59,'2026-03-16 20:45:15','2026-03-16 20:45:15',NULL),(28,1,'API Dog Test Assignment','Test assignment from API Dog',NULL,100.00,0.00,NULL,NULL,0,0.00,'file',10,NULL,'draft',59,'2026-03-16 20:53:51','2026-03-16 20:53:51',NULL),(29,1,'API Dog Test Assignment','Test assignment from API Dog',NULL,100.00,0.00,NULL,NULL,0,0.00,'file',10,NULL,'draft',59,'2026-03-16 22:31:28','2026-03-16 22:31:28',NULL);
/*!40000 ALTER TABLE `assignments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `attendance_photos`
--

DROP TABLE IF EXISTS `attendance_photos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `attendance_photos` (
  `photo_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `session_id` bigint unsigned NOT NULL,
  `file_id` bigint unsigned NOT NULL,
  `uploaded_by` bigint unsigned NOT NULL,
  `photo_type` enum('class_photo','individual','video_frame') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'class_photo',
  `capture_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `processing_status` enum('pending','processing','completed','failed') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  PRIMARY KEY (`photo_id`),
  KEY `file_id` (`file_id`),
  KEY `uploaded_by` (`uploaded_by`),
  KEY `idx_session` (`session_id`),
  KEY `idx_status` (`processing_status`),
  CONSTRAINT `attendance_photos_ibfk_1` FOREIGN KEY (`session_id`) REFERENCES `attendance_sessions` (`session_id`) ON DELETE CASCADE,
  CONSTRAINT `attendance_photos_ibfk_2` FOREIGN KEY (`file_id`) REFERENCES `files` (`file_id`) ON DELETE CASCADE,
  CONSTRAINT `attendance_photos_ibfk_3` FOREIGN KEY (`uploaded_by`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `attendance_photos`
--

LOCK TABLES `attendance_photos` WRITE;
/*!40000 ALTER TABLE `attendance_photos` DISABLE KEYS */;
/*!40000 ALTER TABLE `attendance_photos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `attendance_records`
--

DROP TABLE IF EXISTS `attendance_records`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `attendance_records` (
  `record_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `session_id` bigint unsigned NOT NULL,
  `user_id` bigint unsigned NOT NULL,
  `attendance_status` enum('present','absent','late','excused') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'absent',
  `check_in_time` timestamp NULL DEFAULT NULL,
  `marked_by` enum('manual','ai','self') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'manual',
  `confidence_score` decimal(5,4) DEFAULT NULL,
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`record_id`),
  UNIQUE KEY `unique_session_user` (`session_id`,`user_id`),
  KEY `idx_session` (`session_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_status` (`attendance_status`),
  KEY `idx_session_status` (`session_id`,`attendance_status`),
  KEY `idx_user_date` (`user_id`,`check_in_time`),
  CONSTRAINT `attendance_records_ibfk_1` FOREIGN KEY (`session_id`) REFERENCES `attendance_sessions` (`session_id`) ON DELETE CASCADE,
  CONSTRAINT `attendance_records_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=355 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `attendance_records`
--

LOCK TABLES `attendance_records` WRITE;
/*!40000 ALTER TABLE `attendance_records` DISABLE KEYS */;
INSERT INTO `attendance_records` VALUES (1,1,21,'present','2025-02-03 08:58:00','manual',NULL,NULL,'2026-03-01 14:55:40'),(2,1,22,'present','2025-02-03 09:02:00','manual',NULL,NULL,'2026-03-01 14:55:40'),(3,1,23,'present','2025-02-03 09:00:00','manual',NULL,NULL,'2026-03-01 14:55:40'),(4,1,24,'absent',NULL,'manual',NULL,NULL,'2026-03-01 14:55:40'),(5,1,25,'present','2025-02-03 09:05:00','manual',NULL,NULL,'2026-03-01 14:55:40'),(6,2,21,'present','2025-02-05 09:00:00','manual',NULL,NULL,'2026-03-01 14:55:40'),(7,2,22,'present','2025-02-05 09:03:00','manual',NULL,NULL,'2026-03-01 14:55:40'),(8,2,23,'present','2025-02-05 09:00:00','manual',NULL,NULL,'2026-03-01 14:55:40'),(9,2,24,'late','2025-02-05 09:15:00','manual',NULL,NULL,'2026-03-01 14:55:40'),(10,2,25,'present','2025-02-05 08:58:00','manual',NULL,NULL,'2026-03-01 14:55:40'),(17,11,7,'absent',NULL,'manual',NULL,NULL,'2026-03-02 14:05:42'),(18,11,8,'absent',NULL,'manual',NULL,NULL,'2026-03-02 14:05:42'),(19,11,9,'absent',NULL,'manual',NULL,NULL,'2026-03-02 14:05:42'),(20,11,10,'absent',NULL,'manual',NULL,NULL,'2026-03-02 14:05:42'),(21,11,11,'absent',NULL,'manual',NULL,NULL,'2026-03-02 14:05:42'),(22,11,25,'absent',NULL,'manual',NULL,NULL,'2026-03-02 14:05:42'),(23,11,30,'absent',NULL,'manual',NULL,NULL,'2026-03-02 14:05:42'),(24,11,34,'absent',NULL,'manual',NULL,NULL,'2026-03-02 14:05:42'),(25,11,13,'absent',NULL,'manual',NULL,NULL,'2026-03-02 14:05:42'),(26,11,14,'absent',NULL,'manual',NULL,NULL,'2026-03-02 14:05:42'),(27,11,15,'absent',NULL,'manual',NULL,NULL,'2026-03-02 14:05:42'),(28,11,16,'absent',NULL,'manual',NULL,NULL,'2026-03-02 14:05:42'),(29,11,21,'absent',NULL,'manual',NULL,NULL,'2026-03-02 14:05:42'),(30,11,22,'absent',NULL,'manual',NULL,NULL,'2026-03-02 14:05:42'),(31,11,23,'absent',NULL,'manual',NULL,NULL,'2026-03-02 14:05:42'),(32,11,24,'absent',NULL,'manual',NULL,NULL,'2026-03-02 14:05:42'),(33,11,26,'absent',NULL,'manual',NULL,NULL,'2026-03-02 14:05:42'),(34,11,27,'absent',NULL,'manual',NULL,NULL,'2026-03-02 14:05:42'),(35,11,28,'absent',NULL,'manual',NULL,NULL,'2026-03-02 14:05:42'),(36,11,29,'absent',NULL,'manual',NULL,NULL,'2026-03-02 14:05:42'),(37,12,7,'absent',NULL,'manual',NULL,NULL,'2026-03-02 14:06:47'),(38,12,8,'absent',NULL,'manual',NULL,NULL,'2026-03-02 14:06:47'),(39,12,9,'absent',NULL,'manual',NULL,NULL,'2026-03-02 14:06:47'),(40,12,10,'absent',NULL,'manual',NULL,NULL,'2026-03-02 14:06:47'),(41,12,11,'absent',NULL,'manual',NULL,NULL,'2026-03-02 14:06:47'),(42,12,25,'absent',NULL,'manual',NULL,NULL,'2026-03-02 14:06:47'),(43,12,30,'absent',NULL,'manual',NULL,NULL,'2026-03-02 14:06:47'),(44,12,34,'absent',NULL,'manual',NULL,NULL,'2026-03-02 14:06:47'),(45,12,13,'absent',NULL,'manual',NULL,NULL,'2026-03-02 14:06:47'),(46,12,14,'absent',NULL,'manual',NULL,NULL,'2026-03-02 14:06:47'),(47,12,15,'absent',NULL,'manual',NULL,NULL,'2026-03-02 14:06:47'),(48,12,16,'absent',NULL,'manual',NULL,NULL,'2026-03-02 14:06:47'),(49,12,21,'absent',NULL,'manual',NULL,NULL,'2026-03-02 14:06:47'),(50,12,22,'absent',NULL,'manual',NULL,NULL,'2026-03-02 14:06:47'),(51,12,23,'absent',NULL,'manual',NULL,NULL,'2026-03-02 14:06:47'),(52,12,24,'absent',NULL,'manual',NULL,NULL,'2026-03-02 14:06:47'),(53,12,26,'absent',NULL,'manual',NULL,NULL,'2026-03-02 14:06:47'),(54,12,27,'absent',NULL,'manual',NULL,NULL,'2026-03-02 14:06:47'),(55,12,28,'absent',NULL,'manual',NULL,NULL,'2026-03-02 14:06:47'),(56,12,29,'absent',NULL,'manual',NULL,NULL,'2026-03-02 14:06:47'),(57,13,7,'absent',NULL,'manual',NULL,NULL,'2026-03-02 14:06:53'),(58,13,8,'absent',NULL,'manual',NULL,NULL,'2026-03-02 14:06:53'),(59,13,9,'absent',NULL,'manual',NULL,NULL,'2026-03-02 14:06:53'),(60,13,10,'absent',NULL,'manual',NULL,NULL,'2026-03-02 14:06:53'),(61,13,11,'absent',NULL,'manual',NULL,NULL,'2026-03-02 14:06:53'),(62,13,25,'absent',NULL,'manual',NULL,NULL,'2026-03-02 14:06:53'),(63,13,30,'absent',NULL,'manual',NULL,NULL,'2026-03-02 14:06:53'),(64,13,34,'absent',NULL,'manual',NULL,NULL,'2026-03-02 14:06:53'),(65,13,13,'absent',NULL,'manual',NULL,NULL,'2026-03-02 14:06:53'),(66,13,14,'absent',NULL,'manual',NULL,NULL,'2026-03-02 14:06:53'),(67,13,15,'absent',NULL,'manual',NULL,NULL,'2026-03-02 14:06:53'),(68,13,16,'absent',NULL,'manual',NULL,NULL,'2026-03-02 14:06:53'),(69,13,21,'absent',NULL,'manual',NULL,NULL,'2026-03-02 14:06:53'),(70,13,22,'absent',NULL,'manual',NULL,NULL,'2026-03-02 14:06:53'),(71,13,23,'absent',NULL,'manual',NULL,NULL,'2026-03-02 14:06:53'),(72,13,24,'absent',NULL,'manual',NULL,NULL,'2026-03-02 14:06:53'),(73,13,26,'absent',NULL,'manual',NULL,NULL,'2026-03-02 14:06:53'),(74,13,27,'absent',NULL,'manual',NULL,NULL,'2026-03-02 14:06:53'),(75,13,28,'absent',NULL,'manual',NULL,NULL,'2026-03-02 14:06:53'),(76,13,29,'absent',NULL,'manual',NULL,NULL,'2026-03-02 14:06:53'),(77,14,7,'late',NULL,'manual',NULL,'Came in late','2026-03-02 14:08:07'),(78,14,8,'absent',NULL,'manual',NULL,NULL,'2026-03-02 14:07:07'),(79,14,9,'absent',NULL,'manual',NULL,NULL,'2026-03-02 14:07:07'),(80,14,10,'absent',NULL,'manual',NULL,NULL,'2026-03-02 14:07:07'),(81,14,11,'absent',NULL,'manual',NULL,NULL,'2026-03-02 14:07:07'),(82,14,25,'absent',NULL,'manual',NULL,NULL,'2026-03-02 14:07:07'),(83,14,30,'absent',NULL,'manual',NULL,NULL,'2026-03-02 14:07:07'),(84,14,34,'absent',NULL,'manual',NULL,NULL,'2026-03-02 14:07:07'),(85,14,13,'absent',NULL,'manual',NULL,NULL,'2026-03-02 14:07:07'),(86,14,14,'absent',NULL,'manual',NULL,NULL,'2026-03-02 14:07:07'),(87,14,15,'absent',NULL,'manual',NULL,NULL,'2026-03-02 14:07:07'),(88,14,16,'absent',NULL,'manual',NULL,NULL,'2026-03-02 14:07:07'),(89,14,21,'absent',NULL,'manual',NULL,NULL,'2026-03-02 14:07:07'),(90,14,22,'absent',NULL,'manual',NULL,NULL,'2026-03-02 14:07:07'),(91,14,23,'absent',NULL,'manual',NULL,NULL,'2026-03-02 14:07:07'),(92,14,24,'absent',NULL,'manual',NULL,NULL,'2026-03-02 14:07:07'),(93,14,26,'absent',NULL,'manual',NULL,NULL,'2026-03-02 14:07:07'),(94,14,27,'absent',NULL,'manual',NULL,NULL,'2026-03-02 14:07:07'),(95,14,28,'absent',NULL,'manual',NULL,NULL,'2026-03-02 14:07:07'),(96,14,29,'absent',NULL,'manual',NULL,NULL,'2026-03-02 14:07:07'),(97,14,57,'present',NULL,'manual',NULL,NULL,'2026-03-02 14:08:05'),(118,17,57,'late',NULL,'manual',NULL,'Arrived 10 min late','2026-03-02 23:42:38'),(119,17,58,'present',NULL,'manual',NULL,NULL,'2026-03-02 23:42:38'),(120,17,59,'absent',NULL,'manual',NULL,'No show','2026-03-02 23:42:38'),(121,18,57,'late',NULL,'manual',NULL,'Arrived 10 min late','2026-03-02 23:47:21'),(122,18,58,'present',NULL,'manual',NULL,NULL,'2026-03-02 23:47:21'),(123,18,59,'absent',NULL,'manual',NULL,'No show','2026-03-02 23:47:21'),(124,23,7,'absent',NULL,'manual',NULL,NULL,'2026-03-11 17:20:09'),(125,23,8,'absent',NULL,'manual',NULL,NULL,'2026-03-11 17:20:09'),(126,23,9,'absent',NULL,'manual',NULL,NULL,'2026-03-11 17:20:09'),(127,23,10,'absent',NULL,'manual',NULL,NULL,'2026-03-11 17:20:09'),(128,23,11,'absent',NULL,'manual',NULL,NULL,'2026-03-11 17:20:09'),(129,23,25,'absent',NULL,'manual',NULL,NULL,'2026-03-11 17:20:09'),(130,23,30,'absent',NULL,'manual',NULL,NULL,'2026-03-11 17:20:09'),(131,23,34,'absent',NULL,'manual',NULL,NULL,'2026-03-11 17:20:09'),(132,23,13,'absent',NULL,'manual',NULL,NULL,'2026-03-11 17:20:09'),(133,23,14,'absent',NULL,'manual',NULL,NULL,'2026-03-11 17:20:09'),(134,23,15,'absent',NULL,'manual',NULL,NULL,'2026-03-11 17:20:09'),(135,23,16,'absent',NULL,'manual',NULL,NULL,'2026-03-11 17:20:09'),(136,23,21,'absent',NULL,'manual',NULL,NULL,'2026-03-11 17:20:09'),(137,23,22,'absent',NULL,'manual',NULL,NULL,'2026-03-11 17:20:09'),(138,23,23,'absent',NULL,'manual',NULL,NULL,'2026-03-11 17:20:09'),(139,23,24,'absent',NULL,'manual',NULL,NULL,'2026-03-11 17:20:09'),(140,23,26,'absent',NULL,'manual',NULL,NULL,'2026-03-11 17:20:09'),(141,23,27,'absent',NULL,'manual',NULL,NULL,'2026-03-11 17:20:09'),(142,23,28,'absent',NULL,'manual',NULL,NULL,'2026-03-11 17:20:09'),(143,23,29,'absent',NULL,'manual',NULL,NULL,'2026-03-11 17:20:09'),(144,23,57,'absent',NULL,'manual',NULL,NULL,'2026-03-11 17:20:09'),(145,24,7,'absent',NULL,'manual',NULL,NULL,'2026-03-11 17:37:55'),(146,24,8,'absent',NULL,'manual',NULL,NULL,'2026-03-11 17:37:55'),(147,24,9,'absent',NULL,'manual',NULL,NULL,'2026-03-11 17:37:55'),(148,24,10,'absent',NULL,'manual',NULL,NULL,'2026-03-11 17:37:55'),(149,24,11,'absent',NULL,'manual',NULL,NULL,'2026-03-11 17:37:55'),(150,24,25,'absent',NULL,'manual',NULL,NULL,'2026-03-11 17:37:55'),(151,24,30,'absent',NULL,'manual',NULL,NULL,'2026-03-11 17:37:55'),(152,24,34,'absent',NULL,'manual',NULL,NULL,'2026-03-11 17:37:55'),(153,24,13,'absent',NULL,'manual',NULL,NULL,'2026-03-11 17:37:55'),(154,24,14,'absent',NULL,'manual',NULL,NULL,'2026-03-11 17:37:55'),(155,24,15,'absent',NULL,'manual',NULL,NULL,'2026-03-11 17:37:55'),(156,24,16,'absent',NULL,'manual',NULL,NULL,'2026-03-11 17:37:55'),(157,24,21,'absent',NULL,'manual',NULL,NULL,'2026-03-11 17:37:55'),(158,24,22,'absent',NULL,'manual',NULL,NULL,'2026-03-11 17:37:55'),(159,24,23,'absent',NULL,'manual',NULL,NULL,'2026-03-11 17:37:55'),(160,24,24,'absent',NULL,'manual',NULL,NULL,'2026-03-11 17:37:55'),(161,24,26,'absent',NULL,'manual',NULL,NULL,'2026-03-11 17:37:55'),(162,24,27,'absent',NULL,'manual',NULL,NULL,'2026-03-11 17:37:55'),(163,24,28,'absent',NULL,'manual',NULL,NULL,'2026-03-11 17:37:55'),(164,24,29,'absent',NULL,'manual',NULL,NULL,'2026-03-11 17:37:55'),(165,24,57,'absent',NULL,'manual',NULL,NULL,'2026-03-11 17:37:55'),(166,26,7,'absent',NULL,'manual',NULL,NULL,'2026-03-14 15:36:08'),(167,26,8,'absent',NULL,'manual',NULL,NULL,'2026-03-14 15:36:08'),(168,26,9,'absent',NULL,'manual',NULL,NULL,'2026-03-14 15:36:08'),(169,26,10,'absent',NULL,'manual',NULL,NULL,'2026-03-14 15:36:08'),(170,26,11,'absent',NULL,'manual',NULL,NULL,'2026-03-14 15:36:08'),(171,26,25,'absent',NULL,'manual',NULL,NULL,'2026-03-14 15:36:08'),(172,26,30,'absent',NULL,'manual',NULL,NULL,'2026-03-14 15:36:08'),(173,26,34,'absent',NULL,'manual',NULL,NULL,'2026-03-14 15:36:08'),(174,26,13,'absent',NULL,'manual',NULL,NULL,'2026-03-14 15:36:08'),(175,26,14,'absent',NULL,'manual',NULL,NULL,'2026-03-14 15:36:08'),(176,26,15,'absent',NULL,'manual',NULL,NULL,'2026-03-14 15:36:08'),(177,26,16,'absent',NULL,'manual',NULL,NULL,'2026-03-14 15:36:08'),(178,26,21,'absent',NULL,'manual',NULL,NULL,'2026-03-14 15:36:08'),(179,26,22,'absent',NULL,'manual',NULL,NULL,'2026-03-14 15:36:08'),(180,26,23,'absent',NULL,'manual',NULL,NULL,'2026-03-14 15:36:08'),(181,26,24,'absent',NULL,'manual',NULL,NULL,'2026-03-14 15:36:08'),(182,26,26,'absent',NULL,'manual',NULL,NULL,'2026-03-14 15:36:08'),(183,26,27,'absent',NULL,'manual',NULL,NULL,'2026-03-14 15:36:08'),(184,26,28,'absent',NULL,'manual',NULL,NULL,'2026-03-14 15:36:08'),(185,26,29,'absent',NULL,'manual',NULL,NULL,'2026-03-14 15:36:08'),(186,26,57,'absent',NULL,'manual',NULL,NULL,'2026-03-14 15:36:08'),(187,27,7,'absent',NULL,'manual',NULL,NULL,'2026-03-14 15:40:48'),(188,27,8,'absent',NULL,'manual',NULL,NULL,'2026-03-14 15:40:48'),(189,27,9,'absent',NULL,'manual',NULL,NULL,'2026-03-14 15:40:48'),(190,27,10,'absent',NULL,'manual',NULL,NULL,'2026-03-14 15:40:48'),(191,27,11,'absent',NULL,'manual',NULL,NULL,'2026-03-14 15:40:48'),(192,27,25,'absent',NULL,'manual',NULL,NULL,'2026-03-14 15:40:48'),(193,27,30,'absent',NULL,'manual',NULL,NULL,'2026-03-14 15:40:48'),(194,27,34,'absent',NULL,'manual',NULL,NULL,'2026-03-14 15:40:48'),(195,27,13,'absent',NULL,'manual',NULL,NULL,'2026-03-14 15:40:48'),(196,27,14,'absent',NULL,'manual',NULL,NULL,'2026-03-14 15:40:48'),(197,27,15,'absent',NULL,'manual',NULL,NULL,'2026-03-14 15:40:48'),(198,27,16,'absent',NULL,'manual',NULL,NULL,'2026-03-14 15:40:48'),(199,27,21,'absent',NULL,'manual',NULL,NULL,'2026-03-14 15:40:48'),(200,27,22,'absent',NULL,'manual',NULL,NULL,'2026-03-14 15:40:48'),(201,27,23,'absent',NULL,'manual',NULL,NULL,'2026-03-14 15:40:48'),(202,27,24,'absent',NULL,'manual',NULL,NULL,'2026-03-14 15:40:48'),(203,27,26,'absent',NULL,'manual',NULL,NULL,'2026-03-14 15:40:48'),(204,27,27,'absent',NULL,'manual',NULL,NULL,'2026-03-14 15:40:48'),(205,27,28,'absent',NULL,'manual',NULL,NULL,'2026-03-14 15:40:48'),(206,27,29,'absent',NULL,'manual',NULL,NULL,'2026-03-14 15:40:48'),(207,27,57,'absent',NULL,'manual',NULL,NULL,'2026-03-14 15:40:48'),(208,28,7,'absent',NULL,'manual',NULL,NULL,'2026-03-14 16:06:10'),(209,28,8,'absent',NULL,'manual',NULL,NULL,'2026-03-14 16:06:10'),(210,28,9,'absent',NULL,'manual',NULL,NULL,'2026-03-14 16:06:10'),(211,28,10,'absent',NULL,'manual',NULL,NULL,'2026-03-14 16:06:10'),(212,28,11,'absent',NULL,'manual',NULL,NULL,'2026-03-14 16:06:10'),(213,28,25,'absent',NULL,'manual',NULL,NULL,'2026-03-14 16:06:10'),(214,28,30,'absent',NULL,'manual',NULL,NULL,'2026-03-14 16:06:10'),(215,28,34,'absent',NULL,'manual',NULL,NULL,'2026-03-14 16:06:10'),(216,28,13,'absent',NULL,'manual',NULL,NULL,'2026-03-14 16:06:10'),(217,28,14,'absent',NULL,'manual',NULL,NULL,'2026-03-14 16:06:10'),(218,28,15,'absent',NULL,'manual',NULL,NULL,'2026-03-14 16:06:10'),(219,28,16,'absent',NULL,'manual',NULL,NULL,'2026-03-14 16:06:10'),(220,28,21,'absent',NULL,'manual',NULL,NULL,'2026-03-14 16:06:10'),(221,28,22,'absent',NULL,'manual',NULL,NULL,'2026-03-14 16:06:10'),(222,28,23,'absent',NULL,'manual',NULL,NULL,'2026-03-14 16:06:10'),(223,28,24,'absent',NULL,'manual',NULL,NULL,'2026-03-14 16:06:10'),(224,28,26,'absent',NULL,'manual',NULL,NULL,'2026-03-14 16:06:10'),(225,28,27,'absent',NULL,'manual',NULL,NULL,'2026-03-14 16:06:10'),(226,28,28,'absent',NULL,'manual',NULL,NULL,'2026-03-14 16:06:10'),(227,28,29,'absent',NULL,'manual',NULL,NULL,'2026-03-14 16:06:10'),(228,28,57,'absent',NULL,'manual',NULL,NULL,'2026-03-14 16:06:10'),(229,29,7,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:19:09'),(230,29,8,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:19:09'),(231,29,9,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:19:09'),(232,29,10,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:19:09'),(233,29,11,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:19:09'),(234,29,25,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:19:09'),(235,29,30,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:19:09'),(236,29,34,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:19:09'),(237,29,13,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:19:09'),(238,29,14,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:19:09'),(239,29,15,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:19:09'),(240,29,16,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:19:09'),(241,29,21,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:19:09'),(242,29,22,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:19:09'),(243,29,23,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:19:09'),(244,29,24,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:19:09'),(245,29,26,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:19:09'),(246,29,27,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:19:09'),(247,29,28,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:19:09'),(248,29,29,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:19:09'),(249,29,57,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:19:09'),(250,30,7,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:20:14'),(251,30,8,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:20:14'),(252,30,9,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:20:14'),(253,30,10,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:20:14'),(254,30,11,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:20:14'),(255,30,25,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:20:14'),(256,30,30,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:20:14'),(257,30,34,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:20:14'),(258,30,13,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:20:14'),(259,30,14,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:20:14'),(260,30,15,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:20:14'),(261,30,16,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:20:14'),(262,30,21,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:20:14'),(263,30,22,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:20:14'),(264,30,23,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:20:14'),(265,30,24,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:20:14'),(266,30,26,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:20:14'),(267,30,27,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:20:14'),(268,30,28,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:20:14'),(269,30,29,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:20:14'),(270,30,57,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:20:14'),(271,31,7,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:32:56'),(272,31,8,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:32:56'),(273,31,9,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:32:56'),(274,31,10,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:32:56'),(275,31,11,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:32:56'),(276,31,25,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:32:56'),(277,31,30,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:32:56'),(278,31,34,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:32:56'),(279,31,13,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:32:56'),(280,31,14,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:32:56'),(281,31,15,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:32:56'),(282,31,16,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:32:56'),(283,31,21,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:32:56'),(284,31,22,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:32:56'),(285,31,23,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:32:56'),(286,31,24,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:32:56'),(287,31,26,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:32:56'),(288,31,27,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:32:56'),(289,31,28,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:32:56'),(290,31,29,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:32:56'),(291,31,57,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:32:56'),(292,32,7,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:45:22'),(293,32,8,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:45:22'),(294,32,9,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:45:22'),(295,32,10,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:45:22'),(296,32,11,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:45:22'),(297,32,25,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:45:22'),(298,32,30,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:45:22'),(299,32,34,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:45:22'),(300,32,13,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:45:22'),(301,32,14,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:45:22'),(302,32,15,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:45:22'),(303,32,16,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:45:22'),(304,32,21,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:45:22'),(305,32,22,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:45:22'),(306,32,23,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:45:22'),(307,32,24,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:45:22'),(308,32,26,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:45:22'),(309,32,27,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:45:22'),(310,32,28,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:45:22'),(311,32,29,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:45:22'),(312,32,57,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:45:22'),(313,33,7,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:53:58'),(314,33,8,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:53:58'),(315,33,9,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:53:58'),(316,33,10,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:53:58'),(317,33,11,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:53:58'),(318,33,25,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:53:58'),(319,33,30,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:53:58'),(320,33,34,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:53:58'),(321,33,13,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:53:58'),(322,33,14,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:53:58'),(323,33,15,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:53:58'),(324,33,16,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:53:58'),(325,33,21,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:53:58'),(326,33,22,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:53:58'),(327,33,23,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:53:58'),(328,33,24,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:53:58'),(329,33,26,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:53:58'),(330,33,27,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:53:58'),(331,33,28,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:53:58'),(332,33,29,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:53:58'),(333,33,57,'absent',NULL,'manual',NULL,NULL,'2026-03-16 20:53:58'),(334,34,7,'absent',NULL,'manual',NULL,NULL,'2026-03-16 22:31:34'),(335,34,8,'absent',NULL,'manual',NULL,NULL,'2026-03-16 22:31:34'),(336,34,9,'absent',NULL,'manual',NULL,NULL,'2026-03-16 22:31:34'),(337,34,10,'absent',NULL,'manual',NULL,NULL,'2026-03-16 22:31:34'),(338,34,11,'absent',NULL,'manual',NULL,NULL,'2026-03-16 22:31:34'),(339,34,25,'absent',NULL,'manual',NULL,NULL,'2026-03-16 22:31:34'),(340,34,30,'absent',NULL,'manual',NULL,NULL,'2026-03-16 22:31:34'),(341,34,34,'absent',NULL,'manual',NULL,NULL,'2026-03-16 22:31:34'),(342,34,13,'absent',NULL,'manual',NULL,NULL,'2026-03-16 22:31:34'),(343,34,14,'absent',NULL,'manual',NULL,NULL,'2026-03-16 22:31:34'),(344,34,15,'absent',NULL,'manual',NULL,NULL,'2026-03-16 22:31:34'),(345,34,16,'absent',NULL,'manual',NULL,NULL,'2026-03-16 22:31:34'),(346,34,21,'absent',NULL,'manual',NULL,NULL,'2026-03-16 22:31:34'),(347,34,22,'absent',NULL,'manual',NULL,NULL,'2026-03-16 22:31:34'),(348,34,23,'absent',NULL,'manual',NULL,NULL,'2026-03-16 22:31:34'),(349,34,24,'absent',NULL,'manual',NULL,NULL,'2026-03-16 22:31:34'),(350,34,26,'absent',NULL,'manual',NULL,NULL,'2026-03-16 22:31:34'),(351,34,27,'absent',NULL,'manual',NULL,NULL,'2026-03-16 22:31:34'),(352,34,28,'absent',NULL,'manual',NULL,NULL,'2026-03-16 22:31:34'),(353,34,29,'absent',NULL,'manual',NULL,NULL,'2026-03-16 22:31:34'),(354,34,57,'absent',NULL,'manual',NULL,NULL,'2026-03-16 22:31:34');
/*!40000 ALTER TABLE `attendance_records` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `attendance_sessions`
--

DROP TABLE IF EXISTS `attendance_sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `attendance_sessions` (
  `session_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `section_id` bigint unsigned NOT NULL,
  `session_date` date NOT NULL,
  `session_type` enum('lecture','lab','tutorial','exam') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'lecture',
  `instructor_id` bigint unsigned NOT NULL,
  `start_time` time DEFAULT NULL,
  `end_time` time DEFAULT NULL,
  `location` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `total_students` int DEFAULT '0',
  `present_count` int DEFAULT '0',
  `absent_count` int DEFAULT '0',
  `status` enum('scheduled','in_progress','completed','cancelled') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'scheduled',
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`session_id`),
  KEY `idx_section` (`section_id`),
  KEY `idx_date` (`session_date`),
  KEY `idx_instructor` (`instructor_id`),
  CONSTRAINT `attendance_sessions_ibfk_1` FOREIGN KEY (`section_id`) REFERENCES `course_sections` (`section_id`) ON DELETE CASCADE,
  CONSTRAINT `attendance_sessions_ibfk_2` FOREIGN KEY (`instructor_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=35 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `attendance_sessions`
--

LOCK TABLES `attendance_sessions` WRITE;
/*!40000 ALTER TABLE `attendance_sessions` DISABLE KEYS */;
INSERT INTO `attendance_sessions` VALUES (1,1,'2025-02-03','lecture',8,'09:00:00','10:30:00',NULL,0,0,0,'completed',NULL,'2025-02-03 08:00:00','2026-03-01 14:55:40'),(2,1,'2025-02-05','lecture',8,'09:00:00','10:30:00',NULL,0,0,0,'completed',NULL,'2025-02-05 08:00:00','2026-03-01 14:55:40'),(3,1,'2025-02-10','lecture',8,'09:00:00','10:30:00',NULL,0,0,0,'completed',NULL,'2025-02-10 08:00:00','2026-03-01 14:55:40'),(4,2,'2025-02-04','lecture',9,'11:00:00','12:30:00',NULL,0,0,0,'completed',NULL,'2025-02-04 08:00:00','2026-03-01 14:55:40'),(5,2,'2025-02-06','lecture',9,'11:00:00','12:30:00',NULL,0,0,0,'completed',NULL,'2025-02-06 08:00:00','2026-03-01 14:55:40'),(6,3,'2025-02-03','lecture',10,'13:00:00','14:30:00',NULL,0,0,0,'completed',NULL,'2025-02-03 08:00:00','2026-03-01 14:55:40'),(7,3,'2025-02-05','lecture',10,'13:00:00','14:30:00',NULL,0,0,0,'completed',NULL,'2025-02-05 08:00:00','2026-03-01 14:55:40'),(8,5,'2025-02-03','lab',12,'15:00:00','16:30:00',NULL,0,0,0,'completed',NULL,'2025-02-03 08:00:00','2026-03-01 14:55:40'),(9,9,'2025-02-04','lecture',16,'14:00:00','15:00:00',NULL,0,0,0,'completed',NULL,'2025-02-04 08:00:00','2026-03-01 14:55:40'),(10,10,'2025-02-05','lecture',17,'13:00:00','14:00:00',NULL,0,0,0,'completed',NULL,'2025-02-05 08:00:00','2026-03-01 14:55:40'),(11,1,'2026-03-02','lecture',58,'09:00:00','10:30:00',NULL,20,0,20,'scheduled','Test session','2026-03-02 14:05:42','2026-03-02 14:05:42'),(12,1,'2026-03-15','lecture',58,'09:00:00','10:30:00',NULL,20,0,20,'scheduled','Retest session','2026-03-02 14:06:47','2026-03-02 14:06:47'),(13,1,'2026-03-16','lab',58,NULL,NULL,NULL,20,0,20,'scheduled',NULL,'2026-03-02 14:06:53','2026-03-02 14:06:53'),(14,1,'2026-03-20','lecture',58,'09:00:00','10:30:00',NULL,20,2,19,'completed','Updated retest','2026-03-02 14:07:07','2026-03-02 14:08:14'),(16,11,'2026-03-02','lecture',58,'09:00:00','10:30:00','Room A101',0,0,0,'scheduled','Week 1 intro lecture','2026-03-02 23:33:32','2026-03-02 23:33:32'),(17,11,'2026-03-02','lecture',58,'09:00:00','10:30:00','Room B202',0,2,1,'completed','Updated notes','2026-03-02 23:42:38','2026-03-02 23:42:39'),(18,11,'2026-03-02','lecture',58,'09:00:00','10:30:00','Room B202',0,2,1,'completed','Updated notes','2026-03-02 23:47:21','2026-03-02 23:47:22'),(19,11,'2026-03-02','lecture',58,'09:00:00','10:30:00','Room A101',0,0,0,'scheduled','Week 1 intro lecture','2026-03-02 23:51:58','2026-03-02 23:51:58'),(20,11,'2026-03-02','lecture',58,'09:00:00','10:30:00','Room A101',0,0,0,'scheduled','Week 1 intro lecture','2026-03-03 00:23:19','2026-03-03 00:23:19'),(21,11,'2026-03-02','lecture',58,'09:00:00','10:30:00','Room A101',0,0,0,'scheduled','Week 1 intro lecture','2026-03-03 18:34:04','2026-03-03 18:34:04'),(22,11,'2026-03-02','lecture',58,'09:00:00','10:30:00','Room A101',0,0,0,'scheduled','Week 1 intro lecture','2026-03-05 19:16:25','2026-03-05 19:16:25'),(23,1,'2026-03-15','lecture',59,'09:00:00','10:30:00',NULL,21,0,21,'scheduled',NULL,'2026-03-11 17:20:09','2026-03-11 17:20:09'),(24,1,'2026-03-15','lecture',59,'09:00:00','10:30:00',NULL,21,0,21,'scheduled',NULL,'2026-03-11 17:37:55','2026-03-11 17:37:55'),(25,1,'2026-03-15','lecture',59,'09:00:00','10:30:00',NULL,0,0,0,'scheduled',NULL,'2026-03-14 15:17:51','2026-03-14 15:17:51'),(26,1,'2026-03-15','lecture',59,'09:00:00','10:30:00',NULL,21,0,21,'scheduled',NULL,'2026-03-14 15:36:08','2026-03-14 15:36:08'),(27,1,'2026-03-15','lecture',59,'09:00:00','10:30:00',NULL,21,0,21,'scheduled',NULL,'2026-03-14 15:40:48','2026-03-14 15:40:48'),(28,1,'2026-03-15','lecture',59,'09:00:00','10:30:00',NULL,21,0,21,'scheduled',NULL,'2026-03-14 16:06:10','2026-03-14 16:06:10'),(29,1,'2026-03-15','lecture',59,'09:00:00','10:30:00',NULL,21,0,21,'scheduled',NULL,'2026-03-16 20:19:09','2026-03-16 20:19:09'),(30,1,'2026-03-15','lecture',59,'09:00:00','10:30:00',NULL,21,0,21,'scheduled',NULL,'2026-03-16 20:20:14','2026-03-16 20:20:14'),(31,1,'2026-03-15','lecture',59,'09:00:00','10:30:00',NULL,21,0,21,'scheduled',NULL,'2026-03-16 20:32:56','2026-03-16 20:32:56'),(32,1,'2026-03-15','lecture',59,'09:00:00','10:30:00',NULL,21,0,21,'scheduled',NULL,'2026-03-16 20:45:22','2026-03-16 20:45:22'),(33,1,'2026-03-15','lecture',59,'09:00:00','10:30:00',NULL,21,0,21,'scheduled',NULL,'2026-03-16 20:53:58','2026-03-16 20:53:58'),(34,1,'2026-03-15','lecture',59,'09:00:00','10:30:00',NULL,21,0,21,'scheduled',NULL,'2026-03-16 22:31:34','2026-03-16 22:31:34');
/*!40000 ALTER TABLE `attendance_sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `audit_logs`
--

DROP TABLE IF EXISTS `audit_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `audit_logs` (
  `log_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned DEFAULT NULL,
  `action_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `entity_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `entity_id` bigint unsigned DEFAULT NULL,
  `old_values` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `new_values` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `ip_address` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`log_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_action` (`action_type`),
  KEY `idx_entity` (`entity_type`,`entity_id`),
  KEY `idx_date` (`created_at`),
  CONSTRAINT `audit_logs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=455 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `audit_logs`
--

LOCK TABLES `audit_logs` WRITE;
/*!40000 ALTER TABLE `audit_logs` DISABLE KEYS */;
INSERT INTO `audit_logs` VALUES (1,1,'CREATE','user',7,NULL,'{\"email\": \"alice.student@campus.edu\", \"role\": \"student\"}','192.168.1.1',NULL,'Created new student account','2025-11-20 13:43:00'),(2,2,'UPDATE','grade',1,'{\"score\": 0}','{\"score\": 95}','192.168.1.50',NULL,'Graded assignment submission','2025-11-20 13:43:00'),(3,1,'UPDATE','system_settings',8,'{\"value\": \"false\"}','{\"value\": \"true\"}','192.168.1.1',NULL,'Enabled AI features','2025-11-20 13:43:00'),(4,2,'CREATE','assignment',1,NULL,'{\"title\": \"Assignment 1: Hello World\"}','192.168.1.50',NULL,'Created new assignment','2025-11-20 13:43:00'),(5,1,'DELETE','user',99,'{\"email\": \"test@campus.edu\"}',NULL,'192.168.1.1',NULL,'Deleted test account','2025-11-20 13:43:00'),(6,NULL,'CREATE','auth',NULL,NULL,'{\"email\":\"admin.tarek@example.com\",\"password\":\"SecureP@ss123\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','CREATE auth via POST /api/auth/login','2026-03-16 19:52:44'),(7,NULL,'CREATE','auth',NULL,NULL,'{\"email\":\"admin.tarek@example.com\",\"password\":\"SecureP@ss123\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','CREATE auth via POST /api/auth/login','2026-03-16 19:52:56'),(8,NULL,'CREATE','auth',NULL,NULL,'{\"email\":\"admin.tarek@example.com\",\"password\":\"SecureP@ss123\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','CREATE auth via POST /api/auth/login','2026-03-16 19:53:09'),(9,NULL,'CREATE','auth',NULL,NULL,'{\"email\":\"admin.tarek@example.com\",\"password\":\"SecureP@ss123\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','CREATE auth via POST /api/auth/login','2026-03-16 19:53:37'),(10,NULL,'CREATE','auth',NULL,NULL,'{\"email\":\"admin.tarek@example.com\",\"password\":\"SecureP@ss123\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','CREATE auth via POST /api/auth/login','2026-03-16 19:55:53'),(11,NULL,'CREATE','auth',NULL,NULL,'{\"email\":\"admin.tarek@example.com\",\"password\":\"SecureP@ss123\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','CREATE auth via POST /api/auth/login','2026-03-16 19:58:34'),(12,NULL,'CREATE','auth',NULL,NULL,'{\"email\":\"admin.tarek@example.com\",\"password\":\"SecureP@ss123\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','CREATE auth via POST /api/auth/login','2026-03-16 19:58:54'),(13,NULL,'CREATE','auth',NULL,NULL,'{\"email\":\"admin.tarek@example.com\",\"password\":\"SecureP@ss123\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','CREATE auth via POST /api/auth/login','2026-03-16 19:59:45'),(14,NULL,'CREATE','auth',NULL,NULL,'{\"email\":\"amir_admin@example.com\",\"password\":\"Pass@123\",\"rememberMe\":false}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','CREATE auth via POST /api/auth/login','2026-03-16 20:06:47'),(15,NULL,'CREATE','auth',NULL,NULL,'{\"email\":\"amir_itadmin@example.com\",\"password\":\"Pass@123\",\"rememberMe\":false}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','CREATE auth via POST /api/auth/login','2026-03-16 20:07:55'),(16,NULL,'CREATE','auth',NULL,NULL,'{\"email\":\"admin.tarek@example.com\",\"password\":\"SecureP@ss123\",\"rememberMe\":true}','127.0.0.1','PostmanRuntime/7.52.0','CREATE auth via POST /api/auth/login','2026-03-16 20:18:21'),(17,NULL,'CREATE','auth',NULL,NULL,'{\"email\":\"instructor.tarek@example.com\",\"password\":\"SecureP@ss123\",\"rememberMe\":true}','127.0.0.1','PostmanRuntime/7.52.0','CREATE auth via POST /api/auth/login','2026-03-16 20:18:21'),(18,NULL,'CREATE','auth',NULL,NULL,'{\"email\":\"student.tarek@example.com\",\"password\":\"SecureP@ss123\",\"rememberMe\":true}','127.0.0.1','PostmanRuntime/7.52.0','CREATE auth via POST /api/auth/login','2026-03-16 20:18:21'),(19,NULL,'CREATE','auth',NULL,NULL,'{\"email\":\"ta.tarek@example.com\",\"password\":\"SecureP@ss123\",\"rememberMe\":true}','127.0.0.1','PostmanRuntime/7.52.0','CREATE auth via POST /api/auth/login','2026-03-16 20:18:22'),(20,NULL,'CREATE','auth',NULL,NULL,'{\"email\":\"it_admin.tarek@example.com\",\"password\":\"SecureP@ss123\",\"rememberMe\":true}','127.0.0.1','PostmanRuntime/7.52.0','CREATE auth via POST /api/auth/login','2026-03-16 20:18:22'),(21,NULL,'CREATE','auth',NULL,NULL,'{\"refreshToken\":\"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzczNjkyMzAxLCJleHAiOjE3NzYyODQzMDF9.oRSU7Hv3Y5fYkVat8aECmyTah6xIMOQXzVDuPKXnrbc\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE auth via POST /api/auth/refresh-token','2026-03-16 20:18:53'),(22,57,'UPDATE','users',NULL,NULL,'{\"firstName\":\"Student\",\"lastName\":\"Tarek\",\"phone\":\"+201234567890\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE users via PUT /api/users/profile','2026-03-16 20:18:54'),(23,57,'UPDATE','users',NULL,NULL,'{\"theme\":\"dark\",\"language\":\"en\",\"emailNotifications\":true,\"pushNotifications\":true}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE users via PUT /api/users/preferences','2026-03-16 20:18:54'),(24,57,'UPDATE','users',NULL,NULL,'{\"currentPassword\":\"SecureP@ss123\",\"newPassword\":\"SecureP@ss123\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE users via PATCH /api/users/password','2026-03-16 20:18:54'),(25,59,'UPDATE','admin',57,NULL,'{\"firstName\":\"Student\",\"lastName\":\"Tarek\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE admin via PUT /api/admin/users/57','2026-03-16 20:18:55'),(26,59,'UPDATE','campuses',1,NULL,'{\"name\":\"Updated Campus Name\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE campuses via PUT /api/campuses/1','2026-03-16 20:18:56'),(27,59,'UPDATE','departments',1,NULL,'{\"name\":\"Updated Department\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE departments via PUT /api/departments/1','2026-03-16 20:18:56'),(28,59,'UPDATE','programs',1,NULL,'{\"name\":\"Updated Program\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE programs via PUT /api/programs/1','2026-03-16 20:18:56'),(29,NULL,'CREATE','sections',NULL,NULL,'{\"courseId\":1,\"semesterId\":2,\"sectionNumber\":\"702\",\"maxCapacity\":30,\"location\":\"Room TEST\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE sections via POST /api/sections','2026-03-16 20:18:57'),(30,59,'CREATE','courses',1,NULL,'{\"title\":\"API Dog Test Material\",\"materialType\":\"document\",\"description\":\"Created by API Dog test\",\"weekNumber\":1,\"isPublished\":true}','127.0.0.1','PostmanRuntime/7.52.0','CREATE courses via POST /api/courses/1/materials','2026-03-16 20:18:59'),(31,59,'CREATE','courses',1,NULL,'{\"materials\":[{\"title\":\"Bulk Test 1\",\"materialType\":\"lecture\",\"weekNumber\":10,\"isPublished\":true},{\"title\":\"Bulk Test 2\",\"materialType\":\"slide\",\"weekNumber\":10,\"isPublished\":true}]}','127.0.0.1','PostmanRuntime/7.52.0','CREATE courses via POST /api/courses/1/materials/bulk','2026-03-16 20:18:59'),(32,59,'UPDATE','courses',43,NULL,'{\"title\":\"Updated API Dog Material\",\"description\":\"Updated by test\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE courses via PUT /api/courses/1/materials/43','2026-03-16 20:18:59'),(33,59,'UPDATE','courses',15,NULL,'{\"isPublished\":true}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE courses via PATCH /api/courses/1/materials/15/visibility','2026-03-16 20:18:59'),(34,59,'CREATE','courses',15,NULL,'{}','127.0.0.1','PostmanRuntime/7.52.0','CREATE courses via POST /api/courses/1/materials/15/view','2026-03-16 20:19:00'),(35,59,'DELETE','courses',43,NULL,NULL,'127.0.0.1','PostmanRuntime/7.52.0','DELETE courses via DELETE /api/courses/1/materials/43','2026-03-16 20:19:00'),(36,59,'CREATE','courses',1,NULL,'{\"title\":\"Week 10: API Dog Test\",\"organizationType\":\"lecture\",\"weekNumber\":10,\"orderIndex\":99}','127.0.0.1','PostmanRuntime/7.52.0','CREATE courses via POST /api/courses/1/structure','2026-03-16 20:19:00'),(37,59,'UPDATE','courses',19,NULL,'{\"title\":\"Week 10: Updated\",\"description\":\"Updated by API Dog\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE courses via PUT /api/courses/1/structure/19','2026-03-16 20:19:00'),(38,59,'UPDATE','courses',1,NULL,'{\"orderIds\":[7,8,9,10,11,12]}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE courses via PATCH /api/courses/1/structure/reorder','2026-03-16 20:19:00'),(39,59,'DELETE','courses',19,NULL,NULL,'127.0.0.1','PostmanRuntime/7.52.0','DELETE courses via DELETE /api/courses/1/structure/19','2026-03-16 20:19:00'),(40,59,'CREATE','announcements',NULL,NULL,'{\"title\":\"API Dog Test Announcement\",\"content\":\"This is a test announcement from API Dog.\",\"courseId\":1,\"priority\":\"medium\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE announcements via POST /api/announcements','2026-03-16 20:19:02'),(41,59,'UPDATE','announcements',1,NULL,'{\"title\":\"Updated: Welcome to CS101!\",\"content\":\"Updated announcement content.\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE announcements via PUT /api/announcements/1','2026-03-16 20:19:02'),(42,59,'UPDATE','announcements',1,NULL,'{}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE announcements via PATCH /api/announcements/1/publish','2026-03-16 20:19:02'),(43,59,'UPDATE','announcements',1,NULL,'{\"isPinned\":true}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE announcements via PATCH /api/announcements/1/pin','2026-03-16 20:19:02'),(44,59,'CREATE','assignments',NULL,NULL,'{\"courseId\":1,\"title\":\"API Dog Test Assignment\",\"description\":\"Test assignment from API Dog\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE assignments via POST /api/assignments','2026-03-16 20:19:03'),(45,59,'UPDATE','assignments',1,NULL,'{\"title\":\"Updated Assignment Title\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE assignments via PATCH /api/assignments/1','2026-03-16 20:19:03'),(46,59,'CREATE','discussions',NULL,NULL,'{\"courseId\":1,\"title\":\"API Dog Test Discussion\",\"description\":\"Testing from API Dog.\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE discussions via POST /api/discussions','2026-03-16 20:19:03'),(47,59,'UPDATE','discussions',3,NULL,'{\"title\":\"Updated Discussion Title\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE discussions via PUT /api/discussions/3','2026-03-16 20:19:03'),(48,59,'CREATE','discussions',3,NULL,'{\"messageText\":\"Test reply from API Dog.\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE discussions via POST /api/discussions/3/reply','2026-03-16 20:19:03'),(49,59,'UPDATE','discussions',3,NULL,'{\"isPinned\":true}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE discussions via PATCH /api/discussions/3/pin','2026-03-16 20:19:03'),(50,59,'UPDATE','discussions',3,NULL,'{\"isLocked\":true}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE discussions via PATCH /api/discussions/3/lock','2026-03-16 20:19:04'),(51,59,'CREATE','community',NULL,NULL,'{\"title\":\"API Dog Test Post\",\"content\":\"Testing from API Dog.\",\"communityId\":1}','127.0.0.1','PostmanRuntime/7.52.0','CREATE community via POST /api/community/communities/1/posts','2026-03-16 20:19:04'),(52,59,'CREATE','community',NULL,NULL,'{\"title\":\"Global Post from API Dog\",\"content\":\"Test global post.\",\"communityId\":1}','127.0.0.1','PostmanRuntime/7.52.0','CREATE community via POST /api/community/global/posts','2026-03-16 20:19:04'),(53,59,'CREATE','community',3,NULL,'{\"commentText\":\"API Dog test comment\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE community via POST /api/community/posts/3/comment','2026-03-16 20:19:05'),(54,59,'CREATE','community',3,NULL,'{\"reactionType\":\"like\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE community via POST /api/community/posts/3/react','2026-03-16 20:19:05'),(55,59,'CREATE','files',NULL,NULL,'{\"folderName\":\"API Dog Test Folder\",\"parentFolderId\":1}','127.0.0.1','PostmanRuntime/7.52.0','CREATE files via POST /api/files/folders','2026-03-16 20:19:06'),(56,59,'UPDATE','files',NULL,NULL,'{\"folderName\":\"Updated Test Folder\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE files via PUT /api/files/folders/21','2026-03-16 20:19:06'),(57,59,'DELETE','files',NULL,NULL,NULL,'127.0.0.1','PostmanRuntime/7.52.0','DELETE files via DELETE /api/files/folders/21','2026-03-16 20:19:06'),(58,59,'CREATE','labs',NULL,NULL,'{\"title\":\"API Dog Test Lab\",\"courseId\":1,\"description\":\"Test lab\",\"dueDate\":\"2026-06-15T23:59:00Z\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE labs via POST /api/labs','2026-03-16 20:19:07'),(59,59,'UPDATE','labs',3,NULL,'{\"title\":\"Updated Lab Title\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE labs via PUT /api/labs/3','2026-03-16 20:19:07'),(60,58,'CREATE','rubrics',NULL,NULL,'{\"rubricName\":\"API Dog Test Rubric\",\"courseId\":1,\"totalPoints\":100}','127.0.0.1','PostmanRuntime/7.52.0','CREATE rubrics via POST /api/rubrics','2026-03-16 20:19:09'),(61,59,'CREATE','attendance',NULL,NULL,'{\"sectionId\":1,\"sessionDate\":\"2026-03-15\",\"sessionType\":\"lecture\",\"startTime\":\"09:00:00\",\"endTime\":\"10:30:00\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE attendance via POST /attendance/sessions','2026-03-16 20:19:09'),(62,57,'UPDATE','notifications',NULL,NULL,'{\"emailEnabled\":true,\"pushEnabled\":true}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE notifications via PUT /api/notifications/preferences','2026-03-16 20:19:10'),(63,57,'UPDATE','notifications',NULL,NULL,'{}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE notifications via PATCH /api/notifications/read-all','2026-03-16 20:19:10'),(64,59,'CREATE','notifications',NULL,NULL,'{\"userIds\":[57],\"notificationType\":\"system\",\"title\":\"Test from API Dog\",\"body\":\"This is a test notification.\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE notifications via POST /api/notifications/send','2026-03-16 20:19:10'),(65,57,'CREATE','messages',NULL,NULL,'{\"participantIds\":[59],\"type\":\"direct\",\"text\":\"Hello from API Dog test!\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE messages via POST /api/messages/conversations','2026-03-16 20:19:10'),(66,59,'CREATE','calendar',NULL,NULL,'{\"title\":\"API Dog Test Event\",\"description\":\"Test\",\"startTime\":\"2026-04-01T10:00:00Z\",\"endTime\":\"2026-04-01T11:00:00Z\",\"eventType\":\"meeting\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE calendar via POST /api/calendar/events','2026-03-16 20:19:11'),(67,59,'DELETE','calendar',12,NULL,NULL,'127.0.0.1','PostmanRuntime/7.52.0','DELETE calendar via DELETE /api/calendar/events/12','2026-03-16 20:19:11'),(68,57,'CREATE','tasks',NULL,NULL,'{\"title\":\"Study for Final Exam\",\"description\":\"Review all chapters\",\"taskType\":\"study\",\"dueDate\":\"2026-03-18T18:14:01.673Z\",\"priority\":\"high\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE tasks via POST /api/tasks','2026-03-16 20:19:12'),(69,57,'CREATE','tasks',8,NULL,'{\"notes\":\"Finished studying all chapters\",\"timeTakenMinutes\":120}','127.0.0.1','PostmanRuntime/7.52.0','CREATE tasks via POST /api/tasks/8/complete','2026-03-16 20:19:12'),(70,57,'CREATE','tasks',NULL,NULL,'{\"taskId\":9,\"reminderTime\":\"2026-03-17T18:14:01.673Z\",\"reminderType\":\"in_app\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE tasks via POST /api/tasks/reminders','2026-03-16 20:19:12'),(71,57,'DELETE','search',NULL,NULL,NULL,'127.0.0.1','PostmanRuntime/7.52.0','DELETE search via DELETE /api/search/history','2026-03-16 20:19:13'),(72,59,'CREATE','reports',NULL,NULL,'{\"templateId\":1,\"reportName\":\"Test Student Progress Report\",\"filters\":{\"courseId\":1,\"semesterId\":2},\"exportFormat\":\"pdf\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE reports via POST /api/reports/generate','2026-03-16 20:19:14'),(73,NULL,'CREATE','google-drive',NULL,NULL,'{\"name\":\"EduVerse_Test_Folder\",\"parentId\":\"\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE google-drive via POST /google-drive/folders','2026-03-16 20:19:16'),(74,NULL,'CREATE','google-drive',NULL,NULL,'{\"name\":\"EduVerse_Test_Folder\",\"parentId\":\"\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE google-drive via POST /google-drive/folders/find-or-create','2026-03-16 20:19:17'),(75,NULL,'CREATE','auth',NULL,NULL,'{\"email\":\"admin.tarek@example.com\",\"password\":\"SecureP@ss123\",\"rememberMe\":true}','127.0.0.1','PostmanRuntime/7.52.0','CREATE auth via POST /api/auth/login','2026-03-16 20:19:59'),(76,NULL,'CREATE','auth',NULL,NULL,'{\"email\":\"instructor.tarek@example.com\",\"password\":\"SecureP@ss123\",\"rememberMe\":true}','127.0.0.1','PostmanRuntime/7.52.0','CREATE auth via POST /api/auth/login','2026-03-16 20:19:59'),(77,NULL,'CREATE','auth',NULL,NULL,'{\"email\":\"student.tarek@example.com\",\"password\":\"SecureP@ss123\",\"rememberMe\":true}','127.0.0.1','PostmanRuntime/7.52.0','CREATE auth via POST /api/auth/login','2026-03-16 20:20:00'),(78,NULL,'CREATE','auth',NULL,NULL,'{\"email\":\"ta.tarek@example.com\",\"password\":\"SecureP@ss123\",\"rememberMe\":true}','127.0.0.1','PostmanRuntime/7.52.0','CREATE auth via POST /api/auth/login','2026-03-16 20:20:00'),(79,NULL,'CREATE','auth',NULL,NULL,'{\"email\":\"it_admin.tarek@example.com\",\"password\":\"SecureP@ss123\",\"rememberMe\":true}','127.0.0.1','PostmanRuntime/7.52.0','CREATE auth via POST /api/auth/login','2026-03-16 20:20:00'),(80,NULL,'CREATE','auth',NULL,NULL,'{\"refreshToken\":\"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzczNjkyMzk5LCJleHAiOjE3NzYyODQzOTl9.sE3dUXV3Ho9Ikulo-4XoflvvSOMXUB3Wyk83WyPuDNI\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE auth via POST /api/auth/refresh-token','2026-03-16 20:20:00'),(81,57,'UPDATE','users',NULL,NULL,'{\"firstName\":\"Student\",\"lastName\":\"Tarek\",\"phone\":\"+201234567890\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE users via PUT /api/users/profile','2026-03-16 20:20:00'),(82,57,'UPDATE','users',NULL,NULL,'{\"theme\":\"dark\",\"language\":\"en\",\"emailNotifications\":true,\"pushNotifications\":true}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE users via PUT /api/users/preferences','2026-03-16 20:20:00'),(83,57,'UPDATE','users',NULL,NULL,'{\"currentPassword\":\"SecureP@ss123\",\"newPassword\":\"SecureP@ss123\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE users via PATCH /api/users/password','2026-03-16 20:20:01'),(84,59,'UPDATE','admin',57,NULL,'{\"firstName\":\"Student\",\"lastName\":\"Tarek\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE admin via PUT /api/admin/users/57','2026-03-16 20:20:01'),(85,59,'UPDATE','campuses',1,NULL,'{\"name\":\"Updated Campus Name\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE campuses via PUT /api/campuses/1','2026-03-16 20:20:02'),(86,59,'UPDATE','departments',1,NULL,'{\"name\":\"Updated Department\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE departments via PUT /api/departments/1','2026-03-16 20:20:02'),(87,59,'UPDATE','programs',1,NULL,'{\"name\":\"Updated Program\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE programs via PUT /api/programs/1','2026-03-16 20:20:03'),(88,NULL,'CREATE','sections',NULL,NULL,'{\"courseId\":1,\"semesterId\":2,\"sectionNumber\":\"312\",\"maxCapacity\":30,\"location\":\"Room TEST\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE sections via POST /api/sections','2026-03-16 20:20:04'),(89,59,'CREATE','courses',1,NULL,'{\"title\":\"API Dog Test Material\",\"materialType\":\"document\",\"description\":\"Created by API Dog test\",\"weekNumber\":1,\"isPublished\":true}','127.0.0.1','PostmanRuntime/7.52.0','CREATE courses via POST /api/courses/1/materials','2026-03-16 20:20:05'),(90,59,'CREATE','courses',1,NULL,'{\"materials\":[{\"title\":\"Bulk Test 1\",\"materialType\":\"lecture\",\"weekNumber\":10,\"isPublished\":true},{\"title\":\"Bulk Test 2\",\"materialType\":\"slide\",\"weekNumber\":10,\"isPublished\":true}]}','127.0.0.1','PostmanRuntime/7.52.0','CREATE courses via POST /api/courses/1/materials/bulk','2026-03-16 20:20:05'),(91,59,'UPDATE','courses',46,NULL,'{\"title\":\"Updated API Dog Material\",\"description\":\"Updated by test\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE courses via PUT /api/courses/1/materials/46','2026-03-16 20:20:06'),(92,59,'UPDATE','courses',15,NULL,'{\"isPublished\":true}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE courses via PATCH /api/courses/1/materials/15/visibility','2026-03-16 20:20:06'),(93,59,'CREATE','courses',15,NULL,'{}','127.0.0.1','PostmanRuntime/7.52.0','CREATE courses via POST /api/courses/1/materials/15/view','2026-03-16 20:20:06'),(94,59,'DELETE','courses',46,NULL,NULL,'127.0.0.1','PostmanRuntime/7.52.0','DELETE courses via DELETE /api/courses/1/materials/46','2026-03-16 20:20:06'),(95,59,'CREATE','courses',1,NULL,'{\"title\":\"Week 10: API Dog Test\",\"organizationType\":\"lecture\",\"weekNumber\":10,\"orderIndex\":99}','127.0.0.1','PostmanRuntime/7.52.0','CREATE courses via POST /api/courses/1/structure','2026-03-16 20:20:06'),(96,59,'UPDATE','courses',20,NULL,'{\"title\":\"Week 10: Updated\",\"description\":\"Updated by API Dog\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE courses via PUT /api/courses/1/structure/20','2026-03-16 20:20:07'),(97,59,'UPDATE','courses',1,NULL,'{\"orderIds\":[7,8,9,10,11,12]}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE courses via PATCH /api/courses/1/structure/reorder','2026-03-16 20:20:07'),(98,59,'DELETE','courses',20,NULL,NULL,'127.0.0.1','PostmanRuntime/7.52.0','DELETE courses via DELETE /api/courses/1/structure/20','2026-03-16 20:20:07'),(99,59,'CREATE','announcements',NULL,NULL,'{\"title\":\"API Dog Test Announcement\",\"content\":\"This is a test announcement from API Dog.\",\"courseId\":1,\"priority\":\"medium\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE announcements via POST /api/announcements','2026-03-16 20:20:08'),(100,59,'UPDATE','announcements',1,NULL,'{\"title\":\"Updated: Welcome to CS101!\",\"content\":\"Updated announcement content.\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE announcements via PUT /api/announcements/1','2026-03-16 20:20:08'),(101,59,'UPDATE','announcements',1,NULL,'{}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE announcements via PATCH /api/announcements/1/publish','2026-03-16 20:20:08'),(102,59,'UPDATE','announcements',1,NULL,'{\"isPinned\":true}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE announcements via PATCH /api/announcements/1/pin','2026-03-16 20:20:08'),(103,59,'CREATE','assignments',NULL,NULL,'{\"courseId\":1,\"title\":\"API Dog Test Assignment\",\"description\":\"Test assignment from API Dog\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE assignments via POST /api/assignments','2026-03-16 20:20:08'),(104,59,'UPDATE','assignments',1,NULL,'{\"title\":\"Updated Assignment Title\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE assignments via PATCH /api/assignments/1','2026-03-16 20:20:09'),(105,59,'CREATE','discussions',NULL,NULL,'{\"courseId\":1,\"title\":\"API Dog Test Discussion\",\"description\":\"Testing from API Dog.\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE discussions via POST /api/discussions','2026-03-16 20:20:09'),(106,59,'UPDATE','discussions',3,NULL,'{\"title\":\"Updated Discussion Title\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE discussions via PUT /api/discussions/3','2026-03-16 20:20:09'),(107,59,'UPDATE','discussions',3,NULL,'{\"isPinned\":true}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE discussions via PATCH /api/discussions/3/pin','2026-03-16 20:20:09'),(108,59,'UPDATE','discussions',3,NULL,'{\"isLocked\":true}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE discussions via PATCH /api/discussions/3/lock','2026-03-16 20:20:09'),(109,59,'CREATE','community',NULL,NULL,'{\"title\":\"API Dog Test Post\",\"content\":\"Testing from API Dog.\",\"communityId\":1}','127.0.0.1','PostmanRuntime/7.52.0','CREATE community via POST /api/community/communities/1/posts','2026-03-16 20:20:10'),(110,59,'CREATE','community',NULL,NULL,'{\"title\":\"Global Post from API Dog\",\"content\":\"Test global post.\",\"communityId\":1}','127.0.0.1','PostmanRuntime/7.52.0','CREATE community via POST /api/community/global/posts','2026-03-16 20:20:10'),(111,59,'CREATE','community',3,NULL,'{\"commentText\":\"API Dog test comment\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE community via POST /api/community/posts/3/comment','2026-03-16 20:20:10'),(112,59,'CREATE','community',3,NULL,'{\"reactionType\":\"like\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE community via POST /api/community/posts/3/react','2026-03-16 20:20:11'),(113,59,'CREATE','files',NULL,NULL,'{\"folderName\":\"API Dog Test Folder\",\"parentFolderId\":1}','127.0.0.1','PostmanRuntime/7.52.0','CREATE files via POST /api/files/folders','2026-03-16 20:20:12'),(114,59,'UPDATE','files',NULL,NULL,'{\"folderName\":\"Updated Test Folder\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE files via PUT /api/files/folders/22','2026-03-16 20:20:12'),(115,59,'DELETE','files',NULL,NULL,NULL,'127.0.0.1','PostmanRuntime/7.52.0','DELETE files via DELETE /api/files/folders/22','2026-03-16 20:20:12'),(116,59,'CREATE','labs',NULL,NULL,'{\"title\":\"API Dog Test Lab\",\"courseId\":1,\"description\":\"Test lab\",\"dueDate\":\"2026-06-15T23:59:00Z\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE labs via POST /api/labs','2026-03-16 20:20:13'),(117,59,'UPDATE','labs',3,NULL,'{\"title\":\"Updated Lab Title\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE labs via PUT /api/labs/3','2026-03-16 20:20:13'),(118,58,'CREATE','rubrics',NULL,NULL,'{\"rubricName\":\"API Dog Test Rubric\",\"courseId\":1,\"totalPoints\":100}','127.0.0.1','PostmanRuntime/7.52.0','CREATE rubrics via POST /api/rubrics','2026-03-16 20:20:14'),(119,59,'CREATE','attendance',NULL,NULL,'{\"sectionId\":1,\"sessionDate\":\"2026-03-15\",\"sessionType\":\"lecture\",\"startTime\":\"09:00:00\",\"endTime\":\"10:30:00\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE attendance via POST /attendance/sessions','2026-03-16 20:20:15'),(120,57,'UPDATE','notifications',NULL,NULL,'{\"emailEnabled\":true,\"pushEnabled\":true}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE notifications via PUT /api/notifications/preferences','2026-03-16 20:20:15'),(121,57,'UPDATE','notifications',NULL,NULL,'{}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE notifications via PATCH /api/notifications/read-all','2026-03-16 20:20:15'),(122,59,'CREATE','notifications',NULL,NULL,'{\"userIds\":[57],\"notificationType\":\"system\",\"title\":\"Test from API Dog\",\"body\":\"This is a test notification.\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE notifications via POST /api/notifications/send','2026-03-16 20:20:15'),(123,57,'CREATE','messages',NULL,NULL,'{\"participantIds\":[59],\"type\":\"direct\",\"text\":\"Hello from API Dog test!\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE messages via POST /api/messages/conversations','2026-03-16 20:20:16'),(124,59,'CREATE','calendar',NULL,NULL,'{\"title\":\"API Dog Test Event\",\"description\":\"Test\",\"startTime\":\"2026-04-01T10:00:00Z\",\"endTime\":\"2026-04-01T11:00:00Z\",\"eventType\":\"meeting\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE calendar via POST /api/calendar/events','2026-03-16 20:20:17'),(125,59,'DELETE','calendar',13,NULL,NULL,'127.0.0.1','PostmanRuntime/7.52.0','DELETE calendar via DELETE /api/calendar/events/13','2026-03-16 20:20:17'),(126,57,'CREATE','tasks',NULL,NULL,'{\"title\":\"Study for Final Exam\",\"description\":\"Review all chapters\",\"taskType\":\"study\",\"dueDate\":\"2026-03-18T18:14:01.673Z\",\"priority\":\"high\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE tasks via POST /api/tasks','2026-03-16 20:20:17'),(127,57,'CREATE','tasks',8,NULL,'{\"notes\":\"Finished studying all chapters\",\"timeTakenMinutes\":120}','127.0.0.1','PostmanRuntime/7.52.0','CREATE tasks via POST /api/tasks/8/complete','2026-03-16 20:20:18'),(128,57,'CREATE','tasks',NULL,NULL,'{\"taskId\":9,\"reminderTime\":\"2026-03-17T18:14:01.673Z\",\"reminderType\":\"in_app\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE tasks via POST /api/tasks/reminders','2026-03-16 20:20:18'),(129,57,'DELETE','search',NULL,NULL,NULL,'127.0.0.1','PostmanRuntime/7.52.0','DELETE search via DELETE /api/search/history','2026-03-16 20:20:19'),(130,59,'CREATE','reports',NULL,NULL,'{\"templateId\":1,\"reportName\":\"Test Student Progress Report\",\"filters\":{\"courseId\":1,\"semesterId\":2},\"exportFormat\":\"pdf\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE reports via POST /api/reports/generate','2026-03-16 20:20:20'),(131,NULL,'CREATE','google-drive',NULL,NULL,'{\"name\":\"EduVerse_Test_Folder\",\"parentId\":\"\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE google-drive via POST /google-drive/folders','2026-03-16 20:20:21'),(132,NULL,'CREATE','google-drive',NULL,NULL,'{\"name\":\"EduVerse_Test_Folder\",\"parentId\":\"\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE google-drive via POST /google-drive/folders/find-or-create','2026-03-16 20:20:22'),(133,NULL,'CREATE','auth',NULL,NULL,'{\"email\":\"amir_admin@example.com\",\"password\":\"Pass@123\",\"rememberMe\":false}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','CREATE auth via POST /api/auth/login','2026-03-16 20:29:01'),(134,66,'CREATE','google-drive',NULL,NULL,NULL,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','CREATE google-drive via POST /google-drive/admin/init','2026-03-16 20:29:14'),(135,NULL,'CREATE','google-drive',NULL,NULL,'{\"name\":\"Course_Materials_2\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','CREATE google-drive via POST /google-drive/folders','2026-03-16 20:29:51'),(136,NULL,'CREATE','google-drive',NULL,NULL,'{\"folderId\":\"1G0IX197-VAZ7KpiRe6YZHk0mwy1cd-8j\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','CREATE google-drive via POST /google-drive/files/upload','2026-03-16 20:30:11'),(137,66,'CREATE','courses',1,NULL,'{\"title\":\"Week 1 Lecture Notes: Introduction to Data Structures\",\"description\":\"Comprehensive lecture notes covering the basics.\",\"materialType\":\"lecture\",\"weekNumber\":\"1\",\"orderIndex\":\"0\",\"isPublished\":\"false\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','CREATE courses via POST /api/courses/1/materials/document','2026-03-16 20:31:41'),(138,NULL,'CREATE','auth',NULL,NULL,'{\"email\":\"admin.tarek@example.com\",\"password\":\"SecureP@ss123\",\"rememberMe\":true}','127.0.0.1','PostmanRuntime/7.52.0','CREATE auth via POST /api/auth/login','2026-03-16 20:32:40'),(139,NULL,'CREATE','auth',NULL,NULL,'{\"email\":\"instructor.tarek@example.com\",\"password\":\"SecureP@ss123\",\"rememberMe\":true}','127.0.0.1','PostmanRuntime/7.52.0','CREATE auth via POST /api/auth/login','2026-03-16 20:32:40'),(140,NULL,'CREATE','auth',NULL,NULL,'{\"email\":\"student.tarek@example.com\",\"password\":\"SecureP@ss123\",\"rememberMe\":true}','127.0.0.1','PostmanRuntime/7.52.0','CREATE auth via POST /api/auth/login','2026-03-16 20:32:40'),(141,NULL,'CREATE','auth',NULL,NULL,'{\"email\":\"ta.tarek@example.com\",\"password\":\"SecureP@ss123\",\"rememberMe\":true}','127.0.0.1','PostmanRuntime/7.52.0','CREATE auth via POST /api/auth/login','2026-03-16 20:32:40'),(142,NULL,'CREATE','auth',NULL,NULL,'{\"email\":\"it_admin.tarek@example.com\",\"password\":\"SecureP@ss123\",\"rememberMe\":true}','127.0.0.1','PostmanRuntime/7.52.0','CREATE auth via POST /api/auth/login','2026-03-16 20:32:41'),(143,NULL,'CREATE','auth',NULL,NULL,'{\"refreshToken\":\"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzczNjkzMTYwLCJleHAiOjE3NzYyODUxNjB9.tZtIiKoYxmS5T2BTT8xwOXYYDgAoY0ZJYyUF3oVuNqw\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE auth via POST /api/auth/refresh-token','2026-03-16 20:32:41'),(144,57,'UPDATE','users',NULL,NULL,'{\"firstName\":\"Student\",\"lastName\":\"Tarek\",\"phone\":\"+201234567890\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE users via PUT /api/users/profile','2026-03-16 20:32:41'),(145,57,'UPDATE','users',NULL,NULL,'{\"theme\":\"dark\",\"language\":\"en\",\"emailNotifications\":true,\"pushNotifications\":true}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE users via PUT /api/users/preferences','2026-03-16 20:32:41'),(146,57,'UPDATE','users',NULL,NULL,'{\"currentPassword\":\"SecureP@ss123\",\"newPassword\":\"SecureP@ss123\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE users via PATCH /api/users/password','2026-03-16 20:32:41'),(147,59,'UPDATE','admin',57,NULL,'{\"firstName\":\"Student\",\"lastName\":\"Tarek\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE admin via PUT /api/admin/users/57','2026-03-16 20:32:42'),(148,59,'UPDATE','campuses',1,NULL,'{\"name\":\"Updated Campus Name\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE campuses via PUT /api/campuses/1','2026-03-16 20:32:43'),(149,59,'UPDATE','departments',1,NULL,'{\"name\":\"Updated Department\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE departments via PUT /api/departments/1','2026-03-16 20:32:43'),(150,59,'UPDATE','programs',1,NULL,'{\"name\":\"Updated Program\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE programs via PUT /api/programs/1','2026-03-16 20:32:44'),(151,NULL,'CREATE','sections',NULL,NULL,'{\"courseId\":1,\"semesterId\":2,\"sectionNumber\":\"913\",\"maxCapacity\":30,\"location\":\"Room TEST\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE sections via POST /api/sections','2026-03-16 20:32:45'),(152,59,'CREATE','courses',1,NULL,'{\"title\":\"API Dog Test Material\",\"materialType\":\"document\",\"description\":\"Created by API Dog test\",\"weekNumber\":1,\"isPublished\":true}','127.0.0.1','PostmanRuntime/7.52.0','CREATE courses via POST /api/courses/1/materials','2026-03-16 20:32:46'),(153,59,'CREATE','courses',1,NULL,'{\"materials\":[{\"title\":\"Bulk Test 1\",\"materialType\":\"lecture\",\"weekNumber\":10,\"isPublished\":true},{\"title\":\"Bulk Test 2\",\"materialType\":\"slide\",\"weekNumber\":10,\"isPublished\":true}]}','127.0.0.1','PostmanRuntime/7.52.0','CREATE courses via POST /api/courses/1/materials/bulk','2026-03-16 20:32:46'),(154,59,'UPDATE','courses',50,NULL,'{\"title\":\"Updated API Dog Material\",\"description\":\"Updated by test\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE courses via PUT /api/courses/1/materials/50','2026-03-16 20:32:46'),(155,59,'UPDATE','courses',15,NULL,'{\"isPublished\":true}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE courses via PATCH /api/courses/1/materials/15/visibility','2026-03-16 20:32:47'),(156,59,'CREATE','courses',15,NULL,'{}','127.0.0.1','PostmanRuntime/7.52.0','CREATE courses via POST /api/courses/1/materials/15/view','2026-03-16 20:32:47'),(157,59,'DELETE','courses',50,NULL,NULL,'127.0.0.1','PostmanRuntime/7.52.0','DELETE courses via DELETE /api/courses/1/materials/50','2026-03-16 20:32:47'),(158,59,'CREATE','courses',1,NULL,'{\"title\":\"Week 10: API Dog Test\",\"organizationType\":\"lecture\",\"weekNumber\":10,\"orderIndex\":99}','127.0.0.1','PostmanRuntime/7.52.0','CREATE courses via POST /api/courses/1/structure','2026-03-16 20:32:47'),(159,59,'UPDATE','courses',21,NULL,'{\"title\":\"Week 10: Updated\",\"description\":\"Updated by API Dog\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE courses via PUT /api/courses/1/structure/21','2026-03-16 20:32:47'),(160,59,'UPDATE','courses',1,NULL,'{\"orderIds\":[7,8,9,10,11,12]}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE courses via PATCH /api/courses/1/structure/reorder','2026-03-16 20:32:47'),(161,59,'DELETE','courses',21,NULL,NULL,'127.0.0.1','PostmanRuntime/7.52.0','DELETE courses via DELETE /api/courses/1/structure/21','2026-03-16 20:32:48'),(162,59,'CREATE','announcements',NULL,NULL,'{\"title\":\"API Dog Test Announcement\",\"content\":\"This is a test announcement from API Dog.\",\"courseId\":1,\"priority\":\"medium\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE announcements via POST /api/announcements','2026-03-16 20:32:49'),(163,59,'UPDATE','announcements',1,NULL,'{\"title\":\"Updated: Welcome to CS101!\",\"content\":\"Updated announcement content.\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE announcements via PUT /api/announcements/1','2026-03-16 20:32:49'),(164,59,'UPDATE','announcements',1,NULL,'{}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE announcements via PATCH /api/announcements/1/publish','2026-03-16 20:32:49'),(165,59,'UPDATE','announcements',1,NULL,'{\"isPinned\":true}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE announcements via PATCH /api/announcements/1/pin','2026-03-16 20:32:49'),(166,59,'CREATE','assignments',NULL,NULL,'{\"courseId\":1,\"title\":\"API Dog Test Assignment\",\"description\":\"Test assignment from API Dog\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE assignments via POST /api/assignments','2026-03-16 20:32:50'),(167,59,'UPDATE','assignments',1,NULL,'{\"title\":\"Updated Assignment Title\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE assignments via PATCH /api/assignments/1','2026-03-16 20:32:50'),(168,59,'CREATE','discussions',NULL,NULL,'{\"courseId\":1,\"title\":\"API Dog Test Discussion\",\"description\":\"Testing from API Dog.\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE discussions via POST /api/discussions','2026-03-16 20:32:50'),(169,59,'UPDATE','discussions',3,NULL,'{\"title\":\"Updated Discussion Title\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE discussions via PUT /api/discussions/3','2026-03-16 20:32:50'),(170,59,'CREATE','discussions',3,NULL,'{\"messageText\":\"Test reply from API Dog.\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE discussions via POST /api/discussions/3/reply','2026-03-16 20:32:50'),(171,59,'UPDATE','discussions',3,NULL,'{\"isPinned\":true}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE discussions via PATCH /api/discussions/3/pin','2026-03-16 20:32:50'),(172,59,'UPDATE','discussions',3,NULL,'{\"isLocked\":true}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE discussions via PATCH /api/discussions/3/lock','2026-03-16 20:32:51'),(173,59,'CREATE','community',NULL,NULL,'{\"title\":\"API Dog Test Post\",\"content\":\"Testing from API Dog.\",\"communityId\":1}','127.0.0.1','PostmanRuntime/7.52.0','CREATE community via POST /api/community/communities/1/posts','2026-03-16 20:32:51'),(174,59,'CREATE','community',NULL,NULL,'{\"title\":\"Global Post from API Dog\",\"content\":\"Test global post.\",\"communityId\":1}','127.0.0.1','PostmanRuntime/7.52.0','CREATE community via POST /api/community/global/posts','2026-03-16 20:32:51'),(175,59,'CREATE','community',3,NULL,'{\"commentText\":\"API Dog test comment\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE community via POST /api/community/posts/3/comment','2026-03-16 20:32:52'),(176,59,'CREATE','community',3,NULL,'{\"reactionType\":\"like\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE community via POST /api/community/posts/3/react','2026-03-16 20:32:52'),(177,59,'CREATE','files',NULL,NULL,'{\"folderName\":\"API Dog Test Folder\",\"parentFolderId\":1}','127.0.0.1','PostmanRuntime/7.52.0','CREATE files via POST /api/files/folders','2026-03-16 20:32:53'),(178,59,'UPDATE','files',NULL,NULL,'{\"folderName\":\"Updated Test Folder\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE files via PUT /api/files/folders/23','2026-03-16 20:32:53'),(179,59,'DELETE','files',NULL,NULL,NULL,'127.0.0.1','PostmanRuntime/7.52.0','DELETE files via DELETE /api/files/folders/23','2026-03-16 20:32:53'),(180,59,'CREATE','labs',NULL,NULL,'{\"title\":\"API Dog Test Lab\",\"courseId\":1,\"description\":\"Test lab\",\"dueDate\":\"2026-06-15T23:59:00Z\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE labs via POST /api/labs','2026-03-16 20:32:54'),(181,59,'UPDATE','labs',3,NULL,'{\"title\":\"Updated Lab Title\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE labs via PUT /api/labs/3','2026-03-16 20:32:54'),(182,58,'CREATE','rubrics',NULL,NULL,'{\"rubricName\":\"API Dog Test Rubric\",\"courseId\":1,\"totalPoints\":100}','127.0.0.1','PostmanRuntime/7.52.0','CREATE rubrics via POST /api/rubrics','2026-03-16 20:32:56'),(183,59,'CREATE','attendance',NULL,NULL,'{\"sectionId\":1,\"sessionDate\":\"2026-03-15\",\"sessionType\":\"lecture\",\"startTime\":\"09:00:00\",\"endTime\":\"10:30:00\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE attendance via POST /attendance/sessions','2026-03-16 20:32:56'),(184,57,'UPDATE','notifications',NULL,NULL,'{\"emailEnabled\":true,\"pushEnabled\":true}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE notifications via PUT /api/notifications/preferences','2026-03-16 20:32:57'),(185,57,'UPDATE','notifications',NULL,NULL,'{}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE notifications via PATCH /api/notifications/read-all','2026-03-16 20:32:57'),(186,59,'CREATE','notifications',NULL,NULL,'{\"userIds\":[57],\"notificationType\":\"system\",\"title\":\"Test from API Dog\",\"body\":\"This is a test notification.\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE notifications via POST /api/notifications/send','2026-03-16 20:32:57'),(187,57,'CREATE','messages',NULL,NULL,'{\"participantIds\":[59],\"type\":\"direct\",\"text\":\"Hello from API Dog test!\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE messages via POST /api/messages/conversations','2026-03-16 20:32:57'),(188,59,'CREATE','calendar',NULL,NULL,'{\"title\":\"API Dog Test Event\",\"description\":\"Test\",\"startTime\":\"2026-04-01T10:00:00Z\",\"endTime\":\"2026-04-01T11:00:00Z\",\"eventType\":\"meeting\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE calendar via POST /api/calendar/events','2026-03-16 20:32:58'),(189,59,'DELETE','calendar',14,NULL,NULL,'127.0.0.1','PostmanRuntime/7.52.0','DELETE calendar via DELETE /api/calendar/events/14','2026-03-16 20:32:58'),(190,57,'CREATE','tasks',NULL,NULL,'{\"title\":\"Study for Final Exam\",\"description\":\"Review all chapters\",\"taskType\":\"study\",\"dueDate\":\"2026-03-18T18:14:01.673Z\",\"priority\":\"high\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE tasks via POST /api/tasks','2026-03-16 20:32:59'),(191,57,'CREATE','tasks',8,NULL,'{\"notes\":\"Finished studying all chapters\",\"timeTakenMinutes\":120}','127.0.0.1','PostmanRuntime/7.52.0','CREATE tasks via POST /api/tasks/8/complete','2026-03-16 20:32:59'),(192,57,'CREATE','tasks',NULL,NULL,'{\"taskId\":9,\"reminderTime\":\"2026-03-17T18:14:01.673Z\",\"reminderType\":\"in_app\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE tasks via POST /api/tasks/reminders','2026-03-16 20:33:00'),(193,57,'DELETE','search',NULL,NULL,NULL,'127.0.0.1','PostmanRuntime/7.52.0','DELETE search via DELETE /api/search/history','2026-03-16 20:33:00'),(194,59,'CREATE','reports',NULL,NULL,'{\"templateId\":1,\"reportName\":\"Test Student Progress Report\",\"filters\":{\"courseId\":1,\"semesterId\":2},\"exportFormat\":\"pdf\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE reports via POST /api/reports/generate','2026-03-16 20:33:02'),(195,NULL,'CREATE','google-drive',NULL,NULL,'{\"name\":\"EduVerse_Test_Folder\",\"parentId\":\"\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE google-drive via POST /google-drive/folders','2026-03-16 20:33:03'),(196,NULL,'CREATE','google-drive',NULL,NULL,'{\"name\":\"EduVerse_Test_Folder\",\"parentId\":\"\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE google-drive via POST /google-drive/folders/find-or-create','2026-03-16 20:33:03'),(197,59,'CREATE','google-drive',NULL,NULL,NULL,'127.0.0.1','PostmanRuntime/7.52.0','CREATE google-drive via POST /google-drive/admin/init','2026-03-16 20:33:04'),(198,59,'CREATE','google-drive',1,NULL,NULL,'127.0.0.1','PostmanRuntime/7.52.0','CREATE google-drive via POST /google-drive/admin/courses/1/init','2026-03-16 20:33:05'),(199,59,'CREATE','google-drive',NULL,NULL,NULL,'127.0.0.1','PostmanRuntime/7.52.0','CREATE google-drive via POST /google-drive/admin/labs/3/init','2026-03-16 20:33:15'),(200,59,'CREATE','google-drive',NULL,NULL,NULL,'127.0.0.1','PostmanRuntime/7.52.0','CREATE google-drive via POST /google-drive/admin/assignments/1/init','2026-03-16 20:33:18'),(201,59,'UPDATE','admin',57,NULL,'{\"firstName\":\"Student\",\"lastName\":\"Tarek\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE admin via PUT /api/admin/users/57','2026-03-16 20:34:07'),(202,59,'UPDATE','campuses',1,NULL,'{\"name\":\"Updated Campus Name\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE campuses via PUT /api/campuses/1','2026-03-16 20:34:08'),(203,59,'UPDATE','departments',1,NULL,'{\"name\":\"Updated Department\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE departments via PUT /api/departments/1','2026-03-16 20:34:08'),(204,59,'UPDATE','programs',1,NULL,'{\"name\":\"Updated Program\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE programs via PUT /api/programs/1','2026-03-16 20:34:08'),(205,NULL,'CREATE','sections',NULL,NULL,'{\"courseId\":1,\"semesterId\":2,\"sectionNumber\":\"888\",\"maxCapacity\":30,\"location\":\"Room TEST\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE sections via POST /api/sections','2026-03-16 20:34:09'),(206,NULL,'CREATE','auth',NULL,NULL,'{\"email\":\"amir_admin@example.com\",\"password\":\"Pass@123\",\"rememberMe\":false}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','CREATE auth via POST /api/auth/login','2026-03-16 20:34:32'),(207,NULL,'CREATE','auth',NULL,NULL,'{\"email\":\"amir_itadmin@example.com\",\"password\":\"Pass@123\",\"rememberMe\":false}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','CREATE auth via POST /api/auth/login','2026-03-16 20:34:43'),(208,NULL,'CREATE','auth',NULL,NULL,'{\"email\":\"admin.tarek@example.com\",\"password\":\"SecureP@ss123\",\"rememberMe\":true}','127.0.0.1','PostmanRuntime/7.52.0','CREATE auth via POST /api/auth/login','2026-03-16 20:44:46'),(209,NULL,'CREATE','auth',NULL,NULL,'{\"email\":\"instructor.tarek@example.com\",\"password\":\"SecureP@ss123\",\"rememberMe\":true}','127.0.0.1','PostmanRuntime/7.52.0','CREATE auth via POST /api/auth/login','2026-03-16 20:44:47'),(210,NULL,'CREATE','auth',NULL,NULL,'{\"email\":\"student.tarek@example.com\",\"password\":\"SecureP@ss123\",\"rememberMe\":true}','127.0.0.1','PostmanRuntime/7.52.0','CREATE auth via POST /api/auth/login','2026-03-16 20:44:47'),(211,NULL,'CREATE','auth',NULL,NULL,'{\"email\":\"ta.tarek@example.com\",\"password\":\"SecureP@ss123\",\"rememberMe\":true}','127.0.0.1','PostmanRuntime/7.52.0','CREATE auth via POST /api/auth/login','2026-03-16 20:44:47'),(212,NULL,'CREATE','auth',NULL,NULL,'{\"email\":\"it_admin.tarek@example.com\",\"password\":\"SecureP@ss123\",\"rememberMe\":true}','127.0.0.1','PostmanRuntime/7.52.0','CREATE auth via POST /api/auth/login','2026-03-16 20:44:47'),(213,NULL,'CREATE','auth',NULL,NULL,'{\"refreshToken\":\"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzczNjkzODg2LCJleHAiOjE3NzYyODU4ODZ9.GPneqykk8cYF7P5YbkWxcS9USNU3vNlnUWBaEPSAZ1Y\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE auth via POST /api/auth/refresh-token','2026-03-16 20:44:47'),(214,NULL,'CREATE','auth',NULL,NULL,'{\"email\":\"admin.tarek@example.com\",\"password\":\"SecureP@ss123\",\"rememberMe\":true}','127.0.0.1','PostmanRuntime/7.52.0','CREATE auth via POST /api/auth/login','2026-03-16 20:45:05'),(215,NULL,'CREATE','auth',NULL,NULL,'{\"email\":\"instructor.tarek@example.com\",\"password\":\"SecureP@ss123\",\"rememberMe\":true}','127.0.0.1','PostmanRuntime/7.52.0','CREATE auth via POST /api/auth/login','2026-03-16 20:45:06'),(216,NULL,'CREATE','auth',NULL,NULL,'{\"email\":\"student.tarek@example.com\",\"password\":\"SecureP@ss123\",\"rememberMe\":true}','127.0.0.1','PostmanRuntime/7.52.0','CREATE auth via POST /api/auth/login','2026-03-16 20:45:06'),(217,NULL,'CREATE','auth',NULL,NULL,'{\"email\":\"ta.tarek@example.com\",\"password\":\"SecureP@ss123\",\"rememberMe\":true}','127.0.0.1','PostmanRuntime/7.52.0','CREATE auth via POST /api/auth/login','2026-03-16 20:45:06'),(218,NULL,'CREATE','auth',NULL,NULL,'{\"email\":\"it_admin.tarek@example.com\",\"password\":\"SecureP@ss123\",\"rememberMe\":true}','127.0.0.1','PostmanRuntime/7.52.0','CREATE auth via POST /api/auth/login','2026-03-16 20:45:06'),(219,NULL,'CREATE','auth',NULL,NULL,'{\"refreshToken\":\"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzczNjkzOTA1LCJleHAiOjE3NzYyODU5MDV9.G9LE-UkgRm7jba6ny4XWg6Q5iD6eg8uM-58Ux9Qvh-Q\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE auth via POST /api/auth/refresh-token','2026-03-16 20:45:06'),(220,57,'UPDATE','users',NULL,NULL,'{\"firstName\":\"Student\",\"lastName\":\"Tarek\",\"phone\":\"+201234567890\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE users via PUT /api/users/profile','2026-03-16 20:45:07'),(221,57,'UPDATE','users',NULL,NULL,'{\"theme\":\"dark\",\"language\":\"en\",\"emailNotifications\":true,\"pushNotifications\":true}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE users via PUT /api/users/preferences','2026-03-16 20:45:07'),(222,57,'UPDATE','users',NULL,NULL,'{\"currentPassword\":\"SecureP@ss123\",\"newPassword\":\"SecureP@ss123\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE users via PATCH /api/users/password','2026-03-16 20:45:07'),(223,59,'UPDATE','admin',57,NULL,'{\"firstName\":\"Student\",\"lastName\":\"Tarek\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE admin via PUT /api/admin/users/57','2026-03-16 20:45:08'),(224,59,'UPDATE','campuses',1,NULL,'{\"name\":\"Updated Campus Name\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE campuses via PUT /api/campuses/1','2026-03-16 20:45:09'),(225,59,'UPDATE','departments',1,NULL,'{\"name\":\"Updated Department\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE departments via PUT /api/departments/1','2026-03-16 20:45:09'),(226,59,'UPDATE','programs',1,NULL,'{\"name\":\"Updated Program\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE programs via PUT /api/programs/1','2026-03-16 20:45:09'),(227,NULL,'CREATE','sections',NULL,NULL,'{\"courseId\":1,\"semesterId\":2,\"sectionNumber\":\"902\",\"maxCapacity\":30,\"location\":\"Room TEST\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE sections via POST /api/sections','2026-03-16 20:45:10'),(228,59,'CREATE','courses',1,NULL,'{\"title\":\"API Dog Test Material\",\"materialType\":\"document\",\"description\":\"Created by API Dog test\",\"weekNumber\":1,\"isPublished\":true}','127.0.0.1','PostmanRuntime/7.52.0','CREATE courses via POST /api/courses/1/materials','2026-03-16 20:45:12'),(229,59,'CREATE','courses',1,NULL,'{\"materials\":[{\"title\":\"Bulk Test 1\",\"materialType\":\"lecture\",\"weekNumber\":10,\"isPublished\":true},{\"title\":\"Bulk Test 2\",\"materialType\":\"slide\",\"weekNumber\":10,\"isPublished\":true}]}','127.0.0.1','PostmanRuntime/7.52.0','CREATE courses via POST /api/courses/1/materials/bulk','2026-03-16 20:45:12'),(230,59,'UPDATE','courses',53,NULL,'{\"title\":\"Updated API Dog Material\",\"description\":\"Updated by test\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE courses via PUT /api/courses/1/materials/53','2026-03-16 20:45:12'),(231,59,'UPDATE','courses',15,NULL,'{\"isPublished\":true}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE courses via PATCH /api/courses/1/materials/15/visibility','2026-03-16 20:45:12'),(232,59,'CREATE','courses',15,NULL,'{}','127.0.0.1','PostmanRuntime/7.52.0','CREATE courses via POST /api/courses/1/materials/15/view','2026-03-16 20:45:12'),(233,59,'DELETE','courses',53,NULL,NULL,'127.0.0.1','PostmanRuntime/7.52.0','DELETE courses via DELETE /api/courses/1/materials/53','2026-03-16 20:45:13'),(234,59,'CREATE','courses',1,NULL,'{\"title\":\"Week 10: API Dog Test\",\"organizationType\":\"lecture\",\"weekNumber\":10,\"orderIndex\":99}','127.0.0.1','PostmanRuntime/7.52.0','CREATE courses via POST /api/courses/1/structure','2026-03-16 20:45:13'),(235,59,'UPDATE','courses',22,NULL,'{\"title\":\"Week 10: Updated\",\"description\":\"Updated by API Dog\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE courses via PUT /api/courses/1/structure/22','2026-03-16 20:45:13'),(236,59,'UPDATE','courses',1,NULL,'{\"orderIds\":[7,8,9,10,11,12]}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE courses via PATCH /api/courses/1/structure/reorder','2026-03-16 20:45:13'),(237,59,'DELETE','courses',22,NULL,NULL,'127.0.0.1','PostmanRuntime/7.52.0','DELETE courses via DELETE /api/courses/1/structure/22','2026-03-16 20:45:13'),(238,59,'CREATE','announcements',NULL,NULL,'{\"title\":\"API Dog Test Announcement\",\"content\":\"This is a test announcement from API Dog.\",\"courseId\":1,\"priority\":\"medium\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE announcements via POST /api/announcements','2026-03-16 20:45:15'),(239,59,'UPDATE','announcements',1,NULL,'{\"title\":\"Updated: Welcome to CS101!\",\"content\":\"Updated announcement content.\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE announcements via PUT /api/announcements/1','2026-03-16 20:45:15'),(240,59,'UPDATE','announcements',1,NULL,'{}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE announcements via PATCH /api/announcements/1/publish','2026-03-16 20:45:15'),(241,59,'UPDATE','announcements',1,NULL,'{\"isPinned\":true}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE announcements via PATCH /api/announcements/1/pin','2026-03-16 20:45:15'),(242,59,'CREATE','assignments',NULL,NULL,'{\"courseId\":1,\"title\":\"API Dog Test Assignment\",\"description\":\"Test assignment from API Dog\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE assignments via POST /api/assignments','2026-03-16 20:45:15'),(243,59,'UPDATE','assignments',1,NULL,'{\"title\":\"Updated Assignment Title\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE assignments via PATCH /api/assignments/1','2026-03-16 20:45:15'),(244,59,'CREATE','discussions',NULL,NULL,'{\"courseId\":1,\"title\":\"API Dog Test Discussion\",\"description\":\"Testing from API Dog.\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE discussions via POST /api/discussions','2026-03-16 20:45:16'),(245,59,'UPDATE','discussions',3,NULL,'{\"title\":\"Updated Discussion Title\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE discussions via PUT /api/discussions/3','2026-03-16 20:45:16'),(246,59,'UPDATE','discussions',3,NULL,'{\"isPinned\":true}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE discussions via PATCH /api/discussions/3/pin','2026-03-16 20:45:16'),(247,59,'UPDATE','discussions',3,NULL,'{\"isLocked\":true}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE discussions via PATCH /api/discussions/3/lock','2026-03-16 20:45:16'),(248,59,'CREATE','community',NULL,NULL,'{\"title\":\"API Dog Test Post\",\"content\":\"Testing from API Dog.\",\"communityId\":1}','127.0.0.1','PostmanRuntime/7.52.0','CREATE community via POST /api/community/communities/1/posts','2026-03-16 20:45:17'),(249,59,'CREATE','community',NULL,NULL,'{\"title\":\"Global Post from API Dog\",\"content\":\"Test global post.\",\"communityId\":1}','127.0.0.1','PostmanRuntime/7.52.0','CREATE community via POST /api/community/global/posts','2026-03-16 20:45:17'),(250,59,'CREATE','community',3,NULL,'{\"commentText\":\"API Dog test comment\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE community via POST /api/community/posts/3/comment','2026-03-16 20:45:17'),(251,59,'CREATE','community',3,NULL,'{\"reactionType\":\"like\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE community via POST /api/community/posts/3/react','2026-03-16 20:45:18'),(252,59,'CREATE','files',NULL,NULL,'{\"folderName\":\"API Dog Test Folder\",\"parentFolderId\":1}','127.0.0.1','PostmanRuntime/7.52.0','CREATE files via POST /api/files/folders','2026-03-16 20:45:19'),(253,59,'UPDATE','files',NULL,NULL,'{\"folderName\":\"Updated Test Folder\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE files via PUT /api/files/folders/24','2026-03-16 20:45:19'),(254,59,'DELETE','files',NULL,NULL,NULL,'127.0.0.1','PostmanRuntime/7.52.0','DELETE files via DELETE /api/files/folders/24','2026-03-16 20:45:19'),(255,59,'CREATE','labs',NULL,NULL,'{\"title\":\"API Dog Test Lab\",\"courseId\":1,\"description\":\"Test lab\",\"dueDate\":\"2026-06-15T23:59:00Z\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE labs via POST /api/labs','2026-03-16 20:45:20'),(256,59,'UPDATE','labs',3,NULL,'{\"title\":\"Updated Lab Title\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE labs via PUT /api/labs/3','2026-03-16 20:45:20'),(257,58,'CREATE','rubrics',NULL,NULL,'{\"rubricName\":\"API Dog Test Rubric\",\"courseId\":1,\"totalPoints\":100}','127.0.0.1','PostmanRuntime/7.52.0','CREATE rubrics via POST /api/rubrics','2026-03-16 20:45:22'),(258,59,'CREATE','attendance',NULL,NULL,'{\"sectionId\":1,\"sessionDate\":\"2026-03-15\",\"sessionType\":\"lecture\",\"startTime\":\"09:00:00\",\"endTime\":\"10:30:00\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE attendance via POST /attendance/sessions','2026-03-16 20:45:22'),(259,57,'UPDATE','notifications',NULL,NULL,'{\"emailEnabled\":true,\"pushEnabled\":true}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE notifications via PUT /api/notifications/preferences','2026-03-16 20:45:23'),(260,57,'UPDATE','notifications',NULL,NULL,'{}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE notifications via PATCH /api/notifications/read-all','2026-03-16 20:45:23'),(261,59,'CREATE','notifications',NULL,NULL,'{\"userIds\":[57],\"notificationType\":\"system\",\"title\":\"Test from API Dog\",\"body\":\"This is a test notification.\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE notifications via POST /api/notifications/send','2026-03-16 20:45:23'),(262,57,'CREATE','messages',NULL,NULL,'{\"participantIds\":[59],\"type\":\"direct\",\"text\":\"Hello from API Dog test!\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE messages via POST /api/messages/conversations','2026-03-16 20:45:23'),(263,59,'CREATE','calendar',NULL,NULL,'{\"title\":\"API Dog Test Event\",\"description\":\"Test\",\"startTime\":\"2026-04-01T10:00:00Z\",\"endTime\":\"2026-04-01T11:00:00Z\",\"eventType\":\"meeting\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE calendar via POST /api/calendar/events','2026-03-16 20:45:24'),(264,59,'DELETE','calendar',15,NULL,NULL,'127.0.0.1','PostmanRuntime/7.52.0','DELETE calendar via DELETE /api/calendar/events/15','2026-03-16 20:45:24'),(265,57,'CREATE','tasks',NULL,NULL,'{\"title\":\"Study for Final Exam\",\"description\":\"Review all chapters\",\"taskType\":\"study\",\"dueDate\":\"2026-03-18T18:14:01.673Z\",\"priority\":\"high\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE tasks via POST /api/tasks','2026-03-16 20:45:25'),(266,57,'CREATE','tasks',8,NULL,'{\"notes\":\"Finished studying all chapters\",\"timeTakenMinutes\":120}','127.0.0.1','PostmanRuntime/7.52.0','CREATE tasks via POST /api/tasks/8/complete','2026-03-16 20:45:25'),(267,57,'CREATE','tasks',NULL,NULL,'{\"taskId\":9,\"reminderTime\":\"2026-03-17T18:14:01.673Z\",\"reminderType\":\"in_app\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE tasks via POST /api/tasks/reminders','2026-03-16 20:45:25'),(268,57,'DELETE','search',NULL,NULL,NULL,'127.0.0.1','PostmanRuntime/7.52.0','DELETE search via DELETE /api/search/history','2026-03-16 20:45:26'),(269,59,'CREATE','reports',NULL,NULL,'{\"templateId\":1,\"reportName\":\"Test Student Progress Report\",\"filters\":{\"courseId\":1,\"semesterId\":2},\"exportFormat\":\"pdf\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE reports via POST /api/reports/generate','2026-03-16 20:45:28'),(270,NULL,'CREATE','google-drive',NULL,NULL,'{\"name\":\"EduVerse_Test_Folder\",\"parentId\":\"\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE google-drive via POST /google-drive/folders','2026-03-16 20:45:29'),(271,NULL,'CREATE','google-drive',NULL,NULL,'{\"name\":\"EduVerse_Test_Folder\",\"parentId\":\"\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE google-drive via POST /google-drive/folders/find-or-create','2026-03-16 20:45:30'),(272,59,'CREATE','google-drive',NULL,NULL,NULL,'127.0.0.1','PostmanRuntime/7.52.0','CREATE google-drive via POST /google-drive/admin/init','2026-03-16 20:45:31'),(273,59,'CREATE','google-drive',1,NULL,NULL,'127.0.0.1','PostmanRuntime/7.52.0','CREATE google-drive via POST /google-drive/admin/courses/1/init','2026-03-16 20:45:31'),(274,59,'CREATE','google-drive',NULL,NULL,NULL,'127.0.0.1','PostmanRuntime/7.52.0','CREATE google-drive via POST /google-drive/admin/labs/3/init','2026-03-16 20:45:31'),(275,59,'CREATE','google-drive',NULL,NULL,NULL,'127.0.0.1','PostmanRuntime/7.52.0','CREATE google-drive via POST /google-drive/admin/assignments/1/init','2026-03-16 20:45:31'),(276,NULL,'CREATE','auth',NULL,NULL,'{\"email\":\"admin.tarek@example.com\",\"password\":\"SecureP@ss123\",\"rememberMe\":true}','127.0.0.1','PostmanRuntime/7.52.0','CREATE auth via POST /api/auth/login','2026-03-16 20:53:42'),(277,NULL,'CREATE','auth',NULL,NULL,'{\"email\":\"instructor.tarek@example.com\",\"password\":\"SecureP@ss123\",\"rememberMe\":true}','127.0.0.1','PostmanRuntime/7.52.0','CREATE auth via POST /api/auth/login','2026-03-16 20:53:42'),(278,NULL,'CREATE','auth',NULL,NULL,'{\"email\":\"student.tarek@example.com\",\"password\":\"SecureP@ss123\",\"rememberMe\":true}','127.0.0.1','PostmanRuntime/7.52.0','CREATE auth via POST /api/auth/login','2026-03-16 20:53:42'),(279,NULL,'CREATE','auth',NULL,NULL,'{\"email\":\"ta.tarek@example.com\",\"password\":\"SecureP@ss123\",\"rememberMe\":true}','127.0.0.1','PostmanRuntime/7.52.0','CREATE auth via POST /api/auth/login','2026-03-16 20:53:42'),(280,NULL,'CREATE','auth',NULL,NULL,'{\"email\":\"it_admin.tarek@example.com\",\"password\":\"SecureP@ss123\",\"rememberMe\":true}','127.0.0.1','PostmanRuntime/7.52.0','CREATE auth via POST /api/auth/login','2026-03-16 20:53:42'),(281,NULL,'CREATE','auth',NULL,NULL,'{\"refreshToken\":\"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzczNjk0NDIyLCJleHAiOjE3NzYyODY0MjJ9.Y9mYku_EIzFe9vnldeUXTt1sO_ydxSuctRFnNl3TydI\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE auth via POST /api/auth/refresh-token','2026-03-16 20:53:43'),(282,57,'UPDATE','users',NULL,NULL,'{\"firstName\":\"Student\",\"lastName\":\"Tarek\",\"phone\":\"+201234567890\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE users via PUT /api/users/profile','2026-03-16 20:53:43'),(283,57,'UPDATE','users',NULL,NULL,'{\"theme\":\"dark\",\"language\":\"en\",\"emailNotifications\":true,\"pushNotifications\":true}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE users via PUT /api/users/preferences','2026-03-16 20:53:43'),(284,57,'UPDATE','users',NULL,NULL,'{\"currentPassword\":\"SecureP@ss123\",\"newPassword\":\"SecureP@ss123\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE users via PATCH /api/users/password','2026-03-16 20:53:43'),(285,59,'UPDATE','admin',57,NULL,'{\"firstName\":\"Student\",\"lastName\":\"Tarek\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE admin via PUT /api/admin/users/57','2026-03-16 20:53:44'),(286,59,'UPDATE','campuses',1,NULL,'{\"name\":\"Updated Campus Name\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE campuses via PUT /api/campuses/1','2026-03-16 20:53:45'),(287,59,'UPDATE','departments',1,NULL,'{\"name\":\"Updated Department\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE departments via PUT /api/departments/1','2026-03-16 20:53:45'),(288,59,'UPDATE','programs',1,NULL,'{\"name\":\"Updated Program\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE programs via PUT /api/programs/1','2026-03-16 20:53:45'),(289,NULL,'CREATE','sections',NULL,NULL,'{\"courseId\":1,\"semesterId\":2,\"sectionNumber\":\"113\",\"maxCapacity\":30,\"location\":\"Room TEST\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE sections via POST /api/sections','2026-03-16 20:53:46'),(290,59,'CREATE','courses',1,NULL,'{\"title\":\"API Dog Test Material\",\"materialType\":\"document\",\"description\":\"Created by API Dog test\",\"weekNumber\":1,\"isPublished\":true}','127.0.0.1','PostmanRuntime/7.52.0','CREATE courses via POST /api/courses/1/materials','2026-03-16 20:53:48'),(291,59,'CREATE','courses',1,NULL,'{\"materials\":[{\"title\":\"Bulk Test 1\",\"materialType\":\"lecture\",\"weekNumber\":10,\"isPublished\":true},{\"title\":\"Bulk Test 2\",\"materialType\":\"slide\",\"weekNumber\":10,\"isPublished\":true}]}','127.0.0.1','PostmanRuntime/7.52.0','CREATE courses via POST /api/courses/1/materials/bulk','2026-03-16 20:53:48'),(292,59,'UPDATE','courses',56,NULL,'{\"title\":\"Updated API Dog Material\",\"description\":\"Updated by test\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE courses via PUT /api/courses/1/materials/56','2026-03-16 20:53:48'),(293,59,'UPDATE','courses',15,NULL,'{\"isPublished\":true}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE courses via PATCH /api/courses/1/materials/15/visibility','2026-03-16 20:53:48'),(294,59,'CREATE','courses',15,NULL,'{}','127.0.0.1','PostmanRuntime/7.52.0','CREATE courses via POST /api/courses/1/materials/15/view','2026-03-16 20:53:48'),(295,59,'DELETE','courses',56,NULL,NULL,'127.0.0.1','PostmanRuntime/7.52.0','DELETE courses via DELETE /api/courses/1/materials/56','2026-03-16 20:53:49'),(296,59,'CREATE','courses',1,NULL,'{\"title\":\"Week 10: API Dog Test\",\"organizationType\":\"lecture\",\"weekNumber\":10,\"orderIndex\":99}','127.0.0.1','PostmanRuntime/7.52.0','CREATE courses via POST /api/courses/1/structure','2026-03-16 20:53:49'),(297,59,'UPDATE','courses',23,NULL,'{\"title\":\"Week 10: Updated\",\"description\":\"Updated by API Dog\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE courses via PUT /api/courses/1/structure/23','2026-03-16 20:53:49'),(298,59,'UPDATE','courses',1,NULL,'{\"orderIds\":[7,8,9,10,11,12]}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE courses via PATCH /api/courses/1/structure/reorder','2026-03-16 20:53:49'),(299,59,'DELETE','courses',23,NULL,NULL,'127.0.0.1','PostmanRuntime/7.52.0','DELETE courses via DELETE /api/courses/1/structure/23','2026-03-16 20:53:49'),(300,59,'CREATE','announcements',NULL,NULL,'{\"title\":\"API Dog Test Announcement\",\"content\":\"This is a test announcement from API Dog.\",\"courseId\":1,\"priority\":\"medium\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE announcements via POST /api/announcements','2026-03-16 20:53:51'),(301,59,'UPDATE','announcements',1,NULL,'{\"title\":\"Updated: Welcome to CS101!\",\"content\":\"Updated announcement content.\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE announcements via PUT /api/announcements/1','2026-03-16 20:53:51'),(302,59,'UPDATE','announcements',1,NULL,'{}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE announcements via PATCH /api/announcements/1/publish','2026-03-16 20:53:51'),(303,59,'UPDATE','announcements',1,NULL,'{\"isPinned\":true}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE announcements via PATCH /api/announcements/1/pin','2026-03-16 20:53:51'),(304,59,'CREATE','assignments',NULL,NULL,'{\"courseId\":1,\"title\":\"API Dog Test Assignment\",\"description\":\"Test assignment from API Dog\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE assignments via POST /api/assignments','2026-03-16 20:53:51'),(305,59,'UPDATE','assignments',1,NULL,'{\"title\":\"Updated Assignment Title\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE assignments via PATCH /api/assignments/1','2026-03-16 20:53:52'),(306,59,'CREATE','discussions',NULL,NULL,'{\"courseId\":1,\"title\":\"API Dog Test Discussion\",\"description\":\"Testing from API Dog.\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE discussions via POST /api/discussions','2026-03-16 20:53:52'),(307,59,'UPDATE','discussions',3,NULL,'{\"title\":\"Updated Discussion Title\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE discussions via PUT /api/discussions/3','2026-03-16 20:53:52'),(308,59,'CREATE','discussions',3,NULL,'{\"messageText\":\"Test reply from API Dog.\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE discussions via POST /api/discussions/3/reply','2026-03-16 20:53:52'),(309,59,'UPDATE','discussions',3,NULL,'{\"isPinned\":true}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE discussions via PATCH /api/discussions/3/pin','2026-03-16 20:53:52'),(310,59,'UPDATE','discussions',3,NULL,'{\"isLocked\":true}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE discussions via PATCH /api/discussions/3/lock','2026-03-16 20:53:52'),(311,59,'CREATE','community',NULL,NULL,'{\"title\":\"API Dog Test Post\",\"content\":\"Testing from API Dog.\",\"communityId\":1}','127.0.0.1','PostmanRuntime/7.52.0','CREATE community via POST /api/community/communities/1/posts','2026-03-16 20:53:53'),(312,59,'CREATE','community',NULL,NULL,'{\"title\":\"Global Post from API Dog\",\"content\":\"Test global post.\",\"communityId\":1}','127.0.0.1','PostmanRuntime/7.52.0','CREATE community via POST /api/community/global/posts','2026-03-16 20:53:53'),(313,59,'CREATE','community',3,NULL,'{\"commentText\":\"API Dog test comment\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE community via POST /api/community/posts/3/comment','2026-03-16 20:53:54'),(314,59,'CREATE','community',3,NULL,'{\"reactionType\":\"like\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE community via POST /api/community/posts/3/react','2026-03-16 20:53:54'),(315,59,'CREATE','files',NULL,NULL,'{\"folderName\":\"API Dog Test Folder\",\"parentFolderId\":1}','127.0.0.1','PostmanRuntime/7.52.0','CREATE files via POST /api/files/folders','2026-03-16 20:53:55'),(316,59,'UPDATE','files',NULL,NULL,'{\"folderName\":\"Updated Test Folder\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE files via PUT /api/files/folders/25','2026-03-16 20:53:55'),(317,59,'DELETE','files',NULL,NULL,NULL,'127.0.0.1','PostmanRuntime/7.52.0','DELETE files via DELETE /api/files/folders/25','2026-03-16 20:53:55'),(318,59,'CREATE','labs',NULL,NULL,'{\"title\":\"API Dog Test Lab\",\"courseId\":1,\"description\":\"Test lab\",\"dueDate\":\"2026-06-15T23:59:00Z\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE labs via POST /api/labs','2026-03-16 20:53:56'),(319,59,'UPDATE','labs',3,NULL,'{\"title\":\"Updated Lab Title\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE labs via PUT /api/labs/3','2026-03-16 20:53:56'),(320,58,'CREATE','rubrics',NULL,NULL,'{\"rubricName\":\"API Dog Test Rubric\",\"courseId\":1,\"totalPoints\":100}','127.0.0.1','PostmanRuntime/7.52.0','CREATE rubrics via POST /api/rubrics','2026-03-16 20:53:57'),(321,59,'CREATE','attendance',NULL,NULL,'{\"sectionId\":1,\"sessionDate\":\"2026-03-15\",\"sessionType\":\"lecture\",\"startTime\":\"09:00:00\",\"endTime\":\"10:30:00\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE attendance via POST /attendance/sessions','2026-03-16 20:53:58'),(322,57,'UPDATE','notifications',NULL,NULL,'{\"emailEnabled\":true,\"pushEnabled\":true}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE notifications via PUT /api/notifications/preferences','2026-03-16 20:53:58'),(323,57,'UPDATE','notifications',NULL,NULL,'{}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE notifications via PATCH /api/notifications/read-all','2026-03-16 20:53:58'),(324,59,'CREATE','notifications',NULL,NULL,'{\"userIds\":[57],\"notificationType\":\"system\",\"title\":\"Test from API Dog\",\"body\":\"This is a test notification.\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE notifications via POST /api/notifications/send','2026-03-16 20:53:59'),(325,57,'CREATE','messages',NULL,NULL,'{\"participantIds\":[59],\"type\":\"direct\",\"text\":\"Hello from API Dog test!\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE messages via POST /api/messages/conversations','2026-03-16 20:53:59'),(326,59,'CREATE','calendar',NULL,NULL,'{\"title\":\"API Dog Test Event\",\"description\":\"Test\",\"startTime\":\"2026-04-01T10:00:00Z\",\"endTime\":\"2026-04-01T11:00:00Z\",\"eventType\":\"meeting\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE calendar via POST /api/calendar/events','2026-03-16 20:54:00'),(327,59,'DELETE','calendar',16,NULL,NULL,'127.0.0.1','PostmanRuntime/7.52.0','DELETE calendar via DELETE /api/calendar/events/16','2026-03-16 20:54:00'),(328,57,'CREATE','tasks',NULL,NULL,'{\"title\":\"Study for Final Exam\",\"description\":\"Review all chapters\",\"taskType\":\"study\",\"dueDate\":\"2026-03-18T18:14:01.673Z\",\"priority\":\"high\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE tasks via POST /api/tasks','2026-03-16 20:54:01'),(329,57,'CREATE','tasks',8,NULL,'{\"notes\":\"Finished studying all chapters\",\"timeTakenMinutes\":120}','127.0.0.1','PostmanRuntime/7.52.0','CREATE tasks via POST /api/tasks/8/complete','2026-03-16 20:54:01'),(330,57,'CREATE','tasks',NULL,NULL,'{\"taskId\":9,\"reminderTime\":\"2026-03-17T18:14:01.673Z\",\"reminderType\":\"in_app\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE tasks via POST /api/tasks/reminders','2026-03-16 20:54:01'),(331,57,'DELETE','search',NULL,NULL,NULL,'127.0.0.1','PostmanRuntime/7.52.0','DELETE search via DELETE /api/search/history','2026-03-16 20:54:02'),(332,59,'CREATE','reports',NULL,NULL,'{\"templateId\":1,\"reportName\":\"Test Student Progress Report\",\"filters\":{\"courseId\":1,\"semesterId\":2},\"exportFormat\":\"pdf\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE reports via POST /api/reports/generate','2026-03-16 20:54:03'),(333,NULL,'CREATE','google-drive',NULL,NULL,'{\"name\":\"EduVerse_Test_Folder\",\"parentId\":\"\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE google-drive via POST /google-drive/folders','2026-03-16 20:54:05'),(334,NULL,'CREATE','google-drive',NULL,NULL,'{\"name\":\"EduVerse_Test_Folder\",\"parentId\":\"\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE google-drive via POST /google-drive/folders/find-or-create','2026-03-16 20:54:05'),(335,59,'CREATE','google-drive',NULL,NULL,NULL,'127.0.0.1','PostmanRuntime/7.52.0','CREATE google-drive via POST /google-drive/admin/init','2026-03-16 20:54:07'),(336,59,'CREATE','google-drive',1,NULL,NULL,'127.0.0.1','PostmanRuntime/7.52.0','CREATE google-drive via POST /google-drive/admin/courses/1/init','2026-03-16 20:54:07'),(337,59,'CREATE','google-drive',NULL,NULL,NULL,'127.0.0.1','PostmanRuntime/7.52.0','CREATE google-drive via POST /google-drive/admin/labs/3/init','2026-03-16 20:54:07'),(338,59,'CREATE','google-drive',NULL,NULL,NULL,'127.0.0.1','PostmanRuntime/7.52.0','CREATE google-drive via POST /google-drive/admin/assignments/1/init','2026-03-16 20:54:07'),(339,NULL,'CREATE','auth',NULL,NULL,'{\"email\":\"student.tarek@example.com\",\"password\":\"SecureP@ss123\",\"rememberMe\":false}','127.0.0.1','PostmanRuntime/7.52.0','CREATE auth via POST /api/auth/login','2026-03-16 20:55:53'),(340,NULL,'CREATE','auth',NULL,NULL,'{\"email\":\"instructor.tarek@example.com\",\"password\":\"SecureP@ss123\",\"rememberMe\":false}','127.0.0.1','PostmanRuntime/7.52.0','CREATE auth via POST /api/auth/login','2026-03-16 20:55:53'),(341,NULL,'CREATE','auth',NULL,NULL,'{\"email\":\"admin.tarek@example.com\",\"password\":\"SecureP@ss123\",\"rememberMe\":false}','127.0.0.1','PostmanRuntime/7.52.0','CREATE auth via POST /api/auth/login','2026-03-16 20:55:53'),(342,NULL,'CREATE','auth',NULL,NULL,'{\"email\":\"ta.tarek@example.com\",\"password\":\"SecureP@ss123\",\"rememberMe\":false}','127.0.0.1','PostmanRuntime/7.52.0','CREATE auth via POST /api/auth/login','2026-03-16 20:55:53'),(343,NULL,'CREATE','auth',NULL,NULL,'{\"email\":\"it_admin.tarek@example.com\",\"password\":\"SecureP@ss123\",\"rememberMe\":false}','127.0.0.1','PostmanRuntime/7.52.0','CREATE auth via POST /api/auth/login','2026-03-16 20:55:53'),(344,NULL,'CREATE','auth',NULL,NULL,'{\"email\":\"student.tarek@example.com\",\"password\":\"SecureP@ss123\",\"rememberMe\":false}','127.0.0.1','PostmanRuntime/7.52.0','CREATE auth via POST /api/auth/login','2026-03-16 20:56:24'),(345,NULL,'CREATE','auth',NULL,NULL,'{\"email\":\"instructor.tarek@example.com\",\"password\":\"SecureP@ss123\",\"rememberMe\":false}','127.0.0.1','PostmanRuntime/7.52.0','CREATE auth via POST /api/auth/login','2026-03-16 20:56:24'),(346,NULL,'CREATE','auth',NULL,NULL,'{\"email\":\"admin.tarek@example.com\",\"password\":\"SecureP@ss123\",\"rememberMe\":false}','127.0.0.1','PostmanRuntime/7.52.0','CREATE auth via POST /api/auth/login','2026-03-16 20:56:24'),(347,NULL,'CREATE','auth',NULL,NULL,'{\"email\":\"ta.tarek@example.com\",\"password\":\"SecureP@ss123\",\"rememberMe\":false}','127.0.0.1','PostmanRuntime/7.52.0','CREATE auth via POST /api/auth/login','2026-03-16 20:56:24'),(348,NULL,'CREATE','auth',NULL,NULL,'{\"email\":\"it_admin.tarek@example.com\",\"password\":\"SecureP@ss123\",\"rememberMe\":false}','127.0.0.1','PostmanRuntime/7.52.0','CREATE auth via POST /api/auth/login','2026-03-16 20:56:24'),(349,NULL,'UPDATE','courses',1,NULL,'{\"name\":\"Updated Course Name\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE courses via PATCH /api/courses/1','2026-03-16 20:56:27'),(350,NULL,'CREATE','sections',NULL,NULL,'{\"courseId\":1,\"semesterId\":1,\"maxCapacity\":30,\"location\":\"Room A101\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE sections via POST /api/sections','2026-03-16 20:56:28'),(351,NULL,'UPDATE','sections',11,NULL,'{\"maxCapacity\":35,\"location\":\"Room B202\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE sections via PATCH /api/sections/11','2026-03-16 20:56:28'),(352,NULL,'UPDATE','sections',11,NULL,'{\"action\":\"increment\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE sections via PATCH /api/sections/11/enrollment','2026-03-16 20:56:28'),(353,NULL,'CREATE','auth',NULL,NULL,'{\"email\":\"amir_admin@example.com\",\"password\":\"Pass@123\",\"rememberMe\":false}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','CREATE auth via POST /api/auth/login','2026-03-16 20:56:45'),(354,66,'DELETE','security',10,NULL,NULL,'127.0.0.1','PostmanRuntime/7.52.0','DELETE security via DELETE /api/security/sessions/user/10','2026-03-16 20:57:26'),(355,66,'UPDATE','settings',NULL,NULL,'{\"settings\":{\"platform_name\":\"EduVerse updated\"}}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE settings via PUT /api/settings','2026-03-16 20:57:27'),(356,66,'UPDATE','settings',NULL,NULL,'{\"value\":\"EduVerse Pro\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE settings via PUT /api/settings/platform_name','2026-03-16 20:57:27'),(357,66,'UPDATE','settings',NULL,NULL,'{\"primaryColor\":\"#ff0000\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE settings via PUT /api/settings/branding/1','2026-03-16 20:57:27'),(358,NULL,'CREATE','auth',NULL,NULL,'{\"email\":\"amir_itadmin@example.com\",\"password\":\"Pass@123\",\"rememberMe\":false}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','CREATE auth via POST /api/auth/login','2026-03-16 20:58:10'),(359,67,'CREATE','security',NULL,NULL,'{\"format\":\"json\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE security via POST /api/security/logs/export','2026-03-16 20:59:21'),(360,66,'DELETE','security',10,NULL,NULL,'127.0.0.1','PostmanRuntime/7.52.0','DELETE security via DELETE /api/security/sessions/user/10','2026-03-16 20:59:21'),(361,67,'CREATE','security',NULL,NULL,'{\"ipAddress\":\"192.168.1.50\",\"reason\":\"Repeated failed logins\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE security via POST /api/security/block-ip','2026-03-16 20:59:21'),(362,67,'DELETE','security',1,NULL,NULL,'127.0.0.1','PostmanRuntime/7.52.0','DELETE security via DELETE /api/security/blocked-ips/1','2026-03-16 20:59:21'),(363,67,'CREATE','audit',NULL,NULL,'{\"format\":\"csv\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE audit via POST /api/audit/logs/export','2026-03-16 20:59:22'),(364,66,'UPDATE','settings',NULL,NULL,'{\"settings\":{\"platform_name\":\"EduVerse updated\"}}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE settings via PUT /api/settings','2026-03-16 20:59:22'),(365,66,'UPDATE','settings',NULL,NULL,'{\"value\":\"EduVerse Pro\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE settings via PUT /api/settings/platform_name','2026-03-16 20:59:22'),(366,66,'UPDATE','settings',NULL,NULL,'{\"primaryColor\":\"#ff0000\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE settings via PUT /api/settings/branding/1','2026-03-16 20:59:22'),(367,67,'UPDATE','settings',1,NULL,'{\"maxRequests\":1000,\"windowSeconds\":60}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE settings via PUT /api/settings/rate-limits/1','2026-03-16 20:59:22'),(368,67,'CREATE','integrations',NULL,NULL,'{\"integrationName\":\"Canvas LMS\",\"integrationType\":\"lms\",\"campusId\":1,\"apiEndpoint\":\"https://canvas.example.com\",\"apiKey\":\"s3cr3t\",\"apiSecret\":\"s3cr3t2\",\"configuration\":\"{}\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE integrations via POST /api/integrations','2026-03-16 20:59:23'),(369,67,'UPDATE','integrations',1,NULL,'{\"isActive\":true,\"apiEndpoint\":\"https://canvas-new.example.com\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE integrations via PUT /api/integrations/1','2026-03-16 20:59:23'),(370,67,'DELETE','integrations',1,NULL,NULL,'127.0.0.1','PostmanRuntime/7.52.0','DELETE integrations via DELETE /api/integrations/1','2026-03-16 20:59:23'),(371,67,'CREATE','integrations',2,NULL,NULL,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','CREATE integrations via POST /api/integrations/2/test','2026-03-16 21:00:03'),(372,67,'CREATE','integrations',2,NULL,NULL,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','CREATE integrations via POST /api/integrations/2/sync','2026-03-16 21:00:29'),(373,67,'DELETE','security',57,NULL,NULL,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','DELETE security via DELETE /api/security/sessions/57','2026-03-16 21:01:50'),(374,NULL,'CREATE','auth',NULL,NULL,'{\"email\":\"it_admin.tarek@example.com\",\"password\":\"SecureP@ss123\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','CREATE auth via POST /api/auth/login','2026-03-16 22:02:13'),(375,NULL,'CREATE','auth',NULL,NULL,'{\"email\":\"it_admin.tarek@example.com\",\"password\":\"SecureP@ss123\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','CREATE auth via POST /api/auth/login','2026-03-16 22:03:43'),(376,NULL,'CREATE','auth',NULL,NULL,'{\"email\":\"it_admin.tarek@example.com\",\"password\":\"SecureP@ss123\"}','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.26100.7705','CREATE auth via POST /api/auth/login','2026-03-16 22:04:57'),(377,NULL,'CREATE','auth',NULL,NULL,'{\"email\":\"admin.tarek@example.com\",\"password\":\"SecureP@ss123\"}','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.26100.7705','CREATE auth via POST /api/auth/login','2026-03-16 22:04:57'),(378,NULL,'CREATE','auth',NULL,NULL,'{\"email\":\"student.tarek@example.com\",\"password\":\"SecureP@ss123\"}','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.26100.7705','CREATE auth via POST /api/auth/login','2026-03-16 22:04:57'),(379,61,'CREATE','alerts',NULL,NULL,'{\"name\":\"Test CPU Alert\",\"conditionType\":\"cpu_usage\",\"threshold\":90,\"description\":\"Test alert\"}','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.26100.7705','CREATE alerts via POST /api/alerts','2026-03-16 22:04:58'),(380,61,'UPDATE','alerts',1,NULL,'{\"name\":\"Updated CPU Alert\",\"threshold\":95}','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.26100.7705','UPDATE alerts via PATCH /api/alerts/1','2026-03-16 22:04:58'),(381,61,'DELETE','alerts',1,NULL,NULL,'127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.26100.7705','DELETE alerts via DELETE /api/alerts/1','2026-03-16 22:04:58'),(382,61,'CREATE','backups',NULL,NULL,'{}','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.26100.7705','CREATE backups via POST /api/backups','2026-03-16 22:05:00'),(383,61,'CREATE','database',NULL,NULL,'{}','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.26100.7705','CREATE database via POST /api/database/optimize','2026-03-16 22:05:00'),(384,NULL,'CREATE','auth',NULL,NULL,'{\"email\":\"amir_admin@example.com\",\"password\":\"Pass@123\",\"rememberMe\":false}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','CREATE auth via POST /api/auth/login','2026-03-16 22:16:02'),(385,NULL,'CREATE','auth',NULL,NULL,'{\"email\":\"amir_itadmin@example.com\",\"password\":\"Pass@123\",\"rememberMe\":false}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','CREATE auth via POST /api/auth/login','2026-03-16 22:19:24'),(386,67,'CREATE','alerts',NULL,NULL,'{\"name\":\"High CPU Alert\",\"description\":\"Triggers when CPU usage exceeds threshold\",\"conditionType\":\"cpu_usage\",\"threshold\":90}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','CREATE alerts via POST /api/alerts','2026-03-16 22:20:56'),(387,67,'UPDATE','alerts',2,NULL,'{\"name\":\"High CPU Alert\",\"description\":\"Triggers when CPU usage exceeds threshold updated\",\"conditionType\":\"cpu_usage\",\"threshold\":90,\"isActive\":true}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','UPDATE alerts via PATCH /api/alerts/2','2026-03-16 22:21:34'),(388,67,'UPDATE','alerts',2,NULL,'{\"name\":\"High CPU Alert\",\"description\":\"Triggers when CPU usage exceeds threshold updated\",\"conditionType\":\"cpu_usage\",\"threshold\":90,\"isActive\":true}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','UPDATE alerts via PATCH /api/alerts/2','2026-03-16 22:21:35'),(389,67,'CREATE','alerts',NULL,NULL,'{\"name\":\"High GPU Alert\",\"description\":\"Triggers when GPU usage exceeds threshold\",\"conditionType\":\"gpu_usage\",\"threshold\":94}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','CREATE alerts via POST /api/alerts','2026-03-16 22:22:05'),(390,67,'DELETE','alerts',3,NULL,NULL,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','DELETE alerts via DELETE /api/alerts/3','2026-03-16 22:22:13'),(391,67,'CREATE','backups',NULL,NULL,NULL,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','CREATE backups via POST /api/backups','2026-03-16 22:22:56'),(392,67,'DELETE','backups',2,NULL,NULL,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','DELETE backups via DELETE /api/backups/2','2026-03-16 22:24:07'),(393,NULL,'CREATE','auth',NULL,NULL,'{\"email\":\"admin.tarek@example.com\",\"password\":\"SecureP@ss123\",\"rememberMe\":true}','127.0.0.1','PostmanRuntime/7.52.0','CREATE auth via POST /api/auth/login','2026-03-16 22:31:18'),(394,NULL,'CREATE','auth',NULL,NULL,'{\"email\":\"instructor.tarek@example.com\",\"password\":\"SecureP@ss123\",\"rememberMe\":true}','127.0.0.1','PostmanRuntime/7.52.0','CREATE auth via POST /api/auth/login','2026-03-16 22:31:18'),(395,NULL,'CREATE','auth',NULL,NULL,'{\"email\":\"student.tarek@example.com\",\"password\":\"SecureP@ss123\",\"rememberMe\":true}','127.0.0.1','PostmanRuntime/7.52.0','CREATE auth via POST /api/auth/login','2026-03-16 22:31:18'),(396,NULL,'CREATE','auth',NULL,NULL,'{\"email\":\"ta.tarek@example.com\",\"password\":\"SecureP@ss123\",\"rememberMe\":true}','127.0.0.1','PostmanRuntime/7.52.0','CREATE auth via POST /api/auth/login','2026-03-16 22:31:18'),(397,NULL,'CREATE','auth',NULL,NULL,'{\"email\":\"it_admin.tarek@example.com\",\"password\":\"SecureP@ss123\",\"rememberMe\":true}','127.0.0.1','PostmanRuntime/7.52.0','CREATE auth via POST /api/auth/login','2026-03-16 22:31:18'),(398,NULL,'CREATE','auth',NULL,NULL,'{\"refreshToken\":\"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzczNzAwMjc4LCJleHAiOjE3NzYyOTIyNzh9.FOVqfRuT5dn9C74lKmQV05etWLLV-YOF37q0PpopsJE\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE auth via POST /api/auth/refresh-token','2026-03-16 22:31:19'),(399,57,'UPDATE','users',NULL,NULL,'{\"firstName\":\"Student\",\"lastName\":\"Tarek\",\"phone\":\"+201234567890\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE users via PUT /api/users/profile','2026-03-16 22:31:19'),(400,57,'UPDATE','users',NULL,NULL,'{\"theme\":\"dark\",\"language\":\"en\",\"emailNotifications\":true,\"pushNotifications\":true}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE users via PUT /api/users/preferences','2026-03-16 22:31:19'),(401,57,'UPDATE','users',NULL,NULL,'{\"currentPassword\":\"SecureP@ss123\",\"newPassword\":\"SecureP@ss123\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE users via PATCH /api/users/password','2026-03-16 22:31:19'),(402,59,'UPDATE','admin',57,NULL,'{\"firstName\":\"Student\",\"lastName\":\"Tarek\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE admin via PUT /api/admin/users/57','2026-03-16 22:31:20'),(403,59,'UPDATE','campuses',1,NULL,'{\"name\":\"Updated Campus Name\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE campuses via PUT /api/campuses/1','2026-03-16 22:31:21'),(404,59,'UPDATE','departments',1,NULL,'{\"name\":\"Updated Department\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE departments via PUT /api/departments/1','2026-03-16 22:31:21'),(405,59,'UPDATE','programs',1,NULL,'{\"name\":\"Updated Program\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE programs via PUT /api/programs/1','2026-03-16 22:31:22'),(406,NULL,'CREATE','sections',NULL,NULL,'{\"courseId\":1,\"semesterId\":2,\"sectionNumber\":\"197\",\"maxCapacity\":30,\"location\":\"Room TEST\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE sections via POST /api/sections','2026-03-16 22:31:23'),(407,59,'CREATE','courses',1,NULL,'{\"title\":\"API Dog Test Material\",\"materialType\":\"document\",\"description\":\"Created by API Dog test\",\"weekNumber\":1,\"isPublished\":true}','127.0.0.1','PostmanRuntime/7.52.0','CREATE courses via POST /api/courses/1/materials','2026-03-16 22:31:24'),(408,59,'CREATE','courses',1,NULL,'{\"materials\":[{\"title\":\"Bulk Test 1\",\"materialType\":\"lecture\",\"weekNumber\":10,\"isPublished\":true},{\"title\":\"Bulk Test 2\",\"materialType\":\"slide\",\"weekNumber\":10,\"isPublished\":true}]}','127.0.0.1','PostmanRuntime/7.52.0','CREATE courses via POST /api/courses/1/materials/bulk','2026-03-16 22:31:24'),(409,59,'UPDATE','courses',59,NULL,'{\"title\":\"Updated API Dog Material\",\"description\":\"Updated by test\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE courses via PUT /api/courses/1/materials/59','2026-03-16 22:31:24'),(410,59,'UPDATE','courses',15,NULL,'{\"isPublished\":true}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE courses via PATCH /api/courses/1/materials/15/visibility','2026-03-16 22:31:25'),(411,59,'CREATE','courses',15,NULL,'{}','127.0.0.1','PostmanRuntime/7.52.0','CREATE courses via POST /api/courses/1/materials/15/view','2026-03-16 22:31:25'),(412,59,'DELETE','courses',59,NULL,NULL,'127.0.0.1','PostmanRuntime/7.52.0','DELETE courses via DELETE /api/courses/1/materials/59','2026-03-16 22:31:25'),(413,59,'CREATE','courses',1,NULL,'{\"title\":\"Week 10: API Dog Test\",\"organizationType\":\"lecture\",\"weekNumber\":10,\"orderIndex\":99}','127.0.0.1','PostmanRuntime/7.52.0','CREATE courses via POST /api/courses/1/structure','2026-03-16 22:31:25'),(414,59,'UPDATE','courses',24,NULL,'{\"title\":\"Week 10: Updated\",\"description\":\"Updated by API Dog\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE courses via PUT /api/courses/1/structure/24','2026-03-16 22:31:25'),(415,59,'UPDATE','courses',1,NULL,'{\"orderIds\":[7,8,9,10,11,12]}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE courses via PATCH /api/courses/1/structure/reorder','2026-03-16 22:31:25'),(416,59,'DELETE','courses',24,NULL,NULL,'127.0.0.1','PostmanRuntime/7.52.0','DELETE courses via DELETE /api/courses/1/structure/24','2026-03-16 22:31:26'),(417,59,'CREATE','announcements',NULL,NULL,'{\"title\":\"API Dog Test Announcement\",\"content\":\"This is a test announcement from API Dog.\",\"courseId\":1,\"priority\":\"medium\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE announcements via POST /api/announcements','2026-03-16 22:31:27'),(418,59,'UPDATE','announcements',1,NULL,'{\"title\":\"Updated: Welcome to CS101!\",\"content\":\"Updated announcement content.\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE announcements via PUT /api/announcements/1','2026-03-16 22:31:27'),(419,59,'UPDATE','announcements',1,NULL,'{}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE announcements via PATCH /api/announcements/1/publish','2026-03-16 22:31:27'),(420,59,'UPDATE','announcements',1,NULL,'{\"isPinned\":true}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE announcements via PATCH /api/announcements/1/pin','2026-03-16 22:31:27'),(421,59,'CREATE','assignments',NULL,NULL,'{\"courseId\":1,\"title\":\"API Dog Test Assignment\",\"description\":\"Test assignment from API Dog\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE assignments via POST /api/assignments','2026-03-16 22:31:28'),(422,59,'UPDATE','assignments',1,NULL,'{\"title\":\"Updated Assignment Title\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE assignments via PATCH /api/assignments/1','2026-03-16 22:31:28'),(423,59,'CREATE','discussions',NULL,NULL,'{\"courseId\":1,\"title\":\"API Dog Test Discussion\",\"description\":\"Testing from API Dog.\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE discussions via POST /api/discussions','2026-03-16 22:31:28'),(424,59,'UPDATE','discussions',3,NULL,'{\"title\":\"Updated Discussion Title\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE discussions via PUT /api/discussions/3','2026-03-16 22:31:28'),(425,59,'UPDATE','discussions',3,NULL,'{\"isPinned\":true}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE discussions via PATCH /api/discussions/3/pin','2026-03-16 22:31:29'),(426,59,'UPDATE','discussions',3,NULL,'{\"isLocked\":true}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE discussions via PATCH /api/discussions/3/lock','2026-03-16 22:31:29'),(427,59,'CREATE','community',NULL,NULL,'{\"title\":\"API Dog Test Post\",\"content\":\"Testing from API Dog.\",\"communityId\":1}','127.0.0.1','PostmanRuntime/7.52.0','CREATE community via POST /api/community/communities/1/posts','2026-03-16 22:31:29'),(428,59,'CREATE','community',NULL,NULL,'{\"title\":\"Global Post from API Dog\",\"content\":\"Test global post.\",\"communityId\":1}','127.0.0.1','PostmanRuntime/7.52.0','CREATE community via POST /api/community/global/posts','2026-03-16 22:31:29'),(429,59,'CREATE','community',3,NULL,'{\"commentText\":\"API Dog test comment\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE community via POST /api/community/posts/3/comment','2026-03-16 22:31:30'),(430,59,'CREATE','community',3,NULL,'{\"reactionType\":\"like\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE community via POST /api/community/posts/3/react','2026-03-16 22:31:30'),(431,59,'CREATE','files',NULL,NULL,'{\"folderName\":\"API Dog Test Folder\",\"parentFolderId\":1}','127.0.0.1','PostmanRuntime/7.52.0','CREATE files via POST /api/files/folders','2026-03-16 22:31:31'),(432,59,'UPDATE','files',NULL,NULL,'{\"folderName\":\"Updated Test Folder\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE files via PUT /api/files/folders/26','2026-03-16 22:31:31'),(433,59,'DELETE','files',NULL,NULL,NULL,'127.0.0.1','PostmanRuntime/7.52.0','DELETE files via DELETE /api/files/folders/26','2026-03-16 22:31:31'),(434,59,'CREATE','labs',NULL,NULL,'{\"title\":\"API Dog Test Lab\",\"courseId\":1,\"description\":\"Test lab\",\"dueDate\":\"2026-06-15T23:59:00Z\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE labs via POST /api/labs','2026-03-16 22:31:32'),(435,59,'UPDATE','labs',3,NULL,'{\"title\":\"Updated Lab Title\"}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE labs via PUT /api/labs/3','2026-03-16 22:31:33'),(436,58,'CREATE','rubrics',NULL,NULL,'{\"rubricName\":\"API Dog Test Rubric\",\"courseId\":1,\"totalPoints\":100}','127.0.0.1','PostmanRuntime/7.52.0','CREATE rubrics via POST /api/rubrics','2026-03-16 22:31:34'),(437,59,'CREATE','attendance',NULL,NULL,'{\"sectionId\":1,\"sessionDate\":\"2026-03-15\",\"sessionType\":\"lecture\",\"startTime\":\"09:00:00\",\"endTime\":\"10:30:00\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE attendance via POST /attendance/sessions','2026-03-16 22:31:34'),(438,57,'UPDATE','notifications',NULL,NULL,'{\"emailEnabled\":true,\"pushEnabled\":true}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE notifications via PUT /api/notifications/preferences','2026-03-16 22:31:35'),(439,57,'UPDATE','notifications',NULL,NULL,'{}','127.0.0.1','PostmanRuntime/7.52.0','UPDATE notifications via PATCH /api/notifications/read-all','2026-03-16 22:31:35'),(440,59,'CREATE','notifications',NULL,NULL,'{\"userIds\":[57],\"notificationType\":\"system\",\"title\":\"Test from API Dog\",\"body\":\"This is a test notification.\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE notifications via POST /api/notifications/send','2026-03-16 22:31:35'),(441,57,'CREATE','messages',NULL,NULL,'{\"participantIds\":[59],\"type\":\"direct\",\"text\":\"Hello from API Dog test!\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE messages via POST /api/messages/conversations','2026-03-16 22:31:35'),(442,59,'CREATE','calendar',NULL,NULL,'{\"title\":\"API Dog Test Event\",\"description\":\"Test\",\"startTime\":\"2026-04-01T10:00:00Z\",\"endTime\":\"2026-04-01T11:00:00Z\",\"eventType\":\"meeting\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE calendar via POST /api/calendar/events','2026-03-16 22:31:36'),(443,59,'DELETE','calendar',17,NULL,NULL,'127.0.0.1','PostmanRuntime/7.52.0','DELETE calendar via DELETE /api/calendar/events/17','2026-03-16 22:31:36'),(444,57,'CREATE','tasks',NULL,NULL,'{\"title\":\"Study for Final Exam\",\"description\":\"Review all chapters\",\"taskType\":\"study\",\"dueDate\":\"2026-03-18T18:14:01.673Z\",\"priority\":\"high\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE tasks via POST /api/tasks','2026-03-16 22:31:37'),(445,57,'CREATE','tasks',8,NULL,'{\"notes\":\"Finished studying all chapters\",\"timeTakenMinutes\":120}','127.0.0.1','PostmanRuntime/7.52.0','CREATE tasks via POST /api/tasks/8/complete','2026-03-16 22:31:37'),(446,57,'CREATE','tasks',NULL,NULL,'{\"taskId\":9,\"reminderTime\":\"2026-03-17T18:14:01.673Z\",\"reminderType\":\"in_app\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE tasks via POST /api/tasks/reminders','2026-03-16 22:31:38'),(447,57,'DELETE','search',NULL,NULL,NULL,'127.0.0.1','PostmanRuntime/7.52.0','DELETE search via DELETE /api/search/history','2026-03-16 22:31:38'),(448,59,'CREATE','reports',NULL,NULL,'{\"templateId\":1,\"reportName\":\"Test Student Progress Report\",\"filters\":{\"courseId\":1,\"semesterId\":2},\"exportFormat\":\"pdf\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE reports via POST /api/reports/generate','2026-03-16 22:31:40'),(449,NULL,'CREATE','google-drive',NULL,NULL,'{\"name\":\"EduVerse_Test_Folder\",\"parentId\":\"\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE google-drive via POST /google-drive/folders','2026-03-16 22:31:41'),(450,NULL,'CREATE','google-drive',NULL,NULL,'{\"name\":\"EduVerse_Test_Folder\",\"parentId\":\"\"}','127.0.0.1','PostmanRuntime/7.52.0','CREATE google-drive via POST /google-drive/folders/find-or-create','2026-03-16 22:31:42'),(451,59,'CREATE','google-drive',NULL,NULL,NULL,'127.0.0.1','PostmanRuntime/7.52.0','CREATE google-drive via POST /google-drive/admin/init','2026-03-16 22:31:44'),(452,59,'CREATE','google-drive',1,NULL,NULL,'127.0.0.1','PostmanRuntime/7.52.0','CREATE google-drive via POST /google-drive/admin/courses/1/init','2026-03-16 22:31:44'),(453,59,'CREATE','google-drive',NULL,NULL,NULL,'127.0.0.1','PostmanRuntime/7.52.0','CREATE google-drive via POST /google-drive/admin/labs/3/init','2026-03-16 22:31:44'),(454,59,'CREATE','google-drive',NULL,NULL,NULL,'127.0.0.1','PostmanRuntime/7.52.0','CREATE google-drive via POST /google-drive/admin/assignments/1/init','2026-03-16 22:31:44');
/*!40000 ALTER TABLE `audit_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `backup_records`
--

DROP TABLE IF EXISTS `backup_records`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `backup_records` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `file_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_size_bytes` bigint unsigned NOT NULL DEFAULT '0',
  `type` enum('manual','scheduled') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'manual',
  `status` enum('pending','in_progress','completed','failed') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  `created_by` bigint unsigned DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `completed_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `backup_records_ibfk_created_by` (`created_by`),
  CONSTRAINT `backup_records_ibfk_created_by` FOREIGN KEY (`created_by`) REFERENCES `users` (`user_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `backup_records`
--

LOCK TABLES `backup_records` WRITE;
/*!40000 ALTER TABLE `backup_records` DISABLE KEYS */;
INSERT INTO `backup_records` VALUES (1,'backup_2026-03-16T22-04-58-526Z.sql',687684,'manual','completed',NULL,'2026-03-16 22:04:58','2026-03-16 22:05:00'),(3,'backup_2026-03-16T22-34-10-919Z.sql',0,'manual','in_progress',NULL,'2026-03-16 22:34:10',NULL);
/*!40000 ALTER TABLE `backup_records` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `badges`
--

DROP TABLE IF EXISTS `badges`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `badges` (
  `badge_id` int unsigned NOT NULL AUTO_INCREMENT,
  `badge_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `badge_description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `badge_icon_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `badge_category` enum('achievement','milestone','special','course') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'achievement',
  `rarity` enum('common','rare','epic','legendary') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'common',
  `points_reward` int DEFAULT '0',
  `criteria` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`badge_id`),
  UNIQUE KEY `badge_name` (`badge_name`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `badges`
--

LOCK TABLES `badges` WRITE;
/*!40000 ALTER TABLE `badges` DISABLE KEYS */;
INSERT INTO `badges` VALUES (1,'First Steps','Complete your first assignment',NULL,'achievement','common',10,NULL,1,'2025-11-20 13:43:00'),(2,'Quiz Master','Score 100% on a quiz',NULL,'achievement','rare',50,NULL,1,'2025-11-20 13:43:00'),(3,'Perfect Attendance','Attend all classes in a week',NULL,'milestone','rare',25,NULL,1,'2025-11-20 13:43:00'),(4,'Early Bird','Submit 5 assignments early',NULL,'achievement','epic',100,NULL,1,'2025-11-20 13:43:00'),(5,'Helpful Peer','Complete 10 peer reviews',NULL,'achievement','rare',50,NULL,1,'2025-11-20 13:43:00'),(6,'Level 5','Reach level 5',NULL,'milestone','epic',75,NULL,1,'2025-11-20 13:43:00'),(7,'Overachiever','Score above 95% average',NULL,'achievement','legendary',200,NULL,1,'2025-11-20 13:43:00'),(8,'Consistent Learner','Maintain 30-day streak',NULL,'milestone','epic',150,NULL,1,'2025-11-20 13:43:00');
/*!40000 ALTER TABLE `badges` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `blocked_ips`
--

DROP TABLE IF EXISTS `blocked_ips`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `blocked_ips` (
  `ip_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `ip_address` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `blocked_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `expires_at` timestamp NULL DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`ip_id`),
  UNIQUE KEY `idx_ip_address` (`ip_address`),
  KEY `idx_is_active` (`is_active`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `blocked_ips`
--

LOCK TABLES `blocked_ips` WRITE;
/*!40000 ALTER TABLE `blocked_ips` DISABLE KEYS */;
INSERT INTO `blocked_ips` VALUES (1,'192.168.1.50','Repeated failed logins','2026-03-16 20:59:21',NULL,0);
/*!40000 ALTER TABLE `blocked_ips` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `branding_settings`
--

DROP TABLE IF EXISTS `branding_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `branding_settings` (
  `branding_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `campus_id` bigint unsigned NOT NULL,
  `logo_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `favicon_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `primary_color` varchar(7) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT '#007bff',
  `secondary_color` varchar(7) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT '#6c757d',
  `custom_css` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `email_header_html` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `email_footer_html` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `updated_by` bigint unsigned DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`branding_id`),
  UNIQUE KEY `campus_id` (`campus_id`),
  KEY `branding_settings_ibfk_updated_by` (`updated_by`),
  CONSTRAINT `branding_settings_ibfk_1` FOREIGN KEY (`campus_id`) REFERENCES `campuses` (`campus_id`) ON DELETE CASCADE,
  CONSTRAINT `branding_settings_ibfk_updated_by` FOREIGN KEY (`updated_by`) REFERENCES `users` (`user_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `branding_settings`
--

LOCK TABLES `branding_settings` WRITE;
/*!40000 ALTER TABLE `branding_settings` DISABLE KEYS */;
INSERT INTO `branding_settings` VALUES (1,1,'/assets/logos/main_campus_logo.png','/assets/favicons/main_campus.ico','#ff0000','#6c757d',NULL,NULL,NULL,66,'2026-03-16 20:57:27'),(2,2,'/assets/logos/downtown_campus_logo.png','/assets/favicons/downtown_campus.ico','#28a745','#6c757d',NULL,NULL,NULL,NULL,'2025-11-20 13:43:00'),(3,3,'/assets/logos/online_campus_logo.png','/assets/favicons/online_campus.ico','#17a2b8','#6c757d',NULL,NULL,NULL,NULL,'2025-11-20 13:43:00');
/*!40000 ALTER TABLE `branding_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `calendar_events`
--

DROP TABLE IF EXISTS `calendar_events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `calendar_events` (
  `event_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `course_id` bigint unsigned DEFAULT NULL,
  `event_type` enum('lecture','lab','exam','assignment','quiz','meeting','custom') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `location` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `color` varchar(7) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `start_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `end_time` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `schedule_id` bigint unsigned DEFAULT NULL,
  `exam_id` bigint unsigned DEFAULT NULL,
  `is_recurring` tinyint(1) DEFAULT '0',
  `recurrence_pattern` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `reminder_minutes` int DEFAULT '30',
  `status` enum('scheduled','completed','cancelled') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'scheduled',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`event_id`),
  KEY `schedule_id` (`schedule_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_course` (`course_id`),
  KEY `idx_start` (`start_time`),
  CONSTRAINT `calendar_events_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `calendar_events_ibfk_2` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`) ON DELETE CASCADE,
  CONSTRAINT `calendar_events_ibfk_3` FOREIGN KEY (`schedule_id`) REFERENCES `course_schedules` (`schedule_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `calendar_events`
--

LOCK TABLES `calendar_events` WRITE;
/*!40000 ALTER TABLE `calendar_events` DISABLE KEYS */;
INSERT INTO `calendar_events` VALUES (8,59,NULL,'meeting','API Dog Test Event','Test',NULL,NULL,'2026-04-01 10:00:00','2026-04-01 11:00:00',NULL,NULL,0,NULL,30,'scheduled','2026-03-14 15:17:53','2026-03-14 15:17:53');
/*!40000 ALTER TABLE `calendar_events` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `calendar_integrations`
--

DROP TABLE IF EXISTS `calendar_integrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `calendar_integrations` (
  `integration_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `calendar_type` enum('google','outlook','ical') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `access_token_encrypted` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `refresh_token_encrypted` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `last_sync` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `sync_status` enum('active','error','disabled') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`integration_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_status` (`sync_status`),
  CONSTRAINT `calendar_integrations_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `calendar_integrations`
--

LOCK TABLES `calendar_integrations` WRITE;
/*!40000 ALTER TABLE `calendar_integrations` DISABLE KEYS */;
INSERT INTO `calendar_integrations` VALUES (1,7,'google',NULL,NULL,'2025-02-15 04:00:00','active','2025-11-20 13:43:00','2025-11-20 13:43:00'),(2,8,'outlook',NULL,NULL,'2025-02-15 04:15:00','active','2025-11-20 13:43:00','2025-11-20 13:43:00'),(3,9,'google',NULL,NULL,'2025-02-14 16:30:00','error','2025-11-20 13:43:00','2025-11-20 13:43:00'),(4,10,'ical',NULL,NULL,'2025-02-15 04:30:00','active','2025-11-20 13:43:00','2025-11-20 13:43:00');
/*!40000 ALTER TABLE `calendar_integrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `campuses`
--

DROP TABLE IF EXISTS `campuses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `campuses` (
  `campus_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `campus_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `campus_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `address` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `city` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `country` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `timezone` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'UTC',
  `status` enum('active','inactive') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'active',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`campus_id`),
  UNIQUE KEY `campus_code` (`campus_code`),
  KEY `idx_code` (`campus_code`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `campuses`
--

LOCK TABLES `campuses` WRITE;
/*!40000 ALTER TABLE `campuses` DISABLE KEYS */;
INSERT INTO `campuses` VALUES (1,'Updated Campus Name','MC001','123 University Ave','New York','USA','+1-555-0100','info@maincampus.edu','America/New_York','active','2025-11-20 13:42:59','2026-03-02 23:28:34'),(2,'Downtown Campus','DC002','456 Downtown St','Los Angeles','USA','+1-555-0200','info@downtown.edu','America/Los_Angeles','active','2025-11-20 13:42:59','2025-11-20 13:42:59'),(3,'Online Campus','OC003','789 Virtual Plaza','Chicago','USA','+1-555-0300','info@online.edu','America/Chicago','active','2025-11-20 13:42:59','2025-11-20 13:42:59'),(4,'Main Campus Updated','MAIN2','456 University Ave','Boston','USA','+1-555-0456','main2@university.edu','America/Boston','inactive','2025-11-26 18:16:28','2025-11-26 18:22:21'),(14,'Test Campus Z','TCZ','123 St','NYC','US','555-1234',NULL,'UTC','active','2026-03-02 13:29:51','2026-03-02 13:29:51'),(15,'AutoTest','AT1',NULL,NULL,NULL,NULL,NULL,'UTC','active','2026-03-02 13:49:12','2026-03-02 13:49:12'),(16,'Test Campus','TC01','123 Test St','Cairo','Egypt','+20 123 456 7890','campus@test.com','Africa/Cairo','active','2026-03-02 23:28:34','2026-03-02 23:28:34'),(17,'API Dog Test Campus','APIDOG01','123 Test St','Cairo','Egypt',NULL,NULL,'UTC','active','2026-03-11 17:37:43','2026-03-11 17:37:43');
/*!40000 ALTER TABLE `campuses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `certificates`
--

DROP TABLE IF EXISTS `certificates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `certificates` (
  `certificate_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `course_id` bigint unsigned NOT NULL,
  `certificate_number` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `certificate_type` enum('completion','excellence','participation') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `issue_date` date DEFAULT NULL,
  `expiry_date` date DEFAULT NULL,
  `file_id` bigint unsigned DEFAULT NULL,
  `verification_hash` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_verified` tinyint(1) DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`certificate_id`),
  UNIQUE KEY `certificate_number` (`certificate_number`),
  KEY `file_id` (`file_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_course` (`course_id`),
  KEY `idx_cert_number` (`certificate_number`),
  CONSTRAINT `certificates_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `certificates_ibfk_2` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`) ON DELETE CASCADE,
  CONSTRAINT `certificates_ibfk_3` FOREIGN KEY (`file_id`) REFERENCES `files` (`file_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `certificates`
--

LOCK TABLES `certificates` WRITE;
/*!40000 ALTER TABLE `certificates` DISABLE KEYS */;
/*!40000 ALTER TABLE `certificates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `chat_messages`
--

DROP TABLE IF EXISTS `chat_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `chat_messages` (
  `message_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `thread_id` bigint unsigned NOT NULL,
  `user_id` bigint unsigned NOT NULL,
  `message_text` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `parent_message_id` bigint unsigned DEFAULT NULL,
  `is_answer` tinyint(1) DEFAULT '0',
  `is_endorsed` tinyint(1) DEFAULT '0',
  `endorsed_by` bigint unsigned DEFAULT NULL,
  `upvote_count` int DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`message_id`),
  KEY `parent_message_id` (`parent_message_id`),
  KEY `endorsed_by` (`endorsed_by`),
  KEY `idx_thread` (`thread_id`),
  KEY `idx_user` (`user_id`),
  CONSTRAINT `chat_messages_ibfk_1` FOREIGN KEY (`thread_id`) REFERENCES `course_chat_threads` (`thread_id`) ON DELETE CASCADE,
  CONSTRAINT `chat_messages_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `chat_messages_ibfk_3` FOREIGN KEY (`parent_message_id`) REFERENCES `chat_messages` (`message_id`) ON DELETE CASCADE,
  CONSTRAINT `chat_messages_ibfk_4` FOREIGN KEY (`endorsed_by`) REFERENCES `users` (`user_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chat_messages`
--

LOCK TABLES `chat_messages` WRITE;
/*!40000 ALTER TABLE `chat_messages` DISABLE KEYS */;
INSERT INTO `chat_messages` VALUES (6,3,13,'Here is a great YouTube playlist for data structures: [link]',NULL,0,0,NULL,7,'2025-11-20 13:43:00','2025-11-20 13:43:00'),(9,5,58,'I have uploaded the lecture slides to the course files. Check Chapter 5 section for detailed notes.',NULL,0,0,NULL,0,'2026-03-03 18:24:42','2026-03-03 18:24:42'),(10,5,57,'Thank you professor! I found the slides very helpful.',9,0,0,NULL,0,'2026-03-03 18:24:43','2026-03-03 18:24:43'),(11,6,58,'Great initiative! Focus on the key theorems from Chapter 7 as they carry the most weight.',NULL,1,1,58,0,'2026-03-03 18:26:57','2026-03-05 19:16:31'),(12,6,57,'Thanks professor! Will definitely prioritize Chapter 7.',11,0,0,NULL,0,'2026-03-03 18:26:58','2026-03-03 18:26:58'),(13,6,58,'I recommend using an adjacency list for sparse graphs and a matrix for dense ones. BFS is optimal for shortest path.',NULL,0,0,NULL,0,'2026-03-03 18:34:12','2026-03-03 18:34:12'),(14,6,57,'Would a priority queue help with Dijkstras implementation?',11,0,0,NULL,0,'2026-03-03 18:34:12','2026-03-03 18:34:12'),(15,6,60,'OH',NULL,0,0,NULL,0,'2026-03-10 17:28:42','2026-03-10 17:28:42'),(16,3,59,'Test reply from API Dog.',NULL,0,0,NULL,0,'2026-03-14 15:17:46','2026-03-14 15:17:46'),(17,3,59,'Test reply from API Dog.',NULL,0,0,NULL,0,'2026-03-14 15:40:43','2026-03-14 15:40:43'),(18,3,59,'Test reply from API Dog.',NULL,0,0,NULL,0,'2026-03-16 20:19:03','2026-03-16 20:19:03'),(19,3,59,'Test reply from API Dog.',NULL,0,0,NULL,0,'2026-03-16 20:32:50','2026-03-16 20:32:50'),(20,3,59,'Test reply from API Dog.',NULL,0,0,NULL,0,'2026-03-16 20:53:52','2026-03-16 20:53:52');
/*!40000 ALTER TABLE `chat_messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `chatbot_conversations`
--

DROP TABLE IF EXISTS `chatbot_conversations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `chatbot_conversations` (
  `conversation_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `course_id` bigint unsigned DEFAULT NULL,
  `conversation_title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `context_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `status` enum('active','archived','deleted') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'active',
  `started_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_message_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`conversation_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_course` (`course_id`),
  KEY `idx_status` (`status`),
  CONSTRAINT `chatbot_conversations_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `chatbot_conversations_ibfk_2` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chatbot_conversations`
--

LOCK TABLES `chatbot_conversations` WRITE;
/*!40000 ALTER TABLE `chatbot_conversations` DISABLE KEYS */;
INSERT INTO `chatbot_conversations` VALUES (1,7,NULL,'Help with Assignment 1',NULL,'active','2025-11-20 13:43:00','2025-11-20 13:43:00'),(2,8,NULL,'Python Syntax Questions',NULL,'active','2025-11-20 13:43:00','2025-11-20 13:43:00'),(3,9,2,'Data Structures Explanation',NULL,'archived','2025-11-20 13:43:00','2025-11-20 13:43:00');
/*!40000 ALTER TABLE `chatbot_conversations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `chatbot_messages`
--

DROP TABLE IF EXISTS `chatbot_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `chatbot_messages` (
  `message_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `conversation_id` bigint unsigned NOT NULL,
  `sender_type` enum('user','bot') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `message_text` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `message_metadata` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `intent` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `confidence_score` decimal(3,2) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`message_id`),
  KEY `idx_conversation` (`conversation_id`),
  KEY `idx_sender` (`sender_type`),
  CONSTRAINT `chatbot_messages_ibfk_1` FOREIGN KEY (`conversation_id`) REFERENCES `chatbot_conversations` (`conversation_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chatbot_messages`
--

LOCK TABLES `chatbot_messages` WRITE;
/*!40000 ALTER TABLE `chatbot_messages` DISABLE KEYS */;
INSERT INTO `chatbot_messages` VALUES (1,1,'user','How do I start Assignment 1?',NULL,'help_request',0.95,'2025-11-20 13:43:00'),(2,1,'bot','To start Assignment 1, first review the assignment instructions in the course materials. You need to create a Python program that prints \"Hello World\". Would you like help with setting up your Python environment?',NULL,'help_response',NULL,'2025-11-20 13:43:00'),(3,1,'user','Yes, how do I install Python?',NULL,'help_request',0.92,'2025-11-20 13:43:00'),(4,1,'bot','Here are the steps to install Python: 1) Visit python.org, 2) Download Python 3.11 or later, 3) Run the installer, 4) Check \"Add Python to PATH\", 5) Verify installation by opening terminal and typing \"python --version\".',NULL,'help_response',NULL,'2025-11-20 13:43:00'),(5,2,'user','What is the difference between a list and a tuple?',NULL,'concept_question',0.89,'2025-11-20 13:43:00'),(6,2,'bot','Great question! Lists are mutable (can be modified) and use square brackets [], while tuples are immutable (cannot be modified) and use parentheses (). Lists: [1,2,3], Tuples: (1,2,3)',NULL,'explanation',NULL,'2025-11-20 13:43:00');
/*!40000 ALTER TABLE `chatbot_messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `collaborative_grading`
--

DROP TABLE IF EXISTS `collaborative_grading`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `collaborative_grading` (
  `collab_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `assignment_id` bigint unsigned NOT NULL,
  `submission_id` bigint unsigned NOT NULL,
  `grader_1_id` bigint unsigned NOT NULL,
  `grader_2_id` bigint unsigned DEFAULT NULL,
  `grader_1_score` decimal(5,2) DEFAULT NULL,
  `grader_2_score` decimal(5,2) DEFAULT NULL,
  `final_score` decimal(5,2) DEFAULT NULL,
  `resolution_method` enum('average','higher','manual','grader_1') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'average',
  `status` enum('pending','in_progress','completed','disputed') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `completed_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`collab_id`),
  KEY `submission_id` (`submission_id`),
  KEY `grader_1_id` (`grader_1_id`),
  KEY `grader_2_id` (`grader_2_id`),
  KEY `idx_assignment` (`assignment_id`),
  KEY `idx_status` (`status`),
  CONSTRAINT `collaborative_grading_ibfk_1` FOREIGN KEY (`assignment_id`) REFERENCES `assignments` (`assignment_id`) ON DELETE CASCADE,
  CONSTRAINT `collaborative_grading_ibfk_2` FOREIGN KEY (`submission_id`) REFERENCES `assignment_submissions` (`submission_id`) ON DELETE CASCADE,
  CONSTRAINT `collaborative_grading_ibfk_3` FOREIGN KEY (`grader_1_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `collaborative_grading_ibfk_4` FOREIGN KEY (`grader_2_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `collaborative_grading`
--

LOCK TABLES `collaborative_grading` WRITE;
/*!40000 ALTER TABLE `collaborative_grading` DISABLE KEYS */;
/*!40000 ALTER TABLE `collaborative_grading` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `communities`
--

DROP TABLE IF EXISTS `communities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `communities` (
  `community_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `community_type` enum('global','department') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `department_id` bigint unsigned DEFAULT NULL,
  `cover_image_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `created_by` bigint unsigned NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`community_id`),
  KEY `idx_community_type` (`community_type`),
  KEY `idx_department` (`department_id`),
  KEY `communities_creator_fk` (`created_by`),
  CONSTRAINT `communities_creator_fk` FOREIGN KEY (`created_by`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `communities_dept_fk` FOREIGN KEY (`department_id`) REFERENCES `departments` (`department_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `communities`
--

LOCK TABLES `communities` WRITE;
/*!40000 ALTER TABLE `communities` DISABLE KEYS */;
INSERT INTO `communities` VALUES (1,'Global Community','Platform-wide community for all users','global',NULL,NULL,1,1,'2026-03-10 18:48:58','2026-03-10 18:48:58'),(2,'Math Cohort 2026','Updated: Math department community for the 2026 cohort students','department',2,NULL,1,59,'2026-03-10 19:04:02','2026-03-10 19:05:33'),(3,'Mechanical Engineering General','ME community','department',5,NULL,1,59,'2026-03-10 19:04:27','2026-03-10 19:04:27');
/*!40000 ALTER TABLE `communities` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `community_post_comments`
--

DROP TABLE IF EXISTS `community_post_comments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `community_post_comments` (
  `comment_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `post_id` bigint unsigned NOT NULL,
  `user_id` bigint unsigned NOT NULL,
  `comment_text` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `parent_comment_id` bigint unsigned DEFAULT NULL,
  `upvote_count` int DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`comment_id`),
  KEY `parent_comment_id` (`parent_comment_id`),
  KEY `idx_post` (`post_id`),
  KEY `idx_user` (`user_id`),
  CONSTRAINT `community_post_comments_ibfk_1` FOREIGN KEY (`post_id`) REFERENCES `community_posts` (`post_id`) ON DELETE CASCADE,
  CONSTRAINT `community_post_comments_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `community_post_comments_ibfk_3` FOREIGN KEY (`parent_comment_id`) REFERENCES `community_post_comments` (`comment_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `community_post_comments`
--

LOCK TABLES `community_post_comments` WRITE;
/*!40000 ALTER TABLE `community_post_comments` DISABLE KEYS */;
INSERT INTO `community_post_comments` VALUES (8,3,57,'My comment',NULL,0,'2026-03-10 17:20:31','2026-03-10 17:20:31'),(9,7,58,'Hi guys',NULL,0,'2026-03-10 17:25:34','2026-03-10 17:25:34'),(10,7,60,'Done',NULL,0,'2026-03-10 17:25:52','2026-03-10 17:25:52'),(11,3,59,'API Dog test comment',NULL,0,'2026-03-11 17:37:51','2026-03-11 17:37:51'),(12,3,59,'API Dog test comment',NULL,0,'2026-03-14 15:36:04','2026-03-14 15:36:04'),(13,3,59,'API Dog test comment',NULL,0,'2026-03-14 15:40:44','2026-03-14 15:40:44'),(14,3,59,'API Dog test comment',NULL,0,'2026-03-14 16:06:06','2026-03-14 16:06:06'),(15,3,59,'API Dog test comment',NULL,0,'2026-03-16 20:19:05','2026-03-16 20:19:05'),(16,3,59,'API Dog test comment',NULL,0,'2026-03-16 20:20:10','2026-03-16 20:20:10'),(17,3,59,'API Dog test comment',NULL,0,'2026-03-16 20:32:52','2026-03-16 20:32:52'),(18,3,59,'API Dog test comment',NULL,0,'2026-03-16 20:45:17','2026-03-16 20:45:17'),(19,3,59,'API Dog test comment',NULL,0,'2026-03-16 20:53:54','2026-03-16 20:53:54'),(20,3,59,'API Dog test comment',NULL,0,'2026-03-16 22:31:30','2026-03-16 22:31:30');
/*!40000 ALTER TABLE `community_post_comments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `community_post_reactions`
--

DROP TABLE IF EXISTS `community_post_reactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `community_post_reactions` (
  `reaction_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `post_id` bigint unsigned NOT NULL,
  `user_id` bigint unsigned NOT NULL,
  `reaction_type` enum('like','helpful','insightful','thanks') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'like',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`reaction_id`),
  UNIQUE KEY `unique_post_user_reaction` (`post_id`,`user_id`,`reaction_type`),
  KEY `idx_post` (`post_id`),
  KEY `idx_user` (`user_id`),
  CONSTRAINT `community_post_reactions_ibfk_1` FOREIGN KEY (`post_id`) REFERENCES `community_posts` (`post_id`) ON DELETE CASCADE,
  CONSTRAINT `community_post_reactions_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `community_post_reactions`
--

LOCK TABLES `community_post_reactions` WRITE;
/*!40000 ALTER TABLE `community_post_reactions` DISABLE KEYS */;
INSERT INTO `community_post_reactions` VALUES (15,3,57,'like','2026-03-10 17:20:23'),(16,3,57,'helpful','2026-03-10 17:20:24'),(17,7,58,'like','2026-03-10 17:25:21'),(18,7,58,'insightful','2026-03-10 17:25:23'),(19,7,58,'thanks','2026-03-10 17:25:24'),(20,7,58,'helpful','2026-03-10 17:25:25'),(26,3,59,'like','2026-03-16 22:31:30');
/*!40000 ALTER TABLE `community_post_reactions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `community_post_tags`
--

DROP TABLE IF EXISTS `community_post_tags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `community_post_tags` (
  `post_id` bigint unsigned NOT NULL,
  `tag_id` bigint unsigned NOT NULL,
  PRIMARY KEY (`post_id`,`tag_id`),
  KEY `post_tags_tag_fk` (`tag_id`),
  CONSTRAINT `post_tags_post_fk` FOREIGN KEY (`post_id`) REFERENCES `community_posts` (`post_id`) ON DELETE CASCADE,
  CONSTRAINT `post_tags_tag_fk` FOREIGN KEY (`tag_id`) REFERENCES `community_tags` (`tag_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `community_post_tags`
--

LOCK TABLES `community_post_tags` WRITE;
/*!40000 ALTER TABLE `community_post_tags` DISABLE KEYS */;
INSERT INTO `community_post_tags` VALUES (8,1),(8,2),(9,3),(9,4);
/*!40000 ALTER TABLE `community_post_tags` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `community_posts`
--

DROP TABLE IF EXISTS `community_posts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `community_posts` (
  `post_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `course_id` bigint unsigned DEFAULT NULL,
  `community_id` bigint unsigned DEFAULT NULL,
  `user_id` bigint unsigned NOT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `post_type` enum('discussion','question','announcement','resource') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'discussion',
  `is_pinned` tinyint(1) DEFAULT '0',
  `is_locked` tinyint(1) DEFAULT '0',
  `view_count` int DEFAULT '0',
  `upvote_count` int DEFAULT '0',
  `reply_count` int DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`post_id`),
  KEY `idx_course` (`course_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_community` (`community_id`),
  CONSTRAINT `community_posts_community_fk` FOREIGN KEY (`community_id`) REFERENCES `communities` (`community_id`) ON DELETE CASCADE,
  CONSTRAINT `community_posts_course_fk` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`) ON DELETE CASCADE,
  CONSTRAINT `community_posts_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `community_posts`
--

LOCK TABLES `community_posts` WRITE;
/*!40000 ALTER TABLE `community_posts` DISABLE KEYS */;
INSERT INTO `community_posts` VALUES (3,NULL,1,12,'Study Group for Midterm','Anyone interested in forming a study group for the upcoming midterm? We can meet on weekends.','discussion',0,0,55,11,16,'2025-11-20 13:43:00','2026-03-16 22:31:30'),(7,NULL,1,58,'Post 1 Trying to test the posts','Post 1 Content','announcement',0,0,8,4,2,'2026-03-10 17:25:16','2026-03-10 18:49:07'),(8,NULL,1,57,'First Tagged Post','Testing tags system','discussion',0,0,0,0,0,'2026-03-10 19:04:01','2026-03-10 19:04:01'),(9,NULL,2,57,'Math Study Group','Anyone want to study linear algebra?','discussion',0,0,0,0,0,'2026-03-10 19:04:33','2026-03-10 19:04:33'),(10,NULL,1,59,'API Dog Test Post','Testing from API Dog.','discussion',0,0,0,0,0,'2026-03-11 17:37:50','2026-03-11 17:37:50'),(11,NULL,1,59,'Global Post from API Dog','Test global post.','discussion',0,0,0,0,0,'2026-03-11 17:37:50','2026-03-11 17:37:50'),(12,NULL,1,59,'API Dog Test Post','Testing from API Dog.','discussion',0,0,0,0,0,'2026-03-14 15:17:46','2026-03-14 15:17:46'),(13,NULL,1,59,'Global Post from API Dog','Test global post.','discussion',0,0,0,0,0,'2026-03-14 15:17:47','2026-03-14 15:17:47'),(14,NULL,1,59,'API Dog Test Post','Testing from API Dog.','discussion',0,0,0,0,0,'2026-03-14 15:36:03','2026-03-14 15:36:03'),(15,NULL,1,59,'Global Post from API Dog','Test global post.','discussion',0,0,0,0,0,'2026-03-14 15:36:04','2026-03-14 15:36:04'),(16,NULL,1,59,'API Dog Test Post','Testing from API Dog.','discussion',0,0,0,0,0,'2026-03-14 15:40:43','2026-03-14 15:40:43'),(17,NULL,1,59,'Global Post from API Dog','Test global post.','discussion',0,0,0,0,0,'2026-03-14 15:40:44','2026-03-14 15:40:44'),(18,NULL,1,59,'API Dog Test Post','Testing from API Dog.','discussion',0,0,0,0,0,'2026-03-14 16:06:06','2026-03-14 16:06:06'),(19,NULL,1,59,'Global Post from API Dog','Test global post.','discussion',0,0,0,0,0,'2026-03-14 16:06:06','2026-03-14 16:06:06'),(20,NULL,1,59,'API Dog Test Post','Testing from API Dog.','discussion',0,0,0,0,0,'2026-03-16 20:19:04','2026-03-16 20:19:04'),(21,NULL,1,59,'Global Post from API Dog','Test global post.','discussion',0,0,0,0,0,'2026-03-16 20:19:04','2026-03-16 20:19:04'),(22,NULL,1,59,'API Dog Test Post','Testing from API Dog.','discussion',0,0,0,0,0,'2026-03-16 20:20:10','2026-03-16 20:20:10'),(23,NULL,1,59,'Global Post from API Dog','Test global post.','discussion',0,0,0,0,0,'2026-03-16 20:20:10','2026-03-16 20:20:10'),(24,NULL,1,59,'API Dog Test Post','Testing from API Dog.','discussion',0,0,0,0,0,'2026-03-16 20:32:51','2026-03-16 20:32:51'),(25,NULL,1,59,'Global Post from API Dog','Test global post.','discussion',0,0,0,0,0,'2026-03-16 20:32:51','2026-03-16 20:32:51'),(26,NULL,1,59,'API Dog Test Post','Testing from API Dog.','discussion',0,0,0,0,0,'2026-03-16 20:45:17','2026-03-16 20:45:17'),(27,NULL,1,59,'Global Post from API Dog','Test global post.','discussion',0,0,0,0,0,'2026-03-16 20:45:17','2026-03-16 20:45:17'),(28,NULL,1,59,'API Dog Test Post','Testing from API Dog.','discussion',0,0,0,0,0,'2026-03-16 20:53:53','2026-03-16 20:53:53'),(29,NULL,1,59,'Global Post from API Dog','Test global post.','discussion',0,0,0,0,0,'2026-03-16 20:53:53','2026-03-16 20:53:53'),(30,NULL,1,59,'API Dog Test Post','Testing from API Dog.','discussion',0,0,0,0,0,'2026-03-16 22:31:29','2026-03-16 22:31:29'),(31,NULL,1,59,'Global Post from API Dog','Test global post.','discussion',0,0,0,0,0,'2026-03-16 22:31:29','2026-03-16 22:31:29');
/*!40000 ALTER TABLE `community_posts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `community_tags`
--

DROP TABLE IF EXISTS `community_tags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `community_tags` (
  `tag_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`tag_id`),
  UNIQUE KEY `unique_tag_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `community_tags`
--

LOCK TABLES `community_tags` WRITE;
/*!40000 ALTER TABLE `community_tags` DISABLE KEYS */;
INSERT INTO `community_tags` VALUES (1,'study-tips','2026-03-10 19:04:00'),(2,'exam-prep','2026-03-10 19:04:01'),(3,'math','2026-03-10 19:04:33'),(4,'study-group','2026-03-10 19:04:33'),(5,'apidog-test','2026-03-11 17:20:05');
/*!40000 ALTER TABLE `community_tags` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `content_translations`
--

DROP TABLE IF EXISTS `content_translations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `content_translations` (
  `translation_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `entity_type` enum('course','material','assignment','quiz','announcement','instruction') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `entity_id` bigint unsigned NOT NULL,
  `field_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `language_code` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `translated_content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `translator_type` enum('human','ai','system') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'human',
  `translator_id` bigint unsigned DEFAULT NULL,
  `quality_score` decimal(3,2) DEFAULT NULL,
  `is_verified` tinyint(1) DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`translation_id`),
  UNIQUE KEY `unique_entity_field_lang` (`entity_type`,`entity_id`,`field_name`,`language_code`),
  KEY `translator_id` (`translator_id`),
  KEY `idx_entity` (`entity_type`,`entity_id`),
  KEY `idx_language` (`language_code`),
  CONSTRAINT `content_translations_ibfk_1` FOREIGN KEY (`translator_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `content_translations`
--

LOCK TABLES `content_translations` WRITE;
/*!40000 ALTER TABLE `content_translations` DISABLE KEYS */;
INSERT INTO `content_translations` VALUES (1,'course',1,'course_name','es','Introducci??n a la Programaci??n','ai',NULL,0.95,1,'2025-11-20 13:43:00','2025-11-20 13:43:00'),(2,'course',1,'course_description','es','Conceptos b??sicos de programaci??n usando Python','ai',NULL,0.92,1,'2025-11-20 13:43:00','2025-11-20 13:43:00'),(3,'assignment',1,'title','es','Tarea 1: Hola Mundo','ai',NULL,0.98,1,'2025-11-20 13:43:00','2025-11-20 13:43:00'),(4,'announcement',1,'title','fr','D??but du cours','human',NULL,1.00,1,'2025-11-20 13:43:00','2025-11-20 13:43:00'),(5,'material',1,'title','ar','???????? ????????????','ai',NULL,0.88,0,'2025-11-20 13:43:00','2025-11-20 13:43:00');
/*!40000 ALTER TABLE `content_translations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `course_analytics`
--

DROP TABLE IF EXISTS `course_analytics`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `course_analytics` (
  `analytics_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `course_id` bigint unsigned NOT NULL,
  `instructor_id` bigint unsigned NOT NULL,
  `total_students` int DEFAULT '0',
  `active_students` int DEFAULT '0',
  `average_grade` decimal(5,2) DEFAULT NULL,
  `average_attendance` decimal(5,2) DEFAULT NULL,
  `completion_rate` decimal(5,2) DEFAULT NULL,
  `engagement_score` decimal(5,2) DEFAULT NULL,
  `calculation_date` date NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`analytics_id`),
  KEY `idx_course` (`course_id`),
  KEY `idx_instructor` (`instructor_id`),
  KEY `idx_date` (`calculation_date`),
  CONSTRAINT `course_analytics_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`) ON DELETE CASCADE,
  CONSTRAINT `course_analytics_ibfk_2` FOREIGN KEY (`instructor_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `course_analytics`
--

LOCK TABLES `course_analytics` WRITE;
/*!40000 ALTER TABLE `course_analytics` DISABLE KEYS */;
INSERT INTO `course_analytics` VALUES (2,2,3,12,11,82.75,88.50,72.30,84.10,'2025-02-15','2025-11-20 13:43:01'),(3,3,3,10,10,87.20,95.00,85.40,91.30,'2025-02-15','2025-11-20 13:43:01'),(5,1,58,35,30,78.50,85.20,65.00,72.30,'2026-03-11','2026-03-11 18:12:04'),(6,2,58,28,25,82.10,90.50,70.00,80.15,'2026-03-11','2026-03-11 18:12:04'),(7,3,58,22,20,75.30,78.60,55.00,68.90,'2026-03-11','2026-03-11 18:12:04'),(8,4,58,18,15,88.00,92.30,80.00,85.40,'2026-03-11','2026-03-11 18:12:04');
/*!40000 ALTER TABLE `course_analytics` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `course_chat_threads`
--

DROP TABLE IF EXISTS `course_chat_threads`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `course_chat_threads` (
  `thread_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `course_id` bigint unsigned NOT NULL,
  `created_by` bigint unsigned NOT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `status` enum('open','answered','closed') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'open',
  `is_pinned` tinyint(1) DEFAULT '0',
  `is_locked` tinyint(1) DEFAULT '0',
  `view_count` int DEFAULT '0',
  `reply_count` int DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`thread_id`),
  KEY `idx_course` (`course_id`),
  KEY `idx_creator` (`created_by`),
  CONSTRAINT `course_chat_threads_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`) ON DELETE CASCADE,
  CONSTRAINT `course_chat_threads_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `course_chat_threads`
--

LOCK TABLES `course_chat_threads` WRITE;
/*!40000 ALTER TABLE `course_chat_threads` DISABLE KEYS */;
INSERT INTO `course_chat_threads` VALUES (3,2,12,'Updated Discussion Title','Share study resources and tips','open',0,0,69,20,'2025-11-20 13:43:00','2026-03-16 22:31:29'),(5,1,57,'Help with Midterm Review - Chapter 5','Can anyone share their notes on Chapter 5? I missed the lecture and need help understanding the key concepts.','open',0,0,2,2,'2026-03-03 18:24:20','2026-03-10 17:28:48'),(6,1,57,'Tips for Final Project - Data Structures & Algorithms','Updated: Including both data structures and algorithm choices for the graph module.','open',1,0,6,5,'2026-03-03 18:26:52','2026-03-10 17:28:47'),(8,1,57,'Tips for Final Project - Data Structures','What data structures would you recommend for implementing the graph traversal module?','open',0,0,0,0,'2026-03-03 18:34:11','2026-03-03 18:34:11'),(10,1,57,'Temporary Thread - Delete Test','This thread can be safely deleted for testing purposes.','open',0,0,3,0,'2026-03-03 18:43:55','2026-03-03 18:44:57'),(11,1,57,'Tips for Final Project - Data Structures','What data structures would you recommend for implementing the graph traversal module?','open',0,0,1,0,'2026-03-05 19:16:30','2026-03-10 17:28:46'),(12,1,59,'API Dog Test Discussion','Testing from API Dog.','open',0,0,0,0,'2026-03-11 17:37:49','2026-03-11 17:37:49'),(13,1,59,'API Dog Test Discussion','Testing from API Dog.','open',0,0,0,0,'2026-03-14 15:17:45','2026-03-14 15:17:45'),(14,1,59,'API Dog Test Discussion','Testing from API Dog.','open',0,0,0,0,'2026-03-14 15:36:02','2026-03-14 15:36:02'),(15,1,59,'API Dog Test Discussion','Testing from API Dog.','open',0,0,0,0,'2026-03-14 15:40:43','2026-03-14 15:40:43'),(16,1,59,'API Dog Test Discussion','Testing from API Dog.','open',0,0,0,0,'2026-03-14 16:06:05','2026-03-14 16:06:05'),(17,1,59,'API Dog Test Discussion','Testing from API Dog.','open',0,0,0,0,'2026-03-16 20:19:03','2026-03-16 20:19:03'),(18,1,59,'API Dog Test Discussion','Testing from API Dog.','open',0,0,0,0,'2026-03-16 20:20:09','2026-03-16 20:20:09'),(19,1,59,'API Dog Test Discussion','Testing from API Dog.','open',0,0,0,0,'2026-03-16 20:32:50','2026-03-16 20:32:50'),(20,1,59,'API Dog Test Discussion','Testing from API Dog.','open',0,0,0,0,'2026-03-16 20:45:16','2026-03-16 20:45:16'),(21,1,59,'API Dog Test Discussion','Testing from API Dog.','open',0,0,0,0,'2026-03-16 20:53:52','2026-03-16 20:53:52'),(22,1,59,'API Dog Test Discussion','Testing from API Dog.','open',0,0,0,0,'2026-03-16 22:31:28','2026-03-16 22:31:28');
/*!40000 ALTER TABLE `course_chat_threads` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `course_enrollments`
--

DROP TABLE IF EXISTS `course_enrollments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `course_enrollments` (
  `enrollment_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `section_id` bigint unsigned NOT NULL,
  `program_id` bigint unsigned DEFAULT NULL,
  `enrollment_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `enrollment_status` enum('enrolled','dropped','completed','withdrawn') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'enrolled',
  `grade` varchar(5) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `final_score` decimal(5,2) DEFAULT NULL,
  `dropped_at` timestamp NULL DEFAULT NULL,
  `completed_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`enrollment_id`),
  UNIQUE KEY `unique_enrollment` (`user_id`,`section_id`),
  KEY `program_id` (`program_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_section` (`section_id`),
  KEY `idx_status` (`enrollment_status`),
  KEY `idx_user_status` (`user_id`,`enrollment_status`),
  KEY `idx_section_status` (`section_id`,`enrollment_status`),
  KEY `idx_composite_lookup` (`user_id`,`section_id`,`enrollment_status`),
  CONSTRAINT `course_enrollments_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `course_enrollments_ibfk_2` FOREIGN KEY (`section_id`) REFERENCES `course_sections` (`section_id`) ON DELETE CASCADE,
  CONSTRAINT `course_enrollments_ibfk_3` FOREIGN KEY (`program_id`) REFERENCES `programs` (`program_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=240 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `course_enrollments`
--

LOCK TABLES `course_enrollments` WRITE;
/*!40000 ALTER TABLE `course_enrollments` DISABLE KEYS */;
INSERT INTO `course_enrollments` VALUES (62,7,1,1,'2025-09-01 07:00:00','enrolled',NULL,NULL,NULL,NULL,'2025-11-30 16:28:28'),(63,8,1,1,'2025-09-01 07:15:00','enrolled',NULL,NULL,NULL,NULL,'2025-11-30 16:28:28'),(64,9,1,1,'2025-09-01 07:30:00','enrolled',NULL,NULL,NULL,NULL,'2025-11-30 16:28:28'),(65,10,1,1,'2025-09-01 08:00:00','enrolled',NULL,NULL,NULL,NULL,'2025-11-30 16:28:28'),(66,11,1,1,'2025-09-01 08:15:00','enrolled',NULL,NULL,NULL,NULL,'2025-11-30 16:28:28'),(67,25,1,1,'2025-09-01 11:00:00','enrolled',NULL,NULL,NULL,NULL,'2025-11-30 16:28:28'),(68,30,1,1,'2025-09-01 11:30:00','enrolled',NULL,NULL,NULL,NULL,'2025-11-30 16:28:28'),(69,34,1,1,'2025-11-12 13:00:00','dropped',NULL,NULL,'2025-11-30 16:39:49',NULL,'2025-11-30 16:39:48'),(70,12,9,1,'2025-09-01 07:45:00','enrolled',NULL,NULL,NULL,NULL,'2025-11-30 16:28:28'),(71,13,9,1,'2025-09-01 08:00:00','enrolled',NULL,NULL,NULL,NULL,'2025-11-30 16:28:28'),(72,14,9,1,'2025-09-01 08:15:00','enrolled',NULL,NULL,NULL,NULL,'2025-11-30 16:28:28'),(73,15,9,1,'2025-09-01 08:30:00','enrolled',NULL,NULL,NULL,NULL,'2025-11-30 16:28:28'),(74,16,9,1,'2025-09-01 08:45:00','enrolled',NULL,NULL,NULL,NULL,'2025-11-30 16:28:28'),(75,9,10,1,'2025-09-01 07:30:00','enrolled',NULL,NULL,NULL,NULL,'2025-11-30 16:28:28'),(76,10,10,1,'2025-09-01 08:00:00','enrolled',NULL,NULL,NULL,NULL,'2025-11-30 16:28:28'),(77,11,10,1,'2025-09-01 08:15:00','enrolled',NULL,NULL,NULL,NULL,'2025-11-30 16:28:28'),(78,12,10,1,'2025-09-01 07:45:00','enrolled',NULL,NULL,NULL,NULL,'2025-11-30 16:28:28'),(79,16,10,1,'2025-09-01 09:00:00','enrolled',NULL,NULL,NULL,NULL,'2025-11-30 16:28:28'),(80,25,10,1,'2025-09-01 11:00:00','enrolled',NULL,NULL,NULL,NULL,'2025-11-30 16:28:28'),(81,30,10,1,'2025-09-01 11:30:00','enrolled',NULL,NULL,NULL,NULL,'2025-11-30 16:28:28'),(82,13,1,1,'2025-09-01 08:00:00','dropped',NULL,NULL,'2025-09-15 13:00:00',NULL,'2025-11-30 16:28:28'),(83,14,1,1,'2025-09-01 08:15:00','dropped',NULL,NULL,'2025-09-20 11:00:00',NULL,'2025-11-30 16:28:28'),(84,15,1,1,'2025-09-01 08:30:00','withdrawn',NULL,NULL,NULL,NULL,'2025-11-30 16:28:28'),(85,16,1,1,'2025-09-01 09:00:00','withdrawn',NULL,NULL,NULL,NULL,'2025-11-30 16:28:28'),(86,7,10,1,'2025-09-01 07:00:00','enrolled',NULL,NULL,NULL,NULL,'2025-11-30 16:28:28'),(87,8,10,1,'2025-09-01 07:15:00','enrolled',NULL,NULL,NULL,NULL,'2025-11-30 16:28:28'),(88,34,9,1,'2025-09-01 12:00:00','enrolled',NULL,NULL,NULL,NULL,'2025-11-30 16:28:28'),(185,21,1,1,'2026-03-01 14:55:40','enrolled',NULL,NULL,NULL,NULL,'2026-03-01 14:55:40'),(186,22,1,1,'2026-03-01 14:55:40','enrolled',NULL,NULL,NULL,NULL,'2026-03-01 14:55:40'),(187,23,1,1,'2026-03-01 14:55:40','enrolled',NULL,NULL,NULL,NULL,'2026-03-01 14:55:40'),(188,24,1,1,'2026-03-01 14:55:40','enrolled',NULL,NULL,NULL,NULL,'2026-03-01 14:55:40'),(189,26,1,1,'2026-03-01 14:55:40','enrolled',NULL,NULL,NULL,NULL,'2026-03-01 14:55:40'),(190,27,1,1,'2026-03-01 14:55:40','enrolled',NULL,NULL,NULL,NULL,'2026-03-01 14:55:40'),(191,28,1,1,'2026-03-01 14:55:40','enrolled',NULL,NULL,NULL,NULL,'2026-03-01 14:55:40'),(192,29,1,1,'2026-03-01 14:55:40','enrolled',NULL,NULL,NULL,NULL,'2026-03-01 14:55:40'),(193,31,2,1,'2026-03-01 14:55:40','enrolled',NULL,NULL,NULL,NULL,'2026-03-01 14:55:40'),(194,32,2,1,'2026-03-01 14:55:40','enrolled',NULL,NULL,NULL,NULL,'2026-03-01 14:55:40'),(195,33,2,1,'2026-03-01 14:55:40','enrolled',NULL,NULL,NULL,NULL,'2026-03-01 14:55:40'),(196,34,2,1,'2026-03-01 14:55:40','enrolled',NULL,NULL,NULL,NULL,'2026-03-01 14:55:40'),(197,35,2,1,'2026-03-01 14:55:40','enrolled',NULL,NULL,NULL,NULL,'2026-03-01 14:55:40'),(198,36,2,1,'2026-03-01 14:55:40','enrolled',NULL,NULL,NULL,NULL,'2026-03-01 14:55:40'),(199,37,2,1,'2026-03-01 14:55:40','enrolled',NULL,NULL,NULL,NULL,'2026-03-01 14:55:40'),(200,38,2,1,'2026-03-01 14:55:40','enrolled',NULL,NULL,NULL,NULL,'2026-03-01 14:55:40'),(201,39,2,1,'2026-03-01 14:55:40','enrolled',NULL,NULL,NULL,NULL,'2026-03-01 14:55:40'),(202,40,2,1,'2026-03-01 14:55:40','enrolled',NULL,NULL,NULL,NULL,'2026-03-01 14:55:40'),(203,21,3,1,'2026-03-01 14:55:40','enrolled',NULL,NULL,NULL,NULL,'2026-03-01 14:55:40'),(204,23,3,1,'2026-03-01 14:55:40','enrolled',NULL,NULL,NULL,NULL,'2026-03-01 14:55:40'),(205,25,3,1,'2026-03-01 14:55:40','enrolled',NULL,NULL,NULL,NULL,'2026-03-01 14:55:40'),(206,27,3,1,'2026-03-01 14:55:40','enrolled',NULL,NULL,NULL,NULL,'2026-03-01 14:55:40'),(207,29,3,1,'2026-03-01 14:55:40','enrolled',NULL,NULL,NULL,NULL,'2026-03-01 14:55:40'),(208,32,3,1,'2026-03-01 14:55:40','enrolled',NULL,NULL,NULL,NULL,'2026-03-01 14:55:40'),(209,34,3,1,'2026-03-01 14:55:40','enrolled',NULL,NULL,NULL,NULL,'2026-03-01 14:55:40'),(210,36,3,1,'2026-03-01 14:55:40','enrolled',NULL,NULL,NULL,NULL,'2026-03-01 14:55:40'),(211,38,3,1,'2026-03-01 14:55:40','enrolled',NULL,NULL,NULL,NULL,'2026-03-01 14:55:40'),(212,40,3,1,'2026-03-01 14:55:40','enrolled',NULL,NULL,NULL,NULL,'2026-03-01 14:55:40'),(213,22,4,1,'2026-03-01 14:55:40','enrolled',NULL,NULL,NULL,NULL,'2026-03-01 14:55:40'),(214,24,4,1,'2026-03-01 14:55:40','enrolled',NULL,NULL,NULL,NULL,'2026-03-01 14:55:40'),(215,26,4,1,'2026-03-01 14:55:40','enrolled',NULL,NULL,NULL,NULL,'2026-03-01 14:55:40'),(216,28,4,1,'2026-03-01 14:55:40','enrolled',NULL,NULL,NULL,NULL,'2026-03-01 14:55:40'),(217,30,4,1,'2026-03-01 14:55:40','enrolled',NULL,NULL,NULL,NULL,'2026-03-01 14:55:40'),(218,31,4,1,'2026-03-01 14:55:40','enrolled',NULL,NULL,NULL,NULL,'2026-03-01 14:55:40'),(219,33,4,1,'2026-03-01 14:55:40','enrolled',NULL,NULL,NULL,NULL,'2026-03-01 14:55:40'),(220,35,4,1,'2026-03-01 14:55:40','enrolled',NULL,NULL,NULL,NULL,'2026-03-01 14:55:40'),(221,37,4,1,'2026-03-01 14:55:40','enrolled',NULL,NULL,NULL,NULL,'2026-03-01 14:55:40'),(222,39,4,1,'2026-03-01 14:55:40','enrolled',NULL,NULL,NULL,NULL,'2026-03-01 14:55:40'),(223,21,5,1,'2026-03-01 14:55:40','enrolled',NULL,NULL,NULL,NULL,'2026-03-01 14:55:40'),(224,23,5,1,'2026-03-01 14:55:40','enrolled',NULL,NULL,NULL,NULL,'2026-03-01 14:55:40'),(225,25,5,1,'2026-03-01 14:55:40','enrolled',NULL,NULL,NULL,NULL,'2026-03-01 14:55:40'),(226,27,5,1,'2026-03-01 14:55:40','enrolled',NULL,NULL,NULL,NULL,'2026-03-01 14:55:40'),(227,29,5,1,'2026-03-01 14:55:40','enrolled',NULL,NULL,NULL,NULL,'2026-03-01 14:55:40'),(228,32,5,1,'2026-03-01 14:55:40','enrolled',NULL,NULL,NULL,NULL,'2026-03-01 14:55:40'),(229,34,5,1,'2026-03-01 14:55:40','enrolled',NULL,NULL,NULL,NULL,'2026-03-01 14:55:40'),(230,36,5,1,'2026-03-01 14:55:40','enrolled',NULL,NULL,NULL,NULL,'2026-03-01 14:55:40'),(231,57,7,NULL,'2026-03-04 14:13:13','enrolled',NULL,NULL,NULL,NULL,'2026-03-04 14:13:13'),(232,57,8,NULL,'2026-03-04 14:13:22','enrolled',NULL,NULL,NULL,NULL,'2026-03-04 14:13:22'),(235,57,1,NULL,'2025-08-31 21:00:00','enrolled',NULL,NULL,NULL,NULL,'2026-03-11 16:42:26'),(236,57,3,NULL,'2025-08-31 21:00:00','enrolled',NULL,NULL,NULL,NULL,'2026-03-11 16:42:26'),(237,57,5,NULL,'2025-08-31 21:00:00','enrolled',NULL,NULL,NULL,NULL,'2026-03-11 16:42:26'),(238,57,6,NULL,'2025-08-31 21:00:00','enrolled',NULL,NULL,NULL,NULL,'2026-03-11 16:42:26'),(239,57,26,NULL,'2025-08-31 21:00:00','enrolled',NULL,NULL,NULL,NULL,'2026-03-11 16:42:26');
/*!40000 ALTER TABLE `course_enrollments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `course_instructors`
--

DROP TABLE IF EXISTS `course_instructors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `course_instructors` (
  `assignment_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `section_id` bigint unsigned NOT NULL,
  `role` enum('primary','co_instructor','guest') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'primary',
  `assigned_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`assignment_id`),
  UNIQUE KEY `unique_instructor_section` (`user_id`,`section_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_section` (`section_id`),
  CONSTRAINT `course_instructors_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `course_instructors_ibfk_2` FOREIGN KEY (`section_id`) REFERENCES `course_sections` (`section_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `course_instructors`
--

LOCK TABLES `course_instructors` WRITE;
/*!40000 ALTER TABLE `course_instructors` DISABLE KEYS */;
INSERT INTO `course_instructors` VALUES (1,8,1,'primary','2024-12-15 10:00:00'),(2,9,2,'primary','2024-12-15 10:00:00'),(3,10,3,'primary','2024-12-15 10:00:00'),(4,13,4,'primary','2024-12-15 10:00:00'),(5,12,5,'primary','2024-12-15 10:00:00'),(7,15,7,'primary','2024-12-15 10:00:00'),(8,11,8,'primary','2024-12-15 10:00:00'),(9,16,9,'primary','2024-12-15 10:00:00'),(10,17,10,'primary','2024-12-15 10:00:00'),(11,2,1,'primary','2026-03-10 20:09:45'),(16,64,1,'co_instructor','2026-03-10 21:26:04'),(17,64,24,'primary','2026-03-15 15:05:30'),(18,3,25,'primary','2026-03-15 15:33:03'),(19,58,26,'primary','2026-03-15 15:33:14'),(20,1,6,'primary','2026-03-15 15:33:32');
/*!40000 ALTER TABLE `course_instructors` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `course_materials`
--

DROP TABLE IF EXISTS `course_materials`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `course_materials` (
  `material_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `course_id` bigint unsigned NOT NULL,
  `file_id` bigint unsigned DEFAULT NULL,
  `drive_file_id` bigint unsigned DEFAULT NULL COMMENT 'FK to drive_files table for Google Drive integration',
  `material_type` enum('lecture','slide','video','reading','link','document','other') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'document',
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `external_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `youtube_video_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `order_index` int DEFAULT '0',
  `week_number` int DEFAULT NULL,
  `uploaded_by` bigint unsigned NOT NULL,
  `is_published` tinyint(1) DEFAULT '0',
  `published_at` timestamp NULL DEFAULT NULL,
  `view_count` int DEFAULT '0',
  `download_count` int DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`material_id`),
  KEY `uploaded_by` (`uploaded_by`),
  KEY `idx_course` (`course_id`),
  KEY `idx_file` (`file_id`),
  KEY `idx_type` (`material_type`),
  KEY `idx_materials_week_number` (`course_id`,`week_number`),
  KEY `idx_course_materials_youtube` (`youtube_video_id`),
  CONSTRAINT `course_materials_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`) ON DELETE CASCADE,
  CONSTRAINT `course_materials_ibfk_2` FOREIGN KEY (`file_id`) REFERENCES `files` (`file_id`) ON DELETE SET NULL,
  CONSTRAINT `course_materials_ibfk_3` FOREIGN KEY (`uploaded_by`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=62 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `course_materials`
--

LOCK TABLES `course_materials` WRITE;
/*!40000 ALTER TABLE `course_materials` DISABLE KEYS */;
INSERT INTO `course_materials` VALUES (4,2,4,NULL,'document','Course Syllabus','CS201 Spring 2025 Syllabus',NULL,NULL,1,NULL,3,1,NULL,0,12,'2025-11-20 13:42:59','2026-03-16 22:31:25'),(6,2,NULL,NULL,'lecture','Week 1: Updated Lecture Title','Updated description',NULL,NULL,0,5,59,0,'2026-03-10 20:03:39',1,0,'2026-03-10 20:03:38','2026-03-10 20:05:29'),(7,2,NULL,NULL,'reading','Week 2: Advanced Topics','Testing weekNumber filter',NULL,NULL,0,2,59,1,'2026-03-10 20:04:00',0,0,'2026-03-10 20:03:59','2026-03-10 20:03:59'),(8,2,NULL,NULL,'slide','Week 3: Final Review','Testing weekNumber filter',NULL,NULL,0,3,59,1,'2026-03-10 20:04:02',0,0,'2026-03-10 20:04:02','2026-03-10 20:04:02'),(9,2,NULL,NULL,'slide','Bulk Material 1: Lecture Slides','Created via bulk upload',NULL,NULL,0,4,59,1,'2026-03-10 20:04:27',0,0,'2026-03-10 20:04:26','2026-03-10 20:04:26'),(10,2,NULL,NULL,'reading','Bulk Material 2: Reading Assignment','Created via bulk upload',NULL,NULL,0,4,59,1,'2026-03-10 20:04:27',0,0,'2026-03-10 20:04:27','2026-03-10 20:04:27'),(11,2,NULL,NULL,'document','Bulk Material 3: Lab Exercise','Created via bulk upload',NULL,NULL,0,4,59,0,NULL,0,0,'2026-03-10 20:04:27','2026-03-10 20:04:27'),(15,1,NULL,NULL,'lecture','Week 1: Introduction to Programming','Overview of programming concepts and course structure',NULL,NULL,1,1,2,1,'2026-03-16 20:19:00',37,10,'2026-03-10 20:09:45','2026-03-16 22:31:25'),(16,1,NULL,NULL,'slide','Week 1: Presentation Slides','Accompanying slides for week 1 lecture','https://slides.example.com/week1',NULL,2,1,2,1,'2026-03-10 20:09:45',18,5,'2026-03-10 20:09:45','2026-03-10 20:09:45'),(17,1,NULL,NULL,'video','Week 1: Video Tutorial','Hands-on coding demonstration','https://www.youtube.com/embed/dQw4w9WgXcQ',NULL,3,1,2,1,'2026-03-10 20:09:45',45,0,'2026-03-10 20:09:45','2026-03-10 20:09:45'),(18,1,NULL,NULL,'reading','Week 2: Variables and Data Types','Chapter 2 from textbook','https://textbook.example.com/chapter2',NULL,1,2,2,1,'2026-03-10 20:09:45',12,3,'2026-03-10 20:09:45','2026-03-10 20:09:45'),(19,1,NULL,NULL,'document','Week 2: Lab Exercises (DRAFT)','Practice exercises - not yet ready',NULL,NULL,2,2,5,0,NULL,2,0,'2026-03-10 20:09:45','2026-03-10 20:09:45'),(20,1,NULL,NULL,'link','Week 3: External Resources','Additional learning resources','https://resources.example.com/week3',NULL,1,3,2,1,'2026-03-10 20:09:45',8,0,'2026-03-10 20:09:45','2026-03-10 20:09:45'),(21,1,NULL,NULL,'document','Course Syllabus','Complete course syllabus and schedule',NULL,NULL,0,NULL,2,1,'2026-03-10 20:09:45',100,50,'2026-03-10 20:09:45','2026-03-10 20:09:45'),(22,1,NULL,NULL,'other','Supplementary Material','Miscellaneous course content','https://misc.example.com',NULL,99,NULL,2,1,'2026-03-10 20:09:45',5,1,'2026-03-10 20:09:45','2026-03-10 20:09:45'),(23,1,NULL,NULL,'video','Lecture 1: Introduction to Data Structures','This video covers the basics of data structures.','https://www.youtube.com/embed/8Jl9HwRS5NU','8Jl9HwRS5NU',0,1,66,1,'2026-03-10 21:54:29',0,0,'2026-03-10 21:54:28','2026-03-10 21:54:28'),(24,1,NULL,NULL,'video','Lecture 1: Introduction to Data Structures','This video covers the basics of data structures.','https://www.youtube.com/embed/xom3C8hwGzM','xom3C8hwGzM',0,1,64,1,'2026-03-10 22:00:32',0,0,'2026-03-10 22:00:31','2026-03-10 22:00:31'),(26,1,NULL,NULL,'lecture','Bulk Test 1',NULL,NULL,NULL,0,10,59,1,'2026-03-11 17:20:01',0,0,'2026-03-11 17:20:00','2026-03-11 17:20:00'),(27,1,NULL,NULL,'slide','Bulk Test 2',NULL,NULL,NULL,0,10,59,1,'2026-03-11 17:20:01',0,0,'2026-03-11 17:20:00','2026-03-11 17:20:00'),(29,1,NULL,NULL,'lecture','Bulk Test 1',NULL,NULL,NULL,0,10,59,1,'2026-03-11 17:37:46',0,0,'2026-03-11 17:37:46','2026-03-11 17:37:46'),(30,1,NULL,NULL,'slide','Bulk Test 2',NULL,NULL,NULL,0,10,59,1,'2026-03-11 17:37:46',0,0,'2026-03-11 17:37:46','2026-03-11 17:37:46'),(32,1,NULL,NULL,'lecture','Bulk Test 1',NULL,NULL,NULL,0,10,59,1,'2026-03-14 15:35:59',0,0,'2026-03-14 15:35:59','2026-03-14 15:35:59'),(33,1,NULL,NULL,'slide','Bulk Test 2',NULL,NULL,NULL,0,10,59,1,'2026-03-14 15:35:59',0,0,'2026-03-14 15:35:59','2026-03-14 15:35:59'),(35,1,NULL,NULL,'lecture','Bulk Test 1',NULL,NULL,NULL,0,10,59,1,'2026-03-14 15:40:39',0,0,'2026-03-14 15:40:39','2026-03-14 15:40:39'),(36,1,NULL,NULL,'slide','Bulk Test 2',NULL,NULL,NULL,0,10,59,1,'2026-03-14 15:40:39',0,0,'2026-03-14 15:40:39','2026-03-14 15:40:39'),(38,1,NULL,NULL,'lecture','Bulk Test 1',NULL,NULL,NULL,0,10,59,1,'2026-03-14 16:06:02',0,0,'2026-03-14 16:06:01','2026-03-14 16:06:01'),(39,1,NULL,NULL,'slide','Bulk Test 2',NULL,NULL,NULL,0,10,59,1,'2026-03-14 16:06:02',0,0,'2026-03-14 16:06:01','2026-03-14 16:06:01'),(40,1,NULL,NULL,'document','Test Material','Test',NULL,NULL,0,1,59,1,'2026-03-15 23:22:47',0,0,'2026-03-15 23:22:46','2026-03-15 23:22:46'),(42,14,NULL,NULL,'video','First Lecture Test','Test',NULL,NULL,0,1,58,1,'2026-03-15 23:40:06',3,0,'2026-03-15 23:40:05','2026-03-16 00:06:46'),(44,1,NULL,NULL,'lecture','Bulk Test 1',NULL,NULL,NULL,0,10,59,1,'2026-03-16 20:19:00',0,0,'2026-03-16 20:18:59','2026-03-16 20:18:59'),(45,1,NULL,NULL,'slide','Bulk Test 2',NULL,NULL,NULL,0,10,59,1,'2026-03-16 20:19:00',0,0,'2026-03-16 20:18:59','2026-03-16 20:18:59'),(47,1,NULL,NULL,'lecture','Bulk Test 1',NULL,NULL,NULL,0,10,59,1,'2026-03-16 20:20:06',0,0,'2026-03-16 20:20:05','2026-03-16 20:20:05'),(48,1,NULL,NULL,'slide','Bulk Test 2',NULL,NULL,NULL,0,10,59,1,'2026-03-16 20:20:06',0,0,'2026-03-16 20:20:05','2026-03-16 20:20:05'),(49,1,NULL,1,'lecture','Week 1 Lecture Notes: Introduction to Data Structures','Comprehensive lecture notes covering the basics.','https://drive.google.com/file/d/1PFxy4dByCPhiLvhH2wuKmHlX9fWDi0kK/view?usp=drivesdk',NULL,0,1,66,1,'2026-03-16 20:31:42',0,0,'2026-03-16 20:31:41','2026-03-16 20:31:41'),(51,1,NULL,NULL,'lecture','Bulk Test 1',NULL,NULL,NULL,0,10,59,1,'2026-03-16 20:32:47',0,0,'2026-03-16 20:32:46','2026-03-16 20:32:46'),(52,1,NULL,NULL,'slide','Bulk Test 2',NULL,NULL,NULL,0,10,59,1,'2026-03-16 20:32:47',0,0,'2026-03-16 20:32:46','2026-03-16 20:32:46'),(54,1,NULL,NULL,'lecture','Bulk Test 1',NULL,NULL,NULL,0,10,59,1,'2026-03-16 20:45:12',0,0,'2026-03-16 20:45:12','2026-03-16 20:45:12'),(55,1,NULL,NULL,'slide','Bulk Test 2',NULL,NULL,NULL,0,10,59,1,'2026-03-16 20:45:12',0,0,'2026-03-16 20:45:12','2026-03-16 20:45:12'),(57,1,NULL,NULL,'lecture','Bulk Test 1',NULL,NULL,NULL,0,10,59,1,'2026-03-16 20:53:48',0,0,'2026-03-16 20:53:48','2026-03-16 20:53:48'),(58,1,NULL,NULL,'slide','Bulk Test 2',NULL,NULL,NULL,0,10,59,1,'2026-03-16 20:53:48',0,0,'2026-03-16 20:53:48','2026-03-16 20:53:48'),(60,1,NULL,NULL,'lecture','Bulk Test 1',NULL,NULL,NULL,0,10,59,1,'2026-03-16 22:31:25',0,0,'2026-03-16 22:31:24','2026-03-16 22:31:24'),(61,1,NULL,NULL,'slide','Bulk Test 2',NULL,NULL,NULL,0,10,59,1,'2026-03-16 22:31:25',0,0,'2026-03-16 22:31:24','2026-03-16 22:31:24');
/*!40000 ALTER TABLE `course_materials` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `course_prerequisites`
--

DROP TABLE IF EXISTS `course_prerequisites`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `course_prerequisites` (
  `prerequisite_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `course_id` bigint unsigned NOT NULL,
  `prerequisite_course_id` bigint unsigned NOT NULL,
  `is_mandatory` tinyint(1) DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`prerequisite_id`),
  UNIQUE KEY `unique_prerequisite` (`course_id`,`prerequisite_course_id`),
  KEY `prerequisite_course_id` (`prerequisite_course_id`),
  CONSTRAINT `course_prerequisites_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`) ON DELETE CASCADE,
  CONSTRAINT `course_prerequisites_ibfk_2` FOREIGN KEY (`prerequisite_course_id`) REFERENCES `courses` (`course_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `course_prerequisites`
--

LOCK TABLES `course_prerequisites` WRITE;
/*!40000 ALTER TABLE `course_prerequisites` DISABLE KEYS */;
INSERT INTO `course_prerequisites` VALUES (1,2,1,1,'2024-09-01 08:00:00'),(2,3,2,1,'2025-11-20 13:42:59'),(3,4,2,1,'2025-11-20 13:42:59'),(4,6,5,1,'2025-11-20 13:42:59'),(5,8,5,1,'2025-11-27 17:54:45'),(8,3,1,1,'2026-03-02 23:29:24');
/*!40000 ALTER TABLE `course_prerequisites` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `course_schedules`
--

DROP TABLE IF EXISTS `course_schedules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `course_schedules` (
  `schedule_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `section_id` bigint unsigned NOT NULL,
  `day_of_week` enum('monday','tuesday','wednesday','thursday','friday','saturday','sunday') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  `room` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `building` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `schedule_type` enum('lecture','lab','tutorial','exam') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'lecture',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`schedule_id`),
  KEY `idx_section` (`section_id`),
  CONSTRAINT `course_schedules_ibfk_1` FOREIGN KEY (`section_id`) REFERENCES `course_sections` (`section_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `course_schedules`
--

LOCK TABLES `course_schedules` WRITE;
/*!40000 ALTER TABLE `course_schedules` DISABLE KEYS */;
INSERT INTO `course_schedules` VALUES (1,1,'monday','09:00:00','10:30:00','101','Building A','lecture','2024-12-15 10:00:00'),(2,1,'wednesday','09:00:00','10:30:00','101','Building A','lecture','2024-12-15 10:00:00'),(3,2,'tuesday','11:00:00','12:30:00','102','Building A','lecture','2024-12-15 10:00:00'),(4,2,'thursday','11:00:00','12:30:00','102','Building A','lecture','2024-12-15 10:00:00'),(5,3,'monday','13:00:00','14:30:00','201','Building B','lab','2024-12-15 10:00:00'),(6,3,'wednesday','13:00:00','14:30:00','201','Building B','lab','2024-12-15 10:00:00'),(7,4,'tuesday','14:00:00','15:30:00','202','Building B','tutorial','2024-12-15 10:00:00'),(8,4,'thursday','14:00:00','15:30:00','202','Building B','tutorial','2024-12-15 10:00:00'),(9,5,'monday','15:00:00','16:30:00','301','Lab Building','exam','2024-12-15 10:00:00'),(10,9,'tuesday','14:00:00','15:30:00','320','Building C','lecture','2025-11-27 18:28:26'),(11,1,'monday','14:00:00','15:30:00','355','Building C','lecture','2025-11-27 18:30:21'),(12,2,'monday','09:00:00','10:30:00','101','Building A','lecture','2026-03-01 21:05:48'),(13,1,'monday','11:00:00','12:30:00','102','Main','lecture','2026-03-02 13:31:16'),(14,1,'tuesday','14:00:00','15:30:00','201',NULL,'lecture','2026-03-02 13:50:19'),(15,24,'monday','09:00:00','10:30:00','Room A-101',NULL,'lecture','2026-03-15 15:02:56'),(17,26,'monday','09:00:00','10:30:00','Room A-101',NULL,'lecture','2026-03-15 15:33:14'),(18,6,'monday','09:00:00','10:30:00','Room 401A',NULL,'lecture','2026-03-15 15:33:32'),(19,25,'monday','09:00:00','10:30:00','Room A-101',NULL,'lecture','2026-03-15 15:36:57');
/*!40000 ALTER TABLE `course_schedules` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `course_sections`
--

DROP TABLE IF EXISTS `course_sections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `course_sections` (
  `section_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `course_id` bigint unsigned NOT NULL,
  `semester_id` bigint unsigned NOT NULL,
  `section_number` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `max_capacity` int DEFAULT '50',
  `current_enrollment` int DEFAULT '0',
  `location` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('open','closed','full','cancelled') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'open',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`section_id`),
  UNIQUE KEY `unique_section` (`course_id`,`semester_id`,`section_number`),
  KEY `idx_course` (`course_id`),
  KEY `idx_semester` (`semester_id`),
  CONSTRAINT `course_sections_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`) ON DELETE CASCADE,
  CONSTRAINT `course_sections_ibfk_2` FOREIGN KEY (`semester_id`) REFERENCES `semesters` (`semester_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=35 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `course_sections`
--

LOCK TABLES `course_sections` WRITE;
/*!40000 ALTER TABLE `course_sections` DISABLE KEYS */;
INSERT INTO `course_sections` VALUES (1,1,4,'01',40,7,'Building A, Room 101','open','2025-11-27 18:20:49','2025-11-30 16:39:48'),(2,1,2,'02',50,48,'Room 102B','full','2024-12-15 10:00:00','2025-02-15 09:30:00'),(3,2,2,'01',40,35,'Room 201A','open','2024-12-15 10:00:00','2025-02-15 09:30:00'),(4,2,2,'02',40,38,'Room 202B','open','2024-12-15 10:00:00','2025-02-15 09:30:00'),(5,3,2,'01',45,40,'Lab 301','open','2024-12-15 10:00:00','2025-02-15 09:30:00'),(6,4,2,'01',35,32,'Room 401A','open','2024-12-15 10:00:00','2026-03-15 15:33:32'),(7,5,2,'01',40,39,'Room 501A','open','2024-12-15 10:00:00','2026-03-04 14:13:13'),(8,9,2,'01',50,46,'Room 601A','open','2024-12-15 10:00:00','2026-03-04 14:13:22'),(9,2,3,'2',50,6,'Building C, Room 320','open','2025-11-27 18:25:02','2025-11-30 16:13:44'),(10,1,3,'2',45,9,'Building B, Room 215','open','2025-11-30 16:00:35','2025-11-30 16:13:44'),(11,1,1,'1',35,0,'Room B202','open','2026-03-02 13:30:09','2026-03-16 20:56:28'),(12,1,1,'2',30,0,NULL,'open','2026-03-02 13:50:17','2026-03-02 13:50:17'),(13,1,1,'3',30,0,'Room A101','open','2026-03-02 23:30:18','2026-03-02 23:30:18'),(14,1,1,'4',30,0,'Room A101','open','2026-03-02 23:51:54','2026-03-02 23:51:54'),(15,1,1,'5',30,0,'Room A101','open','2026-03-03 00:23:16','2026-03-03 00:23:16'),(16,1,1,'6',30,0,'Room A101','open','2026-03-03 18:34:00','2026-03-03 18:34:00'),(17,1,1,'7',30,0,'Room A101','open','2026-03-05 19:16:21','2026-03-05 19:16:21'),(21,1,2,'134',30,0,'Room TEST','open','2026-03-14 15:35:57','2026-03-14 15:35:57'),(22,1,2,'282',30,0,'Room TEST','open','2026-03-14 15:40:38','2026-03-14 15:40:38'),(23,1,2,'605',30,0,'Room TEST','open','2026-03-14 16:06:00','2026-03-14 16:06:00'),(24,24,4,'1',30,0,'Room A-101','open','2026-03-15 15:02:56','2026-03-15 15:02:56'),(25,22,4,'1',30,0,'Room A-101','open','2026-03-15 15:33:02','2026-03-15 15:36:57'),(26,14,4,'1',30,0,'Room A-101','open','2026-03-15 15:33:14','2026-03-15 15:33:14'),(27,1,2,'702',30,0,'Room TEST','open','2026-03-16 20:18:57','2026-03-16 20:18:57'),(28,1,2,'312',30,0,'Room TEST','open','2026-03-16 20:20:04','2026-03-16 20:20:04'),(29,1,2,'913',30,0,'Room TEST','open','2026-03-16 20:32:45','2026-03-16 20:32:45'),(30,1,2,'888',30,0,'Room TEST','open','2026-03-16 20:34:09','2026-03-16 20:34:09'),(31,1,2,'902',30,0,'Room TEST','open','2026-03-16 20:45:10','2026-03-16 20:45:10'),(32,1,2,'113',30,0,'Room TEST','open','2026-03-16 20:53:46','2026-03-16 20:53:46'),(33,1,1,'8',30,0,'Room A101','open','2026-03-16 20:56:28','2026-03-16 20:56:28'),(34,1,2,'197',30,0,'Room TEST','open','2026-03-16 22:31:23','2026-03-16 22:31:23');
/*!40000 ALTER TABLE `course_sections` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `course_tas`
--

DROP TABLE IF EXISTS `course_tas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `course_tas` (
  `assignment_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `section_id` bigint unsigned NOT NULL,
  `responsibilities` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `assigned_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`assignment_id`),
  UNIQUE KEY `unique_ta_section` (`user_id`,`section_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_section` (`section_id`),
  CONSTRAINT `course_tas_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `course_tas_ibfk_2` FOREIGN KEY (`section_id`) REFERENCES `course_sections` (`section_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `course_tas`
--

LOCK TABLES `course_tas` WRITE;
/*!40000 ALTER TABLE `course_tas` DISABLE KEYS */;
INSERT INTO `course_tas` VALUES (1,18,1,'Grading assignments and leading lab sessions','2024-12-15 10:00:00'),(2,19,2,'Grading assignments and holding office hours','2024-12-15 10:00:00'),(3,18,3,'Grading assignments and leading lab sessions','2024-12-15 10:00:00'),(4,20,4,'Grading assignments and proctoring quizzes','2024-12-15 10:00:00'),(5,19,5,'Grading assignments and holding office hours','2024-12-15 10:00:00'),(6,5,1,NULL,'2026-03-10 20:09:45'),(7,65,1,'Grading assignments and holding office hours','2026-03-10 21:26:04'),(8,60,24,NULL,'2026-03-15 15:05:30'),(9,65,25,NULL,'2026-03-15 15:33:03'),(10,6,25,NULL,'2026-03-15 15:33:03'),(11,60,26,NULL,'2026-03-15 15:33:14'),(12,60,6,NULL,'2026-03-15 15:33:32');
/*!40000 ALTER TABLE `course_tas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `courses`
--

DROP TABLE IF EXISTS `courses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `courses` (
  `course_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `department_id` bigint unsigned NOT NULL,
  `course_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `course_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `course_description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `credits` int DEFAULT '3',
  `level` enum('freshman','sophomore','junior','senior','graduate') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `syllabus_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `instructor_id` bigint unsigned DEFAULT NULL,
  `ta_ids` json DEFAULT NULL,
  `status` enum('active','inactive','archived') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'active',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`course_id`),
  UNIQUE KEY `unique_course_code` (`department_id`,`course_code`),
  KEY `idx_department` (`department_id`),
  KEY `idx_status` (`status`),
  CONSTRAINT `courses_ibfk_1` FOREIGN KEY (`department_id`) REFERENCES `departments` (`department_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `courses`
--

LOCK TABLES `courses` WRITE;
/*!40000 ALTER TABLE `courses` DISABLE KEYS */;
INSERT INTO `courses` VALUES (1,1,'Updated Course Name','CS101','Basic programming concepts using Python',3,'freshman',NULL,NULL,NULL,'active','2025-11-27 18:18:48','2026-03-02 23:29:23',NULL),(2,1,'Data Structures','CS201','Fundamental data structures and algorithms',3,'sophomore','https://example.com/amir.pdf',NULL,NULL,'active','2025-11-20 13:42:59','2025-11-29 00:27:15',NULL),(3,1,'Database Systems','CS301','Database design and SQL',3,'junior',NULL,NULL,NULL,'active','2025-11-20 13:42:59','2025-11-20 13:42:59',NULL),(4,1,'Artificial Intelligence','CS401','Artificial Intelligence (CS401)',4,'senior',NULL,NULL,NULL,'active','2025-11-20 13:42:59','2026-03-15 15:33:32',NULL),(5,2,'Calculus I','MATH101','Differential calculus',4,'freshman',NULL,NULL,NULL,'active','2025-11-20 13:42:59','2025-11-20 13:42:59',NULL),(6,2,'Linear Algebra','MATH201','Matrices and vector spaces',3,'sophomore',NULL,NULL,NULL,'active','2025-11-20 13:42:59','2025-11-20 13:42:59',NULL),(7,3,'Physics I','PHY101','Classical mechanics',4,'freshman',NULL,NULL,NULL,'active','2025-11-20 13:42:59','2025-11-20 13:42:59',NULL),(8,4,'Business Management','BUS101','Introduction to business management',3,'freshman',NULL,NULL,NULL,'active','2025-11-20 13:42:59','2025-11-20 13:42:59',NULL),(9,3,'Principles of Management','BUS101','Fundamentals of business management and organizational behavior',3,'freshman','/uploads/syllabi/BUS101.pdf',NULL,NULL,'active','2024-09-01 08:00:00','2024-09-01 08:00:00',NULL),(10,3,'Business Finance','BUS202','Financial analysis, investment decisions, and capital budgeting',3,'sophomore','/uploads/syllabi/BUS202.pdf',NULL,NULL,'active','2024-09-01 08:00:00','2024-09-01 08:00:00',NULL),(11,4,'Statistics for Data Science','DS101','Probability, hypothesis testing, statistical inference',3,'freshman','/uploads/syllabi/DS101.pdf',NULL,NULL,'active','2024-09-01 08:00:00','2024-09-01 08:00:00',NULL),(12,1,'Introduction to Programming','CS1001','Basic programming concepts - prerequisite course',3,'freshman',NULL,NULL,NULL,'active','2025-11-27 18:02:54','2025-11-27 18:02:54',NULL),(13,5,'English Literature I','AH101','Classic works of English literature from Renaissance to 19th century',3,'freshman','/uploads/syllabi/AH101.pdf',NULL,NULL,'active','2024-09-01 08:00:00','2024-09-01 08:00:00',NULL),(14,5,'Arabic Language Skills','AH102','Arabic Language Skills (AH102)',3,'freshman','/uploads/syllabi/AH102.pdf',64,NULL,'active','2024-09-01 08:00:00','2026-03-15 15:33:14',NULL),(15,6,'Calculus I','SCI101','Differential and integral calculus',4,'freshman','/uploads/syllabi/SCI101.pdf',NULL,NULL,'active','2024-09-01 08:00:00','2024-09-01 08:00:00',NULL),(16,1,'intro to digital','CS2024','Study of advanced data structures and algorithm optimization techniques',4,'junior','https://example.com/syllabus-advanced.pdf',NULL,NULL,'inactive','2025-11-27 18:13:14','2025-11-27 18:14:45','2025-11-27 18:14:45'),(17,1,'Electro 4','EEE2026','Study of advanced electro 4',2,'junior','https://example.com/syllabus-advanced.pdf',NULL,NULL,'active','2025-11-30 15:49:58','2025-11-30 15:52:42','2025-11-30 15:52:42'),(18,3,'Strategic Management','BUS401','Corporate strategy and competitive analysis',3,'senior','/uploads/syllabi/BUS401.pdf',NULL,NULL,'active','2024-09-01 08:00:00','2024-09-01 08:00:00',NULL),(19,1,'Test Course Z2','TCZ2','A test course',3,'freshman',NULL,NULL,NULL,'active','2026-03-02 13:31:15','2026-03-02 13:31:15',NULL),(20,1,'Auto Course','AC99','Test',3,'freshman',NULL,NULL,NULL,'active','2026-03-02 13:50:13','2026-03-02 13:50:13',NULL),(21,1,'Test Course','TC101','A test course for postman',3,'senior',NULL,NULL,NULL,'active','2026-03-03 18:35:43','2026-03-03 18:35:43',NULL),(22,1,'API Dog Test Course','TEST101','API Dog Test Course (TEST101)',3,'freshman',NULL,58,NULL,'active','2026-03-11 17:37:44','2026-03-15 15:36:57',NULL),(23,1,'EDU FIRST COURSE','EDL2','Course for Fall 2025',3,'freshman',NULL,NULL,NULL,'active','2026-03-15 14:23:35','2026-03-15 14:23:35',NULL),(24,1,'FULL NEW TEST','NEW1','FULL NEW TEST (NEW1)',3,'freshman',NULL,NULL,NULL,'active','2026-03-15 15:02:50','2026-03-15 15:02:50',NULL);
/*!40000 ALTER TABLE `courses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `daily_streaks`
--

DROP TABLE IF EXISTS `daily_streaks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `daily_streaks` (
  `streak_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `current_streak` int DEFAULT '0',
  `longest_streak` int DEFAULT '0',
  `last_activity_date` date DEFAULT NULL,
  `streak_start_date` date DEFAULT NULL,
  `total_active_days` int DEFAULT '0',
  `streak_status` enum('active','broken','frozen') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'active',
  `freeze_count` int DEFAULT '0',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`streak_id`),
  UNIQUE KEY `user_id` (`user_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_streak` (`current_streak`),
  CONSTRAINT `daily_streaks_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `daily_streaks`
--

LOCK TABLES `daily_streaks` WRITE;
/*!40000 ALTER TABLE `daily_streaks` DISABLE KEYS */;
INSERT INTO `daily_streaks` VALUES (1,7,15,15,'2025-02-15','2025-02-01',15,'active',0,'2025-11-20 13:43:00'),(2,8,12,12,'2025-02-15','2025-02-04',12,'active',0,'2025-11-20 13:43:00'),(3,9,8,10,'2025-02-15','2025-02-08',20,'active',1,'2025-11-20 13:43:00'),(4,10,5,7,'2025-02-15','2025-02-11',15,'active',0,'2025-11-20 13:43:00'),(5,11,3,5,'2025-02-15','2025-02-13',10,'active',0,'2025-11-20 13:43:00');
/*!40000 ALTER TABLE `daily_streaks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `deadline_reminders`
--

DROP TABLE IF EXISTS `deadline_reminders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `deadline_reminders` (
  `reminder_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `task_id` bigint unsigned NOT NULL,
  `user_id` bigint unsigned NOT NULL,
  `reminder_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `reminder_type` enum('email','push','sms','in_app') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'in_app',
  `status` enum('pending','sent','failed') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  `sent_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`reminder_id`),
  KEY `idx_task` (`task_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_status` (`status`),
  CONSTRAINT `deadline_reminders_ibfk_1` FOREIGN KEY (`task_id`) REFERENCES `student_tasks` (`task_id`) ON DELETE CASCADE,
  CONSTRAINT `deadline_reminders_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `deadline_reminders`
--

LOCK TABLES `deadline_reminders` WRITE;
/*!40000 ALTER TABLE `deadline_reminders` DISABLE KEYS */;
INSERT INTO `deadline_reminders` VALUES (4,5,8,'2025-02-18 07:00:00','email','sent','2025-02-18 07:00:15','2025-11-20 13:43:00'),(5,6,9,'2025-03-13 07:00:00','push','pending',NULL,'2025-11-20 13:43:00'),(6,7,57,'2026-03-13 18:12:04','in_app','pending',NULL,'2026-03-11 18:12:04'),(7,8,57,'2026-03-15 18:12:04','email','pending',NULL,'2026-03-11 18:12:04'),(10,9,57,'2026-03-17 18:14:02','in_app','pending',NULL,'2026-03-14 15:17:54'),(11,9,57,'2026-03-17 18:14:02','in_app','pending',NULL,'2026-03-14 15:36:12'),(12,9,57,'2026-03-17 18:14:02','in_app','pending',NULL,'2026-03-14 15:40:52'),(13,9,57,'2026-03-17 18:14:02','in_app','pending',NULL,'2026-03-14 16:06:14'),(14,9,57,'2026-03-17 18:14:02','in_app','pending',NULL,'2026-03-16 20:19:12'),(15,9,57,'2026-03-17 18:14:02','in_app','pending',NULL,'2026-03-16 20:20:18'),(16,9,57,'2026-03-17 18:14:02','in_app','pending',NULL,'2026-03-16 20:33:00'),(17,9,57,'2026-03-17 18:14:02','in_app','pending',NULL,'2026-03-16 20:45:25'),(18,9,57,'2026-03-17 18:14:02','in_app','pending',NULL,'2026-03-16 20:54:01'),(19,9,57,'2026-03-17 18:14:02','in_app','pending',NULL,'2026-03-16 22:31:38');
/*!40000 ALTER TABLE `deadline_reminders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `departments`
--

DROP TABLE IF EXISTS `departments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `departments` (
  `department_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `campus_id` bigint unsigned NOT NULL,
  `department_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `department_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `head_of_department_id` bigint unsigned DEFAULT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `status` enum('active','inactive') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'active',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`department_id`),
  UNIQUE KEY `unique_dept_code` (`campus_id`,`department_code`),
  KEY `head_of_department_id` (`head_of_department_id`),
  KEY `idx_campus` (`campus_id`),
  CONSTRAINT `departments_ibfk_1` FOREIGN KEY (`campus_id`) REFERENCES `campuses` (`campus_id`) ON DELETE CASCADE,
  CONSTRAINT `departments_ibfk_2` FOREIGN KEY (`head_of_department_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `departments`
--

LOCK TABLES `departments` WRITE;
/*!40000 ALTER TABLE `departments` DISABLE KEYS */;
INSERT INTO `departments` VALUES (1,1,'Updated Department','CS',NULL,'Department of Computer Science and Engineering','active','2025-11-20 13:42:59','2026-03-16 22:31:21'),(2,1,'Mathematics','MATH',NULL,'Department of Mathematics','active','2025-11-20 13:42:59','2025-11-20 13:42:59'),(3,1,'Physics','PHY',NULL,'Department of Physics','active','2025-11-20 13:42:59','2025-11-20 13:42:59'),(4,2,'Business Administration','BUS',NULL,'School of Business','active','2025-11-20 13:42:59','2025-11-20 13:42:59'),(5,2,'Engineering','ENG',NULL,'School of Engineering','active','2025-11-20 13:42:59','2025-11-20 13:42:59'),(6,3,'Science','SCI',NULL,'Department of mathematics, physics, and chemistry','active','2024-09-01 08:00:00','2024-09-01 08:00:00'),(14,1,'Test Dept Z','TDZ',NULL,'Test','active','2026-03-02 13:29:52','2026-03-02 13:29:52'),(15,1,'AutoDept','AD1',NULL,NULL,'active','2026-03-02 13:49:17','2026-03-02 13:49:17'),(16,1,'Test Department','TD01',NULL,'A test department','active','2026-03-02 23:28:49','2026-03-02 23:28:49'),(17,1,'API Dog Test Dept','TESTD01',NULL,NULL,'active','2026-03-11 17:37:43','2026-03-11 17:37:43');
/*!40000 ALTER TABLE `departments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `device_tokens`
--

DROP TABLE IF EXISTS `device_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `device_tokens` (
  `token_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `device_token` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `device_type` enum('ios','android','web') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `device_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `last_used` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`token_id`),
  UNIQUE KEY `unique_user_token` (`user_id`,`device_token`),
  KEY `idx_user` (`user_id`),
  KEY `idx_active` (`is_active`),
  CONSTRAINT `device_tokens_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `device_tokens`
--

LOCK TABLES `device_tokens` WRITE;
/*!40000 ALTER TABLE `device_tokens` DISABLE KEYS */;
INSERT INTO `device_tokens` VALUES (1,7,'fcm_token_alice_phone_12345','android','Alice Phone',1,'2025-02-15 06:30:00','2025-11-20 13:43:00'),(2,7,'fcm_token_alice_tablet_67890','','Alice Tablet',1,'2025-02-14 18:15:00','2025-11-20 13:43:00'),(3,8,'apns_token_bob_iphone_abcde','ios','Bob iPhone 13',1,'2025-02-15 05:45:00','2025-11-20 13:43:00'),(4,9,'fcm_token_carol_android_fghij','android','Carol Galaxy S21',1,'2025-02-15 07:00:00','2025-11-20 13:43:00'),(5,10,'web_push_token_david_chrome','web','Chrome on Windows',1,'2025-02-15 08:30:00','2025-11-20 13:43:00');
/*!40000 ALTER TABLE `device_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `drive_files`
--

DROP TABLE IF EXISTS `drive_files`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `drive_files` (
  `drive_file_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `drive_id` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Google Drive file ID',
  `drive_folder_id` bigint unsigned NOT NULL COMMENT 'Parent folder in drive_folders',
  `local_file_id` bigint unsigned DEFAULT NULL COMMENT 'FK to local files table (redundant backup)',
  `file_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'File name in Google Drive',
  `original_file_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Original uploaded file name',
  `mime_type` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_size` bigint unsigned NOT NULL COMMENT 'File size in bytes',
  `web_view_link` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Google Drive view link',
  `web_content_link` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Direct download link',
  `thumbnail_link` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Thumbnail URL if available',
  `entity_type` enum('course_material','lab_instruction','lab_ta_material','lab_submission','assignment_instruction','assignment_submission','project_instruction','project_ta_material','project_submission') COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Type of entity this file belongs to',
  `entity_id` bigint unsigned DEFAULT NULL COMMENT 'ID of the related entity',
  `version_number` int DEFAULT '1' COMMENT 'Version number for file updates',
  `uploaded_by` bigint unsigned NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`drive_file_id`),
  UNIQUE KEY `uk_drive_id` (`drive_id`),
  KEY `idx_drive_folder` (`drive_folder_id`),
  KEY `idx_local_file` (`local_file_id`),
  KEY `idx_entity` (`entity_type`,`entity_id`),
  KEY `idx_uploaded_by` (`uploaded_by`),
  CONSTRAINT `fk_drive_files_folder` FOREIGN KEY (`drive_folder_id`) REFERENCES `drive_folders` (`drive_folder_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_drive_files_local` FOREIGN KEY (`local_file_id`) REFERENCES `files` (`file_id`) ON DELETE SET NULL,
  CONSTRAINT `fk_drive_files_uploaded_by` FOREIGN KEY (`uploaded_by`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Tracks files uploaded to Google Drive';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `drive_files`
--

LOCK TABLES `drive_files` WRITE;
/*!40000 ALTER TABLE `drive_files` DISABLE KEYS */;
INSERT INTO `drive_files` VALUES (1,'1PFxy4dByCPhiLvhH2wuKmHlX9fWDi0kK',7,NULL,'Week01_Week_1_Lecture_Notes__Introduction_to_Data_Structu_v1.pdf','Week01_Week_1_Lecture_Notes__Introduction_to_Data_Structu_v1.pdf','application/pdf',139394,'https://drive.google.com/file/d/1PFxy4dByCPhiLvhH2wuKmHlX9fWDi0kK/view?usp=drivesdk','https://drive.google.com/uc?id=1PFxy4dByCPhiLvhH2wuKmHlX9fWDi0kK&export=download',NULL,'course_material',49,1,66,'2026-03-16 20:31:41','2026-03-16 20:31:41');
/*!40000 ALTER TABLE `drive_files` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `drive_folders`
--

DROP TABLE IF EXISTS `drive_folders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `drive_folders` (
  `drive_folder_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `drive_id` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Google Drive folder ID',
  `folder_type` enum('root','department','academic_year','semester','course','course_general','course_lectures','course_labs','course_assignments','course_projects','lecture_week','lab','lab_instructions','lab_ta_materials','lab_submissions','lab_student_submission','assignment','assignment_instructions','assignment_submissions','assignment_student_submission','project','project_instructions','project_ta_materials','project_submissions','project_group_submission') COLLATE utf8mb4_unicode_ci NOT NULL,
  `parent_drive_folder_id` bigint unsigned DEFAULT NULL COMMENT 'Self-referencing FK to parent folder',
  `entity_type` enum('department','semester','course','lab','assignment','project','user','group') COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Type of entity this folder represents',
  `entity_id` bigint unsigned DEFAULT NULL COMMENT 'ID of the related entity (course_id, lab_id, etc.)',
  `folder_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Human-readable folder name',
  `folder_path` varchar(1000) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Full path for reference (e.g., EduVerse/CS/2024-2025/Fall)',
  `created_by` bigint unsigned NOT NULL COMMENT 'User who created this folder',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`drive_folder_id`),
  UNIQUE KEY `uk_drive_id` (`drive_id`),
  KEY `idx_folder_type` (`folder_type`),
  KEY `idx_parent` (`parent_drive_folder_id`),
  KEY `idx_entity` (`entity_type`,`entity_id`),
  KEY `idx_created_by` (`created_by`),
  CONSTRAINT `fk_drive_folders_created_by` FOREIGN KEY (`created_by`) REFERENCES `users` (`user_id`),
  CONSTRAINT `fk_drive_folders_parent` FOREIGN KEY (`parent_drive_folder_id`) REFERENCES `drive_folders` (`drive_folder_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Maps Google Drive folders to entities (courses, labs, etc.)';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `drive_folders`
--

LOCK TABLES `drive_folders` WRITE;
/*!40000 ALTER TABLE `drive_folders` DISABLE KEYS */;
INSERT INTO `drive_folders` VALUES (1,'11z3BsI4TWsUkb_0ZErXnbiqhicqvCar4','root',NULL,NULL,NULL,'EduVerse','EduVerse',66,'2026-03-16 20:29:14','2026-03-16 20:29:14'),(2,'1WG8CJJ8_r36gkEYsHWRFNGZRpt5lZ9cd','department',1,'department',1,'Updated_Department','EduVerse/Updated Department',66,'2026-03-16 20:31:31','2026-03-16 20:31:31'),(3,'1_bl4n-JKg_RdVrTYh970e0tgVCGoTJbB','academic_year',2,NULL,NULL,'2025-2026','EduVerse/Updated Department/2025-2026',66,'2026-03-16 20:31:32','2026-03-16 20:31:32'),(4,'1hzy0BvdRX1wOm3vid-0Hf3dxaCiOx2xb','semester',3,'semester',1,'Fall_2026_Updated','EduVerse/Updated Department/2025-2026/Fall_2026_Updated',66,'2026-03-16 20:31:33','2026-03-16 20:31:33'),(5,'1mmCYS0bVyAqEQdWQPRIvxtMt1HUYU83g','course',4,'course',1,'CS101_Updated_Course_Name','EduVerse/Updated Department/2025-2026/Fall_2026_Updated/CS101_Updated_Course_Name',66,'2026-03-16 20:31:34','2026-03-16 20:31:34'),(6,'1uDOaN3UBSQ1cTeGjPcmDW-q6PNjI_D9m','course_general',5,'course',1,'General','EduVerse/Updated Department/2025-2026/Fall_2026_Updated/CS101_Updated_Course_Name/General',66,'2026-03-16 20:31:35','2026-03-16 20:31:35'),(7,'1U77g8MXYTR_tAhLtZN0uxZjtg4iOBGBd','course_lectures',5,'course',1,'Lectures','EduVerse/Updated Department/2025-2026/Fall_2026_Updated/CS101_Updated_Course_Name/Lectures',66,'2026-03-16 20:31:36','2026-03-16 20:31:36'),(8,'1v76RnRCVjwWy5A4IRqXlk-CMOAMV4tGF','course_labs',5,'course',1,'Labs','EduVerse/Updated Department/2025-2026/Fall_2026_Updated/CS101_Updated_Course_Name/Labs',66,'2026-03-16 20:31:37','2026-03-16 20:31:37'),(9,'1tLOaumIEagNTu7XxqO1aG_kRew-aeZPg','course_assignments',5,'course',1,'Assignments','EduVerse/Updated Department/2025-2026/Fall_2026_Updated/CS101_Updated_Course_Name/Assignments',66,'2026-03-16 20:31:38','2026-03-16 20:31:38'),(10,'1lxs3kcaQF6zZs8BtWCcSWVthyAeofPQU','course_projects',5,'course',1,'Projects','EduVerse/Updated Department/2025-2026/Fall_2026_Updated/CS101_Updated_Course_Name/Projects',66,'2026-03-16 20:31:39','2026-03-16 20:31:39'),(11,'1_pSqKy_zvYhXg93Stg4_gja7y3xW3GS1','semester',3,'semester',2,'Spring_2025','EduVerse/Updated Department/2025-2026/Spring_2025',59,'2026-03-16 20:33:06','2026-03-16 20:33:06'),(12,'1mPc31vENKsswwJlFT_yH6o-s2M8e6aPb','course',11,'course',2,'CS201_Data_Structures','EduVerse/Updated Department/2025-2026/Spring_2025/CS201_Data_Structures',59,'2026-03-16 20:33:07','2026-03-16 20:33:07'),(13,'1CbCgIdRA-BSAMnw9CO5BRPwR5lcKFRwB','course_general',12,'course',2,'General','EduVerse/Updated Department/2025-2026/Spring_2025/CS201_Data_Structures/General',59,'2026-03-16 20:33:07','2026-03-16 20:33:07'),(14,'15HZStYUqQ0-lhcW3wApKTjaQ2eGm_Eus','course_lectures',12,'course',2,'Lectures','EduVerse/Updated Department/2025-2026/Spring_2025/CS201_Data_Structures/Lectures',59,'2026-03-16 20:33:08','2026-03-16 20:33:08'),(15,'1S26fhkXiWDuPNzQMTn5UNwCgsLF3fl4Q','course_labs',12,'course',2,'Labs','EduVerse/Updated Department/2025-2026/Spring_2025/CS201_Data_Structures/Labs',59,'2026-03-16 20:33:09','2026-03-16 20:33:09'),(16,'1ADW91g3mub5OUJAQL72hrttwd1km1QTa','course_assignments',12,'course',2,'Assignments','EduVerse/Updated Department/2025-2026/Spring_2025/CS201_Data_Structures/Assignments',59,'2026-03-16 20:33:10','2026-03-16 20:33:10'),(17,'1kMpR_R3gN1h3_gfxEbXnNVRSOHbzlmIe','course_projects',12,'course',2,'Projects','EduVerse/Updated Department/2025-2026/Spring_2025/CS201_Data_Structures/Projects',59,'2026-03-16 20:33:11','2026-03-16 20:33:11'),(18,'1kXCV4uUZmSV8DpKdBLMdM26iHK3h3PaX','lab',15,'lab',3,'Lab_01_Updated_Lab_Title','EduVerse/Updated Department/2025-2026/Spring_2025/CS201_Data_Structures/Labs/Lab_01_Updated_Lab_Title',59,'2026-03-16 20:33:12','2026-03-16 20:33:12'),(19,'15pkvpSC3vWXqMaPcXleeWEKbKNTa_4EK','lab_instructions',18,'lab',3,'instructions','EduVerse/Updated Department/2025-2026/Spring_2025/CS201_Data_Structures/Labs/Lab_01_Updated_Lab_Title/instructions',59,'2026-03-16 20:33:13','2026-03-16 20:33:13'),(20,'1DvEqPO9a6BRhWl9h0CPDiRaYnV5w8OEX','lab_ta_materials',18,'lab',3,'ta_materials','EduVerse/Updated Department/2025-2026/Spring_2025/CS201_Data_Structures/Labs/Lab_01_Updated_Lab_Title/ta_materials',59,'2026-03-16 20:33:14','2026-03-16 20:33:14'),(21,'18NDzdz7a6PJMkB-IBxAjii_J5Uc31s4U','lab_submissions',18,'lab',3,'submissions','EduVerse/Updated Department/2025-2026/Spring_2025/CS201_Data_Structures/Labs/Lab_01_Updated_Lab_Title/submissions',59,'2026-03-16 20:33:15','2026-03-16 20:33:15'),(22,'1g4c47Nmx_hIo2ouHbUTiqh0srFq7v6h3','assignment',9,'assignment',1,'Assignment_01_Updated_Assignment_Title','EduVerse/Updated Department/2025-2026/Fall_2026_Updated/CS101_Updated_Course_Name/Assignments/Assignment_01_Updated_Assignment_Title',59,'2026-03-16 20:33:16','2026-03-16 20:33:16'),(23,'1Qpc8v00nE_iXt4g5W_16H47YOHiJUMMf','assignment_instructions',22,'assignment',1,'instructions','EduVerse/Updated Department/2025-2026/Fall_2026_Updated/CS101_Updated_Course_Name/Assignments/Assignment_01_Updated_Assignment_Title/instructions',59,'2026-03-16 20:33:17','2026-03-16 20:33:17'),(24,'1ZAH8D2mkzOLMuX0G7Mfo3fqxaX3clGED','assignment_submissions',22,'assignment',1,'submissions','EduVerse/Updated Department/2025-2026/Fall_2026_Updated/CS101_Updated_Course_Name/Assignments/Assignment_01_Updated_Assignment_Title/submissions',59,'2026-03-16 20:33:18','2026-03-16 20:33:18');
/*!40000 ALTER TABLE `drive_folders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `email_verifications`
--

DROP TABLE IF EXISTS `email_verifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `email_verifications` (
  `verification_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `verification_token` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `expires_at` datetime NOT NULL,
  `used` tinyint(1) DEFAULT '0',
  `used_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`verification_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_token` (`verification_token`),
  KEY `idx_used_expires` (`used`,`expires_at`),
  CONSTRAINT `fk_email_verifications_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `email_verifications`
--

LOCK TABLES `email_verifications` WRITE;
/*!40000 ALTER TABLE `email_verifications` DISABLE KEYS */;
INSERT INTO `email_verifications` VALUES (1,25,'5d07adec255c200238f6eaa009c3b46f9896bb02ce146733c8cf2d742b9f0711','2025-11-27 17:22:14',1,'2025-11-26 17:23:27','2025-11-26 15:22:14'),(6,29,'21835f50cc20c446f178a8c94498092b0891812a8e99e493456119faef097fd9','2025-11-27 20:02:35',1,'2025-11-26 20:03:48','2025-11-26 18:02:35'),(7,30,'1232f414678fdff80cafc79ff0c80c37fe239fa37b01ddff305ce46e12538fa3','2025-11-28 01:31:32',1,'2025-11-27 01:33:39','2025-11-26 23:31:32'),(10,33,'420bf068e218a74d45eeae1f71e894af89d642b5c26abc0e125e37deab55c81d','2025-11-28 02:32:35',1,'2025-11-27 02:36:26','2025-11-27 00:32:35'),(11,33,'e3e106fdf64b97aa98d2aa32913f0848e3be99cc0e56da772d0a1fed775b95fe','2025-11-28 02:36:26',1,'2025-11-27 02:36:43','2025-11-27 00:36:26'),(12,34,'d29afa104b8d7a7700c047ee8732a9edae9c77c8b4fb2b3856d25f60bca755a8','2025-12-01 18:08:06',0,NULL,'2025-11-30 16:08:06'),(13,35,'3435b074bbdebb93a84a2af96d393d94ccdddbc778909051c6d8533a5e0a877f','2026-02-26 21:01:55',0,NULL,'2026-02-25 19:01:54'),(14,36,'2fa8c3e006a12edaf0294cf86bdc49c6cf2a8f1792016bcfabcb008018eb77e0','2026-02-26 21:02:43',0,NULL,'2026-02-25 19:02:43');
/*!40000 ALTER TABLE `email_verifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `exam_schedules`
--

DROP TABLE IF EXISTS `exam_schedules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `exam_schedules` (
  `exam_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `course_id` bigint unsigned NOT NULL,
  `semester_id` bigint unsigned NOT NULL,
  `exam_type` enum('midterm','final','quiz','makeup') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `exam_date` date NOT NULL,
  `start_time` time NOT NULL,
  `duration_minutes` int NOT NULL,
  `location` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `instructions` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `status` enum('scheduled','in_progress','completed','cancelled','postponed') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'scheduled',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`exam_id`),
  KEY `idx_course` (`course_id`),
  KEY `idx_semester` (`semester_id`),
  KEY `idx_date` (`exam_date`),
  CONSTRAINT `exam_schedules_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`) ON DELETE CASCADE,
  CONSTRAINT `exam_schedules_ibfk_2` FOREIGN KEY (`semester_id`) REFERENCES `semesters` (`semester_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `exam_schedules`
--

LOCK TABLES `exam_schedules` WRITE;
/*!40000 ALTER TABLE `exam_schedules` DISABLE KEYS */;
INSERT INTO `exam_schedules` VALUES (6,1,2,'midterm','CS101 Midterm','2026-06-15','09:00:00',120,'Room A101',NULL,'scheduled','2026-03-14 15:17:54','2026-03-14 15:17:54');
/*!40000 ALTER TABLE `exam_schedules` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `export_history`
--

DROP TABLE IF EXISTS `export_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `export_history` (
  `export_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `report_id` bigint unsigned NOT NULL,
  `user_id` bigint unsigned NOT NULL,
  `export_format` enum('pdf','excel','csv','json') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_id` bigint unsigned DEFAULT NULL,
  `exported_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`export_id`),
  KEY `file_id` (`file_id`),
  KEY `idx_report` (`report_id`),
  KEY `idx_user` (`user_id`),
  CONSTRAINT `export_history_ibfk_1` FOREIGN KEY (`report_id`) REFERENCES `generated_reports` (`report_id`) ON DELETE CASCADE,
  CONSTRAINT `export_history_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `export_history_ibfk_3` FOREIGN KEY (`file_id`) REFERENCES `files` (`file_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `export_history`
--

LOCK TABLES `export_history` WRITE;
/*!40000 ALTER TABLE `export_history` DISABLE KEYS */;
INSERT INTO `export_history` VALUES (1,1,59,'pdf',NULL,'2026-03-11 18:12:04'),(2,2,59,'excel',NULL,'2026-03-11 18:12:04'),(3,3,59,'csv',NULL,'2026-03-11 18:12:04'),(4,5,59,'pdf',NULL,'2026-03-11 18:19:39'),(5,6,59,'pdf',NULL,'2026-03-11 18:23:02'),(6,7,59,'csv',NULL,'2026-03-11 18:24:07'),(7,8,59,'pdf',NULL,'2026-03-11 18:29:28'),(8,9,59,'pdf',NULL,'2026-03-14 15:17:56'),(9,10,59,'pdf',NULL,'2026-03-14 15:36:14'),(10,11,59,'pdf',NULL,'2026-03-14 15:40:54'),(11,12,59,'pdf',NULL,'2026-03-14 16:06:16'),(12,13,59,'pdf',NULL,'2026-03-16 20:19:14'),(13,14,59,'pdf',NULL,'2026-03-16 20:20:20'),(14,15,59,'pdf',NULL,'2026-03-16 20:33:02'),(15,16,59,'pdf',NULL,'2026-03-16 20:45:27'),(16,17,59,'pdf',NULL,'2026-03-16 20:54:03'),(17,18,59,'pdf',NULL,'2026-03-16 22:31:40');
/*!40000 ALTER TABLE `export_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `face_recognition_data`
--

DROP TABLE IF EXISTS `face_recognition_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `face_recognition_data` (
  `face_data_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `face_encoding` blob NOT NULL,
  `sample_image_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `confidence_threshold` decimal(3,2) DEFAULT '0.75',
  `enrollment_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `status` enum('active','pending','failed','disabled') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  PRIMARY KEY (`face_data_id`),
  UNIQUE KEY `user_id` (`user_id`),
  CONSTRAINT `face_recognition_data_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `face_recognition_data`
--

LOCK TABLES `face_recognition_data` WRITE;
/*!40000 ALTER TABLE `face_recognition_data` DISABLE KEYS */;
INSERT INTO `face_recognition_data` VALUES (1,7,_binary '�PNG\r\n\Z\n\0\0','/uploads/face_samples/user_7_sample.jpg',0.85,'2025-01-20 08:00:00','2025-11-20 13:43:00','active'),(2,8,_binary '�PNG\r\n\Z\n\0','/uploads/face_samples/user_8_sample.jpg',0.80,'2025-01-20 08:15:00','2025-11-20 13:43:00','active'),(3,9,_binary '�PNG\r\n\Z\n\0','/uploads/face_samples/user_9_sample.jpg',0.82,'2025-01-20 08:30:00','2025-11-20 13:43:00','active'),(4,10,_binary '�PNG\r\n\Z\n\0','/uploads/face_samples/user_10_sample.jpg',0.75,'2025-01-20 08:45:00','2025-11-20 13:43:00','active'),(5,11,_binary '�PNG\r\n\Z\n\0','/uploads/face_samples/user_11_sample.jpg',0.78,'2025-01-20 09:00:00','2025-11-20 13:43:00','pending');
/*!40000 ALTER TABLE `face_recognition_data` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `feedback_responses`
--

DROP TABLE IF EXISTS `feedback_responses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `feedback_responses` (
  `response_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `feedback_id` bigint unsigned DEFAULT NULL,
  `ticket_id` bigint unsigned DEFAULT NULL,
  `responder_id` bigint unsigned NOT NULL,
  `response_text` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_internal_note` tinyint(1) DEFAULT '0',
  `attachments` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`response_id`),
  KEY `idx_feedback` (`feedback_id`),
  KEY `idx_ticket` (`ticket_id`),
  KEY `idx_responder` (`responder_id`),
  CONSTRAINT `feedback_responses_ibfk_1` FOREIGN KEY (`feedback_id`) REFERENCES `user_feedback` (`feedback_id`) ON DELETE CASCADE,
  CONSTRAINT `feedback_responses_ibfk_2` FOREIGN KEY (`ticket_id`) REFERENCES `support_tickets` (`ticket_id`) ON DELETE CASCADE,
  CONSTRAINT `feedback_responses_ibfk_3` FOREIGN KEY (`responder_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `feedback_responses`
--

LOCK TABLES `feedback_responses` WRITE;
/*!40000 ALTER TABLE `feedback_responses` DISABLE KEYS */;
INSERT INTO `feedback_responses` VALUES (1,1,1,1,'Thank you for reporting this issue. We have identified the problem with file upload validation. Could you please try again?',0,NULL,'2025-11-20 13:43:00'),(2,1,1,7,'It works now! Thank you so much!',0,NULL,'2025-11-20 13:43:00'),(3,4,2,1,'Your quiz grade has been updated. There was a delay in the automated grading system. Please check your gradebook now.',0,NULL,'2025-11-20 13:43:00'),(4,NULL,3,1,'I have manually sent you a password reset link to your registered email. Please check your spam folder as well.',0,NULL,'2025-11-20 13:43:00'),(5,2,NULL,1,'Great suggestion! We are working on implementing dark mode in the next update.',0,NULL,'2025-11-20 13:43:00');
/*!40000 ALTER TABLE `feedback_responses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `file_permissions`
--

DROP TABLE IF EXISTS `file_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `file_permissions` (
  `permission_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `file_id` bigint unsigned DEFAULT NULL,
  `folder_id` bigint unsigned DEFAULT NULL,
  `user_id` bigint unsigned DEFAULT NULL,
  `role_id` int unsigned DEFAULT NULL,
  `permission_type` enum('read','write','delete','share') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `granted_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `granted_by` bigint unsigned DEFAULT NULL,
  PRIMARY KEY (`permission_id`),
  KEY `granted_by` (`granted_by`),
  KEY `idx_file` (`file_id`),
  KEY `idx_folder` (`folder_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_role` (`role_id`),
  CONSTRAINT `file_permissions_ibfk_1` FOREIGN KEY (`file_id`) REFERENCES `files` (`file_id`) ON DELETE CASCADE,
  CONSTRAINT `file_permissions_ibfk_2` FOREIGN KEY (`folder_id`) REFERENCES `folders` (`folder_id`) ON DELETE CASCADE,
  CONSTRAINT `file_permissions_ibfk_3` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `file_permissions_ibfk_4` FOREIGN KEY (`role_id`) REFERENCES `roles` (`role_id`) ON DELETE CASCADE,
  CONSTRAINT `file_permissions_ibfk_5` FOREIGN KEY (`granted_by`) REFERENCES `users` (`user_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `file_permissions`
--

LOCK TABLES `file_permissions` WRITE;
/*!40000 ALTER TABLE `file_permissions` DISABLE KEYS */;
/*!40000 ALTER TABLE `file_permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `file_versions`
--

DROP TABLE IF EXISTS `file_versions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `file_versions` (
  `version_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `file_id` bigint unsigned NOT NULL,
  `version_number` int NOT NULL,
  `file_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_size` bigint unsigned DEFAULT NULL,
  `uploaded_by` bigint unsigned NOT NULL,
  `change_description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`version_id`),
  UNIQUE KEY `unique_file_version` (`file_id`,`version_number`),
  KEY `uploaded_by` (`uploaded_by`),
  KEY `idx_file` (`file_id`),
  CONSTRAINT `file_versions_ibfk_1` FOREIGN KEY (`file_id`) REFERENCES `files` (`file_id`) ON DELETE CASCADE,
  CONSTRAINT `file_versions_ibfk_2` FOREIGN KEY (`uploaded_by`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `file_versions`
--

LOCK TABLES `file_versions` WRITE;
/*!40000 ALTER TABLE `file_versions` DISABLE KEYS */;
/*!40000 ALTER TABLE `file_versions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `files`
--

DROP TABLE IF EXISTS `files`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `files` (
  `file_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `file_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `original_filename` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_size` bigint unsigned DEFAULT NULL,
  `mime_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `file_extension` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `uploaded_by` bigint unsigned NOT NULL,
  `folder_id` bigint unsigned DEFAULT NULL,
  `checksum` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `download_count` int DEFAULT '0',
  `is_public` tinyint(1) DEFAULT '0',
  `status` enum('active','processing','archived','deleted') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'active',
  `uploaded_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`file_id`),
  KEY `idx_uploader` (`uploaded_by`),
  KEY `idx_folder` (`folder_id`),
  KEY `idx_checksum` (`checksum`),
  KEY `idx_uploader_status` (`uploaded_by`,`status`),
  KEY `idx_folder_status` (`folder_id`,`status`),
  CONSTRAINT `files_ibfk_1` FOREIGN KEY (`uploaded_by`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `files_ibfk_2` FOREIGN KEY (`folder_id`) REFERENCES `folders` (`folder_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `files`
--

LOCK TABLES `files` WRITE;
/*!40000 ALTER TABLE `files` DISABLE KEYS */;
INSERT INTO `files` VALUES (1,'cs101_syllabus.pdf','CS101_Syllabus.pdf','/course_materials/cs101/syllabus.pdf',524288,'application/pdf','pdf',2,2,NULL,0,1,'active','2025-11-20 13:42:59','2025-11-20 13:42:59',NULL),(2,'cs101_lecture1.pdf','Lecture_1_Introduction.pdf','/course_materials/cs101/lecture1.pdf',1048576,'application/pdf','pdf',2,2,NULL,0,1,'active','2025-11-20 13:42:59','2025-11-20 13:42:59',NULL),(3,'cs101_lecture2.pdf','Lecture_2_Variables.pdf','/course_materials/cs101/lecture2.pdf',892467,'application/pdf','pdf',2,2,NULL,0,1,'active','2025-11-20 13:42:59','2025-11-20 13:42:59',NULL),(4,'cs201_syllabus.pdf','CS201_Syllabus.pdf','/course_materials/cs201/syllabus.pdf',612453,'application/pdf','pdf',3,3,NULL,0,1,'active','2025-11-20 13:42:59','2025-11-20 13:42:59',NULL),(5,'assignment1_spec.pdf','Assignment_1_Specifications.pdf','/assignments/cs101/assign1.pdf',234567,'application/pdf','pdf',2,4,NULL,0,0,'active','2025-11-20 13:42:59','2025-11-20 13:42:59',NULL);
/*!40000 ALTER TABLE `files` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `folders`
--

DROP TABLE IF EXISTS `folders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `folders` (
  `folder_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `folder_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `parent_folder_id` bigint unsigned DEFAULT NULL,
  `created_by` bigint unsigned NOT NULL,
  `path` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `level` int DEFAULT '0',
  `is_system_folder` tinyint(1) DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`folder_id`),
  KEY `idx_parent` (`parent_folder_id`),
  KEY `idx_creator` (`created_by`),
  CONSTRAINT `folders_ibfk_1` FOREIGN KEY (`parent_folder_id`) REFERENCES `folders` (`folder_id`) ON DELETE CASCADE,
  CONSTRAINT `folders_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `folders`
--

LOCK TABLES `folders` WRITE;
/*!40000 ALTER TABLE `folders` DISABLE KEYS */;
INSERT INTO `folders` VALUES (1,'Course Materials',NULL,1,'/course_materials',0,1,'2025-11-20 13:42:59','2025-11-20 13:42:59'),(2,'CS101 Materials',NULL,2,'/course_materials/cs101',1,0,'2025-11-20 13:42:59','2025-11-20 13:42:59'),(3,'CS201 Materials',NULL,3,'/course_materials/cs201',1,0,'2025-11-20 13:42:59','2025-11-20 13:42:59'),(4,'Assignments',NULL,1,'/assignments',0,1,'2025-11-20 13:42:59','2025-11-20 13:42:59'),(5,'Student Submissions',NULL,1,'/student_submissions',0,1,'2025-11-20 13:42:59','2025-11-20 13:42:59'),(7,'MergeTestFolder',NULL,59,NULL,0,0,'2026-03-02 14:05:02','2026-03-02 14:05:02'),(8,'Lecture Notes',NULL,59,NULL,0,0,'2026-03-02 23:33:11','2026-03-02 23:33:11'),(9,'Test PM Folder',NULL,59,NULL,0,0,'2026-03-02 23:42:38','2026-03-02 23:42:38'),(10,'Test PM Folder',NULL,59,NULL,0,0,'2026-03-02 23:47:21','2026-03-02 23:47:21'),(11,'Lecture Notes',NULL,59,NULL,0,0,'2026-03-02 23:51:58','2026-03-02 23:51:58'),(12,'Lecture Notes',NULL,59,NULL,0,0,'2026-03-03 00:23:19','2026-03-03 00:23:19'),(13,'Lecture Notes',NULL,59,NULL,0,0,'2026-03-03 18:34:04','2026-03-03 18:34:04'),(14,'Lecture Notes',NULL,59,NULL,0,0,'2026-03-05 19:16:25','2026-03-05 19:16:25');
/*!40000 ALTER TABLE `folders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `forum_categories`
--

DROP TABLE IF EXISTS `forum_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `forum_categories` (
  `category_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `course_id` bigint unsigned NOT NULL,
  `category_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `order_index` int DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`category_id`),
  KEY `idx_course` (`course_id`),
  CONSTRAINT `forum_categories_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `forum_categories`
--

LOCK TABLES `forum_categories` WRITE;
/*!40000 ALTER TABLE `forum_categories` DISABLE KEYS */;
INSERT INTO `forum_categories` VALUES (4,2,'General Discussion','General CS201 discussions',1,'2025-11-20 13:43:00'),(5,2,'Project Discussions','Discuss course projects',2,'2025-11-20 13:43:00'),(6,1,'Test Category','A test forum category',5,'2026-03-05 19:16:32');
/*!40000 ALTER TABLE `forum_categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `generated_reports`
--

DROP TABLE IF EXISTS `generated_reports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `generated_reports` (
  `report_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `template_id` bigint unsigned NOT NULL,
  `user_id` bigint unsigned NOT NULL,
  `report_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `report_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `filters` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `file_id` bigint unsigned DEFAULT NULL,
  `generation_status` enum('pending','processing','completed','failed') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  `generated_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`report_id`),
  KEY `template_id` (`template_id`),
  KEY `file_id` (`file_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_status` (`generation_status`),
  CONSTRAINT `generated_reports_ibfk_1` FOREIGN KEY (`template_id`) REFERENCES `report_templates` (`template_id`) ON DELETE CASCADE,
  CONSTRAINT `generated_reports_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `generated_reports_ibfk_3` FOREIGN KEY (`file_id`) REFERENCES `files` (`file_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `generated_reports`
--

LOCK TABLES `generated_reports` WRITE;
/*!40000 ALTER TABLE `generated_reports` DISABLE KEYS */;
INSERT INTO `generated_reports` VALUES (1,1,2,'Alice Anderson Progress Report - Spring 2025','student','{\"user_id\": 7, \"semester_id\": 2}',NULL,'completed','2025-02-15 08:00:00','2025-11-20 13:43:00'),(2,2,2,'CS101 Section A Analytics','course','{\"section_id\": 1, \"semester_id\": 2}',NULL,'completed','2025-02-14 13:30:00','2025-11-20 13:43:00'),(3,3,2,'CS101 Attendance Report - February','attendance','{\"section_id\": 1, \"month\": \"2025-02\"}',NULL,'completed','2025-02-28 07:00:00','2025-11-20 13:43:00'),(5,1,59,'Test Report','student','{\"courseId\":1}',NULL,'completed','2026-03-11 18:19:40','2026-03-11 18:19:39'),(6,1,59,'Test Report','student','{\"courseId\":1}',NULL,'completed','2026-03-11 18:23:02','2026-03-11 18:23:02'),(7,1,59,'Test','student','{}',NULL,'completed','2026-03-11 18:24:07','2026-03-11 18:24:07'),(8,1,59,'Test Student Progress Report','student','{\"courseId\":1,\"semesterId\":2}',NULL,'completed','2026-03-11 18:29:29','2026-03-11 18:29:28'),(9,1,59,'Test Student Progress Report','student','{\"courseId\":1,\"semesterId\":2}',NULL,'completed','2026-03-14 15:17:57','2026-03-14 15:17:56'),(10,1,59,'Test Student Progress Report','student','{\"courseId\":1,\"semesterId\":2}',NULL,'completed','2026-03-14 15:36:14','2026-03-14 15:36:14'),(11,1,59,'Test Student Progress Report','student','{\"courseId\":1,\"semesterId\":2}',NULL,'completed','2026-03-14 15:40:54','2026-03-14 15:40:54'),(12,1,59,'Test Student Progress Report','student','{\"courseId\":1,\"semesterId\":2}',NULL,'completed','2026-03-14 16:06:16','2026-03-14 16:06:16'),(13,1,59,'Test Student Progress Report','student','{\"courseId\":1,\"semesterId\":2}',NULL,'completed','2026-03-16 20:19:15','2026-03-16 20:19:14'),(14,1,59,'Test Student Progress Report','student','{\"courseId\":1,\"semesterId\":2}',NULL,'completed','2026-03-16 20:20:20','2026-03-16 20:20:20'),(15,1,59,'Test Student Progress Report','student','{\"courseId\":1,\"semesterId\":2}',NULL,'completed','2026-03-16 20:33:02','2026-03-16 20:33:01'),(16,1,59,'Test Student Progress Report','student','{\"courseId\":1,\"semesterId\":2}',NULL,'completed','2026-03-16 20:45:28','2026-03-16 20:45:27'),(17,1,59,'Test Student Progress Report','student','{\"courseId\":1,\"semesterId\":2}',NULL,'completed','2026-03-16 20:54:04','2026-03-16 20:54:03'),(18,1,59,'Test Student Progress Report','student','{\"courseId\":1,\"semesterId\":2}',NULL,'completed','2026-03-16 22:31:40','2026-03-16 22:31:39');
/*!40000 ALTER TABLE `generated_reports` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `gpa_calculations`
--

DROP TABLE IF EXISTS `gpa_calculations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `gpa_calculations` (
  `gpa_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `semester_id` bigint unsigned DEFAULT NULL,
  `calculation_type` enum('semester','cumulative') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'semester',
  `gpa` decimal(3,2) NOT NULL,
  `total_credits` int DEFAULT NULL,
  `total_points` decimal(10,2) DEFAULT NULL,
  `calculated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`gpa_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_semester` (`semester_id`),
  CONSTRAINT `gpa_calculations_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `gpa_calculations_ibfk_2` FOREIGN KEY (`semester_id`) REFERENCES `semesters` (`semester_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `gpa_calculations`
--

LOCK TABLES `gpa_calculations` WRITE;
/*!40000 ALTER TABLE `gpa_calculations` DISABLE KEYS */;
INSERT INTO `gpa_calculations` VALUES (4,7,NULL,'cumulative',3.78,45,170.10,'2025-02-15 21:59:59'),(5,8,NULL,'cumulative',3.52,42,147.84,'2025-02-15 21:59:59'),(6,57,2,'semester',3.65,15,54.75,'2026-03-11 16:42:55'),(7,57,4,'semester',3.80,12,45.60,'2026-03-11 16:42:55'),(8,57,NULL,'cumulative',3.72,27,100.35,'2026-03-11 16:42:55');
/*!40000 ALTER TABLE `gpa_calculations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `grade_components`
--

DROP TABLE IF EXISTS `grade_components`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `grade_components` (
  `component_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `grade_id` bigint unsigned NOT NULL,
  `rubric_id` bigint unsigned DEFAULT NULL,
  `criterion_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `points_earned` decimal(5,2) NOT NULL,
  `max_points` decimal(5,2) NOT NULL,
  `feedback` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`component_id`),
  KEY `rubric_id` (`rubric_id`),
  KEY `idx_grade` (`grade_id`),
  CONSTRAINT `grade_components_ibfk_1` FOREIGN KEY (`grade_id`) REFERENCES `grades` (`grade_id`) ON DELETE CASCADE,
  CONSTRAINT `grade_components_ibfk_2` FOREIGN KEY (`rubric_id`) REFERENCES `rubrics` (`rubric_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `grade_components`
--

LOCK TABLES `grade_components` WRITE;
/*!40000 ALTER TABLE `grade_components` DISABLE KEYS */;
/*!40000 ALTER TABLE `grade_components` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `grades`
--

DROP TABLE IF EXISTS `grades`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `grades` (
  `grade_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `course_id` bigint unsigned NOT NULL,
  `assignment_id` bigint unsigned DEFAULT NULL,
  `quiz_id` bigint unsigned DEFAULT NULL,
  `lab_id` bigint unsigned DEFAULT NULL,
  `grade_type` enum('assignment','quiz','lab','exam','participation','final') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `score` decimal(5,2) NOT NULL,
  `max_score` decimal(5,2) NOT NULL,
  `percentage` decimal(5,2) DEFAULT NULL,
  `letter_grade` varchar(5) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `feedback` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `graded_by` bigint unsigned DEFAULT NULL,
  `graded_at` timestamp NULL DEFAULT NULL,
  `is_published` tinyint(1) DEFAULT '0',
  `published_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`grade_id`),
  KEY `assignment_id` (`assignment_id`),
  KEY `quiz_id` (`quiz_id`),
  KEY `lab_id` (`lab_id`),
  KEY `graded_by` (`graded_by`),
  KEY `idx_user` (`user_id`),
  KEY `idx_course` (`course_id`),
  KEY `idx_type` (`grade_type`),
  KEY `idx_published` (`is_published`),
  KEY `idx_user_course` (`user_id`,`course_id`),
  KEY `idx_course_published` (`course_id`,`is_published`),
  KEY `idx_user_published` (`user_id`,`is_published`),
  CONSTRAINT `grades_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `grades_ibfk_2` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`) ON DELETE CASCADE,
  CONSTRAINT `grades_ibfk_3` FOREIGN KEY (`assignment_id`) REFERENCES `assignments` (`assignment_id`) ON DELETE CASCADE,
  CONSTRAINT `grades_ibfk_4` FOREIGN KEY (`quiz_id`) REFERENCES `quizzes` (`quiz_id`) ON DELETE CASCADE,
  CONSTRAINT `grades_ibfk_5` FOREIGN KEY (`lab_id`) REFERENCES `labs` (`lab_id`) ON DELETE CASCADE,
  CONSTRAINT `grades_ibfk_6` FOREIGN KEY (`graded_by`) REFERENCES `users` (`user_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `grades`
--

LOCK TABLES `grades` WRITE;
/*!40000 ALTER TABLE `grades` DISABLE KEYS */;
INSERT INTO `grades` VALUES (6,21,1,1,NULL,NULL,'assignment',92.00,100.00,92.00,'A','Great work! Well-structured code.',8,'2025-02-01 10:00:00',1,NULL,'2026-03-01 14:55:40','2026-03-01 14:55:40'),(7,22,1,1,NULL,NULL,'assignment',88.00,100.00,88.00,'B+','Good solution. Need improvement in error handling.',8,'2025-02-01 10:00:00',1,NULL,'2026-03-01 14:55:40','2026-03-01 14:55:40'),(8,23,1,1,NULL,NULL,'assignment',95.00,100.00,95.00,'A','Excellent! Clean code and thorough testing.',8,'2025-02-01 10:00:00',1,NULL,'2026-03-01 14:55:40','2026-03-01 14:55:40'),(9,24,1,1,NULL,NULL,'assignment',85.00,100.00,85.00,'B','Acceptable solution but could be optimized.',8,'2025-02-02 09:00:00',1,NULL,'2026-03-01 14:55:40','2026-03-01 14:55:40'),(10,25,1,1,NULL,NULL,'assignment',90.00,100.00,90.00,'A-','Good job overall.',8,'2025-02-01 10:00:00',1,NULL,'2026-03-01 14:55:40','2026-03-01 14:55:40'),(11,21,1,NULL,NULL,NULL,'quiz',18.00,20.00,90.00,'A-','Well done on the quiz!',8,'2025-02-03 10:30:00',1,NULL,'2026-03-01 14:55:40','2026-03-01 14:55:40'),(12,22,1,NULL,NULL,NULL,'quiz',16.00,20.00,80.00,'B-','Good effort. Review control flow concepts.',8,'2025-02-03 10:30:00',1,NULL,'2026-03-01 14:55:40','2026-03-01 14:55:40'),(13,23,1,NULL,NULL,NULL,'quiz',19.00,20.00,95.00,'A','Perfect score! Excellent understanding.',8,'2025-02-03 10:30:00',1,NULL,'2026-03-01 14:55:40','2026-03-01 14:55:40'),(14,24,1,NULL,NULL,NULL,'quiz',15.00,20.00,75.00,'C+','Needs improvement. Review material.',8,'2025-02-03 10:30:00',1,NULL,'2026-03-01 14:55:40','2026-03-01 14:55:40'),(15,25,1,NULL,NULL,NULL,'quiz',17.00,20.00,85.00,'B+','Good work on the quiz.',8,'2025-02-03 10:30:00',1,NULL,'2026-03-01 14:55:40','2026-03-01 14:55:40'),(16,57,1,1,NULL,NULL,'assignment',85.00,100.00,85.00,'A','Great work on programming basics!',2,'2026-03-11 16:42:55',1,'2026-03-11 16:42:55','2026-03-11 16:42:55','2026-03-11 16:42:55'),(17,57,1,2,NULL,NULL,'assignment',78.00,100.00,78.00,'B+','Good understanding of functions.',2,'2026-03-11 16:42:55',1,'2026-03-11 16:42:55','2026-03-11 16:42:55','2026-03-11 16:42:55'),(18,57,1,NULL,NULL,NULL,'quiz',90.00,100.00,90.00,'A','Excellent quiz performance.',2,'2026-03-11 16:42:55',1,'2026-03-11 16:42:55','2026-03-11 16:42:55','2026-03-11 16:42:55'),(19,57,1,NULL,NULL,NULL,'exam',88.00,100.00,88.00,'A','Strong midterm showing.',2,'2026-03-11 16:42:55',1,'2026-03-11 16:42:55','2026-03-11 16:42:55','2026-03-11 16:42:55'),(20,57,1,NULL,NULL,NULL,'participation',95.00,100.00,95.00,'A+','Active participant.',2,'2026-03-11 16:42:55',1,'2026-03-11 16:42:55','2026-03-11 16:42:55','2026-03-11 16:42:55'),(21,57,2,NULL,NULL,NULL,'assignment',92.00,100.00,92.00,'A','Excellent data structures work.',3,'2026-03-11 16:42:55',1,'2026-03-11 16:42:55','2026-03-11 16:42:55','2026-03-11 16:42:55'),(22,57,2,NULL,NULL,NULL,'quiz',88.00,100.00,88.00,'A','Great quiz results.',3,'2026-03-11 16:42:55',1,'2026-03-11 16:42:55','2026-03-11 16:42:55','2026-03-11 16:42:55'),(23,57,2,NULL,NULL,NULL,'exam',82.00,100.00,82.00,'B+','Good exam performance.',3,'2026-03-11 16:42:55',1,'2026-03-11 16:42:55','2026-03-11 16:42:55','2026-03-11 16:42:55'),(24,57,3,NULL,NULL,NULL,'assignment',75.00,100.00,75.00,'B','Solid database work.',4,'2026-03-11 16:42:55',1,'2026-03-11 16:42:55','2026-03-11 16:42:55','2026-03-11 16:42:55'),(25,57,3,NULL,NULL,NULL,'exam',80.00,100.00,80.00,'B+','Good understanding of SQL.',4,'2026-03-11 16:42:55',1,'2026-03-11 16:42:55','2026-03-11 16:42:55','2026-03-11 16:42:55'),(26,57,4,NULL,NULL,NULL,'assignment',95.00,100.00,95.00,'A+','Outstanding AI concepts paper.',2,'2026-03-11 16:42:55',1,'2026-03-11 16:42:55','2026-03-11 16:42:55','2026-03-11 16:42:55'),(27,57,4,NULL,NULL,NULL,'quiz',91.00,100.00,91.00,'A','Great AI quiz.',2,'2026-03-11 16:42:55',1,'2026-03-11 16:42:55','2026-03-11 16:42:55','2026-03-11 16:42:55'),(28,57,5,NULL,NULL,NULL,'exam',87.00,100.00,87.00,'A','Good calculus exam.',2,'2026-03-11 16:42:55',1,'2026-03-11 16:42:55','2026-03-11 16:42:55','2026-03-11 16:42:55');
/*!40000 ALTER TABLE `grades` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `image_text_extractions`
--

DROP TABLE IF EXISTS `image_text_extractions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `image_text_extractions` (
  `extraction_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `image_file_id` bigint unsigned NOT NULL,
  `extracted_text` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `language` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'en',
  `confidence_score` decimal(3,2) DEFAULT NULL,
  `processing_status` enum('pending','completed','failed') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'completed',
  `processing_time_ms` int DEFAULT NULL,
  `ai_model` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`extraction_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_file` (`image_file_id`),
  KEY `idx_status` (`processing_status`),
  CONSTRAINT `image_text_extractions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `image_text_extractions_ibfk_2` FOREIGN KEY (`image_file_id`) REFERENCES `files` (`file_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `image_text_extractions`
--

LOCK TABLES `image_text_extractions` WRITE;
/*!40000 ALTER TABLE `image_text_extractions` DISABLE KEYS */;
INSERT INTO `image_text_extractions` VALUES (1,7,3,'Variables in Python: int, float, str, bool. Variable naming conventions: use lowercase with underscores.','en',0.89,'completed',1800,'tesseract-ocr','2025-11-20 13:43:00'),(2,8,2,'Lecture 1: Introduction to Programming. Topics: What is programming? Programming languages. Python basics.','en',0.92,'completed',2200,'tesseract-ocr','2025-11-20 13:43:00');
/*!40000 ALTER TABLE `image_text_extractions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lab_attendance`
--

DROP TABLE IF EXISTS `lab_attendance`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lab_attendance` (
  `attendance_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `lab_id` bigint unsigned NOT NULL,
  `user_id` bigint unsigned NOT NULL,
  `attendance_status` enum('present','absent','excused','late') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'absent',
  `check_in_time` timestamp NULL DEFAULT NULL,
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `marked_by` bigint unsigned DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`attendance_id`),
  UNIQUE KEY `unique_lab_user` (`lab_id`,`user_id`),
  KEY `marked_by` (`marked_by`),
  KEY `idx_lab` (`lab_id`),
  KEY `idx_user` (`user_id`),
  CONSTRAINT `lab_attendance_ibfk_1` FOREIGN KEY (`lab_id`) REFERENCES `labs` (`lab_id`) ON DELETE CASCADE,
  CONSTRAINT `lab_attendance_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `lab_attendance_ibfk_3` FOREIGN KEY (`marked_by`) REFERENCES `users` (`user_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lab_attendance`
--

LOCK TABLES `lab_attendance` WRITE;
/*!40000 ALTER TABLE `lab_attendance` DISABLE KEYS */;
INSERT INTO `lab_attendance` VALUES (7,4,57,'present','2026-03-03 00:10:05','On time',58,'2026-03-03 00:10:05'),(8,7,57,'present','2026-03-03 00:27:50','On time',58,'2026-03-03 00:27:50');
/*!40000 ALTER TABLE `lab_attendance` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lab_instructions`
--

DROP TABLE IF EXISTS `lab_instructions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lab_instructions` (
  `instruction_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `lab_id` bigint unsigned NOT NULL,
  `file_id` bigint unsigned DEFAULT NULL,
  `instruction_text` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `order_index` int DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`instruction_id`),
  KEY `file_id` (`file_id`),
  KEY `idx_lab` (`lab_id`),
  CONSTRAINT `lab_instructions_ibfk_1` FOREIGN KEY (`lab_id`) REFERENCES `labs` (`lab_id`) ON DELETE CASCADE,
  CONSTRAINT `lab_instructions_ibfk_2` FOREIGN KEY (`file_id`) REFERENCES `files` (`file_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lab_instructions`
--

LOCK TABLES `lab_instructions` WRITE;
/*!40000 ALTER TABLE `lab_instructions` DISABLE KEYS */;
INSERT INTO `lab_instructions` VALUES (7,3,NULL,'Implement a dynamic array class with push, pop, and resize methods',1,'2025-11-20 13:43:00'),(8,4,NULL,'Step 1: Implement the binary tree node class',1,'2026-03-03 00:09:59'),(9,7,NULL,'Step 1: Implement the binary tree node class',1,'2026-03-03 00:26:30');
/*!40000 ALTER TABLE `lab_instructions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lab_submissions`
--

DROP TABLE IF EXISTS `lab_submissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lab_submissions` (
  `submission_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `lab_id` bigint unsigned NOT NULL,
  `user_id` bigint unsigned NOT NULL,
  `file_id` bigint unsigned DEFAULT NULL,
  `submission_text` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `submitted_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `is_late` tinyint(1) DEFAULT '0',
  `status` enum('submitted','graded','returned','resubmit') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'submitted',
  PRIMARY KEY (`submission_id`),
  KEY `file_id` (`file_id`),
  KEY `idx_lab` (`lab_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_status` (`status`),
  CONSTRAINT `lab_submissions_ibfk_1` FOREIGN KEY (`lab_id`) REFERENCES `labs` (`lab_id`) ON DELETE CASCADE,
  CONSTRAINT `lab_submissions_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `lab_submissions_ibfk_3` FOREIGN KEY (`file_id`) REFERENCES `files` (`file_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lab_submissions`
--

LOCK TABLES `lab_submissions` WRITE;
/*!40000 ALTER TABLE `lab_submissions` DISABLE KEYS */;
INSERT INTO `lab_submissions` VALUES (5,4,57,NULL,'My binary tree implementation...','2026-03-03 00:10:01',0,'graded'),(6,7,57,NULL,'My binary tree implementation with inorder, preorder, and postorder traversals.','2026-03-03 00:26:48',0,'submitted');
/*!40000 ALTER TABLE `lab_submissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `labs`
--

DROP TABLE IF EXISTS `labs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `labs` (
  `lab_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `course_id` bigint unsigned NOT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `lab_number` int DEFAULT NULL,
  `due_date` timestamp NULL DEFAULT NULL,
  `available_from` timestamp NULL DEFAULT NULL,
  `max_score` decimal(5,2) DEFAULT '100.00',
  `weight` decimal(5,2) DEFAULT '0.00',
  `status` enum('draft','published','closed','archived') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'draft',
  `created_by` bigint unsigned NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`lab_id`),
  KEY `created_by` (`created_by`),
  KEY `idx_course` (`course_id`),
  KEY `idx_due_date` (`due_date`),
  CONSTRAINT `labs_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`) ON DELETE CASCADE,
  CONSTRAINT `labs_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `labs`
--

LOCK TABLES `labs` WRITE;
/*!40000 ALTER TABLE `labs` DISABLE KEYS */;
INSERT INTO `labs` VALUES (3,2,'Updated Lab Title','Implement dynamic arrays',1,'2025-03-01 21:59:59','2025-02-14 22:00:00',100.00,10.00,'draft',3,'2025-11-20 13:43:00','2026-03-11 17:20:08'),(4,1,'Data Structures Lab 1 (Updated)','Updated description',1,'2026-04-01 23:59:59','2026-03-01 00:00:00',100.00,10.00,'published',58,'2026-03-03 00:09:55','2026-03-03 00:09:58'),(7,1,'Data Structures Lab 1','Binary tree traversal lab',1,'2026-04-01 23:59:59','2026-03-01 00:00:00',100.00,10.00,'published',58,'2026-03-03 00:26:01','2026-03-03 00:26:01'),(8,1,'Data Structures Lab 1','Binary tree traversal lab',1,'2026-04-01 23:59:59','2026-03-01 00:00:00',100.00,10.00,'published',58,'2026-03-03 18:34:08','2026-03-03 18:34:08'),(9,1,'Data Structures Lab 1','Binary tree traversal lab',1,'2026-04-01 23:59:59','2026-03-01 00:00:00',100.00,10.00,'published',58,'2026-03-05 19:16:28','2026-03-05 19:16:28'),(10,1,'API Dog Test Lab','Test lab',NULL,'2026-06-15 23:59:00',NULL,100.00,0.00,'draft',59,'2026-03-11 17:20:08','2026-03-11 17:20:08'),(11,1,'API Dog Test Lab','Test lab',NULL,'2026-06-15 23:59:00',NULL,100.00,0.00,'draft',59,'2026-03-11 17:37:54','2026-03-11 17:37:54'),(12,1,'API Dog Test Lab','Test lab',NULL,'2026-06-15 23:59:00',NULL,100.00,0.00,'draft',59,'2026-03-14 15:17:50','2026-03-14 15:17:50'),(13,1,'API Dog Test Lab','Test lab',NULL,'2026-06-15 23:59:00',NULL,100.00,0.00,'draft',59,'2026-03-14 15:36:07','2026-03-14 15:36:07'),(14,1,'API Dog Test Lab','Test lab',NULL,'2026-06-15 23:59:00',NULL,100.00,0.00,'draft',59,'2026-03-14 15:40:47','2026-03-14 15:40:47'),(15,1,'API Dog Test Lab','Test lab',NULL,'2026-06-15 23:59:00',NULL,100.00,0.00,'draft',59,'2026-03-14 16:06:09','2026-03-14 16:06:09'),(16,1,'API Dog Test Lab','Test lab',NULL,'2026-06-15 23:59:00',NULL,100.00,0.00,'draft',59,'2026-03-16 20:19:07','2026-03-16 20:19:07'),(17,1,'API Dog Test Lab','Test lab',NULL,'2026-06-15 23:59:00',NULL,100.00,0.00,'draft',59,'2026-03-16 20:20:13','2026-03-16 20:20:13'),(18,1,'API Dog Test Lab','Test lab',NULL,'2026-06-15 23:59:00',NULL,100.00,0.00,'draft',59,'2026-03-16 20:32:54','2026-03-16 20:32:54'),(19,1,'API Dog Test Lab','Test lab',NULL,'2026-06-15 23:59:00',NULL,100.00,0.00,'draft',59,'2026-03-16 20:45:20','2026-03-16 20:45:20'),(20,1,'API Dog Test Lab','Test lab',NULL,'2026-06-15 23:59:00',NULL,100.00,0.00,'draft',59,'2026-03-16 20:53:56','2026-03-16 20:53:56'),(21,1,'API Dog Test Lab','Test lab',NULL,'2026-06-15 23:59:00',NULL,100.00,0.00,'draft',59,'2026-03-16 22:31:32','2026-03-16 22:31:32');
/*!40000 ALTER TABLE `labs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `language_preferences`
--

DROP TABLE IF EXISTS `language_preferences`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `language_preferences` (
  `preference_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `language_code` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'en',
  `date_format` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'YYYY-MM-DD',
  `time_format` enum('12h','24h') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT '24h',
  `timezone` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'UTC',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`preference_id`),
  UNIQUE KEY `user_id` (`user_id`),
  CONSTRAINT `language_preferences_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `language_preferences`
--

LOCK TABLES `language_preferences` WRITE;
/*!40000 ALTER TABLE `language_preferences` DISABLE KEYS */;
INSERT INTO `language_preferences` VALUES (1,7,'en','YYYY-MM-DD','24h','America/New_York','2025-11-20 13:43:00'),(2,8,'en','MM/DD/YYYY','12h','America/New_York','2025-11-20 13:43:00'),(3,9,'en','YYYY-MM-DD','24h','America/Los_Angeles','2025-11-20 13:43:00'),(4,10,'en','DD/MM/YYYY','24h','America/Chicago','2025-11-20 13:43:00'),(5,11,'en','YYYY-MM-DD','12h','America/New_York','2025-11-20 13:43:00'),(6,12,'en','MM/DD/YYYY','24h','America/New_York','2025-11-20 13:43:00');
/*!40000 ALTER TABLE `language_preferences` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `leaderboard_rankings`
--

DROP TABLE IF EXISTS `leaderboard_rankings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `leaderboard_rankings` (
  `ranking_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `leaderboard_id` bigint unsigned NOT NULL,
  `user_id` bigint unsigned NOT NULL,
  `rank_position` int NOT NULL,
  `total_points` bigint NOT NULL,
  `previous_rank` int DEFAULT NULL,
  `rank_change` int DEFAULT '0',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ranking_id`),
  UNIQUE KEY `unique_leaderboard_user` (`leaderboard_id`,`user_id`),
  KEY `idx_leaderboard` (`leaderboard_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_rank` (`rank_position`),
  CONSTRAINT `leaderboard_rankings_ibfk_1` FOREIGN KEY (`leaderboard_id`) REFERENCES `leaderboards` (`leaderboard_id`) ON DELETE CASCADE,
  CONSTRAINT `leaderboard_rankings_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `leaderboard_rankings`
--

LOCK TABLES `leaderboard_rankings` WRITE;
/*!40000 ALTER TABLE `leaderboard_rankings` DISABLE KEYS */;
/*!40000 ALTER TABLE `leaderboard_rankings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `leaderboards`
--

DROP TABLE IF EXISTS `leaderboards`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `leaderboards` (
  `leaderboard_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `leaderboard_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `leaderboard_type` enum('global','course','semester','department') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `course_id` bigint unsigned DEFAULT NULL,
  `semester_id` bigint unsigned DEFAULT NULL,
  `department_id` bigint unsigned DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `status` enum('active','archived') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'active',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`leaderboard_id`),
  KEY `department_id` (`department_id`),
  KEY `idx_type` (`leaderboard_type`),
  KEY `idx_course` (`course_id`),
  KEY `idx_semester` (`semester_id`),
  CONSTRAINT `leaderboards_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`) ON DELETE CASCADE,
  CONSTRAINT `leaderboards_ibfk_2` FOREIGN KEY (`semester_id`) REFERENCES `semesters` (`semester_id`) ON DELETE CASCADE,
  CONSTRAINT `leaderboards_ibfk_3` FOREIGN KEY (`department_id`) REFERENCES `departments` (`department_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `leaderboards`
--

LOCK TABLES `leaderboards` WRITE;
/*!40000 ALTER TABLE `leaderboards` DISABLE KEYS */;
/*!40000 ALTER TABLE `leaderboards` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `learning_analytics`
--

DROP TABLE IF EXISTS `learning_analytics`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `learning_analytics` (
  `analytics_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `course_id` bigint unsigned NOT NULL,
  `progress_id` bigint unsigned DEFAULT NULL,
  `metric_type` enum('engagement','performance','participation','time') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `metric_value` decimal(10,2) NOT NULL,
  `metric_date` date NOT NULL,
  `additional_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`analytics_id`),
  KEY `progress_id` (`progress_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_course` (`course_id`),
  KEY `idx_date` (`metric_date`),
  CONSTRAINT `learning_analytics_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `learning_analytics_ibfk_2` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`) ON DELETE CASCADE,
  CONSTRAINT `learning_analytics_ibfk_3` FOREIGN KEY (`progress_id`) REFERENCES `student_progress` (`progress_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `learning_analytics`
--

LOCK TABLES `learning_analytics` WRITE;
/*!40000 ALTER TABLE `learning_analytics` DISABLE KEYS */;
INSERT INTO `learning_analytics` VALUES (1,57,1,NULL,'engagement',72.50,'2026-03-11','{\"logins\": 15, \"views\": 45, \"submissions\": 8}','2026-03-11 18:12:04'),(2,57,1,NULL,'performance',78.50,'2026-03-11','{\"assignments_avg\": 80, \"quizzes_avg\": 75}','2026-03-11 18:12:04'),(3,57,2,NULL,'engagement',65.00,'2026-03-11','{\"logins\": 10, \"views\": 30, \"submissions\": 5}','2026-03-11 18:12:04'),(4,57,2,NULL,'participation',80.00,'2026-03-11','{\"discussions\": 12, \"comments\": 25}','2026-03-11 18:12:04'),(5,57,3,NULL,'time',560.00,'2026-03-11','{\"avg_session_minutes\": 45, \"total_sessions\": 12}','2026-03-11 18:12:04'),(6,57,3,NULL,'performance',91.25,'2026-03-11','{\"assignments_avg\": 92, \"quizzes_avg\": 90}','2026-03-11 18:12:04');
/*!40000 ALTER TABLE `learning_analytics` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lecture_sections_labs`
--

DROP TABLE IF EXISTS `lecture_sections_labs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lecture_sections_labs` (
  `organization_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `course_id` bigint unsigned NOT NULL,
  `material_id` bigint unsigned DEFAULT NULL,
  `organization_type` enum('lecture','section','lab','tutorial') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `week_number` int DEFAULT NULL,
  `order_index` int DEFAULT '0',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`organization_id`),
  KEY `material_id` (`material_id`),
  KEY `idx_course` (`course_id`),
  KEY `idx_type` (`organization_type`),
  CONSTRAINT `lecture_sections_labs_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`) ON DELETE CASCADE,
  CONSTRAINT `lecture_sections_labs_ibfk_2` FOREIGN KEY (`material_id`) REFERENCES `course_materials` (`material_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lecture_sections_labs`
--

LOCK TABLES `lecture_sections_labs` WRITE;
/*!40000 ALTER TABLE `lecture_sections_labs` DISABLE KEYS */;
INSERT INTO `lecture_sections_labs` VALUES (5,2,NULL,'lecture','Week 1: Arrays Introduction',1,1,'Introduction to arrays and lists','2025-11-20 13:43:01','2026-03-10 19:52:36'),(6,2,NULL,'lab','Week 2: Array Operations Lab',2,2,'Hands-on practice with arrays','2025-11-20 13:43:01','2026-03-10 19:52:36'),(7,1,NULL,'lecture','Week 1 Lecture: Introduction',1,0,'Course introduction and overview','2026-03-10 20:09:45','2026-03-16 22:31:25'),(8,1,NULL,'lab','Week 1 Lab: Setup',1,1,'Development environment setup','2026-03-10 20:09:46','2026-03-16 22:31:25'),(9,1,NULL,'lecture','Week 2 Lecture: Variables',2,2,'Variables and data types','2026-03-10 20:09:46','2026-03-16 22:31:25'),(10,1,NULL,'section','Week 2 Discussion: Best Practices',2,3,'Discussion on coding standards','2026-03-10 20:09:46','2026-03-16 22:31:25'),(11,1,NULL,'lecture','Week 3 Lecture: Control Flow',3,4,'If statements and loops','2026-03-10 20:09:46','2026-03-16 22:31:25'),(12,1,NULL,'tutorial','Week 3 Tutorial: Practice',3,5,'Guided practice session','2026-03-10 20:09:46','2026-03-16 22:31:25'),(15,1,NULL,'lecture','Week 10: API Dog Test',10,99,NULL,'2026-03-14 15:17:43','2026-03-14 15:17:43');
/*!40000 ALTER TABLE `lecture_sections_labs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `live_session_participants`
--

DROP TABLE IF EXISTS `live_session_participants`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `live_session_participants` (
  `participant_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `session_id` bigint unsigned NOT NULL,
  `user_id` bigint unsigned NOT NULL,
  `joined_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `left_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `participation_score` decimal(5,2) DEFAULT NULL,
  PRIMARY KEY (`participant_id`),
  UNIQUE KEY `unique_session_user` (`session_id`,`user_id`),
  KEY `idx_session` (`session_id`),
  KEY `idx_user` (`user_id`),
  CONSTRAINT `live_session_participants_ibfk_1` FOREIGN KEY (`session_id`) REFERENCES `live_sessions` (`session_id`) ON DELETE CASCADE,
  CONSTRAINT `live_session_participants_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `live_session_participants`
--

LOCK TABLES `live_session_participants` WRITE;
/*!40000 ALTER TABLE `live_session_participants` DISABLE KEYS */;
INSERT INTO `live_session_participants` VALUES (4,2,12,'2025-02-22 15:00:00','2025-02-22 16:00:00',92.00),(5,2,13,'2025-02-22 15:03:00','2025-02-22 15:45:00',75.00);
/*!40000 ALTER TABLE `live_session_participants` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `live_sessions`
--

DROP TABLE IF EXISTS `live_sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `live_sessions` (
  `session_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `course_id` bigint unsigned NOT NULL,
  `instructor_id` bigint unsigned NOT NULL,
  `session_title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `session_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `start_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `end_time` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `recording_file_id` bigint unsigned DEFAULT NULL,
  `participant_count` int DEFAULT '0',
  `status` enum('scheduled','live','ended','cancelled') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`session_id`),
  KEY `recording_file_id` (`recording_file_id`),
  KEY `idx_course` (`course_id`),
  KEY `idx_instructor` (`instructor_id`),
  KEY `idx_status` (`status`),
  CONSTRAINT `live_sessions_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`) ON DELETE CASCADE,
  CONSTRAINT `live_sessions_ibfk_2` FOREIGN KEY (`instructor_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `live_sessions_ibfk_3` FOREIGN KEY (`recording_file_id`) REFERENCES `files` (`file_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `live_sessions`
--

LOCK TABLES `live_sessions` WRITE;
/*!40000 ALTER TABLE `live_sessions` DISABLE KEYS */;
INSERT INTO `live_sessions` VALUES (2,2,3,'Data Structures Q&A','https://meet.campus.edu/cs201-qa-1','2025-02-22 15:00:00','2025-02-22 16:00:00',NULL,8,'ended','2025-11-20 13:43:00');
/*!40000 ALTER TABLE `live_sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `localization_strings`
--

DROP TABLE IF EXISTS `localization_strings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `localization_strings` (
  `string_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `language_code` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `string_key` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `string_value` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `context` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`string_id`),
  UNIQUE KEY `unique_lang_key` (`language_code`,`string_key`),
  KEY `idx_language` (`language_code`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `localization_strings`
--

LOCK TABLES `localization_strings` WRITE;
/*!40000 ALTER TABLE `localization_strings` DISABLE KEYS */;
INSERT INTO `localization_strings` VALUES (1,'en','dashboard.welcome','Welcome back','dashboard','2025-11-20 13:43:01','2025-11-20 13:43:01'),(2,'es','dashboard.welcome','Bienvenido de nuevo','dashboard','2025-11-20 13:43:01','2025-11-20 13:43:01'),(3,'fr','dashboard.welcome','Bon retour','dashboard','2025-11-20 13:43:01','2025-11-20 13:43:01'),(4,'en','course.assignments','Assignments','courses','2025-11-20 13:43:01','2025-11-20 13:43:01'),(5,'es','course.assignments','Tareas','courses','2025-11-20 13:43:01','2025-11-20 13:43:01'),(6,'fr','course.assignments','Devoirs','courses','2025-11-20 13:43:01','2025-11-20 13:43:01'),(7,'en','grade.submitted','Grade submitted successfully','grading','2025-11-20 13:43:01','2025-11-20 13:43:01'),(8,'es','grade.submitted','Calificaci??n enviada exitosamente','grading','2025-11-20 13:43:01','2025-11-20 13:43:01'),(9,'ar','dashboard.welcome','?????????? ????????????','dashboard','2025-11-20 13:43:01','2025-11-20 13:43:01'),(10,'ar','course.assignments','????????????????','courses','2025-11-20 13:43:01','2025-11-20 13:43:01');
/*!40000 ALTER TABLE `localization_strings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `login_attempts`
--

DROP TABLE IF EXISTS `login_attempts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `login_attempts` (
  `attempt_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned DEFAULT NULL,
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ip_address` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `attempt_status` enum('success','failed','blocked') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `failure_reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `attempted_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`attempt_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_email` (`email`),
  KEY `idx_ip` (`ip_address`),
  KEY `idx_date` (`attempted_at`),
  CONSTRAINT `login_attempts_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `login_attempts`
--

LOCK TABLES `login_attempts` WRITE;
/*!40000 ALTER TABLE `login_attempts` DISABLE KEYS */;
INSERT INTO `login_attempts` VALUES (1,7,'alice.student@campus.edu','192.168.1.100',NULL,'success',NULL,'2025-11-20 13:43:00'),(2,8,'bob.student@campus.edu','192.168.1.101',NULL,'success',NULL,'2025-11-20 13:43:00'),(3,NULL,'wrong@email.com','192.168.1.200',NULL,'failed','Invalid email','2025-11-20 13:43:00'),(4,9,'carol.student@campus.edu','192.168.1.102',NULL,'failed','Wrong password','2025-11-20 13:43:00'),(5,9,'carol.student@campus.edu','192.168.1.102',NULL,'success',NULL,'2025-11-20 13:43:00'),(6,NULL,'admin@campus.edu','203.0.113.45',NULL,'failed','Wrong password','2025-11-20 13:43:00'),(7,NULL,'admin@campus.edu','203.0.113.45',NULL,'blocked','Too many failed attempts','2025-11-20 13:43:00');
/*!40000 ALTER TABLE `login_attempts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `material_downloads`
--

DROP TABLE IF EXISTS `material_downloads`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `material_downloads` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `material_id` bigint unsigned NOT NULL,
  `user_id` bigint unsigned NOT NULL,
  `downloaded_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_material_downloads_material` (`material_id`),
  KEY `idx_material_downloads_user` (`user_id`),
  KEY `idx_material_downloads_time` (`downloaded_at`),
  CONSTRAINT `material_downloads_ibfk_1` FOREIGN KEY (`material_id`) REFERENCES `course_materials` (`material_id`) ON DELETE CASCADE,
  CONSTRAINT `material_downloads_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `material_downloads`
--

LOCK TABLES `material_downloads` WRITE;
/*!40000 ALTER TABLE `material_downloads` DISABLE KEYS */;
INSERT INTO `material_downloads` VALUES (1,16,7,'2026-02-27 20:09:46'),(2,21,7,'2026-03-10 20:09:46');
/*!40000 ALTER TABLE `material_downloads` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `material_views`
--

DROP TABLE IF EXISTS `material_views`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `material_views` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `material_id` bigint unsigned NOT NULL,
  `user_id` bigint unsigned NOT NULL,
  `viewed_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_material_views_material` (`material_id`),
  KEY `idx_material_views_user` (`user_id`),
  KEY `idx_material_views_time` (`viewed_at`),
  CONSTRAINT `material_views_ibfk_1` FOREIGN KEY (`material_id`) REFERENCES `course_materials` (`material_id`) ON DELETE CASCADE,
  CONSTRAINT `material_views_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `material_views`
--

LOCK TABLES `material_views` WRITE;
/*!40000 ALTER TABLE `material_views` DISABLE KEYS */;
INSERT INTO `material_views` VALUES (1,15,7,'2026-02-17 20:09:46'),(2,16,7,'2026-02-25 20:09:46'),(3,17,7,'2026-03-06 20:09:46'),(4,18,7,'2026-02-28 20:09:46'),(5,20,7,'2026-03-02 20:09:46');
/*!40000 ALTER TABLE `material_views` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `message_participants`
--

DROP TABLE IF EXISTS `message_participants`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `message_participants` (
  `participant_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `message_id` bigint unsigned NOT NULL,
  `user_id` bigint unsigned NOT NULL,
  `read_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`participant_id`),
  UNIQUE KEY `unique_message_user` (`message_id`,`user_id`),
  KEY `idx_message` (`message_id`),
  KEY `idx_user` (`user_id`),
  CONSTRAINT `message_participants_ibfk_1` FOREIGN KEY (`message_id`) REFERENCES `messages` (`message_id`) ON DELETE CASCADE,
  CONSTRAINT `message_participants_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=224 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `message_participants`
--

LOCK TABLES `message_participants` WRITE;
/*!40000 ALTER TABLE `message_participants` DISABLE KEYS */;
INSERT INTO `message_participants` VALUES (1,1,7,'2025-02-02 08:30:00',NULL),(2,1,8,'2025-02-02 09:15:00',NULL),(3,1,9,NULL,NULL),(4,2,2,'2025-02-03 12:20:00',NULL),(5,3,7,NULL,NULL),(6,3,8,NULL,NULL),(7,4,23,NULL,NULL),(8,4,8,'2025-02-04 11:00:00',NULL),(9,5,22,'2025-02-08 16:20:00',NULL),(10,5,8,NULL,NULL),(11,6,57,'2026-03-05 19:16:30',NULL),(12,6,58,'2026-03-15 23:11:07',NULL),(13,7,58,'2026-03-03 18:13:00',NULL),(14,7,57,'2026-03-03 18:18:38',NULL),(15,7,60,NULL,NULL),(16,8,58,'2026-03-03 18:16:50',NULL),(17,8,57,NULL,'2026-03-05 19:16:30'),(19,9,57,'2026-03-03 18:18:28','2026-03-03 18:18:39'),(20,9,58,NULL,NULL),(21,9,60,NULL,NULL),(22,10,57,'2026-03-03 18:18:53',NULL),(23,10,58,'2026-03-15 23:11:07',NULL),(24,11,57,'2026-03-03 18:20:17',NULL),(25,11,58,'2026-03-15 23:11:07',NULL),(26,12,59,'2026-03-03 18:23:55',NULL),(27,12,60,'2026-03-14 17:59:58',NULL),(28,13,59,'2026-03-03 18:23:56',NULL),(29,13,57,NULL,NULL),(30,13,58,NULL,NULL),(31,13,60,'2026-03-14 18:24:30',NULL),(32,14,60,'2026-03-03 18:23:59',NULL),(33,14,59,'2026-03-03 18:24:00',NULL),(34,15,59,'2026-03-03 18:24:01','2026-03-03 18:24:03'),(35,15,60,'2026-03-14 17:59:58',NULL),(36,16,59,'2026-03-03 18:24:02',NULL),(37,16,60,'2026-03-14 17:59:58',NULL),(38,17,57,'2026-03-03 18:34:10',NULL),(39,17,58,'2026-03-15 23:11:07',NULL),(40,18,58,'2026-03-03 18:34:10',NULL),(41,18,57,NULL,NULL),(42,18,60,NULL,NULL),(43,19,58,'2026-03-03 18:34:10',NULL),(44,19,57,NULL,NULL),(45,20,57,'2026-03-03 18:34:10',NULL),(46,20,58,'2026-03-15 23:11:07',NULL),(47,21,57,'2026-03-05 19:16:29',NULL),(48,21,58,'2026-03-15 23:11:07',NULL),(49,22,58,'2026-03-05 19:16:29',NULL),(50,22,57,NULL,NULL),(51,22,60,'2026-03-14 18:14:59',NULL),(52,23,58,'2026-03-05 19:16:30',NULL),(53,23,57,NULL,NULL),(54,24,57,'2026-03-05 19:16:30',NULL),(55,24,58,'2026-03-15 23:11:07',NULL),(56,25,57,'2026-03-10 14:21:19',NULL),(57,25,58,NULL,NULL),(58,26,58,'2026-03-10 14:21:23',NULL),(59,26,57,NULL,NULL),(60,27,57,'2026-03-10 14:21:40',NULL),(61,27,58,NULL,NULL),(62,28,58,'2026-03-10 14:21:45',NULL),(63,28,57,NULL,NULL),(64,29,57,'2026-03-10 14:21:57',NULL),(65,29,58,NULL,NULL),(66,30,58,'2026-03-10 14:22:21',NULL),(67,30,57,NULL,NULL),(68,31,57,'2026-03-10 14:22:27','2026-03-10 14:22:33'),(69,31,58,NULL,NULL),(70,32,58,'2026-03-10 14:23:00',NULL),(71,32,57,NULL,NULL),(72,33,58,'2026-03-10 14:23:37',NULL),(73,33,57,NULL,NULL),(74,34,57,'2026-03-10 14:23:43',NULL),(75,34,58,NULL,NULL),(76,35,57,'2026-03-10 14:24:55',NULL),(77,35,58,NULL,NULL),(78,36,58,'2026-03-10 14:24:58',NULL),(79,36,57,NULL,NULL),(80,37,57,'2026-03-10 14:25:06',NULL),(81,37,58,NULL,NULL),(82,38,57,'2026-03-10 14:25:16','2026-03-10 14:25:20'),(83,38,58,NULL,NULL),(84,39,57,'2026-03-10 14:25:44',NULL),(85,39,58,NULL,NULL),(86,40,57,'2026-03-10 14:25:54',NULL),(87,40,58,NULL,NULL),(88,41,57,'2026-03-10 14:26:19',NULL),(89,41,58,NULL,NULL),(90,42,57,'2026-03-10 14:34:11',NULL),(91,42,58,NULL,NULL),(92,43,58,'2026-03-10 14:34:15',NULL),(93,43,57,NULL,NULL),(94,44,58,'2026-03-10 14:34:25',NULL),(95,44,57,NULL,NULL),(96,45,57,'2026-03-10 14:34:37',NULL),(97,45,58,NULL,NULL),(98,46,57,'2026-03-10 14:34:58',NULL),(99,46,58,NULL,NULL),(100,47,58,'2026-03-10 14:35:08',NULL),(101,47,57,NULL,NULL),(102,48,58,'2026-03-10 14:35:16',NULL),(103,48,57,NULL,NULL),(104,49,57,'2026-03-10 14:37:42',NULL),(105,49,58,NULL,NULL),(106,50,57,'2026-03-10 14:37:57',NULL),(107,50,58,NULL,NULL),(108,51,58,'2026-03-10 14:38:00',NULL),(109,51,57,NULL,NULL),(110,52,57,'2026-03-10 14:38:04',NULL),(111,52,58,NULL,NULL),(112,53,58,'2026-03-10 14:38:09',NULL),(113,53,57,NULL,NULL),(114,54,57,'2026-03-10 14:38:17',NULL),(115,54,58,NULL,NULL),(116,55,57,'2026-03-10 14:38:22',NULL),(117,55,58,NULL,NULL),(118,56,57,'2026-03-10 14:38:47','2026-03-10 14:38:51'),(119,56,58,NULL,NULL),(120,57,57,'2026-03-10 14:56:31',NULL),(121,57,58,'2026-03-15 23:11:07',NULL),(122,58,57,'2026-03-10 14:56:46',NULL),(123,58,58,'2026-03-15 23:11:07',NULL),(124,59,58,'2026-03-10 14:56:52',NULL),(125,59,57,NULL,NULL),(126,60,57,'2026-03-10 14:59:44',NULL),(127,60,58,'2026-03-15 23:11:07',NULL),(128,61,58,'2026-03-10 14:59:53',NULL),(129,61,57,NULL,NULL),(130,62,57,'2026-03-10 15:37:30',NULL),(131,62,58,'2026-03-15 23:11:07',NULL),(132,63,57,'2026-03-10 15:37:34',NULL),(133,63,58,'2026-03-15 23:11:07',NULL),(134,64,58,'2026-03-10 15:37:40',NULL),(135,64,57,NULL,NULL),(136,65,58,'2026-03-10 15:37:58',NULL),(137,65,57,NULL,NULL),(138,66,57,'2026-03-10 15:38:17',NULL),(139,66,58,'2026-03-15 23:11:07',NULL),(140,67,58,'2026-03-10 15:38:20',NULL),(141,67,57,NULL,NULL),(142,68,58,'2026-03-10 15:38:57',NULL),(143,68,57,NULL,NULL),(144,69,57,'2026-03-10 15:39:01',NULL),(145,69,58,'2026-03-15 23:11:07',NULL),(146,70,58,'2026-03-10 15:39:04',NULL),(147,70,57,NULL,NULL),(148,71,57,'2026-03-10 15:39:22',NULL),(149,71,58,'2026-03-15 23:11:07',NULL),(150,72,58,'2026-03-10 15:39:25',NULL),(151,72,57,NULL,NULL),(152,73,58,'2026-03-10 15:39:30',NULL),(153,73,57,NULL,NULL),(154,74,57,'2026-03-10 15:39:39',NULL),(155,74,58,'2026-03-15 23:11:07',NULL),(156,75,58,'2026-03-10 15:39:53',NULL),(157,75,57,NULL,NULL),(158,76,58,'2026-03-10 15:39:55',NULL),(159,76,57,NULL,NULL),(160,77,58,'2026-03-10 15:40:12','2026-03-10 15:40:18'),(161,77,57,NULL,NULL),(162,78,57,'2026-03-11 17:37:57',NULL),(163,78,59,'2026-03-14 18:31:12',NULL),(164,79,57,'2026-03-14 15:17:53',NULL),(165,79,59,'2026-03-14 18:31:12',NULL),(166,80,57,'2026-03-14 15:36:10',NULL),(167,80,59,'2026-03-14 18:31:12',NULL),(168,81,57,'2026-03-14 15:40:50',NULL),(169,81,59,'2026-03-14 18:31:12',NULL),(170,82,57,'2026-03-14 16:00:20',NULL),(171,82,58,'2026-03-15 23:11:07',NULL),(172,83,57,'2026-03-14 16:00:26',NULL),(173,83,58,'2026-03-15 23:11:07',NULL),(174,84,58,'2026-03-14 16:00:31',NULL),(175,84,57,NULL,NULL),(176,85,57,'2026-03-14 16:00:34',NULL),(177,85,58,'2026-03-15 23:11:07',NULL),(178,86,58,'2026-03-14 16:00:41',NULL),(179,86,57,NULL,NULL),(180,87,57,'2026-03-14 16:06:12',NULL),(181,87,59,'2026-03-14 18:31:12',NULL),(182,88,59,'2026-03-14 17:45:59',NULL),(183,88,57,NULL,NULL),(184,89,59,'2026-03-14 17:46:20',NULL),(185,89,57,NULL,NULL),(186,90,60,'2026-03-14 17:47:20',NULL),(187,90,59,'2026-03-14 17:59:09',NULL),(188,91,59,'2026-03-14 17:59:09',NULL),(189,91,60,'2026-03-14 17:59:58',NULL),(190,92,60,'2026-03-14 18:00:03',NULL),(191,92,59,'2026-03-14 18:07:02',NULL),(192,93,60,'2026-03-14 18:00:09',NULL),(193,93,59,'2026-03-14 18:07:02',NULL),(194,94,59,'2026-03-14 18:00:12',NULL),(195,94,60,'2026-03-14 18:14:18',NULL),(196,95,60,'2026-03-14 18:14:57',NULL),(197,95,59,'2026-03-14 18:27:19',NULL),(198,96,60,'2026-03-14 18:23:55',NULL),(199,96,59,'2026-03-14 18:27:19',NULL),(200,97,60,'2026-03-14 18:24:18',NULL),(201,97,59,'2026-03-14 18:27:19',NULL),(202,98,59,'2026-03-14 18:30:20',NULL),(203,98,60,'2026-03-14 18:30:26',NULL),(204,99,60,'2026-03-14 18:30:31',NULL),(205,99,59,'2026-03-15 15:48:30',NULL),(206,100,60,'2026-03-14 18:30:34',NULL),(207,100,59,'2026-03-15 15:48:30',NULL),(208,101,59,'2026-03-14 18:30:48',NULL),(209,101,60,NULL,NULL),(210,102,59,'2026-03-14 18:30:58',NULL),(211,102,60,NULL,NULL),(212,103,57,'2026-03-16 20:19:11',NULL),(213,103,59,NULL,NULL),(214,104,57,'2026-03-16 20:20:16',NULL),(215,104,59,NULL,NULL),(216,105,57,'2026-03-16 20:32:58',NULL),(217,105,59,NULL,NULL),(218,106,57,'2026-03-16 20:45:24',NULL),(219,106,59,NULL,NULL),(220,107,57,'2026-03-16 20:53:59',NULL),(221,107,59,NULL,NULL),(222,108,57,'2026-03-16 22:31:36',NULL),(223,108,59,NULL,NULL);
/*!40000 ALTER TABLE `message_participants` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `messages`
--

DROP TABLE IF EXISTS `messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `messages` (
  `message_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `sender_id` bigint unsigned NOT NULL,
  `subject` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `body` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `message_type` enum('direct','group','announcement') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'direct',
  `parent_message_id` bigint unsigned DEFAULT NULL,
  `reply_to_id` bigint unsigned DEFAULT NULL,
  `read_status` tinyint(1) DEFAULT '0',
  `sent_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `edited_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`message_id`),
  KEY `parent_message_id` (`parent_message_id`),
  KEY `idx_sender` (`sender_id`),
  KEY `idx_sent` (`sent_at`),
  KEY `idx_sender_type` (`sender_id`,`message_type`),
  KEY `idx_sent_read` (`sent_at`,`read_status`),
  KEY `fk_messages_reply_to` (`reply_to_id`),
  CONSTRAINT `fk_messages_reply_to` FOREIGN KEY (`reply_to_id`) REFERENCES `messages` (`message_id`) ON DELETE SET NULL,
  CONSTRAINT `messages_ibfk_1` FOREIGN KEY (`sender_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `messages_ibfk_2` FOREIGN KEY (`parent_message_id`) REFERENCES `messages` (`message_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=109 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `messages`
--

LOCK TABLES `messages` WRITE;
/*!40000 ALTER TABLE `messages` DISABLE KEYS */;
INSERT INTO `messages` VALUES (1,2,'Welcome to CS101','Welcome to Introduction to Programming! I look forward to working with you this semester.','announcement',NULL,NULL,0,'2025-11-20 13:43:00',NULL),(2,7,'Question about Assignment 1','Professor Smith, I have a question about the first assignment. Can we use external libraries?','direct',NULL,NULL,1,'2025-11-20 13:43:00',NULL),(3,2,'RE: Question about Assignment 1','For this assignment, please use only built-in Python functions.','direct',NULL,NULL,0,'2025-11-20 13:43:00',NULL),(4,3,'CS201 Project Groups','Please form groups of 3-4 students for the final project.','announcement',NULL,NULL,0,'2025-11-20 13:43:00',NULL),(5,22,'Grade Discussion','I would like to discuss my quiz score from last week.','direct',NULL,NULL,0,'2025-02-08 16:20:00',NULL),(6,57,NULL,'Hey instructor, I have a question about Assignment 1.','direct',NULL,NULL,0,'2026-03-03 18:12:53',NULL),(7,58,'CS101 Study Group','Welcome to the CS101 Study Group!','group',NULL,NULL,0,'2026-03-03 18:13:00',NULL),(8,58,NULL,'Sure, what is your question about Assignment 1?','direct',6,NULL,0,'2026-03-03 18:16:50',NULL),(9,57,NULL,'__DELETED__','direct',7,NULL,0,'2026-03-03 18:18:28',NULL),(10,57,NULL,'This message will be deleted for everyone','direct',6,NULL,0,'2026-03-03 18:18:53',NULL),(11,57,NULL,'__DELETED__','direct',6,NULL,0,'2026-03-03 18:20:17',NULL),(12,59,NULL,'Hi TA, please check lab grades.','direct',NULL,NULL,0,'2026-03-03 18:23:55',NULL),(13,59,'Staff Meeting Room','Staff meeting discussion','group',NULL,NULL,0,'2026-03-03 18:23:56',NULL),(14,60,NULL,'Sure, I will check them right away.','direct',12,NULL,0,'2026-03-03 18:23:59',NULL),(15,59,NULL,'Temporary message for deletion test','direct',12,NULL,0,'2026-03-03 18:24:01',NULL),(16,59,NULL,'__DELETED__','direct',12,NULL,0,'2026-03-03 18:24:02',NULL),(17,57,NULL,'Hi professor, I have a question about the midterm format.','direct',6,NULL,0,'2026-03-03 18:34:10',NULL),(18,58,'CS201 Project Team','Welcome to our project discussion group!','group',NULL,NULL,0,'2026-03-03 18:34:10',NULL),(19,58,NULL,'The midterm will be multiple choice and short answer. Focus on chapters 3-8.','direct',6,NULL,0,'2026-03-03 18:34:10',NULL),(20,57,'{\"fileId\":1}','Here is my draft for review','direct',6,NULL,0,'2026-03-03 18:34:10',NULL),(21,57,NULL,'Hi professor, I have a question about the midterm format.','direct',6,NULL,0,'2026-03-05 19:16:29',NULL),(22,58,'CS201 Project Team','Welcome to our project discussion group!','group',NULL,NULL,0,'2026-03-05 19:16:29',NULL),(23,58,NULL,'The midterm will be multiple choice and short answer. Focus on chapters 3-8.','direct',6,NULL,0,'2026-03-05 19:16:30',NULL),(24,57,'{\"fileId\":1}','Here is my draft for review','direct',6,NULL,0,'2026-03-05 19:16:30',NULL),(25,57,NULL,'Hello','direct',21,NULL,0,'2026-03-10 14:21:19',NULL),(26,58,NULL,'Hi','direct',21,NULL,0,'2026-03-10 14:21:23',NULL),(27,57,NULL,'Why it is sent 2 times for me ?','direct',21,NULL,0,'2026-03-10 14:21:40',NULL),(28,58,NULL,'Me too idk','direct',21,NULL,0,'2026-03-10 14:21:45',NULL),(29,57,NULL,'__DELETED__','direct',21,NULL,0,'2026-03-10 14:21:57',NULL),(30,58,NULL,'Oh it is deleted succeffully','direct',21,NULL,0,'2026-03-10 14:22:21',NULL),(31,57,NULL,'IK wow','direct',21,NULL,0,'2026-03-10 14:22:27',NULL),(32,58,NULL,'Helelo','direct',21,NULL,0,'2026-03-10 14:23:00',NULL),(33,58,'{\"fileId\":2}','How to replay thoo','direct',21,NULL,0,'2026-03-10 14:23:37',NULL),(34,57,NULL,'Idk','direct',21,NULL,0,'2026-03-10 14:23:43',NULL),(35,57,NULL,'Hello','direct',21,NULL,0,'2026-03-10 14:24:55',NULL),(36,58,NULL,'Hi','direct',21,NULL,0,'2026-03-10 14:24:58',NULL),(37,57,NULL,'__DELETED__','direct',21,NULL,0,'2026-03-10 14:25:06',NULL),(38,57,NULL,'Delete for me','direct',21,NULL,0,'2026-03-10 14:25:16',NULL),(39,57,NULL,'How to replay','direct',21,NULL,0,'2026-03-10 14:25:44',NULL),(40,57,NULL,'12','direct',21,NULL,0,'2026-03-10 14:25:54',NULL),(41,57,NULL,'How to know if itis readed or not','direct',21,NULL,0,'2026-03-10 14:26:19',NULL),(42,57,NULL,'اهلا','direct',21,NULL,0,'2026-03-10 14:34:11',NULL),(43,58,NULL,'هلا','direct',21,NULL,0,'2026-03-10 14:34:15',NULL),(44,58,NULL,'ريبلاي','direct',21,NULL,0,'2026-03-10 14:34:25',NULL),(45,57,NULL,'طب ليه مش بل=ايت','direct',21,NULL,0,'2026-03-10 14:34:37',NULL),(46,57,NULL,'Replay to this','direct',21,NULL,0,'2026-03-10 14:34:58',NULL),(47,58,NULL,'Replayed','direct',21,NULL,0,'2026-03-10 14:35:08',NULL),(48,58,NULL,'why not showing that i replayed ?','direct',21,NULL,0,'2026-03-10 14:35:16',NULL),(49,57,NULL,'Hi','direct',21,NULL,0,'2026-03-10 14:37:42',NULL),(50,57,NULL,'Hi','direct',21,NULL,0,'2026-03-10 14:37:57',NULL),(51,58,NULL,'Hello','direct',21,NULL,0,'2026-03-10 14:38:00',NULL),(52,57,NULL,'Replay to me','direct',21,NULL,0,'2026-03-10 14:38:04',NULL),(53,58,NULL,'Replayed','direct',21,NULL,0,'2026-03-10 14:38:09',NULL),(54,57,NULL,'Still not visulaized','direct',21,NULL,0,'2026-03-10 14:38:17',NULL),(55,57,NULL,'__DELETED__','direct',21,NULL,0,'2026-03-10 14:38:22',NULL),(56,57,NULL,'DELETE FOR ME ONLY','direct',21,NULL,0,'2026-03-10 14:38:47',NULL),(57,57,NULL,'hellp','direct',6,NULL,0,'2026-03-10 14:56:31',NULL),(58,57,NULL,'Hello','direct',6,NULL,0,'2026-03-10 14:56:46',NULL),(59,58,NULL,'Hi','direct',6,NULL,0,'2026-03-10 14:56:52',NULL),(60,57,NULL,'لا','direct',6,NULL,0,'2026-03-10 14:59:44',NULL),(61,58,NULL,'طب ما كدا فرونت اند بس','direct',6,NULL,0,'2026-03-10 14:59:53',NULL),(62,57,NULL,'Hi','direct',6,NULL,0,'2026-03-10 15:37:30',NULL),(63,57,NULL,'__DELETED__','direct',6,NULL,0,'2026-03-10 15:37:34',NULL),(64,58,NULL,'Hello Tarek','direct',6,NULL,0,'2026-03-10 15:37:40',NULL),(65,58,NULL,'GN','direct',6,NULL,0,'2026-03-10 15:37:58',NULL),(66,57,NULL,'__DELETED__','direct',6,NULL,0,'2026-03-10 15:38:17',NULL),(67,58,NULL,'WRW','direct',6,NULL,0,'2026-03-10 15:38:20',NULL),(68,58,NULL,'GA','direct',6,NULL,0,'2026-03-10 15:38:57',NULL),(69,57,NULL,'??','direct',6,68,0,'2026-03-10 15:39:01',NULL),(70,58,NULL,'??','direct',6,69,0,'2026-03-10 15:39:04',NULL),(71,57,NULL,'Gn','direct',6,NULL,0,'2026-03-10 15:39:22',NULL),(72,58,NULL,'GN','direct',6,NULL,0,'2026-03-10 15:39:25',NULL),(73,58,NULL,'REPLAY TO ME','direct',6,NULL,0,'2026-03-10 15:39:30',NULL),(74,57,NULL,'Replaying','direct',6,73,0,'2026-03-10 15:39:39',NULL),(75,58,NULL,'Delete the message after me for all','direct',6,NULL,0,'2026-03-10 15:39:53',NULL),(76,58,NULL,'__DELETED__','direct',6,NULL,0,'2026-03-10 15:39:55',NULL),(77,58,NULL,'Delete the message for only me','direct',6,NULL,0,'2026-03-10 15:40:12',NULL),(78,57,NULL,'Hello from API Dog test!','direct',NULL,NULL,0,'2026-03-11 17:37:56',NULL),(79,57,NULL,'Hello from API Dog test!','direct',78,NULL,0,'2026-03-14 15:17:52',NULL),(80,57,NULL,'Hello from API Dog test!','direct',78,NULL,0,'2026-03-14 15:36:09',NULL),(81,57,NULL,'Hello from API Dog test!','direct',78,NULL,0,'2026-03-14 15:40:49',NULL),(82,57,NULL,'Hello!','direct',6,NULL,0,'2026-03-14 16:00:19',NULL),(83,57,NULL,'HELLO','direct',6,NULL,0,'2026-03-14 16:00:25',NULL),(84,58,NULL,'HELLO','direct',6,NULL,0,'2026-03-14 16:00:30',NULL),(85,57,NULL,'<3','direct',6,NULL,0,'2026-03-14 16:00:34',NULL),(86,58,NULL,'_||__','direct',6,NULL,0,'2026-03-14 16:00:40',NULL),(87,57,NULL,'Hello from API Dog test!','direct',78,NULL,0,'2026-03-14 16:06:12',NULL),(88,59,NULL,'Hello!','direct',78,NULL,0,'2026-03-14 17:45:59',NULL),(89,59,NULL,'Hello!','direct',78,NULL,0,'2026-03-14 17:46:19',NULL),(90,60,NULL,'Hello!','direct',12,NULL,0,'2026-03-14 17:47:20',NULL),(91,59,NULL,'Hello!','direct',12,NULL,0,'2026-03-14 17:59:08',NULL),(92,60,NULL,'eh','direct',12,NULL,0,'2026-03-14 18:00:03',NULL),(93,60,NULL,'sure','direct',12,NULL,0,'2026-03-14 18:00:08',NULL),(94,59,NULL,'why not','direct',12,NULL,0,'2026-03-14 18:00:11',NULL),(95,60,NULL,'?','direct',12,NULL,0,'2026-03-14 18:14:57',NULL),(96,60,NULL,'اخيرا','direct',12,NULL,0,'2026-03-14 18:23:55',NULL),(97,60,NULL,'حصل','direct',12,NULL,0,'2026-03-14 18:24:17',NULL),(98,59,NULL,'ايه الكلام','direct',12,97,0,'2026-03-14 18:30:20',NULL),(99,60,NULL,'ايه يا قلبي','direct',12,NULL,0,'2026-03-14 18:30:30',NULL),(100,60,NULL,'__DELETED__','direct',12,NULL,0,'2026-03-14 18:30:33',NULL),(101,59,NULL,'طب دي','direct',12,NULL,0,'2026-03-14 18:30:47',NULL),(102,59,NULL,'دي','direct',12,NULL,0,'2026-03-14 18:30:57',NULL),(103,57,NULL,'Hello from API Dog test!','direct',78,NULL,0,'2026-03-16 20:19:10',NULL),(104,57,NULL,'Hello from API Dog test!','direct',78,NULL,0,'2026-03-16 20:20:16',NULL),(105,57,NULL,'Hello from API Dog test!','direct',78,NULL,0,'2026-03-16 20:32:57',NULL),(106,57,NULL,'Hello from API Dog test!','direct',78,NULL,0,'2026-03-16 20:45:23',NULL),(107,57,NULL,'Hello from API Dog test!','direct',78,NULL,0,'2026-03-16 20:53:59',NULL),(108,57,NULL,'Hello from API Dog test!','direct',78,NULL,0,'2026-03-16 22:31:35',NULL);
/*!40000 ALTER TABLE `messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `milestone_definitions`
--

DROP TABLE IF EXISTS `milestone_definitions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `milestone_definitions` (
  `milestone_id` int unsigned NOT NULL AUTO_INCREMENT,
  `badge_id` int unsigned NOT NULL,
  `milestone_type` enum('xp','level','course_completion','grade','streak') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `threshold_value` int NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`milestone_id`),
  KEY `idx_badge` (`badge_id`),
  CONSTRAINT `milestone_definitions_ibfk_1` FOREIGN KEY (`badge_id`) REFERENCES `badges` (`badge_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `milestone_definitions`
--

LOCK TABLES `milestone_definitions` WRITE;
/*!40000 ALTER TABLE `milestone_definitions` DISABLE KEYS */;
INSERT INTO `milestone_definitions` VALUES (1,6,'level',5,'Reach level 5'),(2,3,'streak',7,'Maintain 7-day learning streak'),(3,2,'grade',100,'Score 100% on any assessment'),(4,7,'grade',95,'Maintain 95% average across all courses'),(5,8,'streak',30,'Maintain 30-day consistent learning streak');
/*!40000 ALTER TABLE `milestone_definitions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notification_preferences`
--

DROP TABLE IF EXISTS `notification_preferences`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notification_preferences` (
  `preference_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `email_enabled` tinyint(1) DEFAULT '1',
  `push_enabled` tinyint(1) DEFAULT '1',
  `sms_enabled` tinyint(1) DEFAULT '0',
  `announcement_email` tinyint(1) DEFAULT '1',
  `grade_email` tinyint(1) DEFAULT '1',
  `assignment_email` tinyint(1) DEFAULT '1',
  `message_email` tinyint(1) DEFAULT '1',
  `deadline_reminder_days` int DEFAULT '2',
  `quiet_hours_start` time DEFAULT NULL,
  `quiet_hours_end` time DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`preference_id`),
  UNIQUE KEY `user_id` (`user_id`),
  CONSTRAINT `notification_preferences_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notification_preferences`
--

LOCK TABLES `notification_preferences` WRITE;
/*!40000 ALTER TABLE `notification_preferences` DISABLE KEYS */;
INSERT INTO `notification_preferences` VALUES (1,7,1,1,0,1,1,1,1,2,'22:00:00','07:00:00','2025-11-20 13:43:00','2025-11-20 13:43:00'),(2,8,1,0,0,1,1,0,1,3,'23:00:00','08:00:00','2025-11-20 13:43:00','2025-11-20 13:43:00'),(3,9,0,1,0,0,1,1,0,1,'21:00:00','06:00:00','2025-11-20 13:43:00','2025-11-20 13:43:00'),(4,10,1,1,0,1,0,1,1,2,'22:00:00','07:00:00','2025-11-20 13:43:00','2025-11-20 13:43:00'),(5,11,1,1,1,1,1,1,1,5,'23:00:00','09:00:00','2025-11-20 13:43:00','2025-11-20 13:43:00'),(6,12,1,0,0,1,1,0,0,2,'22:00:00','07:00:00','2025-11-20 13:43:00','2025-11-20 13:43:00'),(7,57,1,1,0,1,1,1,0,3,NULL,NULL,'2026-03-03 00:10:14','2026-03-16 22:31:35');
/*!40000 ALTER TABLE `notification_preferences` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notifications` (
  `notification_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `notification_type` enum('announcement','grade','assignment','message','deadline','system') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `body` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `related_entity_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `related_entity_id` bigint unsigned DEFAULT NULL,
  `announcement_id` bigint unsigned DEFAULT NULL,
  `is_read` tinyint(1) DEFAULT '0',
  `read_at` timestamp NULL DEFAULT NULL,
  `priority` enum('low','medium','high','urgent') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'medium',
  `action_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`notification_id`),
  KEY `announcement_id` (`announcement_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_read` (`is_read`),
  KEY `idx_type` (`notification_type`),
  KEY `idx_user_read_type` (`user_id`,`is_read`,`notification_type`),
  KEY `idx_user_date` (`user_id`,`created_at`),
  CONSTRAINT `notifications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `notifications_ibfk_2` FOREIGN KEY (`announcement_id`) REFERENCES `announcements` (`announcement_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=38 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifications`
--

LOCK TABLES `notifications` WRITE;
/*!40000 ALTER TABLE `notifications` DISABLE KEYS */;
INSERT INTO `notifications` VALUES (1,21,'','Assignment Due Soon','Assignment 1: Programming Basics is due tomorrow.','assignment',1,NULL,0,NULL,'medium',NULL,'2025-01-31 08:00:00'),(2,7,'assignment','New Assignment Posted','Assignment 1 is now available',NULL,NULL,NULL,1,NULL,'medium',NULL,'2025-02-01 08:00:00'),(3,7,'grade','Grade Posted','Your grade for Assignment 1 has been posted',NULL,NULL,NULL,0,NULL,'medium',NULL,'2025-02-16 08:00:00'),(4,21,'announcement','New Announcement','Dr. Ibrahim Ali posted a new announcement in CS101.','announcement',1,NULL,1,NULL,'medium',NULL,'2025-01-20 09:05:00'),(5,8,'grade','Grade Posted','Your grade for Assignment 1 has been posted',NULL,NULL,NULL,1,NULL,'medium',NULL,'2025-02-16 08:15:00'),(6,9,'deadline','Assignment Due Soon','Assignment 1 due in 2 days',NULL,NULL,NULL,0,NULL,'high',NULL,'2025-02-13 07:00:00'),(7,21,'message','Message Received','Dr. Ibrahim Ali replied to your message about Assignment 1.','message',2,NULL,1,NULL,'medium',NULL,'2025-01-28 15:50:00'),(8,22,'grade','Grade Posted','Your grade for Quiz 1 has been posted.','quiz',1,NULL,0,NULL,'medium',NULL,'2025-02-03 11:00:00'),(10,58,'announcement','Test Notification','This is a test notification from admin',NULL,NULL,NULL,0,NULL,'high',NULL,'2026-03-03 00:10:09'),(14,58,'announcement','Important Announcement','All students must submit assignments by Friday',NULL,NULL,NULL,0,NULL,'high','/assignments','2026-03-03 00:23:24'),(16,58,'announcement','Important Announcement','All students must submit assignments by Friday',NULL,NULL,NULL,0,NULL,'high','/assignments','2026-03-03 18:34:09'),(22,58,'announcement','Important Announcement','All students must submit assignments by Friday',NULL,NULL,NULL,0,NULL,'high','/assignments','2026-03-05 19:16:29'),(23,57,'grade','New Grade Posted','Your grade for Assignment 1 in CS101 has been posted.',NULL,NULL,NULL,1,'2026-03-11 17:20:11','medium',NULL,'2026-03-11 16:43:26'),(24,57,'announcement','New Announcement','Check the latest announcement in CS101.',NULL,NULL,NULL,1,'2026-03-11 17:20:11','high',NULL,'2026-03-11 16:43:26'),(25,57,'assignment','Assignment Due Soon','Assignment 2 in CS101 is due tomorrow.',NULL,NULL,NULL,1,NULL,'high',NULL,'2026-03-11 16:43:26'),(26,57,'system','System Update','EduVerse has been updated with new features.',NULL,NULL,NULL,1,NULL,'low',NULL,'2026-03-11 16:43:26'),(27,57,'system','Test from API Dog','This is a test notification.',NULL,NULL,NULL,1,'2026-03-14 15:17:52','medium',NULL,'2026-03-11 17:37:56'),(28,57,'system','Test from API Dog','This is a test notification.',NULL,NULL,NULL,1,'2026-03-14 15:36:10','medium',NULL,'2026-03-14 15:17:52'),(29,57,'system','Test from API Dog','This is a test notification.',NULL,NULL,NULL,1,'2026-03-14 15:40:49','medium',NULL,'2026-03-14 15:36:09'),(30,57,'system','Test from API Dog','This is a test notification.',NULL,NULL,NULL,1,'2026-03-14 16:06:12','medium',NULL,'2026-03-14 15:40:49'),(31,57,'system','Test from API Dog','This is a test notification.',NULL,NULL,NULL,1,'2026-03-16 20:19:10','medium',NULL,'2026-03-14 16:06:11'),(32,57,'system','Test from API Dog','This is a test notification.',NULL,NULL,NULL,1,'2026-03-16 20:20:16','medium',NULL,'2026-03-16 20:19:10'),(33,57,'system','Test from API Dog','This is a test notification.',NULL,NULL,NULL,1,'2026-03-16 20:32:57','medium',NULL,'2026-03-16 20:20:15'),(34,57,'system','Test from API Dog','This is a test notification.',NULL,NULL,NULL,1,'2026-03-16 20:45:23','medium',NULL,'2026-03-16 20:32:57'),(35,57,'system','Test from API Dog','This is a test notification.',NULL,NULL,NULL,1,'2026-03-16 20:53:59','medium',NULL,'2026-03-16 20:45:23'),(36,57,'system','Test from API Dog','This is a test notification.',NULL,NULL,NULL,1,'2026-03-16 22:31:35','medium',NULL,'2026-03-16 20:53:59'),(37,57,'system','Test from API Dog','This is a test notification.',NULL,NULL,NULL,0,NULL,'medium',NULL,'2026-03-16 22:31:35');
/*!40000 ALTER TABLE `notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `office_hour_appointments`
--

DROP TABLE IF EXISTS `office_hour_appointments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `office_hour_appointments` (
  `appointment_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `slot_id` bigint unsigned NOT NULL,
  `student_id` bigint unsigned NOT NULL,
  `appointment_date` date NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  `topic` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `status` enum('booked','confirmed','cancelled','completed','no_show') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'booked',
  `cancelled_by` bigint unsigned DEFAULT NULL,
  `cancelled_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`appointment_id`),
  KEY `fk_appointment_slot` (`slot_id`),
  KEY `fk_appointment_student` (`student_id`),
  CONSTRAINT `fk_appointment_slot` FOREIGN KEY (`slot_id`) REFERENCES `office_hour_slots` (`slot_id`),
  CONSTRAINT `fk_appointment_student` FOREIGN KEY (`student_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `office_hour_appointments`
--

LOCK TABLES `office_hour_appointments` WRITE;
/*!40000 ALTER TABLE `office_hour_appointments` DISABLE KEYS */;
/*!40000 ALTER TABLE `office_hour_appointments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `office_hour_slots`
--

DROP TABLE IF EXISTS `office_hour_slots`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `office_hour_slots` (
  `slot_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `instructor_id` bigint unsigned NOT NULL,
  `day_of_week` enum('monday','tuesday','wednesday','thursday','friday','saturday','sunday') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  `location` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `mode` enum('in_person','online','hybrid') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'in_person',
  `meeting_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `max_appointments` int DEFAULT '4',
  `is_recurring` tinyint(1) DEFAULT '1',
  `effective_from` date DEFAULT NULL,
  `effective_until` date DEFAULT NULL,
  `status` enum('active','cancelled','suspended') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'active',
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`slot_id`),
  KEY `fk_office_hours_instructor` (`instructor_id`),
  CONSTRAINT `fk_office_hours_instructor` FOREIGN KEY (`instructor_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `office_hour_slots`
--

LOCK TABLES `office_hour_slots` WRITE;
/*!40000 ALTER TABLE `office_hour_slots` DISABLE KEYS */;
/*!40000 ALTER TABLE `office_hour_slots` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `offline_sync_queue`
--

DROP TABLE IF EXISTS `offline_sync_queue`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `offline_sync_queue` (
  `sync_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `entity_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `entity_id` bigint unsigned DEFAULT NULL,
  `action` enum('create','update','delete') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `data_snapshot` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `sync_status` enum('pending','synced','failed','conflict') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  `attempt_count` int DEFAULT '0',
  `error_message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `client_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `synced_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`sync_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_status` (`sync_status`),
  KEY `idx_entity` (`entity_type`,`entity_id`),
  CONSTRAINT `offline_sync_queue_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `offline_sync_queue`
--

LOCK TABLES `offline_sync_queue` WRITE;
/*!40000 ALTER TABLE `offline_sync_queue` DISABLE KEYS */;
INSERT INTO `offline_sync_queue` VALUES (1,7,'assignment_submission',5,'create','{\"assignment_id\": 2, \"submission_text\": \"x = 5\\ny = 10\\nprint(x + y)\"}','synced',1,NULL,'2025-02-14 16:30:00','2025-02-14 16:31:15','2025-11-20 13:43:00'),(2,8,'activity_log',NULL,'create','{\"activity_type\": \"view\", \"entity_type\": \"course_material\", \"entity_id\": 3}','synced',1,NULL,'2025-02-14 17:45:00','2025-02-14 17:46:03','2025-11-20 13:43:00'),(3,9,'quiz_answer',15,'update','{\"answer_text\": \"Updated answer\", \"question_id\": 4}','pending',0,NULL,'2025-02-15 08:20:00',NULL,'2025-11-20 13:43:00'),(4,10,'forum_post',NULL,'create','{\"title\": \"New question\", \"content\": \"How do I...\"}','failed',2,NULL,'2025-02-15 09:00:00',NULL,'2025-11-20 13:43:00');
/*!40000 ALTER TABLE `offline_sync_queue` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `password_resets`
--

DROP TABLE IF EXISTS `password_resets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `password_resets` (
  `reset_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `reset_token` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `expires_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `used` tinyint(1) DEFAULT '0',
  `used_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`reset_id`),
  KEY `idx_token` (`reset_token`),
  KEY `idx_user` (`user_id`),
  CONSTRAINT `password_resets_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `password_resets`
--

LOCK TABLES `password_resets` WRITE;
/*!40000 ALTER TABLE `password_resets` DISABLE KEYS */;
INSERT INTO `password_resets` VALUES (6,59,'82d37db17f4603125601d3d8d0826fa52429f091ab9aebe30edd73b8296838c0','2026-03-02 14:27:06',0,NULL,'2026-03-02 13:27:06');
/*!40000 ALTER TABLE `password_resets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payment_transactions`
--

DROP TABLE IF EXISTS `payment_transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payment_transactions` (
  `transaction_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `course_id` bigint unsigned DEFAULT NULL,
  `amount` decimal(10,2) DEFAULT NULL,
  `currency` varchar(3) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'USD',
  `payment_method` enum('credit_card','paypal','bank_transfer') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `transaction_status` enum('pending','completed','failed','refunded') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `payment_gateway_ref` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `paid_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`transaction_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_course` (`course_id`),
  KEY `idx_status` (`transaction_status`),
  CONSTRAINT `payment_transactions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `payment_transactions_ibfk_2` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payment_transactions`
--

LOCK TABLES `payment_transactions` WRITE;
/*!40000 ALTER TABLE `payment_transactions` DISABLE KEYS */;
INSERT INTO `payment_transactions` VALUES (1,7,NULL,299.99,'USD','credit_card','completed','stripe_ch_1234567890','2025-01-10 13:30:00','2025-11-20 13:43:01'),(2,8,NULL,299.99,'USD','paypal','completed','paypal_txn_9876543210','2025-01-11 08:15:00','2025-11-20 13:43:01'),(3,9,2,399.99,'USD','credit_card','completed','stripe_ch_0987654321','2025-01-12 12:20:00','2025-11-20 13:43:01'),(4,10,NULL,299.99,'USD','credit_card','failed','stripe_ch_1111111111','2025-11-20 13:43:01','2025-11-20 13:43:01'),(5,11,3,349.99,'USD','bank_transfer','pending','bank_ref_555555','2025-11-20 13:43:01','2025-11-20 13:43:01');
/*!40000 ALTER TABLE `payment_transactions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `peer_reviews`
--

DROP TABLE IF EXISTS `peer_reviews`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `peer_reviews` (
  `review_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `submission_id` bigint unsigned NOT NULL,
  `reviewer_id` bigint unsigned NOT NULL,
  `reviewee_id` bigint unsigned NOT NULL,
  `review_text` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `rating` decimal(3,2) DEFAULT NULL,
  `criteria_scores` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `status` enum('pending','submitted','acknowledged') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  `submitted_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`review_id`),
  KEY `idx_submission` (`submission_id`),
  KEY `idx_reviewer` (`reviewer_id`),
  KEY `idx_reviewee` (`reviewee_id`),
  CONSTRAINT `peer_reviews_ibfk_1` FOREIGN KEY (`submission_id`) REFERENCES `assignment_submissions` (`submission_id`) ON DELETE CASCADE,
  CONSTRAINT `peer_reviews_ibfk_2` FOREIGN KEY (`reviewer_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `peer_reviews_ibfk_3` FOREIGN KEY (`reviewee_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `peer_reviews`
--

LOCK TABLES `peer_reviews` WRITE;
/*!40000 ALTER TABLE `peer_reviews` DISABLE KEYS */;
/*!40000 ALTER TABLE `peer_reviews` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `performance_metrics`
--

DROP TABLE IF EXISTS `performance_metrics`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `performance_metrics` (
  `metric_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `course_id` bigint unsigned NOT NULL,
  `metric_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `metric_value` decimal(10,2) NOT NULL,
  `calculation_date` date NOT NULL,
  `trend` enum('improving','stable','declining') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`metric_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_course` (`course_id`),
  KEY `idx_date` (`calculation_date`),
  CONSTRAINT `performance_metrics_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `performance_metrics_ibfk_2` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `performance_metrics`
--

LOCK TABLES `performance_metrics` WRITE;
/*!40000 ALTER TABLE `performance_metrics` DISABLE KEYS */;
INSERT INTO `performance_metrics` VALUES (7,57,1,'assignment_average',80.00,'2026-03-11','improving','2026-03-11 18:12:04'),(8,57,1,'quiz_average',75.00,'2026-03-11','stable','2026-03-11 18:12:04'),(9,57,2,'assignment_average',85.00,'2026-03-11','improving','2026-03-11 18:12:04'),(10,57,3,'overall_grade',91.25,'2026-03-11','improving','2026-03-11 18:12:04'),(11,57,4,'assignment_average',70.00,'2026-03-11','declining','2026-03-11 18:12:04');
/*!40000 ALTER TABLE `performance_metrics` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `permissions`
--

DROP TABLE IF EXISTS `permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `permissions` (
  `permission_id` int unsigned NOT NULL AUTO_INCREMENT,
  `permission_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `permission_description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `module` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`permission_id`),
  UNIQUE KEY `permission_name` (`permission_name`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `permissions`
--

LOCK TABLES `permissions` WRITE;
/*!40000 ALTER TABLE `permissions` DISABLE KEYS */;
INSERT INTO `permissions` VALUES (1,'view_courses','View course information','courses','2025-11-20 13:42:59'),(2,'enroll_courses','Enroll in courses','courses','2025-11-20 13:42:59'),(3,'create_courses','Create new courses','courses','2025-11-20 13:42:59'),(4,'manage_grades','Manage student grades','grading','2025-11-20 13:42:59'),(5,'take_attendance','Mark student attendance','attendance','2025-11-20 13:42:59'),(6,'view_reports','View analytics reports','reports','2025-11-20 13:42:59'),(7,'manage_users','Manage user accounts','users','2025-11-20 13:42:59'),(8,'system_settings','Access system settings','admin','2025-11-20 13:42:59');
/*!40000 ALTER TABLE `permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `points_rules`
--

DROP TABLE IF EXISTS `points_rules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `points_rules` (
  `rule_id` int unsigned NOT NULL AUTO_INCREMENT,
  `action_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `points_value` int NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `multiplier` decimal(3,2) DEFAULT '1.00',
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`rule_id`),
  UNIQUE KEY `action_type` (`action_type`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `points_rules`
--

LOCK TABLES `points_rules` WRITE;
/*!40000 ALTER TABLE `points_rules` DISABLE KEYS */;
INSERT INTO `points_rules` VALUES (1,'quiz_completion',10,'Complete a quiz',1.00,1,'2025-11-20 13:43:00','2025-11-20 13:43:00'),(2,'assignment_submission',15,'Submit an assignment on time',1.00,1,'2025-11-20 13:43:00','2025-11-20 13:43:00'),(3,'perfect_attendance',5,'Attend a class session',1.00,1,'2025-11-20 13:43:00','2025-11-20 13:43:00'),(4,'perfect_score',50,'Get 100% on assignment/quiz',1.50,1,'2025-11-20 13:43:00','2025-11-20 13:43:00'),(5,'early_submission',20,'Submit assignment early',1.00,1,'2025-11-20 13:43:00','2025-11-20 13:43:00'),(6,'daily_login',2,'Log in to the platform',1.00,1,'2025-11-20 13:43:00','2025-11-20 13:43:00'),(7,'forum_post',5,'Create a helpful forum post',1.00,1,'2025-11-20 13:43:00','2025-11-20 13:43:00'),(8,'peer_review',10,'Complete a peer review',1.00,1,'2025-11-20 13:43:00','2025-11-20 13:43:00');
/*!40000 ALTER TABLE `points_rules` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `programs`
--

DROP TABLE IF EXISTS `programs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `programs` (
  `program_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `department_id` bigint unsigned NOT NULL,
  `program_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `program_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `degree_type` enum('bachelor','master','phd','diploma','certificate') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `duration_years` int DEFAULT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `status` enum('active','inactive') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'active',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`program_id`),
  UNIQUE KEY `unique_program_code` (`department_id`,`program_code`),
  KEY `idx_department` (`department_id`),
  CONSTRAINT `programs_ibfk_1` FOREIGN KEY (`department_id`) REFERENCES `departments` (`department_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `programs`
--

LOCK TABLES `programs` WRITE;
/*!40000 ALTER TABLE `programs` DISABLE KEYS */;
INSERT INTO `programs` VALUES (1,1,'Updated Program','BCS','bachelor',4,'Undergraduate program in Computer Science','active','2025-11-20 13:42:59','2026-03-02 23:28:59'),(2,1,'Master of Computer Science','MCS','master',2,'Graduate program in Computer Science','active','2025-11-20 13:42:59','2025-11-20 13:42:59'),(3,2,'Bachelor of Mathematics','BMATH','bachelor',4,'Undergraduate program in Mathematics','active','2025-11-20 13:42:59','2025-11-20 13:42:59'),(4,4,'Bachelor of Business Administration','BBA','bachelor',4,'Undergraduate business program','active','2025-11-20 13:42:59','2025-11-20 13:42:59'),(5,5,'Bachelor of Engineering','BE','bachelor',4,'Undergraduate engineering program','active','2025-11-20 13:42:59','2025-11-20 13:42:59'),(6,3,'MBA','MBA','master',2,'Master of Business Administration','active','2024-09-01 08:00:00','2024-09-01 08:00:00'),(7,4,'BS Data Science','BS-DS','bachelor',4,'Bachelor of Science in Data Science','active','2024-09-01 08:00:00','2024-09-01 08:00:00'),(8,4,'Certificate Data Analytics','CERT-DA','certificate',1,'Certificate in Data Analytics','active','2024-09-01 08:00:00','2024-09-01 08:00:00'),(9,5,'BA English Literature','BA-ENG','bachelor',4,'Bachelor of Arts in English Literature','active','2024-09-01 08:00:00','2024-09-01 08:00:00'),(10,5,'BA Arabic Language','BA-AR','bachelor',4,'Bachelor of Arts in Arabic Language and Culture','active','2024-09-01 08:00:00','2024-09-01 08:00:00'),(11,6,'BS Mathematics','BS-MATH','bachelor',4,'Bachelor of Science in Mathematics','active','2024-09-01 08:00:00','2024-09-01 08:00:00'),(12,6,'BS Physics','BS-PHYS','bachelor',4,'Bachelor of Science in Physics','active','2024-09-01 08:00:00','2024-09-01 08:00:00'),(15,1,'Test Prog Z2','TPZ2','bachelor',4,NULL,'active','2026-03-02 13:31:14','2026-03-02 13:31:14'),(16,1,'AutoProg','AP1','bachelor',4,NULL,'active','2026-03-02 13:49:20','2026-03-02 13:49:20'),(17,1,'Test Program','TP01','bachelor',4,'A test program','active','2026-03-02 23:28:59','2026-03-02 23:28:59'),(18,1,'API Dog Test Program','TESTP01','bachelor',4,NULL,'active','2026-03-11 17:37:43','2026-03-11 17:37:43');
/*!40000 ALTER TABLE `programs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `quiz_answers`
--

DROP TABLE IF EXISTS `quiz_answers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `quiz_answers` (
  `answer_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `attempt_id` bigint unsigned NOT NULL,
  `question_id` bigint unsigned NOT NULL,
  `answer_text` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `selected_option` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `is_correct` tinyint(1) DEFAULT NULL,
  `points_earned` decimal(5,2) DEFAULT '0.00',
  `answered_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`answer_id`),
  UNIQUE KEY `unique_attempt_question` (`attempt_id`,`question_id`),
  KEY `question_id` (`question_id`),
  KEY `idx_attempt` (`attempt_id`),
  CONSTRAINT `quiz_answers_ibfk_1` FOREIGN KEY (`attempt_id`) REFERENCES `quiz_attempts` (`attempt_id`) ON DELETE CASCADE,
  CONSTRAINT `quiz_answers_ibfk_2` FOREIGN KEY (`question_id`) REFERENCES `quiz_questions` (`question_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `quiz_answers`
--

LOCK TABLES `quiz_answers` WRITE;
/*!40000 ALTER TABLE `quiz_answers` DISABLE KEYS */;
/*!40000 ALTER TABLE `quiz_answers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `quiz_attempts`
--

DROP TABLE IF EXISTS `quiz_attempts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `quiz_attempts` (
  `attempt_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `quiz_id` bigint unsigned NOT NULL,
  `user_id` bigint unsigned NOT NULL,
  `attempt_number` int NOT NULL,
  `started_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `submitted_at` timestamp NULL DEFAULT NULL,
  `score` decimal(5,2) DEFAULT NULL,
  `time_taken_minutes` int DEFAULT NULL,
  `status` enum('in_progress','submitted','graded','abandoned') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'in_progress',
  `ip_address` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`attempt_id`),
  KEY `idx_quiz` (`quiz_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_status` (`status`),
  KEY `idx_user_quiz_status` (`user_id`,`quiz_id`,`status`),
  KEY `idx_quiz_date` (`quiz_id`,`started_at`),
  CONSTRAINT `quiz_attempts_ibfk_1` FOREIGN KEY (`quiz_id`) REFERENCES `quizzes` (`quiz_id`) ON DELETE CASCADE,
  CONSTRAINT `quiz_attempts_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `quiz_attempts`
--

LOCK TABLES `quiz_attempts` WRITE;
/*!40000 ALTER TABLE `quiz_attempts` DISABLE KEYS */;
INSERT INTO `quiz_attempts` VALUES (5,1,57,1,'2026-03-02 14:09:06','2026-03-02 14:10:20',0.00,1,'graded',NULL),(6,10,57,1,'2026-03-02 23:44:03','2026-03-02 23:44:03',0.00,0,'graded',NULL),(7,11,57,1,'2026-03-02 23:47:22','2026-03-02 23:47:22',0.00,0,'graded',NULL);
/*!40000 ALTER TABLE `quiz_attempts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `quiz_difficulty_levels`
--

DROP TABLE IF EXISTS `quiz_difficulty_levels`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `quiz_difficulty_levels` (
  `difficulty_id` int unsigned NOT NULL AUTO_INCREMENT,
  `level_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `difficulty_value` int NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`difficulty_id`),
  UNIQUE KEY `level_name` (`level_name`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `quiz_difficulty_levels`
--

LOCK TABLES `quiz_difficulty_levels` WRITE;
/*!40000 ALTER TABLE `quiz_difficulty_levels` DISABLE KEYS */;
INSERT INTO `quiz_difficulty_levels` VALUES (1,'Easy',1,'Basic level questions'),(2,'Medium',2,'Intermediate level questions'),(3,'Hard',3,'Advanced level questions'),(5,'Very Hard',5,'Expert level - synthesis and evaluation');
/*!40000 ALTER TABLE `quiz_difficulty_levels` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `quiz_questions`
--

DROP TABLE IF EXISTS `quiz_questions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `quiz_questions` (
  `question_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `quiz_id` bigint unsigned NOT NULL,
  `question_text` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `question_type` enum('mcq','true_false','short_answer','essay','matching') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `options` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `correct_answer` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `explanation` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `points` decimal(5,2) DEFAULT '1.00',
  `difficulty_level_id` int unsigned DEFAULT NULL,
  `order_index` int DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`question_id`),
  KEY `difficulty_level_id` (`difficulty_level_id`),
  KEY `idx_quiz` (`quiz_id`),
  CONSTRAINT `quiz_questions_ibfk_1` FOREIGN KEY (`quiz_id`) REFERENCES `quizzes` (`quiz_id`) ON DELETE CASCADE,
  CONSTRAINT `quiz_questions_ibfk_2` FOREIGN KEY (`difficulty_level_id`) REFERENCES `quiz_difficulty_levels` (`difficulty_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `quiz_questions`
--

LOCK TABLES `quiz_questions` WRITE;
/*!40000 ALTER TABLE `quiz_questions` DISABLE KEYS */;
INSERT INTO `quiz_questions` VALUES (1,1,'Updated: What is the time complexity of binary search?','',NULL,NULL,NULL,15.00,NULL,0,'2025-01-25 08:00:00','2026-03-05 19:16:27'),(2,1,'Which of the following is not a data type?','',NULL,NULL,NULL,4.00,NULL,1,'2025-01-25 08:00:00','2026-03-05 19:16:27'),(3,1,'What does IDE stand for?','',NULL,NULL,NULL,4.00,NULL,2,'2025-01-25 08:00:00','2026-03-05 19:16:27'),(4,1,'True or False: Comments improve code readability.','true_false',NULL,NULL,NULL,4.00,NULL,3,'2025-01-25 08:00:00','2026-03-05 19:16:27'),(5,3,'What is the time complexity of accessing an element in an array by index?','mcq','[\"O(1)\", \"O(n)\", \"O(log n)\", \"O(n^2)\"]','0','Array access by index is constant time',15.00,2,1,'2025-11-20 13:42:59','2025-11-20 13:42:59'),(6,2,'What is the output of the loop: for(int i=0; i<3; i++)?','',NULL,NULL,NULL,4.00,NULL,1,'2025-02-01 08:00:00','2026-03-01 14:55:40'),(7,2,'Which statement is used to skip an iteration in a loop?','',NULL,NULL,NULL,4.00,NULL,2,'2025-02-01 08:00:00','2026-03-01 14:55:40'),(8,2,'What is the purpose of an if-else statement?','',NULL,NULL,NULL,4.00,NULL,3,'2025-02-01 08:00:00','2026-03-01 14:55:40'),(9,2,'True or False: A switch statement can only handle integers.','true_false',NULL,NULL,NULL,4.00,NULL,4,'2025-02-01 08:00:00','2026-03-01 14:55:40'),(10,2,'Describe the difference between while and do-while loops.','short_answer',NULL,NULL,NULL,4.00,NULL,5,'2025-02-01 08:00:00','2026-03-01 14:55:40'),(11,3,'What is the time complexity of array access?','',NULL,NULL,NULL,5.00,NULL,1,'2025-01-26 08:00:00','2026-03-01 14:55:40'),(12,3,'Explain how a linked list differs from an array.','short_answer',NULL,NULL,NULL,5.00,NULL,2,'2025-01-26 08:00:00','2026-03-01 14:55:40'),(13,3,'What is the advantage of a linked list over an array?','',NULL,NULL,NULL,5.00,NULL,3,'2025-01-26 08:00:00','2026-03-01 14:55:40'),(14,3,'True or False: Linked lists allow constant-time access to elements.','true_false',NULL,NULL,NULL,5.00,NULL,4,'2025-01-26 08:00:00','2026-03-01 14:55:40'),(15,4,'What is encapsulation?','',NULL,NULL,NULL,5.00,NULL,1,'2025-02-03 08:00:00','2026-03-01 14:55:40'),(16,4,'Describe inheritance with an example.','short_answer',NULL,NULL,NULL,5.00,NULL,2,'2025-02-03 08:00:00','2026-03-01 14:55:40'),(17,4,'What are the four pillars of OOP?','',NULL,NULL,NULL,5.00,NULL,3,'2025-02-03 08:00:00','2026-03-01 14:55:40'),(18,4,'True or False: A class can inherit from multiple classes in Java.','true_false',NULL,NULL,NULL,5.00,NULL,4,'2025-02-03 08:00:00','2026-03-01 14:55:40'),(19,4,'What is the difference between a class and an object?','short_answer',NULL,NULL,NULL,5.00,NULL,5,'2025-02-03 08:00:00','2026-03-01 14:55:40'),(21,10,'What is binary search complexity?','mcq','[\"O(1)\",\"O(log n)\",\"O(n)\",\"O(n log n)\"]','O(log n)','Binary search halves the space',10.00,1,0,'2026-03-02 23:44:03','2026-03-02 23:44:19'),(22,11,'Updated: What is binary search complexity?','mcq','[\"O(1)\",\"O(log n)\",\"O(n)\",\"O(n log n)\"]','O(log n)','Binary search halves the search space each step',15.00,1,0,'2026-03-02 23:47:22','2026-03-02 23:47:22'),(23,1,'What is the time complexity of binary search?','mcq','[\"O(1)\",\"O(log n)\",\"O(n)\",\"O(n log n)\"]','O(log n)','Binary search divides the search space in half each iteration',10.00,1,1,'2026-03-02 23:52:00','2026-03-02 23:52:00'),(24,1,'What is the time complexity of binary search?','mcq','[\"O(1)\",\"O(log n)\",\"O(n)\",\"O(n log n)\"]','O(log n)','Binary search divides the search space in half each iteration',10.00,1,1,'2026-03-03 00:23:22','2026-03-03 00:23:22'),(25,1,'What is the time complexity of binary search?','mcq','[\"O(1)\",\"O(log n)\",\"O(n)\",\"O(n log n)\"]','O(log n)','Binary search divides the search space in half each iteration',10.00,1,1,'2026-03-03 18:34:06','2026-03-03 18:34:06'),(26,1,'What is the time complexity of binary search?','mcq','[\"O(1)\",\"O(log n)\",\"O(n)\",\"O(n log n)\"]','O(log n)','Binary search divides the search space in half each iteration',10.00,1,1,'2026-03-05 19:16:27','2026-03-05 19:16:27');
/*!40000 ALTER TABLE `quiz_questions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `quizzes`
--

DROP TABLE IF EXISTS `quizzes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `quizzes` (
  `quiz_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `course_id` bigint unsigned NOT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `instructions` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `quiz_type` enum('practice','graded','midterm','final') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'graded',
  `time_limit_minutes` int DEFAULT NULL,
  `max_attempts` int DEFAULT '1',
  `passing_score` decimal(5,2) DEFAULT NULL,
  `randomize_questions` tinyint(1) DEFAULT '0',
  `show_correct_answers` tinyint(1) DEFAULT '1',
  `show_answers_after` enum('immediate','after_due','never') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'after_due',
  `available_from` timestamp NULL DEFAULT NULL,
  `available_until` timestamp NULL DEFAULT NULL,
  `weight` decimal(5,2) DEFAULT '0.00',
  `status` enum('draft','published','closed','archived') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'draft',
  `created_by` bigint unsigned NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`quiz_id`),
  KEY `created_by` (`created_by`),
  KEY `idx_course` (`course_id`),
  KEY `idx_available` (`available_from`,`available_until`),
  CONSTRAINT `quizzes_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`) ON DELETE CASCADE,
  CONSTRAINT `quizzes_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `quizzes`
--

LOCK TABLES `quizzes` WRITE;
/*!40000 ALTER TABLE `quizzes` DISABLE KEYS */;
INSERT INTO `quizzes` VALUES (1,1,'Updated Quiz Title','Quick assessment of fundamental programming concepts','Answer all questions','graded',45,1,12.00,1,1,'after_due',NULL,NULL,10.00,'published',8,'2025-01-25 08:00:00','2026-03-07 18:26:59',NULL),(2,1,'Quiz 2: Control Flow','Test knowledge of conditionals and loops','Answer all questions','graded',20,1,12.00,1,1,'after_due',NULL,NULL,10.00,'draft',8,'2025-02-01 08:00:00','2025-02-01 08:00:00',NULL),(3,2,'Quiz 1: Arrays and Lists','Understanding arrays',NULL,'graded',60,1,75.00,0,1,'after_due','2025-02-14 22:00:00','2025-02-25 21:59:59',15.00,'draft',3,'2025-11-20 13:42:59','2025-11-20 13:42:59',NULL),(4,3,'Quiz 1: Array and Linked Lists','Assessment of array and linked list concepts','Answer all questions','graded',20,1,15.00,1,0,'after_due',NULL,NULL,10.00,'draft',10,'2025-02-03 08:00:00','2025-02-03 08:00:00',NULL),(5,5,'Quiz 1: OOP Principles','Test understanding of object-oriented programming','Answer all questions','graded',25,1,12.00,1,1,'after_due',NULL,NULL,10.00,'draft',12,'2025-02-05 08:00:00','2025-02-05 08:00:00',NULL),(6,9,'Quiz 1: Statistical Concepts','Assessment of probability and statistics fundamentals','Answer all questions','graded',30,1,12.00,0,1,'after_due',NULL,NULL,10.00,'draft',16,'2025-02-07 08:00:00','2025-02-07 08:00:00',NULL),(7,1,'Updated Merge Quiz','Testing',NULL,'practice',30,3,60.00,1,1,'after_due','2026-03-01 00:00:00','2026-12-31 23:59:59',0.00,'draft',58,'2026-03-02 14:10:15','2026-03-02 14:10:25','2026-03-02 14:10:25'),(8,1,'Midterm Quiz: Arrays and Data Structures','This quiz covers chapters 1-5','Answer all questions. No partial credit.','graded',60,2,70.00,0,1,'after_due','2026-03-15 09:00:00','2026-03-22 23:59:59',15.00,'draft',59,'2026-03-02 14:34:32','2026-03-02 14:34:32',NULL),(9,1,'Midterm Quiz: Arrays and Data Structures','This quiz covers chapters 1-5','Answer all questions. No partial credit.','graded',60,2,70.00,0,1,'after_due','2026-03-15 09:00:00','2026-03-22 23:59:59',15.00,'draft',59,'2026-03-02 14:34:35','2026-03-02 14:34:35',NULL),(10,1,'PM Test Quiz Fixed','A quiz from test','Answer all','graded',30,2,60.00,1,1,'after_due','2026-03-01 00:00:00','2026-06-30 23:59:59',10.00,'draft',58,'2026-03-02 23:44:03','2026-03-02 23:44:03',NULL),(11,1,'Updated Quiz','A quiz from test script','Answer all questions','graded',45,2,60.00,1,1,'after_due','2026-03-01 00:00:00','2026-06-30 23:59:59',10.00,'draft',58,'2026-03-02 23:47:22','2026-03-02 23:47:22',NULL),(12,1,'Midterm Quiz: Data Structures','Covers arrays, linked lists, and trees','Answer all questions. Time limit applies.','graded',45,2,60.00,1,1,'after_due','2026-04-01 09:00:00','2026-04-15 23:59:59',15.00,'draft',58,'2026-03-02 23:52:00','2026-03-02 23:52:00',NULL),(13,1,'Midterm Quiz: Data Structures','Covers arrays, linked lists, and trees','Answer all questions. Time limit applies.','graded',45,2,60.00,1,1,'after_due','2026-04-01 09:00:00','2026-04-15 23:59:59',15.00,'draft',58,'2026-03-03 00:23:21','2026-03-03 00:23:21',NULL),(14,1,'Midterm Quiz: Data Structures','Covers arrays, linked lists, and trees','Answer all questions. Time limit applies.','graded',45,2,60.00,1,1,'after_due','2026-04-01 09:00:00','2026-04-15 23:59:59',15.00,'draft',58,'2026-03-03 18:34:06','2026-03-03 18:34:06',NULL),(15,1,'Midterm Quiz: Data Structures','Covers arrays, linked lists, and trees','Answer all questions. Time limit applies.','graded',45,2,60.00,1,1,'after_due','2026-04-01 09:00:00','2026-04-15 23:59:59',15.00,'published',58,'2026-03-05 19:16:26','2026-03-07 18:27:08',NULL),(16,1,'API Dog Test Quiz','Test quiz from API Dog',NULL,'graded',NULL,1,NULL,0,1,'after_due',NULL,NULL,0.00,'draft',59,'2026-03-11 17:37:53','2026-03-11 17:37:53',NULL),(17,1,'API Dog Test Quiz','Test quiz from API Dog',NULL,'graded',NULL,1,NULL,0,1,'after_due',NULL,NULL,0.00,'draft',59,'2026-03-14 15:36:06','2026-03-14 15:36:06',NULL),(18,1,'API Dog Test Quiz','Test quiz from API Dog',NULL,'graded',NULL,1,NULL,0,1,'after_due',NULL,NULL,0.00,'draft',59,'2026-03-14 15:40:46','2026-03-14 15:40:46',NULL),(19,1,'API Dog Test Quiz','Test quiz from API Dog',NULL,'graded',NULL,1,NULL,0,1,'after_due',NULL,NULL,0.00,'draft',59,'2026-03-14 16:06:09','2026-03-14 16:06:09',NULL);
/*!40000 ALTER TABLE `quizzes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `report_templates`
--

DROP TABLE IF EXISTS `report_templates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `report_templates` (
  `template_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `template_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `template_type` enum('student','course','attendance','grade','analytics','custom') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `template_structure` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_by` bigint unsigned NOT NULL,
  `is_system_template` tinyint(1) DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`template_id`),
  KEY `created_by` (`created_by`),
  KEY `idx_type` (`template_type`),
  CONSTRAINT `report_templates_ibfk_1` FOREIGN KEY (`created_by`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `report_templates`
--

LOCK TABLES `report_templates` WRITE;
/*!40000 ALTER TABLE `report_templates` DISABLE KEYS */;
INSERT INTO `report_templates` VALUES (1,'Student Progress Report','student','{\"sections\": [\"enrollment\", \"grades\", \"attendance\", \"participation\"]}','Comprehensive student progress report',1,1,'2025-11-20 13:43:00','2025-11-20 13:43:00'),(2,'Course Analytics Report','course','{\"sections\": [\"enrollment_stats\", \"grade_distribution\", \"attendance_rate\", \"engagement\"]}','Detailed course performance analytics',1,1,'2025-11-20 13:43:00','2025-11-20 13:43:00'),(3,'Attendance Summary','attendance','{\"sections\": [\"daily_attendance\", \"student_records\", \"trends\"]}','Attendance tracking report',1,1,'2025-11-20 13:43:00','2025-11-20 13:43:00'),(4,'Grade Distribution Report','grade','{\"sections\": [\"grade_breakdown\", \"statistics\", \"comparison\"]}','Grade distribution and statistics',1,1,'2025-11-20 13:43:00','2025-11-20 13:43:00');
/*!40000 ALTER TABLE `report_templates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reward_redemptions`
--

DROP TABLE IF EXISTS `reward_redemptions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reward_redemptions` (
  `redemption_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `reward_id` int unsigned NOT NULL,
  `user_id` bigint unsigned NOT NULL,
  `points_spent` int NOT NULL,
  `redemption_status` enum('pending','approved','delivered','rejected','cancelled') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  `delivery_details` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `approved_by` bigint unsigned DEFAULT NULL,
  `approved_at` timestamp NULL DEFAULT NULL,
  `redeemed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`redemption_id`),
  KEY `approved_by` (`approved_by`),
  KEY `idx_reward` (`reward_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_status` (`redemption_status`),
  CONSTRAINT `reward_redemptions_ibfk_1` FOREIGN KEY (`reward_id`) REFERENCES `rewards` (`reward_id`) ON DELETE CASCADE,
  CONSTRAINT `reward_redemptions_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `reward_redemptions_ibfk_3` FOREIGN KEY (`approved_by`) REFERENCES `users` (`user_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reward_redemptions`
--

LOCK TABLES `reward_redemptions` WRITE;
/*!40000 ALTER TABLE `reward_redemptions` DISABLE KEYS */;
INSERT INTO `reward_redemptions` VALUES (1,1,7,500,'delivered','{\"reward_type\": \"badge\", \"badge_id\": 7}',1,'2025-02-10 08:00:00','2025-02-10 07:30:00'),(2,2,8,300,'approved','{\"reward_type\": \"title\", \"title\": \"Quiz Master\"}',1,'2025-02-12 12:00:00','2025-02-12 11:45:00'),(3,1,9,250,'pending','{\"reward_type\": \"badge\", \"badge_id\": 3}',NULL,NULL,'2025-02-14 14:20:00');
/*!40000 ALTER TABLE `reward_redemptions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rewards`
--

DROP TABLE IF EXISTS `rewards`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rewards` (
  `reward_id` int unsigned NOT NULL AUTO_INCREMENT,
  `reward_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `reward_description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `reward_type` enum('badge','title','avatar','theme','feature_unlock','certificate') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `reward_value` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `points_cost` int DEFAULT '0',
  `achievement_id` int unsigned DEFAULT NULL,
  `is_available` tinyint(1) DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`reward_id`),
  KEY `achievement_id` (`achievement_id`),
  CONSTRAINT `rewards_ibfk_1` FOREIGN KEY (`achievement_id`) REFERENCES `achievements` (`achievement_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rewards`
--

LOCK TABLES `rewards` WRITE;
/*!40000 ALTER TABLE `rewards` DISABLE KEYS */;
INSERT INTO `rewards` VALUES (1,'Premium Badge','Unlock a premium profile badge','badge',NULL,500,NULL,1,'2025-11-20 13:43:00'),(2,'Custom Title','Get a custom profile title','title',NULL,300,NULL,1,'2025-11-20 13:43:00');
/*!40000 ALTER TABLE `rewards` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `role_permissions`
--

DROP TABLE IF EXISTS `role_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `role_permissions` (
  `role_permission_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `role_id` int unsigned NOT NULL,
  `permission_id` int unsigned NOT NULL,
  `granted_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`role_permission_id`),
  UNIQUE KEY `unique_role_permission` (`role_id`,`permission_id`),
  KEY `permission_id` (`permission_id`),
  CONSTRAINT `role_permissions_ibfk_1` FOREIGN KEY (`role_id`) REFERENCES `roles` (`role_id`) ON DELETE CASCADE,
  CONSTRAINT `role_permissions_ibfk_2` FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`permission_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `role_permissions`
--

LOCK TABLES `role_permissions` WRITE;
/*!40000 ALTER TABLE `role_permissions` DISABLE KEYS */;
INSERT INTO `role_permissions` VALUES (3,2,1,'2025-11-20 13:42:59'),(4,2,3,'2025-11-20 13:42:59'),(5,2,4,'2025-11-20 13:42:59'),(6,2,5,'2025-11-20 13:42:59'),(7,2,6,'2025-11-20 13:42:59'),(8,3,1,'2025-11-20 13:42:59'),(9,3,4,'2025-11-20 13:42:59'),(10,3,5,'2025-11-20 13:42:59'),(11,4,1,'2025-11-20 13:42:59'),(12,4,2,'2025-11-20 13:42:59'),(13,4,3,'2025-11-20 13:42:59'),(14,4,4,'2025-11-20 13:42:59'),(15,4,5,'2025-11-20 13:42:59'),(16,4,6,'2025-11-20 13:42:59'),(17,4,7,'2025-11-20 13:42:59'),(18,4,8,'2025-11-20 13:42:59'),(19,5,1,'2025-11-20 13:42:59'),(20,5,3,'2025-11-20 13:42:59'),(21,5,4,'2025-11-20 13:42:59'),(22,5,6,'2025-11-20 13:42:59'),(23,1,1,'2026-03-10 18:15:14'),(24,1,2,'2026-03-10 18:15:14');
/*!40000 ALTER TABLE `role_permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `roles` (
  `role_id` int unsigned NOT NULL AUTO_INCREMENT,
  `role_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `role_description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`role_id`),
  UNIQUE KEY `role_name` (`role_name`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `roles`
--

LOCK TABLES `roles` WRITE;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
INSERT INTO `roles` VALUES (1,'student','Regular student user','2025-11-20 13:42:59'),(2,'instructor','Course instructor','2025-11-20 13:42:59'),(3,'teaching_assistant','Teaching Assistant','2025-11-20 13:42:59'),(4,'admin','System Administrator','2025-11-20 13:42:59'),(5,'department_head','Department Head','2025-11-20 13:42:59'),(6,'it_admin','IT Administrator','2026-03-02 13:17:36');
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rubrics`
--

DROP TABLE IF EXISTS `rubrics`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rubrics` (
  `rubric_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `course_id` bigint unsigned NOT NULL,
  `rubric_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `criteria` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `total_points` decimal(5,2) DEFAULT '100.00',
  `created_by` bigint unsigned NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`rubric_id`),
  KEY `created_by` (`created_by`),
  KEY `idx_course` (`course_id`),
  CONSTRAINT `rubrics_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`) ON DELETE CASCADE,
  CONSTRAINT `rubrics_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rubrics`
--

LOCK TABLES `rubrics` WRITE;
/*!40000 ALTER TABLE `rubrics` DISABLE KEYS */;
INSERT INTO `rubrics` VALUES (1,1,'Programming Assignment Rubric','Rubric for evaluating programming assignments',NULL,100.00,2,'2026-03-11 16:43:58','2026-03-11 16:43:58'),(2,2,'Data Structures Project Rubric','Rubric for DS projects','{\"criteria\": [{\"name\": \"Implementation\", \"points\": 50}, {\"name\": \"Efficiency\", \"points\": 25}, {\"name\": \"Documentation\", \"points\": 15}, {\"name\": \"Presentation\", \"points\": 10}]}',100.00,3,'2025-11-20 13:43:00','2025-11-20 13:43:00'),(3,1,'Test Rubric Z','A rubric',NULL,100.00,58,'2026-03-02 13:34:36','2026-03-02 13:34:36'),(4,1,'AutoRubric','Test rubric',NULL,100.00,58,'2026-03-02 13:51:17','2026-03-02 13:51:17'),(5,1,'MergeTest','Post-merge',NULL,100.00,58,'2026-03-02 14:04:57','2026-03-02 14:04:57'),(6,1,'Essay Grading Rubric','Rubric for evaluating research essays','[{\"name\":\"Content\",\"maxPoints\":40,\"description\":\"Quality of content\"},{\"name\":\"Grammar\",\"maxPoints\":30,\"description\":\"Writing quality\"},{\"name\":\"Format\",\"maxPoints\":30,\"description\":\"Proper formatting\"}]',100.00,58,'2026-03-02 23:32:57','2026-03-02 23:32:57'),(7,1,'Test Rubric PM','Test rubric from postman test','[{\"name\":\"Content\",\"maxPoints\":40},{\"name\":\"Grammar\",\"maxPoints\":30},{\"name\":\"Format\",\"maxPoints\":30}]',100.00,58,'2026-03-02 23:42:38','2026-03-02 23:42:38'),(8,1,'Test Rubric PM','Test rubric from postman test','[{\"name\":\"Content\",\"maxPoints\":40},{\"name\":\"Grammar\",\"maxPoints\":30},{\"name\":\"Format\",\"maxPoints\":30}]',100.00,58,'2026-03-02 23:47:21','2026-03-02 23:47:21'),(9,1,'Essay Grading Rubric','Rubric for evaluating research essays','[{\"name\":\"Content\",\"maxPoints\":40,\"description\":\"Quality of content\"},{\"name\":\"Grammar\",\"maxPoints\":30,\"description\":\"Writing quality\"},{\"name\":\"Format\",\"maxPoints\":30,\"description\":\"Proper formatting\"}]',100.00,58,'2026-03-02 23:51:57','2026-03-02 23:51:57'),(10,1,'Essay Grading Rubric','Rubric for evaluating research essays','[{\"name\":\"Content\",\"maxPoints\":40,\"description\":\"Quality of content\"},{\"name\":\"Grammar\",\"maxPoints\":30,\"description\":\"Writing quality\"},{\"name\":\"Format\",\"maxPoints\":30,\"description\":\"Proper formatting\"}]',100.00,58,'2026-03-03 00:23:19','2026-03-03 00:23:19'),(11,1,'Essay Grading Rubric','Rubric for evaluating research essays','[{\"name\":\"Content\",\"maxPoints\":40,\"description\":\"Quality of content\"},{\"name\":\"Grammar\",\"maxPoints\":30,\"description\":\"Writing quality\"},{\"name\":\"Format\",\"maxPoints\":30,\"description\":\"Proper formatting\"}]',100.00,58,'2026-03-03 18:34:03','2026-03-03 18:34:03'),(12,1,'Essay Grading Rubric','Rubric for evaluating research essays','[{\"name\":\"Content\",\"maxPoints\":40,\"description\":\"Quality of content\"},{\"name\":\"Grammar\",\"maxPoints\":30,\"description\":\"Writing quality\"},{\"name\":\"Format\",\"maxPoints\":30,\"description\":\"Proper formatting\"}]',100.00,58,'2026-03-05 19:16:24','2026-03-05 19:16:24'),(13,1,'API Dog Test Rubric',NULL,NULL,100.00,58,'2026-03-11 17:37:55','2026-03-11 17:37:55'),(14,1,'API Dog Test Rubric',NULL,NULL,100.00,58,'2026-03-14 15:36:08','2026-03-14 15:36:08'),(15,1,'API Dog Test Rubric',NULL,NULL,100.00,58,'2026-03-14 15:40:48','2026-03-14 15:40:48'),(16,1,'API Dog Test Rubric',NULL,NULL,100.00,58,'2026-03-14 16:06:10','2026-03-14 16:06:10'),(17,1,'API Dog Test Rubric',NULL,NULL,100.00,58,'2026-03-16 20:19:09','2026-03-16 20:19:09'),(18,1,'API Dog Test Rubric',NULL,NULL,100.00,58,'2026-03-16 20:20:14','2026-03-16 20:20:14'),(19,1,'API Dog Test Rubric',NULL,NULL,100.00,58,'2026-03-16 20:32:56','2026-03-16 20:32:56'),(20,1,'API Dog Test Rubric',NULL,NULL,100.00,58,'2026-03-16 20:45:22','2026-03-16 20:45:22'),(21,1,'API Dog Test Rubric',NULL,NULL,100.00,58,'2026-03-16 20:53:57','2026-03-16 20:53:57'),(22,1,'API Dog Test Rubric',NULL,NULL,100.00,58,'2026-03-16 22:31:34','2026-03-16 22:31:34');
/*!40000 ALTER TABLE `rubrics` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `scheduled_notifications`
--

DROP TABLE IF EXISTS `scheduled_notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `scheduled_notifications` (
  `scheduled_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `notification_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `body` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `scheduled_for` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `status` enum('pending','sent','failed','cancelled') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  `created_by` bigint unsigned NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `sent_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`scheduled_id`),
  KEY `created_by` (`created_by`),
  KEY `idx_user` (`user_id`),
  KEY `idx_scheduled` (`scheduled_for`),
  KEY `idx_status` (`status`),
  CONSTRAINT `scheduled_notifications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `scheduled_notifications_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `scheduled_notifications`
--

LOCK TABLES `scheduled_notifications` WRITE;
/*!40000 ALTER TABLE `scheduled_notifications` DISABLE KEYS */;
INSERT INTO `scheduled_notifications` VALUES (1,7,'deadline_reminder','Assignment Due Tomorrow','Assignment 2 is due tomorrow at 11:59 PM','2025-02-27 07:00:00','pending',2,'2025-11-20 13:43:00',NULL),(2,8,'deadline_reminder','Quiz Available','Quiz 2 is now available. Due date: March 10','2025-03-01 06:00:00','pending',2,'2025-11-20 13:43:00',NULL),(3,9,'course_update','New Material Posted','Lecture 5 slides have been uploaded','2025-02-20 08:00:00','sent',2,'2025-11-20 13:43:00',NULL),(4,10,'grade_available','Grade Posted','Your grade for Assignment 1 is now available','2025-02-16 08:00:00','sent',2,'2025-11-20 13:43:00',NULL);
/*!40000 ALTER TABLE `scheduled_notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `search_history`
--

DROP TABLE IF EXISTS `search_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `search_history` (
  `history_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `search_query` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `search_filters` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `results_count` int DEFAULT '0',
  `selected_result_id` bigint unsigned DEFAULT NULL,
  `selected_result_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`history_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_query` (`search_query`(255)),
  KEY `idx_date` (`created_at`),
  CONSTRAINT `search_history_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=65 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `search_history`
--

LOCK TABLES `search_history` WRITE;
/*!40000 ALTER TABLE `search_history` DISABLE KEYS */;
INSERT INTO `search_history` VALUES (1,7,'python loops','{\"entity_types\": [\"material\", \"post\"]}',8,5,'post','2025-11-20 13:43:00'),(2,7,'assignment 1','{\"course_id\": 1}',3,1,'assignment','2025-11-20 13:43:00'),(3,8,'hello world','{}',12,3,'assignment','2025-11-20 13:43:00'),(4,9,'data structures','{\"entity_types\": [\"course\", \"material\"]}',15,NULL,NULL,'2025-11-20 13:43:00'),(5,10,'syllabus','{\"course_id\": 1}',2,1,'material','2025-11-20 13:43:00');
/*!40000 ALTER TABLE `search_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `search_index`
--

DROP TABLE IF EXISTS `search_index`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `search_index` (
  `index_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `entity_type` enum('course','material','user','announcement','assignment','quiz','file','post') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `entity_id` bigint unsigned NOT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `keywords` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `metadata` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `search_vector` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `visibility` enum('public','students','instructors','private') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'students',
  `campus_id` bigint unsigned DEFAULT NULL,
  `course_id` bigint unsigned DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`index_id`),
  KEY `idx_entity` (`entity_type`,`entity_id`),
  KEY `idx_campus` (`campus_id`),
  KEY `idx_course` (`course_id`),
  FULLTEXT KEY `idx_search` (`title`,`content`,`keywords`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `search_index`
--

LOCK TABLES `search_index` WRITE;
/*!40000 ALTER TABLE `search_index` DISABLE KEYS */;
INSERT INTO `search_index` VALUES (1,'course',1,'Introduction to Programming','Basic programming concepts using Python. Learn variables, loops, functions, and more.','python, programming, cs101, beginner, coding',NULL,NULL,'students',1,1,'2025-11-20 13:43:00','2025-11-20 13:43:00'),(2,'material',2,'Lecture 1: Introduction to Programming','Overview of programming concepts, what is programming, why learn Python, basic syntax','lecture, introduction, python basics, programming concepts',NULL,NULL,'students',1,1,'2025-11-20 13:43:00','2025-11-20 13:43:00'),(3,'assignment',1,'Assignment 1: Hello World','Create your first Python program that prints Hello World','assignment, hello world, python, beginner',NULL,NULL,'students',1,1,'2025-11-20 13:43:00','2025-11-20 13:43:00'),(4,'announcement',1,'Course Start','Welcome to CS101! Please review the syllabus','welcome, syllabus, course start',NULL,NULL,'students',1,1,'2025-11-20 13:43:00','2025-11-20 13:43:00'),(5,'post',1,'Help with loops','Can someone explain how for loops work in Python?','loops, for loop, help, question, python',NULL,NULL,'students',1,1,'2025-11-20 13:43:00','2025-11-20 13:43:00'),(6,'course',2,'Data Structures and Algorithms','Learn about arrays, linked lists, trees, and graphs','data structures algorithms trees graphs',NULL,NULL,'students',NULL,2,'2026-03-11 18:12:04','2026-03-11 18:12:04'),(7,'course',3,'Database Systems','Introduction to relational databases and SQL','database sql relational queries',NULL,NULL,'students',NULL,3,'2026-03-11 18:12:04','2026-03-11 18:12:04'),(8,'material',2,'Lecture 2: Arrays and Lists','Understanding arrays and linked lists in programming','arrays lists data structures',NULL,NULL,'students',NULL,1,'2026-03-11 18:12:04','2026-03-11 18:12:04'),(9,'user',57,'Tarek Student','Student enrolled in CS courses','student tarek cs',NULL,NULL,'public',NULL,NULL,'2026-03-11 18:12:04','2026-03-11 18:12:04'),(10,'user',58,'Tarek Instructor','Instructor for CS courses','instructor tarek cs',NULL,NULL,'public',NULL,NULL,'2026-03-11 18:12:04','2026-03-11 18:12:04'),(11,'assignment',2,'Assignment 2: Data Structures','Implement a linked list and binary tree','linked list binary tree implementation',NULL,NULL,'students',NULL,2,'2026-03-11 18:12:04','2026-03-11 18:12:04'),(12,'quiz',1,'Quiz 1: Programming Basics','Test your knowledge of variables, loops, and functions','variables loops functions basics',NULL,NULL,'students',NULL,1,'2026-03-11 18:12:04','2026-03-11 18:12:04');
/*!40000 ALTER TABLE `search_index` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `security_logs`
--

DROP TABLE IF EXISTS `security_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `security_logs` (
  `log_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned DEFAULT NULL,
  `event_type` enum('login','logout','failed_login','password_change','permission_change','suspicious_activity','login_success','login_failure','role_change','account_locked','ip_blocked','session_hijack','brute_force') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `severity` enum('low','medium','high','critical') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'medium',
  `ip_address` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `location` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `details` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `metadata` json DEFAULT NULL,
  `is_resolved` tinyint(1) DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`log_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_event` (`event_type`),
  KEY `idx_severity` (`severity`),
  KEY `idx_date` (`created_at`),
  CONSTRAINT `security_logs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `security_logs`
--

LOCK TABLES `security_logs` WRITE;
/*!40000 ALTER TABLE `security_logs` DISABLE KEYS */;
INSERT INTO `security_logs` VALUES (1,7,'login','low','192.168.1.100',NULL,NULL,'Successful login',NULL,1,'2025-11-20 13:43:00'),(2,8,'login','low','192.168.1.101',NULL,NULL,'Successful login',NULL,1,'2025-11-20 13:43:00'),(3,NULL,'failed_login','medium','192.168.1.200',NULL,NULL,'Failed login attempt for email: unknown@test.com',NULL,1,'2025-11-20 13:43:00'),(4,7,'password_change','low','192.168.1.100',NULL,NULL,'User changed password',NULL,1,'2025-11-20 13:43:00'),(5,NULL,'failed_login','high','203.0.113.45',NULL,NULL,'Multiple failed login attempts detected',NULL,0,'2025-11-20 13:43:00'),(6,1,'permission_change','medium','192.168.1.1',NULL,NULL,'Admin modified user role permissions',NULL,1,'2025-11-20 13:43:00');
/*!40000 ALTER TABLE `security_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `semesters`
--

DROP TABLE IF EXISTS `semesters`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `semesters` (
  `semester_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `semester_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `semester_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `registration_start` date DEFAULT NULL,
  `registration_end` date DEFAULT NULL,
  `status` enum('upcoming','active','completed') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'upcoming',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`semester_id`),
  UNIQUE KEY `semester_code` (`semester_code`),
  KEY `idx_code` (`semester_code`),
  KEY `idx_dates` (`start_date`,`end_date`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `semesters`
--

LOCK TABLES `semesters` WRITE;
/*!40000 ALTER TABLE `semesters` DISABLE KEYS */;
INSERT INTO `semesters` VALUES (1,'Fall 2026 Updated','FALL2024','2024-09-01','2024-12-20','2024-08-15','2024-08-31','completed','2024-08-01 00:00:00'),(2,'Spring 2025','SPR2025','2025-01-15','2025-05-30','2024-12-15','2025-01-10','completed','2024-12-01 00:00:00'),(3,'Summer 2025','SU2025','2025-06-01','2025-08-15','2025-05-01','2025-05-25','upcoming','2025-11-20 13:42:59'),(4,'Fall 2025','F2025','2025-09-01','2026-06-30','2025-08-01','2025-08-25','active','2025-11-26 18:54:24'),(7,'Fall 2027','F2027','2027-09-01','2027-12-20','2027-08-01','2027-08-25','upcoming','2025-11-26 19:28:01'),(12,'Fall 2026','F26','2026-09-01','2026-12-15','2026-08-01','2026-08-30','upcoming','2026-03-02 13:29:55'),(13,'Auto Sem','AS1','2027-01-01','2027-05-01','2026-12-01','2026-12-31','upcoming','2026-03-02 13:49:23'),(14,'Fall 2026','F2026','2026-09-01','2026-12-31','2026-08-01','2026-08-25','upcoming','2026-03-02 23:29:09');
/*!40000 ALTER TABLE `semesters` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `server_monitoring`
--

DROP TABLE IF EXISTS `server_monitoring`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `server_monitoring` (
  `monitor_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `server_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `cpu_usage` decimal(5,2) DEFAULT NULL,
  `memory_usage` decimal(5,2) DEFAULT NULL,
  `disk_usage` decimal(5,2) DEFAULT NULL,
  `status` enum('healthy','warning','critical','down') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'healthy',
  `uptime_seconds` bigint DEFAULT NULL,
  `checked_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`monitor_id`),
  KEY `idx_server` (`server_name`),
  KEY `idx_status` (`status`),
  KEY `idx_checked` (`checked_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `server_monitoring`
--

LOCK TABLES `server_monitoring` WRITE;
/*!40000 ALTER TABLE `server_monitoring` DISABLE KEYS */;
/*!40000 ALTER TABLE `server_monitoring` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sessions`
--

DROP TABLE IF EXISTS `sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sessions` (
  `session_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `session_token` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `ip_address` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `device_type` enum('web','mobile_ios','mobile_android','tablet','desktop') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'web',
  `expires_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `remember_me` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`session_id`),
  UNIQUE KEY `session_token` (`session_token`),
  KEY `idx_token` (`session_token`),
  KEY `idx_user` (`user_id`),
  KEY `idx_expires` (`expires_at`),
  CONSTRAINT `sessions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=581 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sessions`
--

LOCK TABLES `sessions` WRITE;
/*!40000 ALTER TABLE `sessions` DISABLE KEYS */;
INSERT INTO `sessions` VALUES (3,17,'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJhbWlyMTIzQGNhbXB1cy5lZHUiLCJ1c2VySWQiOjE3LCJ0eXBlIjoicmVmcmVzaCIsImlhdCI6MTc2NDAyNjY5MywiZXhwIjoxNzY0NjMxNDkzfQ.dTVCFc4JBCHqkmDxVHDFVIGA9lC4i6gxKEgoRTxhMotnFpABxg18leyHqXa8lCa0w3UjDUmhDb5nGPv5HivZ1g',NULL,NULL,'web','2025-12-01 23:24:53','2025-11-24 23:24:53',0),(6,18,'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJhbWlyLnVzZXJAY2FtcHVzLmVkdSIsInVzZXJJZCI6MTgsInR5cGUiOiJyZWZyZXNoIiwiaWF0IjoxNzY0MDI3MjE1LCJleHAiOjE3NjQ2MzIwMTV9.2Oyabfn3xjY7uGXALDWwz4qmG3DxwEIqK4iFk04yaEFeyxg25h0sHRSCa6F70eam5EvFzGt5NUoYzfinBvH0Wg',NULL,NULL,'web','2025-12-01 23:33:35','2025-11-24 23:33:35',0),(13,19,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjE5LCJlbWFpbCI6ImFtaXIxMjM0QGNhbXB1cy5lZHUiLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc2NDA5MzY0MSwiZXhwIjoxNzY0Njk4NDQxfQ.Jyu8OKNLHwj6zdhuiayBFJ3mqWT0JMZfiOLY3qNdHRk','127.0.0.1','Thunder Client (https://www.thunderclient.com)','desktop','2025-12-02 18:00:41','2025-11-25 18:00:41',0),(60,25,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjI1LCJlbWFpbCI6ImFtMzU2NjE0NkBnbWFpbC5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc2NDE3Mzg3NCwiZXhwIjoxNzY0Nzc4Njc0fQ.BtVUgOvdcFbaLLEj6kYP4Xm96krdJGKQGp1jN2OQjFo','127.0.0.1','PostmanRuntime/7.49.1','desktop','2025-12-03 16:17:54','2025-11-26 16:17:54',0),(61,25,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjI1LCJlbWFpbCI6ImFtMzU2NjE0NkBnbWFpbC5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc2NDE3OTYxMiwiZXhwIjoxNzY0Nzg0NDEyfQ.5Sq0Y0FarUgt4W3AEhIUbrZaZKSY8zkRU45ZwGhW95U','127.0.0.1','PostmanRuntime/7.49.1','desktop','2025-12-03 17:53:32','2025-11-26 17:53:32',0),(62,29,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjI5LCJlbWFpbCI6ImFtMzU2NjE0N0BnbWFpbC5jb20iLCJyb2xlcyI6WyJhZG1pbiJdLCJpYXQiOjE3NjQxODAyNDcsImV4cCI6MTc2NDc4NTA0N30.-VOieVPihJLvMNHJbj9_cSItzW9kCZLa5NKB4s_Nfvw','127.0.0.1','PostmanRuntime/7.49.1','desktop','2025-12-03 18:04:07','2025-11-26 18:04:07',0),(63,29,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjI5LCJlbWFpbCI6ImFtMzU2NjE0N0BnbWFpbC5jb20iLCJyb2xlcyI6WyJhZG1pbiJdLCJpYXQiOjE3NjQxODQ5MDYsImV4cCI6MTc2NDc4OTcwNn0.jLUlH_1BzJM0eXbgtiec_6IFyVKl4FB24k1Vi82_k-Y','127.0.0.1','PostmanRuntime/7.49.1','desktop','2025-12-03 19:21:46','2025-11-26 19:21:46',0),(68,30,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjMwLCJlbWFpbCI6ImFtMzU2NjE0M0BnbWFpbC5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc2NDIwMzg2MiwiZXhwIjoxNzY0ODA4NjYyfQ.OMFNxg2GN8WeDxbypZBVcDnP6JrM5fHZ_8X71z_h6D0','192.168.1.3','Dart/3.9 (dart:io)','desktop','2025-12-04 00:37:42','2025-11-27 00:37:42',0),(70,29,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjI5LCJlbWFpbCI6ImFtMzU2NjE0N0BnbWFpbC5jb20iLCJyb2xlcyI6WyJhZG1pbiJdLCJpYXQiOjE3NjQyNjI2OTYsImV4cCI6MTc2NDg2NzQ5Nn0.4UhMJ0d-5lPlvL18DDwH9B1Wfx_BYd-DbcC5Bn3DSb8','127.0.0.1','PostmanRuntime/7.49.1','desktop','2025-12-04 16:58:16','2025-11-27 16:58:16',0),(71,29,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjI5LCJlbWFpbCI6ImFtMzU2NjE0N0BnbWFpbC5jb20iLCJyb2xlcyI6WyJhZG1pbiJdLCJpYXQiOjE3NjQyNjUxNjYsImV4cCI6MTc2NDg2OTk2Nn0.6K6yofEYOZby2sq8EqAQBYElbSWMdTX7E0zQoSbVhb4','127.0.0.1','PostmanRuntime/7.49.1','desktop','2025-12-04 17:39:26','2025-11-27 17:39:26',0),(72,29,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjI5LCJlbWFpbCI6ImFtMzU2NjE0N0BnbWFpbC5jb20iLCJyb2xlcyI6WyJhZG1pbiJdLCJpYXQiOjE3NjQyNzMwMTcsImV4cCI6MTc2NDg3NzgxN30.Qs4njygOc58XwoshQk6H-Ghp6AJlaHkp6mta-8BbRF8','127.0.0.1','PostmanRuntime/7.49.1','desktop','2025-12-04 19:50:18','2025-11-27 19:50:17',0),(73,29,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjI5LCJlbWFpbCI6ImFtMzU2NjE0N0BnbWFpbC5jb20iLCJyb2xlcyI6WyJhZG1pbiJdLCJpYXQiOjE3NjQ1MTc2NzcsImV4cCI6MTc2NTEyMjQ3N30.QTWYpvG_pZUJTKsnoT1Bwv-wOsljbjBsAr0PGx6PU-E','127.0.0.1','PostmanRuntime/7.49.1','desktop','2025-12-07 15:47:58','2025-11-30 15:47:57',0),(74,25,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjI1LCJlbWFpbCI6ImFtMzU2NjE0NkBnbWFpbC5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc2NDUxODY5OSwiZXhwIjoxNzY1MTIzNDk5fQ.jNoA5aP62LQ3PaLbImvakM-weKxjK4TWV8L-ciucodc','127.0.0.1','PostmanRuntime/7.49.1','desktop','2025-12-07 16:05:00','2025-11-30 16:04:59',0),(75,29,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjI5LCJlbWFpbCI6ImFtMzU2NjE0N0BnbWFpbC5jb20iLCJyb2xlcyI6WyJhZG1pbiJdLCJpYXQiOjE3NjQ1MTg3NDMsImV4cCI6MTc2NTEyMzU0M30.pcWldW3f_2BMukMzvJ7W3FSu9GmRkEXJAdHFgrg2kJU','127.0.0.1','PostmanRuntime/7.49.1','desktop','2025-12-07 16:05:43','2025-11-30 16:05:43',0),(76,34,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjM0LCJlbWFpbCI6ImFtaXJfc3R1ZGVudEBjYW1wdXMuZWR1Iiwicm9sZXMiOlsic3R1ZGVudCJdLCJpYXQiOjE3NjQ1MTg5MzMsImV4cCI6MTc2NTEyMzczM30.lea9RdkUal-n0yuoJSk0V6IVBZdW1npMS2szF_S_mYM','127.0.0.1','PostmanRuntime/7.49.1','desktop','2025-12-07 16:08:53','2025-11-30 16:08:53',0),(77,29,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjI5LCJlbWFpbCI6ImFtMzU2NjE0N0BnbWFpbC5jb20iLCJyb2xlcyI6WyJhZG1pbiJdLCJpYXQiOjE3NjQ1MjA3NjQsImV4cCI6MTc2NTEyNTU2NH0.Je4CVQwAgdJ4D8xc09v0Im3iDiIuJReAX3eIlVHOY5A','127.0.0.1','PostmanRuntime/7.49.1','desktop','2025-12-07 16:39:24','2025-11-30 16:39:24',0),(78,36,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjM2LCJlbWFpbCI6ImpvaG4uZG9lQGV4YW1wbGUuY29tIiwicm9sZXMiOlsic3R1ZGVudCJdLCJpYXQiOjE3NzIwNDYyNTIsImV4cCI6MTc3MjY1MTA1Mn0.mdvXYoVNU6LLKHUjWmqPQTRTMytD13pRJJ4vgmRB16c','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','desktop','2026-03-04 19:04:12','2026-02-25 19:04:12',0),(79,36,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjM2LCJlbWFpbCI6ImpvaG4uZG9lQGV4YW1wbGUuY29tIiwicm9sZXMiOlsic3R1ZGVudCJdLCJpYXQiOjE3NzIwNTAyNzQsImV4cCI6MTc3MjY1NTA3NH0.cbFdJWpQVM2tMCVcczIUJGcYqZrAH1SulzVLX9e9Lks','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','desktop','2026-03-04 20:11:14','2026-02-25 20:11:14',0),(80,56,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU2LCJlbWFpbCI6ImFkbWludGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJhZG1pbiJdLCJpYXQiOjE3NzIzODI4MjgsImV4cCI6MTc3Mjk4NzYyOH0.mwUp2Z_FXBSPWy4Mv5EGWqs8r5SYP7fn0l0-9qeZ9Yg','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','desktop','2026-03-08 16:33:48','2026-03-01 16:33:48',0),(81,56,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU2LCJlbWFpbCI6ImFkbWludGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJhZG1pbiJdLCJpYXQiOjE3NzIzOTkwMDMsImV4cCI6MTc3MzAwMzgwM30.-wZ1fnzgbIgErm9zeDCY8d8bJkTLWQLqF3JcSMrTMwI','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','desktop','2026-03-08 21:03:23','2026-03-01 21:03:23',0),(82,56,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU2LCJlbWFpbCI6ImFkbWludGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJhZG1pbiJdLCJpYXQiOjE3NzIzOTk3MTUsImV4cCI6MTc3MzAwNDUxNX0.qzUcx45Odur_uc_kw3EIf8x8xR3Vp27nnL6b4X6CcwM','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','desktop','2026-03-08 21:15:15','2026-03-01 21:15:15',0),(83,56,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU2LCJlbWFpbCI6ImFkbWludGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJhZG1pbiJdLCJpYXQiOjE3NzI0MDAwMzksImV4cCI6MTc3MzAwNDgzOX0.TC1w_AEr4Sdk4XgKB7y9Id87kDn8R92a3KA_L7eBZ40','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','desktop','2026-03-08 21:20:39','2026-03-01 21:20:39',0),(84,56,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU2LCJlbWFpbCI6ImFkbWludGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJhZG1pbiJdLCJpYXQiOjE3NzI0NTczNDIsImV4cCI6MTc3MzA2MjE0Mn0.DG-Gz75Hl0e1wk42Vhq3UbxJ2wZdE4JyYlqhrWLhcJo','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:15:42','2026-03-02 13:15:42',0),(85,56,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU2LCJlbWFpbCI6ImFkbWludGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJhZG1pbiJdLCJpYXQiOjE3NzI0NTczNjAsImV4cCI6MTc3MzA2MjE2MH0.q-B1Wai6zRRkKov2C97DuwoqtqFW56OFkp1tf3COMaY','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:16:00','2026-03-02 13:16:00',0),(86,56,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU2LCJlbWFpbCI6ImFkbWludGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJhZG1pbiJdLCJpYXQiOjE3NzI0NTc0MzIsImV4cCI6MTc3MzA2MjIzMn0.ZVVluOsp3Pe3ofUAQt2wo6T3pKQdUwSTlki72gFai5Y','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:17:12','2026-03-02 13:17:12',0),(87,56,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU2LCJlbWFpbCI6ImFkbWludGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJhZG1pbiJdLCJpYXQiOjE3NzI0NTc0NTUsImV4cCI6MTc3MzA2MjI1NX0.wWV6KgCFtQG8IoZUQ0maASkuuA1oaraR4EAHA2vU9_0','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:17:35','2026-03-02 13:17:35',0),(88,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjQ1NzU0MSwiZXhwIjoxNzczMDYyMzQxfQ.Pk1-QGtFJ8u5kDp95n0KGN8MKTERqs6B0JU5YqEWXu8','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:19:01','2026-03-02 13:19:01',0),(89,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjQ1NzU0MiwiZXhwIjoxNzczMDYyMzQyfQ.kT-TXy0EvBXvaD_s72bXPv9fojopnLxUB871_ZTos6I','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:19:02','2026-03-02 13:19:02',0),(90,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNDU3NTQzLCJleHAiOjE3NzMwNjIzNDN9.YctRyFG-bJ9AMgGlkwLmN-UfAgxN0mzHCc1whe7J8po','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:19:03','2026-03-02 13:19:03',0),(91,60,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MjQ1NzU0NSwiZXhwIjoxNzczMDYyMzQ1fQ.5wXxyK-p2dILps__7SxwZiMnPbyHCpnwb5yJMejbrRQ','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:19:05','2026-03-02 13:19:05',0),(92,61,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzcyNDU3NTQ2LCJleHAiOjE3NzMwNjIzNDZ9.Epf4YqXyrkKSxDQ4XIQ5X18simAzm-iyGOy2WcADt7I','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:19:06','2026-03-02 13:19:06',0),(93,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjQ1NzU3NSwiZXhwIjoxNzczMDYyMzc1fQ.szAOtYQNxy4m12Xx2wbs4sLkwUTmqoFfZNGsmXYyKNo','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:19:35','2026-03-02 13:19:35',0),(94,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjQ1NzU3NiwiZXhwIjoxNzczMDYyMzc2fQ.CTd2DU3gFlAzuGMuXaLa7gfcuc3KPCHEudOze7KL45Q','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:19:36','2026-03-02 13:19:36',0),(95,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNDU3NTc3LCJleHAiOjE3NzMwNjIzNzd9.y8m9TcHCMLy2-rhmURQlCduv7Ev4X5M9cpWbrvf05gA','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:19:37','2026-03-02 13:19:37',0),(96,60,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MjQ1NzU3OCwiZXhwIjoxNzczMDYyMzc4fQ.5NjZQ4_q9Eyn3sORIx5e2UAZXjMxaU_v-2ZfsUCGZ7c','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:19:38','2026-03-02 13:19:38',0),(97,61,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzcyNDU3NTc5LCJleHAiOjE3NzMwNjIzNzl9.i4vB6DEEXvhyTRYFiTeOa7GYbVTURS33HnRbH-K64-k','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:19:39','2026-03-02 13:19:39',0),(98,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjQ1NzU4MCwiZXhwIjoxNzczMDYyMzgwfQ.dabDAEyusDQ0hAm3AYD_237EmE-bJhsMLz_cuhbXdRk','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:19:40','2026-03-02 13:19:40',0),(100,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjQ1NzU4NSwiZXhwIjoxNzczMDYyMzg1fQ.fcWiH6Ruelqp3RW1ownzAOrktTlSDcJOxWsXx9sZCG4','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:19:45','2026-03-02 13:19:45',0),(102,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjQ1NzU4OSwiZXhwIjoxNzczMDYyMzg5fQ.P0VG7CCyluCDiO6pJmne-MSi_MGlItd1SDgAB4EgxlQ','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:19:49','2026-03-02 13:19:49',0),(103,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNDU3NjEwLCJleHAiOjE3NzMwNjI0MTB9.BJBGBx3E8nTe48l-F64xY3eUgV3KMQfU0RpsIbayKts','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:20:10','2026-03-02 13:20:10',0),(104,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjQ1NzYxMSwiZXhwIjoxNzczMDYyNDExfQ.D5BwQCTKKjOppR9aIl7OnMKfUx7gnh_zgF7fFuVFhWQ','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:20:11','2026-03-02 13:20:11',0),(105,61,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzcyNDU3NjEyLCJleHAiOjE3NzMwNjI0MTJ9.BWOdvZybSXY02RCDutG_2RA5-MsryCDq6hVLEYEB5ok','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:20:12','2026-03-02 13:20:12',0),(106,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNDU3NjczLCJleHAiOjE3NzMwNjI0NzN9.pOI5BzK9H3mCOEK10-SF1Q3qxMiekQHGVwgyuc9NWeU','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:21:13','2026-03-02 13:21:13',0),(107,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjQ1NzY3NCwiZXhwIjoxNzczMDYyNDc0fQ.mgqDtlLTDPiaQAsT1B5e_9kEEbIk5vq2RYIbfd8FDgw','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:21:14','2026-03-02 13:21:14',0),(108,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjQ1NzY3NSwiZXhwIjoxNzczMDYyNDc1fQ.lxyWJDcc52TBbLfaIs19QOsmsGMbcL84jZsxIl_oRRU','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:21:15','2026-03-02 13:21:15',0),(109,60,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MjQ1NzY3NiwiZXhwIjoxNzczMDYyNDc2fQ.c9uG5yBbtYooOd-Ep6rVQP6l_cza3doBLgIXHWYTaUU','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:21:16','2026-03-02 13:21:16',0),(110,61,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzcyNDU3Njc3LCJleHAiOjE3NzMwNjI0Nzd9.5P-So3BzhXESkIHFtIP5TBIUlJs-7Uh74MpdjP5Ko0k','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:21:17','2026-03-02 13:21:17',0),(111,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjQ1Nzk4MiwiZXhwIjoxNzczMDYyNzgyfQ.ENt68zQp9sbwnJIJhfvX_yVcE5tsIppZUTWslD-ZROg','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:26:22','2026-03-02 13:26:22',0),(112,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjQ1Nzk4MywiZXhwIjoxNzczMDYyNzgzfQ.TM6MiyoiQmEkBrEx3vljTN0J1HPSFXeHbyZktpm4VwE','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:26:23','2026-03-02 13:26:23',0),(113,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNDU3OTg0LCJleHAiOjE3NzMwNjI3ODR9.yzXNGiVJMzh8ZnzKd_6AUoU7hqRgeQ169liogLA4uWU','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:26:24','2026-03-02 13:26:24',0),(114,60,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MjQ1Nzk4NSwiZXhwIjoxNzczMDYyNzg1fQ.3aQWOAMw610yq1ejND3As9O3bFvW6j7E7943AF5lw9k','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:26:25','2026-03-02 13:26:25',0),(115,61,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzcyNDU3OTg2LCJleHAiOjE3NzMwNjI3ODZ9.wYsfn8IP0GB1pJS9EF-c4pGGCQS_uRXysp8NuM8pjho','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:26:26','2026-03-02 13:26:26',0),(116,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjQ1ODAxNSwiZXhwIjoxNzczMDYyODE1fQ.mtMlLNgV_BqrMcZCTX5gQaV_kjqxQnYqh1ggfhqNMys','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:26:55','2026-03-02 13:26:55',0),(117,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjQ1ODAxNiwiZXhwIjoxNzczMDYyODE2fQ.dJR2KFPk81ACf5E0BD7r8qVxIsX0wCx6uvM5XSe_aDU','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:26:56','2026-03-02 13:26:56',0),(118,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNDU4MDE3LCJleHAiOjE3NzMwNjI4MTd9._JtPX6P9xBtft1AzxKZB3jw5RVYaCQbl7FYuV-qYkbA','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:26:57','2026-03-02 13:26:57',0),(119,60,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MjQ1ODAxOCwiZXhwIjoxNzczMDYyODE4fQ.s_iGGwKJFvCEj0MfK4R5sCQpMI_hmSNGyozZQ6_DTvc','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:26:58','2026-03-02 13:26:58',0),(120,61,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzcyNDU4MDIwLCJleHAiOjE3NzMwNjI4MjB9.14ikw8qmjfGYzUB46G-U5m4c1axJKLzeSsO5FyNp1Hc','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:27:00','2026-03-02 13:27:00',0),(121,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNDU4MDIyLCJleHAiOjE3NzMwNjI4MjJ9.XFTg2dvLrJBDzVjbc2f-rfETOvxNMmjT0S42WKLRxWM','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:27:02','2026-03-02 13:27:02',0),(123,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNDU4MDI1LCJleHAiOjE3NzMwNjI4MjV9.MBvenZ8of-ZATv2kG6N8oTfwdAQhP6ReTbfcTCa1Qz8','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:27:05','2026-03-02 13:27:05',0),(124,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNDU4MDU4LCJleHAiOjE3NzMwNjI4NTh9.RrfC4O4AxgpM52W_Ziy41v4e_LoDDhYVUl-Ql4056rc','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:27:38','2026-03-02 13:27:38',0),(125,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjQ1ODEwMiwiZXhwIjoxNzczMDYyOTAyfQ.nWFDZm5LOFxkw2nJGtuUov3WshoFcEEAZUq4tPRAIvM','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:28:22','2026-03-02 13:28:22',0),(126,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjQ1ODEwMywiZXhwIjoxNzczMDYyOTAzfQ.FglPBPPBH7nfQBDbOe4ATwYwCkMUe-dZW0UHyhnwilA','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:28:23','2026-03-02 13:28:23',0),(127,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNDU4MTA0LCJleHAiOjE3NzMwNjI5MDR9.zQN36WBhyqdJaB34vs0Des643YQ9kktEdCdGc648x88','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:28:24','2026-03-02 13:28:24',0),(128,60,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MjQ1ODEwNSwiZXhwIjoxNzczMDYyOTA1fQ.Jbu5JJzEh9jyJcLvkNutoMetopqwQ9FHREH8jctfX4s','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:28:25','2026-03-02 13:28:25',0),(129,61,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzcyNDU4MTA2LCJleHAiOjE3NzMwNjI5MDZ9.xxnuVIYPJDGE6LEcKV1Qb54hBxIRxpVtQuu2lnOrqUY','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:28:26','2026-03-02 13:28:26',0),(130,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjQ1ODE4NiwiZXhwIjoxNzczMDYyOTg2fQ.8ANquPJfrQYyP1ufWFKKt1clGDQuo1fY_hCU6_coPb8','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:29:46','2026-03-02 13:29:46',0),(131,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjQ1ODE4NywiZXhwIjoxNzczMDYyOTg3fQ.vkxq0Z_vcz0VFDpop2y25PgWlWEl6HPfHnRquBlOnQs','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:29:47','2026-03-02 13:29:47',0),(132,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNDU4MTg4LCJleHAiOjE3NzMwNjI5ODh9.R5i8NwvgX_tC8YNyuPbuSwYUud71Ktuut8wPcWkxNa0','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:29:48','2026-03-02 13:29:48',0),(133,60,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MjQ1ODE4OSwiZXhwIjoxNzczMDYyOTg5fQ.SfPouYynNA4bTT7poH1jRhMukqitetQYeCIMWcrwdlk','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:29:49','2026-03-02 13:29:49',0),(134,61,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzcyNDU4MTkwLCJleHAiOjE3NzMwNjI5OTB9.3E08UPLeH36Z8KFirxwYUOjMYuh08xiAykYLhltt87s','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:29:50','2026-03-02 13:29:50',0),(135,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjQ1ODI2OCwiZXhwIjoxNzczMDYzMDY4fQ.npGKlX-Orcn1W8egIVgLslSSFM-iTQVgIVfb4XIh7dE','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:31:08','2026-03-02 13:31:08',0),(136,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjQ1ODI3MCwiZXhwIjoxNzczMDYzMDcwfQ.gx6TS_utIOkGyNDbnVwVY1rVo2Rcqcapk_Y7VfhsV20','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:31:10','2026-03-02 13:31:10',0),(137,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNDU4MjcxLCJleHAiOjE3NzMwNjMwNzF9.xOkZSrC1YYALcfgdb4BeYIMNOn20ynOMCdfdOLNFBwk','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:31:11','2026-03-02 13:31:11',0),(138,60,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MjQ1ODI3MiwiZXhwIjoxNzczMDYzMDcyfQ.9LParNysweYTwkWp-P04Tz7_mZb5ASEZS2ogWQfwDAY','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:31:12','2026-03-02 13:31:12',0),(139,61,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzcyNDU4MjczLCJleHAiOjE3NzMwNjMwNzN9.AWNFNy0JBYktWvEVHN5mgX7V6Fbx_cct9838H0Qa0O8','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:31:13','2026-03-02 13:31:13',0),(140,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjQ1ODMzNSwiZXhwIjoxNzczMDYzMTM1fQ.RRmntGmYLwUpqT5PzHo5P-wXP0P1Ah8Kf0jv3gO0d_E','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:32:15','2026-03-02 13:32:15',0),(141,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjQ1ODMzNiwiZXhwIjoxNzczMDYzMTM2fQ.Zpor2RBtCgJTZSuaumuZhRmef3IqIFWsQ37xMjGyOGQ','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:32:16','2026-03-02 13:32:16',0),(142,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNDU4MzM3LCJleHAiOjE3NzMwNjMxMzd9.1DK98HsuxAMFfgJQ211oFzsT6k3mDQxe_jvv4SfYRcE','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:32:17','2026-03-02 13:32:17',0),(143,60,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MjQ1ODMzOCwiZXhwIjoxNzczMDYzMTM4fQ.CBWImHCs5mNGguJoAMqnfRU4oNZSCw-o33Zwr20GzlM','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:32:18','2026-03-02 13:32:18',0),(144,61,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzcyNDU4MzM5LCJleHAiOjE3NzMwNjMxMzl9.xef3Rwt29owN0tkOwz4OLyaZjYYzi8953IV3VfrbEw4','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:32:19','2026-03-02 13:32:19',0),(145,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjQ1ODQ3MSwiZXhwIjoxNzczMDYzMjcxfQ.s-4GllGdMj0W2AxrhzNrV8pncDFcg9obRlOz2uh8OiE','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:34:31','2026-03-02 13:34:31',0),(146,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjQ1ODQ3MiwiZXhwIjoxNzczMDYzMjcyfQ.od--UovKqLmk-2rmk3fjCaIK_6517_zPgv_jN4FbNQI','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:34:32','2026-03-02 13:34:32',0),(147,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNDU4NDczLCJleHAiOjE3NzMwNjMyNzN9.PsAxTeZciWqpI4bEC8Nt8lP3gy3HrGwGzZvweWgAXqg','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:34:33','2026-03-02 13:34:33',0),(148,60,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MjQ1ODQ3NCwiZXhwIjoxNzczMDYzMjc0fQ.6mZYD1OulOAAImXGrSQraQknUz6eQcmQr_rikc-ORuQ','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:34:34','2026-03-02 13:34:34',0),(149,61,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzcyNDU4NDc1LCJleHAiOjE3NzMwNjMyNzV9.RnuY__lxGNOTFabgJw6VkL6M-89iD1HOrW2WoiUMBj8','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:34:35','2026-03-02 13:34:35',0),(150,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjQ1ODQ5NiwiZXhwIjoxNzczMDYzMjk2fQ.zxBnZnSn40-JNKGDyc7liZtel-0FoLIb7dS4rGEt7Gg','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:34:56','2026-03-02 13:34:56',0),(151,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNDU4NDk5LCJleHAiOjE3NzMwNjMyOTl9.jg8ytxOIilv_liCtRZmBUP-YFqfRJwLgAYUGmAUxPkg','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:34:59','2026-03-02 13:34:59',0),(152,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNDU5MTA3LCJleHAiOjE3NzMwNjM5MDd9.3cTCamjP8CIs4V6QQyPnHS9lvdXiaprILZHznTI83q4','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:45:07','2026-03-02 13:45:07',0),(153,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNDU5MTE3LCJleHAiOjE3NzMwNjM5MTd9.a-wn85SVilm1W6sBrGda79UVRprzB8NsAQCMs0295fw','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:45:17','2026-03-02 13:45:17',0),(154,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjQ1OTMyOSwiZXhwIjoxNzczMDY0MTI5fQ.42V8Ox7hTEcNkiuIhyXSk7GHnscaHRDtoOeJD2Fjldw','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:48:49','2026-03-02 13:48:49',0),(155,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjQ1OTMzMCwiZXhwIjoxNzczMDY0MTMwfQ.8N3TcKta0n__3z0DSecx7JV5HOPz4PUva7Jw8mrb5Ik','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:48:50','2026-03-02 13:48:50',0),(156,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNDU5MzMxLCJleHAiOjE3NzMwNjQxMzF9.5rXS1Bog5XkhI474yKqMgctNdFaetrByXFbDyg-DB6A','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:48:51','2026-03-02 13:48:51',0),(157,60,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MjQ1OTMzMiwiZXhwIjoxNzczMDY0MTMyfQ.X1Viv9HkFImQbupphM8WLihQZiQDi8KcmQw8fKNQ-kc','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:48:52','2026-03-02 13:48:52',0),(158,61,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzcyNDU5MzMzLCJleHAiOjE3NzMwNjQxMzN9.B6bvOCg4P5J5zl9LDzrKsxNDz6ex7buN6NcZ9tXriB0','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:48:53','2026-03-02 13:48:53',0),(159,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNDU5MzM0LCJleHAiOjE3NzMwNjQxMzR9.IsOMY1xbVp8DlFwP3LHFMKD7gRxgqYTbh14wEIBcCZQ','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:48:54','2026-03-02 13:48:54',0),(160,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNDU5MzM3LCJleHAiOjE3NzMwNjQxMzd9.pur4ZKvmFB8Bksrx67QNt2AC4OW7rDPWywcudHKZ9c0','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:48:57','2026-03-02 13:48:57',0),(161,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50IiwiaW5zdHJ1Y3RvciJdLCJpYXQiOjE3NzI0NTk0MDMsImV4cCI6MTc3MzA2NDIwM30.YbLv-gX9xBfFD7LrZwNbZJTfgSVEiTLfvX5IN3eChv8','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:50:03','2026-03-02 13:50:03',0),(162,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjQ1OTQwNSwiZXhwIjoxNzczMDY0MjA1fQ.PinnDX0_gIKwHIebnvvQ1Gct-U9nHBf6I5mo3i6ug1w','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:50:05','2026-03-02 13:50:05',0),(163,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNDU5NDA2LCJleHAiOjE3NzMwNjQyMDZ9.EmdYlE2-esGZhpIfJX514CP_RFA6_bZH8wO2IluHoYU','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:50:06','2026-03-02 13:50:06',0),(164,60,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MjQ1OTQwNywiZXhwIjoxNzczMDY0MjA3fQ.JBH-TpbL8tmWt_hK7wY9MTNgtSZUB-5ocH2TpxBY8II','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:50:07','2026-03-02 13:50:07',0),(165,61,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzcyNDU5NDA4LCJleHAiOjE3NzMwNjQyMDh9.eSlyY_96QSSZP8wj7EPA-DVib39XHhpI38qpvf4G1xU','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:50:08','2026-03-02 13:50:08',0),(166,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50IiwiaW5zdHJ1Y3RvciJdLCJpYXQiOjE3NzI0NTk0NjMsImV4cCI6MTc3MzA2NDI2M30.Ou1OxNwxs7KxUx2ubEe13VKSxyzlkEjZsG2XCrN9Bz4','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:51:03','2026-03-02 13:51:03',0),(167,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjQ1OTQ2NCwiZXhwIjoxNzczMDY0MjY0fQ.2fvjZUezO8ISd2n_hkgaplkgZZhCrPPNkoH6mWHJixE','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:51:04','2026-03-02 13:51:04',0),(168,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNDU5NDY1LCJleHAiOjE3NzMwNjQyNjV9.9zwTLCgRB3xjcRR-d64i6gazF2V3yTj-jwSf32kaRIM','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:51:05','2026-03-02 13:51:05',0),(169,60,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MjQ1OTQ2NywiZXhwIjoxNzczMDY0MjY3fQ.TnlFpr10pa60WUq_YCrUI_AvXITsahvh2vT1hYUoiH0','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:51:07','2026-03-02 13:51:07',0),(170,61,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzcyNDU5NDY4LCJleHAiOjE3NzMwNjQyNjh9.nMlKKIM-Ncmm6C1ERTGGSEvJ18_X9SsLmtqX059HIGo','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:51:08','2026-03-02 13:51:08',0),(171,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50IiwiaW5zdHJ1Y3RvciJdLCJpYXQiOjE3NzI0NTk2MzIsImV4cCI6MTc3MzA2NDQzMn0.7djQ2ZacNr7I2aHrtYgKF4l3njdk2crOlDh-OnFSOGY','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:53:52','2026-03-02 13:53:52',0),(172,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNDU5NjUxLCJleHAiOjE3NzMwNjQ0NTF9.3N7K5hW4CaF36mSUT_rCxS3Ow6hzT42UKp9rg8JIXdA','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:54:11','2026-03-02 13:54:11',0),(173,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjQ1OTY1MywiZXhwIjoxNzczMDY0NDUzfQ.ljb3lEniXfdJn_Nu61u4ZuqxXashYTnC1wSfB9t7BYA','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:54:13','2026-03-02 13:54:13',0),(174,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjQ1OTY3OCwiZXhwIjoxNzczMDY0NDc4fQ.VhG6r7R62deapTGuWLKyMCmb67z8pigGGyVvA-tVtZs','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:54:38','2026-03-02 13:54:38',0),(175,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjQ1OTY3OSwiZXhwIjoxNzczMDY0NDc5fQ.F4q0oiB7AORj4UPzK-hBpjs14tk2J7Jv3NK5ZtJkFoI','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:54:39','2026-03-02 13:54:39',0),(176,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNDU5NjgwLCJleHAiOjE3NzMwNjQ0ODB9.NZ6MdPSkBoS8rqYfgLniIz41KYaDVQX7uXUPj6XIKPQ','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:54:40','2026-03-02 13:54:40',0),(177,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNDU5NzM4LCJleHAiOjE3NzMwNjQ1Mzh9.2KyCcqCZqpSeg4p-Zpe0uFgPX5muuMDlBim0vhjSmvQ','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 13:55:38','2026-03-02 13:55:38',0),(178,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjQ2MDI1MCwiZXhwIjoxNzczMDY1MDUwfQ.8WI-0AjH6c0tgBT9A_BK5eKj6iv3d8V6Z_HSWrpIdnE','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 14:04:10','2026-03-02 14:04:10',0),(179,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjQ2MDI1MiwiZXhwIjoxNzczMDY1MDUyfQ.koC88F_q0Zz2N8dNOLD0eSion03K6q8-fRWpeG2Y9kY','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 14:04:12','2026-03-02 14:04:12',0),(180,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNDYwMjUzLCJleHAiOjE3NzMwNjUwNTN9.B4sti42V8xEKJ6W1oZY98SxDxFKXAI1SGdyQnbZS-Co','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 14:04:13','2026-03-02 14:04:13',0),(181,60,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MjQ2MDI1NCwiZXhwIjoxNzczMDY1MDU0fQ.35FmlsSb4wpIUTK8m50RRAP1JGLHH85PgQKCV4lOPKU','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 14:04:14','2026-03-02 14:04:14',0),(182,61,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzcyNDYwMjU1LCJleHAiOjE3NzMwNjUwNTV9.8oDVVxfewDDmJwK0OahnGp4fFGgsUQOE1m0kJqU8i3I','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 14:04:15','2026-03-02 14:04:15',0),(183,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNDYwMjU2LCJleHAiOjE3NzMwNjUwNTZ9.bGsqwE_v-cb4YFOJXzfZm_KSahluE4tahpD9A__-Bng','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 14:04:16','2026-03-02 14:04:16',0),(184,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNDYwMjU5LCJleHAiOjE3NzMwNjUwNTl9.-zBpfcry7zurNLLcoAnNLpmsdA01wlbPkbOxTpKUhKs','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 14:04:19','2026-03-02 14:04:19',0),(185,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjQ2MDMzNiwiZXhwIjoxNzczMDY1MTM2fQ.CYhBoQwjlyR9HhuYbyrT1tTBXyeoKfm6C_9vX1f4gNw','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 14:05:36','2026-03-02 14:05:36',0),(186,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjQ2MDMzNywiZXhwIjoxNzczMDY1MTM3fQ.W4q4q994_GmON9v1vhOtivKswxfQuK3jWsG8Kw9Ie3E','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 14:05:37','2026-03-02 14:05:37',0),(187,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNDYwMzM4LCJleHAiOjE3NzMwNjUxMzh9.gWzOD3qoziAXAPEl4anOaXzJt-7QIY1SW4tK_eBPT6k','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 14:05:38','2026-03-02 14:05:38',0),(188,60,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MjQ2MDM0MCwiZXhwIjoxNzczMDY1MTQwfQ.h2cIduQS0lg5y7RhVAdF3GCSnYo93Ujet1cdJNWCcyI','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 14:05:40','2026-03-02 14:05:40',0),(189,61,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzcyNDYwMzQxLCJleHAiOjE3NzMwNjUxNDF9.fRw_JMspiO9LoSxv69p9_SgMRBSmY9AFMogaR7T2m68','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 14:05:41','2026-03-02 14:05:41',0),(190,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjQ2MDQwNiwiZXhwIjoxNzczMDY1MjA2fQ.dq4Hh86dYUCqEFZNQUFzdHogiZ2RGVzOC7Bge_oKfoE','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 14:06:46','2026-03-02 14:06:46',0),(191,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjQ2MDQyNiwiZXhwIjoxNzczMDY1MjI2fQ.cHemDIySwY7zQ5B5VQ5RuiXKUDxDL88PJTuZfjupwKw','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 14:07:06','2026-03-02 14:07:06',0),(192,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjQ2MDQzNiwiZXhwIjoxNzczMDY1MjM2fQ.mWVrUk6ZvCpvoOC3kChagducxcxileZkaQht9DYT9P4','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 14:07:16','2026-03-02 14:07:16',0),(193,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjQ2MDQ0NiwiZXhwIjoxNzczMDY1MjQ2fQ.JBg_hSRzWLjFMBnNpguUChTe0gnfVC-Xp_54qusT4WQ','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 14:07:26','2026-03-02 14:07:26',0),(194,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjQ2MDQ3OSwiZXhwIjoxNzczMDY1Mjc5fQ.SR9Otm58226bB3DMsr_nHw9I_EUToc2_w2KKfXp0E_o','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 14:07:59','2026-03-02 14:07:59',0),(195,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjQ2MDQ4MCwiZXhwIjoxNzczMDY1MjgwfQ.SqVCuLF51w4GrQqR5qFU_KfAD97Akqy7cAYAfXkRkWk','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 14:08:00','2026-03-02 14:08:00',0),(196,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNDYwNDgxLCJleHAiOjE3NzMwNjUyODF9.K3Ie0ywTyVugF46f48G1iW9s5NEhoYZvLRRbVsj_tYQ','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 14:08:01','2026-03-02 14:08:01',0),(197,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjQ2MDUzNywiZXhwIjoxNzczMDY1MzM3fQ.F-jNRKc9W-6aVa7DFf0wgCwXwFEOAjYN53uuov0J0Tg','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 14:08:57','2026-03-02 14:08:57',0),(198,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjQ2MDUzOCwiZXhwIjoxNzczMDY1MzM4fQ.gQc_AlmLG_RSDhckbvnLpKx6Dkg7VrpkyhT2XWwEHwk','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 14:08:58','2026-03-02 14:08:58',0),(199,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNDYwNTM5LCJleHAiOjE3NzMwNjUzMzl9.SnFgRHPKrs8RiQxTMCYKyAQj1-oD5QTLVX4fslfXqeE','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 14:08:59','2026-03-02 14:08:59',0),(200,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjQ2MDYxMywiZXhwIjoxNzczMDY1NDEzfQ.f1uwEUAYji2CY19JbmQx_BQB11zyNWAaA8TjGj-Aw-A','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 14:10:13','2026-03-02 14:10:13',0),(201,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjQ2MDYxNCwiZXhwIjoxNzczMDY1NDE0fQ.uyEAWXygIoPXYMr4OIOgdoWE2sU5yviS0yGEsZaLVzA','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 14:10:14','2026-03-02 14:10:14',0),(202,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjQ2MDY1MiwiZXhwIjoxNzczMDY1NDUyfQ.7NMsjG17GYQAyg7594QHHb2yLZXLgFQ0D_a96nvzdzc','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 14:10:52','2026-03-02 14:10:52',0),(203,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjQ2MDY3MCwiZXhwIjoxNzczMDY1NDcwfQ.6XYfDFdpZoNf-wyEZ6DjanbBLlr44xjNbIgYGDlK6IU','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-09 14:11:10','2026-03-02 14:11:10',0),(204,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjQ2MTc4NywiZXhwIjoxNzczMDY2NTg3fQ.Kfg8lPw4LE7crt35xwdboxj3CNhC21Sy8ILflv8OoiU','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','desktop','2026-03-09 14:29:47','2026-03-02 14:29:47',0),(205,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNDYxODg4LCJleHAiOjE3NzMwNjY2ODh9.6wJB3EIlsHUztlcYLtUwQf-7_32epMRVHWZjXot2PA4','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','desktop','2026-03-09 14:31:28','2026-03-02 14:31:28',0),(206,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjQ5MzkzMywiZXhwIjoxNzczMDk4NzMzfQ.ugxvp8JR0bfvWYV_1y5tVFP5GTsDGHnpYMKRFHe0Vl4','127.0.0.1','PostmanRuntime/7.49.1','desktop','2026-03-09 23:25:33','2026-03-02 23:25:33',0),(207,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjQ5NDAwMCwiZXhwIjoxNzczMDk4ODAwfQ.W3fzVJ_FsUKc-XJxgwHt3SykzUltBv6ClvnR01SNWeA','127.0.0.1','PostmanRuntime/7.49.1','desktop','2026-03-09 23:26:40','2026-03-02 23:26:40',0),(208,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNDk0MDE1LCJleHAiOjE3NzMwOTg4MTV9.pEu0eY5w1TJSQAhq6QlZSs48o1fNP9VkaKo8qIa17iU','127.0.0.1','PostmanRuntime/7.49.1','desktop','2026-03-09 23:26:55','2026-03-02 23:26:55',0),(209,60,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MjQ5NDAzMCwiZXhwIjoxNzczMDk4ODMwfQ.gc6BfnADZxsih3G6_6ZO3dVB2vz8kCuakn49996GCF0','127.0.0.1','PostmanRuntime/7.49.1','desktop','2026-03-09 23:27:10','2026-03-02 23:27:10',0),(210,61,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzcyNDk0MDQ1LCJleHAiOjE3NzMwOTg4NDV9.SeZgTlxobYGTg-DhCvmKjLrijrVEBO0FaFDM1lWyS9Y','127.0.0.1','PostmanRuntime/7.49.1','desktop','2026-03-09 23:27:25','2026-03-02 23:27:25',0),(211,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjQ5NDk1NywiZXhwIjoxNzczMDk5NzU3fQ.fFJc9XrbcRYPZSLeFnBaT7VgM-OdcZ7zlaFqOZaUpRc','127.0.0.1',NULL,'','2026-03-09 23:42:37','2026-03-02 23:42:37',0),(212,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjQ5NDk1NywiZXhwIjoxNzczMDk5NzU3fQ.dnxlxXFNaTuTod8xFZ_b-doYMB5jz779_XFmVaCs3Ec','127.0.0.1',NULL,'','2026-03-09 23:42:37','2026-03-02 23:42:37',0),(213,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNDk0OTU3LCJleHAiOjE3NzMwOTk3NTd9.ta0C13xHdjVy-YTLFgFR56twhCIpFiuOV5yaTvDDSl0','127.0.0.1',NULL,'','2026-03-09 23:42:37','2026-03-02 23:42:37',0),(214,60,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MjQ5NDk1OCwiZXhwIjoxNzczMDk5NzU4fQ.iSemHapJbRh7KO6i1i2YHFE3FBnz0z65SP1uHxvlA9M','127.0.0.1',NULL,'','2026-03-09 23:42:38','2026-03-02 23:42:38',0),(215,61,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzcyNDk0OTU4LCJleHAiOjE3NzMwOTk3NTh9.2BGIcrG5W3pEVKZIqLQrXnklU3B1dkovlx7SeRyz9g4','127.0.0.1',NULL,'','2026-03-09 23:42:38','2026-03-02 23:42:38',0),(216,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjQ5NTAxMCwiZXhwIjoxNzczMDk5ODEwfQ.4JRPF_rk62ISnW10Px1pzrZCAycaYvw-a-bbL-RGaoU','127.0.0.1',NULL,'','2026-03-09 23:43:30','2026-03-02 23:43:30',0),(217,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjQ5NTAxMCwiZXhwIjoxNzczMDk5ODEwfQ.pxjgspo8Kpcq-I3-yRizxdwkil-QoGsZzsjJ2ls7Uak','127.0.0.1',NULL,'','2026-03-09 23:43:30','2026-03-02 23:43:30',0),(218,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjQ5NTA0MywiZXhwIjoxNzczMDk5ODQzfQ.ZVEI0xKcbCQttCrL_jDn0FwrRcH7gfyP2nhTeXo8L8s','127.0.0.1',NULL,'','2026-03-09 23:44:03','2026-03-02 23:44:03',0),(219,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjQ5NTA0MywiZXhwIjoxNzczMDk5ODQzfQ.hLY7TclThJjWx4AX50R0RlXCrXmwkdsAcuz-_er14Ik','127.0.0.1',NULL,'','2026-03-09 23:44:03','2026-03-02 23:44:03',0),(220,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjQ5NTA1OSwiZXhwIjoxNzczMDk5ODU5fQ.ICPJPd5OnNElGPWZ1Q_o9JKsObA3Z3Vm5jbq5TRiIxM','127.0.0.1',NULL,'','2026-03-09 23:44:19','2026-03-02 23:44:19',0),(221,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjQ5NTI0MCwiZXhwIjoxNzczMTAwMDQwfQ.gKO4L31TDPmGqlEA9GvJy1hLcY9KLoqG28Gfx9hS4TU','127.0.0.1',NULL,'','2026-03-09 23:47:20','2026-03-02 23:47:20',0),(222,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjQ5NTI0MCwiZXhwIjoxNzczMTAwMDQwfQ.c7JlXXF170LFoDaL_YG4FQCRA5aB3G1U2l5ndy8HKaQ','127.0.0.1',NULL,'','2026-03-09 23:47:20','2026-03-02 23:47:20',0),(223,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNDk1MjQxLCJleHAiOjE3NzMxMDAwNDF9.DKmiUKx-_MA3XOYqZHYFJLd3H9LIBVH5GqpygqNzGeY','127.0.0.1',NULL,'','2026-03-09 23:47:21','2026-03-02 23:47:21',0),(224,60,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MjQ5NTI0MSwiZXhwIjoxNzczMTAwMDQxfQ.6GscVl5NMmnsPYOSoNrKkGhjs0EcRA0E9WDRBzKIPVo','127.0.0.1',NULL,'','2026-03-09 23:47:21','2026-03-02 23:47:21',0),(225,61,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzcyNDk1MjQxLCJleHAiOjE3NzMxMDAwNDF9.kJckShzNuMsd95Mgw3PY-F7ALycWBC61SSb7nOvQ0cA','127.0.0.1',NULL,'','2026-03-09 23:47:21','2026-03-02 23:47:21',0),(226,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjQ5NTM4MCwiZXhwIjoxNzczMTAwMTgwfQ.dK2sdRrjmObsmhPOlrA8hgzxfKwwevlKaoSBCWovRf8','127.0.0.1','PostmanRuntime/7.51.1','desktop','2026-03-09 23:49:40','2026-03-02 23:49:40',0),(227,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjQ5NTM5OSwiZXhwIjoxNzczMTAwMTk5fQ.wCS1XWq5MAXhcZ13qISNoi0Z1bPH93QWsZfGNePs4-A','127.0.0.1','PostmanRuntime/7.51.1','desktop','2026-03-09 23:49:59','2026-03-02 23:49:59',0),(228,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNDk1NDExLCJleHAiOjE3NzMxMDAyMTF9.-BkjiWiI8X7QDIfFvH-t_TgNlzjTxj2fLZBnysEvWOQ','127.0.0.1','PostmanRuntime/7.51.1','desktop','2026-03-09 23:50:11','2026-03-02 23:50:11',0),(229,60,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MjQ5NTQ0MywiZXhwIjoxNzczMTAwMjQzfQ.35suJaBXCxBeDlEoHqNdokSucbz38aCf7WxCMbtOfC4','127.0.0.1','PostmanRuntime/7.51.1','desktop','2026-03-09 23:50:43','2026-03-02 23:50:43',0),(230,61,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzcyNDk1NDYwLCJleHAiOjE3NzMxMDAyNjB9.bZY1lQYaHZLNInLGS7CGyuJQxo1fIxXB4EkKd5ZyZx8','127.0.0.1','PostmanRuntime/7.51.1','desktop','2026-03-09 23:51:00','2026-03-02 23:51:00',0),(231,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNDk2NTkxLCJleHAiOjE3NzMxMDEzOTF9.MGweTB98iD3_jr3ErO5ami6rR6OyX2Hk6OCivv7QIMg','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-10 00:09:51','2026-03-03 00:09:51',0),(232,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjQ5NjU5MiwiZXhwIjoxNzczMTAxMzkyfQ.b6FGQqhoLyQPAwA7hfBT7gX2y9AC_gKeJl3-sjTvuIU','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-10 00:09:52','2026-03-03 00:09:52',0),(233,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjQ5NjU5MywiZXhwIjoxNzczMTAxMzkzfQ.QYR2oSWIpzy84lbnWLeuI_BaE-3t7iS5JwyqlWAV9Lg','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-10 00:09:53','2026-03-03 00:09:53',0),(234,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjQ5NjY0MCwiZXhwIjoxNzczMTAxNDQwfQ.EqIVxOk7Qy88_0Js1M7KXl4i91rrivc5wyMdgiVJViM','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-10 00:10:40','2026-03-03 00:10:40',0),(235,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNDk2NjQxLCJleHAiOjE3NzMxMDE0NDF9.Im8nTQj1Th3XV0PbqoyI1hyDFevn_p_LIPeIyAX518c','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-10 00:10:41','2026-03-03 00:10:41',0),(236,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjQ5NzMxOCwiZXhwIjoxNzczMTAyMTE4fQ.5lILfFZ3CNqafhC26t9OOX3PRCEV_D2_VP7W1n8_me8','127.0.0.1','PostmanRuntime/7.51.1','desktop','2026-03-10 00:21:58','2026-03-03 00:21:58',0),(237,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjQ5NzMxOCwiZXhwIjoxNzczMTAyMTE4fQ.4htjJZ-dHtiqxEbTkddBZASovcSienjCWn_ZRABuer8','127.0.0.1','PostmanRuntime/7.51.1','desktop','2026-03-10 00:21:58','2026-03-03 00:21:58',0),(238,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNDk3MzE4LCJleHAiOjE3NzMxMDIxMTh9.Kg1463tQsOfxZRitcIs6XIiF_siFHfhDZHHjzguAK94','127.0.0.1','PostmanRuntime/7.51.1','desktop','2026-03-10 00:21:58','2026-03-03 00:21:58',0),(239,60,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MjQ5NzMxOCwiZXhwIjoxNzczMTAyMTE4fQ.rC9QTa2mniUxvaO7qsAc7oC80gk0cU21AK95kIaU_vw','127.0.0.1','PostmanRuntime/7.51.1','desktop','2026-03-10 00:21:58','2026-03-03 00:21:59',0),(240,61,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzcyNDk3MzE5LCJleHAiOjE3NzMxMDIxMTl9.EtYHz0SKrvkUSd0tYHo6ZNlo_9bSIfZ3LAAYwUdFAnE','127.0.0.1','PostmanRuntime/7.51.1','desktop','2026-03-10 00:21:59','2026-03-03 00:21:59',0),(241,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNTYxNDY4LCJleHAiOjE3NzMxNjYyNjh9.xookekgvYWKrbITlRXabDPNLcFEdmcPv2HIaGTdc1PE','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-10 18:11:08','2026-03-03 18:11:08',0),(242,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNTYxNDc0LCJleHAiOjE3NzMxNjYyNzR9.gd3JOa9st32ug4ms2RQlt5SsaRn0kOCmyGF3KqIn1bc','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-10 18:11:14','2026-03-03 18:11:14',0),(243,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjU2MTQ4NCwiZXhwIjoxNzczMTY2Mjg0fQ.TeQEl2ABPoIxmDn0qm-pUGq2ztDZBeVfhOPNihHq6dE','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-10 18:11:24','2026-03-03 18:11:24',0),(244,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjU2MTQ4NSwiZXhwIjoxNzczMTY2Mjg1fQ.6HzM2Ok10vTeT0dWeTcUYMqAbF6P5VRbumFyhEpCERM','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-10 18:11:25','2026-03-03 18:11:25',0),(245,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNTYxNDg2LCJleHAiOjE3NzMxNjYyODZ9.M3fY6heNGwToTFn26lcr-OY-9W-_W5wMuKHvpBfLvi8','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-10 18:11:26','2026-03-03 18:11:26',0),(246,60,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MjU2MTQ4NywiZXhwIjoxNzczMTY2Mjg3fQ.epYDKupTKKjO_bBGadqNAEt7l70s8CZunjcFxMGxa3g','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-10 18:11:27','2026-03-03 18:11:27',0),(247,61,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzcyNTYxNDg4LCJleHAiOjE3NzMxNjYyODh9.E5Xrpolgty1CF00KYjQH0MazBngDGYQLHeC0pN4xm-A','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-10 18:11:28','2026-03-03 18:11:28',0),(248,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjU2MTY4MiwiZXhwIjoxNzczMTY2NDgyfQ.-brZNhhdbhLCSdQf2cjHqhj7ZllZsmkQGXFn3DGIW9g','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-10 18:14:42','2026-03-03 18:14:42',0),(249,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjU2MTY4MywiZXhwIjoxNzczMTY2NDgzfQ.gbI579cMApasc98ra8DP3JX9sAfj9FUVkXQ_BgtJrwQ','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-10 18:14:43','2026-03-03 18:14:43',0),(250,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNTYxNjg0LCJleHAiOjE3NzMxNjY0ODR9.1Elo7GZTUrOKSfRYzOle7Flw5KHAaFW--c1d4CxJGiM','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-10 18:14:44','2026-03-03 18:14:44',0),(251,60,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MjU2MTY4NSwiZXhwIjoxNzczMTY2NDg1fQ.g28hRe9jBb9izv_3OCqMW-VYIIfHaP4cjAQSVNJDSks','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-10 18:14:45','2026-03-03 18:14:45',0),(252,61,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzcyNTYxNjg2LCJleHAiOjE3NzMxNjY0ODZ9.ZAXtjgTr3ge6EHD5vy0CuPD12lRhqAYpGPD_-_E7pLI','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-10 18:14:46','2026-03-03 18:14:46',0),(253,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjU2MTc5NiwiZXhwIjoxNzczMTY2NTk2fQ.DubARO9p5hYKbu9pN8-7ZHNgZaUh59gQMhQ0gWak_30','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-10 18:16:36','2026-03-03 18:16:36',0),(254,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjU2MTc5NywiZXhwIjoxNzczMTY2NTk3fQ.f1o0hPHOE9aT3e4O5vXPvSF5yf8Fus8AXGH7ZvjI1JQ','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-10 18:16:37','2026-03-03 18:16:37',0),(255,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNTYxNzk4LCJleHAiOjE3NzMxNjY1OTh9.a0iC9EZJKZlgnm5ph-jV4u79v6yo_vg_Zs0pwQcOsX0','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-10 18:16:38','2026-03-03 18:16:38',0),(256,60,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MjU2MTc5OSwiZXhwIjoxNzczMTY2NTk5fQ.Gu3bbg9SeetSVaRqVMikKKrEQj3qJJuR8DQGYbMcIHE','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-10 18:16:39','2026-03-03 18:16:39',0),(257,61,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzcyNTYxODAwLCJleHAiOjE3NzMxNjY2MDB9.2H_qfQe5v9kwYmU2MLDolCFSbN_tx7oY5A0rdxl5dLA','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-10 18:16:40','2026-03-03 18:16:40',0),(258,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjU2MTkwMiwiZXhwIjoxNzczMTY2NzAyfQ.aQWgdxmDSDz5g4u_oZSsUyjHMdbG1P6Rq0VXGStTR-Q','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-10 18:18:22','2026-03-03 18:18:22',0),(259,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjU2MTkwMywiZXhwIjoxNzczMTY2NzAzfQ.0Rg5H1gSNBtPeS1yz83DeZGAF9awtVmI77cYXU-lZfE','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-10 18:18:23','2026-03-03 18:18:23',0),(260,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNTYxOTA1LCJleHAiOjE3NzMxNjY3MDV9.OMr0weCvZKzOoxvGUiniEe5hDh0UKFvn1-b1m_IiY0E','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-10 18:18:25','2026-03-03 18:18:25',0),(261,60,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MjU2MTkwNiwiZXhwIjoxNzczMTY2NzA2fQ.rcX5oqqFuyYqMd6XGj1ZDHqqVPQBgToxRJrKaVZWLzI','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-10 18:18:26','2026-03-03 18:18:26',0),(262,61,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzcyNTYxOTA3LCJleHAiOjE3NzMxNjY3MDd9.9V6H_bRzo7PUieFC_Ob1irepG_XWJuAQ0OGCoZ93DQA','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-10 18:18:27','2026-03-03 18:18:27',0),(263,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjU2MjAxMSwiZXhwIjoxNzczMTY2ODExfQ._29Nw7C6lXe9mOIfq8eD-Tvpac1fMFMgMIqPSWxWz-g','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-10 18:20:11','2026-03-03 18:20:11',0),(264,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjU2MjAxMywiZXhwIjoxNzczMTY2ODEzfQ.C2k8tM3E9bS7ezx7tFrlWxPsL95uBeaTulIRlu_ZE4k','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-10 18:20:13','2026-03-03 18:20:13',0),(265,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNTYyMDE0LCJleHAiOjE3NzMxNjY4MTR9.Hqa-Asa0u5gKAu2wi6FMeKboW7N2vxh-EzOzamL-NT0','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-10 18:20:14','2026-03-03 18:20:14',0),(266,60,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MjU2MjAxNSwiZXhwIjoxNzczMTY2ODE1fQ.0n7cM1LZDfNbMOkZMSaHQ4zAjkaCE2feznDdqrwK8Vk','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-10 18:20:15','2026-03-03 18:20:15',0),(267,61,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzcyNTYyMDE2LCJleHAiOjE3NzMxNjY4MTZ9.df9HQdscgd8acbdwnsXFyfop8_k3jzV0Kdj-NDcQGM0','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-10 18:20:16','2026-03-03 18:20:16',0),(268,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjU2MjEwMywiZXhwIjoxNzczMTY2OTAzfQ.alZoLx1VsXsBHgU4_MLd0g6kZu9ZbKpCy0_B1pumgFs','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-10 18:21:43','2026-03-03 18:21:43',0),(269,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjU2MjEwNCwiZXhwIjoxNzczMTY2OTA0fQ.qnjmCGWah-Jt39m2_V8iulY7wYDFLgaXp_mMlpI5Zts','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-10 18:21:44','2026-03-03 18:21:44',0),(270,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNTYyMTA1LCJleHAiOjE3NzMxNjY5MDV9.h6ClI3MWuylbA5cl47YNFQCSMmk0_TyGuCANuErtqvg','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-10 18:21:45','2026-03-03 18:21:45',0),(271,60,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MjU2MjEwNiwiZXhwIjoxNzczMTY2OTA2fQ.0qSMlzQqtJkjtMTT1Dos76me50hkgIAYeevzSYqwom8','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-10 18:21:46','2026-03-03 18:21:46',0),(272,61,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzcyNTYyMTA3LCJleHAiOjE3NzMxNjY5MDd9.qOHXUUiEFIkEY1h9i-CnuEOUT3m_GO4lVf5-OTRZf-k','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-10 18:21:47','2026-03-03 18:21:47',0),(273,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjU2MjE5OSwiZXhwIjoxNzczMTY2OTk5fQ.irgiTfdQ1BE-WUdfv7PRdnbIqrXxQvGJfQ47eTWxegE','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-10 18:23:19','2026-03-03 18:23:19',0),(274,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjU2MjIwMCwiZXhwIjoxNzczMTY3MDAwfQ.rxvbVdfBDLgqfCTfvDpD29hJg_taTXYGONbV711zSMY','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-10 18:23:20','2026-03-03 18:23:20',0),(275,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNTYyMjAxLCJleHAiOjE3NzMxNjcwMDF9.iQTmN0mzl6V-2IwA_7b1IMTQKd3NS58rWLo-ce0kRIU','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-10 18:23:21','2026-03-03 18:23:21',0),(276,60,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MjU2MjIwMiwiZXhwIjoxNzczMTY3MDAyfQ.j5uB2j_TTKAfQwYFNUQNrjM_Pr5RLTt6V9ZibtEhroY','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-10 18:23:22','2026-03-03 18:23:22',0),(277,61,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzcyNTYyMjAzLCJleHAiOjE3NzMxNjcwMDN9.1Kk_O7YtBLGI8QjDKY6CCYB51FVFxK3ae-N1QA0amqM','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-10 18:23:23','2026-03-03 18:23:23',0),(278,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjU2MjQwNywiZXhwIjoxNzczMTY3MjA3fQ.CHLrU6BPbw5gPt5ZAciB6ZBtr73GuOR95FCOqAS2ync','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-10 18:26:47','2026-03-03 18:26:47',0),(279,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjU2MjQwOCwiZXhwIjoxNzczMTY3MjA4fQ.5EtdxYXtyv64tfsTaAkUPz3NDjR0Ud6TE4yKgKSj-hA','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-10 18:26:48','2026-03-03 18:26:48',0),(280,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNTYyNDA5LCJleHAiOjE3NzMxNjcyMDl9.AP2Uk5FeeWXcGTMQrQwo4PyXbuwc897PRmzPdmMaxMU','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-10 18:26:49','2026-03-03 18:26:49',0),(281,60,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MjU2MjQxMCwiZXhwIjoxNzczMTY3MjEwfQ.eHbZHP53rRqaj9QhiVzp2hMZVz_O9OWpB-uvCBUbq60','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-10 18:26:50','2026-03-03 18:26:50',0),(282,61,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzcyNTYyNDExLCJleHAiOjE3NzMxNjcyMTF9.72goPQbkKPEa1lspA5oVMdBZcsPRfOciw25jIewlIxw','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-10 18:26:51','2026-03-03 18:26:51',0),(283,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjU2MjcxNiwiZXhwIjoxNzczMTY3NTE2fQ.SgLO77OOo1F0Rvk7EfifQpAZFeZHYbAq5gdLjZihT00','127.0.0.1','PostmanRuntime/7.51.1','desktop','2026-03-10 18:31:56','2026-03-03 18:31:56',0),(284,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjU2MjcxNiwiZXhwIjoxNzczMTY3NTE2fQ.7S06HxqPgOk4F5P_CrJcoeHdPSagN3TAw6Q4dnhCPUs','127.0.0.1','PostmanRuntime/7.51.1','desktop','2026-03-10 18:31:56','2026-03-03 18:31:56',0),(285,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNTYyNzE2LCJleHAiOjE3NzMxNjc1MTZ9.zKPvGzUhR0aM4CVuJHRqrSRbbB0d6rJ9I63vEAuxGSw','127.0.0.1','PostmanRuntime/7.51.1','desktop','2026-03-10 18:31:56','2026-03-03 18:31:56',0),(286,60,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MjU2MjcxNiwiZXhwIjoxNzczMTY3NTE2fQ.2w3xDrx9_32SAAVVQ13Z5XVOAfWUW8GAu-Zl1of9E7Q','127.0.0.1','PostmanRuntime/7.51.1','desktop','2026-03-10 18:31:56','2026-03-03 18:31:56',0),(287,61,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzcyNTYyNzE3LCJleHAiOjE3NzMxNjc1MTd9.DeIHjKWuxddoIYXJgXcQx4UIAZyUVlpECfRW8XuoJ5w','127.0.0.1','PostmanRuntime/7.51.1','desktop','2026-03-10 18:31:57','2026-03-03 18:31:57',0),(288,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjU2MzI5OCwiZXhwIjoxNzczMTY4MDk4fQ.qurTq0xBIoiuiiVulKE1lXoE8rh4fD02cDfHuAD8ER8','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-10 18:41:38','2026-03-03 18:41:38',0),(289,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjU2MzI5OSwiZXhwIjoxNzczMTY4MDk5fQ.dXIB_SLoFc4I6d2LFOw2W9rJodBRIt3FTim5oMMQYas','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-10 18:41:39','2026-03-03 18:41:39',0),(290,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNTYzMzAwLCJleHAiOjE3NzMxNjgxMDB9.aHppv02ayyP5U8Rc3s_iZUQu2RfWuRA7roHcTRy8kZk','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-10 18:41:40','2026-03-03 18:41:40',0),(291,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjU2MzQ3NCwiZXhwIjoxNzczMTY4Mjc0fQ.rUUgt3PNxg-DWnhPIHbSX7tNN1S7LQIjb-o_BPsguCM','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-10 18:44:34','2026-03-03 18:44:34',0),(292,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjU2MzQ3NSwiZXhwIjoxNzczMTY4Mjc1fQ.80ti5Y-Q3GCS2kegglhoUCI8-No_PhiWqwXqHjFlHjM','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-10 18:44:35','2026-03-03 18:44:35',0),(293,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNTYzNDc2LCJleHAiOjE3NzMxNjgyNzZ9.YnVdxDRD3AJ3uzhtNQbKGLIMLRj9u2X7je-ohjJ4jko','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-10 18:44:36','2026-03-03 18:44:36',0),(294,60,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MjU2MzQ3NywiZXhwIjoxNzczMTY4Mjc3fQ.XP4ow6zpU_b5I2NuIyhu9le5_WLypxM8QFJp4F2YWPs','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-10 18:44:37','2026-03-03 18:44:37',0),(295,61,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzcyNTYzNDc4LCJleHAiOjE3NzMxNjgyNzh9.dYQdphzyLRPhh02egW2gUhDG-fa2Y_ST1ZIIwSxXmag','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-10 18:44:38','2026-03-03 18:44:38',0),(296,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjU5MDE2NSwiZXhwIjoxNzczMTk0OTY1fQ.--0JxBcXPMgoN3LOvbG6O81nIwGaPooHvgzHQpoz2N8','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','desktop','2026-03-11 02:09:25','2026-03-04 02:09:25',0),(297,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjYzMzUzMCwiZXhwIjoxNzczMjM4MzMwfQ.hdCDI6mxpS1gLJ9YILpqQVpI3xZ16TAaNXN8D6lb2po','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','desktop','2026-03-11 14:12:10','2026-03-04 14:12:10',0),(298,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjYzMzc5MywiZXhwIjoxNzczMjM4NTkzfQ.4iDLxd-eBjuHu2W349k_BhMEvOm6RMOCX5DZRNUK344','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','desktop','2026-03-11 14:16:33','2026-03-04 14:16:33',0),(299,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjYzNTQzNiwiZXhwIjoxNzczMjQwMjM2fQ.lAR9rMF-ju48X5vWN5wYcYMBXwfilmH8Jy22ZswNQ5w','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','desktop','2026-03-11 14:43:56','2026-03-04 14:43:56',0),(300,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjYzNTUwNywiZXhwIjoxNzczMjQwMzA3fQ.q70jA8tY2LymieLUys_W8MOuc6CsZEDJuTJA4G1Fkj4','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','desktop','2026-03-11 14:45:07','2026-03-04 14:45:07',0),(301,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNjM1NTc0LCJleHAiOjE3NzMyNDAzNzR9.iFY8AvbIujRP_SviiuClGR73oE1OP7tdPPqfniR9FJA','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','desktop','2026-03-11 14:46:14','2026-03-04 14:46:14',0),(302,60,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MjYzNTYxMCwiZXhwIjoxNzczMjQwNDEwfQ.MzRbWHoYbMvBbsrbq4zkX_OvVfS-Eap0G7gUNhzUsuw','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','desktop','2026-03-11 14:46:50','2026-03-04 14:46:50',0),(303,61,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzcyNjM1Njk2LCJleHAiOjE3NzMyNDA0OTZ9.BvXgmp6O7Q__5p1uJYN7tgt2ao-7G6xNcKeVXXqkoag','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','desktop','2026-03-11 14:48:16','2026-03-04 14:48:16',0),(304,60,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MjYzNjcwOSwiZXhwIjoxNzczMjQxNTA5fQ.B2pJyriF9tV7JUP4jK8VuyEbzgDrtlHAlnM8zIQJ_6E','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','desktop','2026-03-11 15:05:09','2026-03-04 15:05:09',0),(305,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjYzNjc2OSwiZXhwIjoxNzczMjQxNTY5fQ.QrlUZKBiPXFbGgP4j4WbJC02DvOTC07AkYkCsC1C1QA','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','desktop','2026-03-11 15:06:09','2026-03-04 15:06:09',0),(306,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNjM2OTE0LCJleHAiOjE3NzMyNDE3MTR9.uPEZ5oj4miZqL4oa-GiVwi9yKFAiew61XXCKlqk1KhI','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','desktop','2026-03-11 15:08:34','2026-03-04 15:08:34',0),(307,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjczODA3NywiZXhwIjoxNzczMzQyODc3fQ.UvGKNnUPhX3I32ZgdTVdNXt5JaRVInqQne5mlAGPhJA','127.0.0.1','PostmanRuntime/7.51.1','desktop','2026-03-12 19:14:37','2026-03-05 19:14:37',0),(308,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjczODA3NywiZXhwIjoxNzczMzQyODc3fQ.ATLKgcqksHkS5ghP35iRLkO4iJPa2yFULfcAEq9Sf1o','127.0.0.1','PostmanRuntime/7.51.1','desktop','2026-03-12 19:14:37','2026-03-05 19:14:37',0),(309,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyNzM4MDc3LCJleHAiOjE3NzMzNDI4Nzd9.-FMZoEZHO-zKFdXxnxrkTYdLl0mSkXk9RU6kfS7_nss','127.0.0.1','PostmanRuntime/7.51.1','desktop','2026-03-12 19:14:37','2026-03-05 19:14:37',0),(310,60,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MjczODA3NywiZXhwIjoxNzczMzQyODc3fQ.QE9blGikSgmjhP1Y9CtkSii_p29Sm4ayv0m7YJW4CRk','127.0.0.1','PostmanRuntime/7.51.1','desktop','2026-03-12 19:14:37','2026-03-05 19:14:37',0),(311,61,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzcyNzM4MDc3LCJleHAiOjE3NzMzNDI4Nzd9.PiH8FuN6cRgKxgHYQ5v4UU_c6wowgt7NX_cgiOeHq6U','127.0.0.1','PostmanRuntime/7.51.1','desktop','2026-03-12 19:14:37','2026-03-05 19:14:37',0),(312,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjkxMTU0OSwiZXhwIjoxNzczNTE2MzQ5fQ.F1JusMWAfVl2Mwv79owOVwRzB8jBVXnmPQo-JTYWA_E','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','desktop','2026-03-14 19:25:49','2026-03-07 19:25:49',0),(313,60,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MjkxMTU3MCwiZXhwIjoxNzczNTE2MzcwfQ.liCIx_OEr_ugzY7pr-iWAgTFGNy6HtJqLGJb8BTkboU','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','desktop','2026-03-14 19:26:10','2026-03-07 19:26:10',0),(314,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzcyOTExNTkxLCJleHAiOjE3NzM1MTYzOTF9.oftvdhYSIGqUDuRy_gZpVIwNesgjdhmEfDWQETqbsuo','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','desktop','2026-03-14 19:26:31','2026-03-07 19:26:31',0),(315,61,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzcyOTExNjg3LCJleHAiOjE3NzM1MTY0ODd9.WYOM66cEVcMSglv_iyiinW9TKYcufVkO2dlUV5cyjX4','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','desktop','2026-03-14 19:28:07','2026-03-07 19:28:07',0),(316,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MjkxMTc0NiwiZXhwIjoxNzczNTE2NTQ2fQ.Fcf7dYGd1veT8IIRHKgLv5rQKX9Oa6ABF4RrXdHMctg','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','desktop','2026-03-14 19:29:06','2026-03-07 19:29:06',0),(317,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjkxMTc4NiwiZXhwIjoxNzczNTE2NTg2fQ.lSCiNlUOAtiM4LcZz1JsFV1a-kJLNEL0hKfBqHjZmLk','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','desktop','2026-03-14 19:29:46','2026-03-07 19:29:46',0),(318,60,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MjkxMjAxMCwiZXhwIjoxNzczNTE2ODEwfQ.u8c5CxXSdE0wB9Jb93cCrNIbnvvul5dCkB71B_wEvMc','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','desktop','2026-03-14 19:33:30','2026-03-07 19:33:30',0),(319,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjkxMjAzNywiZXhwIjoxNzczNTE2ODM3fQ.5aEJthyB-0kInni6Ez9Kiaatxft4y65_rTOC4lt_Vdo','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','desktop','2026-03-14 19:33:57','2026-03-07 19:33:57',0),(320,61,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzcyOTEyMDU0LCJleHAiOjE3NzM1MTY4NTR9.YdLlIkqNkZB-oz3EeZRm4Iw1j3_J_r61QR4wNmBfBp4','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','desktop','2026-03-14 19:34:14','2026-03-07 19:34:14',0),(321,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjkxMzgyMCwiZXhwIjoxNzczNTE4NjIwfQ.8GVcJlBmV03lKWEA4X_zGXM_qc31n0neQnJryOEDa2g','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-14 20:03:40','2026-03-07 20:03:40',0),(322,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MjkxNDM3MCwiZXhwIjoxNzczNTE5MTcwfQ.dER_XTeZWDnFe2aa1P5vvGeoNP2DZ8u3XodU0n3L6yI','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','desktop','2026-03-14 20:12:50','2026-03-07 20:12:50',0),(323,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzE0ODk1MywiZXhwIjoxNzczNzUzNzUzfQ.Q4s5HgpfHQ51Z44HZiIqLQ4Coxn3twjo4F_dyIlHL_w','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','desktop','2026-03-17 13:22:33','2026-03-10 13:22:33',0),(324,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzczMTQ5MjkzLCJleHAiOjE3NzM3NTQwOTN9.ISJK4iaTLUmjPN7jZYs64C-lk9Gh5Gk5aSr7tySAEJo','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','desktop','2026-03-17 13:28:13','2026-03-10 13:28:13',0),(325,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzE1MTE4MCwiZXhwIjoxNzczNzU1OTgwfQ.6Qbk1ztrPM1MJ_nSmdOPt4-O_8KBWHXXBjMd7QlKnQk','127.0.0.1','axios/1.13.2','desktop','2026-03-17 13:59:40','2026-03-10 13:59:40',0),(326,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzE1MTUwNywiZXhwIjoxNzczNzU2MzA3fQ.zvcEfT_NXP1XBkzu3vaWsMTA7d2xtd7LUzaQN0N7hvs','127.0.0.1','axios/1.13.2','desktop','2026-03-17 14:05:07','2026-03-10 14:05:07',0),(327,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzE1MTU1MywiZXhwIjoxNzczNzU2MzUzfQ.1bDpPNqGar07-I4c5z6QKV4NAmpmIQY1863mIz2-seI','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-17 14:05:53','2026-03-10 14:05:53',0),(328,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzE1MTgyNSwiZXhwIjoxNzczNzU2NjI1fQ.P1Wo6WthMTbPbdnBELrYobIY-iNTj6WYrLc6SxAyvYU','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-17 14:10:25','2026-03-10 14:10:25',0),(329,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzE1MjA3NSwiZXhwIjoxNzczNzU2ODc1fQ.wBINDbNLBRASNGAzyMSXMQxlvF9c4fQOtHm0-YuqXmo','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','desktop','2026-03-17 14:14:35','2026-03-10 14:14:35',0),(330,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MzE1MjA3OSwiZXhwIjoxNzczNzU2ODc5fQ.cD1ES2SGZmLqbDa-thegF8dP_ekIm-wyRFheTkmzMNc','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','desktop','2026-03-17 14:14:39','2026-03-10 14:14:39',0),(331,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzE1MjQ1OSwiZXhwIjoxNzczNzU3MjU5fQ.a2jNMMHU2lS41FOf-D-UeQkW5e3FNsb57qxBEAGGM84','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','desktop','2026-03-17 14:20:59','2026-03-10 14:20:59',0),(332,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MzE1MjQ3MiwiZXhwIjoxNzczNzU3MjcyfQ.g7YqAKcO5V1Lkc0YfLdG_NBC7kuteWY35BG3qJje9-4','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','desktop','2026-03-17 14:21:12','2026-03-10 14:21:12',0),(333,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzE1MjY4NiwiZXhwIjoxNzczNzU3NDg2fQ.9AprDer9pp-iFvg2tl_4MHuLv59RG3sHOYuJNkxikIo','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','desktop','2026-03-17 14:24:46','2026-03-10 14:24:46',0),(334,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MzE1MjY4OSwiZXhwIjoxNzczNzU3NDg5fQ.q-xaynH5EWUChH6s5XyFA76sCYfbtg7Qskqwdy3xHHQ','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','desktop','2026-03-17 14:24:49','2026-03-10 14:24:49',0),(335,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzE1Mjg3MywiZXhwIjoxNzczNzU3NjczfQ.AIHCS9rxInoBW3WxZ2I8K3lIpS9Q0AuWNy98BVkvKv8','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','desktop','2026-03-17 14:27:53','2026-03-10 14:27:53',0),(336,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MzE1Mjg3NCwiZXhwIjoxNzczNzU3Njc0fQ.kOLYnvQv-qMOgbeNKfycmg0SXyRAHVxluzeeWzC551A','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','desktop','2026-03-17 14:27:54','2026-03-10 14:27:54',0),(337,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzE1MzIzNCwiZXhwIjoxNzczNzU4MDM0fQ.p7MHVdPoP1ZLrDCy4N7HFa0hzB7dKbcN2nrTAi4hOlg','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','desktop','2026-03-17 14:33:54','2026-03-10 14:33:54',0),(338,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MzE1MzIzOCwiZXhwIjoxNzczNzU4MDM4fQ.m64T-hsmijYXBjbG6Tyn8Hy82z46ADsT5nzziFQY7KU','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','desktop','2026-03-17 14:33:58','2026-03-10 14:33:58',0),(339,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzE1MzQ1MywiZXhwIjoxNzczNzU4MjUzfQ.oo6LIjqE7ICNxDz8derVGwQQ7kHDepxa4n25o53pa8c','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','desktop','2026-03-17 14:37:33','2026-03-10 14:37:33',0),(340,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MzE1MzQ1NSwiZXhwIjoxNzczNzU4MjU1fQ.XaiGBEkaZyRhPSNU95Pex2Lwn0Lo0Wc7xTygTqBnAFE','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','desktop','2026-03-17 14:37:35','2026-03-10 14:37:35',0),(341,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MzE1MzQ2NywiZXhwIjoxNzczNzU4MjY3fQ.QK1W0cLh-ZC1Y4AFvkuxV2QDyLNolF4oOINXVVECAkc','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','desktop','2026-03-17 14:37:47','2026-03-10 14:37:47',0),(342,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzE1NDU3MSwiZXhwIjoxNzczNzU5MzcxfQ.tKXXUqf5iOxFjBz-5_8QbRD6wRxaVi36IMbairdabLM','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','desktop','2026-03-17 14:56:11','2026-03-10 14:56:11',0),(343,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MzE1NDU3MSwiZXhwIjoxNzczNzU5MzcxfQ.b_M0SHOI2no5DGMHZ2WZt5i99QnNlI00bamobTvMOq8','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','desktop','2026-03-17 14:56:11','2026-03-10 14:56:11',0),(344,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzE1NzAzMywiZXhwIjoxNzczNzYxODMzfQ.PAPS9zRVD0btY1GC4YCDnsNicbWvyzPgB29hOO5_HVY','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','desktop','2026-03-17 15:37:13','2026-03-10 15:37:13',0),(345,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MzE1NzAzNSwiZXhwIjoxNzczNzYxODM1fQ.fMKwuVhXrmJxWzjyA3RsgXsAsV3NR9rnX_QEMf7aCEk','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','desktop','2026-03-17 15:37:15','2026-03-10 15:37:15',0),(346,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MzE1NzMxNCwiZXhwIjoxNzczNzYyMTE0fQ.lrWCdn17BupF6FKsy1_qHnAseHNbVLWO6FwDkZKFQzU','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','desktop','2026-03-17 15:41:54','2026-03-10 15:41:54',0),(347,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzE1NzM4MSwiZXhwIjoxNzczNzYyMTgxfQ.2ujJdnGFn_73cPfxagmQj9DZkJiTLgg9Oe_EEMEWuPg','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','desktop','2026-03-17 15:43:01','2026-03-10 15:43:01',0),(348,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzE2MzIxMywiZXhwIjoxNzczNzY4MDEzfQ.gduVvB_FQn7eT1gRJtXDNi8CMbTstOiwwBmM5u2UakQ','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','desktop','2026-03-17 17:20:13','2026-03-10 17:20:13',0),(349,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzE2MzQ2NSwiZXhwIjoxNzczNzY4MjY1fQ.uYX9XA6w8TROaC54dnRek4vP1E7ZnsqMIRm5OEJ8gis','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','desktop','2026-03-17 17:24:25','2026-03-10 17:24:25',0),(350,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MzE2MzQ4MCwiZXhwIjoxNzczNzY4MjgwfQ.AD37KrPvFMCq6z_08mW4ugNfJL7dvJ3jqNf7vVJHVpk','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','desktop','2026-03-17 17:24:40','2026-03-10 17:24:40',0),(351,60,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MzE2MzU0MSwiZXhwIjoxNzczNzY4MzQxfQ.fejWvj9i6BAY1bK5scZMy1WoZqyidKzX791TqGQ3jJM','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','desktop','2026-03-17 17:25:41','2026-03-10 17:25:41',0),(352,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzczMTY1OTg2LCJleHAiOjE3NzM3NzA3ODZ9.cfvq5jNTaVZ1ENiIz0sPijnH9uCtDUGBp3OuGlLzaM0','127.0.0.1','curl/8.14.1','desktop','2026-03-17 18:06:26','2026-03-10 18:06:26',0),(353,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzE2NTk4NywiZXhwIjoxNzczNzcwNzg3fQ.0o-qE0LnKkWozPay5coN-l8HAyC7de9MHAryRXBNyY0','127.0.0.1','curl/8.14.1','desktop','2026-03-17 18:06:27','2026-03-10 18:06:27',0),(354,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzE2NjAxMywiZXhwIjoxNzczNzcwODEzfQ.KLP7YVkwvYxTEdkhyWx5kXBQZdXDNAcxAAxMJHK7MZ0','127.0.0.1','curl/8.14.1','desktop','2026-03-17 18:06:53','2026-03-10 18:06:53',0),(355,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzczMTY2NDQzLCJleHAiOjE3NzM3NzEyNDN9.sejiKRPx5kTD6jCMP0rarN7HXKvDCDYMgqIQFAd63VI','127.0.0.1','curl/8.14.1','desktop','2026-03-17 18:14:03','2026-03-10 18:14:03',0),(356,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzE2NjQ0MywiZXhwIjoxNzczNzcxMjQzfQ.6snYGE1GN2uTCklZ0WRZi3NJjBwgK6CgT0N80DC6rLE','127.0.0.1','curl/8.14.1','desktop','2026-03-17 18:14:03','2026-03-10 18:14:03',0),(357,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzE2NjQ2MiwiZXhwIjoxNzczNzcxMjYyfQ.fjqcYIUobJE9Wpe6B53PrvZ03IaiXcmkGFhEHQ8Ud8I','127.0.0.1','curl/8.14.1','desktop','2026-03-17 18:14:22','2026-03-10 18:14:22',0),(358,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzE2NjQ2MywiZXhwIjoxNzczNzcxMjYzfQ.fmpzQEFcypjnNwmD6qnuzOr0EkySL0WWE8oAbF4Ll5I','127.0.0.1','curl/8.14.1','desktop','2026-03-17 18:14:23','2026-03-10 18:14:23',0),(359,61,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzczMTY2NTEzLCJleHAiOjE3NzM3NzEzMTN9.pS43OMZPA_kpU_o-EuI_lgHr016L_JqyumayAFCl_Tk','127.0.0.1','curl/8.14.1','desktop','2026-03-17 18:15:13','2026-03-10 18:15:13',0),(360,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzE2OTE5MSwiZXhwIjoxNzczNzczOTkxfQ.nQhfO7vr0fkjPwirbBPv1Mx5Mc77hruzGQDMt663M90','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-17 18:59:51','2026-03-10 18:59:51',0),(361,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzE2OTI5MCwiZXhwIjoxNzczNzc0MDkwfQ.g-JALTlLCKgzNEtd9UpiEFXZt7YjoyKplLPt4-Luw3M','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-17 19:01:30','2026-03-10 19:01:30',0),(362,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzE2OTQxNSwiZXhwIjoxNzczNzc0MjE1fQ.Ctuc5jw51QtobG5JinaAp8KQp7l3GLQkunH4OvA8LPM','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-17 19:03:35','2026-03-10 19:03:35',0),(363,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzczMTY5NDM4LCJleHAiOjE3NzM3NzQyMzh9.zTwWbjK3NLKfaFRmDDHEs6drYPe-XkqxGkalQA0xgrc','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-17 19:03:58','2026-03-10 19:03:58',0),(364,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzE2OTQzOSwiZXhwIjoxNzczNzc0MjM5fQ.P7t8DNlR9P-vKE4hLotAkTt-q-jXHbQFJYVjdl4ukPE','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-17 19:03:59','2026-03-10 19:03:59',0),(365,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzczMTY5NDY2LCJleHAiOjE3NzM3NzQyNjZ9.Muju8TTqS9H39LEOLM_UHAwDLhCYdZnJ0pAStHUodbs','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-17 19:04:26','2026-03-10 19:04:26',0),(366,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzE2OTQ2OCwiZXhwIjoxNzczNzc0MjY4fQ.9wwMj0-QYSyxQ76MhNcZFagMHlNGxqaqCXRfId-qEck','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-17 19:04:28','2026-03-10 19:04:28',0),(367,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzE2OTUwNiwiZXhwIjoxNzczNzc0MzA2fQ.b2zbc_Zreg4qpyy5omyyEj_JgEE6jp2lLt6pfoy46jE','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-17 19:05:06','2026-03-10 19:05:06',0),(368,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzE2OTUyOCwiZXhwIjoxNzczNzc0MzI4fQ.jg7N7cuPPZCxDufT0N_3yjATonJYor_xg8KQbSRwhe8','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-17 19:05:28','2026-03-10 19:05:28',0),(369,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzczMTY5NTMyLCJleHAiOjE3NzM3NzQzMzJ9.BoZcyTQkAbQYbzCE4ZNGuLSofsYWI9ItRmFxJMg_oWw','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-17 19:05:32','2026-03-10 19:05:32',0),(370,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzE2OTU1OSwiZXhwIjoxNzczNzc0MzU5fQ.KKKpGpNSmY1k4gGM3AxteetB9m0IBMzVh1G02H5jqXU','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-17 19:05:59','2026-03-10 19:05:59',0),(371,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzczMTY5NTYyLCJleHAiOjE3NzM3NzQzNjJ9.k9hIuUgmNIx-vHjySCHaItGtleSjCyBrn1gbM2SvXz0','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-17 19:06:02','2026-03-10 19:06:02',0),(372,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MzE3Mjk0NiwiZXhwIjoxNzczNzc3NzQ2fQ.6VohrHDkP9_SeYPScQIQZmceBY_o1q4_7EzYwPo7MoQ','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-17 20:02:27','2026-03-10 20:02:26',0),(373,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MzE3Mjk1NiwiZXhwIjoxNzczNzc3NzU2fQ.A5ZLTP-Yxxqc2TE-mKw4argwyavBO8cKSUpm3Js5vdc','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-17 20:02:36','2026-03-10 20:02:36',0),(374,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MzE3Mjk2OSwiZXhwIjoxNzczNzc3NzY5fQ.i6pvCSN0jXinKyNTXZgRONpQfrctJoIH7aGJtjhonQo','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-17 20:02:49','2026-03-10 20:02:49',0),(375,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzE3Mjk3MSwiZXhwIjoxNzczNzc3NzcxfQ.nhQlbxdnYp7KWESNDZIuM75KSB9fVz1gSDp9IzhzaKg','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-17 20:02:51','2026-03-10 20:02:51',0),(376,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzczMTcyOTczLCJleHAiOjE3NzM3Nzc3NzN9.TWekqkMymt27hpjPstO0CqL0VXpC7Tt8cqNp-ug8WFE','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-17 20:02:53','2026-03-10 20:02:53',0),(377,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzczMTczMDE0LCJleHAiOjE3NzM3Nzc4MTR9.4TsHw0EkbTOUpQc_6rJAi33KkvPhIvbEoVAXa5vOiP4','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-17 20:03:35','2026-03-10 20:03:34',0),(378,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzE3MzAxNiwiZXhwIjoxNzczNzc3ODE2fQ.eZzUzH5K8Qt8atQdBSJV9jL_CsanV8qoy51VfHEED4o','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-17 20:03:37','2026-03-10 20:03:36',0),(379,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzczMTczMDM3LCJleHAiOjE3NzM3Nzc4Mzd9.9wbw4lZIoIUAStAT32hmcEmJ7NIxZz1s5T5tg5M-U20','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-17 20:03:58','2026-03-10 20:03:57',0),(380,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzczMTczMDY0LCJleHAiOjE3NzM3Nzc4NjR9._m1U72kf6suybOMTay_zWlP7BOqqfgZ--KLgqkGWji4','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-17 20:04:25','2026-03-10 20:04:24',0),(381,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzE3MzA4MCwiZXhwIjoxNzczNzc3ODgwfQ.unhP-Jggc2ed5Y8tPNwxBijrqh9J0bk8F9pzSu5JKCI','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-17 20:04:41','2026-03-10 20:04:40',0),(382,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzE3MzEwMSwiZXhwIjoxNzczNzc3OTAxfQ.OnwIGbGYHOzgrmWbxjfVdjpVyMgABZz_J6lQ1BGGJow','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-17 20:05:01','2026-03-10 20:05:01',0),(383,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzczMTczMTI0LCJleHAiOjE3NzM3Nzc5MjR9.sksjdumC7INg_HLQG4qsw1qWeX4QHDlYAjR97fDwkjw','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-17 20:05:25','2026-03-10 20:05:24',0),(384,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzczMTczMTQ4LCJleHAiOjE3NzM3Nzc5NDh9.pPNYLczLDLnLwAKhBbT1FAmN_1jabyuxOvHouosMKx0','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-17 20:05:49','2026-03-10 20:05:48',0),(385,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzczMTczMjQ5LCJleHAiOjE3NzM3NzgwNDl9.y1_MEs-Lq0uJwrVGOKw61Ek8i2aP-BGQNgJvjCdh3JY','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-17 20:07:29','2026-03-10 20:07:29',0),(386,63,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYzLCJlbWFpbCI6ImFtaXJfc3R1ZGVudEBleGFtcGxlLmNvbSIsInJvbGVzIjpbInN0dWRlbnQiXSwiaWF0IjoxNzczMTczNjM2LCJleHAiOjE3NzM3Nzg0MzZ9.6bBAu90CYupGLYnmM9NJf780QS5OGUnSaojLOgG97KU','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','desktop','2026-03-17 20:13:57','2026-03-10 20:13:56',0),(387,64,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjY0LCJlbWFpbCI6ImFtaXJfaW5zdHJ1Y3RvckBleGFtcGxlLmNvbSIsInJvbGVzIjpbImluc3RydWN0b3IiXSwiaWF0IjoxNzczMTczNjUzLCJleHAiOjE3NzM3Nzg0NTN9.qYvVc21ffBBhY0VDY9oT2F4AusoN4yYQTs8NJcB58KY','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','desktop','2026-03-17 20:14:13','2026-03-10 20:14:13',0),(388,65,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjY1LCJlbWFpbCI6ImFtaXJfdGFAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJ0ZWFjaGluZ19hc3Npc3RhbnQiXSwiaWF0IjoxNzczMTczNjcwLCJleHAiOjE3NzM3Nzg0NzB9.hNNRm6yasF_E324ADsuxB2hD_je0WomUZL4WicwtqPM','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','desktop','2026-03-17 20:14:30','2026-03-10 20:14:30',0),(389,66,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjY2LCJlbWFpbCI6ImFtaXJfYWRtaW5AZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJhZG1pbiJdLCJpYXQiOjE3NzMxNzM2ODQsImV4cCI6MTc3Mzc3ODQ4NH0.it1eNhlePIaQzTpxqQ1HR_yFgJMVjoKfSGc28GGGi0M','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','desktop','2026-03-17 20:14:45','2026-03-10 20:14:44',0),(390,67,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjY3LCJlbWFpbCI6ImFtaXJfaXRhZG1pbkBleGFtcGxlLmNvbSIsInJvbGVzIjpbIml0X2FkbWluIl0sImlhdCI6MTc3MzE3MzcwMCwiZXhwIjoxNzczNzc4NTAwfQ.eg9nFpljyCy2v2PsmC2ftvFvswSCPv2nobMfMVzAfQ0','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','desktop','2026-03-17 20:15:00','2026-03-10 20:15:00',0),(391,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzE3Mzc1MSwiZXhwIjoxNzczNzc4NTUxfQ.4RofRfO5TTOm13FCb5ukiix1UlvScNNCoajTgw6s8tI','127.0.0.1','PostmanRuntime/7.51.1','desktop','2026-03-17 20:15:51','2026-03-10 20:15:51',0),(392,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MzE3Mzc1MSwiZXhwIjoxNzczNzc4NTUxfQ.m4E_-lOPPaT5wiVblshu7NHo7WZIcLN7b45Wj3A1niw','127.0.0.1','PostmanRuntime/7.51.1','desktop','2026-03-17 20:15:51','2026-03-10 20:15:51',0),(393,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzczMTczNzUxLCJleHAiOjE3NzM3Nzg1NTF9.ahlYgXkinESXZLU-6iS8wPeCVutz48xccTwBkPtaLz4','127.0.0.1','PostmanRuntime/7.51.1','desktop','2026-03-17 20:15:52','2026-03-10 20:15:51',0),(394,60,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MzE3Mzc1MSwiZXhwIjoxNzczNzc4NTUxfQ.QlBpGALdrhcmW1R0gGBf-6M77WTjknbgo5j7bJTdOJE','127.0.0.1','PostmanRuntime/7.51.1','desktop','2026-03-17 20:15:52','2026-03-10 20:15:51',0),(395,61,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzczMTczNzUxLCJleHAiOjE3NzM3Nzg1NTF9.niOTnyaZzHUYtgRovCITzRwxlb1UO4_QjR9OPndIWT8','127.0.0.1','PostmanRuntime/7.51.1','desktop','2026-03-17 20:15:52','2026-03-10 20:15:51',0),(396,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzE3NDIyMCwiZXhwIjoxNzczNzc5MDIwfQ.B5xxUs6hTP4HrYXvVvmVj3fVeWDRGSkdb6ED6_UEjA0','127.0.0.1','PostmanRuntime/7.51.1','desktop','2026-03-17 20:23:40','2026-03-10 20:23:40',0),(397,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MzE3NDIyMCwiZXhwIjoxNzczNzc5MDIwfQ.JVsEsQnIl_7XBGBfCzCJzIleJvPdPo-gPD2ZT0AWsPU','127.0.0.1','PostmanRuntime/7.51.1','desktop','2026-03-17 20:23:40','2026-03-10 20:23:40',0),(398,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzczMTc0MjIwLCJleHAiOjE3NzM3NzkwMjB9.UTGRA_R7jCHxX8yOCIWHCyvJLd3j8pKjEchwHdzjtmg','127.0.0.1','PostmanRuntime/7.51.1','desktop','2026-03-17 20:23:40','2026-03-10 20:23:40',0),(399,60,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MzE3NDIyMCwiZXhwIjoxNzczNzc5MDIwfQ.ndHodaokr0o-4N39oYE2gqnM9Zt5yWEoJ85OndYM88Y','127.0.0.1','PostmanRuntime/7.51.1','desktop','2026-03-17 20:23:41','2026-03-10 20:23:40',0),(400,61,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzczMTc0MjIwLCJleHAiOjE3NzM3NzkwMjB9.GSvqfjbXLFS8x5C5IUgrVxnYhxZfFBuRhzhST-uaHWk','127.0.0.1','PostmanRuntime/7.51.1','desktop','2026-03-17 20:23:41','2026-03-10 20:23:40',0),(401,64,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjY0LCJlbWFpbCI6ImFtaXJfaW5zdHJ1Y3RvckBleGFtcGxlLmNvbSIsInJvbGVzIjpbImluc3RydWN0b3IiXSwiaWF0IjoxNzczMTc3MzMwLCJleHAiOjE3NzM3ODIxMzB9.RT1Hp1IeqlTaSYYpJVyYckWFvdV9fx4uobFaBH4dBTQ','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','desktop','2026-03-17 21:15:30','2026-03-10 21:15:30',0),(402,66,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjY2LCJlbWFpbCI6ImFtaXJfYWRtaW5AZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJhZG1pbiJdLCJpYXQiOjE3NzMxNzgwNjYsImV4cCI6MTc3Mzc4Mjg2Nn0.ehenzzu9FTQmcyTcldoKWQ_DaDwozo6CyQ8z9F-JRLo','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','desktop','2026-03-17 21:27:46','2026-03-10 21:27:46',0),(403,66,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjY2LCJlbWFpbCI6ImFtaXJfYWRtaW5AZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJhZG1pbiJdLCJpYXQiOjE3NzMxNzk2NDMsImV4cCI6MTc3Mzc4NDQ0M30.WsREWx6ZhkPlokraFmnsmj6CjgMdQ4icf-owLnRCKLc','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','desktop','2026-03-17 21:54:03','2026-03-10 21:54:03',0),(404,64,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjY0LCJlbWFpbCI6ImFtaXJfaW5zdHJ1Y3RvckBleGFtcGxlLmNvbSIsInJvbGVzIjpbImluc3RydWN0b3IiXSwiaWF0IjoxNzczMTgwMDE1LCJleHAiOjE3NzM3ODQ4MTV9.pP70BEt-SgWcoqh8zNIssTDh237Nfnz2_VK2mQli_-k','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','desktop','2026-03-17 22:00:16','2026-03-10 22:00:15',0),(405,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzczMjQ4NzIxLCJleHAiOjE3NzU4NDA3MjF9.Nk7evJUrVqnryZgZ6TIjW_gItIwZ3ZcYcxwEDGB4Q1g','127.0.0.1','Apidog/1.0.0 (https://apidog.com)','desktop','2026-04-10 17:05:22','2026-03-11 17:05:21',1),(406,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MzI0ODc0NCwiZXhwIjoxNzc1ODQwNzQ0fQ.tzS6QtD5v_w-Vu2HFmLgCPJwFg4h1ngU6kd1qrvCZ4c','127.0.0.1','Apidog/1.0.0 (https://apidog.com)','desktop','2026-04-10 17:05:44','2026-03-11 17:05:44',1),(407,60,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MzI0ODc4OCwiZXhwIjoxNzc1ODQwNzg4fQ.77koRnJzkr4IFvgwGjUZPmv4wlms29Tgjrb66cZXRjg','127.0.0.1','Apidog/1.0.0 (https://apidog.com)','desktop','2026-04-10 17:06:29','2026-03-11 17:06:28',1),(408,61,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzczMjQ4Nzk3LCJleHAiOjE3NzU4NDA3OTd9.KNUylZif4I-18F22JOAcFaYoEURCq434RsWz16FQEf0','127.0.0.1','Apidog/1.0.0 (https://apidog.com)','desktop','2026-04-10 17:06:37','2026-03-11 17:06:37',1),(409,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzI0OTExNywiZXhwIjoxNzc1ODQxMTE3fQ.c2HlPaDCt9Way0ab65VJIVLU0hSNSpCL6jwKp5tvASc','127.0.0.1','Apidog/1.0.0 (https://apidog.com)','desktop','2026-04-10 17:11:58','2026-03-11 17:11:57',1),(410,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzczMjQ5NTY2LCJleHAiOjE3NzU4NDE1NjZ9.SNeabOzGL5sxU6q1WyxjR6-50oLJyjw1EnxbpxIrILQ','127.0.0.1','PostmanRuntime/7.51.1','desktop','2026-04-10 17:19:26','2026-03-11 17:19:26',1),(411,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MzI0OTU2NiwiZXhwIjoxNzc1ODQxNTY2fQ.EsV59U4P7RhA6-yTAJJZxcGYkHomcvxNTfD2ZZcrz3g','127.0.0.1','PostmanRuntime/7.51.1','desktop','2026-04-10 17:19:26','2026-03-11 17:19:26',1),(412,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzI0OTU2NiwiZXhwIjoxNzc1ODQxNTY2fQ.L-bLDqFa3-iBPy8jSagsrgoibcozvGWsXK7lnlBgGkg','127.0.0.1','PostmanRuntime/7.51.1','desktop','2026-04-10 17:19:26','2026-03-11 17:19:26',1),(413,60,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MzI0OTU2NiwiZXhwIjoxNzc1ODQxNTY2fQ.s9-G5Ucb2l65ur8ERiGVzcaneVHk64-yjPU5LD9nXZ4','127.0.0.1','PostmanRuntime/7.51.1','desktop','2026-04-10 17:19:27','2026-03-11 17:19:26',1),(414,61,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzczMjQ5NTY2LCJleHAiOjE3NzU4NDE1NjZ9.9qYzd2eQfJRd8_raaxCHPvLYCVl9byTcR4p4Ro7A09Q','127.0.0.1','PostmanRuntime/7.51.1','desktop','2026-04-10 17:19:27','2026-03-11 17:19:26',1),(416,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MzI1MDYyOSwiZXhwIjoxNzc1ODQyNjI5fQ.cZtn-aUXKBp34nBNdzfUeJkcz6espsicSJIBRT1Y3qo','127.0.0.1','PostmanRuntime/7.51.1','desktop','2026-04-10 17:37:10','2026-03-11 17:37:09',1),(417,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzI1MDYzMCwiZXhwIjoxNzc1ODQyNjMwfQ.5o-1M5hyrLNSypgvch5ArNoFLGcR3aYJwNicCkd0gAU','127.0.0.1','PostmanRuntime/7.51.1','desktop','2026-04-10 17:37:10','2026-03-11 17:37:10',1),(418,60,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MzI1MDYzMCwiZXhwIjoxNzc1ODQyNjMwfQ.2yXzpajmSRNUdU3dX8UD-4S1cUklpQSqK3S-ctbFUTM','127.0.0.1','PostmanRuntime/7.51.1','desktop','2026-04-10 17:37:10','2026-03-11 17:37:10',1),(419,61,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzczMjUwNjMwLCJleHAiOjE3NzU4NDI2MzB9.8edxVf1MqukYT0WL0T6SwxBpiEaQmdetANcBKCCSwp0','127.0.0.1','PostmanRuntime/7.51.1','desktop','2026-04-10 17:37:10','2026-03-11 17:37:10',1),(420,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzczMjUwNjMwLCJleHAiOjE3NzU4NDI2MzB9.JjZFHn5tyqBcmSXwi-Jf-OQV01GisC9OZnle7TrhNAs','127.0.0.1','PostmanRuntime/7.51.1','desktop','2026-04-10 17:37:11','2026-03-11 17:37:10',1),(421,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzI1Mjg3NywiZXhwIjoxNzc1ODQ0ODc3fQ.6ociq_RLUmO6pJvDcNMedawb3IMaXtEuLW4bxTHuNiE','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-04-10 18:14:38','2026-03-11 18:14:37',1),(422,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzczMjUyODc5LCJleHAiOjE3NzU4NDQ4Nzl9.6cXHBrkZz3yqkp35NTjJbiFPL0P_WnsT8zJ4QRQkBxs','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-04-10 18:14:39','2026-03-11 18:14:39',1),(423,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MzI1Mjg4MCwiZXhwIjoxNzc1ODQ0ODgwfQ.2s39_tIuXvWTG3W6MEOklohvtJ3ia0viR59NNob8EVE','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-04-10 18:14:40','2026-03-11 18:14:40',1),(424,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzI1MzExOCwiZXhwIjoxNzc1ODQ1MTE4fQ.YQdVE8roXHKrBxHijY1n9aXWx_0I5G-mIVgJtCvVtgY','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-04-10 18:18:38','2026-03-11 18:18:38',1),(425,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzczMjUzMTE5LCJleHAiOjE3NzU4NDUxMTl9.OO9Vo57BBTejwe89uqOSQl5BjgrlqYGOXI3BlA9SWbg','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-04-10 18:18:39','2026-03-11 18:18:39',1),(426,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MzI1MzEyMCwiZXhwIjoxNzc1ODQ1MTIwfQ.N9rf2QNfm4NJIuz4Xkq3sl2tpIytvBvbJFU6OpL3ACQ','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-04-10 18:18:40','2026-03-11 18:18:40',1),(427,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzczMjUzMzEyLCJleHAiOjE3NzU4NDUzMTJ9.JKvFpWRHNPcXeL6Fm-oK_R06gobQnZVZ_1KCWeMVEDs','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-04-10 18:21:52','2026-03-11 18:21:52',1),(428,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzI1MzM0OSwiZXhwIjoxNzc1ODQ1MzQ5fQ.Ak2A3bOCFa_y-BUiazfkqup5lKXmYOtAs8dbmKPI3AE','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-04-10 18:22:30','2026-03-11 18:22:29',1),(429,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzczMjUzMzUwLCJleHAiOjE3NzU4NDUzNTB9.d8RAlNfdo8CL1DuVeasWjo_MyQVjEF9zpZKnrsP9thY','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-04-10 18:22:31','2026-03-11 18:22:30',1),(430,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MzI1MzM1MSwiZXhwIjoxNzc1ODQ1MzUxfQ.GJeHpRVREB40paBu1CVOnncFzYr-m6x3EtImv6Ixtak','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-04-10 18:22:32','2026-03-11 18:22:31',1),(431,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzI1MzQyMSwiZXhwIjoxNzc1ODQ1NDIxfQ.0JEkP_EUQaHpV5JZLBXrWGZneYD_ylv3x6LUdV2O9pk','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-04-10 18:23:41','2026-03-11 18:23:41',1),(432,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzczMjUzNDIyLCJleHAiOjE3NzU4NDU0MjJ9.9aA39IQsEETPbcsVVU2RsBAuGNw2CTs2L2W7EIqUo7g','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-04-10 18:23:42','2026-03-11 18:23:42',1),(433,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MzI1MzQyMywiZXhwIjoxNzc1ODQ1NDIzfQ.rspzD1pKg3KgAhYmp--gsrEF9Ks0nw1xRhgLQpxlgcE','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-04-10 18:23:43','2026-03-11 18:23:43',1),(435,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MzI1MzczNiwiZXhwIjoxNzc1ODQ1NzM2fQ.Qv-5H5UXnXcdLT6I3KC1MW7b2JatqpFOagDlNiXUwwA','127.0.0.1','PostmanRuntime/7.51.1','desktop','2026-04-10 18:28:57','2026-03-11 18:28:56',1),(436,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzI1MzczNiwiZXhwIjoxNzc1ODQ1NzM2fQ.k2Yrl6AxjzW9FKuAZrJX0Gg1-aSn0cTI_IScnEAkjMo','127.0.0.1','PostmanRuntime/7.51.1','desktop','2026-04-10 18:28:57','2026-03-11 18:28:56',1),(437,60,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MzI1MzczNywiZXhwIjoxNzc1ODQ1NzM3fQ.zronOCbj5w-8ZraIqDeL4G7QNvFfd0eULz6EYOqvbcI','127.0.0.1','PostmanRuntime/7.51.1','desktop','2026-04-10 18:28:57','2026-03-11 18:28:57',1),(438,61,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzczMjUzNzM3LCJleHAiOjE3NzU4NDU3Mzd9.fmYCHzCLwecx3wvYvL2Zq48r1EK3Tx5tz5Hn1ztRM-s','127.0.0.1','PostmanRuntime/7.51.1','desktop','2026-04-10 18:28:57','2026-03-11 18:28:57',1),(439,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzczMjUzNzM3LCJleHAiOjE3NzU4NDU3Mzd9.wbwD1oJH8m925w2JnKbwZ9_SRcMECHXaKSqpar7YKi8','127.0.0.1','PostmanRuntime/7.51.1','desktop','2026-04-10 18:28:58','2026-03-11 18:28:57',1),(441,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MzUwMTQ0MCwiZXhwIjoxNzc2MDkzNDQwfQ.n36YwkkPhr7FXdRZsDmcjBGdi4VDEJ_626jszZ32Ygc','127.0.0.1','PostmanRuntime/7.51.1','desktop','2026-04-13 15:17:20','2026-03-14 15:17:20',1),(442,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzUwMTQ0MCwiZXhwIjoxNzc2MDkzNDQwfQ.3iLX-xgFip-jyeEoUIXBRmAWNCRqciZaZE6Q_WB6fiA','127.0.0.1','PostmanRuntime/7.51.1','desktop','2026-04-13 15:17:20','2026-03-14 15:17:20',1),(443,60,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MzUwMTQ0MCwiZXhwIjoxNzc2MDkzNDQwfQ.PBQNMijldpolORxg7tjGG2wiI5Y8IUHMGDX0mx0fhBo','127.0.0.1','PostmanRuntime/7.51.1','desktop','2026-04-13 15:17:20','2026-03-14 15:17:20',1),(444,61,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzczNTAxNDQwLCJleHAiOjE3NzYwOTM0NDB9.nj9iL36vuIBY3jDbxGyTnafdipGNyOweqgGOE7J_nVc','127.0.0.1','PostmanRuntime/7.51.1','desktop','2026-04-13 15:17:21','2026-03-14 15:17:20',1),(445,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzczNTAxNDQwLCJleHAiOjE3NzYwOTM0NDB9.fqPZd5DEDoLc4MWz9VkFeDg7r2uZDnssK2jSuv-klfI','127.0.0.1','PostmanRuntime/7.51.1','desktop','2026-04-13 15:17:21','2026-03-14 15:17:20',1),(447,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MzUwMjUxNSwiZXhwIjoxNzc2MDk0NTE1fQ.aFmaDW-kYxC1FZltDhjFw6sbIXTV3PZQazIhfbA2bfs','127.0.0.1','PostmanRuntime/7.51.1','desktop','2026-04-13 15:35:16','2026-03-14 15:35:15',1),(448,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzUwMjUxNiwiZXhwIjoxNzc2MDk0NTE2fQ._i1Xusg4l4uiH_CDUciN4MEdz9cpPyBHQkQfXtAI46U','127.0.0.1','PostmanRuntime/7.51.1','desktop','2026-04-13 15:35:16','2026-03-14 15:35:16',1),(449,60,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MzUwMjUxNiwiZXhwIjoxNzc2MDk0NTE2fQ.NT3wVarpyhqBong-cHFQ-ultkAPfDSXDKcEQQblt4dg','127.0.0.1','PostmanRuntime/7.51.1','desktop','2026-04-13 15:35:16','2026-03-14 15:35:16',1),(450,61,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzczNTAyNTE2LCJleHAiOjE3NzYwOTQ1MTZ9.LUm2hIEblgaTLxFcKCCG2JiS-e1bMKwM_z3VDje440w','127.0.0.1','PostmanRuntime/7.51.1','desktop','2026-04-13 15:35:16','2026-03-14 15:35:16',1),(451,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzczNTAyNTE2LCJleHAiOjE3NzYwOTQ1MTZ9.tG-Xdc2S_V3NXqms7f8nv0YiKwJLEEKh36t9iUiEoRo','127.0.0.1','PostmanRuntime/7.51.1','desktop','2026-04-13 15:35:17','2026-03-14 15:35:16',1),(453,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MzUwMjUyNSwiZXhwIjoxNzc2MDk0NTI1fQ.ChTfJyXVfmobxAEulC0wMHkiXiZWQzKuw6PiMaLDYhg','127.0.0.1','PostmanRuntime/7.51.1','desktop','2026-04-13 15:35:25','2026-03-14 15:35:25',1),(454,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzUwMjUyNSwiZXhwIjoxNzc2MDk0NTI1fQ.vxQLOTOOL2jSKJfF07v61h6K5gVTeQcqgzmpALGGxio','127.0.0.1','PostmanRuntime/7.51.1','desktop','2026-04-13 15:35:25','2026-03-14 15:35:25',1),(455,60,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MzUwMjUyNSwiZXhwIjoxNzc2MDk0NTI1fQ.VkdBMucPZ1pHE6VlSZV5nhFyV96K7mtxw-qcB-MriqA','127.0.0.1','PostmanRuntime/7.51.1','desktop','2026-04-13 15:35:26','2026-03-14 15:35:25',1),(456,61,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzczNTAyNTI1LCJleHAiOjE3NzYwOTQ1MjV9.06qezmHwlVeSpTeffgC4uOdw63WBrlzqj7PIO9sXW4U','127.0.0.1','PostmanRuntime/7.51.1','desktop','2026-04-13 15:35:26','2026-03-14 15:35:25',1),(457,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzczNTAyNTI2LCJleHAiOjE3NzYwOTQ1MjZ9.y9wJy-sC9IR2-UHkwBsOVhvpXFyh9ahfPsQB-H01tOM','127.0.0.1','PostmanRuntime/7.51.1','desktop','2026-04-13 15:35:26','2026-03-14 15:35:26',1),(459,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MzUwMjgxMSwiZXhwIjoxNzc2MDk0ODExfQ.mlkUTOWQ67TATMRCEJDyj82DCWeSxLg17gyMFOHbJGE','127.0.0.1','PostmanRuntime/7.51.1','desktop','2026-04-13 15:40:11','2026-03-14 15:40:11',1),(460,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzUwMjgxMSwiZXhwIjoxNzc2MDk0ODExfQ.xByX9s3hM1H5AkA64bNobZKrdBFON4XgeJWPA8_3IlQ','127.0.0.1','PostmanRuntime/7.51.1','desktop','2026-04-13 15:40:11','2026-03-14 15:40:11',1),(461,60,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MzUwMjgxMSwiZXhwIjoxNzc2MDk0ODExfQ.CiWWZRTQDNENCJzdFAxiHrDzSsHia0a_aZm_MtIQm-g','127.0.0.1','PostmanRuntime/7.51.1','desktop','2026-04-13 15:40:11','2026-03-14 15:40:11',1),(462,61,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzczNTAyODExLCJleHAiOjE3NzYwOTQ4MTF9.xeQH8Xi8nPA8OaFchzvzqhUo2jy2i3sa-P_C_Ijif-s','127.0.0.1','PostmanRuntime/7.51.1','desktop','2026-04-13 15:40:12','2026-03-14 15:40:11',1),(463,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzczNTAyODExLCJleHAiOjE3NzYwOTQ4MTF9.atUNcjv6LSoDWmF7qkRuGCuDXFTjTxyXU_o1ioxFC9Q','127.0.0.1','PostmanRuntime/7.51.1','desktop','2026-04-13 15:40:12','2026-03-14 15:40:11',1),(464,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzczNTAzNDA4LCJleHAiOjE3NzQxMDgyMDh9.TFyH2fVc9mXXJdPVFad6EOKOGPEYS6HsCyxzPf1VonU','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','desktop','2026-03-21 15:50:08','2026-03-14 15:50:08',0),(465,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzczNTAzNDM5LCJleHAiOjE3NzYwOTU0Mzl9.xWRYMZu9jo_4QQ8u3hrPgmXyVW-ac8QqeLbfeX-RYHA','127.0.0.1','node','desktop','2026-04-13 15:50:40','2026-03-14 15:50:39',1),(466,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzczNTAzNTI5LCJleHAiOjE3NzYwOTU1Mjl9.enrFB8XK194oIbGNCqDkkR0BSUiH5jOxS3-8osPic8Q','127.0.0.1','node','desktop','2026-04-13 15:52:10','2026-03-14 15:52:09',1),(467,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MzUwMzU3NywiZXhwIjoxNzc0MTA4Mzc3fQ.Kb6lfHPVLdaobjhT6stZ2ry5oQ5lJyEF8MauK9O0Ih4','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','desktop','2026-03-21 15:52:58','2026-03-14 15:52:57',0),(469,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzUwMzg5MCwiZXhwIjoxNzc0MTA4NjkwfQ.Pr1WqOvBrKLc1W-0qudgebrqWCZ8kkOJ7E8D43b32hA','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','desktop','2026-03-21 15:58:11','2026-03-14 15:58:10',0),(470,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzUwMzk5NSwiZXhwIjoxNzc0MTA4Nzk1fQ.PWProO5CahVrMXyXkCHSi6Jy08sLG_ZF2vTmPEIq494','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','desktop','2026-03-21 15:59:56','2026-03-14 15:59:55',0),(471,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MzUwMzk5OCwiZXhwIjoxNzc0MTA4Nzk4fQ.PiKJVghnV3QaBhZerNUSMj8xCRREXHa-8DKd3YYhw0k','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','desktop','2026-03-21 15:59:58','2026-03-14 15:59:58',0),(472,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzczNTA0MDk3LCJleHAiOjE3NzYwOTYwOTd9.E6FZ7OWzbk1a2nSeYyG1kPmOig9Xk3qERPaaETLqmEw','127.0.0.1','node','desktop','2026-04-13 16:01:37','2026-03-14 16:01:37',1),(473,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzczNTA0MjQxLCJleHAiOjE3NzYwOTYyNDF9.QlMkJKDCntqPYx1kpV6OMr8Mg-ATzVA17lyhsvDoyiU','127.0.0.1','node','desktop','2026-04-13 16:04:02','2026-03-14 16:04:01',1),(474,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzUwNDI0MSwiZXhwIjoxNzc2MDk2MjQxfQ.w35Q5v5TBSU5vFldNqWiltWBxawjEro6IWe5zNxxfCQ','127.0.0.1','node','desktop','2026-04-13 16:04:02','2026-03-14 16:04:01',1),(476,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MzUwNDM1NSwiZXhwIjoxNzc2MDk2MzU1fQ.joV57tXp3GZqOea5cICNtAJLe5wjJdOxii8FrGJCJzk','127.0.0.1','PostmanRuntime/7.51.1','desktop','2026-04-13 16:05:56','2026-03-14 16:05:55',1),(477,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzUwNDM1NSwiZXhwIjoxNzc2MDk2MzU1fQ.7PRv6dF8jAPC8A86zJX5QSmtPpd8XLeD4Y-1vkuszkI','127.0.0.1','PostmanRuntime/7.51.1','desktop','2026-04-13 16:05:56','2026-03-14 16:05:55',1),(478,60,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MzUwNDM1NiwiZXhwIjoxNzc2MDk2MzU2fQ.dG9SZ0hFxgtz7d5JrEPK2um6F0JY5uq4f7tCXlb0IU4','127.0.0.1','PostmanRuntime/7.51.1','desktop','2026-04-13 16:05:56','2026-03-14 16:05:56',1),(479,61,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzczNTA0MzU2LCJleHAiOjE3NzYwOTYzNTZ9.juYPCnh5F0uVloOpHWzwd05o55cZ5t3Y4x5apE-7cGw','127.0.0.1','PostmanRuntime/7.51.1','desktop','2026-04-13 16:05:56','2026-03-14 16:05:56',1),(480,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzczNTA0MzU2LCJleHAiOjE3NzYwOTYzNTZ9.GbLF_w6GiR1qmzDBEdV_27SejO66wwYZhUi2gDJXGyQ','127.0.0.1','PostmanRuntime/7.51.1','desktop','2026-04-13 16:05:56','2026-03-14 16:05:56',1),(481,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzczNTEwMzM1LCJleHAiOjE3NzQxMTUxMzV9.EVtbSikHua29AabwNXUiLiUCNbjj72TpN56Cm8ql9B4','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','desktop','2026-03-21 17:45:36','2026-03-14 17:45:35',0),(482,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzUxMDM5MywiZXhwIjoxNzc0MTE1MTkzfQ.iolAf6cs12qgxJ0clL4nPZE-rGdRk-nnga9hQMMGTiY','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','desktop','2026-03-21 17:46:33','2026-03-14 17:46:33',0),(483,60,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MzUxMDQyMiwiZXhwIjoxNzc0MTE1MjIyfQ.DQ4pmAIoxzVo08hEIRORXvsFspSOIlqWnH4fPobmIxQ','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','desktop','2026-03-21 17:47:02','2026-03-14 17:47:02',0),(484,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzczNTEwNDU5LCJleHAiOjE3NzQxMTUyNTl9.pMcxIyCCexbam_A9i1skwGMa2iJjMZHxQdeOEPKUlXU','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','desktop','2026-03-21 17:47:39','2026-03-14 17:47:39',0),(485,60,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MzUxMTE5MiwiZXhwIjoxNzc0MTE1OTkyfQ.qgTAeahoNteQlE88hLI6j-Fq875VCGAwb3oJ5xZ8vCc','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','desktop','2026-03-21 17:59:53','2026-03-14 17:59:52',0),(486,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzczNTEyNjUwLCJleHAiOjE3NzQxMTc0NTB9.9kUtxk31EDOJLdf-aCjGk56sywBAMiNRvhBDVttFpgA','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','desktop','2026-03-21 18:24:11','2026-03-14 18:24:10',0),(487,60,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MzUxMjgyNCwiZXhwIjoxNzc0MTE3NjI0fQ.jUgm8Un0IsOrKORWoWx75rbxZSxGwzM14PWJxMpBFD4','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','desktop','2026-03-21 18:27:05','2026-03-14 18:27:04',0),(488,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MzU4Mzk0NCwiZXhwIjoxNzc0MTg4NzQ0fQ.CS_7rtvzCenZX6qMbwg27BhViQsmsEcg20K2hMZB6ZU','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','desktop','2026-03-22 14:12:25','2026-03-15 14:12:24',0),(489,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzczNTgzOTk0LCJleHAiOjE3NzQxODg3OTR9.ebF14ZW4nXklSuuRsxw6FpLq3eX1F4NG0FbK2oyWU6k','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','desktop','2026-03-22 14:13:15','2026-03-15 14:13:14',0),(490,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzczNTg3NjczLCJleHAiOjE3NzQxOTI0NzN9.674kyaJ4JXepwCn_ru54tcFLqVJYfifVhtgDeWvHptA','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','desktop','2026-03-22 15:14:34','2026-03-15 15:14:33',0),(491,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzczNTg4MTIwLCJleHAiOjE3NzQxOTI5MjB9.5gRUALCVTPHoZb5oUfAGdBX2Pg_hsl0cMb4yakOIjeo','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','desktop','2026-03-22 15:22:00','2026-03-15 15:22:00',0),(493,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzczNjEwODU5LCJleHAiOjE3NzQyMTU2NTl9.OF1CvmGgRUqpPrqoV-w20coy4qHqhSAwBDEpowKDXSM','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','desktop','2026-03-22 21:40:59','2026-03-15 21:40:59',0),(494,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzYxMDkyMiwiZXhwIjoxNzc2MjAyOTIyfQ.6uXi5DyZsoestssI9Zls29NojCYhJp2Hn5s2jk7sWAI','127.0.0.1','PostmanRuntime/7.51.1','desktop','2026-04-14 21:42:02','2026-03-15 21:42:02',1),(495,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzYxMTkyMCwiZXhwIjoxNzc0MjE2NzIwfQ.NVR7_oXDRHmQ-SL-gygvrX_W6GiMmIwEBev5kAAZMsk','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','desktop','2026-03-22 21:58:41','2026-03-15 21:58:40',0),(496,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MzYxMjEzMiwiZXhwIjoxNzc0MjE2OTMyfQ.6gaFXoDTTW1e4yfVVSaM3VULy0X2ETwyGdiUucMvky8','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','desktop','2026-03-22 22:02:13','2026-03-15 22:02:12',0),(497,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzczNjEyNzkxLCJleHAiOjE3NzQyMTc1OTF9.uES8chyQe-II9x55HPuMm9QYnAzh-i-luEWchlCWViM','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','desktop','2026-03-22 22:13:12','2026-03-15 22:13:11',0),(498,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzYxMzIwMSwiZXhwIjoxNzc0MjE4MDAxfQ.ygDjXBFqfeFcxcKBZR8Ud9rAeyy_g8uk3tiNJw9guYE','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','desktop','2026-03-22 22:20:01','2026-03-15 22:20:01',0),(499,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MzYxNTU5OSwiZXhwIjoxNzc0MjIwMzk5fQ.Pln9_3IVKwqxY0u4fNIrQywiAE_Awlhme0YVSgtUGSU','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','desktop','2026-03-22 22:59:59','2026-03-15 22:59:59',0),(500,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzYxNTg5OSwiZXhwIjoxNzc0MjIwNjk5fQ.f9owBAh5GtqecUvkjFs4m80Y2o2KlHtfTFt94TFQVQc','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','desktop','2026-03-22 23:04:59','2026-03-15 23:04:59',0),(501,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MzYxNjIxMCwiZXhwIjoxNzc0MjIxMDEwfQ.0nqhqT1KMdV3AmthA1K5b5uBg3r3aD9Yd-k1JqAXgZ0','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','desktop','2026-03-22 23:10:10','2026-03-15 23:10:10',0),(502,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzYxNjgyOCwiZXhwIjoxNzc2MjA4ODI4fQ.Mza4S-OFRkl37qL8XncySHaRO3vyh7UbDS0FJGY6WHw','127.0.0.1','PostmanRuntime/7.51.1','desktop','2026-04-14 23:20:29','2026-03-15 23:20:28',1),(503,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzczNjE2ODQ1LCJleHAiOjE3NzYyMDg4NDV9.BMg8poi7wwlbHAOvVoiNHuGBqjV4MC946knxQ9XoCbs','127.0.0.1','PostmanRuntime/7.51.1','desktop','2026-04-14 23:20:46','2026-03-15 23:20:45',1),(504,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzYxODE2MSwiZXhwIjoxNzc0MjIyOTYxfQ.ugM3FYTzqNE8FEY0ngQu-tdqMuiNy1ehyC5zOy7zOwU','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','desktop','2026-03-22 23:42:41','2026-03-15 23:42:41',0),(505,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MzYxOTY0NCwiZXhwIjoxNzc0MjI0NDQ0fQ.NP1hHOIViKrOaeo6SjQ2PU7Nm36ZxVxdgKdpXW5egog','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','desktop','2026-03-23 00:07:25','2026-03-16 00:07:24',0),(506,66,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjY2LCJlbWFpbCI6ImFtaXJfYWRtaW5AZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJhZG1pbiJdLCJpYXQiOjE3NzM2ODgxNDAsImV4cCI6MTc3NDI5Mjk0MH0.l-glQatdZ7f_68tsj75t4P2SyQ3mxiEphl6fAhiVpIo','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','desktop','2026-03-23 19:09:00','2026-03-16 19:09:00',0),(507,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzczNjkwNzY0LCJleHAiOjE3NzQyOTU1NjR9.i8WYbLAM-8MMfgxYxxbZrvuzP2mZpR9Lw1AVod7G_r8','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-23 19:52:44','2026-03-16 19:52:44',0),(508,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzczNjkwNzc2LCJleHAiOjE3NzQyOTU1NzZ9.gNojDyyC7OBmmYq5zG53bEcPWHKjoEIegX0IoEHdEPM','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-23 19:52:57','2026-03-16 19:52:56',0),(509,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzczNjkwNzg5LCJleHAiOjE3NzQyOTU1ODl9.8zNzDHuyq0HMeL5PMTzmxqouReNfky0VUMPxRYo-gxQ','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-23 19:53:09','2026-03-16 19:53:09',0),(510,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzczNjkwODE3LCJleHAiOjE3NzQyOTU2MTd9.cKUdPFWIlEUtdhuF5wjFL7nKP9sQXV_acRlLPbTakuM','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-23 19:53:37','2026-03-16 19:53:37',0),(511,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzczNjkwOTUzLCJleHAiOjE3NzQyOTU3NTN9.GtRCCY7GOM07ck5iw6r_cXlCBXwJgDlUU-gDyw7rQpU','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-23 19:55:53','2026-03-16 19:55:53',0),(512,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzczNjkxMTE0LCJleHAiOjE3NzQyOTU5MTR9.cDhUy1Av7Z7-3Z74FnC5lEUu7OuYhPi3EyDXlfKyzg8','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-23 19:58:35','2026-03-16 19:58:34',0),(513,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzczNjkxMTM0LCJleHAiOjE3NzQyOTU5MzR9.DsBG_5i2uX4G51d7I92C_emDtYOIHUH6mtu6_9S7JvA','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-23 19:58:54','2026-03-16 19:58:54',0),(514,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzczNjkxMTg1LCJleHAiOjE3NzQyOTU5ODV9.eYJrWN7QBFg5BoKtBIjJmA1IQ7NKGVaHC_csuVccAu0','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-23 19:59:46','2026-03-16 19:59:45',0),(515,66,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjY2LCJlbWFpbCI6ImFtaXJfYWRtaW5AZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJhZG1pbiJdLCJpYXQiOjE3NzM2OTE2MDcsImV4cCI6MTc3NDI5NjQwN30.sfTHcW57kQm5b8jvtWOyGpuy4BHpNa3Zw6uFALLyNcE','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','desktop','2026-03-23 20:06:48','2026-03-16 20:06:47',0),(516,67,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjY3LCJlbWFpbCI6ImFtaXJfaXRhZG1pbkBleGFtcGxlLmNvbSIsInJvbGVzIjpbIml0X2FkbWluIl0sImlhdCI6MTc3MzY5MTY3NSwiZXhwIjoxNzc0Mjk2NDc1fQ.IvN88Gi0DoEFX5BSHQ-OmxUSmvSEM89f_8TLUmrkj1M','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','desktop','2026-03-23 20:07:55','2026-03-16 20:07:55',0),(518,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MzY5MjMwMSwiZXhwIjoxNzc2Mjg0MzAxfQ.rjGNkBCFVurmHZLYJHXsUdUi_IjrEIhOQZQHIe8wXoU','127.0.0.1','PostmanRuntime/7.52.0','desktop','2026-04-15 20:18:22','2026-03-16 20:18:21',1),(519,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzY5MjMwMSwiZXhwIjoxNzc2Mjg0MzAxfQ._J6POeQmKN2ZUIDfMEtVtujfunDbhVu4vayLObrFrvs','127.0.0.1','PostmanRuntime/7.52.0','desktop','2026-04-15 20:18:22','2026-03-16 20:18:21',1),(520,60,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MzY5MjMwMiwiZXhwIjoxNzc2Mjg0MzAyfQ.zZoAFh_4j63LCAJZ4NQXNcAeAG6fujiXROQiEBqDx3E','127.0.0.1','PostmanRuntime/7.52.0','desktop','2026-04-15 20:18:22','2026-03-16 20:18:22',1),(521,61,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzczNjkyMzAyLCJleHAiOjE3NzYyODQzMDJ9.H89fTk8HJwDIOPesfboLdoPRW2RwGV5Foy5iyL9XSEc','127.0.0.1','PostmanRuntime/7.52.0','desktop','2026-04-15 20:18:22','2026-03-16 20:18:22',1),(522,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzczNjkyMzMzLCJleHAiOjE3NzYyODQzMzN9.aIm9z3S9jQ7Cg0BXkaZvPddtQw1wfqOqLtQSiAh32uE','127.0.0.1','PostmanRuntime/7.52.0','desktop','2026-04-15 20:18:54','2026-03-16 20:18:53',1),(524,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MzY5MjM5OSwiZXhwIjoxNzc2Mjg0Mzk5fQ.5WcH0GrqiaGUyMma-0xQRJHQ1kf6GMj67h35PjVqRf4','127.0.0.1','PostmanRuntime/7.52.0','desktop','2026-04-15 20:20:00','2026-03-16 20:19:59',1),(525,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzY5MjQwMCwiZXhwIjoxNzc2Mjg0NDAwfQ.WLUM9SA-FVCtH6eee8YRXjaVcw5zHwF-jf1Zly0PD40','127.0.0.1','PostmanRuntime/7.52.0','desktop','2026-04-15 20:20:00','2026-03-16 20:20:00',1),(526,60,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MzY5MjQwMCwiZXhwIjoxNzc2Mjg0NDAwfQ.R6VSehmwVc1Nsc11UWDm7jW8tHlTbvIP_kJ7INDVW88','127.0.0.1','PostmanRuntime/7.52.0','desktop','2026-04-15 20:20:00','2026-03-16 20:20:00',1),(527,61,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzczNjkyNDAwLCJleHAiOjE3NzYyODQ0MDB9.fFGWqwGqgx4z8Uidf4D2CjxWNApGtHMrbJQfURmrhOo','127.0.0.1','PostmanRuntime/7.52.0','desktop','2026-04-15 20:20:00','2026-03-16 20:20:00',1),(528,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzczNjkyNDAwLCJleHAiOjE3NzYyODQ0MDB9.fPcHGghQtBT99XkVDWU-lRsjgMWYz0RrzM4l41jv9Ok','127.0.0.1','PostmanRuntime/7.52.0','desktop','2026-04-15 20:20:01','2026-03-16 20:20:00',1),(529,66,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjY2LCJlbWFpbCI6ImFtaXJfYWRtaW5AZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJhZG1pbiJdLCJpYXQiOjE3NzM2OTI5NDEsImV4cCI6MTc3NDI5Nzc0MX0.mJcUQJ8aFFrfVR9XTZBuPXeFKRiHxjeMlDw6bgXYBdY','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','desktop','2026-03-23 20:29:01','2026-03-16 20:29:01',0),(531,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MzY5MzE2MCwiZXhwIjoxNzc2Mjg1MTYwfQ.VPwHW3BL_UZwuGnahWUI-MSrH1QcGOH_xDO169yJU00','127.0.0.1','PostmanRuntime/7.52.0','desktop','2026-04-15 20:32:41','2026-03-16 20:32:40',1),(532,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzY5MzE2MCwiZXhwIjoxNzc2Mjg1MTYwfQ.2ZiTnC-_7eZ3c7INsLFYmirF46OqfeD9GiwBNEFVVto','127.0.0.1','PostmanRuntime/7.52.0','desktop','2026-04-15 20:32:41','2026-03-16 20:32:40',1),(533,60,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MzY5MzE2MCwiZXhwIjoxNzc2Mjg1MTYwfQ.RsD8KZ5KZOEs9wE_wmKpWAKthmkqz9nNF170Yqxiyi0','127.0.0.1','PostmanRuntime/7.52.0','desktop','2026-04-15 20:32:41','2026-03-16 20:32:40',1),(534,61,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzczNjkzMTYxLCJleHAiOjE3NzYyODUxNjF9.fAOeLHax0blk1xCY9-huWcfN9CuO9cBgOK-6Oqkc904','127.0.0.1','PostmanRuntime/7.52.0','desktop','2026-04-15 20:32:41','2026-03-16 20:32:41',1),(535,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzczNjkzMTYxLCJleHAiOjE3NzYyODUxNjF9.MO4gZRSjXeigQsi3_naTNvbddFSxXwsZQeZzNzZ8Wtw','127.0.0.1','PostmanRuntime/7.52.0','desktop','2026-04-15 20:32:41','2026-03-16 20:32:41',1),(536,66,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjY2LCJlbWFpbCI6ImFtaXJfYWRtaW5AZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJhZG1pbiJdLCJpYXQiOjE3NzM2OTMyNzIsImV4cCI6MTc3NDI5ODA3Mn0.AIIFX_VSBF1vdsjz5mTbyI1K_N3Q5bhSlrdO-IBcugk','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','desktop','2026-03-23 20:34:32','2026-03-16 20:34:32',0),(537,67,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjY3LCJlbWFpbCI6ImFtaXJfaXRhZG1pbkBleGFtcGxlLmNvbSIsInJvbGVzIjpbIml0X2FkbWluIl0sImlhdCI6MTc3MzY5MzI4MywiZXhwIjoxNzc0Mjk4MDgzfQ.vAQpqXiAQl98yMBzo6x3oCbOxe7EVUmKXsFcbu027Zg','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','desktop','2026-03-23 20:34:43','2026-03-16 20:34:43',0),(539,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MzY5Mzg4NywiZXhwIjoxNzc2Mjg1ODg3fQ.43Q_dHixo5_oPvyXm3Eh5MgrB-2UVf5D5mfZiiw_e3w','127.0.0.1','PostmanRuntime/7.52.0','desktop','2026-04-15 20:44:47','2026-03-16 20:44:47',1),(540,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzY5Mzg4NywiZXhwIjoxNzc2Mjg1ODg3fQ.iOqUkq-s7ZdI27-5LnXguWDmbFutBB_--yUglRSp5ZU','127.0.0.1','PostmanRuntime/7.52.0','desktop','2026-04-15 20:44:47','2026-03-16 20:44:47',1),(541,60,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MzY5Mzg4NywiZXhwIjoxNzc2Mjg1ODg3fQ.V67sZgvn-Bv8x5j6lR4Joy_ZMwP21-0FO5MDRJpUNJc','127.0.0.1','PostmanRuntime/7.52.0','desktop','2026-04-15 20:44:47','2026-03-16 20:44:47',1),(542,61,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzczNjkzODg3LCJleHAiOjE3NzYyODU4ODd9.E6STgnyZehxBNThzA-b-EpQGsMWUb4iuPoM8hWyCTQc','127.0.0.1','PostmanRuntime/7.52.0','desktop','2026-04-15 20:44:48','2026-03-16 20:44:47',1),(543,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzczNjkzODg3LCJleHAiOjE3NzYyODU4ODd9.MsscTw5QSRqIgDiPHJhFOvHvyYL750K9a379qIu9bWA','127.0.0.1','PostmanRuntime/7.52.0','desktop','2026-04-15 20:44:48','2026-03-16 20:44:47',1),(545,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MzY5MzkwNiwiZXhwIjoxNzc2Mjg1OTA2fQ.QYX39fuNf9hBvWN9k2bLEE9bSfANUPZ26rpINRmHLI0','127.0.0.1','PostmanRuntime/7.52.0','desktop','2026-04-15 20:45:06','2026-03-16 20:45:06',1),(546,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzY5MzkwNiwiZXhwIjoxNzc2Mjg1OTA2fQ.O0mbWx3g_DXXw3IAmXpjbf6mrxlFZMMIBkqJwwk0TBY','127.0.0.1','PostmanRuntime/7.52.0','desktop','2026-04-15 20:45:06','2026-03-16 20:45:06',1),(547,60,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MzY5MzkwNiwiZXhwIjoxNzc2Mjg1OTA2fQ.qAJyL8t22kVN8WBaRdCTvxMCJI09vIFtNjgRfeUPEv0','127.0.0.1','PostmanRuntime/7.52.0','desktop','2026-04-15 20:45:06','2026-03-16 20:45:06',1),(548,61,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzczNjkzOTA2LCJleHAiOjE3NzYyODU5MDZ9.JiDVxOoigAY7lmWHfEuBO5k1D2Lk0h6kG4W7e-G1MME','127.0.0.1','PostmanRuntime/7.52.0','desktop','2026-04-15 20:45:07','2026-03-16 20:45:06',1),(549,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzczNjkzOTA2LCJleHAiOjE3NzYyODU5MDZ9.UDuID4dJg7ndlPejHSpxsMjQeiSgTgBj3LuszGJXb3c','127.0.0.1','PostmanRuntime/7.52.0','desktop','2026-04-15 20:45:07','2026-03-16 20:45:06',1),(551,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MzY5NDQyMiwiZXhwIjoxNzc2Mjg2NDIyfQ.5lr6CmJyAG_eyYg9OlXjvZUg6bLfvq9t-AYr3Yuwdh4','127.0.0.1','PostmanRuntime/7.52.0','desktop','2026-04-15 20:53:42','2026-03-16 20:53:42',1),(552,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzY5NDQyMiwiZXhwIjoxNzc2Mjg2NDIyfQ.QtxgBesZfym8jGzxar58mi2hM3iNA8DjY3Qyh0zor14','127.0.0.1','PostmanRuntime/7.52.0','desktop','2026-04-15 20:53:42','2026-03-16 20:53:42',1),(553,60,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MzY5NDQyMiwiZXhwIjoxNzc2Mjg2NDIyfQ.StwnRUPrFOEti_LHof3T2bshpb81qQ9PmGoItvedlog','127.0.0.1','PostmanRuntime/7.52.0','desktop','2026-04-15 20:53:43','2026-03-16 20:53:42',1),(554,61,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzczNjk0NDIyLCJleHAiOjE3NzYyODY0MjJ9.MRn6uqyywzbvmPk3sQhZyaaMVJgn1HlWuWjMjg5juGE','127.0.0.1','PostmanRuntime/7.52.0','desktop','2026-04-15 20:53:43','2026-03-16 20:53:42',1),(555,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzczNjk0NDIyLCJleHAiOjE3NzYyODY0MjJ9.Y9mYku_EIzFe9vnldeUXTt1sO_ydxSuctRFnNl3TydI','127.0.0.1','PostmanRuntime/7.52.0','desktop','2026-04-15 20:53:43','2026-03-16 20:53:42',1),(556,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzY5NDU1MywiZXhwIjoxNzc0Mjk5MzUzfQ.AI-yvgyGMOG2xl4ZScwkD7bcAm7hnuM3JT8D6VFv5sI','127.0.0.1','PostmanRuntime/7.52.0','desktop','2026-03-23 20:55:53','2026-03-16 20:55:53',0),(557,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MzY5NDU1MywiZXhwIjoxNzc0Mjk5MzUzfQ.y4zUWLMuKbwGme8xKalAVy6eGxocAZmLoG1-Tnswi68','127.0.0.1','PostmanRuntime/7.52.0','desktop','2026-03-23 20:55:53','2026-03-16 20:55:53',0),(558,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzczNjk0NTUzLCJleHAiOjE3NzQyOTkzNTN9.Rax8bMbmUAleMObXNth3wQh0_DHbcBYbcKsnjgGWrKA','127.0.0.1','PostmanRuntime/7.52.0','desktop','2026-03-23 20:55:53','2026-03-16 20:55:53',0),(559,60,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MzY5NDU1MywiZXhwIjoxNzc0Mjk5MzUzfQ.0LBv0xy37CBOwUgu4ZY5XuiVLVsQJb0ouTjMpdHhHRg','127.0.0.1','PostmanRuntime/7.52.0','desktop','2026-03-23 20:55:54','2026-03-16 20:55:53',0),(560,61,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzczNjk0NTUzLCJleHAiOjE3NzQyOTkzNTN9.8h91-Il5d_OifDdLuf2rsp1MvYmr-Cn1L3bGtZXGQnk','127.0.0.1','PostmanRuntime/7.52.0','desktop','2026-03-23 20:55:54','2026-03-16 20:55:53',0),(561,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzY5NDU4NCwiZXhwIjoxNzc0Mjk5Mzg0fQ.v4t9Tfe8yYj4xGRQ0jVn7hghf0ZC2Qxh5oEKjKqcShw','127.0.0.1','PostmanRuntime/7.52.0','desktop','2026-03-23 20:56:24','2026-03-16 20:56:24',0),(562,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MzY5NDU4NCwiZXhwIjoxNzc0Mjk5Mzg0fQ.NnQScWIPItwvIwXUHVKpqqK1oL4Sp7LhFHhULPiVWrg','127.0.0.1','PostmanRuntime/7.52.0','desktop','2026-03-23 20:56:24','2026-03-16 20:56:24',0),(563,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzczNjk0NTg0LCJleHAiOjE3NzQyOTkzODR9.dB2gzzRcdE5OreZQhAhMM-7n4kgWtt8cJoRhUwqleGc','127.0.0.1','PostmanRuntime/7.52.0','desktop','2026-03-23 20:56:24','2026-03-16 20:56:24',0),(564,60,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MzY5NDU4NCwiZXhwIjoxNzc0Mjk5Mzg0fQ.WMq7UmTdeoJ7YqxDbmeW--7L3jXI7aD1fV3HEfWEPm8','127.0.0.1','PostmanRuntime/7.52.0','desktop','2026-03-23 20:56:25','2026-03-16 20:56:24',0),(565,61,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzczNjk0NTg0LCJleHAiOjE3NzQyOTkzODR9.PsFttk2fTiupzsQ_GLxzG07AMJhmrjZ-ni_C6XE8B8A','127.0.0.1','PostmanRuntime/7.52.0','desktop','2026-03-23 20:56:25','2026-03-16 20:56:24',0),(566,66,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjY2LCJlbWFpbCI6ImFtaXJfYWRtaW5AZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJhZG1pbiJdLCJpYXQiOjE3NzM2OTQ2MDUsImV4cCI6MTc3NDI5OTQwNX0.a9EIIh5bUGfNJTKBCDVEIDQ6Cyhs6Ef-3KlSRnS7pok','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','desktop','2026-03-23 20:56:46','2026-03-16 20:56:45',0),(567,67,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjY3LCJlbWFpbCI6ImFtaXJfaXRhZG1pbkBleGFtcGxlLmNvbSIsInJvbGVzIjpbIml0X2FkbWluIl0sImlhdCI6MTc3MzY5NDY5MCwiZXhwIjoxNzc0Mjk5NDkwfQ.tkBoOmeDzmP9Pazdc-khsxY6kanFQ3r8GuusA83lsx8','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','desktop','2026-03-23 20:58:11','2026-03-16 20:58:10',0),(568,61,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzczNjk4NTMzLCJleHAiOjE3NzQzMDMzMzN9.xSchigA2aCuwLBUMOkXkTCYMuJ5u5IFKDo6hYkCirTU','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-23 22:02:14','2026-03-16 22:02:13',0),(569,61,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzczNjk4NjIzLCJleHAiOjE3NzQzMDM0MjN9.Qi2drvGe7EBeZcQYEVTXikFqZmUy718Ks1ytQQz4dGQ','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Microsoft Windows 10.0.26200; en-US) PowerShell/7.5.4','desktop','2026-03-23 22:03:43','2026-03-16 22:03:43',0),(570,61,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzczNjk4Njk3LCJleHAiOjE3NzQzMDM0OTd9.1aeKXYuM-Xk1Cge3i2iZAbD2osmsM60cxSrryr-aJVc','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.26100.7705','desktop','2026-03-23 22:04:58','2026-03-16 22:04:57',0),(571,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzczNjk4Njk3LCJleHAiOjE3NzQzMDM0OTd9.Yu-qtbr44gBou5-haiIiy-p5UVzrAggoBhcMKuxu8w4','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.26100.7705','desktop','2026-03-23 22:04:58','2026-03-16 22:04:57',0),(572,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzY5ODY5NywiZXhwIjoxNzc0MzAzNDk3fQ.dOkbaKiy5WPJhNOvNVNFBvX7B0ete83L4FX6ecslHgw','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.26100.7705','desktop','2026-03-23 22:04:58','2026-03-16 22:04:57',0),(573,66,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjY2LCJlbWFpbCI6ImFtaXJfYWRtaW5AZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJhZG1pbiJdLCJpYXQiOjE3NzM2OTkzNjIsImV4cCI6MTc3NDMwNDE2Mn0.Q6NGoG6lGoZaJjoiLPqYSaYBFbOQlZ3JFUlPRCLd6As','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','desktop','2026-03-23 22:16:02','2026-03-16 22:16:02',0),(574,67,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjY3LCJlbWFpbCI6ImFtaXJfaXRhZG1pbkBleGFtcGxlLmNvbSIsInJvbGVzIjpbIml0X2FkbWluIl0sImlhdCI6MTc3MzY5OTU2NCwiZXhwIjoxNzc0MzA0MzY0fQ.BFsSW2K2EvXALeEe_UzKst_hKvm86pBaKP-zTnBIyt0','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36','desktop','2026-03-23 22:19:25','2026-03-16 22:19:24',0),(576,58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU4LCJlbWFpbCI6Imluc3RydWN0b3IudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJpbnN0cnVjdG9yIl0sImlhdCI6MTc3MzcwMDI3OCwiZXhwIjoxNzc2MjkyMjc4fQ.emeBZ5hsjq-O6IsJgVhmMsH3HEpSL0TERf1fFZyraCA','127.0.0.1','PostmanRuntime/7.52.0','desktop','2026-04-15 22:31:18','2026-03-16 22:31:18',1),(577,57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU3LCJlbWFpbCI6InN0dWRlbnQudGFyZWtAZXhhbXBsZS5jb20iLCJyb2xlcyI6WyJzdHVkZW50Il0sImlhdCI6MTc3MzcwMDI3OCwiZXhwIjoxNzc2MjkyMjc4fQ.WE1fUb4-S4y1m35kdtxTEwrso7mz4t1Ex8gqnCOxJeQ','127.0.0.1','PostmanRuntime/7.52.0','desktop','2026-04-15 22:31:19','2026-03-16 22:31:18',1),(578,60,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYwLCJlbWFpbCI6InRhLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsidGVhY2hpbmdfYXNzaXN0YW50Il0sImlhdCI6MTc3MzcwMDI3OCwiZXhwIjoxNzc2MjkyMjc4fQ.uASERf8mcJBVdc9L1fzHrr8CGD-pGltM_VlmQajDgTI','127.0.0.1','PostmanRuntime/7.52.0','desktop','2026-04-15 22:31:19','2026-03-16 22:31:18',1),(579,61,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjYxLCJlbWFpbCI6Iml0X2FkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiaXRfYWRtaW4iXSwiaWF0IjoxNzczNzAwMjc4LCJleHAiOjE3NzYyOTIyNzh9.FPTMLPH913O0X6Jz29PCRzxAsfpHNZL5KxaH4kfOHD4','127.0.0.1','PostmanRuntime/7.52.0','desktop','2026-04-15 22:31:19','2026-03-16 22:31:18',1),(580,59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjU5LCJlbWFpbCI6ImFkbWluLnRhcmVrQGV4YW1wbGUuY29tIiwicm9sZXMiOlsiYWRtaW4iXSwiaWF0IjoxNzczNzAwMjc5LCJleHAiOjE3NzYyOTIyNzl9.T3Fvg9ltz3EonMGV_Ay6sc7kAnwGyIVNJ6VyZXGshJg','127.0.0.1','PostmanRuntime/7.52.0','desktop','2026-04-15 22:31:19','2026-03-16 22:31:19',1);
/*!40000 ALTER TABLE `sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ssl_certificates`
--

DROP TABLE IF EXISTS `ssl_certificates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ssl_certificates` (
  `cert_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `campus_id` bigint unsigned NOT NULL,
  `domain_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `certificate_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `private_key_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `issuer` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `valid_from` date NOT NULL,
  `valid_until` date NOT NULL,
  `status` enum('active','expiring_soon','expired','revoked') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'active',
  `auto_renew` tinyint(1) DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`cert_id`),
  KEY `idx_campus` (`campus_id`),
  KEY `idx_status` (`status`),
  KEY `idx_expiry` (`valid_until`),
  CONSTRAINT `ssl_certificates_ibfk_1` FOREIGN KEY (`campus_id`) REFERENCES `campuses` (`campus_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ssl_certificates`
--

LOCK TABLES `ssl_certificates` WRITE;
/*!40000 ALTER TABLE `ssl_certificates` DISABLE KEYS */;
INSERT INTO `ssl_certificates` VALUES (1,1,'main.campus.edu','/etc/ssl/certs/main_campus.crt','/etc/ssl/private/main_campus.key','Let\'s Encrypt','2025-01-01','2025-12-31','active',1,'2025-11-20 13:43:01','2025-11-20 13:43:01'),(2,2,'downtown.campus.edu','/etc/ssl/certs/downtown.crt','/etc/ssl/private/downtown.key','DigiCert','2024-06-01','2025-05-31','expiring_soon',1,'2025-11-20 13:43:01','2025-11-20 13:43:01'),(3,3,'online.campus.edu','/etc/ssl/certs/online.crt','/etc/ssl/private/online.key','Let\'s Encrypt','2025-02-01','2026-01-31','active',1,'2025-11-20 13:43:01','2025-11-20 13:43:01');
/*!40000 ALTER TABLE `ssl_certificates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `student_progress`
--

DROP TABLE IF EXISTS `student_progress`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `student_progress` (
  `progress_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `course_id` bigint unsigned NOT NULL,
  `enrollment_id` bigint unsigned NOT NULL,
  `completion_percentage` decimal(5,2) DEFAULT '0.00',
  `materials_viewed` int DEFAULT '0',
  `total_materials` int DEFAULT '0',
  `assignments_completed` int DEFAULT '0',
  `total_assignments` int DEFAULT '0',
  `quizzes_completed` int DEFAULT '0',
  `total_quizzes` int DEFAULT '0',
  `average_score` decimal(5,2) DEFAULT NULL,
  `time_spent_minutes` int DEFAULT '0',
  `last_activity_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`progress_id`),
  UNIQUE KEY `unique_user_course` (`user_id`,`course_id`),
  KEY `enrollment_id` (`enrollment_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_course` (`course_id`),
  KEY `idx_user_course_completion` (`user_id`,`course_id`,`completion_percentage`),
  CONSTRAINT `student_progress_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `student_progress_ibfk_2` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`) ON DELETE CASCADE,
  CONSTRAINT `student_progress_ibfk_3` FOREIGN KEY (`enrollment_id`) REFERENCES `course_enrollments` (`enrollment_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `student_progress`
--

LOCK TABLES `student_progress` WRITE;
/*!40000 ALTER TABLE `student_progress` DISABLE KEYS */;
INSERT INTO `student_progress` VALUES (6,57,1,235,65.00,8,12,3,5,2,4,78.50,420,'2026-03-11 18:12:04','2026-03-11 18:12:04'),(7,57,2,236,45.00,5,10,2,4,1,3,82.00,280,'2026-03-10 18:12:04','2026-03-11 18:12:04'),(8,57,3,237,80.00,10,12,4,5,3,3,91.25,560,'2026-03-11 16:12:04','2026-03-11 18:12:04'),(9,57,4,238,30.00,3,10,1,4,0,2,70.00,150,'2026-03-08 18:12:04','2026-03-11 18:12:04');
/*!40000 ALTER TABLE `student_progress` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `student_tasks`
--

DROP TABLE IF EXISTS `student_tasks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `student_tasks` (
  `task_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `task_type` enum('assignment','quiz','lab','study','custom') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `assignment_id` bigint unsigned DEFAULT NULL,
  `quiz_id` bigint unsigned DEFAULT NULL,
  `lab_id` bigint unsigned DEFAULT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `due_date` timestamp NULL DEFAULT NULL,
  `priority` enum('low','medium','high') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'medium',
  `status` enum('pending','in_progress','completed','overdue') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  `completion_percentage` int DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`task_id`),
  KEY `assignment_id` (`assignment_id`),
  KEY `quiz_id` (`quiz_id`),
  KEY `lab_id` (`lab_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_status` (`status`),
  KEY `idx_due_date` (`due_date`),
  CONSTRAINT `student_tasks_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `student_tasks_ibfk_2` FOREIGN KEY (`assignment_id`) REFERENCES `assignments` (`assignment_id`) ON DELETE CASCADE,
  CONSTRAINT `student_tasks_ibfk_3` FOREIGN KEY (`quiz_id`) REFERENCES `quizzes` (`quiz_id`) ON DELETE CASCADE,
  CONSTRAINT `student_tasks_ibfk_4` FOREIGN KEY (`lab_id`) REFERENCES `labs` (`lab_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `student_tasks`
--

LOCK TABLES `student_tasks` WRITE;
/*!40000 ALTER TABLE `student_tasks` DISABLE KEYS */;
INSERT INTO `student_tasks` VALUES (5,8,'custom',NULL,NULL,NULL,'Review lecture notes','Go through weeks 1-3','2025-02-20 21:59:59','medium','in_progress',75,'2025-11-20 13:43:00','2025-11-20 13:43:00'),(6,9,'study',NULL,NULL,NULL,'Prepare for midterm','Review all materials','2025-03-15 21:59:59','high','in_progress',40,'2025-11-20 13:43:00','2025-11-20 13:43:00'),(7,57,'assignment',NULL,NULL,NULL,'Complete Assignment 1','Finish the Hello World assignment','2026-03-14 18:12:04','high','pending',0,'2026-03-11 18:12:04','2026-03-11 18:12:04'),(8,57,'quiz',NULL,NULL,NULL,'Prepare for Quiz 2','Study chapters 3-5 for upcoming quiz','2026-03-16 18:12:04','medium','completed',100,'2026-03-11 18:12:04','2026-03-11 18:19:15'),(9,57,'study',NULL,NULL,NULL,'Review Data Structures Notes','Review linked lists and trees','2026-03-18 18:12:04','low','completed',100,'2026-03-11 18:12:04','2026-03-11 18:22:38'),(10,57,'custom',NULL,NULL,NULL,'Meet with study group','Library room 204 at 3pm','2026-03-12 18:12:04','medium','pending',0,'2026-03-11 18:12:04','2026-03-11 18:12:04'),(11,57,'lab',NULL,NULL,NULL,'Complete Lab 3 Report','Write up results from lab experiment','2026-03-13 18:12:04','high','in_progress',60,'2026-03-11 18:12:04','2026-03-11 18:12:04'),(14,57,'study',NULL,NULL,NULL,'Test',NULL,NULL,'low','pending',0,'2026-03-11 18:23:45','2026-03-11 18:23:45'),(15,57,'study',NULL,NULL,NULL,'Study for Final Exam','Review all chapters','2026-03-18 18:14:02','high','pending',0,'2026-03-14 15:17:54','2026-03-14 15:17:54'),(16,57,'study',NULL,NULL,NULL,'Study for Final Exam','Review all chapters','2026-03-18 18:14:02','high','pending',0,'2026-03-14 15:36:11','2026-03-14 15:36:11'),(17,57,'study',NULL,NULL,NULL,'Study for Final Exam','Review all chapters','2026-03-18 18:14:02','high','pending',0,'2026-03-14 15:40:51','2026-03-14 15:40:51'),(18,57,'study',NULL,NULL,NULL,'Study for Final Exam','Review all chapters','2026-03-18 18:14:02','high','pending',0,'2026-03-14 16:06:13','2026-03-14 16:06:13'),(19,57,'study',NULL,NULL,NULL,'Study for Final Exam','Review all chapters','2026-03-18 18:14:02','high','pending',0,'2026-03-16 20:19:12','2026-03-16 20:19:12'),(20,57,'study',NULL,NULL,NULL,'Study for Final Exam','Review all chapters','2026-03-18 18:14:02','high','pending',0,'2026-03-16 20:20:17','2026-03-16 20:20:17'),(21,57,'study',NULL,NULL,NULL,'Study for Final Exam','Review all chapters','2026-03-18 18:14:02','high','pending',0,'2026-03-16 20:32:59','2026-03-16 20:32:59'),(22,57,'study',NULL,NULL,NULL,'Study for Final Exam','Review all chapters','2026-03-18 18:14:02','high','pending',0,'2026-03-16 20:45:25','2026-03-16 20:45:25'),(23,57,'study',NULL,NULL,NULL,'Study for Final Exam','Review all chapters','2026-03-18 18:14:02','high','pending',0,'2026-03-16 20:54:01','2026-03-16 20:54:01'),(24,57,'study',NULL,NULL,NULL,'Study for Final Exam','Review all chapters','2026-03-18 18:14:02','high','pending',0,'2026-03-16 22:31:37','2026-03-16 22:31:37');
/*!40000 ALTER TABLE `student_tasks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `study_group_members`
--

DROP TABLE IF EXISTS `study_group_members`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `study_group_members` (
  `member_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `group_id` bigint unsigned NOT NULL,
  `user_id` bigint unsigned NOT NULL,
  `role` enum('creator','moderator','member') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'member',
  `joined_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`member_id`),
  UNIQUE KEY `unique_group_user` (`group_id`,`user_id`),
  KEY `idx_group` (`group_id`),
  KEY `idx_user` (`user_id`),
  CONSTRAINT `study_group_members_ibfk_1` FOREIGN KEY (`group_id`) REFERENCES `study_groups` (`group_id`) ON DELETE CASCADE,
  CONSTRAINT `study_group_members_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `study_group_members`
--

LOCK TABLES `study_group_members` WRITE;
/*!40000 ALTER TABLE `study_group_members` DISABLE KEYS */;
INSERT INTO `study_group_members` VALUES (5,2,12,'creator','2025-11-20 13:43:00'),(6,2,13,'member','2025-11-20 13:43:00'),(7,2,14,'member','2025-11-20 13:43:00');
/*!40000 ALTER TABLE `study_group_members` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `study_groups`
--

DROP TABLE IF EXISTS `study_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `study_groups` (
  `group_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `course_id` bigint unsigned NOT NULL,
  `group_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_by` bigint unsigned NOT NULL,
  `max_members` int DEFAULT '10',
  `current_members` int DEFAULT '1',
  `is_public` tinyint(1) DEFAULT '1',
  `meeting_schedule` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('active','inactive','archived') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'active',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`group_id`),
  KEY `idx_course` (`course_id`),
  KEY `idx_creator` (`created_by`),
  CONSTRAINT `study_groups_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`) ON DELETE CASCADE,
  CONSTRAINT `study_groups_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `study_groups`
--

LOCK TABLES `study_groups` WRITE;
/*!40000 ALTER TABLE `study_groups` DISABLE KEYS */;
INSERT INTO `study_groups` VALUES (2,2,'Data Structures Masters','Advanced study group for CS201',12,5,3,1,'Monday & Wednesday 5-7 PM','active','2025-11-20 13:43:00','2025-11-20 13:43:00');
/*!40000 ALTER TABLE `study_groups` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `subscription_plans`
--

DROP TABLE IF EXISTS `subscription_plans`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `subscription_plans` (
  `plan_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `plan_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `price` decimal(10,2) NOT NULL,
  `currency` varchar(3) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'USD',
  `billing_cycle` enum('monthly','quarterly','yearly') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'monthly',
  `features` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`plan_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `subscription_plans`
--

LOCK TABLES `subscription_plans` WRITE;
/*!40000 ALTER TABLE `subscription_plans` DISABLE KEYS */;
/*!40000 ALTER TABLE `subscription_plans` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `support_tickets`
--

DROP TABLE IF EXISTS `support_tickets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `support_tickets` (
  `ticket_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `feedback_id` bigint unsigned DEFAULT NULL,
  `ticket_number` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `subject` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `category` enum('technical','academic','account','payment','general') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `priority` enum('low','medium','high','urgent') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'medium',
  `status` enum('open','in_progress','waiting_user','waiting_admin','resolved','closed') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'open',
  `assigned_to` bigint unsigned DEFAULT NULL,
  `resolution` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `first_response_at` timestamp NULL DEFAULT NULL,
  `resolved_at` timestamp NULL DEFAULT NULL,
  `closed_at` timestamp NULL DEFAULT NULL,
  `satisfaction_rating` int DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ticket_id`),
  UNIQUE KEY `ticket_number` (`ticket_number`),
  KEY `feedback_id` (`feedback_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_ticket_number` (`ticket_number`),
  KEY `idx_status` (`status`),
  KEY `idx_assigned` (`assigned_to`),
  CONSTRAINT `support_tickets_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `support_tickets_ibfk_2` FOREIGN KEY (`feedback_id`) REFERENCES `user_feedback` (`feedback_id`) ON DELETE SET NULL,
  CONSTRAINT `support_tickets_ibfk_3` FOREIGN KEY (`assigned_to`) REFERENCES `users` (`user_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `support_tickets`
--

LOCK TABLES `support_tickets` WRITE;
/*!40000 ALTER TABLE `support_tickets` DISABLE KEYS */;
INSERT INTO `support_tickets` VALUES (1,7,1,'TKT-2025-001','Cannot submit assignment','Student unable to upload file for assignment submission','technical','high','resolved',1,NULL,'2025-02-10 08:30:00','2025-02-10 12:45:00',NULL,5,'2025-11-20 13:43:00','2025-11-20 13:43:00'),(2,10,4,'TKT-2025-002','Grade not updated','Quiz grade not reflected in gradebook','academic','medium','resolved',1,NULL,'2025-02-12 07:15:00','2025-02-12 14:20:00',NULL,4,'2025-11-20 13:43:00','2025-11-20 13:43:00'),(3,12,NULL,'TKT-2025-003','Reset password not working','Password reset email not arriving','account','high','in_progress',1,NULL,'2025-02-14 09:00:00',NULL,NULL,NULL,'2025-11-20 13:43:00','2025-11-20 13:43:00'),(4,13,NULL,'TKT-2025-004','Course enrollment issue','Cannot enroll in CS301 - shows full but seats available','academic','medium','open',NULL,NULL,NULL,NULL,NULL,NULL,'2025-11-20 13:43:00','2025-11-20 13:43:00');
/*!40000 ALTER TABLE `support_tickets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `system_alerts`
--

DROP TABLE IF EXISTS `system_alerts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `system_alerts` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `condition_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `threshold` float NOT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_by` bigint unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `system_alerts_ibfk_updated_by` (`updated_by`),
  CONSTRAINT `system_alerts_ibfk_updated_by` FOREIGN KEY (`updated_by`) REFERENCES `users` (`user_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `system_alerts`
--

LOCK TABLES `system_alerts` WRITE;
/*!40000 ALTER TABLE `system_alerts` DISABLE KEYS */;
INSERT INTO `system_alerts` VALUES (2,'High CPU Alert','Triggers when CPU usage exceeds threshold updated','cpu_usage',90,1,'2026-03-16 22:20:56',NULL);
/*!40000 ALTER TABLE `system_alerts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `system_errors`
--

DROP TABLE IF EXISTS `system_errors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `system_errors` (
  `error_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `error_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `error_message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `error_type` enum('application','database','api','security','system') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `severity` enum('low','medium','high','critical') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'medium',
  `stack_trace` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `user_id` bigint unsigned DEFAULT NULL,
  `ip_address` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `request_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `is_resolved` tinyint(1) DEFAULT '0',
  `resolved_by` bigint unsigned DEFAULT NULL,
  `resolved_at` timestamp NULL DEFAULT NULL,
  `resolution_notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`error_id`),
  KEY `user_id` (`user_id`),
  KEY `resolved_by` (`resolved_by`),
  KEY `idx_type` (`error_type`),
  KEY `idx_severity` (`severity`),
  KEY `idx_resolved` (`is_resolved`),
  KEY `idx_date` (`created_at`),
  CONSTRAINT `system_errors_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL,
  CONSTRAINT `system_errors_ibfk_2` FOREIGN KEY (`resolved_by`) REFERENCES `users` (`user_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `system_errors`
--

LOCK TABLES `system_errors` WRITE;
/*!40000 ALTER TABLE `system_errors` DISABLE KEYS */;
/*!40000 ALTER TABLE `system_errors` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `system_settings`
--

DROP TABLE IF EXISTS `system_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `system_settings` (
  `setting_id` int unsigned NOT NULL AUTO_INCREMENT,
  `setting_key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `setting_value` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `setting_type` enum('string','number','boolean','json') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'string',
  `category` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `is_public` tinyint(1) DEFAULT '0',
  `updated_by` bigint unsigned DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`setting_id`),
  UNIQUE KEY `setting_key` (`setting_key`),
  KEY `system_settings_ibfk_updated_by` (`updated_by`),
  CONSTRAINT `system_settings_ibfk_updated_by` FOREIGN KEY (`updated_by`) REFERENCES `users` (`user_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `system_settings`
--

LOCK TABLES `system_settings` WRITE;
/*!40000 ALTER TABLE `system_settings` DISABLE KEYS */;
INSERT INTO `system_settings` VALUES (1,'platform_name','EduVerse Pro','string','general','Platform display name',1,66,'2026-03-16 19:39:07','2026-03-16 20:59:22'),(2,'max_file_upload_size','52428800','number','files','Maximum file upload size in bytes (50MB)',0,NULL,'2026-03-16 19:39:07','2025-11-20 13:43:00'),(3,'session_timeout_minutes','120','number','security','Session timeout duration',0,NULL,'2026-03-16 19:39:07','2025-11-20 13:43:00'),(4,'enable_ai_features','true','boolean','features','Enable AI-powered features',0,NULL,'2026-03-16 19:39:07','2025-11-20 13:43:00'),(5,'enable_gamification','true','boolean','features','Enable gamification system',1,NULL,'2026-03-16 19:39:07','2025-11-20 13:43:00'),(6,'default_language','en','string','localization','Default platform language',1,NULL,'2026-03-16 19:39:07','2025-11-20 13:43:00'),(7,'enable_face_recognition','true','boolean','features','Enable face recognition for attendance',0,NULL,'2026-03-16 19:39:07','2025-11-20 13:43:00'),(8,'maintenance_mode','false','boolean','system','System maintenance mode',0,NULL,'2026-03-16 19:39:07','2025-11-20 13:43:00'),(9,'max_login_attempts','5','number','security','Maximum failed login attempts before lockout',0,NULL,'2026-03-16 19:39:07','2025-11-20 13:43:00'),(10,'password_min_length','8','number','security','Minimum password length',0,NULL,'2026-03-16 19:39:07','2025-11-20 13:43:00');
/*!40000 ALTER TABLE `system_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ta_instructor_access`
--

DROP TABLE IF EXISTS `ta_instructor_access`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ta_instructor_access` (
  `access_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `instructor_id` bigint unsigned NOT NULL,
  `ta_id` bigint unsigned NOT NULL,
  `section_id` bigint unsigned NOT NULL,
  `access_level` enum('view','grade','edit','full') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'grade',
  `can_upload_materials` tinyint(1) DEFAULT '0',
  `can_create_assignments` tinyint(1) DEFAULT '0',
  `can_grade_assignments` tinyint(1) DEFAULT '1',
  `can_manage_attendance` tinyint(1) DEFAULT '1',
  `can_send_announcements` tinyint(1) DEFAULT '0',
  `granted_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `revoked_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`access_id`),
  KEY `idx_instructor` (`instructor_id`),
  KEY `idx_ta` (`ta_id`),
  KEY `idx_section` (`section_id`),
  CONSTRAINT `ta_instructor_access_ibfk_1` FOREIGN KEY (`instructor_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `ta_instructor_access_ibfk_2` FOREIGN KEY (`ta_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `ta_instructor_access_ibfk_3` FOREIGN KEY (`section_id`) REFERENCES `course_sections` (`section_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ta_instructor_access`
--

LOCK TABLES `ta_instructor_access` WRITE;
/*!40000 ALTER TABLE `ta_instructor_access` DISABLE KEYS */;
/*!40000 ALTER TABLE `ta_instructor_access` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `task_completion`
--

DROP TABLE IF EXISTS `task_completion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `task_completion` (
  `completion_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `task_id` bigint unsigned NOT NULL,
  `user_id` bigint unsigned NOT NULL,
  `completed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `time_taken_minutes` int DEFAULT NULL,
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`completion_id`),
  UNIQUE KEY `task_id` (`task_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `task_completion_ibfk_1` FOREIGN KEY (`task_id`) REFERENCES `student_tasks` (`task_id`) ON DELETE CASCADE,
  CONSTRAINT `task_completion_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `task_completion`
--

LOCK TABLES `task_completion` WRITE;
/*!40000 ALTER TABLE `task_completion` DISABLE KEYS */;
INSERT INTO `task_completion` VALUES (3,8,57,'2026-03-11 18:19:15',120,'Finished studying all chapters'),(4,9,57,'2026-03-11 18:22:38',60,'Done');
/*!40000 ALTER TABLE `task_completion` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `theme_preferences`
--

DROP TABLE IF EXISTS `theme_preferences`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `theme_preferences` (
  `preference_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `theme_mode` enum('light','dark','auto') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'light',
  `primary_color` varchar(7) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT '#007bff',
  `font_size` enum('small','medium','large') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'medium',
  `layout_density` enum('comfortable','compact') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'comfortable',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`preference_id`),
  UNIQUE KEY `user_id` (`user_id`),
  CONSTRAINT `theme_preferences_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `theme_preferences`
--

LOCK TABLES `theme_preferences` WRITE;
/*!40000 ALTER TABLE `theme_preferences` DISABLE KEYS */;
INSERT INTO `theme_preferences` VALUES (1,7,'dark','#007bff','medium','comfortable','2025-11-20 13:43:00'),(2,8,'light','#28a745','medium','compact','2025-11-20 13:43:00'),(3,9,'auto','#007bff','large','comfortable','2025-11-20 13:43:00'),(4,10,'light','#dc3545','small','comfortable','2025-11-20 13:43:00'),(5,11,'dark','#ffc107','medium','compact','2025-11-20 13:43:00'),(6,12,'light','#007bff','medium','comfortable','2025-11-20 13:43:00');
/*!40000 ALTER TABLE `theme_preferences` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `two_factor_auth`
--

DROP TABLE IF EXISTS `two_factor_auth`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `two_factor_auth` (
  `auth_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `secret_key` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `enabled` tinyint(1) DEFAULT '0',
  `backup_codes` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`auth_id`),
  UNIQUE KEY `user_id` (`user_id`),
  CONSTRAINT `two_factor_auth_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `two_factor_auth`
--

LOCK TABLES `two_factor_auth` WRITE;
/*!40000 ALTER TABLE `two_factor_auth` DISABLE KEYS */;
/*!40000 ALTER TABLE `two_factor_auth` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_badges`
--

DROP TABLE IF EXISTS `user_badges`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_badges` (
  `user_badge_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `badge_id` int unsigned NOT NULL,
  `earned_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `display_on_profile` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`user_badge_id`),
  UNIQUE KEY `unique_user_badge` (`user_id`,`badge_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_badge` (`badge_id`),
  CONSTRAINT `user_badges_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `user_badges_ibfk_2` FOREIGN KEY (`badge_id`) REFERENCES `badges` (`badge_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_badges`
--

LOCK TABLES `user_badges` WRITE;
/*!40000 ALTER TABLE `user_badges` DISABLE KEYS */;
INSERT INTO `user_badges` VALUES (1,7,1,'2025-11-20 13:43:00',1),(2,7,2,'2025-11-20 13:43:00',1),(3,7,3,'2025-11-20 13:43:00',1),(4,8,1,'2025-11-20 13:43:00',1),(5,8,3,'2025-11-20 13:43:00',1),(6,9,1,'2025-11-20 13:43:00',1),(7,10,1,'2025-11-20 13:43:00',1);
/*!40000 ALTER TABLE `user_badges` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_feedback`
--

DROP TABLE IF EXISTS `user_feedback`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_feedback` (
  `feedback_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `feedback_type` enum('bug','feature_request','complaint','suggestion','praise','other') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `category` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `subject` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `priority` enum('low','medium','high','urgent') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'medium',
  `status` enum('new','in_review','in_progress','resolved','closed','rejected') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'new',
  `attachments` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `browser_info` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `page_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`feedback_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_type` (`feedback_type`),
  KEY `idx_status` (`status`),
  CONSTRAINT `user_feedback_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_feedback`
--

LOCK TABLES `user_feedback` WRITE;
/*!40000 ALTER TABLE `user_feedback` DISABLE KEYS */;
INSERT INTO `user_feedback` VALUES (1,7,'bug','assignments','Cannot submit assignment','Getting error when trying to upload file for Assignment 1','high','resolved',NULL,'Chrome 120.0.0 / Windows 10','/courses/1/assignments/1','2025-11-20 13:43:00','2025-11-20 13:43:00'),(2,8,'feature_request','ui','Dark mode needed','Would love to have a dark mode option for late night studying','medium','in_progress',NULL,'Firefox 121.0 / macOS','/settings','2025-11-20 13:43:00','2025-11-20 13:43:00'),(3,9,'suggestion','gamification','More badge types','Suggest adding badges for forum participation and helping peers','low','new',NULL,'Safari 17.0 / iOS','/profile/badges','2025-11-20 13:43:00','2025-11-20 13:43:00'),(4,10,'complaint','grading','Grade not updated','My quiz grade has not been updated for 3 days','medium','resolved',NULL,'Chrome 120.0.0 / Windows 11','/courses/1/grades','2025-11-20 13:43:00','2025-11-20 13:43:00'),(5,11,'praise','general','Great platform!','Really enjoying the AI features and clean interface','low','closed',NULL,'Edge 120.0.0 / Windows 10','/dashboard','2025-11-20 13:43:00','2025-11-20 13:43:00');
/*!40000 ALTER TABLE `user_feedback` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_levels`
--

DROP TABLE IF EXISTS `user_levels`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_levels` (
  `level_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `current_level` int DEFAULT '1',
  `total_xp` bigint DEFAULT '0',
  `xp_to_next_level` int DEFAULT '100',
  `tier` enum('bronze','silver','gold','platinum','diamond') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'bronze',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`level_id`),
  UNIQUE KEY `user_id` (`user_id`),
  KEY `idx_level` (`current_level`),
  KEY `idx_tier` (`tier`),
  CONSTRAINT `user_levels_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_levels`
--

LOCK TABLES `user_levels` WRITE;
/*!40000 ALTER TABLE `user_levels` DISABLE KEYS */;
INSERT INTO `user_levels` VALUES (1,7,3,320,150,'silver','2025-11-20 13:43:00'),(2,8,2,180,120,'bronze','2025-11-20 13:43:00'),(3,9,2,150,120,'bronze','2025-11-20 13:43:00'),(4,10,1,85,100,'bronze','2025-11-20 13:43:00'),(5,11,1,65,100,'bronze','2025-11-20 13:43:00'),(6,12,1,45,100,'bronze','2025-11-20 13:43:00'),(7,13,1,30,100,'bronze','2025-11-20 13:43:00'),(8,14,1,25,100,'bronze','2025-11-20 13:43:00'),(9,15,1,20,100,'bronze','2025-11-20 13:43:00'),(10,16,1,15,100,'bronze','2025-11-20 13:43:00');
/*!40000 ALTER TABLE `user_levels` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_preferences`
--

DROP TABLE IF EXISTS `user_preferences`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_preferences` (
  `preference_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `language` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'en',
  `theme` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'light',
  `email_notifications` tinyint(1) NOT NULL DEFAULT '1',
  `push_notifications` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`preference_id`),
  UNIQUE KEY `uq_user_preferences_user_id` (`user_id`),
  CONSTRAINT `fk_user_preferences_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_preferences`
--

LOCK TABLES `user_preferences` WRITE;
/*!40000 ALTER TABLE `user_preferences` DISABLE KEYS */;
INSERT INTO `user_preferences` VALUES (1,57,'en','dark',1,1,'2026-03-10 18:14:04','2026-03-11 17:19:55');
/*!40000 ALTER TABLE `user_preferences` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_roles`
--

DROP TABLE IF EXISTS `user_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_roles` (
  `user_role_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `role_id` int unsigned NOT NULL,
  `assigned_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `assigned_by` bigint unsigned DEFAULT NULL,
  PRIMARY KEY (`user_role_id`),
  UNIQUE KEY `unique_user_role` (`user_id`,`role_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_role` (`role_id`),
  CONSTRAINT `user_roles_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `user_roles_ibfk_2` FOREIGN KEY (`role_id`) REFERENCES `roles` (`role_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=59 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_roles`
--

LOCK TABLES `user_roles` WRITE;
/*!40000 ALTER TABLE `user_roles` DISABLE KEYS */;
INSERT INTO `user_roles` VALUES (1,1,4,'2025-11-20 13:42:59',1),(2,2,2,'2025-11-20 13:42:59',1),(3,3,2,'2025-11-20 13:42:59',1),(4,4,2,'2025-11-20 13:42:59',1),(5,5,3,'2025-11-20 13:42:59',1),(6,6,3,'2025-11-20 13:42:59',1),(7,7,1,'2025-11-20 13:42:59',1),(8,8,1,'2025-11-20 13:42:59',1),(9,9,1,'2025-11-20 13:42:59',1),(10,10,1,'2025-11-20 13:42:59',1),(11,11,1,'2025-11-20 13:42:59',1),(12,12,1,'2025-11-20 13:42:59',1),(13,13,1,'2025-11-20 13:42:59',1),(14,14,1,'2025-11-20 13:42:59',1),(15,15,1,'2025-11-20 13:42:59',1),(16,16,1,'2025-11-20 13:42:59',1),(17,17,1,'2025-11-24 23:02:53',NULL),(18,18,1,'2025-11-24 23:29:13',NULL),(19,19,1,'2025-11-25 02:17:12',NULL),(25,25,1,'2025-11-26 15:22:14',NULL),(29,29,4,'2025-11-26 18:02:35',NULL),(30,1,5,'2025-11-26 18:11:25',NULL),(32,1,3,'2025-11-26 18:12:12',NULL),(35,1,2,'2025-11-26 18:12:56',NULL),(36,30,1,'2025-11-26 23:31:32',NULL),(39,33,1,'2025-11-27 00:32:35',NULL),(40,34,1,'2025-11-30 16:08:06',NULL),(41,35,1,'2026-02-25 19:01:54',NULL),(42,36,1,'2026-02-25 19:02:43',NULL),(46,56,4,'2026-03-01 16:32:28',NULL),(47,57,1,'2026-03-02 13:17:13',NULL),(48,58,2,'2026-03-02 13:17:14',NULL),(49,59,4,'2026-03-02 13:17:15',NULL),(50,60,3,'2026-03-02 13:18:41',NULL),(51,61,6,'2026-03-02 13:18:42',NULL),(52,62,1,'2026-03-02 13:27:01',NULL),(54,63,1,'2026-03-10 19:38:25',NULL),(55,64,2,'2026-03-10 19:38:32',NULL),(56,65,3,'2026-03-10 19:38:39',NULL),(57,66,4,'2026-03-10 19:38:45',NULL),(58,67,6,'2026-03-10 19:38:52',NULL);
/*!40000 ALTER TABLE `user_roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_subscriptions`
--

DROP TABLE IF EXISTS `user_subscriptions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_subscriptions` (
  `subscription_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `plan_id` bigint unsigned NOT NULL,
  `status` enum('active','cancelled','expired','suspended') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'active',
  `started_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `expires_at` timestamp NULL DEFAULT NULL,
  `cancelled_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`subscription_id`),
  KEY `fk_subscription_user` (`user_id`),
  KEY `fk_subscription_plan` (`plan_id`),
  CONSTRAINT `fk_subscription_plan` FOREIGN KEY (`plan_id`) REFERENCES `subscription_plans` (`plan_id`),
  CONSTRAINT `fk_subscription_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_subscriptions`
--

LOCK TABLES `user_subscriptions` WRITE;
/*!40000 ALTER TABLE `user_subscriptions` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_subscriptions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `user_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `password_hash` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `first_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `profile_picture_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `bio` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `social_links` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `campus_id` bigint unsigned DEFAULT NULL,
  `status` enum('active','inactive','suspended','pending') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'active',
  `email_verified` tinyint(1) DEFAULT '0',
  `last_login_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `email` (`email`),
  KEY `idx_email` (`email`),
  KEY `idx_campus` (`campus_id`),
  KEY `idx_status` (`status`),
  KEY `idx_email_status` (`email`,`status`),
  KEY `idx_campus_status` (`campus_id`,`status`)
) ENGINE=InnoDB AUTO_INCREMENT=68 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'admin@campus.edu','$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi','John','Admin','+1-555-1001',NULL,NULL,NULL,1,'active',1,NULL,'2025-11-20 13:42:59','2025-11-20 13:42:59',NULL),(2,'prof.smith@campus.edu','$2b$10$BtLRojkSErhQ3Tq8e519k.zWzNU9y8y8rFecMQFGboSBTgpXaeZTC','Robert','Smith','+1-555-1002',NULL,NULL,NULL,1,'active',1,NULL,'2025-11-20 13:42:59','2026-03-02 14:33:23','2026-03-02 14:33:23'),(3,'prof.johnson@campus.edu','$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi','Emily','Johnson','+1-555-1003',NULL,NULL,NULL,1,'active',1,NULL,'2025-11-20 13:42:59','2025-11-20 13:42:59',NULL),(4,'prof.williams@campus.edu','$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi','Michael','Williams','+1-555-1004',NULL,NULL,NULL,1,'active',1,NULL,'2025-11-20 13:42:59','2025-11-20 13:42:59',NULL),(5,'ta.brown@campus.edu','$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi','Sarah','Brown','+1-555-1005',NULL,NULL,NULL,1,'active',1,NULL,'2025-11-20 13:42:59','2025-11-20 13:42:59',NULL),(6,'ta.davis@campus.edu','$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi','James','Davis','+1-555-1006',NULL,NULL,NULL,1,'active',1,NULL,'2025-11-20 13:42:59','2025-11-20 13:42:59',NULL),(7,'alice.student@campus.edu','$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi','Alice','Anderson','+1-555-2001',NULL,NULL,NULL,1,'active',1,NULL,'2025-11-20 13:42:59','2025-11-20 13:42:59',NULL),(8,'bob.student@campus.edu','$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi','Bob','Martinez','+1-555-2002',NULL,NULL,NULL,1,'active',1,NULL,'2025-11-20 13:42:59','2025-11-20 13:42:59',NULL),(9,'carol.student@campus.edu','$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi','Carol','Garcia','+1-555-2003',NULL,NULL,NULL,1,'active',1,NULL,'2025-11-20 13:42:59','2025-11-20 13:42:59',NULL),(10,'david.student@campus.edu','$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi','David','Rodriguez','+1-555-2004',NULL,NULL,NULL,1,'active',1,NULL,'2025-11-20 13:42:59','2025-11-20 13:42:59',NULL),(11,'emma.student@campus.edu','$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi','Emma','Wilson','+1-555-2005',NULL,NULL,NULL,1,'active',1,NULL,'2025-11-20 13:42:59','2025-11-20 13:42:59',NULL),(12,'frank.student@campus.edu','$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi','Frank','Lopez','+1-555-2006',NULL,NULL,NULL,1,'active',1,NULL,'2025-11-20 13:42:59','2025-11-20 13:42:59',NULL),(13,'grace.student@campus.edu','$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi','Grace','Lee','+1-555-2007',NULL,NULL,NULL,1,'active',1,NULL,'2025-11-20 13:42:59','2025-11-20 13:42:59',NULL),(14,'henry.student@campus.edu','$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi','Henry','Walker','+1-555-2008',NULL,NULL,NULL,1,'active',1,NULL,'2025-11-20 13:42:59','2025-11-20 13:42:59',NULL),(15,'ivy.student@campus.edu','$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi','Ivy','Hall','+1-555-2009',NULL,NULL,NULL,1,'active',1,NULL,'2025-11-20 13:42:59','2025-11-20 13:42:59',NULL),(16,'jack.student@campus.edu','$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi','Jack','Allen','+1-555-2010',NULL,NULL,NULL,1,'active',1,NULL,'2025-11-20 13:42:59','2025-11-20 13:42:59',NULL),(17,'amir123@campus.edu','$2a$12$C311w/5Myorf1.zx35NarOlekceRfdFvjGr1xUgx0s4GHxky4JaQa','Amir','Doe','+1234567890',NULL,NULL,NULL,1,'active',1,'2025-11-24 23:24:53','2025-11-24 23:02:53','2025-11-24 23:24:53',NULL),(18,'amir.user@campus.edu','$2a$12$Rq1HOfy3QufvhHKiKrGQFeqyHsX896gCod41jJF1r.XNUUIeQMd4i','Test','amir2','+1234567800',NULL,NULL,NULL,1,'active',1,'2025-11-24 23:33:35','2025-11-24 23:29:12','2025-11-24 23:33:35',NULL),(19,'amir1234@campus.edu','$2b$10$Z0TxzhBdcMLt2YuGEbPmTe/nYpEvVPw6I8E7h7cHUaS79NpKv.Lwq','Amir','Mohamed','+125451526',NULL,NULL,NULL,1,'active',1,'2025-11-25 18:00:40','2025-11-25 02:17:12','2025-11-25 18:00:41',NULL),(20,'ta.salim.noor@eduverse.edu.eg','$2y$10$N9qo8uLOickgx2ZMRZoMye','Salim','Noor','+20-100-444-0003',NULL,NULL,NULL,2,'active',1,'2025-02-13 15:20:00','2024-09-01 08:00:00','2024-09-01 08:00:00',NULL),(21,'student.ali.youssef@eduverse.edu.eg','$2y$10$N9qo8uLOickgx2ZMRZoMye','Ali','Youssef','+20-100-555-0001',NULL,NULL,NULL,1,'active',1,'2025-02-15 17:45:00','2024-09-01 08:00:00','2024-09-01 08:00:00',NULL),(22,'student.maya.ibrahim@eduverse.edu.eg','$2y$10$N9qo8uLOickgx2ZMRZoMye','Maya','Ibrahim','+20-100-555-0002',NULL,NULL,NULL,1,'active',1,'2025-02-15 16:30:00','2024-09-01 08:00:00','2024-09-01 08:00:00',NULL),(23,'student.zain.ahmed@eduverse.edu.eg','$2y$10$N9qo8uLOickgx2ZMRZoMye','Zain','Ahmed','+20-100-555-0003',NULL,NULL,NULL,1,'active',1,'2025-02-15 18:00:00','2024-09-01 08:00:00','2024-09-01 08:00:00',NULL),(24,'student.hana.khalil@eduverse.edu.eg','$2y$10$N9qo8uLOickgx2ZMRZoMye','Hana','Khalil','+20-100-555-0004',NULL,NULL,NULL,1,'active',1,'2025-02-14 17:15:00','2024-09-01 08:00:00','2024-09-01 08:00:00',NULL),(25,'am3566146@gmail.com','$2b$10$lqumSGY0jP1eCtbxIlQQveE1nD7m37YU9jJRrwoGoDlBenDS1EQqi','Amir','Hamdi','+201234567890',NULL,NULL,NULL,NULL,'active',1,'2025-11-30 16:05:00','2025-11-26 15:22:14','2025-11-30 16:04:59',NULL),(26,'student.mariam.fahmy@eduverse.edu.eg','$2y$10$N9qo8uLOickgx2ZMRZoMye','Mariam','Fahmy','+20-100-555-0006',NULL,NULL,NULL,1,'active',1,'2025-02-13 18:20:00','2024-09-01 08:00:00','2024-09-01 08:00:00',NULL),(27,'student.rashid.nour@eduverse.edu.eg','$2y$10$N9qo8uLOickgx2ZMRZoMye','Rashid','Nour','+20-100-555-0007',NULL,NULL,NULL,1,'active',1,'2025-02-13 17:00:00','2024-09-01 08:00:00','2024-09-01 08:00:00',NULL),(28,'student.sara.aziz@eduverse.edu.eg','$2y$10$N9qo8uLOickgx2ZMRZoMye','Sara','Aziz','+20-100-555-0008',NULL,NULL,NULL,2,'active',1,'2025-02-15 15:30:00','2024-09-01 08:00:00','2024-09-01 08:00:00',NULL),(29,'am3566147@gmail.com','$2b$10$oplLjPdOuM19aeyZg9CQJuhUoiQxN00m2LjMTGd4.IDrIs2WI/nUC','John','Doe',NULL,NULL,NULL,NULL,NULL,'active',1,'2025-11-30 16:39:24','2025-11-26 18:02:35','2025-11-30 16:39:24',NULL),(30,'am3566143@gmail.com','$2b$10$1ZlE/jNftUxyDDR5b6Kd2eLR3IB5ZUN9LCrVDU9E0zsMP5mfy4/q.','Amir','Hamdi','+2015464646445',NULL,NULL,NULL,NULL,'active',1,'2025-11-27 00:40:27','2025-11-26 23:31:32','2025-11-27 00:40:27',NULL),(31,'student.amr.shaker@eduverse.edu.eg','$2y$10$N9qo8uLOickgx2ZMRZoMye','Amr','Shaker','+20-100-555-0011',NULL,NULL,NULL,2,'active',1,'2025-02-13 16:30:00','2024-09-01 08:00:00','2024-09-01 08:00:00',NULL),(32,'student.dalal.hassan@eduverse.edu.eg','$2y$10$N9qo8uLOickgx2ZMRZoMye','Dalal','Hassan','+20-100-555-0012',NULL,NULL,NULL,1,'active',1,'2025-02-12 17:45:00','2024-09-01 08:00:00','2024-09-01 08:00:00',NULL),(33,'amirhamdidx720@gmail.com','$2b$10$pl4Dx6LsyXtolFjT3s.X5u.mYMJSYrkM98nDz1IkuCck.O7d3cl52','Amir','Hamdi',NULL,NULL,NULL,NULL,NULL,'active',1,'2025-11-27 00:36:46','2025-11-27 00:32:35','2025-11-27 00:36:46',NULL),(34,'amir_student@campus.edu','$2b$10$pmCL5b.Hv9aPeH9MBxHEHuB4YQiZyMz5tZTIEh6xjRDUUB/K5hqaK','Amir','Strudent',NULL,NULL,NULL,NULL,NULL,'active',1,'2025-11-30 16:08:53','2025-11-30 16:08:06','2025-11-30 16:08:53',NULL),(35,'amir@edu.com','$2b$10$wPRxhFVeedYmnpkDJWzgZuUH4qn2cjd9zF65tCSfrUnSRbjleFhOS','Test','User','+20201234567',NULL,NULL,NULL,NULL,'pending',0,NULL,'2026-02-25 19:01:54','2026-02-25 19:01:54',NULL),(36,'john.doe@example.com','$2b$10$HNLv5bD5GbRDJzyOlJr0FuP5A6ibEUhKWkKbbm/ytOhFTffEmy8VG','John','Doe','+1234567890',NULL,NULL,NULL,NULL,'active',1,'2026-02-25 20:11:14','2026-02-25 19:02:43','2026-02-25 20:11:14',NULL),(37,'student.fouad.ali@eduverse.edu.eg','$2y$10$N9qo8uLOickgx2ZMRZoMye','Fouad','Ali','+20-100-555-0017',NULL,NULL,NULL,3,'active',1,'2025-02-15 19:00:00','2024-09-01 08:00:00','2024-09-01 08:00:00',NULL),(38,'student.lina.noor@eduverse.edu.eg','$2y$10$N9qo8uLOickgx2ZMRZoMye','Lina','Noor','+20-100-555-0018',NULL,NULL,NULL,3,'active',1,'2025-02-14 18:45:00','2024-09-01 08:00:00','2024-09-01 08:00:00',NULL),(39,'student.sami.aziz@eduverse.edu.eg','$2y$10$N9qo8uLOickgx2ZMRZoMye','Sami','Aziz','+20-100-555-0019',NULL,NULL,NULL,3,'active',1,'2025-02-13 19:20:00','2024-09-01 08:00:00','2024-09-01 08:00:00',NULL),(40,'student.joud.mohammad@eduverse.edu.eg','$2y$10$N9qo8uLOickgx2ZMRZoMye','Joud','Mohammad','+20-100-555-0020',NULL,NULL,NULL,1,'active',1,'2025-02-12 18:30:00','2024-09-01 08:00:00','2024-09-01 08:00:00',NULL),(41,'student.rayan.saleh@eduverse.edu.eg','$2y$10$N9qo8uLOickgx2ZMRZoMye','Rayan','Saleh','+20-100-555-0021',NULL,NULL,NULL,1,'active',1,'2025-02-11 19:00:00','2024-09-01 08:00:00','2024-09-01 08:00:00',NULL),(42,'student.ghada.hussein@eduverse.edu.eg','$2y$10$N9qo8uLOickgx2ZMRZoMye','Ghada','Hussein','+20-100-555-0022',NULL,NULL,NULL,2,'active',1,'2025-02-10 17:45:00','2024-09-01 08:00:00','2024-09-01 08:00:00',NULL),(43,'student.tariq.samir@eduverse.edu.eg','$2y$10$N9qo8uLOickgx2ZMRZoMye','Tariq','Samir','+20-100-555-0023',NULL,NULL,NULL,2,'active',1,'2025-02-09 18:00:00','2024-09-01 08:00:00','2024-09-01 08:00:00',NULL),(44,'student.souad.noor@eduverse.edu.eg','$2y$10$N9qo8uLOickgx2ZMRZoMye','Souad','Noor','+20-100-555-0024',NULL,NULL,NULL,2,'active',1,'2025-02-08 17:15:00','2024-09-01 08:00:00','2024-09-01 08:00:00',NULL),(45,'student.walid.ahmed@eduverse.edu.eg','$2y$10$N9qo8uLOickgx2ZMRZoMye','Walid','Ahmed','+20-100-555-0025',NULL,NULL,NULL,1,'active',1,'2025-02-07 19:30:00','2024-09-01 08:00:00','2024-09-01 08:00:00',NULL),(46,'student.yasmine.khalil@eduverse.edu.eg','$2y$10$N9qo8uLOickgx2ZMRZoMye','Yasmine','Khalil','+20-100-555-0026',NULL,NULL,NULL,1,'active',1,'2025-02-06 16:45:00','2024-09-01 08:00:00','2024-09-01 08:00:00',NULL),(47,'student.ismail.ahmed@eduverse.edu.eg','$2y$10$N9qo8uLOickgx2ZMRZoMye','Ismail','Ahmed','+20-100-555-0027',NULL,NULL,NULL,3,'active',1,'2025-02-15 20:00:00','2024-09-01 08:00:00','2024-09-01 08:00:00',NULL),(48,'student.zainab.saleh@eduverse.edu.eg','$2y$10$N9qo8uLOickgx2ZMRZoMye','Zainab','Saleh','+20-100-555-0028',NULL,NULL,NULL,3,'active',1,'2025-02-14 19:15:00','2024-09-01 08:00:00','2024-09-01 08:00:00',NULL),(49,'student.jamal.abdel@eduverse.edu.eg','$2y$10$N9qo8uLOickgx2ZMRZoMye','Jamal','Abdel','+20-100-555-0029',NULL,NULL,NULL,3,'active',1,'2025-02-13 18:45:00','2024-09-01 08:00:00','2024-09-01 08:00:00',NULL),(50,'student.haya.ibrahim@eduverse.edu.eg','$2y$10$N9qo8uLOickgx2ZMRZoMye','Haya','Ibrahim','+20-100-555-0030',NULL,NULL,NULL,1,'active',1,'2025-02-12 19:00:00','2024-09-01 08:00:00','2024-09-01 08:00:00',NULL),(51,'admin.ahmed@eduverse.edu.eg','$2y$10$N9qo8uLOickgx2ZMRZoMye','Ahmed','Hassan','+20-100-111-0001',NULL,NULL,NULL,1,'active',1,'2025-02-15 07:00:00','2024-09-01 05:00:00','2024-09-01 05:00:00',NULL),(52,'admin.fatima@eduverse.edu.eg','$2y$10$N9qo8uLOickgx2ZMRZoMye','Fatima','Khalil','+20-100-111-0002',NULL,NULL,NULL,1,'active',1,'2025-02-14 12:30:00','2024-09-01 05:00:00','2024-09-01 05:00:00',NULL),(53,'admin.karim@eduverse.edu.eg','$2y$10$N9qo8uLOickgx2ZMRZoMye','Karim','Mohamed','+20-100-111-0003',NULL,NULL,NULL,2,'active',1,'2025-02-13 09:15:00','2024-09-01 05:00:00','2024-09-01 05:00:00',NULL),(56,'admintarek@example.com','$2b$10$Q2Np7QKr5aDtpwBYgf4Zi.5SaZ1GtMs8Y.C7xgP4d5FyVmwMUoJae','John','Doe','+1234567890',NULL,NULL,NULL,NULL,'active',1,'2026-03-02 13:17:35','2026-03-01 16:32:28','2026-03-02 13:17:35',NULL),(57,'student.tarek@example.com','$2b$10$uAeqZOmta.4nIXlerg/0MOg1s2Xk9hdv7TbT1qRmxVyRbbrRBzwc6','Student','Tarek','+201234567890',NULL,'Test bio from Sprint 3 testing','{\"github\":\"https://github.com/test\"}',NULL,'active',1,'2026-03-16 22:31:19','2026-03-02 13:17:13','2026-03-16 22:31:19',NULL),(58,'instructor.tarek@example.com','$2b$10$RU6fgXm2NqYTHxolk6QWHOq2/dQ9FPu/vYL5QCMHYLgiALcvaOdJi','Tarek','Instructor',NULL,NULL,NULL,NULL,NULL,'active',1,'2026-03-16 22:31:18','2026-03-02 13:17:14','2026-03-16 22:31:18',NULL),(59,'admin.tarek@example.com','$2b$10$P3HIhwwNVVYRTY8dM9bUU.E1jfyQAI4qOv8MId8cozPNVI2OSBJtK','Tarek','Admin',NULL,NULL,NULL,NULL,NULL,'active',1,'2026-03-16 22:31:18','2026-03-02 13:17:15','2026-03-16 22:31:18',NULL),(60,'ta.tarek@example.com','$2b$10$ZNeL4pilwwieU42jvS.e2OfgCamtEX6UZF.8/wPp./gjN6GY7b/Z.','Tarek','TA',NULL,NULL,NULL,NULL,NULL,'active',1,'2026-03-16 22:31:19','2026-03-02 13:18:41','2026-03-16 22:31:18',NULL),(61,'it_admin.tarek@example.com','$2b$10$EJkScTvamvd/ThfdVedTvuS9eY2484LRX7U5B31nbyC44DZBrRbwG','Tarek','ITAdmin',NULL,NULL,NULL,NULL,NULL,'active',1,'2026-03-16 22:31:19','2026-03-02 13:18:42','2026-03-16 22:31:18',NULL),(62,'testdel999@example.com','$2b$10$iSkjrSWfZz9mc.DDwM3tTuMmxbH5tiEc7EGtTVi5ZegO8ktZ2fxKi','Test','Del',NULL,NULL,NULL,NULL,NULL,'active',1,NULL,'2026-03-02 13:27:01','2026-03-02 13:27:01',NULL),(63,'amir_student@example.com','$2b$10$YQOcjPCtrtejaaLkj13GyuGQIjIHEmfSJbtqMokOc8zH3F4Rl8c0O','John','Doe','+1234567890',NULL,NULL,NULL,NULL,'active',1,'2026-03-10 20:13:57','2026-03-10 19:38:25','2026-03-10 20:13:56',NULL),(64,'amir_instructor@example.com','$2b$10$El1BXYYGaBSs/DGRo6/Tc.afHxnjGnFQ8.Nxd6582jTtkFVFGoiEG','John','Doe','+1234567890',NULL,NULL,NULL,NULL,'active',1,'2026-03-10 22:00:16','2026-03-10 19:38:32','2026-03-10 22:00:15',NULL),(65,'amir_ta@example.com','$2b$10$A6Gkd7MsXv1CIA.tl3AO3ezgrn5fXK3lhR35SiJjIXtBfLxV65H6u','John','Doe','+1234567890',NULL,NULL,NULL,NULL,'active',1,'2026-03-10 20:14:30','2026-03-10 19:38:39','2026-03-10 20:14:30',NULL),(66,'amir_admin@example.com','$2b$10$G8EUYQ5PCuWpyzA7O8/ve.H.HS/nKBrp7ytplTOTaM9OD68vsXaRq','John','Doe','+1234567890',NULL,NULL,NULL,NULL,'active',1,'2026-03-16 22:16:02','2026-03-10 19:38:45','2026-03-16 22:16:02',NULL),(67,'amir_itadmin@example.com','$2b$10$PTpBY1XV1CKKsPf3QY9Jlu55Ha.CKTF.FOnJeYbOND.Nd3c9gzuQi','John','Doe','+1234567890',NULL,NULL,NULL,NULL,'active',1,'2026-03-16 22:19:25','2026-03-10 19:38:52','2026-03-16 22:19:24',NULL);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `v_course_performance`
--

DROP TABLE IF EXISTS `v_course_performance`;
/*!50001 DROP VIEW IF EXISTS `v_course_performance`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_course_performance` AS SELECT 
 1 AS `course_id`,
 1 AS `course_name`,
 1 AS `course_code`,
 1 AS `section_id`,
 1 AS `section_number`,
 1 AS `total_students`,
 1 AS `avg_completion`,
 1 AS `avg_grade`,
 1 AS `total_assignments`,
 1 AS `total_quizzes`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_student_dashboard`
--

DROP TABLE IF EXISTS `v_student_dashboard`;
/*!50001 DROP VIEW IF EXISTS `v_student_dashboard`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_student_dashboard` AS SELECT 
 1 AS `user_id`,
 1 AS `first_name`,
 1 AS `last_name`,
 1 AS `email`,
 1 AS `profile_picture_url`,
 1 AS `current_level`,
 1 AS `total_xp`,
 1 AS `enrolled_courses`,
 1 AS `pending_tasks`,
 1 AS `unread_notifications`,
 1 AS `current_streak`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `voice_recordings`
--

DROP TABLE IF EXISTS `voice_recordings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `voice_recordings` (
  `recording_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `course_id` bigint unsigned DEFAULT NULL,
  `file_id` bigint unsigned NOT NULL,
  `transcription_id` bigint unsigned DEFAULT NULL,
  `duration_seconds` int DEFAULT NULL,
  `recording_type` enum('lecture','note','question','answer') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`recording_id`),
  KEY `file_id` (`file_id`),
  KEY `transcription_id` (`transcription_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_course` (`course_id`),
  CONSTRAINT `voice_recordings_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `voice_recordings_ibfk_2` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`) ON DELETE CASCADE,
  CONSTRAINT `voice_recordings_ibfk_3` FOREIGN KEY (`file_id`) REFERENCES `files` (`file_id`) ON DELETE CASCADE,
  CONSTRAINT `voice_recordings_ibfk_4` FOREIGN KEY (`transcription_id`) REFERENCES `voice_transcriptions` (`transcription_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `voice_recordings`
--

LOCK TABLES `voice_recordings` WRITE;
/*!40000 ALTER TABLE `voice_recordings` DISABLE KEYS */;
/*!40000 ALTER TABLE `voice_recordings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `voice_transcriptions`
--

DROP TABLE IF EXISTS `voice_transcriptions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `voice_transcriptions` (
  `transcription_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `audio_file_id` bigint unsigned DEFAULT NULL,
  `transcribed_text` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `language` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'en',
  `confidence_score` decimal(3,2) DEFAULT NULL,
  `duration_seconds` int DEFAULT NULL,
  `processing_time_ms` int DEFAULT NULL,
  `ai_model` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`transcription_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_file` (`audio_file_id`),
  CONSTRAINT `voice_transcriptions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `voice_transcriptions_ibfk_2` FOREIGN KEY (`audio_file_id`) REFERENCES `files` (`file_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `voice_transcriptions`
--

LOCK TABLES `voice_transcriptions` WRITE;
/*!40000 ALTER TABLE `voice_transcriptions` DISABLE KEYS */;
INSERT INTO `voice_transcriptions` VALUES (1,7,5,'Remember to review chapter 3 before the midterm. Focus on loop structures and function definitions.','en',0.94,180,2500,'whisper-1','2025-11-20 13:43:00'),(2,8,5,'Question about assignment: How do we handle edge cases in the input validation?','en',0.91,240,3100,'whisper-1','2025-11-20 13:43:00');
/*!40000 ALTER TABLE `voice_transcriptions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `weak_topics_analysis`
--

DROP TABLE IF EXISTS `weak_topics_analysis`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `weak_topics_analysis` (
  `analysis_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `course_id` bigint unsigned NOT NULL,
  `topic_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `weakness_score` decimal(5,2) NOT NULL,
  `attempt_count` int DEFAULT '0',
  `success_rate` decimal(5,2) DEFAULT '0.00',
  `last_attempted_at` timestamp NULL DEFAULT NULL,
  `recommendation_generated` tinyint(1) DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`analysis_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_course` (`course_id`),
  CONSTRAINT `weak_topics_analysis_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `weak_topics_analysis_ibfk_2` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `weak_topics_analysis`
--

LOCK TABLES `weak_topics_analysis` WRITE;
/*!40000 ALTER TABLE `weak_topics_analysis` DISABLE KEYS */;
INSERT INTO `weak_topics_analysis` VALUES (3,9,2,'Linked List Operations',58.00,4,48.00,'2025-02-15 12:45:00',1,'2025-11-20 13:43:00','2025-11-20 13:43:00'),(5,57,1,'Recursion',75.50,5,40.00,'2026-03-11 18:12:04',1,'2026-03-11 18:12:04','2026-03-11 18:12:04'),(6,57,1,'Binary Trees',60.00,3,33.33,'2026-03-09 18:12:04',0,'2026-03-11 18:12:04','2026-03-11 18:12:04'),(7,57,2,'SQL Joins',45.00,4,50.00,'2026-03-10 18:12:04',1,'2026-03-11 18:12:04','2026-03-11 18:12:04');
/*!40000 ALTER TABLE `weak_topics_analysis` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `xp_transactions`
--

DROP TABLE IF EXISTS `xp_transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `xp_transactions` (
  `transaction_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `source_type` enum('quiz','assignment','lab','attendance','login','streak','achievement','manual') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `source_id` bigint unsigned DEFAULT NULL,
  `rule_id` int unsigned DEFAULT NULL,
  `points_earned` int NOT NULL,
  `multiplier` decimal(3,2) DEFAULT '1.00',
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`transaction_id`),
  KEY `rule_id` (`rule_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_source` (`source_type`,`source_id`),
  KEY `idx_date` (`created_at`),
  KEY `idx_user_date` (`user_id`,`created_at`),
  KEY `idx_source_composite` (`source_type`,`source_id`,`user_id`),
  CONSTRAINT `xp_transactions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `xp_transactions_ibfk_2` FOREIGN KEY (`rule_id`) REFERENCES `points_rules` (`rule_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `xp_transactions`
--

LOCK TABLES `xp_transactions` WRITE;
/*!40000 ALTER TABLE `xp_transactions` DISABLE KEYS */;
INSERT INTO `xp_transactions` VALUES (1,7,'quiz',1,1,10,1.00,'Completed Quiz 1: Python Basics','2025-11-20 13:43:00'),(2,7,'assignment',1,4,75,1.50,'Perfect score on Assignment 1','2025-11-20 13:43:00'),(3,7,'attendance',1,3,5,1.00,'Attended lecture on 2025-02-03','2025-11-20 13:43:00'),(4,8,'quiz',1,1,10,1.00,'Completed Quiz 1: Python Basics','2025-11-20 13:43:00'),(5,8,'assignment',1,2,15,1.00,'Submitted Assignment 1','2025-11-20 13:43:00'),(6,8,'attendance',1,3,5,1.00,'Attended lecture on 2025-02-03','2025-11-20 13:43:00'),(7,9,'attendance',1,3,5,1.00,'Attended lecture on 2025-02-03','2025-11-20 13:43:00'),(8,10,'assignment',1,2,15,1.00,'Submitted Assignment 1','2025-11-20 13:43:00'),(9,11,'attendance',1,3,5,1.00,'Attended lecture on 2025-02-03','2025-11-20 13:43:00');
/*!40000 ALTER TABLE `xp_transactions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Final view structure for view `v_course_performance`
--

/*!50001 DROP VIEW IF EXISTS `v_course_performance`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_course_performance` AS select `c`.`course_id` AS `course_id`,`c`.`course_name` AS `course_name`,`c`.`course_code` AS `course_code`,`cs`.`section_id` AS `section_id`,`cs`.`section_number` AS `section_number`,count(distinct `ce`.`user_id`) AS `total_students`,avg(`sp`.`completion_percentage`) AS `avg_completion`,avg(`g`.`percentage`) AS `avg_grade`,count(distinct `a`.`assignment_id`) AS `total_assignments`,count(distinct `q`.`quiz_id`) AS `total_quizzes` from ((((((`courses` `c` join `course_sections` `cs` on((`c`.`course_id` = `cs`.`course_id`))) left join `course_enrollments` `ce` on((`cs`.`section_id` = `ce`.`section_id`))) left join `student_progress` `sp` on(((`ce`.`user_id` = `sp`.`user_id`) and (`c`.`course_id` = `sp`.`course_id`)))) left join `grades` `g` on(((`ce`.`user_id` = `g`.`user_id`) and (`c`.`course_id` = `g`.`course_id`)))) left join `assignments` `a` on((`c`.`course_id` = `a`.`course_id`))) left join `quizzes` `q` on((`c`.`course_id` = `q`.`quiz_id`))) where (`c`.`status` = 'active') group by `c`.`course_id`,`cs`.`section_id` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_student_dashboard`
--

/*!50001 DROP VIEW IF EXISTS `v_student_dashboard`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_student_dashboard` AS select `u`.`user_id` AS `user_id`,`u`.`first_name` AS `first_name`,`u`.`last_name` AS `last_name`,`u`.`email` AS `email`,`u`.`profile_picture_url` AS `profile_picture_url`,`ul`.`current_level` AS `current_level`,`ul`.`total_xp` AS `total_xp`,count(distinct `ce`.`enrollment_id`) AS `enrolled_courses`,count(distinct `st`.`task_id`) AS `pending_tasks`,count(distinct `n`.`notification_id`) AS `unread_notifications`,`ds`.`current_streak` AS `current_streak` from (((((`users` `u` left join `user_levels` `ul` on((`u`.`user_id` = `ul`.`user_id`))) left join `course_enrollments` `ce` on(((`u`.`user_id` = `ce`.`user_id`) and (`ce`.`enrollment_status` = 'enrolled')))) left join `student_tasks` `st` on(((`u`.`user_id` = `st`.`user_id`) and (`st`.`status` in ('pending','in_progress'))))) left join `notifications` `n` on(((`u`.`user_id` = `n`.`user_id`) and (`n`.`is_read` = 0)))) left join `daily_streaks` `ds` on((`u`.`user_id` = `ds`.`user_id`))) where (`u`.`status` = 'active') group by `u`.`user_id` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-03-17  0:34:12
