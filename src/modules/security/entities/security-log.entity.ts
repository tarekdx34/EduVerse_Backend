import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { User } from '../../auth/entities/user.entity';

export enum SecurityEventType {
  LOGIN = 'login',
  LOGOUT = 'logout',
  FAILED_LOGIN = 'failed_login',
  PASSWORD_CHANGE = 'password_change',
  PERMISSION_CHANGE = 'permission_change',
  SUSPICIOUS_ACTIVITY = 'suspicious_activity',
  LOGIN_SUCCESS = 'login_success',
  LOGIN_FAILURE = 'login_failure',
  ROLE_CHANGE = 'role_change',
  ACCOUNT_LOCKED = 'account_locked',
  IP_BLOCKED = 'ip_blocked',
  SESSION_HIJACK = 'session_hijack',
  BRUTE_FORCE = 'brute_force',
}

export enum SecuritySeverity {
  LOW = 'low',
  MEDIUM = 'medium',
  HIGH = 'high',
  CRITICAL = 'critical',
}

@Entity('security_logs')
export class SecurityLog {
  @PrimaryGeneratedColumn({ name: 'log_id', type: 'bigint', unsigned: true })
  logId: number;

  @Column({ name: 'user_id', type: 'bigint', unsigned: true, nullable: true })
  userId: number;

  @Column({
    name: 'event_type',
    type: 'enum',
    enum: SecurityEventType,
  })
  eventType: SecurityEventType;

  @Column({
    name: 'severity',
    type: 'enum',
    enum: SecuritySeverity,
    default: SecuritySeverity.MEDIUM,
  })
  severity: SecuritySeverity;

  @Column({ name: 'ip_address', type: 'varchar', length: 45, nullable: true })
  ipAddress: string;

  @Column({ name: 'location', type: 'varchar', length: 255, nullable: true })
  location: string;

  @Column({ name: 'user_agent', type: 'text', nullable: true })
  userAgent: string;

  @Column({ name: 'details', type: 'text', nullable: true })
  details: string;

  @Column({ name: 'metadata', type: 'json', nullable: true })
  metadata: any;

  @Column({ name: 'is_resolved', type: 'tinyint', default: 0 })
  isResolved: boolean;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'user_id' })
  user: User;
}
