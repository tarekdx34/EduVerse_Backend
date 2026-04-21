import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
  Index,
} from 'typeorm';
import type { Relation } from 'typeorm';
import type { File } from './file.entity';
import type { User } from '../../auth/entities/user.entity';
import type { Role } from '../../auth/entities/role.entity';

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

  @ManyToOne('File', 'permissions', { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'file_id' })
  file: Relation<File>;

  @Column({ name: 'user_id', type: 'bigint', nullable: true })
  userId?: number;

  @ManyToOne('User', { nullable: true })
  @JoinColumn({ name: 'user_id' })
  user?: Relation<User>;

  @Column({ name: 'role_id', type: 'bigint', nullable: true })
  roleId?: number;

  @ManyToOne('Role', { nullable: true })
  @JoinColumn({ name: 'role_id' })
  role?: Relation<Role>;

  @Column({
    name: 'permission_type',
    type: 'enum',
    enum: PermissionType,
    nullable: false,
  })
  permissionType: PermissionType;

  @Column({ name: 'granted_by', type: 'bigint', nullable: false })
  grantedBy: number;

  @ManyToOne('User')
  @JoinColumn({ name: 'granted_by' })
  granter: Relation<User>;

  @Column({ name: 'granted_at', type: 'timestamp', default: () => 'CURRENT_TIMESTAMP' })
  grantedAt: Date;
}

