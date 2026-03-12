# 📁 File Management - Quick Reference Guide

## Overview
4 core tables + hierarchical permission system for upload/download/version control

---

## 🗂️ Table Quick Reference

| Table | Purpose | Key Columns |
|-------|---------|------------|
| `folders` | Hierarchy (tree structure) | folder_id, parent_folder_id, path, level |
| `files` | File metadata | file_id, file_path, status, folder_id |
| `file_versions` | Version history | version_id, file_id, version_number |
| `file_permissions` | Access control | permission_id, file_id/folder_id, user_id/role_id |

---

## 🏗️ Module Structure

```
src/modules/files/
├── files.module.ts
├── controllers/
│   ├── files.controller.ts       (upload, download, CRUD)
│   ├── folders.controller.ts     (folder CRUD)
│   ├── file-versions.controller.ts  (versions, rollback)
│   └── file-permissions.controller.ts (grant, revoke)
├── services/
│   ├── files.service.ts
│   ├── folders.service.ts
│   ├── file-versions.service.ts
│   ├── file-permissions.service.ts
│   └── file-storage.service.ts   (abstraction: local/S3)
├── entities/ (4 TypeORM entities)
├── dtos/ (DTOs for each operation)
├── guards/ (permission checks)
├── enums/ (status, permission types)
└── exceptions/ (custom exceptions)
```

---

## 📝 Implementation Checklist

### Day 1-2: Setup
- [ ] Create `files.module.ts`
- [ ] Create 4 TypeORM entities
- [ ] Create file storage config (local/S3)
- [ ] Add module to `app.module.ts`

### Day 2-3: Services
- [ ] `file-storage.service.ts` (upload/download abstraction)
- [ ] `files.service.ts` (file CRUD)
- [ ] `folders.service.ts` (folder CRUD + hierarchy)
- [ ] `file-versions.service.ts` (version management)

### Day 3-4: Permissions & Guards
- [ ] `file-permissions.service.ts` (grant/revoke/check)
- [ ] `file-access.guard.ts` (permission enforcement)
- [ ] `folder-access.guard.ts` (cascade logic)

### Day 4-5: Controllers & DTOs
- [ ] Files controller (4 endpoints)
- [ ] Folders controller (4 endpoints)
- [ ] Versions controller (3 endpoints)
- [ ] Permissions controller (3 endpoints)
- [ ] DTOs for each operation

### Day 5-6: Testing
- [ ] Unit tests (services)
- [ ] Integration tests (flows)
- [ ] API tests (Postman)

---

## 🔐 Permission Logic

### Default Role Permissions
```
ADMIN:     All files/folders: CREATE, READ, UPDATE, DELETE
INSTRUCTOR: Own files: all, Course materials: READ, Submissions: UPDATE
STUDENT:   Course materials: READ, Own submissions: CREATE/UPDATE/DELETE
```

### Permission Check (Pseudo-code)
```typescript
async checkPermission(userId, fileId, action: 'read'|'write'|'delete') {
  // 1. Check direct user permission
  const userPerm = await repo.findOne({
    file_id: fileId,
    user_id: userId,
    permission_type: action
  });
  if (userPerm) return true;

  // 2. Check role-based permission
  const userRoles = await getUserRoles(userId);
  const rolePerm = await repo.findOne({
    file_id: fileId,
    role_id: In(userRoles),
    permission_type: action
  });
  if (rolePerm) return true;

  // 3. Check folder permissions (cascade)
  const file = await filesRepo.findOne(fileId);
  return await checkFolderPermission(userId, file.folder_id, action);
}
```

---

## 🔄 Core Operations

### Upload
```typescript
POST /api/files/upload
Content-Type: multipart/form-data

// Flow:
1. Validate file (size, type, folder_id)
2. Store file (local/S3)
3. Create file metadata
4. Create initial version (v1)
5. Return file info
```

### Download
```typescript
GET /api/files/:fileId/download

// Flow:
1. Check file exists
2. Check READ permission
3. Stream file to client
4. Increment download_count
```

### Create Folder
```typescript
POST /api/folders
{
  folder_name: "CS101 Materials",
  parent_folder_id: 1, // Optional
}

// Flow:
1. Validate parent folder (if provided)
2. Calculate path based on parent
3. Create folder record
4. Set level based on hierarchy
```

### Grant Permission
```typescript
POST /api/files/:fileId/permissions
{
  user_id: 25,           // OR role_id
  permission_type: "read"
}

// Flow:
1. Check if granter has permission to grant
2. Create permission record
3. Cascade to related files/folders
```

### Rollback Version
```typescript
POST /api/files/:fileId/versions/:versionId/rollback

// Flow:
1. Get target version data
2. Copy to new version
3. Update file.file_path
4. Create version record (new)
5. Return updated file info
```

---

## 🎯 Key Patterns (From Enrollments Module)

1. **Module Structure**: Copy from `enrollments.module.ts`
2. **DTO Validation**: Use `@IsNotEmpty()`, `@MaxLength()`, etc.
3. **Service Injection**: Constructor injection with `@Inject()`
4. **Controllers**: Use guards, return DTOs, handle pagination
5. **Error Handling**: Custom exceptions in `exceptions/` folder
6. **Testing**: Service specs with mocked repos

---

## 📊 Database Queries (Common)

### Get folder contents with permissions
```sql
SELECT f.*, p.permission_type
FROM files f
LEFT JOIN file_permissions p 
  ON f.file_id = p.file_id 
  AND (p.user_id = ? OR p.role_id IN (?))
WHERE f.folder_id = ?
  AND f.status != 'deleted'
ORDER BY f.uploaded_at DESC;
```

### Check cascading permissions
```sql
WITH RECURSIVE folder_hierarchy AS (
  SELECT folder_id, parent_folder_id
  FROM folders WHERE folder_id = ?
  UNION ALL
  SELECT f.folder_id, f.parent_folder_id
  FROM folders f
  INNER JOIN folder_hierarchy fh 
    ON f.folder_id = fh.parent_folder_id
)
SELECT DISTINCT p.permission_type
FROM file_permissions p
WHERE p.folder_id IN (SELECT folder_id FROM folder_hierarchy)
  AND (p.user_id = ? OR p.role_id IN (?));
```

### Get file version history
```sql
SELECT * FROM file_versions
WHERE file_id = ?
ORDER BY version_number DESC;
```

---

## 🧪 Test Scenarios

### Upload Scenario
```
1. Instructor uploads lecture.pdf → Course Materials
2. System creates file + version v1
3. System auto-grants STUDENT role READ permission
4. Students can download lecture.pdf
5. Instructor can update (v2), students get new version
```

### Permission Cascade
```
1. Create folder "CS101 Materials"
2. Add 5 files to folder
3. Grant STUDENT role READ permission on folder
4. Verify all 5 files readable by students
5. Add 6th file to folder
6. Verify 6th file also readable by students (inherited)
```

### Version Rollback
```
1. Upload assignment.pdf (v1)
2. Update assignment.pdf (v2) - added deadline
3. Update assignment.pdf (v3) - changed deadline
4. Rollback to v1 (original)
5. Verify v4 created (rollback record)
6. Verify all versions accessible
```

---

## 🔒 Security Checklist

- [ ] All endpoints require JWT auth
- [ ] File upload: validate type & size
- [ ] Filename sanitization (no path traversal)
- [ ] Permission checks before download
- [ ] Soft delete (no permanent loss)
- [ ] Checksum validation
- [ ] File stored outside web root

---

## 📈 Performance Tips

1. **Index columns**: folder_id, uploaded_by, status
2. **Cache permission checks** (5 min TTL)
3. **Paginate folder contents** (20 items default)
4. **Stream large files** (don't load all in memory)
5. **Use queryBuilder** for complex queries

---

## 🔗 Integration Points

**Courses Module:**
- Create system folders for each course
- Link course materials to folders
- Grant permissions based on enrollment

**Enrollment Module:**
- Check enrollment status before file access
- Auto-revoke access on drop/withdraw
- Track submissions per student

**Grading Module (Future):**
- Access student submissions
- Upload feedback files
- Version track graded submissions

---

## 💡 Implementation Tips

1. **Start Simple**: Get basic upload/download working first
2. **Test Permissions Early**: Don't leave permission system for last
3. **Use Guards**: Leverage NestJS guards for permission checks
4. **Plan Storage**: Decide local vs S3 before implementation
5. **Audit Trail**: Log all file operations for compliance

---

## 📞 Common Questions

**Q: How to handle large files?**
A: Stream upload/download, implement chunking, set size limits in config

**Q: How to backup versions?**
A: Keep all versions in storage, set retention policy (30 days auto-cleanup)

**Q: How to handle deleted files?**
A: Use soft delete (deleted_at), keep in DB for 30 days, then hard delete

**Q: Permission inheritance order?**
A: User-specific > Role-based > Folder cascade > Default deny

**Q: Max file size?**
A: Set in config, suggest 500MB per file, 10GB per user

---

## 🎓 References

- Check: `src/modules/enrollments/` (module structure)
- Check: `src/modules/courses/` (controller patterns)
- Database: `eduverse_db.sql` (schema details)
- Phase: `FILE_MANAGEMENT_PHASE_PLAN.md` (detailed guide)

---

**Version:** 1.0  
**Last Updated:** 2025-11-30  
**Next Phase:** Assignments & Submissions (uses File Management)
