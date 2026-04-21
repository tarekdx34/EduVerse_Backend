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

@Entity('peer_reviews')
export class PeerReview {
  @PrimaryGeneratedColumn({ name: 'review_id', type: 'bigint', unsigned: true })
  reviewId: number;

  @Column({ name: 'submission_id', type: 'bigint', unsigned: true })
  submissionId: number;

  @Column({ name: 'reviewer_id', type: 'bigint', unsigned: true })
  reviewerId: number;

  @Column({ name: 'reviewee_id', type: 'bigint', unsigned: true })
  revieweeId: number;

  @Column({ name: 'review_text', type: 'text', nullable: true })
  reviewText: string;

  @Column({ type: 'decimal', precision: 3, scale: 2, nullable: true })
  rating: number | null;

  @Column({ name: 'criteria_scores', type: 'longtext', nullable: true })
  criteriaScores: string | null;

  @Column({
    type: 'enum',
    enum: ['pending', 'submitted', 'acknowledged'],
    default: 'pending',
  })
  status: string;

  @Column({ name: 'submitted_at', type: 'timestamp', nullable: true })
  submittedAt: Date;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @ManyToOne('User')
  @JoinColumn({ name: 'reviewer_id' })
  reviewer: Relation<User>;

  @ManyToOne('User')
  @JoinColumn({ name: 'reviewee_id' })
  reviewee: Relation<User>;
}
