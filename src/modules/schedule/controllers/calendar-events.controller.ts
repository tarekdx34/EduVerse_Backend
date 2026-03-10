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
import { CalendarEventsService } from '../services';
import {
  CreateCalendarEventDto,
  UpdateCalendarEventDto,
  QueryCalendarEventDto,
} from '../dto';

@ApiTags('📆 Calendar Events')
@ApiBearerAuth('JWT-auth')
@Controller('api/calendar/events')
@UseGuards(JwtAuthGuard, RolesGuard)
export class CalendarEventsController {
  constructor(private readonly calendarService: CalendarEventsService) {}

  @Get()
  @ApiOperation({
    summary: 'List calendar events',
    description: `
## List Calendar Events

Returns paginated list of calendar events for the current user.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles**: ALL

### Role-Based Filtering
Users see:
- Their own personal events
- Course events for enrolled/taught courses

### Query Parameters
- \`courseId\`: Filter by course
- \`eventType\`: Filter by event type (lecture, lab, exam, etc.)
- \`status\`: Filter by status
- \`fromDate\`: Filter from date
- \`toDate\`: Filter until date
    `,
  })
  @ApiResponse({ status: 200, description: 'Paginated list of calendar events' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async findAll(@Query() query: QueryCalendarEventDto, @Req() req: any) {
    const userId = req.user.userId || req.user.id;
    const roles = this.extractRoles(req.user);
    return this.calendarService.findAll(query, userId, roles);
  }

  @Get(':id')
  @ApiOperation({
    summary: 'Get calendar event by ID',
    description: `
## Get Event Details

Returns detailed information about a specific calendar event.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles**: ALL (must own event or have course access)
    `,
  })
  @ApiParam({ name: 'id', description: 'Calendar event ID', type: Number, example: 1 })
  @ApiResponse({ status: 200, description: 'Calendar event details' })
  @ApiResponse({ status: 404, description: 'Event not found' })
  async findById(@Param('id', ParseIntPipe) id: number, @Req() req: any) {
    const userId = req.user.userId || req.user.id;
    const roles = this.extractRoles(req.user);
    return this.calendarService.findById(id, userId, roles);
  }

  @Post()
  @ApiOperation({
    summary: 'Create calendar event',
    description: `
## Create Calendar Event

Creates a new calendar event.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles**: 
  - Personal events: ALL users
  - Course events: INSTRUCTOR, ADMIN only

### Event Types
- \`lecture\`: Class lecture
- \`lab\`: Lab session
- \`exam\`: Examination
- \`assignment\`: Assignment deadline
- \`quiz\`: Quiz
- \`meeting\`: Meeting
- \`custom\`: Custom event

### Recurring Events
Set \`isRecurring: true\` and specify \`recurrencePattern\` (daily, weekly, monthly).
    `,
  })
  @ApiBody({ type: CreateCalendarEventDto })
  @ApiResponse({ status: 201, description: 'Calendar event created successfully' })
  @ApiResponse({ status: 400, description: 'Invalid input data' })
  @ApiResponse({ status: 403, description: 'Forbidden - Cannot create course events' })
  @HttpCode(HttpStatus.CREATED)
  async create(@Body() dto: CreateCalendarEventDto, @Req() req: any) {
    const userId = req.user.userId || req.user.id;
    const roles = this.extractRoles(req.user);
    return this.calendarService.create(dto, userId, roles);
  }

  @Put(':id')
  @ApiOperation({
    summary: 'Update calendar event',
    description: `
## Update Calendar Event

Updates an existing calendar event.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles**: 
  - Own events: Event owner
  - Course events: INSTRUCTOR, ADMIN
    `,
  })
  @ApiParam({ name: 'id', description: 'Calendar event ID', type: Number, example: 1 })
  @ApiBody({ type: UpdateCalendarEventDto })
  @ApiResponse({ status: 200, description: 'Calendar event updated successfully' })
  @ApiResponse({ status: 404, description: 'Event not found' })
  @ApiResponse({ status: 403, description: 'Forbidden - Cannot edit this event' })
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateCalendarEventDto,
    @Req() req: any,
  ) {
    const userId = req.user.userId || req.user.id;
    const roles = this.extractRoles(req.user);
    return this.calendarService.update(id, dto, userId, roles);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Delete calendar event',
    description: `
## Delete Calendar Event

Removes a calendar event.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles**: 
  - Own events: Event owner
  - Course events: INSTRUCTOR, ADMIN
    `,
  })
  @ApiParam({ name: 'id', description: 'Calendar event ID', type: Number, example: 1 })
  @ApiResponse({ status: 200, description: 'Calendar event deleted successfully' })
  @ApiResponse({ status: 404, description: 'Event not found' })
  @ApiResponse({ status: 403, description: 'Forbidden - Cannot delete this event' })
  async delete(@Param('id', ParseIntPipe) id: number, @Req() req: any) {
    const userId = req.user.userId || req.user.id;
    const roles = this.extractRoles(req.user);
    return this.calendarService.delete(id, userId, roles);
  }

  private extractRoles(user: any): string[] {
    if (Array.isArray(user.roles)) {
      return user.roles.map((r: any) => (typeof r === 'string' ? r : r.name || r.roleName));
    }
    return [];
  }
}
