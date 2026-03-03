import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Patch,
  Body,
  Param,
  Req,
  UseGuards,
  ParseIntPipe,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiParam,
  ApiBody,
  ApiResponse,
  ApiBearerAuth,
} from '@nestjs/swagger';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../auth/guards/roles.guard';
import { Roles } from '../../auth/roles.decorator';
import { RoleName } from '../../auth/entities/role.entity';
import { CourseStructureService } from '../services';
import {
  CreateStructureDto,
  UpdateStructureDto,
  ReorderStructureDto,
} from '../dto';

@ApiTags('🏗️ Course Structure')
@ApiBearerAuth('JWT-auth')
@Controller('api/courses/:courseId/structure')
@UseGuards(JwtAuthGuard, RolesGuard)
export class CourseStructureController {
  constructor(private readonly structureService: CourseStructureService) {}

  @Get()
  @ApiOperation({
    summary: 'Get course structure',
    description: `
## Get Course Content Structure

Returns the course's content organization (lectures, sections, labs) grouped by week.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles**: ALL

### Response Structure
- \`data\`: Flat list of all structure items
- \`byWeek\`: Items grouped by week number for easy display

### Use Cases
- Building course syllabus view
- Navigation sidebar
- Progress tracking
    `,
  })
  @ApiParam({ name: 'courseId', description: 'Course ID', type: Number, example: 1 })
  @ApiResponse({ status: 200, description: 'Course structure retrieved' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async findAll(@Param('courseId', ParseIntPipe) courseId: number) {
    return this.structureService.findAll(courseId);
  }

  @Get(':id')
  @ApiOperation({
    summary: 'Get structure item by ID',
    description: `
## Get Structure Item Details

Returns detailed information about a specific structure item.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles**: ALL
    `,
  })
  @ApiParam({ name: 'courseId', description: 'Course ID', type: Number, example: 1 })
  @ApiParam({ name: 'id', description: 'Structure item ID', type: Number, example: 1 })
  @ApiResponse({ status: 200, description: 'Structure item details' })
  @ApiResponse({ status: 404, description: 'Structure item not found' })
  async findById(
    @Param('courseId', ParseIntPipe) courseId: number,
    @Param('id', ParseIntPipe) id: number,
  ) {
    return this.structureService.findById(id);
  }

  @Post()
  @Roles(RoleName.INSTRUCTOR, RoleName.ADMIN, RoleName.IT_ADMIN)
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Create structure item',
    description: `
## Create Course Structure Item

Adds a new content organization item (lecture, section, lab) to the course.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles**: INSTRUCTOR, ADMIN only (TAs cannot modify structure)

### Organization Types
- \`lecture\`: Main lecture content
- \`section\`: Discussion or tutorial section
- \`lab\`: Hands-on lab session
- \`tutorial\`: Tutorial session

### Ordering
- Items are automatically ordered within their week
- Use \`orderIndex\` to specify custom order
- Use PATCH /reorder to reorder multiple items
    `,
  })
  @ApiParam({ name: 'courseId', description: 'Course ID', type: Number, example: 1 })
  @ApiBody({ type: CreateStructureDto })
  @ApiResponse({ status: 201, description: 'Structure item created' })
  @ApiResponse({ status: 400, description: 'Invalid input data' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  async create(
    @Param('courseId', ParseIntPipe) courseId: number,
    @Body() dto: CreateStructureDto,
    @Req() req: any,
  ) {
    const userId = req.user.userId || req.user.id;
    const roles = this.extractRoles(req.user);
    return this.structureService.create(courseId, dto, userId, roles);
  }

  @Put(':id')
  @Roles(RoleName.INSTRUCTOR, RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'Update structure item',
    description: `
## Update Structure Item

Updates an existing structure item.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles**: INSTRUCTOR, ADMIN only
    `,
  })
  @ApiParam({ name: 'courseId', description: 'Course ID', type: Number, example: 1 })
  @ApiParam({ name: 'id', description: 'Structure item ID', type: Number, example: 1 })
  @ApiBody({ type: UpdateStructureDto })
  @ApiResponse({ status: 200, description: 'Structure item updated' })
  @ApiResponse({ status: 404, description: 'Structure item not found' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  async update(
    @Param('courseId', ParseIntPipe) courseId: number,
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateStructureDto,
    @Req() req: any,
  ) {
    const userId = req.user.userId || req.user.id;
    const roles = this.extractRoles(req.user);
    return this.structureService.update(id, dto, userId, roles);
  }

  @Delete(':id')
  @Roles(RoleName.INSTRUCTOR, RoleName.ADMIN, RoleName.IT_ADMIN)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Delete structure item',
    description: `
## Delete Structure Item

Removes a structure item from the course.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles**: INSTRUCTOR, ADMIN only

### Note
Deleting a structure item does NOT delete associated materials.
    `,
  })
  @ApiParam({ name: 'courseId', description: 'Course ID', type: Number, example: 1 })
  @ApiParam({ name: 'id', description: 'Structure item ID', type: Number, example: 1 })
  @ApiResponse({ status: 200, description: 'Structure item deleted' })
  @ApiResponse({ status: 404, description: 'Structure item not found' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  async delete(
    @Param('courseId', ParseIntPipe) courseId: number,
    @Param('id', ParseIntPipe) id: number,
    @Req() req: any,
  ) {
    const userId = req.user.userId || req.user.id;
    const roles = this.extractRoles(req.user);
    return this.structureService.delete(id, userId, roles);
  }

  @Patch('reorder')
  @Roles(RoleName.INSTRUCTOR, RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'Reorder structure items',
    description: `
## Reorder Structure Items

Changes the order of structure items within a course.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles**: INSTRUCTOR, ADMIN only

### Request Body
Provide array of structure item IDs in the desired new order.

### Example
\`\`\`json
{
  "orderIds": [3, 1, 2, 4]
}
\`\`\`
This would reorder items so that:
- ID 3 is first (orderIndex: 0)
- ID 1 is second (orderIndex: 1)
- ID 2 is third (orderIndex: 2)
- ID 4 is fourth (orderIndex: 3)
    `,
  })
  @ApiParam({ name: 'courseId', description: 'Course ID', type: Number, example: 1 })
  @ApiBody({ type: ReorderStructureDto })
  @ApiResponse({ status: 200, description: 'Items reordered successfully' })
  @ApiResponse({ status: 400, description: 'Invalid input data' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  @ApiResponse({ status: 404, description: 'Some items not found' })
  async reorder(
    @Param('courseId', ParseIntPipe) courseId: number,
    @Body() dto: ReorderStructureDto,
    @Req() req: any,
  ) {
    const userId = req.user.userId || req.user.id;
    const roles = this.extractRoles(req.user);
    return this.structureService.reorder(courseId, dto, userId, roles);
  }

  private extractRoles(user: any): string[] {
    if (Array.isArray(user.roles)) {
      return user.roles.map((r: any) => (typeof r === 'string' ? r : r.name || r.roleName));
    }
    return [];
  }
}
