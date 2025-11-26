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
  @PrimaryGeneratedColumn('increment', { type: 'bigint' })
  id: number;

  @Column({ type: 'varchar', length: 100, nullable: false })
  name: string;

  @Column({ type: 'varchar', length: 20, unique: true, nullable: false })
  code: string;

  @Column({ type: 'date', nullable: false })
  startDate: Date;

  @Column({ type: 'date', nullable: false })
  endDate: Date;

  @Column({ type: 'date', nullable: false })
  registrationStart: Date;

  @Column({ type: 'date', nullable: false })
  registrationEnd: Date;

  @Column({
    type: 'enum',
    enum: SemesterStatus,
    default: SemesterStatus.UPCOMING,
  })
  status: SemesterStatus;

  @CreateDateColumn()
  createdAt: Date;
}
