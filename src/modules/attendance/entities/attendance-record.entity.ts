import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
  UpdateDateColumn,
  Index,
} from 'typeorm';
import type { Relation } from 'typeorm';
import { AttendanceStatus, MarkedBy } from '../enums';
import type { AttendanceSession } from './attendance-session.entity';
import type { User } from '../../auth/entities/user.entity';

@Entity('attendance_records')
@Index(['sessionId'])
@Index(['userId'])
@Index(['attendanceStatus'])
export class AttendanceRecord {
  @PrimaryGeneratedColumn('increment', {
    name: 'record_id',
    type: 'bigint',
  })
  id: number;

  @Column({
    type: 'bigint',
    nullable: false,
    name: 'session_id',
  })
  sessionId: number;

  @Column({
    type: 'bigint',
    unsigned: true,
    nullable: false,
    name: 'user_id',
  })
  userId: number;

  @Column({
    type: 'enum',
    enum: AttendanceStatus,
    default: AttendanceStatus.ABSENT,
    name: 'attendance_status',
  })
  attendanceStatus: AttendanceStatus;

  @Column({
    type: 'timestamp',
    nullable: true,
    name: 'check_in_time',
  })
  checkInTime: Date | null;

  @Column({
    type: 'enum',
    enum: MarkedBy,
    default: MarkedBy.MANUAL,
    name: 'marked_by',
  })
  markedBy: MarkedBy;

  @Column({
    type: 'decimal',
    precision: 5,
    scale: 4,
    nullable: true,
    name: 'confidence_score',
  })
  confidenceScore: number | null;

  @Column({
    type: 'text',
    nullable: true,
    name: 'notes',
  })
  notes: string | null;

  @UpdateDateColumn({
    name: 'updated_at',
  })
  updatedAt: Date;

  @ManyToOne('AttendanceSession', 'records', {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'session_id' })
  session: Relation<AttendanceSession>;

  @ManyToOne('User', {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'user_id' })
  user: Relation<User>;
}
