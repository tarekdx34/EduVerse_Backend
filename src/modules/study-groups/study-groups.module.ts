import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { StudyGroup } from './entities/study-group.entity';
import { StudyGroupMember } from './entities/study-group-member.entity';
import { StudyGroupsService } from './services/study-groups.service';
import { StudyGroupsController } from './controllers/study-groups.controller';

@Module({
  imports: [
    TypeOrmModule.forFeature([StudyGroup, StudyGroupMember]),
  ],
  controllers: [StudyGroupsController],
  providers: [StudyGroupsService],
  exports: [StudyGroupsService],
})
export class StudyGroupsModule {}
