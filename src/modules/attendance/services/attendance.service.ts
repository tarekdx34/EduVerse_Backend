import { Injectable, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Between, Like } from 'typeorm';
import {
  AttendanceSession,
  AttendanceRecord,
} from '../entities';
import {
  CreateSessionDto,
  UpdateSessionDto,
  MarkAttendanceDto,
  BatchAttendanceDto,
  AttendanceQueryDto,
  AttendanceSummaryDto,
  StudentAttendanceSummaryDto,
  CourseAttendanceSummaryDto,
  WeeklyTrendDto,
  UpdateRecordDto,
} from '../dto';
import { AttendanceStatus, SessionStatus, MarkedBy } from '../enums';
import {
  SessionNotFoundException,
  SessionClosedException,
  RecordNotFoundException,
} from '../exceptions';
import { CourseSection } from '../../courses/entities/course-section.entity';
import { CourseEnrollment } from '../../enrollments/entities/course-enrollment.entity';
import { User } from '../../auth/entities/user.entity';
import { NotificationsService } from '../../notifications/services/notifications.service';
import { NotificationPriority, NotificationType } from '../../notifications/enums';

@Injectable()
export class AttendanceService {
  constructor(
    @InjectRepository(AttendanceSession)
    private readonly sessionRepo: Repository<AttendanceSession>,
    @InjectRepository(AttendanceRecord)
    private readonly recordRepo: Repository<AttendanceRecord>,
    @InjectRepository(CourseSection)
    private readonly sectionRepo: Repository<CourseSection>,
    @InjectRepository(CourseEnrollment)
    private readonly enrollmentRepo: Repository<CourseEnrollment>,
    @InjectRepository(User)
    private readonly userRepo: Repository<User>,
    private readonly notificationsService: NotificationsService,
  ) {}

  private async notifyStudentIfMarkedAbsent(
    session: AttendanceSession,
    userId: number,
    previousStatus?: AttendanceStatus | null,
    nextStatus?: AttendanceStatus | null,
  ): Promise<void> {
    if (nextStatus !== AttendanceStatus.ABSENT || previousStatus === AttendanceStatus.ABSENT) {
      return;
    }

    await this.notificationsService.createNotification({
      userId,
      notificationType: NotificationType.SYSTEM,
      title: 'Attendance Marked Absent',
      body: `You were marked absent for ${session.section?.course?.name || 'a class session'} on ${session.sessionDate}.`,
      relatedEntityType: 'attendance_session',
      relatedEntityId: session.id,
      priority: NotificationPriority.MEDIUM,
      actionUrl: '/attendance/my',
    });
  }

  async createSession(
    dto: CreateSessionDto,
    instructorId: number,
  ): Promise<AttendanceSession> {
    const section = await this.sectionRepo.findOne({
      where: { id: dto.sectionId },
    });
    if (!section) {
      throw new BadRequestException(`Section with ID ${dto.sectionId} not found`);
    }

    const session = this.sessionRepo.create({
      sectionId: dto.sectionId,
      sessionDate: dto.sessionDate,
      sessionType: dto.sessionType,
      instructorId,
      startTime: dto.startTime,
      endTime: dto.endTime,
      location: dto.location,
      notes: dto.notes,
      status: SessionStatus.SCHEDULED,
    });

    const savedSession = await this.sessionRepo.save(session);

    // Auto-create attendance records for all enrolled students (default: absent)
    await this.autoCreateRecordsForSession(savedSession.id, dto.sectionId);

    return this.findSessionById(savedSession.id);
  }

  private async autoCreateRecordsForSession(
    sessionId: number,
    sectionId: number,
  ): Promise<void> {
    const section = await this.sectionRepo.findOne({
      where: { id: sectionId },
      relations: ['course'],
    });
    if (!section) return;

    const enrollments = await this.enrollmentRepo.find({
      where: { sectionId: sectionId },
    });

    const records = enrollments.map((enrollment) =>
      this.recordRepo.create({
        sessionId,
        userId: enrollment.userId,
        attendanceStatus: AttendanceStatus.ABSENT,
        markedBy: MarkedBy.MANUAL,
      }),
    );

    if (records.length > 0) {
      await this.recordRepo.save(records);
      await this.sessionRepo.update(sessionId, {
        totalStudents: records.length,
        absentCount: records.length,
      });
    }
  }

  async findAllSessions(query: AttendanceQueryDto): Promise<{
    data: AttendanceSession[];
    meta: { total: number; page: number; limit: number; totalPages: number };
  }> {
    const {
      sectionId,
      courseId,
      instructorId,
      sessionType,
      status,
      dateFrom,
      dateTo,
      search,
      page = 1,
      limit = 10,
      sortBy = 'sessionDate',
      sortOrder = 'DESC',
    } = query;

    const queryBuilder = this.sessionRepo
      .createQueryBuilder('session')
      .leftJoinAndSelect('session.section', 'section')
      .leftJoinAndSelect('section.course', 'course')
      .leftJoinAndSelect('session.instructor', 'instructor');

    if (sectionId) {
      queryBuilder.andWhere('session.sectionId = :sectionId', { sectionId });
    }

    if (courseId) {
      queryBuilder.andWhere('section.courseId = :courseId', { courseId });
    }

    if (instructorId) {
      queryBuilder.andWhere('session.instructorId = :instructorId', { instructorId });
    }

    if (sessionType) {
      queryBuilder.andWhere('session.sessionType = :sessionType', { sessionType });
    }

    if (status) {
      queryBuilder.andWhere('session.status = :status', { status });
    }

    if (dateFrom && dateTo) {
      queryBuilder.andWhere('session.sessionDate BETWEEN :dateFrom AND :dateTo', {
        dateFrom,
        dateTo,
      });
    } else if (dateFrom) {
      queryBuilder.andWhere('session.sessionDate >= :dateFrom', { dateFrom });
    } else if (dateTo) {
      queryBuilder.andWhere('session.sessionDate <= :dateTo', { dateTo });
    }

    if (search) {
      queryBuilder.andWhere('session.notes LIKE :search', {
        search: `%${search}%`,
      });
    }

    const validSortFields = ['sessionDate', 'createdAt', 'status'];
    const orderField = validSortFields.includes(sortBy) ? sortBy : 'sessionDate';
    queryBuilder.orderBy(`session.${orderField}`, sortOrder);

    const total = await queryBuilder.getCount();
    const data = await queryBuilder
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

  async findSessionById(sessionId: number): Promise<AttendanceSession> {
    const session = await this.sessionRepo.findOne({
      where: { id: sessionId },
      relations: ['section', 'section.course', 'instructor', 'records', 'records.user'],
    });

    if (!session) {
      throw new SessionNotFoundException(sessionId);
    }

    return session;
  }

  async updateSession(
    sessionId: number,
    dto: UpdateSessionDto,
  ): Promise<AttendanceSession> {
    const session = await this.findSessionById(sessionId);

    if (
      session.status === SessionStatus.COMPLETED ||
      session.status === SessionStatus.CANCELLED
    ) {
      throw new SessionClosedException(sessionId);
    }

    await this.sessionRepo.update(sessionId, dto);
    return this.findSessionById(sessionId);
  }

  async deleteSession(sessionId: number): Promise<void> {
    const session = await this.findSessionById(sessionId);
    await this.sessionRepo.remove(session);
  }

  async closeSession(sessionId: number): Promise<AttendanceSession> {
    const session = await this.findSessionById(sessionId);

    if (session.status === SessionStatus.COMPLETED) {
      throw new SessionClosedException(sessionId);
    }

    // Update counts
    const records = await this.recordRepo.find({ where: { sessionId } });
    const presentCount = records.filter(
      (r) =>
        r.attendanceStatus === AttendanceStatus.PRESENT ||
        r.attendanceStatus === AttendanceStatus.LATE,
    ).length;
    const absentCount = records.filter(
      (r) => r.attendanceStatus === AttendanceStatus.ABSENT,
    ).length;

    await this.sessionRepo.update(sessionId, {
      status: SessionStatus.COMPLETED,
      presentCount,
      absentCount,
    });

    return this.findSessionById(sessionId);
  }

  async getSessionRecords(sessionId: number): Promise<AttendanceRecord[]> {
    await this.findSessionById(sessionId);
    return this.recordRepo.find({
      where: { sessionId },
      relations: ['user'],
      order: { userId: 'ASC' },
    });
  }

  async markAttendance(dto: MarkAttendanceDto): Promise<AttendanceRecord> {
    const session = await this.findSessionById(dto.sessionId);

    if (
      session.status === SessionStatus.COMPLETED ||
      session.status === SessionStatus.CANCELLED
    ) {
      throw new SessionClosedException(dto.sessionId);
    }

    let record = await this.recordRepo.findOne({
      where: { sessionId: dto.sessionId, userId: dto.userId },
    });
    const previousStatus = record?.attendanceStatus ?? null;

    if (record) {
      record.attendanceStatus = dto.attendanceStatus;
      record.checkInTime = dto.checkInTime ? new Date(dto.checkInTime) : null;
      record.notes = dto.notes || null;
      record.markedBy = MarkedBy.MANUAL;
    } else {
      record = this.recordRepo.create({
        sessionId: dto.sessionId,
        userId: dto.userId,
        attendanceStatus: dto.attendanceStatus,
        checkInTime: dto.checkInTime ? new Date(dto.checkInTime) : null,
        notes: dto.notes,
        markedBy: MarkedBy.MANUAL,
      });
    }

    const saved = await this.recordRepo.save(record);
    await this.notifyStudentIfMarkedAbsent(
      session,
      dto.userId,
      previousStatus,
      saved.attendanceStatus,
    );
    return saved;
  }

  async markBatchAttendance(dto: BatchAttendanceDto): Promise<AttendanceRecord[]> {
    const session = await this.findSessionById(dto.sessionId);

    if (
      session.status === SessionStatus.COMPLETED ||
      session.status === SessionStatus.CANCELLED
    ) {
      throw new SessionClosedException(dto.sessionId);
    }

    const results: AttendanceRecord[] = [];

    for (const recordDto of dto.records) {
      let record = await this.recordRepo.findOne({
        where: { sessionId: dto.sessionId, userId: recordDto.userId },
      });
      const previousStatus = record?.attendanceStatus ?? null;

      if (record) {
        record.attendanceStatus = recordDto.attendanceStatus;
        record.checkInTime = recordDto.checkInTime
          ? new Date(recordDto.checkInTime)
          : null;
        record.notes = recordDto.notes || null;
        record.markedBy = MarkedBy.MANUAL;
      } else {
        record = this.recordRepo.create({
          sessionId: dto.sessionId,
          userId: recordDto.userId,
          attendanceStatus: recordDto.attendanceStatus,
          checkInTime: recordDto.checkInTime
            ? new Date(recordDto.checkInTime)
            : null,
          notes: recordDto.notes,
          markedBy: MarkedBy.MANUAL,
        });
      }

      const saved = await this.recordRepo.save(record);
      await this.notifyStudentIfMarkedAbsent(
        session,
        recordDto.userId,
        previousStatus,
        saved.attendanceStatus,
      );
      results.push(saved);
    }

    return results;
  }

  async updateRecord(
    recordId: number,
    dto: UpdateRecordDto,
  ): Promise<AttendanceRecord> {
    const record = await this.recordRepo.findOne({
      where: { id: recordId },
      relations: ['session'],
    });

    if (!record) {
      throw new RecordNotFoundException(recordId);
    }

    if (
      record.session.status === SessionStatus.COMPLETED ||
      record.session.status === SessionStatus.CANCELLED
    ) {
      throw new SessionClosedException(record.sessionId);
    }

    const previousStatus = record.attendanceStatus;

    if (dto.attendanceStatus) {
      record.attendanceStatus = dto.attendanceStatus;
    }
    if (dto.checkInTime) {
      record.checkInTime = new Date(dto.checkInTime);
    }
    if (dto.notes !== undefined) {
      record.notes = dto.notes;
    }

    const saved = await this.recordRepo.save(record);
    const session = await this.findSessionById(record.sessionId);
    await this.notifyStudentIfMarkedAbsent(
      session,
      record.userId,
      previousStatus,
      saved.attendanceStatus,
    );
    return saved;
  }

  async getStudentAttendance(
    studentId: number,
    courseId?: number,
  ): Promise<StudentAttendanceSummaryDto> {
    const user = await this.userRepo.findOne({ where: { userId: studentId } });
    if (!user) {
      throw new BadRequestException(`User with ID ${studentId} not found`);
    }

    const queryBuilder = this.recordRepo
      .createQueryBuilder('record')
      .leftJoin('record.session', 'session')
      .leftJoin('session.section', 'section')
      .where('record.userId = :studentId', { studentId });

    if (courseId) {
      queryBuilder.andWhere('section.courseId = :courseId', { courseId });
    }

    const records = await queryBuilder.getMany();

    const totalSessions = records.length;
    const totalPresent = records.filter(
      (r) => r.attendanceStatus === AttendanceStatus.PRESENT,
    ).length;
    const totalLate = records.filter(
      (r) => r.attendanceStatus === AttendanceStatus.LATE,
    ).length;
    const totalAbsent = records.filter(
      (r) => r.attendanceStatus === AttendanceStatus.ABSENT,
    ).length;
    const totalExcused = records.filter(
      (r) => r.attendanceStatus === AttendanceStatus.EXCUSED,
    ).length;

    const attendancePercentage =
      totalSessions > 0
        ? ((totalPresent + totalLate) / totalSessions) * 100
        : 0;

    return {
      userId: studentId,
      studentName: `${user.firstName} ${user.lastName}`,
      studentEmail: user.email,
      totalSessions,
      totalPresent,
      totalAbsent,
      totalLate,
      totalExcused,
      attendancePercentage: Math.round(attendancePercentage * 100) / 100,
      isAtRisk: attendancePercentage < 75,
    };
  }

  async getSectionSummary(sectionId: number): Promise<CourseAttendanceSummaryDto> {
    const section = await this.sectionRepo.findOne({
      where: { id: sectionId },
      relations: ['course'],
    });

    if (!section) {
      throw new BadRequestException(`Section with ID ${sectionId} not found`);
    }

    const sessions = await this.sessionRepo.find({
      where: { sectionId, status: SessionStatus.COMPLETED },
    });

    const totalSessions = sessions.length;

    if (totalSessions === 0) {
      return {
        courseId: section.courseId,
        courseName: section.course?.name || 'Unknown',
        sectionId: section.id,
        sectionName: section.sectionNumber || 'Unknown',
        totalSessions: 0,
        averageAttendance: 0,
        atRiskStudentsCount: 0,
      };
    }

    // Get all records for this section
    const records = await this.recordRepo
      .createQueryBuilder('record')
      .leftJoin('record.session', 'session')
      .where('session.sectionId = :sectionId', { sectionId })
      .andWhere('session.status = :status', { status: SessionStatus.COMPLETED })
      .getMany();

    // Group by student
    const studentRecords = new Map<number, AttendanceRecord[]>();
    records.forEach((r) => {
      if (!studentRecords.has(r.userId)) {
        studentRecords.set(r.userId, []);
      }
      studentRecords.get(r.userId)!.push(r);
    });

    let totalAttendance = 0;
    let atRiskCount = 0;

    studentRecords.forEach((recs) => {
      const present = recs.filter(
        (r) =>
          r.attendanceStatus === AttendanceStatus.PRESENT ||
          r.attendanceStatus === AttendanceStatus.LATE,
      ).length;
      const percentage = (present / recs.length) * 100;
      totalAttendance += percentage;
      if (percentage < 75) {
        atRiskCount++;
      }
    });

    const averageAttendance =
      studentRecords.size > 0 ? totalAttendance / studentRecords.size : 0;

    return {
      courseId: section.courseId,
      courseName: section.course?.name || 'Unknown',
      sectionId: section.id,
      sectionName: section.sectionNumber || 'Unknown',
      totalSessions,
      averageAttendance: Math.round(averageAttendance * 100) / 100,
      atRiskStudentsCount: atRiskCount,
    };
  }

  async getWeeklyTrends(sectionId: number): Promise<WeeklyTrendDto[]> {
    const sessions = await this.sessionRepo.find({
      where: { sectionId, status: SessionStatus.COMPLETED },
      order: { sessionDate: 'ASC' },
    });

    if (sessions.length === 0) {
      return [];
    }

    // Group sessions by week
    const weeklyData = new Map<string, AttendanceSession[]>();

    sessions.forEach((session) => {
      const date = new Date(session.sessionDate);
      const weekStart = this.getWeekStart(date);
      const weekKey = weekStart.toISOString().split('T')[0];

      if (!weeklyData.has(weekKey)) {
        weeklyData.set(weekKey, []);
      }
      weeklyData.get(weekKey)!.push(session);
    });

    const trends: WeeklyTrendDto[] = [];

    for (const [weekStart, weekSessions] of weeklyData) {
      const weekEnd = new Date(weekStart);
      weekEnd.setDate(weekEnd.getDate() + 6);

      let totalAttendance = 0;
      for (const session of weekSessions) {
        if (session.totalStudents > 0) {
          totalAttendance +=
            (session.presentCount / session.totalStudents) * 100;
        }
      }

      trends.push({
        weekStart,
        weekEnd: weekEnd.toISOString().split('T')[0],
        sessionsCount: weekSessions.length,
        averageAttendance:
          weekSessions.length > 0
            ? Math.round((totalAttendance / weekSessions.length) * 100) / 100
            : 0,
      });
    }

    return trends;
  }

  private getWeekStart(date: Date): Date {
    const d = new Date(date);
    const day = d.getDay();
    const diff = d.getDate() - day + (day === 0 ? -6 : 1); // Adjust for Sunday
    d.setDate(diff);
    d.setHours(0, 0, 0, 0);
    return d;
  }

  async getCourseAttendanceSummary(
    courseId: number,
  ): Promise<CourseAttendanceSummaryDto[]> {
    const sections = await this.sectionRepo.find({
      where: { courseId },
    });

    const summaries: CourseAttendanceSummaryDto[] = [];

    for (const section of sections) {
      const summary = await this.getSectionSummary(section.id);
      summaries.push(summary);
    }

    return summaries;
  }
}
