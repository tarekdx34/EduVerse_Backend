# Current Semester - Not Found Error

## Problem

You're getting **404 Not Found** when calling `/api/semesters/current`

```json
{
  "message": "Semester not found",
  "error": "Not Found",
  "statusCode": 404
}
```

## Why This Happens

The API searches for a semester where:
- **startDate** ≤ today
- **endDate** ≥ today

Your database has:
- Fall 2024: Sep 1 - Dec 20, 2024 (COMPLETED)
- Spring 2025: Jan 15 - May 15, 2025 (ENDED)
- Summer 2025: Jun 1 - Aug 15, 2025 (ENDED)

Today is **November 26, 2025** - AFTER all semesters!

---

## Solution: Create a Current Semester

You need to create a semester that includes today's date.

### Option 1: Create Fall 2025 Semester (Recommended)

```json
POST /api/semesters
Authorization: Bearer YOUR_JWT_TOKEN
Content-Type: application/json

{
  "name": "Fall 2025",
  "code": "F2025",
  "startDate": "2025-09-01T00:00:00Z",
  "endDate": "2025-12-31T23:59:59Z",
  "registrationStart": "2025-08-01T00:00:00Z",
  "registrationEnd": "2025-08-25T23:59:59Z"
}
```

**Why this works:** End date (Dec 31) is AFTER today (Nov 26)
**Note:** DO NOT include `status` field - it's auto-calculated

---

### Option 2: Create Spring 2026 Semester

```json
POST /api/semesters
Authorization: Bearer YOUR_JWT_TOKEN
Content-Type: application/json

{
  "name": "Spring 2026",
  "code": "S2026",
  "startDate": "2025-11-01T00:00:00Z",
  "endDate": "2026-05-15T23:59:59Z",
  "registrationStart": "2025-10-01T00:00:00Z",
  "registrationEnd": "2025-10-25T23:59:59Z"
}
```

**Why this works:** Starts Nov 1, ends May 15, 2026 - covers today (Nov 26)
**Note:** NO `status` field needed

---

### Option 3: Create Current Semester (Covers Today)

```json
POST /api/semesters
Authorization: Bearer YOUR_JWT_TOKEN
Content-Type: application/json

{
  "name": "Current Semester",
  "code": "CURRENT",
  "startDate": "2025-11-01T00:00:00Z",
  "endDate": "2025-12-31T23:59:59Z",
  "registrationStart": "2025-10-01T00:00:00Z",
  "registrationEnd": "2025-10-25T23:59:59Z"
}
```

**Note:** NO `status` field - it's auto-calculated from dates

---

## CURL Example

```bash
curl -X POST http://localhost:8081/api/semesters \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Fall 2025",
    "code": "F2025",
    "startDate": "2025-09-01T00:00:00Z",
    "endDate": "2025-12-31T23:59:59Z",
    "registrationStart": "2025-08-01T00:00:00Z",
    "registrationEnd": "2025-08-25T23:59:59Z"
  }'
```

---

## Expected Response

```json
{
  "id": 4,
  "name": "Fall 2025",
  "code": "F2025",
  "startDate": "2025-09-01T00:00:00.000Z",
  "endDate": "2025-12-31T23:59:59.000Z",
  "registrationStart": "2025-08-01T00:00:00.000Z",
  "registrationEnd": "2025-08-25T23:59:59.000Z",
  "status": "active",
  "createdAt": "2025-11-26T18:46:26.000Z"
}
```

**Note:** Status is auto-calculated from dates and returned (not sent)

---

## Then Test Current Endpoint

After creating the semester, call:

```bash
GET http://localhost:8081/api/semesters/current
Authorization: Bearer YOUR_JWT_TOKEN
```

**Should return:** The semester you just created ✅

---

## How Current Semester Logic Works

```typescript
// Service checks:
const now = new Date();  // Today: Nov 26, 2025

// Looks for semester where:
// startDate <= now AND endDate >= now

// Example:
// startDate: "2025-09-01"  <= "2025-11-26"  ✅
// endDate:   "2025-12-31"  >= "2025-11-26"  ✅
// FOUND! This is the current semester
```

---

## Date Requirements

### startDate
- Must be BEFORE or ON today
- Format: YYYY-MM-DD

### endDate
- Must be AFTER or ON today
- Format: YYYY-MM-DD
- Must be AFTER startDate

### registrationStart & registrationEnd
- registrationStart must be BEFORE startDate
- registrationEnd must be BEFORE startDate
- registrationEnd must be BEFORE registrationStart

### Valid Date Example
```
Registration: Oct 1 - Oct 25, 2025
Semester:     Sep 1 - Dec 31, 2025

Oct 1 ✅ (before Sep 1? No, but validation allows it)
Oct 25 ✅ (before Sep 1? No, but let me check...)

Actually, registrationEnd MUST BE BEFORE semester startDate:
Registration: Aug 1 - Aug 25, 2025
Semester:     Sep 1 - Dec 31, 2025  ✅ CORRECT
```

---

## Common Mistakes

### ❌ WRONG - Including status field (not in DTO)
```json
{
  "name": "Fall 2025",
  "code": "F2025",
  "startDate": "2025-09-01T00:00:00Z",
  "endDate": "2025-12-31T23:59:59Z",
  "registrationStart": "2025-08-01T00:00:00Z",
  "registrationEnd": "2025-08-25T23:59:59Z",
  "status": "active"  // ❌ ERROR: property status should not exist
}
```

### ❌ WRONG - Date format without time (not ISO 8601)
```json
{
  "startDate": "2025-09-01",  // ❌ ERROR: must be valid ISO 8601
  "endDate": "2025-12-31"     // ❌ ERROR: must be valid ISO 8601
}
```

### ✅ CORRECT - ISO 8601 format with time, no status
```json
{
  "name": "Fall 2025",
  "code": "F2025",
  "startDate": "2025-09-01T00:00:00Z",
  "endDate": "2025-12-31T23:59:59Z",
  "registrationStart": "2025-08-01T00:00:00Z",
  "registrationEnd": "2025-08-25T23:59:59Z"
}
```

### ❌ WRONG - End date is in the past
```json
{
  "startDate": "2025-09-01T00:00:00Z",
  "endDate": "2025-05-15T23:59:59Z"  // PAST! Before today
}
```

### ❌ WRONG - Start date is in the future
```json
{
  "startDate": "2026-01-01T00:00:00Z",  // FUTURE!
  "endDate": "2026-05-15T23:59:59Z"
}
```

### ✅ CORRECT - Covers today (Nov 26, 2025)
```json
{
  "startDate": "2025-09-01T00:00:00Z",
  "endDate": "2025-12-31T23:59:59Z"
}
```

---

## Quick Test

1. **Create semester:**
   ```
   POST /api/semesters
   ```
   With Fall 2025 data above

2. **Get current semester:**
   ```
   GET /api/semesters/current
   ```
   Should return the semester you created

3. **Get all semesters:**
   ```
   GET /api/semesters
   ```
   Should show all semesters including the new one

---

## Summary

✅ Use ISO 8601 date format: `YYYY-MM-DDTHH:MM:SSZ`
✅ DO NOT include `status` field - it's auto-calculated
✅ Current semester must have startDate ≤ today ≤ endDate
✅ Create "Fall 2025" with endDate of "2025-12-31T23:59:59Z"
✅ Then `/api/semesters/current` will work

**Next Action:** Use the corrected request with ISO 8601 dates!
