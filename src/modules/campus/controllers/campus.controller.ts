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
import { CampusService } from '../services/campus.service';
import {
  CreateCampusDto,
  UpdateCampusDto,
  CampusDto,
} from '../dtos/campus.dto';
import { Status } from '../enums/status.enum';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../auth/guards/roles.guard';
import { Roles } from '../../auth/roles.decorator';
import { RoleName } from '../../auth/entities/role.entity';

@ApiTags('🏛️ Campus')
@Controller('api/campuses')
@UseGuards(JwtAuthGuard, RolesGuard)
@ApiBearerAuth('JWT-auth')
export class CampusController {
  constructor(private readonly campusService: CampusService) {}

  @Get()
  @Roles(
    RoleName.IT_ADMIN,
    RoleName.ADMIN,
    RoleName.INSTRUCTOR,
    RoleName.TA,
    RoleName.STUDENT,
  )
  @ApiOperation({
    summary: 'List all campuses',
    description: `
## List All Campuses

Retrieves all campuses in the system with optional status filter.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: All roles (STUDENT, INSTRUCTOR, TA, ADMIN, IT_ADMIN)

### Filtering
Use the \`status\` query parameter to filter by campus status.
    `,
  })
  @ApiQuery({ name: 'status', required: false, enum: ['active', 'inactive'], description: 'Filter by status' })
  @ApiResponse({ status: 200, description: 'List of campuses' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async findAll(@Query('status') status?: string): Promise<CampusDto[]> {
    return this.campusService.findAll(status as Status) as Promise<CampusDto[]>;
  }

  @Post()
  @Roles(RoleName.IT_ADMIN, RoleName.ADMIN)
  @HttpCode(201)
  @ApiOperation({
    summary: 'Create new campus',
    description: `
## Create New Campus

Creates a new campus in the system.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: ADMIN, IT_ADMIN only

### Notes
- Campus names must be unique
- New campuses are active by default
    `,
  })
  @ApiBody({ type: CreateCampusDto })
  @ApiResponse({ status: 201, description: 'Campus created successfully' })
  @ApiResponse({ status: 400, description: 'Invalid input data' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - Admin access required' })
  @ApiResponse({ status: 409, description: 'Campus name already exists' })
  async create(@Body() dto: CreateCampusDto): Promise<CampusDto> {
    return this.campusService.create(dto) as Promise<CampusDto>;
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
    summary: 'Get campus by ID',
    description: `
## Get Campus Details

Retrieves details of a specific campus.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: All roles (STUDENT, INSTRUCTOR, TA, ADMIN, IT_ADMIN)
    `,
  })
  @ApiParam({ name: 'id', description: 'Campus ID', type: Number })
  @ApiResponse({ status: 200, description: 'Campus details' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 404, description: 'Campus not found' })
  async findById(@Param('id', ParseIntPipe) id: number): Promise<CampusDto> {
    return this.campusService.findById(id) as Promise<CampusDto>;
  }

  @Put(':id')
  @Roles(RoleName.IT_ADMIN, RoleName.ADMIN)
  @ApiOperation({
    summary: 'Update campus',
    description: `
## Update Campus

Updates an existing campus.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: ADMIN, IT_ADMIN only
    `,
  })
  @ApiParam({ name: 'id', description: 'Campus ID', type: Number })
  @ApiBody({ type: UpdateCampusDto })
  @ApiResponse({ status: 200, description: 'Campus updated successfully' })
  @ApiResponse({ status: 400, description: 'Invalid input data' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - Admin access required' })
  @ApiResponse({ status: 404, description: 'Campus not found' })
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateCampusDto,
  ): Promise<CampusDto> {
    return this.campusService.update(id, dto) as Promise<CampusDto>;
  }

  @Delete(':id')
  @Roles(RoleName.IT_ADMIN, RoleName.ADMIN)
  @HttpCode(204)
  @ApiOperation({
    summary: 'Delete campus',
    description: `
## Delete Campus

Deletes a campus from the system.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: ADMIN, IT_ADMIN only

### ⚠️ Warning
- Campuses with departments cannot be deleted
- Consider deactivating instead of deleting
    `,
  })
  @ApiParam({ name: 'id', description: 'Campus ID', type: Number })
  @ApiResponse({ status: 204, description: 'Campus deleted successfully' })
  @ApiResponse({ status: 400, description: 'Cannot delete campus with departments' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - Admin access required' })
  @ApiResponse({ status: 404, description: 'Campus not found' })
  async delete(@Param('id', ParseIntPipe) id: number): Promise<void> {
    return this.campusService.delete(id);
  }
}
