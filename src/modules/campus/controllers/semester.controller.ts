import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Param,
  Body,
  Query,
  UseGuards,
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
import { SemesterService } from '../services/semester.service';
import {
  CreateSemesterDto,
  UpdateSemesterDto,
  SemesterDto,
} from '../dtos/semester.dto';
import { SemesterStatus } from '../enums/semester-status.enum';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../auth/guards/roles.guard';
import { Roles } from '../../auth/roles.decorator';
import { RoleName } from '../../auth/entities/role.entity';

@ApiTags('📅 Semesters')
@Controller('api/semesters')
@UseGuards(JwtAuthGuard, RolesGuard)
@ApiBearerAuth('JWT-auth')
export class SemesterController {
  constructor(private readonly semesterService: SemesterService) {}

  @Get()
  @Roles(
    RoleName.IT_ADMIN,
    RoleName.ADMIN,
    RoleName.INSTRUCTOR,
    RoleName.TA,
    RoleName.STUDENT,
  )
  @ApiOperation({
    summary: 'List all semesters',
    description: `
## List All Semesters

Retrieves all semesters with optional filters.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: All roles (STUDENT, INSTRUCTOR, TA, ADMIN, IT_ADMIN)

### Filtering
- \`status\`: Filter by semester status (upcoming, active, completed)
- \`year\`: Filter by academic year
    `,
  })
  @ApiQuery({ name: 'status', required: false, enum: ['upcoming', 'active', 'completed'] })
  @ApiQuery({ name: 'year', required: false, type: String, example: '2024' })
  @ApiResponse({ status: 200, description: 'List of semesters' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async findAll(
    @Query('status') status?: string,
    @Query('year') year?: string,
  ): Promise<SemesterDto[]> {
    const yearNum = year ? parseInt(year, 10) : undefined;
    return this.semesterService.findAll(status as SemesterStatus, yearNum) as Promise<
      SemesterDto[]
    >;
  }

  @Get('current')
  @Roles(
    RoleName.IT_ADMIN,
    RoleName.ADMIN,
    RoleName.INSTRUCTOR,
    RoleName.TA,
    RoleName.STUDENT,
  )
  @ApiOperation({
    summary: 'Get current semester',
    description: `
## Get Current Active Semester

Returns the currently active semester.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: All roles (STUDENT, INSTRUCTOR, TA, ADMIN, IT_ADMIN)

### Notes
Only one semester can be active at a time.
    `,
  })
  @ApiResponse({ status: 200, description: 'Current semester details' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 404, description: 'No active semester found' })
  async getCurrentSemester(): Promise<SemesterDto> {
    return this.semesterService.findCurrentSemester() as Promise<SemesterDto>;
  }

  @Post()
  @Roles(RoleName.IT_ADMIN, RoleName.ADMIN, RoleName.DEPARTMENT_HEAD)
  @HttpCode(201)
  @ApiOperation({
    summary: 'Create new semester',
    description: `
## Create New Semester

Creates a new semester period.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: ADMIN, IT_ADMIN only

### Semester Properties
- Name (e.g., "Fall 2024", "Spring 2025")
- Start and end dates
- Registration period
- Status (upcoming, active, completed)
    `,
  })
  @ApiBody({ type: CreateSemesterDto })
  @ApiResponse({ status: 201, description: 'Semester created successfully' })
  @ApiResponse({ status: 400, description: 'Invalid input or date conflicts' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - Admin access required' })
  async create(@Body() dto: CreateSemesterDto): Promise<SemesterDto> {
    return this.semesterService.create(dto) as Promise<SemesterDto>;
  }

  @Get(':id')
  @Roles(
    RoleName.IT_ADMIN,
    RoleName.ADMIN,
    RoleName.INSTRUCTOR,
    RoleName.TA,
    RoleName.STUDENT,
  )
  @ApiOperation({
    summary: 'Get semester by ID',
    description: `
## Get Semester Details

Retrieves details of a specific semester.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: All roles (STUDENT, INSTRUCTOR, TA, ADMIN, IT_ADMIN)
    `,
  })
  @ApiParam({ name: 'id', description: 'Semester ID', type: Number })
  @ApiResponse({ status: 200, description: 'Semester details' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 404, description: 'Semester not found' })
  async findById(@Param('id', ParseIntPipe) id: number): Promise<SemesterDto> {
    return this.semesterService.findById(id) as Promise<SemesterDto>;
  }

  @Put(':id')
  @Roles(RoleName.IT_ADMIN, RoleName.ADMIN, RoleName.DEPARTMENT_HEAD)
  @ApiOperation({
    summary: 'Update semester',
    description: `
## Update Semester

Updates an existing semester.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: ADMIN, IT_ADMIN only

### Notes
Be careful changing dates on active semesters.
    `,
  })
  @ApiParam({ name: 'id', description: 'Semester ID', type: Number })
  @ApiBody({ type: UpdateSemesterDto })
  @ApiResponse({ status: 200, description: 'Semester updated successfully' })
  @ApiResponse({ status: 400, description: 'Invalid input data' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - Admin access required' })
  @ApiResponse({ status: 404, description: 'Semester not found' })
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateSemesterDto,
  ): Promise<SemesterDto> {
    return this.semesterService.update(id, dto) as Promise<SemesterDto>;
  }

  @Delete(':id')
  @Roles(RoleName.IT_ADMIN, RoleName.ADMIN, RoleName.DEPARTMENT_HEAD)
  @HttpCode(204)
  @ApiOperation({
    summary: 'Delete semester',
    description: `
## Delete Semester

Deletes a semester from the system.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: ADMIN, IT_ADMIN only

### ⚠️ Warning
- Active semesters cannot be deleted
- Semesters with course sections cannot be deleted
    `,
  })
  @ApiParam({ name: 'id', description: 'Semester ID', type: Number })
  @ApiResponse({ status: 204, description: 'Semester deleted successfully' })
  @ApiResponse({ status: 400, description: 'Cannot delete active semester' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - Admin access required' })
  @ApiResponse({ status: 404, description: 'Semester not found' })
  async delete(@Param('id', ParseIntPipe) id: number): Promise<void> {
    return this.semesterService.delete(id);
  }
}
