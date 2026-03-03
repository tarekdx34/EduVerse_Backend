import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Lab } from './entities/lab.entity';
import { LabSubmission } from './entities/lab-submission.entity';
import { LabInstruction } from './entities/lab-instruction.entity';
import { LabAttendance } from './entities/lab-attendance.entity';
import { LabsService } from './services/labs.service';
import { LabsController } from './controllers/labs.controller';

@Module({
  imports: [
    TypeOrmModule.forFeature([Lab, LabSubmission, LabInstruction, LabAttendance]),
  ],
  controllers: [LabsController],
  providers: [LabsService],
  exports: [LabsService],
})
export class LabsModule {}
