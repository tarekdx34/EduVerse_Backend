import { Module, forwardRef } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Grade, GradeComponent, Rubric, RubricCriteria, GpaCalculation } from './entities';
import { GradesService, RubricsService } from './services';
import { GradesController, RubricsController } from './controllers';
import { Course } from '../courses/entities/course.entity';
import { CourseEnrollment } from '../enrollments/entities/course-enrollment.entity';
import { User } from '../auth/entities/user.entity';
import { Semester } from '../campus/entities/semester.entity';
import { Assignment } from '../assignments/entities/assignment.entity';
import { CoursesModule } from '../courses/courses.module';
import { EnrollmentsModule } from '../enrollments/enrollments.module';
import { NotificationsModule } from '../notifications/notifications.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      Grade,
      GradeComponent,
      Rubric,
      RubricCriteria,
      GpaCalculation,
      Course,
      CourseEnrollment,
      User,
      Semester,
      Assignment,
    ]),
    forwardRef(() => CoursesModule),
    forwardRef(() => EnrollmentsModule),
    NotificationsModule,
  ],
  controllers: [GradesController, RubricsController],
  providers: [GradesService, RubricsService],
  exports: [GradesService, RubricsService],
})
export class GradesModule {}
