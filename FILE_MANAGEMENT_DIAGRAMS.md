# 📊 File Management - Visual Architecture & Diagrams

## 🏗️ System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        REST API LAYER                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  POST /files/upload      GET /files/:id/download               │
│  PUT  /files/:id         DELETE /files/:id                     │
│  POST /folders           GET /folders/:id/contents             │
│  POST /files/:id/versions/rollback                             │
│  POST /files/:id/permissions                                   │
│                                                                 │
└────────────┬────────────────────────────────┬───────────────────┘
             │                                │
    ┌────────▼────────┐          ┌────────────▼──────────┐
    │ Controllers (4) │          │ Custom Guards (3)     │
    ├─────────────────┤          ├──────────────────────┤
    │ Files           │          │ FileAccessGuard      │
    │ Folders         │          │ FolderAccessGuard    │
    │ Versions        │          │ UploadQuotaGuard     │
    │ Permissions     │          │                      │
    └────────┬────────┘          └──────────┬───────────┘
             │                              │
             └──────────────┬───────────────┘
                            │
        ┌───────────────────▼──────────────────┐
        │      Services Layer (5 Services)     │
        ├────────────────────────────────────────┤
        │                                       │
        │  ┌─ FileStorageService               │
        │  │  (Local/S3 abstraction)            │
        │  │                                    │
        │  ├─ FilesService                     │
        │  │  (File CRUD & metadata)           │
        │  │                                    │
        │  ├─ FoldersService                   │
        │  │  (Hierarchy management)           │
        │  │                                    │
        │  ├─ FileVersionsService              │
        │  │  (Version tracking)               │
        │  │                                    │
        │  └─ FilePermissionsService           │
        │     (Permission logic)               │
        │                                       │
        └──────────────┬────────────────────────┘
                       │
        ┌──────────────▼────────────────────┐
        │    Repository Layer (TypeORM)     │
        ├───────────────────────────────────┤
        │                                   │
        │  - FileRepository                 │
        │  - FolderRepository               │
        │  - FileVersionRepository          │
        │  - FilePermissionRepository       │
        │                                   │
        └──────────────┬────────────────────┘
                       │
        ┌──────────────▼────────────────────┐
        │      Database Layer (MySQL)       │
        ├───────────────────────────────────┤
        │                                   │
        │  - files table                    │
        │  - folders table                  │
        │  - file_versions table            │
        │  - file_permissions table         │
        │                                   │
        └───────────────────────────────────┘
```

---

## 🔄 Data Flow Diagrams

### **Upload Flow**
```
USER
  │
  ├─ POST /api/files/upload
  │  ├─ multipart/form-data: file + folder_id
  │  │
  │  ▼
  ├─ FilesController.uploadFile()
  │  ├─ Check authentication
  │  ├─ Validate file (size, type)
  │  ├─ Check folder permission (write)
  │  │
  │  ▼
  ├─ FileStorageService.uploadFile()
  │  ├─ Generate unique filename
  │  ├─ Save to disk/S3
  │  ├─ Calculate checksum (SHA-256)
  │  │
  │  ▼
  ├─ FilesService.createFile()
  │  ├─ Insert metadata in DB
  │  ├─ Link to folder (if provided)
  │  ├─ Set status = 'active'
  │  │
  │  ▼
  ├─ FileVersionsService.createVersion()
  │  ├─ Create version_1
  │  ├─ Set uploaded_by = current_user
  │  │
  │  ▼
  ├─ FilePermissionsService.grantDefaultPermissions()
  │  ├─ If public: everyone can read
  │  ├─ If private: only uploader can access
  │  │
  │  ▼
  └─ Return FileResponseDto
     ├─ file_id, file_name, size, mime_type
     ├─ upload_url, version_count
     └─ 200 OK ✅
```

---

### **Download Flow**
```
USER
  │
  ├─ GET /api/files/:fileId/download
  │
  ▼
├─ FilesController.downloadFile()
│  ├─ Check authentication
│  │
│  ▼
├─ FileAccessGuard
│  ├─ Check if user has READ permission
│  ├─ Method 1: Direct permission? ──YES──→ Allow
│  ├─ Method 2: Role permission? ───YES──→ Allow
│  ├─ Method 3: Folder inheritance? YES──→ Allow
│  └─ Default ────────────────────NO───→ Deny 403
│
│ ✅ Permission Granted
│
├─ FilesService.getFile()
│  ├─ Fetch file metadata from DB
│  ├─ Verify file exists
│  ├─ Check status != 'deleted'
│  │
│  ▼
├─ FileStorageService.downloadFile()
│  ├─ Read from disk/S3
│  ├─ Setup response headers
│  ├─ Content-Type: application/pdf
│  ├─ Content-Length: 524288
│  │
│  ▼
├─ Stream File to Client
│  │
│  ▼
├─ FilesService.incrementDownloadCount()
│  ├─ Increment download_count
│  ├─ Log access event
│  │
│  ▼
└─ Return file stream
   └─ 200 OK with binary data ✅
```

---

### **Permission Check Flow**
```
┌─ Check Permission on File
│
├─ FilePermissionsService.checkPermission(userId, fileId, action)
│
│  1️⃣ Direct User Permission?
│     SELECT * FROM file_permissions
│     WHERE file_id = ? AND user_id = ? AND permission_type = ?
│     │
│     ├─ YES ──→ ALLOW ✅
│     └─ NO ──→ Continue to step 2
│
│  2️⃣ Role-Based Permission?
│     SELECT * FROM file_permissions
│     WHERE file_id = ? AND role_id IN (user_roles) AND permission_type = ?
│     │
│     ├─ YES ──→ ALLOW ✅
│     └─ NO ──→ Continue to step 3
│
│  3️⃣ Folder Cascade Permission?
│     Get folder_id from file
│     Recursively check parent folders
│     WITH RECURSIVE folder_tree AS (...)
│     │
│     ├─ YES ──→ ALLOW ✅
│     └─ NO ──→ Continue to step 4
│
│  4️⃣ Default Action
│     └─ DENY 🚫
│
└─ Return: true/false
```

---

## 🗂️ Folder Hierarchy Example

```
Root Folders (level=0, is_system_folder=true)
│
├─ Course Materials (folder_id=1)
│  path: "/course_materials"
│  │
│  ├─ CS101 Materials (folder_id=2, parent=1, level=1)
│  │  path: "/course_materials/cs101"
│  │  │
│  │  ├─ Lectures (folder_id=6, parent=2, level=2)
│  │  │  path: "/course_materials/cs101/lectures"
│  │  │  └─ cs101_lecture1.pdf (v1, v2, v3)
│  │  │
│  │  └─ Syllabus (folder_id=7, parent=2, level=2)
│  │     path: "/course_materials/cs101/syllabus"
│  │     └─ syllabus.pdf (v1, v2)
│  │
│  ├─ CS201 Materials (folder_id=3, parent=1, level=1)
│  │  path: "/course_materials/cs201"
│  │  └─ cs201_lecture1.pdf
│  │
│  └─ CS301 Materials (folder_id=4, parent=1, level=1)
│     path: "/course_materials/cs301"
│     └─ cs301_lecture1.pdf
│
├─ Assignments (folder_id=8, level=0, is_system_folder=true)
│  path: "/assignments"
│  │
│  ├─ CS101 Assignments (folder_id=9, parent=8, level=1)
│  │  path: "/assignments/cs101"
│  │  ├─ Assignment1 (folder_id=10, parent=9, level=2)
│  │  └─ Assignment2 (folder_id=11, parent=9, level=2)
│  │
│  └─ CS201 Assignments (folder_id=12, parent=8, level=1)
│     path: "/assignments/cs201"
│     └─ Assignment1 (folder_id=13, parent=12, level=2)
│
└─ Student Submissions (folder_id=14, level=0, is_system_folder=true)
   path: "/student_submissions"
   │
   ├─ User25 (folder_id=15, parent=14, level=1)
   │  path: "/student_submissions/user_25"
   │  ├─ assignment1_submission.pdf (v1, v2, v3)
   │  └─ assignment2_submission.pdf (v1)
   │
   └─ User26 (folder_id=16, parent=14, level=1)
      path: "/student_submissions/user_26"
      └─ assignment1_submission.pdf (v1)
```

---

## 📦 Database Relationships

```
┌──────────────┐
│   users      │
│──────────────│
│ user_id (PK) │◄────────────────┐
│ ...          │                 │
└──────────────┘          ┌──────▼─────────────┐
                          │ file_permissions   │
                          │────────────────────│
                          │ permission_id (PK) │
                          │ user_id (FK)       │
                          │ role_id (FK)       │
                          │ ...                │
                          └──────┬─────────────┘
                                 │
                    ┌────────────┴────────────┐
                    │                         │
        ┌───────────▼────────────┐   ┌───────▼──────────┐
        │       files            │   │     folders      │
        │────────────────────────│   │──────────────────│
        │ file_id (PK)           │   │ folder_id (PK)   │
        │ file_path              │◄──┤ parent_id (FK)   │
        │ uploaded_by (FK)───┐   │   │ created_by (FK)  │
        │ folder_id (FK)─────┼───┼───┤ ...              │
        │ ...                │   │   └──────────────────┘
        └────────┬───────────┘   │
                 │               │
        ┌────────▼─────────────┐ │
        │ file_versions        │ │
        │────────────────────  │ │
        │ version_id (PK)      │ │
        │ file_id (FK)─────────┘ │
        │ version_number         │
        │ uploaded_by (FK)───┐   │
        │ ...                │   │
        └────────────────────┤   │
                             │   │
                             └───┘
                        (Many relationships)
```

---

## 🔐 Permission Matrix Example

### **Scenario: CS101 Course**

```
Folder: "CS101 Materials" (folder_id=2)
Files:  syllabus.pdf, lecture1.pdf, lecture2.pdf

Permission Grants:
┌─────────────────────┬──────────────┬──────────────┬──────────────┐
│ Type                │ Granted To   │ Scope        │ Allows       │
├─────────────────────┼──────────────┼──────────────┼──────────────┤
│ READ                │ STUDENT role │ folder_id=2  │ All students │
│                     │              │ (cascade)    │ in CS101     │
├─────────────────────┼──────────────┼──────────────┼──────────────┤
│ WRITE               │ INSTRUCTOR   │ folder_id=2  │ Can update   │
│                     │ user_id=2    │ (specific)   │ files        │
├─────────────────────┼──────────────┼──────────────┼──────────────┤
│ SHARE               │ INSTRUCTOR   │ folder_id=2  │ Can grant    │
│                     │ user_id=2    │              │ permissions  │
└─────────────────────┴──────────────┴──────────────┴──────────────┘

Result:
├─ Student (user_id=25, role=STUDENT)
│  ├─ syllabus.pdf ──→ READ ✅ (via folder cascade)
│  ├─ lecture1.pdf ──→ READ ✅ (via folder cascade)
│  └─ lecture2.pdf ──→ READ ✅ (via folder cascade)
│
└─ Instructor (user_id=2, role=INSTRUCTOR)
   ├─ syllabus.pdf ──→ READ ✅, WRITE ✅, SHARE ✅
   ├─ lecture1.pdf ──→ READ ✅, WRITE ✅, SHARE ✅
   └─ lecture2.pdf ──→ READ ✅, WRITE ✅, SHARE ✅
```

---

## 📈 Request/Response Flow

### **Upload Request → Response**
```
REQUEST:
┌─────────────────────────────────────────────────┐
│ POST /api/files/upload                          │
│ Content-Type: multipart/form-data               │
│                                                 │
│ Headers:                                        │
│ Authorization: Bearer eyJhbGc...               │
│                                                 │
│ Body:                                           │
│ ├─ file: [binary pdf data]                     │
│ ├─ folder_id: 2                                │
│ └─ description: "CS101 Lecture Notes"          │
└─────────────────────────────────────────────────┘
                    │
                    ▼
PROCESSING:
┌─────────────────────────────────────────────────┐
│ 1. Validate JWT token ─────────────────→ ✅    │
│ 2. Validate file size (max 500MB) ────→ ✅    │
│ 3. Validate mime type ────────────────→ ✅    │
│ 4. Check folder write permission ─────→ ✅    │
│ 5. Store file to disk ────────────────→ ✅    │
│ 6. Create DB metadata ────────────────→ ✅    │
│ 7. Create version record ─────────────→ ✅    │
│ 8. Set default permissions ───────────→ ✅    │
└─────────────────────────────────────────────────┘
                    │
                    ▼
RESPONSE:
┌─────────────────────────────────────────────────┐
│ HTTP 200 OK                                     │
│ Content-Type: application/json                  │
│                                                 │
│ {                                               │
│   "success": true,                             │
│   "data": {                                     │
│     "file_id": 123,                            │
│     "file_name": "cs101_lecture1_xyz.pdf",     │
│     "original_filename": "CS101_Lecture1.pdf", │
│     "file_size": 1048576,                      │
│     "mime_type": "application/pdf",            │
│     "folder_id": 2,                            │
│     "uploaded_by": 2,                          │
│     "status": "active",                        │
│     "uploaded_at": "2025-11-30T10:30:00Z",    │
│     "versions_count": 1,                       │
│     "download_url": "/api/files/123/download", │
│     "permissions": ["read", "write", "delete"] │
│   }                                             │
│ }                                               │
└─────────────────────────────────────────────────┘
```

---

## 🔄 Version Control Timeline

```
Timeline of file: assignment1_spec.pdf

2025-11-30 10:00 ─┐ Version 1
                  │ Size: 234 KB
                  │ Content: Original assignment specification
                  │ Uploaded by: Instructor (user_id=2)
                  │
2025-11-30 14:30 ─┤ Version 2
                  │ Size: 235 KB
                  │ Content: Fixed typos in V1
                  │ Uploaded by: Instructor (user_id=2)
                  │ Change: "Fixed grammar errors"
                  │
2025-11-30 16:00 ─┤ Version 3
                  │ Size: 236 KB
                  │ Content: Updated deadline
                  │ Uploaded by: Instructor (user_id=2)
                  │ Change: "Extended deadline to Dec 7"
                  │
2025-11-30 17:45 ─┤ Version 4 (CURRENT)
                  │ Size: 234 KB ← Rolled back to V1
                  │ Content: Rolled back to original
                  │ Uploaded by: Admin (user_id=1)
                  │ Change: "Reverted to original - no deadline"
                  │
                  └─ Latest = V4 ✅
                  
All versions stored:
├─ /storage/files/file_123/v1_234567.pdf (Original)
├─ /storage/files/file_123/v2_235678.pdf (Typos fixed)
├─ /storage/files/file_123/v3_236789.pdf (Deadline updated)
└─ /storage/files/file_123/v4_234567.pdf (Rollback to V1)
```

---

## 🎯 State Machine: File Status

```
[PROCESSING] ──────────────────────┐
    │                              │
    ├─ All checks passed?          │
    │  ├─ YES ──→ [ACTIVE] ←─────┐ │
    │  └─ NO  ──→ [FAILED] ←────┐ │
    │                            │ │
    │                    ┌───────┘ │
    │                    │         │
                    [ACTIVE] ←─────┘
                    │        │
        ┌───────────┘        │
        │                    │
        ├─ User deletes?     │
        │  └─ [DELETED]      │
        │                    │
        └─ Moved to storage? │
           └─ [ARCHIVED]     │
        
User actions:
├─ Upload ──→ PROCESSING ──→ ACTIVE (or FAILED)
├─ Update ──→ Create version in ACTIVE file
├─ Delete ──→ DELETED (soft delete, data kept)
└─ Archive ──→ ARCHIVED (old versions)
```

---

## 📊 Caching Strategy

```
Permission Cache (Redis/Memory)
┌────────────────────────────────────────────┐
│ Key: file_permission_{fileId}_{userId}     │
│ Value: ['read', 'write', 'delete']         │
│ TTL: 5 minutes                             │
│                                            │
│ Hit Rate Target: 95%+                      │
│ Invalidation: On permission change         │
└────────────────────────────────────────────┘

Folder Tree Cache
┌────────────────────────────────────────────┐
│ Key: folder_hierarchy_{folderId}           │
│ Value: {path, level, children}             │
│ TTL: 10 minutes                            │
│                                            │
│ Hit Rate Target: 90%+                      │
│ Invalidation: On folder create/delete      │
└────────────────────────────────────────────┘

File Metadata Cache
┌────────────────────────────────────────────┐
│ Key: file_{fileId}                         │
│ Value: {name, size, status, path}          │
│ TTL: 15 minutes                            │
│                                            │
│ Hit Rate Target: 85%+                      │
│ Invalidation: On file update               │
└────────────────────────────────────────────┘
```

---

## ⚡ Performance Optimization Layers

```
Layer 1: Database Indexing
┌─────────────────────────────────────────┐
│ CREATE INDEX idx_files_folder           │
│ CREATE INDEX idx_files_user             │
│ CREATE INDEX idx_permissions_user       │
│ CREATE INDEX idx_permissions_role       │
│ CREATE INDEX idx_versions_file          │
└─────────────────────────────────────────┘
         ⬇️ ~90% query improvement

Layer 2: Query Optimization
┌─────────────────────────────────────────┐
│ ✅ Use QueryBuilder for complex queries │
│ ✅ Load relations eagerly (minimize N+1)│
│ ✅ Pagination for large result sets     │
│ ✅ Select only needed columns           │
└─────────────────────────────────────────┘
         ⬇️ ~50% response time improvement

Layer 3: Caching Layer
┌─────────────────────────────────────────┐
│ ✅ Cache permission checks (5 min)      │
│ ✅ Cache folder hierarchy (10 min)      │
│ ✅ Cache file metadata (15 min)         │
│ ✅ Invalidate on mutations              │
└─────────────────────────────────────────┘
         ⬇️ ~80% permission check improvement

Layer 4: File Streaming
┌─────────────────────────────────────────┐
│ ✅ Stream large files (don't load all)  │
│ ✅ Chunk-based upload                   │
│ ✅ Compression for text files           │
│ ✅ CDN integration (future)              │
└─────────────────────────────────────────┘
         ⬇️ ~70% download speed improvement
```

---

## 🔒 Security Layers

```
Layer 1: Authentication
├─ JWT token required for all endpoints
├─ Token validation on each request
└─ Token expiration checks

Layer 2: Authorization (Guards)
├─ File access guard (permission check)
├─ Folder access guard (cascade logic)
└─ Upload quota guard (size limits)

Layer 3: Input Validation
├─ File size limits (500MB max)
├─ File type whitelist (PDF, DOCX, etc.)
├─ Filename sanitization (no path traversal)
└─ Folder depth limit (10 levels max)

Layer 4: Data Protection
├─ Checksum validation (SHA-256)
├─ Soft delete (data recovery possible)
├─ Version history (audit trail)
└─ Permission audit logging

Layer 5: Storage Security
├─ Files stored outside web root
├─ Randomized filenames (prevent enumeration)
├─ Directory traversal prevention
└─ Encrypted storage option (S3 KMS)
```

---

*Diagrams Version: 1.0*  
*Created: 2025-11-30*  
*Format: ASCII/Text (DevOps friendly)*
