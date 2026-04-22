import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
  CreateDateColumn,
  UpdateDateColumn,
  OneToMany,
  ManyToMany,
  JoinTable,
} from 'typeorm';
import type { Relation } from 'typeorm';
import type { User } from '../../auth/entities/user.entity';
import type { Course } from '../../courses/entities/course.entity';
import { PostType } from '../enums';
import type { CommunityComment } from './community-comment.entity';
import type { CommunityReaction } from './community-reaction.entity';
import type { Community } from './community.entity';
import type { CommunityTag } from './community-tag.entity';

@Entity('community_posts')
export class CommunityPost {
  @PrimaryGeneratedColumn({ name: 'post_id', type: 'bigint', unsigned: true })
  id: number;

  @Column({ name: 'course_id', type: 'bigint', unsigned: true, nullable: true })
  courseId: number | null;

  @Column({ name: 'community_id', type: 'bigint', unsigned: true, nullable: true })
  communityId: number | null;

  @Column({ name: 'user_id', type: 'bigint', unsigned: true })
  userId: number;

  @Column({ length: 255 })
  title: string;

  @Column({ type: 'text' })
  content: string;

  @Column({
    name: 'post_type',
    type: 'enum',
    enum: PostType,
    default: PostType.DISCUSSION,
  })
  postType: PostType;

  @Column({ name: 'is_pinned', type: 'tinyint', default: 0 })
  isPinned: boolean;

  @Column({ name: 'is_locked', type: 'tinyint', default: 0 })
  isLocked: boolean;

  @Column({ name: 'view_count', type: 'int', default: 0 })
  viewCount: number;

  @Column({ name: 'upvote_count', type: 'int', default: 0 })
  upvoteCount: number;

  @Column({ name: 'reply_count', type: 'int', default: 0 })
  replyCount: number;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  // Relations
  @ManyToOne('User', { eager: true })
  @JoinColumn({ name: 'user_id' })
  author: Relation<User>;

  @ManyToOne('Course', { eager: true, nullable: true })
  @JoinColumn({ name: 'course_id' })
  course: Relation<Course>;

  @ManyToOne('Community', 'posts', { nullable: true })
  @JoinColumn({ name: 'community_id' })
  community: Relation<Community>;

  @OneToMany('CommunityComment', 'post')
  comments: Relation<CommunityComment>[];

  @OneToMany('CommunityReaction', 'post')
  reactions: Relation<CommunityReaction>[];

  @ManyToMany('CommunityTag', 'posts', { eager: true })
  @JoinTable({
    name: 'community_post_tags',
    joinColumn: { name: 'post_id', referencedColumnName: 'id' },
    inverseJoinColumn: { name: 'tag_id', referencedColumnName: 'id' },
  })
  tags: Relation<CommunityTag>[];
}
