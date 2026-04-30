import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, IsNull } from 'typeorm';
import { Course } from '../entities/course.entity';
import { CoursePrerequisite } from '../entities/course-prerequisite.entity';
import { CreateCourseDto, UpdateCourseDto } from '../dtos';
import { CourseStatus } from '../enums';
import { Assignment, AssignmentSubmission } from '../../assignments/entities';
import { CourseMaterial } from '../../course-materials/entities/course-material.entity';
import {
  CourseNotFoundException,
  CourseCodeAlreadyExistsException,
  CannotDeleteCourseWithActiveSectionsException,
  CircularPrerequisiteDetectedException,
  DepartmentNotFoundException,
  PrerequisiteAlreadyExistsException,
} from '../exceptions';
import { Department } from '../../campus/entities/department.entity';

@Injectable()
export class CoursesService {
  private readonly logger = new Logger(CoursesService.name);

  constructor(
    @InjectRepository(Course)
    private courseRepository: Repository<Course>,
    @InjectRepository(CoursePrerequisite)
    private prerequisiteRepository: Repository<CoursePrerequisite>,
    @InjectRepository(Department)
    private departmentRepository: Repository<Department>,
    @InjectRepository(Assignment)
    private assignmentRepository: Repository<Assignment>,
    @InjectRepository(AssignmentSubmission)
    private submissionRepository: Repository<AssignmentSubmission>,
    @InjectRepository(CourseMaterial)
    private materialRepository: Repository<CourseMaterial>,
  ) {}

  async getRecentActivity(
    courseId: number,
    limit = 8,
  ): Promise<
    Array<{
      type: 'assignment_created' | 'submission_received' | 'submission_graded' | 'material_uploaded';
      title: string;
      description: string;
      occurredAt: string;
    }>
  > {
    await this.findById(courseId);

    const safeLimit = Math.max(1, Math.min(limit, 20));

    const [recentAssignments, recentMaterials, recentSubmissions, recentGradedSubmissions] =
      await Promise.all([
        this.assignmentRepository.find({
          where: { courseId },
          order: { createdAt: 'DESC' },
          take: safeLimit,
        }),
        this.materialRepository.find({
          where: { courseId },
          order: { createdAt: 'DESC' },
          take: safeLimit,
        }),
        this.submissionRepository
          .createQueryBuilder('submission')
          .innerJoinAndSelect('submission.assignment', 'assignment')
          .where('assignment.courseId = :courseId', { courseId })
          .orderBy('submission.submittedAt', 'DESC')
          .take(safeLimit)
          .getMany(),
        this.submissionRepository
          .createQueryBuilder('submission')
          .innerJoinAndSelect('submission.assignment', 'assignment')
          .where('assignment.courseId = :courseId', { courseId })
          .andWhere('submission.gradedAt IS NOT NULL')
          .orderBy('submission.gradedAt', 'DESC')
          .take(safeLimit)
          .getMany(),
      ]);

    const activity = [
      ...recentAssignments.map((item) => ({
        type: 'assignment_created' as const,
        title: 'Assignment created',
        description: `"${item.title}" was created.`,
        occurredAt: item.createdAt?.toISOString?.() ?? new Date(item.createdAt).toISOString(),
      })),
      ...recentMaterials.map((item) => ({
        type: 'material_uploaded' as const,
        title: 'Material uploaded',
        description: `"${item.title}" was uploaded.`,
        occurredAt: item.createdAt?.toISOString?.() ?? new Date(item.createdAt).toISOString(),
      })),
      ...recentSubmissions.map((item) => ({
        type: 'submission_received' as const,
        title: 'Submission received',
        description: `A submission was received for "${item.assignment?.title || 'assignment'}".`,
        occurredAt: item.submittedAt?.toISOString?.() ?? new Date(item.submittedAt).toISOString(),
      })),
      ...recentGradedSubmissions.map((item) => ({
        type: 'submission_graded' as const,
        title: 'Submission graded',
        description: `A submission for "${item.assignment?.title || 'assignment'}" was graded.`,
        occurredAt: item.gradedAt?.toISOString?.() ?? new Date(item.gradedAt as Date).toISOString(),
      })),
    ];

    return activity
      .sort((a, b) => new Date(b.occurredAt).getTime() - new Date(a.occurredAt).getTime())
      .slice(0, safeLimit);
  }

  async findAll(
    departmentId?: number,
    level?: string,
    status?: CourseStatus,
    search?: string,
    page = 1,
    limit = 20,
  ) {
    let query = this.courseRepository
      .createQueryBuilder('course')
      .leftJoinAndSelect('course.department', 'department')
      .where('course.deletedAt IS NULL');

    if (departmentId) {
      query = query.andWhere('course.departmentId = :departmentId', {
        departmentId,
      });
    }

    if (level) {
      query = query.andWhere('course.level = :level', { level });
    }

    if (status) {
      query = query.andWhere('course.status = :status', { status });
    }

    if (search) {
      query = query.andWhere(
        '(course.name LIKE :search OR course.code LIKE :search)',
        { search: `%${search}%` },
      );
    }

    const skip = (page - 1) * limit;
    const [data, total] = await query
      .skip(skip)
      .take(limit)
      .orderBy('course.name', 'ASC')
      .getManyAndCount();

    const totalPages = Math.ceil(total / limit);

    return {
      data,
      meta: {
        total,
        page,
        limit,
        totalPages,
      },
    };
  }

  async findById(id: number) {
    const course = await this.courseRepository.findOne({
      where: { id, deletedAt: IsNull() },
      relations: ['department', 'prerequisites', 'sections'],
    });

    if (!course) {
      throw new CourseNotFoundException(id);
    }

    return course;
  }

  async findByCourseCode(code: string, departmentId: number) {
    return this.courseRepository.findOne({
      where: { code, departmentId, deletedAt: IsNull() },
    });
  }

  async findByDepartment(departmentId: number) {
    return this.courseRepository.find({
      where: { departmentId, deletedAt: IsNull() },
      relations: ['department'],
      order: { name: 'ASC' },
    });
  }

  async create(dto: CreateCourseDto): Promise<Course> {
    const department = await this.departmentRepository.findOne({
      where: { id: dto.departmentId },
    });

    if (!department) {
      throw new DepartmentNotFoundException(dto.departmentId);
    }

    const existing = await this.findByCourseCode(dto.code, dto.departmentId);
    if (existing) {
      throw new CourseCodeAlreadyExistsException(dto.code, dto.departmentId);
    }

    const course = this.courseRepository.create({
      departmentId: dto.departmentId,
      name: dto.name,
      code: dto.code,
      description: dto.description,
      credits: dto.credits,
      level: dto.level,
      syllabusUrl: dto.syllabusUrl || null,
      skills: dto.skills || [],
      status: CourseStatus.ACTIVE,
    });

    await this.courseRepository.save(course);
    this.logger.log(`Course created: ${course.id} (${course.code})`);

    return course;
  }

  async update(id: number, dto: UpdateCourseDto): Promise<Course> {
    const course = await this.findById(id);

    Object.assign(course, dto);
    if (dto.skills !== undefined) {
      course.skills = dto.skills;
    }
    await this.courseRepository.save(course);
    this.logger.log(`Course updated: ${id}`);

    return course;
  }

  async softDelete(id: number): Promise<void> {
    const course = await this.findById(id);

    // Temporarily bypass active sections check to allow administrative cleanup
    /*
    const activeCount = await this.courseRepository
      .createQueryBuilder('course')
      .innerJoin('course.sections', 'section')
      .where('course.id = :id', { id })
      .andWhere('section.status IN (:...statuses)', {
        statuses: ['OPEN', 'CLOSED', 'FULL'],
      })
      .getCount();

    if (activeCount > 0) {
      throw new CannotDeleteCourseWithActiveSectionsException(id);
    }
    */

    await this.courseRepository.softDelete(id);
    this.logger.log(`Course soft-deleted: ${id}`);
  }

  async addPrerequisite(
    courseId: number,
    prerequisiteCourseId: number,
    isMandatory: boolean,
  ): Promise<CoursePrerequisite> {
    const course = await this.findById(courseId);
    const prerequisiteCourse = await this.findById(prerequisiteCourseId);

    if (courseId === prerequisiteCourseId) {
      throw new CircularPrerequisiteDetectedException(courseId, prerequisiteCourseId);
    }

    const existing = await this.prerequisiteRepository.findOne({
      where: { courseId, prerequisiteCourseId },
    });
    if (existing) {
      throw new PrerequisiteAlreadyExistsException(courseId, prerequisiteCourseId);
    }

    await this.detectCircularDependency(courseId, prerequisiteCourseId);

    const prerequisite = this.prerequisiteRepository.create({
      courseId,
      prerequisiteCourseId,
      isMandatory,
    });

    await this.prerequisiteRepository.save(prerequisite);
    this.logger.log(
      `Prerequisite added: ${courseId} requires ${prerequisiteCourseId}`,
    );

    return prerequisite;
  }

  async removePrerequisite(courseId: number, prerequisiteId: number): Promise<void> {
    const prerequisite = await this.prerequisiteRepository.findOne({
      where: { id: prerequisiteId, courseId },
    });

    if (!prerequisite) {
      throw new CourseNotFoundException(prerequisiteId);
    }

    await this.prerequisiteRepository.remove(prerequisite);
    this.logger.log(`Prerequisite removed: ${prerequisiteId}`);
  }

  async getPrerequisites(courseId: number) {
    await this.findById(courseId);

    return this.prerequisiteRepository.find({
      where: { courseId },
      relations: ['prerequisiteCourse'],
      order: { createdAt: 'ASC' },
    });
  }

  private async detectCircularDependency(
    courseId: number,
    prerequisiteId: number,
  ): Promise<void> {
    const visited = new Set<number>();
    const stack = new Set<number>();

    const hasCycle = await this.dfs(prerequisiteId, courseId, visited, stack);

    if (hasCycle) {
      throw new CircularPrerequisiteDetectedException(courseId, prerequisiteId);
    }
  }

  private async dfs(
    current: number,
    target: number,
    visited: Set<number>,
    stack: Set<number>,
  ): Promise<boolean> {
    visited.add(current);
    stack.add(current);

    const prerequisites = await this.prerequisiteRepository.find({
      where: { courseId: current },
    });

    for (const prereq of prerequisites) {
      if (prereq.prerequisiteCourseId === target) {
        return true;
      }

      if (!visited.has(prereq.prerequisiteCourseId)) {
        if (
          await this.dfs(
            prereq.prerequisiteCourseId,
            target,
            visited,
            stack,
          )
        ) {
          return true;
        }
      }
    }

    stack.delete(current);
    return false;
  }
}
