# Testing POST Campus Endpoint in Postman

## Step-by-Step Guide

### 1. Prerequisites
- Postman installed
- Backend server running (`npm start` or `npm run start:dev`)
- Valid JWT token for authentication
- Server URL: `http://localhost:3000`

### 2. Get JWT Token First

If you don't have a token, you need to authenticate:

**Endpoint:** `POST /api/auth/login` (or your auth endpoint)

**Request Body:**
```json
{
  "email": "admin@example.com",
  "password": "your_password"
}
```

**Response will include:**
```json
{
  "accessToken": "your_jwt_token_here",
  "user": { ... }
}
```

Copy this token - you'll need it for authorization.

---

## Testing POST Campus Endpoint

### Step 1: Open Postman

1. Click **+** to create a new request
2. Select **HTTP Method:** POST
3. Enter **URL:** `http://localhost:3000/api/campuses`

### Step 2: Set Authorization Header

**Option A: Using Authorization Tab (Recommended)**

1. Go to **Authorization** tab
2. Select Type: **Bearer Token**
3. Paste your JWT token in the **Token** field

**Option B: Using Headers Tab**

1. Go to **Headers** tab
2. Add header:
   - **Key:** `Authorization`
   - **Value:** `Bearer YOUR_JWT_TOKEN_HERE`

### Step 3: Set Content-Type Header

Go to **Headers** tab and add:
- **Key:** `Content-Type`
- **Value:** `application/json`

(Usually auto-added if you use Body as JSON)

### Step 4: Add Request Body

1. Click **Body** tab
2. Select **raw**
3. Select **JSON** from dropdown
4. Paste this JSON:

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

### Step 5: Send Request

Click the **Send** button

### Step 6: Check Response

**Success Response (201 Created):**
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
  "createdAt": "2025-01-15T10:30:00.000Z",
  "updatedAt": "2025-01-15T10:30:00.000Z"
}
```

---

## Sample Test Cases

### Test Case 1: Create Campus with All Fields

**URL:** `POST http://localhost:3000/api/campuses`

**Headers:**
```
Authorization: Bearer YOUR_JWT_TOKEN
Content-Type: application/json
```

**Body:**
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

**Expected:** 201 Created

---

### Test Case 2: Create Campus with Minimal Fields

**URL:** `POST http://localhost:3000/api/campuses`

**Headers:**
```
Authorization: Bearer YOUR_JWT_TOKEN
Content-Type: application/json
```

**Body:**
```json
{
  "name": "North Campus",
  "code": "NORTH"
}
```

**Expected:** 201 Created (with defaults: timezone=UTC, status=active)

---

### Test Case 3: Create with Invalid Code Format

**URL:** `POST http://localhost:3000/api/campuses`

**Body (will fail):**
```json
{
  "name": "Test Campus",
  "code": "invalid_code_123"
}
```

**Expected:** 400 Bad Request
```json
{
  "statusCode": 400,
  "message": "Code must be 2-20 uppercase alphanumeric characters",
  "error": "Bad Request"
}
```

---

### Test Case 4: Create with Duplicate Code

**URL:** `POST http://localhost:3000/api/campuses`

**Body (if MAIN already exists):**
```json
{
  "name": "Another Campus",
  "code": "MAIN"
}
```

**Expected:** 409 Conflict
```json
{
  "statusCode": 409,
  "message": "Campus code \"MAIN\" already exists",
  "error": "Conflict"
}
```

---

### Test Case 5: Create Without Authentication

**URL:** `POST http://localhost:3000/api/campuses`

**Body:**
```json
{
  "name": "Test Campus",
  "code": "TEST"
}
```

**Expected:** 401 Unauthorized (no token provided)

---

### Test Case 6: Create with Invalid Phone Format

**URL:** `POST http://localhost:3000/api/campuses`

**Body:**
```json
{
  "name": "Test Campus",
  "code": "TEST",
  "phone": "invalid@phone#format"
}
```

**Expected:** 400 Bad Request (invalid phone format)

---

## Validation Rules Reference

| Field | Rule | Example |
|-------|------|---------|
| name | Required, 1-100 chars | "Main Campus" |
| code | Required, 2-20 uppercase alphanumeric, unique | "MAIN", "CAMPUS01" |
| address | Optional | "123 University St" |
| city | Optional | "New York" |
| country | Optional | "USA" |
| phone | Optional, valid format | "+1-555-0100" |
| email | Optional | "main@university.edu" |
| timezone | Optional, defaults to UTC | "America/New_York" |
| status | Optional, defaults to active | "active" or "inactive" |

---

## Common Errors & Solutions

### Error: 401 Unauthorized

**Problem:** Missing or invalid JWT token

**Solution:**
1. Get a valid JWT token from login endpoint
2. Add it to Authorization header: `Bearer YOUR_TOKEN`
3. Check token hasn't expired

### Error: 400 Bad Request - Code Format

**Problem:** Code doesn't match pattern (2-20 uppercase alphanumeric)

**Solutions:**
- ✅ MAIN, CAMPUS01, NORTH (valid)
- ❌ main, CAMPUS_01, C (invalid)

### Error: 409 Conflict - Duplicate Code

**Problem:** Campus code already exists

**Solution:**
1. Use a unique campus code
2. Check existing campuses: `GET /api/campuses`
3. Generate new code like: CAMPUS02, SOUTH, etc.

### Error: 403 Forbidden

**Problem:** Your user role doesn't have permission

**Solution:**
- Only IT_ADMIN role can create campuses
- Check your user role in the JWT token
- Contact admin if you need elevated privileges

---

## Postman Collection JSON

You can import this into Postman as a collection:

```json
{
  "info": {
    "name": "Campus API",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  "item": [
    {
      "name": "Create Campus",
      "request": {
        "method": "POST",
        "header": [
          {
            "key": "Authorization",
            "value": "Bearer {{jwt_token}}",
            "type": "text"
          },
          {
            "key": "Content-Type",
            "value": "application/json",
            "type": "text"
          }
        ],
        "body": {
          "mode": "raw",
          "raw": "{\n  \"name\": \"Main Campus\",\n  \"code\": \"MAIN\",\n  \"address\": \"123 University Street\",\n  \"city\": \"New York\",\n  \"country\": \"USA\",\n  \"phone\": \"+1-555-0100\",\n  \"email\": \"main@university.edu\",\n  \"timezone\": \"America/New_York\",\n  \"status\": \"active\"\n}"
        },
        "url": {
          "raw": "http://localhost:3000/api/campuses",
          "protocol": "http",
          "host": ["localhost"],
          "port": "3000",
          "path": ["api", "campuses"]
        }
      }
    },
    {
      "name": "List Campuses",
      "request": {
        "method": "GET",
        "header": [
          {
            "key": "Authorization",
            "value": "Bearer {{jwt_token}}",
            "type": "text"
          }
        ],
        "url": {
          "raw": "http://localhost:3000/api/campuses",
          "protocol": "http",
          "host": ["localhost"],
          "port": "3000",
          "path": ["api", "campuses"]
        }
      }
    },
    {
      "name": "Get Campus by ID",
      "request": {
        "method": "GET",
        "header": [
          {
            "key": "Authorization",
            "value": "Bearer {{jwt_token}}",
            "type": "text"
          }
        ],
        "url": {
          "raw": "http://localhost:3000/api/campuses/1",
          "protocol": "http",
          "host": ["localhost"],
          "port": "3000",
          "path": ["api", "campuses", "1"]
        }
      }
    }
  ],
  "variable": [
    {
      "key": "jwt_token",
      "value": "your_jwt_token_here"
    }
  ]
}
```

---

## Tips for Testing

### 1. Use Environment Variables
In Postman, create an environment with:
- `base_url`: `http://localhost:3000`
- `jwt_token`: Your JWT token

Then use `{{base_url}}` and `{{jwt_token}}` in requests.

### 2. Save Valid Responses
After successful creation, copy the response and save it for reference.

### 3. Test Error Cases
Always test invalid inputs to verify error handling:
- Invalid code format
- Duplicate code
- Missing required fields
- Invalid phone format

### 4. Check Request/Response
After sending:
1. Check **Status Code** (201 for success)
2. Review **Response Body** for returned data
3. Check **Response Headers**
4. Use **Console** tab to see request details

### 5. Use Pre-request Scripts
Add this to auto-generate unique codes:

```javascript
// Pre-request Script tab
const timestamp = Date.now();
const randomCode = "CAMPUS" + timestamp.toString().slice(-4);
pm.environment.set("randomCode", randomCode);
```

Then use `"code": "{{randomCode}}"` in body.

---

## Quick Reference - Request Format

```
POST /api/campuses HTTP/1.1
Host: localhost:3000
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json

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

**Expected Response:**
```
HTTP/1.1 201 Created
Content-Type: application/json

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
  "createdAt": "2025-01-15T10:30:00.000Z",
  "updatedAt": "2025-01-15T10:30:00.000Z"
}
```

---

## Testing Checklist

- [ ] Postman installed and running
- [ ] Backend server running (`npm run start:dev`)
- [ ] Have valid JWT token from login
- [ ] Authorization header set correctly
- [ ] Content-Type set to application/json
- [ ] Request body in valid JSON format
- [ ] Code is uppercase alphanumeric, 2-20 chars
- [ ] Send request and check 201 status
- [ ] Response includes new campus with ID
- [ ] Timestamp fields are present
- [ ] Test with minimal fields (only name + code)
- [ ] Test duplicate code error (409)
- [ ] Test invalid code format (400)
- [ ] Test without auth token (401)

---

## Related API Endpoints

After creating a campus, test these related endpoints:

```bash
# List all campuses
GET /api/campuses

# Get specific campus
GET /api/campuses/1

# Update campus
PUT /api/campuses/1

# Delete campus (only if no departments)
DELETE /api/campuses/1

# Get departments in campus
GET /api/campuses/1/departments
```

---

For more details, see: `CAMPUS_FEATURE_DOCUMENTATION.md`
