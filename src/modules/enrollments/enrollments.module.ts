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
    ]),
    forwardRef(() => CoursesModule),
  ],
  controllers: [EnrollmentsController],
  providers: [EnrollmentsService],
  exports: [EnrollmentsService],
})
export class EnrollmentsModule {}
