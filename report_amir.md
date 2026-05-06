# Comprehensive Investigation Report
## Target Features: Question Bank Saving + Exam Generator

## 1) Investigation scope and method

This report is based on **static backend code investigation only** (no runtime execution, no code logic changes).

Reviewed modules and related files:

- Question Bank:
  - `src\modules\question-bank\question-bank.controller.ts`
  - `src\modules\question-bank\question-bank.service.ts`
  - `src\modules\question-bank\dto\question.dto.ts`
  - `src\modules\question-bank\dto\chapter.dto.ts`
  - `src\modules\question-bank\entities\*`
  - `src\modules\question-bank\tests\question-bank.service.spec.ts`
- Exam Generator:
  - `src\modules\exams\exams.controller.ts`
  - `src\modules\exams\exam-drafts.controller.ts`
  - `src\modules\exams\exams.service.ts`
  - `src\modules\exams\dto\generate-exam.dto.ts`
  - `src\modules\exams\entities\*`
  - `src\modules\exams\tests\exams.service.spec.ts`
- Cross-cutting:
  - `src\database\migrations\1778000000000-CreateQuestionBankAndExams.ts`
  - `src\modules\auth\guards\roles.guard.ts`
  - `src\modules\files\*` (upload/storage behavior used by question images)

---

## 2) Arabic messages interpretation and exact status

| Arabic message | Intended requirement | Current status |
|---|---|---|
| انا عامل يرفع صورة واحدة مع السؤال ، خليه يقدر يرفع كذا صورة | Multiple images per question | **Not implemented** |
| ... يرفع سؤال واحد ... عايزين يقدر يرفع كذا سؤال ليهم علاقة ببعض | Batch create related/multipart questions | **Not implemented** |
| نقدر نضيف caption للصورة | Image caption metadata | **Not implemented** |
| نقدر نحدد الدرجة للامتحان ككل و weight كل سؤال ... و يعمل حساباته بحيث يطلع درجة كل سؤال | Exam total grade + per-question weights + computed per-question marks | **Partially implemented** (weights and total weight sum exist; total-mark-driven distribution does not) |

---

## 3) Current implemented capabilities (what exists now)

## 3.1 Question Bank (implemented)

1. Chapter CRUD by course.
2. Question CRUD.
3. Question image upload endpoint (`POST /api/question-bank/questions/upload-image`).
4. Question classification:
   - type, difficulty, Bloom, status.
5. Type-specific payload validation:
   - MCQ, True/False, Fill blanks, Written/Essay.
6. Supports text-based and file-based question body (`questionText` or `questionFileId`).

## 3.2 Exam Generator (implemented)

1. Rule-based draft generation (`POST /api/exams/generate-preview`).
2. Uses approved bank questions only during generation.
3. Supports filters per rule:
   - chapter, type, difficulty, Bloom.
4. Draft editing (`PATCH /api/exams/drafts/:draftId/items/:itemId`):
   - replacement question, weight, order.
5. Draft save to final exam (`POST /api/exams/drafts/:draftId/save`).
6. Stores and returns total exam weight (sum of item weights).
7. Word export endpoint (`POST /api/exams/:id/export-word`).

---

## 4) Detailed issues, risks, and fixes

Severity legend:
- **Critical**: security/data-leak/integrity risk
- **High**: major correctness or reliability risk
- **Medium**: functional gap or maintainability concern
- **Low**: quality/consistency concern

## 4.1 Question Bank issues

| ID | Severity | Finding | Evidence | Suggested fix |
|---|---|---|---|---|
| QB-01 | High | Only one image per question is supported. | `questionFileId` single FK in `question-bank-question.entity.ts`; single file interceptor in `question-bank.controller.ts` | Add `question_attachments` table (1:N), support `FilesInterceptor`, keep backward compatibility for old `questionFileId`. |
| QB-02 | High | No batch create for related questions / multipart question groups. | Only `POST /api/question-bank/questions` single-item endpoint | Add `POST /api/question-bank/questions/batch` and `question_group_id` model; transactional bulk save. |
| QB-03 | High | No caption metadata for question images. | No caption in DTO/entity/upload endpoint | Add attachment metadata (`caption`, `altText`, `displayOrder`, `kind`) per image. |
| QB-04 | **Critical** | Students can access question bank and receive sensitive answer fields. | `@Roles(...STUDENT)` on list/get in controller; entity includes `expectedAnswerText`, `hints`; options include `isCorrect` | Add role-based response shaping (public DTO for student), hide correctness/expected answers/hints from students. |
| QB-05 | **Critical** | Role-only authorization without resource ownership/enrollment checks. | `roles.guard.ts` checks roles only; service only `ensureCourseExists` / `ensureChapterExists` | Add course-scope authorization guard (instructor-of-course / student-enrolled-in-course). |
| QB-06 | High | Students can query questions without default status restriction. | `listQuestions` filters by status only if query provided | Force student queries to approved/public status only. |
| QB-07 | High | Update operation re-writes child options/blanks even when not requested. | `findQuestionById` loads children + `replaceQuestionChildren` condition uses `source.options !== undefined` | Change patch logic to update children only when `dto.options`/`dto.fillBlanks` are explicitly provided. |
| QB-08 | High | Type switching can preserve stale child rows (e.g., essay with MCQ options). | `validateQuestionPayload` doesn’t reject extra type-incompatible child data; replace flow can reinsert old children | Add strict normalization: when type changes, clear incompatible child tables and reject incompatible payload fields. |
| QB-09 | High | Create/update question with child rows is not transactional. | `save(question)` then `replaceQuestionChildren` separate operations | Wrap parent+child writes in DB transaction. |
| QB-10 | High | Image upload is a dual-write (local files + Supabase) without rollback compensation. | `filesService.uploadFile` then Supabase upload in `uploadQuestionImage` | Add transactional-outbox or compensation delete on failure; or unify to one storage backend. |
| QB-11 | Medium | `ensureFileExists` validates existence only, not ownership/type/context. | `ensureFileExists` just `fileRepo.exist({ fileId })` | Validate uploaded file belongs to allowed question-image source and user/course scope. |
| QB-12 | Medium | Pagination limit has no upper bound (possible heavy queries). | DTO `limit` has `@Min(1)` but no max; service uses raw limit | Add `@Max(100)` and server-side clamp. |
| QB-13 | Medium | `questionImageUrl` is added via `(question as any)` dynamic mutation. | `attachQuestionImageUrls` uses `as any` | Use explicit response DTO with typed `questionImageUrl`. |
| QB-14 | Medium | Hard delete may fail with DB FK restrictions when question used by exams; error handling not user-friendly. | `deleteQuestion` uses remove; exam tables use `ON DELETE RESTRICT` | Introduce soft delete/archive and “in-use” checks with clear conflict responses. |
| QB-15 | Medium | Chapter uniqueness conflicts likely return raw DB errors. | Unique indexes on chapter name/order; no service-level conflict handling | Catch DB duplicate-key exceptions and return clear 409 conflict messages. |
| QB-16 | Medium | Signed URL generation done at read time and can become expensive. | `listQuestions` -> `attachQuestionImageUrls` each request | Cache short-lived URLs or return storage keys + dedicated signed URL endpoint. |
| QB-17 | Medium | Test suite appears stale relative to service constructor and config requirements. | `QuestionBankService` constructor requires `ConfigService`; spec initializes with fewer dependencies | Update tests/mocks to current constructor and add behavior-focused tests for security and type transitions. |

## 4.2 Exam Generator issues

| ID | Severity | Finding | Evidence | Suggested fix |
|---|---|---|---|---|
| EX-01 | **Critical** | No course-level authorization for list/read/update/save operations. | Service methods query by IDs without ownership/enrollment check | Add course access guard for each endpoint and service-level checks. |
| EX-02 | **Critical** | Exam and draft listing can expose cross-course data to unauthorized users with same role. | `findExams` and `findDrafts` have no `courseId/user` scoping | Scope queries by authorized courses and role context. |
| EX-03 | High | Replacement question can come from another course and non-approved status. | `updateDraftItem` finds replacement by `id` only | Enforce same course + approved status + optional chapter/type constraints. |
| EX-04 | High | Replacement can duplicate an existing question in the same draft. | No duplicate check in `updateDraftItem` | Add uniqueness validation per draft (`questionId` unique within draft). |
| EX-05 | High | Draft expiration exists in schema but not enforced anywhere. | `expiresAt` set on create, no checks/cleanup usage | Enforce expiry checks on read/update/save and schedule cleanup job. |
| EX-06 | High | Saving same draft multiple times can create duplicate exams. | `saveDraft` does not mark draft consumed/finalized | Add idempotency: draft state (`open/finalized`) and one-way transition. |
| EX-07 | High | No transactions around exam creation + item insertion. | `saveDraft` saves exam then items separately | Use transaction and rollback on partial failure. |
| EX-08 | High | Generic catch in generation downgrades error structure and status semantics. | `catch(e)` + `throw new BadRequestException(e.message)` | Preserve original exceptions; only wrap unknown errors. |
| EX-09 | Medium | Non-null assertions on `questionMap.get(...)!` can crash under race conditions. | `questionMap.get(item.questionId)!...` | Validate map entries and return controlled conflict error. |
| EX-10 | Medium | No uniqueness constraints for `item_order` per draft/exam. | Index exists, not unique (`exam-draft-item.entity.ts`, migration) | Add unique constraints on `(draft_id,item_order)` and `(exam_id,item_order)`. |
| EX-11 | Medium | API duplication increases maintenance risk. | `/api/exams/drafts*` and `/api/exam-drafts*`; plus `/list` aliases | Consolidate canonical routes and keep aliases deprecated with clear timeline. |
| EX-12 | Medium | Scoring model is incomplete for requested “total exam grade + computed item marks”. | Has `weightPerQuestion` and `totalWeight` sum only | Add `totalMarks` input and distribution strategy (manual/auto/normalized). |
| EX-13 | Medium | Word export is plain HTML text; images/captions unsupported; potential formatting/injection concerns. | `exportExamAsWord` builds HTML string directly | Use robust document rendering pipeline, sanitize text, support media embedding and captions. |
| EX-14 | Medium | Status lifecycle exists in enum but missing publish/archive workflow endpoints. | `exam.entity.ts` has statuses; controller lacks publish/archive/update status | Add lifecycle endpoints with permission and state machine checks. |
| EX-15 | Medium | Generation loop can issue repeated queries per rule and scale poorly. | Per-rule chapter existence and candidate query in loop | Preload chapter validity and optimize candidate retrieval with grouped queries/caching. |
| EX-16 | Medium | Validation gaps in DTO: rules array allows empty at DTO level; weights allow 0 without business policy. | `rules` has `@IsArray()` but no `ArrayMinSize`; `@Min(0)` on weights | Add stricter validation and business constraints. |

---

## 5) Architecture-level stability concerns

1. **RBAC vs ABAC gap**  
   Current guard is role-only; system needs resource-scope authorization (course membership/ownership).

2. **Missing transactional boundaries**  
   Critical write flows are multi-step and non-atomic in both target features.

3. **Data leakage risk by entity-level exposure**  
   Entities are returned directly to client in several endpoints; sensitive fields are not role-filtered.

4. **Storage consistency gap**  
   Question image flow currently writes to two storage systems with no consistency contract.

5. **Lifecycle incompleteness**  
   Draft expiry and exam status lifecycle are partially modeled but not operationally enforced.

---

## 6) Suggested fix roadmap (prioritized)

## Phase 0 (urgent risk reduction)

1. Restrict sensitive responses for students (hide answers/hints/correct flags).
2. Add course-scope authorization checks across question bank and exams.
3. Enforce draft expiration and block stale draft operations.
4. Replace generic catch/rethrow in exam generation with proper exception propagation.

## Phase 1 (data integrity and correctness)

1. Add transactions for:
   - question create/update + children
   - draft save -> exam + exam items
2. Validate replacement question constraints (same course, approved, no duplicates).
3. Fix question update child rewrite logic (patch only touched children).
4. Add unique constraints for exam/draft item order and handle conflicts gracefully.

## Phase 2 (feature completion for requested Arabic requirements)

1. Multi-image per question:
   - attachment table + order.
2. Image caption support:
   - caption/alt metadata per image.
3. Batch related question save:
   - group model + bulk create endpoint.
4. Total-grade-driven scoring:
   - explicit exam total marks and auto distribution algorithm.

## Phase 3 (operational robustness)

1. Idempotent draft finalization and draft state machine.
2. Background jobs:
   - expired draft cleanup
   - orphan image/file cleanup
3. Better observability:
   - structured logs/metrics for generation failures, shortage patterns, latency.
4. Expand tests (unit + integration + authorization + migration constraints).

---

## 7) Enhancement proposals (to make system more stable and production-ready)

## 7.1 Question Bank enhancements

1. **Versioning and audit trail** for questions/options/blanks.
2. **Approval workflow** with reviewer, rejection reasons, and publish gates.
3. **Usage analytics** (`use_count`, last_used_at, discrimination indices, difficulty drift).
4. **Tagging and outcomes model**:
   - learning outcomes
   - topic tags
   - cognitive objective mapping.
5. **Bulk import/export** (CSV/Excel/QTI/JSON) with validation reports.
6. **Duplicate detection** for near-identical questions.
7. **Soft delete + restore** instead of hard delete.
8. **Media management enhancements**:
   - multiple attachments
   - caption/alt
   - crop/focal metadata
   - attachment reuse registry.

## 7.2 Exam Generator enhancements

1. **Blueprint engine** (target percentages by chapter/type/difficulty/Bloom/outcome).
2. **Auto-mark allocation** from `totalMarks` with rounding policy.
3. **Sectioned exams** (A/B/C sections, optional blocks, mandatory counts).
4. **Manual add/remove item endpoints** with consistent ordering semantics.
5. **Publish/schedule/archive lifecycle** for generated exams.
6. **Multiple export formats** (PDF, DOCX, JSON) with media embedding.
7. **Idempotency keys** for generation/save endpoints to avoid duplicates.
8. **Concurrency safety**:
   - optimistic lock/version field on drafts
   - conflict-aware updates.

---

## 8) Necessary missing features (high business value, currently absent)

1. **Resource-scoped authorization** (course-level ABAC) for all endpoints.
2. **Student-safe response contracts** (public/private DTO separation).
3. **Draft expiration policy enforcement + cleanup job**.
4. **Question attachment model with caption support**.
5. **Batch related question authoring** (multipart/group questions).
6. **Total exam marks + automatic marks distribution**.
7. **Publish workflow for exams module** (not just draft save).
8. **Reliable transactions and idempotency for write-critical operations**.
9. **Comprehensive test coverage for security + data integrity paths**.

---

## 9) Final assessment

The backend provides a solid baseline for both target features, but currently behaves as a **functional prototype** rather than a **hardened production subsystem**.  
The largest gaps are in:

1. **Security and data exposure controls**,
2. **Transactional integrity and lifecycle enforcement**,
3. **Missing requested authoring capabilities** (multi-image, caption, related batch questions),
4. **Incomplete grading model** for total-mark-driven exam construction.

Addressing the Phase 0 and Phase 1 items first will materially improve stability and safety before adding advanced feature enhancements.

