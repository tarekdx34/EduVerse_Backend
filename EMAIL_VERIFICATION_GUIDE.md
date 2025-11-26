# Email Verification Implementation Guide

## Overview
Email verification is now fully implemented in the EduVerse authentication system. When users register, they must verify their email address before they can log in.

## Features Implemented

### 1. User Registration Flow
- User registers with email, password, name, and optional phone
- User account is created with status `PENDING` and `emailVerified = false`
- Verification email is sent to the user's email address
- Returns success message with user data (without login tokens)
- If email sending fails, registration is rolled back and error is thrown

### 2. Email Verification
- Users receive an email with a verification link containing a token
- Token is valid for 24 hours
- Tokens are hashed and stored in the database for security
- Once verified, user status changes to `ACTIVE` and `emailVerified = true`
- User can now log in

### 3. Resend Verification Email
- Users can request a new verification email if they didn't receive the first one
- Previous unused tokens are invalidated
- New token is generated with fresh 24-hour expiration

### 4. Login Restrictions
- Users cannot log in if `emailVerified = false`
- Users cannot log in if status is not `ACTIVE`

## Database Schema

### New Table: `email_verifications`
```sql
CREATE TABLE `email_verifications` (
  `verification_id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `verification_token` varchar(255) NOT NULL,
  `expires_at` datetime NOT NULL,
  `used` tinyint(1) DEFAULT 0,
  `used_at` datetime NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_token` (`verification_token`),
  KEY `idx_used_expires` (`used`, `expires_at`),
  CONSTRAINT `fk_email_verifications_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### Updated User Table
- Existing column: `email_verified` (tinyint(1) DEFAULT 0)
- Existing column: `status` (enum: 'active', 'inactive', 'suspended', 'pending')
- New relationship: One-to-Many with `email_verifications` table

## API Endpoints

### 1. Register
**POST** `/api/auth/register`

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "SecurePass123!",
  "firstName": "John",
  "lastName": "Doe",
  "phone": "+1-555-1234",
  "role": "student"
}
```

**Response (Success - 201):**
```json
{
  "message": "Registration successful! Please check your email to verify your account.",
  "user": {
    "userId": 1,
    "email": "user@example.com",
    "firstName": "John",
    "lastName": "Doe",
    "phone": "+1-555-1234",
    "fullName": "John Doe",
    "status": "pending",
    "emailVerified": false,
    "createdAt": "2025-11-26T14:45:00Z"
  }
}
```

### 2. Verify Email
**POST** `/api/auth/verify-email`

**Request Body:**
```json
{
  "token": "verification_token_from_email"
}
```

**Response (Success - 200):**
```json
{
  "message": "Email verified successfully! Your account is now active."
}
```

**Response (Error - 400):**
```json
{
  "statusCode": 400,
  "message": "Verification token has expired",
  "error": "Bad Request"
}
```

### 3. Resend Verification Email
**POST** `/api/auth/resend-verification-email`

**Request Body:**
```json
{
  "email": "user@example.com"
}
```

**Response (Success - 200):**
```json
{
  "message": "Verification email has been sent to your email address"
}
```

**Response (Error - 400):**
```json
{
  "statusCode": 400,
  "message": "Email is already verified",
  "error": "Bad Request"
}
```

### 4. Login
**POST** `/api/auth/login`

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "SecurePass123!",
  "rememberMe": false
}
```

**Response (Success - 200):**
```json
{
  "accessToken": "jwt_access_token",
  "refreshToken": "jwt_refresh_token",
  "user": {
    "userId": 1,
    "email": "user@example.com",
    "firstName": "John",
    "lastName": "Doe",
    "fullName": "John Doe",
    "roles": ["student"],
    "emailVerified": true,
    "status": "active"
  }
}
```

**Response (Error - 401):**
```json
{
  "statusCode": 401,
  "message": "Please verify your email first",
  "error": "Unauthorized"
}
```

## Email Template
The verification email includes:
- Welcome message
- Personalized greeting with user's first name
- "Verify Email" button with the verification link
- Link expiration notice (24 hours)
- Footer with EduVerse branding

## Security Measures

1. **Token Storage**: Tokens are hashed using SHA256 before storage
2. **Token Expiration**: Tokens expire after 24 hours
3. **Single Use**: Tokens can only be used once; marked as `used` after verification
4. **One Token Per User**: Previous unused tokens are invalidated when generating new ones
5. **User Deletion on Failure**: If email sending fails, the user and verification records are deleted
6. **Account Lockout**: Unverified accounts cannot log in

## Implementation Details

### Entity Classes
- `User` - Updated with relationship to `EmailVerification`
- `EmailVerification` - New entity for storing verification tokens
- `Role`, `Session`, `PasswordReset`, `TwoFactorAuth` - Unchanged

### Service Methods
- `register()` - Creates user and sends verification email
- `verifyEmail(token)` - Verifies token and activates user account
- `resendVerificationEmail(email)` - Sends new verification email
- `login()` - Enhanced to check email verification status

### Controller Endpoints
- `POST /api/auth/register` - Enhanced to prevent auto-activation
- `POST /api/auth/verify-email` - Verifies email token
- `POST /api/auth/resend-verification-email` - Resends verification email
- `POST /api/auth/login` - Enhanced to check email verification

## Testing the Feature

### Test Case 1: Register New User
1. POST `/api/auth/register` with valid data
2. Check email for verification link
3. Extract token from email
4. POST `/api/auth/verify-email` with token
5. POST `/api/auth/login` should succeed

### Test Case 2: Expired Token
1. Wait 24+ hours after registration
2. Try to verify with expired token
3. Should receive "Verification token has expired" error
4. POST `/api/auth/resend-verification-email` to get new token

### Test Case 3: Login Without Verification
1. Register new user
2. Try to login without verifying email
3. Should receive "Please verify your email first" error

### Test Case 4: Resend Verification
1. Register new user
2. POST `/api/auth/resend-verification-email`
3. Check email for new verification link
4. Verify with new token

## Environment Variables Required
- `FRONTEND_URL` - URL for verification link (e.g., http://localhost:3000)
- `MAIL_HOST` - SMTP server host
- `MAIL_PORT` - SMTP server port
- `MAIL_USER` - SMTP username
- `MAIL_PASSWORD` - SMTP password
- `MAIL_FROM_NAME` - Display name for emails
- `MAIL_FROM_ADDRESS` - From address for emails

## Migration Path for Existing Users
If you have existing users without email verification:
1. Run the SQL migration to create `email_verifications` table
2. Set existing users as verified: `UPDATE users SET email_verified = 1, status = 'active' WHERE status = 'pending'`
3. Optionally send verification emails to old users for re-verification

## Future Enhancements
- [ ] Email verification timeout configurable per environment
- [ ] Automatic resend after X days if not verified
- [ ] Verification code (6 digits) alternative to token
- [ ] Verification rate limiting
- [ ] Admin panel to manage verifications
