import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
} from 'typeorm';

@Entity('quiz_difficulty_levels')
export class QuizDifficultyLevel {
  @PrimaryGeneratedColumn({ name: 'difficulty_id', type: 'int', unsigned: true })
  id: number;

  @Column({ name: 'level_name', type: 'varchar', length: 50 })
  levelName: string;

  @Column({ name: 'difficulty_value', type: 'int' })
  difficultyValue: number;

  @Column({ type: 'text', nullable: true })
  description: string;
}
