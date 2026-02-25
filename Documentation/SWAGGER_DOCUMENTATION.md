# EduVerse API - Swagger Documentation Guide

## Table of Contents
1. [Overview](#overview)
2. [Accessing Swagger UI](#accessing-swagger-ui)
3. [Authentication](#authentication)
4. [Using the API Documentation](#using-the-api-documentation)
5. [Testing Endpoints](#testing-endpoints)
6. [Role-Based Access Control](#role-based-access-control)
7. [Common Use Cases](#common-use-cases)
8. [Troubleshooting](#troubleshooting)

---

## Overview

EduVerse API uses **Swagger (OpenAPI 3.0)** for interactive API documentation. Swagger provides a user-friendly interface to explore, understand, and test all API endpoints directly from your browser.

### Features
- 📖 Interactive API documentation
- 🔐 Built-in authentication support
- 🧪 Test endpoints directly in the browser
- 📋 Request/response schema visualization
- 🏷️ Organized endpoints by tags/modules

---

## Accessing Swagger UI

### URL
Once the server is running, access Swagger UI at:

```
http://localhost:3001/api-docs
```

### Starting the Server

```bash
# Development mode
npm run start:dev

# Production mode
npm run start:prod

# Or using the batch file
./start.bat
```

After starting, you'll see:
```
🚀 Application is running on: http://localhost:3001
📚 Swagger API Documentation: http://localhost:3001/api-docs
```

---

## Authentication

Most EduVerse API endpoints require authentication. Here's how to authenticate in Swagger:

### Step 1: Get Access Token

1. Navigate to the **🔐 Authentication** section
2. Expand `POST /api/auth/login`
3. Click **"Try it out"**
4. Enter your credentials:
   ```json
   {
     "email": "your.email@example.com",
     "password": "YourPassword123!",
     "rememberMe": false
   }
   ```
5. Click **"Execute"**
6. Copy the `accessToken` from the response

### Step 2: Authorize Swagger

1. Click the **🔓 Authorize** button (top right of Swagger UI)
2. In the modal, enter your token:
   ```
   Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
   ```
   > ⚠️ Include the word "Bearer" followed by a space before your token
3. Click **"Authorize"**
4. Click **"Close"**

Now all authenticated endpoints will automatically include your token.

### Token Expiration

- **Access tokens** expire after 15 minutes
- Use `POST /api/auth/refresh-token` to get a new access token
- **Refresh tokens** expire after 7 days (or 30 days with `rememberMe: true`)

---

## Using the API Documentation

### Navigation

Endpoints are organized by tags (modules):

| Tag | Description |
|-----|-------------|
| 🔐 Authentication | Login, register, password reset, email verification |
| 👥 User Management | Admin endpoints for users, roles, permissions |
| 🏛️ Campus | Campus management |
| 🏢 Departments | Department management |
| 📚 Programs | Academic programs |
| 📅 Semesters | Semester/term management |
| 📖 Courses | Course catalog |
| 📝 Course Sections | Course sections and schedules |
| ✅ Enrollments | Student course registration |
| 📁 Files | File upload and management |
| 📂 Folders | Folder organization |
| 🎬 YouTube | YouTube video integration |

### Understanding Endpoint Details

Each endpoint shows:

1. **HTTP Method** - GET, POST, PUT, DELETE, PATCH
2. **Path** - The URL path (e.g., `/api/auth/login`)
3. **Summary** - Brief description
4. **Description** - Detailed information including:
   - Access control requirements
   - Required roles
   - Process flow
   - Notes and warnings

### Color Coding

- 🟢 **GET** - Retrieve data
- 🟡 **POST** - Create new resource
- 🔵 **PUT/PATCH** - Update existing resource
- 🔴 **DELETE** - Remove resource

---

## Testing Endpoints

### Step-by-Step Guide

1. **Expand the endpoint** by clicking on it
2. Click **"Try it out"** button
3. **Fill in parameters**:
   - Path parameters (in URL)
   - Query parameters (optional filters)
   - Request body (JSON data)
4. Click **"Execute"**
5. View the response:
   - Response code
   - Response headers
   - Response body

### Example: Creating a Campus

1. Navigate to **🏛️ Campus** → `POST /api/campuses`
2. Click "Try it out"
3. Enter the request body:
   ```json
   {
     "name": "Engineering Campus",
     "code": "ENG01",
     "address": "123 Tech Street",
     "city": "Cairo",
     "country": "Egypt",
     "email": "engineering@university.edu"
   }
   ```
4. Click "Execute"
5. Expected response: `201 Created`

---

## Role-Based Access Control

### Available Roles

| Role | Description | Access Level |
|------|-------------|--------------|
| `student` | Regular students | View courses, enroll, manage own files |
| `instructor` | Faculty members | Manage course content, view enrollments |
| `ta` | Teaching assistants | Limited instructor capabilities |
| `admin` | Administrators | User management, campus/course management |
| `it_admin` | IT administrators | Full system access, role/permission management |

### Endpoint Access Matrix

#### Public Endpoints (No Authentication)
- `POST /api/auth/register`
- `POST /api/auth/login`
- `POST /api/auth/forgot-password`
- `POST /api/auth/reset-password`
- `POST /api/auth/verify-email`
- `GET /api/courses` (read-only)

#### Student Endpoints
- `GET /api/enrollments/my-courses`
- `GET /api/enrollments/available`
- `POST /api/enrollments/register`
- `DELETE /api/enrollments/:id` (own enrollments)

#### Instructor Endpoints
- `GET /api/enrollments/section/:sectionId/students`
- `GET /api/enrollments/section/:sectionId/waitlist`
- Course content management

#### Admin Endpoints
- All user management under `/api/admin/*`
- Campus, department, program, semester CRUD
- Course and section management

#### IT Admin Endpoints
- Role and permission management
- System-wide configurations

### How to Check Required Roles

Each endpoint's description includes an **Access Control** section:

```
### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: ADMIN, IT_ADMIN only
```

---

## Common Use Cases

### 1. Student Registration Flow

```mermaid
1. POST /api/auth/register (create account)
2. Check email for verification link
3. POST /api/auth/verify-email (verify account)
4. POST /api/auth/login (get tokens)
```

### 2. Student Course Enrollment

```mermaid
1. POST /api/auth/login (authenticate)
2. GET /api/enrollments/available (view available courses)
3. POST /api/enrollments/register (enroll in section)
4. GET /api/enrollments/my-courses (verify enrollment)
```

### 3. Admin User Management

```mermaid
1. POST /api/auth/login (as admin)
2. GET /api/admin/users (list users)
3. POST /api/admin/users/:id/roles (assign role)
4. PUT /api/admin/users/:id/status (activate/deactivate)
```

### 4. File Upload

```mermaid
1. POST /api/auth/login (authenticate)
2. POST /api/files/folders (create folder - optional)
3. POST /api/files/upload (upload file)
4. POST /api/files/:fileId/permissions (share file)
```

---

## Troubleshooting

### Common Issues

#### 401 Unauthorized
- **Cause**: Missing or expired token
- **Solution**: 
  1. Login again to get fresh token
  2. Re-authorize in Swagger UI

#### 403 Forbidden
- **Cause**: User doesn't have required role
- **Solution**: 
  1. Check endpoint's required roles
  2. Contact admin for role assignment

#### 400 Bad Request
- **Cause**: Invalid input data
- **Solution**: 
  1. Check request body format
  2. Verify required fields are present
  3. Check field validation rules in schema

#### 404 Not Found
- **Cause**: Resource doesn't exist
- **Solution**: 
  1. Verify the ID is correct
  2. Check if resource was deleted

#### 409 Conflict
- **Cause**: Duplicate resource (e.g., email already exists)
- **Solution**: 
  1. Use different unique values
  2. Check existing resources

### Swagger UI Issues

#### "Failed to fetch" Error
- Server might not be running
- CORS issues - check server logs
- Try refreshing the page

#### Schema Not Loading
- Clear browser cache
- Restart the server
- Check for TypeScript compilation errors

---

## Additional Resources

### API Response Codes

| Code | Meaning |
|------|---------|
| 200 | Success |
| 201 | Created |
| 204 | No Content (success with no body) |
| 400 | Bad Request |
| 401 | Unauthorized |
| 403 | Forbidden |
| 404 | Not Found |
| 409 | Conflict |
| 413 | Payload Too Large |
| 500 | Internal Server Error |

### Support

For API issues or questions:
- Check the endpoint's description for usage details
- Review request/response schemas
- Contact: support@eduverse.com

---

## Version Information

- **API Version**: 1.0.0
- **Swagger UI Version**: Latest
- **Last Updated**: February 2024

---

*This documentation is auto-generated and maintained with the EduVerse API codebase.*
