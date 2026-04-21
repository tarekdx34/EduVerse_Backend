import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import type { Relation } from 'typeorm';
import type { User } from '../../auth/entities/user.entity';
import type { StudyGroup } from './study-group.entity';

@Entity('study_group_members')
export class StudyGroupMember {
  @PrimaryGeneratedColumn({ name: 'member_id', type: 'bigint', unsigned: true })
  memberId: number;

  @Column({ name: 'group_id', type: 'bigint', unsigned: true })
  groupId: number;

  @Column({ name: 'user_id', type: 'bigint', unsigned: true })
  userId: number;

  @Column({
    type: 'enum',
    enum: ['creator', 'moderator', 'member'],
    default: 'member',
  })
  role: string;

  @CreateDateColumn({ name: 'joined_at' })
  joinedAt: Date;

  @ManyToOne('StudyGroup')
  @JoinColumn({ name: 'group_id' })
  group: Relation<StudyGroup>;

  @ManyToOne('User')
  @JoinColumn({ name: 'user_id' })
  user: Relation<User>;
}
