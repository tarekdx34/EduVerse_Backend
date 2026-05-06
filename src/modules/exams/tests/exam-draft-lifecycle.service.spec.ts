import { BadRequestException } from '@nestjs/common';
import { ExamDraftStatus } from '../entities/exam-draft.entity';
import { makeExamsService } from './exams-test-utils';

describe('Exam draft lifecycle', () => {
  it('refuses to remove the last item from an open draft', async () => {
    const { service, repos } = makeExamsService();
    repos.draftRepo.findOne.mockResolvedValue({
      id: 1,
      courseId: 10,
      status: ExamDraftStatus.OPEN,
      expiresAt: new Date(Date.now() + 60_000),
      items: [{ id: 1 }],
      sections: [],
    });
    repos.draftItemRepo.findOne.mockResolvedValue({ id: 1, draftId: 1 });
    repos.draftItemRepo.count.mockResolvedValue(1);

    await expect(service.removeDraftItem(1, 1, 99)).rejects.toBeInstanceOf(
      BadRequestException,
    );
    expect(repos.draftItemRepo.remove).not.toHaveBeenCalled();
  });
});
