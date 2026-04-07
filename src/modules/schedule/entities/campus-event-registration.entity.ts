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
import { CampusEvent } from './campus-event.entity';
import { User } from '../../auth/entities/user.entity';

export enum RegistrationStatus {
  REGISTERED = 'registered',
  ATTENDED = 'attended',
  CANCELLED = 'cancelled',
  NO_SHOW = 'no_show',
}

@Entity('campus_event_registrations')
@Index(['eventId', 'userId'], { unique: true })
@Index(['eventId'])
@Index(['userId'])
@Index(['status'])
@Index(['eventId', 'status'])
export class CampusEventRegistration {
  @PrimaryGeneratedColumn({
    name: 'registration_id',
    type: 'bigint',
    unsigned: true,
  })
  registrationId: number;

  @Column({
    name: 'event_id',
    type: 'bigint',
    unsigned: true,
    nullable: false,
  })
  eventId: number;

  @ManyToOne(() => CampusEvent, (event) => event.registrations, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'event_id' })
  event: CampusEvent;

  @Column({
    name: 'user_id',
    type: 'bigint',
    unsigned: true,
    nullable: false,
  })
  userId: number;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'user_id' })
  user: User;

  @Column({
    type: 'enum',
    enum: RegistrationStatus,
    default: RegistrationStatus.REGISTERED,
  })
  status: RegistrationStatus;

  @Column({
    type: 'text',
    nullable: true,
  })
  notes: string | null;

  @CreateDateColumn({
    name: 'registered_at',
  })
  registeredAt: Date;

  @UpdateDateColumn({
    name: 'updated_at',
  })
  updatedAt: Date;
}
