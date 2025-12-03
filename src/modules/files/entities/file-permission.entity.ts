import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
  Index,
} from 'typeorm';
import { File } from './file.entity';
import { User } from '../../auth/entities/user.entity';
import { Role } from '../../auth/entities/role.entity';

export enum PermissionType {
  READ = 'read',
  WRITE = 'write',
  DELETE = 'delete',
  SHARE = 'share',
}

@Entity('file_permissions')
@Index(['fileId'])
@Index(['userId'])
@Index(['roleId'])
export class FilePermission {
  @PrimaryGeneratedColumn({ name: 'permission_id', type: 'bigint' })
  permissionId: number;

  @Column({ name: 'file_id', type: 'bigint', nullable: false })
  fileId: number;

  @ManyToOne(() => File, (file) => file.permissions, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'file_id' })
  file: File;

  @Column({ name: 'user_id', type: 'bigint', nullable: true })
  userId?: number;

  @ManyToOne(() => User, { nullable: true })
  @JoinColumn({ name: 'user_id' })
  user?: User;

  @Column({ name: 'role_id', type: 'bigint', nullable: true })
  roleId?: number;

  @ManyToOne(() => Role, { nullable: true })
  @JoinColumn({ name: 'role_id' })
  role?: Role;

  @Column({
    name: 'permission_type',
    type: 'enum',
    enum: PermissionType,
    nullable: false,
  })
  permissionType: PermissionType;

  @Column({ name: 'granted_by', type: 'bigint', nullable: false })
  grantedBy: number;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'granted_by' })
  granter: User;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;
}

