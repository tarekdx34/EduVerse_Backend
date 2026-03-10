import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToMany,
} from 'typeorm';
import { CommunityPost } from './community-post.entity';

@Entity('community_tags')
export class CommunityTag {
  @PrimaryGeneratedColumn({ name: 'tag_id', type: 'bigint', unsigned: true })
  id: number;

  @Column({ type: 'varchar', length: 50, unique: true })
  name: string;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @ManyToMany(() => CommunityPost, (post) => post.tags)
  posts: CommunityPost[];
}
