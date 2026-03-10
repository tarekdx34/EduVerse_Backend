import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  Index,
} from 'typeorm';
import { SemesterStatus } from '../enums/semester-status.enum';

@Entity('semesters')
@Index('idx_semester_code', ['code'], { unique: true })
export class Semester {
  @PrimaryGeneratedColumn('increment', { type: 'bigint', name: 'semester_id' })
  id: number;

  @Column({ type: 'varchar', length: 100, nullable: false, name: 'semester_name' })
  name: string;

  @Column({ type: 'varchar', length: 20, unique: true, nullable: false, name: 'semester_code' })
  code: string;

  @Column({ type: 'date', nullable: false, name: 'start_date' })
  startDate: Date;

  @Column({ type: 'date', nullable: false, name: 'end_date' })
  endDate: Date;

  @Column({ type: 'date', nullable: true, name: 'registration_start' })
  registrationStart: Date;

  @Column({ type: 'date', nullable: true, name: 'registration_end' })
  registrationEnd: Date;

  @Column({
    type: 'enum',
    enum: SemesterStatus,
    default: SemesterStatus.UPCOMING,
  })
  status: SemesterStatus;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;
}
