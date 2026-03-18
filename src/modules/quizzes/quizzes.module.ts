import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { QuizzesController } from './controllers/quizzes.controller';
import { QuizzesService, QuizGradingService } from './services';
import { Quiz, QuizQuestion, QuizAttempt, QuizAnswer, QuizDifficultyLevel } from './entities';
import { Course } from '../courses/entities/course.entity';
import { CourseTA } from '../enrollments/entities/course-ta.entity';
import { CourseInstructor } from '../enrollments/entities/course-instructor.entity';

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
    ]),
  ],
  controllers: [QuizzesController],
  providers: [QuizzesService, QuizGradingService],
  exports: [QuizzesService, QuizGradingService],
})
export class QuizzesModule {}
