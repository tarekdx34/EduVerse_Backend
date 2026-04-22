import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  OneToMany,
  JoinColumn,
  CreateDateColumn,
} from 'typeorm';
import { User } from '../../auth/entities/user.entity';
import { ReportTemplate } from './report-template.entity';
import type { ExportHistory } from './export-history.entity';

@Entity('generated_reports')
export class GeneratedReport {
  @PrimaryGeneratedColumn({ name: 'report_id', type: 'bigint', unsigned: true })
  reportId: number;

  @Column({ name: 'template_id', type: 'bigint', unsigned: true, nullable: false })
  templateId: number;

  @ManyToOne(() => ReportTemplate, (template) => template.generatedReports)
  @JoinColumn({ name: 'template_id' })
  template: ReportTemplate;

  @Column({ name: 'user_id', type: 'bigint', unsigned: true, nullable: false })
  userId: number;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'user_id' })
  user: User;

  @Column({ name: 'report_name', type: 'varchar', length: 255, nullable: false })
  reportName: string;

  @Column({ name: 'report_type', type: 'varchar', length: 50, nullable: false })
  reportType: string;

  @Column({ name: 'filters', type: 'longtext', nullable: true })
  filters: string | null;

  @Column({ name: 'file_id', type: 'bigint', unsigned: true, nullable: true })
  fileId: number;

  @Column({
    name: 'generation_status',
    type: 'enum',
    enum: ['pending', 'processing', 'completed', 'failed'],
    default: 'pending',
  })
  generationStatus: string;

  @Column({ name: 'generated_at', type: 'timestamp', nullable: true })
  generatedAt: Date;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @OneToMany('ExportHistory', 'report')
  exportHistory: ExportHistory[];
}
