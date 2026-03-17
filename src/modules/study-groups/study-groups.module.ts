import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { StudyGroup } from './entities/study-group.entity';
import { StudyGroupMember } from './entities/study-group-member.entity';
import { StudyGroupsService } from './services/study-groups.service';
import { StudyGroupsController } from './controllers/study-groups.controller';
import { NotificationsModule } from '../notifications/notifications.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([StudyGroup, StudyGroupMember]),
    NotificationsModule,
  ],
  controllers: [StudyGroupsController],
  providers: [StudyGroupsService],
  exports: [StudyGroupsService],
})
export class StudyGroupsModule {}
