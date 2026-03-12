import {
  Injectable,
  Logger,
  NotFoundException,
  ForbiddenException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { GeneratedReport } from '../entities/generated-report.entity';
import { ReportTemplate } from '../entities/report-template.entity';
import { ExportHistory } from '../entities/export-history.entity';
import { GenerateReportDto } from '../dto/generate-report.dto';
import { ReportQueryDto } from '../dto/report-query.dto';

@Injectable()
export class ReportsService {
  private readonly logger = new Logger(ReportsService.name);

  constructor(
    @InjectRepository(GeneratedReport)
    private readonly reportRepo: Repository<GeneratedReport>,
    @InjectRepository(ReportTemplate)
    private readonly templateRepo: Repository<ReportTemplate>,
    @InjectRepository(ExportHistory)
    private readonly exportHistoryRepo: Repository<ExportHistory>,
  ) {}

  async getTemplates(query?: ReportQueryDto) {
    const { page = 1, limit = 20 } = query || {};

    const qb = this.templateRepo
      .createQueryBuilder('t')
      .leftJoinAndSelect('t.creator', 'creator')
      .orderBy('t.createdAt', 'DESC')
      .skip((page - 1) * limit)
      .take(limit);

    if (query?.reportType) {
      qb.andWhere('t.templateType = :type', { type: query.reportType });
    }

    const [data, total] = await qb.getManyAndCount();

    return {
      data,
      meta: { total, page, limit, totalPages: Math.ceil(total / limit) },
    };
  }

  async generate(dto: GenerateReportDto, userId: number) {
    const template = await this.templateRepo.findOne({
      where: { templateId: dto.templateId },
    });

    if (!template) {
      throw new NotFoundException(`Template with ID ${dto.templateId} not found`);
    }

    // Create the report record with pending status
    const report = this.reportRepo.create({
      templateId: dto.templateId,
      userId,
      reportName: dto.reportName,
      reportType: template.templateType,
      filters: dto.filters ? JSON.stringify(dto.filters) : null,
      generationStatus: 'pending',
    });

    const savedReport = await this.reportRepo.save(report);
    this.logger.log(`Report ${savedReport.reportId} created with status 'pending'`);

    // Simulate report generation
    savedReport.generationStatus = 'processing';
    await this.reportRepo.save(savedReport);

    try {
      savedReport.generationStatus = 'completed';
      savedReport.generatedAt = new Date();
      await this.reportRepo.save(savedReport);

      // Record in export history
      const exportRecord = this.exportHistoryRepo.create({
        reportId: savedReport.reportId,
        userId,
        exportFormat: dto.exportFormat || 'pdf',
      });
      await this.exportHistoryRepo.save(exportRecord);

      this.logger.log(`Report ${savedReport.reportId} generated successfully`);
    } catch (error) {
      savedReport.generationStatus = 'failed';
      await this.reportRepo.save(savedReport);
      this.logger.error(`Report ${savedReport.reportId} generation failed`, error.stack);
      throw error;
    }

    return this.reportRepo.findOne({
      where: { reportId: savedReport.reportId },
      relations: ['template', 'user'],
    });
  }

  async getReport(reportId: number, userId: number, isAdmin = false) {
    const report = await this.reportRepo.findOne({
      where: { reportId },
      relations: ['template', 'user', 'exportHistory'],
    });

    if (!report) {
      throw new NotFoundException(`Report with ID ${reportId} not found`);
    }

    if (!isAdmin && report.userId !== userId) {
      throw new ForbiddenException('You do not have access to this report');
    }

    return report;
  }

  async downloadReport(reportId: number, userId: number, format?: string, isAdmin = false) {
    const report = await this.getReport(reportId, userId, isAdmin);

    // Record download in export history if format is specified
    if (format) {
      const exportRecord = this.exportHistoryRepo.create({
        reportId: report.reportId,
        userId,
        exportFormat: format,
      });
      await this.exportHistoryRepo.save(exportRecord);
    }

    return {
      reportId: report.reportId,
      reportName: report.reportName,
      reportType: report.reportType,
      generationStatus: report.generationStatus,
      filters: report.filters ? JSON.parse(report.filters) : null,
      generatedAt: report.generatedAt,
      downloadUrl: `/api/reports/${report.reportId}/file`,
    };
  }

  async getHistory(userId: number, query: ReportQueryDto) {
    const { page = 1, limit = 20, sortBy = 'created_at' } = query;

    const qb = this.reportRepo
      .createQueryBuilder('r')
      .leftJoinAndSelect('r.template', 'template')
      .where('r.userId = :userId', { userId });

    if (query.reportType) {
      qb.andWhere('r.reportType = :reportType', { reportType: query.reportType });
    }

    if (query.generationStatus) {
      qb.andWhere('r.generationStatus = :status', { status: query.generationStatus });
    }

    const orderColumn = sortBy === 'report_name' ? 'r.reportName' : 'r.createdAt';
    qb.orderBy(orderColumn, 'DESC')
      .skip((page - 1) * limit)
      .take(limit);

    const [data, total] = await qb.getManyAndCount();

    return {
      data,
      meta: { total, page, limit, totalPages: Math.ceil(total / limit) },
    };
  }

  async deleteReport(reportId: number, userId: number, isAdmin = false) {
    const report = await this.reportRepo.findOne({
      where: { reportId },
    });

    if (!report) {
      throw new NotFoundException(`Report with ID ${reportId} not found`);
    }

    if (!isAdmin && report.userId !== userId) {
      throw new ForbiddenException('You do not have permission to delete this report');
    }

    // Delete related export history records first
    await this.exportHistoryRepo.delete({ reportId });

    await this.reportRepo.remove(report);

    this.logger.log(`Report ${reportId} deleted by user ${userId}`);

    return { message: `Report ${reportId} deleted successfully` };
  }
}
