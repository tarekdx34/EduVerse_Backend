import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, Repository } from 'typeorm';
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
  BulkPublishGradesDto,
  TranscriptResponseDto,
  TranscriptSemester,
  TranscriptCourse,
} from '../dto';
import { Course } from '../../courses/entities/course.entity';
import { CourseEnrollment } from '../../enrollments/entities/course-enrollment.entity';
import { User } from '../../auth/entities/user.entity';
import { NotificationType, NotificationPriority } from '../../notifications/enums';
import { NotificationsService } from '../../notifications/services/notifications.service';

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
    private notificationsService: NotificationsService,
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

    if (grade.isPublished) {
      throw new GradeAlreadyPublishedException();
    }

    grade.isPublished = 1;
    const saved = await this.gradeRepo.save(grade);

    // Notify student about published grade
    await this.notificationsService.createNotification({
      userId: saved.userId,
      notificationType: NotificationType.GRADE,
      title: 'Grade Published',
      body: `Your grade for a ${saved.gradeType} has been published.`,
      relatedEntityType: 'grade',
      relatedEntityId: saved.id,
      priority: NotificationPriority.HIGH,
      actionUrl: `/grades`,
    });

    return saved;
  }

  async publishGrades(dto: BulkPublishGradesDto): Promise<{
    affected: number;
    gradeIds: number[];
    grades: Grade[];
  }> {
    const requestedIds = [...new Set(dto.gradeIds.map((id) => Number(id)).filter((id) => Number.isInteger(id) && id > 0))];
    if (!requestedIds.length) {
      return { affected: 0, gradeIds: [], grades: [] };
    }

    const grades = await this.gradeRepo.find({
      where: { id: In(requestedIds) as any },
    });

    const unpublishedGrades = grades.filter((grade) => !grade.isPublished);
    if (!unpublishedGrades.length) {
      return { affected: 0, gradeIds: [], grades: [] };
    }

    unpublishedGrades.forEach((grade) => {
      grade.isPublished = 1;
    });

    const savedGrades = await this.gradeRepo.save(unpublishedGrades);

    await Promise.all(
      savedGrades.map((grade) =>
        this.notificationsService.createNotification({
          userId: grade.userId,
          notificationType: NotificationType.GRADE,
          title: 'Grade Published',
          body: `Your grade for a ${grade.gradeType} has been published.`,
          relatedEntityType: 'grade',
          relatedEntityId: grade.id,
          priority: NotificationPriority.HIGH,
          actionUrl: '/grades',
        }),
      ),
    );

    return {
      affected: savedGrades.length,
      gradeIds: savedGrades.map((grade) => Number(grade.id)),
      grades: savedGrades,
    };
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

    const dedupedCourseGrades: Array<{ courseId: number; grade: Grade }> = [];
    for (const [courseId, courseGrades] of courseMap) {
      // Keep latest published grade per course for transcript/GPA purposes
      const finalGrade = courseGrades[courseGrades.length - 1];
      dedupedCourseGrades.push({ courseId, grade: finalGrade });
    }

    const courseIds = dedupedCourseGrades.map((item) => item.courseId);
    const courseSemesterRows: Array<{
      courseId: string | number;
      semesterId: string | number;
      semesterName: string;
    }> = [];

    if (courseIds.length > 0) {
      // Important: build explicit placeholders for IN (...) so MySQL receives
      // each course ID as a bound parameter (instead of a single array value).
      const inPlaceholders = courseIds.map(() => '?').join(', ');
      courseSemesterRows.push(
        ...(await this.enrollmentRepo.query(
          `
          SELECT
            cs.course_id AS courseId,
            MAX(s.semester_id) AS semesterId,
            SUBSTRING_INDEX(
              GROUP_CONCAT(s.semester_name ORDER BY s.semester_id DESC SEPARATOR '||'),
              '||',
              1
            ) AS semesterName
          FROM course_enrollments ce
          INNER JOIN course_sections cs ON cs.section_id = ce.section_id
          INNER JOIN semesters s ON s.semester_id = cs.semester_id
          WHERE ce.user_id = ?
            AND cs.course_id IN (${inPlaceholders})
          GROUP BY cs.course_id
          `,
          [studentId, ...courseIds],
        )),
      );
    }

    const semesterByCourse = new Map<number, { semesterId: number; semesterName: string }>();
    for (const row of courseSemesterRows) {
      semesterByCourse.set(Number(row.courseId), {
        semesterId: Number(row.semesterId) || 0,
        semesterName: row.semesterName || 'Unknown Semester',
      });
    }

    const semesterBuckets = new Map<
      number,
      {
        semesterId: number;
        semesterName: string;
        courses: TranscriptCourse[];
        totalCredits: number;
        totalQualityPoints: number;
      }
    >();

    let totalCredits = 0;
    let totalQualityPoints = 0;
    for (const { courseId, grade: finalGrade } of dedupedCourseGrades) {
      const normalizedCourseId = Number(courseId);
      const course = finalGrade.course;
      const credits = course?.credits || 3;
      const letterGrade = finalGrade.letterGrade || 'N/A';
      const gradePoint = this.getGradePoint(letterGrade);
      const semesterInfo = semesterByCourse.get(normalizedCourseId) || {
        semesterId: 0,
        semesterName: 'All Courses',
      };

      const transcriptCourse: TranscriptCourse = {
        courseId: normalizedCourseId,
        courseName: course?.name || '',
        credits,
        letterGrade,
        score: Number(finalGrade.score),
        maxScore: Number(finalGrade.maxScore),
      };

      const existing = semesterBuckets.get(semesterInfo.semesterId) || {
        semesterId: semesterInfo.semesterId,
        semesterName: semesterInfo.semesterName,
        courses: [],
        totalCredits: 0,
        totalQualityPoints: 0,
      };
      existing.courses.push(transcriptCourse);
      existing.totalCredits += credits;
      existing.totalQualityPoints += gradePoint * credits;
      semesterBuckets.set(semesterInfo.semesterId, existing);

      totalCredits += credits;
      totalQualityPoints += gradePoint * credits;
    }

    const cumulativeGpa =
      totalCredits > 0
        ? Math.round((totalQualityPoints / totalCredits) * 100) / 100
        : 0;

    const semesters: TranscriptSemester[] = Array.from(semesterBuckets.values())
      .sort((a, b) => a.semesterId - b.semesterId)
      .map((bucket) => ({
        semesterId: bucket.semesterId,
        semesterName: bucket.semesterName,
        gpa:
          bucket.totalCredits > 0
            ? Math.round((bucket.totalQualityPoints / bucket.totalCredits) * 100) / 100
            : 0,
        courses: bucket.courses,
      }));

    const dto = new TranscriptResponseDto();
    dto.studentId = studentId;
    dto.studentName = user ? `${user.firstName} ${user.lastName}` : '';
    dto.cumulativeGpa = cumulativeGpa;
    dto.totalCredits = totalCredits;
    dto.semesters = semesters.length
      ? semesters
      : [
          {
            semesterId: 0,
            semesterName: 'All Courses',
            gpa: cumulativeGpa,
            courses: [],
          },
        ];

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
