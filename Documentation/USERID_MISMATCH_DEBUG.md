# UserId Mismatch Debug Analysis

## Problem Description
- User ID 25 enrolls → DB shows userId 11
- User ID 25 enrolls again → DB shows userId 12 (incremented by 1)
- User ID 25 enrolls again → DB shows userId 13 (incremented by 1)

Pattern: **First enrollment gets a random ID, subsequent enrollments increment by 1**

## Root Cause Analysis

### Hypothesis 1: JWT Payload Contains Wrong UserId ❌
- Auth service creates payload: `{ sub: user.userId, ... }`
- JWT Strategy validates: `userId: payload.sub`
- JWT payload is correct ✅

### Hypothesis 2: Controller Extracts Wrong UserId ✅ LIKELY
**File:** `src/modules/enrollments/controllers/enrollments.controller.ts`

```typescript
@Post('register')
@Roles(RoleName.STUDENT)
async enrollCourse(
  @Request() req,
  @Body() enrollCourseDto: EnrollCourseDto,
): Promise<EnrollmentResponseDto> {
  return this.enrollmentsService.enrollStudent(req.user.userId, enrollCourseDto);
  //                                             ^^^^^^ THIS IS WRONG
}
```

### The Real Issue: User Entity Property Name

The problem is likely that **`req.user` object has a different property name than `userId`**.

Common issues:
1. **`req.user.id`** instead of `req.user.userId`
2. **`req.user.sub`** from JWT payload instead of `req.user.userId`
3. **`req.user` is the User entity** with database column `user_id` but property `userId`

### Check: What Properties Does req.user Have?

Looking at JWT strategy's `validate()` method (line 43):
```typescript
return user;  // Returns full User entity object
```

The User entity has:
```typescript
@PrimaryGeneratedColumn({ name: 'user_id' })
userId: number;  // TypeORM property name
```

So `req.user.userId` should work... **UNLESS**

### The Real Problem: Multiple Calls Creating Different Users! 🔴

Pattern observed:
- 1st enrollment: userId becomes 11
- 2nd enrollment: userId becomes 12
- 3rd enrollment: userId becomes 13

This looks like **`req.user` is not the user entity, but something else is being auto-incremented**.

Possible explanations:
1. **`req.user.userId` is undefined** → defaults to undefined or null
2. **Auto-increment is being triggered** for a related table
3. **Session table `userId` is being used instead** (which is auto-increment)

### Most Likely: req.user.id vs req.user.userId

**Passport typically returns `req.user` with the returned object from validate().**

The validate() returns the User entity, but Passport might transform it.

Check the exact property name that JWT strategy is returning.

## Solution

Add debugging to controller to check what `req.user` contains:

```typescript
@Post('register')
@Roles(RoleName.STUDENT)
async enrollCourse(
  @Request() req,
  @Body() enrollCourseDto: EnrollCourseDto,
): Promise<EnrollmentResponseDto> {
  console.log('req.user:', req.user);  // Debug
  console.log('req.user properties:', Object.keys(req.user));  // Show all keys
  console.log('req.user.userId:', req.user.userId);  // Check this value
  console.log('req.user.id:', req.user.id);  // Check this too
  
  return this.enrollmentsService.enrollStudent(req.user.userId, enrollCourseDto);
}
```

## Likely Fixes

### Fix 1: Use `req.user.id` instead of `req.user.userId`
```typescript
// Change this:
return this.enrollmentsService.enrollStudent(req.user.userId, enrollCourseDto);

// To this:
return this.enrollmentsService.enrollStudent(req.user.id, enrollCourseDto);
```

### Fix 2: Check if userId is null and handle
```typescript
const userId = req.user.userId || req.user.id;
if (!userId) {
  throw new BadRequestException('User ID not found in token');
}
return this.enrollmentsService.enrollStudent(userId, enrollCourseDto);
```

### Fix 3: Check JWT Strategy's validate method
Make sure it returns the correct user object with userId property.

## Files to Check

1. **src/modules/auth/strategies/jwt.strategy.ts** - Line 43 (return user)
2. **src/modules/enrollments/controllers/enrollments.controller.ts** - Line 63 (req.user.userId)
3. **src/modules/auth/entities/user.entity.ts** - Verify userId property

## Next Steps

1. Add console.log statements to debug
2. Check what `req.user` actually contains
3. Verify the property name matches
4. Fix in all enrollment controller methods
5. Test enrollment again
