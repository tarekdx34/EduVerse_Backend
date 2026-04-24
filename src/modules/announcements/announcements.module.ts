import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Announcement } from './entities/announcement.entity';
import { AnnouncementsController } from './controllers/announcements.controller';
import { AnnouncementsService } from './services/announcements.service';
import { CourseEnrollment } from '../enrollments/entities/course-enrollment.entity';
import { CourseInstructor } from '../enrollments/entities/course-instructor.entity';
import { CourseTA } from '../enrollments/entities/course-ta.entity';
import { CourseSection } from '../courses/entities/course-section.entity';
import { NotificationsModule } from '../notifications/notifications.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      Announcement,
      CourseEnrollment,
      CourseInstructor,
      CourseTA,
      CourseSection,
    ]),
    NotificationsModule,
  ],
  controllers: [AnnouncementsController],
  providers: [AnnouncementsService],
  exports: [AnnouncementsService],
})
export class AnnouncementsModule {}
