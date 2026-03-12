import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  OneToMany,
  JoinColumn,
  CreateDateColumn,
  UpdateDateColumn,
  Index,
} from 'typeorm';
import { SessionStatus, SessionType } from '../enums';
import { CourseSection } from '../../courses/entities/course-section.entity';
import { User } from '../../auth/entities/user.entity';
import { AttendanceRecord } from './attendance-record.entity';
import { AttendancePhoto } from './attendance-photo.entity';

@Entity('attendance_sessions')
@Index(['sectionId'])
@Index(['instructorId'])
@Index(['sessionDate'])
@Index(['status'])
export class AttendanceSession {
  @PrimaryGeneratedColumn('increment', {
    name: 'session_id',
    type: 'bigint',
  })
  id: number;

  @Column({
    type: 'bigint',
    nullable: false,
    name: 'section_id',
  })
  sectionId: number;

  @Column({
    type: 'date',
    nullable: false,
    name: 'session_date',
  })
  sessionDate: string;

  @Column({
    type: 'enum',
    enum: SessionType,
    default: SessionType.LECTURE,
    name: 'session_type',
  })
  sessionType: SessionType;

  @Column({
    type: 'bigint',
    nullable: false,
    name: 'instructor_id',
  })
  instructorId: number;

  @Column({
    type: 'time',
    nullable: true,
    name: 'start_time',
  })
  startTime: string | null;

  @Column({
    type: 'time',
    nullable: true,
    name: 'end_time',
  })
  endTime: string | null;

  @Column({
    type: 'varchar',
    length: 100,
    nullable: true,
    name: 'location',
  })
  location: string | null;

  @Column({
    type: 'int',
    default: 0,
    name: 'total_students',
  })
  totalStudents: number;

  @Column({
    type: 'int',
    default: 0,
    name: 'present_count',
  })
  presentCount: number;

  @Column({
    type: 'int',
    default: 0,
    name: 'absent_count',
  })
  absentCount: number;

  @Column({
    type: 'enum',
    enum: SessionStatus,
    default: SessionStatus.SCHEDULED,
    name: 'status',
  })
  status: SessionStatus;

  @Column({
    type: 'text',
    nullable: true,
    name: 'notes',
  })
  notes: string | null;

  @CreateDateColumn({
    name: 'created_at',
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
  @JoinColumn({ name: 'instructor_id' })
  instructor: User;

  @OneToMany(() => AttendanceRecord, (record) => record.session)
  records: AttendanceRecord[];

  @OneToMany(() => AttendancePhoto, (photo) => photo.session)
  photos: AttendancePhoto[];
}
