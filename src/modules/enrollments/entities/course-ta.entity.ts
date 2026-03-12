import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
  CreateDateColumn,
  Index,
  Unique,
} from 'typeorm';
import { CourseSection } from '../../courses/entities/course-section.entity';
import { User } from '../../auth/entities/user.entity';

@Entity('course_tas')
@Unique('UQ_section_id_user_id', ['sectionId', 'userId'])
@Index(['sectionId'])
@Index(['userId'])
export class CourseTA {
  @PrimaryGeneratedColumn('increment', {
    name: 'assignment_id',
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
    type: 'text',
    nullable: true,
    name: 'responsibilities',
  })
  responsibilities: string | null;

  @CreateDateColumn({
    name: 'assigned_at',
  })
  assignedAt: Date;

  @ManyToOne(() => CourseSection, {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'section_id' })
  section: CourseSection;

  @ManyToOne(() => User, {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'user_id' })
  ta: User;
}
