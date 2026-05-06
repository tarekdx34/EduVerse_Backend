import { BadRequestException } from '@nestjs/common';
import {
  BloomLevel,
  QuestionBankDifficulty,
  QuestionBankType,
} from '../../question-bank/enums/question-bank.enums';
import { ExamDraftStatus } from '../entities/exam-draft.entity';
import { makeExamsService } from './exams-test-utils';

describe('Exam draft items', () => {
  it('requires full item list for reorder', async () => {
    const { service, repos } = makeExamsService();
    repos.draftRepo.findOne.mockResolvedValue({
      id: 1,
      courseId: 10,
      status: ExamDraftStatus.OPEN,
      expiresAt: new Date(Date.now() + 60_000),
      items: [{ id: 1 }, { id: 2 }],
      sections: [],
    });
    repos.draftItemRepo.find.mockResolvedValue([{ id: 1 }, { id: 2 }]);

    await expect(
      service.reorderDraftItems(1, { items: [{ itemId: 1, itemOrder: 0 }] }, 99),
    ).rejects.toBeInstanceOf(BadRequestException);
  });

  it('allows replacement outside original constraints only with override reason', () => {
    const { service } = makeExamsService();
    const draft = {
      id: 1,
      sections: [],
      generationRequestJson: {
        rules: [
          {
            chapterId: 1,
            count: 1,
            weightPerQuestion: 1,
            questionType: QuestionBankType.MCQ,
          },
        ],
      },
    };
    const question = {
      id: 10,
      chapterId: 2,
      questionType: QuestionBankType.WRITTEN,
      difficulty: QuestionBankDifficulty.EASY,
      bloomLevel: BloomLevel.REMEMBERING,
    };

    expect(() =>
      (service as any).assertQuestionMatchesDraftGeneration(
        draft,
        question,
        null,
        'Instructor selected this manually',
      ),
    ).not.toThrow();
  });
});
