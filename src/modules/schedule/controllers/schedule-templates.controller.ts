import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  Query,
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
import { ScheduleTemplatesService } from '../services/schedule-templates.service';
import {
  CreateScheduleTemplateDto,
  UpdateScheduleTemplateDto,
  ApplyTemplateToSectionDto,
  BulkApplyTemplateDto,
  QueryScheduleTemplateDto,
} from '../dto';

@ApiTags('📋 Schedule Templates')
@ApiBearerAuth('JWT-auth')
@Controller('api/schedule-templates')
@UseGuards(JwtAuthGuard, RolesGuard)
export class ScheduleTemplatesController {
  constructor(private readonly templatesService: ScheduleTemplatesService) {}

  @Get()
  @ApiOperation({
    summary: 'List schedule templates',
    description: `
## List Schedule Templates

Returns paginated list of schedule templates.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles**: ALL

### Visibility Rules
- **Admins/IT_Admins**: See all templates
- **Department Heads**: See university-wide and own department templates
- **Others**: See active university-wide templates only

### Query Parameters
- \`scheduleType\`: Filter by type
- \`departmentId\`: Filter by department
- \`isActive\`: Filter by active status
- \`search\`: Search in name or description
    `,
  })
  @ApiResponse({ status: 200, description: 'Paginated list of templates' })
  async findAll(@Query() query: QueryScheduleTemplateDto, @Req() req: any) {
    const userId = req.user.userId || req.user.id;
    const roles = this.extractRoles(req.user);
    return this.templatesService.findAll(query, userId, roles);
  }

  @Get(':id')
  @ApiOperation({
    summary: 'Get template by ID',
    description: 'Returns detailed information about a specific schedule template including all time slots.',
  })
  @ApiParam({ name: 'id', description: 'Template ID', type: Number })
  @ApiResponse({ status: 200, description: 'Template details' })
  @ApiResponse({ status: 404, description: 'Template not found' })
  async findById(@Param('id', ParseIntPipe) id: number) {
    return this.templatesService.findById(id);
  }

  @Post()
  @Roles(RoleName.ADMIN, RoleName.IT_ADMIN, RoleName.DEPARTMENT_HEAD)
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Create schedule template',
    description: `
## Create Schedule Template

Creates a new reusable schedule template.

### Access Control
- **Roles**: ADMIN, IT_ADMIN, DEPARTMENT_HEAD

### Permissions
- **Admins**: Can create university-wide or department templates
- **Department Heads**: Can only create department templates for their department
    `,
  })
  @ApiBody({ type: CreateScheduleTemplateDto })
  @ApiResponse({ status: 201, description: 'Template created successfully' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  async create(@Body() dto: CreateScheduleTemplateDto, @Req() req: any) {
    const userId = req.user.userId || req.user.id;
    const roles = this.extractRoles(req.user);
    return this.templatesService.create(dto, userId, roles);
  }

  @Put(':id')
  @Roles(RoleName.ADMIN, RoleName.IT_ADMIN, RoleName.DEPARTMENT_HEAD)
  @ApiOperation({
    summary: 'Update schedule template',
    description: 'Updates template metadata (not slots). To modify slots, delete and recreate.',
  })
  @ApiParam({ name: 'id', description: 'Template ID', type: Number })
  @ApiBody({ type: UpdateScheduleTemplateDto })
  @ApiResponse({ status: 200, description: 'Template updated' })
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateScheduleTemplateDto,
    @Req() req: any,
  ) {
    const userId = req.user.userId || req.user.id;
    const roles = this.extractRoles(req.user);
    return this.templatesService.update(id, dto, userId, roles);
  }

  @Delete(':id')
  @Roles(RoleName.ADMIN, RoleName.IT_ADMIN, RoleName.DEPARTMENT_HEAD)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Delete schedule template',
    description: 'Deletes a schedule template. Does not affect existing course schedules created from this template.',
  })
  @ApiParam({ name: 'id', description: 'Template ID', type: Number })
  @ApiResponse({ status: 200, description: 'Template deleted' })
  async delete(@Param('id', ParseIntPipe) id: number, @Req() req: any) {
    const userId = req.user.userId || req.user.id;
    const roles = this.extractRoles(req.user);
    return this.templatesService.delete(id, userId, roles);
  }

  @Post('apply')
  @Roles(RoleName.ADMIN, RoleName.IT_ADMIN, RoleName.DEPARTMENT_HEAD)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Apply template to section',
    description: `
## Apply Template to Course Section

Applies a schedule template to a course section. Replaces existing schedules.

### Process
1. Deletes all existing schedules for the section
2. Creates new schedules based on template slots
3. Optionally overrides building/room from template
    `,
  })
  @ApiBody({ type: ApplyTemplateToSectionDto })
  @ApiResponse({ status: 200, description: 'Template applied successfully' })
  async applyToSection(@Body() dto: ApplyTemplateToSectionDto, @Req() req: any) {
    const userId = req.user.userId || req.user.id;
    const roles = this.extractRoles(req.user);
    return this.templatesService.applyToSection(dto, userId, roles);
  }

  @Post('apply/bulk')
  @Roles(RoleName.ADMIN, RoleName.IT_ADMIN, RoleName.DEPARTMENT_HEAD)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Bulk apply template to multiple sections',
    description: `
## Bulk Apply Template

Applies a schedule template to multiple course sections at once.

### Response
Returns detailed results for each section including successes and failures.
    `,
  })
  @ApiBody({ type: BulkApplyTemplateDto })
  @ApiResponse({ status: 200, description: 'Bulk application completed' })
  async bulkApply(@Body() dto: BulkApplyTemplateDto, @Req() req: any) {
    const userId = req.user.userId || req.user.id;
    const roles = this.extractRoles(req.user);
    return this.templatesService.bulkApply(dto, userId, roles);
  }

  private extractRoles(user: any): string[] {
    if (Array.isArray(user.roles)) {
      return user.roles.map((r: any) => (typeof r === 'string' ? r : r.name || r.roleName));
    }
    return [];
  }
}
