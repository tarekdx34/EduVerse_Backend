import { QuestionBankService } from '../question-bank.service';

export const supabaseMock = {
  storage: {
    listBuckets: jest.fn().mockResolvedValue({
      data: [{ id: 'question-images', name: 'question-images' }],
      error: null,
    }),
    from: jest.fn().mockReturnValue({
      upload: jest.fn().mockResolvedValue({ error: null }),
      createSignedUrls: jest.fn().mockResolvedValue({ data: [], error: null }),
      getPublicUrl: jest.fn().mockReturnValue({
        data: { publicUrl: 'public-url' },
      }),
    }),
  },
};

export const makeQuestionBankRepo = () =>
  ({
    exist: jest.fn(),
    findOne: jest.fn(),
    findOneByOrFail: jest.fn(),
    find: jest.fn(),
    findAndCount: jest.fn(),
    save: jest.fn((value) => Promise.resolve({ id: 1, ...value })),
    create: jest.fn((value) => value),
    delete: jest.fn(),
    remove: jest.fn(),
    update: jest.fn(),
    softDelete: jest.fn(),
    restore: jest.fn(),
    count: jest.fn(),
    createQueryBuilder: jest.fn(() => ({
      select: jest.fn().mockReturnThis(),
      where: jest.fn().mockReturnThis(),
      andWhere: jest.fn().mockReturnThis(),
      getRawOne: jest.fn().mockResolvedValue({ maxOrder: null }),
    })),
  }) as any;

export const makeQuestionBankService = (
  overrides: Record<string, any> = {},
) => {
  const repos = {
    chapterRepo: makeQuestionBankRepo(),
    questionRepo: makeQuestionBankRepo(),
    attachmentRepo: makeQuestionBankRepo(),
    groupRepo: makeQuestionBankRepo(),
    groupItemRepo: makeQuestionBankRepo(),
    versionRepo: makeQuestionBankRepo(),
    reviewEventRepo: makeQuestionBankRepo(),
    optionRepo: makeQuestionBankRepo(),
    blankRepo: makeQuestionBankRepo(),
    courseRepo: makeQuestionBankRepo(),
    fileRepo: makeQuestionBankRepo(),
    filePermissionRepo: makeQuestionBankRepo(),
    ...overrides,
  };

  const filesService =
    overrides.filesService ||
    ({
      uploadFile: jest.fn(),
      deleteFile: jest.fn(),
    } as any);

  const configService =
    overrides.configService ||
    ({
      get: jest.fn((key: string) => {
        const values: Record<string, string> = {
          SUPABASE_URL: 'http://supabase.test',
          SUPABASE_SERVICE_ROLE_KEY: 'service-key',
          SUPABASE_BUCKET_QUESTION_IMAGES: 'question-images',
        };
        return values[key];
      }),
    } as any);

  const accessService =
    overrides.accessService ||
    ({
      assertInstructorOwnsCourse: jest.fn().mockResolvedValue(undefined),
      getInstructorCourseIds: jest.fn().mockResolvedValue([1]),
    } as any);

  const dataSource =
    overrides.dataSource ||
    ({
      transaction: jest.fn((callback) =>
        callback({
          create: jest.fn((_, value) => value),
          save: jest.fn((value) => Promise.resolve({ id: 1, ...value })),
          update: jest.fn(),
          delete: jest.fn(),
          restore: jest.fn(),
          findOne: jest.fn(),
          query: jest
            .fn()
            .mockResolvedValueOnce([])
            .mockResolvedValue([{ maxOrder: -1 }]),
          createQueryBuilder: jest.fn(() => ({
            select: jest.fn().mockReturnThis(),
            where: jest.fn().mockReturnThis(),
            getRawOne: jest.fn().mockResolvedValue({ maxVersion: '1' }),
          })),
        }),
      ),
    } as any);

  return {
    repos,
    filesService,
    accessService,
    service: new QuestionBankService(
      dataSource,
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
      filesService,
      configService,
      accessService,
    ),
  };
};
