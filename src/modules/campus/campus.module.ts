import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Campus } from './entities/campus.entity';
import { Department } from './entities/department.entity';
import { Program } from './entities/program.entity';
import { Semester } from './entities/semester.entity';
import { User } from '../auth/entities/user.entity';
import { CampusService } from './services/campus.service';
import { DepartmentService } from './services/department.service';
import { ProgramService } from './services/program.service';
import { SemesterService } from './services/semester.service';
import { CampusController } from './controllers/campus.controller';
import { DepartmentController } from './controllers/department.controller';
import { ProgramController } from './controllers/program.controller';
import { SemesterController } from './controllers/semester.controller';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      Campus,
      Department,
      Program,
      Semester,
      User,
    ]),
  ],
  controllers: [
    CampusController,
    DepartmentController,
    ProgramController,
    SemesterController,
  ],
  providers: [
    CampusService,
    DepartmentService,
    ProgramService,
    SemesterService,
  ],
  exports: [
    CampusService,
    DepartmentService,
    ProgramService,
    SemesterService,
  ],
})
export class CampusModule {}
