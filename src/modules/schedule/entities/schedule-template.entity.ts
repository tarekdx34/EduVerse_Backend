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
import { User } from '../../auth/entities/user.entity';
import { Department } from '../../campus/entities/department.entity';
import { ScheduleTemplateSlot } from './schedule-template-slot.entity';

export enum TemplateScheduleType {
  LECTURE = 'LECTURE',
  LAB = 'LAB',
  TUTORIAL = 'TUTORIAL',
  HYBRID = 'HYBRID',
}

@Entity('schedule_templates')
@Index(['departmentId'])
@Index(['isActive'])
@Index(['createdBy'])
@Index(['scheduleType'])
@Index(['isActive', 'departmentId'])
export class ScheduleTemplate {
  @PrimaryGeneratedColumn({
    name: 'template_id',
    type: 'bigint',
    unsigned: true,
  })
  templateId: number;

  @Column({
    type: 'varchar',
    length: 255,
    nullable: false,
  })
  name: string;

  @Column({
    type: 'text',
    nullable: true,
  })
  description: string | null;

  @Column({
    name: 'department_id',
    type: 'bigint',
    unsigned: true,
    nullable: true,
  })
  departmentId: number | null;

  @ManyToOne(() => Department, { onDelete: 'SET NULL', nullable: true })
  @JoinColumn({ name: 'department_id' })
  department: Department | null;

  @Column({
    name: 'schedule_type',
    type: 'enum',
    enum: TemplateScheduleType,
    default: TemplateScheduleType.LECTURE,
  })
  scheduleType: TemplateScheduleType;

  @Column({
    name: 'created_by',
    type: 'bigint',
    unsigned: true,
    nullable: false,
  })
  createdBy: number;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'created_by' })
  creator: User;

  @Column({
    name: 'is_active',
    type: 'tinyint',
    width: 1,
    default: 1,
  })
  isActive: boolean;

  @CreateDateColumn({
    name: 'created_at',
  })
  createdAt: Date;

  @UpdateDateColumn({
    name: 'updated_at',
  })
  updatedAt: Date;

  @OneToMany(() => ScheduleTemplateSlot, (slot) => slot.template, { cascade: true })
  slots: ScheduleTemplateSlot[];
}
