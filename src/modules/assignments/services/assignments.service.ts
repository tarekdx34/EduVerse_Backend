import { Injectable, Logger, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Assignment, AssignmentSubmission } from '../entities';
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

    // Calculate attempt number
    const existingCount = await this.submissionRepo.count({
      where: { assignmentId, userId },
    });

    const submission = this.submissionRepo.create({
      assignmentId,
      userId,
      submissionText: dto.submissionText ?? null,
      submissionLink: dto.submissionLink ?? null,
      fileId: dto.fileId ?? null,
      submissionStatus: SubmissionStatus.SUBMITTED,
      isLate,
      attemptNumber: existingCount + 1,
      submittedAt: now,
    });

    const saved = await this.submissionRepo.save(submission);
    this.logger.log(
      `Submission created for assignment ${assignmentId} by user ${userId} (attempt ${saved.attemptNumber})`,
    );

    return saved;
  }

  async getSubmissions(assignmentId: number): Promise<AssignmentSubmission[]> {
    return this.submissionRepo.find({
      where: { assignmentId },
      relations: ['user'],
      order: { submittedAt: 'DESC' },
    });
  }

  async getMySubmission(assignmentId: number, userId: number): Promise<AssignmentSubmission> {
    const submission = await this.submissionRepo.findOne({
      where: { assignmentId, userId },
      order: { attemptNumber: 'DESC' },
    });

    if (!submission) {
      throw new SubmissionNotFoundException();
    }

    return submission;
  }

  async gradeSubmission(
    assignmentId: number,
    submissionId: number,
    dto: GradeSubmissionDto,
    graderId: number,
  ): Promise<{ submissionId: number; score: number; maxScore: number; feedback?: string }> {
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

    submission.submissionStatus = SubmissionStatus.GRADED;
    await this.submissionRepo.save(submission);

    this.logger.log(
      `Submission ${submissionId} graded by user ${graderId}: ${dto.score}/${assignment.maxScore}`,
    );

    // TODO: Create grade record in grades table when GradesModule is wired
    return {
      submissionId: submission.id,
      score: dto.score,
      maxScore: Number(assignment.maxScore),
      feedback: dto.feedback,
    };
  }
}
