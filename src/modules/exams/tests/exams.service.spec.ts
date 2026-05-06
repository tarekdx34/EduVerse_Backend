import { BadRequestException, NotFoundException } from '@nestjs/common';
import { ExamsService } from '../exams.service';
import { ExamGroupSelectionMode } from '../dto/generate-exam.dto';

describe('ExamsService', () => {
  const makeRepo = () =>
    ({
      exist: jest.fn(),
      findOne: jest.fn(),
      findAndCount: jest.fn(),
      save: jest.fn(),
      create: jest.fn((value) => value),
      update: jest.fn(),
      remove: jest.fn(),
      count: jest.fn(),
      createQueryBuilder: jest.fn(),
    }) as any;

  const makeAccessService = () =>
    ({
      assertInstructorOwnsCourse: jest.fn().mockResolvedValue(undefined),
      getInstructorCourseIds: jest.fn().mockResolvedValue([1]),
    }) as any;

  const makeService = (overrides: Record<string, any> = {}) => {
    const repos = {
      courseRepo: makeRepo(),
      chapterRepo: makeRepo(),
      questionRepo: makeRepo(),
      optionRepo: makeRepo(),
      blankRepo: makeRepo(),
      attachmentRepo: makeRepo(),
      groupRepo: makeRepo(),
      groupItemRepo: makeRepo(),
      draftRepo: makeRepo(),
      draftItemRepo: makeRepo(),
      draftSectionRepo: makeRepo(),
      examRepo: makeRepo(),
      examItemRepo: makeRepo(),
      examSectionRepo: makeRepo(),
      snapshotRepo: makeRepo(),
      exportRepo: makeRepo(),
      paperTemplateRepo: makeRepo(),
      ...overrides,
    };

    return {
      repos,
      service: new ExamsService(
        { transaction: jest.fn() } as any,
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
        overrides.accessService || makeAccessService(),
      ),
    };
  };

  it('throws when course does not exist', async () => {
    const courseRepo = makeRepo();
    courseRepo.exist.mockResolvedValue(false);
    const { service } = makeService({ courseRepo });

    await expect(
      service.generatePreview(
        {
          courseId: 1,
          title: 'Midterm',
          rules: [{ chapterId: 1, count: 1, weightPerQuestion: 1 }],
        },
        10,
      ),
    ).rejects.toBeInstanceOf(NotFoundException);
  });

  it('throws when no rules provided', async () => {
    const courseRepo = makeRepo();
    courseRepo.exist.mockResolvedValue(true);
    const { service } = makeService({ courseRepo });

    await expect(
      service.generatePreview(
        {
          courseId: 1,
          title: 'Midterm',
          rules: [],
        },
        10,
      ),
    ).rejects.toBeInstanceOf(BadRequestException);
  });

  it('rejects exclude-grouped mode when scope is selected group', async () => {
    const courseRepo = makeRepo();
    courseRepo.exist.mockResolvedValue(true);
    const { service } = makeService({ courseRepo });

    await expect(
      service.generatePreview(
        {
          courseId: 1,
          title: 'Midterm',
          rules: [
            {
              scope: 'group' as any,
              groupIds: [1],
              count: 1,
              weightPerQuestion: 1,
            },
          ],
          groupSelectionMode: ExamGroupSelectionMode.EXCLUDE_GROUPED,
        },
        10,
      ),
    ).rejects.toBeInstanceOf(BadRequestException);
  });

  it('lists exams with normalized pagination and instructor course scope', async () => {
    const examRepo = makeRepo();
    examRepo.findAndCount.mockResolvedValue([[], 0]);
    const { service } = makeService({ examRepo });

    await service.findExams(10, 0, 500);

    expect(examRepo.findAndCount).toHaveBeenCalledWith(
      expect.objectContaining({
        order: { createdAt: 'DESC' },
        skip: 0,
        take: 100,
      }),
    );
  });

  it('lists exams with course and status filters', async () => {
    const examRepo = makeRepo();
    const accessService = makeAccessService();
    examRepo.findAndCount.mockResolvedValue([[], 0]);
    const { service } = makeService({ examRepo, accessService });

    await service.findExams(10, 1, 20, {
      courseId: 3,
      status: 'published' as any,
    });

    expect(accessService.assertInstructorOwnsCourse).toHaveBeenCalledWith(
      10,
      3,
    );
    expect(examRepo.findAndCount).toHaveBeenCalledWith(
      expect.objectContaining({
        where: expect.objectContaining({ status: 'published' }),
      }),
    );
  });

  it('lists drafts with normalized pagination and instructor course scope', async () => {
    const draftRepo = makeRepo();
    draftRepo.findAndCount.mockResolvedValue([[], 0]);
    const { service } = makeService({ draftRepo });

    await service.findDrafts(10, -3, 0);

    expect(draftRepo.findAndCount).toHaveBeenCalledWith(
      expect.objectContaining({
        order: { createdAt: 'DESC' },
        skip: 0,
        take: 1,
      }),
    );
  });

  it('exports escaped snapshot content with attachments and answer key', async () => {
    const exportRepo = makeRepo();
    exportRepo.create.mockImplementation((value) => value);
    exportRepo.save.mockResolvedValue({});
    const { service } = makeService({ exportRepo });
    jest.spyOn(service, 'findExamById').mockResolvedValue({
      id: 7,
      title: '<Exam>',
      totalMarks: 10,
      totalWeight: 10,
      sections: [
        {
          id: 2,
          title: '<Section>',
          instructions: '<Instructions>',
          totalMarks: 10,
          sectionOrder: 0,
        },
      ],
      items: [
        {
          itemOrder: 0,
          sectionId: 2,
          marks: 10,
          weight: 1,
          snapshot: {
            questionText: '<Question>',
            marks: 10,
            optionsJson: [{ optionText: '<A>', isCorrect: 1 }],
            fillBlanksJson: [{ blankKey: 'x', acceptableAnswer: '<ans>' }],
            expectedAnswerText: '<Expected>',
            hints: '<Hint>',
            attachmentsJson: [
              {
                caption: '<Caption>',
                altText: '<Alt>',
                displayOrder: 0,
              },
            ],
          },
        },
      ],
    } as any);

    const result = await service.exportExamAsWord(
      7,
      { includeAnswerKey: true, format: 'html_doc' as any },
      10,
    );
    const html = Buffer.from(result.content, 'base64').toString('utf8');

    expect(html).toContain('&lt;Question&gt;');
    expect(html).toContain('&lt;Caption&gt;');
    expect(html).toContain('(correct)');
    expect(html).toContain('&lt;Expected&gt;');
    expect(html).not.toContain('<Question>');
  });
});
