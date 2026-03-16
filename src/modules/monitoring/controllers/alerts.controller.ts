import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Param,
  Body,
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
  ApiBody,
} from '@nestjs/swagger';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../auth/guards/roles.guard';
import { Roles } from '../../../common/decorators/roles.decorator';
import { RoleName } from '../../auth/entities/role.entity';
import { AlertsService } from '../services/alerts.service';
import { CreateAlertDto } from '../dto/create-alert.dto';
import { UpdateAlertDto } from '../dto/update-alert.dto';

@ApiTags('🚨 System Alerts')
@ApiBearerAuth('JWT-auth')
@Controller('api/alerts')
@UseGuards(JwtAuthGuard, RolesGuard)
export class AlertsController {
  constructor(private readonly alertsService: AlertsService) {}

  @Get()
  @Roles(RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'Get all alert rules',
    description:
      'Retrieves all configured system alert rules. ' +
      'Access roles: ADMIN, IT_ADMIN. Uses table: `system_alerts`.',
  })
  @ApiResponse({ status: 200, description: 'Alert rules returned' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden – insufficient role' })
  async getAlerts() {
    return this.alertsService.getAlerts();
  }

  @Post()
  @Roles(RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'Create a new alert rule',
    description:
      'Creates a new system alert rule with condition type and threshold. ' +
      'Access roles: IT_ADMIN. Uses table: `system_alerts`.',
  })
  @ApiBody({ type: CreateAlertDto })
  @ApiResponse({ status: 201, description: 'Alert rule created' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden – insufficient role' })
  async createAlert(@Body() dto: CreateAlertDto, @Request() req) {
    return this.alertsService.createAlert(dto, req.user.sub);
  }

  @Patch(':id')
  @Roles(RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'Update an alert rule',
    description:
      'Updates an existing system alert rule. Can modify name, description, condition, threshold, active status. ' +
      'Access roles: IT_ADMIN. Uses table: `system_alerts`.',
  })
  @ApiParam({ name: 'id', type: Number, description: 'Alert rule ID' })
  @ApiBody({ type: UpdateAlertDto })
  @ApiResponse({ status: 200, description: 'Alert rule updated' })
  @ApiResponse({ status: 404, description: 'Alert not found' })
  async updateAlert(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateAlertDto,
    @Request() req,
  ) {
    return this.alertsService.updateAlert(id, dto, req.user.sub);
  }

  @Delete(':id')
  @Roles(RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'Delete an alert rule',
    description:
      'Permanently removes an alert rule. ' +
      'Access roles: IT_ADMIN. Uses table: `system_alerts`.',
  })
  @ApiParam({ name: 'id', type: Number, description: 'Alert rule ID' })
  @ApiResponse({ status: 200, description: 'Alert rule deleted' })
  @ApiResponse({ status: 404, description: 'Alert not found' })
  async deleteAlert(@Param('id', ParseIntPipe) id: number) {
    return this.alertsService.deleteAlert(id);
  }
}
