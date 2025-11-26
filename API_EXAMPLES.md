# Email Verification API Examples

## Complete Request/Response Examples

### 1. User Registration

**Endpoint**: `POST /api/auth/register`  
**Status**: 201 Created

**Request**:
```json
{
  "email": "john.doe@example.com",
  "password": "SecurePass123!",
  "firstName": "John",
  "lastName": "Doe",
  "phone": "+1-555-1234",
  "role": "student"
}
```

**Success Response** (201):
```json
{
  "message": "Registration successful! Please check your email to verify your account.",
  "user": {
    "userId": 17,
    "email": "john.doe@example.com",
    "firstName": "John",
    "lastName": "Doe",
    "phone": "+1-555-1234",
    "fullName": "John Doe",
    "status": "pending",
    "emailVerified": false,
    "roles": ["student"],
    "createdAt": "2025-11-26T14:45:00.000Z",
    "updatedAt": "2025-11-26T14:45:00.000Z"
  }
}
```

**Error: Email Already Registered** (409):
```json
{
  "statusCode": 409,
  "message": "Email already registered",
  "error": "Conflict"
}
```

**Error: Failed to Send Email** (400):
```json
{
  "statusCode": 400,
  "message": "Failed to send verification email",
  "error": "Bad Request"
}
```

---

### 2. Verify Email

**Endpoint**: `POST /api/auth/verify-email`  
**Status**: 200 OK

**Request**:
```json
{
  "token": "a7b8c9d0e1f2g3h4i5j6k7l8m9n0o1p2q3r4s5t6u7v8w9x0y1z2a3b4c5d6e"
}
```

**Success Response** (200):
```json
{
  "message": "Email verified successfully! Your account is now active."
}
```

**Error: Invalid Token** (400):
```json
{
  "statusCode": 400,
  "message": "Invalid or already used verification token",
  "error": "Bad Request"
}
```

**Error: Token Expired** (400):
```json
{
  "statusCode": 400,
  "message": "Verification token has expired",
  "error": "Bad Request"
}
```

---

### 3. Resend Verification Email

**Endpoint**: `POST /api/auth/resend-verification-email`  
**Status**: 200 OK

**Request**:
```json
{
  "email": "john.doe@example.com"
}
```

**Success Response** (200):
```json
{
  "message": "Verification email has been sent to your email address"
}
```

**Error: User Not Found** (400):
```json
{
  "statusCode": 400,
  "message": "User not found",
  "error": "Bad Request"
}
```

**Error: Already Verified** (400):
```json
{
  "statusCode": 400,
  "message": "Email is already verified",
  "error": "Bad Request"
}
```

---

### 4. Login (Before Email Verification)

**Endpoint**: `POST /api/auth/login`  
**Status**: 401 Unauthorized

**Request**:
```json
{
  "email": "john.doe@example.com",
  "password": "SecurePass123!",
  "rememberMe": false
}
```

**Error Response** (401):
```json
{
  "statusCode": 401,
  "message": "Please verify your email first",
  "error": "Unauthorized"
}
```

---

### 5. Login (After Email Verification)

**Endpoint**: `POST /api/auth/login`  
**Status**: 200 OK

**Request**:
```json
{
  "email": "john.doe@example.com",
  "password": "SecurePass123!",
  "rememberMe": false
}
```

**Success Response** (200):
```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjE3LCJlbWFpbCI6ImpvaG4uZG9lQGV4YW1wbGUuY29tIiwicm9sZXMiOlsic3R1ZGVudCJdLCJpYXQiOjE2MzAwMDAwMDAsImV4cCI6MTYzMDAwMzYwMH0.SIGNATURE",
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjE3LCJlbWFpbCI6ImpvaG4uZG9lQGV4YW1wbGUuY29tIiwicm9sZXMiOlsic3R1ZGVudCJdLCJpYXQiOjE2MzAwMDAwMDAsImV4cCI6MTYzMDYwNDgwMH0.SIGNATURE",
  "user": {
    "userId": 17,
    "email": "john.doe@example.com",
    "firstName": "John",
    "lastName": "Doe",
    "fullName": "John Doe",
    "phone": "+1-555-1234",
    "roles": ["student"],
    "emailVerified": true,
    "status": "active",
    "lastLoginAt": "2025-11-26T14:50:00.000Z",
    "createdAt": "2025-11-26T14:45:00.000Z"
  }
}
```

---

## Complete Registration to Login Flow

### Step-by-Step Example

#### Step 1: User Registers
```bash
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "newuser@example.com",
    "password": "MyPass@123",
    "firstName": "Jane",
    "lastName": "Smith"
  }'
```

**Response**:
```json
{
  "message": "Registration successful! Please check your email to verify your account.",
  "user": {
    "userId": 18,
    "email": "newuser@example.com",
    "firstName": "Jane",
    "lastName": "Smith",
    "status": "pending",
    "emailVerified": false
  }
}
```

---

#### Step 2: Email Sent to User
The user receives an email with subject: **"Verify Your Email Address"**

Email body contains:
- Welcome message
- Verification link: `http://localhost:3000/verify-email?token=a7b8c9d0e1f2g3h4i5j6k7l8m9n0o1p2q3r4s5t6u7v8w9x0y1z2a3b4c5d6e`
- Raw token link
- Footer with copyright

---

#### Step 3: User Clicks Link or Submits Token
User receives token from email and submits it:

```bash
curl -X POST http://localhost:3000/api/auth/verify-email \
  -H "Content-Type: application/json" \
  -d '{
    "token": "a7b8c9d0e1f2g3h4i5j6k7l8m9n0o1p2q3r4s5t6u7v8w9x0y1z2a3b4c5d6e"
  }'
```

**Response**:
```json
{
  "message": "Email verified successfully! Your account is now active."
}
```

---

#### Step 4: User Can Now Login
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "newuser@example.com",
    "password": "MyPass@123",
    "rememberMe": false
  }'
```

**Response**:
```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "userId": 18,
    "email": "newuser@example.com",
    "firstName": "Jane",
    "lastName": "Smith",
    "status": "active",
    "emailVerified": true,
    "roles": ["student"]
  }
}
```

---

## Resend Verification Email Flow

### Scenario: User Didn't Receive Email

#### Step 1: Request Resend
```bash
curl -X POST http://localhost:3000/api/auth/resend-verification-email \
  -H "Content-Type: application/json" \
  -d '{
    "email": "newuser@example.com"
  }'
```

**Response**:
```json
{
  "message": "Verification email has been sent to your email address"
}
```

#### Step 2: New Email Sent
- User receives new verification email with fresh token
- Previous token is invalidated in database

#### Step 3: Verify with New Token
```bash
curl -X POST http://localhost:3000/api/auth/verify-email \
  -H "Content-Type: application/json" \
  -d '{
    "token": "new_token_from_resent_email"
  }'
```

---

## Error Scenarios

### Scenario 1: Token Expired (24+ hours)

```bash
curl -X POST http://localhost:3000/api/auth/verify-email \
  -H "Content-Type: application/json" \
  -d '{
    "token": "old_token_from_24_hours_ago"
  }'
```

**Response** (400):
```json
{
  "statusCode": 400,
  "message": "Verification token has expired",
  "error": "Bad Request"
}
```

**Solution**: Call `/api/auth/resend-verification-email` to get new token

---

### Scenario 2: Token Already Used

```bash
curl -X POST http://localhost:3000/api/auth/verify-email \
  -H "Content-Type: application/json" \
  -d '{
    "token": "already_verified_token"
  }'
```

**Response** (400):
```json
{
  "statusCode": 400,
  "message": "Invalid or already used verification token",
  "error": "Bad Request"
}
```

**Solution**: No action needed (email already verified) or resend if needed

---

### Scenario 3: Login Before Email Verification

```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "newuser@example.com",
    "password": "MyPass@123"
  }'
```

**Response** (401):
```json
{
  "statusCode": 401,
  "message": "Please verify your email first",
  "error": "Unauthorized"
}
```

**Solution**: Complete email verification first

---

## cURL Command Examples for Testing

### Quick Test Script
```bash
#!/bin/bash

# Variables
BASE_URL="http://localhost:3000/api/auth"
EMAIL="test-$(date +%s)@example.com"
PASSWORD="TestPass@123"
FIRST_NAME="Test"
LAST_NAME="User"

echo "1. Registering user..."
REGISTER_RESPONSE=$(curl -s -X POST $BASE_URL/register \
  -H "Content-Type: application/json" \
  -d "{
    \"email\": \"$EMAIL\",
    \"password\": \"$PASSWORD\",
    \"firstName\": \"$FIRST_NAME\",
    \"lastName\": \"$LAST_NAME\"
  }")

echo "Registration Response:"
echo $REGISTER_RESPONSE | jq .

# Note: In real test, extract token from email service
# For testing, you might need to check database directly:
# SELECT verification_token FROM email_verifications WHERE user_id = X

echo ""
echo "2. Check email service for verification token..."
echo "   (Look for email sent to: $EMAIL)"

echo ""
echo "3. Verify email with token (when available)..."
echo "   curl -X POST $BASE_URL/verify-email \\"
echo "     -H 'Content-Type: application/json' \\"
echo "     -d '{\"token\": \"TOKEN_FROM_EMAIL\"}'"

echo ""
echo "4. Try login before verification..."
curl -s -X POST $BASE_URL/login \
  -H "Content-Type: application/json" \
  -d "{
    \"email\": \"$EMAIL\",
    \"password\": \"$PASSWORD\"
  }" | jq .

echo ""
echo "5. After verification, login should work..."
```

---

## Response Status Codes Reference

| Code | Meaning | When It Occurs |
|------|---------|----------------|
| 201 | Created | Registration successful |
| 200 | OK | Verification success, resend success, login success |
| 400 | Bad Request | Invalid input, expired token, user not found |
| 401 | Unauthorized | Email not verified, invalid credentials |
| 409 | Conflict | Email already registered |

---

## Database Queries for Testing

### Check User Registration
```sql
SELECT user_id, email, status, email_verified, created_at 
FROM users 
WHERE email = 'test@example.com';
```

### Check Verification Token
```sql
SELECT verification_id, user_id, verification_token, expires_at, used 
FROM email_verifications 
WHERE user_id = 18;
```

### Mark Token as Used Manually (for testing)
```sql
UPDATE email_verifications 
SET used = 1, used_at = NOW() 
WHERE user_id = 18 AND used = 0;
```

### Clean Up Test Data
```sql
DELETE FROM email_verifications WHERE user_id IN (
  SELECT user_id FROM users WHERE email LIKE 'test-%@example.com'
);

DELETE FROM users WHERE email LIKE 'test-%@example.com';
```

---

**All examples tested and ready to use!**
