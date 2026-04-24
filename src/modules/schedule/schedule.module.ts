import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { NotificationsModule } from '../notifications/notifications.module';

// Entities
import {
  ExamSchedule,
  CalendarEvent,
  CalendarIntegration,
  CampusEvent,
  CampusEventRegistration,
  ScheduleTemplate,
  ScheduleTemplateSlot,
} from './entities';
import { CourseSchedule } from '../courses/entities/course-schedule.entity';

// Controllers
import {
  ScheduleController,
  ExamScheduleController,
  CalendarEventsController,
  CalendarIntegrationsController,
  CampusEventsController,
  ScheduleTemplatesController,
} from './controllers';

// Services
import {
  ScheduleService,
  ExamScheduleService,
  CalendarEventsService,
  CalendarIntegrationsService,
  CampusEventsService,
  ScheduleTemplatesService,
} from './services';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      ExamSchedule,
      CalendarEvent,
      CalendarIntegration,
      CourseSchedule,
      CampusEvent,
      CampusEventRegistration,
      ScheduleTemplate,
      ScheduleTemplateSlot,
    ]),
    NotificationsModule,
  ],
  controllers: [
    ScheduleController,
    ExamScheduleController,
    CalendarEventsController,
    CalendarIntegrationsController,
    CampusEventsController,
    ScheduleTemplatesController,
  ],
  providers: [
    ScheduleService,
    ExamScheduleService,
    CalendarEventsService,
    CalendarIntegrationsService,
    CampusEventsService,
    ScheduleTemplatesService,
  ],
  exports: [
    ScheduleService,
    ExamScheduleService,
    CalendarEventsService,
    CalendarIntegrationsService,
    CampusEventsService,
    ScheduleTemplatesService,
  ],
})
export class ScheduleModule {}
