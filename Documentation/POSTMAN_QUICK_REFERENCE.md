# Postman Collection - Quick Reference Card

## 🎯 Files to Import
1. **Enrollment_API.postman_collection.json** - API endpoints
2. **Enrollment_API_Environment.postman_environment.json** - Environment variables

## 📌 Base URL
```
http://localhost:8081
```

---

## 🔓 Authentication Endpoints

| Method | Endpoint | Purpose |
|--------|----------|---------|
| POST | `/api/auth/register` | Create student account |
| POST | `/api/auth/login` | Get access token |
| GET | `/api/auth/me` | Get current user |

**Login Response:**
```json
{
  "accessToken": "eyJhbGc...",
  "user": { "userId": 1, "email": "student@example.com", ... }
}
```

**Copy token to environment variable `{{access_token}}`**

---

## 🎓 Student Endpoints

### Browse Courses
```
GET /api/enrollments/available?page=1&limit=20
Headers: Authorization: Bearer {{access_token}}
```
Response: Array of available courses with sections

### Get My Courses
```
GET /api/enrollments/my-courses
Headers: Authorization: Bearer {{access_token}}
```
Response: Array of enrolled courses

### Enroll in Course
```
POST /api/enrollments/register
Headers: Authorization: Bearer {{access_token}}
Body: { "sectionId": 1 }
```
✅ Status: **enrolled** (NOT pending/waitlisted)

### Get Enrollment Details
```
GET /api/enrollments/{id}
Headers: Authorization: Bearer {{access_token}}
```

### Drop Course
```
DELETE /api/enrollments/{id}
Headers: Authorization: Bearer {{access_token}}
Body: { "reason": "student_request" }
```
✅ Status: **dropped**

---

## 👨‍🏫 Instructor Endpoints

### Get Section Students
```
GET /api/enrollments/section/{sectionId}/students
Headers: Authorization: Bearer {{instructor_token}}
```
✅ Only returns ENROLLED students

### Get Section Waitlist
```
GET /api/enrollments/section/{sectionId}/waitlist
Headers: Authorization: Bearer {{instructor_token}}
```
✅ Returns empty array [] (not implemented yet)

---

## 👨‍💼 Admin Endpoints

### Update Enrollment Status
```
POST /api/enrollments/{id}/status
Headers: Authorization: Bearer {{admin_token}}
Body: { "status": "completed" }
```

### Force Drop
```
DELETE /api/enrollments/{id}
Headers: Authorization: Bearer {{admin_token}}
Body: { "reason": "admin_removal" }
```
✅ Admin can drop any enrollment (no deadline)

---

## 🧪 Quick Test Sequences

### Sequence 1: Student Enrollment (2 min)
```
1. POST /api/auth/register
2. POST /api/auth/login → Copy token
3. GET  /api/enrollments/available → Copy sectionId
4. POST /api/enrollments/register → Should have status="enrolled"
5. GET  /api/enrollments/my-courses → Should appear
```

### Sequence 2: Drop Course (1 min)
```
1. GET /api/enrollments/my-courses → Find enrollmentId
2. DELETE /api/enrollments/{id} → Should have status="dropped"
3. GET /api/enrollments/my-courses → Should NOT appear
```

### Sequence 3: Instructor View (1 min)
```
1. GET /api/enrollments/section/1/students → List of students
2. GET /api/enrollments/section/1/waitlist → Empty array
```

---

## ✅ Verification Checklist

### Enum Values (MUST BE CORRECT)
✅ Enrollment status values:
- `"enrolled"` ✅
- `"dropped"` ✅
- `"completed"` ✅
- `"withdrawn"` ✅

❌ These should NOT appear:
- `"pending"` ❌
- `"waitlisted"` ❌
- `"rejected"` ❌

### Response Fields
✅ All responses should have:
- `id` - Enrollment ID
- `userId` - Student ID
- `sectionId` - Section ID
- `status` - Current status
- `programId` - Can be null
- `enrollmentDate` - ISO format
- `updatedAt` - ISO format

---

## 🚨 HTTP Status Codes

| Code | Meaning | Example |
|------|---------|---------|
| 200 | Success | GET my courses |
| 201 | Created | POST register |
| 400 | Bad Request | Missing sectionId |
| 401 | Unauthorized | Missing token |
| 403 | Forbidden | Wrong role |
| 404 | Not Found | Invalid ID |
| 409 | Conflict | Already enrolled |

---

## 🔧 Environment Variables

| Variable | Value | Usage |
|----------|-------|-------|
| `{{base_url}}` | http://localhost:8081 | All requests |
| `{{access_token}}` | (from login) | Student requests |
| `{{instructor_token}}` | (from login) | Instructor requests |
| `{{admin_token}}` | (from login) | Admin requests |
| `{{section_id}}` | 1 | Enrollment requests |
| `{{enrollment_id}}` | 1 | Get/update requests |

---

## 💡 Common Mistakes to Avoid

❌ Using PENDING status
✅ Use ENROLLED instead

❌ Using WAITLISTED status
✅ Section fills up but still uses ENROLLED

❌ Using course_id
✅ Use section_id instead

❌ Expired token
✅ Re-login to get new token

❌ Wrong role (student trying admin endpoint)
✅ Use correct token for role

---

## 📊 Expected Responses

### Successful Enrollment
```json
{
  "id": 123,
  "userId": 1,
  "sectionId": 1,
  "status": "enrolled",
  "grade": null,
  "finalScore": null,
  "enrollmentDate": "2025-11-30T14:09:00Z",
  "droppedAt": null,
  "completedAt": null,
  "updatedAt": "2025-11-30T14:09:00Z",
  "programId": null,
  "canDrop": true,
  "dropDeadline": "2025-12-15T00:00:00Z"
}
```

### Already Enrolled Error
```json
{
  "statusCode": 409,
  "message": "Student is already enrolled in this section",
  "error": "Conflict"
}
```

### Dropped Enrollment
```json
{
  "id": 123,
  "status": "dropped",
  "droppedAt": "2025-11-30T14:10:00Z",
  ...
}
```

---

## 🎯 Import & Setup (3 steps)

1. **Import Collection**
   - Postman → Import → Enrollment_API.postman_collection.json

2. **Import Environment**
   - Postman → Import → Enrollment_API_Environment.postman_environment.json

3. **Select Environment**
   - Top right dropdown → "Enrollment API - Local Dev"

---

## 📝 Notes

- All requests require Bearer token in Authorization header
- Port: **8081** (custom, not 3000)
- Protocol: **http** (not https)
- Base URL: **http://localhost:8081**

---

**Ready to Test! ✅**

See **POSTMAN_COLLECTION_GUIDE.md** for detailed instructions.
