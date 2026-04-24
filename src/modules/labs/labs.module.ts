import { Module, forwardRef } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Lab } from './entities/lab.entity';
import { LabSubmission } from './entities/lab-submission.entity';
import { LabInstruction } from './entities/lab-instruction.entity';
import { LabAttendance } from './entities/lab-attendance.entity';
import { CourseSection } from '../courses/entities/course-section.entity';
import { CourseEnrollment } from '../enrollments/entities/course-enrollment.entity';
import { LabsService } from './services/labs.service';
import { LabsController } from './controllers/labs.controller';
import { GoogleDriveModule } from '../google-drive/google-drive.module';
import { DriveFile } from '../google-drive/entities/drive-file.entity';
import { GradesModule } from '../grades/grades.module';
import { NotificationsModule } from '../notifications/notifications.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([Lab, LabSubmission, LabInstruction, LabAttendance, DriveFile, CourseSection, CourseEnrollment]),
    GoogleDriveModule,
    forwardRef(() => GradesModule),
    NotificationsModule,
  ],
  controllers: [LabsController],
  providers: [LabsService],
  exports: [LabsService],
})
export class LabsModule {}
