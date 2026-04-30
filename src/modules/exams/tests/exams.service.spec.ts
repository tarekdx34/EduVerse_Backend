import { BadRequestException, NotFoundException } from '@nestjs/common';
import { ExamsService } from '../exams.service';

describe('ExamsService', () => {
  const makeRepo = () =>
    ({
      exist: jest.fn(),
      findOne: jest.fn(),
      save: jest.fn(),
      create: jest.fn((value) => value),
      createQueryBuilder: jest.fn(),
    }) as any;

  it('throws when course does not exist', async () => {
    const courseRepo = makeRepo();
    courseRepo.exist.mockResolvedValue(false);

    const service = new ExamsService(
      courseRepo,
      makeRepo(),
      makeRepo(),
      makeRepo(),
      makeRepo(),
      makeRepo(),
      makeRepo(),
    );

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

    const service = new ExamsService(
      courseRepo,
      makeRepo(),
      makeRepo(),
      makeRepo(),
      makeRepo(),
      makeRepo(),
      makeRepo(),
    );

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
});

