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

@Entity('api_rate_limits')
export class ApiRateLimit {
  @PrimaryGeneratedColumn({ name: 'limit_id', type: 'bigint', unsigned: true })
  limitId: number;

  @Column({ name: 'user_id', type: 'bigint', unsigned: true, nullable: true })
  userId: number;

  @Column({ name: 'api_key', type: 'varchar', length: 255, nullable: true })
  apiKey: string;

  @Column({ name: 'endpoint', type: 'varchar', length: 255, nullable: true })
  endpoint: string;

  @Column({ name: 'request_count', type: 'int', default: 0 })
  requestCount: number;

  @Column({ name: 'window_start', type: 'timestamp' })
  windowStart: Date;

  @Column({ name: 'window_end', type: 'timestamp' })
  windowEnd: Date;

  @Column({ name: 'max_requests', type: 'int', default: 1000 })
  maxRequests: number;

  @Column({ name: 'window_seconds', type: 'int', default: 60 })
  windowSeconds: number;

  @Column({ name: 'is_blocked', type: 'tinyint', default: 0 })
  isBlocked: boolean;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'user_id' })
  user: User;
}
