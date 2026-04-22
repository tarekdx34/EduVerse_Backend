import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import type { Relation } from 'typeorm';
import type { User } from '../../auth/entities/user.entity';

@Entity('office_hour_slots')
export class OfficeHourSlot {
  @PrimaryGeneratedColumn({ name: 'slot_id', type: 'bigint', unsigned: true })
  slotId: number;

  @Column({ name: 'instructor_id', type: 'bigint', unsigned: true })
  instructorId: number;

  @Column({
    name: 'day_of_week',
    type: 'enum',
    enum: ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'],
  })
  dayOfWeek: string;

  @Column({ name: 'start_time', type: 'time' })
  startTime: string;

  @Column({ name: 'end_time', type: 'time' })
  endTime: string;

  @Column({ type: 'varchar', length: 255, nullable: true })
  location: string;

  @Column({
    type: 'enum',
    enum: ['in_person', 'online', 'hybrid'],
    default: 'in_person',
  })
  mode: string;

  @Column({ name: 'meeting_url', type: 'varchar', length: 500, nullable: true })
  meetingUrl: string;

  @Column({ name: 'max_appointments', type: 'int', default: 4 })
  maxAppointments: number;

  @Column({ name: 'is_recurring', type: 'tinyint', default: 1 })
  isRecurring: boolean;

  @Column({ name: 'effective_from', type: 'date', nullable: true })
  effectiveFrom: Date;

  @Column({ name: 'effective_until', type: 'date', nullable: true })
  effectiveUntil: Date;

  @Column({
    type: 'enum',
    enum: ['active', 'cancelled', 'suspended'],
    default: 'active',
  })
  status: string;

  @Column({ type: 'text', nullable: true })
  notes: string;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  @ManyToOne('User')
  @JoinColumn({ name: 'instructor_id' })
  instructor: Relation<User>;
}
