# EduVerse Sprint Workflow Template

> **Reference document for implementing any new feature or sprint in the EduVerse NestJS backend.**
> Follow these 7 phases in order. Each phase includes checklists, conventions, and deliverables.

---

## Table of Contents

- [Project Context](#project-context)
- [Phase 1: Planning & Requirements](#phase-1-planning--requirements)
- [Phase 2: Database Schema](#phase-2-database-schema)
- [Phase 3: Entities & DTOs](#phase-3-entities--dtos)
- [Phase 4: Services & Controllers](#phase-4-services--controllers)
- [Phase 5: Testing](#phase-5-testing)
- [Phase 6: Documentation](#phase-6-documentation)
- [Phase 7: Commit & Cleanup](#phase-7-commit--cleanup)
- [Mandatory Deliverables](#mandatory-deliverables)
- [Conventions & Quick Reference](#conventions--quick-reference)

---

## Project Context

| Setting              | Value                                                        |
| -------------------- | ------------------------------------------------------------ |
| Framework            | NestJS + TypeORM                                             |
| Database             | MySQL / MariaDB (`eduverse_db`)                              |
| DB Port              | `3306`                                                       |
| DB User              | `root` (empty password)                                      |
| Server Port          | `8081`                                                       |
| TypeORM `synchronize`| `false` — **all schema changes require manual SQL**          |
| Auth                 | JWT via `POST /api/auth/login` → `{ accessToken }`           |
| Login Body           | `{ "email": "...", "password": "...", "rememberMe": true }`  |
| Test Password        | `SecureP@ss123` (all test accounts)                          |
| Test Emails          | `*.tarek@example.com`                                        |
| User PK              | `userId` property → `user_id` column (**not** `id`)          |
| Roles                | `student`, `instructor`, `teaching_assistant`, `admin`, `it_admin`, `department_head` |

### Tool Access

| Tool            | Capability  | Notes                                                                 |
| --------------- | ----------- | --------------------------------------------------------------------- |
| MySQL MCP tool  | **READ-ONLY** | Use for `SELECT` verification queries only                          |
| mysqlsh CLI     | Full DDL/DML | Execute `CREATE`, `ALTER`, `INSERT`, `UPDATE`, `DELETE` via CLI     |

**mysqlsh invocation:**

```powershell
& "C:\Program Files\MySQL\MySQL Shell 9.5\bin\mysqlsh.exe" --sql -h localhost -u root --password="" -P 3306 --database=eduverse_db
```

---

## Phase 1: Planning & Requirements

> **Goal:** Fully understand the feature before writing any code.

### Checklist

- [ ] Gather requirements from the user (ask clarifying questions)
- [ ] Write numbered **user stories** in role–action–benefit format:
  ```
  US-01: As a [role], I want to [action] so that [benefit].
  US-02: ...
  ```
- [ ] Design the **API endpoints table**:
  | # | Method | Path | Auth | Roles | Description |
  |---|--------|------|------|-------|-------------|
  | 1 | GET    | `/api/feature` | JWT | admin | List all items |
  | 2 | POST   | `/api/feature` | JWT | admin | Create item |
- [ ] Identify **affected modules** and existing files
- [ ] Document **dependencies** on other modules (imports, relations, shared services)
- [ ] Map out the **entity relationships** (which tables reference which)
- [ ] **Get user approval** before proceeding to Phase 2

### Tips

- Check existing modules for similar patterns: `src/modules/` directory
- Review `FRONTEND_DASHBOARD_GUIDE.md` for frontend expectations
- If the feature touches enrollments, review: `course_enrollments → course_sections → courses → departments`

---

## Phase 2: Database Schema

> **Goal:** Create all database objects and seed data via SQL scripts.

### Checklist

- [ ] Write `CREATE TABLE` statements with proper constraints, indexes, and foreign keys
- [ ] Write `ALTER TABLE` statements if modifying existing tables
- [ ] Write `INSERT` statements for seed/mock data
- [ ] Write `DROP` / rollback statements (commented out, for emergencies)
- [ ] Execute DDL via **mysqlsh CLI** (not the read-only MCP tool):
  ```powershell
  & "C:\Program Files\MySQL\MySQL Shell 9.5\bin\mysqlsh.exe" --sql -h localhost -u root --password="" -P 3306 --database=eduverse_db -e "SOURCE D:/path/to/script.sql"
  ```
- [ ] Verify tables and data with `SELECT` queries via the MySQL MCP tool
- [ ] Save the complete script as **`DB_CHANGES_<FEATURE>.sql`**

### SQL File Template

```sql
-- ============================================================
-- DB_CHANGES_<FEATURE>.sql
-- Feature: <Feature Name>
-- Date: YYYY-MM-DD
-- Description: <Brief description>
-- ============================================================

-- =========================
-- 1. DDL — Table Creation
-- =========================

CREATE TABLE IF NOT EXISTS `table_name` (
    `id`          INT AUTO_INCREMENT PRIMARY KEY,
    `name`        VARCHAR(255) NOT NULL,
    `user_id`     INT NOT NULL,
    `created_at`  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at`  TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT `fk_table_user` FOREIGN KEY (`user_id`)
        REFERENCES `users`(`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================
-- 2. Indexes
-- =========================

CREATE INDEX `idx_table_user` ON `table_name`(`user_id`);

-- =========================
-- 3. Seed / Mock Data
-- =========================

INSERT INTO `table_name` (`name`, `user_id`) VALUES
('Sample Item', 1);

-- =========================
-- 4. Verification Queries
-- =========================

-- SELECT * FROM `table_name` LIMIT 10;
-- DESCRIBE `table_name`;

-- =========================
-- 5. Rollback (use with caution)
-- =========================

-- DROP TABLE IF EXISTS `table_name`;
```

### Key Rules

- **Never** rely on TypeORM `synchronize` — it is disabled (`false`)
- Always use `utf8mb4` charset for Unicode support
- Foreign keys referencing `users` must target `user_id`, not `id`
- Use `TIMESTAMP` with defaults for `created_at` / `updated_at`
- Use `ON DELETE CASCADE` or `ON DELETE SET NULL` as appropriate

---

## Phase 3: Entities & DTOs

> **Goal:** Create TypeORM entities and validated DTOs that map to the database schema.

### Checklist

- [ ] Create entity file: `src/modules/<module>/entities/<name>.entity.ts`
- [ ] Create DTOs:
  - `src/modules/<module>/dto/create-<name>.dto.ts`
  - `src/modules/<module>/dto/update-<name>.dto.ts`
  - `src/modules/<module>/dto/<name>-query.dto.ts` (for pagination/filtering)
- [ ] Export from barrel files (`index.ts`) in both `entities/` and `dto/` directories
- [ ] Verify column names match the database exactly (use `@Column({ name: 'db_column' })`)
- [ ] Add class-validator decorators to all DTO properties

### Entity Template

```typescript
import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';

@Entity('table_name')
export class FeatureItem {
  @PrimaryGeneratedColumn({ name: 'id' })
  id: number;

  @Column({ name: 'name', length: 255 })
  name: string;

  @Column({ name: 'user_id' })
  userId: number;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'user_id' })
  user: User;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;
}
```

### DTO Template

```typescript
import { IsString, IsNotEmpty, IsOptional, IsInt, Min } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';

export class CreateFeatureItemDto {
  @ApiProperty({ description: 'Name of the item' })
  @IsString()
  @IsNotEmpty()
  name: string;
}

export class UpdateFeatureItemDto {
  @ApiPropertyOptional({ description: 'Updated name' })
  @IsString()
  @IsOptional()
  name?: string;
}

export class FeatureItemQueryDto {
  @ApiPropertyOptional({ default: 1 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page?: number = 1;

  @ApiPropertyOptional({ default: 10 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  limit?: number = 10;
}
```

### Key Rules

- Entity property names use **camelCase**; column names use **snake_case**
- Always specify `{ name: 'column_name' }` in `@Column` to be explicit
- The User entity's PK is `userId` (column: `user_id`) — join on this, not `id`
- Use `@CreateDateColumn` and `@UpdateDateColumn` for timestamps
- All DTOs must use `class-validator` decorators for validation
- All DTOs must use `@ApiProperty` / `@ApiPropertyOptional` for Swagger

---

## Phase 4: Services & Controllers

> **Goal:** Implement business logic and REST endpoints with proper auth guards.

### Checklist

- [ ] Create service: `src/modules/<module>/services/<name>.service.ts`
- [ ] Create controller: `src/modules/<module>/controllers/<name>.controller.ts`
- [ ] Register in module file (`<module>.module.ts`):
  - Add entity to `TypeOrmModule.forFeature([...])`
  - Add controller to `controllers: [...]`
  - Add service to `providers: [...]`
  - Add service to `exports: [...]` if needed by other modules
- [ ] Export from barrel files (`index.ts`)
- [ ] Apply auth guards and role decorators
- [ ] Implement pagination for all list endpoints

### Controller Template

```typescript
import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  Query,
  UseGuards,
  Request,
  ParseIntPipe,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../auth/guards/roles.guard';
import { Roles } from '../../auth/decorators/roles.decorator';

@ApiTags('Feature')
@ApiBearerAuth()
@Controller('feature')
@UseGuards(JwtAuthGuard, RolesGuard)
export class FeatureController {
  constructor(private readonly featureService: FeatureService) {}

  // ⚠️ CRITICAL: Static routes MUST come BEFORE :id param routes
  @Get('my-items')
  @ApiOperation({ summary: 'Get current user items' })
  @Roles('student', 'instructor')
  getMyItems(@Request() req) {
    return this.featureService.getByUser(req.user.userId);
  }

  @Get('stats')
  @ApiOperation({ summary: 'Get feature statistics' })
  @Roles('admin')
  getStats() {
    return this.featureService.getStats();
  }

  // Parameterized routes AFTER static routes
  @Get(':id')
  @ApiOperation({ summary: 'Get item by ID' })
  getById(@Param('id', ParseIntPipe) id: number) {
    return this.featureService.findById(id);
  }

  @Get()
  @ApiOperation({ summary: 'List all items' })
  findAll(@Query() query: FeatureItemQueryDto) {
    return this.featureService.findAll(query);
  }

  @Post()
  @ApiOperation({ summary: 'Create item' })
  @Roles('admin', 'instructor')
  create(@Body() dto: CreateFeatureItemDto, @Request() req) {
    return this.featureService.create(dto, req.user.userId);
  }

  @Put(':id')
  @ApiOperation({ summary: 'Update item' })
  @Roles('admin', 'instructor')
  update(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateFeatureItemDto,
  ) {
    return this.featureService.update(id, dto);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete item' })
  @Roles('admin')
  delete(@Param('id', ParseIntPipe) id: number) {
    return this.featureService.delete(id);
  }
}
```

### Service Pagination Pattern

```typescript
async findAll(query: FeatureItemQueryDto) {
  const { page = 1, limit = 10 } = query;
  const [data, total] = await this.repo.findAndCount({
    skip: (page - 1) * limit,
    take: limit,
    order: { createdAt: 'DESC' },
  });

  return {
    data,
    meta: {
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    },
  };
}
```

### Key Rules

- **Static routes BEFORE parameterized routes** — NestJS matches top-down; `/stats` must come before `/:id` or it will be treated as an ID
- Use `@UseGuards(JwtAuthGuard, RolesGuard)` at the controller or method level
- Use `@Roles('admin', 'instructor')` to restrict by role
- Access the authenticated user via `@Request() req` → `req.user.userId`
- All list endpoints must return `{ data: [], meta: { total, page, limit, totalPages } }`
- Use `ParseIntPipe` for numeric route parameters

---

## Phase 5: Testing

> **Goal:** Verify everything works end-to-end with real HTTP requests.

### Checklist

- [ ] Run `npm run build` — fix any compilation errors
- [ ] Start the server: `node dist/main.js`
- [ ] Obtain auth tokens for test users:
  ```powershell
  $loginBody = @{ email = "admin.tarek@example.com"; password = "SecureP@ss123"; rememberMe = $true } | ConvertTo-Json
  $response = Invoke-RestMethod -Uri "http://localhost:8081/api/auth/login" -Method POST -Body $loginBody -ContentType "application/json"
  $token = $response.accessToken
  $headers = @{ Authorization = "Bearer $token" }
  ```
- [ ] Test **each endpoint** individually:
  ```powershell
  # GET list
  Invoke-RestMethod -Uri "http://localhost:8081/api/feature?page=1&limit=5" -Headers $headers

  # POST create
  $body = @{ name = "Test Item" } | ConvertTo-Json
  Invoke-RestMethod -Uri "http://localhost:8081/api/feature" -Method POST -Body $body -ContentType "application/json" -Headers $headers

  # GET by ID
  Invoke-RestMethod -Uri "http://localhost:8081/api/feature/1" -Headers $headers

  # PUT update
  $updateBody = @{ name = "Updated Item" } | ConvertTo-Json
  Invoke-RestMethod -Uri "http://localhost:8081/api/feature/1" -Method PUT -Body $updateBody -ContentType "application/json" -Headers $headers

  # DELETE
  Invoke-RestMethod -Uri "http://localhost:8081/api/feature/1" -Method DELETE -Headers $headers
  ```
- [ ] Test with **multiple roles** (student, instructor, admin)
- [ ] Verify **access control**:
  - Unauthorized users → `401 Unauthorized`
  - Wrong role → `403 Forbidden`
- [ ] Test **edge cases**:
  - Empty data sets (page with no results)
  - Invalid IDs (non-existent, negative, string)
  - Duplicate entries (if uniqueness constraints exist)
  - Missing required fields → validation errors
- [ ] Verify **pagination response format**:
  ```json
  {
    "data": [...],
    "meta": {
      "total": 42,
      "page": 1,
      "limit": 10,
      "totalPages": 5
    }
  }
  ```

### Test Accounts

| Role               | Email                              | Password        |
| ------------------ | ---------------------------------- | --------------- |
| Admin              | `admin.tarek@example.com`          | `SecureP@ss123` |
| Student            | `student.tarek@example.com`        | `SecureP@ss123` |
| Instructor         | `instructor.tarek@example.com`     | `SecureP@ss123` |
| Teaching Assistant | `ta.tarek@example.com`             | `SecureP@ss123` |
| IT Admin           | `itadmin.tarek@example.com`        | `SecureP@ss123` |
| Department Head    | `depthead.tarek@example.com`       | `SecureP@ss123` |

> **Note:** Verify actual test account emails in the database before testing. The pattern above is a convention — actual emails may vary.

---

## Phase 6: Documentation

> **Goal:** Create comprehensive documentation for the feature.

### Checklist

- [ ] Create **`<FEATURE>_SUMMARY.md`** with all sections below
- [ ] Update **`FRONTEND_DASHBOARD_GUIDE.md`** with new endpoint details
- [ ] Update **`EduVerse_Postman_Collection.json`** with new requests
- [ ] Update test HTML files if the feature has a frontend test page

### Feature Summary Template (`<FEATURE>_SUMMARY.md`)

```markdown
# <Feature Name> — Implementation Summary

## Overview
Brief description of the feature and its purpose.

## Architecture

src/modules/<module>/
├── controllers/
│   └── <name>.controller.ts
├── services/
│   └── <name>.service.ts
├── entities/
│   └── <name>.entity.ts
├── dto/
│   ├── create-<name>.dto.ts
│   ├── update-<name>.dto.ts
│   └── <name>-query.dto.ts
├── <module>.module.ts
└── index.ts

## API Endpoints

| # | Method | Path              | Auth | Roles          | Description        |
|---|--------|-------------------|------|----------------|--------------------|
| 1 | GET    | /api/feature      | JWT  | all            | List items         |
| 2 | POST   | /api/feature      | JWT  | admin          | Create item        |
| 3 | GET    | /api/feature/:id  | JWT  | all            | Get item by ID     |
| 4 | PUT    | /api/feature/:id  | JWT  | admin          | Update item        |
| 5 | DELETE | /api/feature/:id  | JWT  | admin          | Delete item        |

## Access Control

| Role        | Permissions                     |
|-------------|---------------------------------|
| admin       | Full CRUD                       |
| instructor  | Read, create own                |
| student     | Read only                       |

## Database Changes
- Created table: `table_name`
- Added columns: (if ALTER TABLE)
- SQL file: `DB_CHANGES_<FEATURE>.sql`

## Files Created / Modified

### Created
- `src/modules/<module>/entities/<name>.entity.ts`
- `src/modules/<module>/dto/create-<name>.dto.ts`
- ...

### Modified
- `src/modules/<module>/<module>.module.ts` — registered entity, controller, service
- ...

## Testing Results
- ✅ GET /api/feature — 200 OK (pagination works)
- ✅ POST /api/feature — 201 Created
- ✅ Access control — 403 for unauthorized roles
- ✅ Validation — 400 for missing required fields
```

---

## Phase 7: Commit & Cleanup

> **Goal:** Clean commit with only relevant files.

### Checklist

- [ ] Review all changed files: `git --no-pager status`
- [ ] Stage only feature-related files:
  ```powershell
  git add src/modules/<module>/
  git add DB_CHANGES_<FEATURE>.sql
  git add <FEATURE>_SUMMARY.md
  ```
- [ ] Write a descriptive commit message using **Conventional Commits**:
  ```
  feat(<module>): add <feature description>

  - Created <module> module with CRUD endpoints
  - Added database schema and seed data
  - Implemented role-based access control
  - Added pagination support

  Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>
  ```
- [ ] Remove any temporary/debug files
- [ ] Verify the build still passes: `npm run build`

### Conventional Commit Prefixes

| Prefix     | Use Case                                |
| ---------- | --------------------------------------- |
| `feat`     | New feature                             |
| `fix`      | Bug fix                                 |
| `docs`     | Documentation only                      |
| `refactor` | Code change that neither fixes nor adds |
| `chore`    | Maintenance, dependencies, config       |
| `test`     | Adding or updating tests                |

---

## Mandatory Deliverables

> **Every feature/sprint MUST produce these two files.**

| # | Deliverable                    | Description                                                        |
|---|--------------------------------|--------------------------------------------------------------------|
| 1 | `DB_CHANGES_<FEATURE>.sql`     | Complete SQL: DDL, indexes, seeds, verification queries, rollback  |
| 2 | `<FEATURE>_SUMMARY.md`         | Architecture, endpoints, access control, testing results, files    |

---

## Conventions & Quick Reference

### Pagination Response Format

All list endpoints **must** return:

```json
{
  "data": [],
  "meta": {
    "total": 0,
    "page": 1,
    "limit": 10,
    "totalPages": 0
  }
}
```

### Naming Conventions

| Item       | Convention                 | Example                        |
| ---------- | -------------------------- | ------------------------------ |
| Entity     | `<Name>.entity.ts`         | `course.entity.ts`             |
| Create DTO | `create-<name>.dto.ts`     | `create-course.dto.ts`         |
| Update DTO | `update-<name>.dto.ts`     | `update-course.dto.ts`         |
| Query DTO  | `<name>-query.dto.ts`      | `course-query.dto.ts`          |
| Service    | `<name>.service.ts`        | `course.service.ts`            |
| Controller | `<name>.controller.ts`     | `course.controller.ts`         |
| Module     | `<name>.module.ts`         | `course.module.ts`             |
| Barrel     | `index.ts`                 | Re-exports all public symbols  |

### Module Registration

```typescript
@Module({
  imports: [
    TypeOrmModule.forFeature([FeatureEntity, OtherEntity]),
    // Other module imports
  ],
  controllers: [FeatureController],
  providers: [FeatureService],
  exports: [FeatureService], // Only if other modules need it
})
export class FeatureModule {}
```

Then register in `app.module.ts`:

```typescript
imports: [
  // ...existing modules
  FeatureModule,
],
```

### Auth & Guards

```typescript
// Import guards and decorators
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../auth/guards/roles.guard';
import { Roles } from '../../auth/decorators/roles.decorator';

// Apply at controller level (all routes) or method level (specific routes)
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles('admin', 'instructor')
```

### Enrollment Access Chain

When checking if a user has access to a course resource, follow this chain:

```
course_enrollments → course_sections → courses → departments
```

A student enrolled in a `course_section` has access to the parent `course` and its resources.

### CORS Configuration

CORS uses a callback-based origin check in `src/main.ts`. When adding new frontend origins, update the CORS configuration there.

### Common Gotchas

1. **Route ordering:** Static routes (`/stats`, `/my-items`) MUST be declared before parameterized routes (`/:id`) in NestJS controllers
2. **User PK:** The User entity uses `userId` (column `user_id`), not `id` — always join on `user_id`
3. **TypeORM sync disabled:** Every schema change needs a manual SQL script — no auto-migration
4. **MySQL MCP is read-only:** Use `mysqlsh` CLI for any DDL or DML operations
5. **Password field:** Test accounts all use `SecureP@ss123`
6. **Date columns:** Use `TIMESTAMP` in SQL, `@CreateDateColumn` / `@UpdateDateColumn` in entities

---

*Last updated: 2025*
