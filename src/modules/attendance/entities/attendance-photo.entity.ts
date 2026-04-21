import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
  Index,
} from 'typeorm';
import type { Relation } from 'typeorm';
import { PhotoType, ProcessingStatus } from '../enums';
import type { AttendanceSession } from './attendance-session.entity';
import type { User } from '../../auth/entities/user.entity';

@Entity('attendance_photos')
@Index(['sessionId'])
@Index(['uploadedBy'])
export class AttendancePhoto {
  @PrimaryGeneratedColumn('increment', {
    name: 'photo_id',
    type: 'bigint',
  })
  id: number;

  @Column({
    type: 'bigint',
    nullable: false,
    name: 'session_id',
  })
  sessionId: number;

  @Column({
    type: 'bigint',
    unsigned: true,
    nullable: true,
    name: 'file_id',
  })
  fileId: number | null;

  @Column({
    type: 'bigint',
    unsigned: true,
    nullable: false,
    name: 'uploaded_by',
  })
  uploadedBy: number;

  @Column({
    type: 'enum',
    enum: PhotoType,
    default: PhotoType.CLASS_PHOTO,
    name: 'photo_type',
  })
  photoType: PhotoType;

  @Column({
    type: 'timestamp',
    default: () => 'CURRENT_TIMESTAMP',
    name: 'capture_timestamp',
  })
  captureTimestamp: Date;

  @Column({
    type: 'enum',
    enum: ProcessingStatus,
    default: ProcessingStatus.PENDING,
    name: 'processing_status',
  })
  processingStatus: ProcessingStatus;

  @ManyToOne('AttendanceSession', 'photos', {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'session_id' })
  session: Relation<AttendanceSession>;

  @ManyToOne('User', {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'uploaded_by' })
  uploader: Relation<User>;
}
