import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
  CreateDateColumn,
} from 'typeorm';
import { User } from '../../auth/entities/user.entity';

@Entity('course_analytics')
export class CourseAnalytics {
  @PrimaryGeneratedColumn({
    name: 'analytics_id',
    type: 'bigint',
    unsigned: true,
  })
  analyticsId: number;

  @Column({ name: 'course_id', type: 'bigint', unsigned: true })
  courseId: number;

  @Column({ name: 'instructor_id', type: 'bigint', unsigned: true })
  instructorId: number;

  @Column({ name: 'total_students', type: 'int', default: 0 })
  totalStudents: number;

  @Column({ name: 'active_students', type: 'int', default: 0 })
  activeStudents: number;

  @Column({
    name: 'average_grade',
    type: 'decimal',
    precision: 5,
    scale: 2,
    nullable: true,
  })
  averageGrade: number;

  @Column({
    name: 'average_attendance',
    type: 'decimal',
    precision: 5,
    scale: 2,
    nullable: true,
  })
  averageAttendance: number;

  @Column({
    name: 'completion_rate',
    type: 'decimal',
    precision: 5,
    scale: 2,
    nullable: true,
  })
  completionRate: number;

  @Column({
    name: 'engagement_score',
    type: 'decimal',
    precision: 5,
    scale: 2,
    nullable: true,
  })
  engagementScore: number;

  @Column({ name: 'calculation_date', type: 'date' })
  calculationDate: Date;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'instructor_id' })
  instructor: User;
}
