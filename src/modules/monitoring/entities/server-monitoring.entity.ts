import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
} from 'typeorm';

export enum ServerStatus {
  HEALTHY = 'healthy',
  WARNING = 'warning',
  CRITICAL = 'critical',
  DOWN = 'down',
}

@Entity('server_monitoring')
export class ServerMonitoring {
  @PrimaryGeneratedColumn({ name: 'monitor_id', type: 'bigint', unsigned: true })
  monitorId: number;

  @Column({ name: 'server_name', type: 'varchar', length: 100 })
  serverName: string;

  @Column({ name: 'cpu_usage', type: 'decimal', precision: 5, scale: 2, nullable: true })
  cpuUsage: number;

  @Column({ name: 'memory_usage', type: 'decimal', precision: 5, scale: 2, nullable: true })
  memoryUsage: number;

  @Column({ name: 'disk_usage', type: 'decimal', precision: 5, scale: 2, nullable: true })
  diskUsage: number;

  @Column({
    name: 'status',
    type: 'enum',
    enum: ServerStatus,
    default: ServerStatus.HEALTHY,
  })
  status: ServerStatus;

  @Column({ name: 'uptime_seconds', type: 'bigint', nullable: true })
  uptimeSeconds: number;

  @Column({ name: 'checked_at', type: 'timestamp', default: () => 'CURRENT_TIMESTAMP' })
  checkedAt: Date;
}
