import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { User } from './user.entity';

@Entity('two_factor_auth')
export class TwoFactorAuth {
  @PrimaryGeneratedColumn({ name: 'auth_id' })
  authId: number;

  @Column({ name: 'user_id' })
  userId: number;

  @Column({ name: 'secret_key', length: 255, nullable: true })
  secretKey?: string;

  @Column({ default: false })
  enabled: boolean;

  @Column({ name: 'backup_codes', type: 'text', nullable: true })
  backupCodes?: string;

  @Column({ name: 'last_used_at', type: 'datetime', nullable: true })
  lastUsedAt?: Date;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  // Relationships
  @ManyToOne(() => User, (user) => user.twoFactorAuths, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'user_id' })
  user: User;
}
