import { ExamsService } from '../exams.service';

export const makeExamRepo = () =>
  ({
    exist: jest.fn(),
    findOne: jest.fn(),
    find: jest.fn(),
    findAndCount: jest.fn(),
    save: jest.fn((value) => Promise.resolve({ id: 1, ...value })),
    create: jest.fn((value) => value),
    update: jest.fn(),
    remove: jest.fn(),
    count: jest.fn(),
    createQueryBuilder: jest.fn(),
  }) as any;

export const makeExamsService = (overrides: Record<string, any> = {}) => {
  const repos = {
    courseRepo: makeExamRepo(),
    chapterRepo: makeExamRepo(),
    questionRepo: makeExamRepo(),
    optionRepo: makeExamRepo(),
    blankRepo: makeExamRepo(),
    attachmentRepo: makeExamRepo(),
    groupRepo: makeExamRepo(),
    groupItemRepo: makeExamRepo(),
    draftRepo: makeExamRepo(),
    draftItemRepo: makeExamRepo(),
    draftSectionRepo: makeExamRepo(),
    examRepo: makeExamRepo(),
    examItemRepo: makeExamRepo(),
    examSectionRepo: makeExamRepo(),
    snapshotRepo: makeExamRepo(),
    exportRepo: makeExamRepo(),
    paperTemplateRepo: makeExamRepo(),
    ...overrides,
  };

  const accessService =
    overrides.accessService ||
    ({
      assertInstructorOwnsCourse: jest.fn().mockResolvedValue(undefined),
      getInstructorCourseIds: jest.fn().mockResolvedValue([1]),
    } as any);

  return {
    repos,
    accessService,
    service: new ExamsService(
      overrides.dataSource || ({ transaction: jest.fn() } as any),
      repos.courseRepo,
      repos.chapterRepo,
      repos.questionRepo,
      repos.optionRepo,
      repos.blankRepo,
      repos.attachmentRepo,
      repos.groupRepo,
      repos.groupItemRepo,
      repos.draftRepo,
      repos.draftItemRepo,
      repos.draftSectionRepo,
      repos.examRepo,
      repos.examItemRepo,
      repos.examSectionRepo,
      repos.snapshotRepo,
      repos.exportRepo,
      repos.paperTemplateRepo,
      accessService,
      overrides.filesService,
      overrides.fileStorageService,
      overrides.configService,
    ),
  };
};
