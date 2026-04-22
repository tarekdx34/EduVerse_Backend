import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
  CreateDateColumn,
  UpdateDateColumn,
  OneToMany,
} from 'typeorm';
import type { Relation } from 'typeorm';
import type { User } from '../../auth/entities/user.entity';
import type { Department } from '../../campus/entities/department.entity';
import type { CommunityPost } from './community-post.entity';

export enum CommunityType {
  GLOBAL = 'global',
  DEPARTMENT = 'department',
}

@Entity('communities')
export class Community {
  @PrimaryGeneratedColumn({ name: 'community_id', type: 'bigint', unsigned: true })
  id: number;

  @Column({ length: 255 })
  name: string;

  @Column({ type: 'text', nullable: true })
  description: string;

  @Column({
    name: 'community_type',
    type: 'enum',
    enum: CommunityType,
  })
  communityType: CommunityType;

  @Column({ name: 'department_id', type: 'bigint', unsigned: true, nullable: true })
  departmentId: number | null;

  @Column({ name: 'cover_image_url', type: 'varchar', length: 500, nullable: true })
  coverImageUrl: string | null;

  @Column({ name: 'is_active', type: 'tinyint', default: 1 })
  isActive: boolean;

  @Column({ name: 'created_by', type: 'bigint', unsigned: true })
  createdById: number;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  // Relations
  @ManyToOne('Department', { nullable: true, onDelete: 'CASCADE' })
  @JoinColumn({ name: 'department_id' })
  department: Relation<Department>;

  @ManyToOne('User', { eager: true, onDelete: 'CASCADE' })
  @JoinColumn({ name: 'created_by' })
  createdBy: Relation<User>;

  @OneToMany('CommunityPost', 'community')
  posts: Relation<CommunityPost>[];
}
