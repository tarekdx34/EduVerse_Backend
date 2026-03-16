import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { User } from '../../auth/entities/user.entity';

@Entity('audit_logs')
export class AuditLog {
  @PrimaryGeneratedColumn({ name: 'log_id', type: 'bigint', unsigned: true })
  logId: number;

  @Column({ name: 'user_id', type: 'bigint', unsigned: true, nullable: true })
  userId: number;

  @Column({ name: 'action_type', type: 'varchar', length: 50 })
  actionType: string;

  @Column({ name: 'entity_type', type: 'varchar', length: 50, nullable: true })
  entityType: string;

  @Column({
    name: 'entity_id',
    type: 'bigint',
    unsigned: true,
    nullable: true,
  })
  entityId: number;

  @Column({ name: 'old_values', type: 'longtext', nullable: true })
  oldValues: string;

  @Column({ name: 'new_values', type: 'longtext', nullable: true })
  newValues: string;

  @Column({ name: 'ip_address', type: 'varchar', length: 45, nullable: true })
  ipAddress: string;

  @Column({ name: 'user_agent', type: 'text', nullable: true })
  userAgent: string;

  @Column({ name: 'description', type: 'text', nullable: true })
  description: string;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'user_id' })
  user: User;
}
