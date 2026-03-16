import {
  Controller,
  Get,
  Put,
  Param,
  Body,
  Query,
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
  ApiQuery,
} from '@nestjs/swagger';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../auth/guards/roles.guard';
import { Roles } from '../../../common/decorators/roles.decorator';
import { RoleName } from '../../auth/entities/role.entity';
import { SettingsService } from '../services/settings.service';
import { UpdateSettingsDto, UpdateSingleSettingDto } from '../dto/update-settings.dto';
import { UpdateBrandingDto } from '../dto/update-branding.dto';
import { UpdateRateLimitsDto } from '../dto/update-rate-limits.dto';

@ApiTags('⚙️ Settings')
@ApiBearerAuth('JWT-auth')
@Controller('api/settings')
@UseGuards(JwtAuthGuard, RolesGuard)
export class SettingsController {
  constructor(private readonly settingsService: SettingsService) {}

  // ── Static routes FIRST ────────────────────────────────────

  @Get('branding')
  @ApiOperation({
    summary: 'Get branding settings (public)',
    description: 'Retrieves publicly accessible branding configuration like logos, UI colors, and custom CSS. No auth required. Uses table: `branding_settings`.',
  })
  @ApiResponse({ status: 200, description: 'Branding settings returned' })
  @ApiQuery({ name: 'campusId', required: false, type: Number })
  async getBranding(@Query('campusId') campusId?: number) {
    return this.settingsService.getBranding(campusId ? Number(campusId) : undefined);
  }

  @Put('branding/:campusId')
  @Roles(RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'Update branding settings',
    description: 'Updates UI configurations like primary and secondary UI colors. Access rules: ADMIN, IT_ADMIN. Uses table: `branding_settings`.',
  })
  @ApiParam({ name: 'campusId', type: Number })
  @ApiResponse({ status: 200, description: 'Branding updated' })
  async updateBranding(
    @Param('campusId', ParseIntPipe) campusId: number,
    @Body() dto: UpdateBrandingDto,
    @Request() req,
  ) {
    const userId = req.user.userId || req.user.id;
    return this.settingsService.updateBranding(campusId, dto, userId);
  }

  @Get('rate-limits')
  @Roles(RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'Get rate limit configurations',
    description: 'Fetches configured thresholds mapping maximum requests dynamically loaded to endpoint routers. Access rules: IT_ADMIN. Uses table: `api_rate_limits`.',
  })
  @ApiResponse({ status: 200, description: 'Rate limits returned' })
  async getRateLimits() {
    return this.settingsService.getRateLimits();
  }

  @Put('rate-limits/:id')
  @Roles(RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'Update a rate limit configuration',
    description: 'Updates limits applied to specified API route matching endpoints. Access rules: IT_ADMIN. Uses table: `api_rate_limits`.',
  })
  @ApiParam({ name: 'id', type: Number })
  @ApiResponse({ status: 200, description: 'Rate limit updated' })
  async updateRateLimit(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateRateLimitsDto,
  ) {
    return this.settingsService.updateRateLimit(id, dto);
  }

  // ── Generic settings routes ────────────────────────────────

  @Get()
  @Roles(RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'Get all system settings',
    description: 'Retrieves active universal application configurations across cache structures. Access rules: ADMIN, IT_ADMIN. Uses table: `system_settings`.',
  })
  @ApiResponse({ status: 200, description: 'All settings returned' })
  async getAllSettings() {
    return this.settingsService.getAllSettings();
  }

  @Put()
  @Roles(RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'Update multiple system settings',
    description: 'Batch updates generic property map array of system settings. Access rules: ADMIN, IT_ADMIN. Uses table: `system_settings`.',
  })
  @ApiResponse({ status: 200, description: 'Settings updated' })
  async updateSettings(@Body() dto: UpdateSettingsDto, @Request() req) {
    const userId = req.user.userId || req.user.id;
    return this.settingsService.updateSettings(dto, userId);
  }

  // ── Parameter routes LAST ──────────────────────────────────

  @Get(':key')
  @Roles(RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'Get a specific setting by key',
    description: 'Fast retrieval query locating single string cache index key setting. Access rules: ADMIN, IT_ADMIN. Uses table: `system_settings`.',
  })
  @ApiParam({ name: 'key', description: 'Setting key' })
  @ApiResponse({ status: 200, description: 'Setting returned' })
  async getSetting(@Param('key') key: string) {
    return this.settingsService.getSetting(key);
  }

  @Put(':key')
  @Roles(RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'Update a specific setting by key',
    description: 'Upserts singular setting instance modifying existing string configurations. Access rules: ADMIN, IT_ADMIN. Uses table: `system_settings`.',
  })
  @ApiParam({ name: 'key', description: 'Setting key' })
  @ApiResponse({ status: 200, description: 'Setting updated' })
  async updateSetting(
    @Param('key') key: string,
    @Body() dto: UpdateSingleSettingDto,
    @Request() req,
  ) {
    const userId = req.user.userId || req.user.id;
    return this.settingsService.updateSetting(key, dto, userId);
  }
}
