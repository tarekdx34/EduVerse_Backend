import { Module, forwardRef } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Lab } from './entities/lab.entity';
import { LabSubmission } from './entities/lab-submission.entity';
import { LabInstruction } from './entities/lab-instruction.entity';
import { LabAttendance } from './entities/lab-attendance.entity';
import { LabsService } from './services/labs.service';
import { LabsController } from './controllers/labs.controller';
import { GoogleDriveModule } from '../google-drive/google-drive.module';
import { DriveFile } from '../google-drive/entities/drive-file.entity';
import { GradesModule } from '../grades/grades.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([Lab, LabSubmission, LabInstruction, LabAttendance, DriveFile]),
    GoogleDriveModule,
    forwardRef(() => GradesModule),
  ],
  controllers: [LabsController],
  providers: [LabsService],
  exports: [LabsService],
})
export class LabsModule {}
