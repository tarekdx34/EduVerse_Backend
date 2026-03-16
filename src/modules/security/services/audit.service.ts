import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { AuditLog } from '../entities/audit-log.entity';
import { AuditLogQueryDto } from '../dto/audit-log-query.dto';
import { ExportLogsDto, ExportFormat } from '../dto/export-logs.dto';

@Injectable()
export class AuditService {
  private readonly logger = new Logger(AuditService.name);

  constructor(
    @InjectRepository(AuditLog)
    private auditLogRepo: Repository<AuditLog>,
  ) {}

  async getAuditLogs(query: AuditLogQueryDto) {
    const { actionType, entityType, userId, startDate, endDate, page = 1, limit = 20 } = query;

    const qb = this.auditLogRepo
      .createQueryBuilder('al')
      .leftJoinAndSelect('al.user', 'user');

    if (actionType) qb.andWhere('al.action_type = :actionType', { actionType });
    if (entityType) qb.andWhere('al.entity_type = :entityType', { entityType });
    if (userId) qb.andWhere('al.user_id = :userId', { userId });
    if (startDate) qb.andWhere('al.created_at >= :startDate', { startDate });
    if (endDate) qb.andWhere('al.created_at <= :endDate', { endDate });

    const total = await qb.getCount();
    const data = await qb
      .orderBy('al.createdAt', 'DESC')
      .skip((page - 1) * limit)
      .take(limit)
      .getMany();

    return {
      data,
      meta: { total, page, limit, totalPages: Math.ceil(total / limit) },
    };
  }

  async getEntityAuditHistory(entityType: string, entityId: number) {
    const data = await this.auditLogRepo
      .createQueryBuilder('al')
      .leftJoinAndSelect('al.user', 'user')
      .where('al.entity_type = :entityType', { entityType })
      .andWhere('al.entity_id = :entityId', { entityId })
      .orderBy('al.createdAt', 'DESC')
      .getMany();

    return { data };
  }

  async createAuditLog(data: Partial<AuditLog>) {
    const log = this.auditLogRepo.create(data);
    return this.auditLogRepo.save(log);
  }

  async exportAuditLogs(dto: ExportLogsDto) {
    const qb = this.auditLogRepo
      .createQueryBuilder('al')
      .leftJoinAndSelect('al.user', 'user');

    if (dto.startDate) qb.andWhere('al.created_at >= :startDate', { startDate: dto.startDate });
    if (dto.endDate) qb.andWhere('al.created_at <= :endDate', { endDate: dto.endDate });

    const logs = await qb.orderBy('al.createdAt', 'DESC').getMany();

    if (dto.format === ExportFormat.CSV) {
      const header = 'log_id,user_id,action_type,entity_type,entity_id,description,created_at\n';
      const rows = logs.map(
        (l) => `${l.logId},${l.userId || ''},${l.actionType},${l.entityType || ''},${l.entityId || ''},${(l.description || '').replace(/,/g, ';')},${l.createdAt}`,
      );
      return { data: header + rows.join('\n'), format: 'csv' };
    }

    return { data: logs, format: 'json' };
  }
}
