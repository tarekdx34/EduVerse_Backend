# NestJS LMS Project - Campus Structure Module

I'm continuing the LMS project. Authentication and User Management (Features 1.1, 1.2) are ALREADY COMPLETE and working.

## WHAT EXISTS:

✅ User authentication with JWT
✅ User management with RBAC
✅ Role and permission system
✅ Admin dashboard functionality

## NOW BUILD: Campus Structure (Multi-Campus Support)

### PROJECT CONTEXT:

This is Feature 1.3 - building the institutional hierarchy. The platform supports multiple campuses, each with departments, programs, and semesters.

### DATABASE SCHEMA (Already exists in MySQL):

1. **campuses**: campus_id, campus_name, campus_code, address, city, country, phone, email, timezone, status, created_at, updated_at

2. **departments**: department_id, campus_id, department_name, department_code, head_of_department_id, description, status, created_at, updated_at

3. **programs**: program_id, department_id, program_name, program_code, degree_type (bachelor/master/phd/diploma/certificate), duration_years, description, status

4. **semesters**: semester_id, semester_name, semester_code, start_date, end_date, registration_start, registration_end, status (upcoming/active/completed)

### HIERARCHY:

```
Campus → Departments → Programs
Semesters are global across all campuses
```

### REQUIREMENTS:

1. Multi-campus support
2. Each campus has multiple departments
3. Each department has multiple programs
4. Programs have degree types (Bachelor, Master, PhD, etc.)
5. Departments can have a head (links to User with INSTRUCTOR role)
6. Semester management (can overlap but typically sequential)
7. Support for different timezones per campus
8. Active/Inactive status for all entities

---

## API ENDPOINTS TO IMPLEMENT:

### CAMPUS MANAGEMENT:

**1. GET /api/campuses** - List all campuses

- Query params: `status` (active/inactive)
- Response: `CampusDto[]`
- Access: All authenticated users can view
- Use `@Query()` decorator for filters

**2. POST /api/campuses** - Create new campus

- Request: `CreateCampusDto`
- Response: Created `CampusDto` (201)
- Access: IT_ADMIN only
- Use `@Roles('IT_ADMIN')` guard

**3. GET /api/campuses/:id** - Get campus by ID

- Include department count
- Response: `CampusDto`
- Access: All authenticated users
- Use `@Param('id', ParseIntPipe)`

**4. PUT /api/campuses/:id** - Update campus

- Request: `UpdateCampusDto`
- Response: Updated `CampusDto`
- Access: IT_ADMIN, ADMIN (own campus only)
- Check campus ownership for ADMIN users

**5. DELETE /api/campuses/:id** - Delete campus

- Check if campus has departments first
- Response: 204 No Content
- Access: IT_ADMIN only
- Throw `ConflictException` if has departments

### DEPARTMENT MANAGEMENT:

**6. GET /api/campuses/:campusId/departments** - List departments by campus

- Response: `DepartmentDto[]`
- Access: All authenticated users
- Use nested route

**7. POST /api/departments** - Create new department

- Request: `CreateDepartmentDto` {campusId, name, code, headOfDepartmentId?, description?}
- Verify headOfDepartmentId is a user with INSTRUCTOR role
- Response: Created `DepartmentDto` (201)
- Access: IT_ADMIN, ADMIN (own campus only)

**8. GET /api/departments/:id** - Get department by ID

- Include head info (name, email) using relations
- Include program count
- Response: `DepartmentDto`
- Access: All authenticated users

**9. PUT /api/departments/:id** - Update department

- Can change head of department
- Request: `UpdateDepartmentDto`
- Response: Updated `DepartmentDto`
- Access: IT_ADMIN, ADMIN (own campus only)

**10. DELETE /api/departments/:id** - Delete department - Check if department has programs first - Response: 204 No Content - Access: IT_ADMIN, ADMIN (own campus only)

### PROGRAM MANAGEMENT:

**11. GET /api/departments/:deptId/programs** - List programs by department - Response: `ProgramDto[]` - Access: All authenticated users

**12. POST /api/programs** - Create new program - Request: `CreateProgramDto` {departmentId, name, code, degreeType, durationYears, description?} - Response: Created `ProgramDto` (201) - Access: IT_ADMIN, ADMIN

**13. GET /api/programs/:id** - Get program by ID - Include department and campus info using relations - Response: `ProgramDto` - Access: All authenticated users

**14. PUT /api/programs/:id** - Update program - Request: `UpdateProgramDto` - Response: Updated `ProgramDto` - Access: IT_ADMIN, ADMIN

**15. DELETE /api/programs/:id** - Delete program - Check if program has enrolled students first (we'll implement this later) - Response: 204 No Content - Access: IT_ADMIN, ADMIN

### SEMESTER MANAGEMENT:

**16. GET /api/semesters** - List all semesters - Query params: `status` (upcoming/active/completed), `year` - Response: `SemesterDto[]` - Access: All authenticated users

**17. POST /api/semesters** - Create new semester - Request: `CreateSemesterDto` {name, code, startDate, endDate, registrationStart, registrationEnd} - Auto-set status based on dates - Response: Created `SemesterDto` (201) - Access: IT_ADMIN, ADMIN

**18. GET /api/semesters/:id** - Get semester by ID - Response: `SemesterDto` - Access: All authenticated users

**19. PUT /api/semesters/:id** - Update semester - Can change dates - Auto-update status based on current date - Request: `UpdateSemesterDto` - Response: Updated `SemesterDto` - Access: IT_ADMIN, ADMIN

**20. DELETE /api/semesters/:id** - Delete semester - Check if semester has courses first (we'll implement this later) - Response: 204 No Content - Access: IT_ADMIN only

**21. GET /api/semesters/current** - Get current active semester - Based on current date falling between start_date and end_date - Response: `SemesterDto` - Access: All authenticated users - Use custom repository query

---

## ENTITIES TO CREATE (TypeORM):

### 1. Campus Entity

**File**: `campus.entity.ts`

```
Fields:
- id: number (PrimaryGeneratedColumn, campus_id)
- name: string (Column, campus_name)
- code: string (Column, campus_code, unique)
- address: string (Column, nullable)
- city: string (Column, nullable)
- country: string (Column, nullable)
- phone: string (Column, nullable)
- email: string (Column, nullable)
- timezone: string (Column, default 'UTC')
- status: Status enum (Column, default ACTIVE)
- createdAt: Date (CreateDateColumn)
- updatedAt: Date (UpdateDateColumn)

Relationships:
- @OneToMany(() => Department, department => department.campus)
  departments: Department[]

Indexes:
- Unique index on campus_code
```

### 2. Department Entity

**File**: `department.entity.ts`

```
Fields:
- id: number (PrimaryGeneratedColumn, department_id)
- campusId: number (Column, campus_id)
- name: string (Column, department_name)
- code: string (Column, department_code)
- headOfDepartmentId: number (Column, nullable, head_of_department_id)
- description: string (Column, text, nullable)
- status: Status enum (Column, default ACTIVE)
- createdAt: Date (CreateDateColumn)
- updatedAt: Date (UpdateDateColumn)

Relationships:
- @ManyToOne(() => Campus, campus => campus.departments, { onDelete: 'RESTRICT' })
  @JoinColumn({ name: 'campus_id' })
  campus: Campus

- @OneToMany(() => Program, program => program.department)
  programs: Program[]

- @ManyToOne(() => User) // for head of department
  @JoinColumn({ name: 'head_of_department_id' })
  head: User

Indexes:
- Unique composite index on (campus_id, department_code)
```

### 3. Program Entity

**File**: `program.entity.ts`

```
Fields:
- id: number (PrimaryGeneratedColumn, program_id)
- departmentId: number (Column, department_id)
- name: string (Column, program_name)
- code: string (Column, program_code)
- degreeType: DegreeType enum (Column, degree_type)
- durationYears: number (Column, duration_years)
- description: string (Column, text, nullable)
- status: Status enum (Column, default ACTIVE)
- createdAt: Date (CreateDateColumn)
- updatedAt: Date (UpdateDateColumn)

Relationships:
- @ManyToOne(() => Department, department => department.programs, { onDelete: 'RESTRICT' })
  @JoinColumn({ name: 'department_id' })
  department: Department

Indexes:
- Unique composite index on (department_id, program_code)
```

### 4. Semester Entity

**File**: `semester.entity.ts`

```
Fields:
- id: number (PrimaryGeneratedColumn, semester_id)
- name: string (Column, semester_name)
- code: string (Column, semester_code, unique)
- startDate: Date (Column, start_date, type: 'date')
- endDate: Date (Column, end_date, type: 'date')
- registrationStart: Date (Column, registration_start, type: 'date')
- registrationEnd: Date (Column, registration_end, type: 'date')
- status: SemesterStatus enum (Column)
- createdAt: Date (CreateDateColumn)

Indexes:
- Unique index on semester_code
```

---

## ENUMS TO CREATE:

### 1. Status Enum

**File**: `status.enum.ts`

```typescript
export enum Status {
  ACTIVE = 'active',
  INACTIVE = 'inactive',
}
```

### 2. DegreeType Enum

**File**: `degree-type.enum.ts`

```typescript
export enum DegreeType {
  BACHELOR = 'bachelor',
  MASTER = 'master',
  PHD = 'phd',
  DIPLOMA = 'diploma',
  CERTIFICATE = 'certificate',
}
```

### 3. SemesterStatus Enum

**File**: `semester-status.enum.ts`

```typescript
export enum SemesterStatus {
  UPCOMING = 'upcoming',
  ACTIVE = 'active',
  COMPLETED = 'completed',
}
```

---

## DTOs TO CREATE (with class-validator):

### Campus DTOs:

**File**: `campus.dto.ts`

1. **CreateCampusDto**
   - name: string (@IsString, @IsNotEmpty, @Length(1, 100))
   - code: string (@IsString, @IsNotEmpty, @Matches(/^[A-Z0-9]{2,20}$/))
   - address?: string (@IsOptional, @IsString)
   - city?: string (@IsOptional, @IsString)
   - country?: string (@IsOptional, @IsString)
   - phone?: string (@IsOptional, @Matches phone pattern)
   - email?: string (@IsOptional, @IsEmail)
   - timezone?: string (@IsOptional, @IsString)
   - status?: Status (@IsOptional, @IsEnum(Status))

2. **UpdateCampusDto** - extends PartialType(CreateCampusDto)

3. **CampusDto** (response)
   - All fields from entity
   - departmentCount?: number (optional, calculated)

### Department DTOs:

**File**: `department.dto.ts`

1. **CreateDepartmentDto**
   - campusId: number (@IsInt, @IsPositive)
   - name: string (@IsString, @IsNotEmpty, @Length(1, 100))
   - code: string (@IsString, @IsNotEmpty, @Matches(/^[A-Z0-9]{2,20}$/))
   - headOfDepartmentId?: number (@IsOptional, @IsInt, @IsPositive)
   - description?: string (@IsOptional, @IsString)
   - status?: Status (@IsOptional, @IsEnum(Status))

2. **UpdateDepartmentDto** - extends PartialType(CreateDepartmentDto)
   - Remove campusId (cannot change campus after creation)

3. **DepartmentDto** (response)
   - All fields from entity
   - campusName: string
   - headName?: string
   - headEmail?: string
   - programCount?: number

### Program DTOs:

**File**: `program.dto.ts`

1. **CreateProgramDto**
   - departmentId: number (@IsInt, @IsPositive)
   - name: string (@IsString, @IsNotEmpty, @Length(1, 100))
   - code: string (@IsString, @IsNotEmpty, @Matches(/^[A-Z0-9]{2,20}$/))
   - degreeType: DegreeType (@IsEnum(DegreeType))
   - durationYears: number (@IsInt, @IsPositive, @Min(1), @Max(10))
   - description?: string (@IsOptional, @IsString)
   - status?: Status (@IsOptional, @IsEnum(Status))

2. **UpdateProgramDto** - extends PartialType(CreateProgramDto)
   - Remove departmentId

3. **ProgramDto** (response)
   - All fields from entity
   - departmentName: string
   - campusName: string

### Semester DTOs:

**File**: `semester.dto.ts`

1. **CreateSemesterDto**
   - name: string (@IsString, @IsNotEmpty, @Length(1, 100))
   - code: string (@IsString, @IsNotEmpty, @Matches(/^[A-Z0-9]{2,20}$/))
   - startDate: Date (@IsDateString or @IsDate with @Type)
   - endDate: Date (@IsDateString or @IsDate with @Type)
   - registrationStart: Date (@IsDateString)
   - registrationEnd: Date (@IsDateString)

2. **UpdateSemesterDto** - extends PartialType(CreateSemesterDto)

3. **SemesterDto** (response)
   - All fields from entity

---

## SERVICES TO CREATE:

### 1. CampusService

**File**: `campus.service.ts`

Methods:

- `findAll(status?: Status): Promise<Campus[]>` - with optional filter
- `findById(id: number): Promise<Campus>` - throw NotFoundException
- `create(dto: CreateCampusDto): Promise<Campus>` - check unique code
- `update(id: number, dto: UpdateCampusDto): Promise<Campus>`
- `delete(id: number): Promise<void>` - check for departments first
- `getCampusWithDepartmentCount(id: number): Promise<CampusDto>`

Business Logic:

- Validate unique campus_code before create/update
- Check if campus has departments before delete
- Use QueryBuilder for department count

### 2. DepartmentService

**File**: `department.service.ts`

Methods:

- `findByCampusId(campusId: number): Promise<Department[]>`
- `findById(id: number): Promise<Department>` - with relations
- `create(dto: CreateDepartmentDto): Promise<Department>` - validate head
- `update(id: number, dto: UpdateDepartmentDto): Promise<Department>`
- `delete(id: number): Promise<void>` - check for programs
- `validateHeadOfDepartment(userId: number): Promise<void>` - check INSTRUCTOR role

Business Logic:

- Validate unique (campus_id, department_code)
- Verify head is INSTRUCTOR or ADMIN role before assigning
- Check if department has programs before delete
- Load campus and head relations for responses

### 3. ProgramService

**File**: `program.service.ts`

Methods:

- `findByDepartmentId(departmentId: number): Promise<Program[]>`
- `findById(id: number): Promise<Program>` - with department and campus
- `create(dto: CreateProgramDto): Promise<Program>`
- `update(id: number, dto: UpdateProgramDto): Promise<Program>`
- `delete(id: number): Promise<void>` - check for students (future)

Business Logic:

- Validate unique (department_id, program_code)
- Validate durationYears is reasonable (1-10 years)
- Load department and campus relations

### 4. SemesterService

**File**: `semester.service.ts`

Methods:

- `findAll(status?: SemesterStatus, year?: number): Promise<Semester[]>`
- `findById(id: number): Promise<Semester>`
- `findCurrentSemester(): Promise<Semester>` - based on current date
- `create(dto: CreateSemesterDto): Promise<Semester>` - auto-calculate status
- `update(id: number, dto: UpdateSemesterDto): Promise<Semester>` - recalculate status
- `delete(id: number): Promise<void>` - check for courses (future)
- `calculateStatus(startDate: Date, endDate: Date): SemesterStatus` - helper method

Business Logic:

- Validate unique semester_code
- Validate date ranges (start < end, registration dates logical)
- Auto-calculate status:
  - UPCOMING: current date < start_date
  - ACTIVE: start_date <= current date <= end_date
  - COMPLETED: current date > end_date
- Filter by year using YEAR(start_date)

---

## CONTROLLERS TO CREATE:

### 1. CampusController

**File**: `campus.controller.ts`

```
@Controller('api/campuses')
@UseGuards(JwtAuthGuard, RolesGuard)
class CampusController

Endpoints:
- GET / - @Roles('IT_ADMIN', 'ADMIN', 'INSTRUCTOR', 'TA', 'STUDENT')
- POST / - @Roles('IT_ADMIN')
- GET /:id - @Roles('IT_ADMIN', 'ADMIN', 'INSTRUCTOR', 'TA', 'STUDENT')
- PUT /:id - @Roles('IT_ADMIN', 'ADMIN') + check campus ownership
- DELETE /:id - @Roles('IT_ADMIN')
```

### 2. DepartmentController

**File**: `department.controller.ts`

```
@Controller('api')
@UseGuards(JwtAuthGuard, RolesGuard)
class DepartmentController

Endpoints:
- GET /campuses/:campusId/departments - All authenticated
- POST /departments - @Roles('IT_ADMIN', 'ADMIN')
- GET /departments/:id - All authenticated
- PUT /departments/:id - @Roles('IT_ADMIN', 'ADMIN')
- DELETE /departments/:id - @Roles('IT_ADMIN', 'ADMIN')
```

### 3. ProgramController

**File**: `program.controller.ts`

```
@Controller('api')
@UseGuards(JwtAuthGuard, RolesGuard)
class ProgramController

Endpoints:
- GET /departments/:deptId/programs - All authenticated
- POST /programs - @Roles('IT_ADMIN', 'ADMIN')
- GET /programs/:id - All authenticated
- PUT /programs/:id - @Roles('IT_ADMIN', 'ADMIN')
- DELETE /programs/:id - @Roles('IT_ADMIN', 'ADMIN')
```

### 4. SemesterController

**File**: `semester.controller.ts`

```
@Controller('api/semesters')
@UseGuards(JwtAuthGuard, RolesGuard)
class SemesterController

Endpoints:
- GET / - All authenticated, with query filters
- GET /current - All authenticated
- POST / - @Roles('IT_ADMIN', 'ADMIN')
- GET /:id - All authenticated
- PUT /:id - @Roles('IT_ADMIN', 'ADMIN')
- DELETE /:id - @Roles('IT_ADMIN')
```

---

## CUSTOM EXCEPTIONS:

**File**: `campus.exceptions.ts`

Create custom exceptions extending HttpException or built-in exceptions:

1. `CampusNotFoundException` extends NotFoundException
2. `DepartmentNotFoundException` extends NotFoundException
3. `ProgramNotFoundException` extends NotFoundException
4. `SemesterNotFoundException` extends NotFoundException
5. `CampusCodeAlreadyExistsException` extends ConflictException
6. `DepartmentCodeAlreadyExistsException` extends ConflictException
7. `ProgramCodeAlreadyExistsException` extends ConflictException
8. `InvalidHeadOfDepartmentException` extends BadRequestException
9. `CannotDeleteCampusWithDepartmentsException` extends ConflictException
10. `CannotDeleteDepartmentWithProgramsException` extends ConflictException
11. `InvalidDateRangeException` extends BadRequestException

---

## SECURITY IMPLEMENTATION:

### Guards and Decorators:

1. **Roles Decorator**

```typescript
// @Roles('IT_ADMIN', 'ADMIN')
export const Roles = (...roles: string[]) => SetMetadata('roles', roles);
```

2. **RolesGuard**

```typescript
// Check if user has required role
// Access user from request.user (set by JwtAuthGuard)
```

3. **Campus Ownership Check**
   For ADMIN users:

- Check if user's campus_id matches the campus being accessed/modified
- IT_ADMIN bypasses this check
- Implement in service layer or custom guard

---

## MODULE CONFIGURATION:

**File**: `campus.module.ts`

```typescript
@Module({
  imports: [
    TypeOrmModule.forFeature([
      Campus,
      Department,
      Program,
      Semester,
      User, // if needed for head validation
    ]),
  ],
  controllers: [
    CampusController,
    DepartmentController,
    ProgramController,
    SemesterController,
  ],
  providers: [
    CampusService,
    DepartmentService,
    ProgramService,
    SemesterService,
  ],
  exports: [CampusService, DepartmentService, ProgramService, SemesterService],
})
export class CampusModule {}
```

---

## VALIDATION RULES:

1. **Campus**:
   - code: 2-20 chars, uppercase alphanumeric, unique globally
   - email: valid email format
   - phone: optional validation pattern

2. **Department**:
   - code: 2-20 chars, unique within campus
   - headOfDepartmentId: must be INSTRUCTOR or ADMIN role

3. **Program**:
   - code: 2-20 chars, unique within department
   - durationYears: 1-10 years
   - degreeType: must be valid enum value

4. **Semester**:
   - code: unique globally (e.g., FALL2024)
   - Date validations:
     - startDate < endDate
     - registrationStart < registrationEnd
     - registrationEnd < startDate
   - Status auto-calculated, not user-provided

---

## CUSTOM REPOSITORY QUERIES:

Use TypeORM QueryBuilder for:

1. **Campus with department count**:

```typescript
leftJoinAndSelect + loadRelationCountAndMap;
```

2. **Department with program count**:

```typescript
leftJoinAndSelect + count;
```

3. **Current semester**:

```typescript
where('start_date <= :now AND end_date >= :now');
```

4. **Semester by year**:

```typescript
where('YEAR(start_date) = :year');
```

5. **Filter by status**:

```typescript
where('status = :status');
```

---

## IMPLEMENTATION CHECKLIST:

- [ ] Create all entity files with TypeORM decorators
- [ ] Create all enum files
- [ ] Create all DTO files with class-validator
- [ ] Create exception classes
- [ ] Create service files with business logic
- [ ] Create controller files with REST endpoints
- [ ] Implement Roles decorator and RolesGuard
- [ ] Add campus ownership validation for ADMIN
- [ ] Implement semester status auto-calculation
- [ ] Add proper error handling in all services
- [ ] Create the main CampusModule
- [ ] Register CampusModule in AppModule
- [ ] Test all endpoints with different roles

---

## TECHNICAL REQUIREMENTS:

1. **Use TypeORM** for database operations
2. **Use class-validator** and class-transformer for DTOs
3. **Use @nestjs/passport** with JWT for authentication
4. **Use Guards**: JwtAuthGuard and custom RolesGuard
5. **Use Pipes**: ValidationPipe globally, ParseIntPipe for IDs
6. **Error Handling**: Use HttpException-based custom exceptions
7. **Response Format**: Return plain objects (DTOs), NestJS auto-serializes to JSON
8. **Async/Await**: All service methods return Promises
9. **Dependency Injection**: Use constructor injection in all classes
10. **Prevent Circular References**: Use @Exclude() or plain transformation

---

## NOTES:

- Follow NestJS best practices and folder structure
- Use `@InjectRepository()` for repository injection
- Use `@Body()`, `@Param()`, `@Query()` decorators appropriately
- Return proper HTTP status codes (201 for create, 204 for delete)
- Use `ValidationPipe` with `transform: true` for DTO transformation
- Use `ParseIntPipe` for path parameters
- Use relations carefully to avoid N+1 queries
- Implement proper cascade and delete constraints
- Add database indexes for frequently queried fields

---

Please provide complete, production-ready NestJS code for all components listed above.
