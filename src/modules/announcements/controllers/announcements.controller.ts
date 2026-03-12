import {
  Controller,
  Get,
  Post,
  Put,
  Patch,
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
import { AnnouncementsService } from '../services/announcements.service';
import {
  CreateAnnouncementDto,
  UpdateAnnouncementDto,
  AnnouncementQueryDto,
  ScheduleAnnouncementDto,
} from '../dto';

@ApiTags('📢 Announcements')
@ApiBearerAuth('JWT-auth')
@Controller('api/announcements')
@UseGuards(JwtAuthGuard, RolesGuard)
export class AnnouncementsController {
  constructor(private readonly announcementsService: AnnouncementsService) {}

  @Get()
  @ApiOperation({
    summary: 'List announcements',
    description: `
List all announcements with optional filtering. Results are filtered based on user role:
- **Admin**: See ALL announcements
- **Instructor/TA**: See announcements for courses they teach + their own drafts
- **Student**: See published announcements for enrolled courses only

**Sorting**: Pinned announcements appear first, then sorted by creation date (newest first).
    `,
  })
  @ApiResponse({ status: 200, description: 'Paginated list of announcements' })
  async findAll(@Query() query: AnnouncementQueryDto, @Req() req: any) {
    const userId = req.user.userId || req.user.id;
    const roles = this.extractRoles(req.user);
    return this.announcementsService.findAll(query, userId, roles);
  }

  @Post()
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN, RoleName.IT_ADMIN)
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Create announcement',
    description: `
Create a new announcement. 

**Allowed Roles**: Instructor, TA, Admin

**Announcement Types**:
- \`course\`: Specific to a course (requires courseId)
- \`department\`: Department-wide
- \`campus\`: Campus-wide
- \`system\`: System-wide (all users)

**Tip**: Set \`isPublished: true\` to publish immediately, or leave it as \`false\` to create a draft.
    `,
  })
  @ApiBody({ type: CreateAnnouncementDto })
  @ApiResponse({ status: 201, description: 'Announcement created successfully' })
  @ApiResponse({ status: 403, description: 'Forbidden - Insufficient permissions' })
  async create(@Body() dto: CreateAnnouncementDto, @Req() req: any) {
    const userId = req.user.userId || req.user.id;
    return this.announcementsService.create(dto, userId);
  }

  @Get(':id')
  @ApiOperation({
    summary: 'Get announcement details',
    description: 'Get a single announcement by ID. Increments the view count.',
  })
  @ApiParam({ name: 'id', description: 'Announcement ID', example: 1 })
  @ApiResponse({ status: 200, description: 'Announcement details' })
  @ApiResponse({ status: 404, description: 'Announcement not found' })
  async findOne(@Param('id', ParseIntPipe) id: number, @Req() req: any) {
    const userId = req.user.userId || req.user.id;
    const roles = this.extractRoles(req.user);
    return this.announcementsService.findOne(id, userId, roles);
  }

  @Put(':id')
  @Roles(RoleName.INSTRUCTOR, RoleName.TA, RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'Update announcement',
    description: `
Update an existing announcement.

**Allowed Roles**: Owner (Instructor/TA who created it), Admin

**Note**: Non-admin users can only update their own announcements.
    `,
  })
  @ApiParam({ name: 'id', description: 'Announcement ID', example: 1 })
  @ApiBody({ type: UpdateAnnouncementDto })
  @ApiResponse({ status: 200, description: 'Announcement updated successfully' })
  @ApiResponse({ status: 403, description: 'Forbidden - Not the owner' })
  @ApiResponse({ status: 404, description: 'Announcement not found' })
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateAnnouncementDto,
    @Req() req: any,
  ) {
    const userId = req.user.userId || req.user.id;
    const roles = this.extractRoles(req.user);
    return this.announcementsService.update(id, dto, userId, roles);
  }

  @Delete(':id')
  @Roles(RoleName.INSTRUCTOR, RoleName.ADMIN, RoleName.IT_ADMIN)
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({
    summary: 'Delete announcement',
    description: `
Delete an announcement permanently.

**Allowed Roles**: Owner (Instructor who created it), Admin

**Note**: TAs cannot delete announcements. Non-admin instructors can only delete their own.
    `,
  })
  @ApiParam({ name: 'id', description: 'Announcement ID', example: 1 })
  @ApiResponse({ status: 204, description: 'Announcement deleted successfully' })
  @ApiResponse({ status: 403, description: 'Forbidden - Not the owner or admin' })
  @ApiResponse({ status: 404, description: 'Announcement not found' })
  async remove(@Param('id', ParseIntPipe) id: number, @Req() req: any) {
    const userId = req.user.userId || req.user.id;
    const roles = this.extractRoles(req.user);
    return this.announcementsService.remove(id, userId, roles);
  }

  @Patch(':id/publish')
  @Roles(RoleName.INSTRUCTOR, RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'Publish announcement',
    description: `
Publish a draft announcement immediately.

**Allowed Roles**: Owner (Instructor), Admin

**Effect**: Sets \`isPublished = true\` and \`publishedAt = now()\`. Clears any scheduled time.
    `,
  })
  @ApiParam({ name: 'id', description: 'Announcement ID', example: 1 })
  @ApiResponse({ status: 200, description: 'Announcement published successfully' })
  @ApiResponse({ status: 403, description: 'Forbidden - Not the owner or admin' })
  @ApiResponse({ status: 404, description: 'Announcement not found' })
  async publish(@Param('id', ParseIntPipe) id: number, @Req() req: any) {
    const userId = req.user.userId || req.user.id;
    const roles = this.extractRoles(req.user);
    return this.announcementsService.publish(id, userId, roles);
  }

  @Patch(':id/schedule')
  @Roles(RoleName.INSTRUCTOR, RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'Schedule announcement',
    description: `
Schedule an announcement for future publication.

**Allowed Roles**: Owner (Instructor), Admin

**Note**: The announcement will remain unpublished until a cron job publishes it at the scheduled time.
    `,
  })
  @ApiParam({ name: 'id', description: 'Announcement ID', example: 1 })
  @ApiBody({ type: ScheduleAnnouncementDto })
  @ApiResponse({ status: 200, description: 'Announcement scheduled successfully' })
  @ApiResponse({ status: 403, description: 'Forbidden - Not the owner or admin' })
  @ApiResponse({ status: 404, description: 'Announcement not found' })
  async schedule(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: ScheduleAnnouncementDto,
    @Req() req: any,
  ) {
    const userId = req.user.userId || req.user.id;
    const roles = this.extractRoles(req.user);
    return this.announcementsService.schedule(id, dto, userId, roles);
  }

  @Patch(':id/pin')
  @Roles(RoleName.INSTRUCTOR, RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'Toggle pin announcement',
    description: `
Pin or unpin an announcement. Pinned announcements appear at the top of the list.

**Allowed Roles**: Instructor, Admin
    `,
  })
  @ApiParam({ name: 'id', description: 'Announcement ID', example: 1 })
  @ApiResponse({ status: 200, description: 'Pin status toggled successfully' })
  @ApiResponse({ status: 403, description: 'Forbidden - Insufficient permissions' })
  @ApiResponse({ status: 404, description: 'Announcement not found' })
  async togglePin(@Param('id', ParseIntPipe) id: number, @Req() req: any) {
    const userId = req.user.userId || req.user.id;
    const roles = this.extractRoles(req.user);
    return this.announcementsService.togglePin(id, userId, roles);
  }

  @Get(':id/analytics')
  @Roles(RoleName.INSTRUCTOR, RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'Get announcement analytics',
    description: `
Get analytics data for an announcement including view count and publication status.

**Allowed Roles**: Owner (Author), Instructor, Admin
    `,
  })
  @ApiParam({ name: 'id', description: 'Announcement ID', example: 1 })
  @ApiResponse({ status: 200, description: 'Announcement analytics data' })
  @ApiResponse({ status: 403, description: 'Forbidden - Insufficient permissions' })
  @ApiResponse({ status: 404, description: 'Announcement not found' })
  async getAnalytics(@Param('id', ParseIntPipe) id: number, @Req() req: any) {
    const userId = req.user.userId || req.user.id;
    const roles = this.extractRoles(req.user);
    return this.announcementsService.getAnalytics(id, userId, roles);
  }

  /**
   * Helper to extract role names from user object
   */
  private extractRoles(user: any): string[] {
    if (!user.roles) return [];
    return user.roles.map((r: any) => r.roleName || r.name || r);
  }
}
