import {
  Controller,
  Get,
  UseGuards,
} from '@nestjs/common';
import {
  ApiTags,
  ApiBearerAuth,
  ApiOperation,
  ApiResponse,
} from '@nestjs/swagger';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../auth/guards/roles.guard';
import { Roles } from '../../../common/decorators/roles.decorator';
import { RoleName } from '../../auth/entities/role.entity';
import { MonitoringService } from '../services/monitoring.service';

@ApiTags('📊 Monitoring')
@ApiBearerAuth('JWT-auth')
@Controller('api/monitoring')
@UseGuards(JwtAuthGuard, RolesGuard)
export class MonitoringController {
  constructor(private readonly monitoringService: MonitoringService) {}

  @Get('servers')
  @Roles(RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'Get server monitoring records',
    description:
      'Retrieves all server monitoring records ordered by most recent check. ' +
      'Access roles: ADMIN, IT_ADMIN. Uses table: `server_monitoring`.',
  })
  @ApiResponse({ status: 200, description: 'Server monitoring records returned' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden – insufficient role' })
  async getServers() {
    return this.monitoringService.getServers();
  }

  @Get('health')
  @Roles(RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'Get current server health',
    description:
      'Returns real-time server health metrics (CPU, memory, uptime) from the OS. ' +
      'Access roles: ADMIN, IT_ADMIN. Uses: Node.js os module (no DB table).',
  })
  @ApiResponse({ status: 200, description: 'Current server health metrics returned' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden – insufficient role' })
  async getHealth() {
    return this.monitoringService.getHealth();
  }

  @Get('metrics')
  @Roles(RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'Get server metrics with history',
    description:
      'Returns current health plus the last 50 historical server_monitoring records. ' +
      'Access roles: ADMIN, IT_ADMIN. Uses table: `server_monitoring`.',
  })
  @ApiResponse({ status: 200, description: 'Metrics with history returned' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden – insufficient role' })
  async getMetrics() {
    return this.monitoringService.getMetrics();
  }
}
