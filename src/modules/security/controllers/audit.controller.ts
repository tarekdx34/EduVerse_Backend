import {
  Controller,
  Get,
  Post,
  Param,
  Query,
  Body,
  UseGuards,
  ParseIntPipe,
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
import { AuditService } from '../services/audit.service';
import { AuditLogQueryDto } from '../dto/audit-log-query.dto';
import { ExportLogsDto } from '../dto/export-logs.dto';

@ApiTags('📋 Audit')
@ApiBearerAuth('JWT-auth')
@Controller('api/audit')
@UseGuards(JwtAuthGuard, RolesGuard)
export class AuditController {
  constructor(private readonly auditService: AuditService) {}

  @Get('logs')
  @Roles(RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'Get audit logs (paginated, filterable)',
    description: 'Retrieves comprehensive audit trails for writes/deletes occurring system-wide. Access rules: ADMIN, IT_ADMIN. Uses table: `audit_logs`.',
  })
  @ApiResponse({ status: 200, description: 'Audit logs returned' })
  async getAuditLogs(@Query() query: AuditLogQueryDto) {
    return this.auditService.getAuditLogs(query);
  }

  @Post('logs/export')
  @Roles(RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'Export audit logs',
    description: 'Export audit functionality dumping logs to CSV or JSON formats. Access rules: IT_ADMIN. Uses table: `audit_logs`.',
  })
  @ApiResponse({ status: 200, description: 'Export data returned' })
  async exportAuditLogs(@Body() dto: ExportLogsDto) {
    return this.auditService.exportAuditLogs(dto);
  }

  @Get('logs/entity/:type/:id')
  @Roles(RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'Get audit history for a specific entity',
    description: 'Retrieves historical changes tied to a specific entity map based on its type/id. Access rules: ADMIN, IT_ADMIN. Uses table: `audit_logs`.',
  })
  @ApiParam({ name: 'type', description: 'Entity type (e.g. user, course)' })
  @ApiParam({ name: 'id', description: 'Entity ID', type: Number })
  @ApiResponse({ status: 200, description: 'Entity audit history returned' })
  async getEntityAuditHistory(
    @Param('type') type: string,
    @Param('id', ParseIntPipe) id: number,
  ) {
    return this.auditService.getEntityAuditHistory(type, id);
  }
}
