import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ScheduleModule } from '@nestjs/schedule';
import { Notification } from './entities/notification.entity';
import { NotificationPreference } from './entities/notification-preference.entity';
import { ScheduledNotification } from './entities/scheduled-notification.entity';
import { NotificationsService } from './services/notifications.service';
import { NotificationCronService } from './services/notification-cron.service';
import { NotificationsController } from './controllers/notifications.controller';
import { NotificationsGateway } from './notifications.gateway';
import { CourseEnrollment } from '../enrollments/entities/course-enrollment.entity';
import { CourseInstructor } from '../enrollments/entities/course-instructor.entity';
import { CourseTA } from '../enrollments/entities/course-ta.entity';
import { User } from '../auth/entities/user.entity';
import { CampusEventRegistration } from '../schedule/entities/campus-event-registration.entity';
import { CourseSchedule } from '../courses/entities/course-schedule.entity';
import { Assignment } from '../assignments/entities/assignment.entity';
import { AssignmentSubmission } from '../assignments/entities/assignment-submission.entity';
import { Lab } from '../labs/entities/lab.entity';
import { LabSubmission } from '../labs/entities/lab-submission.entity';
import { Quiz } from '../quizzes/entities/quiz.entity';
import { QuizAttempt } from '../quizzes/entities/quiz-attempt.entity';
import { ExamSchedule } from '../schedule/entities/exam-schedule.entity';
import { CampusEvent } from '../schedule/entities/campus-event.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      Notification,
      NotificationPreference,
      ScheduledNotification,
      CourseEnrollment,
      CourseInstructor,
      CourseTA,
      User,
      CampusEventRegistration,
      CourseSchedule,
      Assignment,
      AssignmentSubmission,
      Lab,
      LabSubmission,
      Quiz,
      QuizAttempt,
      ExamSchedule,
      CampusEvent,
    ]),
    ScheduleModule.forRoot(),
  ],
  controllers: [NotificationsController],
  providers: [NotificationsService, NotificationsGateway, NotificationCronService],
  exports: [NotificationsService, NotificationsGateway],
})
export class NotificationsModule {}
