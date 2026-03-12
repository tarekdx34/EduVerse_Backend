import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
  UpdateDateColumn,
} from 'typeorm';
import { User } from '../../auth/entities/user.entity';

@Entity('student_progress')
export class StudentProgress {
  @PrimaryGeneratedColumn({
    name: 'progress_id',
    type: 'bigint',
    unsigned: true,
  })
  progressId: number;

  @Column({ name: 'user_id', type: 'bigint', unsigned: true })
  userId: number;

  @Column({ name: 'course_id', type: 'bigint', unsigned: true })
  courseId: number;

  @Column({ name: 'enrollment_id', type: 'bigint', unsigned: true })
  enrollmentId: number;

  @Column({
    name: 'completion_percentage',
    type: 'decimal',
    precision: 5,
    scale: 2,
    default: 0.0,
  })
  completionPercentage: number;

  @Column({ name: 'materials_viewed', type: 'int', default: 0 })
  materialsViewed: number;

  @Column({ name: 'total_materials', type: 'int', default: 0 })
  totalMaterials: number;

  @Column({ name: 'assignments_completed', type: 'int', default: 0 })
  assignmentsCompleted: number;

  @Column({ name: 'total_assignments', type: 'int', default: 0 })
  totalAssignments: number;

  @Column({ name: 'quizzes_completed', type: 'int', default: 0 })
  quizzesCompleted: number;

  @Column({ name: 'total_quizzes', type: 'int', default: 0 })
  totalQuizzes: number;

  @Column({
    name: 'average_score',
    type: 'decimal',
    precision: 5,
    scale: 2,
    nullable: true,
  })
  averageScore: number;

  @Column({ name: 'time_spent_minutes', type: 'int', default: 0 })
  timeSpentMinutes: number;

  @Column({ name: 'last_activity_at', type: 'timestamp', nullable: true })
  lastActivityAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'user_id' })
  user: User;
}
