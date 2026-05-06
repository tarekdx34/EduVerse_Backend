# Question Bank And Exam Generator Investigation Report

Date: 2026-05-04  
Workspace: `D:\Graduation\backend\last_backend\EduVerse_Backend`  
Report file: `questionBank_Exam_report.md`  
Previous report reviewed first: `report_amir.md`  
Revision note: updated after user-provided DBeaver screenshots and read-only live Aiven metadata checks confirmed the deployed database contains the base feature tables.
Final implementation audit note: updated after the main fix plan was implemented and re-audited on 2026-05-04. The original investigation findings below are retained as historical context, but the current backend state is summarized in Section 2A and the final assessment.

## 1. Scope And Method

This investigation is a static backend review plus read-only live Aiven database metadata/integrity checks. I did not start the NestJS server, run tests, execute migrations, call application APIs, or modify any source code. The only write made for this task is this report file.

The target features are:

1. Save questions to the question bank.
2. Generate exams from the question bank.

The main reviewed files are:

| Area | Files |
|---|---|
| Question bank controller/service | `src/modules/question-bank/question-bank.controller.ts`, `src/modules/question-bank/question-bank.service.ts` |
| Question bank DTOs/entities/enums | `src/modules/question-bank/dto/question.dto.ts`, `src/modules/question-bank/dto/chapter.dto.ts`, `src/modules/question-bank/entities/*.ts`, `src/modules/question-bank/enums/question-bank.enums.ts` |
| Exam controller/service | `src/modules/exams/exams.controller.ts`, `src/modules/exams/exam-drafts.controller.ts`, `src/modules/exams/exams.service.ts` |
| Exam DTOs/entities | `src/modules/exams/dto/generate-exam.dto.ts`, `src/modules/exams/entities/*.ts` |
| Database migrations | Base: `src/database/migrations/1778000000000-CreateQuestionBankAndExams.ts`, `src/database/migrations/1779000000000-SeedWebDevQuestions.ts`; implemented hardening: `src/database/migrations/1780000000000-HardenQuestionBankAndExamFeatures.ts`, `src/database/migrations/1780000000001-MarkEmptyExamDraftsFailed.ts`, `src/database/migrations/1780000000002-VerifyQuestionBankExamConstraintsAndAddOverrideReasons.ts` |
| Auth and course access context | `src/modules/auth/guards/roles.guard.ts`, `src/modules/enrollments/entities/*.ts`, `src/modules/courses/entities/*.ts` |
| File/image storage context | `src/modules/files/files.service.ts`, `src/modules/files/file-storage.service.ts`, `src/modules/files/entities/file.entity.ts` |
| App/database bootstrap | `src/app.module.ts`, `src/config/typeorm.config.ts`, `src/config/database.config.ts`, `eduverse_db.sql`, `tables.txt` |
| Existing tests | `src/modules/question-bank/tests/question-bank.service.spec.ts`, `src/modules/exams/tests/exams.service.spec.ts` |

## 2. Original Executive Summary Historical Findings

This section records the original investigation findings before the main implementation work. These issues were used to create `questionBank_Exam_fix_plan.md`. They should not be read as the current backend status after the final audit.

At the time of the original investigation, the implementation was a useful first version, but it was not yet stable or safe enough for production use. The biggest problems were not small syntax issues. They were feature-model, authorization, database integrity, and lifecycle problems.

Highest priority problems:

1. The current controllers allow non-instructor roles on these features, but the intended product rule is instructor-only for now.
2. The modules use role-based authorization only. They do not verify that the instructor owns or teaches the requested course.
3. The requested question image requirements are not implemented: multiple images, captions, ordered attachments, and attachment metadata are missing.
4. Related/batch questions are not implemented. The database has no question group model.
5. Exam generation supports `weightPerQuestion` and sums `totalWeight`, but it does not support total exam marks with automatic per-question mark distribution.
6. Important write flows are not transactional. Partial writes can leave broken parent/child data.
7. Draft expiration is stored but not enforced. Drafts can be edited or saved after expiration.
8. Saving a draft is not idempotent. Saving the same draft repeatedly can create duplicate exams.
9. Final exams reference live question bank rows instead of storing immutable snapshots of selected questions.
10. Correction after re-investigation: the live Aiven `eduverse_db` does contain the base question bank and exam generator tables. Future deployed database changes should be made through TypeORM migration scripts under `src/database/migrations`, then applied to Aiven with the migration workflow.

Recommended immediate order:

1. Enforce instructor-only access and course ownership checks.
2. Add transactions and idempotency to critical writes.
3. Add the missing attachment/group/scoring schema.
4. Enforce draft lifecycle.
5. Add tests around security, transactions, scoring, and database constraints.

## 2A. Current Implementation Status After Final Audit

Final audit date: 2026-05-04.

Current status: the main question bank and exam generator backend plan is implemented. No remaining backend implementation gaps were found against the main plan.

Verification completed:

```text
npm test -- --runInBand
17 suites passed, 99 tests passed

npm run build
TSC Found 0 issues

npm run migration:show
[X] HardenQuestionBankAndExamFeatures1780000000000
[X] MarkEmptyExamDraftsFailed1780000000001
[X] VerifyQuestionBankExamConstraintsAndAddOverrideReasons1780000000002
```

Current implemented migration files:

1. `src/database/migrations/1780000000000-HardenQuestionBankAndExamFeatures.ts`
2. `src/database/migrations/1780000000001-MarkEmptyExamDraftsFailed.ts`
3. `src/database/migrations/1780000000002-VerifyQuestionBankExamConstraintsAndAddOverrideReasons.ts`

Current implemented group API route style:

1. `POST /api/question-bank/groups`
2. `GET /api/question-bank/groups`
3. `GET /api/question-bank/groups/:groupId`
4. `PATCH /api/question-bank/groups/:groupId`
5. `DELETE /api/question-bank/groups/:groupId`
6. `POST /api/question-bank/groups/:groupId/questions/batch`
7. `PATCH /api/question-bank/groups/:groupId/questions/reorder`

Current conclusion:

1. The two features are instructor-only for the current product scope.
2. Instructor course ownership is enforced through `course_instructors -> course_sections -> course_id`.
3. Question create, update, plain bulk create, and grouped batch create persist parent and child rows transactionally.
4. Existing and uploaded question files are checked for access and image MIME where required.
5. Attachments, captions, alt text, groups, group list/delete, bulk create, review events, versions, sections, marks, draft lifecycle, immutable snapshots, export hardening, cleanup services, response DTO mapping, and tests are implemented for the main plan scope.
6. Future enhancements such as tags, learning outcomes, CSV/Excel import/export, similarity detection, usage statistics, quality metrics, blueprint templates, schedule integration, gradebook integration, and group-aware exam selection remain intentionally outside the main plan and are tracked separately in `questionBank_Exam_future_enhance_plan.md`.

Historical detail notice: Sections 3 through 14 preserve the original investigation detail that justified the fix plan. Some headings and issue descriptions in those sections intentionally describe the pre-implementation state. For current backend status, use Section 2A and Section 15.

## 3. Original Feature Map Before Implementation

### 3.1 Question Bank: What Currently Exists

| Capability | Current status | Evidence |
|---|---:|---|
| Create chapter for course | Implemented | `question-bank.controller.ts:53-60`, `question-bank.service.ts:74-81` |
| List chapters by course | Implemented | `question-bank.controller.ts:62-68`, `question-bank.service.ts:83-89` |
| Update/delete chapter | Implemented | `question-bank.controller.ts:70-88`, `question-bank.service.ts:91-114` |
| Create one question | Implemented | `question-bank.controller.ts:90-97`, `question-bank.service.ts:150-179` |
| Upload one question image | Implemented as one file only | `question-bank.controller.ts:99-130`, especially `FileInterceptor('image')` at line 101 |
| List/filter questions | Implemented | `question-bank.controller.ts:132-138`, `question-bank.service.ts:181-218` |
| Get one question | Implemented | `question-bank.controller.ts:140-146`, `question-bank.service.ts:220-230` |
| Update/delete one question | Implemented | `question-bank.controller.ts:148-165`, `question-bank.service.ts:232-294` |
| Question types | Implemented | `question-bank.enums.ts:1-7` |
| Difficulty and Bloom filters | Implemented | `question-bank.enums.ts:9-22`, `question.dto.ts:193-206` |
| Approval status field | Partially implemented | `question-bank.enums.ts:24-28`, but no approval workflow endpoint |
| Multiple images per question | Missing | Single `questionFileId` field only |
| Image captions | Missing | No caption field in DTO/entity/migration |
| Plain bulk question create | Missing | No `POST /api/question-bank/questions/batch` endpoint |
| Batch related questions | Missing | No grouped batch endpoint and no group schema |

### 3.2 Exam Generator: What Currently Exists

| Capability | Current status | Evidence |
|---|---:|---|
| List exams | Implemented, but globally scoped | `exams.controller.ts:32-48`, `exams.service.ts:46-66` |
| List drafts | Implemented, but globally scoped | `exams.controller.ts:50-66`, `exam-drafts.controller.ts:23-39`, `exams.service.ts:68-88` |
| Get draft | Implemented, but no course access check | `exams.controller.ts:68-72`, `exam-drafts.controller.ts:41-45`, `exams.service.ts:90-101` |
| Generate preview/draft | Implemented | `exams.controller.ts:74-82`, `exams.service.ts:103-239` |
| Rule filters | Implemented | `generate-exam.dto.ts:19-50`, `exams.service.ts:130-152` |
| Approved questions only during generation | Implemented | `exams.service.ts:135-137` |
| Update draft item | Implemented, but unsafe | `exams.controller.ts:84-92`, `exams.service.ts:241-269` |
| Save draft to final exam | Implemented, but unsafe | `exams.controller.ts:94-101`, `exams.service.ts:271-311` |
| Export Word | Implemented as base64 HTML `.doc` | `exams.controller.ts:109-113`, `exams.service.ts:324-345` |
| Total marks distribution | Missing | Only `weightPerQuestion` and summed `totalWeight` exist |
| Exam sections | Missing | No draft/final section entities or endpoints |
| Manual draft add/remove/reorder | Missing | Only replacement/update exists |
| Draft expiration enforcement | Missing | `expiresAt` is set but never checked |
| Publish/archive lifecycle endpoints | Missing | `Exam.status` exists, but no state-changing endpoints |

## 4. Database State Summary

### 4.1 Tables Created By The Feature Migration

The migration `src/database/migrations/1778000000000-CreateQuestionBankAndExams.ts` creates these tables:

| Table | Purpose | Evidence |
|---|---|---|
| `course_chapters` | Course-level chapter structure | Migration lines 7-20 |
| `question_bank_questions` | Main question bank records | Migration lines 22-43 |
| `question_bank_options` | MCQ and true/false options | Migration lines 45-55 |
| `question_bank_fill_blanks` | Fill blank acceptable answers | Migration lines 57-66 |
| `exam_drafts` | Generated exam drafts | Migration lines 68-81 |
| `exam_draft_items` | Draft item rows | Migration lines 83-97 |
| `exams` | Saved final exam header | Migration lines 99-112 |
| `exam_items` | Saved final exam item rows | Migration lines 114-123 |

### 4.2 Live Aiven Database Re-Check

After the user provided DBeaver screenshots, I re-checked the database target from `.env` and confirmed the backend points to the deployed Aiven database:

| Config key | Observed value |
|---|---|
| `DB_HOST` | `eduverse-db-awab-first-project.g.aivencloud.com` |
| `DB_PORT` | `15868` |
| `DB_USERNAME` | `avnadmin` |
| `DB_DATABASE` | `eduverse_db` |
| `DB_SSL_CA_PATH` | `ca.pem` |

Credentials were not copied into this report.

Direct metadata queries against the live Aiven `eduverse_db` confirm the base feature tables exist. Current row counts at the time of re-check:

| Live table | Actual count | Meaning |
|---|---:|---|
| `course_chapters` | 2 | Chapter records used by question bank questions |
| `question_bank_questions` | 55 | Bank questions exist |
| `question_bank_options` | 109 | MCQ/true-false option rows exist |
| `question_bank_fill_blanks` | 11 | Fill-blank answer rows exist |
| `exam_drafts` | 16 | Generated drafts exist |
| `exam_draft_items` | 100 | Draft item rows exist |
| `exams` | 4 | Saved exams exist |
| `exam_items` | 60 | Saved exam item rows exist |
| `exam_schedules` | 1 | Existing schedule-module exam schedule table, separate from generated exam content |
| `quiz_questions` | 127 | Existing quiz-module question table, separate from question bank |

Status distribution:

| Table | Status | Count |
|---|---|---:|
| `question_bank_questions` | `approved` | 50 |
| `question_bank_questions` | `draft` | 5 |
| `exams` | `draft` | 4 |

Conclusion:

The deployed Aiven database does have the base tables for the two investigated features. The original report statement that could be read as "there are no tables for the two features" was incomplete and misleading. The accurate finding is:

1. The live deployed database has the base tables.
2. The source of truth for future database changes should be migration scripts in `src/database/migrations`, not manual edits to dump/reference files.
3. Several required enhancement tables/columns are still missing, such as attachments, captions, question groups, versions, exam item snapshots, total marks, item marks, and draft finalization state.

### 4.3 Live Schema Constraint Findings

The live schema is mostly aligned with `1778000000000-CreateQuestionBankAndExams.ts`, but it confirms the same modeling gaps found in code:

| Area | Live schema finding | Impact |
|---|---|---|
| Question images | `question_bank_questions` has one nullable `question_file_id` only | Multiple images and per-image captions cannot be represented |
| Question captions | No `caption`, `alt_text`, or attachment metadata columns/tables were found | The requested caption feature is missing |
| Related questions | No question group table was found | Batch related/multipart questions cannot be represented |
| Question versions | No version table was found | Saved exams still depend on mutable question rows |
| Exam scoring | `exams` has `total_weight`; `exam_items` has `weight`; no `total_marks` or `marks` columns | Total-grade-driven distribution is missing |
| Draft lifecycle | `exam_drafts` has `expires_at`; no `status`, `finalized_exam_id`, or `finalized_at` | Expiration/finalization cannot be enforced cleanly |
| Draft item order | `exam_draft_items` has non-unique index `IDX_exam_draft_items_draft_order` | Duplicate orders are possible |
| Exam item order | `exam_items` has no unique `(exam_id, item_order)` constraint | Duplicate final exam orders are possible |
| Option order | `question_bank_options` has non-unique `(question_id, option_order)` index | Duplicate option order is possible |
| Fill blank keys | `question_bank_fill_blanks` has no unique `(question_id, blank_key)` constraint | Duplicate blank keys are possible |

### 4.4 Live Data Integrity Check

Read-only aggregate checks against Aiven found:

| Check | Count | Interpretation |
|---|---:|---|
| Duplicate option orders | 0 | Current data is clean for adding a future unique `(question_id, option_order)` constraint. |
| Duplicate fill-blank keys | 0 | Current data is clean for adding a future unique `(question_id, blank_key)` constraint. |
| Duplicate draft item orders | 0 | Current data is clean for adding a future unique `(draft_id, item_order)` constraint. |
| Duplicate draft questions | 0 | Current data is clean for adding a future unique `(draft_id, question_id)` constraint if duplicate questions should remain forbidden. |
| Duplicate exam item orders | 0 | Current data is clean for adding a future unique `(exam_id, item_order)` constraint. |
| Duplicate exam questions | 0 | Current data is clean for adding a future unique `(exam_id, question_id)` constraint if duplicate final questions should remain forbidden. |
| Expired drafts | 16 | All current drafts are expired by `expires_at`, but the backend still allows read/update/save because expiration is not enforced. |
| Drafts without items | 9 | There are saved draft headers without item rows, proving the missing transaction/failed-generation cleanup risk is real in live data. |
| Exams without items | 0 | Current saved exams have items. |
| Exam total weight mismatch | 0 | Current saved exams have `total_weight` matching summed item weights. |

Why this matters:

1. The live data supports adding the recommended uniqueness constraints after a migration review.
2. The expired draft count confirms draft expiration is currently only stored, not operationally enforced.
3. Empty drafts confirm partial/failed generation states already exist and need cleanup or explicit draft statuses.
4. Before adding constraints or cleanup migrations, write migrations that check/clean data first, then add constraints.

### 4.5 Required Database Change Method

Do not edit `eduverse_db.sql` or `tables.txt` for this feature work. Those files are not the deployment mechanism for Aiven schema changes.

The project method should be:

1. Create a new TypeORM migration file under `src/database/migrations`.
2. Put every schema change for these features in that migration: new tables, new columns, indexes, foreign keys, and backfill SQL.
3. Review the migration against the live Aiven schema before applying it.
4. Apply the migration to the deployed Aiven database with the existing migration command, for example `npm run migration:run`.
5. Keep `synchronize` disabled in production. Schema drift should be handled by explicit migrations only.

Why this matters:

1. The live deployed database is the operational database.
2. Manual changes through DBeaver are easy to forget and hard to reproduce.
3. Dump-file edits do not change Aiven and can create confusion.
4. Migration files provide reviewable, repeatable, version-controlled database changes.
5. Rollback planning can be handled with the migration `down` method when practical.

Migration tasks needed for the requested feature hardening:

1. Add question attachment tables for multiple images, captions, alt text, and display order.
2. Add question group tables for related/batch questions.
3. Add total marks and item marks columns for exam scoring.
4. Add draft lifecycle/finalization columns.
5. Add snapshot/version tables so saved exams do not depend on mutable question rows.
6. Add unique constraints and indexes after checking/cleaning existing Aiven data.

## 5. Line-Level Question Bank Investigation

### 5.1 Controller Layer

| Lines | Finding | Why it matters |
|---|---|---|
| `question-bank.controller.ts:48-49` | Uses JWT and role guards for the whole controller. | Good baseline authentication, but roles alone are not enough for course resources. |
| `question-bank.controller.ts:53-88` | Chapter endpoints accept `courseId` but do not pass the user to the service. | The service cannot verify that the instructor owns or teaches that course. |
| `question-bank.controller.ts:62-63` | Chapter list currently allows `STUDENT` and should not. | Product rule is instructor-only for now; students, TAs, and admins should not use this feature surface. |
| `question-bank.controller.ts:90-97` | Create question accepts one DTO and creates one question. | No batch creation and no related-question grouping. |
| `question-bank.controller.ts:99-101` | Upload image uses `FileInterceptor('image')`. | This supports exactly one image per request, not multiple images. |
| `question-bank.controller.ts:105` | Swagger description says returned `fileId` should be used as `questionFileId`. | Confirms the design is one image/file reference per question. |
| `question-bank.controller.ts:108-119` | Upload body has only one `image` field. | No caption, alt text, order, or attachment metadata can be submitted. |
| `question-bank.controller.ts:132-138` | Question list currently allows `STUDENT`, `TA`, and `ADMIN`. | For the current product scope, only `INSTRUCTOR` should be allowed, and only for owned/taught courses. |
| `question-bank.controller.ts:140-146` | Question get currently allows `STUDENT`, `TA`, and `ADMIN`. | Direct ID access has no instructor-course ownership check and returns answer-related fields. |
| `question-bank.controller.ts:148-165` | Update/delete endpoints allow `TA` and `ADMIN` and do not pass course context. | For now only instructors should edit/delete, and the service must verify the question belongs to a course they teach. |

### 5.2 DTO Layer

| Lines | Finding | Why it matters |
|---|---|---|
| `question.dto.ts:51-115` | Create DTO represents one question only. | Missing batch creation and missing parent/group model. |
| `question.dto.ts:74-83` | Supports `questionText` or one `questionFileId`. | Cannot store multiple images/files for one question. |
| `question.dto.ts:85-93` | Stores expected answer and hints in the same entity contract. | Acceptable for instructor-only authoring, but dangerous if any non-instructor role remains allowed. |
| `question.dto.ts:100-106` | `options` accepts option text and correctness. | Correct flags are answer-key data and are safe only behind instructor-only access. |
| `question.dto.ts:108-114` | `fillBlanks` accepts acceptable answers. | Acceptable answers are answer-key data and are safe only behind instructor-only access. |
| `question.dto.ts:180-226` | Query DTO has `limit` with `@Min(1)` but no `@Max`. | Clients can request very large limits, causing heavy queries. |
| `question.dto.ts:180-226` | Query DTO has no instructor/course ownership context. | Controller/service should pass authenticated instructor context instead of exposing a role-neutral list. |
| `question.dto.ts:52-60` | `courseId` and `chapterId` are integers but have no `@Min(1)`. | Zero/negative IDs can reach service or database and cause inconsistent 400/404/DB errors. |
| `question.dto.ts:117-178` | Update DTO allows `chapterId` without `@Min(1)`. | A bad ID can skip business checks or produce raw database errors. |

### 5.3 Service Layer

| Lines | Finding | Why it matters |
|---|---|---|
| `question-bank.service.ts:54-69` | Constructor throws if Supabase config is missing. | Because `QuestionBankModule` is imported by `AppModule`, missing Supabase env can prevent the entire backend from starting, even if question image upload is not used. |
| `question-bank.service.ts:74-114` | Chapter CRUD only checks existence. | No course access control, no duplicate handling, no in-use check before delete. |
| `question-bank.service.ts:116-148` | Upload writes to both local file storage and Supabase. | Dual-write without rollback can leave DB/local file records without Supabase image, or Supabase object without usable metadata. |
| `question-bank.service.ts:120` | Validates image before upload. | Good, but validation is only MIME-based here and extension-based later in file service. |
| `question-bank.service.ts:123` | Calls `filesService.uploadFile(file, userId)`. | This creates a normal `files` row, but no course/question context is stored. |
| `question-bank.service.ts:124-134` | Uploads again to Supabase under `question-bank/files/{fileId}.{extension}`. | The DB `files.file_path` points to local storage, while question display URLs are derived from Supabase convention. These can drift. |
| `question-bank.service.ts:136-140` | Supabase failure after local upload throws an error. | The already-created local file/DB row is not compensated or deleted. |
| `question-bank.service.ts:150-179` | Question create saves parent, then child options/blanks. | Missing transaction. Parent can remain without required children if child save fails. |
| `question-bank.service.ts:154-158` | Validates course/chapter/file existence only. | No check that the caller can modify this course or that the file belongs to the caller/course/context. |
| `question-bank.service.ts:161-174` | Creates one question row. | No group ID, no batch metadata, no question version, no tags/outcomes. |
| `question-bank.service.ts:176-178` | Saves question then replaces children. | Same transaction gap. |
| `question-bank.service.ts:181-218` | Lists questions with options, blanks, chapter, file. | Returns full entities including sensitive child rows. |
| `question-bank.service.ts:193-210` | Status filter is optional. | This is fine for instructor authoring, but only after controller/service access is restricted to the owning instructor. |
| `question-bank.service.ts:212-214` | Uses raw `limit` from query. | No server-side clamp in question bank list. |
| `question-bank.service.ts:220-230` | Finds question by ID only. | No instructor ownership/course scope check, so ID-based access can cross course boundaries. |
| `question-bank.service.ts:237` | Update starts by fetching full question entity. | It loads children and then later spreads them into the merged payload, causing patch bugs. |
| `question-bank.service.ts:241-243` | Only validates file if `dto.questionFileId` is truthy. | Clearing a file to null is allowed, but invalid values like zero can behave inconsistently. Add stricter DTO validation. |
| `question-bank.service.ts:245-262` | Builds `merged` by spreading the loaded entity and patch DTO. | Existing `options` and `fillBlanks` relations become part of the merged DTO even when the patch did not intend to update them. |
| `question-bank.service.ts:264` | Validates merged payload. | Validation can pass because stale children from the database satisfy the type rules, hiding invalid patch intent. |
| `question-bank.service.ts:265-287` | Updates parent, then replaces children. | Missing transaction and high risk of unintended child rewrites. |
| `question-bank.service.ts:291-294` | Deletes question with hard remove. | If the question is used by exam items, the database restricts deletion. If not used, deletion removes history instead of archiving. |
| `question-bank.service.ts:296-330` | `replaceQuestionChildren` deletes and recreates children. | This loses child IDs, does not preserve audit history, and can reorder or duplicate data under concurrency. |
| `question-bank.service.ts:301` | Replaces options if `patch.options !== undefined` OR `source.options !== undefined`. | Since `source` is merged from a loaded entity, `source.options` is usually defined. A patch to title/status can rewrite all options accidentally. |
| `question-bank.service.ts:316` | Same bug for fill blanks. | A patch unrelated to fill blanks can delete/recreate blanks. |
| `question-bank.service.ts:332-393` | Validates required child payload by question type. | Good baseline, but it does not reject incompatible extra fields. Example: essay can still keep MCQ options. |
| `question-bank.service.ts:343-357` | MCQ requires at least one correct answer. | If only single-answer MCQ is intended, multiple correct answers should be rejected or a separate multi-select type should be added. |
| `question-bank.service.ts:359-373` | True/False requires two options and exactly one correct. | It does not enforce canonical option values/order or prevent duplicate option text. |
| `question-bank.service.ts:375-381` | Fill blanks require at least one blank. | It does not enforce unique `blankKey` per question. |
| `question-bank.service.ts:383-392` | Written/essay requires expected answer. | Good for instructor bank quality, but reinforces why this API must remain instructor-only. |
| `question-bank.service.ts:414-419` | `ensureFileExists` only checks file ID existence. | It does not check uploader, file status, deleted state, MIME type, image context, or course ownership. |
| `question-bank.service.ts:433-438` | Allows `image/webp`. | Default `FilesService` extension allow-list does not include `webp`, so webp can pass first validation and fail later. |
| `question-bank.service.ts:461-497` | Adds `questionImageUrl` via `(question as any)`. | Response shape is dynamic and undocumented by DTO. This weakens API typing and Swagger accuracy. |
| `question-bank.service.ts:506` | Listing signed URLs calls bucket readiness. | A Supabase bucket check failure can break read paths for questions with images. |
| `question-bank.service.ts:519-522` | Signed URLs are generated per response. | This can become expensive for large lists and repeated frontend refreshes. |

### 5.4 Entity And Database Model

| Lines | Finding | Why it matters |
|---|---|---|
| `question-bank-question.entity.ts:50-51` | One nullable `questionFileId` on question. | This is the core reason multiple images cannot be represented. |
| `question-bank-question.entity.ts:53-57` | Expected answer and hints live on main question row. | Convenient for instructors, unsafe if non-instructor roles can call these endpoints. |
| `question-bank-question.entity.ts:79-89` | Question cascades with course/chapter and sets file null on delete. | Course/chapter deletion can collide with exam item `RESTRICT` references or lose question bank records. |
| `question-bank-option.entity.ts:24-25` | `isCorrect` stored directly on option. | Must stay behind instructor-only access. |
| `question-bank-option.entity.ts:13` | Non-unique index on `questionId,itemOrder`. | Duplicate option orders are allowed. |
| `question-bank-fill-blank.entity.ts:19-23` | Blank key and answer stored without uniqueness. | Duplicate blank keys can create ambiguous grading/export behavior. |
| `course-chapter.entity.ts:15-16` | Unique chapter order/name per course. | Good, but service does not catch duplicate-key errors and return clean 409 responses. |
| Migration lines 22-43 | `question_bank_questions` has no `deleted_at`, version, approval metadata, group ID, or source metadata. | Missing production lifecycle and audit support. |
| Migration lines 45-66 | Options/blanks have no timestamps. | Child answer changes are not auditable. |
| Migration lines 39-40 | Useful generation indexes exist for course/chapter/type/difficulty/Bloom/status. | Good for rule-based generation. |

## 6. Line-Level Exam Generator Investigation

### 6.1 Controller Layer

| Lines | Finding | Why it matters |
|---|---|---|
| `exams.controller.ts:27-28` | Uses JWT and role guards. | Good baseline, but no course access guard. |
| `exams.controller.ts:32-39` | Exam list currently allows `STUDENT`, `TA`, and `ADMIN`. | Product rule is instructor-only for now; list must also be scoped to courses the instructor teaches. |
| `exams.controller.ts:41-48` | Duplicate `/list` endpoint calls same service. | API duplication increases maintenance and documentation confusion. |
| `exams.controller.ts:50-66` | Draft list endpoints are duplicated. | Same duplication issue, plus no course/user scoping. |
| `exams.controller.ts:68-72` | Draft get by ID only. | Any currently allowed non-instructor role, or an instructor from another course, can fetch by ID unless ownership is checked. |
| `exams.controller.ts:74-82` | `try/catch` rethrows the same error. | Redundant; real error handling is in service and currently problematic. |
| `exams.controller.ts:84-92` | Update draft item does not pass `req.user`. | Service cannot enforce who owns/teaches the draft course. |
| `exams.controller.ts:94-101` | Save draft passes user ID only. | Service still does not verify draft course authorization. |
| `exams.controller.ts:103-107` | Exam get currently allows `STUDENT`, `TA`, and `ADMIN`. | The response includes question records and should be instructor-only and course-owned. |
| `exams.controller.ts:109-113` | Export Word currently allows `TA` and `ADMIN`. | For now export should be instructor-only and course-owned. |
| `exam-drafts.controller.ts:19-45` | Separate `/api/exam-drafts` controller duplicates draft read routes. | Two route surfaces for same behavior make authorization fixes easy to miss. |

### 6.2 DTO Layer

| Lines | Finding | Why it matters |
|---|---|---|
| `generate-exam.dto.ts:19-50` | Rule supports chapter, count, weight, type, difficulty, Bloom. | Good minimal blueprint input. |
| `generate-exam.dto.ts:31-34` | `weightPerQuestion` allows zero. | Zero-weight questions may be intentional in practice exams, but for real exams this should be a business rule, not default behavior. |
| `generate-exam.dto.ts:52-73` | Generate DTO has no `totalMarks`. | Cannot satisfy the requested "exam total grade plus per-question weight and auto-calculated question marks" requirement. |
| `generate-exam.dto.ts:63-67` | `rules` has no `ArrayMinSize(1)`. | Empty rules are caught in service, but DTO validation should reject bad input earlier and consistently. |
| `generate-exam.dto.ts:75-94` | Draft item update allows replacement, weight, order. | Missing validation for replacement constraints, duplicate order, and duplicate question. |
| `generate-exam.dto.ts:82-86` | Draft update weight allows zero. | Same business-rule gap. |

### 6.3 Service Layer

| Lines | Finding | Why it matters |
|---|---|---|
| `exams.service.ts:46-66` | `findExams` returns all exams, paginated only. | No instructor ownership/course filter, so instructors can see exams outside their courses. |
| `exams.service.ts:68-88` | `findDrafts` returns all drafts. | No generated-by/course scope. Drafts can expose generation strategy and private course content. |
| `exams.service.ts:90-101` | `findDraftById` uses ID only and loads items. | No course authorization or expiration enforcement. |
| `exams.service.ts:103-104` | Generation checks course existence. | Good baseline, but existence is not authorization. |
| `exams.service.ts:105-239` | Most generation logic is wrapped in catch-all. | It converts structured errors into weaker BadRequest errors and logs directly to console. |
| `exams.service.ts:106-108` | Empty rule check is in service. | Should be moved to DTO with `ArrayMinSize(1)` and kept in service as defense. |
| `exams.service.ts:120-128` | Checks chapter belongs to course per rule. | Good correctness check, but repeated per rule and not preloaded. |
| `exams.service.ts:130-152` | Candidate query filters by course, chapter, approved status, type, difficulty, Bloom. | Good generator core. |
| `exams.service.ts:152-155` | Converts raw IDs and removes already selected IDs in memory. | Fine for small pools, but can scale poorly for large courses/rules. |
| `exams.service.ts:157-167` | Shortages are collected per rule. | Good intent, but shortage details are lost by the catch block later. |
| `exams.service.ts:169-173` | Uses deterministic shuffle by seed and chapter. | Useful for reproducibility, but should include rule identity if same chapter has multiple rule buckets. |
| `exams.service.ts:192-201` | Saves draft before saving draft items. | Missing transaction. Draft can exist with missing/incomplete items. |
| `exams.service.ts:199` | Sets `expiresAt` to 24 hours. | Expiration is never enforced anywhere else. |
| `exams.service.ts:203-208` | Loads selected questions by ID after draft creation. | Race condition: a question can change status/delete between selection and draft item creation. |
| `exams.service.ts:216-218` | Uses `questionMap.get(... )!`. | Non-null assertion can crash if a selected question is missing under race conditions. |
| `exams.service.ts:225-234` | Returns draft item records and total weight. | Does not return full preview question content or normalized marks. |
| `exams.service.ts:235-238` | Catch-all logs to console and throws `BadRequestException(e.message)`. | Loses `shortages` object and changes some error semantics. Use Nest logger and preserve known HTTP exceptions. |
| `exams.service.ts:241-269` | Updates draft item without loading draft. | Cannot check draft expiration, ownership, course, or finalized state. |
| `exams.service.ts:253-265` | Replacement question is fetched by ID only. | Can replace with a question from another course, with draft/archived status, or with incompatible type/rule. |
| `exams.service.ts:260-264` | Replacement copies metadata from question. | Good, but no validation that this replacement still satisfies the original blueprint. |
| `exams.service.ts:266-268` | Weight/order updates are direct saves. | No duplicate order check, no transaction, no optimistic lock. |
| `exams.service.ts:271-311` | Saves draft to exam. | No expiration check, no finalized state check, no idempotency, no transaction. |
| `exams.service.ts:280-283` | Computes `totalWeight` from item weights. | This is not the same as total exam marks. |
| `exams.service.ts:284-297` | Saves exam header first. | Missing transaction. An exam can exist without all items if item save fails. |
| `exams.service.ts:291-295` | `snapshotJson` stores only draft ID, seed, generated time. | It does not snapshot actual question text/options/answers at save time. |
| `exams.service.ts:299-308` | Saves exam items referencing question IDs. | Final exam content changes if question bank questions are edited later. |
| `exams.service.ts:313-322` | Finds exam by ID and loads `items.question`. | If any non-instructor role remains allowed, answer data can leak; even instructor access needs course ownership checks. |
| `exams.service.ts:324-345` | Word export builds HTML string directly. | No escaping/sanitization, no real DOCX, no images/captions/options/sections, and potential HTML injection. |
| `exams.service.ts:371-382` | Pagination clamp exists in exam service. | Good practice; question bank should use the same pattern. |

### 6.4 Entity And Database Model

| Lines | Finding | Why it matters |
|---|---|---|
| `exam.entity.ts:26-27` | Stores `totalWeight`, not `totalMarks`. | Cannot represent exam grade independently from selection weights. |
| `exam.entity.ts:29-30` | Status supports draft/published/archived. | Model exists, but no lifecycle endpoints or state machine. |
| `exam.entity.ts:32-33` | `snapshotJson` exists. | Good idea, but current service stores metadata only, not question content snapshots. |
| `exam-item.entity.ts:20-27` | Exam item stores only question ID, weight, order. | No item marks, no section, no snapshot content, no selected version. |
| `exam-item.entity.ts:33-35` | Question FK uses `RESTRICT`. | Prevents deletion of used questions, but no friendly in-use handling. |
| `exam-draft.entity.ts:35-36` | Draft expiration field exists. | Missing enforcement and cleanup. |
| `exam-draft.entity.ts:48-49` | Draft has item cascade. | Good for deleting drafts, but finalization should still be transactional. |
| `exam-draft-item.entity.ts:15` | Index on draft/order is not unique. | Duplicate item orders are allowed. |
| `exam-draft-item.entity.ts:23-42` | Draft item stores metadata copied from question. | Useful for filtering, but replacement can break original rule semantics. |
| Migration lines 83-97 | Draft items have no unique order or unique question per draft. | Duplicate orders/questions can exist. |
| Migration lines 114-123 | Exam items have no index or unique constraint. | Listing by exam/order and protecting duplicate orders will be weaker. |

## 7. Detailed Findings And Fixes

Severity meanings:

| Severity | Meaning |
|---|---|
| Critical | Security/data leak/cross-course access/data corruption risk |
| High | Major correctness, stability, or missing core requirement |
| Medium | Functional gap, maintainability issue, or weak operational behavior |
| Low | Quality, documentation, or polish issue |

### 7.1 Question Bank Findings

#### QB-01 - Critical - Question Bank Is Not Instructor-Only

Evidence:

1. `STUDENT` is allowed on list questions: `question-bank.controller.ts:132-133`.
2. `STUDENT` is allowed on get question: `question-bank.controller.ts:140-141`.
3. `TA` and `ADMIN` are also allowed on question create/upload/update/delete/list/get paths in this controller.
4. List loads options and fill blanks: `question-bank.service.ts:186-191`.
5. Question entity includes `expectedAnswerText` and `hints`: `question-bank-question.entity.ts:53-57`.
6. Option entity includes `isCorrect`: `question-bank-option.entity.ts:24-25`.
7. Fill blank entity includes `acceptableAnswer`: `question-bank-fill-blank.entity.ts:22-23`.

Risk:

The intended current scope is instructor-only authoring. Allowing students, TAs, or admins into this feature surface creates unnecessary exposure of answer-key data and makes the permission model unclear. Even if admins can manage the platform elsewhere, this specific feature should be limited to instructors for now.

Fix:

1. Change all question bank `@Roles(...)` decorators to `@Roles(RoleName.INSTRUCTOR)` only.
2. Keep all question bank responses as instructor-authoring responses; do not add any non-instructor response surface now.
3. Pass `req.user.userId` into list/get/chapter/update/delete paths and verify the instructor owns or teaches the course before returning data.
4. Add tests proving `STUDENT`, `TA`, and `ADMIN` receive 403 for every question bank endpoint.
5. Add tests proving an instructor cannot access a question/chapter from another instructor's course.

#### QB-02 - Critical - No Instructor Course Ownership Authorization

Evidence:

1. `RolesGuard` only checks user role names: `roles.guard.ts:9-28`.
2. Question bank create/update/delete/list/get methods do not receive enough user/course access context.
3. Service checks course existence only: `question-bank.service.ts:395-400`.
4. Existing database has course assignment tables that can support instructor ownership checks:
   - `course_instructors` in `course-instructor.entity.ts`.
   - `course_sections.courseId` in `course-section.entity.ts:31-37`.

Risk:

Any user with the instructor role can create/update/delete/list/get questions for any course ID if they know or guess it. This is still a critical issue even after removing students, TAs, and admins from the decorators.

Fix:

1. Add an `InstructorCourseAccessService` or guard that checks the authenticated instructor is assigned to a section whose `courseId` matches the target course.
2. Pass `req.user` into all question bank service methods.
3. Never rely on role-only authorization for course-scoped resources.
4. Add integration tests for cross-course denial.
5. Keep all non-instructor role access out of this feature until a future product decision explicitly changes the scope.

Ownership source of truth for these two features:

1. Use only `course_instructors -> course_sections -> course_id`.
2. Do not authorize question bank or exam generator access from legacy `courses.instructor_id`.
3. If a real instructor is currently stored only in `courses.instructor_id`, migrate or assign them into `course_instructors` before enabling strict ownership.

#### QB-03 - High - Multiple Images Per Question Are Not Supported

Evidence:

1. Upload endpoint uses `FileInterceptor('image')`: `question-bank.controller.ts:101`.
2. Request body accepts one `image`: `question-bank.controller.ts:108-119`.
3. Create DTO has one `questionFileId`: `question.dto.ts:79-83`.
4. Entity has one `questionFileId`: `question-bank-question.entity.ts:50-51`.
5. Migration has one `question_file_id`: `CreateQuestionBankAndExams.ts:30-31`.

Risk:

The requested feature "one question can have multiple images" cannot be implemented with the current data model. Trying to overload `questionText` or reuse files manually will create fragile frontend/backend behavior.

Fix:

Add a new table:

```sql
question_bank_question_attachments
- attachment_id bigint primary key
- question_id bigint not null
- file_id bigint not null
- attachment_type enum('image','document','audio','video') default 'image'
- caption varchar(500) null
- alt_text varchar(500) null
- display_order int unsigned not null default 0
- is_primary tinyint not null default 0
- created_by bigint not null
- created_at datetime not null
- updated_at datetime not null
- deleted_at datetime null
- unique(question_id, display_order)
- foreign key question_id -> question_bank_questions(question_id)
- foreign key file_id -> files(file_id)
```

API changes:

1. `POST /api/question-bank/questions/:id/attachments` with `FilesInterceptor('images', maxCount)`.
2. `PATCH /api/question-bank/questions/:id/attachments/reorder`.
3. `DELETE /api/question-bank/questions/:id/attachments/:attachmentId`.
4. Keep `questionFileId` temporarily for backward compatibility, but migrate it into attachments.

#### QB-04 - High - Image Captions And Alt Text Are Missing

Evidence:

1. Upload DTO/body has only binary image.
2. Question DTO has no caption field.
3. Entity/migration has no caption field.

Risk:

Instructors cannot describe figures, diagrams, or image context. Generated exams and exports cannot render captions. Accessibility is also weaker because no alt text exists.

Fix:

Store `caption` and `altText` per attachment, not directly on the question. One question can have several images, and each image needs its own caption/order.

#### QB-05 - High - Plain Bulk Create And Batch Related Questions Are Missing

Evidence:

1. Only single create endpoint exists: `question-bank.controller.ts:90-97`.
2. Create DTO models one question: `question.dto.ts:51-115`.
3. No group table exists in migration.
4. No plain bulk endpoint exists for creating many unrelated questions in one request.

Risk:

The system cannot efficiently support instructors who need to add many questions at once. It also cannot represent multipart questions such as one passage/image/case study with several related sub-questions. If batch behavior is implemented only on the frontend, the backend still performs many separate writes, partial failure handling is weak, and related-question relationships are lost.

Fix:

Add plain bulk create first:

```http
POST /api/question-bank/questions/batch
```

Rules:

1. Instructor-only and course-owned.
2. Request-level `courseId`.
3. `questions` array with an explicit max batch size, for example 50 initially.
4. Every item uses the same type-specific validation as single create.
5. One database transaction for the whole request.
6. If one item fails, no question/options/fill-blanks/attachments are saved.
7. Validation errors should identify item index, for example `questions[4].options`.

Then add related-question grouping:

Add:

```sql
question_bank_question_groups
- group_id bigint primary key
- course_id bigint not null
- chapter_id bigint not null
- title varchar(255) null
- shared_prompt text null
- shared_file_id bigint null
- group_type enum('passage','case_study','image_set','multipart','other')
- created_by bigint not null
- created_at datetime not null
- updated_at datetime not null
- deleted_at datetime null
```

Then either:

1. Add `group_id` and `group_order` to `question_bank_questions`, or
2. Add `question_bank_question_group_items(group_id, question_id, item_order)`.

API:

1. `POST /api/question-bank/questions/batch`
2. `POST /api/question-bank/groups`
3. `POST /api/question-bank/groups/:groupId/questions/batch`
4. `PATCH /api/question-bank/groups/:groupId/questions/reorder`
5. Exam generator option: keep grouped questions together, exclude grouped questions, or allow independent selection.

#### QB-06 - High - Question Create/Update Is Not Transactional

Evidence:

1. Create saves parent: `question-bank.service.ts:176`.
2. Create then saves children separately: `question-bank.service.ts:177`.
3. Update saves parent: `question-bank.service.ts:265-286`.
4. Update then replaces children separately: `question-bank.service.ts:287`.

Risk:

If parent save succeeds and child save fails, the database can contain an invalid MCQ without options, a fill blank without blanks, or a partially updated question.

Fix:

Use TypeORM transaction for parent and child writes:

1. Validate DTO first.
2. Start transaction.
3. Save parent.
4. Insert/delete children.
5. Commit.
6. Rollback on failure.

Also add database constraints where possible:

1. Unique `(question_id, option_order)`.
2. Unique `(question_id, blank_key)`.
3. Application-level child count validation because SQL cannot easily enforce "MCQ has at least two options".

#### QB-07 - High - Patch Updates Can Accidentally Delete/Recreate Child Rows

Evidence:

1. Update loads question with relations: `question-bank.service.ts:237`.
2. `merged` spreads the loaded entity: `question-bank.service.ts:245-262`.
3. `replaceQuestionChildren` runs if `source.options !== undefined`: `question-bank.service.ts:301`.
4. Same for `fillBlanks`: `question-bank.service.ts:316`.

Risk:

A patch that only changes status, difficulty, or question text can still delete and recreate existing options/blanks because the merged entity includes loaded child arrays. This can change child IDs, lose history, cause race issues, and produce unexpected order changes.

Fix:

1. In update, only replace `options` when `dto.options !== undefined`.
2. Only replace `fillBlanks` when `dto.fillBlanks !== undefined`.
3. If `questionType` changes, explicitly clear incompatible child tables in a controlled transaction.
4. Add tests:
   - Patch status does not touch options.
   - Patch text does not touch blanks.
   - Switching MCQ to essay removes options.

#### QB-08 - High - Type Switching Can Leave Stale Incompatible Children

Evidence:

1. Validation requires fields for the target type but does not reject extra fields: `question-bank.service.ts:332-393`.
2. Existing child rows can be preserved through the merged payload: `question-bank.service.ts:245-262`.

Risk:

An essay question can still have MCQ options in the database. A written question can keep fill blanks. This confuses exam rendering, grading, exports, and analytics.

Fix:

1. Add strict type normalization:
   - MCQ/true_false: allow options, reject fillBlanks.
   - Fill_blanks: allow fillBlanks, reject options.
   - Written/essay: reject options and fillBlanks.
2. On type change, clear incompatible children inside the same transaction.
3. Add check constraints through application tests because MySQL table-level conditional constraints are limited.

#### QB-09 - High - Image Upload Has Dual-Write Consistency Risk

Evidence:

1. Local/DB file upload happens first: `question-bank.service.ts:123`.
2. Supabase upload happens next: `question-bank.service.ts:129-134`.
3. Supabase failure throws without cleanup: `question-bank.service.ts:136-140`.

Risk:

The database can record a file that the question bank expects to exist in Supabase, but the Supabase object may be missing. Later question list/get can show `questionImageUrl: null`.

Fix:

1. Choose one canonical storage backend for question images, or store both explicitly.
2. If keeping dual storage, add compensation:
   - Delete local file/DB row if Supabase upload fails.
   - Delete Supabase object if DB association fails.
3. Store actual Supabase path in the database instead of reconstructing it from file ID and MIME type.
4. Add an orphan cleanup job.

#### QB-10 - High - WebP Is Allowed By Question Validation But Not By Default File Storage

Evidence:

1. Question image validation allows `image/webp`: `question-bank.service.ts:433-438`.
2. Default allowed file extensions omit `webp`: `file-storage.service.ts:20-23`.
3. `FilesService.uploadFile` validates by extension: `files.service.ts:53-58`.

Risk:

A WebP image can pass question-bank validation and then fail inside file storage. The user sees inconsistent behavior.

Fix:

1. Add `webp` to default `ALLOWED_FILE_TYPES`.
2. Validate extension and MIME together in one shared helper.
3. Return one consistent error message.

#### QB-11 - Medium - No Clean Conflict Handling For Chapter Uniqueness

Evidence:

1. Chapter unique indexes exist: `course-chapter.entity.ts:15-16`.
2. Service directly saves create/update: `question-bank.service.ts:79-80`, `question-bank.service.ts:102-103`.

Risk:

Duplicate chapter order/name likely returns raw database errors instead of clean HTTP 409.

Fix:

Catch duplicate-key errors and return `ConflictException` with a clear message.

#### QB-12 - Medium - No Soft Delete Or In-Use Check For Questions/Chapters

Evidence:

1. Delete question uses `remove`: `question-bank.service.ts:291-294`.
2. Exam items reference question with `RESTRICT`: `exam-item.entity.ts:33-35`.
3. Chapter delete removes the chapter: `question-bank.service.ts:106-114`.

Risk:

Deleting a question or chapter used in exams can fail with database errors. Deleting unused questions loses history and audit context.

Fix:

1. Add `deleted_at` or use `status = archived` as the default delete behavior.
2. Before hard delete, check exam usage and return a clear 409 if used.
3. Keep hard delete only for controlled maintenance or never-used drafts.

#### QB-13 - Medium - Option And Blank Ordering Is Not Fully Deterministic

Evidence:

1. Options have an order index: `question-bank-option.entity.ts:27-28`.
2. Fill blanks do not have an order index.
3. `findQuestionById` loads relations without order: `question-bank.service.ts:220-224`.
4. List query joins children but orders only by question creation: `question-bank.service.ts:212-214`.

Risk:

Frontend display order can change depending on database result order. Fill blanks are especially ambiguous.

Fix:

1. Add explicit ordering when loading relations.
2. Add `blank_order`.
3. Add unique `(question_id, option_order)` and `(question_id, blank_order)`.

#### QB-14 - Medium - Approval Workflow Is Only A Status Field

Evidence:

1. Status enum exists: `question-bank.enums.ts:24-28`.
2. Create DTO can set status: `question.dto.ts:95-98`.
3. There are no approve/reject endpoints.

Risk:

Any creator with write access can potentially create approved questions. There is no reviewer, rejection reason, approval date, or audit trail.

Fix:

1. Default new questions to draft.
2. Add endpoints:
   - `POST /api/question-bank/questions/:id/submit-for-review`
   - `POST /api/question-bank/questions/:id/approve`
   - `POST /api/question-bank/questions/:id/reject`
   - `POST /api/question-bank/questions/:id/archive`
3. Add fields/table:
   - `reviewed_by`
   - `reviewed_at`
   - `review_status`
   - `review_comment`
   - `question_bank_review_events`

#### QB-15 - Medium - Tests Are Stale And Do Not Cover Critical Behavior

Evidence:

1. `QuestionBankService` constructor now requires `ConfigService`: `question-bank.service.ts:52`.
2. Test instantiations omit it: `question-bank.service.spec.ts:26-34`, `question-bank.service.spec.ts:55-63`, `question-bank.service.spec.ts:78-86`.
3. Upload test does not mock Supabase calls but service now calls Supabase in upload path.

Risk:

Tests likely fail or do not protect real behavior. Security and transaction risks are untested.

Fix:

1. Update mocks for `ConfigService` and Supabase.
2. Add tests for:
   - instructor-only role restrictions
   - instructor course ownership authorization
   - multi-image attachment creation
   - patch without child rewrite
   - type switch cleanup
   - duplicate chapter conflict
   - transaction rollback

### 7.2 Exam Generator Findings

#### EX-01 - Critical - Exam Generator Is Not Instructor-Only Or Course-Owned

Evidence:

1. `findExams` queries all exams: `exams.service.ts:46-66`.
2. `findDrafts` queries all drafts: `exams.service.ts:68-88`.
3. `findDraftById` uses draft ID only: `exams.service.ts:90-101`.
4. `findExamById` uses exam ID only: `exams.service.ts:313-322`.
5. Controllers do not pass `req.user` to read/list/update methods.
6. Controllers currently allow `STUDENT`, `TA`, and `ADMIN` on parts of the exam feature.

Risk:

The intended current scope is instructor-only exam authoring. Current decorators and service methods allow non-instructor roles into parts of the feature and allow instructors to access exams/drafts outside their own courses.

Fix:

1. Change all exam generator and exam draft `@Roles(...)` decorators to `@Roles(RoleName.INSTRUCTOR)` only.
2. Add instructor course ownership checks to every exam and draft service method.
3. Add `courseId` filters for list endpoints and require that the course is owned/taught by the authenticated instructor.
4. Pass `req.user.userId` into `findExams`, `findDrafts`, `findDraftById`, `updateDraftItem`, `saveDraft`, `findExamById`, and `exportExamAsWord`.
5. Add tests proving `STUDENT`, `TA`, and `ADMIN` receive 403 for every exam generator endpoint.

Ownership source of truth is the same as the question bank: use only `course_instructors -> course_sections -> course_id`. Do not authorize exam generator access from `courses.instructor_id`.

#### EX-02 - Critical - Non-Instructor Exam Access Can Leak Answers/Hints

Evidence:

1. `STUDENT`, `TA`, and `ADMIN` are currently allowed on some exam read/list/export routes.
2. Service loads `items.question`: `exams.service.ts:313-317`.
3. Question entity includes `expectedAnswerText` and `hints`: `question-bank-question.entity.ts:53-57`.

Risk:

Generated exams load live question bank rows that include answer-key data. Because this feature is instructor-only for now, the safest fix is not to design student-facing exam delivery here yet. Non-instructor roles should be denied completely.

Fix:

1. Remove `RoleName.STUDENT`, `RoleName.TA`, and `RoleName.ADMIN` from exam generator/read/export decorators.
2. Keep generated exam response DTOs instructor-only for now.
3. Add course ownership checks so one instructor cannot read another instructor's exam.
4. If a separate learner-facing delivery module is added later, implement it as a separate API surface with separate response DTOs.

#### EX-03 - High - Final Exams Do Not Snapshot Question Content

Evidence:

1. `saveDraft` stores only draft ID, seed, generated time in `snapshotJson`: `exams.service.ts:291-295`.
2. `exam_items` stores only `questionId`, `weight`, and `itemOrder`: `exam-item.entity.ts:20-27`.
3. Final exam reads live question rows: `exams.service.ts:313-317`.

Risk:

If an instructor edits a question after the exam is saved, the saved exam silently changes. If a question is archived/deleted, exam behavior may break or deletion is blocked. This is dangerous for academic records.

Fix:

At save time, store immutable item snapshots:

```sql
exam_item_snapshots
- snapshot_id bigint primary key
- exam_item_id bigint not null
- source_question_id bigint not null
- source_question_version_id bigint null
- question_type enum(...)
- question_text text null
- options_json json null
- fill_blanks_json json null
- expected_answer_text text null
- hints text null
- attachments_json json null
- created_at datetime not null
```

If a separate learner-facing delivery module is added in a future phase, omit answer fields from that future response. For the current project scope, generated exam read/export stays instructor-only.

#### EX-04 - High - Draft Save Is Not Transactional

Evidence:

1. Exam header saved first: `exams.service.ts:284-297`.
2. Exam items saved second: `exams.service.ts:299-308`.
3. Live Aiven aggregate check found 9 draft headers without draft items, which proves partial/empty draft states already exist.

Risk:

If item insertion fails, the database can contain an exam with no items or partial items. The live empty-draft data shows the system already needs explicit cleanup/status handling for incomplete generation states.

Fix:

Use a transaction for:

1. Reload draft with items.
2. Validate draft state and expiry.
3. Create exam.
4. Create exam items.
5. Create item snapshots.
6. Mark draft finalized.
7. Commit.

#### EX-05 - High - Saving Same Draft Multiple Times Creates Duplicate Exams

Evidence:

1. `saveDraft` does not update the draft after saving: `exams.service.ts:271-311`.
2. `exam_drafts` has no status/finalized field: `exam-draft.entity.ts:15-50`.

Risk:

Double-clicks, retries, or client timeouts can create duplicate final exams from the same draft.

Fix:

Add draft state:

```sql
ALTER TABLE exam_drafts
ADD COLUMN status enum('open','finalized','expired','cancelled') default 'open',
ADD COLUMN finalized_exam_id bigint null,
ADD COLUMN finalized_at datetime null,
ADD COLUMN finalized_by bigint null;
```

Then make save idempotent:

1. If draft is finalized, return the existing exam.
2. Use transaction and row lock.
3. Optional: support `Idempotency-Key` header.

#### EX-06 - High - Draft Expiration Is Not Enforced

Evidence:

1. Draft `expiresAt` is set on generation: `exams.service.ts:199`.
2. Draft entity stores it: `exam-draft.entity.ts:35-36`.
3. No service method checks whether `expiresAt < now`.
4. Live Aiven aggregate check found 16 expired drafts.

Risk:

Old drafts can be edited and saved even though the schema implies they should expire.

Fix:

1. Add `assertDraftOpenAndNotExpired(draft)` used by get/update/save.
2. Return 410 Gone or 409 Conflict for expired drafts.
3. Add scheduled cleanup job to mark old open drafts as expired.

#### EX-07 - High - Replacement Question Validation Is Unsafe

Evidence:

1. Replacement question is fetched by ID only: `exams.service.ts:253-256`.
2. Replacement can update item metadata directly: `exams.service.ts:260-264`.

Risk:

A draft item can be replaced by:

1. A question from another course.
2. A draft or archived question.
3. A duplicate question already in the same draft.
4. A question that violates the original blueprint rule.

Fix:

Validate replacement:

1. Same course as draft.
2. `status = approved`.
3. Not already used in draft.
4. Same type/difficulty/Bloom/chapter if the original rule requires strict replacement.
5. Caller has access to the course.

#### EX-08 - High - Shortage Details Are Lost During Error Handling

Evidence:

1. Shortage error includes structured `shortages`: `exams.service.ts:185-189`.
2. Catch block throws only `e.message`: `exams.service.ts:235-238`.

Risk:

Frontend cannot reliably show which chapter/type/difficulty/Bloom bucket is short. Debugging exam generation becomes harder.

Fix:

1. If `e` is an `HttpException`, rethrow it unchanged.
2. Only wrap unknown errors.
3. Replace `console.error` with Nest `Logger`.

#### EX-09 - High - Total Marks Requirement Is Missing

Evidence:

1. DTO has `weightPerQuestion` only: `generate-exam.dto.ts:31-34`.
2. Exam entity stores `totalWeight`: `exam.entity.ts:26-27`.
3. Service sums weights: `exams.service.ts:229-232`, `exams.service.ts:280-283`.

Risk:

The requested behavior is: instructor sets total exam grade and question weights, system calculates actual question marks. Current implementation only sums weights. It cannot produce an exam worth 60 or 100 marks unless the frontend manually sets every `weightPerQuestion` as actual marks.

Fix:

Add:

```ts
totalMarks: number;
markDistributionMode: 'manual' | 'weight_normalized' | 'equal';
roundingPolicy: 'nearest_0_25' | 'nearest_0_5' | 'nearest_1';
```

Algorithm:

1. Generate selected items with weight units.
2. `totalWeight = sum(weightUnits)`.
3. `rawMark = totalMarks * item.weightUnits / totalWeight`.
4. Apply rounding policy.
5. Adjust final item by rounding delta so item marks sum exactly to totalMarks.

Database:

1. `exam_drafts.total_marks`.
2. `exam_draft_items.weight_units`.
3. `exam_draft_items.marks`.
4. `exams.total_marks`.
5. `exam_items.weight_units`.
6. `exam_items.marks`.

#### EX-10 - Medium - Duplicate Item Order, Duplicate Questions, And Manual Draft Controls Are Incomplete

Evidence:

1. Draft item index is non-unique: `exam-draft-item.entity.ts:15`.
2. Exam item has no index/unique constraint: `exam-item.entity.ts:12-36`.
3. Update directly sets `itemOrder`: `exams.service.ts:267`.
4. There is only one draft item update endpoint: `PATCH /api/exams/drafts/:draftId/items/:itemId`.
5. There are no endpoints to manually add a question, remove a question, or reorder the full draft item list.

Risk:

Two items can have the same order. The same question can appear multiple times after replacement. Export and display order can become unstable. Instructors also cannot fully review and repair generated drafts because they cannot manually add missing questions, remove weak questions, or submit one authoritative ordered list.

Fix:

Add database constraints:

1. `unique(draft_id, item_order)`.
2. `unique(draft_id, question_id)`.
3. `unique(exam_id, item_order)`.
4. Optional `unique(exam_id, question_id)`.

Provide reorder endpoint that accepts the full ordered list and updates transactionally.

Add manual draft controls:

1. `POST /api/exams/drafts/:draftId/items`
2. `DELETE /api/exams/drafts/:draftId/items/:itemId`
3. `PATCH /api/exams/drafts/:draftId/items/reorder`

Rules:

1. Draft must be open and not expired.
2. Added/replacement question must belong to the same course.
3. Added/replacement question must be `approved`.
4. If using sections, item must be assigned to a valid draft section.
5. Reorder must update all affected items in one transaction.
6. Mark totals must be recalculated or validated after add/remove/reorder.

#### EX-11 - Medium - Exam Status Lifecycle Is Incomplete

Evidence:

1. Status enum exists: `exam.entity.ts:29-30`.
2. No publish/archive endpoints in `exams.controller.ts`.

Risk:

Exam lifecycle is not enforced even for instructor-only usage. There is no controlled transition from generated draft to published/archived/internal workflow states.

Fix:

Add:

1. `POST /api/exams/:id/publish`
2. `POST /api/exams/:id/archive`
3. `POST /api/exams/:id/unpublish` if business allows
4. State machine rules:
   - draft -> published
   - published -> archived
   - draft -> archived
   - archived should not return to published unless a future explicit product rule allows it

#### EX-12 - Medium - Word Export Is Not Production-Quality

Evidence:

1. Export builds HTML strings: `exams.service.ts:328-339`.
2. It does not escape question text: `exams.service.ts:336`.
3. It returns `.doc` MIME with base64 HTML: `exams.service.ts:340-344`.

Risk:

Export can have broken formatting, missing media, missing options, no captions, no sections, and possible HTML injection if question text contains HTML.

Fix:

1. Escape/sanitize all content.
2. Use a DOCX generator or PDF pipeline.
3. Include:
   - sections
   - question numbers
   - marks
   - options
   - images and captions
   - answer key as optional instructor-only export
4. Return file stream/download response instead of JSON base64 for large exports.

#### EX-13 - Medium - Tests Cover Only Basic Paths

Evidence:

1. Existing tests cover course missing, empty rules, and pagination: `exams.service.spec.ts:15-112`.
2. No tests cover authorization, replacement, expiration, idempotency, transactions, answer exposure, or shortage payload preservation.

Risk:

The riskiest behavior can regress silently.

Fix:

Add unit/integration tests for:

1. `STUDENT`, `TA`, and `ADMIN` are denied from the feature controllers.
2. Instructor cannot access another instructor's course.
3. Generation shortage returns structured `shortages`.
4. Draft save cannot be repeated.
5. Expired draft cannot be saved.
6. Replacement rejects cross-course/draft/archived/duplicate questions.
7. Save rollback leaves no partial exam.
8. Total marks distribution sums exactly to requested total.

## 8. Missing Enhancement Tables And Columns Needed

### 8.1 Question Bank Attachments

Needed table: `question_bank_question_attachments`

Reason:

The current `question_file_id` supports one file only. Multiple images, captions, ordering, alt text, and future media support need a 1-to-many table.

Required columns:

| Column | Reason |
|---|---|
| `attachment_id` | Primary key |
| `question_id` | Connect attachment to question |
| `file_id` | Reuse existing file table |
| `attachment_type` | Support image now, document/audio/video later |
| `caption` | Required requested feature |
| `alt_text` | Accessibility and export quality |
| `display_order` | Stable image order |
| `is_primary` | Frontend thumbnail/default display |
| `created_by`, `created_at`, `updated_at`, `deleted_at` | Audit and soft delete |

### 8.2 Question Groups

Needed tables:

1. `question_bank_question_groups`
2. Either `question_bank_question_group_items` or `group_id/group_order` on `question_bank_questions`

Reason:

Related multipart questions need a durable backend relationship. Exam generator also needs to know whether to keep grouped questions together.

### 8.3 Question Versions

Needed tables:

1. `question_bank_question_versions`
2. Optional `question_bank_option_versions`
3. Optional `question_bank_fill_blank_versions`

Reason:

Final exams should be stable. If bank questions change, old exams should keep the version selected at generation/save time.

### 8.4 Question Review Events

Needed table: `question_bank_review_events`

Reason:

The current status field has no reviewer, reason, or history. Production question banks usually need approval workflow.

### 8.5 Tags And Learning Outcomes

Needed tables:

1. `question_bank_tags`
2. `question_bank_question_tags`
3. `learning_outcomes`
4. `question_bank_question_outcomes`

Reason:

Difficulty, Bloom, and chapter are not enough for high-quality exam generation. Tags/outcomes allow blueprint generation by objectives and reduce accidental gaps.

### 8.6 Question Usage Statistics

Needed table: `question_bank_usage_stats` or `exam_question_usage`

Reason:

Generator should know how often questions are used, when they were last used, and whether a question is overexposed. This supports better randomization and exam quality.

### 8.7 Exam Sections

Needed tables:

1. `exam_sections`
2. Add `section_id` to `exam_items` and `exam_draft_items`

Reason:

Real exams often have sections such as MCQ, Written, Essay, Bonus, or "Answer any 3 of 5". The current flat list cannot represent these structures.

### 8.8 Exam Item Snapshots

Needed table: `exam_item_snapshots`

Reason:

Final exams should not depend on mutable question bank rows. This table preserves exact selected content at save/publish time.

### 8.9 Total Marks And Mark Distribution Columns

Needed columns:

1. `exam_drafts.total_marks`
2. `exam_draft_items.weight_units`
3. `exam_draft_items.marks`
4. `exams.total_marks`
5. `exam_items.weight_units`
6. `exam_items.marks`

Reason:

Requested total-grade-driven exam generation cannot be represented with `total_weight` alone.

### 8.10 Draft Finalization Columns

Needed columns:

1. `exam_drafts.status`
2. `exam_drafts.finalized_exam_id`
3. `exam_drafts.finalized_by`
4. `exam_drafts.finalized_at`

Reason:

Prevents duplicate exams and supports draft lifecycle.

### 8.11 Idempotency Keys

Needed table: `api_idempotency_keys`

Reason:

Generation and draft save are retry-sensitive operations. Idempotency prevents duplicate drafts/exams when clients retry after timeout.

### 8.12 Exam Export Records

Needed table: `exam_exports`

Reason:

Exports can be slow and should be auditable. Store who exported, format, file ID, status, and timestamp.

## 9. Backend Fix Roadmap

### Phase 0 - Immediate Security Fixes

1. Make all question bank endpoints instructor-only.
2. Make all exam generator and exam draft endpoints instructor-only.
3. Remove `STUDENT`, `TA`, and `ADMIN` from the two feature controllers for now.
4. Add instructor course ownership checks to question bank and exam endpoints.
5. Add tests proving non-instructor roles receive 403 and instructors cannot access courses they do not teach.

### Phase 1 - Data Integrity Fixes

1. Add transactions to question create/update.
2. Add transactions to exam generation draft creation and draft save.
3. Fix question update child replacement logic.
4. Add replacement question validation.
5. Add unique constraints for draft/exam item order and question uniqueness.
6. Add soft delete/in-use checks for questions and chapters.

### Phase 2 - Requested Feature Completion

1. Implement multiple image attachments per question.
2. Add caption and alt text per attachment.
3. Add batch related question creation.
4. Add question groups and group-aware exam generation.
5. Add total marks and automatic marks distribution.

### Phase 3 - Lifecycle And Production Hardening

1. Enforce draft expiration.
2. Add draft finalized/expired/cancelled states.
3. Add publish/archive exam lifecycle endpoints.
4. Snapshot final exam item content.
5. Replace HTML Word export with real DOCX/PDF export.
6. Add usage analytics and avoid overusing the same questions.

### Phase 4 - Quality And Observability

1. Add structured logs through Nest `Logger`.
2. Add metrics for generation shortages, generation latency, and draft save failures.
3. Add cleanup jobs for expired drafts and orphan files/images.
4. Add integration tests against a test database.
5. Add API documentation for new DTOs and response shapes.

## 10. Instructor Workflow And UX Stability Scenarios

The two features should be optimized around instructor authoring only. These are the practical backend scenarios that should be handled cleanly:

### 10.1 Instructor Creates Bank Content

Expected flow:

1. Instructor selects one of their own courses.
2. Instructor creates or selects a chapter.
3. Instructor uploads one or more images with captions and alt text.
4. Instructor creates one question or a related group of questions.
5. Backend validates type-specific answer structure.
6. Backend saves the question, options/blanks, attachments, and group links atomically.

Backend requirements:

1. Reject non-instructor roles before service logic.
2. Reject instructors who do not teach the course.
3. Return precise validation messages, such as missing correct MCQ option, duplicate blank key, missing caption metadata shape, or invalid image type.
4. Use transactions so a failed option/attachment save does not leave a partial question.
5. Support draft status for unfinished authoring and approved status for generator-eligible questions.

### 10.2 Instructor Edits Existing Questions

Expected flow:

1. Instructor lists only questions from their own course.
2. Instructor filters by chapter/type/difficulty/Bloom/status.
3. Instructor edits text, images, options, blanks, status, or metadata.
4. Backend updates only fields included in the patch.
5. If a question is already used in a saved exam, backend preserves old exam content through snapshots/versioning.

Backend requirements:

1. Patch status/text must not delete/recreate options or blanks.
2. Type changes must clear incompatible children in a transaction.
3. Used questions should be archived/versioned, not destructively changed for old exams.
4. Conflicts such as duplicate chapter order should return 409 with clear messages.

### 10.3 Instructor Generates An Exam

Expected flow:

1. Instructor selects one of their own courses.
2. Instructor enters total marks, title, rules, and optional seed.
3. Backend checks that each chapter belongs to the course.
4. Backend selects approved questions only.
5. Backend returns a preview with shortage details if any rule cannot be satisfied.
6. Backend creates draft and draft items atomically only when generation succeeds.

Backend requirements:

1. Empty or expired drafts should not remain silently active.
2. Shortage responses should include chapter, type, difficulty, Bloom, required count, and available count.
3. Mark distribution should sum exactly to total exam marks after rounding.
4. Generation should avoid duplicate questions unless a future setting explicitly allows duplicates.

### 10.4 Instructor Reviews And Saves Draft

Expected flow:

1. Instructor sees only their own draft.
2. Instructor replaces questions, changes order, and adjusts marks.
3. Backend validates replacements against course/status/duplicate constraints.
4. Instructor saves the draft once.
5. Backend finalizes the draft idempotently and creates immutable exam item snapshots.

Backend requirements:

1. Expired drafts cannot be edited or saved.
2. Saving the same draft twice should return the existing exam or reject the second save cleanly.
3. Draft save must be a transaction.
4. Saved exam total marks and item marks must remain consistent.

### 10.5 Instructor Exports Exam

Expected flow:

1. Instructor exports only their own saved exam.
2. Export includes question text, options, images, captions, sections, and marks.
3. Optional answer-key export is instructor-only.

Backend requirements:

1. Escape/sanitize text before document generation.
2. Use snapshots so export does not change after bank question edits.
3. Use async export jobs or streaming for large exams.
4. Store export records for audit and troubleshooting.

### 10.6 Operational Cleanup

Expected behavior:

1. Expired drafts are marked expired by a scheduled job.
2. Empty draft headers are cleaned or marked failed.
3. Orphan uploads are cleaned after failed question/image saves.
4. Generation failures are logged with structured details.

These scenarios are the practical acceptance criteria for making the two features stable from backend, database, and instructor UX perspectives.

## 11. Necessary New Features Not Currently In The Project

### 11.1 Question Bank

| Feature | Why necessary |
|---|---|
| Multi-image attachments | Required by current user requirement and common for diagrams/questions. |
| Captions and alt text | Required by current user requirement and improves accessibility/export. |
| Plain bulk question create API | Necessary for instructors adding many unrelated questions without many separate requests. |
| Related question groups | Required for passage/case/multipart questions. |
| Question versioning | Prevents old exams from changing when bank questions are edited. |
| Approval workflow | Prevents unreviewed questions from being used in exams. |
| Soft delete/archive | Preserves history and avoids FK delete errors. |
| Tags and learning outcomes | Enables better exam blueprints than chapter/type/difficulty only. |
| Bulk import/export | Necessary for real instructors managing large banks. |
| Duplicate detection | Prevents repeated or near-identical questions. |
| Usage statistics | Avoids overexposing the same questions and improves generator quality. |
| Question quality metrics | Track difficulty drift, discrimination, success rate, and review needs. |

### 11.2 Exam Generator

| Feature | Why necessary |
|---|---|
| Total marks distribution | Required by current requested scoring behavior. |
| Exam sections | Needed for real exam structure. |
| Blueprint templates | Reusable generation rules for midterm/final/practice exams. |
| Group-aware selection | Prevents splitting related multipart questions incorrectly. |
| Draft state machine | Needed for stable edits, expiration, and finalization. |
| Idempotent generation/save | Prevents duplicate drafts/exams on retry. |
| Publish/archive workflow | Controls instructor workflow state now; can control learner visibility later only if a separate delivery feature is added. |
| Immutable exam snapshots | Preserves academic record integrity. |
| Manual add/remove/reorder endpoints | Instructors need full control after generation. |
| Export jobs | Reliable DOCX/PDF exports with media and answer keys. |
| Scheduled exams integration | Connect generated exams to the existing schedule module. |
| Gradebook integration | Future-only: connect published exams to grades/submissions if this module later becomes an assessment-delivery system. |

## 12. Suggested API Design

### 12.1 Question Attachments

```http
POST /api/question-bank/questions/:questionId/attachments
Content-Type: multipart/form-data
fields:
  images[]: files
  metadata: JSON [{ "caption": "...", "altText": "...", "displayOrder": 0 }]
```

```http
PATCH /api/question-bank/questions/:questionId/attachments/:attachmentId
body:
{
  "caption": "Updated caption",
  "altText": "Description for accessibility",
  "displayOrder": 2,
  "isPrimary": true
}
```

### 12.2 Plain Bulk Question Create

```http
POST /api/question-bank/questions/batch
body:
{
  "courseId": 34,
  "defaultChapterId": 2,
  "questions": [
    {
      "questionType": "mcq",
      "difficulty": "medium",
      "bloomLevel": "understanding",
      "questionText": "...",
      "options": [...]
    },
    {
      "chapterId": 3,
      "questionType": "essay",
      "difficulty": "hard",
      "bloomLevel": "evaluating",
      "questionText": "...",
      "expectedAnswerText": "..."
    }
  ]
}
```

Rules:

1. Instructor-only and course-owned.
2. Does not create a question group.
3. Saves all questions and child rows in one transaction.
4. Rejects the whole batch if any item is invalid.
5. Returns created questions in request order.
6. Validation errors identify item indexes.

### 12.3 Batch Related Questions

```http
POST /api/question-bank/groups
body:
{
  "courseId": 34,
  "chapterId": 2,
  "title": "Case study: HTTP API design",
  "sharedPrompt": "...",
  "groupType": "case_study"
}
```

```http
POST /api/question-bank/groups/:groupId/questions/batch
body:
{
  "questions": [
    {
      "questionType": "mcq",
      "difficulty": "medium",
      "bloomLevel": "understanding",
      "questionText": "...",
      "options": [...]
    }
  ]
}
```

### 12.4 Exam Generation With Total Marks

```http
POST /api/exams/generate-preview
body:
{
  "courseId": 34,
  "title": "Midterm",
  "totalMarks": 60,
  "markDistributionMode": "weight_normalized",
  "roundingPolicy": "nearest_0_5",
  "rules": [
    {
      "chapterId": 2,
      "count": 10,
      "weightPerQuestion": 1,
      "questionType": "mcq"
    },
    {
      "chapterId": 2,
      "count": 2,
      "weightPerQuestion": 5,
      "questionType": "essay"
    }
  ]
}
```

Expected calculation:

1. Total weight units = `(10 * 1) + (2 * 5) = 20`.
2. Each MCQ mark = `60 * 1 / 20 = 3`.
3. Each essay mark = `60 * 5 / 20 = 15`.
4. Sum = `10*3 + 2*15 = 60`.

### 12.5 Exam Sections

```http
POST /api/exams/generate-preview
body:
{
  "courseId": 34,
  "title": "Midterm",
  "totalMarks": 60,
  "sections": [
    {
      "title": "MCQ",
      "instructions": "Answer all questions.",
      "totalMarks": 30,
      "answerPolicy": "answer_all",
      "rules": [...]
    },
    {
      "title": "Essay",
      "instructions": "Answer any 2 questions.",
      "totalMarks": 30,
      "answerPolicy": "answer_any",
      "requiredAnswerCount": 2,
      "rules": [...]
    }
  ]
}
```

Draft section management:

1. `POST /api/exams/drafts/:draftId/sections`
2. `PATCH /api/exams/drafts/:draftId/sections/:sectionId`
3. `DELETE /api/exams/drafts/:draftId/sections/:sectionId`
4. `PATCH /api/exams/drafts/:draftId/sections/reorder`

### 12.6 Manual Draft Item Controls

```http
POST /api/exams/drafts/:draftId/items
body:
{
  "questionId": 58,
  "draftSectionId": 3,
  "weightUnits": 2,
  "marks": 4
}
```

Endpoints:

1. `POST /api/exams/drafts/:draftId/items`
2. `PATCH /api/exams/drafts/:draftId/items/:itemId`
3. `DELETE /api/exams/drafts/:draftId/items/:itemId`
4. `PATCH /api/exams/drafts/:draftId/items/reorder`

Rules:

1. Draft must be open and not expired.
2. Question must belong to the same course.
3. Question must be approved.
4. Item marks must remain valid against section/exam totals.

### 12.7 Exam Lifecycle

Endpoints:

1. `POST /api/exams/:id/publish`
2. `POST /api/exams/:id/archive`
3. `POST /api/exams/:id/unpublish` only if product explicitly allows it.

State rules:

1. `draft -> published`
2. `draft -> archived`
3. `published -> archived`
4. `archived` is terminal unless a future product rule changes that.

## 13. Suggested Database Constraints

Add these constraints after data cleanup:

```sql
ALTER TABLE question_bank_options
ADD UNIQUE KEY UQ_qb_option_order (question_id, option_order);

ALTER TABLE question_bank_fill_blanks
ADD UNIQUE KEY UQ_qb_blank_key (question_id, blank_key);

ALTER TABLE exam_draft_items
ADD UNIQUE KEY UQ_draft_item_order (draft_id, item_order),
ADD UNIQUE KEY UQ_draft_question (draft_id, question_id);

ALTER TABLE exam_items
ADD UNIQUE KEY UQ_exam_item_order (exam_id, item_order),
ADD KEY IDX_exam_items_exam_order (exam_id, item_order);
```

For question attachments:

```sql
ALTER TABLE question_bank_question_attachments
ADD UNIQUE KEY UQ_qb_attachment_order (question_id, display_order),
ADD KEY IDX_qb_attachment_question (question_id),
ADD KEY IDX_qb_attachment_file (file_id);
```

For exam sections:

```sql
ALTER TABLE exam_draft_sections
ADD UNIQUE KEY UQ_exam_draft_section_order (draft_id, section_order);

ALTER TABLE exam_sections
ADD UNIQUE KEY UQ_exam_section_order (exam_id, section_order);

ALTER TABLE exam_draft_items
ADD KEY IDX_exam_draft_items_section_order (draft_section_id, item_order);

ALTER TABLE exam_items
ADD KEY IDX_exam_items_section_order (section_id, item_order);
```

## 14. Suggested Test Plan

### 14.1 Question Bank Tests

1. `STUDENT`, `TA`, and `ADMIN` receive 403 for every question bank endpoint.
2. Instructor cannot create/list/get/update/delete questions in another instructor's course.
3. Instructor cannot upload/attach a question image for another instructor's course.
4. Create MCQ rolls back if option insert fails.
5. Patch status does not delete/recreate options.
6. Switch MCQ to essay removes options.
7. WebP upload behavior is consistent.
8. Multiple attachment create stores order/caption/alt text.
9. Plain bulk question create is transactional.
10. Plain bulk question create returns item-indexed validation errors.
11. Batch group create is transactional.
12. Duplicate chapter name/order returns 409.
13. Delete used question returns friendly conflict or archives.

### 14.2 Exam Generator Tests

1. `STUDENT`, `TA`, and `ADMIN` receive 403 for every exam generator and draft endpoint.
2. Instructor lists only own course exams and drafts.
3. Instructor cannot get/update/save/export another instructor's draft or exam.
4. Draft expiration blocks update/save.
5. Save draft twice returns same exam or rejects second save.
6. Save draft rolls back all rows on item insert failure.
7. Replacement rejects cross-course question.
8. Replacement rejects draft/archived question.
9. Replacement rejects duplicate question in same draft.
10. Shortage response preserves structured `shortages`.
11. Total marks distribution sums exactly to requested total.
12. Draft manual add/remove/reorder is transactional.
13. Exam sections preserve section order and item order.
14. Publish/archive lifecycle rejects invalid transitions.
15. Export escapes HTML and includes images/captions/options/sections.

## 15. Final Assessment

After the final audit on 2026-05-04, the main question bank and exam generator backend plan is implemented. The features are no longer only a prototype against the investigated risk list; the requested main-plan hardening work has been added and verified.

The current backend state is:

1. Question bank and exam generator endpoints are instructor-only for the current scope.
2. Course ownership is enforced through `course_instructors -> course_sections -> course_id`.
3. Core question bank writes are transactional and preserve parent/child integrity for single create, plain bulk create, grouped batch create, and updates.
4. Attachments, captions, alt text, groups, group list/delete, question versions, review events, and private response DTO mapping are implemented.
5. Exam generation supports marks, sections, draft lifecycle, manual draft controls, idempotent save, publish/archive, immutable item snapshots, and hardened export behavior.
6. Database changes are represented by TypeORM migrations under `src/database/migrations`; dump/reference files are not the deployment mechanism.
7. Tests and build pass, and the relevant migrations are shown as applied.

Remaining work belongs to the separate future enhancement plan, not the main implementation plan. That future scope includes tags and learning outcomes, CSV/Excel import/export, duplicate similarity detection, usage statistics, quality metrics, blueprint templates, schedule integration, gradebook integration, and more advanced group-aware exam selection.
