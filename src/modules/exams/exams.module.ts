import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { CourseSection } from '../courses/entities/course-section.entity';
import { Course } from '../courses/entities/course.entity';
import { CourseInstructor } from '../enrollments/entities/course-instructor.entity';
import { FilesModule } from '../files/files.module';
import { QuestionBankFillBlank } from '../question-bank/entities/question-bank-fill-blank.entity';
import { QuestionBankOption } from '../question-bank/entities/question-bank-option.entity';
import { QuestionBankQuestionAttachment } from '../question-bank/entities/question-bank-question-attachment.entity';
import { QuestionBankQuestionVersion } from '../question-bank/entities/question-bank-question-version.entity';
import { QuestionBankQuestionGroup } from '../question-bank/entities/question-bank-question-group.entity';
import { QuestionBankQuestionGroupItem } from '../question-bank/entities/question-bank-question-group-item.entity';
import { CourseChapter } from '../question-bank/entities/course-chapter.entity';
import { QuestionBankQuestion } from '../question-bank/entities/question-bank-question.entity';
import { InstructorCourseAccessService } from '../question-bank/services/instructor-course-access.service';
import { ExamDraftsController } from './exam-drafts.controller';
import { ExamDraftCleanupService } from './exam-draft-cleanup.service';
import { ExamsController } from './exams.controller';
import { ExamsService } from './exams.service';
import { ExamDraftItem } from './entities/exam-draft-item.entity';
import { ExamDraftSection } from './entities/exam-draft-section.entity';
import { ExamDraft } from './entities/exam-draft.entity';
import { ExamExport } from './entities/exam-export.entity';
import { ExamItemSnapshot } from './entities/exam-item-snapshot.entity';
import { ExamItem } from './entities/exam-item.entity';
import { ExamPaperTemplate } from './entities/exam-paper-template.entity';
import { ExamSection } from './entities/exam-section.entity';
import { Exam } from './entities/exam.entity';

@Module({
  imports: [
    FilesModule,
    TypeOrmModule.forFeature([
      Course,
      CourseSection,
      CourseInstructor,
      CourseChapter,
      QuestionBankQuestion,
      QuestionBankOption,
      QuestionBankFillBlank,
      QuestionBankQuestionAttachment,
      QuestionBankQuestionVersion,
      QuestionBankQuestionGroup,
      QuestionBankQuestionGroupItem,
      ExamDraft,
      ExamDraftItem,
      ExamDraftSection,
      Exam,
      ExamItem,
      ExamSection,
      ExamItemSnapshot,
      ExamExport,
      ExamPaperTemplate,
    ]),
  ],
  controllers: [ExamsController, ExamDraftsController],
  providers: [ExamsService, ExamDraftCleanupService, InstructorCourseAccessService],
  exports: [ExamsService],
})
export class ExamsModule {}
