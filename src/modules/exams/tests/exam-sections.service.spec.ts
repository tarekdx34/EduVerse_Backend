import { BadRequestException } from '@nestjs/common';
import {
  BloomLevel,
  QuestionBankDifficulty,
  QuestionBankType,
} from '../../question-bank/enums/question-bank.enums';
import { makeExamsService } from './exams-test-utils';

describe('Exam sections', () => {
  it('requires override reason when section question violates generation rules', () => {
    const { service } = makeExamsService();
    const draft = {
      id: 1,
      sections: [{ id: 3, sectionOrder: 0 }],
      generationRequestJson: {
        sections: [
          {
            rules: [
              {
                chapterId: 1,
                count: 1,
                weightPerQuestion: 1,
                questionType: QuestionBankType.MCQ,
              },
            ],
          },
        ],
      },
    };
    const question = {
      id: 9,
      chapterId: 2,
      questionType: QuestionBankType.WRITTEN,
      difficulty: QuestionBankDifficulty.EASY,
      bloomLevel: BloomLevel.REMEMBERING,
    };

    expect(() =>
      (service as any).assertQuestionMatchesDraftGeneration(
        draft,
        question,
        3,
      ),
    ).toThrow(BadRequestException);
  });
});
