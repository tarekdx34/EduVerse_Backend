# Course Soft Delete - Important Information

## What is Soft Delete?

The course deletion uses **soft delete**, which means:
- ✅ The record is **marked as deleted** in the database (deleted_at timestamp is set)
- ✅ The record is **NOT physically removed** from the database
- ✅ The record is **automatically excluded** from all normal queries
- ✅ The deletion is **reversible** (audit trail preserved)

## Delete Request Behavior

### DELETE /api/courses/:id

**What you see:**
```
HTTP 204 No Content
(Empty response body)
```

**What happens in the database:**
- The `deleted_at` column for course ID 14 is set to the current timestamp
- The record remains in the database but is hidden from normal queries
- All related data (prerequisites, sections, schedules) remains intact

**Example (before):**
```sql
| id | name | code | deleted_at |
| 14 | Math | MTH201 | NULL |
```

**Example (after):**
```sql
| id | name | code | deleted_at |
| 14 | Math | MTH201 | 2025-11-27 18:09:19 |
```

## Verification

### To verify the soft delete worked:

**1. Query in MySQL directly:**
```sql
-- See soft-deleted records
SELECT * FROM courses WHERE deleted_at IS NOT NULL;

-- See active records only (what the API returns)
SELECT * FROM courses WHERE deleted_at IS NULL;
```

**2. Try to retrieve the deleted course via API:**
```bash
GET /api/courses/14
```

**Response:**
```json
{
  "statusCode": 404,
  "message": "Course with ID 14 not found",
  "error": "Not Found"
}
```

The API returns 404 because it automatically filters out soft-deleted records.

## Why Soft Delete?

1. **Data Integrity**: Preserves referential relationships
2. **Audit Trail**: Keeps historical record of what was deleted and when
3. **Reversibility**: Can be restored if needed
4. **Compliance**: Maintains data for compliance/regulatory requirements

## Hard Delete (if needed)

To physically remove a record from the database, use a direct SQL query:

```sql
-- WARNING: This is permanent and irreversible!
DELETE FROM courses WHERE id = 14;
```

⚠️ **Do NOT use hard delete in production** as it breaks referential integrity with prerequisites, sections, and schedules.

## Delete Constraints

A course **cannot be deleted** (soft or hard) if it has active sections:

**Active sections** = status is OPEN, CLOSED, or FULL

**Inactive sections** = status is CANCELLED

### To delete a course with active sections:

1. First, close or cancel all sections:
```bash
PATCH /api/sections/:id
```

2. Request body:
```json
{
  "status": "CANCELLED"
}
```

3. Then delete the course:
```bash
DELETE /api/courses/14
```

## FAQ

**Q: Why does the API return 204 (success) if nothing was deleted?**
A: The deletion IS successful - it soft-deletes the record by setting deleted_at. The record is still in the database but marked as deleted and hidden from queries.

**Q: Can I see the deleted record in the database?**
A: Yes, query WHERE deleted_at IS NOT NULL to see soft-deleted records.

**Q: Can I restore a deleted course?**
A: Not through the API. You would need a database migration or direct SQL UPDATE to set deleted_at back to NULL. This is intentional for security.

**Q: Why am I still seeing the course in the database?**
A: Because soft delete doesn't remove the row - it just marks it. This is by design. Use MySQL queries with `WHERE deleted_at IS NULL` to see only active records.

## Implementation Details

The soft delete is implemented using TypeORM's `@DeleteDateColumn()` decorator:

```typescript
@DeleteDateColumn({
  name: 'deleted_at',
  nullable: true,
})
deletedAt: Date | null;
```

All queries automatically exclude soft-deleted records because every query builder includes:
```typescript
where('course.deletedAt IS NULL')
```
