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
  @PrimaryGeneratedColumn('increment', { type: 'bigint' })
  id: number;

  @Column({ type: 'bigint', nullable: false })
  campusId: number;

  @Column({ type: 'varchar', length: 100, nullable: false })
  name: string;

  @Column({ type: 'varchar', length: 20, nullable: false })
  code: string;

  @Column({ type: 'bigint', nullable: true })
  headOfDepartmentId: number;

  @Column({ type: 'text', nullable: true })
  description: string;

  @Column({ type: 'enum', enum: Status, default: Status.ACTIVE })
  status: Status;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @ManyToOne(() => Campus, (campus) => campus.departments, {
    onDelete: 'RESTRICT',
  })
  @JoinColumn({ name: 'campusId' })
  campus: Campus;

  @OneToMany(() => Program, (program) => program.department)
  programs: Program[];

  @ManyToOne(() => User, { nullable: true })
  @JoinColumn({ name: 'headOfDepartmentId' })
  head: User;
}
