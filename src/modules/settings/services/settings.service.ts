import { Injectable, Logger, NotFoundException, OnModuleInit } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { SystemSetting } from '../entities/system-setting.entity';
import { BrandingSetting } from '../entities/branding-setting.entity';
import { ApiRateLimit } from '../entities/api-rate-limit.entity';
import { UpdateSettingsDto, UpdateSingleSettingDto } from '../dto/update-settings.dto';
import { UpdateBrandingDto } from '../dto/update-branding.dto';

@Injectable()
export class SettingsService implements OnModuleInit {
  private readonly logger = new Logger(SettingsService.name);
  private settingsCache: Map<string, SystemSetting> = new Map();

  constructor(
    @InjectRepository(SystemSetting)
    private settingsRepo: Repository<SystemSetting>,
    @InjectRepository(BrandingSetting)
    private brandingRepo: Repository<BrandingSetting>,
    @InjectRepository(ApiRateLimit)
    private rateLimitRepo: Repository<ApiRateLimit>,
  ) {}

  async onModuleInit() {
    await this.loadSettingsCache();
  }

  private async loadSettingsCache() {
    const settings = await this.settingsRepo.find();
    this.settingsCache.clear();
    settings.forEach((s) => this.settingsCache.set(s.settingKey, s));
    this.logger.log(`Loaded ${settings.length} settings into cache`);
  }

  private invalidateCache() {
    this.settingsCache.clear();
  }

  // ── System Settings ────────────────────────────────────────

  async getAllSettings() {
    if (this.settingsCache.size === 0) {
      await this.loadSettingsCache();
    }
    const data = Array.from(this.settingsCache.values());
    return { data };
  }

  async getPublicSettings() {
    if (this.settingsCache.size === 0) {
      await this.loadSettingsCache();
    }
    const data = Array.from(this.settingsCache.values()).filter(
      (s) => s.isPublic,
    );
    return { data };
  }

  async getSetting(key: string) {
    if (this.settingsCache.has(key)) {
      return { data: this.settingsCache.get(key) };
    }

    const setting = await this.settingsRepo.findOne({
      where: { settingKey: key },
    });
    if (!setting) {
      throw new NotFoundException(`Setting '${key}' not found`);
    }
    return { data: setting };
  }

  async updateSettings(dto: UpdateSettingsDto, userId: number) {
    const results: SystemSetting[] = [];

    for (const [key, value] of Object.entries(dto.settings)) {
      const setting = await this.settingsRepo.findOne({
        where: { settingKey: key },
      });
      if (setting) {
        setting.settingValue = value;
        setting.updatedBy = userId;
        results.push(await this.settingsRepo.save(setting));
      }
    }

    this.invalidateCache();
    await this.loadSettingsCache();

    return { data: results, message: `${results.length} settings updated` };
  }

  async updateSetting(key: string, dto: UpdateSingleSettingDto, userId: number) {
    const setting = await this.settingsRepo.findOne({
      where: { settingKey: key },
    });
    if (!setting) {
      throw new NotFoundException(`Setting '${key}' not found`);
    }

    setting.settingValue = dto.value;
    if (dto.description) setting.description = dto.description;
    setting.updatedBy = userId;

    const result = await this.settingsRepo.save(setting);
    this.invalidateCache();
    await this.loadSettingsCache();

    return { data: result };
  }

  // ── Branding ───────────────────────────────────────────────

  async getBranding(campusId?: number) {
    const where: any = {};
    if (campusId) where.campusId = campusId;

    const data = await this.brandingRepo.find({ where });
    return { data };
  }

  async updateBranding(campusId: number, dto: UpdateBrandingDto, userId: number) {
    let branding = await this.brandingRepo.findOne({
      where: { campusId },
    });

    if (!branding) {
      branding = this.brandingRepo.create({ campusId });
    }

    if (dto.logoUrl !== undefined) branding.logoUrl = dto.logoUrl;
    if (dto.faviconUrl !== undefined) branding.faviconUrl = dto.faviconUrl;
    if (dto.primaryColor !== undefined) branding.primaryColor = dto.primaryColor;
    if (dto.secondaryColor !== undefined) branding.secondaryColor = dto.secondaryColor;
    if (dto.customCss !== undefined) branding.customCss = dto.customCss;
    if (dto.emailHeaderHtml !== undefined) branding.emailHeaderHtml = dto.emailHeaderHtml;
    if (dto.emailFooterHtml !== undefined) branding.emailFooterHtml = dto.emailFooterHtml;
    branding.updatedBy = userId;

    const result = await this.brandingRepo.save(branding);
    return { data: result };
  }

  // ── Rate Limits ────────────────────────────────────────────

  async getRateLimits() {
    const data = await this.rateLimitRepo.find({
      order: { createdAt: 'DESC' },
    });
    return { data };
  }

  async updateRateLimit(id: number, dto: any) {
    const rateLimit = await this.rateLimitRepo.findOne({
      where: { limitId: id },
    });
    if (!rateLimit) {
      throw new NotFoundException(`Rate limit ${id} not found`);
    }

    if (dto.maxRequests !== undefined) rateLimit.maxRequests = dto.maxRequests;
    if (dto.windowSeconds !== undefined) rateLimit.windowSeconds = dto.windowSeconds;
    if (dto.endpoint !== undefined) rateLimit.endpoint = dto.endpoint;

    const result = await this.rateLimitRepo.save(rateLimit);
    return { data: result };
  }
}
