import { Injectable, Logger, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { SecurityLog, SecurityEventType, SecuritySeverity } from '../entities/security-log.entity';
import { LoginAttempt } from '../entities/login-attempt.entity';
import { BlockedIp } from '../entities/blocked-ip.entity';
import { Session } from '../../auth/entities/session.entity';
import { SecurityLogQueryDto } from '../dto/security-log-query.dto';
import { ExportLogsDto, ExportFormat } from '../dto/export-logs.dto';
import { NotificationsService } from '../../notifications/services/notifications.service';
import { NotificationPriority, NotificationType } from '../../notifications/enums';

@Injectable()
export class SecurityService {
  private readonly logger = new Logger(SecurityService.name);

  constructor(
    @InjectRepository(SecurityLog)
    private securityLogRepo: Repository<SecurityLog>,
    @InjectRepository(LoginAttempt)
    private loginAttemptRepo: Repository<LoginAttempt>,
    @InjectRepository(BlockedIp)
    private blockedIpRepo: Repository<BlockedIp>,
    @InjectRepository(Session)
    private sessionRepo: Repository<Session>,
    private notificationsService: NotificationsService,
  ) {}

  // ── Security Logs ──────────────────────────────────────────

  async getSecurityLogs(query: SecurityLogQueryDto) {
    const { eventType, severity, userId, startDate, endDate, page = 1, limit = 20 } = query;

    const qb = this.securityLogRepo
      .createQueryBuilder('sl')
      .leftJoinAndSelect('sl.user', 'user');

    if (eventType) qb.andWhere('sl.event_type = :eventType', { eventType });
    if (severity) qb.andWhere('sl.severity = :severity', { severity });
    if (userId) qb.andWhere('sl.user_id = :userId', { userId });
    if (startDate) qb.andWhere('sl.created_at >= :startDate', { startDate });
    if (endDate) qb.andWhere('sl.created_at <= :endDate', { endDate });

    const total = await qb.getCount();
    const data = await qb
      .orderBy('sl.createdAt', 'DESC')
      .skip((page - 1) * limit)
      .take(limit)
      .getMany();

    return {
      data,
      meta: { total, page, limit, totalPages: Math.ceil(total / limit) },
    };
  }

  async getSecurityLogStats() {
    const byType = await this.securityLogRepo
      .createQueryBuilder('sl')
      .select('sl.event_type', 'eventType')
      .addSelect('COUNT(*)', 'count')
      .groupBy('sl.event_type')
      .getRawMany();

    const bySeverity = await this.securityLogRepo
      .createQueryBuilder('sl')
      .select('sl.severity', 'severity')
      .addSelect('COUNT(*)', 'count')
      .groupBy('sl.severity')
      .getRawMany();

    const last24h = await this.securityLogRepo
      .createQueryBuilder('sl')
      .where('sl.created_at >= DATE_SUB(NOW(), INTERVAL 24 HOUR)')
      .getCount();

    const last7d = await this.securityLogRepo
      .createQueryBuilder('sl')
      .where('sl.created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)')
      .getCount();

    return { data: { byType, bySeverity, last24h, last7d } };
  }

  // ── Threats ────────────────────────────────────────────────

  async getThreats() {
    // Failed login spikes in the last 24 hours
    const failedLogins = await this.loginAttemptRepo
      .createQueryBuilder('la')
      .select('la.ip_address', 'ipAddress')
      .addSelect('la.email', 'email')
      .addSelect('COUNT(*)', 'attempts')
      .where('la.attempt_status = :status', { status: 'failed' })
      .andWhere('la.attempted_at >= DATE_SUB(NOW(), INTERVAL 24 HOUR)')
      .groupBy('la.ip_address')
      .addGroupBy('la.email')
      .having('COUNT(*) >= 3')
      .orderBy('attempts', 'DESC')
      .getRawMany();

    // Currently blocked IPs
    const blockedIps = await this.blockedIpRepo.find({
      where: { isActive: true },
      order: { blockedAt: 'DESC' },
    });

    // Suspicious activity events
    const suspiciousEvents = await this.securityLogRepo
      .createQueryBuilder('sl')
      .leftJoinAndSelect('sl.user', 'user')
      .where('sl.severity IN (:...severities)', {
        severities: ['high', 'critical'],
      })
      .andWhere('sl.is_resolved = 0')
      .orderBy('sl.createdAt', 'DESC')
      .limit(20)
      .getMany();

    return { data: { failedLogins, blockedIps, suspiciousEvents } };
  }

  // ── Sessions ───────────────────────────────────────────────

  async getActiveSessions() {
    const sessions = await this.sessionRepo
      .createQueryBuilder('s')
      .leftJoinAndSelect('s.user', 'user')
      .where('s.expires_at > NOW()')
      .orderBy('s.createdAt', 'DESC')
      .getMany();

    return { data: sessions };
  }

  async revokeSession(sessionId: number) {
    const session = await this.sessionRepo.findOne({
      where: { sessionId },
    });
    if (!session) {
      throw new NotFoundException(`Session ${sessionId} not found`);
    }
    await this.sessionRepo.remove(session);
    return { message: `Session ${sessionId} revoked successfully` };
  }

  async revokeUserSessions(userId: number) {
    const result = await this.sessionRepo.delete({ userId });
    return {
      message: `${result.affected || 0} sessions revoked for user ${userId}`,
    };
  }

  // ── Login Attempts ─────────────────────────────────────────

  async getLoginAttempts(query: SecurityLogQueryDto) {
    const { userId, startDate, endDate, page = 1, limit = 20 } = query;

    const qb = this.loginAttemptRepo
      .createQueryBuilder('la')
      .leftJoinAndSelect('la.user', 'user');

    if (userId) qb.andWhere('la.user_id = :userId', { userId });
    if (startDate) qb.andWhere('la.attempted_at >= :startDate', { startDate });
    if (endDate) qb.andWhere('la.attempted_at <= :endDate', { endDate });

    const total = await qb.getCount();
    const data = await qb
      .orderBy('la.attemptedAt', 'DESC')
      .skip((page - 1) * limit)
      .take(limit)
      .getMany();

    return {
      data,
      meta: { total, page, limit, totalPages: Math.ceil(total / limit) },
    };
  }

  // ── Dashboard ──────────────────────────────────────────────

  async getDashboard() {
    const totalLogs = await this.securityLogRepo.count();
    const unresolvedThreats = await this.securityLogRepo.count({
      where: { isResolved: false },
    });
    const activeSessions = await this.sessionRepo
      .createQueryBuilder('s')
      .where('s.expires_at > NOW()')
      .getCount();
    const blockedIps = await this.blockedIpRepo.count({
      where: { isActive: true },
    });
    const recentFailedLogins = await this.loginAttemptRepo
      .createQueryBuilder('la')
      .where('la.attempt_status = :status', { status: 'failed' })
      .andWhere('la.attempted_at >= DATE_SUB(NOW(), INTERVAL 24 HOUR)')
      .getCount();

    return {
      data: {
        totalLogs,
        unresolvedThreats,
        activeSessions,
        blockedIps,
        recentFailedLogins,
      },
    };
  }

  // ── Log Security Event (used by other modules) ─────────────

  async logSecurityEvent(data: Partial<SecurityLog>) {
    const log = this.securityLogRepo.create(data);
    const saved = await this.securityLogRepo.save(log);

    if ([SecuritySeverity.HIGH, SecuritySeverity.CRITICAL].includes(saved.severity as SecuritySeverity)) {
      const adminIds = await this.notificationsService.getOperationalAdminIds();
      await this.notificationsService.createBulkNotifications(adminIds, {
        notificationType: NotificationType.SYSTEM,
        title: 'Security Event Detected',
        body: `A ${saved.severity} security event (${saved.eventType}) was logged and requires attention.`,
        relatedEntityType: 'security_log',
        relatedEntityId: saved.logId,
        priority:
          saved.severity === SecuritySeverity.CRITICAL
            ? NotificationPriority.URGENT
            : NotificationPriority.HIGH,
        actionUrl: '/admin/security',
      });
    }

    return saved;
  }

  // ── Export ──────────────────────────────────────────────────

  async exportLogs(dto: ExportLogsDto) {
    const qb = this.securityLogRepo
      .createQueryBuilder('sl')
      .leftJoinAndSelect('sl.user', 'user');

    if (dto.startDate) qb.andWhere('sl.created_at >= :startDate', { startDate: dto.startDate });
    if (dto.endDate) qb.andWhere('sl.created_at <= :endDate', { endDate: dto.endDate });

    const logs = await qb.orderBy('sl.createdAt', 'DESC').getMany();

    if (dto.format === ExportFormat.CSV) {
      const header = 'log_id,user_id,event_type,severity,ip_address,details,created_at\n';
      const rows = logs.map(
        (l) => `${l.logId},${l.userId || ''},${l.eventType},${l.severity},${l.ipAddress || ''},${(l.details || '').replace(/,/g, ';')},${l.createdAt}`,
      );
      return { data: header + rows.join('\n'), format: 'csv' };
    }

    return { data: logs, format: 'json' };
  }
}
