# Postman Collection Guide - Enrollment API Testing

## 📋 Overview
This guide explains how to use the Postman collection to test the Enrollment API endpoints running on port 8081.

---

## 🚀 Quick Start

### 1. Import Collection & Environment
1. Open Postman
2. Click **Import** in the top left
3. Select **Enrollment_API.postman_collection.json**
4. Click **Import**
5. Click **Import** again
6. Select **Enrollment_API_Environment.postman_environment.json**
7. Click **Import**

### 2. Select Environment
1. Top right, click the **Environment** dropdown
2. Select **"Enrollment API - Local Dev"**

### 3. Verify Base URL
- Ensure base URL is set to: `http://localhost:8081`
- Check environment variables are loaded

---

## 📁 Collection Structure

### 1. Authentication
Test user registration and login
- **Register Student** - Create new student account
- **Login Student** - Get access token
- **Get Current User** - Verify logged-in user

### 2. Enrollment - Student Operations
Student-only endpoints
- **Get My Courses** - View enrolled courses
- **Get Available Courses** - Browse available courses
- **Enroll in Course** - Register for a section
- **Get Enrollment Details** - View enrollment info
- **Drop Course** - Withdraw from course

### 3. Enrollment - Instructor Operations
Instructor-only endpoints
- **Get Section Students** - View enrolled students
- **Get Section Waitlist** - View waitlist

### 4. Enrollment - Admin Operations
Admin-only endpoints
- **Update Enrollment Status** - Change enrollment status
- **Force Drop Enrollment** - Remove student enrollment

### 5. Test Data Setup
Helper endpoints to find test data
- **Get All Courses** - List all courses
- **Get Course Sections** - List sections
- **Get All Semesters** - List semesters
- **Get All Departments** - List departments

---

## 🔑 Authentication Setup

### Step 1: Register a Student
1. Go to **Authentication** → **Register Student**
2. Click **Send**
3. Copy the response (save the user ID if needed)

### Step 2: Login
1. Go to **Authentication** → **Login Student**
2. Verify `email` and `password` match registration
3. Click **Send**
4. Copy the `access_token` from response

### Step 3: Save Token to Environment
1. Open environment variables (gear icon top right)
2. Click **Enrollment API - Local Dev**
3. Find `access_token` variable
4. Paste the token into the **Current Value** field
5. Click **Save**

### Step 4: Use Token in Requests
All requests with `{{access_token}}` variable will now use your token automatically

---

## ✅ Typical Testing Workflow

### Workflow 1: Enroll in a Course

**Step 1: Get Available Courses**
```
GET /api/enrollments/available
Headers: Authorization: Bearer {{access_token}}
```
- Find a course and note its section ID

**Step 2: Enroll in Course**
```
POST /api/enrollments/register
Headers: Authorization: Bearer {{access_token}}
Body: {
  "sectionId": 1  // Use actual section ID
}
```
- Success: Returns enrollment details with status "enrolled"

**Step 3: Verify Enrollment**
```
GET /api/enrollments/my-courses
Headers: Authorization: Bearer {{access_token}}
```
- Should now see the course in your list

### Workflow 2: Drop a Course

**Step 1: Get My Courses**
```
GET /api/enrollments/my-courses
```
- Find an enrollment ID

**Step 2: Drop the Course**
```
DELETE /api/enrollments/{enrollment_id}
Body: {
  "reason": "student_request",
  "notes": "Optional notes"
}
```
- Success: Status changes to "dropped"

### Workflow 3: Instructor Views Class

**Step 1: Login as Instructor** (optional - need instructor account)
```
POST /api/auth/login
Body: {
  "email": "instructor@example.com",
  "password": "Password123!"
}
```

**Step 2: Get Section Students**
```
GET /api/enrollments/section/1/students
Headers: Authorization: Bearer {{instructor_token}}
```
- Returns list of enrolled students

**Step 3: Get Waitlist**
```
GET /api/enrollments/section/1/waitlist
Headers: Authorization: Bearer {{instructor_token}}
```
- Returns empty array (waitlist not implemented)

---

## 📊 Environment Variables Explained

| Variable | Purpose | Default |
|----------|---------|---------|
| `base_url` | API base URL | http://localhost:8081 |
| `access_token` | Student JWT token | (empty - fill after login) |
| `instructor_token` | Instructor JWT token | (empty - optional) |
| `admin_token` | Admin JWT token | (empty - optional) |
| `student_email` | Test student email | student@example.com |
| `student_password` | Test student password | Password123! |
| `course_id` | Test course ID | 1 |
| `section_id` | Test section ID | 1 |
| `semester_id` | Test semester ID | 1 |
| `enrollment_id` | Test enrollment ID | 1 |

### How to Update Variables
1. Click gear icon (⚙️) top right
2. Select your environment
3. Edit the **Current Value** column
4. Click **Save**

---

## 🧪 Test Cases

### Test 1: Successful Enrollment
```
1. Authenticate (get token)
2. GET /api/enrollments/available
   ✅ Should return list of courses
   
3. POST /api/enrollments/register
   ✅ Should return enrollment with status="enrolled"
   
4. GET /api/enrollments/my-courses
   ✅ Course should appear in list
```

### Test 2: Cannot Enroll Twice
```
1. POST /api/enrollments/register (section 1)
   ✅ Should succeed
   
2. POST /api/enrollments/register (section 1 again)
   ❌ Should return error: "Already enrolled"
```

### Test 3: Drop Course
```
1. POST /api/enrollments/register
   ✅ Enrollment created
   
2. DELETE /api/enrollments/1
   ✅ Should return enrollment with status="dropped"
   
3. Try DELETE again
   ❌ Should return error: "Cannot drop"
```

### Test 4: Verify Enum Values
```
1. POST /api/enrollments/register
   ✅ Check response: status = "enrolled" (NOT "pending" or "waitlisted")
   
2. DELETE /api/enrollments/1
   ✅ Check response: status = "dropped"
   
3. Check database directly:
   ✅ enrollment_status values are only: enrolled, dropped, completed, withdrawn
```

### Test 5: Instructor Can View Students
```
1. Login as instructor
2. GET /api/enrollments/section/1/students
   ✅ Should return list of enrolled students
   
3. GET /api/enrollments/section/1/waitlist
   ✅ Should return empty array []
```

---

## 🔍 Debugging Tips

### Check Status Codes
- ✅ **200** - Success
- ✅ **201** - Created
- ❌ **400** - Bad Request (check body)
- ❌ **401** - Unauthorized (check token)
- ❌ **403** - Forbidden (insufficient permissions)
- ❌ **404** - Not Found (check IDs)
- ❌ **409** - Conflict (duplicate enrollment)

### View Full Response
1. Send request
2. Click **Response** tab
3. Scroll through JSON body
4. Check for error messages

### Check Headers
1. Click **Headers** tab in response
2. Verify `Content-Type: application/json`
3. Check for any errors in response headers

### Copy Token from Response
1. In **Response** body, find `"accessToken"` or `"access_token"`
2. Click on value to select
3. Ctrl+C to copy
4. Paste into environment variable

---

## 🚨 Common Errors & Solutions

### Error: "Unauthorized"
**Problem:** Token missing or expired
**Solution:** 
1. Go to Authentication → Login Student
2. Get new token
3. Update environment variable

### Error: "Data truncated for column 'enrollment_status'"
**Problem:** Invalid enum value used
**Solution:**
- Use only: `enrolled`, `dropped`, `completed`, `withdrawn`
- NOT: `pending`, `waitlisted`, `rejected`

### Error: "Unknown column 'course_id'"
**Problem:** Old schema being used
**Solution:**
- Use `section_id` not `course_id`
- Rebuild TypeORM entities

### Error: "Section not found"
**Problem:** Invalid section ID
**Solution:**
1. Go to Test Data Setup → Get Course Sections
2. Find a valid section ID
3. Update `section_id` in environment
4. Retry enrollment

### Error: "Cannot drop past enrollment"
**Problem:** Trying to drop already dropped course
**Solution:**
- Cannot drop same enrollment twice
- Get my courses to find active enrollments
- Only ENROLLED enrollments can be dropped

---

## 📝 Request Examples

### Register
```bash
POST http://localhost:8081/api/auth/register
Content-Type: application/json

{
  "email": "student@example.com",
  "password": "Password123!",
  "firstName": "John",
  "lastName": "Doe",
  "phone": "1234567890"
}
```

### Login
```bash
POST http://localhost:8081/api/auth/login
Content-Type: application/json

{
  "email": "student@example.com",
  "password": "Password123!"
}

RESPONSE:
{
  "accessToken": "eyJhbGc...",
  "user": { ... }
}
```

### Enroll
```bash
POST http://localhost:8081/api/enrollments/register
Authorization: Bearer {{access_token}}
Content-Type: application/json

{
  "sectionId": 1
}

RESPONSE:
{
  "id": 123,
  "userId": 1,
  "sectionId": 1,
  "status": "enrolled",
  "enrollmentDate": "2025-11-30T...",
  ...
}
```

### Drop
```bash
DELETE http://localhost:8081/api/enrollments/123
Authorization: Bearer {{access_token}}
Content-Type: application/json

{
  "reason": "student_request"
}

RESPONSE:
{
  "id": 123,
  "status": "dropped",
  "droppedAt": "2025-11-30T...",
  ...
}
```

---

## ✨ Pro Tips

1. **Use Variables** - Click "{{variable_name}}" to use environment variables
2. **Save Responses** - Click "Save Response" to store test data
3. **Pre-request Script** - Automatically run login before each request
4. **Collection Runner** - Run all tests in sequence
5. **Monitor** - Watch all API calls in real-time

---

## 🎯 Validation Checklist

After each test, verify:
- [ ] Response status is correct
- [ ] Response body has expected fields
- [ ] `status` field uses valid enum values
- [ ] `programId` field is present (can be null)
- [ ] Timestamps are valid ISO format
- [ ] No database errors in response
- [ ] No schema errors (column name mismatches)

---

## 🔗 Related Documentation

See these files for more details:
- `ENROLLMENT_TESTING_PLAN.md` - Comprehensive test cases
- `ENROLLMENT_API_EXAMPLES.md` - More request examples
- `ENROLLMENT_QUICK_FIX_REFERENCE.md` - Quick reference
- `ENROLLMENT_ISSUES_ANALYSIS.md` - What was fixed

---

## 📞 Support

If you encounter issues:
1. Check the error message carefully
2. Review the relevant documentation
3. Verify all IDs are correct
4. Ensure token is valid (not expired)
5. Check server is running on port 8081

---

**Collection Version:** 1.0
**Created:** 2025-11-30
**Last Updated:** 2025-11-30
**Status:** Ready for Testing ✅
