import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';
import type { Relation } from 'typeorm';
import type { User } from '../../auth/entities/user.entity';
import type { CommunityPost } from './community-post.entity';

@Entity('community_post_comments')
export class CommunityComment {
  @PrimaryGeneratedColumn({ name: 'comment_id', type: 'bigint', unsigned: true })
  id: number;

  @Column({ name: 'post_id', type: 'bigint', unsigned: true })
  postId: number;

  @Column({ name: 'user_id', type: 'bigint', unsigned: true })
  userId: number;

  @Column({ name: 'comment_text', type: 'text' })
  commentText: string;

  @Column({ name: 'parent_comment_id', type: 'bigint', unsigned: true, nullable: true })
  parentCommentId?: number;

  @Column({ name: 'upvote_count', type: 'int', default: 0 })
  upvoteCount: number;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  // Relations
  @ManyToOne('User', { eager: true })
  @JoinColumn({ name: 'user_id' })
  author: Relation<User>;

  @ManyToOne('CommunityPost', 'comments', { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'post_id' })
  post: Relation<CommunityPost>;

  @ManyToOne('CommunityComment', { nullable: true })
  @JoinColumn({ name: 'parent_comment_id' })
  parentComment: Relation<CommunityComment>;
}
