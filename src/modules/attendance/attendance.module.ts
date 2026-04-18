import { Module, forwardRef } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ConfigModule } from '@nestjs/config';
import {
  AttendanceSession,
  AttendanceRecord,
  AttendancePhoto,
  AiAttendanceProcessing,
  StudentFaceReference,
} from './entities';
import {
  AttendanceService,
  AttendanceExcelService,
  AttendanceAiService,
  StudentFaceReferenceService,
} from './services';
import { AttendanceController } from './controllers';
import { CourseSection } from '../courses/entities/course-section.entity';
import { CourseEnrollment } from '../enrollments/entities/course-enrollment.entity';
import { User } from '../auth/entities/user.entity';
import { CoursesModule } from '../courses/courses.module';
import { EnrollmentsModule } from '../enrollments/enrollments.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      AttendanceSession,
      AttendanceRecord,
      AttendancePhoto,
      AiAttendanceProcessing,
      StudentFaceReference,
      CourseSection,
      CourseEnrollment,
      User,
    ]),
    ConfigModule,
    forwardRef(() => CoursesModule),
    forwardRef(() => EnrollmentsModule),
  ],
  controllers: [AttendanceController],
  providers: [
    AttendanceService,
    AttendanceExcelService,
    AttendanceAiService,
    StudentFaceReferenceService,
  ],
  exports: [AttendanceService],
})
export class AttendanceModule {}
