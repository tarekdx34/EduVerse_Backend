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
  @PrimaryGeneratedColumn('increment', {
    type: 'bigint',
    name: 'program_id', // Map to actual column name
  })
  id: number;

  @Column({
    type: 'bigint',
    nullable: false,
    name: 'department_id', // Map to actual column name
  })
  departmentId: number;

  @Column({
    type: 'varchar',
    length: 200,
    nullable: false,
    name: 'program_name', // Map to actual column name
  })
  name: string;

  @Column({
    type: 'varchar',
    length: 20,
    nullable: false,
    name: 'program_code', // Map to actual column name
  })
  code: string;

  @Column({
    type: 'enum',
    enum: DegreeType,
    nullable: false,
    name: 'degree_type', // Map to actual column name
  })
  degreeType: DegreeType;

  @Column({
    type: 'int',
    nullable: true,
    name: 'duration_years', // Map to actual column name
  })
  durationYears: number;

  @Column({ type: 'text', nullable: true })
  description: string;

  @Column({
    type: 'enum',
    enum: Status,
    default: Status.ACTIVE,
  })
  status: Status;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  @ManyToOne(() => Department, (department) => department.programs, {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'department_id' })
  department: Department;
}
