import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  OneToMany,
  JoinColumn,
} from 'typeorm';
import type { Relation } from 'typeorm';
import type { User } from '../../auth/entities/user.entity';

@Entity('study_groups')
export class StudyGroup {
  @PrimaryGeneratedColumn({ name: 'group_id', type: 'bigint', unsigned: true })
  groupId: number;

  @Column({ name: 'course_id', type: 'bigint', unsigned: true })
  courseId: number;

  @Column({ name: 'group_name', type: 'varchar', length: 255 })
  groupName: string;

  @Column({ type: 'text', nullable: true })
  description: string;

  @Column({ name: 'created_by', type: 'bigint', unsigned: true })
  createdBy: number;

  @Column({ name: 'max_members', type: 'int', default: 10 })
  maxMembers: number;

  @Column({ name: 'current_members', type: 'int', default: 1 })
  currentMembers: number;

  @Column({ name: 'is_public', type: 'tinyint', default: 1 })
  isPublic: boolean;

  @Column({ name: 'meeting_schedule', type: 'varchar', length: 255, nullable: true })
  meetingSchedule: string;

  @Column({
    type: 'enum',
    enum: ['active', 'inactive', 'archived'],
    default: 'active',
  })
  status: string;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  @ManyToOne('User')
  @JoinColumn({ name: 'created_by' })
  creator: Relation<User>;
}
