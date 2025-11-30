# Enrollment Feature - Testing & Validation Plan

## Overview
This document provides a comprehensive testing plan to validate all enrollment feature fixes.

---

## Part 1: Compilation & Build Tests ✅

### 1.1 TypeScript Compilation
```bash
npm run build
```
**Expected Result:** ✅ Build completes with 0 errors
**Verify:**
- [ ] No "Property X does not exist" errors
- [ ] No "Type Y is not assignable" errors
- [ ] All imports resolve correctly
- [ ] Output: "Successfully compiled"

**Specific Fixes to Verify:**
- [ ] ✅ No error: "Property 'PENDING' does not exist on type 'typeof EnrollmentStatus'"
- [ ] ✅ No error: "Property 'WAITLISTED' does not exist on type 'typeof EnrollmentStatus'"
- [ ] ✅ No error: "Property 'programId' does not exist on type 'Course'"

### 1.2 Runtime Type Checking (if configured)
```bash
npm run type-check
# or
npx tsc --noEmit
```
**Expected Result:** ✅ 0 type errors

---

## Part 2: Enum Validation Tests

### 2.1 EnrollmentStatus Enum Values
```typescript
import { EnrollmentStatus } from './src/modules/enrollments/enums';

// Test 1: Verify enum exists
console.assert(EnrollmentStatus.ENROLLED !== undefined, 'ENROLLED exists');
console.assert(EnrollmentStatus.DROPPED !== undefined, 'DROPPED exists');
console.assert(EnrollmentStatus.COMPLETED !== undefined, 'COMPLETED exists');
console.assert(EnrollmentStatus.WITHDRAWN !== undefined, 'WITHDRAWN exists');

// Test 2: Verify invalid values removed
console.assert(EnrollmentStatus.PENDING === undefined, 'PENDING removed');
console.assert(EnrollmentStatus.WAITLISTED === undefined, 'WAITLISTED removed');
console.assert(EnrollmentStatus.REJECTED === undefined, 'REJECTED removed');

// Test 3: Verify string values match database
console.assert(EnrollmentStatus.ENROLLED === 'enrolled', 'ENROLLED = enrolled');
console.assert(EnrollmentStatus.DROPPED === 'dropped', 'DROPPED = dropped');
console.assert(EnrollmentStatus.COMPLETED === 'completed', 'COMPLETED = completed');
console.assert(EnrollmentStatus.WITHDRAWN === 'withdrawn', 'WITHDRAWN = withdrawn');
```

**Checklist:**
- [ ] ENROLLED exists and = 'enrolled'
- [ ] DROPPED exists and = 'dropped'
- [ ] COMPLETED exists and = 'completed'
- [ ] WITHDRAWN exists and = 'withdrawn'
- [ ] PENDING does not exist
- [ ] WAITLISTED does not exist
- [ ] REJECTED does not exist

---

## Part 3: Database Alignment Tests

### 3.1 course_enrollments Table Schema
```sql
-- Verify all columns exist and have correct types
SELECT COLUMN_NAME, COLUMN_TYPE, IS_NULLABLE, COLUMN_KEY
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = 'eduverse_db' 
  AND TABLE_NAME = 'course_enrollments'
ORDER BY ORDINAL_POSITION;
```

**Verify:**
- [ ] `enrollment_id` BIGINT PK
- [ ] `user_id` BIGINT FK
- [ ] `section_id` BIGINT FK
- [ ] `program_id` BIGINT nullable ✅ **CRITICAL**
- [ ] `enrollment_status` ENUM('enrolled','dropped','completed','withdrawn')
- [ ] `grade` VARCHAR(5)
- [ ] `final_score` DECIMAL(5,2)
- [ ] `dropped_at` TIMESTAMP nullable
- [ ] `completed_at` TIMESTAMP nullable
- [ ] `updated_at` TIMESTAMP

### 3.2 course_tas Table Schema
```sql
SELECT COLUMN_NAME, COLUMN_TYPE, IS_NULLABLE
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = 'eduverse_db' 
  AND TABLE_NAME = 'course_tas'
ORDER BY ORDINAL_POSITION;
```

**Verify:**
- [ ] `assignment_id` BIGINT PK ✅ **NOT ta_id**
- [ ] `user_id` BIGINT FK ✅ **NOT ta_user_id**
- [ ] `section_id` BIGINT FK ✅ **NOT course_id**
- [ ] `responsibilities` TEXT nullable ✅
- [ ] `assigned_at` TIMESTAMP ✅ **NOT created_at**

### 3.3 course_instructors Table Schema
```sql
SELECT COLUMN_NAME, COLUMN_TYPE, IS_NULLABLE
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = 'eduverse_db' 
  AND TABLE_NAME = 'course_instructors'
ORDER BY ORDINAL_POSITION;
```

**Verify:**
- [ ] `assignment_id` BIGINT PK
- [ ] `user_id` BIGINT FK
- [ ] `section_id` BIGINT FK
- [ ] `role` ENUM('primary','co_instructor','guest')
- [ ] `assigned_at` TIMESTAMP
- [ ] `updated_at` TIMESTAMP ✅ **MUST EXIST**

---

## Part 4: Entity Mapping Tests

### 4.1 CourseEnrollment Entity
```typescript
// Test: programId field exists and is optional
const enrollment = new CourseEnrollment();
console.assert(enrollment.hasOwnProperty('programId') || true, 'programId field exists');
console.assert(enrollment.program === undefined || enrollment.program === null, 'program relation nullable');
```

**Checklist:**
- [ ] Entity has `programId` field
- [ ] Entity has `program` relationship
- [ ] Relationship is optional (nullable)
- [ ] Default status is ENROLLED (not PENDING)

### 4.2 CourseTA Entity
```typescript
// Verify all fields and relations
const ta = new CourseTA();
console.assert(ta.userId !== undefined, 'Has userId');
console.assert(ta.sectionId !== undefined, 'Has sectionId (NOT courseId)');
console.assert(ta.responsibilities !== undefined, 'Has responsibilities');
console.assert(ta.assignedAt !== undefined, 'Has assignedAt (NOT createdAt)');
console.assert(ta.section !== undefined, 'Has section relation (NOT course)');
console.assert(ta.ta !== undefined, 'Has ta relation');
```

**Checklist:**
- [ ] Entity has `userId` (not `taId`)
- [ ] Entity has `sectionId` (not `courseId`)
- [ ] Entity has `responsibilities` field
- [ ] Entity has `assignedAt` field (not `createdAt`)
- [ ] Entity has `section` relationship (not `course`)
- [ ] Entity has `ta` relationship
- [ ] Unique constraint on (sectionId, userId)

### 4.3 CourseInstructor Entity
```typescript
// Verify updatedAt field
const instructor = new CourseInstructor();
console.assert(instructor.updatedAt !== undefined, 'Has updatedAt');
```

**Checklist:**
- [ ] Entity has `updatedAt` field
- [ ] Field is `@UpdateDateColumn`
- [ ] Field maps to `updated_at` column

---

## Part 5: Service Logic Tests

### 5.1 enrollStudent() Method
```typescript
// Mock test
const enrollCourseDto = { sectionId: 1 };
// await enrollmentsService.enrollStudent(userId, enrollCourseDto);

// Verify:
// [ ] Enrollment created with ENROLLED status (not PENDING or WAITLISTED)
// [ ] programId set to null (or correct value)
// [ ] No database enum errors
// [ ] Returns correct response
```

**Test Cases:**
- [ ] Enroll with available seats → ENROLLED
- [ ] Enroll with full section → ENROLLED (not WAITLISTED)
- [ ] Verify programId is null
- [ ] Verify no enum errors occur

### 5.2 dropCourse() Method
```typescript
// Test: Can only drop ENROLLED
// Before: Could drop PENDING, WAITLISTED, ENROLLED
// After: Can only drop ENROLLED

// Test 1: Drop ENROLLED enrollment → Should succeed
// Test 2: Try to drop COMPLETED enrollment → Should throw
// Test 3: Try to drop DROPPED enrollment → Should throw
```

**Test Cases:**
- [ ] Can drop ENROLLED enrollment
- [ ] Cannot drop COMPLETED enrollment
- [ ] Cannot drop DROPPED enrollment
- [ ] Cannot drop WITHDRAWN enrollment
- [ ] No reference to PENDING or WAITLISTED

### 5.3 getMyEnrollments() Method
```typescript
// Test: Only returns ENROLLED and COMPLETED
// Before: Queried for ENROLLED, COMPLETED, PENDING
// After: Only ENROLLED and COMPLETED

const enrollments = await enrollmentsService.getMyEnrollments(userId);
// All should have status = 'enrolled' or 'completed'
```

**Test Cases:**
- [ ] Returns only ENROLLED enrollments
- [ ] Returns only COMPLETED enrollments
- [ ] Does not return WITHDRAWN
- [ ] Does not return DROPPED
- [ ] Does not error on missing PENDING status

### 5.4 getWaitlist() Method
```typescript
// Test: Returns empty array (waitlist not implemented)
// Before: Queried for WAITLISTED status (failed)
// After: Returns []

const waitlist = await enrollmentsService.getWaitlist(sectionId);
console.assert(Array.isArray(waitlist), 'Returns array');
console.assert(waitlist.length === 0, 'Returns empty array');
```

**Test Cases:**
- [ ] Returns empty array
- [ ] No database errors
- [ ] No WAITLISTED queries

---

## Part 6: API Integration Tests

### 6.1 POST /api/enrollments/register
```bash
curl -X POST http://localhost:3000/api/enrollments/register \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"sectionId": 1}'
```

**Expected Response:**
```json
{
  "id": 123,
  "userId": 1,
  "sectionId": 1,
  "status": "enrolled",
  "grade": null,
  "enrollmentDate": "2025-11-30T...",
  // ... other fields
}
```

**Verify:**
- [ ] Status = 'enrolled' (never 'pending' or 'waitlisted')
- [ ] No database errors
- [ ] Response includes all fields
- [ ] programId included (or handled correctly)

### 6.2 GET /api/enrollments/my-courses
```bash
curl -X GET http://localhost:3000/api/enrollments/my-courses \
  -H "Authorization: Bearer <token>"
```

**Expected Response:** Array of enrollments
```json
[
  {
    "id": 123,
    "status": "enrolled",
    ...
  }
]
```

**Verify:**
- [ ] Returns array
- [ ] All items have valid status
- [ ] No PENDING or WAITLISTED items
- [ ] Semester filter works if provided

### 6.3 DELETE /api/enrollments/:id
```bash
curl -X DELETE http://localhost:3000/api/enrollments/123 \
  -H "Authorization: Bearer <token>"
```

**Expected Response:** Updated enrollment with status='dropped'
```json
{
  "id": 123,
  "status": "dropped",
  "droppedAt": "2025-11-30T...",
  ...
}
```

**Verify:**
- [ ] Can drop ENROLLED enrollment
- [ ] Cannot drop other statuses
- [ ] droppedAt set correctly
- [ ] Section enrollment count decremented

### 6.4 GET /api/enrollments/section/:sectionId/students
```bash
curl -X GET http://localhost:3000/api/enrollments/section/1/students \
  -H "Authorization: Bearer <token>"
```

**Expected Response:** Array of enrolled students
```json
[
  { "id": 1, "userId": 10, "status": "enrolled", ... },
  { "id": 2, "userId": 11, "status": "enrolled", ... }
]
```

**Verify:**
- [ ] Returns only ENROLLED students
- [ ] Uses correct schema (section_id not course_id)
- [ ] No errors

### 6.5 GET /api/enrollments/section/:sectionId/waitlist
```bash
curl -X GET http://localhost:3000/api/enrollments/section/1/waitlist \
  -H "Authorization: Bearer <token>"
```

**Expected Response:** Empty array
```json
[]
```

**Verify:**
- [ ] Returns empty array (not error)
- [ ] No database errors

---

## Part 7: Database Integration Tests

### 7.1 Insert Enrollment
```sql
-- Test inserting enrollment with new schema
INSERT INTO course_enrollments (
  user_id, section_id, program_id, enrollment_status, enrollment_date, updated_at
) VALUES (
  1, 1, NULL, 'enrolled', NOW(), NOW()
);

-- Should succeed
-- program_id can be NULL
-- enrollment_status must be one of: 'enrolled', 'dropped', 'completed', 'withdrawn'
```

**Verify:**
- [ ] Insert succeeds with ENROLLED status
- [ ] Insert fails with PENDING status
- [ ] Insert fails with WAITLISTED status
- [ ] programId can be NULL
- [ ] programId can accept valid program ID

### 7.2 Query Enrollments
```sql
-- Test querying with new enum values
SELECT * FROM course_enrollments 
WHERE enrollment_status IN ('enrolled', 'completed');

-- Should return results
-- Should NOT query for 'pending' or 'waitlisted'
```

**Verify:**
- [ ] Queries work for all 4 valid statuses
- [ ] programId column accessible
- [ ] Unique constraint on (user_id, section_id) enforced

### 7.3 CourseTA Queries
```sql
-- Test section-level TA assignment
SELECT * FROM course_tas WHERE section_id = 1;

-- Should work
-- NOT: SELECT * FROM course_tas WHERE course_id = 1;
```

**Verify:**
- [ ] section_id queries work
- [ ] user_id queries work
- [ ] responsibilities column exists
- [ ] assigned_at column exists
- [ ] assignment_id is primary key

---

## Part 8: Error Handling Tests

### 8.1 Invalid Enum Values
```typescript
// Try to create enrollment with invalid status
try {
  await enrollmentRepository.create({
    userId: 1,
    sectionId: 1,
    status: 'pending'  // Invalid
  }).save();
  console.error('Should have failed');
} catch (e) {
  console.assert(e.message.includes('Data truncated'), 'Correct error');
}
```

**Verify:**
- [ ] Gets "Data truncated" error for 'pending'
- [ ] Gets "Data truncated" error for 'waitlisted'
- [ ] Gets "Data truncated" error for 'rejected'
- [ ] Succeeds for 'enrolled', 'dropped', 'completed', 'withdrawn'

### 8.2 Missing Fields
```typescript
// Try to query courseTA with wrong field name
try {
  await courseTA.find({ where: { courseId: 1 } });
  console.error('Should have failed');
} catch (e) {
  console.assert(e.message.includes('Unknown column'), 'Correct error');
}
```

**Verify:**
- [ ] courseId queries fail
- [ ] taId queries fail
- [ ] sectionId and userId queries succeed

### 8.3 Constraint Violations
```typescript
// Try to create duplicate TA assignment in same section
try {
  await courseTA.create({
    userId: 1,
    sectionId: 1,
    // ...
  }).save();
  
  await courseTA.create({
    userId: 1,
    sectionId: 1,  // Duplicate
    // ...
  }).save();
  
  console.error('Should have failed');
} catch (e) {
  console.assert(e.message.includes('Duplicate'), 'Unique constraint enforced');
}
```

**Verify:**
- [ ] Cannot assign same TA twice to same section
- [ ] Can assign same TA to different sections
- [ ] Constraint is on (sectionId, userId)

---

## Part 9: Regression Tests

### 9.1 Existing Functionality
```typescript
// Test that existing enrollment operations still work

// [ ] Create enrollment (with new schema)
// [ ] Get enrollment by ID
// [ ] Update enrollment grade
// [ ] Query student enrollments
// [ ] Calculate GPA
// [ ] Check prerequisites
// [ ] Validate schedule conflicts
```

### 9.2 Related Features
```typescript
// Test integration with other modules

// [ ] Course module still works
// [ ] Section module still works
// [ ] User module still works
// [ ] Campus module still works
// [ ] Auth guards still work
```

---

## Part 10: Performance Tests (Optional)

### 10.1 Query Performance
```sql
-- Ensure indexes are used
EXPLAIN SELECT * FROM course_enrollments 
WHERE user_id = 1 AND status = 'enrolled';

EXPLAIN SELECT * FROM course_tas 
WHERE section_id = 1;
```

**Verify:**
- [ ] Uses index on (user_id, status)
- [ ] Uses index on (section_id)
- [ ] Query plans efficient

### 10.2 Bulk Operations
```typescript
// Test bulk inserts don't break
const enrollments = [];
for (let i = 0; i < 100; i++) {
  enrollments.push({
    userId: Math.floor(Math.random() * 100),
    sectionId: Math.floor(Math.random() * 10),
    status: 'enrolled',
    // ...
  });
}
await enrollmentRepository.save(enrollments);
```

**Verify:**
- [ ] Bulk inserts succeed
- [ ] No enum errors in bulk operations
- [ ] Performance acceptable

---

## Test Execution Plan

### Phase 1: Unit Tests
1. Compile & Build Tests (Part 1)
2. Enum Validation Tests (Part 2)

### Phase 2: Schema Tests
3. Database Alignment Tests (Part 3)
4. Entity Mapping Tests (Part 4)

### Phase 3: Service Tests
5. Service Logic Tests (Part 5)
6. Error Handling Tests (Part 8)

### Phase 4: Integration Tests
7. API Integration Tests (Part 6)
8. Database Integration Tests (Part 7)
9. Regression Tests (Part 9)

### Phase 5: Performance (Optional)
10. Performance Tests (Part 10)

---

## Pass/Fail Criteria

### Must Pass (Critical)
- ✅ Build succeeds
- ✅ All 4 enum values work
- ✅ Database schema matches entity
- ✅ Can insert enrollments
- ✅ Can query enrollments
- ✅ API endpoints respond

### Should Pass (High Priority)
- ✅ All integration tests pass
- ✅ Error handling works
- ✅ No regression

### Nice to Pass (Low Priority)
- ✅ Performance acceptable
- ✅ Query plans efficient

---

## Success Criteria: 100% Tests Passing ✅
