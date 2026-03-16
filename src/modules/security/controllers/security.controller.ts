import {
  Controller,
  Get,
  Post,
  Delete,
  Body,
  Param,
  Query,
  UseGuards,
  ParseIntPipe,
  Request,
} from '@nestjs/common';
import {
  ApiTags,
  ApiBearerAuth,
  ApiOperation,
  ApiResponse,
  ApiParam,
} from '@nestjs/swagger';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../auth/guards/roles.guard';
import { Roles } from '../../../common/decorators/roles.decorator';
import { RoleName } from '../../auth/entities/role.entity';
import { SecurityService } from '../services/security.service';
import { IpBlockerService } from '../services/ip-blocker.service';
import { SecurityLogQueryDto } from '../dto/security-log-query.dto';
import { BlockIpDto } from '../dto/block-ip.dto';
import { ExportLogsDto } from '../dto/export-logs.dto';

@ApiTags('🔒 Security')
@ApiBearerAuth('JWT-auth')
@Controller('api/security')
@UseGuards(JwtAuthGuard, RolesGuard)
export class SecurityController {
  constructor(
    private readonly securityService: SecurityService,
    private readonly ipBlockerService: IpBlockerService,
  ) {}

  // ── Static routes first ────────────────────────────────────

  @Get('logs')
  @Roles(RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'Get security logs (paginated, filterable)',
    description: 'Retrieves a paginated list of security events. Access rules: ADMIN, IT_ADMIN. Uses table: `security_logs`.',
  })
  @ApiResponse({ status: 200, description: 'Security logs returned' })
  async getSecurityLogs(@Query() query: SecurityLogQueryDto) {
    return this.securityService.getSecurityLogs(query);
  }

  @Get('logs/stats')
  @Roles(RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'Get security log statistics',
    description: 'Retrieves security statistics (recent logs, categorization). Access rules: ADMIN, IT_ADMIN. Uses table: `security_logs`.',
  })
  @ApiResponse({ status: 200, description: 'Security stats returned' })
  async getSecurityLogStats() {
    return this.securityService.getSecurityLogStats();
  }

  @Post('logs/export')
  @Roles(RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'Export security logs',
    description: 'Exports security logs in CSV or JSON format. Access rules: IT_ADMIN. Uses table: `security_logs`.',
  })
  @ApiResponse({ status: 200, description: 'Export data returned' })
  async exportLogs(@Body() dto: ExportLogsDto) {
    return this.securityService.exportLogs(dto);
  }

  @Get('dashboard')
  @Roles(RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'Get security dashboard',
    description: 'Fetches aggregated security data for dashboards. Access rules: ADMIN, IT_ADMIN. Uses tables: `security_logs`, `sessions`, `blocked_ips`, `login_attempts`.',
  })
  @ApiResponse({ status: 200, description: 'Dashboard data returned' })
  async getDashboard() {
    return this.securityService.getDashboard();
  }

  @Get('threats')
  @Roles(RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'Get active threats',
    description: 'Retrieves a list of currently active threats, blocked IPs, and multiple failures. Access rules: IT_ADMIN. Uses tables: `security_logs`, `login_attempts`, `blocked_ips`.',
  })
  @ApiResponse({ status: 200, description: 'Threats data returned' })
  async getThreats() {
    return this.securityService.getThreats();
  }

  @Get('sessions')
  @Roles(RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'Get active sessions',
    description: 'List all currently active sessions on the server. Access rules: ADMIN, IT_ADMIN. Uses table: `sessions`.',
  })
  @ApiResponse({ status: 200, description: 'Active sessions returned' })
  async getActiveSessions() {
    return this.securityService.getActiveSessions();
  }

  @Get('blocked-ips')
  @Roles(RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'Get blocked IPs',
    description: 'Retrieves complete list of blocked IP addresses. Access rules: IT_ADMIN. Uses table: `blocked_ips`.',
  })
  @ApiResponse({ status: 200, description: 'Blocked IPs returned' })
  async getBlockedIps() {
    return this.ipBlockerService.getBlockedIps();
  }

  @Post('block-ip')
  @Roles(RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'Block an IP address',
    description: 'Blocks a specific IPv4/IPv6 address permanently or temporarily. Access rules: IT_ADMIN. Uses table: `blocked_ips`.',
  })
  @ApiResponse({ status: 201, description: 'IP blocked' })
  async blockIp(@Body() dto: BlockIpDto) {
    return this.ipBlockerService.blockIp(dto);
  }

  @Get('login-attempts')
  @Roles(RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'Get login attempts',
    description: 'Queries login attempts log base including failures and successes. Access rules: ADMIN, IT_ADMIN. Uses table: `login_attempts`.',
  })
  @ApiResponse({ status: 200, description: 'Login attempts returned' })
  async getLoginAttempts(@Query() query: SecurityLogQueryDto) {
    return this.securityService.getLoginAttempts(query);
  }

  // ── Parameter routes ───────────────────────────────────────

  @Delete('sessions/user/:userId')
  @Roles(RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'Revoke all sessions for a user',
    description: 'Force purges all active tokens rendering existing sessions invalid. Access rules: ADMIN, IT_ADMIN. Uses table: `sessions`.',
  })
  @ApiParam({ name: 'userId', type: Number })
  @ApiResponse({ status: 200, description: 'User sessions revoked' })
  async revokeUserSessions(@Param('userId', ParseIntPipe) userId: number) {
    return this.securityService.revokeUserSessions(userId);
  }

  @Delete('sessions/:id')
  @Roles(RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'Revoke a specific session',
    description: 'Terminates a single specific session instance by ID. Access rules: ADMIN, IT_ADMIN. Uses table: `sessions`.',
  })
  @ApiParam({ name: 'id', type: Number })
  @ApiResponse({ status: 200, description: 'Session revoked' })
  async revokeSession(@Param('id', ParseIntPipe) id: number) {
    return this.securityService.revokeSession(id);
  }

  @Delete('blocked-ips/:id')
  @Roles(RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'Unblock an IP address',
    description: 'Removes an IP block restoring connection to the target server point. Access rules: IT_ADMIN. Uses table: `blocked_ips`.',
  })
  @ApiParam({ name: 'id', type: Number })
  @ApiResponse({ status: 200, description: 'IP unblocked' })
  async unblockIp(@Param('id', ParseIntPipe) id: number) {
    return this.ipBlockerService.unblockIp(id);
  }
}
