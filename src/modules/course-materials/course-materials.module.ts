import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

// Entities
import { CourseMaterial, LectureSectionLab } from './entities';
import { File } from '../files/entities/file.entity';

// Controllers
import { MaterialsController, CourseStructureController } from './controllers';

// Services
import { MaterialsService, CourseStructureService } from './services';

// Import YouTube module for video upload functionality
import { YoutubeModule } from '../youtube/youtube.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      CourseMaterial,
      LectureSectionLab,
      File,
    ]),
    YoutubeModule,
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
