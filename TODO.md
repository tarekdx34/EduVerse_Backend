Feature 2.1: Course Management System - NestJS Backend
Project Context
I'm continuing the LMS project. The following features are ALREADY COMPLETE: ✅ Authentication (Login, Register, JWT) ✅ User Management (Users, Roles, Permissions) ✅ Campus Structure (Campuses, Departments, Programs, Semesters)
NOW BUILD: Course Management System
This is Feature 2.1 - the core academic structure. Instructors create courses, define prerequisites, create sections for different semesters, and set up class schedules.

Database Schema (Already exists in MySQL/PostgreSQL)
Tables:
courses
course_id (PK, UUID/INT)
department_id (FK)
course_name (VARCHAR)
course_code (VARCHAR, unique per department)
course_description (TEXT)
credits (INT)
level (ENUM: FRESHMAN, SOPHOMORE, JUNIOR, SENIOR, GRADUATE)
syllabus_url (VARCHAR, nullable)
status (ENUM: ACTIVE, INACTIVE, ARCHIVED)
created_at (TIMESTAMP)
updated_at (TIMESTAMP)
deleted_at (TIMESTAMP, nullable)
course_prerequisites
prerequisite_id (PK, UUID/INT)
course_id (FK)
prerequisite_course_id (FK)
is_mandatory (BOOLEAN)
created_at (TIMESTAMP)
UNIQUE(course_id, prerequisite_course_id)
course_sections
section_id (PK, UUID/INT)
course_id (FK)
semester_id (FK)
section_number (VARCHAR)
max_capacity (INT)
current_enrollment (INT, default 0)
location (VARCHAR, nullable)
status (ENUM: OPEN, CLOSED, FULL, CANCELLED)
created_at (TIMESTAMP)
updated_at (TIMESTAMP)
UNIQUE(course_id, semester_id, section_number)
course_schedules
schedule_id (PK, UUID/INT)
section_id (FK)
day_of_week (ENUM: MONDAY-SUNDAY)
start_time (TIME)
end_time (TIME)
room (VARCHAR)
building (VARCHAR)
schedule_type (ENUM: LECTURE, LAB, TUTORIAL, EXAM)
created_at (TIMESTAMP)

Course Hierarchy
Department → Course → Course Section (per semester) → Schedule (when it meets)
Example:
Course: "Data Structures" (CS201)
Prerequisites: "Introduction to Programming" (CS101)
Section: CS201-01 (Fall 2024, max 40 students)
Schedule: Monday 10:00-11:30 (Lecture), Wednesday 14:00-16:00 (Lab)

Requirements
Instructors can create courses in their department
Set course prerequisites (can have multiple)
Create sections for specific semesters
Each section has enrollment capacity
Define class schedules (days, times, rooms)
Track current enrollment count
Support for lecture, lab, tutorial, exam schedules
Courses can be archived (soft delete)

API Endpoints to Implement
COURSE MANAGEMENT
1. GET /api/courses - List all courses
Query params: departmentId, level, status, search, page, limit
Response: Paginated CourseDto[]
Access: All authenticated users
Include department info in response
2. POST /api/courses - Create new course
Request Body: CreateCourseDto
typescript
 {
    departmentId: string;
    name: string;
    code: string;
    description: string;
    credits: number;
    level: CourseLevel;
    syllabusUrl?: string;
  }
Response: CourseDto (201 Created)
Access: INSTRUCTOR, ADMIN, IT_ADMIN
Validation: Instructor must belong to the department
3. GET /api/courses/:id - Get course details
Include prerequisites
Include section count
Include department info
Response: CourseDetailDto
Access: All authenticated users
4. PATCH /api/courses/:id - Update course
Request Body: UpdateCourseDto (Partial of CreateCourseDto)
Response: CourseDto
Access: INSTRUCTOR (course creator), ADMIN, IT_ADMIN
5. DELETE /api/courses/:id - Soft delete course
Sets deleted_at timestamp
Cannot delete if active sections exist
Response: 204 No Content
Access: ADMIN, IT_ADMIN
6. GET /api/departments/:deptId/courses - Get courses by department
Response: CourseDto[]
Access: All authenticated users

PREREQUISITE MANAGEMENT
7. GET /api/courses/:id/prerequisites - Get course prerequisites
Response: PrerequisiteDto[]
Include prerequisite course details
Access: All authenticated users
8. POST /api/courses/:id/prerequisites - Add prerequisite
Request Body: CreatePrerequisiteDto
typescript
 {
    prerequisiteCourseId: string;
    isMandatory: boolean;
  }
Prevent circular dependencies (implement detection algorithm)
Response: PrerequisiteDto (201 Created)
Access: INSTRUCTOR (course creator), ADMIN, IT_ADMIN
9. DELETE /api/courses/:id/prerequisites/:prereqId - Remove prerequisite
Response: 204 No Content
Access: INSTRUCTOR (course creator), ADMIN, IT_ADMIN

SECTION MANAGEMENT
10. GET /api/courses/:courseId/sections - Get sections for a course
Query params: semesterId, status
Response: CourseSectionDto[]
Include course and semester info
Access: All authenticated users
11. POST /api/sections - Create new section
Request Body: CreateSectionDto
typescript
 {
    courseId: string;
    semesterId: string;
    sectionNumber: string;
    maxCapacity: number;
    location?: string;
  }
Auto-set currentEnrollment to 0
Status defaults to OPEN
Response: CourseSectionDto (201 Created)
Access: INSTRUCTOR, ADMIN, IT_ADMIN
12. GET /api/sections/:id - Get section details
Include course info, semester info, schedules
Include instructor(s) info (if assigned - for future features)
Response: CourseSectionDto
Access: All authenticated users
13. PATCH /api/sections/:id - Update section
Can change capacity, location, status
Cannot change course or semester
Request Body: UpdateSectionDto
Response: CourseSectionDto
Access: INSTRUCTOR (assigned to section), ADMIN, IT_ADMIN
14. DELETE /api/sections/:id - Delete section
Cannot delete if students enrolled (currentEnrollment > 0)
Response: 204 No Content
Access: ADMIN, IT_ADMIN
15. GET /api/semesters/:semesterId/sections - Get all sections in semester
Response: CourseSectionDto[]
Access: All authenticated users

SCHEDULE MANAGEMENT
16. POST /api/sections/:id/schedules - Add schedule to section
Request Body: CreateScheduleDto
typescript
 {
    dayOfWeek: DayOfWeek;
    startTime: string; // "HH:mm" format
    endTime: string;   // "HH:mm" format
    room: string;
    building: string;
    scheduleType: ScheduleType;
  }
```
- Can have multiple schedules (e.g., MWF for lecture, T for lab)
- Validate no time conflicts for same room/building
- Response: `CourseScheduleDto` (201 Created)
- Access: INSTRUCTOR (assigned to section), ADMIN, IT_ADMIN

**17. PATCH /api/schedules/:id - Update schedule**
- Request Body: `UpdateScheduleDto`
- Validate time conflicts
- Response: `CourseScheduleDto`
- Access: INSTRUCTOR, ADMIN, IT_ADMIN

**18. DELETE /api/schedules/:id - Delete schedule**
- Response: 204 No Content
- Access: INSTRUCTOR, ADMIN, IT_ADMIN

**19. GET /api/sections/:id/schedules - Get schedules for section**
- Response: `CourseScheduleDto[]`
- Access: All authenticated users

---

## NestJS Module Structure

### Modules to Create:
```
courses/
├── courses.module.ts
├── entities/
│   ├── course.entity.ts
│   ├── course-prerequisite.entity.ts
│   ├── course-section.entity.ts
│   └── course-schedule.entity.ts
├── dto/
│   ├── course/
│   │   ├── create-course.dto.ts
│   │   ├── update-course.dto.ts
│   │   ├── course.dto.ts
│   │   └── course-detail.dto.ts
│   ├── prerequisite/
│   │   ├── create-prerequisite.dto.ts
│   │   └── prerequisite.dto.ts
│   ├── section/
│   │   ├── create-section.dto.ts
│   │   ├── update-section.dto.ts
│   │   └── course-section.dto.ts
│   └── schedule/
│       ├── create-schedule.dto.ts
│       ├── update-schedule.dto.ts
│       └── course-schedule.dto.ts
├── enums/
│   ├── course-level.enum.ts
│   ├── course-status.enum.ts
│   ├── section-status.enum.ts
│   ├── day-of-week.enum.ts
│   └── schedule-type.enum.ts
├── services/
│   ├── courses.service.ts
│   ├── course-sections.service.ts
│   └── course-schedules.service.ts
├── controllers/
│   ├── courses.controller.ts
│   ├── course-sections.controller.ts
│   └── course-schedules.controller.ts
└── exceptions/
    ├── course-not-found.exception.ts
    ├── circular-prerequisite.exception.ts
    ├── schedule-conflict.exception.ts
    ├── cannot-delete-course.exception.ts
    └── section-capacity-exceeded.exception.ts

Entities to Create (TypeORM)
1. Course Entity
typescript
@Entity('courses')
export class Course {
  @PrimaryGeneratedColumn('uuid')
  courseId: string;

  @ManyToOne(() => Department)
  @JoinColumn({ name: 'department_id' })
  department: Department;

  @Column()
  courseName: string;

  @Column()
  courseCode: string;

  @Column('text')
  courseDescription: string;

  @Column('int')
  credits: number;

  @Column({ type: 'enum', enum: CourseLevel })
  level: CourseLevel;

  @Column({ nullable: true })
  syllabusUrl: string;

  @Column({ type: 'enum', enum: CourseStatus, default: CourseStatus.ACTIVE })
  status: CourseStatus;

  @OneToMany(() => CourseSection, section => section.course)
  sections: CourseSection[];

  @OneToMany(() => CoursePrerequisite, prereq => prereq.course)
  prerequisites: CoursePrerequisite[];

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @DeleteDateColumn()
  deletedAt: Date;
}
Indexes:
Unique index on (department_id, course_code)
Index on department_id
Index on status
Index on deleted_at (for soft delete queries)
2. CoursePrerequisite Entity
typescript
@Entity('course_prerequisites')
@Unique(['course', 'prerequisiteCourse'])
export class CoursePrerequisite {
  @PrimaryGeneratedColumn('uuid')
  prerequisiteId: string;

  @ManyToOne(() => Course, course => course.prerequisites)
  @JoinColumn({ name: 'course_id' })
  course: Course;

  @ManyToOne(() => Course)
  @JoinColumn({ name: 'prerequisite_course_id' })
  prerequisiteCourse: Course;

  @Column({ default: true })
  isMandatory: boolean;

  @CreateDateColumn()
  createdAt: Date;
}
3. CourseSection Entity
typescript
@Entity('course_sections')
@Unique(['course', 'semester', 'sectionNumber'])
export class CourseSection {
  @PrimaryGeneratedColumn('uuid')
  sectionId: string;

  @ManyToOne(() => Course, course => course.sections)
  @JoinColumn({ name: 'course_id' })
  course: Course;

  @ManyToOne(() => Semester)
  @JoinColumn({ name: 'semester_id' })
  semester: Semester;

  @Column()
  sectionNumber: string;

  @Column('int')
  maxCapacity: number;

  @Column('int', { default: 0 })
  currentEnrollment: number;

  @Column({ nullable: true })
  location: string;

  @Column({ type: 'enum', enum: SectionStatus, default: SectionStatus.OPEN })
  status: SectionStatus;

  @OneToMany(() => CourseSchedule, schedule => schedule.section)
  schedules: CourseSchedule[];

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
Indexes:
Index on course_id
Index on semester_id
Index on status
4. CourseSchedule Entity
typescript
@Entity('course_schedules')
export class CourseSchedule {
  @PrimaryGeneratedColumn('uuid')
  scheduleId: string;

  @ManyToOne(() => CourseSection, section => section.schedules)
  @JoinColumn({ name: 'section_id' })
  section: CourseSection;

  @Column({ type: 'enum', enum: DayOfWeek })
  dayOfWeek: DayOfWeek;

  @Column('time')
  startTime: string;

  @Column('time')
  endTime: string;

  @Column()
  room: string;

  @Column()
  building: string;

  @Column({ type: 'enum', enum: ScheduleType })
  scheduleType: ScheduleType;

  @CreateDateColumn()
  createdAt: Date;
}
Indexes:
Index on section_id
Composite index on (building, room, day_of_week) for conflict checking

Enums to Create
typescript
export enum CourseLevel {
  FRESHMAN = 'freshman',
  SOPHOMORE = 'sophomore',
  JUNIOR = 'junior',
  SENIOR = 'senior',
  GRADUATE = 'graduate'
}

export enum CourseStatus {
  ACTIVE = 'active',
  INACTIVE = 'inactive',
  ARCHIVED = 'archived'
}

export enum SectionStatus {
  OPEN = 'open',
  CLOSED = 'closed',
  FULL = 'full',
  CANCELLED = 'cancelled'
}

export enum DayOfWeek {
  MONDAY = 'monday',
  TUESDAY = 'tuesday',
  WEDNESDAY = 'wednesday',
  THURSDAY = 'thursday',
  FRIDAY = 'friday',
  SATURDAY = 'saturday',
  SUNDAY = 'sunday'
}

export enum ScheduleType {
  LECTURE = 'lecture',
  LAB = 'lab',
  TUTORIAL = 'tutorial',
  EXAM = 'exam'
}

DTOs with Class-Validator
Course DTOs
typescript
export class CreateCourseDto {
  @IsUUID()
  @IsNotEmpty()
  departmentId: string;

  @IsString()
  @Length(3, 200)
  name: string;

  @IsString()
  @Length(2, 20)
  @Matches(/^[A-Z0-9]+$/, { message: 'Course code must be alphanumeric uppercase' })
  code: string;

  @IsString()
  @Length(10, 2000)
  description: string;

  @IsInt()
  @Min(1)
  @Max(6)
  credits: number;

  @IsEnum(CourseLevel)
  level: CourseLevel;

  @IsUrl()
  @IsOptional()
  syllabusUrl?: string;
}

export class UpdateCourseDto extends PartialType(CreateCourseDto) {}

export class CourseDto {
  courseId: string;
  departmentId: string;
  departmentName?: string;
  name: string;
  code: string;
  description: string;
  credits: number;
  level: CourseLevel;
  syllabusUrl?: string;
  status: CourseStatus;
  createdAt: Date;
  updatedAt: Date;
}

export class CourseDetailDto extends CourseDto {
  prerequisites: PrerequisiteDto[];
  sectionCount: number;
}
Prerequisite DTOs
typescript
export class CreatePrerequisiteDto {
  @IsUUID()
  @IsNotEmpty()
  prerequisiteCourseId: string;

  @IsBoolean()
  @IsOptional()
  isMandatory?: boolean = true;
}

export class PrerequisiteDto {
  prerequisiteId: string;
  courseId: string;
  prerequisiteCourseId: string;
  prerequisiteCourseName: string;
  prerequisiteCourseCode: string;
  isMandatory: boolean;
  createdAt: Date;
}
Section DTOs
typescript
export class CreateSectionDto {
  @IsUUID()
  @IsNotEmpty()
  courseId: string;

  @IsUUID()
  @IsNotEmpty()
  semesterId: string;

  @IsString()
  @Length(1, 10)
  sectionNumber: string;

  @IsInt()
  @Min(1)
  @Max(500)
  maxCapacity: number;

  @IsString()
  @IsOptional()
  location?: string;
}

export class UpdateSectionDto {
  @IsInt()
  @Min(1)
  @Max(500)
  @IsOptional()
  maxCapacity?: number;

  @IsString()
  @IsOptional()
  location?: string;

  @IsEnum(SectionStatus)
  @IsOptional()
  status?: SectionStatus;
}

export class CourseSectionDto {
  sectionId: string;
  courseId: string;
  courseName: string;
  courseCode: string;
  semesterId: string;
  semesterName: string;
  sectionNumber: string;
  maxCapacity: number;
  currentEnrollment: number;
  location?: string;
  status: SectionStatus;
  schedules?: CourseScheduleDto[];
  createdAt: Date;
  updatedAt: Date;
}
Schedule DTOs
typescript
export class CreateScheduleDto {
  @IsEnum(DayOfWeek)
  dayOfWeek: DayOfWeek;

  @IsString()
  @Matches(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/, {
    message: 'Start time must be in HH:mm format'
  })
  startTime: string;

  @IsString()
  @Matches(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/, {
    message: 'End time must be in HH:mm format'
  })
  endTime: string;

  @IsString()
  @Length(1, 50)
  room: string;

  @IsString()
  @Length(1, 100)
  building: string;

  @IsEnum(ScheduleType)
  scheduleType: ScheduleType;
}

export class UpdateScheduleDto extends PartialType(CreateScheduleDto) {}

export class CourseScheduleDto {
  scheduleId: string;
  sectionId: string;
  dayOfWeek: DayOfWeek;
  startTime: string;
  endTime: string;
  room: string;
  building: string;
  scheduleType: ScheduleType;
  createdAt: Date;
}

Business Logic Requirements
CoursesService
Course code uniqueness: Validate course code is unique within department
Instructor authorization: Only instructors in the same department can create courses
Soft delete validation: Cannot delete course if it has active sections (currentEnrollment > 0 or status = OPEN)
Search functionality: Implement text search across name, code, description
Pagination: Use TypeORM pagination for listing courses
Prerequisites Logic (Circular Dependency Detection)
Implement graph-based cycle detection:
typescript
async detectCircularPrerequisite(courseId: string, prerequisiteCourseId: string): Promise<boolean> {
  // Use DFS or BFS to detect if adding this prerequisite creates a cycle
  // A → B, B → C, trying to add C → A would create a cycle
  // Return true if cycle detected, false otherwise
}
Algorithm steps:
Start from prerequisiteCourseId
Traverse all its prerequisites recursively
If we encounter courseId in the traversal, cycle detected
Use visited set to avoid infinite loops
Throw CircularPrerequisiteException if cycle found
Section Status Management
Auto-update section status:
typescript
async updateSectionStatus(sectionId: string): Promise<void> {
  const section = await this.findSection(sectionId);
  
  if (section.currentEnrollment >= section.maxCapacity) {
    section.status = SectionStatus.FULL;
  } else if (section.status === SectionStatus.FULL && 
             section.currentEnrollment < section.maxCapacity) {
    section.status = SectionStatus.OPEN;
  }
  
  await this.sectionRepository.save(section);
}
Schedule Conflict Detection
typescript
async checkScheduleConflict(
  building: string,
  room: string,
  dayOfWeek: DayOfWeek,
  startTime: string,
  endTime: string,
  excludeScheduleId?: string
): Promise<boolean> {
  // Find all schedules for the same room, building, and day
  // Check if time ranges overlap
  // Time overlap exists if: (start1 < end2) AND (start2 < end1)
  // Return true if conflict found
}
Time validation:
Parse time strings to compare: startTime < endTime
Convert to minutes for easier comparison
Check overlapping intervals

Security & Guards
Role-Based Access Control
Use NestJS Guards with @UseGuards(JwtAuthGuard, RolesGuard):
typescript
// courses.controller.ts
@Controller('api/courses')
@UseGuards(JwtAuthGuard)
export class CoursesController {
  
  @Get()
  @Roles(Role.STUDENT, Role.INSTRUCTOR, Role.ADMIN, Role.IT_ADMIN)
  async findAll(@Query() query: QueryCoursesDto) { }

  @Post()
  @Roles(Role.INSTRUCTOR, Role.ADMIN, Role.IT_ADMIN)
  async create(@Body() dto: CreateCourseDto, @CurrentUser() user: User) {
    // Validate instructor belongs to department
  }

  @Patch(':id')
  @Roles(Role.INSTRUCTOR, Role.ADMIN, Role.IT_ADMIN)
  async update(
    @Param('id') id: string,
    @Body() dto: UpdateCourseDto,
    @CurrentUser() user: User
  ) {
    // Validate user has permission to edit this course
  }

  @Delete(':id')
  @Roles(Role.ADMIN, Role.IT_ADMIN)
  async remove(@Param('id') id: string) { }
}
Authorization Checks
Instructors: Can only create courses in their own department
Course Creators: Can edit/delete their own courses
Admins: Can edit any course in their campus
IT_ADMINS: Full access
Students: Read-only access
Implement custom decorator:
typescript
@CanEditCourse() // Custom decorator that checks ownership
async updateCourse(@Param('id') id: string, @CurrentUser() user: User) { }

Exception Classes
Create custom exceptions extending HttpException:
typescript
export class CourseNotFoundException extends NotFoundException {
  constructor(courseId: string) {
    super(`Course with ID ${courseId} not found`);
  }
}

export class CircularPrerequisiteException extends BadRequestException {
  constructor(courseId: string, prerequisiteId: string) {
    super(
      `Adding prerequisite ${prerequisiteId} to course ${courseId} would create a circular dependency`
    );
  }
}

export class ScheduleConflictException extends ConflictException {
  constructor(building: string, room: string, dayOfWeek: string, time: string) {
    super(
      `Schedule conflict detected for ${building} ${room} on ${dayOfWeek} at ${time}`
    );
  }
}

export class CannotDeleteCourseException extends BadRequestException {
  constructor(reason: string) {
    super(`Cannot delete course: ${reason}`);
  }
}

export class SectionCapacityExceededException extends BadRequestException {
  constructor(sectionId: string) {
    super(`Section ${sectionId} has reached maximum capacity`);
  }
}

export class UnauthorizedCourseAccessException extends ForbiddenException {
  constructor() {
    super('You do not have permission to access or modify this course');
  }
}

Validation Rules Summary
Course Validation
courseCode: 2-20 characters, alphanumeric uppercase (e.g., CS101, MATH201)
credits: Integer between 1-6
name: 3-200 characters
description: 10-2000 characters
syllabusUrl: Valid URL format (optional)
Section Validation
sectionNumber: 1-10 characters (e.g., "01", "A1", "LAB-1")
maxCapacity: Integer between 1-500
currentEnrollment: Cannot exceed maxCapacity
Schedule Validation
startTime / endTime: HH:mm format (24-hour)
startTime must be before endTime
No overlapping schedules for same room/building/day
room: 1-50 characters
building: 1-100 characters

Query & Filter Requirements
Course Listing Filters
typescript
interface QueryCoursesDto {
  departmentId?: string;
  level?: CourseLevel;
  status?: CourseStatus;
  search?: string; // Search in name, code, description
  page?: number;
  limit?: number;
}
Section Listing Filters
typescript
interface QuerySectionsDto {
  semesterId?: string;
  status?: SectionStatus;
  courseId?: string;
}
Implement using TypeORM QueryBuilder:
typescript
const query = this.courseRepository.createQueryBuilder('course')
  .leftJoinAndSelect('course.department', 'department')
  .where('course.deletedAt IS NULL');

if (departmentId) {
  query.andWhere('course.departmentId = :departmentId', { departmentId });
}

if (level) {
  query.andWhere('course.level = :level', { level });
}

if (search) {
  query.andWhere(
    '(course.courseName LIKE :search OR course.courseCode LIKE :search)',
    { search: `%${search}%` }
  );
}

Performance Optimization
Database Indexes
Composite index on (department_id, course_code) for uniqueness
Index on department_id for department queries
Index on status and deleted_at for filtering
Index on semester_id for section queries
Composite index on (building, room, day_of_week) for conflict checking
Index on course_id in sections table
Eager/Lazy Loading
Use relations in find options selectively
Lazy load prerequisites only when needed
Eager load department info for course listings
Use query builders for complex joins
Caching
Consider implementing caching for:
Course listings (invalidate on create/update/delete)
Department course lists
Section schedules

Testing Requirements
Unit Tests
Circular prerequisite detection algorithm
Schedule conflict detection logic
Section status auto-update logic
Authorization validation
DTO validation
Integration Tests
Complete CRUD operations for courses
Adding/removing prerequisites
Creating sections with schedules
Soft delete behavior
Filter and pagination
Permission checks
Test Data
Create fixtures for:
Sample departments
Sample courses with various levels
Course prerequisites (including edge cases)
Sections across multiple semesters
Schedules with different types

Additional Requirements
Soft Delete Implementation
Use TypeORM's @DeleteDateColumn():
typescript
@DeleteDateColumn()
deletedAt: Date;
Default queries should exclude soft-deleted records:
typescript
.where('course.deletedAt IS NULL')
Pagination Response Format
typescript
interface PaginatedResponse<T> {
  data: T[];
  meta: {
    total: number;
    page: number;
    limit: number;
    totalPages: number;
  };
}
Logging
Use NestJS Logger for:
Course creation/updates
Prerequisite changes
Section enrollment updates
Schedule conflicts detected
Authorization failures

Integration with Existing Entities
Reference existing entities:
typescript
// From campus module
import { Department } from '../campus/entities/department.entity';
import { Semester } from '../campus/entities/semester.entity';

// From users module (for future use)
import { User } from '../users/entities/user.entity';
Ensure proper module imports in CoursesModule:
typescript
@Module({
  imports: [
    TypeOrmModule.forFeature([
      Course,
      CoursePrerequisite,
      CourseSection,
      CourseSchedule
    ]),
    forwardRef(() => CampusModule), // For Department, Semester
    forwardRef(() => UsersModule),  // For authorization
  ],
  controllers: [CoursesController, CourseSectionsController, CourseSchedulesController],
  providers: [CoursesService, CourseSectionsService, CourseSchedulesService],
  exports: [CoursesService, CourseSectionsService],
})
export class CoursesModule {}

Deliverables
Please provide complete, production-ready NestJS code including:
✅ Entity classes with TypeORM decorators and relationships
✅ DTO classes with class-validator decorators
✅ Enum files for all enumerated types
✅ Service classes with business logic:
CoursesService
CourseSectionsService
CourseSchedulesService
✅ Controller classes with proper REST endpoints:
CoursesController
CourseSectionsController
CourseSchedulesController
✅ Custom exception classes
✅ Circular prerequisite detection algorithm (graph traversal)
✅ Schedule conflict checking logic
✅ Guards and decorators for authorization
✅ Module configuration (imports, providers, exports)
✅ Database migrations (TypeORM migrations for schema)
✅ Complete working implementation

Important Notes
✅ Handle circular prerequisite dependencies with graph algorithms
✅ Validate schedule time conflicts before saving
✅ Auto-update section status based on enrollment
✅ Implement soft delete for courses (cannot delete if active sections exist)
✅ Add proper database indexes for query performance
✅ Use TypeORM relations carefully to avoid N+1 queries
✅ Implement proper error handling and custom exceptions
✅ Follow NestJS best practices (modules, services, controllers separation)
✅ Use class-validator and class-transformer for DTOs
✅ Implement role-based access control with guards
✅ Support pagination for all list endpoints
✅ Write clean, maintainable, well-documented code
