import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ServerMonitoring } from './entities/server-monitoring.entity';
import { SystemError } from './entities/system-error.entity';
import { SslCertificate } from './entities/ssl-certificate.entity';
import { SystemAlert } from './entities/system-alert.entity';
import { MonitoringService } from './services/monitoring.service';
import { ErrorsService } from './services/errors.service';
import { SslService } from './services/ssl.service';
import { AlertsService } from './services/alerts.service';
import { MonitoringController } from './controllers/monitoring.controller';
import { ErrorsController } from './controllers/errors.controller';
import { SslController } from './controllers/ssl.controller';
import { AlertsController } from './controllers/alerts.controller';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      ServerMonitoring,
      SystemError,
      SslCertificate,
      SystemAlert,
    ]),
  ],
  controllers: [
    MonitoringController,
    ErrorsController,
    SslController,
    AlertsController,
  ],
  providers: [
    MonitoringService,
    ErrorsService,
    SslService,
    AlertsService,
  ],
  exports: [MonitoringService, ErrorsService, SslService, AlertsService],
})
export class MonitoringModule {}
