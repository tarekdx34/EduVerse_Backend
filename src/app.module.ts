import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AuthModule } from './modules/auth/auth.module';
import { EmailModule } from './modules/email/email.module';
import { CampusModule } from './modules/campus/campus.module';
import { CoursesModule } from './modules/courses/courses.module';
import { EnrollmentsModule } from './modules/enrollments/enrollments.module';
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
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
