import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Body,
  Param,
  Query,
  HttpStatus,
  HttpCode,
  ParseIntPipe,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiParam,
  ApiQuery,
  ApiBody,
} from '@nestjs/swagger';
import { CoursesService } from '../services/courses.service';
import { CreateCourseDto, UpdateCourseDto, CreatePrerequisiteDto } from '../dtos';
import { CourseStatus } from '../enums';

@ApiTags('📖 Courses')
@Controller('api/courses')
export class CoursesController {
  constructor(private readonly coursesService: CoursesService) {}

  @Get()
  @ApiOperation({
    summary: 'List all courses',
    description: `
## List All Courses

Retrieves a paginated list of courses with optional filters.

### Access Control
- **Authentication Required**: No (Public endpoint)
- **Roles Required**: None (accessible to all)

### Filtering Options
- \`departmentId\`: Filter by department
- \`level\`: Filter by course level (100, 200, 300, etc.)
- \`status\`: Filter by course status
- \`search\`: Search by course name or code

### Pagination
- \`page\`: Page number (default: 1)
- \`limit\`: Items per page (default: 20, max: 100)
    `,
  })
  @ApiQuery({ name: 'departmentId', required: false, type: Number })
  @ApiQuery({ name: 'level', required: false, type: String, example: '300' })
  @ApiQuery({ name: 'status', required: false, enum: CourseStatus })
  @ApiQuery({ name: 'search', required: false, type: String })
  @ApiQuery({ name: 'page', required: false, type: Number, example: 1 })
  @ApiQuery({ name: 'limit', required: false, type: Number, example: 20 })
  @ApiResponse({ status: 200, description: 'Paginated list of courses' })
  async findAll(
    @Query('departmentId', new ParseIntPipe({ optional: true }))
    departmentId?: number,
    @Query('level') level?: string,
    @Query('status') status?: CourseStatus,
    @Query('search') search?: string,
    @Query('page', new ParseIntPipe({ optional: true })) page = 1,
    @Query('limit', new ParseIntPipe({ optional: true })) limit = 20,
  ) {
    return this.coursesService.findAll(
      departmentId,
      level,
      status,
      search,
      page,
      limit,
    );
  }

  @Get('department/:deptId')
  @ApiOperation({
    summary: 'Get courses by department',
    description: `
## Get Courses by Department

Retrieves all courses offered by a specific department.

### Access Control
- **Authentication Required**: No (Public endpoint)
- **Roles Required**: None
    `,
  })
  @ApiParam({ name: 'deptId', description: 'Department ID', type: Number })
  @ApiResponse({ status: 200, description: 'List of courses' })
  @ApiResponse({ status: 404, description: 'Department not found' })
  async findByDepartment(
    @Param('deptId', ParseIntPipe) deptId: number,
  ) {
    return this.coursesService.findByDepartment(deptId);
  }

  @Get(':id')
  @ApiOperation({
    summary: 'Get course by ID',
    description: `
## Get Course Details

Retrieves detailed information about a specific course.

### Access Control
- **Authentication Required**: No (Public endpoint)
- **Roles Required**: None

### Response Includes
- Course information (code, name, credits)
- Prerequisites count
- Available sections count
    `,
  })
  @ApiParam({ name: 'id', description: 'Course ID', type: Number })
  @ApiResponse({ status: 200, description: 'Course details' })
  @ApiResponse({ status: 404, description: 'Course not found' })
  async findById(@Param('id', ParseIntPipe) id: number) {
    const course = await this.coursesService.findById(id);
    const prerequisites = await this.coursesService.getPrerequisites(id);
    
    return {
      ...course,
      prerequisitesCount: prerequisites.length,
      sectionsCount: course.sections.length,
    };
  }

  @Post()
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Create new course',
    description: `
## Create New Course

Creates a new course in the catalog.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token recommended)
- **Roles Required**: ADMIN, IT_ADMIN, INSTRUCTOR

### Required Fields
- Course code (unique)
- Course name
- Credit hours
- Department ID

### Notes
- Course codes must be unique
- New courses are active by default
    `,
  })
  @ApiBody({ type: CreateCourseDto })
  @ApiResponse({ status: 201, description: 'Course created successfully' })
  @ApiResponse({ status: 400, description: 'Invalid input data' })
  @ApiResponse({ status: 409, description: 'Course code already exists' })
  async create(@Body() dto: CreateCourseDto) {
    return this.coursesService.create(dto);
  }

  @Patch(':id')
  @ApiOperation({
    summary: 'Update course',
    description: `
## Update Course

Updates an existing course's information.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token recommended)
- **Roles Required**: ADMIN, IT_ADMIN, INSTRUCTOR
    `,
  })
  @ApiParam({ name: 'id', description: 'Course ID', type: Number })
  @ApiBody({ type: UpdateCourseDto })
  @ApiResponse({ status: 200, description: 'Course updated successfully' })
  @ApiResponse({ status: 400, description: 'Invalid input data' })
  @ApiResponse({ status: 404, description: 'Course not found' })
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateCourseDto,
  ) {
    return this.coursesService.update(id, dto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({
    summary: 'Delete course',
    description: `
## Delete Course (Soft Delete)

Soft deletes a course from the system.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token recommended)
- **Roles Required**: ADMIN, IT_ADMIN

### Notes
- This performs a soft delete (course is marked as inactive)
- Courses with active enrollments cannot be deleted
    `,
  })
  @ApiParam({ name: 'id', description: 'Course ID', type: Number })
  @ApiResponse({ status: 204, description: 'Course deleted successfully' })
  @ApiResponse({ status: 400, description: 'Cannot delete course with enrollments' })
  @ApiResponse({ status: 404, description: 'Course not found' })
  async delete(@Param('id', ParseIntPipe) id: number) {
    await this.coursesService.softDelete(id);
  }

  @Get(':id/prerequisites')
  @ApiOperation({
    summary: 'Get course prerequisites',
    description: `
## Get Course Prerequisites

Retrieves all prerequisite courses for a specific course.

### Access Control
- **Authentication Required**: No (Public endpoint)
- **Roles Required**: None

### Response
Returns list of courses that must be completed before enrolling.
    `,
  })
  @ApiParam({ name: 'id', description: 'Course ID', type: Number })
  @ApiResponse({ status: 200, description: 'List of prerequisite courses' })
  @ApiResponse({ status: 404, description: 'Course not found' })
  async getPrerequisites(@Param('id', ParseIntPipe) id: number) {
    return this.coursesService.getPrerequisites(id);
  }

  @Post(':id/prerequisites')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Add prerequisite to course',
    description: `
## Add Course Prerequisite

Adds a prerequisite requirement to a course.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token recommended)
- **Roles Required**: ADMIN, IT_ADMIN

### Notes
- Cannot add circular prerequisites
- A course cannot be its own prerequisite
    `,
  })
  @ApiParam({ name: 'id', description: 'Course ID', type: Number })
  @ApiBody({ type: CreatePrerequisiteDto })
  @ApiResponse({ status: 201, description: 'Prerequisite added successfully' })
  @ApiResponse({ status: 400, description: 'Invalid prerequisite or circular dependency' })
  @ApiResponse({ status: 404, description: 'Course not found' })
  async addPrerequisite(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: CreatePrerequisiteDto,
  ) {
    return this.coursesService.addPrerequisite(
      id,
      dto.prerequisiteCourseId,
      dto.isMandatory,
    );
  }

  @Delete(':id/prerequisites/:prereqId')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({
    summary: 'Remove prerequisite from course',
    description: `
## Remove Course Prerequisite

Removes a prerequisite requirement from a course.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token recommended)
- **Roles Required**: ADMIN, IT_ADMIN
    `,
  })
  @ApiParam({ name: 'id', description: 'Course ID', type: Number })
  @ApiParam({ name: 'prereqId', description: 'Prerequisite Course ID', type: Number })
  @ApiResponse({ status: 204, description: 'Prerequisite removed successfully' })
  @ApiResponse({ status: 404, description: 'Course or prerequisite not found' })
  async removePrerequisite(
    @Param('id', ParseIntPipe) id: number,
    @Param('prereqId', ParseIntPipe) prereqId: number,
  ) {
    await this.coursesService.removePrerequisite(id, prereqId);
  }
}
