# Question Bank And Exam Generator Fix Plan

Date: 2026-05-04  
Source report: `questionBank_Exam_report.md`  
Scope: implementation plan only. No code or database changes are made by this plan file.  
Final audit update: the main implementation was completed and verified on 2026-05-04. This plan now reflects the actual consolidated migration files and implemented API route names.

## 1. Goal

Make the question bank and exam generator backend stable, instructor-only, course-owned, transactional, and ready for the requested feature improvements:

1. Instructor-only access for both features.
2. Instructor course ownership checks.
3. Multiple images per question.
4. Captions and alt text per image.
5. Batch related question creation.
6. Plain bulk question creation for unrelated questions.
7. Total exam marks and calculated per-question marks.
8. Exam sections for real exam structure.
9. Manual draft item add/remove/reorder controls.
10. Draft lifecycle, idempotent save, and expiration enforcement.
11. Exam publish/archive lifecycle controls.
12. Immutable saved exam snapshots.
13. Safer database constraints and cleanup.
14. Comprehensive tests for security, data integrity, and instructor workflows.

## 2. Non-Goals

These items are intentionally not part of the immediate implementation:

1. Do not edit `eduverse_db.sql`.
2. Do not edit `tables.txt`.
3. Do not manually change the Aiven database in DBeaver.
4. Do not enable TypeORM `synchronize` in production.
5. Do not add learner/student exam delivery now.
6. Do not allow `STUDENT`, `TA`, or `ADMIN` to use the question bank or exam generator for now.

All deployed schema changes must be made through new migration files in `src/database/migrations`.

## 3. Current Relevant Files

### 3.1 Existing Files To Edit

Question bank:

1. `src/modules/question-bank/question-bank.controller.ts`
2. `src/modules/question-bank/question-bank.service.ts`
3. `src/modules/question-bank/question-bank.module.ts`
4. `src/modules/question-bank/dto/question.dto.ts`
5. `src/modules/question-bank/dto/chapter.dto.ts`
6. `src/modules/question-bank/entities/course-chapter.entity.ts`
7. `src/modules/question-bank/entities/question-bank-question.entity.ts`
8. `src/modules/question-bank/entities/question-bank-option.entity.ts`
9. `src/modules/question-bank/entities/question-bank-fill-blank.entity.ts`
10. `src/modules/question-bank/enums/question-bank.enums.ts`
11. `src/modules/question-bank/tests/question-bank.service.spec.ts`

Exam generator:

1. `src/modules/exams/exams.controller.ts`
2. `src/modules/exams/exam-drafts.controller.ts`
3. `src/modules/exams/exams.service.ts`
4. `src/modules/exams/exams.module.ts`
5. `src/modules/exams/dto/generate-exam.dto.ts`
6. `src/modules/exams/entities/exam.entity.ts`
7. `src/modules/exams/entities/exam-item.entity.ts`
8. `src/modules/exams/entities/exam-draft.entity.ts`
9. `src/modules/exams/entities/exam-draft-item.entity.ts`
10. `src/modules/exams/tests/exams.service.spec.ts`

Shared/supporting files:

1. `src/modules/auth/guards/roles.guard.ts` only if shared role behavior needs tests or clarification.
2. `src/modules/enrollments/entities/course-instructor.entity.ts` for instructor course assignment queries.
3. `src/modules/courses/entities/course-section.entity.ts` for course ownership through sections.
4. `src/modules/files/file-storage.service.ts` for WebP extension allow-list.
5. `src/modules/files/files.service.ts` for file ownership/context validation if centralizing file checks.

### 3.2 New Files To Create

Access control:

1. `src/modules/question-bank/services/instructor-course-access.service.ts`
2. Optional later shared extraction: `src/common/services/instructor-course-access.service.ts`

Question bank DTOs:

1. `src/modules/question-bank/dto/question-attachment.dto.ts`
2. `src/modules/question-bank/dto/question-group.dto.ts`
3. `src/modules/question-bank/dto/question-bulk.dto.ts`
4. `src/modules/question-bank/dto/question-response.dto.ts`

Question bank entities:

1. `src/modules/question-bank/entities/question-bank-question-attachment.entity.ts`
2. `src/modules/question-bank/entities/question-bank-question-group.entity.ts`
3. `src/modules/question-bank/entities/question-bank-question-group-item.entity.ts`
4. `src/modules/question-bank/entities/question-bank-question-version.entity.ts`
5. `src/modules/question-bank/entities/question-bank-review-event.entity.ts`

Exam entities:

1. `src/modules/exams/entities/exam-item-snapshot.entity.ts`
2. `src/modules/exams/entities/exam-section.entity.ts`
3. `src/modules/exams/entities/exam-export.entity.ts`

Exam DTOs:

1. `src/modules/exams/dto/exam-lifecycle.dto.ts`
2. `src/modules/exams/dto/exam-export.dto.ts`
3. `src/modules/exams/dto/exam-section.dto.ts`
4. `src/modules/exams/dto/exam-draft-item.dto.ts`
5. Optional split: `src/modules/exams/dto/exam-response.dto.ts`

Migrations actually implemented:

1. `src/database/migrations/1780000000000-HardenQuestionBankAndExamFeatures.ts`
2. `src/database/migrations/1780000000001-MarkEmptyExamDraftsFailed.ts`
3. `src/database/migrations/1780000000002-VerifyQuestionBankExamConstraintsAndAddOverrideReasons.ts`

Implementation note:

The original plan split the schema work into four conceptual migration slices. The final implementation consolidated those slices into the three TypeORM migrations above:

1. `1780000000000-HardenQuestionBankAndExamFeatures.ts` adds the main feature schema: attachments, groups, versions, review events, marks, draft/final sections, lifecycle columns, snapshots, exports, and primary feature constraints/backfills.
2. `1780000000001-MarkEmptyExamDraftsFailed.ts` handles existing empty draft cleanup.
3. `1780000000002-VerifyQuestionBankExamConstraintsAndAddOverrideReasons.ts` performs explicit duplicate prechecks and adds override reason columns.

Tests:

1. `src/modules/question-bank/tests/question-bank.controller.spec.ts`
2. `src/modules/question-bank/tests/question-bank-attachments.service.spec.ts`
3. `src/modules/question-bank/tests/question-bank-groups.service.spec.ts`
4. `src/modules/question-bank/tests/question-bank-bulk.service.spec.ts`
5. `src/modules/exams/tests/exams.controller.spec.ts`
6. `src/modules/exams/tests/exam-draft-lifecycle.service.spec.ts`
7. `src/modules/exams/tests/exam-marks-distribution.service.spec.ts`
8. `src/modules/exams/tests/exam-sections.service.spec.ts`
9. `src/modules/exams/tests/exam-draft-items.service.spec.ts`

## 4. Implementation Principles

1. Use migrations for schema changes. Do not edit dump files.
2. Keep scope instructor-only.
3. Enforce ownership in the service layer even if controller guards exist.
4. Use transactions for multi-table writes.
5. Use explicit response DTOs instead of returning mutated entities where practical.
6. Keep backward compatibility for existing `questionFileId` until attachments are migrated.
7. Add tests before or with each risky behavior change.
8. Clean live data before adding constraints that could fail.
9. Make each phase independently deployable where possible.

## 5. Phase 0 - Safety Baseline And Instructor-Only Access

### 5.1 Purpose

Remove `STUDENT`, `TA`, and `ADMIN` access from the question bank and exam generator now. Add instructor course ownership checks so one instructor cannot access another instructor's course data.

### 5.2 Files To Edit

1. `src/modules/question-bank/question-bank.controller.ts`
2. `src/modules/question-bank/question-bank.service.ts`
3. `src/modules/question-bank/question-bank.module.ts`
4. `src/modules/exams/exams.controller.ts`
5. `src/modules/exams/exam-drafts.controller.ts`
6. `src/modules/exams/exams.service.ts`
7. `src/modules/exams/exams.module.ts`
8. `src/modules/question-bank/tests/question-bank.service.spec.ts`
9. `src/modules/exams/tests/exams.service.spec.ts`

### 5.3 Files To Create

1. `src/modules/question-bank/services/instructor-course-access.service.ts`
2. `src/modules/question-bank/tests/question-bank.controller.spec.ts`
3. `src/modules/exams/tests/exams.controller.spec.ts`

### 5.4 Access Rules

Question bank:

1. `POST /api/courses/:courseId/chapters`: instructor only.
2. `GET /api/courses/:courseId/chapters`: instructor only.
3. `PATCH /api/courses/:courseId/chapters/:chapterId`: instructor only.
4. `DELETE /api/courses/:courseId/chapters/:chapterId`: instructor only.
5. `POST /api/question-bank/questions`: instructor only.
6. `POST /api/question-bank/questions/upload-image`: instructor only.
7. `GET /api/question-bank/questions`: instructor only.
8. `GET /api/question-bank/questions/:id`: instructor only.
9. `PATCH /api/question-bank/questions/:id`: instructor only.
10. `DELETE /api/question-bank/questions/:id`: instructor only.

Exam generator:

1. `GET /api/exams`: instructor only.
2. `GET /api/exams/list`: instructor only or deprecated.
3. `GET /api/exams/drafts`: instructor only.
4. `GET /api/exams/drafts/list`: instructor only or deprecated.
5. `GET /api/exams/drafts/:draftId`: instructor only.
6. `POST /api/exams/generate-preview`: instructor only.
7. `PATCH /api/exams/drafts/:draftId/items/:itemId`: instructor only.
8. `POST /api/exams/drafts/:draftId/save`: instructor only.
9. `GET /api/exams/:id`: instructor only.
10. `POST /api/exams/:id/export-word`: instructor only.
11. `GET /api/exam-drafts`: instructor only or deprecated.
12. `GET /api/exam-drafts/list`: instructor only or deprecated.
13. `GET /api/exam-drafts/:draftId`: instructor only or deprecated.

### 5.5 Implementation Steps

1. In `question-bank.controller.ts`, change every `@Roles(...)` decorator in the controller to `@Roles(RoleName.INSTRUCTOR)`.
2. In `exams.controller.ts`, change every `@Roles(...)` decorator to `@Roles(RoleName.INSTRUCTOR)`.
3. In `exam-drafts.controller.ts`, change every `@Roles(...)` decorator to `@Roles(RoleName.INSTRUCTOR)`.
4. Add `@Req() req` to question bank list/get/chapter/delete methods that currently do not receive the user.
5. Add `@Req() req` to exam list/get/draft/update/export methods that currently do not receive the user.
6. Create `InstructorCourseAccessService`.
7. Register `InstructorCourseAccessService` in `QuestionBankModule`.
8. Export it from `QuestionBankModule` or move it to a shared module so `ExamsModule` can use it.
9. Inject access service into `QuestionBankService`.
10. Inject access service into `ExamsService`.

### 5.6 InstructorCourseAccessService Contract

Create:

`src/modules/question-bank/services/instructor-course-access.service.ts`

Methods:

```ts
assertInstructorOwnsCourse(userId: number, courseId: number): Promise<void>
getInstructorCourseIds(userId: number): Promise<number[]>
```

Implementation outline:

1. Query `CourseInstructor`.
2. Join or load `CourseSection`.
3. Match `CourseSection.courseId` to the requested `courseId`.
4. Throw `ForbiddenException` if no assignment exists.
5. Throw `NotFoundException` only when the course/resource truly does not exist.

Ownership source of truth:

1. Use only `course_instructors -> course_sections -> course_id`.
2. Do not use `courses.instructor_id` as an authorization fallback for the question bank or exam generator.
3. If a real instructor currently exists only in `courses.instructor_id`, create a migration/backfill or admin assignment step that inserts the proper `course_instructors` row before enabling strict access.
4. Keep `TA`, `ADMIN`, and `STUDENT` denied even if they appear in legacy course columns or related records.

Required repositories:

1. `CourseInstructor`
2. `CourseSection`
3. Optional `Course`

Files to update for dependency injection:

1. `src/modules/question-bank/question-bank.module.ts`
2. `src/modules/exams/exams.module.ts`

### 5.7 Service-Level Authorization Calls

Question bank:

1. `createChapter(courseId, dto, userId)` checks instructor owns course.
2. `listChapters(courseId, userId)` checks instructor owns course.
3. `updateChapter(courseId, chapterId, dto, userId)` checks instructor owns course.
4. `deleteChapter(courseId, chapterId, userId)` checks instructor owns course.
5. `createQuestion(dto, userId)` checks instructor owns `dto.courseId`.
6. `listQuestions(query, userId)` restricts list to instructor course IDs.
7. `findQuestionById(questionId, userId)` verifies found question course is owned.
8. `updateQuestion(questionId, dto, userId)` verifies existing question course is owned.
9. `deleteQuestion(questionId, userId)` verifies existing question course is owned.
10. `uploadQuestionImage(userId, file)` remains instructor-only by controller; later phases add course context for attachments.

Exam generator:

1. `findExams(page, limit, userId, optionalCourseId)` restricts to instructor course IDs.
2. `findDrafts(page, limit, userId, optionalCourseId)` restricts to instructor course IDs.
3. `findDraftById(draftId, userId)` verifies draft course ownership.
4. `generatePreview(dto, userId)` checks instructor owns `dto.courseId`.
5. `updateDraftItem(draftId, itemId, dto, userId)` verifies draft course ownership.
6. `saveDraft(draftId, userId)` verifies draft course ownership.
7. `findExamById(examId, userId)` verifies exam course ownership.
8. `exportExamAsWord(examId, userId)` verifies exam course ownership.

### 5.8 Tests

Create or update tests:

1. `question-bank.controller.spec.ts`
   - `STUDENT` receives 403 for all question bank endpoints.
   - `TA` receives 403 for all question bank endpoints.
   - `ADMIN` receives 403 for all question bank endpoints.
   - `INSTRUCTOR` with no course assignment receives 403.
   - `INSTRUCTOR` with course assignment succeeds.

2. `exams.controller.spec.ts`
   - `STUDENT` receives 403 for all exam endpoints.
   - `TA` receives 403 for all exam endpoints.
   - `ADMIN` receives 403 for all exam endpoints.
   - instructor cannot read another instructor's draft/exam.

3. `question-bank.service.spec.ts`
   - mock `InstructorCourseAccessService`.
   - verify service calls ownership checks before returning data.

4. `exams.service.spec.ts`
   - mock `InstructorCourseAccessService`.
   - verify service calls ownership checks for list/get/update/save/export.

### 5.9 Acceptance Criteria

1. No question bank endpoint contains `RoleName.STUDENT`, `RoleName.TA`, or `RoleName.ADMIN`.
2. No exam generator endpoint contains `RoleName.STUDENT`, `RoleName.TA`, or `RoleName.ADMIN`.
3. Instructor course ownership is checked in service methods.
4. Existing instructor workflows still work for owned courses.
5. Cross-course instructor access returns 403.

## 6. Phase 1 - Transaction Boundaries And Existing Data Integrity

### 6.1 Purpose

Make current writes atomic before adding larger features.

### 6.2 Files To Edit

1. `src/modules/question-bank/question-bank.service.ts`
2. `src/modules/exams/exams.service.ts`
3. `src/modules/question-bank/entities/question-bank-option.entity.ts`
4. `src/modules/question-bank/entities/question-bank-fill-blank.entity.ts`
5. `src/modules/exams/entities/exam-draft-item.entity.ts`
6. `src/modules/exams/entities/exam-item.entity.ts`
7. `src/modules/question-bank/tests/question-bank.service.spec.ts`
8. `src/modules/exams/tests/exams.service.spec.ts`

### 6.3 Files To Create

1. `src/database/migrations/1780000000002-VerifyQuestionBankExamConstraintsAndAddOverrideReasons.ts`
2. `src/modules/exams/tests/exam-draft-lifecycle.service.spec.ts`

### 6.4 Question Bank Transaction Steps

Update `QuestionBankService.createQuestion`:

1. Validate instructor owns course.
2. Validate course exists.
3. Validate chapter exists.
4. Validate file exists if provided.
5. Validate payload.
6. Start TypeORM transaction.
7. Save question parent.
8. Save options/fill blanks.
9. Commit transaction.
10. Return question by ID.

Update `QuestionBankService.updateQuestion`:

1. Load existing question by ID.
2. Verify instructor owns existing question course.
3. Validate target chapter if changed.
4. Validate target file if changed.
5. Validate merged payload.
6. Start transaction.
7. Save parent fields.
8. Replace only child arrays explicitly included in patch.
9. If question type changes, delete incompatible child rows.
10. Commit transaction.
11. Return question by ID.

### 6.5 Patch Child Rewrite Fix

File:

`src/modules/question-bank/question-bank.service.ts`

Change behavior:

1. Do not call option delete/save when `dto.options === undefined`.
2. Do not call fill blank delete/save when `dto.fillBlanks === undefined`.
3. If `dto.questionType` changes:
   - switching to `MCQ` or `TRUE_FALSE` clears fill blanks.
   - switching to `FILL_BLANKS` clears options.
   - switching to `WRITTEN` or `ESSAY` clears options and fill blanks.
4. Reject incompatible payload fields instead of silently keeping them.

### 6.6 Type-Specific Validation Rules

File:

`src/modules/question-bank/question-bank.service.ts`

Add validation:

1. `MCQ`
   - at least 2 options.
   - at least 1 correct option.
   - if single-answer only is intended, exactly 1 correct option.
   - no fill blanks.
2. `TRUE_FALSE`
   - exactly 2 options.
   - exactly 1 correct option.
   - no fill blanks.
3. `FILL_BLANKS`
   - at least 1 blank.
   - unique `blankKey`.
   - no options.
4. `WRITTEN` and `ESSAY`
   - expected answer required.
   - no options.
   - no fill blanks.

### 6.7 Exam Transaction Steps

Update `ExamsService.generatePreview`:

1. Validate instructor owns course.
2. Validate rules.
3. Build selected items.
4. If shortage exists, throw structured shortage response before creating draft.
5. Start transaction.
6. Save draft.
7. Save draft items.
8. Commit.
9. Return draft preview.

Update `ExamsService.saveDraft`:

1. Load draft with items.
2. Verify instructor owns draft course.
3. Verify draft is not expired.
4. Verify draft has items.
5. Compute total weight or total marks depending on phase.
6. Start transaction.
7. Save exam header.
8. Save exam items.
9. Mark draft finalized after Phase 3 lifecycle exists.
10. Commit.
11. Return saved exam.

### 6.8 Migration: Constraints And Cleanup

Create:

`src/database/migrations/1780000000002-VerifyQuestionBankExamConstraintsAndAddOverrideReasons.ts`

Migration `up` should:

1. Check duplicate `(question_id, option_order)`.
2. Check duplicate `(question_id, blank_key)`.
3. Check duplicate `(draft_id, item_order)`.
4. Check duplicate `(draft_id, question_id)`.
5. Check duplicate `(exam_id, item_order)`.
6. Check duplicate `(exam_id, question_id)` if final duplicates are disallowed.
7. Mark or clean empty draft headers.
8. Add unique constraints after data is clean.

Suggested constraints:

1. `question_bank_options`: unique `(question_id, option_order)`.
2. `question_bank_fill_blanks`: unique `(question_id, blank_key)`.
3. `exam_draft_items`: unique `(draft_id, item_order)`.
4. `exam_draft_items`: unique `(draft_id, question_id)`.
5. `exam_items`: unique `(exam_id, item_order)`.
6. Optional `exam_items`: unique `(exam_id, question_id)`.

Migration `down` should:

1. Drop added unique constraints.
2. Avoid trying to restore cleaned data.

### 6.9 Tests

Question bank:

1. Create MCQ rollback when option save fails.
2. Create fill blank rollback when blank save fails.
3. Patch status does not delete/recreate options.
4. Patch text does not delete/recreate blanks.
5. Type change clears incompatible children.
6. Duplicate blank key rejected.
7. Incompatible child payload rejected.

Exam generator:

1. Shortage response creates no draft.
2. Draft creation rollback leaves no draft without items.
3. Save draft rollback leaves no exam without items.
4. Expired draft cannot be saved after lifecycle phase.
5. Empty draft cannot be saved.

### 6.10 Acceptance Criteria

1. Multi-table question writes are transactional.
2. Multi-table exam writes are transactional.
3. Patch operations touch only intended child data.
4. Structured shortage details are preserved.
5. Live data can accept recommended constraints after migration review.

## 7. Phase 2 - Question Attachments, Captions, And Image Stability

### 7.1 Purpose

Support multiple images per question with captions, alt text, display order, and safe storage references.

### 7.2 Files To Edit

1. `src/modules/question-bank/question-bank.controller.ts`
2. `src/modules/question-bank/question-bank.service.ts`
3. `src/modules/question-bank/question-bank.module.ts`
4. `src/modules/question-bank/dto/question.dto.ts`
5. `src/modules/question-bank/entities/question-bank-question.entity.ts`
6. `src/modules/files/file-storage.service.ts`
7. `src/modules/question-bank/tests/question-bank.service.spec.ts`

### 7.3 Files To Create

1. `src/modules/question-bank/entities/question-bank-question-attachment.entity.ts`
2. `src/modules/question-bank/dto/question-attachment.dto.ts`
3. `src/modules/question-bank/tests/question-bank-attachments.service.spec.ts`
4. `src/database/migrations/1780000000000-HardenQuestionBankAndExamFeatures.ts`

### 7.4 Entity: QuestionBankQuestionAttachment

Create:

`src/modules/question-bank/entities/question-bank-question-attachment.entity.ts`

Fields:

1. `id` mapped to `attachment_id`.
2. `questionId` mapped to `question_id`.
3. `fileId` mapped to `file_id`.
4. `attachmentType` enum: `image`, `document`, `audio`, `video`.
5. `caption` nullable `varchar(500)`.
6. `altText` nullable `varchar(500)`.
7. `displayOrder` unsigned int.
8. `isPrimary` tinyint.
9. `createdBy`.
10. `createdAt`.
11. `updatedAt`.
12. `deletedAt` nullable.
13. Relation to `QuestionBankQuestion`.
14. Relation to `File`.

### 7.5 DTOs

Create:

`src/modules/question-bank/dto/question-attachment.dto.ts`

DTOs:

1. `CreateQuestionAttachmentDto`
   - `fileId`
   - `caption`
   - `altText`
   - `displayOrder`
   - `isPrimary`
2. `UpdateQuestionAttachmentDto`
   - optional `caption`
   - optional `altText`
   - optional `displayOrder`
   - optional `isPrimary`
3. `ReorderQuestionAttachmentsDto`
   - array of `{ attachmentId, displayOrder }`
4. `QuestionAttachmentResponseDto`
   - file ID
   - image URL
   - caption
   - alt text
   - order

### 7.6 Controller Endpoints

Edit:

`src/modules/question-bank/question-bank.controller.ts`

Add endpoints:

1. `POST /api/question-bank/questions/:questionId/attachments`
   - instructor only.
   - supports attaching existing uploaded files by `fileId`.
   - verifies question ownership.

2. `POST /api/question-bank/questions/:questionId/attachments/upload`
   - instructor only.
   - uses `FilesInterceptor('images', maxCount)`.
   - accepts metadata JSON for captions and alt text.

3. `PATCH /api/question-bank/questions/:questionId/attachments/:attachmentId`
   - instructor only.
   - updates caption, alt text, display order, primary flag.

4. `PATCH /api/question-bank/questions/:questionId/attachments/reorder`
   - instructor only.
   - transactionally reorders all attachments.

5. `DELETE /api/question-bank/questions/:questionId/attachments/:attachmentId`
   - instructor only.
   - soft deletes attachment.

### 7.7 Service Methods

Edit:

`src/modules/question-bank/question-bank.service.ts`

Add methods:

1. `addQuestionAttachment(questionId, dto, userId)`
2. `uploadQuestionAttachments(questionId, files, metadata, userId)`
3. `updateQuestionAttachment(questionId, attachmentId, dto, userId)`
4. `reorderQuestionAttachments(questionId, dto, userId)`
5. `deleteQuestionAttachment(questionId, attachmentId, userId)`
6. `attachQuestionAttachmentUrls(questions)`

Service rules:

1. Verify instructor owns question course.
2. Verify file exists.
3. Verify file was uploaded by the instructor or belongs to the question/course context.
4. Verify MIME is image for `image` attachments.
5. Enforce unique order per question.
6. If setting `isPrimary`, unset other primary attachments for that question.
7. Use transactions for multi-file upload metadata save.

### 7.8 Storage Fixes

Edit:

`src/modules/files/file-storage.service.ts`

Change:

1. Add `webp` to default allowed file extensions.
2. Consider shared image MIME/extension validation helper.

Edit:

`src/modules/question-bank/question-bank.service.ts`

Change:

1. Stop deriving Supabase path only from file ID and MIME type.
2. Store actual storage path in the attachment table or file metadata.
3. Add compensation cleanup if Supabase upload fails after local upload.

### 7.9 Migration

In:

`src/database/migrations/1780000000000-HardenQuestionBankAndExamFeatures.ts`

Add table:

`question_bank_question_attachments`

Constraints:

1. FK `question_id` to `question_bank_questions(question_id)`.
2. FK `file_id` to `files(file_id)`.
3. Unique `(question_id, display_order)`.
4. Index `(question_id)`.
5. Index `(file_id)`.

Backfill:

1. For each existing `question_bank_questions.question_file_id`, create one attachment row.
2. Use `display_order = 0`.
3. Use `is_primary = 1`.
4. Leave `caption` and `alt_text` null.

### 7.10 Tests

1. Instructor can add multiple attachments.
2. Non-instructor cannot add attachments.
3. Instructor cannot attach files to another instructor's question.
4. Captions are saved per image.
5. Attachment order is stable.
6. Duplicate attachment order rejected.
7. Primary image uniqueness maintained.
8. WebP upload accepted consistently.
9. Supabase failure does not leave broken attachment rows.

### 7.11 Acceptance Criteria

1. One question can have multiple images.
2. Each image can have caption and alt text.
3. Existing `questionFileId` data is migrated to attachments.
4. Old single-image behavior still works during transition.
5. Instructor receives stable ordered attachment response.

## 8. Phase 3 - Plain Bulk Create, Related Question Groups, And Batch Create

### 8.1 Purpose

Support two instructor authoring workflows:

1. Plain bulk creation for many unrelated questions in one request.
2. Grouped/multipart question creation where several related questions belong to one passage, case, image set, or multipart prompt.

### 8.2 Files To Edit

1. `src/modules/question-bank/question-bank.controller.ts`
2. `src/modules/question-bank/question-bank.service.ts`
3. `src/modules/question-bank/question-bank.module.ts`
4. `src/modules/question-bank/dto/question.dto.ts`
5. `src/modules/question-bank/entities/question-bank-question.entity.ts`
6. `src/modules/exams/exams.service.ts`

### 8.3 Files To Create

1. `src/modules/question-bank/entities/question-bank-question-group.entity.ts`
2. `src/modules/question-bank/entities/question-bank-question-group-item.entity.ts`
3. `src/modules/question-bank/dto/question-group.dto.ts`
4. `src/modules/question-bank/dto/question-bulk.dto.ts`
5. `src/modules/question-bank/tests/question-bank-groups.service.spec.ts`
6. `src/modules/question-bank/tests/question-bank-bulk.service.spec.ts`

Migration already planned:

1. `src/database/migrations/1780000000000-HardenQuestionBankAndExamFeatures.ts`

### 8.4 Entities

Create `QuestionBankQuestionGroup`:

Fields:

1. `groupId`
2. `courseId`
3. `chapterId`
4. `title`
5. `sharedPrompt`
6. `sharedFileId`
7. `groupType`: `passage`, `case_study`, `image_set`, `multipart`, `other`
8. `createdBy`
9. `createdAt`
10. `updatedAt`
11. `deletedAt`

Create `QuestionBankQuestionGroupItem`:

Fields:

1. `groupItemId`
2. `groupId`
3. `questionId`
4. `itemOrder`
5. `createdAt`

### 8.5 DTOs

Create:

`src/modules/question-bank/dto/question-group.dto.ts`

DTOs:

1. `CreateQuestionGroupDto`
2. `UpdateQuestionGroupDto`
3. `BatchCreateGroupedQuestionsDto`
4. `ReorderQuestionGroupItemsDto`
5. `QuestionGroupResponseDto`

Create:

`src/modules/question-bank/dto/question-bulk.dto.ts`

DTOs:

1. `BulkCreateQuestionBankQuestionsDto`
2. `BulkCreateQuestionBankQuestionItemDto`
3. `BulkCreateQuestionBankQuestionsResponseDto`

Bulk DTO rules:

1. `courseId` is required at the request level.
2. `questions` is a non-empty array.
3. Maximum batch size should be explicit, for example 50 initially.
4. Each question item uses the same validation rules as `CreateQuestionBankQuestionDto`.
5. Each question item may specify `chapterId`; if missing, allow optional request-level `defaultChapterId`.
6. Response returns created question IDs and item indexes.
7. Validation errors identify the failing item index, for example `questions[3].options`.

### 8.6 Controller Endpoints

Add to:

`src/modules/question-bank/question-bank.controller.ts`

Endpoints:

1. `POST /api/question-bank/groups`
2. `GET /api/question-bank/groups`
3. `GET /api/question-bank/groups/:groupId`
4. `PATCH /api/question-bank/groups/:groupId`
5. `DELETE /api/question-bank/groups/:groupId`
6. `POST /api/question-bank/groups/:groupId/questions/batch`
7. `PATCH /api/question-bank/groups/:groupId/questions/reorder`
8. `POST /api/question-bank/questions/batch`

All endpoints instructor-only and course-owned.

Plain bulk endpoint:

`POST /api/question-bank/questions/batch`

Behavior:

1. Creates many independent questions in one request.
2. Does not create a group.
3. Uses one database transaction for all parent, option, fill-blank, and attachment-link rows.
4. If any question fails validation, no question is saved.
5. If any file, chapter, or course check fails, no question is saved.
6. Returns created questions in request order.

### 8.7 Service Methods

Add to:

`QuestionBankService`

1. `createQuestionGroup(dto, userId)`
2. `listQuestionGroups(query, userId)`
3. `findQuestionGroupById(groupId, userId)`
4. `updateQuestionGroup(groupId, dto, userId)`
5. `deleteQuestionGroup(groupId, userId)`
6. `batchCreateGroupedQuestions(groupId, dto, userId)`
7. `reorderQuestionGroupItems(groupId, dto, userId)`
8. `bulkCreateQuestions(dto, userId)`

Rules:

1. Instructor must own group course.
2. Group chapter must belong to course.
3. Batch create is transactional.
4. All questions in group share course/chapter by default.
5. Child question validation uses existing type-specific validation.
6. If one question in batch fails validation, no question is saved.
7. Plain bulk create checks instructor owns request `courseId`.
8. Plain bulk create rejects any item whose `chapterId` does not belong to the request course.
9. Plain bulk create rejects cross-course file usage.
10. Single create, plain bulk create, and grouped batch create should use shared internal helpers so validation and child-row persistence do not drift.

### 8.8 Exam Generator Group Rules

Edit:

`src/modules/exams/dto/generate-exam.dto.ts`

Add optional rule:

```ts
groupSelectionMode?: 'independent' | 'keep_group_together' | 'exclude_grouped';
```

Edit:

`src/modules/exams/exams.service.ts`

Generation behavior:

1. `independent`: existing behavior.
2. `keep_group_together`: if one question from a group is selected, include the group according to section/rule constraints.
3. `exclude_grouped`: do not select grouped questions.

Recommendation:

Implement only `independent` plus metadata in the first group phase, then add group-aware selection in a later generator improvement if needed.

### 8.9 Migration

In:

`1780000000000-HardenQuestionBankAndExamFeatures.ts`

Add:

1. `question_bank_question_groups`
2. `question_bank_question_group_items`

Constraints:

1. FK group course to `courses`.
2. FK group chapter to `course_chapters`.
3. FK group item question to `question_bank_questions`.
4. Unique `(group_id, question_id)`.
5. Unique `(group_id, item_order)`.

### 8.10 Tests

1. Instructor can create group.
2. Instructor cannot create group for another instructor's course.
3. Batch creation saves all questions in transaction.
4. Invalid question in batch rolls back all questions.
5. Reorder enforces unique order.
6. Deleting group does not delete questions unless explicit business rule says so.
7. Plain bulk create saves independent questions transactionally.
8. Plain bulk create returns item-indexed validation errors.
9. Plain bulk create rejects batches above the configured maximum.

### 8.11 Acceptance Criteria

1. Backend can represent related questions.
2. Backend can batch create related questions transactionally.
3. Group metadata is available for frontend authoring UX.
4. Exam generator does not break on grouped questions.
5. Instructor can create multiple unrelated questions in one request through `POST /api/question-bank/questions/batch`.
6. Plain bulk create and grouped batch create both roll back fully on any failed item.

## 9. Phase 4 - Total Marks And Mark Distribution

### 9.1 Purpose

Support instructor-defined total exam marks and automatic per-question mark calculation from weights.

### 9.2 Files To Edit

1. `src/modules/exams/dto/generate-exam.dto.ts`
2. `src/modules/exams/exams.service.ts`
3. `src/modules/exams/entities/exam.entity.ts`
4. `src/modules/exams/entities/exam-item.entity.ts`
5. `src/modules/exams/entities/exam-draft.entity.ts`
6. `src/modules/exams/entities/exam-draft-item.entity.ts`
7. `src/modules/exams/tests/exams.service.spec.ts`

### 9.3 Files To Create

1. `src/modules/exams/tests/exam-marks-distribution.service.spec.ts`
2. `src/database/migrations/1780000000000-HardenQuestionBankAndExamFeatures.ts`

### 9.4 DTO Changes

Edit:

`src/modules/exams/dto/generate-exam.dto.ts`

Add to `GenerateExamPreviewDto`:

1. `totalMarks: number`
2. `markDistributionMode?: 'manual' | 'weight_normalized' | 'equal'`
3. `roundingPolicy?: 'none' | 'nearest_0_25' | 'nearest_0_5' | 'nearest_1'`

Rename or clarify:

1. Keep `weightPerQuestion` for compatibility.
2. Internally treat it as `weightUnits`.
3. Add documentation that marks are calculated from total marks and weights.

Add to `UpdateDraftItemDto`:

1. `weightUnits?: number`
2. `marks?: number`

Recommendation:

Use `weight` for backward compatibility in code initially, but plan a migration toward `weightUnits`.

### 9.5 Entity Changes

Edit `exam-draft.entity.ts`:

1. Add `totalMarks`.
2. Add `markDistributionMode`.
3. Add `roundingPolicy`.

Edit `exam-draft-item.entity.ts`:

1. Add `weightUnits`.
2. Add `marks`.
3. Keep existing `weight` temporarily.

Edit `exam.entity.ts`:

1. Add `totalMarks`.
2. Keep `totalWeight` for compatibility.

Edit `exam-item.entity.ts`:

1. Add `weightUnits`.
2. Add `marks`.
3. Keep existing `weight` temporarily.

### 9.6 Mark Distribution Algorithm

Create private methods in:

`src/modules/exams/exams.service.ts`

Methods:

1. `calculateDraftMarks(selectedItems, totalMarks, mode, roundingPolicy)`
2. `roundMark(value, roundingPolicy)`
3. `adjustRoundingDelta(items, totalMarks)`

Algorithm:

1. If mode is `equal`, every question starts with `totalMarks / questionCount`.
2. If mode is `weight_normalized`, compute `rawMark = totalMarks * weightUnits / totalWeightUnits`.
3. Apply rounding policy to every item.
4. Compute delta between rounded sum and `totalMarks`.
5. Add/subtract delta from the last eligible item or distribute by largest remainder.
6. Guarantee final sum exactly equals `totalMarks`.
7. Reject generation if total weight units is zero.

### 9.7 Migration

Create:

`src/database/migrations/1780000000000-HardenQuestionBankAndExamFeatures.ts`

Add columns:

1. `exam_drafts.total_marks decimal(10,2) null`
2. `exam_drafts.mark_distribution_mode enum(...)`
3. `exam_drafts.rounding_policy enum(...)`
4. `exam_draft_items.weight_units decimal(7,2) null`
5. `exam_draft_items.marks decimal(7,2) null`
6. `exams.total_marks decimal(10,2) null`
7. `exam_items.weight_units decimal(7,2) null`
8. `exam_items.marks decimal(7,2) null`

Backfill:

1. Copy existing `exam_draft_items.weight` to `weight_units`.
2. Copy existing `exam_items.weight` to `weight_units`.
3. Copy existing `exams.total_weight` to `total_marks` only if product accepts treating old weights as marks.
4. Otherwise leave `total_marks` null for old exams and calculate only for new exams.

### 9.8 Service Flow Updates

`generatePreview`:

1. Validate `totalMarks > 0`.
2. Validate every rule has positive weight when using weighted mode.
3. Select questions.
4. Calculate draft item marks.
5. Save draft with total marks and mode.
6. Save draft items with `weightUnits` and `marks`.
7. Return `totalMarks`, `totalWeight`, and item `marks`.

`updateDraftItem`:

1. If weight or marks changes, recalculate total or enforce manual mode.
2. If manual marks are allowed, verify sum equals total marks before save.
3. If weighted mode, recalculate all draft item marks after weight change.

`saveDraft`:

1. Copy draft `totalMarks` to exam.
2. Copy item `weightUnits` and `marks` to exam items.
3. Validate item marks sum equals exam total marks.

### 9.9 Tests

1. Weighted distribution sums exactly to total marks.
2. Equal distribution sums exactly to total marks.
3. Rounding to 0.5 still sums exactly.
4. Zero total marks rejected.
5. Zero total weight rejected for weighted mode.
6. Updating draft item weight recalculates marks.
7. Saving draft copies marks to final exam.

### 9.10 Acceptance Criteria

1. Instructor can enter total exam marks.
2. Backend calculates item marks.
3. Mark sum equals total marks.
4. Existing `totalWeight` behavior remains compatible.
5. Final exams store marks, not only weights.

## 9A. Phase 4A - Exam Sections

### 9A.1 Purpose

Add real exam structure so the generator can represent sections such as MCQ, Written, Essay, Problem Solving, Bonus, or "Answer any 3 of 5" instead of a single flat item list.

### 9A.2 Files To Edit

1. `src/modules/exams/exams.controller.ts`
2. `src/modules/exams/exams.service.ts`
3. `src/modules/exams/exams.module.ts`
4. `src/modules/exams/dto/generate-exam.dto.ts`
5. `src/modules/exams/entities/exam.entity.ts`
6. `src/modules/exams/entities/exam-item.entity.ts`
7. `src/modules/exams/entities/exam-draft.entity.ts`
8. `src/modules/exams/entities/exam-draft-item.entity.ts`
9. `src/modules/exams/tests/exams.service.spec.ts`

### 9A.3 Files To Create

1. `src/modules/exams/entities/exam-section.entity.ts`
2. `src/modules/exams/entities/exam-draft-section.entity.ts`
3. `src/modules/exams/dto/exam-section.dto.ts`
4. `src/modules/exams/tests/exam-sections.service.spec.ts`
5. Migration: `src/database/migrations/1780000000000-HardenQuestionBankAndExamFeatures.ts`

### 9A.4 Entity Design

Create `exam_draft_sections`:

1. `draft_section_id`
2. `draft_id`
3. `title`
4. `instructions`
5. `section_order`
6. `total_marks`
7. `answer_policy`: `answer_all`, `answer_any`
8. `required_answer_count`
9. `created_at`
10. `updated_at`

Create `exam_sections`:

1. `section_id`
2. `exam_id`
3. `title`
4. `instructions`
5. `section_order`
6. `total_marks`
7. `answer_policy`
8. `required_answer_count`
9. `created_at`
10. `updated_at`

Update existing item entities:

1. Add `draft_section_id` nullable to `exam_draft_items`.
2. Add `section_id` nullable to `exam_items`.
3. Keep null allowed during migration so old flat exams still load.
4. Add indexes on `(draft_section_id, item_order)` and `(section_id, item_order)`.

### 9A.5 DTO Changes

Edit `GenerateExamPreviewDto`:

1. Add optional `sections` array.
2. Each section can contain its own title, instructions, total marks, answer policy, and generation rules.
3. Keep current top-level `rules` for backward compatibility.
4. Reject requests that send both top-level `rules` and `sections` unless explicitly supported.
5. If sections are provided, distribute marks within each section, then verify section totals sum to exam `totalMarks`.

Create `exam-section.dto.ts`:

1. `CreateExamSectionDto`
2. `UpdateExamSectionDto`
3. `ReorderExamSectionsDto`
4. `ExamSectionResponseDto`

### 9A.6 Controller Endpoints

Add to `src/modules/exams/exams.controller.ts`:

1. `POST /api/exams/drafts/:draftId/sections`
2. `PATCH /api/exams/drafts/:draftId/sections/:sectionId`
3. `DELETE /api/exams/drafts/:draftId/sections/:sectionId`
4. `PATCH /api/exams/drafts/:draftId/sections/reorder`

All endpoints are instructor-only and course-owned.

### 9A.7 Service Methods

Add to `ExamsService`:

1. `createDraftSection(draftId, dto, userId)`
2. `updateDraftSection(draftId, sectionId, dto, userId)`
3. `deleteDraftSection(draftId, sectionId, userId)`
4. `reorderDraftSections(draftId, dto, userId)`
5. `copyDraftSectionsToExam(draft, exam, manager)`

Rules:

1. Verify draft ownership before changing sections.
2. Reject section changes when draft is finalized, expired, cancelled, or failed.
3. Deleting a section with items should either reject with 409 or require explicit `moveItemsToSectionId`.
4. Reordering sections is transactional.
5. `saveDraft` copies draft sections to final exam sections before copying items.
6. Export orders by section order, then item order.

### 9A.8 Migration

In `1780000000000-HardenQuestionBankAndExamFeatures.ts`:

1. Create `exam_draft_sections`.
2. Create `exam_sections`.
3. Add nullable `draft_section_id` to `exam_draft_items`.
4. Add nullable `section_id` to `exam_items`.
5. Backfill old exams/drafts with a default section only if product wants every item sectioned immediately.
6. Otherwise leave old rows null and let response DTO expose them as a flat default section.

### 9A.9 Tests

1. Instructor can generate a sectioned draft.
2. Section totals sum to exam total marks.
3. Section item marks sum to section marks.
4. Instructor can create/update/reorder draft sections.
5. Deleting a section with items is rejected or moves items according to explicit DTO.
6. Saving draft copies sections and item section links.
7. Export preserves section order and item order.
8. Instructor cannot change another instructor's draft sections.

### 9A.10 Acceptance Criteria

1. Backend can represent flat and sectioned exams.
2. Sectioned generation is optional and backward compatible.
3. Sections are included in draft, final exam, and export responses.
4. Section operations are instructor-only, course-owned, and transactional.

## 10. Phase 5 - Draft Lifecycle, Idempotency, And Cleanup

### 10.1 Purpose

Make drafts reliable: enforce expiration, prevent duplicate saves, mark failed/empty drafts, support manual item control, support exam publish/archive state changes, and clean old data.

### 10.2 Files To Edit

1. `src/modules/exams/exams.service.ts`
2. `src/modules/exams/entities/exam-draft.entity.ts`
3. `src/modules/exams/entities/exam.entity.ts`
4. `src/modules/exams/entities/exam-draft-item.entity.ts`
5. `src/modules/exams/exams.controller.ts`
6. `src/modules/exams/exam-drafts.controller.ts`
7. `src/modules/exams/exams.module.ts`
8. `src/modules/exams/tests/exams.service.spec.ts`

### 10.3 Files To Create

1. `src/modules/exams/dto/exam-lifecycle.dto.ts`
2. `src/modules/exams/dto/exam-draft-item.dto.ts`
3. `src/modules/exams/tests/exam-draft-lifecycle.service.spec.ts`
4. `src/modules/exams/tests/exam-draft-items.service.spec.ts`
5. Optional: `src/modules/exams/exam-draft-cleanup.service.ts`
6. Migration: `src/database/migrations/1780000000000-HardenQuestionBankAndExamFeatures.ts`

### 10.4 Entity Changes

Edit:

`src/modules/exams/entities/exam-draft.entity.ts`

Add:

1. `status`: `open`, `finalized`, `expired`, `cancelled`, `failed`
2. `finalizedExamId`
3. `finalizedBy`
4. `finalizedAt`
5. Optional `failureReason`

### 10.5 Service Rules

Add private method:

`assertDraftOpenAndNotExpired(draft)`

Rules:

1. If status is finalized, return existing exam or throw conflict depending endpoint.
2. If status is expired, throw conflict.
3. If `expiresAt < now`, mark expired or throw conflict.
4. If no items, throw conflict and optionally mark failed.

Add exam status state machine:

1. `draft -> published`
2. `draft -> archived`
3. `published -> archived`
4. Optional `published -> draft` only if product explicitly allows unpublish.
5. `archived` is terminal unless a future product rule says otherwise.

Add draft item manual-control rules:

1. Manual changes are allowed only for open, non-expired drafts.
2. Replacement/addition question must belong to the same course.
3. Replacement/addition question must be `approved`.
4. Replacement/addition question must match selected section/rule constraints unless instructor explicitly overrides with a tracked reason.
5. Reorder receives the full ordered list and updates transactionally.
6. Remove refuses to leave an invalid empty draft unless the endpoint intentionally marks it failed/cancelled.

### 10.5A Controller Endpoints

Add to `src/modules/exams/exams.controller.ts`:

Draft item controls:

1. `POST /api/exams/drafts/:draftId/items`
2. `PATCH /api/exams/drafts/:draftId/items/:itemId`
3. `DELETE /api/exams/drafts/:draftId/items/:itemId`
4. `PATCH /api/exams/drafts/:draftId/items/reorder`

Exam lifecycle controls:

1. `POST /api/exams/:id/publish`
2. `POST /api/exams/:id/archive`
3. `POST /api/exams/:id/unpublish` only if product allows returning a published exam to draft.

All endpoints are instructor-only and course-owned.

### 10.5B DTOs

Create `src/modules/exams/dto/exam-draft-item.dto.ts`:

1. `AddDraftItemDto`
2. `RemoveDraftItemDto`
3. `ReorderDraftItemsDto`
4. `DraftItemResponseDto`

Create or extend `src/modules/exams/dto/exam-lifecycle.dto.ts`:

1. `PublishExamDto`
2. `ArchiveExamDto`
3. Optional `UnpublishExamDto`
4. Fields: `reason`, optional `scheduledAt`, optional `confirmNoStudentDelivery`

Service methods to add:

1. `addDraftItem(draftId, dto, userId)`
2. `removeDraftItem(draftId, itemId, dto, userId)`
3. `reorderDraftItems(draftId, dto, userId)`
4. `publishExam(examId, dto, userId)`
5. `archiveExam(examId, dto, userId)`
6. Optional `unpublishExam(examId, dto, userId)`

### 10.6 Idempotent Save

Update:

`ExamsService.saveDraft`

Flow:

1. Start transaction.
2. Lock draft row if supported.
3. Load draft with items.
4. If `status = finalized` and `finalizedExamId` exists, return existing exam.
5. If expired, reject.
6. If empty, reject or mark failed.
7. Create exam.
8. Create exam items.
9. Create snapshots after Phase 6.
10. Set `status = finalized`.
11. Set `finalizedExamId`.
12. Commit.

### 10.7 Cleanup Job

Optional create:

`src/modules/exams/exam-draft-cleanup.service.ts`

If using `@nestjs/schedule`, add scheduled method:

1. Mark open drafts as expired when `expiresAt < now`.
2. Mark old empty drafts as failed.
3. Log counts.

Register in:

`src/modules/exams/exams.module.ts`

### 10.8 Migration

In:

`1780000000000-HardenQuestionBankAndExamFeatures.ts`

Add columns:

1. `exam_drafts.status`
2. `exam_drafts.finalized_exam_id`
3. `exam_drafts.finalized_by`
4. `exam_drafts.finalized_at`
5. `exam_drafts.failure_reason`
6. Optional `exams.published_at`
7. Optional `exams.published_by`
8. Optional `exams.archived_at`
9. Optional `exams.archived_by`
10. Optional `exams.status_reason`

Backfill:

1. For drafts with `expires_at < NOW()` and no matching finalized exam, set `status = expired`.
2. For drafts with no items, set `status = failed` or `expired` depending product decision.
3. Leave recent drafts with items as `open`.

### 10.9 Tests

1. Expired draft cannot be updated.
2. Expired draft cannot be saved.
3. Empty draft cannot be saved.
4. Saving finalized draft returns existing exam or conflicts.
5. Save draft is transactional.
6. Cleanup service marks expired drafts.
7. Instructor can manually add an approved same-course question to an open draft.
8. Instructor cannot manually add another course's question.
9. Instructor can remove and reorder draft items transactionally.
10. Invalid reorder payload rolls back all item order changes.
11. Publish allows only valid state transitions.
12. Archive allows only valid state transitions.
13. `STUDENT`, `TA`, and `ADMIN` receive 403 for lifecycle and manual item endpoints.

### 10.10 Acceptance Criteria

1. Expired drafts are not editable.
2. Empty drafts cannot become exams.
3. Same draft cannot create duplicate exams.
4. Live expired/empty draft issue has a planned migration cleanup.
5. Instructor can add, remove, and reorder draft items safely.
6. Exam publish/archive state transitions are explicit and tested.

## 11. Phase 6 - Immutable Exam Snapshots And Export Hardening

### 11.1 Purpose

Make saved exams stable even after question bank edits and improve export reliability.

### 11.2 Files To Edit

1. `src/modules/exams/exams.service.ts`
2. `src/modules/exams/entities/exam-item.entity.ts`
3. `src/modules/exams/exams.module.ts`
4. `src/modules/exams/tests/exams.service.spec.ts`

### 11.3 Files To Create

1. `src/modules/exams/entities/exam-item-snapshot.entity.ts`
2. `src/modules/exams/entities/exam-export.entity.ts`
3. `src/modules/exams/dto/exam-export.dto.ts`
4. `src/database/migrations/1780000000000-HardenQuestionBankAndExamFeatures.ts`

### 11.4 Entity: ExamItemSnapshot

Create:

`src/modules/exams/entities/exam-item-snapshot.entity.ts`

Fields:

1. `snapshotId`
2. `examItemId`
3. `sourceQuestionId`
4. `sourceQuestionVersionId`
5. `sectionId`
6. `questionType`
7. `questionText`
8. `optionsJson`
9. `fillBlanksJson`
10. `expectedAnswerText`
11. `hints`
12. `attachmentsJson`
13. `marks`
14. `itemOrder`
15. `createdAt`

### 11.5 Save Draft Snapshot Flow

Edit:

`src/modules/exams/exams.service.ts`

In `saveDraft`:

1. Load draft items.
2. Load questions with options, fill blanks, and attachments.
3. Create exam item.
4. Create exam item snapshot for each exam item.
5. Store exact question content at save time.
6. Use snapshots for export.

### 11.6 Export Hardening

Edit:

`src/modules/exams/exams.service.ts`

Short-term:

1. Escape all HTML values in `exportExamAsWord`.
2. Include options for MCQ/true-false.
3. Include marks.
4. Include captions and alt text.
5. Include section titles, section instructions, section marks, and item marks.
6. Preserve section order and item order.
7. Use snapshots instead of live question rows.

Later:

1. Replace base64 HTML `.doc` with real DOCX or PDF generation.
2. Stream file response for large exports.
3. Add export records.

### 11.7 Entity: ExamExport

Create:

`src/modules/exams/entities/exam-export.entity.ts`

Fields:

1. `exportId`
2. `examId`
3. `format`: `docx`, `pdf`, `html_doc`
4. `status`: `pending`, `completed`, `failed`
5. `fileId`
6. `requestedBy`
7. `createdAt`
8. `completedAt`
9. `failureReason`

### 11.8 Migration

In:

`1780000000000-HardenQuestionBankAndExamFeatures.ts`

Add tables:

1. `exam_item_snapshots`
2. `exam_exports`

Add FKs:

1. snapshot to `exam_items`.
2. export to `exams`.
3. export to `files` nullable.

### 11.9 Tests

1. Saving exam creates snapshots.
2. Editing bank question after save does not change exam snapshot.
3. Export uses snapshot text.
4. Export escapes HTML.
5. Export includes options, captions, and marks.
6. Instructor cannot export another instructor's exam.

### 11.10 Acceptance Criteria

1. Saved exams are immutable in content.
2. Export content stays stable after bank edits.
3. Export does not expose unsafe unsanitized HTML.
4. Export is instructor-only and course-owned.

## 12. Phase 7 - Approval Workflow, Soft Delete, Versioning, And Review Events

### 12.1 Purpose

Make question lifecycle stable for instructors and prevent accidental destructive changes.

### 12.2 Files To Edit

1. `src/modules/question-bank/question-bank.controller.ts`
2. `src/modules/question-bank/question-bank.service.ts`
3. `src/modules/question-bank/entities/question-bank-question.entity.ts`
4. `src/modules/question-bank/enums/question-bank.enums.ts`

### 12.3 Files To Create

1. `src/modules/question-bank/entities/question-bank-question-version.entity.ts`
2. `src/modules/question-bank/entities/question-bank-review-event.entity.ts`
3. `src/modules/question-bank/dto/question-response.dto.ts`
4. Migration: `src/database/migrations/1780000000000-HardenQuestionBankAndExamFeatures.ts`

### 12.4 Question Status Rules

Current statuses:

1. `draft`
2. `approved`
3. `archived`

Add workflow endpoints:

1. `POST /api/question-bank/questions/:id/submit-for-review`
2. `POST /api/question-bank/questions/:id/approve`
3. `POST /api/question-bank/questions/:id/reject`
4. `POST /api/question-bank/questions/:id/archive`
5. `POST /api/question-bank/questions/:id/restore`

Because current scope is instructor-only, review may be simple:

1. Instructor drafts question.
2. Instructor approves own question for generator eligibility.
3. Every status change writes review event.

### 12.5 Versioning

On update:

1. Before changing a question, write current state to `question_bank_question_versions`.
2. Include question text, type, difficulty, Bloom, options JSON, fill blanks JSON, expected answer, hints, attachment metadata.
3. Increment version number.

On exam save:

1. Store `sourceQuestionVersionId` in snapshot when available.

### 12.6 Soft Delete

Add to `question_bank_questions`:

1. `deleted_at`

Behavior:

1. Delete endpoint archives or soft deletes instead of hard removing.
2. If question is used by exam items, return 409 or archive only.
3. List excludes soft-deleted by default.
4. Instructor can filter archived/deleted if needed.

### 12.7 Migration

Create:

`src/database/migrations/1780000000000-HardenQuestionBankAndExamFeatures.ts`

Add:

1. `question_bank_questions.deleted_at`
2. `question_bank_questions.reviewed_by`
3. `question_bank_questions.reviewed_at`
4. `question_bank_questions.review_comment`
5. `question_bank_question_versions`
6. `question_bank_review_events`

### 12.8 Tests

1. Approve changes status to approved.
2. Archive hides from generation.
3. Update creates version row.
4. Delete used question does not hard delete.
5. Archived question is not selected by generator.

### 12.9 Acceptance Criteria

1. Question lifecycle is auditable.
2. Generator uses approved questions only.
3. Used questions are not destructively deleted.
4. Question updates can be traced through versions.

## 13. Phase 8 - Query, Pagination, Response DTOs, And UX Refinements

### 13.1 Purpose

Improve instructor UX and API consistency.

### 13.2 Files To Edit

1. `src/modules/question-bank/dto/question.dto.ts`
2. `src/modules/question-bank/dto/chapter.dto.ts`
3. `src/modules/question-bank/question-bank.service.ts`
4. `src/modules/exams/dto/generate-exam.dto.ts`
5. `src/modules/exams/exams.service.ts`

### 13.3 Files To Create

1. `src/modules/question-bank/dto/question-response.dto.ts`
2. `src/modules/exams/dto/exam-response.dto.ts`

### 13.4 Question Bank Improvements

DTO validation:

1. Add `@Min(1)` to `courseId`.
2. Add `@Min(1)` to `chapterId`.
3. Add `@Max(100)` to `limit`.
4. Add `@MaxLength` for captions and group titles.
5. Add strict nested validation for attachment metadata.

Query:

1. Clamp limit server-side to 100.
2. Add `search` query by text.
3. Add `hasAttachments` filter.
4. Add `groupId` filter.
5. Add `createdBy` filter only if useful for instructor.

Response:

1. Return typed response DTO.
2. Include attachments array.
3. Include group info.
4. Include `usageCount` after usage stats phase.

### 13.5 Exam Generator Improvements

Query:

1. Add `courseId` optional filter for instructor's own courses.
2. Add `status` filter.
3. Add date range filter.

Response:

1. Draft preview returns full enough item data for review.
2. Include `totalMarks`.
3. Include `marks` per item.
4. Include sections when present.
5. Include draft item IDs needed for manual add/remove/reorder UX.
6. Include exam status lifecycle fields.
7. Include shortage details unchanged.

### 13.6 Tests

1. Limit above 100 clamps or rejects.
2. Invalid course ID rejects.
3. Search/filter works for instructor-owned courses only.
4. Response includes attachments in order.
5. Exam list filters by status/course.
6. Sectioned exam responses preserve section and item order.
7. Manual draft item response contains recalculated marks.

### 13.7 Acceptance Criteria

1. API responses are stable and documented.
2. Instructor list views are efficient.
3. Frontend can render attachments/groups/sections/marks without extra guessing.
4. Frontend can build manual draft review screens without hidden backend assumptions.

## 14. Phase 9 - Observability And Operational Cleanup

### 14.1 Purpose

Make production behavior diagnosable and maintainable.

### 14.2 Files To Edit

1. `src/modules/exams/exams.service.ts`
2. `src/modules/question-bank/question-bank.service.ts`
3. `src/modules/exams/exams.module.ts`
4. `src/modules/question-bank/question-bank.module.ts`

### 14.3 Files To Create

1. `src/modules/exams/exam-draft-cleanup.service.ts`
2. `src/modules/question-bank/question-bank-cleanup.service.ts`
3. Optional: `src/modules/exams/exam-generation-logger.service.ts`

### 14.4 Logging

Replace direct `console.error` in `ExamsService.generatePreview` with Nest `Logger`.

Log:

1. generation start.
2. generation success.
3. shortage error with rule details.
4. draft save success.
5. draft save conflict/expired/empty.
6. export success/failure.

Do not log:

1. full answer keys.
2. full question text where avoidable.
3. credentials or file signed URLs.

### 14.5 Cleanup Jobs

Exam cleanup:

1. Mark expired open drafts.
2. Mark empty drafts as failed.
3. Optional delete very old failed drafts after retention.

Question bank cleanup:

1. Find orphan uploaded files not attached to any question after a retention window.
2. Find attachments whose file is deleted.
3. Find questions with invalid child structures for admin/instructor repair.

### 14.6 Metrics

If metrics infrastructure exists later, track:

1. exam generation count.
2. generation shortage count by course/rule.
3. draft save count.
4. draft save conflict count.
5. expired draft cleanup count.
6. question upload failures.
7. attachment upload failures.

### 14.7 Acceptance Criteria

1. Failures are visible in logs.
2. Expired and empty drafts do not accumulate silently.
3. Orphan files have a cleanup path.
4. Operational behavior can be investigated without DB manual digging.

## 15. Migration Execution Plan For Aiven

### 15.1 Before Applying Migrations

1. Confirm `.env` points to intended Aiven database.
2. Confirm backup exists.
3. Run read-only duplicate checks.
4. Review migration SQL.
5. Confirm no manual DBeaver schema edits are pending.

### 15.2 Migration Order

Actual implemented order:

1. `1780000000000-HardenQuestionBankAndExamFeatures.ts`
2. `1780000000001-MarkEmptyExamDraftsFailed.ts`
3. `1780000000002-VerifyQuestionBankExamConstraintsAndAddOverrideReasons.ts`

Reason:

1. Main feature schema, backfills, lifecycle/version fields, attachments, groups, marks, sections, snapshots, exports, and baseline constraints are created first.
2. Existing empty draft headers are marked failed after the lifecycle status column exists.
3. Duplicate prechecks and override-reason columns run last so constraint/index failures are reported clearly before tightening behavior.

### 15.3 Apply Command

Use existing project migration command:

```bash
npm run migration:run
```

Do not use `synchronize: true`.

### 15.4 Post-Migration Checks

Run read-only checks:

1. Tables exist.
2. Constraints exist.
3. Existing question file IDs were backfilled into attachments.
4. `exam_draft_sections` and `exam_sections` exist if section phase is implemented.
5. Expired drafts are marked expired.
6. Empty drafts are marked failed or otherwise handled.
7. Existing exams still load.
8. Existing exam total weights still match item sums.
9. Strict instructor ownership data exists in `course_instructors -> course_sections` for courses that should be manageable.

## 16. Recommended Implementation Order

Use this order to reduce risk:

1. Phase 0: instructor-only access and ownership.
2. Phase 1: transactions and current integrity fixes.
3. Phase 5: draft lifecycle and cleanup, because live Aiven already has expired/empty drafts.
4. Phase 4: total marks and item marks.
5. Phase 4A: exam sections, because marks/export/manual review need section structure.
6. Phase 2: attachments and captions.
7. Phase 3: plain bulk create, question groups, and grouped batch creation.
8. Phase 6: snapshots and export hardening.
9. Phase 7: approval/versioning/soft delete.
10. Phase 8: query and response polish.
11. Phase 9: observability and cleanup.

Reason:

1. Security must happen first.
2. Transaction safety should happen before adding more tables.
3. Draft lifecycle is urgent because live data already shows expired and empty drafts.
4. Mark distribution affects core exam generation.
5. Sections should be introduced before final export hardening so saved/exported exams have a stable structure.
6. Attachments/groups/plain bulk create expand authoring features after the base is safer.

## 17. Final Acceptance Checklist

Security:

1. All target endpoints are instructor-only.
2. Instructor ownership is checked for every course-scoped operation.
3. `STUDENT`, `TA`, and `ADMIN` receive 403.
4. Cross-course instructor access receives 403.

Question bank:

1. Instructor can create, list, get, update, archive/delete questions in owned courses.
2. Create/update is transactional.
3. Patch does not rewrite children unless requested.
4. Type switching clears incompatible children.
5. Multiple images per question work.
6. Captions and alt text work.
7. Plain bulk question create works for unrelated questions.
8. Batch related questions work.
9. Question versions/review events exist.

Exam generator:

1. Instructor can generate exam draft for owned course.
2. Shortage response is structured.
3. Draft creation is transactional.
4. Expired drafts cannot be updated/saved.
5. Empty drafts cannot be saved.
6. Draft save is idempotent.
7. Total marks and item marks are correct.
8. Replacement question validation is strict.
9. Manual draft add/remove/reorder works transactionally.
10. Exam sections work for draft, final exam, and export responses.
11. Publish/archive lifecycle is explicit and tested.
12. Saved exam has immutable item snapshots.
13. Export uses snapshots and escapes content.

Database:

1. All new schema exists through migrations.
2. Constraints are added after cleanup.
3. Existing Aiven data remains readable.
4. No manual dump-file changes are required.

Tests:

1. Unit tests cover service logic.
2. Controller tests cover roles.
3. Transaction tests cover rollback paths.
4. Migration checks are documented.
5. Export tests cover escaping and snapshot usage.
