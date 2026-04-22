import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import type { Relation } from 'typeorm';
import type { Lab } from './lab.entity';
import type { User } from '../../auth/entities/user.entity';

@Entity('lab_attendance')
export class LabAttendance {
  @PrimaryGeneratedColumn('increment', { name: 'attendance_id', type: 'bigint', unsigned: true })
  id: number;

  @Column({ name: 'lab_id', type: 'bigint', unsigned: true })
  labId: number;

  @Column({ name: 'user_id', type: 'bigint', unsigned: true })
  userId: number;

  @Column({ name: 'attendance_status', type: 'enum', enum: ['present', 'absent', 'excused', 'late'], default: 'absent' })
  attendanceStatus: string;

  @Column({ name: 'check_in_time', type: 'timestamp', nullable: true })
  checkInTime: Date;

  @Column({ name: 'notes', type: 'text', nullable: true })
  notes: string;

  @Column({ name: 'marked_by', type: 'bigint', unsigned: true, nullable: true })
  markedBy: number;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @ManyToOne('Lab', 'attendanceRecords')
  @JoinColumn({ name: 'lab_id' })
  lab: Relation<Lab>;

  @ManyToOne('User', { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'user_id' })
  user: Relation<User>;

  @ManyToOne('User', { onDelete: 'SET NULL', nullable: true })
  @JoinColumn({ name: 'marked_by' })
  marker: Relation<User>;
}
