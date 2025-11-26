# Complete API Endpoints - All Requests

## Base URL
```
http://localhost:3000
```

## Authentication Header (Required for all requests)
```
Authorization: Bearer YOUR_JWT_TOKEN
Content-Type: application/json
```

---

## 📍 CAMPUS ENDPOINTS

### 1. Get All Campuses
```http
GET /api/campuses
Authorization: Bearer YOUR_JWT_TOKEN
```

**Query Parameters (Optional):**
- `status`: Filter by status (active or inactive)

**Example:**
```http
GET /api/campuses?status=active
```

**Response (200 OK):**
```json
[
  {
    "id": 1,
    "name": "Main Campus",
    "code": "MAIN",
    "address": "123 University St",
    "city": "New York",
    "country": "USA",
    "phone": "+1-555-0100",
    "email": "main@university.edu",
    "timezone": "America/New_York",
    "status": "active",
    "createdAt": "2025-01-15T10:30:00Z",
    "updatedAt": "2025-01-15T10:30:00Z"
  }
]
```

---

### 2. Get Campus by ID
```http
GET /api/campuses/:id
Authorization: Bearer YOUR_JWT_TOKEN
```

**URL Parameters:**
- `id`: Campus ID (number)

**Example:**
```http
GET /api/campuses/1
```

**Response (200 OK):**
```json
{
  "id": 1,
  "name": "Main Campus",
  "code": "MAIN",
  "address": "123 University St",
  "city": "New York",
  "country": "USA",
  "phone": "+1-555-0100",
  "email": "main@university.edu",
  "timezone": "America/New_York",
  "status": "active",
  "createdAt": "2025-01-15T10:30:00Z",
  "updatedAt": "2025-01-15T10:30:00Z",
  "departments": [
    {
      "id": 1,
      "name": "Computer Science",
      "code": "CS"
    }
  ]
}
```

---

### 3. Create Campus
```http
POST /api/campuses
Authorization: Bearer YOUR_JWT_TOKEN
Content-Type: application/json
```

**Required Role:** ADMIN

**Request Body:**
```json
{
  "name": "Main Campus",
  "code": "MAIN",
  "address": "123 University Street",
  "city": "New York",
  "country": "USA",
  "phone": "+1-555-0100",
  "email": "main@university.edu",
  "timezone": "America/New_York",
  "status": "active"
}
```

**Minimal Request (Required fields only):**
```json
{
  "name": "Main Campus",
  "code": "MAIN"
}
```

**Response (201 Created):**
```json
{
  "id": 1,
  "name": "Main Campus",
  "code": "MAIN",
  "address": "123 University Street",
  "city": "New York",
  "country": "USA",
  "phone": "+1-555-0100",
  "email": "main@university.edu",
  "timezone": "America/New_York",
  "status": "active",
  "createdAt": "2025-01-15T10:30:00Z",
  "updatedAt": "2025-01-15T10:30:00Z"
}
```

---

### 4. Update Campus
```http
PUT /api/campuses/:id
Authorization: Bearer YOUR_JWT_TOKEN
Content-Type: application/json
```

**Required Role:** ADMIN

**URL Parameters:**
- `id`: Campus ID (number)

**Request Body (all fields optional):**
```json
{
  "name": "Main Campus Updated",
  "code": "MAIN2",
  "address": "456 University Ave",
  "city": "Boston",
  "country": "USA",
  "phone": "+1-555-0456",
  "email": "main2@university.edu",
  "timezone": "America/Boston",
  "status": "inactive"
}
```

**Example:**
```http
PUT /api/campuses/1
```

**Response (200 OK):**
```json
{
  "id": 1,
  "name": "Main Campus Updated",
  "code": "MAIN2",
  "address": "456 University Ave",
  "city": "Boston",
  "country": "USA",
  "phone": "+1-555-0456",
  "email": "main2@university.edu",
  "timezone": "America/Boston",
  "status": "inactive",
  "createdAt": "2025-01-15T10:30:00Z",
  "updatedAt": "2025-01-15T11:00:00Z"
}
```

---

### 5. Delete Campus
```http
DELETE /api/campuses/:id
Authorization: Bearer YOUR_JWT_TOKEN
```

**Required Role:** ADMIN

**URL Parameters:**
- `id`: Campus ID (number)

**Example:**
```http
DELETE /api/campuses/1
```

**Response (204 No Content)**
(Empty response body)

---

## 📚 DEPARTMENT ENDPOINTS

### 1. Get Departments by Campus
```http
GET /api/campuses/:campusId/departments
Authorization: Bearer YOUR_JWT_TOKEN
```

**URL Parameters:**
- `campusId`: Campus ID (number)

**Example:**
```http
GET /api/campuses/1/departments
```

**Response (200 OK):**
```json
[
  {
    "id": 1,
    "name": "Computer Science",
    "code": "CS",
    "campusId": 1,
    "createdAt": "2025-01-15T10:30:00Z",
    "updatedAt": "2025-01-15T10:30:00Z"
  },
  {
    "id": 2,
    "name": "Mathematics",
    "code": "MATH",
    "campusId": 1,
    "createdAt": "2025-01-15T10:35:00Z",
    "updatedAt": "2025-01-15T10:35:00Z"
  }
]
```

---

### 2. Get Department by ID
```http
GET /api/departments/:id
Authorization: Bearer YOUR_JWT_TOKEN
```

**URL Parameters:**
- `id`: Department ID (number)

**Example:**
```http
GET /api/departments/1
```

**Response (200 OK):**
```json
{
  "id": 1,
  "name": "Computer Science",
  "code": "CS",
  "campusId": 1,
  "createdAt": "2025-01-15T10:30:00Z",
  "updatedAt": "2025-01-15T10:30:00Z"
}
```

---

### 3. Create Department
```http
POST /api/departments
Authorization: Bearer YOUR_JWT_TOKEN
Content-Type: application/json
```

**Required Role:** ADMIN

**Request Body:**
```json
{
  "name": "Computer Science",
  "code": "CS",
  "campusId": 1
}
```

**Response (201 Created):**
```json
{
  "id": 1,
  "name": "Computer Science",
  "code": "CS",
  "campusId": 1,
  "createdAt": "2025-01-15T10:30:00Z",
  "updatedAt": "2025-01-15T10:30:00Z"
}
```

---

### 4. Update Department
```http
PUT /api/departments/:id
Authorization: Bearer YOUR_JWT_TOKEN
Content-Type: application/json
```

**Required Role:** ADMIN

**URL Parameters:**
- `id`: Department ID (number)

**Request Body (all fields optional):**
```json
{
  "name": "Computer Science & Engineering",
  "code": "CSE"
}
```

**Example:**
```http
PUT /api/departments/1
```

**Response (200 OK):**
```json
{
  "id": 1,
  "name": "Computer Science & Engineering",
  "code": "CSE",
  "campusId": 1,
  "createdAt": "2025-01-15T10:30:00Z",
  "updatedAt": "2025-01-15T11:00:00Z"
}
```

---

### 5. Delete Department
```http
DELETE /api/departments/:id
Authorization: Bearer YOUR_JWT_TOKEN
```

**Required Role:** ADMIN

**URL Parameters:**
- `id`: Department ID (number)

**Example:**
```http
DELETE /api/departments/1
```

**Response (204 No Content)**
(Empty response body)

---

## 🎓 PROGRAM ENDPOINTS

### 1. Get Programs by Department
```http
GET /api/departments/:deptId/programs
Authorization: Bearer YOUR_JWT_TOKEN
```

**URL Parameters:**
- `deptId`: Department ID (number)

**Example:**
```http
GET /api/departments/1/programs
```

**Response (200 OK):**
```json
[
  {
    "id": 1,
    "name": "B.S. Computer Science",
    "code": "BSCS",
    "degreeType": "bachelor",
    "durationYears": 4,
    "departmentId": 1,
    "description": "Bachelor of Science in Computer Science",
    "status": "active",
    "createdAt": "2025-01-15T10:30:00Z",
    "updatedAt": "2025-01-15T10:30:00Z"
  },
  {
    "id": 2,
    "name": "M.S. Computer Science",
    "code": "MSCS",
    "degreeType": "master",
    "durationYears": 2,
    "departmentId": 1,
    "description": "Master of Science in Computer Science",
    "status": "active",
    "createdAt": "2025-01-15T10:35:00Z",
    "updatedAt": "2025-01-15T10:35:00Z"
  }
]
```

---

### 2. Get Program by ID
```http
GET /api/programs/:id
Authorization: Bearer YOUR_JWT_TOKEN
```

**URL Parameters:**
- `id`: Program ID (number)

**Example:**
```http
GET /api/programs/1
```

**Response (200 OK):**
```json
{
  "id": 1,
  "name": "B.S. Computer Science",
  "code": "BSCS",
  "degreeType": "bachelor",
  "durationYears": 4,
  "departmentId": 1,
  "description": "Bachelor of Science in Computer Science",
  "status": "active",
  "createdAt": "2025-01-15T10:30:00Z",
  "updatedAt": "2025-01-15T10:30:00Z"
}
```

---

### 3. Create Program
```http
POST /api/programs
Authorization: Bearer YOUR_JWT_TOKEN
Content-Type: application/json
```

**Required Role:** ADMIN

**Request Body:**
```json
{
  "name": "B.S. Computer Science",
  "code": "BSCS",
  "degreeType": "bachelor",
  "durationYears": 4,
  "departmentId": 1,
  "description": "Bachelor of Science in Computer Science",
  "status": "active"
}
```

**Minimal Request (Required fields only):**
```json
{
  "name": "B.S. Computer Science",
  "code": "BSCS",
  "degreeType": "bachelor",
  "durationYears": 4,
  "departmentId": 1
}
```

**Degree Types (Required):**
- `bachelor`
- `master`
- `phd`
- `diploma`
- `certificate`

**Duration Years (Required):**
- Must be a positive integer between 1 and 10
- Examples: 4, 2, 3, 1

**Response (201 Created):**
```json
{
  "id": 1,
  "name": "B.S. Computer Science",
  "code": "BSCS",
  "degreeType": "bachelor",
  "durationYears": 4,
  "departmentId": 1,
  "description": "Bachelor of Science in Computer Science",
  "status": "active",
  "createdAt": "2025-01-15T10:30:00Z",
  "updatedAt": "2025-01-15T10:30:00Z"
}
```

---

### 4. Update Program
```http
PUT /api/programs/:id
Authorization: Bearer YOUR_JWT_TOKEN
Content-Type: application/json
```

**Required Role:** ADMIN

**URL Parameters:**
- `id`: Program ID (number)

**Request Body (all fields optional):**
```json
{
  "name": "B.S. Computer Science (Updated)",
  "code": "BSCS2",
  "degreeType": "bachelor",
  "durationYears": 4,
  "description": "Updated description",
  "status": "active"
}
```

**Example:**
```http
PUT /api/programs/1
```

**Response (200 OK):**
```json
{
  "id": 1,
  "name": "B.S. Computer Science (Updated)",
  "code": "BSCS2",
  "degreeType": "bachelor",
  "durationYears": 4,
  "departmentId": 1,
  "description": "Updated description",
  "status": "active",
  "createdAt": "2025-01-15T10:30:00Z",
  "updatedAt": "2025-01-15T11:00:00Z"
}
```

---

### 5. Delete Program
```http
DELETE /api/programs/:id
Authorization: Bearer YOUR_JWT_TOKEN
```

**Required Role:** ADMIN

**URL Parameters:**
- `id`: Program ID (number)

**Example:**
```http
DELETE /api/programs/1
```

**Response (204 No Content)**
(Empty response body)

---

## 📅 SEMESTER ENDPOINTS

### 1. Get All Semesters
```http
GET /api/semesters
Authorization: Bearer YOUR_JWT_TOKEN
```

**Query Parameters (Optional):**
- `status`: Filter by status (upcoming, active, completed)
- `year`: Filter by year (e.g., 2025)

**Example:**
```http
GET /api/semesters?status=active&year=2025
```

**Response (200 OK):**
```json
[
  {
    "id": 1,
    "name": "Fall 2024",
    "code": "F2024",
    "startDate": "2024-09-01",
    "endDate": "2024-12-20",
    "registrationStart": "2024-08-01",
    "registrationEnd": "2024-08-25",
    "status": "completed",
    "createdAt": "2025-01-15T10:30:00Z"
  },
  {
    "id": 2,
    "name": "Spring 2025",
    "code": "S2025",
    "startDate": "2025-01-15",
    "endDate": "2025-05-15",
    "registrationStart": "2024-12-01",
    "registrationEnd": "2025-01-10",
    "status": "active",
    "createdAt": "2025-01-15T10:35:00Z"
  }
]
```

---

### 2. Get Current Semester
```http
GET /api/semesters/current
Authorization: Bearer YOUR_JWT_TOKEN
```

**Response (200 OK):**
```json
{
  "id": 2,
  "name": "Spring 2025",
  "code": "S2025",
  "startDate": "2025-01-15",
  "endDate": "2025-05-15",
  "registrationStart": "2024-12-01",
  "registrationEnd": "2025-01-10",
  "status": "active",
  "createdAt": "2025-01-15T10:35:00Z"
}
```

---

### 3. Get Semester by ID
```http
GET /api/semesters/:id
Authorization: Bearer YOUR_JWT_TOKEN
```

**URL Parameters:**
- `id`: Semester ID (number)

**Example:**
```http
GET /api/semesters/1
```

**Response (200 OK):**
```json
{
  "id": 1,
  "name": "Fall 2024",
  "code": "F2024",
  "startDate": "2024-09-01",
  "endDate": "2024-12-20",
  "registrationStart": "2024-08-01",
  "registrationEnd": "2024-08-25",
  "status": "completed",
  "createdAt": "2025-01-15T10:30:00Z"
}
```

---

### 4. Create Semester
```http
POST /api/semesters
Authorization: Bearer YOUR_JWT_TOKEN
Content-Type: application/json
```

**Required Role:** ADMIN

**Request Body:**
```json
{
  "name": "Fall 2026",
  "code": "F2026",
  "startDate": "2026-09-01",
  "endDate": "2026-12-20",
  "registrationStart": "2026-08-01",
  "registrationEnd": "2026-08-25"
}
```

**Status Options:**
- `upcoming`
- `active`
- `completed`

**Response (201 Created):**
```json
{
  "id": 3,
  "name": "Fall 2026",
  "code": "F2026",
  "startDate": "2026-09-01",
  "endDate": "2026-12-20",
  "registrationStart": "2026-08-01",
  "registrationEnd": "2026-08-25",
  "status": "upcoming",
  "createdAt": "2025-01-15T10:40:00Z"
}
```

---

### 5. Update Semester
```http
PUT /api/semesters/:id
Authorization: Bearer YOUR_JWT_TOKEN
Content-Type: application/json
```

**Required Role:** ADMIN

**URL Parameters:**
- `id`: Semester ID (number)

**Request Body (all fields optional):**
```json
{
  "name": "Fall 2025 (Updated)",
  "status": "active",
  "endDate": "2025-12-25"
}
```

**Example:**
```http
PUT /api/semesters/3
```

**Response (200 OK):**
```json
{
  "id": 3,
  "name": "Fall 2025 (Updated)",
  "code": "F2025",
  "startDate": "2025-09-01",
  "endDate": "2025-12-25",
  "registrationStart": "2025-08-01",
  "registrationEnd": "2025-08-25",
  "status": "active",
  "createdAt": "2025-01-15T10:40:00Z"
}
```

---

### 6. Delete Semester
```http
DELETE /api/semesters/:id
Authorization: Bearer YOUR_JWT_TOKEN
```

**Required Role:** ADMIN

**URL Parameters:**
- `id`: Semester ID (number)

**Example:**
```http
DELETE /api/semesters/3
```

**Response (204 No Content)**
(Empty response body)

---

## 🔐 Common Headers

All requests require:
```
Authorization: Bearer YOUR_JWT_TOKEN
Content-Type: application/json
```

---

## ❌ Error Responses

### 400 Bad Request
```json
{
  "statusCode": 400,
  "message": "Code must be 2-20 uppercase alphanumeric characters",
  "error": "Bad Request"
}
```

### 401 Unauthorized
```json
{
  "statusCode": 401,
  "message": "Unauthorized",
  "error": "Unauthorized"
}
```

### 403 Forbidden
```json
{
  "statusCode": 403,
  "message": "Forbidden resource",
  "error": "Forbidden"
}
```

### 404 Not Found
```json
{
  "statusCode": 404,
  "message": "Campus with ID 999 not found",
  "error": "Not Found"
}
```

### 409 Conflict
```json
{
  "statusCode": 409,
  "message": "Campus code \"MAIN\" already exists",
  "error": "Conflict"
}
```

---

## 📋 Validation Rules

### Campus Code
- Required: Yes
- Format: 2-20 uppercase alphanumeric
- Unique: Yes
- Examples: `MAIN`, `CAMPUS01`, `NORTH`

### Campus Name
- Required: Yes
- Length: 1-100 characters
- Examples: `Main Campus`, `North Campus`

### Campus Phone
- Required: No
- Format: Digits, spaces, hyphens, parentheses, dots
- Examples: `+1-555-0100`, `(555) 012-3456`

### Campus Timezone
- Required: No
- Default: `UTC`
- Examples: `America/New_York`, `Europe/London`, `Asia/Tokyo`

### Campus Status
- Required: No
- Default: `active`
- Options: `active`, `inactive`

### Department Code
- Required: Yes
- Unique: Within campus
- Examples: `CS`, `MATH`, `ENG`

### Program Degree Type
- Required: Yes
- Options: `associate`, `bachelor`, `master`, `doctorate`, `certificate`

### Semester Dates
- `startDate` and `endDate` must be valid dates
- `endDate` must be after `startDate`
- Format: `YYYY-MM-DD`

---

## 🚀 Quick Examples

### Create Campus and Department

**1. Create Campus:**
```bash
curl -X POST http://localhost:3000/api/campuses \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Main Campus",
    "code": "MAIN"
  }'
```

**2. Create Department:**
```bash
curl -X POST http://localhost:3000/api/departments \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Computer Science",
    "code": "CS",
    "campusId": 1
  }'
```

**3. Create Program:**
```bash
curl -X POST http://localhost:3000/api/programs \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "B.S. Computer Science",
    "code": "BSCS",
    "degreeType": "bachelor",
    "durationYears": 4,
    "departmentId": 1,
    "description": "Bachelor of Science in Computer Science"
  }'
```

**4. Create Semester:**
```bash
curl -X POST http://localhost:3000/api/semesters \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Fall 2025",
    "code": "F2025",
    "startDate": "2025-09-01",
    "endDate": "2025-12-20",
    "registrationStart": "2025-08-01",
    "registrationEnd": "2025-08-25",
    "status": "upcoming"
  }'
```
