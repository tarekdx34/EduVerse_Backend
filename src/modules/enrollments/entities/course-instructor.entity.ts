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
import { CourseSection } from '../../courses/entities/course-section.entity';
import { User } from '../../auth/entities/user.entity';

export enum InstructorRole {
  PRIMARY = 'primary',
  CO_INSTRUCTOR = 'co_instructor',
  GUEST = 'guest',
}

@Entity('course_instructors')
@Unique('UQ_section_id_user_id', ['sectionId', 'userId'])
@Index(['sectionId'])
@Index(['userId'])
export class CourseInstructor {
  @PrimaryGeneratedColumn('increment', {
    type: 'bigint',
    name: 'assignment_id',
  })
  id: number;

  @Column({
    type: 'bigint',
    nullable: false,
    name: 'section_id',
  })
  sectionId: number;

  @Column({
    type: 'bigint',
    nullable: false,
    name: 'user_id',
  })
  userId: number;

  @Column({
    type: 'enum',
    enum: InstructorRole,
    default: InstructorRole.PRIMARY,
    name: 'role',
  })
  role: InstructorRole;

  @CreateDateColumn({
    name: 'assigned_at',
  })
  createdAt: Date;

  @UpdateDateColumn({
    name: 'updated_at',
  })
  updatedAt: Date;

  @ManyToOne(() => CourseSection, {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'section_id' })
  section: CourseSection;

  @ManyToOne(() => User, {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'user_id' })
  instructor: User;
}
