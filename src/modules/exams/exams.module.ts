import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Course } from '../courses/entities/course.entity';
import { CourseChapter } from '../question-bank/entities/course-chapter.entity';
import { QuestionBankQuestion } from '../question-bank/entities/question-bank-question.entity';
import { ExamsController } from './exams.controller';
import { ExamsService } from './exams.service';
import { ExamDraftItem } from './entities/exam-draft-item.entity';
import { ExamDraft } from './entities/exam-draft.entity';
import { ExamItem } from './entities/exam-item.entity';
import { Exam } from './entities/exam.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      Course,
      CourseChapter,
      QuestionBankQuestion,
      ExamDraft,
      ExamDraftItem,
      Exam,
      ExamItem,
    ]),
  ],
  controllers: [ExamsController],
  providers: [ExamsService],
  exports: [ExamsService],
})
export class ExamsModule {}

