import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { CourseSection } from '../courses/entities/course-section.entity';
import { Course } from '../courses/entities/course.entity';
import { CourseInstructor } from '../enrollments/entities/course-instructor.entity';
import { FilesModule } from '../files/files.module';
import { FilePermission } from '../files/entities/file-permission.entity';
import { File } from '../files/entities/file.entity';
import { CourseChapter } from './entities/course-chapter.entity';
import { QuestionBankFillBlank } from './entities/question-bank-fill-blank.entity';
import { QuestionBankOption } from './entities/question-bank-option.entity';
import { QuestionBankQuestionAttachment } from './entities/question-bank-question-attachment.entity';
import { QuestionBankQuestionGroupItem } from './entities/question-bank-question-group-item.entity';
import { QuestionBankQuestionGroup } from './entities/question-bank-question-group.entity';
import { QuestionBankQuestionVersion } from './entities/question-bank-question-version.entity';
import { QuestionBankQuestion } from './entities/question-bank-question.entity';
import { QuestionBankReviewEvent } from './entities/question-bank-review-event.entity';
import { QuestionBankController } from './question-bank.controller';
import { QuestionBankCleanupService } from './question-bank-cleanup.service';
import { QuestionBankService } from './question-bank.service';
import { InstructorCourseAccessService } from './services/instructor-course-access.service';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      Course,
      CourseSection,
      CourseInstructor,
      File,
      FilePermission,
      CourseChapter,
      QuestionBankQuestion,
      QuestionBankOption,
      QuestionBankFillBlank,
      QuestionBankQuestionAttachment,
      QuestionBankQuestionGroup,
      QuestionBankQuestionGroupItem,
      QuestionBankQuestionVersion,
      QuestionBankReviewEvent,
    ]),
    FilesModule,
  ],
  controllers: [QuestionBankController],
  providers: [
    QuestionBankService,
    QuestionBankCleanupService,
    InstructorCourseAccessService,
  ],
  exports: [QuestionBankService, InstructorCourseAccessService],
})
export class QuestionBankModule {}
