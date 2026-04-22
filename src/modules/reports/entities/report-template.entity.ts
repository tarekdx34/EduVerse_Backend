import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  OneToMany,
  JoinColumn,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';
import { User } from '../../auth/entities/user.entity';
import type { GeneratedReport } from './generated-report.entity';

@Entity('report_templates')
export class ReportTemplate {
  @PrimaryGeneratedColumn({ name: 'template_id', type: 'bigint', unsigned: true })
  templateId: number;

  @Column({ name: 'template_name', type: 'varchar', length: 255, nullable: false })
  templateName: string;

  @Column({
    name: 'template_type',
    type: 'enum',
    enum: ['student', 'course', 'attendance', 'grade', 'analytics', 'custom'],
    nullable: false,
  })
  templateType: string;

  @Column({ name: 'template_structure', type: 'longtext', nullable: false })
  templateStructure: string;

  @Column({ name: 'description', type: 'text', nullable: true })
  description: string;

  @Column({ name: 'created_by', type: 'bigint', unsigned: true, nullable: false })
  createdBy: number;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'created_by' })
  creator: User;

  @Column({ name: 'is_system_template', type: 'tinyint', default: 0 })
  isSystemTemplate: number;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  @OneToMany('GeneratedReport', 'template')
  generatedReports: GeneratedReport[];
}
