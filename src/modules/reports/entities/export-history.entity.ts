import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
  CreateDateColumn,
} from 'typeorm';
import { User } from '../../auth/entities/user.entity';
import { GeneratedReport } from './generated-report.entity';

@Entity('export_history')
export class ExportHistory {
  @PrimaryGeneratedColumn({ name: 'export_id', type: 'bigint', unsigned: true })
  exportId: number;

  @Column({ name: 'report_id', type: 'bigint', unsigned: true, nullable: false })
  reportId: number;

  @ManyToOne(() => GeneratedReport, (report) => report.exportHistory, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'report_id' })
  report: GeneratedReport;

  @Column({ name: 'user_id', type: 'bigint', unsigned: true, nullable: false })
  userId: number;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'user_id' })
  user: User;

  @Column({
    name: 'export_format',
    type: 'enum',
    enum: ['pdf', 'excel', 'csv', 'json'],
    nullable: false,
  })
  exportFormat: string;

  @Column({ name: 'file_id', type: 'bigint', unsigned: true, nullable: true })
  fileId: number;

  @CreateDateColumn({ name: 'exported_at' })
  exportedAt: Date;
}
