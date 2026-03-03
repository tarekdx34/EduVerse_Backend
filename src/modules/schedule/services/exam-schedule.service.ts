import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Between, LessThanOrEqual, MoreThanOrEqual } from 'typeorm';
import { ExamSchedule } from '../entities';
import {
  CreateExamScheduleDto,
  UpdateExamScheduleDto,
  QueryExamScheduleDto,
} from '../dto';
import { ExamConflictException } from '../exceptions';

@Injectable()
export class ExamScheduleService {
  constructor(
    @InjectRepository(ExamSchedule)
    private readonly examRepo: Repository<ExamSchedule>,
  ) {}

  async findAll(query: QueryExamScheduleDto, userId: number, roles: string[]) {
    const { courseId, semesterId, examType, fromDate, toDate, page = 1, limit = 10 } = query;

    const qb = this.examRepo.createQueryBuilder('exam')
      .leftJoinAndSelect('exam.course', 'course')
      .leftJoinAndSelect('exam.semester', 'semester');

    // Role-based filtering
    const isAdmin = roles.includes('admin') || roles.includes('it_admin');
    const isInstructor = roles.includes('instructor');
    const isTA = roles.includes('teaching_assistant');

    if (!isAdmin) {
      if (isInstructor) {
        // Instructors can see exams for their courses (via course_sections -> course_instructors)
        qb.innerJoin('course_sections', 'cs', 'cs.course_id = exam.courseId')
          .innerJoin('course_instructors', 'ci', 'ci.section_id = cs.section_id AND ci.user_id = :userId', { userId });
      } else if (isTA) {
        // TAs can see exams for courses they assist (via course_sections -> course_tas)
        qb.innerJoin('course_sections', 'cs', 'cs.course_id = exam.courseId')
          .innerJoin('course_tas', 'ct', 'ct.section_id = cs.section_id AND ct.user_id = :userId', { userId });
      } else {
        // Students can see exams for enrolled courses
        qb.innerJoin('course_sections', 'cs', 'cs.course_id = exam.courseId')
          .innerJoin('course_enrollments', 'ce', 'ce.section_id = cs.section_id AND ce.user_id = :userId AND ce.enrollment_status = :status', { userId, status: 'enrolled' });
      }
    }

    if (courseId) {
      qb.andWhere('exam.courseId = :courseId', { courseId });
    }

    if (semesterId) {
      qb.andWhere('exam.semesterId = :semesterId', { semesterId });
    }

    if (examType) {
      qb.andWhere('exam.examType = :examType', { examType });
    }

    if (fromDate) {
      qb.andWhere('exam.examDate >= :fromDate', { fromDate });
    }

    if (toDate) {
      qb.andWhere('exam.examDate <= :toDate', { toDate });
    }

    qb.orderBy('exam.examDate', 'ASC')
      .addOrderBy('exam.startTime', 'ASC')
      .skip((page - 1) * limit)
      .take(limit);

    const [items, total] = await qb.getManyAndCount();

    return {
      data: items,
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  async findById(id: number, userId: number, roles: string[]) {
    const exam = await this.examRepo.findOne({
      where: { examId: id },
      relations: ['course', 'semester'],
    });

    if (!exam) {
      throw new NotFoundException(`Exam schedule with ID ${id} not found`);
    }

    // Access control: Check if user can view this exam
    const isAdmin = roles.includes('admin') || roles.includes('it_admin');
    if (!isAdmin) {
      // Additional checks would go here if needed
    }

    return exam;
  }

  async create(dto: CreateExamScheduleDto, createdBy: number) {
    // Check for conflicts
    const conflict = await this.checkConflicts(dto);
    if (conflict) {
      throw new ExamConflictException(conflict);
    }

    const exam = this.examRepo.create(dto);
    return this.examRepo.save(exam);
  }

  async update(id: number, dto: UpdateExamScheduleDto, userId: number, roles: string[]) {
    const exam = await this.findById(id, userId, roles);

    // Check ownership for non-admin
    const isAdmin = roles.includes('admin') || roles.includes('it_admin');
    if (!isAdmin) {
      // Instructors can only update exams for their courses
      const isInstructor = roles.includes('instructor');
      if (isInstructor) {
        // Additional ownership check would be performed here
      }
    }

    // Check for conflicts if date/time changed
    if (dto.examDate || dto.startTime || dto.durationMinutes) {
      const checkDto = { ...exam, ...dto };
      const conflict = await this.checkConflicts(checkDto, id);
      if (conflict) {
        throw new ExamConflictException(conflict);
      }
    }

    Object.assign(exam, dto);
    return this.examRepo.save(exam);
  }

  async delete(id: number, userId: number, roles: string[]) {
    const exam = await this.findById(id, userId, roles);
    await this.examRepo.remove(exam);
    return { message: 'Exam schedule deleted successfully' };
  }

  async checkExamConflicts(courseId?: number, semesterId?: number) {
    // This checks for overlapping exams across courses for students
    const qb = this.examRepo.createQueryBuilder('e1')
      .innerJoin(ExamSchedule, 'e2', 
        'e1.examId <> e2.examId AND e1.examDate = e2.examDate')
      .where('e1.startTime < ADDTIME(e2.startTime, SEC_TO_TIME(e2.durationMinutes * 60))')
      .andWhere('ADDTIME(e1.startTime, SEC_TO_TIME(e1.durationMinutes * 60)) > e2.startTime');

    if (courseId) {
      qb.andWhere('(e1.courseId = :courseId OR e2.courseId = :courseId)', { courseId });
    }

    if (semesterId) {
      qb.andWhere('e1.semesterId = :semesterId AND e2.semesterId = :semesterId', { semesterId });
    }

    return qb.getMany();
  }

  private async checkConflicts(dto: CreateExamScheduleDto | any, excludeId?: number): Promise<string | null> {
    const qb = this.examRepo.createQueryBuilder('exam')
      .where('exam.examDate = :examDate', { examDate: dto.examDate })
      .andWhere('exam.location = :location', { location: dto.location });

    if (excludeId) {
      qb.andWhere('exam.examId <> :excludeId', { excludeId });
    }

    // Time overlap check
    qb.andWhere(
      `exam.startTime < ADDTIME(:startTime, SEC_TO_TIME(:duration * 60)) 
       AND ADDTIME(exam.startTime, SEC_TO_TIME(exam.durationMinutes * 60)) > :startTime`,
      { startTime: dto.startTime, duration: dto.durationMinutes }
    );

    const conflict = await qb.getOne();
    if (conflict) {
      return `Exam conflicts with existing exam at ${conflict.location} on ${conflict.examDate} at ${conflict.startTime}`;
    }

    return null;
  }
}
