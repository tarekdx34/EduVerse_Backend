import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { User } from './user.entity';

@Entity('password_resets')
export class PasswordReset {
  @PrimaryGeneratedColumn({ name: 'reset_id' })
  resetId: number;

  @Column({ name: 'user_id' })
  userId: number;

  @Column({ name: 'reset_token', length: 255 })
  resetToken: string;

  @Column({ name: 'expires_at', type: 'datetime' })
  expiresAt: Date;

  @Column({ default: false })
  used: boolean;

  @Column({ name: 'used_at', type: 'datetime', nullable: true })
  usedAt?: Date;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  // Relationships
  @ManyToOne(() => User, (user) => user.passwordResets, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'user_id' })
  user: User;
}
