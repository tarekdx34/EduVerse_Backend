# Campus Management Feature Documentation

## Overview
The Campus Management feature provides a complete hierarchical structure for managing educational institutions, from campuses down to individual course sections. It supports multi-level organization with full CRUD operations.

## Architecture & Data Structure

### Hierarchy Levels
```
Campus
  ├── Department
  │   └── Program
  │       └── Semester
  │           └── Course
  │               └── Section
```

### Database Schema

#### Campus Table
```sql
CREATE TABLE campuses (
  id UUID PRIMARY KEY,
  name VARCHAR(255) NOT NULL UNIQUE,
  location VARCHAR(255),
  address VARCHAR(500),
  phone_number VARCHAR(20),
  email VARCHAR(255),
  website_url VARCHAR(255),
  established_date DATE,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### Department Table
```sql
CREATE TABLE departments (
  id UUID PRIMARY KEY,
  campus_id UUID NOT NULL REFERENCES campuses(id),
  name VARCHAR(255) NOT NULL,
  code VARCHAR(50),
  description TEXT,
  department_head_id UUID REFERENCES users(id),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(campus_id, code)
);
```

#### Program Table
```sql
CREATE TABLE programs (
  id UUID PRIMARY KEY,
  department_id UUID NOT NULL REFERENCES departments(id),
  name VARCHAR(255) NOT NULL,
  code VARCHAR(50),
  description TEXT,
  duration_years INT,
  total_credits INT,
  program_coordinator_id UUID REFERENCES users(id),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(department_id, code)
);
```

#### Semester Table
```sql
CREATE TABLE semesters (
  id UUID PRIMARY KEY,
  program_id UUID NOT NULL REFERENCES programs(id),
  name VARCHAR(100) NOT NULL,
  semester_number INT,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  is_active BOOLEAN DEFAULT true,
  current_semester BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## API Endpoints

### Campus Endpoints

#### 1. Get All Campuses
```http
GET /api/campuses
```

**Query Parameters:**
- `skip` (optional): Number of records to skip (default: 0)
- `take` (optional): Number of records to take (default: 10)
- `isActive` (optional): Filter by active status (true/false)

**Example Request:**
```bash
curl -X GET "http://localhost:8081/api/campuses?skip=0&take=10" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Response:**
```json
{
  "data": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "name": "Main Campus",
      "location": "New York",
      "address": "123 University Ave, NY 10001",
      "phone_number": "+1-555-0123",
      "email": "main@eduverse.edu",
      "website_url": "https://main.eduverse.edu",
      "established_date": "2010-01-15",
      "is_active": true,
      "departmentCount": 5,
      "created_at": "2025-01-01T10:00:00Z",
      "updated_at": "2025-01-15T12:00:00Z"
    }
  ],
  "total": 1,
  "page": 1,
  "limit": 10
}
```

#### 2. Create Campus
```http
POST /api/campuses
```

**Request Body:**
```json
{
  "name": "Main Campus",
  "location": "New York",
  "address": "123 University Ave, NY 10001",
  "phone_number": "+1-555-0123",
  "email": "main@eduverse.edu",
  "website_url": "https://main.eduverse.edu",
  "established_date": "2010-01-15"
}
```

**Example Request:**
```bash
curl -X POST "http://localhost:8081/api/campuses" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Main Campus",
    "location": "New York",
    "address": "123 University Ave, NY 10001",
    "phone_number": "+1-555-0123",
    "email": "main@eduverse.edu",
    "website_url": "https://main.eduverse.edu",
    "established_date": "2010-01-15"
  }'
```

**Response (201 Created):**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "name": "Main Campus",
  "location": "New York",
  "address": "123 University Ave, NY 10001",
  "phone_number": "+1-555-0123",
  "email": "main@eduverse.edu",
  "website_url": "https://main.eduverse.edu",
  "established_date": "2010-01-15",
  "is_active": true,
  "created_at": "2025-01-15T12:00:00Z",
  "updated_at": "2025-01-15T12:00:00Z"
}
```

#### 3. Get Campus by ID
```http
GET /api/campuses/:id
```

**Example Request:**
```bash
curl -X GET "http://localhost:8081/api/campuses/550e8400-e29b-41d4-a716-446655440000" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Response:**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "name": "Main Campus",
  "location": "New York",
  "address": "123 University Ave, NY 10001",
  "phone_number": "+1-555-0123",
  "email": "main@eduverse.edu",
  "website_url": "https://main.eduverse.edu",
  "established_date": "2010-01-15",
  "is_active": true,
  "departmentCount": 5,
  "departments": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440001",
      "name": "Computer Science",
      "code": "CS",
      "description": "Department of Computer Science and Engineering"
    }
  ],
  "created_at": "2025-01-15T12:00:00Z",
  "updated_at": "2025-01-15T12:00:00Z"
}
```

#### 4. Update Campus
```http
PUT /api/campuses/:id
```

**Request Body:**
```json
{
  "name": "Main Campus Updated",
  "phone_number": "+1-555-9999",
  "is_active": true
}
```

**Example Request:**
```bash
curl -X PUT "http://localhost:8081/api/campuses/550e8400-e29b-41d4-a716-446655440000" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Main Campus Updated",
    "phone_number": "+1-555-9999"
  }'
```

**Response:**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "name": "Main Campus Updated",
  "location": "New York",
  "phone_number": "+1-555-9999",
  "is_active": true,
  "updated_at": "2025-01-15T13:00:00Z"
}
```

#### 5. Delete Campus
```http
DELETE /api/campuses/:id
```

**Example Request:**
```bash
curl -X DELETE "http://localhost:8081/api/campuses/550e8400-e29b-41d4-a716-446655440000" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Response (204 No Content):**
```
No response body
```

---

### Department Endpoints

#### 1. Get Departments by Campus
```http
GET /api/campuses/:campusId/departments
```

**Query Parameters:**
- `skip` (optional): Number of records to skip
- `take` (optional): Number of records to take

**Example Request:**
```bash
curl -X GET "http://localhost:8081/api/campuses/550e8400-e29b-41d4-a716-446655440000/departments" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Response:**
```json
{
  "data": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440001",
      "campusId": "550e8400-e29b-41d4-a716-446655440000",
      "name": "Computer Science",
      "code": "CS",
      "description": "Department of Computer Science and Engineering",
      "departmentHeadId": "550e8400-e29b-41d4-a716-446655440010",
      "is_active": true,
      "programCount": 3,
      "created_at": "2025-01-15T12:00:00Z"
    }
  ],
  "total": 1
}
```

#### 2. Create Department
```http
POST /api/departments
```

**Request Body:**
```json
{
  "campusId": "550e8400-e29b-41d4-a716-446655440000",
  "name": "Computer Science",
  "code": "CS",
  "description": "Department of Computer Science and Engineering",
  "department_head_id": "550e8400-e29b-41d4-a716-446655440010"
}
```

**Example Request:**
```bash
curl -X POST "http://localhost:8081/api/departments" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "campusId": "550e8400-e29b-41d4-a716-446655440000",
    "name": "Computer Science",
    "code": "CS",
    "description": "Department of Computer Science and Engineering"
  }'
```

**Response (201 Created):**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440001",
  "campusId": "550e8400-e29b-41d4-a716-446655440000",
  "name": "Computer Science",
  "code": "CS",
  "is_active": true,
  "created_at": "2025-01-15T12:00:00Z"
}
```

#### 3. Get Department by ID
```http
GET /api/departments/:id
```

**Example Request:**
```bash
curl -X GET "http://localhost:8081/api/departments/550e8400-e29b-41d4-a716-446655440001" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Response:**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440001",
  "campusId": "550e8400-e29b-41d4-a716-446655440000",
  "name": "Computer Science",
  "code": "CS",
  "description": "Department of Computer Science and Engineering",
  "is_active": true,
  "programCount": 3,
  "programs": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440002",
      "name": "Bachelor of Science in Computer Science",
      "code": "BSCS"
    }
  ]
}
```

#### 4. Update Department
```http
PUT /api/departments/:id
```

**Request Body:**
```json
{
  "name": "Computer Science & Engineering",
  "is_active": true
}
```

**Example Request:**
```bash
curl -X PUT "http://localhost:8081/api/departments/550e8400-e29b-41d4-a716-446655440001" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Computer Science & Engineering"
  }'
```

#### 5. Delete Department
```http
DELETE /api/departments/:id
```

**Example Request:**
```bash
curl -X DELETE "http://localhost:8081/api/departments/550e8400-e29b-41d4-a716-446655440001" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

### Program Endpoints

#### 1. Get Programs by Department
```http
GET /api/departments/:deptId/programs
```

**Example Request:**
```bash
curl -X GET "http://localhost:8081/api/departments/550e8400-e29b-41d4-a716-446655440001/programs" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Response:**
```json
{
  "data": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440002",
      "departmentId": "550e8400-e29b-41d4-a716-446655440001",
      "name": "Bachelor of Science in Computer Science",
      "code": "BSCS",
      "description": "4-year undergraduate program",
      "duration_years": 4,
      "total_credits": 120,
      "is_active": true,
      "semesterCount": 8
    }
  ],
  "total": 1
}
```

#### 2. Create Program
```http
POST /api/programs
```

**Request Body:**
```json
{
  "departmentId": "550e8400-e29b-41d4-a716-446655440001",
  "name": "Bachelor of Science in Computer Science",
  "code": "BSCS",
  "description": "4-year undergraduate program",
  "duration_years": 4,
  "total_credits": 120
}
```

**Example Request:**
```bash
curl -X POST "http://localhost:8081/api/programs" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "departmentId": "550e8400-e29b-41d4-a716-446655440001",
    "name": "Bachelor of Science in Computer Science",
    "code": "BSCS",
    "description": "4-year undergraduate program",
    "duration_years": 4,
    "total_credits": 120
  }'
```

**Response (201 Created):**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440002",
  "departmentId": "550e8400-e29b-41d4-a716-446655440001",
  "name": "Bachelor of Science in Computer Science",
  "code": "BSCS",
  "duration_years": 4,
  "total_credits": 120,
  "is_active": true,
  "created_at": "2025-01-15T12:00:00Z"
}
```

#### 3. Get Program by ID
```http
GET /api/programs/:id
```

**Response:**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440002",
  "departmentId": "550e8400-e29b-41d4-a716-446655440001",
  "name": "Bachelor of Science in Computer Science",
  "code": "BSCS",
  "description": "4-year undergraduate program",
  "duration_years": 4,
  "total_credits": 120,
  "is_active": true,
  "semesterCount": 8
}
```

#### 4. Update Program
```http
PUT /api/programs/:id
```

**Request Body:**
```json
{
  "name": "Bachelor of Science in Computer Science (Updated)",
  "total_credits": 128
}
```

#### 5. Delete Program
```http
DELETE /api/programs/:id
```

---

### Semester Endpoints

#### 1. Get All Semesters
```http
GET /api/semesters
```

**Query Parameters:**
- `skip` (optional): Number of records to skip
- `take` (optional): Number of records to take
- `isActive` (optional): Filter by active status

**Example Request:**
```bash
curl -X GET "http://localhost:8081/api/semesters?skip=0&take=10" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Response:**
```json
{
  "data": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440003",
      "programId": "550e8400-e29b-41d4-a716-446655440002",
      "name": "Fall 2024 - Semester 1",
      "semester_number": 1,
      "start_date": "2024-08-15",
      "end_date": "2024-12-15",
      "is_active": true,
      "current_semester": true,
      "created_at": "2025-01-15T12:00:00Z"
    }
  ],
  "total": 1
}
```

#### 2. Get Current Semester
```http
GET /api/semesters/current
```

**Example Request:**
```bash
curl -X GET "http://localhost:8081/api/semesters/current" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Response:**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440003",
  "programId": "550e8400-e29b-41d4-a716-446655440002",
  "name": "Fall 2024 - Semester 1",
  "semester_number": 1,
  "start_date": "2024-08-15",
  "end_date": "2024-12-15",
  "is_active": true,
  "current_semester": true
}
```

#### 3. Create Semester
```http
POST /api/semesters
```

**Request Body:**
```json
{
  "programId": "550e8400-e29b-41d4-a716-446655440002",
  "name": "Fall 2024 - Semester 1",
  "semester_number": 1,
  "start_date": "2024-08-15",
  "end_date": "2024-12-15"
}
```

**Example Request:**
```bash
curl -X POST "http://localhost:8081/api/semesters" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "programId": "550e8400-e29b-41d4-a716-446655440002",
    "name": "Fall 2024 - Semester 1",
    "semester_number": 1,
    "start_date": "2024-08-15",
    "end_date": "2024-12-15"
  }'
```

**Response (201 Created):**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440003",
  "programId": "550e8400-e29b-41d4-a716-446655440002",
  "name": "Fall 2024 - Semester 1",
  "semester_number": 1,
  "start_date": "2024-08-15",
  "end_date": "2024-12-15",
  "is_active": true,
  "current_semester": false,
  "created_at": "2025-01-15T12:00:00Z"
}
```

#### 4. Get Semester by ID
```http
GET /api/semesters/:id
```

#### 5. Update Semester
```http
PUT /api/semesters/:id
```

**Request Body:**
```json
{
  "name": "Fall 2024 - Semester 1 (Updated)",
  "current_semester": true
}
```

#### 6. Delete Semester
```http
DELETE /api/semesters/:id
```

---

## Complete Workflow Example

Here's a step-by-step example to set up a complete campus structure:

### Step 1: Create a Campus
```bash
curl -X POST "http://localhost:8081/api/campuses" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Main Campus",
    "location": "New York",
    "address": "123 University Ave, NY 10001",
    "phone_number": "+1-555-0123",
    "email": "main@eduverse.edu",
    "website_url": "https://main.eduverse.edu",
    "established_date": "2010-01-15"
  }'
```

**Save the `id` as `CAMPUS_ID`**

### Step 2: Create a Department
```bash
curl -X POST "http://localhost:8081/api/departments" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "campusId": "CAMPUS_ID",
    "name": "Computer Science",
    "code": "CS",
    "description": "Department of Computer Science and Engineering"
  }'
```

**Save the `id` as `DEPARTMENT_ID`**

### Step 3: Create a Program
```bash
curl -X POST "http://localhost:8081/api/programs" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "departmentId": "DEPARTMENT_ID",
    "name": "Bachelor of Science in Computer Science",
    "code": "BSCS",
    "description": "4-year undergraduate program",
    "duration_years": 4,
    "total_credits": 120
  }'
```

**Save the `id` as `PROGRAM_ID`**

### Step 4: Create Semesters
```bash
curl -X POST "http://localhost:8081/api/semesters" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "programId": "PROGRAM_ID",
    "name": "Fall 2024 - Semester 1",
    "semester_number": 1,
    "start_date": "2024-08-15",
    "end_date": "2024-12-15"
  }'
```

### Step 5: Verify the Structure
```bash
curl -X GET "http://localhost:8081/api/campuses/CAMPUS_ID" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

## Error Responses

### 400 Bad Request
```json
{
  "statusCode": 400,
  "message": "Campus name already exists",
  "error": "Bad Request"
}
```

### 404 Not Found
```json
{
  "statusCode": 404,
  "message": "Campus not found",
  "error": "Not Found"
}
```

### 409 Conflict
```json
{
  "statusCode": 409,
  "message": "Department code already exists in this campus",
  "error": "Conflict"
}
```

### 500 Internal Server Error
```json
{
  "statusCode": 500,
  "message": "An error occurred while processing your request",
  "error": "Internal Server Error"
}
```

---

## Validation Rules

### Campus
- `name`: Required, unique, 1-255 characters
- `location`: Optional, 1-255 characters
- `email`: Optional, must be valid email format
- `phone_number`: Optional, max 20 characters
- `established_date`: Optional, must be valid date

### Department
- `campusId`: Required, must reference existing campus
- `name`: Required, 1-255 characters
- `code`: Optional, unique within campus, max 50 characters
- `department_head_id`: Optional, must reference existing user

### Program
- `departmentId`: Required, must reference existing department
- `name`: Required, 1-255 characters
- `code`: Optional, unique within department, max 50 characters
- `duration_years`: Optional, must be positive integer
- `total_credits`: Optional, must be positive integer

### Semester
- `programId`: Required, must reference existing program
- `name`: Required, 1-100 characters
- `semester_number`: Optional, must be positive integer
- `start_date`: Required, must be valid date
- `end_date`: Required, must be after start_date
- `current_semester`: Optional, boolean

---

## Authorization

All endpoints require JWT authentication. Include the token in the Authorization header:

```
Authorization: Bearer <JWT_TOKEN>
```

The following roles have access to Campus Management endpoints:
- `ADMIN`: Full access (create, read, update, delete)
- `CAMPUS_MANAGER`: Full access to assigned campus
- `DEPARTMENT_HEAD`: Read access to department
- `PROGRAM_COORDINATOR`: Read access to program

---

## Pagination

List endpoints support pagination with the following parameters:

- `skip`: Number of records to skip (default: 0, min: 0)
- `take`: Number of records to take (default: 10, min: 1, max: 100)

**Example:**
```
GET /api/campuses?skip=10&take=20
```

---

## Filtering & Sorting

### Filter by Active Status
```
GET /api/campuses?isActive=true
```

### Sort by Created Date
```
GET /api/campuses?sortBy=created_at&sortOrder=desc
```

---

## Best Practices

1. **Hierarchical Creation**: Always create parent entities before child entities (Campus → Department → Program → Semester)

2. **Unique Codes**: Use meaningful codes for departments and programs for easier identification

3. **Date Management**: Ensure semester dates don't overlap within a program

4. **Active Status**: Use the `is_active` flag to deactivate entities instead of deleting them

5. **Audit Trail**: Track creation and update timestamps for compliance

6. **Error Handling**: Always handle HTTP error codes appropriately in client applications

---

## Rate Limiting

API calls are rate-limited to prevent abuse:
- **Limit**: 1000 requests per hour per user
- **Headers**: `X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset`

---

## Support & Troubleshooting

### Common Issues

**Issue**: "Campus not found" error
- **Solution**: Verify the campus ID is correct and the campus exists

**Issue**: "Department code already exists in this campus"
- **Solution**: Use a unique code for the department within the campus

**Issue**: "Cannot delete department with active programs"
- **Solution**: Deactivate or delete associated programs first

---

## Version History

- **v1.0.0** (2025-01-15): Initial release with Campus, Department, Program, and Semester management
