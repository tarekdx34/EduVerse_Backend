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
import { CampusEventsService } from '../services/campus-events.service';
import {
  CreateCampusEventDto,
  UpdateCampusEventDto,
  QueryCampusEventDto,
  RegisterCampusEventDto,
} from '../dto';

@ApiTags('🎉 Campus Events')
@ApiBearerAuth('JWT-auth')
@Controller('api/campus-events')
@UseGuards(JwtAuthGuard, RolesGuard)
export class CampusEventsController {
  constructor(private readonly eventsService: CampusEventsService) {}

  @Get()
  @ApiOperation({
    summary: 'List campus events',
    description: `
## List Campus Events

Returns paginated list of campus events filtered by visibility and query parameters.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles**: ALL

### Visibility Rules
- **University-wide events**: Visible to ALL users
- **Department events**: Visible to users in that department
- **Campus events**: Visible to users on that campus
- **Program events**: Visible to users in that program
- **Admins/IT_Admins**: See all events regardless of status
- **Others**: Only see published events

### Query Parameters
- \`eventType\`: Filter by event type
- \`scopeId\`: Filter by scope ID
- \`status\`: Filter by status
- \`fromDate\`: Events from this date
- \`toDate\`: Events until this date
- \`tag\`: Filter by tag
- \`search\`: Search in title or description
- \`page\`: Page number (default: 1)
- \`limit\`: Items per page (default: 10)
    `,
  })
  @ApiResponse({ status: 200, description: 'Paginated list of campus events' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async findAll(@Query() query: QueryCampusEventDto, @Req() req: any) {
    const userId = req.user.userId || req.user.id;
    const roles = this.extractRoles(req.user);
    return this.eventsService.findAll(query, userId, roles);
  }

  @Get('my')
  @ApiOperation({
    summary: 'Get my campus events',
    description: `
## Get My Campus Events

Returns campus events visible to the current user (published events from today onwards).

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles**: ALL
    `,
  })
  @ApiResponse({ status: 200, description: 'List of events visible to user' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async findMyEvents(@Req() req: any) {
    const userId = req.user.userId || req.user.id;
    const roles = this.extractRoles(req.user);
    return this.eventsService.findMyEvents(userId, roles);
  }

  @Get(':id')
  @ApiOperation({
    summary: 'Get campus event by ID',
    description: `
## Get Campus Event Details

Returns detailed information about a specific campus event including registration status.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles**: ALL

### Response Includes
- Event details
- User's registration status (if applicable)
- Current registration count
- Spots remaining (if max attendees set)
    `,
  })
  @ApiParam({ name: 'id', description: 'Campus event ID', type: Number, example: 1 })
  @ApiResponse({ status: 200, description: 'Campus event details' })
  @ApiResponse({ status: 404, description: 'Event not found' })
  async findById(@Param('id', ParseIntPipe) id: number, @Req() req: any) {
    const userId = req.user.userId || req.user.id;
    const roles = this.extractRoles(req.user);
    return this.eventsService.findById(id, userId, roles);
  }

  @Post()
  @Roles(RoleName.ADMIN, RoleName.IT_ADMIN, RoleName.DEPARTMENT_HEAD)
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Create campus event',
    description: `
## Create New Campus Event

Creates a new campus event.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles**: ADMIN, IT_ADMIN, DEPARTMENT_HEAD

### Permissions
- **Admins/IT_Admins**: Can create any type of event
- **Department Heads**: Can only create department-level events for their department

### Required Fields
- \`title\`: Event name
- \`eventType\`: Type of event (university_wide, department, campus, program)
- \`startDatetime\`: Start date and time
- \`endDatetime\`: End date and time

### Optional Fields
- \`description\`: Event description
- \`scopeId\`: Department/campus/program ID (required for non-university_wide events)
- \`location\`, \`building\`, \`room\`: Location details
- \`isMandatory\`: Is attendance mandatory
- \`registrationRequired\`: Does event require registration
- \`maxAttendees\`: Maximum number of attendees
- \`color\`: Hex color for calendar display
- \`status\`: Event status (default: draft)
- \`tags\`: Array of tags
    `,
  })
  @ApiBody({ type: CreateCampusEventDto })
  @ApiResponse({ status: 201, description: 'Campus event created successfully' })
  @ApiResponse({ status: 400, description: 'Invalid input data' })
  @ApiResponse({ status: 403, description: 'Forbidden - Insufficient permissions' })
  async create(@Body() dto: CreateCampusEventDto, @Req() req: any) {
    const userId = req.user.userId || req.user.id;
    const roles = this.extractRoles(req.user);
    return this.eventsService.create(dto, userId, roles);
  }

  @Put(':id')
  @Roles(RoleName.ADMIN, RoleName.IT_ADMIN, RoleName.DEPARTMENT_HEAD)
  @ApiOperation({
    summary: 'Update campus event',
    description: `
## Update Campus Event

Updates an existing campus event.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles**: ADMIN, IT_ADMIN, DEPARTMENT_HEAD, Event Organizer

### Permissions
- **Admins/IT_Admins**: Can update any event
- **Department Heads**: Can update department events
- **Event Organizer**: Can update own events
    `,
  })
  @ApiParam({ name: 'id', description: 'Campus event ID', type: Number, example: 1 })
  @ApiBody({ type: UpdateCampusEventDto })
  @ApiResponse({ status: 200, description: 'Campus event updated successfully' })
  @ApiResponse({ status: 404, description: 'Event not found' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateCampusEventDto,
    @Req() req: any,
  ) {
    const userId = req.user.userId || req.user.id;
    const roles = this.extractRoles(req.user);
    return this.eventsService.update(id, dto, userId, roles);
  }

  @Delete(':id')
  @Roles(RoleName.ADMIN, RoleName.IT_ADMIN, RoleName.DEPARTMENT_HEAD)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Delete campus event',
    description: `
## Delete Campus Event

Deletes a campus event from the system.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles**: ADMIN, IT_ADMIN, Event Organizer

### Permissions
- **Admins/IT_Admins**: Can delete any event
- **Event Organizer**: Can delete own events
    `,
  })
  @ApiParam({ name: 'id', description: 'Campus event ID', type: Number, example: 1 })
  @ApiResponse({ status: 200, description: 'Campus event deleted successfully' })
  @ApiResponse({ status: 404, description: 'Event not found' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  async delete(@Param('id', ParseIntPipe) id: number, @Req() req: any) {
    const userId = req.user.userId || req.user.id;
    const roles = this.extractRoles(req.user);
    return this.eventsService.delete(id, userId, roles);
  }

  @Post(':id/register')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Register for campus event',
    description: `
## Register for Campus Event

Registers the current user for an event that requires registration.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles**: ALL

### Validation
- Event must require registration
- Event must be published
- User cannot be already registered
- Event must have available capacity (if max attendees set)
    `,
  })
  @ApiParam({ name: 'id', description: 'Campus event ID', type: Number, example: 1 })
  @ApiBody({ type: RegisterCampusEventDto })
  @ApiResponse({ status: 200, description: 'Successfully registered for event' })
  @ApiResponse({ status: 400, description: 'Bad request - Already registered or event full' })
  @ApiResponse({ status: 404, description: 'Event not found' })
  async register(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: RegisterCampusEventDto,
    @Req() req: any,
  ) {
    const userId = req.user.userId || req.user.id;
    return this.eventsService.register(id, dto, userId);
  }

  @Delete(':id/register')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Unregister from campus event',
    description: `
## Unregister from Campus Event

Cancels the current user's registration for an event.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles**: ALL
    `,
  })
  @ApiParam({ name: 'id', description: 'Campus event ID', type: Number, example: 1 })
  @ApiResponse({ status: 200, description: 'Successfully unregistered from event' })
  @ApiResponse({ status: 404, description: 'Registration not found' })
  @ApiResponse({ status: 400, description: 'Registration already cancelled' })
  async unregister(@Param('id', ParseIntPipe) id: number, @Req() req: any) {
    const userId = req.user.userId || req.user.id;
    return this.eventsService.unregister(id, userId);
  }

  @Get(':id/registrations')
  @Roles(RoleName.ADMIN, RoleName.IT_ADMIN, RoleName.DEPARTMENT_HEAD)
  @ApiOperation({
    summary: 'Get event registrations',
    description: `
## Get Event Registrations

Returns list of registrations for an event.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles**: ADMIN, IT_ADMIN, Event Organizer

### Response Includes
- Event details
- List of registrations with user info
- Summary statistics (registered, attended, cancelled, no_show)
    `,
  })
  @ApiParam({ name: 'id', description: 'Campus event ID', type: Number, example: 1 })
  @ApiResponse({ status: 200, description: 'List of registrations' })
  @ApiResponse({ status: 404, description: 'Event not found' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  async getRegistrations(@Param('id', ParseIntPipe) id: number, @Req() req: any) {
    const userId = req.user.userId || req.user.id;
    const roles = this.extractRoles(req.user);
    return this.eventsService.getRegistrations(id, userId, roles);
  }

  private extractRoles(user: any): string[] {
    if (Array.isArray(user.roles)) {
      return user.roles.map((r: any) => (typeof r === 'string' ? r : r.name || r.roleName));
    }
    return [];
  }
}
