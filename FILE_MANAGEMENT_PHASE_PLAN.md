# 📁 PHASE 3: File Management System - Comprehensive Implementation Plan

**Status:** Planning Phase  
**Priority:** HIGH  
**Duration:** Week 6  
**Dependencies:** Phase 1 (Auth), Phase 2 (Enrollment)

---

## 🎯 Executive Summary

The File Management System is a comprehensive feature that handles all file operations in the Eduverse platform. It supports:
- Upload/Download files with versioning
- Hierarchical folder structure
- Permission-based access control
- File tracking and analytics
- Multi-user collaboration

**Tables:** 4 core tables + relationships
- `files` - File metadata & storage
- `folders` - Hierarchical folder structure
- `file_versions` - Version control
- `file_permissions` - Access control

---

## 📊 Database Schema Analysis

### 1. **folders** Table
```sql
Column                Type                  Purpose
────────────────────────────────────────────────────────
folder_id             BIGINT(20) UNSIGNED   Primary Key (Auto-increment)
folder_name           VARCHAR(255)          Folder display name
parent_folder_id      BIGINT(20) UNSIGNED   Self-referencing for hierarchy
created_by            BIGINT(20) UNSIGNED   FK → users
path                  TEXT                  Full folder path (e.g., /course_materials/cs101)
level                 INT(11)               Depth in hierarchy (0 = root)
is_system_folder      TINYINT(1)            Reserved system folders flag
created_at            TIMESTAMP             Audit
updated_at            TIMESTAMP             Audit
```

**Current Data (System Folders):**
- Root: `Course Materials`, `Assignments`, `Student Submissions`
- Sub: `CS101 Materials`, `CS201 Materials`

---

### 2. **files** Table
```sql
Column                Type                  Purpose
────────────────────────────────────────────────────────
file_id               BIGINT(20) UNSIGNED   Primary Key (Auto-increment)
file_name             VARCHAR(255)          Stored filename (normalized)
original_filename     VARCHAR(255)          Original uploaded filename
file_path             VARCHAR(500)          Storage path
file_size             BIGINT(20)            Bytes
mime_type             VARCHAR(100)          Content-type (e.g., application/pdf)
file_extension        VARCHAR(10)           Extension (e.g., pdf)
uploaded_by           BIGINT(20) UNSIGNED   FK → users
folder_id             BIGINT(20) UNSIGNED   FK → folders (NULLABLE)
checksum              VARCHAR(64)           SHA-256 for integrity
download_count        INT(11)               Analytics
is_public             TINYINT(1)            Global visibility flag
status                ENUM                  'active','processing','archived','deleted'
uploaded_at           TIMESTAMP             Audit
updated_at            TIMESTAMP             Audit
deleted_at            TIMESTAMP             Soft delete support
```

**Enum Values:**
- `status`: active, processing, archived, deleted

**Current Data Patterns:**
- Course materials PDFs: 1-2MB
- System manages: cs101_syllabus.pdf, cs101_lecture1.pdf, cs101_lecture2.pdf, etc.

---

### 3. **file_versions** Table
```sql
Column                Type                  Purpose
────────────────────────────────────────────────────────
version_id            BIGINT(20) UNSIGNED   Primary Key (Auto-increment)
file_id               BIGINT(20) UNSIGNED   FK → files
version_number        INT(11)               Sequential version (1, 2, 3...)
file_path             VARCHAR(500)          Path to versioned file
file_size             BIGINT(20)            Bytes at this version
uploaded_by           BIGINT(20) UNSIGNED   FK → users (who uploaded)
change_description    TEXT                  What changed in this version
created_at            TIMESTAMP             Version creation time
```

**Purpose:** Keep history of all file updates, allow rollback

**Example Flow:**
```
File: assignment1_spec.pdf
├── Version 1 (v1_234567_bytes) - Created by instructor ID 2
├── Version 2 (v2_245678_bytes) - Fixed typos, created by instructor ID 2
└── Version 3 (v3_256789_bytes) - Updated deadline, created by instructor ID 2
```

---

### 4. **file_permissions** Table
```sql
Column                Type                  Purpose
────────────────────────────────────────────────────────
permission_id         BIGINT(20) UNSIGNED   Primary Key (Auto-increment)
file_id               BIGINT(20) UNSIGNED   FK → files (NULLABLE)
folder_id             BIGINT(20) UNSIGNED   FK → folders (NULLABLE)
user_id               BIGINT(20) UNSIGNED   FK → users (NULLABLE)
role_id               INT(10) UNSIGNED      FK → roles (NULLABLE)
permission_type       ENUM                  'read','write','delete','share'
granted_at            TIMESTAMP             Audit
granted_by            BIGINT(20) UNSIGNED   FK → users (who granted)
```

**Enum Values:**
- `permission_type`: read, write, delete, share

**Granularity:**
- Can grant to individual user OR role (flexibility)
- Can apply to file OR folder (cascading)
- Separate permissions per action

**Example Scenarios:**
```
Scenario 1: Course Material (Public Read)
- File: cs101_syllabus.pdf
- Folder: CS101 Materials
- Permission: role_id=STUDENT, permission_type='read'
- Result: All students can read

Scenario 2: Assignment (Instructor Only)
- File: assignment1_spec.pdf
- Permission: user_id=2, permission_type='write'
- Result: Only instructor ID 2 can modify

Scenario 3: Folder Cascading
- Folder: Student Submissions
- Permission: folder_id=5, role_id=ADMIN, permission_type='delete'
- Result: Admins can delete files in this folder
```

---

## 🏗️ Module Architecture (Following Existing Patterns)

### Directory Structure
```
src/modules/files/
├── files.module.ts              [Module definition]
├── controllers/
│   ├── index.ts
│   ├── files.controller.ts      [Upload, Download, List, Delete]
│   ├── folders.controller.ts    [Create, List, Update, Delete folders]
│   ├── file-versions.controller.ts  [View versions, Rollback]
│   └── file-permissions.controller.ts  [Grant, Revoke permissions]
├── services/
│   ├── index.ts
│   ├── files.service.ts         [Core file operations]
│   ├── folders.service.ts       [Folder CRUD & hierarchy]
│   ├── file-versions.service.ts [Version management]
│   ├── file-permissions.service.ts  [Permission logic]
│   └── file-storage.service.ts  [S3 or local disk storage]
├── entities/
│   ├── index.ts
│   ├── file.entity.ts
│   ├── folder.entity.ts
│   ├── file-version.entity.ts
│   └── file-permission.entity.ts
├── dtos/
│   ├── index.ts
│   ├── upload-file.dto.ts
│   ├── create-folder.dto.ts
│   ├── grant-permission.dto.ts
│   └── file-response.dto.ts
├── enums/
│   ├── index.ts
│   ├── file-status.enum.ts
│   └── permission-type.enum.ts
├── exceptions/
│   ├── index.ts
│   ├── file-not-found.exception.ts
│   └── permission-denied.exception.ts
├── guards/
│   ├── index.ts
│   ├── file-access.guard.ts     [Check permissions before access]
│   └── folder-access.guard.ts
└── tests/
    └── files.service.spec.ts
```

---

## 📋 Implementation Roadmap

### **WEEK 6: File Management Phase (Phases Breakdown)**

#### **Day 1-2: Setup & Database Integration**
```
✓ Create files.module.ts
✓ Setup TypeORM entities for all 4 tables
✓ Register module in app.module.ts
✓ Create migration scripts (if needed)
✓ Setup file storage configuration (local/S3)
```

**Files to Create:**
- `src/modules/files/files.module.ts`
- `src/modules/files/entities/{file,folder,file-version,file-permission}.entity.ts`
- `src/config/file-storage.config.ts`

---

#### **Day 2-3: Core Services Implementation**
```
Phase 1: File Storage Service
├── Upload file (local/S3 abstraction)
├── Download file
├── Delete file (hard/soft)
└── Stream file for download

Phase 2: Folder Service
├── Create folder hierarchy
├── List folder contents (recursive)
├── Move items between folders
├── Delete folder (with contents)
└── Get folder path

Phase 3: File Service
├── Create file metadata
├── Update file info
├── Track file downloads
├── Handle versioning triggers
└── Archive old files

Phase 4: Version Service
├── Create version on upload
├── List versions
├── Rollback to version
└── Cleanup old versions
```

**Files to Create:**
- `src/modules/files/services/file-storage.service.ts`
- `src/modules/files/services/files.service.ts`
- `src/modules/files/services/folders.service.ts`
- `src/modules/files/services/file-versions.service.ts`

---

#### **Day 3-4: Permission System & Guards**
```
Phase 1: Permission Service
├── Grant permission (user/role)
├── Revoke permission
├── Check permission
├── List permissions
└── Handle cascading (folder → files)

Phase 2: Access Guards
├── File access guard (check user permissions)
├── Folder access guard
├── Upload guard (quota, format)
└── Delete guard (soft delete, permissions)

Phase 3: Permission Caching
├── Cache permission checks
├── Invalidate on grant/revoke
└── Performance optimization
```

**Files to Create:**
- `src/modules/files/services/file-permissions.service.ts`
- `src/modules/files/guards/file-access.guard.ts`
- `src/modules/files/guards/folder-access.guard.ts`

---

#### **Day 4-5: Controllers & DTOs**
```
Phase 1: File Controller
├── POST   /api/files/upload
├── GET    /api/files/:fileId/download
├── GET    /api/files/:fileId
├── PUT    /api/files/:fileId
├── DELETE /api/files/:fileId
├── GET    /api/files/by-folder/:folderId
└── GET    /api/files/search?query=...

Phase 2: Folder Controller
├── POST   /api/folders
├── GET    /api/folders/:folderId
├── GET    /api/folders/:folderId/contents
├── PUT    /api/folders/:folderId
├── DELETE /api/folders/:folderId
└── GET    /api/folders/path/:folderPath

Phase 3: Version Controller
├── GET    /api/files/:fileId/versions
├── GET    /api/files/:fileId/versions/:versionId/download
├── POST   /api/files/:fileId/versions/:versionId/rollback
└── DELETE /api/files/:fileId/versions/:versionId

Phase 4: Permission Controller
├── POST   /api/files/:fileId/permissions
├── GET    /api/files/:fileId/permissions
├── DELETE /api/files/:fileId/permissions/:permissionId
├── POST   /api/folders/:folderId/permissions
└── PUT    /api/permissions/:permissionId
```

**Files to Create:**
- `src/modules/files/controllers/files.controller.ts`
- `src/modules/files/controllers/folders.controller.ts`
- `src/modules/files/controllers/file-versions.controller.ts`
- `src/modules/files/controllers/file-permissions.controller.ts`
- `src/modules/files/dtos/...` (upload, create-folder, permission DTOs)

---

#### **Day 5-6: Testing & Integration**
```
Phase 1: Unit Tests
├── Service tests (files, folders, permissions)
├── Guard tests
└── DTO validation tests

Phase 2: Integration Tests
├── Upload flow
├── Download flow
├── Permission checks
├── Version rollback
└── Folder hierarchy

Phase 3: API Testing (Postman Collection)
├── Create collection with all endpoints
├── Test cases for each role (student, instructor, admin)
└── Permission verification scenarios
```

---

## 🔐 Permission Model

### Hierarchical Permission System

```
Role-Based Permissions (Default)
│
├── ADMIN
│   ├── files: CREATE, READ, UPDATE, DELETE (all files)
│   ├── folders: CREATE, READ, UPDATE, DELETE (all folders)
│   └── permissions: GRANT, REVOKE (all users)
│
├── INSTRUCTOR
│   ├── files: CREATE (own uploads)
│   │   ├── READ: own files + course materials
│   │   ├── UPDATE: own files + students' submissions (for grading)
│   │   └── DELETE: own files
│   ├── folders: CREATE (own folders in course)
│   │   ├── READ: course folders + submissions folder
│   │   ├── UPDATE: own folders
│   │   └── DELETE: own folders
│   └── permissions: GRANT (to students in course)
│
└── STUDENT
    ├── files: CREATE (submissions only)
    │   ├── READ: course materials + own submissions
    │   ├── UPDATE: own submissions (if not submitted)
    │   └── DELETE: own submissions (if not graded)
    ├── folders: READ (course materials, submissions)
    └── permissions: NONE (inherited from course)

User-Specific Overrides
└── Can grant explicit permissions to specific users:
    ├── User X: READ access to File Y
    ├── User Z: WRITE access to Folder W
    └── Overrides role-based permissions
```

---

## 🔄 Data Flows

### **Upload Flow**
```
1. User submits file via POST /api/files/upload
   ├── File uploaded to request
   ├── Size & format validation
   └── Permission check (can upload to folder)

2. File Storage Service
   ├── Generate unique filename
   ├── Store file (local/S3)
   ├── Calculate checksum
   └── Return storage path

3. Files Service
   ├── Create file metadata in DB
   ├── Link to folder (if provided)
   ├── Set status = 'processing'
   └── Trigger async processing

4. Version Service
   ├── Create initial version (v1)
   ├── Set uploaded_by user
   └── Set status = 'active'

5. Response
   ├── Return file metadata
   ├── Include file_id, url
   └── Status: 'active'
```

**HTTP Endpoints:**
```
POST /api/files/upload
Content-Type: multipart/form-data

Request:
{
  file: <binary>,
  folder_id: 1,
  description: "CS101 Lecture Notes"
}

Response: 200 OK
{
  file_id: 123,
  file_name: "cs101_lecture1_xyz.pdf",
  original_filename: "CS101_Lecture1.pdf",
  file_size: 1048576,
  mime_type: "application/pdf",
  folder_id: 1,
  uploaded_at: "2025-11-30T...",
  status: "active"
}
```

---

### **Download Flow**
```
1. User requests GET /api/files/:fileId/download
   ├── Check file exists
   ├── Check permissions (read)
   └── Check file status (not deleted)

2. File Access Guard
   ├── Verify user has READ permission
   ├── Check folder permissions (cascading)
   ├── Verify user role matches
   └── Allow or Deny

3. File Storage Service
   ├── Retrieve file from storage
   ├── Setup stream headers
   └── Transfer file to client

4. Analytics Update
   ├── Increment download_count
   ├── Update last_accessed
   └── Log access event

5. Response
   ├── Stream file data
   ├── Content-Type header
   └── Content-Length header
```

---

### **Permission Cascade (Folders → Files)**
```
Scenario: Grant STUDENT role READ access to Folder "CS101 Materials"

Before:
├── Folder: CS101 Materials (folder_id=2)
│   ├── File: cs101_syllabus.pdf (file_id=1)
│   └── File: cs101_lecture1.pdf (file_id=2)
└── file_permissions: EMPTY

After Grant:
├── Folder Permission Created
│   └── folder_id=2, role_id=STUDENT, permission_type='read'
├── File Permissions Inherited
│   ├── file_id=1, role_id=STUDENT, permission_type='read' (auto-granted)
│   └── file_id=2, role_id=STUDENT, permission_type='read' (auto-granted)
└── New files added to folder automatically inherit

Permission Check:
User Role: STUDENT
File: cs101_lecture1.pdf
├── Direct permission? NO
├── Folder permission? YES (CS101 Materials folder)
└── Result: ALLOWED ✓
```

---

### **Version Rollback Flow**
```
Current State:
file_id=5, assignment1_spec.pdf
├── Version 1: Original (234 KB)
├── Version 2: Fixed typos (235 KB) ← Current
└── Version 3: New deadline (236 KB)

Rollback Request:
POST /api/files/5/versions/1/rollback
{
  reason: "Revert to original specification"
}

Process:
1. Validate permission (WRITE access required)
2. Get Version 1 data from storage
3. Create new version (Version 4)
   ├── Copy Version 1 file
   ├── Set change_description: "Rolled back to v1"
   ├── Set uploaded_by: current_user_id
   └── version_number: 4
4. Update files.file_path → Version 4 path
5. Return new version details
6. Old versions still available for recovery

Result:
├── Version 1: Original (234 KB)
├── Version 2: Fixed typos (235 KB)
├── Version 3: New deadline (236 KB)
└── Version 4: Rolled back to v1 (234 KB) ← Current
```

---

## 📦 DTOs (Data Transfer Objects)

### **Upload File DTO**
```typescript
// upload-file.dto.ts
export class UploadFileDto {
  @IsNotEmpty()
  @Type(() => String)
  original_filename: string;

  @IsOptional()
  @Type(() => Number)
  folder_id?: number;

  @IsOptional()
  @MaxLength(500)
  description?: string;

  @IsOptional()
  @Type(() => Boolean)
  is_public?: boolean = false;

  // File object (handled by middleware)
  file: Express.Multer.File;
}
```

### **Create Folder DTO**
```typescript
// create-folder.dto.ts
export class CreateFolderDto {
  @IsNotEmpty()
  @MaxLength(255)
  folder_name: string;

  @IsOptional()
  @Type(() => Number)
  parent_folder_id?: number;

  @IsOptional()
  @MaxLength(500)
  description?: string;

  @IsOptional()
  @Type(() => Boolean)
  is_system_folder?: boolean = false;
}
```

### **Grant Permission DTO**
```typescript
// grant-permission.dto.ts
export class GrantPermissionDto {
  @IsOptional()
  @Type(() => Number)
  user_id?: number;

  @IsOptional()
  @Type(() => Number)
  role_id?: number;

  @IsNotEmpty()
  @IsEnum(['read', 'write', 'delete', 'share'])
  permission_type: string;

  @IsOptional()
  @MaxLength(500)
  reason?: string;
}
```

### **File Response DTO**
```typescript
// file-response.dto.ts
export class FileResponseDto {
  file_id: number;
  file_name: string;
  original_filename: string;
  file_size: number;
  mime_type: string;
  file_extension: string;
  uploaded_by: number;
  folder_id?: number;
  download_count: number;
  is_public: boolean;
  status: string;
  uploaded_at: Date;
  updated_at: Date;
  deleted_at?: Date;
  permissions?: string[]; // ['read', 'write']
  versions_count?: number;
  download_url?: string;
}
```

---

## 🧪 Testing Strategy

### **Unit Tests (Services)**

**FileStorage Service Tests:**
```typescript
describe('FileStorageService', () => {
  it('should upload file and return path', () => {});
  it('should download file and stream correctly', () => {});
  it('should delete file from storage', () => {});
  it('should handle large files (>100MB)', () => {});
  it('should calculate checksum correctly', () => {});
});
```

**Files Service Tests:**
```typescript
describe('FilesService', () => {
  it('should create file metadata', () => {});
  it('should update file info', () => {});
  it('should increment download count', () => {});
  it('should soft delete file', () => {});
  it('should retrieve file with versions', () => {});
});
```

**Permissions Service Tests:**
```typescript
describe('FilePermissionsService', () => {
  it('should grant permission to user', () => {});
  it('should grant permission to role', () => {});
  it('should check user permission', () => {});
  it('should cascade permissions from folder', () => {});
  it('should revoke permission', () => {});
});
```

### **Integration Tests (Flows)**

**Upload Flow:**
```typescript
it('should complete full upload flow', async () => {
  // 1. Upload file
  // 2. Verify metadata created
  // 3. Verify version created
  // 4. Verify file accessible to uploader
  // 5. Verify permissions apply
});
```

**Permission Cascade:**
```typescript
it('should cascade folder permissions to files', async () => {
  // 1. Create folder
  // 2. Add files to folder
  // 3. Grant role permission on folder
  // 4. Verify files inherit permission
  // 5. Add new file to folder
  // 6. Verify new file inherits permission
});
```

**Version Rollback:**
```typescript
it('should rollback to previous version', async () => {
  // 1. Upload file (v1)
  // 2. Update file (v2)
  // 3. Update file (v3)
  // 4. Rollback to v1
  // 5. Verify current file = v1
  // 6. Verify v4 created (rollback record)
  // 7. Verify all versions accessible
});
```

---

## 🔒 Security Considerations

### **Input Validation**
```
✓ File size limits (max 500MB per file)
✓ File type whitelist (PDF, DOCX, XLSX, PPTX, images, video)
✓ Filename sanitization (no path traversal)
✓ Folder depth limit (max 10 levels)
✓ Permission type enum validation
```

### **Access Control**
```
✓ All endpoints require authentication
✓ File-level permission checks
✓ Folder-level permission inheritance
✓ User cannot bypass role permissions
✓ Soft delete prevents data loss
```

### **Data Protection**
```
✓ Checksum validation for file integrity
✓ Version history for audit trail
✓ Deleted_at timestamp (soft delete)
✓ Uploaded_by tracking
✓ Permission audit logging
```

### **Storage Security**
```
✓ Files stored outside web root
✓ Randomized filenames (prevent enumeration)
✓ Organize by folder hierarchy
✓ Support for encrypted storage (S3 server-side)
✓ Backup versioning system
```

---

## 📊 File Storage Options

### **Option 1: Local File System** (Development)
```
Pros:
- Simple to implement
- No external dependencies
- Fast local access

Cons:
- Single server only
- No backup
- Not scalable
- Manual cleanup

Structure:
storage/
├── files/
│   ├── 2025/
│   │   ├── 11/
│   │   │   └── 30/
│   │   │       └── file_xyz_1234.pdf
└── versions/
    └── file_5/
        ├── v1_234567.pdf
        └── v2_245678.pdf
```

### **Option 2: AWS S3** (Production)
```
Pros:
- Highly scalable
- Built-in backup
- CDN integration
- Server-side encryption
- Lifecycle policies (auto-archive)

Cons:
- Additional cost
- External dependency
- Latency considerations

Bucket Structure:
eduverse-files/
├── course-materials/
│   ├── cs101/
│   │   └── syllabus.pdf
├── assignments/
│   ├── cs101/
│   │   └── assign1.pdf
├── submissions/
│   ├── user-25/
│   │   └── submission_xyz.pdf
└── versions/
    ├── file-5/
    │   ├── v1.pdf
    │   └── v2.pdf
```

**Abstraction Layer (file-storage.service.ts):**
```typescript
// Injectable service that handles both options
export class FileStorageService {
  async uploadFile(file: Express.Multer.File): Promise<string> {
    if (this.isS3Enabled()) {
      return this.uploadToS3(file);
    } else {
      return this.uploadToLocal(file);
    }
  }

  async downloadFile(filePath: string): Promise<Stream> {
    if (this.isS3Enabled()) {
      return this.downloadFromS3(filePath);
    } else {
      return this.downloadFromLocal(filePath);
    }
  }
}
```

---

## 🚀 Rollout Strategy

### **Phase 3a: Core Features (Days 1-3)**
```
✓ Upload/Download (basic)
✓ Folder structure (create, list, delete)
✓ File CRUD operations
✓ Basic permission system
```

### **Phase 3b: Advanced Features (Days 3-5)**
```
✓ File versioning
✓ Permission cascading
✓ Access controls & guards
✓ Search/Filter capabilities
```

### **Phase 3c: Integration & Testing (Days 5-6)**
```
✓ Integration with Enrollment (course materials)
✓ Integration with Courses (assignments)
✓ Performance optimization
✓ Security hardening
```

---

## 📈 Performance Considerations

### **Optimization Strategies**

**Database Indexes:**
```sql
CREATE INDEX idx_files_folder_id ON files(folder_id);
CREATE INDEX idx_files_uploaded_by ON files(uploaded_by);
CREATE INDEX idx_files_status ON files(status);
CREATE INDEX idx_folders_parent_id ON folders(parent_folder_id);
CREATE INDEX idx_permissions_user_id ON file_permissions(user_id);
CREATE INDEX idx_permissions_role_id ON file_permissions(role_id);
CREATE INDEX idx_versions_file_id ON file_versions(file_id);
```

**Caching:**
```typescript
// Cache permission checks (5 min TTL)
@Cacheable({
  key: 'file_permission_{{fileId}}_{{userId}}',
  ttl: 300
})
async checkPermission(fileId, userId) {
  // Permission check logic
}

// Invalidate on permission change
@CacheEvict({
  key: 'file_permission_*'
})
async grantPermission(...) {
  // Grant logic
}
```

**Pagination:**
```typescript
// Folder contents with pagination
GET /api/folders/:folderId/contents?page=1&limit=20

// File versions with pagination
GET /api/files/:fileId/versions?page=1&limit=10
```

---

## 🔗 Integration Points

### **With Courses Module**
```
Course Materials:
- Create system folder: "CS101 Materials"
- Link to course: courses.course_id
- Auto-create file_permissions: ROLE=STUDENT, PERMISSION=READ

Assignment Submissions:
- Create folder per assignment
- Students upload submissions
- Instructor downloads for grading
```

### **With Enrollment Module**
```
Enrolled Student Access:
- Check: Is user enrolled in course_section?
- If YES: Grant READ access to course materials
- If DROPPED/WITHDRAWN: Revoke access

Submission Grading:
- Instructor can READ/WRITE student submissions
- Track version history of submissions
```

---

## 📝 API Endpoint Summary

| Method | Endpoint | Purpose | Auth Required |
|--------|----------|---------|---------------|
| POST | `/api/files/upload` | Upload file | Yes |
| GET | `/api/files/:fileId/download` | Download file | Yes |
| GET | `/api/files/:fileId` | Get file info | Yes |
| PUT | `/api/files/:fileId` | Update file | Yes |
| DELETE | `/api/files/:fileId` | Delete file | Yes |
| GET | `/api/files/by-folder/:folderId` | List files in folder | Yes |
| POST | `/api/folders` | Create folder | Yes |
| GET | `/api/folders/:folderId` | Get folder info | Yes |
| GET | `/api/folders/:folderId/contents` | List folder contents | Yes |
| DELETE | `/api/folders/:folderId` | Delete folder | Yes |
| GET | `/api/files/:fileId/versions` | List versions | Yes |
| POST | `/api/files/:fileId/versions/:versionId/rollback` | Rollback version | Yes |
| POST | `/api/files/:fileId/permissions` | Grant permission | Yes |
| GET | `/api/files/:fileId/permissions` | List permissions | Yes |
| DELETE | `/api/files/:fileId/permissions/:permissionId` | Revoke permission | Yes |

---

## ✅ Success Criteria

### **Functional Requirements**
- [x] Users can upload files (students, instructors)
- [x] Users can download files (based on permissions)
- [x] Folder hierarchy works (nested up to 10 levels)
- [x] File versioning tracks all changes
- [x] Permissions control access (user/role based)
- [x] Soft delete prevents data loss
- [x] File search functionality works

### **Performance Requirements**
- [x] Upload <5 seconds for 50MB file
- [x] Download starts <2 seconds
- [x] Folder list <1 second (100+ items)
- [x] Permission check <100ms (cached)
- [x] Database queries <200ms

### **Security Requirements**
- [x] All endpoints require authentication
- [x] File access respects permissions
- [x] No path traversal vulnerabilities
- [x] Filenames sanitized
- [x] File type validation

### **Testing Requirements**
- [x] Unit tests: 80%+ coverage
- [x] Integration tests: all major flows
- [x] API tests: all endpoints

---

## 📚 Dependencies

### **NPM Packages**
```json
{
  "@nestjs/common": "^10.0.0",
  "@nestjs/core": "^10.0.0",
  "@nestjs/typeorm": "^9.0.0",
  "typeorm": "^0.3.0",
  "multer": "^1.4.5",
  "class-validator": "^0.14.0",
  "class-transformer": "^0.5.1",
  "aws-sdk": "^2.x.x" // Optional, for S3
}
```

### **Built-in NestJS Features**
```
✓ Guards (for permission checks)
✓ Interceptors (for logging)
✓ Pipes (for validation)
✓ Exception filters (for error handling)
✓ Decorators (custom @HasPermission, etc.)
```

---

## 🎓 Implementation Guide

### **Follow These Patterns (from Enrollments Module)**

1. **Module Setup**
   - Look at: `enrollments.module.ts`
   - Pattern: Export controllers, services, use TypeOrmModule

2. **DTOs**
   - Look at: `dto/enroll-course.dto.ts`
   - Pattern: Use decorators for validation

3. **Services**
   - Look at: `services/enrollments.service.ts`
   - Pattern: Inject repo, use queryBuilder for complex queries

4. **Controllers**
   - Look at: `controllers/enrollments.controller.ts`
   - Pattern: Use guards, validate permissions, return DTO

5. **Exception Handling**
   - Look at: `exceptions/` folder
   - Pattern: Custom exceptions extending BadRequestException

---

## 📞 Support & Next Steps

**Questions to Consider:**
1. Local storage or S3?
2. Max file size limits?
3. File type restrictions?
4. Quota per user/course?
5. Auto-cleanup of deleted files?

**Next Phase (Phase 4):**
- Assignments & Submissions
- Grading System
- Uses File Management heavily

---

**Document Version:** 1.0  
**Last Updated:** 2025-11-30  
**Status:** Ready for Implementation
