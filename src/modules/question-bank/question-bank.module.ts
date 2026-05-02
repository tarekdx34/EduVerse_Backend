import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Course } from '../courses/entities/course.entity';
import { FilesModule } from '../files/files.module';
import { File } from '../files/entities/file.entity';
import { CourseChapter } from './entities/course-chapter.entity';
import { QuestionBankFillBlank } from './entities/question-bank-fill-blank.entity';
import { QuestionBankOption } from './entities/question-bank-option.entity';
import { QuestionBankQuestion } from './entities/question-bank-question.entity';
import { QuestionBankController } from './question-bank.controller';
import { QuestionBankService } from './question-bank.service';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      Course,
      File,
      CourseChapter,
      QuestionBankQuestion,
      QuestionBankOption,
      QuestionBankFillBlank,
    ]),
    FilesModule,
  ],
  controllers: [QuestionBankController],
  providers: [QuestionBankService],
  exports: [QuestionBankService],
})
export class QuestionBankModule {}
