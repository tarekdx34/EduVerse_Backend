import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
  CreateDateColumn,
} from 'typeorm';
import { User } from '../../auth/entities/user.entity';

@Entity('search_history')
export class SearchHistory {
  @PrimaryGeneratedColumn({ name: 'history_id', type: 'bigint', unsigned: true })
  historyId: number;

  @Column({ name: 'user_id', type: 'bigint', unsigned: true })
  userId: number;

  @Column({ name: 'search_query', type: 'varchar', length: 500 })
  searchQuery: string;

  @Column({ name: 'search_filters', type: 'longtext', nullable: true })
  searchFilters: string;

  @Column({ name: 'results_count', type: 'int', default: 0 })
  resultsCount: number;

  @Column({ name: 'selected_result_id', type: 'bigint', unsigned: true, nullable: true })
  selectedResultId: number;

  @Column({ name: 'selected_result_type', type: 'varchar', length: 50, nullable: true })
  selectedResultType: string;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'user_id' })
  user: User;
}
