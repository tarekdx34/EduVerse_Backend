// src/modules/google-drive/entities/drive-folder.entity.ts
import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  OneToMany,
  JoinColumn,
  Index,
} from 'typeorm';
import { User } from '../../auth/entities/user.entity';

export enum DriveFolderType {
  ROOT = 'root',
  DEPARTMENT = 'department',
  ACADEMIC_YEAR = 'academic_year',
  SEMESTER = 'semester',
  COURSE = 'course',
  COURSE_GENERAL = 'course_general',
  COURSE_LECTURES = 'course_lectures',
  COURSE_LABS = 'course_labs',
  COURSE_ASSIGNMENTS = 'course_assignments',
  COURSE_PROJECTS = 'course_projects',
  LECTURE_WEEK = 'lecture_week',
  LAB = 'lab',
  LAB_INSTRUCTIONS = 'lab_instructions',
  LAB_TA_MATERIALS = 'lab_ta_materials',
  LAB_SUBMISSIONS = 'lab_submissions',
  LAB_STUDENT_SUBMISSION = 'lab_student_submission',
  ASSIGNMENT = 'assignment',
  ASSIGNMENT_INSTRUCTIONS = 'assignment_instructions',
  ASSIGNMENT_SUBMISSIONS = 'assignment_submissions',
  ASSIGNMENT_STUDENT_SUBMISSION = 'assignment_student_submission',
  PROJECT = 'project',
  PROJECT_INSTRUCTIONS = 'project_instructions',
  PROJECT_TA_MATERIALS = 'project_ta_materials',
  PROJECT_SUBMISSIONS = 'project_submissions',
  PROJECT_GROUP_SUBMISSION = 'project_group_submission',
}

export enum DriveEntityType {
  DEPARTMENT = 'department',
  SEMESTER = 'semester',
  COURSE = 'course',
  LAB = 'lab',
  ASSIGNMENT = 'assignment',
  PROJECT = 'project',
  USER = 'user',
  GROUP = 'group',
}

@Entity('drive_folders')
@Index(['entityType', 'entityId'])
@Index(['folderType'])
@Index(['parentDriveFolderId'])
export class DriveFolder {
  @PrimaryGeneratedColumn({ name: 'drive_folder_id', type: 'bigint', unsigned: true })
  driveFolderId: number;

  @Column({ name: 'drive_id', type: 'varchar', length: 100, unique: true })
  driveId: string;

  @Column({
    name: 'folder_type',
    type: 'enum',
    enum: DriveFolderType,
  })
  folderType: DriveFolderType;

  @Column({ name: 'parent_drive_folder_id', type: 'bigint', unsigned: true, nullable: true })
  parentDriveFolderId: number | null;

  @Column({
    name: 'entity_type',
    type: 'enum',
    enum: DriveEntityType,
    nullable: true,
  })
  entityType: DriveEntityType | null;

  @Column({ name: 'entity_id', type: 'bigint', unsigned: true, nullable: true })
  entityId: number | null;

  @Column({ name: 'folder_name', type: 'varchar', length: 255 })
  folderName: string;

  @Column({ name: 'folder_path', type: 'varchar', length: 1000, nullable: true })
  folderPath: string | null;

  @Column({ name: 'created_by', type: 'bigint', unsigned: true })
  createdBy: number;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  // Relations
  @ManyToOne(() => DriveFolder, (folder) => folder.children, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'parent_drive_folder_id' })
  parent: DriveFolder | null;

  @OneToMany(() => DriveFolder, (folder) => folder.parent)
  children: DriveFolder[];

  @ManyToOne(() => User)
  @JoinColumn({ name: 'created_by', referencedColumnName: 'userId' })
  creator: User;
}
