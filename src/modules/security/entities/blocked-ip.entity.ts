import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
} from 'typeorm';

@Entity('blocked_ips')
export class BlockedIp {
  @PrimaryGeneratedColumn({ name: 'ip_id', type: 'bigint', unsigned: true })
  ipId: number;

  @Column({ name: 'ip_address', type: 'varchar', length: 45 })
  ipAddress: string;

  @Column({ name: 'reason', type: 'varchar', length: 255 })
  reason: string;

  @CreateDateColumn({ name: 'blocked_at' })
  blockedAt: Date;

  @Column({ name: 'expires_at', type: 'timestamp', nullable: true })
  expiresAt: Date | null;

  @Column({ name: 'is_active', type: 'tinyint', default: 1 })
  isActive: boolean;
}
