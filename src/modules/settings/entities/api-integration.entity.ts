import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { User } from '../../auth/entities/user.entity';

export enum IntegrationType {
  LMS = 'lms',
  SSO = 'sso',
  PAYMENT = 'payment',
  EMAIL = 'email',
  SMS = 'sms',
  AI = 'ai',
  STORAGE = 'storage',
  OTHER = 'other',
}

export enum HealthStatus {
  HEALTHY = 'healthy',
  DEGRADED = 'degraded',
  DOWN = 'down',
}

@Entity('api_integrations')
export class ApiIntegration {
  @PrimaryGeneratedColumn({ name: 'integration_id', type: 'bigint', unsigned: true })
  integrationId: number;

  @Column({ name: 'campus_id', type: 'bigint', unsigned: true })
  campusId: number;

  @Column({ name: 'integration_name', type: 'varchar', length: 100 })
  integrationName: string;

  @Column({
    name: 'integration_type',
    type: 'enum',
    enum: IntegrationType,
  })
  integrationType: IntegrationType;

  @Column({ name: 'api_endpoint', type: 'varchar', length: 500, nullable: true })
  apiEndpoint: string;

  @Column({ name: 'api_key_encrypted', type: 'varchar', length: 500, nullable: true })
  apiKeyEncrypted: string;

  @Column({ name: 'api_secret_encrypted', type: 'varchar', length: 500, nullable: true })
  apiSecretEncrypted: string;

  @Column({ name: 'configuration', type: 'longtext', nullable: true })
  configuration: string;

  @Column({ name: 'is_active', type: 'tinyint', default: 1 })
  isActive: boolean;

  @Column({
    name: 'health_status',
    type: 'enum',
    enum: HealthStatus,
    default: HealthStatus.HEALTHY,
  })
  healthStatus: HealthStatus;

  @Column({ name: 'last_sync_at', type: 'timestamp', nullable: true })
  lastSyncAt: Date;

  @Column({ name: 'created_by', type: 'bigint', unsigned: true, nullable: true })
  createdBy: number;

  @Column({ name: 'updated_by', type: 'bigint', unsigned: true, nullable: true })
  updatedBy: number;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'created_by' })
  createdByUser: User;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'updated_by' })
  updatedByUser: User;
}
