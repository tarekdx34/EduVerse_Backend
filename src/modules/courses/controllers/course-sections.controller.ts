import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Body,
  Param,
  Query,
  UseGuards,
  HttpStatus,
  HttpCode,
  ParseIntPipe,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
  ApiParam,
  ApiQuery,
  ApiBody,
} from '@nestjs/swagger';
import { CourseSectionsService } from '../services/course-sections.service';
import { CreateSectionDto, UpdateSectionDto } from '../dtos';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../auth/guards/roles.guard';
import { Roles } from '../../auth/roles.decorator';
import { RoleName } from '../../auth/entities/role.entity';

@ApiTags('📝 Course Sections')
@Controller('api/sections')
export class CourseSectionsController {
  constructor(
    private readonly sectionsService: CourseSectionsService,
  ) {}

  @Get('course/:courseId')
  @ApiOperation({
    summary: 'Get sections by course',
    description: `
## Get Course Sections

Retrieves all sections for a specific course, optionally filtered by semester.

### Access Control
- **Authentication Required**: No (Public endpoint)
- **Roles Required**: None

### Filtering
Use \`semesterId\` to filter sections for a specific semester.
    `,
  })
  @ApiParam({ name: 'courseId', description: 'Course ID', type: Number })
  @ApiQuery({ name: 'semesterId', required: false, type: Number })
  @ApiResponse({ status: 200, description: 'List of course sections' })
  @ApiResponse({ status: 404, description: 'Course not found' })
  async findByCourseId(
    @Param('courseId', ParseIntPipe) courseId: number,
    @Query('semesterId', new ParseIntPipe({ optional: true }))
    semesterId?: number,
  ) {
    return this.sectionsService.findByCourseId(courseId, semesterId);
  }

  @Get(':id')
  @ApiOperation({
    summary: 'Get section by ID',
    description: `
## Get Section Details

Retrieves detailed information about a specific course section.

### Access Control
- **Authentication Required**: No (Public endpoint)
- **Roles Required**: None

### Response Includes
- Section information (number, capacity)
- Instructor details
- Schedule information
- Current enrollment count
    `,
  })
  @ApiParam({ name: 'id', description: 'Section ID', type: Number })
  @ApiResponse({ status: 200, description: 'Section details' })
  @ApiResponse({ status: 404, description: 'Section not found' })
  async findById(@Param('id', ParseIntPipe) id: number) {
    return this.sectionsService.findById(id);
  }

  @Post()
  @HttpCode(HttpStatus.CREATED)
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({
    summary: 'Create new section',
    description: `
## Create Course Section

Creates a new section for a course.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token recommended)
- **Roles Required**: ADMIN, IT_ADMIN, INSTRUCTOR

### Required Fields
- Course ID
- Semester ID
- Section number
- Capacity
- Instructor ID
    `,
  })
  @ApiBody({ type: CreateSectionDto })
  @ApiResponse({ status: 201, description: 'Section created successfully' })
  @ApiResponse({ status: 400, description: 'Invalid input data' })
  @ApiResponse({ status: 409, description: 'Section number already exists for this course/semester' })
  async create(@Body() dto: CreateSectionDto) {
    return this.sectionsService.create(dto);
  }

  @Patch(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({
    summary: 'Update section',
    description: `
## Update Course Section

Updates an existing course section.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token recommended)
- **Roles Required**: ADMIN, IT_ADMIN, INSTRUCTOR (section owner)
    `,
  })
  @ApiParam({ name: 'id', description: 'Section ID', type: Number })
  @ApiBody({ type: UpdateSectionDto })
  @ApiResponse({ status: 200, description: 'Section updated successfully' })
  @ApiResponse({ status: 400, description: 'Invalid input data' })
  @ApiResponse({ status: 404, description: 'Section not found' })
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateSectionDto,
  ) {
    return this.sectionsService.update(id, dto);
  }

  @Patch(':id/enrollment')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({
    summary: 'Update section enrollment count',
    description: `
## Update Section Enrollment

Updates the current enrollment count for a section.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token recommended)
- **Roles Required**: ADMIN, IT_ADMIN, INSTRUCTOR

### Notes
This is typically called automatically by the enrollment system.
    `,
  })
  @ApiParam({ name: 'id', description: 'Section ID', type: Number })
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        currentEnrollment: { type: 'number', example: 25 },
      },
    },
  })
  @ApiResponse({ status: 200, description: 'Enrollment count updated' })
  @ApiResponse({ status: 404, description: 'Section not found' })
  async updateEnrollment(
    @Param('id', ParseIntPipe) id: number,
    @Body('currentEnrollment') currentEnrollment: number,
  ) {
    await this.sectionsService.updateEnrollment(id, currentEnrollment);
    return this.sectionsService.findById(id);
  }
}
