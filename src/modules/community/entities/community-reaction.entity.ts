import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
  CreateDateColumn,
  Unique,
} from 'typeorm';
import { User } from '../../auth/entities/user.entity';
import { CommunityPost } from './community-post.entity';
import { ReactionType } from '../enums';

@Entity('community_post_reactions')
@Unique(['postId', 'userId', 'reactionType'])
export class CommunityReaction {
  @PrimaryGeneratedColumn({ name: 'reaction_id', type: 'bigint', unsigned: true })
  id: number;

  @Column({ name: 'post_id', type: 'bigint', unsigned: true })
  postId: number;

  @Column({ name: 'user_id', type: 'bigint', unsigned: true })
  userId: number;

  @Column({
    name: 'reaction_type',
    type: 'enum',
    enum: ReactionType,
    default: ReactionType.LIKE,
  })
  reactionType: ReactionType;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  // Relations
  @ManyToOne(() => User, { eager: true })
  @JoinColumn({ name: 'user_id' })
  user: User;

  @ManyToOne(() => CommunityPost, (post) => post.reactions, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'post_id' })
  post: CommunityPost;
}
