import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Param,
  Body,
  UseGuards,
  Request,
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
import { IntegrationsService } from '../services/integrations.service';
import { CreateIntegrationDto, UpdateIntegrationDto } from '../dto/create-integration.dto';

@ApiTags('🔌 Integrations')
@ApiBearerAuth('JWT-auth')
@Controller('api/integrations')
@UseGuards(JwtAuthGuard, RolesGuard)
export class IntegrationsController {
  constructor(private readonly integrationsService: IntegrationsService) {}

  @Get()
  @Roles(RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({ summary: 'Get all API integrations' })
  @ApiResponse({ status: 200, description: 'Integrations returned' })
  async getAll() {
    return this.integrationsService.getAll();
  }

  @Post()
  @Roles(RoleName.IT_ADMIN)
  @ApiOperation({ summary: 'Create a new API integration' })
  @ApiResponse({ status: 201, description: 'Integration created' })
  async create(@Body() dto: CreateIntegrationDto, @Request() req) {
    const userId = req.user.userId || req.user.id;
    return this.integrationsService.create(dto, userId);
  }

  @Get(':id')
  @Roles(RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({ summary: 'Get a specific integration' })
  @ApiParam({ name: 'id', type: Number })
  @ApiResponse({ status: 200, description: 'Integration returned' })
  async getById(@Param('id', ParseIntPipe) id: number) {
    return this.integrationsService.getById(id);
  }

  @Put(':id')
  @Roles(RoleName.IT_ADMIN)
  @ApiOperation({ summary: 'Update an integration' })
  @ApiParam({ name: 'id', type: Number })
  @ApiResponse({ status: 200, description: 'Integration updated' })
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateIntegrationDto,
    @Request() req,
  ) {
    const userId = req.user.userId || req.user.id;
    return this.integrationsService.update(id, dto, userId);
  }

  @Delete(':id')
  @Roles(RoleName.IT_ADMIN)
  @ApiOperation({ summary: 'Delete an integration' })
  @ApiParam({ name: 'id', type: Number })
  @ApiResponse({ status: 200, description: 'Integration deleted' })
  async delete(@Param('id', ParseIntPipe) id: number) {
    return this.integrationsService.delete(id);
  }

  @Post(':id/test')
  @Roles(RoleName.IT_ADMIN)
  @ApiOperation({ summary: 'Test integration connection' })
  @ApiParam({ name: 'id', type: Number })
  @ApiResponse({ status: 200, description: 'Test result returned' })
  async testConnection(@Param('id', ParseIntPipe) id: number) {
    return this.integrationsService.testConnection(id);
  }

  @Post(':id/sync')
  @Roles(RoleName.IT_ADMIN)
  @ApiOperation({ summary: 'Trigger integration sync' })
  @ApiParam({ name: 'id', type: Number })
  @ApiResponse({ status: 200, description: 'Sync triggered' })
  async triggerSync(@Param('id', ParseIntPipe) id: number) {
    return this.integrationsService.triggerSync(id);
  }
}
