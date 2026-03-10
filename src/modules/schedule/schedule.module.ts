import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

// Entities
import { ExamSchedule, CalendarEvent, CalendarIntegration } from './entities';
import { CourseSchedule } from '../courses/entities/course-schedule.entity';

// Controllers
import {
  ScheduleController,
  ExamScheduleController,
  CalendarEventsController,
  CalendarIntegrationsController,
} from './controllers';

// Services
import {
  ScheduleService,
  ExamScheduleService,
  CalendarEventsService,
  CalendarIntegrationsService,
} from './services';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      ExamSchedule,
      CalendarEvent,
      CalendarIntegration,
      CourseSchedule,
    ]),
  ],
  controllers: [
    ScheduleController,
    ExamScheduleController,
    CalendarEventsController,
    CalendarIntegrationsController,
  ],
  providers: [
    ScheduleService,
    ExamScheduleService,
    CalendarEventsService,
    CalendarIntegrationsService,
  ],
  exports: [
    ScheduleService,
    ExamScheduleService,
    CalendarEventsService,
    CalendarIntegrationsService,
  ],
})
export class ScheduleModule {}
