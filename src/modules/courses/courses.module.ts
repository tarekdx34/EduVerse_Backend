import { Module, forwardRef } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import {
  Course,
  CoursePrerequisite,
  CourseSection,
  CourseSchedule,
} from './entities';
import {
  CoursesService,
  CourseSectionsService,
  CourseSchedulesService,
} from './services';
import {
  CoursesController,
  CourseSectionsController,
} from './controllers';
import { CourseSchedulesController } from './controllers';
import { CampusModule } from '../campus/campus.module';
import { Department } from '../campus/entities/department.entity';
import { Semester } from '../campus/entities/semester.entity';
import { Assignment, AssignmentSubmission } from '../assignments/entities';
import { CourseMaterial } from '../course-materials/entities/course-material.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      Course,
      CoursePrerequisite,
      CourseSection,
      CourseSchedule,
      Department,
      Semester,
      Assignment,
      AssignmentSubmission,
      CourseMaterial,
    ]),
    forwardRef(() => CampusModule),
  ],
  controllers: [
    CoursesController,
    CourseSectionsController,
    CourseSchedulesController,
  ],
  providers: [
    CoursesService,
    CourseSectionsService,
    CourseSchedulesService,
  ],
  exports: [
    CoursesService,
    CourseSectionsService,
    CourseSchedulesService,
  ],
})
export class CoursesModule {}
