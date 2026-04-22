import {
  ForbiddenException,
  Injectable,
  Logger,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CourseAnalytics } from '../entities/course-analytics.entity';
import {
  LearningAnalytics,
  MetricType,
} from '../entities/learning-analytics.entity';
import { PerformanceMetrics } from '../entities/performance-metrics.entity';
import { StudentProgress } from '../entities/student-progress.entity';
import { WeakTopicsAnalysis } from '../entities/weak-topics-analysis.entity';
import { ActivityLog } from '../entities/activity-log.entity';
import { AnalyticsQueryDto } from '../dto/analytics-query.dto';
import { StudentAnalyticsQueryDto } from '../dto/student-analytics-query.dto';
import { RoleName } from '../../auth/entities/role.entity';
import { CourseTA } from '../../enrollments/entities/course-ta.entity';
import { CourseInstructor } from '../../enrollments/entities/course-instructor.entity';

@Injectable()
export class AnalyticsService {
  private readonly logger = new Logger(AnalyticsService.name);

  constructor(
    @InjectRepository(CourseAnalytics)
    private courseAnalyticsRepo: Repository<CourseAnalytics>,
    @InjectRepository(LearningAnalytics)
    private learningAnalyticsRepo: Repository<LearningAnalytics>,
    @InjectRepository(PerformanceMetrics)
    private performanceMetricsRepo: Repository<PerformanceMetrics>,
    @InjectRepository(StudentProgress)
    private studentProgressRepo: Repository<StudentProgress>,
    @InjectRepository(WeakTopicsAnalysis)
    private weakTopicsRepo: Repository<WeakTopicsAnalysis>,
    @InjectRepository(ActivityLog)
    private activityLogRepo: Repository<ActivityLog>,
    @InjectRepository(CourseTA)
    private courseTARepo: Repository<CourseTA>,
    @InjectRepository(CourseInstructor)
    private courseInstructorRepo: Repository<CourseInstructor>,
  ) {}

  async getDashboard(userId: number, roles: string[]) {
    this.logger.log(`Getting dashboard for user ${userId}, roles: ${roles}`);

    const isAdmin = roles.some((r) =>
      [RoleName.ADMIN, RoleName.IT_ADMIN].includes(r as RoleName),
    );
    const isInstructor = roles.includes(RoleName.INSTRUCTOR);
    const isTA = roles.includes(RoleName.TA);

    if (isAdmin) {
      // System-wide stats
      const stats = await this.courseAnalyticsRepo
        .createQueryBuilder('ca')
        .select('COUNT(DISTINCT ca.course_id)', 'totalCourses')
        .addSelect('SUM(ca.total_students)', 'totalStudents')
        .addSelect('AVG(ca.average_grade)', 'averageGrade')
        .addSelect('AVG(ca.average_attendance)', 'averageAttendance')
        .addSelect('AVG(ca.completion_rate)', 'averageCompletionRate')
        .addSelect('AVG(ca.engagement_score)', 'averageEngagement')
        .getRawOne();

      const recentActivity = await this.activityLogRepo
        .createQueryBuilder('al')
        .select('al.activity_type', 'activityType')
        .addSelect('COUNT(*)', 'count')
        .where('al.created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)')
        .groupBy('al.activity_type')
        .getRawMany();

      return { data: { ...stats, recentActivity } };
    }

    if (isInstructor) {
      // Instructor's courses
      const stats = await this.courseAnalyticsRepo
        .createQueryBuilder('ca')
        .select('COUNT(DISTINCT ca.course_id)', 'totalCourses')
        .addSelect('SUM(ca.total_students)', 'totalStudents')
        .addSelect('AVG(ca.average_grade)', 'averageGrade')
        .addSelect('AVG(ca.average_attendance)', 'averageAttendance')
        .addSelect('AVG(ca.completion_rate)', 'averageCompletionRate')
        .addSelect('AVG(ca.engagement_score)', 'averageEngagement')
        .where('ca.instructor_id = :userId', { userId })
        .getRawOne();

      const courseBreakdown = await this.courseAnalyticsRepo
        .createQueryBuilder('ca')
        .where('ca.instructor_id = :userId', { userId })
        .orderBy('ca.calculation_date', 'DESC')
        .getMany();

      return { data: { ...stats, courseBreakdown } };
    }

    if (isTA) {
      const accessibleCourseIds = await this.getAccessibleCourseIds(userId, roles);

      if (accessibleCourseIds !== null && accessibleCourseIds.length === 0) {
        return {
          data: {
            totalCourses: '0',
            totalStudents: '0',
            averageGrade: '0',
            averageAttendance: '0',
            averageCompletionRate: '0',
            averageEngagement: '0',
            courseBreakdown: [],
          },
        };
      }

      const stats = await this.courseAnalyticsRepo
        .createQueryBuilder('ca')
        .select('COUNT(DISTINCT ca.course_id)', 'totalCourses')
        .addSelect('SUM(ca.total_students)', 'totalStudents')
        .addSelect('AVG(ca.average_grade)', 'averageGrade')
        .addSelect('AVG(ca.average_attendance)', 'averageAttendance')
        .addSelect('AVG(ca.completion_rate)', 'averageCompletionRate')
        .addSelect('AVG(ca.engagement_score)', 'averageEngagement')
        .where('ca.course_id IN (:...courseIds)', {
          courseIds: accessibleCourseIds,
        })
        .getRawOne();

      const courseBreakdown = await this.courseAnalyticsRepo
        .createQueryBuilder('ca')
        .where('ca.course_id IN (:...courseIds)', {
          courseIds: accessibleCourseIds,
        })
        .orderBy('ca.calculation_date', 'DESC')
        .getMany();

      return { data: { ...stats, courseBreakdown } };
    }

    // Student view
    const progress = await this.studentProgressRepo
      .createQueryBuilder('sp')
      .select('COUNT(DISTINCT sp.course_id)', 'totalCourses')
      .addSelect('AVG(sp.completion_percentage)', 'averageCompletion')
      .addSelect('AVG(sp.average_score)', 'averageScore')
      .addSelect('SUM(sp.time_spent_minutes)', 'totalTimeSpent')
      .where('sp.user_id = :userId', { userId })
      .getRawOne();

    const courseProgress = await this.studentProgressRepo.find({
      where: { userId },
      order: { updatedAt: 'DESC' },
    });

    return { data: { ...progress, courseProgress } };
  }

  async getCourseAnalytics(courseId: number, userId?: number, roles: string[] = []) {
    this.logger.log(`Getting analytics for course ${courseId}`);
    await this.assertAnalyticsAccess(courseId, userId, roles);

    const analytics = await this.courseAnalyticsRepo.find({
      where: { courseId },
      order: { calculationDate: 'DESC' },
    });

    if (!analytics.length) {
      throw new NotFoundException(
        `No analytics found for course ${courseId}`,
      );
    }

    const latest = analytics[0];
    const history = analytics;

    return { data: { latest, history } };
  }

  async getStudentAnalytics(studentId: number, courseId?: number) {
    this.logger.log(
      `Getting analytics for student ${studentId}, course: ${courseId || 'all'}`,
    );

    const progressWhere: any = { userId: studentId };
    if (courseId) progressWhere.courseId = courseId;

    const progress = await this.studentProgressRepo.find({
      where: progressWhere,
      order: { updatedAt: 'DESC' },
    });

    const learningQb = this.learningAnalyticsRepo
      .createQueryBuilder('la')
      .where('la.user_id = :studentId', { studentId });

    if (courseId) {
      learningQb.andWhere('la.course_id = :courseId', { courseId });
    }

    const learningMetrics = await learningQb
      .orderBy('la.metric_date', 'DESC')
      .limit(50)
      .getMany();

    const performanceQb = this.performanceMetricsRepo
      .createQueryBuilder('pm')
      .where('pm.user_id = :studentId', { studentId });

    if (courseId) {
      performanceQb.andWhere('pm.course_id = :courseId', { courseId });
    }

    const performanceMetrics = await performanceQb
      .orderBy('pm.calculation_date', 'DESC')
      .limit(50)
      .getMany();

    return { data: { progress, learningMetrics, performanceMetrics } };
  }

  async getPerformanceMetrics(
    courseId: number,
    query: AnalyticsQueryDto,
    userId?: number,
    roles: string[] = [],
  ) {
    await this.assertAnalyticsAccess(courseId, userId, roles);
    const { startDate, endDate, page = 1, limit = 20 } = query;

    const qb = this.performanceMetricsRepo
      .createQueryBuilder('pm')
      .where('pm.course_id = :courseId', { courseId });

    if (startDate) {
      qb.andWhere('pm.calculation_date >= :startDate', { startDate });
    }
    if (endDate) {
      qb.andWhere('pm.calculation_date <= :endDate', { endDate });
    }

    const total = await qb.getCount();

    const data = await qb
      .orderBy('pm.calculation_date', 'DESC')
      .skip((page - 1) * limit)
      .take(limit)
      .getMany();

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

  async getEngagement(
    courseId: number,
    query: AnalyticsQueryDto,
    userId?: number,
    roles: string[] = [],
  ) {
    await this.assertAnalyticsAccess(courseId, userId, roles);
    const { startDate, endDate, page = 1, limit = 20 } = query;

    const qb = this.learningAnalyticsRepo
      .createQueryBuilder('la')
      .where('la.course_id = :courseId', { courseId })
      .andWhere('la.metric_type = :metricType', {
        metricType: MetricType.ENGAGEMENT,
      });

    if (startDate) {
      qb.andWhere('la.metric_date >= :startDate', { startDate });
    }
    if (endDate) {
      qb.andWhere('la.metric_date <= :endDate', { endDate });
    }

    const total = await qb.getCount();

    const data = await qb
      .orderBy('la.metric_date', 'DESC')
      .skip((page - 1) * limit)
      .take(limit)
      .getMany();

    // Aggregate engagement summary
    const summary = await this.learningAnalyticsRepo
      .createQueryBuilder('la')
      .select('AVG(la.metric_value)', 'averageEngagement')
      .addSelect('MIN(la.metric_value)', 'minEngagement')
      .addSelect('MAX(la.metric_value)', 'maxEngagement')
      .addSelect('COUNT(DISTINCT la.user_id)', 'uniqueStudents')
      .where('la.course_id = :courseId', { courseId })
      .andWhere('la.metric_type = :metricType', {
        metricType: MetricType.ENGAGEMENT,
      })
      .getRawOne();

    return {
      data,
      summary,
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  async getAttendanceTrends(
    courseId: number,
    query: AnalyticsQueryDto,
    userId?: number,
    roles: string[] = [],
  ) {
    await this.assertAnalyticsAccess(courseId, userId, roles);
    const { startDate, endDate, page = 1, limit = 20 } = query;

    const qb = this.courseAnalyticsRepo
      .createQueryBuilder('ca')
      .select('ca.calculation_date', 'date')
      .addSelect('ca.average_attendance', 'averageAttendance')
      .addSelect('ca.total_students', 'totalStudents')
      .addSelect('ca.active_students', 'activeStudents')
      .where('ca.course_id = :courseId', { courseId });

    if (startDate) {
      qb.andWhere('ca.calculation_date >= :startDate', { startDate });
    }
    if (endDate) {
      qb.andWhere('ca.calculation_date <= :endDate', { endDate });
    }

    const totalQb = qb.clone();
    const total = await totalQb.getCount();

    const data = await qb
      .orderBy('ca.calculation_date', 'ASC')
      .offset((page - 1) * limit)
      .limit(limit)
      .getRawMany();

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

  async getAtRiskStudents(
    courseId?: number,
    userId?: number,
    roles: string[] = [],
  ) {
    this.logger.log(
      `Getting at-risk students${courseId ? ` for course ${courseId}` : ''}`,
    );

    const accessibleCourseIds = await this.getAccessibleCourseIds(userId, roles);
    if (courseId) {
      await this.assertAnalyticsAccess(courseId, userId, roles);
    }

    const hasScopedCourseList =
      accessibleCourseIds !== null && accessibleCourseIds.length > 0;

    // Students with low grades from course analytics
    const lowGradeQb = this.courseAnalyticsRepo
      .createQueryBuilder('ca')
      .select('DISTINCT ca.course_id', 'courseId')
      .addSelect('ca.average_grade', 'averageGrade')
      .addSelect('ca.average_attendance', 'averageAttendance')
      .where(
        '(ca.average_grade < 70 OR ca.average_attendance < 75)',
      );

    if (courseId) {
      lowGradeQb.andWhere('ca.course_id = :courseId', { courseId });
    } else if (hasScopedCourseList) {
      lowGradeQb.andWhere('ca.course_id IN (:...courseIds)', {
        courseIds: accessibleCourseIds,
      });
    }

    const atRiskCourses = await lowGradeQb.getRawMany();

    // Students with low progress
    const progressQb = this.studentProgressRepo
      .createQueryBuilder('sp')
      .leftJoinAndSelect('sp.user', 'user')
      .where(
        '(sp.average_score < 70 OR sp.completion_percentage < 50)',
      );

    if (courseId) {
      progressQb.andWhere('sp.course_id = :courseId', { courseId });
    } else if (hasScopedCourseList) {
      progressQb.andWhere('sp.course_id IN (:...courseIds)', {
        courseIds: accessibleCourseIds,
      });
    }

    const atRiskStudents = await progressQb
      .orderBy('sp.average_score', 'ASC')
      .getMany();

    return {
      data: {
        atRiskCourses,
        atRiskStudents: atRiskStudents.map((sp) => ({
          userId: sp.userId,
          courseId: sp.courseId,
          userName: sp.user
            ? `${sp.user['firstName'] || ''} ${sp.user['lastName'] || ''}`.trim()
            : null,
          completionPercentage: sp.completionPercentage,
          averageScore: sp.averageScore,
          timeSpentMinutes: sp.timeSpentMinutes,
          lastActivityAt: sp.lastActivityAt,
        })),
      },
    };
  }

  async getGradeDistribution(
    courseId: number,
    userId?: number,
    roles: string[] = [],
  ) {
    this.logger.log(`Getting grade distribution for course ${courseId}`);
    await this.assertAnalyticsAccess(courseId, userId, roles);

    const distribution = await this.studentProgressRepo
      .createQueryBuilder('sp')
      .select(
        `CASE
          WHEN sp.average_score >= 90 THEN 'A'
          WHEN sp.average_score >= 80 THEN 'B'
          WHEN sp.average_score >= 70 THEN 'C'
          WHEN sp.average_score >= 60 THEN 'D'
          ELSE 'F'
        END`,
        'grade',
      )
      .addSelect('COUNT(*)', 'count')
      .where('sp.course_id = :courseId', { courseId })
      .andWhere('sp.average_score IS NOT NULL')
      .groupBy('grade')
      .orderBy('grade', 'ASC')
      .getRawMany();

    const stats = await this.courseAnalyticsRepo
      .createQueryBuilder('ca')
      .select('ca.average_grade', 'averageGrade')
      .addSelect('ca.total_students', 'totalStudents')
      .where('ca.course_id = :courseId', { courseId })
      .orderBy('ca.calculation_date', 'DESC')
      .limit(1)
      .getRawOne();

    return { data: { distribution, stats } };
  }

  async getEnrollmentTrends(query: AnalyticsQueryDto) {
    const { startDate, endDate, page = 1, limit = 20 } = query;

    const qb = this.courseAnalyticsRepo
      .createQueryBuilder('ca')
      .select('ca.calculation_date', 'date')
      .addSelect('SUM(ca.total_students)', 'totalEnrollments')
      .addSelect('SUM(ca.active_students)', 'activeStudents')
      .addSelect('COUNT(DISTINCT ca.course_id)', 'totalCourses');

    if (startDate) {
      qb.andWhere('ca.calculation_date >= :startDate', { startDate });
    }
    if (endDate) {
      qb.andWhere('ca.calculation_date <= :endDate', { endDate });
    }

    qb.groupBy('ca.calculation_date');

    const allData = await qb
      .orderBy('ca.calculation_date', 'ASC')
      .getRawMany();

    const total = allData.length;
    const data = allData.slice((page - 1) * limit, page * limit);

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

  async getCourseComparison(
    courseIds: number[],
    userId?: number,
    roles: string[] = [],
  ) {
    this.logger.log(`Comparing courses: ${courseIds.join(', ')}`);

    if (!courseIds || courseIds.length === 0) {
      return { data: [] };
    }

    for (const courseId of courseIds) {
      await this.assertAnalyticsAccess(courseId, userId, roles);
    }

    const comparison = await this.courseAnalyticsRepo
      .createQueryBuilder('ca')
      .where('ca.course_id IN (:...courseIds)', { courseIds })
      .andWhere(
        'ca.calculation_date = (SELECT MAX(ca2.calculation_date) FROM course_analytics ca2 WHERE ca2.course_id = ca.course_id)',
      )
      .orderBy('ca.course_id', 'ASC')
      .getMany();

    return { data: comparison };
  }

  async getWeakTopics(courseId: number, userId?: number) {
    this.logger.log(
      `Getting weak topics for course ${courseId}${userId ? `, user ${userId}` : ''}`,
    );

    const qb = this.weakTopicsRepo
      .createQueryBuilder('wt')
      .where('wt.course_id = :courseId', { courseId });

    if (userId) {
      qb.andWhere('wt.user_id = :userId', { userId });
    }

    const data = await qb
      .orderBy('wt.weakness_score', 'DESC')
      .getMany();

    // Aggregate by topic if no specific user
    let topicSummary: any[] | null = null;
    if (!userId) {
      topicSummary = await this.weakTopicsRepo
        .createQueryBuilder('wt')
        .select('wt.topic_name', 'topicName')
        .addSelect('AVG(wt.weakness_score)', 'avgWeaknessScore')
        .addSelect('AVG(wt.success_rate)', 'avgSuccessRate')
        .addSelect('SUM(wt.attempt_count)', 'totalAttempts')
        .addSelect('COUNT(DISTINCT wt.user_id)', 'affectedStudents')
        .where('wt.course_id = :courseId', { courseId })
        .groupBy('wt.topic_name')
        .orderBy('avgWeaknessScore', 'DESC')
        .getRawMany();
    }

    return { data, topicSummary };
  }

  private async getAccessibleCourseIds(
    userId?: number,
    roles: string[] = [],
  ): Promise<number[] | null> {
    if (!userId) return [];

    const isAdmin = roles.some((r) =>
      [RoleName.ADMIN, RoleName.IT_ADMIN].includes(r as RoleName),
    );

    if (isAdmin) {
      return null;
    }

    const isInstructor = roles.includes(RoleName.INSTRUCTOR);
    const isTA = roles.includes(RoleName.TA);

    const courseIds = new Set<number>();

    if (isInstructor) {
      const instructorAssignments = await this.courseInstructorRepo.find({
        where: { userId },
        relations: ['section'],
      });

      instructorAssignments.forEach((assignment) => {
        if (assignment.section?.courseId) {
          courseIds.add(Number(assignment.section.courseId));
        }
      });
    }

    if (isTA) {
      const taAssignments = await this.courseTARepo.find({
        where: { userId },
        relations: ['section'],
      });

      taAssignments.forEach((assignment) => {
        if (assignment.section?.courseId) {
          courseIds.add(Number(assignment.section.courseId));
        }
      });
    }

    return Array.from(courseIds);
  }

  private async assertAnalyticsAccess(
    courseId: number,
    userId?: number,
    roles: string[] = [],
  ) {
    const accessibleCourseIds = await this.getAccessibleCourseIds(userId, roles);

    if (accessibleCourseIds === null) {
      return;
    }

    if (!accessibleCourseIds.includes(Number(courseId))) {
      throw new ForbiddenException(
        `You do not have analytics access to course ${courseId}`,
      );
    }
  }
}
