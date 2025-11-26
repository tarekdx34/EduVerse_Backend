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
import { Status } from '../enums/status.enum';
import { Campus } from './campus.entity';
import { Program } from './program.entity';
import { User } from '../../auth/entities/user.entity';

@Entity('departments')
@Index(['campusId', 'code'], { unique: true })
export class Department {
  @PrimaryGeneratedColumn('increment', {
    name: 'department_id',
    type: 'bigint',
  })
  id: number;

  @Column({
    type: 'bigint',
    nullable: false,
    name: 'campus_id', // Map to actual column name
  })
  campusId: number;

  @Column({
    type: 'varchar',
    length: 200,
    nullable: false,
    name: 'department_name', // Map to actual column name
  })
  name: string;

  @Column({
    type: 'varchar',
    length: 20,
    nullable: false,
    name: 'department_code', // Map to actual column name
  })
  code: string;

  @Column({
    type: 'bigint',
    nullable: true,
    name: 'head_of_department_id', // Map to actual column name
  })
  headOfDepartmentId: number;

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

  @ManyToOne(() => Campus, (campus) => campus.departments, {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'campus_id' })
  campus: Campus;

  @OneToMany(() => Program, (program) => program.department)
  programs: Program[];

  @ManyToOne(() => User, { nullable: true })
  @JoinColumn({ name: 'head_of_department_id' })
  head: User;
}
