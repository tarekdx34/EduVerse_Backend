import { BadRequestException } from '@nestjs/common';
import { QuestionBankService } from '../question-bank.service';

const supabaseMock = {
  storage: {
    listBuckets: jest.fn().mockResolvedValue({
      data: [{ id: 'question-images', name: 'question-images' }],
      error: null,
    }),
    from: jest.fn().mockReturnValue({
      upload: jest.fn().mockResolvedValue({ error: null }),
      createSignedUrls: jest.fn().mockResolvedValue({
        data: [{ path: 'question-bank/files/88.png', signedUrl: 'signed-url' }],
        error: null,
      }),
      getPublicUrl: jest.fn().mockReturnValue({
        data: { publicUrl: 'public-url' },
      }),
    }),
  },
};

jest.mock('@supabase/supabase-js', () => ({
  createClient: jest.fn(() => supabaseMock),
}));

describe('QuestionBankService', () => {
  const makeRepo = () =>
    ({
      exist: jest.fn(),
      findOne: jest.fn(),
      findOneByOrFail: jest.fn(),
      save: jest.fn((value) => Promise.resolve({ id: 1, ...value })),
      create: jest.fn((value) => value),
      delete: jest.fn(),
      remove: jest.fn(),
      update: jest.fn(),
      softDelete: jest.fn(),
      restore: jest.fn(),
      count: jest.fn(),
      createQueryBuilder: jest.fn(),
    }) as any;

  const makeFilesService = () =>
    ({
      uploadFile: jest.fn(),
      deleteFile: jest.fn(),
    }) as any;

  const makeConfigService = () =>
    ({
      get: jest.fn((key: string) => {
        const values: Record<string, string> = {
          SUPABASE_URL: 'http://supabase.test',
          SUPABASE_SERVICE_ROLE_KEY: 'service-key',
          SUPABASE_BUCKET_QUESTION_IMAGES: 'question-images',
        };
        return values[key];
      }),
    }) as any;

  const makeAccessService = () =>
    ({
      assertInstructorOwnsCourse: jest.fn().mockResolvedValue(undefined),
      getInstructorCourseIds: jest.fn().mockResolvedValue([1]),
    }) as any;

  const makeService = (overrides: Record<string, any> = {}) => {
    const repos = {
      chapterRepo: makeRepo(),
      questionRepo: makeRepo(),
      attachmentRepo: makeRepo(),
      groupRepo: makeRepo(),
      groupItemRepo: makeRepo(),
      versionRepo: makeRepo(),
      reviewEventRepo: makeRepo(),
      optionRepo: makeRepo(),
      blankRepo: makeRepo(),
      courseRepo: makeRepo(),
      fileRepo: makeRepo(),
      filePermissionRepo: makeRepo(),
      ...overrides,
    };

    return {
      repos,
      service: new QuestionBankService(
        {
          transaction: jest.fn((callback) =>
            callback({
              create: jest.fn((_, value) => value),
              save: jest.fn((value) => Promise.resolve({ id: 1, ...value })),
              update: jest.fn(),
              delete: jest.fn(),
              restore: jest.fn(),
              findOne: jest.fn(),
              createQueryBuilder: jest.fn(() => ({
                select: jest.fn().mockReturnThis(),
                where: jest.fn().mockReturnThis(),
                getRawOne: jest.fn().mockResolvedValue({ maxVersion: '1' }),
              })),
            }),
          ),
        } as any,
        repos.chapterRepo,
        repos.questionRepo,
        repos.attachmentRepo,
        repos.groupRepo,
        repos.groupItemRepo,
        repos.versionRepo,
        repos.reviewEventRepo,
        repos.optionRepo,
        repos.blankRepo,
        repos.courseRepo,
        repos.fileRepo,
        repos.filePermissionRepo,
        overrides.filesService || makeFilesService(),
        makeConfigService(),
        overrides.accessService || makeAccessService(),
      ),
    };
  };

  it('rejects question creation without text and file', async () => {
    const chapterRepo = makeRepo();
    chapterRepo.exist.mockResolvedValue(true);
    const { service } = makeService({ chapterRepo });

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

  it('uploads question image via files service', async () => {
    const filesService = makeFilesService();
    filesService.uploadFile.mockResolvedValue({ fileId: 88 });
    const { service } = makeService({ filesService });

    const image = {
      mimetype: 'image/png',
      size: 1000,
      originalname: 'q.png',
      buffer: Buffer.from('img'),
    } as Express.Multer.File;

    await service.uploadQuestionImage(9, image);

    expect(filesService.uploadFile).toHaveBeenCalledWith(image, 9);
  });

  it('uploads question group image through the dedicated helper', async () => {
    const filesService = makeFilesService();
    filesService.uploadFile.mockResolvedValue({ fileId: 89 });
    const { service } = makeService({ filesService });

    const image = {
      mimetype: 'image/png',
      size: 1000,
      originalname: 'group.png',
      buffer: Buffer.from('img'),
    } as Express.Multer.File;

    await service.uploadQuestionGroupImage(9, image);

    expect(filesService.uploadFile).toHaveBeenCalledWith(image, 9);
  });

  it('rejects unsupported question image type', async () => {
    const { service } = makeService();

    const image = {
      mimetype: 'application/pdf',
      size: 1000,
      originalname: 'q.pdf',
      buffer: Buffer.from('pdf'),
    } as Express.Multer.File;

    await expect(service.uploadQuestionImage(9, image)).rejects.toBeInstanceOf(
      BadRequestException,
    );
  });

  it('rejects incompatible children for written questions', async () => {
    const chapterRepo = makeRepo();
    chapterRepo.exist.mockResolvedValue(true);
    const { service } = makeService({ chapterRepo });

    await expect(
      service.createQuestion(
        {
          courseId: 1,
          chapterId: 1,
          questionType: 'written' as any,
          difficulty: 'easy' as any,
          bloomLevel: 'remembering' as any,
          questionText: 'Explain',
          expectedAnswerText: 'Answer',
          options: [{ optionText: 'A', isCorrect: true }],
        },
        1,
      ),
    ).rejects.toBeInstanceOf(BadRequestException);
  });

  it('rejects duplicate fill blank keys', async () => {
    const chapterRepo = makeRepo();
    chapterRepo.exist.mockResolvedValue(true);
    const { service } = makeService({ chapterRepo });

    await expect(
      service.createQuestion(
        {
          courseId: 1,
          chapterId: 1,
          questionType: 'fill_blanks' as any,
          difficulty: 'easy' as any,
          bloomLevel: 'remembering' as any,
          questionText: 'Fill [a] and [a]',
          fillBlanks: [
            { blankKey: 'a', acceptableAnswer: 'One' },
            { blankKey: 'A', acceptableAnswer: 'Two' },
          ],
        },
        1,
      ),
    ).rejects.toBeInstanceOf(BadRequestException);
  });

  it('saves MCQ options when creating a question', async () => {
    const manager = {
      create: jest.fn((_, value) => value),
      save: jest.fn((value) => {
        if (Array.isArray(value)) {
          return Promise.resolve(value);
        }
        if (value.questionType) {
          return Promise.resolve({ id: 123, ...value });
        }
        return Promise.resolve({ id: 1, ...value });
      }),
      update: jest.fn(),
      delete: jest.fn(),
      findOne: jest.fn().mockResolvedValue({
        id: 123,
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
    const chapterRepo = makeRepo();
    chapterRepo.exist.mockResolvedValue(true);
    const dataSource = {
      transaction: jest.fn((callback) => callback(manager)),
    };
    const { service } = makeService({ chapterRepo });
    (service as any).dataSource = dataSource;
    jest
      .spyOn(service, 'findQuestionById')
      .mockResolvedValue({ id: 123 } as any);

    await service.createQuestion(
      {
        courseId: 1,
        chapterId: 1,
        questionType: 'mcq' as any,
        difficulty: 'easy' as any,
        bloomLevel: 'remembering' as any,
        questionText: 'Choose one',
        options: [
          { optionText: 'A', isCorrect: true },
          { optionText: 'B', isCorrect: false },
        ],
      },
      10,
    );

    expect(manager.save).toHaveBeenCalledWith([
      expect.objectContaining({
        questionId: 123,
        optionText: 'A',
        isCorrect: 1,
        optionOrder: 0,
      }),
      expect.objectContaining({
        questionId: 123,
        optionText: 'B',
        isCorrect: 0,
        optionOrder: 1,
      }),
    ]);
  });

  it('saves fill blank answers when creating a question', async () => {
    const manager = {
      create: jest.fn((_, value) => value),
      save: jest.fn((value) => {
        if (Array.isArray(value)) {
          return Promise.resolve(value);
        }
        if (value.questionType) {
          return Promise.resolve({ id: 124, ...value });
        }
        return Promise.resolve({ id: 1, ...value });
      }),
      update: jest.fn(),
      delete: jest.fn(),
      findOne: jest.fn().mockResolvedValue({
        id: 124,
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
    const chapterRepo = makeRepo();
    chapterRepo.exist.mockResolvedValue(true);
    const dataSource = {
      transaction: jest.fn((callback) => callback(manager)),
    };
    const { service } = makeService({ chapterRepo });
    (service as any).dataSource = dataSource;
    jest
      .spyOn(service, 'findQuestionById')
      .mockResolvedValue({ id: 124 } as any);

    await service.createQuestion(
      {
        courseId: 1,
        chapterId: 1,
        questionType: 'fill_blanks' as any,
        difficulty: 'easy' as any,
        bloomLevel: 'remembering' as any,
        questionText: 'Fill [term]',
        fillBlanks: [
          {
            blankKey: 'term',
            acceptableAnswer: 'Answer',
            isCaseSensitive: true,
          },
        ],
      },
      10,
    );

    expect(manager.save).toHaveBeenCalledWith([
      expect.objectContaining({
        questionId: 124,
        blankKey: 'term',
        acceptableAnswer: 'Answer',
        isCaseSensitive: 1,
      }),
    ]);
  });

  it('patches question text without rewriting existing children', async () => {
    const manager = {
      create: jest.fn((_, value) => value),
      save: jest.fn((value) => Promise.resolve({ id: 1, ...value })),
      update: jest.fn(),
      delete: jest.fn(),
      findOne: jest.fn().mockResolvedValue({
        id: 1,
        options: [],
        fillBlanks: [],
        attachments: [],
      }),
      createQueryBuilder: jest.fn(() => ({
        select: jest.fn().mockReturnThis(),
        where: jest.fn().mockReturnThis(),
        getRawOne: jest.fn().mockResolvedValue({ maxVersion: '1' }),
      })),
    };
    const dataSource = {
      transaction: jest.fn((callback) => callback(manager)),
    };
    const { service } = makeService({});
    (service as any).dataSource = dataSource;
    jest.spyOn(service, 'findQuestionById').mockResolvedValue({
      id: 1,
      courseId: 1,
      chapterId: 1,
      questionType: 'written',
      difficulty: 'easy',
      bloomLevel: 'remembering',
      questionText: 'Old',
      expectedAnswerText: 'Answer',
      hints: null,
      status: 'draft',
      options: [],
      fillBlanks: [],
      attachments: [],
    } as any);

    await service.updateQuestion(1, { questionText: 'New' }, 10);

    expect(manager.delete).not.toHaveBeenCalled();
  });

  it('clears incompatible children when question type changes', async () => {
    const manager = {
      create: jest.fn((_, value) => value),
      save: jest.fn((value) => Promise.resolve({ id: 1, ...value })),
      update: jest.fn(),
      delete: jest.fn(),
      findOne: jest.fn().mockResolvedValue({
        id: 1,
        options: [],
        fillBlanks: [],
        attachments: [],
      }),
      createQueryBuilder: jest.fn(() => ({
        select: jest.fn().mockReturnThis(),
        where: jest.fn().mockReturnThis(),
        getRawOne: jest.fn().mockResolvedValue({ maxVersion: '1' }),
      })),
    };
    const dataSource = {
      transaction: jest.fn((callback) => callback(manager)),
    };
    const { service } = makeService({});
    (service as any).dataSource = dataSource;
    jest.spyOn(service, 'findQuestionById').mockResolvedValue({
      id: 1,
      courseId: 1,
      chapterId: 1,
      questionType: 'mcq',
      difficulty: 'easy',
      bloomLevel: 'remembering',
      questionText: 'Old',
      expectedAnswerText: null,
      hints: null,
      status: 'draft',
      options: [
        { optionText: 'A', isCorrect: 1 },
        { optionText: 'B', isCorrect: 0 },
      ],
      fillBlanks: [],
      attachments: [],
    } as any);

    await service.updateQuestion(
      1,
      {
        questionType: 'written' as any,
        expectedAnswerText: 'Answer',
      },
      10,
    );

    expect(manager.delete).toHaveBeenCalledTimes(2);
  });
});
