import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  Index,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { User } from '../../auth/entities/user.entity';

@Entity('student_face_references')
@Index(['userId', 'isActive'])
@Index(['userId', 'isPrimary'])
export class StudentFaceReference {
  @PrimaryGeneratedColumn({ name: 'reference_id', type: 'bigint', unsigned: true })
  id: number;

  @Column({ name: 'user_id', type: 'bigint', unsigned: true })
  userId: number;

  @Column({ name: 'bucket_name', length: 120 })
  bucketName: string;

  @Column({ name: 'storage_path', length: 500 })
  storagePath: string;

  @Column({ name: 'mime_type', length: 100 })
  mimeType: string;

  @Column({ name: 'file_size', type: 'int', unsigned: true })
  fileSize: number;

  @Column({ name: 'is_primary', type: 'tinyint', default: () => '1' })
  isPrimary: boolean;

  @Column({ name: 'is_active', type: 'tinyint', default: () => '1' })
  isActive: boolean;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'user_id', referencedColumnName: 'userId' })
  user: User;
}

