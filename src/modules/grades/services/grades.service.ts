import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Grade, GpaCalculation } from '../entities';
import { GradeType } from '../enums';
import {
  GradeNotFoundException,
  GradeAlreadyPublishedException,
} from '../exceptions';
import {
  CreateGradeDto,
  UpdateGradeDto,
  GradeQueryDto,
  TranscriptResponseDto,
  TranscriptSemester,
  TranscriptCourse,
} from '../dto';
import { Course } from '../../courses/entities/course.entity';
import { CourseEnrollment } from '../../enrollments/entities/course-enrollment.entity';
import { User } from '../../auth/entities/user.entity';

@Injectable()
export class GradesService {
  private readonly logger = new Logger(GradesService.name);

  private readonly gradePointMap: Record<string, number> = {
    'A': 4.0,
    'A-': 3.7,
    'B+': 3.3,
    'B': 3.0,
    'B-': 2.7,
    'C+': 2.3,
    'C': 2.0,
    'C-': 1.7,
    'D+': 1.3,
    'D': 1.0,
    'F': 0.0,
  };

  constructor(
    @InjectRepository(Grade)
    private gradeRepo: Repository<Grade>,
    @InjectRepository(GpaCalculation)
    private gpaRepo: Repository<GpaCalculation>,
    @InjectRepository(Course)
    private courseRepo: Repository<Course>,
    @InjectRepository(CourseEnrollment)
    private enrollmentRepo: Repository<CourseEnrollment>,
    @InjectRepository(User)
    private userRepo: Repository<User>,
  ) {}

  async createGrade(dto: CreateGradeDto, graderId: number): Promise<Grade> {
    const percentage = (dto.score / dto.maxScore) * 100;
    const letterGrade = this.getLetterGrade(percentage);

    const grade = this.gradeRepo.create({
      ...dto,
      percentage,
      letterGrade,
      gradedBy: graderId,
      gradedAt: new Date(),
      isPublished: dto.isPublished ? 1 : 0,
    });

    const saved = await this.gradeRepo.save(grade);
    this.logger.log(`Grade created: ${saved.id} for user ${dto.userId}`);
    return saved;
  }

  async findAll(
    query: GradeQueryDto,
  ): Promise<{ data: Grade[]; meta: { total: number; page: number; limit: number; totalPages: number } }> {
    const page = query.page || 1;
    const limit = query.limit || 10;
    const skip = (page - 1) * limit;

    const qb = this.gradeRepo
      .createQueryBuilder('grade')
      .leftJoinAndSelect('grade.user', 'user')
      .leftJoinAndSelect('grade.course', 'course')
      .leftJoinAndSelect('grade.assignment', 'assignment');

    if (query.courseId) {
      qb.andWhere('grade.courseId = :courseId', { courseId: query.courseId });
    }
    if (query.userId) {
      qb.andWhere('grade.userId = :userId', { userId: query.userId });
    }
    if (query.gradeType) {
      qb.andWhere('grade.gradeType = :gradeType', { gradeType: query.gradeType });
    }
    if (query.isPublished !== undefined) {
      qb.andWhere('grade.isPublished = :isPublished', {
        isPublished: query.isPublished ? 1 : 0,
      });
    }

    qb.orderBy('grade.createdAt', 'DESC');
    qb.skip(skip).take(limit);

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

  async findMyGrades(userId: number): Promise<Grade[]> {
    return this.gradeRepo.find({
      where: { userId },
      relations: ['course', 'assignment'],
      order: { courseId: 'ASC', gradeType: 'ASC' },
    });
  }

  async updateGrade(
    id: number,
    dto: UpdateGradeDto,
    graderId: number,
  ): Promise<Grade> {
    const grade = await this.gradeRepo.findOne({ where: { id } });
    if (!grade) {
      throw new GradeNotFoundException(id);
    }
    if (grade.isPublished) {
      throw new GradeAlreadyPublishedException();
    }

    Object.assign(grade, dto);

    if (dto.score !== undefined || dto.maxScore !== undefined) {
      const score = dto.score ?? grade.score;
      const maxScore = dto.maxScore ?? grade.maxScore;
      grade.percentage = (score / maxScore) * 100;
      grade.letterGrade = this.getLetterGrade(grade.percentage);
    }

    grade.gradedBy = graderId;
    grade.gradedAt = new Date();

    return this.gradeRepo.save(grade);
  }

  async publishGrade(id: number): Promise<Grade> {
    const grade = await this.gradeRepo.findOne({ where: { id } });
    if (!grade) {
      throw new GradeNotFoundException(id);
    }

    grade.isPublished = 1;
    return this.gradeRepo.save(grade);
  }

  async getTranscript(studentId: number): Promise<TranscriptResponseDto> {
    const user = await this.userRepo.findOne({ where: { userId: studentId } });
    const grades = await this.gradeRepo.find({
      where: { userId: studentId, isPublished: 1 },
      relations: ['course'],
      order: { courseId: 'ASC' },
    });

    // Group grades by course
    const courseMap = new Map<number, Grade[]>();
    for (const grade of grades) {
      const list = courseMap.get(grade.courseId) || [];
      list.push(grade);
      courseMap.set(grade.courseId, list);
    }

    // Build transcript courses
    const transcriptCourses: TranscriptCourse[] = [];
    let totalCredits = 0;
    let totalQualityPoints = 0;

    for (const [courseId, courseGrades] of courseMap) {
      const course = courseGrades[0].course;
      // Use the best/final grade for the course
      const finalGrade = courseGrades[courseGrades.length - 1];
      const credits = course?.credits || 3;
      const gradePoint = this.getGradePoint(finalGrade.letterGrade || 'F');

      transcriptCourses.push({
        courseId,
        courseName: course?.name || '',
        credits,
        letterGrade: finalGrade.letterGrade || 'N/A',
        score: Number(finalGrade.score),
        maxScore: Number(finalGrade.maxScore),
      });

      totalCredits += credits;
      totalQualityPoints += gradePoint * credits;
    }

    const cumulativeGpa =
      totalCredits > 0
        ? Math.round((totalQualityPoints / totalCredits) * 100) / 100
        : 0;

    // Build a single semester grouping (simplified version)
    const semester: TranscriptSemester = {
      semesterId: 0,
      semesterName: 'All Courses',
      gpa: cumulativeGpa,
      courses: transcriptCourses,
    };

    const dto = new TranscriptResponseDto();
    dto.studentId = studentId;
    dto.studentName = user ? `${user.firstName} ${user.lastName}` : '';
    dto.cumulativeGpa = cumulativeGpa;
    dto.totalCredits = totalCredits;
    dto.semesters = [semester];

    return dto;
  }

  async calculateGPA(
    studentId: number,
  ): Promise<{ semesterGpa: number; cumulativeGpa: number }> {
    const grades = await this.gradeRepo.find({
      where: { userId: studentId, isPublished: 1 },
      relations: ['course'],
    });

    if (grades.length === 0) {
      return { semesterGpa: 0, cumulativeGpa: 0 };
    }

    // Deduplicate: keep last grade per course
    const courseGradeMap = new Map<number, Grade>();
    for (const grade of grades) {
      courseGradeMap.set(grade.courseId, grade);
    }

    let totalCredits = 0;
    let totalQualityPoints = 0;

    for (const [, grade] of courseGradeMap) {
      const credits = grade.course?.credits || 3;
      const gradePoint = this.getGradePoint(grade.letterGrade || 'F');
      totalCredits += credits;
      totalQualityPoints += gradePoint * credits;
    }

    const cumulativeGpa =
      totalCredits > 0
        ? Math.round((totalQualityPoints / totalCredits) * 100) / 100
        : 0;

    return { semesterGpa: cumulativeGpa, cumulativeGpa };
  }

  async getDistribution(
    courseId: number,
  ): Promise<{ letterGrade: string; count: number }[]> {
    const results = await this.gradeRepo
      .createQueryBuilder('grade')
      .select('grade.letterGrade', 'letterGrade')
      .addSelect('COUNT(*)', 'count')
      .where('grade.courseId = :courseId', { courseId })
      .andWhere('grade.isPublished = 1')
      .groupBy('grade.letterGrade')
      .orderBy('grade.letterGrade', 'ASC')
      .getRawMany();

    return results.map((r) => ({
      letterGrade: r.letterGrade,
      count: Number(r.count),
    }));
  }

  private getLetterGrade(percentage: number): string {
    if (percentage >= 93) return 'A';
    if (percentage >= 90) return 'A-';
    if (percentage >= 87) return 'B+';
    if (percentage >= 83) return 'B';
    if (percentage >= 80) return 'B-';
    if (percentage >= 77) return 'C+';
    if (percentage >= 73) return 'C';
    if (percentage >= 70) return 'C-';
    if (percentage >= 67) return 'D+';
    if (percentage >= 63) return 'D';
    return 'F';
  }

  private getGradePoint(letterGrade: string): number {
    return this.gradePointMap[letterGrade] ?? 0.0;
  }
}
