import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
  CreateDateColumn,
  UpdateDateColumn,
  Index,
  Unique,
} from 'typeorm';
import { EnrollmentStatus, DropReason } from '../enums';
import { User } from '../../auth/entities/user.entity';
import { CourseSection } from '../../courses/entities/course-section.entity';
import { Program } from '../../campus/entities/program.entity';

@Entity('course_enrollments')
@Unique(['userId', 'sectionId'])
@Index(['userId', 'status'])
@Index(['sectionId', 'status'])
export class CourseEnrollment {
  @PrimaryGeneratedColumn('increment', {
    name: 'enrollment_id',
    type: 'bigint',
  })
  id: number;

  @Column({
    type: 'bigint',
    nullable: false,
    name: 'user_id',
  })
  userId: number;

  @Column({
    type: 'bigint',
    nullable: false,
    name: 'section_id',
  })
  sectionId: number;

  @Column({
    type: 'bigint',
    nullable: true,
    name: 'program_id',
  })
  programId: number | null;

  @Column({
    type: 'enum',
    enum: EnrollmentStatus,
    default: EnrollmentStatus.ENROLLED,
    name: 'enrollment_status',
  })
  status: EnrollmentStatus;

  @Column({
    type: 'varchar',
    length: 5,
    nullable: true,
    name: 'grade',
  })
  grade: string | null;

  @Column({
    type: 'decimal',
    precision: 5,
    scale: 2,
    nullable: true,
    name: 'final_score',
  })
  finalScore: number | null;



  @CreateDateColumn({
    name: 'enrollment_date',
  })
  enrollmentDate: Date;

  @Column({
    type: 'datetime',
    nullable: true,
    name: 'dropped_at',
  })
  droppedAt: Date | null;

  @Column({
    type: 'datetime',
    nullable: true,
    name: 'completed_at',
  })
  completedAt: Date | null;

  @UpdateDateColumn({
    name: 'updated_at',
  })
  updatedAt: Date;

  @ManyToOne(() => User, {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'user_id' })
  user: User;

  @ManyToOne(() => CourseSection, {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'section_id' })
  section: CourseSection;

  @ManyToOne(() => Program, {
    onDelete: 'SET NULL',
  })
  @JoinColumn({ name: 'program_id' })
  program: Program | null;
}
