import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToMany,
  JoinTable,
} from 'typeorm';
import { User } from './user.entity';
import { Permission } from './permission.entity';

export enum RoleName {
  STUDENT = 'student',
  INSTRUCTOR = 'instructor',
  TA = 'ta',
  ADMIN = 'admin',
  IT_ADMIN = 'it_admin',
}

@Entity('roles')
export class Role {
  @PrimaryGeneratedColumn({ name: 'role_id' })
  roleId: number;

  @Column({
    name: 'role_name',
    type: 'enum',
    enum: RoleName,
    unique: true,
  })
  roleName: RoleName;

  @Column({ name: 'role_description', type: 'text', nullable: true })
  roleDescription?: string;

  // Relationships
  @ManyToMany(() => User, (user) => user.roles)
  users: User[];

  @ManyToMany(() => Permission, (permission) => permission.roles)
  @JoinTable({
    name: 'role_permissions',
    joinColumn: { name: 'role_id', referencedColumnName: 'roleId' },
    inverseJoinColumn: {
      name: 'permission_id',
      referencedColumnName: 'permissionId',
    },
  })
  permissions: Permission[];
}
