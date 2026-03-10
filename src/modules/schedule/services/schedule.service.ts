import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Between } from 'typeorm';
import { CalendarEvent, ExamSchedule } from '../entities';
import { CourseSchedule } from '../../courses/entities/course-schedule.entity';
import { QueryScheduleDto } from '../dto';

@Injectable()
export class ScheduleService {
  constructor(
    @InjectRepository(CalendarEvent)
    private readonly eventRepo: Repository<CalendarEvent>,
    @InjectRepository(ExamSchedule)
    private readonly examRepo: Repository<ExamSchedule>,
    @InjectRepository(CourseSchedule)
    private readonly courseScheduleRepo: Repository<CourseSchedule>,
  ) {}

  async getDailySchedule(userId: number, roles: string[], date?: string) {
    const targetDate = date ? new Date(date) : new Date();
    const startOfDay = new Date(targetDate);
    startOfDay.setHours(0, 0, 0, 0);
    const endOfDay = new Date(targetDate);
    endOfDay.setHours(23, 59, 59, 999);

    const dateStr = targetDate.toISOString().split('T')[0];
    const dayOfWeek = this.getDayOfWeek(targetDate);

    // Get course schedules for the day
    const courseSchedules = await this.getCourseSchedulesForUser(userId, roles, dayOfWeek);

    // Get calendar events for the day
    const events = await this.eventRepo.createQueryBuilder('event')
      .leftJoinAndSelect('event.course', 'course')
      .where('event.userId = :userId', { userId })
      .andWhere('event.startTime >= :start AND event.startTime <= :end', {
        start: startOfDay,
        end: endOfDay,
      })
      .orderBy('event.startTime', 'ASC')
      .getMany();

    // Get exams for the day
    const exams = await this.getExamsForUser(userId, roles, dateStr, dateStr);

    return {
      date: dateStr,
      dayOfWeek,
      schedules: courseSchedules.map(s => ({
        type: 'class',
        ...s,
      })),
      events: events.map(e => ({
        type: 'event',
        ...e,
      })),
      exams: exams.map(e => ({
        type: 'exam',
        ...e,
      })),
    };
  }

  async getWeeklySchedule(userId: number, roles: string[], startDate?: string) {
    const start = startDate ? new Date(startDate) : this.getStartOfWeek(new Date());
    const weekDays: any[] = [];

    for (let i = 0; i < 7; i++) {
      const day = new Date(start);
      day.setDate(start.getDate() + i);
      const dailySchedule = await this.getDailySchedule(userId, roles, day.toISOString().split('T')[0]);
      weekDays.push(dailySchedule);
    }

    return {
      weekStart: start.toISOString().split('T')[0],
      weekEnd: new Date(start.getTime() + 6 * 24 * 60 * 60 * 1000).toISOString().split('T')[0],
      days: weekDays,
    };
  }

  async getScheduleRange(userId: number, roles: string[], query: QueryScheduleDto) {
    const { startDate, endDate, eventType, courseId } = query;

    const qb = this.eventRepo.createQueryBuilder('event')
      .leftJoinAndSelect('event.course', 'course')
      .where('event.userId = :userId', { userId });

    if (startDate && endDate) {
      qb.andWhere('event.startTime >= :startDate AND event.endTime <= :endDate', {
        startDate: new Date(startDate),
        endDate: new Date(endDate),
      });
    }

    if (eventType) {
      qb.andWhere('event.eventType = :eventType', { eventType });
    }

    if (courseId) {
      qb.andWhere('event.courseId = :courseId', { courseId });
    }

    const events = await qb.orderBy('event.startTime', 'ASC').getMany();

    // Also get exams in range
    const exams = await this.getExamsForUser(userId, roles, startDate, endDate);

    return {
      startDate,
      endDate,
      events,
      exams,
    };
  }

  async getSectionSchedule(sectionId: number) {
    const schedules = await this.courseScheduleRepo.find({
      where: { sectionId },
      relations: ['section', 'section.course'],
      order: { dayOfWeek: 'ASC', startTime: 'ASC' },
    });

    return schedules;
  }

  async getAcademicCalendar(semesterId?: number) {
    // Get semester milestones and important dates
    const qb = this.eventRepo.createQueryBuilder('event')
      .where('event.courseId IS NULL') // System-wide events
      .andWhere('event.eventType IN (:...types)', { 
        types: ['exam', 'assignment', 'meeting'] 
      })
      .orderBy('event.startTime', 'ASC');

    const events = await qb.getMany();

    // Get all exams
    const examsQb = this.examRepo.createQueryBuilder('exam')
      .leftJoinAndSelect('exam.course', 'course')
      .leftJoinAndSelect('exam.semester', 'semester');

    if (semesterId) {
      examsQb.where('exam.semesterId = :semesterId', { semesterId });
    }

    const exams = await examsQb.orderBy('exam.examDate', 'ASC').getMany();

    return {
      events,
      exams,
    };
  }

  private async getCourseSchedulesForUser(userId: number, roles: string[], dayOfWeek: string) {
    const isAdmin = roles.includes('admin') || roles.includes('it_admin');
    const isInstructor = roles.includes('instructor');
    const isTA = roles.includes('teaching_assistant');

    const qb = this.courseScheduleRepo.createQueryBuilder('schedule')
      .leftJoinAndSelect('schedule.section', 'section')
      .leftJoinAndSelect('section.course', 'course')
      .where('UPPER(schedule.dayOfWeek) = :dayOfWeek', { dayOfWeek: dayOfWeek.toUpperCase() });

    if (!isAdmin) {
      if (isInstructor) {
        qb.innerJoin('course_instructors', 'ci', 'ci.section_id = section.id AND ci.user_id = :userId', { userId });
      } else if (isTA) {
        qb.innerJoin('course_tas', 'ct', 'ct.section_id = section.id AND ct.user_id = :userId', { userId });
      } else {
        // Student - enrolled courses
        qb.innerJoin('course_enrollments', 'ce', 'ce.section_id = section.id AND ce.user_id = :userId AND ce.enrollment_status = :status', { 
          userId, 
          status: 'enrolled' 
        });
      }
    }

    return qb.orderBy('schedule.startTime', 'ASC').getMany();
  }

  private async getExamsForUser(userId: number, roles: string[], fromDate?: string, toDate?: string) {
    const isAdmin = roles.includes('admin') || roles.includes('it_admin');
    const isInstructor = roles.includes('instructor');
    const isTA = roles.includes('teaching_assistant');

    const qb = this.examRepo.createQueryBuilder('exam')
      .leftJoinAndSelect('exam.course', 'course')
      .leftJoinAndSelect('exam.semester', 'semester');

    if (!isAdmin) {
      if (isInstructor) {
        qb.innerJoin('course_sections', 'cs', 'cs.course_id = exam.courseId')
          .innerJoin('course_instructors', 'ci', 'ci.section_id = cs.section_id AND ci.user_id = :userId', { userId });
      } else if (isTA) {
        qb.innerJoin('course_sections', 'cs', 'cs.course_id = exam.courseId')
          .innerJoin('course_tas', 'ct', 'ct.section_id = cs.section_id AND ct.user_id = :userId', { userId });
      } else {
        qb.innerJoin('course_sections', 'cs', 'cs.course_id = exam.courseId')
          .innerJoin('course_enrollments', 'ce', 'ce.section_id = cs.section_id AND ce.user_id = :userId AND ce.enrollment_status = :status', { 
            userId, 
            status: 'enrolled' 
          });
      }
    }

    if (fromDate) {
      qb.andWhere('exam.examDate >= :fromDate', { fromDate });
    }

    if (toDate) {
      qb.andWhere('exam.examDate <= :toDate', { toDate });
    }

    return qb.orderBy('exam.examDate', 'ASC').addOrderBy('exam.startTime', 'ASC').getMany();
  }

  private getDayOfWeek(date: Date): string {
    const days = ['SUNDAY', 'MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY'];
    return days[date.getDay()];
  }

  private getStartOfWeek(date: Date): Date {
    const d = new Date(date);
    const day = d.getDay();
    const diff = d.getDate() - day + (day === 0 ? -6 : 1); // Adjust for Monday start
    d.setDate(diff);
    d.setHours(0, 0, 0, 0);
    return d;
  }
}
