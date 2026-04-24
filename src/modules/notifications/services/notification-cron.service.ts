import { Injectable, Logger } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { InjectRepository } from '@nestjs/typeorm';
import { Between, In, IsNull, Repository } from 'typeorm';
import { NotificationsService } from './notifications.service';
import { NotificationPriority, NotificationType } from '../enums';
import { CourseSchedule } from '../../courses/entities/course-schedule.entity';
import { DayOfWeek } from '../../courses/enums';
import { CourseInstructor } from '../../enrollments/entities/course-instructor.entity';
import { CourseTA } from '../../enrollments/entities/course-ta.entity';
import { Assignment } from '../../assignments/entities/assignment.entity';
import { AssignmentSubmission } from '../../assignments/entities/assignment-submission.entity';
import { AssignmentStatus, SubmissionStatus } from '../../assignments/enums';
import { Lab } from '../../labs/entities/lab.entity';
import { LabSubmission } from '../../labs/entities/lab-submission.entity';
import { LabStatus } from '../../labs/enums';
import { Quiz } from '../../quizzes/entities/quiz.entity';
import { QuizAttempt } from '../../quizzes/entities/quiz-attempt.entity';
import { QuizStatus } from '../../quizzes/enums';
import { ExamSchedule } from '../../schedule/entities/exam-schedule.entity';
import { CampusEvent, CampusEventStatus } from '../../schedule/entities/campus-event.entity';

@Injectable()
export class NotificationCronService {
  private readonly logger = new Logger(NotificationCronService.name);

  constructor(
    private readonly notificationsService: NotificationsService,
    @InjectRepository(CourseSchedule)
    private readonly courseScheduleRepository: Repository<CourseSchedule>,
    @InjectRepository(CourseInstructor)
    private readonly instructorRepository: Repository<CourseInstructor>,
    @InjectRepository(CourseTA)
    private readonly taRepository: Repository<CourseTA>,
    @InjectRepository(Assignment)
    private readonly assignmentRepository: Repository<Assignment>,
    @InjectRepository(AssignmentSubmission)
    private readonly assignmentSubmissionRepository: Repository<AssignmentSubmission>,
    @InjectRepository(Lab)
    private readonly labRepository: Repository<Lab>,
    @InjectRepository(LabSubmission)
    private readonly labSubmissionRepository: Repository<LabSubmission>,
    @InjectRepository(Quiz)
    private readonly quizRepository: Repository<Quiz>,
    @InjectRepository(QuizAttempt)
    private readonly quizAttemptRepository: Repository<QuizAttempt>,
    @InjectRepository(ExamSchedule)
    private readonly examScheduleRepository: Repository<ExamSchedule>,
    @InjectRepository(CampusEvent)
    private readonly campusEventRepository: Repository<CampusEvent>,
  ) {}

  private getTodayDayOfWeek(): DayOfWeek {
    const dayNames: DayOfWeek[] = [
      DayOfWeek.SUNDAY,
      DayOfWeek.MONDAY,
      DayOfWeek.TUESDAY,
      DayOfWeek.WEDNESDAY,
      DayOfWeek.THURSDAY,
      DayOfWeek.FRIDAY,
      DayOfWeek.SATURDAY,
    ];

    return dayNames[new Date().getDay()];
  }

  private atHour(hour: number): Date {
    const now = new Date();
    now.setHours(hour, 0, 0, 0);
    return now;
  }

  private getTomorrowRange(): { start: Date; end: Date } {
    const start = new Date();
    start.setDate(start.getDate() + 1);
    start.setHours(0, 0, 0, 0);

    const end = new Date(start);
    end.setHours(23, 59, 59, 999);

    return { start, end };
  }

  private getUpcomingRange(daysAhead: number): { start: Date; end: Date } {
    const start = new Date();
    const end = new Date();
    end.setDate(end.getDate() + daysAhead);
    return { start, end };
  }

  @Cron(CronExpression.EVERY_DAY_AT_7AM)
  async handleDailyScheduleReminders() {
    this.logger.log('Running daily teaching schedule reminders');

    const dayOfWeek = this.getTodayDayOfWeek();
    const scheduleRows = await this.courseScheduleRepository.find({
      where: { dayOfWeek },
      select: ['sectionId'],
    });

    const sectionIds = [...new Set(scheduleRows.map((row) => Number(row.sectionId)))];
    if (!sectionIds.length) {
      return;
    }

    const [instructors, tas] = await Promise.all([
      this.instructorRepository.find({
        where: { sectionId: In(sectionIds) as any },
        select: ['sectionId', 'userId'],
      }),
      this.taRepository.find({
        where: { sectionId: In(sectionIds) as any },
        select: ['sectionId', 'userId'],
      }),
    ]);

    const validSectionIds = new Set(sectionIds);
    const staffIds = [
      ...instructors.filter((assignment) => validSectionIds.has(Number(assignment.sectionId))).map((assignment) => Number(assignment.userId)),
      ...tas.filter((assignment) => validSectionIds.has(Number(assignment.sectionId))).map((assignment) => Number(assignment.userId)),
    ];

    await this.notificationsService.dispatchScheduledNotifications(
      staffIds,
      {
        notificationType: NotificationType.SCHEDULE,
        title: 'Teaching Schedule Reminder',
        body: 'You have teaching activities scheduled for today. Check your course schedule for details.',
        priority: NotificationPriority.MEDIUM,
        actionUrl: '/schedule',
      },
      this.atHour(7),
    );
  }

  @Cron(CronExpression.EVERY_DAY_AT_9AM)
  async handleDeadlineReminders() {
    this.logger.log('Running academic deadline reminders');
    await Promise.all([
      this.sendAssignmentDeadlineReminders(),
      this.sendLabDeadlineReminders(),
      this.sendQuizClosingReminders(),
      this.sendExamTomorrowReminders(),
      this.sendCampusEventReminders(),
    ]);
  }

  @Cron('0 8 * * 1')
  async handleGradingReminders() {
    this.logger.log('Running pending grading reminders');
    await Promise.all([
      this.sendAssignmentGradingReminders(),
      this.sendLabGradingReminders(),
    ]);
  }

  private async sendAssignmentDeadlineReminders(): Promise<void> {
    const { start, end } = this.getUpcomingRange(2);
    const assignments = await this.assignmentRepository.find({
      where: {
        status: AssignmentStatus.PUBLISHED,
        dueDate: Between(start, end),
      } as any,
      relations: ['course'],
    });

    for (const assignment of assignments) {
      const [studentIds, submittedRows] = await Promise.all([
        this.notificationsService.getEnrolledStudentIds(Number(assignment.courseId)),
        this.assignmentSubmissionRepository.find({
          where: { assignmentId: assignment.id },
          select: ['userId'],
        }),
      ]);

      const submittedStudentIds = new Set(submittedRows.map((row) => Number(row.userId)));
      const recipients = studentIds.filter((userId) => !submittedStudentIds.has(userId));
      if (!recipients.length) {
        continue;
      }

      await this.notificationsService.dispatchScheduledNotifications(
        recipients,
        {
          notificationType: NotificationType.DEADLINE,
          title: `Assignment Due Soon: ${assignment.title}`,
          body: `The assignment "${assignment.title}" is due soon. Submit it before the deadline.`,
          relatedEntityType: 'assignment',
          relatedEntityId: assignment.id,
          priority: NotificationPriority.HIGH,
          actionUrl: `/courses/${assignment.courseId}/assignments/${assignment.id}`,
        },
        this.atHour(9),
      );
    }
  }

  private async sendLabDeadlineReminders(): Promise<void> {
    const { start, end } = this.getUpcomingRange(2);
    const labs = await this.labRepository.find({
      where: {
        status: LabStatus.PUBLISHED as any,
        dueDate: Between(start, end),
      } as any,
      relations: ['course'],
    });

    for (const lab of labs) {
      const [studentIds, submittedRows] = await Promise.all([
        this.notificationsService.getEnrolledStudentIds(Number(lab.courseId)),
        this.labSubmissionRepository.find({
          where: { labId: lab.id },
          select: ['userId'],
        }),
      ]);

      const submittedStudentIds = new Set(submittedRows.map((row) => Number(row.userId)));
      const recipients = studentIds.filter((userId) => !submittedStudentIds.has(userId));
      if (!recipients.length) {
        continue;
      }

      await this.notificationsService.dispatchScheduledNotifications(
        recipients,
        {
          notificationType: NotificationType.DEADLINE,
          title: `Lab Due Soon: ${lab.title}`,
          body: `The lab "${lab.title}" is due soon. Submit your work before the deadline.`,
          relatedEntityType: 'lab',
          relatedEntityId: lab.id,
          priority: NotificationPriority.HIGH,
          actionUrl: `/courses/${lab.courseId}/labs/${lab.id}`,
        },
        this.atHour(9),
      );
    }
  }

  private async sendQuizClosingReminders(): Promise<void> {
    const { start, end } = this.getUpcomingRange(1);
    const quizzes = await this.quizRepository.find({
      where: {
        status: QuizStatus.PUBLISHED,
        availableUntil: Between(start, end),
        deletedAt: IsNull(),
      } as any,
      relations: ['course'],
    });

    for (const quiz of quizzes) {
      const [studentIds, attemptRows] = await Promise.all([
        this.notificationsService.getEnrolledStudentIds(Number(quiz.courseId)),
        this.quizAttemptRepository.find({
          where: { quizId: quiz.id },
          select: ['userId'],
        }),
      ]);

      const attemptedStudentIds = new Set(attemptRows.map((row) => Number(row.userId)));
      const recipients = studentIds.filter((userId) => !attemptedStudentIds.has(userId));
      if (!recipients.length) {
        continue;
      }

      await this.notificationsService.dispatchScheduledNotifications(
        recipients,
        {
          notificationType: NotificationType.DEADLINE,
          title: `Quiz Closing Soon: ${quiz.title}`,
          body: `The quiz "${quiz.title}" will close soon. Complete your attempt before the window ends.`,
          relatedEntityType: 'quiz',
          relatedEntityId: quiz.id,
          priority: NotificationPriority.HIGH,
          actionUrl: `/courses/${quiz.courseId}/quizzes/${quiz.id}`,
        },
        this.atHour(9),
      );
    }
  }

  private async sendAssignmentGradingReminders(): Promise<void> {
    const submittedAssignments = await this.assignmentSubmissionRepository
      .createQueryBuilder('submission')
      .innerJoin('submission.assignment', 'assignment')
      .select('submission.assignmentId', 'assignmentId')
      .addSelect('COUNT(*)', 'submissionCount')
      .where('submission.submissionStatus = :status', { status: SubmissionStatus.SUBMITTED })
      .groupBy('submission.assignmentId')
      .getRawMany<{ assignmentId: string; submissionCount: string }>();

    for (const row of submittedAssignments) {
      const assignment = await this.assignmentRepository.findOne({
        where: { id: Number(row.assignmentId) },
      });
      if (!assignment) {
        continue;
      }

      const staffIds = await this.notificationsService.getCourseStaffUserIds(Number(assignment.courseId));
      if (!staffIds.length) {
        continue;
      }

      await this.notificationsService.dispatchScheduledNotifications(
        staffIds,
        {
          notificationType: NotificationType.DEADLINE,
          title: `Pending Assignment Grading: ${assignment.title}`,
          body: `You have ${Number(row.submissionCount)} assignment submissions waiting to be graded.`,
          relatedEntityType: 'assignment',
          relatedEntityId: assignment.id,
          priority: NotificationPriority.MEDIUM,
          actionUrl: `/instructor/courses/${assignment.courseId}/grading`,
        },
        this.atHour(8),
      );
    }
  }

  private async sendLabGradingReminders(): Promise<void> {
    const submittedLabs = await this.labSubmissionRepository
      .createQueryBuilder('submission')
      .innerJoin('submission.lab', 'lab')
      .select('submission.labId', 'labId')
      .addSelect('COUNT(*)', 'submissionCount')
      .where('submission.status = :status', { status: 'submitted' })
      .groupBy('submission.labId')
      .getRawMany<{ labId: string; submissionCount: string }>();

    for (const row of submittedLabs) {
      const lab = await this.labRepository.findOne({
        where: { id: Number(row.labId) },
      });
      if (!lab) {
        continue;
      }

      const staffIds = await this.notificationsService.getCourseStaffUserIds(Number(lab.courseId));
      if (!staffIds.length) {
        continue;
      }

      await this.notificationsService.dispatchScheduledNotifications(
        staffIds,
        {
          notificationType: NotificationType.DEADLINE,
          title: `Pending Lab Grading: ${lab.title}`,
          body: `You have ${Number(row.submissionCount)} lab submissions waiting to be graded.`,
          relatedEntityType: 'lab',
          relatedEntityId: lab.id,
          priority: NotificationPriority.MEDIUM,
          actionUrl: `/instructor/courses/${lab.courseId}/labs/${lab.id}`,
        },
        this.atHour(8),
      );
    }
  }

  private async sendExamTomorrowReminders(): Promise<void> {
    const { start, end } = this.getTomorrowRange();
    const exams = await this.examScheduleRepository.find({
      where: {
        examDate: Between(start.toISOString().slice(0, 10), end.toISOString().slice(0, 10)) as any,
        status: 'scheduled',
      } as any,
      relations: ['course'],
    });

    for (const exam of exams) {
      const studentIds = await this.notificationsService.getEnrolledStudentIds(Number(exam.courseId));
      if (!studentIds.length) {
        continue;
      }

      const examTitle = exam.title || `${exam.examType} exam`;
      await this.notificationsService.dispatchScheduledNotifications(
        studentIds,
        {
          notificationType: NotificationType.SCHEDULE,
          title: `Exam Tomorrow: ${examTitle}`,
          body: `Your ${exam.examType} exam for ${exam.course?.name || 'your course'} is scheduled for tomorrow at ${exam.startTime}.`,
          relatedEntityType: 'exam_schedule',
          relatedEntityId: exam.examId,
          priority: NotificationPriority.URGENT,
          actionUrl: `/exams/schedule/${exam.examId}`,
        },
        this.atHour(9),
      );
    }
  }

  private async sendCampusEventReminders(): Promise<void> {
    const { start, end } = this.getTomorrowRange();
    const events = await this.campusEventRepository.find({
      where: {
        status: CampusEventStatus.PUBLISHED,
        registrationRequired: true as any,
        startDatetime: Between(start, end),
      } as any,
    });

    for (const event of events) {
      const registrantIds = await this.notificationsService.getCampusEventRegistrantIds(Number(event.eventId));
      if (!registrantIds.length) {
        continue;
      }

      await this.notificationsService.dispatchScheduledNotifications(
        registrantIds,
        {
          notificationType: NotificationType.SCHEDULE,
          title: `Campus Event Reminder: ${event.title}`,
          body: `You are registered for "${event.title}", which starts tomorrow.`,
          relatedEntityType: 'campus_event',
          relatedEntityId: event.eventId,
          priority: NotificationPriority.MEDIUM,
          actionUrl: `/campus-events/${event.eventId}`,
        },
        this.atHour(9),
      );
    }
  }
}
