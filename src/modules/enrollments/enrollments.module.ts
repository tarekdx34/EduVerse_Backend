import { Module, forwardRef } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import {
  CourseEnrollment,
  CourseInstructor,
  CourseTA,
} from './entities';
import { EnrollmentsService } from './services';
import { EnrollmentsController } from './controllers';
import { Course } from '../courses/entities/course.entity';
import { CourseSection } from '../courses/entities/course-section.entity';
import { CourseSchedule } from '../courses/entities/course-schedule.entity';
import { CoursePrerequisite } from '../courses/entities/course-prerequisite.entity';
import { User } from '../auth/entities/user.entity';
import { Semester } from '../campus/entities/semester.entity';
import { Program } from '../campus/entities/program.entity';
import { CoursesModule } from '../courses/courses.module';
import { StudentProgress } from '../analytics/entities/student-progress.entity';
import { NotificationsModule } from '../notifications/notifications.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      CourseEnrollment,
      CourseInstructor,
      CourseTA,
      Course,
      CourseSection,
      CourseSchedule,
      CoursePrerequisite,
      User,
      Semester,
      Program,
      StudentProgress,
    ]),
    forwardRef(() => CoursesModule),
    NotificationsModule,
  ],
  controllers: [EnrollmentsController],
  providers: [EnrollmentsService],
  exports: [EnrollmentsService],
})
export class EnrollmentsModule {}
