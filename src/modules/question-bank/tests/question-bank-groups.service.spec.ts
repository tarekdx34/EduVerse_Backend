import { BadRequestException, ForbiddenException } from '@nestjs/common';
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

describe('QuestionBank groups', () => {
  it('creates course-level groups without requiring a chapter', async () => {
    const { service, repos } = makeQuestionBankService();

    await service.createQuestionGroup(
      {
        courseId: 1,
        title: 'Shared passage',
      },
      99,
    );

    expect(repos.chapterRepo.exist).not.toHaveBeenCalled();
    expect(repos.groupRepo.create).toHaveBeenCalledWith(
      expect.objectContaining({
        courseId: 1,
        title: 'Shared passage',
        sharedPrompt: null,
        sharedFileId: null,
        createdBy: 99,
      }),
    );
  });

  it('uses the same attachable-file security for shared group files', async () => {
    const { service, repos } = makeQuestionBankService();
    repos.chapterRepo.exist.mockResolvedValue(true);
    repos.fileRepo.findOne.mockResolvedValue({
      fileId: 7,
      uploadedBy: 11,
      isPublic: 0,
      mimeType: 'image/png',
    });
    repos.filePermissionRepo.exist.mockResolvedValue(false);

    await expect(
      service.createQuestionGroup(
        {
          courseId: 1,
          chapterId: 2,
          sharedFileId: 7,
        },
        99,
      ),
    ).rejects.toBeInstanceOf(ForbiddenException);
  });

  it('lists groups for instructor-owned courses only', async () => {
    const { service, repos, accessService } = makeQuestionBankService();
    repos.groupRepo.findAndCount.mockResolvedValue([[{ id: 3 }], 1]);

    const result = await service.listQuestionGroups({ courseId: 1 }, 99);

    expect(accessService.assertInstructorOwnsCourse).toHaveBeenCalledWith(
      99,
      1,
    );
    expect(repos.groupRepo.findAndCount).toHaveBeenCalledWith(
      expect.objectContaining({
        relations: ['items', 'sharedFile'],
        skip: 0,
        take: 20,
      }),
    );
    expect(result.total).toBe(1);
  });

  it('soft deletes group metadata without deleting questions', async () => {
    const { service, repos } = makeQuestionBankService();
    repos.groupRepo.findOne.mockResolvedValue({
      id: 3,
      courseId: 1,
      items: [{ questionId: 7 }],
    });

    await service.deleteQuestionGroup(3, 99);

    expect(repos.groupRepo.softDelete).toHaveBeenCalledWith(3);
    expect(repos.questionRepo.delete).not.toHaveBeenCalled();
    expect(repos.questionRepo.remove).not.toHaveBeenCalled();
  });

  it('includes group metadata in private question responses', () => {
    const { service } = makeQuestionBankService();

    const response = service.toPrivateResponse({
      id: 10,
      courseId: 1,
      chapterId: 2,
      questionType: 'written',
      difficulty: 'easy',
      bloomLevel: 'remembering',
      status: 'draft',
      questionText: 'Question',
      expectedAnswerText: 'Answer',
      hints: null,
      options: [],
      fillBlanks: [],
      attachments: [],
      groupItems: [
        {
          id: 5,
          groupId: 3,
          itemOrder: 2,
          group: {
            courseId: 1,
            chapterId: 2,
            title: 'Case',
            sharedPrompt: 'Read this',
            sharedFileId: 8,
            groupType: 'case_study',
          },
        },
      ],
    } as any);

    expect(response.groups).toEqual([
      expect.objectContaining({
        groupItemId: 5,
        groupId: 3,
        title: 'Case',
        sharedFileId: 8,
        groupType: 'case_study',
      }),
    ]);
  });

  it('saves child rows when creating questions inside a group', async () => {
    let nextQuestionId = 300;
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
      query: jest
        .fn()
        .mockResolvedValueOnce([])
        .mockResolvedValueOnce([{ maxOrder: -1 }]),
      findOne: jest.fn().mockResolvedValue({
        id: 300,
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
    repos.groupRepo.findOne.mockResolvedValue({
      id: 5,
      courseId: 1,
      chapterId: 2,
      items: [],
    });
    repos.chapterRepo.exist.mockResolvedValue(true);
    jest
      .spyOn(service, 'findQuestionById')
      .mockResolvedValue({ id: 300 } as any);

    await service.addGroupedQuestions(
      5,
      {
        questions: [
          {
            courseId: 1,
            chapterId: 2,
            questionType: QuestionBankType.FILL_BLANKS,
            difficulty: QuestionBankDifficulty.EASY,
            bloomLevel: BloomLevel.REMEMBERING,
            questionText: 'Fill [term]',
            fillBlanks: [
              {
                blankKey: 'term',
                acceptableAnswer: 'Answer',
                isCaseSensitive: false,
              },
            ],
          },
        ],
      },
      99,
    );

    expect(manager.save).toHaveBeenCalledWith([
      expect.objectContaining({
        questionId: 300,
        blankKey: 'term',
        acceptableAnswer: 'Answer',
        isCaseSensitive: 0,
      }),
    ]);
  });

  it('appends grouped questions after existing item order', async () => {
    let nextQuestionId = 400;
    const versionBuilder = {
      select: jest.fn().mockReturnThis(),
      where: jest.fn().mockReturnThis(),
      getRawOne: jest.fn().mockResolvedValue({ maxVersion: '0' }),
    };
    const manager = {
      create: jest.fn((_, value) => value),
      save: jest.fn((value) => {
        if (value.questionType) {
          return Promise.resolve({ id: nextQuestionId++, ...value });
        }
        return Promise.resolve({ id: 1, ...value });
      }),
      update: jest.fn(),
      delete: jest.fn(),
      restore: jest.fn(),
      query: jest
        .fn()
        .mockResolvedValueOnce([])
        .mockResolvedValueOnce([{ maxOrder: '2' }]),
      findOne: jest.fn().mockResolvedValue({
        id: 400,
        options: [],
        fillBlanks: [],
        attachments: [],
      }),
      createQueryBuilder: jest.fn().mockReturnValue(versionBuilder),
    };
    const dataSource = {
      transaction: jest.fn((callback) => callback(manager)),
    } as any;
    const { service, repos } = makeQuestionBankService({ dataSource });
    repos.groupRepo.findOne.mockResolvedValue({
      id: 5,
      courseId: 1,
      chapterId: 2,
      items: [{ questionId: 7, itemOrder: 0 }],
    });
    repos.chapterRepo.exist.mockResolvedValue(true);
    jest
      .spyOn(service, 'findQuestionById')
      .mockResolvedValue({ id: 400 } as any);

    await service.addGroupedQuestions(
      5,
      {
        questions: [
          {
            courseId: 1,
            chapterId: 2,
            questionType: QuestionBankType.MCQ,
            difficulty: QuestionBankDifficulty.EASY,
            bloomLevel: BloomLevel.REMEMBERING,
            questionText: 'Choose',
            options: [
              { optionText: 'A', isCorrect: true },
              { optionText: 'B', isCorrect: false },
            ],
          },
        ],
      },
      99,
    );

    expect(manager.save).toHaveBeenCalledWith(
      expect.objectContaining({
        groupId: 5,
        questionId: 400,
        itemOrder: 3,
      }),
    );
  });

  it('rejects grouped questionFileId when the file is not owned or shared', async () => {
    const { service, repos } = makeQuestionBankService();
    repos.groupRepo.findOne.mockResolvedValue({
      id: 5,
      courseId: 1,
      chapterId: 2,
      items: [],
    });
    repos.chapterRepo.exist.mockResolvedValue(true);
    repos.fileRepo.findOne.mockResolvedValue({
      fileId: 44,
      uploadedBy: 22,
      isPublic: 0,
      mimeType: 'image/png',
    });
    repos.filePermissionRepo.exist.mockResolvedValue(false);

    await expect(
      service.addGroupedQuestions(
        5,
        {
          questions: [
            {
              courseId: 1,
              chapterId: 2,
              questionFileId: 44,
              questionType: QuestionBankType.WRITTEN,
              difficulty: QuestionBankDifficulty.EASY,
              bloomLevel: BloomLevel.REMEMBERING,
              expectedAnswerText: 'Expected',
            },
          ],
        },
        99,
      ),
    ).rejects.toBeInstanceOf(ForbiddenException);
  });

  it('rejects non-image grouped questionFileId files', async () => {
    const { service, repos } = makeQuestionBankService();
    repos.groupRepo.findOne.mockResolvedValue({
      id: 5,
      courseId: 1,
      chapterId: 2,
      items: [],
    });
    repos.chapterRepo.exist.mockResolvedValue(true);
    repos.fileRepo.findOne.mockResolvedValue({
      fileId: 45,
      uploadedBy: 99,
      isPublic: 0,
      mimeType: 'application/pdf',
    });

    await expect(
      service.addGroupedQuestions(
        5,
        {
          questions: [
            {
              courseId: 1,
              chapterId: 2,
              questionFileId: 45,
              questionType: QuestionBankType.WRITTEN,
              difficulty: QuestionBankDifficulty.EASY,
              bloomLevel: BloomLevel.REMEMBERING,
              expectedAnswerText: 'Expected',
            },
          ],
        },
        99,
      ),
    ).rejects.toBeInstanceOf(BadRequestException);
  });

  it('requires every grouped question to choose its own chapter', async () => {
    const { service, repos } = makeQuestionBankService();
    repos.groupRepo.findOne.mockResolvedValue({
      id: 5,
      courseId: 1,
      chapterId: null,
      items: [],
    });

    await expect(
      service.addGroupedQuestions(
        5,
        {
          questions: [
            {
              courseId: 1,
              questionType: QuestionBankType.WRITTEN,
              difficulty: QuestionBankDifficulty.EASY,
              bloomLevel: BloomLevel.REMEMBERING,
              questionText: 'Explain',
              expectedAnswerText: 'Expected',
            },
          ],
        },
        99,
      ),
    ).rejects.toBeInstanceOf(BadRequestException);
  });
});
