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
  const makeFilesService = () =>
    ({
      uploadFile: jest.fn(),
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
      makeFilesService(),
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

  it('uploads question image via files service', async () => {
    const filesService = makeFilesService();
    filesService.uploadFile.mockResolvedValue({ fileId: 88 });

    const service = new QuestionBankService(
      makeRepo(),
      makeRepo(),
      makeRepo(),
      makeRepo(),
      makeRepo(),
      makeRepo(),
      filesService,
    );

    const image = {
      mimetype: 'image/png',
      size: 1000,
      originalname: 'q.png',
      buffer: Buffer.from('img'),
    } as Express.Multer.File;

    await service.uploadQuestionImage(9, image);

    expect(filesService.uploadFile).toHaveBeenCalledWith(image, 9);
  });

  it('rejects unsupported question image type', async () => {
    const service = new QuestionBankService(
      makeRepo(),
      makeRepo(),
      makeRepo(),
      makeRepo(),
      makeRepo(),
      makeRepo(),
      makeFilesService(),
    );

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
});
