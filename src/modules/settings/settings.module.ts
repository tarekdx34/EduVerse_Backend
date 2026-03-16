import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { SystemSetting } from './entities/system-setting.entity';
import { BrandingSetting } from './entities/branding-setting.entity';
import { ApiIntegration } from './entities/api-integration.entity';
import { ApiRateLimit } from './entities/api-rate-limit.entity';
import { SettingsService } from './services/settings.service';
import { IntegrationsService } from './services/integrations.service';
import { SettingsController } from './controllers/settings.controller';
import { IntegrationsController } from './controllers/integrations.controller';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      SystemSetting,
      BrandingSetting,
      ApiIntegration,
      ApiRateLimit,
    ]),
  ],
  controllers: [SettingsController, IntegrationsController],
  providers: [SettingsService, IntegrationsService],
  exports: [SettingsService, IntegrationsService],
})
export class SettingsModule {}
