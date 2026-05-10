import { BadRequestException, NotFoundException } from '@nestjs/common';
import JSZip from 'jszip';
import { ExamsService } from '../exams.service';
import { ExamGroupSelectionMode } from '../dto/generate-exam.dto';

describe('ExamsService', () => {
  const readDocxXml = async (content: string, path: string) => {
    const zip = await JSZip.loadAsync(Buffer.from(content, 'base64'));
    const file = zip.file(path);
    if (!file) throw new Error(`Missing ${path}`);
    return file.async('string');
  };

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
        overrides.filesService,
        overrides.fileStorageService,
        overrides.configService,
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
            sourceGroupTitle: 'Hidden group title',
            sourceGroupPrompt: 'Hidden group prompt',
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
    const documentXml = await readDocxXml(result.content, 'word/document.xml');
    const footerXml = await readDocxXml(result.content, 'word/footer1.xml');

    expect(result.fileName).toBe('exam-7.docx');
    expect(result.mimeType).toBe(
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    );
    expect(documentXml).toContain('Alexandria University');
    expect(documentXml).toContain('Faculty of Engineering');
    expect(documentXml).toContain('جامعة الإسكندرية');
    expect(documentXml).toContain('&lt;Question&gt;');
    expect(documentXml).toContain('(correct)');
    expect(documentXml).toContain('&lt;Expected&gt;');
    expect(documentXml).not.toContain('<Question>');
    expect(documentXml).not.toContain('Hidden group title');
    expect(documentXml).not.toContain('Hidden group prompt');
    expect(footerXml).toContain('PAGE');
    expect(footerXml).toContain('NUMPAGES');
  });

  it('can hide total and question marks in paper export', async () => {
    const exportRepo = makeRepo();
    exportRepo.create.mockImplementation((value) => value);
    exportRepo.save.mockResolvedValue({});
    const { service } = makeService({ exportRepo });
    jest.spyOn(service, 'findExamById').mockResolvedValue({
      id: 8,
      title: 'Final',
      totalMarks: 20,
      totalWeight: 20,
      sections: [
        {
          id: 3,
          title: 'MCQ',
          totalMarks: 20,
          sectionOrder: 0,
        },
      ],
      items: [
        {
          id: 1,
          itemOrder: 1,
          sectionId: 3,
          marks: 5,
          weight: 1,
          snapshot: { questionText: 'Section question', marks: 5 },
        },
        {
          id: 2,
          itemOrder: 0,
          sectionId: null,
          marks: 5,
          weight: 1,
          snapshot: { questionText: 'Pool question', marks: 5 },
        },
        {
          id: 3,
          itemOrder: 3,
          sectionId: 3,
          marks: 5,
          weight: 1,
          snapshot: { questionText: 'Second section question', marks: 5 },
        },
        {
          id: 4,
          itemOrder: 2,
          sectionId: null,
          marks: 5,
          weight: 1,
          snapshot: { questionText: 'Later pool question', marks: 5 },
        },
      ],
    } as any);

    const result = await service.exportExamAsWord(
      8,
      {
        format: 'html_doc' as any,
        showTotalMarks: false,
        showQuestionMarks: false,
      },
      10,
    );
    const documentXml = await readDocxXml(result.content, 'word/document.xml');
    const footerXml = await readDocxXml(result.content, 'word/footer1.xml');

    expect(documentXml).toContain('>1. </w:t>');
    expect(documentXml).toContain('Pool question');
    expect(documentXml).toContain('>2. </w:t>');
    expect(documentXml).toContain('Section question');
    expect(documentXml).toContain('>3. </w:t>');
    expect(documentXml).toContain('Second section question');
    expect(documentXml).toContain('>4. </w:t>');
    expect(documentXml).toContain('Later pool question');
    expect(documentXml.indexOf('Second section question')).toBeLessThan(
      documentXml.indexOf('Later pool question'),
    );
    expect(documentXml).not.toContain('Section Marks:');
    expect(documentXml).not.toContain('Marks: 5');
    expect(footerXml).not.toContain('{totalPages}');
    expect(footerXml).toContain('NUMPAGES');
  });

  it('renders common LaTeX markers as readable math text in DOCX export', async () => {
    const exportRepo = makeRepo();
    exportRepo.create.mockImplementation((value) => value);
    exportRepo.save.mockResolvedValue({});
    const { service } = makeService({ exportRepo });
    jest.spyOn(service, 'findExamById').mockResolvedValue({
      id: 10,
      title: 'Math Final',
      totalMarks: 10,
      totalWeight: 10,
      sections: [],
      items: [
        {
          id: 1,
          itemOrder: 0,
          sectionId: null,
          marks: 10,
          weight: 1,
          snapshot: {
            questionText:
              'Find $C(s)/R(s)$ when $G(s)=\\frac{10}{s^2+2s+10}$ and $R_0=10,000 \\Omega$. A thermistor is represented by $R=R_0 e^{-0.1T}$. Find $K_1$ for $t \\ge 0$ at $t=1.0\\ \\text{s}$.',
            marks: 10,
            optionsJson: [
              {
                optionText: '$\\sqrt{19}$',
                isCorrect: 1,
              },
            ],
          },
        },
      ],
    } as any);

    const result = await service.exportExamAsWord(
      10,
      { format: 'html_doc' as any },
      10,
    );
    const documentXml = await readDocxXml(result.content, 'word/document.xml');

    expect(documentXml).toContain('C(s)/R(s)');
    expect(documentXml).toContain('(10)/(s');
    expect(documentXml).toContain('R₀');
    expect(documentXml).toContain('K₁');
    expect(documentXml).toMatch(/e⁻|⁻⁰\.¹ᵀ/);
    expect(documentXml).toContain('≥ 0');
    expect(documentXml).toContain('t=1.0 s');
    expect(documentXml).toContain('√(19)');
    expect(documentXml).not.toContain('K□');
    expect(documentXml).not.toContain('tge0');
    expect(documentXml).not.toContain('text{s}');
    expect(documentXml).not.toContain('$C(s)/R(s)$');
    expect(documentXml).not.toContain('e^(-0.1T)');
    expect(documentXml).not.toContain('\\frac');
    expect(documentXml).not.toContain('\\Omega');
  });

  it('registers a Flutter-rendered PDF client export', async () => {
    const examRepo = makeRepo();
    examRepo.findOne.mockResolvedValue({
      id: 77,
      courseId: 5,
      items: [],
      sections: [],
    });
    const exportRepo = makeRepo();
    exportRepo.create.mockImplementation((value) => value);
    exportRepo.save.mockImplementation((value) =>
      Promise.resolve({ id: 123, ...value }),
    );
    const filesService = {
      uploadFile: jest.fn().mockResolvedValue({
        fileId: 456,
        fileName: 'exam-77.pdf',
        originalFileName: 'exam-77.pdf',
        mimeType: 'application/pdf',
        fileSize: 12,
      }),
    };
    const accessService = makeAccessService();
    const { service } = makeService({
      examRepo,
      exportRepo,
      filesService,
      accessService,
    });
    const file = {
      originalname: 'exam-77.pdf',
      mimetype: 'application/pdf',
      size: 12,
      buffer: Buffer.from('%PDF'),
    } as any;

    const result = await service.registerClientPdfExport(
      77,
      file,
      { format: 'pdf', variant: 'student' },
      9,
    );

    expect(accessService.assertInstructorOwnsCourse).toHaveBeenCalledWith(9, 5);
    expect(filesService.uploadFile).toHaveBeenCalledWith(file, 9);
    expect(exportRepo.create).toHaveBeenCalledWith(
      expect.objectContaining({
        examId: 77,
        format: 'pdf',
        status: 'completed',
        fileId: 456,
        requestedBy: 9,
      }),
    );
    expect(result).toEqual(
      expect.objectContaining({
        exportId: 123,
        examId: 77,
        status: 'completed',
        format: 'pdf',
        fileId: 456,
      }),
    );
  });

  it('rejects invalid client export uploads', async () => {
    const examRepo = makeRepo();
    examRepo.findOne.mockResolvedValue({
      id: 77,
      courseId: 5,
      items: [],
      sections: [],
    });
    const { service } = makeService({
      examRepo,
      filesService: { uploadFile: jest.fn() },
    });

    await expect(
      service.registerClientPdfExport(77, undefined, { format: 'pdf' }, 9),
    ).rejects.toBeInstanceOf(BadRequestException);

    await expect(
      service.registerClientPdfExport(
        77,
        {
          originalname: 'exam-77.txt',
          mimetype: 'text/plain',
          size: 12,
          buffer: Buffer.from('nope'),
        } as any,
        { format: 'pdf' },
        9,
      ),
    ).rejects.toBeInstanceOf(BadRequestException);
  });

  it('exports PDF with unicode paper text and real content bytes', async () => {
    const exportRepo = makeRepo();
    exportRepo.create.mockImplementation((value) => value);
    exportRepo.save.mockResolvedValue({});
    const { service } = makeService({ exportRepo });
    jest.spyOn(service, 'findExamById').mockResolvedValue({
      id: 9,
      title: 'Final',
      totalMarks: 10,
      totalWeight: 10,
      durationMinutes: 120,
      course: { code: 'CS505', name: 'Web Development' },
      sections: [],
      items: [
        {
          id: 1,
          itemOrder: 0,
          sectionId: null,
          marks: 5,
          weight: 1,
          snapshot: {
            questionText: 'ما نتيجة الكود؟',
            marks: 5,
            optionsJson: [{ optionText: 'الإجابة الأولى', isCorrect: 1 }],
          },
        },
      ],
      paperTemplateSnapshotJson: {
        headerJson: {
          right: [{ value: 'جامعة الإسكندرية', bold: true }],
          metadataRight: [{ value: 'المادة: {courseCode}' }],
        },
        trailingJson: { lines: [{ value: 'بالتوفيق' }] },
        footerJson: { pageNumberFormat: 'Page {page} of {totalPages}' },
      },
    } as any);

    const result = await service.exportExamAsWord(
      9,
      { format: 'pdf' as any },
      10,
    );
    const bytes = Buffer.from(result.content, 'base64');

    expect(result.mimeType).toBe('application/pdf');
    expect(bytes.subarray(0, 4).toString()).toBe('%PDF');
    expect(bytes.length).toBeGreaterThan(1000);
  });
});
