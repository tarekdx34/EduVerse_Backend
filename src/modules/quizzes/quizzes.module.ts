import { Module, forwardRef } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { QuizzesController } from './controllers/quizzes.controller';
import { QuizzesService, QuizGradingService } from './services';
import { Quiz, QuizQuestion, QuizAttempt, QuizAnswer, QuizDifficultyLevel } from './entities';
import { Course } from '../courses/entities/course.entity';
import { CourseTA } from '../enrollments/entities/course-ta.entity';
import { CourseInstructor } from '../enrollments/entities/course-instructor.entity';
import { AuthModule } from '../auth/auth.module';
import { GradesModule } from '../grades/grades.module';
import { NotificationsModule } from '../notifications/notifications.module';
import { CourseEnrollment } from '../enrollments/entities/course-enrollment.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      Quiz,
      QuizQuestion,
      QuizAttempt,
      QuizAnswer,
      QuizDifficultyLevel,
      Course,
      CourseTA,
      CourseInstructor,
      CourseEnrollment,
    ]),
    AuthModule,
    forwardRef(() => GradesModule),
    NotificationsModule,
  ],
  controllers: [QuizzesController],
  providers: [QuizzesService, QuizGradingService],
  exports: [QuizzesService, QuizGradingService],
})
export class QuizzesModule {}
