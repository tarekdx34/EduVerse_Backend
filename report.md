# EduVerse Question Bank Plan vs Backend Implementation Report

## 1) Scope Reviewed

This report compares:

1. **Your plan/spec HTML**: `C:\Users\am356\Downloads\eduverse_question_bank_spec.html` (read end-to-end, lines 1–1070).
2. **Implemented backend code** in this repo for question bank and related exam generation/assessment:
   - `src/modules/question-bank/*`
   - `src/modules/exams/*`
   - Related DB migrations:
     - `src/database/migrations/1778000000000-CreateQuestionBankAndExams.ts`
     - `src/database/migrations/1779000000000-SeedWebDevQuestions.ts`
   - Related assessment module context:
     - `src/modules/quizzes/*`

---

## 2) Executive Summary

**Result:** The backend implements a **strong core subset** of your idea (question bank CRUD + classification + exam draft generation), but there are major gaps versus your full concept (learning outcomes, richer media model, matching type in question bank, separate written-answer/rubric model, soft delete, `/api/v1` contract, publish/export model, and analytics).

### High-level alignment

| Area | Alignment |
|---|---|
| Question bank CRUD | **Implemented** |
| Core taxonomy (type, difficulty, Bloom) | **Implemented** |
| Exam generation from bank | **Implemented (different model)** |
| Chapter/topic organization | **Implemented (via `course_chapters`)** |
| Learning outcomes | **Not implemented** |
| Rich media array model | **Partially implemented (single file FK only)** |
| Matching question type (in question bank) | **Not implemented** |
| Dedicated written answers/rubrics table | **Not implemented** |
| API shape from spec (`/api/v1/...`) | **Not implemented** |
| Supabase/RLS architecture | **Not implemented** (NestJS + MySQL) |

---

## 3) Section-by-Section Comparison (Spec vs Reality)

## 3.1 Overview / Feature Set

### Agreements
- Question bank module exists.
- Exam generator module exists.
- Live editing exists at draft-item level (replace question, reorder, adjust weight).
- Bloom + difficulty + type classification exists.

### Differences
- Your spec emphasizes **learning outcome-driven generation** and **bank analytics health dashboards**; backend currently does not store learning outcomes and has no dedicated question-bank health endpoint/dashboard.
- Your spec proposes broader exam finalization/publish/export flows; backend has only draft save + Word export for exams module (publish is in quizzes module, not exam-draft flow).

---

## 3.2 Question Creation Interface / Fields

## Implemented fields (question bank DTO/entity)

From `CreateQuestionBankQuestionDto` + `QuestionBankQuestion`:
- `courseId`, `chapterId`
- `questionType` (`written`, `mcq`, `true_false`, `fill_blanks`, `essay`)
- `difficulty` (`easy`, `medium`, `hard`)
- `bloomLevel` (`remembering` ... `creating`)
- `questionText` (optional if file exists)
- `questionFileId` (single file reference)
- `expectedAnswerText`
- `hints`
- `status` (`draft`, `approved`, `archived`)
- options array (`optionText`, `isCorrect`)
- fillBlanks array (`blankKey`, `acceptableAnswer`, `isCaseSensitive`)

### Agreements
- Dynamic validation by question type is implemented:
  - MCQ: minimum options + at least one correct
  - True/False: exactly 2 options + exactly one correct
  - Fill blanks: at least one blank
  - Written/Essay: expected answer required
- Supports private answer guidance (`hints`, `expectedAnswerText`) similar to instructor context fields.

### Differences
- **Missing planned fields**:
  - `learning_outcome`
  - `media_urls` array
  - `topic_tag`
  - `instructor_note` (explicit dedicated field)
  - `use_count`
- **Media model mismatch**:
  - Plan: multiple media URLs
  - Actual: one `question_file_id` FK
- **Question type mismatch**:
  - Plan includes `matching`
  - Question bank enum does not include matching
  - (Matching exists in quizzes module, not question-bank module)
- **Option feedback text** (planned) is not stored in `question_bank_options`.

---

## 3.3 Exam Generator Logic

## Implemented behavior (`ExamsService.generatePreview`)

- Input model: `courseId`, `title`, `rules[]`, optional `seed`.
- Each rule has:
  - `chapterId`
  - `count`
  - `weightPerQuestion`
  - optional `questionType`, `difficulty`, `bloomLevel`
- Selection:
  - query approved question pool by course/chapter + optional filters
  - exclude already selected IDs
  - deterministic seeded shuffle
  - take first N
- On shortages: returns structured error with required/available per bucket.
- Stores draft in:
  - `exam_drafts`
  - `exam_draft_items`

### Agreements
- Randomized auto-selection from question bank.
- No-repeat selection.
- Explicit shortage handling (bank insufficiency warning behavior conceptually present).
- Editable draft before saving final exam.

### Differences
- Plan algorithm references **subject × type × difficulty × learning outcome** and weighted reservoir behavior; implementation uses **chapter-driven rules** and seeded shuffle.
- No learning outcome filtering.
- No global “difficulty distribution across full set” engine exactly as described.
- No explicit endpoint to remove draft item; only patch update/replacement/order/weight.

---

## 3.4 API Contract Comparison

## Planned API (spec)
- Question bank under `/api/v1/questions...`
- Exam builder under `/api/v1/exams...`
- Includes publish and export (`pdf|json`) endpoints in exam resource group.

## Actual API (implemented)

### Question bank/chapter
- `POST /api/courses/:courseId/chapters`
- `GET /api/courses/:courseId/chapters`
- `PATCH /api/courses/:courseId/chapters/:chapterId`
- `DELETE /api/courses/:courseId/chapters/:chapterId`
- `POST /api/question-bank/questions`
- `GET /api/question-bank/questions`
- `GET /api/question-bank/questions/:id`
- `PATCH /api/question-bank/questions/:id`
- `DELETE /api/question-bank/questions/:id`

### Exams (question-bank powered)
- `POST /api/exams/generate-preview`
- `PATCH /api/exams/drafts/:draftId/items/:itemId`
- `POST /api/exams/drafts/:draftId/save`
- `GET /api/exams/:id`
- `POST /api/exams/:id/export-word`

### Related quizzes module (separate flow)
- `PATCH /api/quizzes/:id/status` (publish/close/archive for quiz objects)
- attempts, grading, statistics, progress endpoints exist there.

### Key API differences
- No `/api/v1` namespace.
- Question resource naming differs (`question-bank/questions` vs `questions`).
- No `GET /api/.../questions/stats` in question-bank module.
- Exam export differs: implemented Word export (base64 doc), not `pdf|json`.
- Question delete is hard delete, not soft delete.

---

## 3.5 Database Architecture Comparison (Tables + Columns)

## Planned tables (spec)
- `questions`
- `answer_options`
- `written_answers`
- `exams`
- `exam_questions`
- `subjects`

## Implemented tables (migration + entities)
- `course_chapters`
- `question_bank_questions`
- `question_bank_options`
- `question_bank_fill_blanks`
- `exam_drafts`
- `exam_draft_items`
- `exams`
- `exam_items`

## Column-level mapping

### A) Questions

| Planned (`questions`) | Implemented (`question_bank_questions`) | Status |
|---|---|---|
| `id` | `question_id` | Match (renamed) |
| `instructor_id` | `created_by` / `updated_by` | Partial |
| `subject_id` | `course_id` + `chapter_id` | Different model |
| `question_text` | `question_text` | Match |
| `question_type` | `question_type` | Match |
| `difficulty` | `difficulty` | Match |
| `blooms_level` | `bloom_level` | Match |
| `learning_outcome` | — | Missing |
| `media_urls` (`text[]`) | `question_file_id` | Partial (single FK only) |
| `topic_tag` | — (`chapter` used structurally) | Missing direct field |
| `instructor_note` | — (closest: `hints`) | Missing direct field |
| `use_count` | — | Missing |
| `created_at` | `created_at` (+ `updated_at`) | Match+ |

### B) Options

| Planned (`answer_options`) | Implemented (`question_bank_options`) | Status |
|---|---|---|
| `id` | `option_id` | Match (renamed) |
| `question_id` | `question_id` | Match |
| `option_text` | `option_text` | Match |
| `is_correct` | `is_correct` | Match |
| `option_order` | `option_order` | Match |
| `feedback_text` | — | Missing |

### C) Written answers

| Planned (`written_answers`) | Implemented | Status |
|---|---|---|
| Separate table with `model_answer`, `keywords`, `rubric_json`, `max_score` | No separate table; uses `expected_answer_text` and `hints` in question row | Not implemented as designed |

### D) Exams

| Planned (`exams`) | Implemented (`exams`) | Status |
|---|---|---|
| `id` | `exam_id` | Match (renamed) |
| `instructor_id` | `created_by` | Partial |
| `subject_id` | `course_id` | Different model |
| `title` | `title` | Match |
| `status` | `status` (`draft/published/archived`) | Match |
| `generation_params` | `snapshot_json` | Partial (different semantics) |
| `total_marks` | `total_weight` | Similar concept, different naming/meaning |
| `instructions` | — | Missing |
| `created_at` | `created_at` (+ `updated_at`) | Match+ |

### E) Exam questions/items

| Planned (`exam_questions`) | Implemented (`exam_items` + `exam_draft_items`) | Status |
|---|---|---|
| `exam_id` | `exam_id` / `draft_id` | Match via split model |
| `question_id` | `question_id` | Match |
| `position_order` | `item_order` | Match |
| `points` | `weight` | Similar concept |
| `is_manually_added` | — | Missing |

### F) Subjects

| Planned (`subjects`) | Implemented | Status |
|---|---|---|
| Dedicated `subjects` table | Uses existing `courses` (+ `course_chapters`) | Different architecture |

---

## 3.6 Service/Function Comparison

## Implemented key functions

### `QuestionBankService`
- Chapter CRUD:
  - `createChapter`, `listChapters`, `updateChapter`, `deleteChapter`
- Question CRUD:
  - `createQuestion`, `listQuestions`, `findQuestionById`, `updateQuestion`, `deleteQuestion`
- Core logic:
  - `validateQuestionPayload`
  - `replaceQuestionChildren`
  - existence guards for course/chapter/file

### `ExamsService`
- `generatePreview`
- `updateDraftItem`
- `saveDraft`
- `findExamById`
- `exportExamAsWord`
- deterministic shuffle utility

### Related `QuizzesService` (separate assessment path)
- quiz publish/change status
- question management inside quizzes
- attempts, submission, grading, statistics

### Differences vs planned functional scope
- No learning outcome-aware generation function.
- No direct exam “publish” function in exams module.
- No PDF/JSON exam export in exams module.
- No explicit bank stats endpoint in question-bank module.
- No question use-count increment mechanism tied to exam generation.

---

## 3.7 Infrastructure / Technology Alignment

## Planned
- Supabase (PostgreSQL), tRPC-oriented architecture in examples.

## Implemented
- NestJS + TypeORM + **MySQL** (`AppModule` DB config).
- Migration-managed schema in repo.
- No Supabase/RLS isolation layer for question bank.

### Outcome
- Architecture is production-capable, but it diverges from your recommended Supabase isolation approach and API style.

---

## 3.8 Agreements Checklist (What already matches well)

- Question bank CRUD with role-based guards.
- Core pedagogical tagging: type, difficulty, Bloom.
- Support for MCQ / True-False / Fill-blanks / Written / Essay.
- Exam draft generation with randomization and no duplicates.
- Draft editing and final exam save.
- Chapter-based organization under course context.

---

## 3.9 Gaps Checklist (Main differences to close)

1. Add `learning_outcome` to data model, DTOs, filters, and generation rules.
2. Add richer media model (`media_urls[]` or dedicated attachments table per question).
3. Add missing metadata fields (`topic_tag`, `instructor_note`, `use_count`).
4. Add option-level `feedback_text`.
5. Add matching type support in question-bank module (not only quizzes).
6. Decide on separate `written_answers`/rubric model vs keeping denormalized fields.
7. Add bank stats endpoint (`count by type/difficulty/bloom/outcome`).
8. Add soft-delete strategy for question bank.
9. Expand exams module: publish endpoint + export formats (PDF/JSON) + instructions field.
10. Align API contract/versioning with desired `/api/v1` design if required.

---

## 4) Final Verdict

The current backend is **not a 1:1 implementation** of your spec, but it is a **solid foundation** that already covers the core operational workflow. The largest strategic gaps are in **metadata richness (learning outcomes/media/tags), API contract alignment, advanced exam lifecycle features, and analytics/statistics around the question bank**.

