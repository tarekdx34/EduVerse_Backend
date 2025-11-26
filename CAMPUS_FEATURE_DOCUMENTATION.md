# Campus Feature Documentation

## Overview

The Campus feature is a core component of the EduVerse Backend that manages educational institutions, their departments, programs, and academic semesters. It provides a hierarchical structure for organizing academic entities within a multi-campus education system.

## Feature Structure

### Hierarchy

```
Campus
├── Department (Multiple)
│   ├── Program (Multiple)
│   │   └── Semester (Multiple)
```

Each campus can have multiple departments, each department can have multiple programs, and each program can have multiple semesters.

## Core Entities

### Campus Entity

Represents a physical or logical campus/institution location.

**Fields:**
- `id` (number): Primary key, auto-generated
- `name` (string, max 100): Campus name
- `code` (string, max 20, unique): Unique campus identifier (e.g., "MAIN", "NORTH01")
- `address` (string, max 255): Physical address
- `city` (string, max 100): City location
- `country` (string, max 100): Country location
- `phone` (string, max 20): Contact phone number
- `email` (string, max 255): Contact email address
- `timezone` (string, default: "UTC"): Timezone identifier (e.g., "America/New_York")
- `status` (enum): ACTIVE or INACTIVE
- `createdAt` (Date): Creation timestamp
- `updatedAt` (Date): Last update timestamp
- `departments` (relation): Array of Department entities

**Validations:**
- Name: 1-100 characters, required
- Code: 2-20 uppercase alphanumeric characters, required, unique
- Phone: Valid phone format (digits, spaces, hyphens, parentheses, dots allowed)

### Department Entity

Represents a department within a campus (e.g., Computer Science, Business, Engineering).

**Key Fields:**
- `id` (number): Primary key
- `name` (string): Department name
- `code` (string, unique per campus): Department code
- `campus` (relation): Reference to parent Campus
- `programs` (relation): Array of Program entities

### Program Entity

Represents an academic program within a department (e.g., B.Sc. Computer Science, MBA).

**Key Fields:**
- `id` (number): Primary key
- `name` (string): Program name
- `code` (string, unique per department): Program code
- `degree_type` (enum): Type of degree (ASSOCIATE, BACHELOR, MASTER, DOCTORATE, CERTIFICATE)
- `department` (relation): Reference to parent Department

### Semester Entity

Represents an academic semester within a program.

**Key Fields:**
- `id` (number): Primary key
- `code` (string, unique): Semester identifier
- `name` (string): Semester name
- `status` (enum): Status of semester
- `startDate` (Date): Semester start date
- `endDate` (Date): Semester end date
- `program` (relation): Reference to parent Program

## API Endpoints

### Campus Endpoints

#### 1. Get All Campuses

```http
GET /api/campuses
```

**Query Parameters:**
- `status` (optional): Filter by status (active or inactive)

**Allowed Roles:** IT_ADMIN, ADMIN, INSTRUCTOR, TA, STUDENT

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
    "phone": "+1-555-0123",
    "email": "main@university.edu",
    "timezone": "America/New_York",
    "status": "active",
    "createdAt": "2025-01-15T10:30:00Z",
    "updatedAt": "2025-01-15T10:30:00Z"
  }
]
```

#### 2. Get Campus by ID

```http
GET /api/campuses/{id}
```

**URL Parameters:**
- `id` (number): Campus ID

**Allowed Roles:** IT_ADMIN, ADMIN, INSTRUCTOR, TA, STUDENT

**Response (200 OK):**
```json
{
  "id": 1,
  "name": "Main Campus",
  "code": "MAIN",
  "address": "123 University St",
  "city": "New York",
  "country": "USA",
  "phone": "+1-555-0123",
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

**Error Responses:**
- `404 Not Found`: Campus with given ID does not exist

#### 3. Create Campus

```http
POST /api/campuses
```

**Allowed Roles:** IT_ADMIN

**Request Body:**
```json
{
  "name": "Main Campus",
  "code": "MAIN",
  "address": "123 University St",
  "city": "New York",
  "country": "USA",
  "phone": "+1-555-0123",
  "email": "main@university.edu",
  "timezone": "America/New_York",
  "status": "active"
}
```

**Response (201 Created):**
```json
{
  "id": 1,
  "name": "Main Campus",
  "code": "MAIN",
  "address": "123 University St",
  "city": "New York",
  "country": "USA",
  "phone": "+1-555-0123",
  "email": "main@university.edu",
  "timezone": "America/New_York",
  "status": "active",
  "createdAt": "2025-01-15T10:30:00Z",
  "updatedAt": "2025-01-15T10:30:00Z"
}
```

**Error Responses:**
- `409 Conflict`: Campus code already exists
- `400 Bad Request`: Validation error (invalid code format, required fields missing, etc.)

#### 4. Update Campus

```http
PUT /api/campuses/{id}
```

**URL Parameters:**
- `id` (number): Campus ID

**Allowed Roles:** IT_ADMIN, ADMIN

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

**Error Responses:**
- `404 Not Found`: Campus not found
- `409 Conflict`: New code already exists
- `400 Bad Request`: Validation error

#### 5. Delete Campus

```http
DELETE /api/campuses/{id}
```

**URL Parameters:**
- `id` (number): Campus ID

**Allowed Roles:** IT_ADMIN

**Response (204 No Content)**

**Error Responses:**
- `404 Not Found`: Campus not found
- `409 Conflict`: Campus has associated departments and cannot be deleted

### Department Endpoints

#### 1. Get Departments by Campus

```http
GET /api/campuses/{campusId}/departments
```

**URL Parameters:**
- `campusId` (number): Campus ID

**Allowed Roles:** IT_ADMIN, ADMIN, INSTRUCTOR, TA, STUDENT

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
  }
]
```

#### 2. Get Department by ID

```http
GET /api/departments/{id}
```

**URL Parameters:**
- `id` (number): Department ID

**Allowed Roles:** IT_ADMIN, ADMIN, INSTRUCTOR, TA, STUDENT

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

#### 3. Create Department

```http
POST /api/departments
```

**Allowed Roles:** IT_ADMIN, ADMIN

**Request Body:**
```json
{
  "name": "Computer Science",
  "code": "CS",
  "campusId": 1
}
```

**Response (201 Created)**

#### 4. Update Department

```http
PUT /api/departments/{id}
```

**Allowed Roles:** IT_ADMIN, ADMIN

#### 5. Delete Department

```http
DELETE /api/departments/{id}
```

**Allowed Roles:** IT_ADMIN, ADMIN

**Error:** Cannot delete department with existing programs

## Business Rules

### Campus Management

1. **Code Uniqueness:** Each campus must have a unique code across the entire system.
2. **Code Format:** Campus code must be 2-20 uppercase alphanumeric characters (e.g., MAIN, CAMPUS01).
3. **Timezone Support:** Campus timezone is stored for coordination of academic activities.
4. **Status Tracking:** Campus can be marked as ACTIVE or INACTIVE for administrative purposes.
5. **Deletion Constraint:** A campus cannot be deleted if it has associated departments.
6. **Default Values:**
   - `timezone` defaults to "UTC" if not provided
   - `status` defaults to "ACTIVE" if not provided

### Department Management

1. **Code Uniqueness:** Department codes must be unique within a campus but can be repeated across campuses.
2. **Relationship:** Each department must belong to exactly one campus.
3. **Hierarchy:** A department cannot exist without a parent campus.

### Program Management

1. **Degree Types:** Programs are classified by degree type (ASSOCIATE, BACHELOR, MASTER, DOCTORATE, CERTIFICATE).
2. **Department Relationship:** Each program belongs to exactly one department.

### Semester Management

1. **Date Validation:** End date must be after start date.
2. **Code Uniqueness:** Semester codes must be globally unique.
3. **Status Tracking:** Semesters can have specific status values indicating their phase.

## Authentication & Authorization

All campus feature endpoints are protected with JWT authentication. Additionally, role-based access control (RBAC) is implemented with the following roles:

### Role Permissions

| Endpoint | GET | POST | PUT | DELETE |
|----------|-----|------|-----|--------|
| Campuses | ✓ All | ✓ IT_ADMIN | ✓ IT_ADMIN, ADMIN | ✓ IT_ADMIN |
| Departments | ✓ All | ✓ IT_ADMIN, ADMIN | ✓ IT_ADMIN, ADMIN | ✓ IT_ADMIN, ADMIN |
| Programs | ✓ All | ✓ IT_ADMIN, ADMIN | ✓ IT_ADMIN, ADMIN | ✓ IT_ADMIN, ADMIN |
| Semesters | ✓ All | ✓ IT_ADMIN, ADMIN | ✓ IT_ADMIN, ADMIN | ✓ IT_ADMIN, ADMIN |

**All** roles include: IT_ADMIN, ADMIN, INSTRUCTOR, TA, STUDENT

### Headers Required

All requests must include:
```
Authorization: Bearer {JWT_TOKEN}
Content-Type: application/json
```

## Error Handling

### Common Error Codes

| Code | Status | Description | Example |
|------|--------|-------------|---------|
| 400 | Bad Request | Validation error or invalid input | Invalid phone format, code format |
| 401 | Unauthorized | Missing or invalid JWT token | Token expired, missing header |
| 403 | Forbidden | User lacks required role | Non-IT_ADMIN trying to create campus |
| 404 | Not Found | Resource does not exist | Campus with ID 999 not found |
| 409 | Conflict | Business rule violation | Campus code already exists, deletion constraint |
| 500 | Internal Server Error | Unexpected server error | Database connection error |

### Error Response Format

```json
{
  "statusCode": 409,
  "message": "Campus code \"MAIN\" already exists",
  "error": "Conflict"
}
```

## Database Schema

### Campuses Table

```sql
CREATE TABLE campuses (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  code VARCHAR(20) NOT NULL UNIQUE,
  address VARCHAR(255),
  city VARCHAR(100),
  country VARCHAR(100),
  phone VARCHAR(20),
  email VARCHAR(255),
  timezone VARCHAR(50) DEFAULT 'UTC',
  status ENUM('active', 'inactive') DEFAULT 'active',
  createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

### Departments Table

```sql
CREATE TABLE departments (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  code VARCHAR(50) NOT NULL,
  campusId BIGINT NOT NULL,
  createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (campusId) REFERENCES campuses(id),
  UNIQUE KEY unique_code_per_campus (code, campusId)
);
```

### Programs Table

```sql
CREATE TABLE programs (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  code VARCHAR(50) NOT NULL,
  degree_type ENUM('associate', 'bachelor', 'master', 'doctorate', 'certificate'),
  departmentId BIGINT NOT NULL,
  createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (departmentId) REFERENCES departments(id),
  UNIQUE KEY unique_code_per_department (code, departmentId)
);
```

## Usage Examples

### Example 1: Create a Complete Campus Structure

```bash
# 1. Create Campus
curl -X POST http://localhost:3000/api/campuses \
  -H "Authorization: Bearer {JWT_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Main Campus",
    "code": "MAIN",
    "address": "123 University St",
    "city": "New York",
    "country": "USA",
    "phone": "+1-555-0123",
    "email": "main@university.edu",
    "timezone": "America/New_York"
  }'

# Response: Campus created with ID: 1

# 2. Create Department under Campus
curl -X POST http://localhost:3000/api/departments \
  -H "Authorization: Bearer {JWT_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Computer Science",
    "code": "CS",
    "campusId": 1
  }'

# Response: Department created with ID: 1

# 3. Create Program under Department
curl -X POST http://localhost:3000/api/programs \
  -H "Authorization: Bearer {JWT_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "B.S. Computer Science",
    "code": "BSCS",
    "degree_type": "bachelor",
    "departmentId": 1
  }'

# Response: Program created with ID: 1

# 4. Create Semester under Program
curl -X POST http://localhost:3000/api/semesters \
  -H "Authorization: Bearer {JWT_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Fall 2025",
    "code": "FALL2025",
    "status": "active",
    "startDate": "2025-09-01",
    "endDate": "2025-12-15",
    "programId": 1
  }'
```

### Example 2: Query Campus with Details

```bash
curl -X GET http://localhost:3000/api/campuses/1 \
  -H "Authorization: Bearer {JWT_TOKEN}" \
  -H "Content-Type: application/json"

# Response includes departments and related data
```

### Example 3: Filter Active Campuses

```bash
curl -X GET "http://localhost:3000/api/campuses?status=active" \
  -H "Authorization: Bearer {JWT_TOKEN}" \
  -H "Content-Type: application/json"
```

### Example 4: Update Campus Information

```bash
curl -X PUT http://localhost:3000/api/campuses/1 \
  -H "Authorization: Bearer {JWT_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "city": "Boston",
    "timezone": "America/Boston"
  }'
```

### Example 5: Delete Campus (Only if no departments)

```bash
curl -X DELETE http://localhost:3000/api/campuses/1 \
  -H "Authorization: Bearer {JWT_TOKEN}" \
  -H "Content-Type: application/json"

# Response: 204 No Content (if successful)
```

## Testing

The campus feature includes comprehensive unit and integration tests covering:
- CRUD operations (Create, Read, Update, Delete)
- Validation of input data
- Error handling and exception scenarios
- Role-based access control
- Database constraints and relationships
- Edge cases and boundary conditions

For more details, see `campus.controller.spec.ts` and `campus.service.spec.ts`.

## Related Documentation

- [API Examples](./API_EXAMPLES.md)
- [Database Schema Analysis](./DATABASE_SCHEMA_ANALYSIS.md)
- [Architecture Diagrams](./ARCHITECTURE_DIAGRAMS.md)

## Support and Issues

For issues or questions regarding the campus feature:
1. Check existing error handling documentation
2. Review database constraints
3. Verify role-based permissions
4. Check JWT token validity
