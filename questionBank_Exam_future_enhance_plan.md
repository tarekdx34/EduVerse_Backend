# Question Bank And Exam Generator Future Enhancement Plan

Date: 2026-05-04
Source documents:

1. `questionBank_Exam_report.md`
2. `questionBank_Exam_fix_plan.md`

Scope: future enhancement plan only. This file does not change code or database schema.

## 1. Purpose

This plan covers advanced enhancements that are intentionally separate from the primary stabilization plan. The primary plan should be implemented first because it fixes the required security, ownership, transaction, attachment, marks, sections, draft lifecycle, snapshot, export, and test foundations.

Future enhancements in this file are designed to make the question bank and exam generator stronger as a long-term academic authoring system:

1. Tags and learning outcomes.
2. CSV and Excel import/export.
3. Duplicate and similarity detection.
4. Question usage statistics.
5. Question quality metrics.
6. Exam blueprint templates.
7. Advanced group-aware generation.
8. Schedule integration.
9. Gradebook integration.
10. Optional online assessment delivery bridge.
11. Instructor dashboards and analytics.
12. Audit, governance, and long-term cleanup.

## 2. Relationship To The Primary Plan

This future plan assumes the primary plan has already added or fixed:

1. Instructor-only access.
2. Instructor ownership through `course_instructors -> course_sections -> course_id`.
3. Transactions for question creation/update and exam draft/final save.
4. Multiple question attachments with captions and alt text.
5. Plain bulk question create.
6. Related question groups.
7. Total marks and item marks.
8. Exam sections.
9. Manual draft item add/remove/reorder.
10. Draft lifecycle and idempotent save.
11. Publish/archive lifecycle.
12. Immutable exam item snapshots.
13. Export hardening.
14. Review/version/soft delete basics.

Do not start this future plan before the core security and ownership work is complete. These future features rely on the primary plan's stable data model.

## 3. Non-Goals

These items are not part of this future plan:

1. Do not re-open `STUDENT`, `TA`, or `ADMIN` access to the instructor authoring APIs.
2. Do not manually edit the Aiven database in DBeaver.
3. Do not edit `eduverse_db.sql` or `tables.txt`.
4. Do not enable TypeORM `synchronize`.
5. Do not connect generated exams to student grades unless the project has a clear delivery/submission workflow or a manual grade entry workflow.
6. Do not use `courses.instructor_id` as an authorization source.

All deployed database changes must be implemented as TypeORM migrations in:

`src/database/migrations`

## 4. Current Integration Points

Relevant existing modules:

1. `src/modules/question-bank`
2. `src/modules/exams`
3. `src/modules/files`
4. `src/modules/schedule`
5. `src/modules/grades`
6. `src/modules/analytics`
7. `src/modules/quizzes`
8. `src/modules/courses`
9. `src/modules/enrollments`
10. `src/modules/notifications`

Important existing entities:

1. `src/modules/schedule/entities/exam-schedule.entity.ts`
   - Table: `exam_schedules`
   - Already stores course, semester, exam type, date, time, duration, location, instructions, and status.

2. `src/modules/grades/entities/grade.entity.ts`
   - Table: `grades`
   - Already supports `gradeType = exam` and `gradeType = final`.
   - Does not currently have `exam_id` for generated exams.

3. `src/modules/grades/entities/grade-component.entity.ts`
   - Table: `grade_components`
   - Can later represent per-section or per-question grading if connected carefully.

4. `src/modules/analytics/entities/course-analytics.entity.ts`
   - Table: `course_analytics`
   - Existing analytics module can be extended or queried for instructor dashboards.

5. `src/modules/files/entities/file.entity.ts`
   - Table: `files`
   - Useful for import files, export files, and generated report artifacts.

## 5. Future Database Migrations

Recommended migration files:

1. `1781000000000-AddQuestionBankTagsAndOutcomes.ts`
2. `1781000000001-AddQuestionBankImportExportJobs.ts`
3. `1781000000002-AddQuestionDuplicateDetection.ts`
4. `1781000000003-AddQuestionUsageAndQualityMetrics.ts`
5. `1781000000004-AddExamBlueprintTemplates.ts`
6. `1781000000005-AddExamScheduleIntegration.ts`
7. `1781000000006-AddExamGradebookIntegration.ts`
8. `1781000000007-AddExamAnalyticsAndGovernance.ts`

Reason for this order:

1. Tags/outcomes improve classification first.
2. Import/export can then use tags/outcomes.
3. Duplicate detection can run during import and normal create/update.
4. Usage and quality metrics need stable exam snapshots and generation records.
5. Blueprint templates depend on tags/outcomes and metrics.
6. Schedule integration depends on saved/published exams.
7. Gradebook integration should come after schedule/delivery decisions.
8. Analytics/governance should aggregate stable events from all previous phases.

## 6. Phase F0 - Future Safety Baseline

### 6.1 Purpose

Add shared conventions before adding advanced features. This avoids inconsistent future APIs.

### 6.2 Files To Edit

1. `src/modules/question-bank/question-bank.module.ts`
2. `src/modules/exams/exams.module.ts`
3. `src/modules/question-bank/question-bank.service.ts`
4. `src/modules/exams/exams.service.ts`
5. `src/modules/question-bank/dto/question-response.dto.ts`
6. `src/modules/exams/dto/exam-response.dto.ts`

### 6.3 Files To Create

1. `src/modules/question-bank/services/question-bank-audit.service.ts`
2. `src/modules/exams/services/exam-audit.service.ts`
3. `src/modules/question-bank/dto/future-common.dto.ts`
4. `src/modules/exams/dto/future-common.dto.ts`

### 6.4 Rules

1. All future endpoints remain instructor-only unless explicitly stated.
2. All course-scoped future endpoints use `course_instructors -> course_sections -> course_id`.
3. All bulk operations need:
   - max item count
   - transaction boundary
   - item-indexed errors
   - import/export job tracking when long-running
4. All analytics/quality endpoints must avoid exposing answer keys to non-instructor roles.
5. All future scheduled jobs should log count summaries but not full question text or answer keys.

### 6.5 Acceptance Criteria

1. Future services have clear ownership and audit helpers.
2. Future endpoints follow the same pagination, response, and error conventions as the primary plan.
3. No advanced feature bypasses instructor ownership.

## 7. Phase F1 - Tags And Learning Outcomes

### 7.1 Purpose

Add richer metadata so instructors can classify questions by topic, skill, learning outcome, and course objective. This improves search, filtering, exam blueprints, and coverage reports.

### 7.2 Files To Edit

1. `src/modules/question-bank/question-bank.controller.ts`
2. `src/modules/question-bank/question-bank.service.ts`
3. `src/modules/question-bank/question-bank.module.ts`
4. `src/modules/question-bank/dto/question.dto.ts`
5. `src/modules/question-bank/dto/question-response.dto.ts`
6. `src/modules/question-bank/entities/question-bank-question.entity.ts`
7. `src/modules/exams/dto/generate-exam.dto.ts`
8. `src/modules/exams/exams.service.ts`

### 7.3 Files To Create

Entities:

1. `src/modules/question-bank/entities/question-bank-tag.entity.ts`
2. `src/modules/question-bank/entities/question-bank-question-tag.entity.ts`
3. `src/modules/question-bank/entities/learning-outcome.entity.ts`
4. `src/modules/question-bank/entities/question-bank-question-outcome.entity.ts`

DTOs:

1. `src/modules/question-bank/dto/question-tag.dto.ts`
2. `src/modules/question-bank/dto/learning-outcome.dto.ts`
3. `src/modules/question-bank/dto/question-metadata.dto.ts`

Tests:

1. `src/modules/question-bank/tests/question-bank-tags.service.spec.ts`
2. `src/modules/question-bank/tests/learning-outcomes.service.spec.ts`
3. `src/modules/exams/tests/exam-outcome-generation.service.spec.ts`

Migration:

1. `src/database/migrations/1781000000000-AddQuestionBankTagsAndOutcomes.ts`

### 7.4 Database Design

Create `question_bank_tags`:

1. `tag_id`
2. `course_id`
3. `name`
4. `slug`
5. `description`
6. `color`
7. `created_by`
8. `created_at`
9. `updated_at`
10. `deleted_at`

Constraints:

1. Unique `(course_id, slug)`.
2. Index `(course_id, name)`.

Create `question_bank_question_tags`:

1. `question_id`
2. `tag_id`
3. `created_at`

Constraints:

1. Primary or unique `(question_id, tag_id)`.
2. FK to `question_bank_questions`.
3. FK to `question_bank_tags`.

Create `learning_outcomes`:

1. `outcome_id`
2. `course_id`
3. `code`
4. `title`
5. `description`
6. `outcome_order`
7. `created_by`
8. `created_at`
9. `updated_at`
10. `deleted_at`

Constraints:

1. Unique `(course_id, code)`.
2. Unique `(course_id, outcome_order)`.

Create `question_bank_question_outcomes`:

1. `question_id`
2. `outcome_id`
3. `coverage_weight`
4. `created_at`

Constraints:

1. Unique `(question_id, outcome_id)`.
2. `coverage_weight > 0`.

### 7.5 API Endpoints

Tags:

1. `POST /api/question-bank/tags`
2. `GET /api/question-bank/tags?courseId=...`
3. `PATCH /api/question-bank/tags/:tagId`
4. `DELETE /api/question-bank/tags/:tagId`
5. `POST /api/question-bank/questions/:questionId/tags`
6. `DELETE /api/question-bank/questions/:questionId/tags/:tagId`

Learning outcomes:

1. `POST /api/question-bank/learning-outcomes`
2. `GET /api/question-bank/learning-outcomes?courseId=...`
3. `PATCH /api/question-bank/learning-outcomes/:outcomeId`
4. `DELETE /api/question-bank/learning-outcomes/:outcomeId`
5. `POST /api/question-bank/questions/:questionId/outcomes`
6. `DELETE /api/question-bank/questions/:questionId/outcomes/:outcomeId`

Question search enhancements:

1. `GET /api/question-bank/questions?tagIds=1,2`
2. `GET /api/question-bank/questions?outcomeIds=1,2`
3. `GET /api/question-bank/questions?missingOutcomes=true`

### 7.6 Service Rules

1. Instructor must own the course.
2. Tag/outcome must belong to the same course as the question.
3. Deleting a tag or outcome should soft delete by default.
4. Generation should only use active tags/outcomes.
5. Question response DTO should include tags and outcomes when requested.
6. Avoid N+1 queries in list responses.

### 7.7 Exam Generator Integration

Extend `ExamGenerationRuleDto`:

1. `tagIds?: number[]`
2. `outcomeIds?: number[]`
3. `requireAllTags?: boolean`
4. `minimumOutcomeCoverage?: number`

Generation rules:

1. Validate every tag/outcome belongs to the requested course.
2. If `requireAllTags` is true, question must have all listed tags.
3. If false, question can match any listed tag.
4. Outcome filters should preserve shortage details by outcome.
5. Shortage response should include missing tag/outcome metadata.

### 7.8 Tests

1. Instructor can create course-scoped tags.
2. Instructor cannot use tags from another course.
3. Instructor can create course-scoped learning outcomes.
4. Instructor cannot attach an outcome from another course to a question.
5. Question list filters by tags and outcomes.
6. Exam generation filters by tags and outcomes.
7. Shortage response reports tag/outcome shortages.
8. Deleted tags/outcomes are not used in generation.

### 7.9 Acceptance Criteria

1. Questions can be classified by tags and learning outcomes.
2. Exam generation can filter by tags and outcomes.
3. Metadata is course-owned and instructor-only.
4. Existing questions still work without tags/outcomes.

## 8. Phase F2 - CSV And Excel Import/Export

### 8.1 Purpose

Allow instructors to import and export large question banks using CSV or Excel files. This is different from the primary plan's JSON bulk API; it is a file-based workflow with preview, validation, error reporting, and rollback.

### 8.2 Files To Edit

1. `src/modules/question-bank/question-bank.controller.ts`
2. `src/modules/question-bank/question-bank.service.ts`
3. `src/modules/question-bank/question-bank.module.ts`
4. `src/modules/files/files.service.ts`
5. `src/modules/files/file-storage.service.ts`
6. `src/modules/question-bank/dto/question.dto.ts`

### 8.3 Files To Create

Services:

1. `src/modules/question-bank/services/question-bank-import.service.ts`
2. `src/modules/question-bank/services/question-bank-export.service.ts`
3. `src/modules/question-bank/services/question-bank-import-validator.service.ts`
4. `src/modules/question-bank/services/question-bank-import-template.service.ts`

Entities:

1. `src/modules/question-bank/entities/question-bank-import-job.entity.ts`
2. `src/modules/question-bank/entities/question-bank-import-error.entity.ts`
3. `src/modules/question-bank/entities/question-bank-export-job.entity.ts`

DTOs:

1. `src/modules/question-bank/dto/question-bank-import.dto.ts`
2. `src/modules/question-bank/dto/question-bank-export.dto.ts`

Tests:

1. `src/modules/question-bank/tests/question-bank-import.service.spec.ts`
2. `src/modules/question-bank/tests/question-bank-export.service.spec.ts`

Migration:

1. `src/database/migrations/1781000000001-AddQuestionBankImportExportJobs.ts`

### 8.4 Supported Formats

Initial supported import formats:

1. `.xlsx`
2. `.csv`

Initial supported export formats:

1. `.xlsx`
2. `.csv`
3. Optional JSON export for system-to-system transfer.

Use existing dependencies where possible:

1. `exceljs` is already installed.
2. `files` table can store uploaded import files and generated export files.

### 8.5 Import Template Columns

Required columns:

1. `course_code` or request-level `courseId`
2. `chapter_name` or `chapter_id`
3. `question_type`
4. `difficulty`
5. `bloom_level`
6. `question_text`

Type-specific columns:

1. `expected_answer_text`
2. `hints`
3. `option_1`
4. `option_1_is_correct`
5. `option_2`
6. `option_2_is_correct`
7. `option_3`
8. `option_3_is_correct`
9. `option_4`
10. `option_4_is_correct`
11. `blank_1_key`
12. `blank_1_answer`
13. `blank_1_case_sensitive`

Metadata columns:

1. `status`
2. `tags`
3. `learning_outcomes`
4. `group_key`
5. `group_title`
6. `group_type`
7. `attachment_urls`
8. `source_reference`

### 8.6 Database Design

Create `question_bank_import_jobs`:

1. `import_job_id`
2. `course_id`
3. `file_id`
4. `status`: `uploaded`, `validating`, `validation_failed`, `ready`, `importing`, `completed`, `failed`, `cancelled`
5. `mode`: `validate_only`, `import`
6. `total_rows`
7. `valid_rows`
8. `invalid_rows`
9. `created_questions_count`
10. `created_groups_count`
11. `created_by`
12. `created_at`
13. `completed_at`
14. `failure_reason`

Create `question_bank_import_errors`:

1. `import_error_id`
2. `import_job_id`
3. `row_number`
4. `column_name`
5. `field_path`
6. `error_code`
7. `message`
8. `raw_value`

Create `question_bank_export_jobs`:

1. `export_job_id`
2. `course_id`
3. `file_id`
4. `status`
5. `format`
6. `filter_json`
7. `row_count`
8. `requested_by`
9. `created_at`
10. `completed_at`
11. `failure_reason`

### 8.7 API Endpoints

Import:

1. `GET /api/question-bank/import-template?format=xlsx`
2. `POST /api/question-bank/imports/upload`
3. `POST /api/question-bank/imports/:jobId/validate`
4. `GET /api/question-bank/imports/:jobId`
5. `GET /api/question-bank/imports/:jobId/errors`
6. `POST /api/question-bank/imports/:jobId/commit`
7. `POST /api/question-bank/imports/:jobId/cancel`

Export:

1. `POST /api/question-bank/exports`
2. `GET /api/question-bank/exports/:jobId`
3. `GET /api/question-bank/exports/:jobId/download`

### 8.8 Service Rules

1. Upload validates file type and size.
2. Validation phase does not write questions.
3. Commit phase writes all accepted rows in transactions.
4. Optionally support `skip_invalid_rows`, but default should be all-or-nothing.
5. Errors must include row and column.
6. Import should reuse existing single/bulk question validation helpers.
7. Duplicate detection phase should run before commit after Phase F3.
8. Import should not create tags/outcomes unless `allowCreateMetadata = true`.
9. Export should respect instructor ownership and filters.
10. Export should not include answer keys unless `includeAnswers = true`.

### 8.9 Tests

1. Instructor downloads template.
2. Instructor uploads valid CSV.
3. Instructor uploads valid XLSX.
4. Invalid file type is rejected.
5. Validation returns row-level errors.
6. Commit creates questions transactionally.
7. Commit rolls back if one row fails.
8. Import cannot target another instructor's course.
9. Export respects filters.
10. Export can exclude answer keys.

### 8.10 Acceptance Criteria

1. Instructor can safely validate a file before importing.
2. Import errors are understandable and row-specific.
3. Large bank management does not require manual SQL.
4. Import/export uses migrations, files, and transactions.

## 9. Phase F3 - Duplicate And Similarity Detection

### 9.1 Purpose

Prevent accidental duplicate questions and help instructors review near-duplicates before saving or importing.

### 9.2 Files To Edit

1. `src/modules/question-bank/question-bank.service.ts`
2. `src/modules/question-bank/question-bank.controller.ts`
3. `src/modules/question-bank/question-bank.module.ts`
4. `src/modules/question-bank/services/question-bank-import.service.ts`
5. `src/modules/question-bank/dto/question.dto.ts`

### 9.3 Files To Create

Services:

1. `src/modules/question-bank/services/question-duplicate-detection.service.ts`
2. `src/modules/question-bank/services/question-normalization.service.ts`
3. `src/modules/question-bank/services/question-similarity.service.ts`

Entities:

1. `src/modules/question-bank/entities/question-bank-question-signature.entity.ts`
2. `src/modules/question-bank/entities/question-bank-duplicate-candidate.entity.ts`

DTOs:

1. `src/modules/question-bank/dto/question-duplicate.dto.ts`

Tests:

1. `src/modules/question-bank/tests/question-duplicate-detection.service.spec.ts`

Migration:

1. `src/database/migrations/1781000000002-AddQuestionDuplicateDetection.ts`

### 9.4 Detection Levels

Level 1: exact normalized duplicate.

1. Trim whitespace.
2. Lowercase where appropriate.
3. Normalize punctuation.
4. Remove repeated spaces.
5. Hash normalized question text plus type plus course.

Level 2: same stem, different answer/options.

1. Compare normalized `question_text`.
2. Compare option set separately.
3. Warn if text is same but correct answer differs.

Level 3: near-duplicate similarity.

1. Token-based similarity.
2. Jaccard or cosine over normalized tokens.
3. Optional later vector embeddings if an approved AI/vector infrastructure exists.

Do not require vector search in the first duplicate phase. Start with deterministic hashing and token similarity.

### 9.5 Database Design

Create `question_bank_question_signatures`:

1. `signature_id`
2. `question_id`
3. `course_id`
4. `normalized_text_hash`
5. `normalized_answer_hash`
6. `normalized_options_hash`
7. `token_fingerprint`
8. `created_at`
9. `updated_at`

Constraints:

1. Unique `(question_id)`.
2. Index `(course_id, normalized_text_hash)`.
3. Index `(course_id, normalized_options_hash)`.

Create `question_bank_duplicate_candidates`:

1. `candidate_id`
2. `course_id`
3. `source_question_id`
4. `matched_question_id`
5. `similarity_score`
6. `match_type`: `exact_text`, `same_stem`, `similar_text`, `same_answers`
7. `status`: `open`, `ignored`, `confirmed_duplicate`, `resolved`
8. `created_by`
9. `created_at`
10. `resolved_by`
11. `resolved_at`
12. `resolution_comment`

### 9.6 API Endpoints

1. `POST /api/question-bank/questions/check-duplicates`
2. `GET /api/question-bank/questions/:questionId/duplicates`
3. `GET /api/question-bank/duplicate-candidates?courseId=...`
4. `POST /api/question-bank/duplicate-candidates/:candidateId/ignore`
5. `POST /api/question-bank/duplicate-candidates/:candidateId/confirm`
6. `POST /api/question-bank/duplicate-candidates/:candidateId/resolve`

### 9.7 Service Rules

1. Duplicate detection is course-scoped.
2. Exact duplicate can be blocking or warning based on request option.
3. Near duplicate should be warning by default.
4. Import validation should return duplicate warnings before commit.
5. Create/update should update question signature in the same transaction.
6. Soft-deleted/archived questions can be included or excluded by query option.
7. Instructors can override warning with reason.

### 9.8 Tests

1. Exact same question is detected.
2. Whitespace/case variations are detected.
3. Different course duplicate does not block.
4. Same stem but different answer produces warning.
5. Import validation returns duplicate warnings.
6. Updating a question updates signature.
7. Ignoring a candidate hides it from open list.

### 9.9 Acceptance Criteria

1. Instructor gets duplicate warnings before creating/importing repeated questions.
2. Duplicate detection does not block legitimate variations without override path.
3. Duplicate logic is deterministic and testable.

## 10. Phase F4 - Question Usage Statistics

### 10.1 Purpose

Track how often each question is used in generated and saved exams. This helps avoid overexposure and improves generator quality.

### 10.2 Files To Edit

1. `src/modules/exams/exams.service.ts`
2. `src/modules/question-bank/question-bank.service.ts`
3. `src/modules/question-bank/question-bank.module.ts`
4. `src/modules/exams/exams.module.ts`
5. `src/modules/question-bank/dto/question-response.dto.ts`
6. `src/modules/exams/dto/generate-exam.dto.ts`

### 10.3 Files To Create

Entities:

1. `src/modules/question-bank/entities/question-bank-usage-event.entity.ts`
2. `src/modules/question-bank/entities/question-bank-usage-summary.entity.ts`

Services:

1. `src/modules/question-bank/services/question-usage.service.ts`

DTOs:

1. `src/modules/question-bank/dto/question-usage.dto.ts`

Tests:

1. `src/modules/question-bank/tests/question-usage.service.spec.ts`
2. `src/modules/exams/tests/exam-generation-usage.service.spec.ts`

Migration:

1. `src/database/migrations/1781000000003-AddQuestionUsageAndQualityMetrics.ts`

### 10.4 Database Design

Create `question_bank_usage_events`:

1. `usage_event_id`
2. `question_id`
3. `course_id`
4. `exam_id`
5. `draft_id`
6. `event_type`: `preview_selected`, `draft_saved`, `exam_published`, `exam_exported`, `manual_added`
7. `used_by`
8. `used_at`
9. `metadata_json`

Create `question_bank_usage_summaries`:

1. `question_id`
2. `course_id`
3. `preview_selected_count`
4. `saved_exam_count`
5. `published_exam_count`
6. `exported_count`
7. `manual_added_count`
8. `last_used_at`
9. `last_published_at`
10. `updated_at`

### 10.5 API Endpoints

1. `GET /api/question-bank/questions/:questionId/usage`
2. `GET /api/question-bank/usage?courseId=...`
3. `GET /api/question-bank/usage/overused?courseId=...`

### 10.6 Generator Integration

Extend `GenerateExamPreviewDto`:

1. `avoidRecentlyUsed?: boolean`
2. `recentUsageWindowDays?: number`
3. `maxSavedExamUses?: number`
4. `usagePenaltyMode?: 'none' | 'soft_penalty' | 'exclude_overused'`

Selection behavior:

1. `none`: ignore usage.
2. `soft_penalty`: prefer less-used questions but allow overused questions if pool is small.
3. `exclude_overused`: exclude questions above threshold; return shortage if insufficient.

### 10.7 Service Rules

1. Count usage when draft is saved, not only previewed.
2. Preview selection can be tracked separately to measure generator behavior.
3. Published exams should count as stronger usage than draft previews.
4. Manual draft add should count if final exam is saved.
5. Usage updates must happen in the same transaction as save/publish where possible.
6. Do not leak usage from other instructors' courses.

### 10.8 Tests

1. Saving exam increments saved usage.
2. Publishing exam increments published usage.
3. Exporting exam increments export usage.
4. Generator can avoid recently used questions.
5. Generator returns shortage if usage filter excludes too many questions.
6. Question response includes `usageCount` when requested.

### 10.9 Acceptance Criteria

1. Instructor can see question usage history.
2. Generator can reduce repeated question exposure.
3. Usage metrics are course-owned and reliable.

## 11. Phase F5 - Question Quality Metrics

### 11.1 Purpose

Track academic quality signals for questions: observed difficulty, discrimination, average score, answer distribution, review needs, and stale/weak question detection.

Important clarification:

Question quality metrics require student answer/submission data. If the project remains paper-only, quality metrics can start with instructor review metrics and manual outcome data. Automated score-based metrics require online delivery or gradebook item-level data.

### 11.2 Files To Edit

1. `src/modules/question-bank/question-bank.service.ts`
2. `src/modules/question-bank/question-bank.module.ts`
3. `src/modules/exams/exams.service.ts`
4. `src/modules/analytics/analytics.module.ts`
5. `src/modules/analytics/services/analytics.service.ts`

### 11.3 Files To Create

Entities:

1. `src/modules/question-bank/entities/question-bank-quality-metric.entity.ts`
2. `src/modules/question-bank/entities/question-bank-answer-distribution.entity.ts`
3. `src/modules/question-bank/entities/question-bank-review-recommendation.entity.ts`

Services:

1. `src/modules/question-bank/services/question-quality.service.ts`
2. `src/modules/question-bank/services/question-quality-calculation.service.ts`

DTOs:

1. `src/modules/question-bank/dto/question-quality.dto.ts`

Tests:

1. `src/modules/question-bank/tests/question-quality.service.spec.ts`

Migration:

1. `src/database/migrations/1781000000003-AddQuestionUsageAndQualityMetrics.ts`

### 11.4 Database Design

Create `question_bank_quality_metrics`:

1. `metric_id`
2. `question_id`
3. `course_id`
4. `attempt_count`
5. `average_score`
6. `average_score_percent`
7. `observed_difficulty`: `easy`, `medium`, `hard`, `unknown`
8. `discrimination_index`
9. `correct_rate`
10. `skip_rate`
11. `manual_quality_rating`
12. `last_calculated_at`
13. `updated_at`

Create `question_bank_answer_distributions`:

1. `distribution_id`
2. `question_id`
3. `option_id`
4. `answer_text_hash`
5. `selected_count`
6. `selected_percent`
7. `calculated_at`

Create `question_bank_review_recommendations`:

1. `recommendation_id`
2. `question_id`
3. `course_id`
4. `reason_code`: `too_easy`, `too_hard`, `low_discrimination`, `overused`, `stale`, `missing_metadata`
5. `severity`: `low`, `medium`, `high`
6. `status`: `open`, `dismissed`, `resolved`
7. `created_at`
8. `resolved_at`
9. `resolved_by`

### 11.5 API Endpoints

1. `GET /api/question-bank/questions/:questionId/quality`
2. `GET /api/question-bank/quality?courseId=...`
3. `GET /api/question-bank/review-recommendations?courseId=...`
4. `POST /api/question-bank/review-recommendations/:id/dismiss`
5. `POST /api/question-bank/review-recommendations/:id/resolve`
6. `POST /api/question-bank/questions/:questionId/manual-quality-rating`

### 11.6 Calculation Rules

If online attempts or item-level grades exist:

1. `correct_rate = correct_attempts / total_attempts`.
2. `skip_rate = skipped_attempts / total_attempts`.
3. `average_score_percent = average_score / max_score`.
4. Observed difficulty maps from correct rate or average score.
5. Discrimination compares top and bottom scoring groups.

If no online attempts exist:

1. Use manual quality rating.
2. Use usage count.
3. Use instructor review status.
4. Use metadata completeness.
5. Do not pretend automated difficulty metrics are available.

### 11.7 Tests

1. Quality metric calculation handles no attempts.
2. Manual quality rating is saved.
3. Overused question creates recommendation.
4. Missing metadata creates recommendation.
5. Low discrimination creates recommendation when enough data exists.
6. Dismiss/resolve workflow is course-owned.

### 11.8 Acceptance Criteria

1. Quality metrics are honest about available data.
2. Instructor can identify weak or overused questions.
3. Automated metrics do not run without sufficient data.

## 12. Phase F6 - Exam Blueprint Templates

### 12.1 Purpose

Allow instructors to save reusable exam generation blueprints for midterms, finals, quizzes, and practice exams. Templates should support chapters, tags, outcomes, difficulty balance, Bloom balance, sections, total marks, usage constraints, and group rules.

### 12.2 Files To Edit

1. `src/modules/exams/exams.controller.ts`
2. `src/modules/exams/exams.service.ts`
3. `src/modules/exams/exams.module.ts`
4. `src/modules/exams/dto/generate-exam.dto.ts`
5. `src/modules/exams/dto/exam-response.dto.ts`

### 12.3 Files To Create

Entities:

1. `src/modules/exams/entities/exam-blueprint-template.entity.ts`
2. `src/modules/exams/entities/exam-blueprint-template-section.entity.ts`
3. `src/modules/exams/entities/exam-blueprint-template-rule.entity.ts`

DTOs:

1. `src/modules/exams/dto/exam-blueprint-template.dto.ts`

Services:

1. `src/modules/exams/services/exam-blueprint-template.service.ts`

Tests:

1. `src/modules/exams/tests/exam-blueprint-template.service.spec.ts`
2. `src/modules/exams/tests/exam-template-generation.service.spec.ts`

Migration:

1. `src/database/migrations/1781000000004-AddExamBlueprintTemplates.ts`

### 12.4 Database Design

Create `exam_blueprint_templates`:

1. `template_id`
2. `course_id`
3. `name`
4. `description`
5. `exam_type`
6. `total_marks`
7. `mark_distribution_mode`
8. `rounding_policy`
9. `group_selection_mode`
10. `usage_policy_json`
11. `is_default`
12. `created_by`
13. `created_at`
14. `updated_at`
15. `deleted_at`

Create `exam_blueprint_template_sections`:

1. `template_section_id`
2. `template_id`
3. `title`
4. `instructions`
5. `section_order`
6. `total_marks`
7. `answer_policy`
8. `required_answer_count`

Create `exam_blueprint_template_rules`:

1. `template_rule_id`
2. `template_section_id`
3. `chapter_id`
4. `question_type`
5. `difficulty`
6. `bloom_level`
7. `count`
8. `weight_units`
9. `tag_filter_json`
10. `outcome_filter_json`
11. `rule_order`

### 12.5 API Endpoints

1. `POST /api/exams/blueprint-templates`
2. `GET /api/exams/blueprint-templates?courseId=...`
3. `GET /api/exams/blueprint-templates/:templateId`
4. `PATCH /api/exams/blueprint-templates/:templateId`
5. `DELETE /api/exams/blueprint-templates/:templateId`
6. `POST /api/exams/blueprint-templates/:templateId/generate-preview`
7. `POST /api/exams/blueprint-templates/:templateId/duplicate`
8. `POST /api/exams/blueprint-templates/:templateId/set-default`

### 12.6 Service Rules

1. Template is course-owned.
2. Template rules must reference chapters, tags, and outcomes from the same course.
3. Deleted chapters/tags/outcomes should make template validation fail with actionable errors.
4. Template generation uses the same generator as normal `generate-preview`.
5. Duplicate template copies sections/rules but not generated drafts.
6. Default template should be unique per course and exam type.

### 12.7 Tests

1. Instructor can create template.
2. Template rejects cross-course chapters/tags/outcomes.
3. Template generation creates a normal exam draft.
4. Deleted metadata causes template validation warning/error.
5. Default template uniqueness is enforced.
6. Duplicate template works.

### 12.8 Acceptance Criteria

1. Instructors can reuse generation rules.
2. Templates integrate with sections, marks, tags, outcomes, groups, and usage policies.
3. Template generation produces the same draft shape as normal generation.

## 13. Phase F7 - Advanced Group-Aware Generation

### 13.1 Purpose

Improve generation behavior for grouped questions beyond basic metadata. This prevents splitting multipart questions incorrectly and supports case/passage-based exam sections.

### 13.2 Files To Edit

1. `src/modules/exams/exams.service.ts`
2. `src/modules/exams/dto/generate-exam.dto.ts`
3. `src/modules/question-bank/entities/question-bank-question-group.entity.ts`
4. `src/modules/question-bank/entities/question-bank-question-group-item.entity.ts`

### 13.3 Files To Create

1. `src/modules/exams/services/exam-group-selection.service.ts`
2. `src/modules/exams/tests/exam-group-selection.service.spec.ts`

### 13.4 Generator Modes

Supported modes:

1. `independent`
   - Treat grouped questions like normal individual questions.

2. `exclude_grouped`
   - Do not select grouped questions.

3. `keep_group_together`
   - If one group item is selected, include the whole group.

4. `group_as_section`
   - Create a section from the group prompt and include all group items.

5. `max_one_from_group`
   - Prevent selecting multiple questions from the same group.

### 13.5 Service Rules

1. Group belongs to the same course.
2. Group chapter belongs to the same course.
3. Group item order is stable.
4. If whole group does not fit requested count/marks, return structured shortage.
5. Marks can be distributed inside group.
6. Export includes shared prompt before group items.

### 13.6 Tests

1. `keep_group_together` selects full group.
2. `exclude_grouped` excludes grouped questions.
3. `max_one_from_group` avoids multiple group items.
4. Group shortage includes group metadata.
5. Export preserves group prompt and item order.

### 13.7 Acceptance Criteria

1. Grouped questions behave predictably during generation.
2. Multipart exams can be generated without broken context.

## 14. Phase F8 - Schedule Integration

### 14.1 Purpose

Connect generated exams to the existing schedule module so instructors can schedule a generated/published exam without duplicating metadata manually.

Important clarification:

This phase schedules the generated exam as an academic event. It does not by itself create online student attempts or gradebook entries.

### 14.2 Existing Files To Integrate

1. `src/modules/schedule/entities/exam-schedule.entity.ts`
2. `src/modules/schedule/services/exam-schedule.service.ts`
3. `src/modules/schedule/controllers/exam-schedule.controller.ts`
4. `src/modules/schedule/dto/create-exam-schedule.dto.ts`
5. `src/modules/schedule/dto/update-exam-schedule.dto.ts`
6. `src/modules/exams/entities/exam.entity.ts`
7. `src/modules/exams/exams.service.ts`
8. `src/modules/exams/exams.module.ts`

### 14.3 Files To Create

DTOs:

1. `src/modules/exams/dto/exam-schedule-link.dto.ts`

Services:

1. `src/modules/exams/services/exam-schedule-link.service.ts`

Tests:

1. `src/modules/exams/tests/exam-schedule-link.service.spec.ts`

Migration:

1. `src/database/migrations/1781000000005-AddExamScheduleIntegration.ts`

### 14.4 Database Options

Preferred option: add nullable `generated_exam_id` to `exam_schedules`.

Columns:

1. `exam_schedules.generated_exam_id bigint unsigned null`
2. Index `(generated_exam_id)`
3. FK to `exams(exam_id)` with `SET NULL` or `RESTRICT`

Alternative option: create join table `generated_exam_schedule_links`.

Use join table if one generated exam can have multiple schedule events or if existing schedule semantics should remain untouched.

Recommended initial design:

1. Add `generated_exam_id` to `exam_schedules`.
2. Allow one generated exam to have zero or one active schedule.
3. If multiple schedules are needed later, migrate to a join table.

### 14.5 API Endpoints

From exams module:

1. `POST /api/exams/:examId/schedule`
2. `GET /api/exams/:examId/schedule`
3. `PATCH /api/exams/:examId/schedule/:scheduleId`
4. `DELETE /api/exams/:examId/schedule/:scheduleId`

Or from schedule module:

1. Extend `POST /api/schedule/exams` to accept `generatedExamId`.
2. Extend schedule response to include generated exam metadata.

Pick one primary route style and document it. Avoid maintaining two write paths with different validation.

### 14.6 Service Rules

1. Instructor must own generated exam course.
2. Instructor must own schedule course.
3. Schedule course must match exam course.
4. Generated exam should be `published` before scheduling unless product allows scheduling draft exams.
5. Start/end time conflicts should use existing schedule conflict logic.
6. Schedule delete should not delete the generated exam.
7. Archiving an exam should warn or block if it has an active schedule.

### 14.7 Notifications

If integrating with `notifications`:

1. Notify instructor when exam is scheduled.
2. Notify enrolled students only if a learner-facing schedule feed is already available and product approves visibility.
3. Do not expose answer keys or snapshots in notifications.

### 14.8 Tests

1. Instructor can schedule own published exam.
2. Instructor cannot schedule another course's exam.
3. Schedule course must match exam course.
4. Conflict detection still works.
5. Deleting schedule does not delete exam.
6. Archived exam cannot be newly scheduled.

### 14.9 Acceptance Criteria

1. Generated exams can be linked to schedule events.
2. Schedule integration respects ownership and lifecycle.
3. Existing schedule APIs keep working.

## 15. Phase F9 - Gradebook Integration

### 15.1 Purpose

Connect generated exams to the grades module when the project has a clear grading workflow.

Critical clarification:

The current exam generator creates instructor-authored exams. It does not currently collect student submissions or attempts. Therefore, gradebook integration must be one of these two models:

1. Manual grade entry for a generated exam.
2. Online delivery/submission integration after a separate assessment delivery module exists.

Do not automatically create grades just because an exam is published or scheduled.

### 15.2 Existing Files To Integrate

1. `src/modules/grades/entities/grade.entity.ts`
2. `src/modules/grades/entities/grade-component.entity.ts`
3. `src/modules/grades/services/grades.service.ts`
4. `src/modules/grades/controllers/grades.controller.ts`
5. `src/modules/grades/dto/create-grade.dto.ts`
6. `src/modules/grades/dto/update-grade.dto.ts`
7. `src/modules/exams/entities/exam.entity.ts`
8. `src/modules/exams/entities/exam-item.entity.ts`
9. `src/modules/enrollments/entities/course-enrollment.entity.ts`

### 15.3 Files To Create

DTOs:

1. `src/modules/exams/dto/exam-gradebook.dto.ts`
2. `src/modules/grades/dto/exam-grade.dto.ts`

Services:

1. `src/modules/exams/services/exam-gradebook.service.ts`

Tests:

1. `src/modules/exams/tests/exam-gradebook.service.spec.ts`
2. `src/modules/grades/tests/exam-grades.service.spec.ts`

Migration:

1. `src/database/migrations/1781000000006-AddExamGradebookIntegration.ts`

### 15.4 Database Design

Minimal integration:

1. Add nullable `exam_id` to `grades`.
2. Add FK from `grades.exam_id` to `exams.exam_id`.
3. Add index `(exam_id)`.
4. Add unique `(user_id, course_id, exam_id)` when `exam_id` is not null if MySQL strategy supports it safely.

Optional gradebook control table:

Create `exam_gradebook_settings`:

1. `setting_id`
2. `exam_id`
3. `course_id`
4. `max_score`
5. `grade_type`: `exam`, `final`
6. `publish_grades_on`
7. `created_by`
8. `created_at`
9. `updated_at`

Optional per-item grading table:

Create `exam_question_grades` only if item-level grading is required:

1. `exam_question_grade_id`
2. `exam_id`
3. `exam_item_id`
4. `user_id`
5. `score`
6. `max_score`
7. `feedback`
8. `graded_by`
9. `graded_at`

### 15.5 API Endpoints

Gradebook setup:

1. `POST /api/exams/:examId/gradebook`
2. `GET /api/exams/:examId/gradebook`
3. `PATCH /api/exams/:examId/gradebook`

Manual grade entry:

1. `POST /api/exams/:examId/grades`
2. `POST /api/exams/:examId/grades/bulk`
3. `GET /api/exams/:examId/grades`
4. `PATCH /api/exams/:examId/grades/:gradeId`
5. `POST /api/exams/:examId/grades/publish`

Optional import:

1. `POST /api/exams/:examId/grades/import`
2. `GET /api/exams/:examId/grades/import/:jobId`

### 15.6 Service Rules

1. Instructor must own exam course.
2. Student must be enrolled in exam course.
3. Score cannot exceed exam total marks.
4. `maxScore` should default from `exams.total_marks`.
5. Published grades should not be overwritten without explicit update reason.
6. Grade rows should use existing `GradeType.EXAM` or `GradeType.FINAL`.
7. Manual grade import should be transactional or row-error based with clear status.
8. Gradebook integration should use saved exam snapshots, not mutable question bank rows.

### 15.7 Tests

1. Instructor can create gradebook setting for own exam.
2. Instructor cannot create grades for another course's exam.
3. Student must be enrolled.
4. Score above max is rejected.
5. Bulk grade entry is transactional or returns row-level errors.
6. Publishing grades updates `is_published`.
7. `GradeType.EXAM` and `GradeType.FINAL` are used correctly.

### 15.8 Acceptance Criteria

1. Generated exams can become gradebook items only through explicit instructor action.
2. No grade is created without student/enrollment validation.
3. Existing grades module remains compatible.

## 16. Phase F10 - Optional Online Assessment Delivery Bridge

### 16.1 Purpose

If the product later needs students to take generated exams online, build a separate delivery layer. Do not reuse instructor authoring endpoints for students.

### 16.2 Why This Is Separate

Instructor exam generator stores answer keys, hints, acceptable answers, and snapshots. Student delivery must hide those fields and enforce availability, attempts, timing, submission, and grading rules.

### 16.3 Files To Create

New module recommended:

1. `src/modules/assessment-delivery/assessment-delivery.module.ts`
2. `src/modules/assessment-delivery/assessment-delivery.controller.ts`
3. `src/modules/assessment-delivery/assessment-delivery.service.ts`

Entities:

1. `src/modules/assessment-delivery/entities/exam-attempt.entity.ts`
2. `src/modules/assessment-delivery/entities/exam-attempt-answer.entity.ts`
3. `src/modules/assessment-delivery/entities/exam-attempt-event.entity.ts`

DTOs:

1. `src/modules/assessment-delivery/dto/start-exam-attempt.dto.ts`
2. `src/modules/assessment-delivery/dto/submit-exam-answer.dto.ts`
3. `src/modules/assessment-delivery/dto/submit-exam-attempt.dto.ts`
4. `src/modules/assessment-delivery/dto/student-exam-response.dto.ts`

Migration:

1. `src/database/migrations/1781000000008-AddAssessmentDelivery.ts`

### 16.4 Student-Safe APIs

1. `GET /api/student/exams`
2. `GET /api/student/exams/:examId`
3. `POST /api/student/exams/:examId/attempts`
4. `PATCH /api/student/exams/:examId/attempts/:attemptId/answers/:itemId`
5. `POST /api/student/exams/:examId/attempts/:attemptId/submit`

### 16.5 Security Rules

1. Student response DTO must never include correct options, expected answers, hints, acceptable blank answers, or answer-key exports.
2. Student must be enrolled in the course.
3. Exam must be published and scheduled/available.
4. Attempt start/end time must be enforced.
5. Attempts must be idempotent.
6. Submission must be immutable after final submit.

### 16.6 Acceptance Criteria

1. Student delivery is isolated from instructor authoring APIs.
2. Answer keys are never exposed to students.
3. Attempts can feed gradebook and quality metrics.

## 17. Phase F11 - Instructor Analytics Dashboard

### 17.1 Purpose

Give instructors a dashboard for bank health and exam generation quality.

### 17.2 Files To Edit

1. `src/modules/analytics/analytics.module.ts`
2. `src/modules/analytics/controllers/analytics.controller.ts`
3. `src/modules/analytics/services/analytics.service.ts`
4. `src/modules/question-bank/question-bank.module.ts`
5. `src/modules/exams/exams.module.ts`

### 17.3 Files To Create

Services:

1. `src/modules/analytics/services/question-bank-analytics.service.ts`
2. `src/modules/analytics/services/exam-generator-analytics.service.ts`

DTOs:

1. `src/modules/analytics/dto/question-bank-analytics.dto.ts`
2. `src/modules/analytics/dto/exam-generator-analytics.dto.ts`

Tests:

1. `src/modules/analytics/tests/question-bank-analytics.service.spec.ts`
2. `src/modules/analytics/tests/exam-generator-analytics.service.spec.ts`

### 17.4 Dashboard Metrics

Question bank:

1. Total questions by course.
2. Questions by status.
3. Questions by type.
4. Questions by difficulty.
5. Questions by Bloom level.
6. Questions missing tags.
7. Questions missing outcomes.
8. Questions missing expected answers.
9. Overused questions.
10. Duplicate candidate count.
11. Quality recommendation count.

Exam generator:

1. Drafts created.
2. Drafts finalized.
3. Drafts expired.
4. Generation shortage count.
5. Most common shortage reasons.
6. Average generation time.
7. Exam exports count.
8. Published exams count.
9. Schedule-linked exams count.
10. Gradebook-linked exams count.

### 17.5 API Endpoints

1. `GET /api/analytics/question-bank/summary?courseId=...`
2. `GET /api/analytics/question-bank/coverage?courseId=...`
3. `GET /api/analytics/question-bank/quality?courseId=...`
4. `GET /api/analytics/exam-generator/summary?courseId=...`
5. `GET /api/analytics/exam-generator/shortages?courseId=...`

### 17.6 Service Rules

1. Instructor can only see owned courses.
2. Aggregates should not expose answer keys.
3. Queries should use indexes and precomputed summaries where needed.
4. Heavy metrics can be cached or calculated by scheduled jobs.

### 17.7 Acceptance Criteria

1. Instructor can see bank health and generation quality.
2. Analytics are course-owned.
3. Heavy queries do not degrade normal API performance.

## 18. Phase F12 - Governance, Audit, And Retention

### 18.1 Purpose

Improve long-term operational safety: audit changes, retain academic records, and clean old jobs/files safely.

### 18.2 Files To Edit

1. `src/modules/question-bank/question-bank.service.ts`
2. `src/modules/exams/exams.service.ts`
3. `src/modules/files/files.service.ts`
4. `src/modules/monitoring`

### 18.3 Files To Create

Entities:

1. `src/modules/question-bank/entities/question-bank-audit-log.entity.ts`
2. `src/modules/exams/entities/exam-audit-log.entity.ts`
3. `src/modules/exams/entities/exam-retention-policy.entity.ts`

Services:

1. `src/modules/question-bank/services/question-bank-retention.service.ts`
2. `src/modules/exams/services/exam-retention.service.ts`

Migration:

1. `src/database/migrations/1781000000007-AddExamAnalyticsAndGovernance.ts`

### 18.4 Audit Events

Question bank:

1. Question created.
2. Question updated.
3. Question archived/deleted.
4. Question approved/rejected.
5. Attachment added/removed.
6. Import committed.
7. Duplicate override used.

Exam generator:

1. Draft generated.
2. Draft manually edited.
3. Draft finalized.
4. Exam published/archived.
5. Exam scheduled.
6. Gradebook linked.
7. Export generated.

### 18.5 Retention Rules

1. Keep final exam snapshots indefinitely unless explicit institutional retention rules say otherwise.
2. Keep import/export job records for a configurable period.
3. Clean failed import/export files after retention window.
4. Do not delete files referenced by snapshots or published exams.
5. Soft delete question bank metadata before hard delete.

### 18.6 Acceptance Criteria

1. Major academic actions have audit records.
2. Cleanup jobs are safe and reversible where needed.
3. Retention does not break historical exams.

## 19. Recommended Future Implementation Order

Recommended order after the primary plan is complete:

1. Phase F0: future safety baseline.
2. Phase F1: tags and learning outcomes.
3. Phase F2: CSV/Excel import/export.
4. Phase F3: duplicate and similarity detection.
5. Phase F4: usage statistics.
6. Phase F6: blueprint templates.
7. Phase F7: advanced group-aware generation.
8. Phase F8: schedule integration.
9. Phase F9: gradebook integration if manual grading is desired.
10. Phase F10: online assessment delivery only if student online exams are required.
11. Phase F5: quality metrics after usage, grade, or attempt data exists.
12. Phase F11: analytics dashboard.
13. Phase F12: governance, audit, and retention.

Reason:

1. Tags/outcomes improve all later features.
2. Import/export benefits from tags/outcomes.
3. Duplicate detection should run during import.
4. Usage stats should exist before overuse-aware templates.
5. Schedule and gradebook need stable published exams.
6. Automated quality metrics need real usage or attempt/grade data.

## 20. Future Migration Execution Plan

Before applying future migrations:

1. Finish and deploy the primary plan.
2. Confirm `.env` points to the intended Aiven database.
3. Confirm backup exists.
4. Run read-only checks for existing data.
5. Review migration SQL.
6. Run `npm run build`.
7. Run `npm run typeorm -- migration:show -d src/config/typeorm.config.ts`.

Apply migrations from the backend root:

```bash
cd /d D:\Graduation\backend\last_backend\EduVerse_Backend
npm run migration:run
```

After applying:

1. Verify new tables exist.
2. Verify indexes and constraints exist.
3. Verify existing question bank and exam endpoints still work.
4. Verify instructor ownership remains strict.
5. Verify import/export jobs do not expose answer keys unexpectedly.
6. Verify schedule/gradebook integrations do not create student-visible data unless explicitly intended.

## 21. Future Acceptance Checklist

Question bank metadata:

1. Tags work.
2. Learning outcomes work.
3. Questions can be filtered by tags/outcomes.
4. Generation can use tags/outcomes.

Import/export:

1. Template download works.
2. CSV/XLSX validation works.
3. Row-level errors are clear.
4. Commit is transactional or explicitly row-error based.
5. Export respects answer-key options.

Duplicate detection:

1. Exact duplicates are detected.
2. Near-duplicates are warned.
3. Instructor can override with reason.
4. Import uses duplicate checks.

Usage and quality:

1. Usage events are recorded.
2. Overused questions can be avoided.
3. Quality metrics do not pretend unavailable data exists.
4. Review recommendations are actionable.

Templates and generation:

1. Blueprint templates can be created and reused.
2. Templates validate deleted or cross-course metadata.
3. Group-aware generation works.
4. Shortage responses include metadata details.

Schedule and gradebook:

1. Generated exams can be linked to exam schedules.
2. Schedule integration does not delete generated exams.
3. Gradebook integration requires explicit instructor action.
4. Student enrollment is validated before grades are created.

Security:

1. Instructor ownership remains enforced.
2. Student-safe APIs are separate if online delivery is built.
3. Answer keys are never leaked to students.
4. Audit logs exist for major academic actions.

## 22. Final Notes

This future plan is intentionally larger than the primary plan. It should be implemented in small, independently testable phases after the core question bank and exam generator are stable.

The safest long-term path is:

1. Stabilize the instructor-only backend first.
2. Add metadata and import/export.
3. Add generation intelligence.
4. Add schedule and gradebook connections.
5. Add student delivery only as a separate secured module if the product needs online exams.
