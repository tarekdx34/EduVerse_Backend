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
import { ProgramService } from '../services/program.service';
import {
  CreateProgramDto,
  UpdateProgramDto,
  ProgramDto,
} from '../dtos/program.dto';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../auth/guards/roles.guard';
import { Roles } from '../../auth/roles.decorator';
import { RoleName } from '../../auth/entities/role.entity';

@ApiTags('📚 Programs')
@Controller('api')
@UseGuards(JwtAuthGuard, RolesGuard)
@ApiBearerAuth('JWT-auth')
export class ProgramController {
  constructor(private readonly programService: ProgramService) {}

  @Get('departments/:deptId/programs')
  @Roles(
    RoleName.IT_ADMIN,
    RoleName.ADMIN,
    RoleName.INSTRUCTOR,
    RoleName.TA,
    RoleName.STUDENT,
  )
  @ApiOperation({
    summary: 'List programs by department',
    description: `
## List Programs in Department

Retrieves all academic programs belonging to a specific department.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: All roles (STUDENT, INSTRUCTOR, TA, ADMIN, IT_ADMIN)
    `,
  })
  @ApiParam({ name: 'deptId', description: 'Department ID', type: Number })
  @ApiResponse({ status: 200, description: 'List of programs' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 404, description: 'Department not found' })
  async findByDepartmentId(
    @Param('deptId', ParseIntPipe) deptId: number,
  ): Promise<ProgramDto[]> {
    return this.programService.findByDepartmentId(deptId) as Promise<
      ProgramDto[]
    >;
  }

  @Post('programs')
  @Roles(RoleName.IT_ADMIN, RoleName.ADMIN)
  @HttpCode(201)
  @ApiOperation({
    summary: 'Create new program',
    description: `
## Create New Academic Program

Creates a new academic program within a department.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: ADMIN, IT_ADMIN only

### Program Types
- Bachelor's, Master's, PhD, Certificate, etc.
    `,
  })
  @ApiBody({ type: CreateProgramDto })
  @ApiResponse({ status: 201, description: 'Program created successfully' })
  @ApiResponse({ status: 400, description: 'Invalid input data' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - Admin access required' })
  async create(@Body() dto: CreateProgramDto): Promise<ProgramDto> {
    return this.programService.create(dto) as Promise<ProgramDto>;
  }

  @Get('programs/:id')
  @Roles(
    RoleName.IT_ADMIN,
    RoleName.ADMIN,
    RoleName.INSTRUCTOR,
    RoleName.TA,
    RoleName.STUDENT,
  )
  @ApiOperation({
    summary: 'Get program by ID',
    description: `
## Get Program Details

Retrieves details of a specific academic program.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: All roles (STUDENT, INSTRUCTOR, TA, ADMIN, IT_ADMIN)
    `,
  })
  @ApiParam({ name: 'id', description: 'Program ID', type: Number })
  @ApiResponse({ status: 200, description: 'Program details' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 404, description: 'Program not found' })
  async findById(@Param('id', ParseIntPipe) id: number): Promise<ProgramDto> {
    return this.programService.findById(id) as Promise<ProgramDto>;
  }

  @Put('programs/:id')
  @Roles(RoleName.IT_ADMIN, RoleName.ADMIN)
  @ApiOperation({
    summary: 'Update program',
    description: `
## Update Academic Program

Updates an existing academic program.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: ADMIN, IT_ADMIN only
    `,
  })
  @ApiParam({ name: 'id', description: 'Program ID', type: Number })
  @ApiBody({ type: UpdateProgramDto })
  @ApiResponse({ status: 200, description: 'Program updated successfully' })
  @ApiResponse({ status: 400, description: 'Invalid input data' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - Admin access required' })
  @ApiResponse({ status: 404, description: 'Program not found' })
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateProgramDto,
  ): Promise<ProgramDto> {
    return this.programService.update(id, dto) as Promise<ProgramDto>;
  }

  @Delete('programs/:id')
  @Roles(RoleName.IT_ADMIN, RoleName.ADMIN)
  @HttpCode(204)
  @ApiOperation({
    summary: 'Delete program',
    description: `
## Delete Academic Program

Deletes an academic program from the system.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: ADMIN, IT_ADMIN only

### ⚠️ Warning
Programs with enrolled students cannot be deleted.
    `,
  })
  @ApiParam({ name: 'id', description: 'Program ID', type: Number })
  @ApiResponse({ status: 204, description: 'Program deleted successfully' })
  @ApiResponse({ status: 400, description: 'Cannot delete program with students' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - Admin access required' })
  @ApiResponse({ status: 404, description: 'Program not found' })
  async delete(@Param('id', ParseIntPipe) id: number): Promise<void> {
    return this.programService.delete(id);
  }
}
