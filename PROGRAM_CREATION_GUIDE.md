# Program Creation - Correct Format

## ❌ WRONG Format (What you tried)
```json
{
  "name": "Electro_3",
  "code": "EE41",
  "degree_type": "master",
  "departmentId": 1
}
```

**Errors:**
- `degree_type` should be `degreeType` (camelCase, not snake_case)
- Missing required field: `durationYears`
- `degree_type` is not valid, must be `degreeType`

---

## ✅ CORRECT Format
```json
{
  "name": "Electro_3",
  "code": "EE41",
  "degreeType": "master",
  "durationYears": 2,
  "departmentId": 1,
  "description": "Master's program in Electrical Engineering",
  "status": "active"
}
```

---

## Required Fields

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `name` | string | Program name (1-100 chars) | "Electro_3" |
| `code` | string | Program code (2-20 uppercase alphanumeric) | "EE41" |
| `degreeType` | enum | Type of degree | "master" |
| `durationYears` | number | Program duration (1-10 years) | 2 |
| `departmentId` | number | Department ID | 1 |

---

## Optional Fields

| Field | Type | Default | Example |
|-------|------|---------|---------|
| `description` | string | null | "Master's program in..." |
| `status` | enum | "active" | "active" or "inactive" |

---

## Valid Degree Types

- `bachelor` - Bachelor's degree (typically 4 years)
- `master` - Master's degree (typically 2 years)
- `phd` - PhD/Doctorate (typically 3-5 years)
- `diploma` - Diploma (typically 2-3 years)
- `certificate` - Certificate (typically 1 year)

---

## Valid Durations

- Minimum: 1 year
- Maximum: 10 years
- Must be a positive integer

---

## Complete Examples

### Example 1: Bachelor's Degree
```json
{
  "name": "B.S. Computer Science",
  "code": "BSCS",
  "degreeType": "bachelor",
  "durationYears": 4,
  "departmentId": 1,
  "description": "Bachelor of Science in Computer Science"
}
```

### Example 2: Master's Degree
```json
{
  "name": "M.S. Electrical Engineering",
  "code": "MSEE",
  "degreeType": "master",
  "durationYears": 2,
  "departmentId": 1,
  "description": "Master of Science in Electrical Engineering"
}
```

### Example 3: PhD Program
```json
{
  "name": "Ph.D. Computer Science",
  "code": "PHD_CS",
  "degreeType": "phd",
  "durationYears": 5,
  "departmentId": 1,
  "description": "Doctoral program in Computer Science"
}
```

### Example 4: Certificate Program
```json
{
  "name": "Professional Certificate",
  "code": "CERT001",
  "degreeType": "certificate",
  "durationYears": 1,
  "departmentId": 1
}
```

### Example 5: Diploma Program
```json
{
  "name": "IT Diploma",
  "code": "DIP_IT",
  "degreeType": "diploma",
  "durationYears": 2,
  "departmentId": 2,
  "description": "Information Technology Diploma"
}
```

---

## POSTMAN Request Template

### Create Program (with all fields)
```
POST /api/programs
Authorization: Bearer YOUR_JWT_TOKEN
Content-Type: application/json

{
  "name": "Electro_3",
  "code": "EE41",
  "degreeType": "master",
  "durationYears": 2,
  "departmentId": 1,
  "description": "Master's program in Electrical Engineering",
  "status": "active"
}
```

### Create Program (minimal)
```
POST /api/programs
Authorization: Bearer YOUR_JWT_TOKEN
Content-Type: application/json

{
  "name": "Electro_3",
  "code": "EE41",
  "degreeType": "master",
  "durationYears": 2,
  "departmentId": 1
}
```

---

## Expected Response (201 Created)

```json
{
  "id": 5,
  "name": "Electro_3",
  "code": "EE41",
  "degreeType": "master",
  "durationYears": 2,
  "departmentId": 1,
  "description": "Master's program in Electrical Engineering",
  "status": "active",
  "createdAt": "2025-01-26T18:38:47.000Z",
  "updatedAt": "2025-01-26T18:38:47.000Z"
}
```

---

## Error Handling

### Error: degree_type should not exist
**Cause:** Using `degree_type` instead of `degreeType`
**Fix:** Change to camelCase: `"degreeType": "master"`

### Error: durationYears is required
**Cause:** Missing `durationYears` field
**Fix:** Add it: `"durationYears": 2`

### Error: durationYears must be between 1 and 10
**Cause:** Invalid duration value
**Fix:** Use value between 1-10: `"durationYears": 4`

### Error: Code must be 2-20 uppercase alphanumeric
**Cause:** Invalid code format
**Fix:** Use uppercase letters and numbers only: `"code": "EE41"`

### Error: degreeType must be one of...
**Cause:** Invalid degree type
**Fix:** Use one of: bachelor, master, phd, diploma, certificate

---

## Complete Flow Example

```bash
# Step 1: Create Campus
curl -X POST http://localhost:3000/api/campuses \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Engineering Campus",
    "code": "ENG"
  }'
# Returns: campus id = 1

# Step 2: Create Department
curl -X POST http://localhost:3000/api/departments \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Electrical Engineering",
    "code": "EE",
    "campusId": 1
  }'
# Returns: department id = 1

# Step 3: Create Program
curl -X POST http://localhost:3000/api/programs \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Electro_3",
    "code": "EE41",
    "degreeType": "master",
    "durationYears": 2,
    "departmentId": 1,
    "description": "Master program in Electrical Engineering"
  }'
# Returns: Success! Program created
```

---

## Summary

✅ Always use `degreeType` (camelCase)
✅ Always include `durationYears` (1-10)
✅ Code must be 2-20 uppercase alphanumeric
✅ Department ID must exist
✅ Valid degree types: bachelor, master, phd, diploma, certificate
