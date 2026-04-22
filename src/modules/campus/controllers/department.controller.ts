import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Param,
  Body,
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
  ApiBody,
} from '@nestjs/swagger';
import { DepartmentService } from '../services/department.service';
import {
  CreateDepartmentDto,
  UpdateDepartmentDto,
  DepartmentDto,
} from '../dtos/department.dto';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../auth/guards/roles.guard';
import { Roles } from '../../auth/roles.decorator';
import { RoleName } from '../../auth/entities/role.entity';

@ApiTags('🏢 Departments')
@Controller('api')
@UseGuards(JwtAuthGuard, RolesGuard)
@ApiBearerAuth('JWT-auth')
export class DepartmentController {
  constructor(private readonly departmentService: DepartmentService) {}

  @Get('departments')
  @Roles(
    RoleName.IT_ADMIN,
    RoleName.ADMIN,
    RoleName.INSTRUCTOR,
    RoleName.TA,
    RoleName.STUDENT,
  )
  @ApiOperation({
    summary: 'List all departments',
    description: `
## List All Departments

Retrieves all departments across campuses.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: All roles (STUDENT, INSTRUCTOR, TA, ADMIN, IT_ADMIN)
    `,
  })
  @ApiResponse({ status: 200, description: 'List of all departments' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async findAll(): Promise<DepartmentDto[]> {
    return this.departmentService.findAll() as Promise<DepartmentDto[]>;
  }

  @Get('campuses/:campusId/departments')
  @Roles(
    RoleName.IT_ADMIN,
    RoleName.ADMIN,
    RoleName.INSTRUCTOR,
    RoleName.TA,
    RoleName.STUDENT,
  )
  @ApiOperation({
    summary: 'List departments by campus',
    description: `
## List Departments in Campus

Retrieves all departments belonging to a specific campus.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: All roles (STUDENT, INSTRUCTOR, TA, ADMIN, IT_ADMIN)
    `,
  })
  @ApiParam({ name: 'campusId', description: 'Campus ID', type: Number })
  @ApiResponse({ status: 200, description: 'List of departments' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 404, description: 'Campus not found' })
  async findByCampusId(
    @Param('campusId', ParseIntPipe) campusId: number,
  ): Promise<DepartmentDto[]> {
    return this.departmentService.findByCampusId(campusId) as Promise<
      DepartmentDto[]
    >;
  }

  @Post('departments')
  @Roles(RoleName.IT_ADMIN, RoleName.ADMIN)
  @HttpCode(201)
  @ApiOperation({
    summary: 'Create new department',
    description: `
## Create New Department

Creates a new department within a campus.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: ADMIN, IT_ADMIN only
    `,
  })
  @ApiBody({ type: CreateDepartmentDto })
  @ApiResponse({ status: 201, description: 'Department created successfully' })
  @ApiResponse({ status: 400, description: 'Invalid input data' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - Admin access required' })
  async create(@Body() dto: CreateDepartmentDto): Promise<DepartmentDto> {
    return this.departmentService.create(dto) as Promise<DepartmentDto>;
  }

  @Get('departments/:id')
  @Roles(
    RoleName.IT_ADMIN,
    RoleName.ADMIN,
    RoleName.INSTRUCTOR,
    RoleName.TA,
    RoleName.STUDENT,
  )
  @ApiOperation({
    summary: 'Get department by ID',
    description: `
## Get Department Details

Retrieves details of a specific department.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: All roles (STUDENT, INSTRUCTOR, TA, ADMIN, IT_ADMIN)
    `,
  })
  @ApiParam({ name: 'id', description: 'Department ID', type: Number })
  @ApiResponse({ status: 200, description: 'Department details' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 404, description: 'Department not found' })
  async findById(
    @Param('id', ParseIntPipe) id: number,
  ): Promise<DepartmentDto> {
    return this.departmentService.findById(id) as Promise<DepartmentDto>;
  }

  @Put('departments/:id')
  @Roles(RoleName.IT_ADMIN, RoleName.ADMIN)
  @ApiOperation({
    summary: 'Update department',
    description: `
## Update Department

Updates an existing department.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: ADMIN, IT_ADMIN only
    `,
  })
  @ApiParam({ name: 'id', description: 'Department ID', type: Number })
  @ApiBody({ type: UpdateDepartmentDto })
  @ApiResponse({ status: 200, description: 'Department updated successfully' })
  @ApiResponse({ status: 400, description: 'Invalid input data' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - Admin access required' })
  @ApiResponse({ status: 404, description: 'Department not found' })
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateDepartmentDto,
  ): Promise<DepartmentDto> {
    return this.departmentService.update(id, dto) as Promise<DepartmentDto>;
  }

  @Delete('departments/:id')
  @Roles(RoleName.IT_ADMIN, RoleName.ADMIN)
  @HttpCode(204)
  @ApiOperation({
    summary: 'Delete department',
    description: `
## Delete Department

Deletes a department from the system.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: ADMIN, IT_ADMIN only

### ⚠️ Warning
Departments with programs or courses cannot be deleted.
    `,
  })
  @ApiParam({ name: 'id', description: 'Department ID', type: Number })
  @ApiResponse({ status: 204, description: 'Department deleted successfully' })
  @ApiResponse({ status: 400, description: 'Cannot delete department with programs' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - Admin access required' })
  @ApiResponse({ status: 404, description: 'Department not found' })
  async delete(@Param('id', ParseIntPipe) id: number): Promise<void> {
    return this.departmentService.delete(id);
  }
}
