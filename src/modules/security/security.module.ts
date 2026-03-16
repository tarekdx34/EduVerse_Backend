import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { APP_INTERCEPTOR } from '@nestjs/core';
import { SecurityLog } from './entities/security-log.entity';
import { AuditLog } from './entities/audit-log.entity';
import { LoginAttempt } from './entities/login-attempt.entity';
import { BlockedIp } from './entities/blocked-ip.entity';
import { Session } from '../auth/entities/session.entity';
import { SecurityService } from './services/security.service';
import { AuditService } from './services/audit.service';
import { IpBlockerService } from './services/ip-blocker.service';
import { SecurityController } from './controllers/security.controller';
import { AuditController } from './controllers/audit.controller';
import { AuditLogInterceptor } from './interceptors/audit-log.interceptor';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      SecurityLog,
      AuditLog,
      LoginAttempt,
      BlockedIp,
      Session,
    ]),
  ],
  controllers: [SecurityController, AuditController],
  providers: [
    SecurityService,
    AuditService,
    IpBlockerService,
    {
      provide: APP_INTERCEPTOR,
      useClass: AuditLogInterceptor,
    },
  ],
  exports: [SecurityService, AuditService, IpBlockerService],
})
export class SecurityModule {}
