import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AuthModule } from './modules/auth/auth.module';
import { EmailModule } from './modules/email/email.module';
import { CampusModule } from './modules/campus/campus.module';
import { CoursesModule } from './modules/courses/courses.module';
import { EnrollmentsModule } from './modules/enrollments/enrollments.module';
import { FilesModule } from './modules/files/files.module';
import { AssignmentsModule } from './modules/assignments/assignments.module';
import { GradesModule } from './modules/grades/grades.module';
import { AttendanceModule } from './modules/attendance/attendance.module';
import { QuizzesModule } from './modules/quizzes/quizzes.module';
import { LabsModule } from './modules/labs/labs.module';
import { NotificationsModule } from './modules/notifications/notifications.module';
import { MessagingModule } from './modules/messaging/messaging.module';
import { DiscussionsModule } from './modules/discussions/discussions.module';
import { AnnouncementsModule } from './modules/announcements/announcements.module';
import { CommunityModule } from './modules/community/community.module';
import { ScheduleModule } from './modules/schedule/schedule.module';
import { CourseMaterialsModule } from './modules/course-materials/course-materials.module';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import databaseConfig from './config/database.config';
import { YoutubeModule } from './modules/youtube/youtube.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      load: [databaseConfig],
      envFilePath: '.env',
    }),
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (configService: ConfigService) => {
        const dbConfig = configService.get('database');

        if (!dbConfig) {
          throw new Error('Database configuration is missing');
        }

        return {
          type: 'mysql',
          host: dbConfig.host,
          port: dbConfig.port,
          username: dbConfig.username,
          password: dbConfig.password,
          database: dbConfig.database,
          entities: [__dirname + '/**/*.entity{.ts,.js}'],
          synchronize: dbConfig.synchronize,
          logging: dbConfig.logging,
        };
      },
    }),
    AuthModule,
    EmailModule,
    CampusModule,
    CoursesModule,
    EnrollmentsModule,
    YoutubeModule,
    FilesModule,
    AssignmentsModule,
    GradesModule,
    AttendanceModule,
    QuizzesModule,
    LabsModule,
    NotificationsModule,
    MessagingModule,
    DiscussionsModule,
    AnnouncementsModule,
    CommunityModule,
    ScheduleModule,
    CourseMaterialsModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
