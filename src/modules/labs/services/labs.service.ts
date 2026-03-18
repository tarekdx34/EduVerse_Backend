import { Injectable, Logger, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Lab } from '../entities/lab.entity';
import { LabSubmission } from '../entities/lab-submission.entity';
import { LabInstruction } from '../entities/lab-instruction.entity';
import { LabAttendance } from '../entities/lab-attendance.entity';
import {
  CreateLabDto,
  UpdateLabDto,
  SubmitLabDto,
  GradeLabSubmissionDto,
  CreateInstructionDto,
  MarkLabAttendanceDto,
  LabQueryDto,
} from '../dto';
import { DriveFolderService } from '../../google-drive/services/drive-folder.service';
import { DriveFileEntityType } from '../../google-drive/entities/drive-file.entity';

@Injectable()
export class LabsService {
  private readonly logger = new Logger(LabsService.name);

  constructor(
    @InjectRepository(Lab)
    private labRepository: Repository<Lab>,
    @InjectRepository(LabSubmission)
    private submissionRepository: Repository<LabSubmission>,
    @InjectRepository(LabInstruction)
    private instructionRepository: Repository<LabInstruction>,
    @InjectRepository(LabAttendance)
    private attendanceRepository: Repository<LabAttendance>,
    private driveFolderService: DriveFolderService,
  ) {}

  // ============ LABS CRUD ============

  async findAll(query: LabQueryDto) {
    const { courseId, status, page = 1, limit = 20 } = query;
    const qb = this.labRepository.createQueryBuilder('lab')
      .leftJoinAndSelect('lab.course', 'course');

    if (courseId) qb.andWhere('lab.courseId = :courseId', { courseId });
    if (status) qb.andWhere('lab.status = :status', { status });

    qb.orderBy('lab.createdAt', 'DESC')
      .skip((page - 1) * limit)
      .take(limit);

    const [data, total] = await qb.getManyAndCount();
    return { data, meta: { total, page, limit, totalPages: Math.ceil(total / limit) } };
  }

  async findById(id: number): Promise<Lab> {
    const lab = await this.labRepository.findOne({
      where: { id },
      relations: ['course', 'instructions'],
    });
    if (!lab) throw new NotFoundException(`Lab with ID ${id} not found`);
    return lab;
  }

  async create(dto: CreateLabDto, userId: number): Promise<Lab> {
    const lab = this.labRepository.create({ ...dto, createdBy: userId });
    const saved = await this.labRepository.save(lab);
    this.logger.log(`Lab created: ${saved.id} by user ${userId}`);
    return saved;
  }

  async update(id: number, dto: UpdateLabDto): Promise<Lab> {
    const lab = await this.findById(id);
    Object.assign(lab, dto);
    const updated = await this.labRepository.save(lab);
    this.logger.log(`Lab updated: ${id}`);
    return updated;
  }

  async remove(id: number): Promise<void> {
    const lab = await this.findById(id);
    await this.labRepository.remove(lab);
    this.logger.log(`Lab deleted: ${id}`);
  }

  // ============ INSTRUCTIONS ============

  async getInstructions(labId: number): Promise<LabInstruction[]> {
    await this.findById(labId);
    return this.instructionRepository.find({
      where: { labId },
      order: { orderIndex: 'ASC' },
    });
  }

  async addInstruction(labId: number, dto: CreateInstructionDto): Promise<LabInstruction> {
    await this.findById(labId);
    const instruction = this.instructionRepository.create({ ...dto, labId });
    return this.instructionRepository.save(instruction);
  }

  // ============ SUBMISSIONS ============

  async submit(labId: number, userId: number, dto: SubmitLabDto): Promise<LabSubmission> {
    const lab = await this.findById(labId);

    let isLate = false;
    if (lab.dueDate && new Date() > new Date(lab.dueDate)) {
      isLate = true;
    }

    const submission = this.submissionRepository.create({
      labId,
      userId,
      submissionText: dto.submissionText,
      fileId: dto.fileId,
      isLate,
      status: 'submitted',
    });
    const saved = await this.submissionRepository.save(submission);
    this.logger.log(`Lab ${labId} submitted by user ${userId}`);
    return saved;
  }

  async getSubmissions(labId: number) {
    await this.findById(labId);
    return this.submissionRepository.find({
      where: { labId },
      relations: ['user', 'file'],
      order: { submittedAt: 'DESC' },
    });
  }

  async getMySubmission(labId: number, userId: number) {
    await this.findById(labId);
    return this.submissionRepository.find({
      where: { labId, userId },
      relations: ['user', 'file'],
      order: { submittedAt: 'DESC' },
    });
  }

  async gradeSubmission(labId: number, submissionId: number, dto: GradeLabSubmissionDto): Promise<LabSubmission> {
    await this.findById(labId);
    const submission = await this.submissionRepository.findOne({
      where: { id: submissionId, labId },
    });
    if (!submission) throw new NotFoundException(`Submission ${submissionId} not found for lab ${labId}`);

    submission.status = dto.status;
    const updated = await this.submissionRepository.save(submission);
    this.logger.log(`Submission ${submissionId} graded: ${dto.status}`);
    return this.submissionRepository.findOne({
      where: { id: updated.id },
      relations: ['user', 'file'],
    }) as Promise<LabSubmission>;
  }

  // ============ ATTENDANCE ============

  async markAttendance(labId: number, dto: MarkLabAttendanceDto, markedByUserId: number): Promise<LabAttendance> {
    await this.findById(labId);

    const existing = await this.attendanceRepository.findOne({
      where: { labId, userId: dto.userId },
    });
    if (existing) {
      existing.attendanceStatus = dto.attendanceStatus;
      existing.notes = dto.notes ?? existing.notes;
      existing.markedBy = markedByUserId;
      if (dto.attendanceStatus === 'present' || dto.attendanceStatus === 'late') {
        existing.checkInTime = new Date();
      }
      return this.attendanceRepository.save(existing);
    }

    const record = this.attendanceRepository.create({
      labId,
      userId: dto.userId,
      attendanceStatus: dto.attendanceStatus,
      notes: dto.notes,
      markedBy: markedByUserId,
    } as Partial<LabAttendance>);
    if (dto.attendanceStatus === 'present' || dto.attendanceStatus === 'late') {
      record.checkInTime = new Date();
    }
    return this.attendanceRepository.save(record);
  }

  async getAttendance(labId: number): Promise<LabAttendance[]> {
    await this.findById(labId);
    return this.attendanceRepository.find({
      where: { labId },
      order: { createdAt: 'ASC' },
    });
  }

  // ============ GOOGLE DRIVE UPLOADS ============

  /**
   * Upload instruction file to Google Drive
   */
  async uploadInstructionToDrive(
    labId: number,
    file: Express.Multer.File,
    title: string | undefined,
    orderIndex: number,
    userId: number,
  ) {
    const lab = await this.findById(labId);

    // Ensure lab folder structure exists
    const folders = await this.driveFolderService.createLabFolderStructure(labId, userId);

    // Generate file name
    const ext = file.originalname.split('.').pop() || 'file';
    const safeTitle = (title || `Lab${lab.labNumber || labId}_Instructions`).replace(/[^a-zA-Z0-9_-]/g, '_').substring(0, 50);
    const fileName = `${safeTitle}_v1.${ext}`;

    // Upload to Drive
    const driveFile = await this.driveFolderService.uploadFileToDrive(
      file.buffer,
      fileName,
      file.mimetype,
      folders.instructions.driveFolderId,
      DriveFileEntityType.LAB_INSTRUCTION,
      null,
      userId,
    );

    // Create instruction record
    const instruction = this.instructionRepository.create({
      labId,
      instructionText: title || fileName,
      orderIndex,
    });
    const savedInstruction = await this.instructionRepository.save(instruction);

    this.logger.log(`Uploaded lab instruction to Drive: ${fileName} -> ${driveFile.driveId}`);

    return {
      instruction: savedInstruction,
      driveFile: {
        driveId: driveFile.driveId,
        fileName: driveFile.fileName,
        webViewLink: driveFile.webViewLink,
        webContentLink: driveFile.webContentLink,
      },
    };
  }

  /**
   * Upload TA material to Google Drive
   */
  async uploadTaMaterialToDrive(
    labId: number,
    file: Express.Multer.File,
    title: string | undefined,
    materialType: string | undefined,
    userId: number,
  ) {
    const lab = await this.findById(labId);

    // Ensure lab folder structure exists
    const folders = await this.driveFolderService.createLabFolderStructure(labId, userId);

    // Generate file name
    const ext = file.originalname.split('.').pop() || 'file';
    const typePrefix = materialType ? `${materialType}_` : '';
    const safeTitle = (title || `Lab${lab.labNumber || labId}_TA_Material`).replace(/[^a-zA-Z0-9_-]/g, '_').substring(0, 50);
    const fileName = `${typePrefix}${safeTitle}.${ext}`;

    // Upload to Drive
    const driveFile = await this.driveFolderService.uploadFileToDrive(
      file.buffer,
      fileName,
      file.mimetype,
      folders.taMaterials.driveFolderId,
      DriveFileEntityType.LAB_TA_MATERIAL,
      labId,
      userId,
    );

    this.logger.log(`Uploaded lab TA material to Drive: ${fileName} -> ${driveFile.driveId}`);

    return {
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
    labId: number,
    file: Express.Multer.File,
    submissionText: string | undefined,
    userId: number,
  ) {
    const lab = await this.findById(labId);

    // Create student submission folder
    const studentFolder = await this.driveFolderService.createLabStudentSubmissionFolder(labId, userId, userId);

    // Generate file name
    const ext = file.originalname.split('.').pop() || 'file';
    const timestamp = new Date().toISOString().slice(0, 10).replace(/-/g, '');
    const fileName = `Lab${lab.labNumber || labId}_Submission_${timestamp}.${ext}`;

    // Upload to Drive
    const driveFile = await this.driveFolderService.uploadFileToDrive(
      file.buffer,
      fileName,
      file.mimetype,
      studentFolder.driveFolderId,
      DriveFileEntityType.LAB_SUBMISSION,
      null,
      userId,
    );

    // Check if late submission
    const isLate = lab.dueDate ? new Date() > new Date(lab.dueDate) : false;

    // Create or update submission record
    let submission = await this.submissionRepository.findOne({
      where: { labId, userId },
    });

    if (submission) {
      if (submissionText) {
        submission.submissionText = submissionText;
      }
      submission.submittedAt = new Date();
      submission.isLate = isLate;
      submission.status = 'submitted';
    } else {
      submission = this.submissionRepository.create({
        labId,
        userId,
        submissionText: submissionText,
        submittedAt: new Date(),
        isLate,
        status: 'submitted',
      });
    }
    const savedSubmission = await this.submissionRepository.save(submission);

    this.logger.log(`Uploaded lab submission to Drive: ${fileName} -> ${driveFile.driveId}`);

    return {
      submission: savedSubmission,
      driveFile: {
        driveFileId: driveFile.driveFileId,
        driveId: driveFile.driveId,
        fileName: driveFile.fileName,
        webViewLink: driveFile.webViewLink,
        webContentLink: driveFile.webContentLink,
      },
      isLate,
    };
  }
}
