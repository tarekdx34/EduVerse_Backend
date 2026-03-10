# 🚀 Complete Test Suite - Run All Endpoints Simultaneously

## 📋 Overview

This complete test collection automatically:
- ✅ Logs in all 3 users (student, admin, instructor)
- ✅ Gets test data (semesters, courses, sections)
- ✅ Runs all student operations
- ✅ Runs all instructor operations
- ✅ Runs all admin operations
- ✅ Cleans up by dropping enrollment
- ✅ Verifies all operations with assertions
- ✅ Shows detailed console output for each operation

## 📦 File

**`Enrollment_API_Complete_Test.postman_collection.json`**

## 🚀 How to Import

### Step 1: Import Collection
1. Open **Postman**
2. Click **Import** (top left)
3. Select the file: `Enrollment_API_Complete_Test.postman_collection.json`
4. Click **Import**

### Step 2: Create/Select Environment
1. Gear icon (top right) → **Environments**
2. Create new environment called: **"Enrollment Test"**
3. Leave variables empty (they will be auto-filled)
4. Save
5. Select environment from dropdown

## ▶️ How to Run All Tests

### Option 1: Collection Runner (Recommended)
1. Click **Collection** in the left panel
2. Find **Enrollment API - Complete Test Suite**
3. Click the **▶️ Play** icon (Run Collection)
4. Settings:
   - **Delay:** 100ms (between requests)
   - **Keep cookies:** OFF
   - **Data file:** None
5. Click **Run**

### Option 2: Manual Sequential
1. Go to **Setup & Authentication** folder
2. Run each endpoint in order:
   1. Student Login
   2. Admin Login
   3. Instructor Login
   4. Get Test Data (all 3)
3. Go to **Student Endpoints** → Run all in order
4. Go to **Instructor Endpoints** → Run all in order
5. Go to **Admin Endpoints** → Run all in order
6. Go to **Cleanup & Verification** → Run all in order

## 📊 What Gets Tested

### Setup Phase (Automatic)
```
✅ Student Login - tarekstudent@gmail.com
✅ Admin Login - tarekadmin@gmail.com
✅ Instructor Login - tarekinstructor@gmail.com
✅ Get Semesters
✅ Get Courses
✅ Get Course Sections
```

### Student Operations
```
✅ Get Current User (Student)
✅ Get Available Courses
✅ Enroll in Course → Returns enrollment_id
✅ Get My Courses → Verify enrollment exists
✅ Get Enrollment Details → Verify userId matches
```

### Instructor Operations
```
✅ Get Current User (Instructor)
✅ Get Section Students → Shows enrolled students
✅ Get Section Waitlist → Empty array
```

### Admin Operations
```
✅ Get Current User (Admin)
✅ Update Enrollment Status → Changes to 'completed'
✅ Get All Semesters
✅ Get All Departments
✅ Get Course Sections
```

### Cleanup
```
✅ Drop Course → Status changes to 'dropped'
✅ Verify Dropped → Confirms not in active list
```

## 📈 Console Output

When you run, check the **Console** tab (bottom left) for:

```
✅ Student Token Set: eyJhbGc...
✅ Student ID: 25
✅ Admin Token Set: eyJhbGc...
✅ Admin ID: 28
✅ Instructor Token Set: eyJhbGc...
✅ Instructor ID: 30
✅ Semester ID Set: 1
✅ Course ID Set: 5
✅ Section ID Set: 12
✅ Available Courses Retrieved, Section ID: 12
✅ Enrolled Successfully - Enrollment ID: 456, Status: enrolled, UserId: 25
✅ Found 1 enrolled courses
   - Course: Computer Science 101, Status: enrolled
✅ Enrollment Details: ID=456, UserId=25, Status=enrolled
✅ Instructor User Info Retrieved
✅ Found 1 students in section
   - StudentId: 25, Status: enrolled
✅ Waitlist Retrieved (Count: 0)
✅ Admin User Info Retrieved
✅ Enrollment Status Updated to: completed
✅ Found 1 semesters
   - Fall 2024 (FA24)
✅ Found 3 departments
   - Computer Science (CS)
   - Information Technology (IT)
   - Engineering (ENG)
✅ Found 12 sections
✅ Course Dropped - Status: dropped
✅ Verified: Dropped enrollment no longer in active list
```

## ✅ Test Assertions

Each endpoint includes automatic tests:

### All endpoints check:
- ✅ Status code is correct (200 or 201)
- ✅ Response has expected properties
- ✅ Data types are correct

### Specific assertions:
- Enrollment status must be 'enrolled'
- UserId must match student ID
- Update status must change to 'completed'
- Dropped status must be 'dropped'
- Waitlist must be empty array

## 🔄 Auto-Generated Variables

The collection automatically creates variables:

| Variable | Set By | Used For |
|----------|--------|----------|
| `student_token` | Student Login | Student requests |
| `admin_token` | Admin Login | Admin requests |
| `instructor_token` | Instructor Login | Instructor requests |
| `student_id` | Student Login | Verify userId |
| `admin_id` | Admin Login | Admin operations |
| `instructor_id` | Instructor Login | Instructor operations |
| `semester_id` | Get Semesters | Filter requests |
| `course_id` | Get Courses | Section requests |
| `section_id` | Get Sections | Enrollment requests |
| `available_section_id` | Available Courses | Enroll request |
| `enrollment_id` | Enroll response | Get/Update requests |

## 💡 Pro Tips

1. **Run Multiple Times:**
   - Each run will create new enrollments
   - Check database to see all records

2. **Check Collection Runner Output:**
   - Click each test to see detailed results
   - Red X = Failed test
   - Green ✓ = Passed test

3. **Monitor Console Tab:**
   - Shows all custom logs
   - Displays extracted variable values
   - Useful for debugging

4. **Test Results Summary:**
   - Should show ~30 passed tests
   - 0 failed tests
   - 0 skipped tests

## 🧪 Testing Checklist

### Before Running:
- [ ] Server running on port 8081
- [ ] Collection imported
- [ ] Environment selected
- [ ] Users exist (student, admin, instructor)

### After Running:
- [ ] No failed tests
- [ ] Console shows all ✅ messages
- [ ] All tokens extracted
- [ ] Test data populated
- [ ] Enrollment created & verified
- [ ] Status updated by admin
- [ ] Enrollment dropped
- [ ] Database shows correct userId

## 📊 Expected Results

```
Total Tests: ~30
Passed: 30 ✓
Failed: 0
Skipped: 0
Duration: ~2-3 seconds

Test Summary:
├─ Setup & Authentication (6/6 passed)
├─ Student Operations (5/5 passed)
├─ Instructor Operations (3/3 passed)
├─ Admin Operations (5/5 passed)
└─ Cleanup & Verification (2/2 passed)
```

## 🚨 Troubleshooting

### Error: "Cannot GET /api/..."
- ❌ Wrong endpoint URL
- ✅ Check POSTMAN_ENDPOINTS_CORRECTION.md

### Error: "Unauthorized"
- ❌ Token expired or missing
- ✅ Re-run login requests first

### Error: "User not found"
- ❌ Credentials wrong
- ✅ Use exact emails/passwords provided

### Error: "Already enrolled"
- ❌ Student already enrolled in this section
- ✅ Use different section_id

### Error: "Section not found"
- ❌ Invalid section_id
- ✅ Run "Get Available Courses" first

## 📚 Related Files

- `POSTMAN_QUICK_REFERENCE.md` - Endpoint reference
- `POSTMAN_ENDPOINTS_CORRECTION.md` - Endpoint corrections
- `POSTMAN_COLLECTION_GUIDE.md` - Detailed guide

## ✨ Summary

This collection provides:
- ✅ **Automatic authentication** with all 3 users
- ✅ **Complete test coverage** of all endpoints
- ✅ **Data extraction** for dependent requests
- ✅ **Assertion testing** for each endpoint
- ✅ **Console logging** for verification
- ✅ **Sequential execution** with auto delay
- ✅ **Cleanup operations** for data integrity

**Ready to test!** 🚀

---

**Last Updated:** 2025-11-30
**Version:** 1.0
**Status:** ✅ Complete & Ready to Use
