import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
  Index,
} from 'typeorm';
import type { Relation } from 'typeorm';
import type { User } from '../../auth/entities/user.entity';

export enum NotificationDevicePlatform {
  ANDROID = 'android',
}

@Entity('notification_device_tokens')
@Index('idx_notification_device_tokens_token_hash', ['tokenHash'], {
  unique: true,
})
@Index('idx_notification_device_tokens_user_active', ['userId', 'isActive'])
export class NotificationDeviceToken {
  @PrimaryGeneratedColumn('increment', {
    name: 'device_token_id',
    type: 'bigint',
    unsigned: true,
  })
  id: number;

  @Column({ name: 'user_id', type: 'bigint', unsigned: true })
  userId: number;

  @Column({ name: 'fcm_token', type: 'text' })
  fcmToken: string;

  @Column({ name: 'token_hash', type: 'varchar', length: 64 })
  tokenHash: string;

  @Column({
    name: 'platform',
    type: 'enum',
    enum: NotificationDevicePlatform,
    default: NotificationDevicePlatform.ANDROID,
  })
  platform: NotificationDevicePlatform;

  @Column({ name: 'device_id', type: 'varchar', length: 255, nullable: true })
  deviceId: string | null;

  @Column({ name: 'device_name', type: 'varchar', length: 255, nullable: true })
  deviceName: string | null;

  @Column({ name: 'app_version', type: 'varchar', length: 64, nullable: true })
  appVersion: string | null;

  @Column({ name: 'locale', type: 'varchar', length: 32, nullable: true })
  locale: string | null;

  @Column({ name: 'is_active', type: 'tinyint', default: 1 })
  isActive: boolean;

  @Column({ name: 'last_seen_at', type: 'timestamp', nullable: true })
  lastSeenAt: Date | null;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  @ManyToOne('User', { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'user_id' })
  user: Relation<User>;
}
