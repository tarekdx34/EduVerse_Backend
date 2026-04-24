import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

// Entities
import {
  CourseMaterial,
  LectureSectionLab,
  StudentMaterialView,
} from './entities';
import { File } from '../files/entities/file.entity';
import { CourseEnrollment } from '../enrollments/entities/course-enrollment.entity';
import { StudentProgress } from '../analytics/entities/student-progress.entity';

// Controllers
import { MaterialsController, CourseStructureController } from './controllers';

// Services
import { MaterialsService, CourseStructureService } from './services';

// Import YouTube module for video upload functionality
import { YoutubeModule } from '../youtube/youtube.module';

// Import Google Drive module for document upload functionality
import { GoogleDriveModule } from '../google-drive/google-drive.module';

// Import Notifications module
import { NotificationsModule } from '../notifications/notifications.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      CourseMaterial,
      LectureSectionLab,
      StudentMaterialView,
      File,
      CourseEnrollment,
      StudentProgress,
    ]),
    YoutubeModule,
    GoogleDriveModule,
    NotificationsModule,
  ],
  controllers: [
    MaterialsController,
    CourseStructureController,
  ],
  providers: [
    MaterialsService,
    CourseStructureService,
  ],
  exports: [
    MaterialsService,
    CourseStructureService,
  ],
})
export class CourseMaterialsModule {}
