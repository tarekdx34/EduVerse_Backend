import { Injectable, Logger, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { SystemError } from '../entities/system-error.entity';
import { ErrorQueryDto } from '../dto/error-query.dto';
import { UpdateErrorDto } from '../dto/update-error.dto';

@Injectable()
export class ErrorsService {
  private readonly logger = new Logger(ErrorsService.name);

  constructor(
    @InjectRepository(SystemError)
    private errorRepo: Repository<SystemError>,
  ) {}

  async getErrors(query: ErrorQueryDto) {
    const { errorType, severity, isResolved, startDate, endDate, page = 1, limit = 20 } = query;

    const qb = this.errorRepo
      .createQueryBuilder('se')
      .leftJoinAndSelect('se.user', 'user')
      .leftJoinAndSelect('se.resolver', 'resolver');

    if (errorType) qb.andWhere('se.error_type = :errorType', { errorType });
    if (severity) qb.andWhere('se.severity = :severity', { severity });
    if (isResolved !== undefined) qb.andWhere('se.is_resolved = :isResolved', { isResolved });
    if (startDate) qb.andWhere('se.created_at >= :startDate', { startDate });
    if (endDate) qb.andWhere('se.created_at <= :endDate', { endDate });

    const total = await qb.getCount();
    const data = await qb
      .orderBy('se.createdAt', 'DESC')
      .skip((page - 1) * limit)
      .take(limit)
      .getMany();

    return {
      data,
      meta: { total, page, limit, totalPages: Math.ceil(total / limit) },
    };
  }

  async getErrorDetails(id: number) {
    const error = await this.errorRepo.findOne({
      where: { errorId: id },
      relations: ['user', 'resolver'],
    });
    if (!error) {
      throw new NotFoundException(`System error #${id} not found`);
    }
    return { data: error };
  }

  async updateErrorStatus(id: number, dto: UpdateErrorDto, resolvedByUserId: number) {
    const error = await this.errorRepo.findOne({ where: { errorId: id } });
    if (!error) {
      throw new NotFoundException(`System error #${id} not found`);
    }

    if (dto.status === 'resolved') {
      error.isResolved = true;
      error.resolvedBy = resolvedByUserId;
      error.resolvedAt = new Date();
    } else if (dto.status === 'investigating') {
      error.isResolved = false;
      (error as any).resolvedBy = null;
      (error as any).resolvedAt = null;
    }

    if (dto.resolutionNotes) {
      error.resolutionNotes = dto.resolutionNotes;
    }

    const saved = await this.errorRepo.save(error);
    return { data: saved, message: `Error #${id} status updated to ${dto.status}` };
  }

  async getErrorStats() {
    const byType = await this.errorRepo
      .createQueryBuilder('se')
      .select('se.error_type', 'errorType')
      .addSelect('COUNT(*)', 'count')
      .groupBy('se.error_type')
      .getRawMany();

    const bySeverity = await this.errorRepo
      .createQueryBuilder('se')
      .select('se.severity', 'severity')
      .addSelect('COUNT(*)', 'count')
      .groupBy('se.severity')
      .getRawMany();

    const total = await this.errorRepo.count();
    const unresolved = await this.errorRepo.count({ where: { isResolved: false } });

    return { data: { total, unresolved, byType, bySeverity } };
  }
}
