import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
  CreateDateColumn,
} from 'typeorm';
import type { Relation } from 'typeorm';
import type { User } from '../../auth/entities/user.entity';
import type { StudentTask } from './student-task.entity';

@Entity('task_completion')
export class TaskCompletion {
  @PrimaryGeneratedColumn({ name: 'completion_id', type: 'bigint', unsigned: true })
  completionId: number;

  @Column({ name: 'task_id', type: 'bigint', unsigned: true, unique: true })
  taskId: number;

  @Column({ name: 'user_id', type: 'bigint', unsigned: true })
  userId: number;

  @CreateDateColumn({ name: 'completed_at', type: 'timestamp' })
  completedAt: Date;

  @Column({ name: 'time_taken_minutes', type: 'int', nullable: true })
  timeTakenMinutes: number | null;

  @Column({ name: 'notes', type: 'text', nullable: true })
  notes: string | null;

  @ManyToOne('StudentTask')
  @JoinColumn({ name: 'task_id' })
  task: Relation<StudentTask>;

  @ManyToOne('User')
  @JoinColumn({ name: 'user_id' })
  user: Relation<User>;
}
