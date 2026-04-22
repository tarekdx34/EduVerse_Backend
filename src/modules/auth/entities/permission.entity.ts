import { Entity, PrimaryGeneratedColumn, Column, ManyToMany } from 'typeorm';
import { Role } from './role.entity';

@Entity('permissions')
export class Permission {
  @PrimaryGeneratedColumn({ name: 'permission_id' })
  permissionId: number;

  @Column({ name: 'permission_name', length: 50, unique: true })
  permissionName: string;

  @Column({ name: 'permission_description', type: 'text', nullable: true })
  permissionDescription?: string;

  @Column({ length: 50, nullable: true })
  module?: string;

  // Relationships
  @ManyToMany(() => Role, (role) => role.permissions)
  roles: Role[];
}
