import {
  Controller,
  Get,
  Post,
  Delete,
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
import { CalendarIntegrationsService } from '../services';
import { ConnectCalendarDto } from '../dto';

@ApiTags('🔗 Calendar Integrations')
@ApiBearerAuth('JWT-auth')
@Controller('api/calendar/integrations')
@UseGuards(JwtAuthGuard, RolesGuard)
export class CalendarIntegrationsController {
  constructor(private readonly integrationsService: CalendarIntegrationsService) {}

  @Get()
  @ApiOperation({
    summary: 'List calendar integrations',
    description: `
## List User's Calendar Integrations

Returns all external calendar integrations for the current user.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles**: ALL

### Supported Calendar Types
- \`google\`: Google Calendar
- \`outlook\`: Microsoft Outlook Calendar
- \`ical\`: iCal/Apple Calendar

### Response Includes
- Integration ID
- Calendar type
- Sync status (active, error, disabled)
- Last sync timestamp
    `,
  })
  @ApiResponse({ status: 200, description: 'List of calendar integrations' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async findAll(@Req() req: any) {
    const userId = req.user.userId || req.user.id;
    return this.integrationsService.findAll(userId);
  }

  @Post('connect')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Connect external calendar',
    description: `
## Connect External Calendar

Links an external calendar service to the user's EduVerse account.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles**: ALL

### OAuth Flow
1. Frontend initiates OAuth flow with calendar provider
2. User authorizes EduVerse access
3. Frontend receives authorization code
4. Frontend calls this endpoint with the code

### Supported Calendars
- **Google Calendar**: Full sync support
- **Outlook Calendar**: Full sync support
- **iCal**: Import/export support
    `,
  })
  @ApiBody({ type: ConnectCalendarDto })
  @ApiResponse({ status: 201, description: 'Calendar connected successfully' })
  @ApiResponse({ status: 400, description: 'Invalid authorization code' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async connect(@Body() dto: ConnectCalendarDto, @Req() req: any) {
    const userId = req.user.userId || req.user.id;
    return this.integrationsService.connect(dto, userId);
  }

  @Post(':id/sync')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Sync calendar',
    description: `
## Trigger Manual Calendar Sync

Manually triggers synchronization with the external calendar.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles**: ALL (own integrations only)

### Sync Process
- Imports events from external calendar
- Exports EduVerse events to external calendar
- Updates sync timestamp
    `,
  })
  @ApiParam({ name: 'id', description: 'Integration ID', type: Number, example: 1 })
  @ApiResponse({ status: 200, description: 'Sync initiated successfully' })
  @ApiResponse({ status: 404, description: 'Integration not found' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async sync(@Param('id', ParseIntPipe) id: number, @Req() req: any) {
    const userId = req.user.userId || req.user.id;
    return this.integrationsService.sync(id, userId);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Disconnect calendar',
    description: `
## Disconnect External Calendar

Removes the integration with an external calendar service.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles**: ALL (own integrations only)

### What Happens
- Removes stored tokens
- Stops future syncs
- Does NOT delete events already in EduVerse
    `,
  })
  @ApiParam({ name: 'id', description: 'Integration ID', type: Number, example: 1 })
  @ApiResponse({ status: 200, description: 'Calendar disconnected successfully' })
  @ApiResponse({ status: 404, description: 'Integration not found' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async disconnect(@Param('id', ParseIntPipe) id: number, @Req() req: any) {
    const userId = req.user.userId || req.user.id;
    return this.integrationsService.disconnect(id, userId);
  }
}
