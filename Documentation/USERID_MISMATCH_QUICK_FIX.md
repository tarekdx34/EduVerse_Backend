# ⚡ UserId Mismatch - Quick Action Guide

## What's Wrong
User ID 25 enrolls → Database shows user_id 11, 12, 13 (incrementing)

## What We Did
Added debugging and fallback logic to find the root cause

## What You Need to Do NOW

### Step 1: Rebuild & Start Server
```bash
npm run build
npm start
```

### Step 2: Test Enrollment
Using Postman:
1. **Register** → `POST /api/auth/register`
2. **Login** → `POST /api/auth/login` → Copy token
3. **Enroll** → `POST /api/enrollments/register` { "sectionId": 1 }

### Step 3: Check Server Console
Look for this output:
```
=== ENROLL DEBUG ===
req.user: [Object]
req.user.userId: 25
req.user.id: undefined
req.user properties: [ 'userId', 'email', 'firstName', ... ]
==================
```

### Step 4: Tell Me What You See
Share the console output, specifically:
- What is the value of `req.user.userId`?
- What is the value of `req.user.id`?
- What are ALL the properties in `req.user`?

### Step 5: Check Database
```sql
SELECT * FROM course_enrollments ORDER BY enrollment_id DESC LIMIT 1;
```

Did the enrollment save with the CORRECT user_id (25)?

---

## Expected Outcomes

### ✅ If FIXED
- Console shows: `req.user.userId: 25`
- Database shows: `user_id: 25`
- Enrollment saves correctly
- Delete works because user_id matches

### ❌ If NOT FIXED
- Console shows: `req.user.userId: undefined`
- Database shows: `user_id: 11` or `user_id: 12`
- We need to fix JWT strategy
- Send me the console output

---

## Files Modified

✅ **src/modules/enrollments/controllers/enrollments.controller.ts**
- Added: Fallback logic for userId
- Added: Debug logging
- Added: Error handling

📍 **Still builds:** npm run build ✅

---

## Files to Check After Debug

If `req.user.userId` is undefined, we need to fix:

**src/modules/auth/strategies/jwt.strategy.ts** (line 43)
```typescript
// Currently returns: user (full User entity)
// Might need to return: { userId: user.userId, ... }
```

---

## Timeline

1. **NOW** → Start server & test (5 min)
2. **Check console** → Share output (1 min)
3. **Based on output** → Apply permanent fix (10 min)
4. **Verify** → Test enrollment again (5 min)

---

## Questions?

If enrollment still saves with wrong userId after fix:
- Check what exactly is in `req.user`
- Look for any property that equals 25
- We'll use that property instead

**Remember:** The console output will tell us exactly what to fix!
