# Email Verification - Architecture & Flow Diagrams

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         EduVerse Backend                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │                 Auth Module                               │   │
│  ├──────────────────────────────────────────────────────────┤   │
│  │  • AuthController                                         │   │
│  │  • AuthService                                            │   │
│  │  • JwtStrategy                                            │   │
│  └──────────────────────────────────────────────────────────┘   │
│                            ↕                                     │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │              Email Module                                 │   │
│  ├──────────────────────────────────────────────────────────┤   │
│  │  • EmailService                                           │   │
│  │  • Email Templates                                        │   │
│  └──────────────────────────────────────────────────────────┘   │
│                            ↕                                     │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │              Database (MySQL)                             │   │
│  ├──────────────────────────────────────────────────────────┤   │
│  │  • users                                                  │   │
│  │  • email_verifications (NEW)                              │   │
│  │  • roles                                                  │   │
│  │  • sessions                                               │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
        ↕                          ↕                     ↕
  ┌────────────┐          ┌──────────────┐      ┌────────────┐
  │   SMTP     │          │  Frontend    │      │  External  │
  │   Server   │          │  Application │      │  Systems   │
  └────────────┘          └──────────────┘      └────────────┘
```

---

## Data Flow Diagram

### Registration Flow
```
User
  │
  ├─→ POST /api/auth/register
  │         ↓
  │    ┌─────────────────────┐
  │    │ Validate Request    │
  │    │ - Email format      │
  │    │ - Password strength │
  │    │ - Required fields   │
  │    └─────────────────────┘
  │         ↓
  │    ┌─────────────────────┐
  │    │ Check Email Exists  │
  │    │ in users table      │
  │    └─────────────────────┘
  │         ↓
  │    ┌─────────────────────┐
  │    │ Create User         │
  │    │ status: PENDING     │
  │    │ emailVerified: false│
  │    └─────────────────────┘
  │         ↓
  │    ┌─────────────────────┐
  │    │ Generate Token      │
  │    │ - 32 bytes random   │
  │    │ - SHA256 hash       │
  │    │ - 24h expiration    │
  │    └─────────────────────┘
  │         ↓
  │    ┌─────────────────────┐
  │    │ Store in DB         │
  │    │ email_verifications │
  │    └─────────────────────┘
  │         ↓
  │    ┌─────────────────────┐
  │    │ Send Email          │
  │    │ with token link     │
  │    └─────────────────────┘
  │         ↓
  │    Response: 201 Created
  │    { message, user }
  │
  └─→ Check Email
      │
      └─→ Click Verification Link
          │
          ├─→ POST /api/auth/verify-email
          │         ↓
          │    ┌────────────────────┐
          │    │ Hash Token         │
          │    │ from request       │
          │    └────────────────────┘
          │         ↓
          │    ┌────────────────────┐
          │    │ Find Token in DB   │
          │    │ - Check if used    │
          │    │ - Check expiration │
          │    └────────────────────┘
          │         ↓
          │    ┌────────────────────┐
          │    │ Update User        │
          │    │ emailVerified: true│
          │    │ status: ACTIVE     │
          │    └────────────────────┘
          │         ↓
          │    ┌────────────────────┐
          │    │ Mark Token Used    │
          │    │ used: true         │
          │    │ used_at: now()     │
          │    └────────────────────┘
          │         ↓
          │    Response: 200 OK
          │    { message }
          │
          └─→ User Can Now Login
              │
              ├─→ POST /api/auth/login
              │         ↓
              │    ┌────────────────────┐
              │    │ Verify Email Check │
              │    │ emailVerified: true│
              │    │ status: ACTIVE     │
              │    └────────────────────┘
              │         ↓
              │    Response: 200 OK
              │    { accessToken, refreshToken, user }
              │
              └─→ User Logged In ✅
```

---

## Database Entity Relationship Diagram

```
┌─────────────────────────────────────┐
│          users                      │
├─────────────────────────────────────┤
│ PK  user_id (bigint)               │
│ UQ  email (varchar)                │
│     password_hash (varchar)        │
│     first_name (varchar)           │
│     last_name (varchar)            │
│     phone (varchar, nullable)      │
│     profile_picture_url (text)     │
│     campus_id (bigint, nullable)   │
│     status (enum)                  │
│     email_verified (tinyint)       │ ◄─ Used by verification
│     last_login_at (datetime)       │
│     created_at (timestamp)         │
│     updated_at (timestamp)         │
│     deleted_at (timestamp)         │
└─────────────────────────────────────┘
         │
         │ One-to-Many
         │ Relationship
         ▼
┌─────────────────────────────────────┐
│    email_verifications (NEW)         │
├─────────────────────────────────────┤
│ PK  verification_id (bigint)        │
│ FK  user_id (bigint)                │
│     verification_token (varchar)    │
│     expires_at (datetime)           │
│     used (tinyint)                  │
│     used_at (datetime, nullable)    │
│     created_at (timestamp)          │
│                                     │
│ Indexes:                            │
│  - idx_user_id                      │
│  - idx_token                        │
│  - idx_used_expires                 │
│  - UNIQUE(user_id, used) WHERE used │
└─────────────────────────────────────┘
```

---

## API Endpoint Flow Diagram

```
                    ┌─────────────────────┐
                    │   Client/Frontend   │
                    └────────┬────────────┘
                             │
          ┌──────────────────┼──────────────────┐
          │                  │                  │
          ▼                  ▼                  ▼
    ┌──────────┐      ┌──────────┐      ┌─────────────┐
    │ register │      │  login   │      │ verify-email│
    │  (201)   │      │  (200)   │      │   (200)     │
    └──────────┘      └──────────┘      └─────────────┘
          │                  │                  │
          │ Returns:         │ Returns:         │ Returns:
          │ message + user   │ tokens + user    │ message
          │ (no tokens)      │ (if verified)    │
          │                  │                  │
          ├─→ Error (409)    ├─→ Error (401)    ├─→ Error (400)
          │    Email exists  │    Not verified  │    Invalid token
          │                  │                  │
          └──────────────────┼──────────────────┘
                             │
          ┌──────────────────┴──────────────────┐
          │                                     │
          ▼                                     ▼
    ┌───────────────────┐            ┌──────────────────────┐
    │ resend-verification│            │ refresh-token        │
    │ (200)             │            │ login                │
    └───────────────────┘            │ logout               │
          │                          │ get-me               │
          │ Returns:                 │ forgot-password      │
          │ message                  │ reset-password       │
          │                          │ (existing endpoints) │
          │                          └──────────────────────┘
          │
          └─→ Error (400)
               User not found
               Already verified
```

---

## Token Lifecycle Diagram

```
                      Token Generation
                            │
                            ▼
                    ┌─────────────────┐
                    │ Generate Random │
                    │ 32 bytes        │
                    └────────┬────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │ Plain Token     │
                    │ (for email)     │
                    └────────┬────────┘
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
        ▼                    ▼                    ▼
  ┌──────────┐      ┌──────────────┐      ┌────────────┐
  │ Email    │      │ Hash Token   │      │ Store in   │
  │ (plain)  │      │ (SHA256)     │      │ Database   │
  └──────────┘      └──────────────┘      └────────────┘
        │                   │                    │
        │                   │                    ▼
        │                   │            ┌──────────────┐
        │                   │            │ Database     │
        │                   │            │ - hashed     │
        │                   │            │ - expires_at │
        │                   │            │ - used: false│
        │                   │            └──────────────┘
        │                   │                    │
        ▼                   ▼                    ▼
   User Receives      Token Comparison    24-hour Timer
   Verification Link   (not plain stored)  Starts
   
                        ┌─────────────────────┐
                        │ User Clicks Link    │
                        │ or Submits Token    │
                        └──────────┬──────────┘
                                   │
                                   ▼
                        ┌─────────────────────┐
                        │ Token Validation    │
                        ├─────────────────────┤
                        │ ✓ Hash match?       │
                        │ ✓ Not expired?      │
                        │ ✓ Not used?         │
                        └──────────┬──────────┘
                                   │
                    ┌──────────────┴──────────────┐
                    │ Success                │ Failure
                    ▼                        ▼
            ┌─────────────────┐    ┌──────────────────┐
            │ Mark Used       │    │ Error Response   │
            │ used: true      │    │ - Invalid token  │
            │ used_at: now()  │    │ - Expired        │
            │                 │    │ - Already used   │
            │ Update User     │    └──────────────────┘
            │ emailVerified:1 │           │
            │ status: ACTIVE  │           └─→ User can Resend
            └─────────────────┘
                    │
                    ▼
            User Account Active
            Can Login ✅
```

---

## Authentication State Machine

```
                    ┌──────────────┐
                    │   START      │
                    └────┬─────────┘
                         │
                         ▼
                 ┌──────────────────┐
                 │  NOT REGISTERED  │
                 └────┬─────────────┘
                      │
            POST /api/auth/register
                      │
                      ▼
         ┌────────────────────────────┐
         │ REGISTERED - EMAIL PENDING │
         │ status: PENDING            │◄────────┐
         │ emailVerified: false       │         │
         │                            │         │
         │ ✗ Cannot login             │         │
         │ ✓ Can verify               │         │
         │ ✓ Can resend               │         │
         └────┬──────────────┬────────┘         │
              │              │                  │
        Resend Email    Verify Email            │
              │              │                  │
              │              └──────────────────┘
              │                   │
              └───────────────────┘
                        │
                        ▼
         ┌────────────────────────────┐
         │ EMAIL VERIFIED - ACTIVE    │
         │ status: ACTIVE             │
         │ emailVerified: true        │
         │                            │
         │ ✓ Can login                │
         │ ✓ Can refresh token        │
         │ ✓ Can logout               │
         │ ✓ Full access              │
         └────┬──────────────┬────────┘
              │              │
            Login      Admin Suspend
              │              │
              ▼              ▼
         ┌──────────┐   ┌───────────┐
         │ LOGGED   │   │ SUSPENDED │
         │ IN       │   └───────────┘
         └──────────┘
```

---

## Security Flow Diagram

```
                    User Input
                         │
                         ▼
         ┌───────────────────────────┐
         │ Validate Request Format   │
         │ - Email format            │
         │ - Password strength       │
         │ - Required fields         │
         └───────┬─────────────────────┘
                 │
                 ▼
         ┌───────────────────────────┐
         │ Check Email Uniqueness    │
         │ Query users table         │
         └───────┬─────────────────────┘
                 │
         ┌───────┴────────┐
         │ Exists?        │ Not exists?
         ▼                ▼
      Error 409      ┌──────────────┐
      Conflict       │ Hash Password│
                     │ bcrypt       │
                     └───┬──────────┘
                         │
                         ▼
                 ┌──────────────────┐
                 │ Create User      │
                 │ status: PENDING  │
                 │ verified: false  │
                 └───┬──────────────┘
                     │
                     ▼
           ┌───────────────────────┐
           │ Generate Token        │
           │ 1. Random 32 bytes    │
           │ 2. Hash with SHA256   │
           │ 3. 24h expiration     │
           └───┬───────────────────┘
               │
               ├─────────────────┐
               │                 │
         ┌─────▼─────┐   ┌───────▼──────┐
         │ Email DB  │   │ Send Email   │
         │ (hashed)  │   │ (plain token)│
         └───────────┘   └────┬────────┘
                              │
                      ┌───────┴────────┐
                      │                │
                   Success         Failure
                      │                │
                      ▼                ▼
                  Return 201      Rollback User
                  { message,      Return 400
                    user }        Error
                      │                │
                      ▼                ▼
                 User Receives    Registration
                 Email with       Failed
                 Verification
                 Link
```

---

## Timeline Diagram

```
Time: 0s
├─ User registers
│  ├─ Account created (PENDING)
│  ├─ Verification token generated (24h expiration)
│  ├─ Token sent via email
│  └─ Response: 201 Created

Time: 1-24 hours
├─ User receives and clicks email link
│  ├─ POST /api/auth/verify-email
│  ├─ Token validated (not expired, not used)
│  ├─ User status changed to ACTIVE
│  ├─ emailVerified set to true
│  ├─ Token marked as used
│  └─ Response: 200 OK

Time: 24+ hours
├─ Token expires automatically
│  ├─ User cannot verify with old token
│  ├─ Must use /resend-verification-email
│  └─ New token generated with new 24h window

Alternative Path (Token Resend):
├─ User doesn't receive email
│  ├─ POST /resend-verification-email
│  ├─ Previous tokens invalidated
│  ├─ New token generated
│  ├─ New email sent
│  └─ Process repeats from Time: 1-24 hours
```

---

## Error Flow Diagram

```
                 Request to API
                      │
                      ▼
        ┌─────────────────────────┐
        │ Route to Endpoint       │
        └────┬────────────────────┘
             │
    ┌────────┴────────┬────────────┐
    │                 │            │
    ▼                 ▼            ▼
 register         login        verify-email
    │                │            │
    └─────┬──────────┴────────┬────┘
          │ Input Validation  │
          │ (class-validator) │
          └────┬──────────────┘
               │
        ┌──────┴──────┐
        │ Valid?      │ Invalid
        ▼             ▼
    Proceed       ┌────────────┐
        │         │ 400 Error  │
        │         │ Bad Request│
        │         └────────────┘
        │
        ▼
   ┌──────────────────┐
   │ Business Logic   │
   │ Processing       │
   └────┬─────────────┘
        │
   ┌────┴───────┬──────────┬──────────┐
   │            │          │          │
   ▼            ▼          ▼          ▼
Success      409       400/401    500/Other
  │         Conflict   Bad/Auth    Server Error
  │         Email      Expired     System
  │         Exists     Token       Issues
  │
  ▼
Return Response
with Status Code
```

---

**These diagrams provide a complete visual overview of the email verification system's architecture, flows, and processes!**
