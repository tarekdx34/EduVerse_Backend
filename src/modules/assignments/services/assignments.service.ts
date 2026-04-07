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
import { DriveFolderService } from '../../google-drive/services/drive-folder.service';
import { DriveFileEntityType } from '../../google-drive/entities/drive-file.entity';
import { GradesService } from '../../grades/services';
import { GradeType } from '../../grades/enums';

@Injectable()
export class AssignmentsService {
  private readonly logger = new Logger(AssignmentsService.name);

  constructor(
    @InjectRepository(Assignment)
    private assignmentRepo: Repository<Assignment>,
    @InjectRepository(AssignmentSubmission)
    private submissionRepo: Repository<AssignmentSubmission>,
    @InjectRepository(Course)
    private courseRepo: Repository<Course>,
    @InjectRepository(CourseEnrollment)
    private enrollmentRepo: Repository<CourseEnrollment>,
    @InjectRepository(DriveFile)
    private driveFileRepo: Repository<DriveFile>,
    private driveFolderService: DriveFolderService,
    @Inject(forwardRef(() => GradesService))
    private gradesService: GradesService,
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

    return result!;
  }

  async findAll(query: AssignmentQueryDto): Promise<{
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

    if (query.courseId) {
      qb.andWhere('assignment.courseId = :courseId', { courseId: query.courseId });
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

    const updateData: Partial<Assignment> = { ...dto } as any;
    if (dto.lateSubmissionAllowed !== undefined) {
      updateData.lateSubmissionAllowed = dto.lateSubmissionAllowed ? 1 : 0;
    }

    Object.assign(assignment, updateData);
    const saved = await this.assignmentRepo.save(assignment);
    this.logger.log(`Assignment ${id} updated by user ${userId}`);

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

  async getMySubmission(assignmentId: number, userId: number): Promise<any> {
    const submission = await this.submissionRepo.findOne({
      where: { assignmentId, userId },
      order: { attemptNumber: 'DESC' },
    });

    if (!submission) {
      throw new SubmissionNotFoundException();
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
    file: Express.Multer.File,
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
    file: Express.Multer.File,
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
}
