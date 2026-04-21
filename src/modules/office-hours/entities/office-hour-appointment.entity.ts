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
import type { OfficeHourSlot } from './office-hour-slot.entity';

@Entity('office_hour_appointments')
export class OfficeHourAppointment {
  @PrimaryGeneratedColumn({ name: 'appointment_id', type: 'bigint', unsigned: true })
  appointmentId: number;

  @Column({ name: 'slot_id', type: 'bigint', unsigned: true })
  slotId: number;

  @Column({ name: 'student_id', type: 'bigint', unsigned: true })
  studentId: number;

  @Column({ name: 'appointment_date', type: 'date' })
  appointmentDate: Date;

  @Column({ name: 'start_time', type: 'time' })
  startTime: string;

  @Column({ name: 'end_time', type: 'time' })
  endTime: string;

  @Column({ type: 'varchar', length: 255, nullable: true })
  topic: string;

  @Column({ type: 'text', nullable: true })
  notes: string;

  @Column({
    type: 'enum',
    enum: ['booked', 'confirmed', 'cancelled', 'completed', 'no_show'],
    default: 'booked',
  })
  status: string;

  @Column({ name: 'cancelled_by', type: 'bigint', unsigned: true, nullable: true })
  cancelledBy: number;

  @Column({ name: 'cancelled_at', type: 'timestamp', nullable: true })
  cancelledAt: Date;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  @ManyToOne('OfficeHourSlot')
  @JoinColumn({ name: 'slot_id' })
  slot: Relation<OfficeHourSlot>;

  @ManyToOne('User')
  @JoinColumn({ name: 'student_id' })
  student: Relation<User>;
}
