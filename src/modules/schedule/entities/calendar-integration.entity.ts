import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
  CreateDateColumn,
  UpdateDateColumn,
  Index,
} from 'typeorm';
import type { Relation } from 'typeorm';
import type { User } from '../../auth/entities/user.entity';
import { CalendarType, SyncStatus } from '../enums';

@Entity('calendar_integrations')
@Index(['userId'])
export class CalendarIntegration {
  @PrimaryGeneratedColumn({
    name: 'integration_id',
    type: 'bigint',
    unsigned: true,
  })
  integrationId: number;

  @Column({
    name: 'user_id',
    type: 'bigint',
    unsigned: true,
  })
  userId: number;

  @ManyToOne('User', { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'user_id' })
  user: Relation<User>;

  @Column({
    name: 'calendar_type',
    type: 'enum',
    enum: CalendarType,
    nullable: true,
  })
  calendarType: CalendarType | null;

  @Column({
    name: 'access_token_encrypted',
    type: 'varchar',
    length: 500,
    nullable: true,
  })
  accessTokenEncrypted: string | null;

  @Column({
    name: 'refresh_token_encrypted',
    type: 'varchar',
    length: 500,
    nullable: true,
  })
  refreshTokenEncrypted: string | null;

  @Column({
    name: 'last_sync',
    type: 'timestamp',
    nullable: true,
  })
  lastSync: Date | null;

  @Column({
    name: 'sync_status',
    type: 'enum',
    enum: SyncStatus,
    nullable: true,
  })
  syncStatus: SyncStatus | null;

  @CreateDateColumn({
    name: 'created_at',
  })
  createdAt: Date;

  @UpdateDateColumn({
    name: 'updated_at',
  })
  updatedAt: Date;
}
