import {
  makeQuestionBankService,
  supabaseMock,
} from './question-bank-test-utils';
import {
  BloomLevel,
  QuestionBankDifficulty,
  QuestionBankType,
} from '../enums/question-bank.enums';

jest.mock('@supabase/supabase-js', () => ({
  createClient: jest.fn(() => supabaseMock),
}));

describe('QuestionBank bulk create', () => {
  it('returns row failures without creating invalid rows when chapter data is missing', async () => {
    const dataSource = { transaction: jest.fn() } as any;
    const { service } = makeQuestionBankService({ dataSource });

    const result = await service.bulkCreateQuestions(
      {
        courseId: 1,
        questions: [
          {
            courseId: 1,
            chapterId: undefined as unknown as number,
            questionType: QuestionBankType.WRITTEN,
            difficulty: QuestionBankDifficulty.EASY,
            bloomLevel: BloomLevel.REMEMBERING,
            questionText: 'Question',
            expectedAnswerText: 'Answer',
          },
        ],
      },
      99,
    );

    expect(dataSource.transaction).not.toHaveBeenCalled();
    expect(result.count).toBe(0);
    expect(result.failed).toEqual([
      expect.objectContaining({
        rowIndex: 0,
        message: 'Each question requires chapterId or defaultChapterId',
      }),
    ]);
  });

  it('saves child options inside the bulk create transaction', async () => {
    let nextQuestionId = 200;
    const manager = {
      create: jest.fn((_, value) => value),
      save: jest.fn((value) => {
        if (Array.isArray(value)) {
          return Promise.resolve(value);
        }
        if (value.questionType) {
          return Promise.resolve({ id: nextQuestionId++, ...value });
        }
        return Promise.resolve({ id: 1, ...value });
      }),
      update: jest.fn(),
      delete: jest.fn(),
      restore: jest.fn(),
      findOne: jest.fn().mockResolvedValue({
        id: 200,
        options: [],
        fillBlanks: [],
        attachments: [],
      }),
      createQueryBuilder: jest.fn(() => ({
        select: jest.fn().mockReturnThis(),
        where: jest.fn().mockReturnThis(),
        getRawOne: jest.fn().mockResolvedValue({ maxVersion: '0' }),
      })),
    };
    const dataSource = {
      transaction: jest.fn((callback) => callback(manager)),
    } as any;
    const { service, repos } = makeQuestionBankService({ dataSource });
    repos.chapterRepo.exist.mockResolvedValue(true);
    jest
      .spyOn(service, 'findQuestionById')
      .mockResolvedValue({ id: 200 } as any);

    await service.bulkCreateQuestions(
      {
        courseId: 1,
        questions: [
          {
            courseId: 1,
            chapterId: 2,
            questionType: QuestionBankType.MCQ,
            difficulty: QuestionBankDifficulty.EASY,
            bloomLevel: BloomLevel.REMEMBERING,
            questionText: 'Choose one',
            options: [
              { optionText: 'A', isCorrect: true },
              { optionText: 'B', isCorrect: false },
            ],
          },
        ],
      },
      99,
    );

    expect(manager.save).toHaveBeenCalledWith([
      expect.objectContaining({
        questionId: 200,
        optionText: 'A',
        isCorrect: 1,
        optionOrder: 0,
      }),
      expect.objectContaining({
        questionId: 200,
        optionText: 'B',
        isCorrect: 0,
        optionOrder: 1,
      }),
    ]);
  });
});
