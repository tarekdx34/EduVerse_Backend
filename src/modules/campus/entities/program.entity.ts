import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
  CreateDateColumn,
  UpdateDateColumn,
  Index,
} from 'typeorm';
import { Status } from '../enums/status.enum';
import { DegreeType } from '../enums/degree-type.enum';
import { Department } from './department.entity';

@Entity('programs')
@Index(['departmentId', 'code'], { unique: true })
export class Program {
  @PrimaryGeneratedColumn('increment', { type: 'bigint' })
  id: number;

  @Column({ type: 'bigint', nullable: false })
  departmentId: number;

  @Column({ type: 'varchar', length: 100, nullable: false })
  name: string;

  @Column({ type: 'varchar', length: 20, nullable: false })
  code: string;

  @Column({ type: 'enum', enum: DegreeType, nullable: false })
  degreeType: DegreeType;

  @Column({ type: 'int', nullable: false })
  durationYears: number;

  @Column({ type: 'text', nullable: true })
  description: string;

  @Column({ type: 'enum', enum: Status, default: Status.ACTIVE })
  status: Status;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @ManyToOne(() => Department, (department) => department.programs, {
    onDelete: 'RESTRICT',
  })
  @JoinColumn({ name: 'departmentId' })
  department: Department;
}
