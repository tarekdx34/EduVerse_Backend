import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { GeneratedReport } from './entities/generated-report.entity';
import { ReportTemplate } from './entities/report-template.entity';
import { ExportHistory } from './entities/export-history.entity';
import { ReportsService } from './services/reports.service';
import { ReportsController } from './controllers/reports.controller';

@Module({
  imports: [TypeOrmModule.forFeature([GeneratedReport, ReportTemplate, ExportHistory])],
  controllers: [ReportsController],
  providers: [ReportsService],
  exports: [ReportsService],
})
export class ReportsModule {}
