# System Administrator / IT Role Endpoints Documentation

This document outlines all system administration and IT role endpoints available in the EduVerse backend. These endpoints are crucial for building the Settings and System Management sections of the Flutter frontend app.

## General Information

- **Base URL:** `https://api.eduverse.com` (replace with your environment's base URL)
- **Authentication:** All requests (unless specified) require a JWT Bearer token in the `Authorization` header.
- **Roles Required:** Generally, `ADMIN` or `IT_ADMIN` roles are required. Some destructive operations require strictly `IT_ADMIN`.
- **Response Format:** All successful responses return JSON. Error responses follow a standard shape:
  ```json
  {
    "statusCode": 400,
    "message": "Validation failed / Error description",
    "error": "Bad Request"
  }
  ```

---

## 1. Settings (`/api/settings`)

These endpoints manange global system settings, custom branding, and dynamic rate limiting limits.

### 1.1 Get Branding Settings
- **Endpoint:** `GET /api/settings/branding`
- **Auth Required:** No (Public endpoint)
- **Roles:** None
- **Query Parameters:**
  - `campusId` (optional, integer): Get branding for a specific campus.
- **Response:**
  ```json
  {
    "id": 1,
    "campusId": null,
    "primaryColor": "#1976D2",
    "secondaryColor": "#FFC107",
    "logoUrl": "https://...",
    "faviconUrl": "https://...",
    "customCss": null,
    "updatedAt": "2026-04-06T10:00:00Z"
  }
  ```

### 1.2 Update Branding Settings
- **Endpoint:** `PUT /api/settings/branding/:campusId`
- **Roles:** `ADMIN`, `IT_ADMIN`
- **Path Parameters:**
  - `campusId` (required, integer): ID of the campus to update.
- **Request Body (`UpdateBrandingDto`):**
  ```json
  {
    "primaryColor": "#ff0000",
    "secondaryColor": "#00ff00",
    "logoUrl": "https://...",
    "faviconUrl": "https://...",
    "customCss": "body { margin: 0; }"
  }
  ```

### 1.3 Get API Rate Limits
- **Endpoint:** `GET /api/settings/rate-limits`
- **Roles:** `IT_ADMIN`
- **Response:** List of rate limit configuration objects.
  ```json
  [
    {
      "id": 1,
      "endpoint": "/api/users",
      "maxRequests": 100,
      "windowMs": 60000,
      "description": "General user queries limit"
    }
  ]
  ```

### 1.4 Update API Rate Limits
- **Endpoint:** `PUT /api/settings/rate-limits/:id`
- **Roles:** `IT_ADMIN`
- **Path Parameters:**
  - `id` (required, integer): ID of the rate limit to update.
- **Request Body (`UpdateRateLimitsDto`):**
  ```json
  {
    "maxRequests": 150,
    "windowMs": 60000,
    "description": "Updated limit"
  }
  ```

### 1.5 Get All Universal Settings
- **Endpoint:** `GET /api/settings`
- **Roles:** `ADMIN`, `IT_ADMIN`
- **Response:**
  ```json
  [
    {
      "key": "ALLOW_REGISTRATION",
      "value": "true",
      "description": "Is student registration currently permitted?",
      "updatedAt": "2026-04-06T10:00:00Z"
    }
  ]
  ```

### 1.6 Update Multiple Settings (Batch)
- **Endpoint:** `PUT /api/settings`
- **Roles:** `ADMIN`, `IT_ADMIN`
- **Request Body (`UpdateSettingsDto`):**
  ```json
  {
    "settings": [
      { "key": "ALLOW_REGISTRATION", "value": "false" },
      { "key": "MAINTENANCE_MODE", "value": "true" }
    ]
  }
  ```

---

## 2. Integrations (`/api/integrations` & `/google-drive`)

Used for setting up third-party tools like Google Drive, payment gateways, or LMS bridges.

### 2.1 List All API Integrations
- **Endpoint:** `GET /api/integrations`
- **Roles:** `IT_ADMIN`
- **Response:**
  ```json
  [
    {
      "id": 1,
      "provider": "google-drive",
      "status": "connected",
      "lastSync": "2026-04-05T08:00:00Z"
    }
  ]
  ```

### 2.2 Create / Setup an Integration
- **Endpoint:** `POST /api/integrations`
- **Roles:** `IT_ADMIN`
- **Request Body (`CreateIntegrationDto`):**
  ```json
  {
    "provider": "google-drive",
    "credentials": {
      "clientId": "...",
      "clientSecret": "..."
    }
  }
  ```

### Google Drive Specific Operations
- **Init Tree:** `POST /google-drive/admin/init` - Initializes the base system storage folder tree in the connected Google Drive.
- **Get Storage Hierarchy:** `GET /google-drive/admin/tree` - Returns the nested folder hierarchy mapped from Drive.

---

## 3. Backups (`/api/backups`)

Handles database SQL dumps and restorations.

### 3.1 List All Backups
- **Endpoint:** `GET /api/backups`
- **Roles:** `ADMIN`, `IT_ADMIN`
- **Response:**
  ```json
  [
    {
      "id": 1,
      "filename": "backup_2026-03-16T22-04-58-526Z.sql",
      "sizeBytes": 1048576,
      "status": "completed",
      "createdAt": "2026-03-16T22:04:58Z"
    }
  ]
  ```

### 3.2 Create Backup
- **Endpoint:** `POST /api/backups`
- **Roles:** `IT_ADMIN`
- **Response (201 Created):**
  ```json
  {
    "message": "Backup created successfully",
    "id": 2,
    "filename": "backup_current_date.sql"
  }
  ```

### 3.3 Get Backup Details
- **Endpoint:** `GET /api/backups/:id`
- **Roles:** `ADMIN`, `IT_ADMIN`
- **Path Parameters:** `id` (integer)

### 3.4 Delete Backup
- **Endpoint:** `DELETE /api/backups/:id`
- **Roles:** `IT_ADMIN`
- **Path Parameters:** `id` (integer)

---

## 4. Database (`/api/database`)

Endpoints to monitor raw database metrics and trigger maintenance.

### 4.1 Database Status
- **Endpoint:** `GET /api/database/status`
- **Roles:** `IT_ADMIN`
- **Response:**
  ```json
  {
    "status": "healthy",
    "version": "PostgreSQL 14.2",
    "uptime": "2 days 14 hours"
  }
  ```

### 4.2 Database Tables Info
- **Endpoint:** `GET /api/database/tables`
- **Roles:** `IT_ADMIN`
- **Response:** Array of table sizes and row estimates.

### 4.3 Optimize Database
- **Endpoint:** `POST /api/database/optimize`
- **Roles:** `IT_ADMIN`
- **Description:** Triggers a cleanup task (`VACUUM` / defragmentation).

---

## 5. System Alerts (`/api/alerts`)

Manage automated triggers (e.g., CPU high, storage full) that notify IT admins.

### 5.1 List Alert Rules
- **Endpoint:** `GET /api/alerts`
- **Roles:** `ADMIN`, `IT_ADMIN`
- **Response:**
  ```json
  [
    {
      "id": 1,
      "name": "High CPU Usage",
      "description": "Alerts when CPU is > 90%",
      "condition": "cpu_utilization",
      "threshold": 90,
      "isActive": true
    }
  ]
  ```

### 5.2 Create Alert Rule
- **Endpoint:** `POST /api/alerts`
- **Roles:** `IT_ADMIN`
- **Request Body (`CreateAlertDto`):**
  ```json
  {
    "name": "Storage Warning",
    "description": "Disk space low",
    "condition": "disk_space",
    "threshold": 85,
    "isActive": true
  }
  ```

### 5.3 Update Alert Rule
- **Endpoint:** `PATCH /api/alerts/:id`
- **Roles:** `IT_ADMIN`
- **Path Parameters:** `id` (integer)
- **Request Body (`UpdateAlertDto`):** Partial versions of the create shape.

### 5.4 Delete Alert Rule
- **Endpoint:** `DELETE /api/alerts/:id`
- **Roles:** `IT_ADMIN`

---

## 6. SSL Certificates (`/api/ssl`)

Monitor the lifecycle of system TLS/SSL certificates to prevent unexpected expiration.

### 6.1 List Certificates
- **Endpoint:** `GET /api/ssl`
- **Roles:** `IT_ADMIN`

### 6.2 Get Expiring Certificates
- **Endpoint:** `GET /api/ssl/expiring`
- **Roles:** `IT_ADMIN`
- **Response:** Returns only certificates expiring in less than 30 days.

### 6.3 Certificate Details
- **Endpoint:** `GET /api/ssl/:id`
- **Roles:** `IT_ADMIN`
- **Path Parameters:** `id` (string/integer)

---

## 7. System Errors (`/api/errors`)

Access logs of internal server exceptions.

### 7.1 List / Search System Errors
- **Endpoint:** `GET /api/errors`
- **Roles:** `IT_ADMIN`
- **Query Parameters (`ErrorQueryDto`):**
  - `page` (optional)
  - `limit` (optional)
  - `severity` (optional)
  - `startDate` (optional)
  - `endDate` (optional)

### 7.2 System Error Statistics
- **Endpoint:** `GET /api/errors/stats`
- **Roles:** `IT_ADMIN`
- **Response:** Aggregation data (e.g. counts per severity, most common exception type).

### 7.3 Get Specific Error Log
- **Endpoint:** `GET /api/errors/:id`
- **Roles:** `IT_ADMIN`

### 7.4 Resolve Error Log
- **Endpoint:** `PATCH /api/errors/:id`
- **Roles:** `IT_ADMIN`
- **Request Body (`UpdateErrorDto`):**
  ```json
  {
    "status": "resolved",
    "notes": "Fixed in patch v1.0.4"
  }
  ```

---
*Generated for the Flutter Development Team*