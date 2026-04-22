import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
  Index,
} from 'typeorm';
import type { Relation } from 'typeorm';
import type { ScheduleTemplate } from './schedule-template.entity';
import { DayOfWeek, ScheduleType } from '../../courses/enums';

@Entity('schedule_template_slots')
@Index(['templateId'])
@Index(['dayOfWeek', 'startTime'])
@Index(['templateId', 'slotType'])
export class ScheduleTemplateSlot {
  @PrimaryGeneratedColumn({
    name: 'slot_id',
    type: 'bigint',
    unsigned: true,
  })
  slotId: number;

  @Column({
    name: 'template_id',
    type: 'bigint',
    unsigned: true,
    nullable: false,
  })
  templateId: number;

  @ManyToOne('ScheduleTemplate', 'slots', { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'template_id' })
  template: Relation<ScheduleTemplate>;

  @Column({
    name: 'day_of_week',
    type: 'enum',
    enum: DayOfWeek,
    nullable: false,
  })
  dayOfWeek: DayOfWeek;

  @Column({
    name: 'start_time',
    type: 'time',
    nullable: false,
  })
  startTime: string;

  @Column({
    name: 'end_time',
    type: 'time',
    nullable: false,
  })
  endTime: string;

  @Column({
    name: 'slot_type',
    type: 'enum',
    enum: ScheduleType,
    nullable: false,
  })
  slotType: ScheduleType;

  @Column({
    name: 'duration_minutes',
    type: 'int',
    nullable: false,
  })
  durationMinutes: number;

  @Column({
    type: 'varchar',
    length: 100,
    nullable: true,
  })
  building: string | null;

  @Column({
    type: 'varchar',
    length: 100,
    nullable: true,
  })
  room: string | null;
}
