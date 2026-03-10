import { Module, forwardRef } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Assignment, AssignmentSubmission } from './entities';
import { AssignmentsService } from './services';
import { AssignmentsController } from './controllers';
import { Course } from '../courses/entities/course.entity';
import { CourseSection } from '../courses/entities/course-section.entity';
import { CourseEnrollment } from '../enrollments/entities/course-enrollment.entity';
import { User } from '../auth/entities/user.entity';
import { CoursesModule } from '../courses/courses.module';
import { EnrollmentsModule } from '../enrollments/enrollments.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      Assignment,
      AssignmentSubmission,
      Course,
      CourseSection,
      CourseEnrollment,
      User,
    ]),
    forwardRef(() => CoursesModule),
    forwardRef(() => EnrollmentsModule),
  ],
  controllers: [AssignmentsController],
  providers: [AssignmentsService],
  exports: [AssignmentsService],
})
export class AssignmentsModule {}
