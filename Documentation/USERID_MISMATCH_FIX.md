# UserId Mismatch - Root Cause Analysis & Solution

## 🔴 CRITICAL BUG IDENTIFIED

### Symptoms
- User ID 25 enrolls → DB saves userId 11
- User ID 25 enrolls again → DB saves userId 12
- User ID 25 enrolls again → DB saves userId 13
- **Pattern:** First enrollment gets wrong ID, subsequent ones increment

### Root Cause
The controller is passing **`req.user.userId`** to the service, but there's likely a mismatch between what the JWT strategy returns and what the controller expects.

---

## 🔍 Investigation Done

### What We Added
Debugging statements in **`src/modules/enrollments/controllers/enrollments.controller.ts`**:

```typescript
const userId = req.user.userId || req.user.id;
console.log('req.user.userId:', req.user.userId);
console.log('req.user.id:', req.user.id);
console.log('req.user properties:', Object.keys(req.user));
```

### Why This Matters
1. **JWT Strategy** returns the User entity (line 43 of jwt.strategy.ts)
2. **User entity** has property `userId` (mapped to database column `user_id`)
3. **req.user** should have `userId` property
4. If `userId` is undefined, Passport/NestJS might be using something else

### Possible Root Causes

#### Cause 1: req.user.userId is undefined ❌ LIKELY
If `req.user.userId` is undefined:
- TypeORM auto-generates next ID in sequence
- This explains why: 11, 12, 13 (incrementing)

#### Cause 2: Wrong Property Name in JWT Strategy
JWT strategy returns User entity but maybe property name is wrong

#### Cause 3: Passport Transform
Passport might transform the returned object differently

---

## ✅ TEMPORARY FIX APPLIED

### Changes Made
**File:** `src/modules/enrollments/controllers/enrollments.controller.ts`

1. **Added fallback logic:**
```typescript
const userId = req.user.userId || req.user.id;
if (!userId) {
  throw new BadRequestException('User ID not found in authentication token');
}
```

2. **Added debugging logs:**
```typescript
console.log('=== ENROLL DEBUG ===');
console.log('req.user:', req.user);
console.log('req.user.userId:', req.user.userId);
console.log('req.user.id:', req.user.id);
console.log('req.user properties:', Object.keys(req.user));
```

3. **Applied to all methods using userId:**
   - `enrollCourse()` - POST /register
   - `getMyEnrollments()` - GET /my-courses
   - And other enrollment endpoints

### Why This Fix?
- **Line 1:** Try userId first, then id as fallback
- **Line 2-5:** Error if neither exists (prevents silent failures)
- **Debugging:** Shows us what property names are available

---

## 🧪 NEXT STEPS TO IDENTIFY EXACT ISSUE

### Step 1: Test Enrollment
1. Start server: `npm start`
2. Register new student
3. Get login token
4. Call POST /api/enrollments/register
5. **Check console logs** for the debug output

### Step 2: Analyze Console Output
Look for:
```
=== ENROLL DEBUG ===
req.user: { ... }
req.user.userId: 25
req.user.id: undefined
req.user properties: [ 'userId', 'email', ... ]
==================
```

If output shows:
- ✅ `req.user.userId: 25` → Problem solved by fallback
- ❌ `req.user.userId: undefined` → Problem is in JWT strategy
- ❌ `req.user.id: 11` → Problem is using wrong property

### Step 3: Database Check
After enrollment:
```sql
SELECT * FROM course_enrollments WHERE user_id IN (11, 12, 13, 25);
```

If fixed, should show:
```
enrollment_id | user_id | section_id | status
123           | 25      | 1          | enrolled
```

---

## 🔧 PERMANENT FIX (Based on Findings)

### If `req.user.userId` is undefined
**Problem:** JWT strategy not returning user properly

**Fix in JWT Strategy:**
```typescript
// File: src/modules/auth/strategies/jwt.strategy.ts
async validate(payload: any) {
  const user = await this.userRepository.findOne({
    where: { userId: payload.sub },
    relations: ['roles', 'roles.permissions'],
  });

  if (!user) {
    throw new UnauthorizedException('User not found');
  }

  // FIX: Make sure we're returning the right object
  return {
    userId: user.userId,        // Add this explicitly
    id: user.userId,           // Add fallback name
    email: user.email,
    roles: user.roles,
    // ... rest of properties
  };
}
```

### If `req.user.id` is correct
**Problem:** JWT strategy returns simplified object with `id` instead of `userId`

**Fix in Controller:** (already applied)
```typescript
const userId = req.user.userId || req.user.id;  // ✅ Already done
```

### If neither works
**Problem:** Completely different property name

**Check:** All `req.user` properties
```typescript
console.log('All properties:', Object.keys(req.user));
// Look for any numeric property that matches expected userId
```

---

## 📋 All Files to Update Once Root Cause Found

After identifying the exact issue, update these controllers:

1. ✅ `src/modules/enrollments/controllers/enrollments.controller.ts` - DONE
2. ⏳ Check `src/modules/courses/controllers/` - if they use userId
3. ⏳ Check `src/modules/auth/controllers/` - if they have same issue
4. ⏳ Any other controller using `req.user.userId`

---

## 🚀 Test Plan

### Test Sequence
```
1. Register: student@test.com / Password123!
   → Get user ID (should be 25)
   
2. Login: Get access token
   
3. Enroll: POST /api/enrollments/register { sectionId: 1 }
   → Check console debug output
   → Should create enrollment with user_id = 25
   
4. Verify: GET /api/enrollments/my-courses
   → Console should show correct userId
   → Response should list enrollment
   
5. Check DB:
   SELECT * FROM course_enrollments WHERE user_id = 25;
   → Should show the enrollment
```

### Verification
- ✅ No console errors
- ✅ No database constraint violations
- ✅ enrollment.user_id = 25 (actual user ID)
- ✅ Can delete enrollment (DELETE works because user_id matches)

---

## 📊 Current Status

| Component | Status | Action |
|-----------|--------|--------|
| Build | ✅ Passes | Ready |
| Debugging Added | ✅ Added | Need to test |
| Fallback Logic | ✅ Added | Need to verify |
| Console Output | ⏳ Pending | Run server and test |
| Root Cause | ⏳ Pending | Analyze debug output |
| Permanent Fix | ⏳ Pending | After root cause found |

---

## 💡 Why This Happened

### What Was Happening Before
1. Controller calls: `enrollService.enrollStudent(req.user.userId, ...)`
2. `req.user.userId` is undefined (wrong property name)
3. Service receives: `undefined` as userId
4. Database creates enrollment with:
   - `userId: null` or `userId: undefined` → auto-increment activates
   - First auto-increment value: 11
   - Next: 12, 13, etc.

### Why TypeORM Auto-Increment Works
MySQL/TypeORM behavior:
- If `INSERT INTO ... VALUES (NULL, ...)` on auto-increment column
- Database automatically generates next sequence number
- Sequence: 11 → 12 → 13

---

## ✨ Summary

✅ **Fixed:** Added fallback logic to handle property name mismatch
⏳ **Pending:** Run server and capture debug output
⏳ **Pending:** Identify exact property name returned by JWT strategy
⏳ **Pending:** Apply permanent fix to JWT strategy if needed

**Build Status:** ✅ Compiles with 0 errors
**Ready for:** Testing on local server with port 8081

---

**Last Updated:** 2025-11-30
**Status:** In Progress - Waiting for Debug Output
