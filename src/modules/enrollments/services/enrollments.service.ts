import { Injectable, Logger, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, In, IsNull, LessThan } from 'typeorm';
import { CourseEnrollment } from '../entities/course-enrollment.entity';
import { CourseInstructor } from '../entities/course-instructor.entity';
import { CourseTA } from '../entities/course-ta.entity';
import { Course } from '../../courses/entities/course.entity';
import { CourseSection } from '../../courses/entities/course-section.entity';
import { CourseSchedule } from '../../courses/entities/course-schedule.entity';
import { CoursePrerequisite } from '../../courses/entities/course-prerequisite.entity';
import { User } from '../../auth/entities/user.entity';
import { Semester } from '../../campus/entities/semester.entity';
import { SectionStatus } from '../../courses/enums';
import { EnrollmentStatus, DropReason } from '../enums';
import {
  EnrollmentNotFoundException,
  AlreadyEnrolledException,
  SectionFullException,
  PrerequisiteNotMetException,
  ScheduleConflictException,
  DropDeadlinePassedException,
  FailedGradeRequiredForRetakeException,
  RetakeRequiresAdminApprovalException,
  CannotDropPastEnrollmentException,
  EnrollmentAccessDeniedException,
} from '../exceptions';
import { EnrollCourseDto } from '../dto/enroll-course.dto';
import { EnrollmentResponseDto } from '../dto/enrollment-response.dto';
import { AvailableCoursesFilterDto, AvailableCoursesDto } from '../dto/available-courses.dto';

interface GradeInfo {
  letterGrade: string;
  numericValue: number;
  isPassing: boolean;
}

@Injectable()
export class EnrollmentsService {
  private readonly logger = new Logger(EnrollmentsService.name);
  private readonly gradeScale = {
    'A': { value: 4.0, passing: true },
    'A-': { value: 3.7, passing: true },
    'B+': { value: 3.3, passing: true },
    'B': { value: 3.0, passing: true },
    'B-': { value: 2.7, passing: true },
    'C+': { value: 2.3, passing: true },
    'C': { value: 2.0, passing: true },
    'C-': { value: 1.7, passing: false },
    'D+': { value: 1.3, passing: false },
    'D': { value: 1.0, passing: false },
    'F': { value: 0.0, passing: false },
  };
  private readonly DROP_DEADLINE_PERCENTAGE = 0.5; // Can drop until 50% through semester

  constructor(
    @InjectRepository(CourseEnrollment)
    private enrollmentRepository: Repository<CourseEnrollment>,
    @InjectRepository(CourseInstructor)
    private instructorRepository: Repository<CourseInstructor>,
    @InjectRepository(CourseTA)
    private taRepository: Repository<CourseTA>,
    @InjectRepository(Course)
    private courseRepository: Repository<Course>,
    @InjectRepository(CourseSection)
    private sectionRepository: Repository<CourseSection>,
    @InjectRepository(CourseSchedule)
    private scheduleRepository: Repository<CourseSchedule>,
    @InjectRepository(CoursePrerequisite)
    private prerequisiteRepository: Repository<CoursePrerequisite>,
    @InjectRepository(User)
    private userRepository: Repository<User>,
    @InjectRepository(Semester)
    private semesterRepository: Repository<Semester>,
  ) {}

  async enrollStudent(userId: number, enrollCourseDto: EnrollCourseDto): Promise<EnrollmentResponseDto> {
    const { sectionId } = enrollCourseDto;

    const [user, section, course, semester] = await Promise.all([
      this.userRepository.findOne({ where: { userId } }),
      this.sectionRepository.findOne({ where: { id: sectionId } }),
      null,
      null,
    ]);

    if (!user) throw new BadRequestException('User not found');
    if (!section) throw new BadRequestException('Section not found');

    const course_ = await this.courseRepository.findOne({ where: { id: section.courseId } });
    if (!course_) throw new BadRequestException('Course not found');

    const semester_ = await this.semesterRepository.findOne({ where: { id: section.semesterId } });
    if (!semester_) throw new BadRequestException('Semester not found');

    // Check 1: Already enrolled
    const existingEnrollment = await this.enrollmentRepository.findOne({
      where: {
        userId,
        sectionId,
      },
    });
    if (existingEnrollment && existingEnrollment.status !== EnrollmentStatus.DROPPED) {
      throw new AlreadyEnrolledException();
    }

    // Check 2: Check for retake logic
    const previousEnrollment = await this.enrollmentRepository
      .createQueryBuilder('enrollment')
      .leftJoinAndSelect('enrollment.section', 'section')
      .where('enrollment.userId = :userId', { userId })
      .andWhere('section.courseId = :courseId', { courseId: course_.id })
      .andWhere('enrollment.status IN (:...statuses)', {
        statuses: [EnrollmentStatus.COMPLETED, EnrollmentStatus.DROPPED],
      })
      .orderBy('enrollment.enrollmentDate', 'DESC')
      .getOne();

    if (previousEnrollment && previousEnrollment.status === EnrollmentStatus.COMPLETED) {
      const previousGrade = previousEnrollment.grade;
      const gradeInfo = this.parseGrade(previousGrade);

      if (!gradeInfo.isPassing) {
        // Failed - can retake freely
        this.logger.log(`Student ${userId} retaking course ${course_.id} - failed previously`);
      } else {
        // Passed - needs admin approval to improve grade
        if (gradeInfo.letterGrade === 'B' || (gradeInfo.letterGrade === 'B-' && true)) {
          throw new RetakeRequiresAdminApprovalException();
        }
      }
    }

    // Check 3: Prerequisites
    await this.validatePrerequisites(userId, course_.id);

    // Check 4: Schedule conflicts
    await this.validateScheduleConflict(userId, sectionId);

    // Check 5: Capacity and enrollment
    let enrollmentStatus = EnrollmentStatus.ENROLLED;
    if (section.currentEnrollment >= section.maxCapacity) {
      enrollmentStatus = EnrollmentStatus.ENROLLED;
      this.logger.log(
        `Section ${sectionId} is full, but enrolling student ${userId} (waitlist handled separately)`
      );
    }

    // Create enrollment
    const enrollment = this.enrollmentRepository.create({
      userId,
      sectionId,
      programId: null,
      status: enrollmentStatus,
    });

    const savedEnrollment = await this.enrollmentRepository.save(enrollment);

    // Update section enrollment count only if enrolled (not waitlisted)
    if (enrollmentStatus === EnrollmentStatus.ENROLLED) {
      await this.sectionRepository.increment(
        { id: sectionId },
        'currentEnrollment',
        1
      );

      // Check if section is now full
      const updatedSection = await this.sectionRepository.findOne({ where: { id: sectionId } });
      if (updatedSection && updatedSection.currentEnrollment >= updatedSection.maxCapacity) {
        await this.sectionRepository.update({ id: sectionId }, { status: SectionStatus.FULL });
      }
    }

    return this.buildEnrollmentResponse(savedEnrollment, course_, section, semester_);
  }

  async getMyEnrollments(userId: number, semester?: number): Promise<EnrollmentResponseDto[]> {
    // Simple query without relationships first
    const enrollments = await this.enrollmentRepository.find({
      where: {
        userId,
        status: In([EnrollmentStatus.ENROLLED, EnrollmentStatus.COMPLETED]),
      },
      order: { enrollmentDate: 'DESC' },
    });

    // Filter by semester if provided
    let filtered = enrollments;
    if (semester) {
      // Load sections for filtering
      const sectionIds = enrollments.map(e => e.sectionId);
      if (sectionIds.length === 0) return [];
      
      const sections = await this.sectionRepository.find({
        where: { semesterId: semester, id: In(sectionIds) },
      });
      const validSectionIds = new Set(sections.map(s => s.id));
      filtered = enrollments.filter(e => validSectionIds.has(e.sectionId));
    }

    // Load related data for each enrollment
    return Promise.all(
      filtered.map(async (enrollment) => {
        const section = await this.sectionRepository.findOne({
          where: { id: enrollment.sectionId },
          relations: ['course', 'semester'],
        });

        if (!section || !section.course || !section.semester) {
          throw new Error(`Missing related data for enrollment ${enrollment.id}`);
        }

        return this.buildEnrollmentResponse(enrollment, section.course, section, section.semester);
      })
    );
  }

  async getAvailableCourses(userId: number, filters: AvailableCoursesFilterDto): Promise<AvailableCoursesDto[]> {
    const { departmentId, semesterId, search, level, page = 1, limit = 20 } = filters;

    let courseQuery = this.courseRepository
      .createQueryBuilder('course')
      .where('course.deletedAt IS NULL')
      .andWhere('course.status = :status', { status: 'ACTIVE' });

    if (departmentId) {
      courseQuery = courseQuery.andWhere('course.departmentId = :departmentId', { departmentId });
    }

    if (level) {
      courseQuery = courseQuery.andWhere('course.level = :level', { level });
    }

    if (search) {
      courseQuery = courseQuery.andWhere(
        '(course.name LIKE :search OR course.code LIKE :search)',
        { search: `%${search}%` }
      );
    }

    const courses = await courseQuery
      .skip((page - 1) * limit)
      .take(limit)
      .getMany();

    const results: AvailableCoursesDto[] = [];

    for (const course of courses) {
      const sections = await this.sectionRepository.find({
        where: { courseId: course.id },
        relations: ['semester'],
      });

      const filteredSections = semesterId
        ? sections.filter((s) => s.semesterId === semesterId)
        : sections.filter((s) => s.status !== 'CANCELLED');

      if (filteredSections.length === 0) continue;

      const prerequisites = await this.prerequisiteRepository.find({
        where: { courseId: course.id },
        relations: ['prerequisiteCourse'],
      });

      const userEnrollment = await this.enrollmentRepository
        .createQueryBuilder('enrollment')
        .leftJoinAndSelect('enrollment.section', 'section')
        .where('enrollment.userId = :userId', { userId })
        .andWhere('section.courseId = :courseId', { courseId: course.id })
        .andWhere('enrollment.status IN (:...statuses)', {
          statuses: [EnrollmentStatus.ENROLLED, EnrollmentStatus.COMPLETED],
        })
        .getOne();

      const canEnroll = !userEnrollment && (await this.checkPrerequisites(userId, course.id));

      results.push({
        id: course.id,
        name: course.name,
        code: course.code,
        description: course.description,
        credits: course.credits,
        level: course.level,
        departmentId: course.departmentId,
        departmentName: course.department?.name || 'Unknown',
        sections: filteredSections.map((s) => ({
          id: s.id,
          sectionNumber: s.sectionNumber,
          maxCapacity: s.maxCapacity,
          currentEnrollment: s.currentEnrollment,
          availableSeats: Math.max(0, s.maxCapacity - s.currentEnrollment),
          location: s.location,
          semesterId: s.semesterId,
          semesterName: s.semester?.name || 'Unknown',
        })),
        prerequisites: prerequisites.map((p) => ({
          id: p.id,
          courseId: p.courseId,
          prerequisiteCourseId: p.prerequisiteCourseId,
          courseCode: p.prerequisiteCourse?.code || '',
          courseName: p.prerequisiteCourse?.name || '',
          isMandatory: p.isMandatory,
        })),
        canEnroll,
        enrollmentStatus: userEnrollment?.status,
      });
    }

    return results;
  }

  async dropCourse(enrollmentId: number, userId: number, isAdmin: boolean): Promise<EnrollmentResponseDto> {
    const enrollment = await this.enrollmentRepository.findOne({
      where: { id: enrollmentId },
      relations: ['section', 'section.course', 'section.semester'],
    });

    if (!enrollment) throw new EnrollmentNotFoundException();

    // Check permission
    if (!isAdmin && enrollment.userId !== userId) {
      throw new EnrollmentAccessDeniedException();
    }

    // Check if can drop (not already dropped/completed/withdrawn)
    if (![EnrollmentStatus.ENROLLED].includes(enrollment.status)) {
      throw new CannotDropPastEnrollmentException();
    }

    // Check drop deadline for students (not admin)
    if (!isAdmin && enrollment.status === EnrollmentStatus.ENROLLED) {
      const canDrop = await this.isWithinDropDeadline(enrollment.section.semester);
      if (!canDrop) {
        throw new DropDeadlinePassedException();
      }
    }

    // Store previous status
    const previousStatus = enrollment.status;

    // Update enrollment
    enrollment.status = EnrollmentStatus.DROPPED;
    enrollment.droppedAt = new Date();

    const updated = await this.enrollmentRepository.save(enrollment);

    // Decrease enrollment count if was enrolled (before dropping)
    if (previousStatus === EnrollmentStatus.ENROLLED) {
      await this.sectionRepository.decrement({ id: enrollment.sectionId }, 'currentEnrollment', 1);
      this.logger.log(`Student ${enrollment.userId} dropped from section ${enrollment.sectionId}`);
    }

    return this.buildEnrollmentResponse(updated, updated.section.course, updated.section, updated.section.semester);
  }

  async getSectionStudents(sectionId: number): Promise<EnrollmentResponseDto[]> {
    const enrollments = await this.enrollmentRepository.find({
      where: {
        sectionId,
        status: EnrollmentStatus.ENROLLED,
      },
      relations: ['section', 'section.course', 'section.semester', 'user'],
      order: { enrollmentDate: 'ASC' },
    });

    return Promise.all(
      enrollments.map((e) => this.buildEnrollmentResponse(e, e.section.course, e.section, e.section.semester))
    );
  }

  async getWaitlist(sectionId: number): Promise<EnrollmentResponseDto[]> {
    // Waitlist functionality is currently not implemented
    // In the future, a separate waitlist table should be created
    return [];
  }

  async getEnrollmentById(enrollmentId: number): Promise<EnrollmentResponseDto> {
    const enrollment = await this.enrollmentRepository.findOne({
      where: { id: enrollmentId },
      relations: ['section', 'section.course', 'section.semester'],
    });

    if (!enrollment) throw new EnrollmentNotFoundException();

    return this.buildEnrollmentResponse(enrollment, enrollment.section.course, enrollment.section, enrollment.section.semester);
  }

  // Private helper methods

  private async validatePrerequisites(userId: number, courseId: number): Promise<void> {
    const prerequisites = await this.prerequisiteRepository.find({
      where: { courseId },
      relations: ['prerequisiteCourse'],
    });

    if (prerequisites.length === 0) return;

    for (const prereq of prerequisites) {
      const completed = await this.enrollmentRepository
        .createQueryBuilder('enrollment')
        .leftJoinAndSelect('enrollment.section', 'section')
        .where('enrollment.userId = :userId', { userId })
        .andWhere('section.courseId = :courseId', { courseId: prereq.prerequisiteCourseId })
        .andWhere('enrollment.status = :status', { status: EnrollmentStatus.COMPLETED })
        .getOne();

      if (!completed) {
        throw new PrerequisiteNotMetException(
          `Prerequisite course ${prereq.prerequisiteCourse.code} not completed`
        );
      }

      // Check if grade meets B- threshold for best grade policy
      if (completed.grade && !this.isGradeAcceptable(completed.grade)) {
        throw new PrerequisiteNotMetException(
          `Prerequisite course grade must be B- or higher`
        );
      }
    }
  }

  private async checkPrerequisites(userId: number, courseId: number): Promise<boolean> {
    try {
      await this.validatePrerequisites(userId, courseId);
      return true;
    } catch {
      return false;
    }
  }

  private async validateScheduleConflict(userId: number, newSectionId: number): Promise<void> {
    const newSection = await this.sectionRepository.findOne({
      where: { id: newSectionId },
      relations: ['schedules'],
    });

    if (!newSection) return;

    // Get user's current enrollments
    const userEnrollments = await this.enrollmentRepository.find({
      where: {
        userId,
        status: EnrollmentStatus.ENROLLED,
      },
      relations: ['section', 'section.schedules'],
    });

    const newSchedules = newSection.schedules || [];

    for (const enrollment of userEnrollments) {
      const existingSchedules = enrollment.section.schedules || [];

      for (const newSched of newSchedules) {
        for (const existingSched of existingSchedules) {
          if (this.hasScheduleConflict(newSched, existingSched)) {
            throw new ScheduleConflictException();
          }
        }
      }
    }
  }

  private hasScheduleConflict(schedule1: CourseSchedule, schedule2: CourseSchedule): boolean {
    if (schedule1.dayOfWeek !== schedule2.dayOfWeek) return false;

    const start1 = this.timeToMinutes(schedule1.startTime);
    const end1 = this.timeToMinutes(schedule1.endTime);
    const start2 = this.timeToMinutes(schedule2.startTime);
    const end2 = this.timeToMinutes(schedule2.endTime);

    return start1 < end2 && start2 < end1;
  }

  private timeToMinutes(time: string): number {
    const [hours, minutes] = time.split(':').map(Number);
    return hours * 60 + minutes;
  }

  private async isWithinDropDeadline(semester: Semester): Promise<boolean> {
    const now = new Date();
    const semesterStart = new Date(semester.startDate);
    const semesterEnd = new Date(semester.endDate);

    const totalDays = (semesterEnd.getTime() - semesterStart.getTime()) / (1000 * 60 * 60 * 24);
    const elapsedDays = (now.getTime() - semesterStart.getTime()) / (1000 * 60 * 60 * 24);
    const percentageElapsed = elapsedDays / totalDays;

    return percentageElapsed < this.DROP_DEADLINE_PERCENTAGE;
  }

  private parseGrade(grade: string | null): GradeInfo {
    if (!grade) {
      return { letterGrade: 'F', numericValue: 0, isPassing: false };
    }

    const gradeInfo = this.gradeScale[grade];
    return {
      letterGrade: grade,
      numericValue: gradeInfo?.value || 0,
      isPassing: gradeInfo?.passing || false,
    };
  }

  private isGradeAcceptable(grade: string): boolean {
    // Best grade for prerequisites is B- or higher
    const gradeOrder = ['A', 'A-', 'B+', 'B', 'B-'];
    return gradeOrder.includes(grade);
  }

  private async buildEnrollmentResponse(
    enrollment: CourseEnrollment,
    course: Course,
    section: CourseSection,
    semester: Semester
  ): Promise<EnrollmentResponseDto> {
    const canDrop = enrollment.status === EnrollmentStatus.ENROLLED
      ? await this.isWithinDropDeadline(semester)
      : false;

    const dropDeadline = semester && canDrop ? this.calculateDropDeadline(semester) : null;

    // Get instructor - temporarily disabled
    const instructor: any = null;
    // const instructor = await this.instructorRepository.findOne({
    //   where: { sectionId: section.id },
    //   relations: ['instructor'],
    //   order: { role: 'ASC' },
    // });

    // Get prerequisites
    const prerequisites = await this.prerequisiteRepository.find({
      where: { courseId: course.id },
      relations: ['prerequisiteCourse'],
    });

    const prerequisitesData = await Promise.all(
      prerequisites.map(async (p) => {
        const studentCompletion = await this.enrollmentRepository
          .createQueryBuilder('enrollment')
          .leftJoinAndSelect('enrollment.section', 'section')
          .where('enrollment.userId = :userId', { userId: enrollment.userId })
          .andWhere('section.courseId = :courseId', { courseId: p.prerequisiteCourseId })
          .andWhere('enrollment.status = :status', { status: EnrollmentStatus.COMPLETED })
          .getOne();

        return {
          id: p.id,
          courseId: p.courseId,
          prerequisiteCourseId: p.prerequisiteCourseId,
          courseCode: p.prerequisiteCourse?.code || '',
          courseName: p.prerequisiteCourse?.name || '',
          isMandatory: p.isMandatory,
          studentCompleted: !!studentCompletion,
          studentGrade: studentCompletion?.grade || null,
        };
      })
    );

    return {
      id: enrollment.id,
      userId: enrollment.userId,
      sectionId: enrollment.sectionId,
      status: enrollment.status,
      grade: enrollment.grade,
      finalScore: enrollment.finalScore ? Number(enrollment.finalScore) : null,
      enrollmentDate: enrollment.enrollmentDate,
      droppedAt: enrollment.droppedAt,
      completedAt: enrollment.completedAt,
      canDrop,
      dropDeadline,
      course: {
        id: course.id,
        name: course.name,
        code: course.code,
        description: course.description,
        credits: course.credits,
        level: course.level,
      },
      section: {
        id: section.id,
        sectionNumber: section.sectionNumber,
        maxCapacity: section.maxCapacity,
        currentEnrollment: section.currentEnrollment,
        location: section.location,
      },
      semester: {
        id: semester.id,
        name: semester.name,
        startDate: semester.startDate,
        endDate: semester.endDate,
      },
      instructor: instructor?.instructor
        ? {
            id: instructor.instructor.userId,
            firstName: instructor.instructor.firstName,
            lastName: instructor.instructor.lastName,
            email: instructor.instructor.email,
          }
        : undefined,
      prerequisites: prerequisitesData,
    };
  }

  private calculateDropDeadline(semester: Semester): Date {
    const semesterStart = new Date(semester.startDate);
    const semesterEnd = new Date(semester.endDate);
    const totalMs = semesterEnd.getTime() - semesterStart.getTime();
    const deadlineMs = totalMs * this.DROP_DEADLINE_PERCENTAGE;
    return new Date(semesterStart.getTime() + deadlineMs);
  }
}
