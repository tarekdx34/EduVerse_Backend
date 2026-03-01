import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { QuizzesController } from './controllers/quizzes.controller';
import { QuizzesService, QuizGradingService } from './services';
import { Quiz, QuizQuestion, QuizAttempt, QuizAnswer, QuizDifficultyLevel } from './entities';
import { Course } from '../courses/entities/course.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      Quiz,
      QuizQuestion,
      QuizAttempt,
      QuizAnswer,
      QuizDifficultyLevel,
      Course,
    ]),
  ],
  controllers: [QuizzesController],
  providers: [QuizzesService, QuizGradingService],
  exports: [QuizzesService, QuizGradingService],
})
export class QuizzesModule {}
