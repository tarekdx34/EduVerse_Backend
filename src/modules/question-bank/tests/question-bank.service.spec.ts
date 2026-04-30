import { BadRequestException } from '@nestjs/common';
import { QuestionBankService } from '../question-bank.service';

describe('QuestionBankService', () => {
  const makeRepo = () =>
    ({
      exist: jest.fn(),
      findOne: jest.fn(),
      save: jest.fn((value) => Promise.resolve({ id: 1, ...value })),
      create: jest.fn((value) => value),
      delete: jest.fn(),
      remove: jest.fn(),
      createQueryBuilder: jest.fn(),
    }) as any;

  it('rejects question creation without text and file', async () => {
    const courseRepo = makeRepo();
    courseRepo.exist.mockResolvedValue(true);
    const chapterRepo = makeRepo();
    chapterRepo.exist.mockResolvedValue(true);

    const service = new QuestionBankService(
      chapterRepo,
      makeRepo(),
      makeRepo(),
      makeRepo(),
      courseRepo,
      makeRepo(),
    );

    await expect(
      service.createQuestion(
        {
          courseId: 1,
          chapterId: 1,
          questionType: 'written' as any,
          difficulty: 'easy' as any,
          bloomLevel: 'remembering' as any,
          expectedAnswerText: 'Answer',
        },
        1,
      ),
    ).rejects.toBeInstanceOf(BadRequestException);
  });
});

