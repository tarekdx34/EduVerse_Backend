import {
  Column,
  CreateDateColumn,
  Entity,
  Index,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
  Unique,
  UpdateDateColumn,
} from 'typeorm';
import { User } from '../../auth/entities/user.entity';
import { CourseMaterial } from './course-material.entity';

@Entity('student_material_views')
@Unique(['userId', 'materialId'])
@Index(['userId', 'courseId'])
@Index(['materialId'])
export class StudentMaterialView {
  @PrimaryGeneratedColumn({
    name: 'view_id',
    type: 'bigint',
    unsigned: true,
  })
  viewId: number;

  @Column({ name: 'user_id', type: 'bigint', unsigned: true })
  userId: number;

  @Column({ name: 'course_id', type: 'bigint', unsigned: true })
  courseId: number;

  @Column({ name: 'material_id', type: 'bigint', unsigned: true })
  materialId: number;

  @Column({ name: 'views_count', type: 'int', default: 1 })
  viewsCount: number;

  @CreateDateColumn({ name: 'first_viewed_at' })
  firstViewedAt: Date;

  @UpdateDateColumn({ name: 'last_viewed_at' })
  lastViewedAt: Date;

  @ManyToOne(() => User, {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'user_id' })
  user: User;

  @ManyToOne(() => CourseMaterial, {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'material_id' })
  material: CourseMaterial;
}
