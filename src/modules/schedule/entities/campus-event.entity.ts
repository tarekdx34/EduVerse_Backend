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
import { Campus } from '../../campus/entities/campus.entity';
import { Program } from '../../campus/entities/program.entity';
import { CampusEventRegistration } from './campus-event-registration.entity';

export enum CampusEventType {
  UNIVERSITY_WIDE = 'university_wide',
  DEPARTMENT = 'department',
  CAMPUS = 'campus',
  PROGRAM = 'program',
}

export enum CampusEventStatus {
  DRAFT = 'draft',
  PUBLISHED = 'published',
  CANCELLED = 'cancelled',
  COMPLETED = 'completed',
}

@Entity('campus_events')
@Index(['eventType'])
@Index(['eventType', 'scopeId'])
@Index(['startDatetime', 'endDatetime'])
@Index(['status'])
@Index(['startDatetime', 'status'])
export class CampusEvent {
  @PrimaryGeneratedColumn({
    name: 'event_id',
    type: 'bigint',
    unsigned: true,
  })
  eventId: number;

  @Column({
    type: 'varchar',
    length: 255,
    nullable: false,
  })
  title: string;

  @Column({
    type: 'text',
    nullable: true,
  })
  description: string | null;

  @Column({
    name: 'event_type',
    type: 'enum',
    enum: CampusEventType,
    default: CampusEventType.UNIVERSITY_WIDE,
  })
  eventType: CampusEventType;

  @Column({
    name: 'scope_id',
    type: 'bigint',
    unsigned: true,
    nullable: true,
  })
  scopeId: number | null;

  @Column({
    name: 'start_datetime',
    type: 'datetime',
    nullable: false,
  })
  startDatetime: Date;

  @Column({
    name: 'end_datetime',
    type: 'datetime',
    nullable: false,
  })
  endDatetime: Date;

  @Column({
    type: 'varchar',
    length: 255,
    nullable: true,
  })
  location: string | null;

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

  @Column({
    name: 'organizer_id',
    type: 'bigint',
    unsigned: true,
    nullable: false,
  })
  organizerId: number;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'organizer_id' })
  organizer: User;

  @Column({
    name: 'is_mandatory',
    type: 'tinyint',
    width: 1,
    default: 0,
  })
  isMandatory: boolean;

  @Column({
    name: 'registration_required',
    type: 'tinyint',
    width: 1,
    default: 0,
  })
  registrationRequired: boolean;

  @Column({
    name: 'max_attendees',
    type: 'int',
    nullable: true,
  })
  maxAttendees: number | null;

  @Column({
    type: 'varchar',
    length: 7,
    default: '#10B981',
  })
  color: string;

  @Column({
    type: 'enum',
    enum: CampusEventStatus,
    default: CampusEventStatus.DRAFT,
  })
  status: CampusEventStatus;

  @Column({
    type: 'json',
    nullable: true,
  })
  tags: string[] | null;

  @CreateDateColumn({
    name: 'created_at',
  })
  createdAt: Date;

  @UpdateDateColumn({
    name: 'updated_at',
  })
  updatedAt: Date;

  @OneToMany(() => CampusEventRegistration, (registration) => registration.event)
  registrations: CampusEventRegistration[];

  // Virtual relations for scope
  // These are not actual FK in DB but useful for joins
  department?: Department;
  campus?: Campus;
  program?: Program;
}
