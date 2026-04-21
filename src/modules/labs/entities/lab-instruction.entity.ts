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

@Entity('lab_instructions')
export class LabInstruction {
  @PrimaryGeneratedColumn('increment', { name: 'instruction_id', type: 'bigint', unsigned: true })
  id: number;

  @Column({ name: 'lab_id', type: 'bigint', unsigned: true })
  labId: number;

  @Column({ name: 'file_id', type: 'bigint', unsigned: true, nullable: true })
  fileId: number;

  @Column({ name: 'instruction_text', type: 'text', nullable: true })
  instructionText: string;

  @Column({ name: 'order_index', type: 'int', default: 0 })
  orderIndex: number;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @ManyToOne('Lab', 'instructions')
  @JoinColumn({ name: 'lab_id' })
  lab: Relation<Lab>;
}
