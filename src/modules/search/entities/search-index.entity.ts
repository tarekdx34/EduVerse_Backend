import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';

export enum SearchEntityType {
  COURSE = 'course',
  MATERIAL = 'material',
  USER = 'user',
  ANNOUNCEMENT = 'announcement',
  ASSIGNMENT = 'assignment',
  QUIZ = 'quiz',
  FILE = 'file',
  POST = 'post',
}

export enum SearchVisibility {
  PUBLIC = 'public',
  STUDENTS = 'students',
  INSTRUCTORS = 'instructors',
  PRIVATE = 'private',
}

@Entity('search_index')
export class SearchIndex {
  @PrimaryGeneratedColumn({ name: 'index_id', type: 'bigint', unsigned: true })
  indexId: number;

  @Column({
    name: 'entity_type',
    type: 'enum',
    enum: SearchEntityType,
  })
  entityType: SearchEntityType;

  @Column({ name: 'entity_id', type: 'bigint', unsigned: true })
  entityId: number;

  @Column({ name: 'title', type: 'varchar', length: 255, nullable: true })
  title: string;

  @Column({ name: 'content', type: 'text', nullable: true })
  content: string;

  @Column({ name: 'keywords', type: 'text', nullable: true })
  keywords: string;

  @Column({ name: 'metadata', type: 'longtext', nullable: true })
  metadata: string;

  @Column({ name: 'search_vector', type: 'text', nullable: true })
  searchVector: string;

  @Column({
    name: 'visibility',
    type: 'enum',
    enum: SearchVisibility,
    default: SearchVisibility.STUDENTS,
  })
  visibility: SearchVisibility;

  @Column({ name: 'campus_id', type: 'bigint', unsigned: true, nullable: true })
  campusId: number;

  @Column({ name: 'course_id', type: 'bigint', unsigned: true, nullable: true })
  courseId: number;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;
}
