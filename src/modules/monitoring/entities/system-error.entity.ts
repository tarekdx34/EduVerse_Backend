import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { User } from '../../auth/entities/user.entity';

export enum ErrorType {
  APPLICATION = 'application',
  DATABASE = 'database',
  API = 'api',
  SECURITY = 'security',
  SYSTEM = 'system',
}

export enum ErrorSeverity {
  LOW = 'low',
  MEDIUM = 'medium',
  HIGH = 'high',
  CRITICAL = 'critical',
}

@Entity('system_errors')
export class SystemError {
  @PrimaryGeneratedColumn({ name: 'error_id', type: 'bigint', unsigned: true })
  errorId: number;

  @Column({ name: 'error_code', type: 'varchar', length: 50, nullable: true })
  errorCode: string;

  @Column({ name: 'error_message', type: 'text' })
  errorMessage: string;

  @Column({
    name: 'error_type',
    type: 'enum',
    enum: ErrorType,
  })
  errorType: ErrorType;

  @Column({
    name: 'severity',
    type: 'enum',
    enum: ErrorSeverity,
    default: ErrorSeverity.MEDIUM,
  })
  severity: ErrorSeverity;

  @Column({ name: 'stack_trace', type: 'text', nullable: true })
  stackTrace: string;

  @Column({ name: 'user_id', type: 'bigint', unsigned: true, nullable: true })
  userId: number;

  @Column({ name: 'ip_address', type: 'varchar', length: 45, nullable: true })
  ipAddress: string;

  @Column({ name: 'request_url', type: 'varchar', length: 500, nullable: true })
  requestUrl: string;

  @Column({ name: 'user_agent', type: 'text', nullable: true })
  userAgent: string;

  @Column({ name: 'is_resolved', type: 'tinyint', default: 0 })
  isResolved: boolean;

  @Column({ name: 'resolved_by', type: 'bigint', unsigned: true, nullable: true })
  resolvedBy: number;

  @Column({ name: 'resolved_at', type: 'timestamp', nullable: true })
  resolvedAt: Date;

  @Column({ name: 'resolution_notes', type: 'text', nullable: true })
  resolutionNotes: string;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'user_id' })
  user: User;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'resolved_by' })
  resolver: User;
}
