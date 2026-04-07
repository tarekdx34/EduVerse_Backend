# Frontend Migration Guide: Google Drive Integration

> **Purpose**: This document describes the backend API changes for Google Drive integration in assignments and labs. Use this as a prompt/guide for updating the frontend to work with the new response formats and features.

---

## Summary of Backend Changes

The backend now integrates Google Drive for file storage. All file uploads (instructions, submissions) are stored in Google Drive with organized folder structures. The API response formats have changed to include `driveFile` objects with preview/download URLs.

---

## 🔄 CRITICAL: Response Format Changes

### 1. Submission Objects Now Include `driveFile`

**BEFORE** (old format):
```typescript
interface AssignmentSubmission {
  id: number;
  assignmentId: number;
  userId: number;
  fileId: number | null;  // Was a local file ID or null
  submissionText: string | null;
  submissionLink: string | null;
  // ... other fields
}
```

**AFTER** (new format):
```typescript
interface AssignmentSubmission {
  id: number;
  assignmentId: number;
  userId: number;
  fileId: number | null;  // Now references drive_files.drive_file_id
  submissionText: string | null;
  submissionLink: string | null;
  // ... other fields
  
  // ⭐ NEW: Attached DriveFile object when fileId is not null
  driveFile: DriveFile | null;
}

interface DriveFile {
  driveId: string;           // Google Drive file ID
  fileName: string;          // Original file name
  webViewLink: string;       // Google Drive view URL (opens in new tab)
  iframeUrl: string;         // Embeddable preview URL (for iframe)
  downloadUrl: string;       // Direct download URL
}
```

**Same change applies to:**
- `LabSubmission` objects
- Any endpoint returning submission data

---

### 2. Assignment/Lab Detail Now Includes `instructionFiles`

**BEFORE**:
```typescript
interface Assignment {
  id: number;
  title: string;
  description: string;
  instructions: string;  // Markdown text only
  // ...
}
```

**AFTER**:
```typescript
interface Assignment {
  id: number;
  title: string;
  description: string;
  instructions: string;  // Markdown text
  // ...
  
  // ⭐ NEW: Array of instruction files from Google Drive
  instructionFiles: DriveFile[];
}
```

**Same change applies to:**
- `Lab` objects from `GET /api/labs/:id`

---

### 3. Upload Endpoint Response Changed

**BEFORE** (old format):
```typescript
// POST /api/assignments/:id/submissions/upload
// Response:
{ fileId: number }
```

**AFTER** (new format):
```typescript
// POST /api/assignments/:id/submissions/upload
// Response:
{
  submission: {
    id: number;
    assignmentId: number;
    userId: number;
    fileId: number;
    submissionStatus: 'submitted';
    isLate: number;
    attemptNumber: number;
    submittedAt: string;
    // ...
  };
  driveFile: {
    driveFileId: number;
    driveId: string;
    fileName: string;
    webViewLink: string;
    webContentLink: string;
  };
  isLate: boolean;
}
```

**Key Change**: Upload now creates/updates the submission automatically. You no longer need a separate `POST /submit` call after uploading a file.

---

## 🎯 Frontend Components to Update

### For Claude/AI Prompt:

```
Update the frontend to handle Google Drive integration changes in assignments and labs:

1. **Submission Display Components** (`MySubmission.tsx`, `SubmissionList.tsx`):
   - Check for `submission.driveFile` object (not just `fileId`)
   - If `driveFile` exists, display:
     - File name as link to `driveFile.webViewLink` (opens Google Drive)
     - "Preview" button that opens `driveFile.iframeUrl` in modal/iframe
     - "Download" button that uses `driveFile.downloadUrl`
   - If `driveFile` is null but `submissionText` exists, show text
   - If `driveFile` is null but `submissionLink` exists, show link

2. **File Preview Component** (new or updated `FilePreviewer.tsx`):
   - Accept `driveFile` prop with `iframeUrl`
   - Render iframe: <iframe src={driveFile.iframeUrl} />
   - Add fullscreen toggle button
   - Works for PDFs, docs, images, etc.

3. **Assignment/Lab Detail Components**:
   - Check for `instructionFiles` array
   - Display list of downloadable instruction files
   - Each file shows: name, preview button, download button
   - Use same preview modal as submissions

4. **Submission Upload Flow**:
   - `POST /api/assignments/:id/submissions/upload` now returns full submission
   - No need for separate `/submit` call when uploading file
   - Update success handling to use returned `submission` and `driveFile`

5. **Instructor Grading View** (see detailed section below):
   - Show submitted file in preview iframe
   - Grade form alongside file preview
```

---

## 📋 Instructor Grading Workflow (NEW)

### API Endpoints for Grading

#### 1. Get All Submissions (Instructor/TA)

```typescript
// GET /api/assignments/:assignmentId/submissions
// Headers: Authorization: Bearer <token>

// Response:
{
  data: [
    {
      id: 30,
      assignmentId: 52,
      userId: 57,
      user: {
        userId: 57,
        firstName: "Student",
        lastName: "Tarek",
        email: "student.tarek@example.com"
      },
      fileId: 9,
      submissionText: null,
      submissionLink: null,
      submissionStatus: "submitted",  // or "graded"
      isLate: 0,
      attemptNumber: 1,
      submittedAt: "2026-04-07T12:20:53Z",
      score: null,        // null if not graded
      feedback: null,     // null if not graded
      gradedBy: null,
      gradedAt: null,
      driveFile: {        // ⭐ Attached for viewing submitted file
        driveId: "1ra843elXnUDC6AEoJzcyL5vE3r3BEOOY",
        fileName: "Assignment_52_Submission_20260407.txt",
        webViewLink: "https://drive.google.com/file/d/.../view",
        iframeUrl: "https://drive.google.com/file/d/.../preview",
        downloadUrl: "https://drive.google.com/uc?id=...&export=download"
      }
    },
    // ... more submissions
  ],
  meta: {
    total: 25,
    page: 1,
    limit: 20,
    totalPages: 2
  }
}
```

#### 2. Get Single Submission Detail

```typescript
// GET /api/assignments/:assignmentId/submissions/:submissionId
// Headers: Authorization: Bearer <token>

// Same response format as single item from list above
```

#### 3. Grade a Submission

```typescript
// PATCH /api/assignments/:assignmentId/submissions/:submissionId/grade
// Headers: Authorization: Bearer <token>
// Body:
{
  score: 85,
  feedback: "Good work! Consider adding more examples in future submissions."
}

// Response: Updated submission object with score, feedback, gradedBy, gradedAt filled in
```

#### Same endpoints for Labs:
- `GET /api/labs/:labId/submissions`
- `GET /api/labs/:labId/submissions/:submissionId`
- `PATCH /api/labs/:labId/submissions/:submissionId/grade`

---

## 🖥️ Instructor Grading UI Component Specification

### Component: `SubmissionGrader.tsx`

```typescript
interface SubmissionGraderProps {
  submission: AssignmentSubmission | LabSubmission;
  maxScore: number;
  onGrade: (score: number, feedback: string) => Promise<void>;
  onNext?: () => void;  // Navigate to next ungraded
  onPrev?: () => void;  // Navigate to previous
}
```

### Recommended Layout:

```
┌─────────────────────────────────────────────────────────────────────┐
│  ← Back to List          Assignment: Research Paper                 │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  Student: John Doe (john.doe@example.com)                           │
│  Submitted: April 7, 2026 at 2:30 PM                               │
│  Status: On Time ✓  |  Attempt: 1                                   │
│                                                                     │
├────────────────────────────────────┬────────────────────────────────┤
│                                    │                                │
│  ┌──────────────────────────────┐  │   GRADE SUBMISSION             │
│  │                              │  │                                │
│  │                              │  │   Score: [____] / 100          │
│  │     SUBMITTED FILE           │  │                                │
│  │     (iframe preview)         │  │   Feedback:                    │
│  │                              │  │   ┌────────────────────────┐   │
│  │     driveFile.iframeUrl      │  │   │                        │   │
│  │                              │  │   │                        │   │
│  │                              │  │   │                        │   │
│  │                              │  │   └────────────────────────┘   │
│  │                              │  │                                │
│  └──────────────────────────────┘  │   [Save Grade]  [Save & Next]  │
│                                    │                                │
│  [Open in Drive] [Download]        │                                │
│                                    │                                │
├────────────────────────────────────┴────────────────────────────────┤
│  ◀ Previous Student     3 of 25 graded      Next Student ▶         │
└─────────────────────────────────────────────────────────────────────┘
```

### React Component Example:

```tsx
// components/instructor/SubmissionGrader.tsx
import { useState } from 'react';

interface DriveFile {
  driveId: string;
  fileName: string;
  webViewLink: string;
  iframeUrl: string;
  downloadUrl: string;
}

interface Submission {
  id: number;
  user: { firstName: string; lastName: string; email: string };
  submittedAt: string;
  isLate: number;
  attemptNumber: number;
  submissionStatus: string;
  submissionText: string | null;
  submissionLink: string | null;
  driveFile: DriveFile | null;
  score: number | null;
  feedback: string | null;
}

interface Props {
  submission: Submission;
  maxScore: number;
  assignmentTitle: string;
  onGrade: (score: number, feedback: string) => Promise<void>;
  onNavigate: (direction: 'prev' | 'next') => void;
  currentIndex: number;
  totalCount: number;
}

export function SubmissionGrader({
  submission,
  maxScore,
  assignmentTitle,
  onGrade,
  onNavigate,
  currentIndex,
  totalCount,
}: Props) {
  const [score, setScore] = useState<string>(
    submission.score?.toString() ?? ''
  );
  const [feedback, setFeedback] = useState(submission.feedback ?? '');
  const [saving, setSaving] = useState(false);

  const handleSave = async (andNext = false) => {
    const scoreNum = parseFloat(score);
    if (isNaN(scoreNum) || scoreNum < 0 || scoreNum > maxScore) {
      alert(`Score must be between 0 and ${maxScore}`);
      return;
    }
    
    setSaving(true);
    try {
      await onGrade(scoreNum, feedback);
      if (andNext) {
        onNavigate('next');
      }
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className="submission-grader">
      {/* Header */}
      <header className="grader-header">
        <button onClick={() => window.history.back()}>← Back to List</button>
        <h2>{assignmentTitle}</h2>
      </header>

      {/* Student Info */}
      <section className="student-info">
        <p>
          <strong>Student:</strong> {submission.user.firstName} {submission.user.lastName}
          ({submission.user.email})
        </p>
        <p>
          <strong>Submitted:</strong> {new Date(submission.submittedAt).toLocaleString()}
          {submission.isLate ? (
            <span className="badge badge-warning">Late</span>
          ) : (
            <span className="badge badge-success">On Time</span>
          )}
          <span className="attempt">Attempt #{submission.attemptNumber}</span>
        </p>
      </section>

      {/* Main Content: Preview + Grading Form */}
      <div className="grader-content">
        {/* Left: Submitted Content */}
        <div className="submission-preview">
          {submission.driveFile ? (
            <>
              <iframe
                src={submission.driveFile.iframeUrl}
                title="Submission Preview"
                className="preview-iframe"
                allowFullScreen
              />
              <div className="preview-actions">
                <a
                  href={submission.driveFile.webViewLink}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="btn btn-secondary"
                >
                  Open in Google Drive
                </a>
                <a
                  href={submission.driveFile.downloadUrl}
                  className="btn btn-secondary"
                >
                  Download
                </a>
              </div>
            </>
          ) : submission.submissionText ? (
            <div className="text-submission">
              <h4>Text Submission</h4>
              <div className="submission-text">{submission.submissionText}</div>
            </div>
          ) : submission.submissionLink ? (
            <div className="link-submission">
              <h4>Link Submission</h4>
              <a href={submission.submissionLink} target="_blank" rel="noopener noreferrer">
                {submission.submissionLink}
              </a>
            </div>
          ) : (
            <div className="no-submission">No submission content</div>
          )}
        </div>

        {/* Right: Grading Form */}
        <div className="grading-form">
          <h3>Grade Submission</h3>
          
          <div className="form-group">
            <label>
              Score (out of {maxScore})
            </label>
            <input
              type="number"
              min="0"
              max={maxScore}
              step="0.5"
              value={score}
              onChange={(e) => setScore(e.target.value)}
              className="score-input"
            />
          </div>

          <div className="form-group">
            <label>Feedback</label>
            <textarea
              value={feedback}
              onChange={(e) => setFeedback(e.target.value)}
              rows={6}
              placeholder="Enter feedback for the student..."
              className="feedback-input"
            />
          </div>

          <div className="form-actions">
            <button
              onClick={() => handleSave(false)}
              disabled={saving}
              className="btn btn-primary"
            >
              {saving ? 'Saving...' : 'Save Grade'}
            </button>
            <button
              onClick={() => handleSave(true)}
              disabled={saving || currentIndex >= totalCount - 1}
              className="btn btn-success"
            >
              Save & Next
            </button>
          </div>
        </div>
      </div>

      {/* Navigation Footer */}
      <footer className="grader-footer">
        <button
          onClick={() => onNavigate('prev')}
          disabled={currentIndex <= 0}
        >
          ◀ Previous Student
        </button>
        <span>{currentIndex + 1} of {totalCount}</span>
        <button
          onClick={() => onNavigate('next')}
          disabled={currentIndex >= totalCount - 1}
        >
          Next Student ▶
        </button>
      </footer>
    </div>
  );
}
```

### CSS Styles:

```css
/* SubmissionGrader.css */
.submission-grader {
  display: flex;
  flex-direction: column;
  height: 100vh;
}

.grader-header {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1rem;
  border-bottom: 1px solid #e0e0e0;
}

.student-info {
  padding: 1rem;
  background: #f5f5f5;
}

.grader-content {
  display: grid;
  grid-template-columns: 1fr 400px;
  flex: 1;
  overflow: hidden;
}

.submission-preview {
  padding: 1rem;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.preview-iframe {
  flex: 1;
  width: 100%;
  border: 1px solid #ddd;
  border-radius: 4px;
}

.preview-actions {
  display: flex;
  gap: 0.5rem;
  margin-top: 0.5rem;
}

.grading-form {
  padding: 1rem;
  border-left: 1px solid #e0e0e0;
  overflow-y: auto;
}

.score-input {
  width: 100px;
  padding: 0.5rem;
  font-size: 1.25rem;
  text-align: center;
}

.feedback-input {
  width: 100%;
  padding: 0.5rem;
  resize: vertical;
}

.form-actions {
  display: flex;
  gap: 0.5rem;
  margin-top: 1rem;
}

.grader-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem;
  border-top: 1px solid #e0e0e0;
}

.badge {
  display: inline-block;
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  font-size: 0.75rem;
  margin-left: 0.5rem;
}

.badge-success { background: #d4edda; color: #155724; }
.badge-warning { background: #fff3cd; color: #856404; }
```

---

## 📱 Submission List View (Instructor)

### Component: `SubmissionList.tsx`

```tsx
// components/instructor/SubmissionList.tsx
interface SubmissionListProps {
  assignmentId: number;
  submissions: Submission[];
  onSelectSubmission: (submission: Submission) => void;
}

export function SubmissionList({ 
  assignmentId, 
  submissions, 
  onSelectSubmission 
}: SubmissionListProps) {
  const [filter, setFilter] = useState<'all' | 'graded' | 'ungraded'>('all');
  
  const filtered = submissions.filter(s => {
    if (filter === 'graded') return s.submissionStatus === 'graded';
    if (filter === 'ungraded') return s.submissionStatus !== 'graded';
    return true;
  });

  const gradedCount = submissions.filter(s => s.submissionStatus === 'graded').length;

  return (
    <div className="submission-list">
      <header>
        <h2>Submissions</h2>
        <div className="progress">
          {gradedCount} / {submissions.length} graded
        </div>
      </header>

      <div className="filters">
        <button 
          className={filter === 'all' ? 'active' : ''} 
          onClick={() => setFilter('all')}
        >
          All ({submissions.length})
        </button>
        <button 
          className={filter === 'ungraded' ? 'active' : ''} 
          onClick={() => setFilter('ungraded')}
        >
          Ungraded ({submissions.length - gradedCount})
        </button>
        <button 
          className={filter === 'graded' ? 'active' : ''} 
          onClick={() => setFilter('graded')}
        >
          Graded ({gradedCount})
        </button>
      </div>

      <table className="submissions-table">
        <thead>
          <tr>
            <th>Student</th>
            <th>Submitted</th>
            <th>Status</th>
            <th>Score</th>
            <th>Action</th>
          </tr>
        </thead>
        <tbody>
          {filtered.map(submission => (
            <tr key={submission.id}>
              <td>
                {submission.user.firstName} {submission.user.lastName}
              </td>
              <td>
                {new Date(submission.submittedAt).toLocaleDateString()}
                {submission.isLate ? ' 🕐' : ''}
              </td>
              <td>
                <span className={`status ${submission.submissionStatus}`}>
                  {submission.submissionStatus}
                </span>
              </td>
              <td>
                {submission.score !== null ? submission.score : '—'}
              </td>
              <td>
                <button onClick={() => onSelectSubmission(submission)}>
                  {submission.submissionStatus === 'graded' ? 'View' : 'Grade'}
                </button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
```

---

## 🔗 API Service Functions

### Updated API Service:

```typescript
// services/assignmentService.ts

export const assignmentService = {
  // Get assignment with instructionFiles
  async getAssignment(id: number): Promise<Assignment> {
    const response = await api.get(`/api/assignments/${id}`);
    return response.data;
    // Now includes: instructionFiles: DriveFile[]
  },

  // Upload submission file (now returns full submission)
  async uploadSubmission(
    assignmentId: number, 
    file: File
  ): Promise<{
    submission: AssignmentSubmission;
    driveFile: DriveFile;
    isLate: boolean;
  }> {
    const formData = new FormData();
    formData.append('file', file);
    
    const response = await api.post(
      `/api/assignments/${assignmentId}/submissions/upload`,
      formData
    );
    return response.data;
  },

  // Get my submission (student)
  async getMySubmission(assignmentId: number): Promise<AssignmentSubmission | null> {
    try {
      const response = await api.get(
        `/api/assignments/${assignmentId}/submissions/my`
      );
      return response.data; // Now includes: driveFile: DriveFile | null
    } catch (error) {
      if (error.response?.status === 404) return null;
      throw error;
    }
  },

  // Get all submissions (instructor)
  async getSubmissions(assignmentId: number): Promise<{
    data: AssignmentSubmission[];
    meta: PaginationMeta;
  }> {
    const response = await api.get(
      `/api/assignments/${assignmentId}/submissions`
    );
    return response.data; // Each submission includes: driveFile: DriveFile | null
  },

  // Grade submission
  async gradeSubmission(
    assignmentId: number,
    submissionId: number,
    score: number,
    feedback: string
  ): Promise<AssignmentSubmission> {
    const response = await api.patch(
      `/api/assignments/${assignmentId}/submissions/${submissionId}/grade`,
      { score, feedback }
    );
    return response.data;
  },
};
```

### Same patterns for Labs:

```typescript
// services/labService.ts

export const labService = {
  async getLab(id: number): Promise<Lab> {
    // Now includes: instructionFiles: DriveFile[]
  },

  async uploadSubmission(labId: number, file: File): Promise<{
    submission: LabSubmission;
    driveFile: DriveFile;
    isLate: boolean;
  }> {
    // Same pattern as assignments
  },

  async getMySubmission(labId: number): Promise<LabSubmission | null> {
    // Now includes: driveFile: DriveFile | null
  },

  async getSubmissions(labId: number): Promise<{
    data: LabSubmission[];
    meta: PaginationMeta;
  }> {
    // Each includes: driveFile: DriveFile | null
  },

  async gradeSubmission(
    labId: number,
    submissionId: number,
    score: number,
    feedback: string
  ): Promise<LabSubmission> {
    // Same pattern as assignments
  },
};
```

---

## ✅ Migration Checklist

### Types & Interfaces
- [ ] Update `AssignmentSubmission` interface to include `driveFile: DriveFile | null`
- [ ] Update `LabSubmission` interface to include `driveFile: DriveFile | null`
- [ ] Update `Assignment` interface to include `instructionFiles: DriveFile[]`
- [ ] Update `Lab` interface to include `instructionFiles: DriveFile[]`
- [ ] Create `DriveFile` interface with: `driveId`, `fileName`, `webViewLink`, `iframeUrl`, `downloadUrl`

### API Services
- [ ] Update `uploadSubmission` to expect new response format (submission + driveFile)
- [ ] Remove separate `POST /submit` call after file upload (no longer needed)
- [ ] Update `getMySubmission` to handle `driveFile` in response
- [ ] Update `getSubmissions` to handle `driveFile` in each submission

### Student Components
- [ ] Update `MySubmission.tsx` to display `driveFile` links
- [ ] Update `SubmissionForm.tsx` to handle new upload response
- [ ] Add `FilePreviewer.tsx` component using `iframeUrl`
- [ ] Update assignment/lab detail to show `instructionFiles`

### Instructor Components
- [ ] Create/Update `SubmissionList.tsx` with grading status indicators
- [ ] Create `SubmissionGrader.tsx` with file preview + grading form
- [ ] Add navigation between submissions (prev/next)
- [ ] Show preview of submitted files using `iframeUrl`

### Shared Components
- [ ] Create `DriveFilePreview.tsx` - reusable iframe preview modal
- [ ] Create `DriveFileDownload.tsx` - download button component
- [ ] Update existing file display components to use Drive URLs

---

## 🛠️ Database Schema Change (Reference)

The `file_id` column in `assignment_submissions` and `lab_submissions` tables now references `drive_files.drive_file_id` instead of the old `files.file_id`.

This is transparent to the frontend - you just use the new `driveFile` object in API responses.

---

## 📞 Need Help?

If you encounter issues:
1. Check that you're using the latest API response format
2. Verify `driveFile` is not `undefined` before accessing properties
3. Use optional chaining: `submission?.driveFile?.iframeUrl`
4. Test with instructor.tarek@example.com (SecureP@ss123) for grading
5. Test with student.tarek@example.com (SecureP@ss123) for submissions
