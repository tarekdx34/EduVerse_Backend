// src/modules/google-drive/services/drive-folder.service.ts
import { Injectable, Logger, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, DataSource } from 'typeorm';
import { ConfigService } from '@nestjs/config';
import { GoogleDriveService } from '../google-drive.service';
import { DriveFolder, DriveFolderType, DriveEntityType } from '../entities/drive-folder.entity';
import { DriveFile, DriveFileEntityType } from '../entities/drive-file.entity';

@Injectable()
export class DriveFolderService {
  private readonly logger = new Logger(DriveFolderService.name);

  constructor(
    @InjectRepository(DriveFolder)
    private driveFolderRepository: Repository<DriveFolder>,
    @InjectRepository(DriveFile)
    private driveFileRepository: Repository<DriveFile>,
    private driveService: GoogleDriveService,
    private configService: ConfigService,
    private dataSource: DataSource,
  ) {}

  // ============================================================================
  // ROOT FOLDER MANAGEMENT
  // ============================================================================

  /**
   * Initialize or get the root EduVerse folder
   */
  async initRootFolder(userId: number): Promise<DriveFolder> {
    // Check if root folder already exists in DB
    let rootFolder = await this.driveFolderRepository.findOne({
      where: { folderType: DriveFolderType.ROOT },
    });

    if (rootFolder) {
      this.logger.log(`Root folder already exists: ${rootFolder.driveId}`);
      return rootFolder;
    }

    // Check if we have a root folder ID in env
    let rootFolderId = this.configService.get<string>('GOOGLE_DRIVE_ROOT_FOLDER_ID');

    if (!rootFolderId) {
      // Create new root folder in Drive
      const driveFolder = await this.driveService.createFolder('EduVerse');
      rootFolderId = driveFolder.id;
      this.logger.log(`Created new EduVerse root folder: ${rootFolderId}`);
    }

    // Save to database
    rootFolder = this.driveFolderRepository.create({
      driveId: rootFolderId,
      folderType: DriveFolderType.ROOT,
      folderName: 'EduVerse',
      folderPath: 'EduVerse',
      createdBy: userId,
    });

    await this.driveFolderRepository.save(rootFolder);
    this.logger.log(`Root folder saved to database: ${rootFolder.driveFolderId}`);

    return rootFolder;
  }

  /**
   * Get root folder or throw if not initialized
   */
  async getRootFolder(): Promise<DriveFolder> {
    const rootFolder = await this.driveFolderRepository.findOne({
      where: { folderType: DriveFolderType.ROOT },
    });

    if (!rootFolder) {
      throw new NotFoundException('EduVerse root folder not initialized. Call POST /api/admin/google-drive/init first.');
    }

    return rootFolder;
  }

  // ============================================================================
  // COURSE HIERARCHY MANAGEMENT
  // ============================================================================

  /**
   * Ensure complete folder hierarchy exists for a course
   * Creates: Department → Academic Year → Semester → Course → (General, Lectures, Labs, Assignments, Projects)
   */
  async ensureCourseHierarchy(
    courseId: number,
    userId: number,
  ): Promise<{
    course: DriveFolder;
    general: DriveFolder;
    lectures: DriveFolder;
    labs: DriveFolder;
    assignments: DriveFolder;
    projects: DriveFolder;
  }> {
    // Get course with department
    const courseData = await this.dataSource.query(
      `SELECT c.course_id, c.course_name, c.course_code, 
              d.department_id, d.department_name,
              cs.semester_id
       FROM courses c
       JOIN departments d ON c.department_id = d.department_id
       LEFT JOIN course_sections cs ON cs.course_id = c.course_id
       WHERE c.course_id = ?
       LIMIT 1`,
      [courseId],
    );

    if (!courseData || courseData.length === 0) {
      throw new NotFoundException(`Course ${courseId} not found`);
    }

    const course = courseData[0];
    
    // Get or create root folder
    const rootFolder = await this.getRootFolder();

    // Get or create department folder
    const departmentFolder = await this.getOrCreateFolder(
      course.department_name.replace(/[^a-zA-Z0-9_-]/g, '_'),
      DriveFolderType.DEPARTMENT,
      rootFolder.driveFolderId,
      DriveEntityType.DEPARTMENT,
      course.department_id,
      userId,
      `${rootFolder.folderPath}/${course.department_name}`,
    );

    // Get or create academic year folder (use current academic year)
    const academicYear = this.getCurrentAcademicYear();
    const yearFolder = await this.getOrCreateFolder(
      academicYear,
      DriveFolderType.ACADEMIC_YEAR,
      departmentFolder.driveFolderId,
      null,
      null,
      userId,
      `${departmentFolder.folderPath}/${academicYear}`,
    );

    // Get or create semester folder
    const semesterName = await this.getCurrentSemesterName(course.semester_id);
    const semesterFolder = await this.getOrCreateFolder(
      semesterName,
      DriveFolderType.SEMESTER,
      yearFolder.driveFolderId,
      DriveEntityType.SEMESTER,
      course.semester_id,
      userId,
      `${yearFolder.folderPath}/${semesterName}`,
    );

    // Get or create course folder
    const courseFolderName = `${course.course_code}_${course.course_name}`.replace(/[^a-zA-Z0-9_-]/g, '_');
    const courseFolder = await this.getOrCreateFolder(
      courseFolderName,
      DriveFolderType.COURSE,
      semesterFolder.driveFolderId,
      DriveEntityType.COURSE,
      courseId,
      userId,
      `${semesterFolder.folderPath}/${courseFolderName}`,
    );

    // Create course subfolders
    const general = await this.getOrCreateFolder(
      'General',
      DriveFolderType.COURSE_GENERAL,
      courseFolder.driveFolderId,
      DriveEntityType.COURSE,
      courseId,
      userId,
      `${courseFolder.folderPath}/General`,
    );

    const lectures = await this.getOrCreateFolder(
      'Lectures',
      DriveFolderType.COURSE_LECTURES,
      courseFolder.driveFolderId,
      DriveEntityType.COURSE,
      courseId,
      userId,
      `${courseFolder.folderPath}/Lectures`,
    );

    const labs = await this.getOrCreateFolder(
      'Labs',
      DriveFolderType.COURSE_LABS,
      courseFolder.driveFolderId,
      DriveEntityType.COURSE,
      courseId,
      userId,
      `${courseFolder.folderPath}/Labs`,
    );

    const assignments = await this.getOrCreateFolder(
      'Assignments',
      DriveFolderType.COURSE_ASSIGNMENTS,
      courseFolder.driveFolderId,
      DriveEntityType.COURSE,
      courseId,
      userId,
      `${courseFolder.folderPath}/Assignments`,
    );

    const projects = await this.getOrCreateFolder(
      'Projects',
      DriveFolderType.COURSE_PROJECTS,
      courseFolder.driveFolderId,
      DriveEntityType.COURSE,
      courseId,
      userId,
      `${courseFolder.folderPath}/Projects`,
    );

    return { course: courseFolder, general, lectures, labs, assignments, projects };
  }

  /**
   * Get or create a lecture week folder
   */
  async ensureLectureWeekFolder(
    courseId: number,
    weekNumber: number,
    userId: number,
  ): Promise<DriveFolder> {
    const hierarchy = await this.ensureCourseHierarchy(courseId, userId);
    
    const weekFolderName = `Week_${weekNumber.toString().padStart(2, '0')}`;
    
    return this.getOrCreateFolder(
      weekFolderName,
      DriveFolderType.LECTURE_WEEK,
      hierarchy.lectures.driveFolderId,
      DriveEntityType.COURSE,
      courseId,
      userId,
      `${hierarchy.lectures.folderPath}/${weekFolderName}`,
    );
  }

  // ============================================================================
  // LAB FOLDER MANAGEMENT
  // ============================================================================

  /**
   * Create complete lab folder structure
   * Creates: Labs/Lab_XX/instructions, ta_materials, submissions
   */
  async createLabFolderStructure(
    labId: number,
    userId: number,
  ): Promise<{
    lab: DriveFolder;
    instructions: DriveFolder;
    taMaterials: DriveFolder;
    submissions: DriveFolder;
  }> {
    // Get lab data
    const labData = await this.dataSource.query(
      `SELECT l.lab_id, l.course_id, l.title, l.lab_number
       FROM labs l
       WHERE l.lab_id = ?`,
      [labId],
    );

    if (!labData || labData.length === 0) {
      throw new NotFoundException(`Lab ${labId} not found`);
    }

    const lab = labData[0];
    
    // Ensure course hierarchy exists
    const hierarchy = await this.ensureCourseHierarchy(lab.course_id, userId);
    
    // Create lab folder
    const labNumber = lab.lab_number || labId;
    const labFolderName = `Lab_${labNumber.toString().padStart(2, '0')}_${lab.title}`.replace(/[^a-zA-Z0-9_-]/g, '_');
    
    const labFolder = await this.getOrCreateFolder(
      labFolderName,
      DriveFolderType.LAB,
      hierarchy.labs.driveFolderId,
      DriveEntityType.LAB,
      labId,
      userId,
      `${hierarchy.labs.folderPath}/${labFolderName}`,
    );

    // Create subfolders
    const instructions = await this.getOrCreateFolder(
      'instructions',
      DriveFolderType.LAB_INSTRUCTIONS,
      labFolder.driveFolderId,
      DriveEntityType.LAB,
      labId,
      userId,
      `${labFolder.folderPath}/instructions`,
    );

    const taMaterials = await this.getOrCreateFolder(
      'ta_materials',
      DriveFolderType.LAB_TA_MATERIALS,
      labFolder.driveFolderId,
      DriveEntityType.LAB,
      labId,
      userId,
      `${labFolder.folderPath}/ta_materials`,
    );

    const submissions = await this.getOrCreateFolder(
      'submissions',
      DriveFolderType.LAB_SUBMISSIONS,
      labFolder.driveFolderId,
      DriveEntityType.LAB,
      labId,
      userId,
      `${labFolder.folderPath}/submissions`,
    );

    return { lab: labFolder, instructions, taMaterials, submissions };
  }

  /**
   * Create student submission folder for a lab
   */
  async createLabStudentSubmissionFolder(
    labId: number,
    studentId: number,
    userId: number,
  ): Promise<DriveFolder> {
    // Get student info
    const studentData = await this.dataSource.query(
      `SELECT user_id, first_name, last_name FROM users WHERE user_id = ?`,
      [studentId],
    );

    if (!studentData || studentData.length === 0) {
      throw new NotFoundException(`Student ${studentId} not found`);
    }

    const student = studentData[0];
    const labFolders = await this.createLabFolderStructure(labId, userId);
    
    const studentFolderName = `${studentId}_${student.first_name}_${student.last_name}`.replace(/[^a-zA-Z0-9_-]/g, '_');

    return this.getOrCreateFolder(
      studentFolderName,
      DriveFolderType.LAB_STUDENT_SUBMISSION,
      labFolders.submissions.driveFolderId,
      DriveEntityType.USER,
      studentId,
      userId,
      `${labFolders.submissions.folderPath}/${studentFolderName}`,
    );
  }

  // ============================================================================
  // ASSIGNMENT FOLDER MANAGEMENT
  // ============================================================================

  /**
   * Create complete assignment folder structure
   */
  async createAssignmentFolderStructure(
    assignmentId: number,
    userId: number,
  ): Promise<{
    assignment: DriveFolder;
    instructions: DriveFolder;
    submissions: DriveFolder;
  }> {
    // Get assignment data
    const assignmentData = await this.dataSource.query(
      `SELECT a.assignment_id, a.course_id, a.title
       FROM assignments a
       WHERE a.assignment_id = ?`,
      [assignmentId],
    );

    if (!assignmentData || assignmentData.length === 0) {
      throw new NotFoundException(`Assignment ${assignmentId} not found`);
    }

    const assignment = assignmentData[0];
    
    // Ensure course hierarchy exists
    const hierarchy = await this.ensureCourseHierarchy(assignment.course_id, userId);
    
    // Create assignment folder
    const assignmentFolderName = `Assignment_${assignmentId.toString().padStart(2, '0')}_${assignment.title}`.replace(/[^a-zA-Z0-9_-]/g, '_');
    
    const assignmentFolder = await this.getOrCreateFolder(
      assignmentFolderName,
      DriveFolderType.ASSIGNMENT,
      hierarchy.assignments.driveFolderId,
      DriveEntityType.ASSIGNMENT,
      assignmentId,
      userId,
      `${hierarchy.assignments.folderPath}/${assignmentFolderName}`,
    );

    // Create subfolders
    const instructions = await this.getOrCreateFolder(
      'instructions',
      DriveFolderType.ASSIGNMENT_INSTRUCTIONS,
      assignmentFolder.driveFolderId,
      DriveEntityType.ASSIGNMENT,
      assignmentId,
      userId,
      `${assignmentFolder.folderPath}/instructions`,
    );

    const submissions = await this.getOrCreateFolder(
      'submissions',
      DriveFolderType.ASSIGNMENT_SUBMISSIONS,
      assignmentFolder.driveFolderId,
      DriveEntityType.ASSIGNMENT,
      assignmentId,
      userId,
      `${assignmentFolder.folderPath}/submissions`,
    );

    return { assignment: assignmentFolder, instructions, submissions };
  }

  /**
   * Create student submission folder for an assignment
   */
  async createAssignmentStudentSubmissionFolder(
    assignmentId: number,
    studentId: number,
    userId: number,
  ): Promise<DriveFolder> {
    // Get student info
    const studentData = await this.dataSource.query(
      `SELECT user_id, first_name, last_name FROM users WHERE user_id = ?`,
      [studentId],
    );

    if (!studentData || studentData.length === 0) {
      throw new NotFoundException(`Student ${studentId} not found`);
    }

    const student = studentData[0];
    const assignmentFolders = await this.createAssignmentFolderStructure(assignmentId, userId);
    
    const studentFolderName = `${studentId}_${student.first_name}_${student.last_name}`.replace(/[^a-zA-Z0-9_-]/g, '_');

    return this.getOrCreateFolder(
      studentFolderName,
      DriveFolderType.ASSIGNMENT_STUDENT_SUBMISSION,
      assignmentFolders.submissions.driveFolderId,
      DriveEntityType.USER,
      studentId,
      userId,
      `${assignmentFolders.submissions.folderPath}/${studentFolderName}`,
    );
  }

  // ============================================================================
  // FILE UPLOAD HELPERS
  // ============================================================================

  /**
   * Upload a file to Drive and save record to database
   */
  async uploadFileToDrive(
    buffer: Buffer,
    fileName: string,
    mimeType: string,
    folderId: number,
    entityType: DriveFileEntityType | null,
    entityId: number | null,
    userId: number,
  ): Promise<DriveFile> {
    // Get folder to get the Drive ID
    const folder = await this.driveFolderRepository.findOne({
      where: { driveFolderId: folderId },
    });

    if (!folder) {
      throw new NotFoundException(`Folder ${folderId} not found`);
    }

    // Upload to Google Drive
    const driveFile = await this.driveService.uploadFile(
      buffer,
      fileName,
      mimeType,
      folder.driveId,
    );

    // Make file publicly accessible so links work
    await this.driveService.makeFilePublic(driveFile.id);

    // Save to database
    const dbFile = this.driveFileRepository.create({
      driveId: driveFile.id,
      driveFolderId: folderId,
      fileName: fileName,
      originalFileName: fileName,
      mimeType: mimeType,
      fileSize: parseInt(driveFile.size || '0', 10),
      webViewLink: driveFile.webViewLink,
      webContentLink: driveFile.webContentLink,
      thumbnailLink: driveFile.thumbnailLink,
      entityType: entityType,
      entityId: entityId,
      uploadedBy: userId,
    });

    await this.driveFileRepository.save(dbFile);
    
    this.logger.log(`Uploaded file ${fileName} to Drive: ${driveFile.id}`);
    
    return dbFile;
  }

  // ============================================================================
  // QUERY HELPERS
  // ============================================================================

  /**
   * Get folder by entity type and ID
   */
  async getFolderByEntity(
    entityType: DriveEntityType,
    entityId: number,
    folderType?: DriveFolderType,
  ): Promise<DriveFolder | null> {
    const where: any = { entityType, entityId };
    if (folderType) {
      where.folderType = folderType;
    }
    
    return this.driveFolderRepository.findOne({ where });
  }

  /**
   * Get files in a folder
   */
  async getFilesInFolder(folderId: number): Promise<DriveFile[]> {
    return this.driveFileRepository.find({
      where: { driveFolderId: folderId },
      order: { createdAt: 'DESC' },
    });
  }

  /**
   * Get folder tree for a course
   */
  async getCourseTree(courseId: number): Promise<DriveFolder[]> {
    return this.driveFolderRepository.find({
      where: { entityType: DriveEntityType.COURSE, entityId: courseId },
      order: { folderPath: 'ASC' },
    });
  }

  /**
   * Get full folder tree
   */
  async getFullTree(): Promise<DriveFolder[]> {
    return this.driveFolderRepository.find({
      order: { folderPath: 'ASC' },
      relations: ['children'],
    });
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /**
   * Get or create a folder (idempotent)
   * Includes comprehensive check-first logic:
   * 1. Check database for existing folder
   * 2. Verify parent folder exists in Google Drive (recover if stale)
   * 3. Check if folder already exists in Google Drive by name
   * 4. Use existing or create new folder in Drive
   * 5. Sync result back to database
   */
  private async getOrCreateFolder(
    name: string,
    folderType: DriveFolderType,
    parentDriveFolderId: number,
    entityType: DriveEntityType | null,
    entityId: number | null,
    userId: number,
    folderPath: string,
  ): Promise<DriveFolder> {
    // STEP 1: Check if folder exists in database
    const existing = await this.driveFolderRepository.findOne({
      where: {
        folderType,
        parentDriveFolderId,
        folderName: name,
      },
    });

    if (existing) {
      this.logger.debug(`📁 Folder found in DB: ${name} (ID: ${existing.driveFolderId})`);
      return existing;
    }

    // STEP 2: Get parent folder from database
    const parentFolder = await this.driveFolderRepository.findOne({
      where: { driveFolderId: parentDriveFolderId },
    });

    if (!parentFolder) {
      throw new NotFoundException(`Parent folder ${parentDriveFolderId} not found in database`);
    }

    // STEP 3: Verify parent folder exists in Google Drive
    // This handles cases where the folder was deleted manually or has stale IDs
    let parentDriveId = parentFolder.driveId;
    const parentExists = await this.driveService.verifyFolderExists(parentDriveId);

    if (!parentExists) {
      this.logger.warn(
        `⚠️ Parent folder "${parentFolder.folderName}" (${parentFolder.driveFolderId}) has stale Drive ID: ${parentDriveId}. ` +
        `Attempting recovery...`,
      );

      parentDriveId = await this.recoverParentFolder(parentFolder);
    }

    // STEP 4: Check if folder already exists in Google Drive
    let driveFolder = await this.driveService.findFolderByName(name, parentDriveId);

    if (driveFolder) {
      // Folder exists in Drive but not in DB - sync it
      this.logger.log(
        `🔄 Found existing folder in Drive: "${name}" (${driveFolder.id}) - syncing to database`,
      );

      // STEP 4.5: Check if this Drive ID is already tracked in the database
      // (handles edge cases where folder was recreated with different parent/type)
      const existingByDriveId = await this.driveFolderRepository.findOne({
        where: { driveId: driveFolder.id },
      });

      if (existingByDriveId) {
        // Drive ID already exists in DB - return the existing record
        this.logger.log(
          `📁 Drive ID ${driveFolder.id} already linked to folder "${existingByDriveId.folderName}" (DB ID: ${existingByDriveId.driveFolderId}) - returning existing`,
        );
        return existingByDriveId;
      }
    } else {
      // Folder doesn't exist in Drive - create it
      this.logger.log(`✨ Creating new folder in Drive: "${name}" under parent ${parentDriveId}`);
      driveFolder = await this.driveService.createFolder(name, parentDriveId);
    }

    // STEP 5: Save folder to database (whether found or created in Drive)
    const newFolder = this.driveFolderRepository.create({
      driveId: driveFolder.id,
      folderType,
      parentDriveFolderId,
      entityType,
      entityId,
      folderName: name,
      folderPath,
      createdBy: userId,
    });

    await this.driveFolderRepository.save(newFolder);
    this.logger.log(
      `✅ Folder synced to DB: "${name}" -> Drive ID: ${driveFolder.id} (DB ID: ${newFolder.driveFolderId})`,
    );

    return newFolder;
  }

  /**
   * Recover a parent folder that has a stale Drive ID
   * Tries multiple strategies: search by name, recreate, or rebuild hierarchy
   */
  private async recoverParentFolder(folder: DriveFolder): Promise<string> {
    // Strategy 1: Try to find folder by name in its parent
    if (folder.parentDriveFolderId) {
      const grandParentFolder = await this.driveFolderRepository.findOne({
        where: { driveFolderId: folder.parentDriveFolderId },
      });

      if (grandParentFolder) {
        // Verify grandparent exists
        const grandParentExists = await this.driveService.verifyFolderExists(grandParentFolder.driveId);

        if (grandParentExists) {
          // Search for the folder by name
          const foundFolder = await this.driveService.findFolderByName(
            folder.folderName,
            grandParentFolder.driveId,
          );

          if (foundFolder) {
            // Found it! Update the stale Drive ID
            this.logger.log(
              `✅ Recovered folder "${folder.folderName}" (${folder.driveFolderId}): ` +
              `updated Drive ID from ${folder.driveId} to ${foundFolder.id}`,
            );
            folder.driveId = foundFolder.id;
            await this.driveFolderRepository.save(folder);
            return foundFolder.id;
          }
        } else {
          // Grandparent also stale - rebuild entire hierarchy
          this.logger.warn(`🔄 Grandparent also stale. Rebuilding hierarchy from root...`);
          const newDriveId = await this.rebuildFolderHierarchy(folder);
          return newDriveId;
        }
      } else {
        throw new NotFoundException(
          `Grandparent folder ${folder.parentDriveFolderId} not found in database`,
        );
      }
    }

    // Strategy 2: Recreate the folder if it's root-level
    this.logger.warn(`🔄 Recreating root-level folder "${folder.folderName}" in Drive...`);
    const newDriveId = await this.recreateRootLevelFolder(folder);
    return newDriveId;
  }

  /**
   * Rebuild folder hierarchy from root when multiple levels are stale
   */
  private async rebuildFolderHierarchy(
    staleFolder: DriveFolder,
  ): Promise<string> {
    // Get the full path from root
    const pathFolders: DriveFolder[] = [staleFolder];
    let currentParentId = staleFolder.parentDriveFolderId;

    // Walk up the tree to find all ancestors
    while (currentParentId) {
      const parent = await this.driveFolderRepository.findOne({
        where: { driveFolderId: currentParentId },
      });

      if (!parent) {
        break;
      }

      pathFolders.unshift(parent);
      currentParentId = parent.parentDriveFolderId;
    }

    // Now rebuild from root
    let currentDriveId: string | null = null;
    let currentPath = '';

    for (const folder of pathFolders) {
      // For root folder, use existing or create
      if (!folder.parentDriveFolderId) {
        // This is root - verify it exists
        if (folder.driveId) {
          const rootExists = await this.driveService.verifyFolderExists(folder.driveId);
          if (rootExists) {
            currentDriveId = folder.driveId;
            currentPath = folder.folderName;
            continue;
          }
        }

        // Root doesn't exist - create new root
        const rootFolder = await this.driveService.createFolder('EduVerse');
        folder.driveId = rootFolder.id;
        await this.driveFolderRepository.save(folder);
        currentDriveId = rootFolder.id;
        currentPath = folder.folderName;
        continue;
      }

      // Get parent's new Drive ID
      const parentFolder = await this.driveFolderRepository.findOne({
        where: { driveFolderId: folder.parentDriveFolderId! },
      });

      if (!parentFolder) {
        throw new Error(`Parent folder not found during rebuild: ${folder.parentDriveFolderId}`);
      }

      // Create this folder
      const newFolder = await this.driveService.createFolder(folder.folderName, parentFolder.driveId);
      folder.driveId = newFolder.id;
      await this.driveFolderRepository.save(folder);

      currentDriveId = newFolder.id;
      currentPath = `${currentPath}/${folder.folderName}`;

      this.logger.log(`✅ Rebuilt folder ${folder.driveFolderId} -> ${newFolder.id}`);
    }

    if (!currentDriveId) {
      throw new Error('Failed to rebuild hierarchy: no Drive ID generated');
    }

    return currentDriveId;
  }

  /**
   * Recreate a root-level folder (no parent in DB)
   */
  private async recreateRootLevelFolder(
    folder: DriveFolder,
  ): Promise<string> {
    // Create under root EduVerse folder
    const rootFolder = await this.getRootFolder();

    // Verify root exists
    const rootExists = await this.driveService.verifyFolderExists(rootFolder.driveId);
    if (!rootExists) {
      throw new Error(
        'Root EduVerse folder does not exist in Drive. Please reinitialize it first.',
      );
    }

    const newFolder = await this.driveService.createFolder(folder.folderName, rootFolder.driveId);
    folder.driveId = newFolder.id;
    await this.driveFolderRepository.save(folder);

    this.logger.log(`✅ Recreated root-level folder ${folder.driveFolderId} -> ${newFolder.id}`);

    return newFolder.id;
  }

  /**
   * Get current academic year string (e.g., "2024-2025")
   */
  private getCurrentAcademicYear(): string {
    const now = new Date();
    const year = now.getFullYear();
    const month = now.getMonth(); // 0-11
    
    // Academic year typically starts in August/September
    if (month >= 7) { // August onwards
      return `${year}-${year + 1}`;
    } else {
      return `${year - 1}-${year}`;
    }
  }

  /**
   * Get semester name from ID or default
   */
  private async getCurrentSemesterName(semesterId: number | null): Promise<string> {
    if (semesterId) {
      const result = await this.dataSource.query(
        `SELECT semester_name FROM semesters WHERE semester_id = ?`,
        [semesterId],
      );
      if (result && result.length > 0) {
        return result[0].semester_name.replace(/[^a-zA-Z0-9_-]/g, '_');
      }
    }
    
    // Default based on current date
    const now = new Date();
    const month = now.getMonth();
    
    if (month >= 0 && month <= 4) {
      return 'Spring';
    } else if (month >= 5 && month <= 7) {
      return 'Summer';
    } else {
      return 'Fall';
    }
  }

  // ============================================================================
  // DRIVE FILE ENTITY LINKING (FIX FOR fileId=NULL ISSUE)
  // ============================================================================

  /**
   * Update DriveFile entity linkage to parent submission
   * 
   * This is the CORE FIX for the fileId=NULL issue. When files are uploaded to Google Drive,
   * they create records in drive_files table. This method links those Drive files to their
   * parent submission entities via entity_type and entity_id fields.
   * 
   * Usage:
   * 1. Upload file to Drive (creates DriveFile record)
   * 2. Create/update submission (creates LabSubmission or AssignmentSubmission record)
   * 3. Call this method to link them: updateDriveFileEntity(driveFileId, 'lab_submission', submissionId)
   * 
   * @param driveFileId - Primary key of drive_files table (drive_file_id)
   * @param entityType - Type of parent entity ('lab_submission', 'assignment_submission', etc.)
   * @param entityId - Primary key of parent entity (submission_id)
   * @throws NotFoundException if DriveFile not found
   */
  async updateDriveFileEntity(
    driveFileId: number,
    entityType: DriveFileEntityType,
    entityId: number,
  ): Promise<void> {
    const driveFile = await this.driveFileRepository.findOne({
      where: { driveFileId },
    });

    if (!driveFile) {
      throw new NotFoundException(`DriveFile ${driveFileId} not found`);
    }

    // Update the entity linkage
    driveFile.entityType = entityType;
    driveFile.entityId = entityId;

    await this.driveFileRepository.save(driveFile);
    this.logger.log(`✅ Linked DriveFile ${driveFileId} to ${entityType} ${entityId}`);
  }

  /**
   * Get DriveFiles for a submission
   * 
   * Use this method instead of submission.fileId (which is always null for Google Drive uploads).
   * This queries the drive_files table using entity_type and entity_id linkage.
   * 
   * Example:
   * ```typescript
   * // Get all files for lab submission ID 15
   * const files = await driveFolderService.getDriveFilesForEntity('lab_submission', 15);
   * console.log(files[0].webViewLink); // Google Drive view link
   * ```
   * 
   * @param entityType - 'lab_submission', 'assignment_submission', etc.
   * @param entityId - The submission_id
   * @returns Array of DriveFile entities linked to this submission (ordered by newest first)
   */
  async getDriveFilesForEntity(
    entityType: DriveFileEntityType,
    entityId: number,
  ): Promise<DriveFile[]> {
    return this.driveFileRepository.find({
      where: { entityType, entityId },
      order: { createdAt: 'DESC' },
    });
  }

  // ============================================================================
  // SHARED LINK-BUILDER UTILITY
  // ============================================================================

  /**
   * Build standardised file-link object from a DriveFile entity.
   * Use this everywhere instead of inline construction so the URL
   * format (especially iframeUrl /preview suffix) stays consistent.
   */
  buildFileLinks(driveFile: DriveFile): {
    driveId: string;
    fileName: string;
    webViewLink: string | null;
    iframeUrl: string;
    downloadUrl: string;
  } {
    return {
      driveId: driveFile.driveId,
      fileName: driveFile.fileName,
      webViewLink: driveFile.webViewLink,
      iframeUrl: `https://drive.google.com/file/d/${driveFile.driveId}/preview`,
      downloadUrl: `https://drive.google.com/uc?id=${driveFile.driveId}&export=download`,
    };
  }
}
