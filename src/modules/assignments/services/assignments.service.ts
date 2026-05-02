import { Injectable, Logger, BadRequestException, Inject, forwardRef } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Assignment, AssignmentSubmission } from '../entities';
import { DriveFile } from '../../google-drive/entities/drive-file.entity';
import { AssignmentStatus, SubmissionStatus } from '../enums';
import {
  AssignmentNotFoundException,
  SubmissionDeadlinePassedException,
  AssignmentNotPublishedException,
  AssignmentNotAvailableYetException,
  SubmissionNotFoundException,
} from '../exceptions';
import { CreateAssignmentDto } from '../dto/create-assignment.dto';
import { UpdateAssignmentDto } from '../dto/update-assignment.dto';
import { AssignmentQueryDto } from '../dto/assignment-query.dto';
import { SubmitAssignmentDto } from '../dto/submit-assignment.dto';
import { GradeSubmissionDto } from '../dto/grade-submission.dto';
import { Course } from '../../courses/entities/course.entity';
import { CourseEnrollment } from '../../enrollments/entities/course-enrollment.entity';
import { CourseInstructor } from '../../enrollments/entities/course-instructor.entity';
import { CourseTA } from '../../enrollments/entities/course-ta.entity';
import { DriveFolderService } from '../../google-drive/services/drive-folder.service';
import { GoogleDriveService } from '../../google-drive/google-drive.service';
import { DriveFileEntityType } from '../../google-drive/entities/drive-file.entity';
import { GradesService } from '../../grades/services';
import { GradeType } from '../../grades/enums';
import { EnrollmentStatus } from '../../enrollments/enums';
import { RoleName } from '../../auth/entities/role.entity';
import { NotificationType, NotificationPriority } from '../../notifications/enums';
import { NotificationsService } from '../../notifications/services/notifications.service';

type UploadedAssignmentFile = {
  originalname: string;
  mimetype: string;
  buffer: Buffer;
};

@Injectable()
export class AssignmentsService {
  private readonly logger = new Logger(AssignmentsService.name);

  private async notifyStudentsAboutPublishedAssignment(assignment: Assignment): Promise<void> {
    const studentIds = await this.notificationsService.getEnrolledStudentIds(
      Number(assignment.courseId),
    );
    if (studentIds.length === 0) {
      this.logger.warn(`No enrolled students found to notify for assignment ${assignment.id}`);
      return;
    }

    await this.notificationsService.createBulkNotifications(studentIds, {
      notificationType: NotificationType.ASSIGNMENT,
      title: 'New Assignment Posted',
      body: `A new assignment "${assignment.title}" has been posted in ${assignment.course?.name || 'your course'}.`,
      relatedEntityType: 'assignment',
      relatedEntityId: assignment.id,
      priority: NotificationPriority.MEDIUM,
      actionUrl: `/courses/${assignment.courseId}/assignments/${assignment.id}`,
    });
  }

  private async notifyCourseStaffAboutSubmission(
    assignment: Assignment,
    studentId: number,
  ): Promise<void> {
    const staffIds = (await this.notificationsService.getCourseStaffUserIds(
      Number(assignment.courseId),
    )).filter((userId) => Number(userId) !== Number(studentId));

    if (!staffIds.length) {
      return;
    }

    await this.notificationsService.createBulkNotifications(staffIds, {
      notificationType: NotificationType.ASSIGNMENT,
      title: 'Assignment Submission Received',
      body: `A student submitted work for "${assignment.title}".`,
      relatedEntityType: 'assignment',
      relatedEntityId: assignment.id,
      priority: NotificationPriority.LOW,
      actionUrl: `/courses/${assignment.courseId}/assignments/${assignment.id}/submissions`,
    });
  }

  constructor(
    @InjectRepository(Assignment)
    private assignmentRepo: Repository<Assignment>,
    @InjectRepository(AssignmentSubmission)
    private submissionRepo: Repository<AssignmentSubmission>,
    @InjectRepository(Course)
    private courseRepo: Repository<Course>,
    @InjectRepository(CourseEnrollment)
    private enrollmentRepo: Repository<CourseEnrollment>,
    @InjectRepository(CourseInstructor)
    private courseInstructorRepo: Repository<CourseInstructor>,
    @InjectRepository(CourseTA)
    private courseTARepo: Repository<CourseTA>,
    @InjectRepository(DriveFile)
    private driveFileRepo: Repository<DriveFile>,
    private driveFolderService: DriveFolderService,
    private googleDriveService: GoogleDriveService,
    @Inject(forwardRef(() => GradesService))
    private gradesService: GradesService,
    private notificationsService: NotificationsService,
  ) {}

  async create(dto: CreateAssignmentDto, userId: number): Promise<Assignment> {
    const course = await this.courseRepo.findOne({ where: { id: dto.courseId } });
    if (!course) {
      throw new BadRequestException('Course not found');
    }

    const assignment = this.assignmentRepo.create({
      ...dto,
      createdBy: userId,
      status: dto.status ?? AssignmentStatus.DRAFT,
      lateSubmissionAllowed: dto.lateSubmissionAllowed ? 1 : 0,
    });

    const saved = await this.assignmentRepo.save(assignment);
    this.logger.log(`Assignment "${saved.title}" created by user ${userId} for course ${dto.courseId}`);

    const result = await this.assignmentRepo.findOne({
      where: { id: saved.id },
      relations: ['course'],
    });

    if (result?.status === AssignmentStatus.PUBLISHED) {
      await this.notifyStudentsAboutPublishedAssignment(result);
    }

    return result!;
  }

  async findAll(
    query: AssignmentQueryDto,
    userId?: number,
    roles: string[] = [],
  ): Promise<{
    data: Assignment[];
    meta: { total: number; page: number; limit: number; totalPages: number };
  }> {
    const page = query.page ?? 1;
    const limit = query.limit ?? 10;
    const sortBy = query.sortBy ?? 'createdAt';
    const sortOrder = query.sortOrder ?? 'DESC';

    const qb = this.assignmentRepo
      .createQueryBuilder('assignment')
      .leftJoinAndSelect('assignment.course', 'course');

    const accessibleCourseIds = await this.resolveAccessibleCourseIds(userId, roles);
    if (accessibleCourseIds && accessibleCourseIds.length === 0) {
      return {
        data: [],
        meta: {
          total: 0,
          page,
          limit,
          totalPages: 0,
        },
      };
    }

    if (query.courseId) {
      if (accessibleCourseIds && !accessibleCourseIds.includes(query.courseId)) {
        return {
          data: [],
          meta: {
            total: 0,
            page,
            limit,
            totalPages: 0,
          },
        };
      }
      qb.andWhere('assignment.courseId = :courseId', { courseId: query.courseId });
    } else if (accessibleCourseIds) {
      qb.andWhere('assignment.courseId IN (:...courseIds)', {
        courseIds: accessibleCourseIds,
      });
    }

    if (query.sectionId) {
      qb.innerJoin(
        'course_sections',
        'section',
        'section.course_id = assignment.course_id AND section.section_id = :sectionId',
        { sectionId: query.sectionId },
      );
    }

    if (query.status) {
      qb.andWhere('assignment.status = :status', { status: query.status });
    }

    if (query.dueBefore) {
      qb.andWhere('assignment.dueDate <= :dueBefore', { dueBefore: query.dueBefore });
    }

    if (query.dueAfter) {
      qb.andWhere('assignment.dueDate >= :dueAfter', { dueAfter: query.dueAfter });
    }

    if (query.search) {
      qb.andWhere('assignment.title LIKE :search', { search: `%${query.search}%` });
    }

    qb.orderBy(`assignment.${sortBy}`, sortOrder);
    qb.skip((page - 1) * limit);
    qb.take(limit);

    const [data, total] = await qb.getManyAndCount();

    return {
      data,
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  private async resolveAccessibleCourseIds(
    userId?: number,
    roles: string[] = [],
  ): Promise<number[] | null> {
    if (!userId) {
      return null;
    }

    const normalizedRoles = roles
      .map((role) => String(role).toLowerCase())
      .filter((role) => role.length > 0);

    const isAdmin = normalizedRoles.some((role) =>
      [
        RoleName.ADMIN,
        RoleName.IT_ADMIN,
        RoleName.DEPARTMENT_HEAD,
      ].map((value) => value.toLowerCase()).includes(role),
    );
    if (isAdmin) {
      return null;
    }

    const wantsInstructorCourses = normalizedRoles.includes(
      RoleName.INSTRUCTOR.toLowerCase(),
    );
    const wantsTACourses = normalizedRoles.includes(RoleName.TA.toLowerCase());

    if (!wantsInstructorCourses && !wantsTACourses) {
      return null;
    }

    const courseIds = new Set<number>();

    if (wantsInstructorCourses) {
      const assignments = await this.courseInstructorRepo.find({
        where: { userId },
        relations: ['section'],
      });
      for (const assignment of assignments) {
        const courseId = Number(assignment.section?.courseId);
        if (Number.isFinite(courseId) && courseId > 0) {
          courseIds.add(courseId);
        }
      }
    }

    if (wantsTACourses) {
      const assignments = await this.courseTARepo.find({
        where: { userId },
        relations: ['section'],
      });
      for (const assignment of assignments) {
        const courseId = Number(assignment.section?.courseId);
        if (Number.isFinite(courseId) && courseId > 0) {
          courseIds.add(courseId);
        }
      }
    }

    return Array.from(courseIds.values());
  }

  async findOne(id: number): Promise<Assignment> {
    const assignment = await this.assignmentRepo.findOne({
      where: { id },
      relations: ['course', 'submissions', 'submissions.user'],
    });

    if (!assignment) {
      throw new AssignmentNotFoundException();
    }

    // Attach instruction files
    const instructionFiles = await this.driveFileRepo.find({
      where: {
        entityType: DriveFileEntityType.ASSIGNMENT_INSTRUCTION as any,
        entityId: id,
      },
    });

    (assignment as any).instructionFiles = instructionFiles.map(file => 
      this.driveFolderService.buildFileLinks(file)
    );

    return assignment;
  }

  async update(id: number, dto: UpdateAssignmentDto, userId: number): Promise<Assignment> {
    const assignment = await this.assignmentRepo.findOne({ where: { id } });
    if (!assignment) {
      throw new AssignmentNotFoundException();
    }

    const previousStatus = assignment.status;

    const updateData: Partial<Assignment> = { ...dto } as any;
    if (dto.lateSubmissionAllowed !== undefined) {
      updateData.lateSubmissionAllowed = dto.lateSubmissionAllowed ? 1 : 0;
    }

    Object.assign(assignment, updateData);
    const saved = await this.assignmentRepo.save(assignment);
    this.logger.log(`Assignment ${id} updated by user ${userId}`);

    if (previousStatus !== AssignmentStatus.PUBLISHED && saved.status === AssignmentStatus.PUBLISHED) {
      const publishedAssignment = await this.assignmentRepo.findOne({
        where: { id: saved.id },
        relations: ['course'],
      });

      if (publishedAssignment) {
        await this.notifyStudentsAboutPublishedAssignment(publishedAssignment);
      }
    }

    return saved;
  }

  async remove(id: number): Promise<void> {
    const assignment = await this.assignmentRepo.findOne({ where: { id } });
    if (!assignment) {
      throw new AssignmentNotFoundException();
    }

    await this.assignmentRepo.remove(assignment);
    this.logger.log(`Assignment ${id} deleted`);
  }

  async changeStatus(id: number, status: AssignmentStatus, userId: number): Promise<Assignment> {
    const assignment = await this.assignmentRepo.findOne({ where: { id } });
    if (!assignment) {
      throw new AssignmentNotFoundException();
    }

    const validTransitions: Record<string, string> = {
      [AssignmentStatus.DRAFT]: AssignmentStatus.PUBLISHED,
      [AssignmentStatus.PUBLISHED]: AssignmentStatus.CLOSED,
      [AssignmentStatus.CLOSED]: AssignmentStatus.ARCHIVED,
    };

    if (validTransitions[assignment.status] !== status) {
      throw new BadRequestException(
        `Invalid status transition from "${assignment.status}" to "${status}"`,
      );
    }

    assignment.status = status;
    const saved = await this.assignmentRepo.save(assignment);
    this.logger.log(`Assignment ${id} status changed to ${status} by user ${userId}`);

    // Notify students if published
    if (status === AssignmentStatus.PUBLISHED) {
      const publishedAssignment = await this.assignmentRepo.findOne({
        where: { id: saved.id },
        relations: ['course'],
      });

      if (publishedAssignment) {
        await this.notifyStudentsAboutPublishedAssignment(publishedAssignment);
      }
    }

    return saved;
  }

  async submit(
    assignmentId: number,
    dto: SubmitAssignmentDto,
    userId: number,
  ): Promise<AssignmentSubmission> {
    const assignment = await this.assignmentRepo.findOne({ where: { id: assignmentId } });
    if (!assignment) {
      throw new AssignmentNotFoundException();
    }

    if (assignment.status !== AssignmentStatus.PUBLISHED) {
      throw new AssignmentNotPublishedException();
    }

    const now = new Date();

    if (assignment.availableFrom && now < new Date(assignment.availableFrom)) {
      throw new AssignmentNotAvailableYetException();
    }

    let isLate = 0;

    if (assignment.dueDate && now > new Date(assignment.dueDate)) {
      if (!assignment.lateSubmissionAllowed) {
        throw new SubmissionDeadlinePassedException();
      }
      isLate = 1;
    }

    // Check student is enrolled in the course
    const enrollment = await this.enrollmentRepo
      .createQueryBuilder('enrollment')
      .innerJoin('course_sections', 'section', 'section.section_id = enrollment.section_id')
      .where('enrollment.user_id = :userId', { userId })
      .andWhere('section.course_id = :courseId', { courseId: assignment.courseId })
      .andWhere('enrollment.enrollment_status = :status', { status: 'enrolled' })
      .getOne();

    if (!enrollment) {
      throw new BadRequestException('Student is not enrolled in this course');
    }

    // ⭐ UPSERT: Find the most recent submission for this student
    let submission = await this.submissionRepo.findOne({
      where: { assignmentId, userId },
      order: { attemptNumber: 'DESC' },
    });

    let attemptNumber = 1;
    let isUpdate = false;

    if (submission) {
      if (submission.submissionStatus === SubmissionStatus.GRADED) {
        // New attempt after grading
        attemptNumber = submission.attemptNumber + 1;
        submission = null;
        this.logger.log(`Starting new attempt ${attemptNumber} for assignment ${assignmentId}, user ${userId} (previous was graded)`);
      } else {
        attemptNumber = submission.attemptNumber;
        isUpdate = true;
      }
    }

    if (submission) {
      // UPDATE existing submission
      if (dto.submissionText !== undefined) {
        submission.submissionText = dto.submissionText;
      }
      if (dto.submissionLink !== undefined) {
        submission.submissionLink = dto.submissionLink;
      }
      if (dto.fileId !== undefined && dto.fileId !== null) {
        submission.fileId = dto.fileId;
      }
      submission.submittedAt = now;
      submission.isLate = isLate;
      submission.submissionStatus = SubmissionStatus.SUBMITTED;
      this.logger.log(`Assignment ${assignmentId} submission UPDATED for user ${userId}, attempt ${attemptNumber}`);
    } else {
      // INSERT new submission
      submission = this.submissionRepo.create({
        assignmentId,
        userId,
        submissionText: dto.submissionText ?? null,
        submissionLink: dto.submissionLink ?? null,
        fileId: dto.fileId ?? null,
        submissionStatus: SubmissionStatus.SUBMITTED,
        isLate,
        attemptNumber,
        submittedAt: now,
      });
      this.logger.log(`Assignment ${assignmentId} submission CREATED for user ${userId}, attempt ${attemptNumber}`);
    }

    const saved = await this.submissionRepo.save(submission);
    await this.notifyCourseStaffAboutSubmission(assignment, userId);
    return saved;
  }

  // ============ HELPER ============
  private async attachDriveFile(submission: AssignmentSubmission): Promise<any> {
    if (!submission.fileId) {
      return { ...submission, driveFile: null };
    }
    const file = await this.driveFileRepo.findOne({
      where: { driveFileId: submission.fileId },
    });
    return {
      ...submission,
      driveFile: file ? this.driveFolderService.buildFileLinks(file) : null,
    };
  }

  async getSubmissions(assignmentId: number): Promise<any[]> {
    const submissions = await this.submissionRepo.find({
      where: { assignmentId },
      relations: ['user'],
      order: { submittedAt: 'DESC' },
    });
    return Promise.all(submissions.map(sub => this.attachDriveFile(sub)));
  }

  async getMySubmission(assignmentId: number, userId: number): Promise<any | null> {
    const submission = await this.submissionRepo.findOne({
      where: { assignmentId, userId },
      order: { attemptNumber: 'DESC' },
    });

    if (!submission) {
      // "No submission yet" is a normal student state; return null instead of 404
      // so dashboard polling/lookups do not spam console/network errors.
      return null;
    }

    return this.attachDriveFile(submission);
  }

  async gradeSubmission(
    assignmentId: number,
    submissionId: number,
    dto: GradeSubmissionDto,
    graderId: number,
  ): Promise<{ submissionId: number; score: number; maxScore: number; feedback?: string; gradeId?: number }> {
    const submission = await this.submissionRepo.findOne({
      where: { id: submissionId, assignmentId },
    });
    if (!submission) {
      throw new SubmissionNotFoundException();
    }

    const assignment = await this.assignmentRepo.findOne({ where: { id: assignmentId } });
    if (!assignment) {
      throw new AssignmentNotFoundException();
    }

    // Update submission with grading info
    submission.submissionStatus = SubmissionStatus.GRADED;
    submission.score = dto.score;
    submission.feedback = dto.feedback || null;
    submission.gradedBy = graderId;
    submission.gradedAt = new Date();
    await this.submissionRepo.save(submission);

    this.logger.log(
      `Submission ${submissionId} graded by user ${graderId}: ${dto.score}/${assignment.maxScore}`,
    );

    // Create grade record in central grades table
    const grade = await this.gradesService.createGrade({
      userId: submission.userId,
      courseId: assignment.courseId,
      gradeType: GradeType.ASSIGNMENT,
      assignmentId: assignmentId,
      score: dto.score,
      maxScore: Number(assignment.maxScore),
      feedback: dto.feedback,
      isPublished: true, // Assignment grades are immediately visible
    }, graderId);
    this.logger.log(`Grade record created: ${grade.id} for assignment ${assignmentId}, user ${submission.userId}`);
    
    // Notify student about graded assignment
    await this.notificationsService.createNotification({
      userId: submission.userId,
      notificationType: NotificationType.GRADE,
      title: 'Assignment Graded',
      body: `Your submission for "${assignment.title}" has been graded. Score: ${dto.score}/${assignment.maxScore}`,
      relatedEntityType: 'assignment',
      relatedEntityId: assignmentId,
      priority: NotificationPriority.HIGH,
      actionUrl: `/courses/${assignment.courseId}/assignments/${assignmentId}`,
    });

    return {
      submissionId: submission.id,
      score: dto.score,
      maxScore: Number(assignment.maxScore),
      feedback: dto.feedback,
      gradeId: Number(grade.id),
    };
  }

  // ============ GOOGLE DRIVE UPLOADS ============

  /**
   * Upload instruction file to Google Drive
   */
  async uploadInstructionToDrive(
    assignmentId: number,
    file: UploadedAssignmentFile,
    title: string | undefined,
    orderIndex: number,
    userId: number,
  ) {
    const assignment = await this.assignmentRepo.findOne({ where: { id: assignmentId } });
    if (!assignment) {
      throw new AssignmentNotFoundException();
    }

    // Ensure assignment folder structure exists
    const folders = await this.driveFolderService.createAssignmentFolderStructure(assignmentId, userId);

    // Generate file name
    const ext = file.originalname.split('.').pop() || 'file';
    const safeTitle = (title || `Assignment${assignment.title}_Instructions`).replace(/[^a-zA-Z0-9_-]/g, '_').substring(0, 50);
    const fileName = `${safeTitle}_v1.${ext}`;

    // Upload to Drive
    const driveFile = await this.driveFolderService.uploadFileToDrive(
      file.buffer,
      fileName,
      file.mimetype,
      folders.instructions.driveFolderId,
      DriveFileEntityType.ASSIGNMENT_INSTRUCTION,
      assignmentId,
      userId,
    );

    this.logger.log(`Uploaded assignment instruction to Drive: ${fileName} -> ${driveFile.driveId}`);

    return {
      assignmentId,
      driveFile: {
        driveFileId: driveFile.driveFileId,
        driveId: driveFile.driveId,
        fileName: driveFile.fileName,
        webViewLink: driveFile.webViewLink,
        webContentLink: driveFile.webContentLink,
      },
    };
  }

  /**
   * Upload student submission to Google Drive
   */
  async uploadSubmissionToDrive(
    assignmentId: number,
    file: UploadedAssignmentFile,
    submissionText: string | undefined,
    submissionLink: string | undefined,
    userId: number,
  ) {
    const assignment = await this.assignmentRepo.findOne({ where: { id: assignmentId } });
    if (!assignment) {
      throw new AssignmentNotFoundException();
    }

    if (assignment.status !== AssignmentStatus.PUBLISHED) {
      throw new AssignmentNotPublishedException();
    }

    const now = new Date();

    if (assignment.availableFrom && now < new Date(assignment.availableFrom)) {
      throw new AssignmentNotAvailableYetException();
    }

    let isLate = 0;
    if (assignment.dueDate && now > new Date(assignment.dueDate)) {
      if (!assignment.lateSubmissionAllowed) {
        throw new SubmissionDeadlinePassedException();
      }
      isLate = 1;
    }

    // Check student is enrolled in the course
    const enrollment = await this.enrollmentRepo
      .createQueryBuilder('enrollment')
      .innerJoin('course_sections', 'section', 'section.section_id = enrollment.section_id')
      .where('enrollment.user_id = :userId', { userId })
      .andWhere('section.course_id = :courseId', { courseId: assignment.courseId })
      .andWhere('enrollment.enrollment_status = :status', { status: 'enrolled' })
      .getOne();

    if (!enrollment) {
      throw new BadRequestException('Student is not enrolled in this course');
    }

    // Create student submission folder
    const studentFolder = await this.driveFolderService.createAssignmentStudentSubmissionFolder(assignmentId, userId, userId);

    // Generate file name
    const ext = file.originalname.split('.').pop() || 'file';
    const timestamp = new Date().toISOString().slice(0, 10).replace(/-/g, '');
    const fileName = `Assignment_${assignmentId}_Submission_${timestamp}.${ext}`;

    // Upload to Drive
    const driveFile = await this.driveFolderService.uploadFileToDrive(
      file.buffer,
      fileName,
      file.mimetype,
      studentFolder.driveFolderId,
      DriveFileEntityType.ASSIGNMENT_SUBMISSION,
      null,
      userId,
    );

    // ⭐ UPSERT: Find the most recent submission for this student
    let submission = await this.submissionRepo.findOne({
      where: { assignmentId, userId },
      order: { attemptNumber: 'DESC' }, // Get latest attempt
    });

    let attemptNumber = 1;
    let isUpdate = false;

    if (submission) {
      // Check if the latest submission is already finalized (graded)
      if (submission.submissionStatus === SubmissionStatus.GRADED) {
        // Start a new attempt if they're resubmitting after grading
        attemptNumber = submission.attemptNumber + 1;
        submission = null; // Force creation of new record
        this.logger.log(`Starting new attempt ${attemptNumber} for assignment ${assignmentId}, user ${userId} (previous was graded)`);
      } else {
        // UPDATE the current in-progress submission
        attemptNumber = submission.attemptNumber;
        isUpdate = true;
      }
    }

    if (submission) {
      // UPDATE existing submission
      if (submissionText !== undefined) {
        submission.submissionText = submissionText;
      }
      if (submissionLink !== undefined) {
        submission.submissionLink = submissionLink;
      }
      submission.submittedAt = now;
      submission.isLate = isLate;
      submission.submissionStatus = SubmissionStatus.SUBMITTED;
      this.logger.log(`Assignment ${assignmentId} submission UPDATED for user ${userId}, attempt ${attemptNumber}`);
    } else {
      // INSERT new submission
      submission = this.submissionRepo.create({
        assignmentId,
        userId,
        submissionText: submissionText ?? null,
        submissionLink: submissionLink ?? null,
        fileId: driveFile.driveFileId,
        submissionStatus: SubmissionStatus.SUBMITTED,
        isLate,
        attemptNumber,
        submittedAt: now,
      });
      this.logger.log(`Assignment ${assignmentId} submission CREATED for user ${userId}, attempt ${attemptNumber}`);
    }

    const savedSubmission = await this.submissionRepo.save(submission);
    await this.notifyCourseStaffAboutSubmission(assignment, userId);

    // ⭐ CRITICAL FIX: Link the DriveFile to the submission via entity_id
    await this.driveFolderService.updateDriveFileEntity(
      driveFile.driveFileId,
      DriveFileEntityType.ASSIGNMENT_SUBMISSION,
      savedSubmission.id,
    );

    this.logger.log(`Uploaded assignment submission to Drive: ${fileName} -> ${driveFile.driveId} (${isUpdate ? 'UPDATED' : 'CREATED'} submission ${savedSubmission.id})`);

    return {
      submission: savedSubmission,
      driveFile: {
        driveFileId: driveFile.driveFileId,
        driveId: driveFile.driveId,
        fileName: driveFile.fileName,
        webViewLink: driveFile.webViewLink,
        webContentLink: driveFile.webContentLink,
      },
      isLate: isLate === 1,
    };
  }

  /**
   * Delete an instruction file from an assignment.
   * Removes the file from Google Drive and the database record.
   * If Google Drive deletion fails, still deletes the DB record and returns a warning.
   */
  async deleteInstructionFile(
    assignmentId: number,
    driveId: string,
    userId: number,
  ): Promise<{
    success: boolean;
    message: string;
    deletedFileDriveId: string;
    assignmentId: number;
  }> {
    // a) Verify the assignment exists
    const assignment = await this.assignmentRepo.findOne({ where: { id: assignmentId } });
    if (!assignment) {
      throw new AssignmentNotFoundException();
    }

    // b) Verify the instruction file record exists and belongs to this assignment
    const instructionFile = await this.driveFileRepo.findOne({
      where: {
        driveId,
        entityType: DriveFileEntityType.ASSIGNMENT_INSTRUCTION as any,
        entityId: assignmentId,
      },
    });

    if (!instructionFile) {
      throw new BadRequestException('Instruction file not found');
    }

    // c) Authorization is handled by the @Roles guard in the controller
    // (instructor, TA, or admin — same as upload endpoint)

    // d) Delete the physical file from Google Drive (log error but continue on failure)
    let driveDeletionFailed = false;
    try {
      await this.googleDriveService.deleteFile(instructionFile.driveId);
      this.logger.log(`Deleted instruction file from Google Drive: ${instructionFile.driveId}`);
    } catch (error) {
      driveDeletionFailed = true;
      const errorMessage =
        error instanceof Error ? error.message : String(error);
      this.logger.error(
        `Failed to delete instruction file from Google Drive: ${instructionFile.driveId} — ${errorMessage}`,
      );
    }

    // e) Delete the drive_files database record
    await this.driveFileRepo.remove(instructionFile);
    this.logger.log(
      `Deleted instruction file record ${driveId} from database for assignment ${assignmentId} by user ${userId}`,
    );

    // f) Clean up: remove any related join/cached references
    // The drive_files record is the primary link. No separate pivot table exists.
    // Any cached references in assignment metadata are resolved at query time via
    // the findOne() method, so removing the DB record is sufficient.

    // g) Do NOT delete:
    // - Audit logs or activity history (none stored separately for instruction files)
    // - The assignment itself
    // - Other instruction files for the same assignment

    // Build response
    if (driveDeletionFailed) {
      return {
        success: true,
        message:
          'Instruction file deleted from database records, but failed to delete from Google Drive',
        deletedFileDriveId: driveId,
        assignmentId,
      };
    }

    return {
      success: true,
      message: 'Instruction file deleted successfully',
      deletedFileDriveId: driveId,
      assignmentId,
    };
  }
}
