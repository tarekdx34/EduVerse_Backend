import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  OneToMany,
  JoinColumn,
} from 'typeorm';
import { Course } from '../../courses/entities/course.entity';
import { LabSubmission } from './lab-submission.entity';
import { LabInstruction } from './lab-instruction.entity';
import { LabAttendance } from './lab-attendance.entity';

@Entity('labs')
export class Lab {
  @PrimaryGeneratedColumn('increment', { name: 'lab_id', type: 'bigint', unsigned: true })
  id: number;

  @Column({ name: 'course_id', type: 'bigint', unsigned: true })
  courseId: number;

  @Column({ name: 'title', type: 'varchar', length: 255 })
  title: string;

  @Column({ name: 'description', type: 'text', nullable: true })
  description: string;

  @Column({ name: 'lab_number', type: 'int', nullable: true })
  labNumber: number;

  @Column({ name: 'due_date', type: 'timestamp', nullable: true })
  dueDate: Date;

  @Column({ name: 'available_from', type: 'timestamp', nullable: true })
  availableFrom: Date;

  @Column({ name: 'max_score', type: 'decimal', precision: 5, scale: 2, default: 100 })
  maxScore: number;

  @Column({ name: 'weight', type: 'decimal', precision: 5, scale: 2, default: 0 })
  weight: number;

  @Column({ name: 'status', type: 'enum', enum: ['draft', 'published', 'closed', 'archived'], default: 'draft' })
  status: string;

  @Column({ name: 'created_by', type: 'bigint', unsigned: true })
  createdBy: number;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  @ManyToOne(() => Course)
  @JoinColumn({ name: 'course_id' })
  course: Course;

  @OneToMany(() => LabSubmission, (s) => s.lab)
  submissions: LabSubmission[];

  @OneToMany(() => LabInstruction, (i) => i.lab)
  instructions: LabInstruction[];

  @OneToMany(() => LabAttendance, (a) => a.lab)
  attendanceRecords: LabAttendance[];
}
