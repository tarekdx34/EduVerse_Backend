import { BadRequestException, ForbiddenException } from '@nestjs/common';
import { plainToInstance } from 'class-transformer';
import { QuestionBankQueryDto } from '../dto/question.dto';
import { QuestionAttachmentType } from '../entities/question-bank-question-attachment.entity';
import {
  makeQuestionBankService,
  supabaseMock,
} from './question-bank-test-utils';

jest.mock('@supabase/supabase-js', () => ({
  createClient: jest.fn(() => supabaseMock),
}));

describe('QuestionBank attachments', () => {
  const ownedQuestion = {
    id: 5,
    courseId: 1,
    chapterId: 2,
    questionFileId: null,
    options: [],
    fillBlanks: [],
    attachments: [],
  };

  it('rejects image attachments when the existing file is not an image', async () => {
    const { service, repos } = makeQuestionBankService();
    repos.questionRepo.findOne.mockResolvedValue(ownedQuestion);
    repos.fileRepo.findOne.mockResolvedValue({
      fileId: 10,
      uploadedBy: 99,
      isPublic: 0,
      mimeType: 'application/pdf',
    });

    await expect(
      service.addQuestionAttachment(
        5,
        { fileId: 10, attachmentType: QuestionAttachmentType.IMAGE },
        99,
      ),
    ).rejects.toBeInstanceOf(BadRequestException);
  });

  it('rejects files that are neither owned nor shared with the instructor', async () => {
    const { service, repos } = makeQuestionBankService();
    repos.questionRepo.findOne.mockResolvedValue(ownedQuestion);
    repos.fileRepo.findOne.mockResolvedValue({
      fileId: 10,
      uploadedBy: 22,
      isPublic: 0,
      mimeType: 'image/png',
    });
    repos.filePermissionRepo.exist.mockResolvedValue(false);

    await expect(
      service.addQuestionAttachment(
        5,
        { fileId: 10, attachmentType: QuestionAttachmentType.IMAGE },
        99,
      ),
    ).rejects.toBeInstanceOf(ForbiddenException);
  });

  it('rejects questionFileId when the image file is not owned or shared', async () => {
    const { service, repos } = makeQuestionBankService();
    repos.chapterRepo.exist.mockResolvedValue(true);
    repos.fileRepo.findOne.mockResolvedValue({
      fileId: 44,
      uploadedBy: 22,
      isPublic: 0,
      mimeType: 'image/png',
    });
    repos.filePermissionRepo.exist.mockResolvedValue(false);

    await expect(
      service.createQuestion(
        {
          courseId: 1,
          chapterId: 2,
          questionFileId: 44,
          questionType: 'written' as any,
          difficulty: 'easy' as any,
          bloomLevel: 'remembering' as any,
          expectedAnswerText: 'Expected',
        },
        99,
      ),
    ).rejects.toBeInstanceOf(ForbiddenException);
  });

  it('rejects non-image questionFileId files', async () => {
    const { service, repos } = makeQuestionBankService();
    repos.chapterRepo.exist.mockResolvedValue(true);
    repos.fileRepo.findOne.mockResolvedValue({
      fileId: 45,
      uploadedBy: 99,
      isPublic: 0,
      mimeType: 'application/pdf',
    });

    await expect(
      service.createQuestion(
        {
          courseId: 1,
          chapterId: 2,
          questionFileId: 45,
          questionType: 'written' as any,
          difficulty: 'easy' as any,
          bloomLevel: 'remembering' as any,
          expectedAnswerText: 'Expected',
        },
        99,
      ),
    ).rejects.toBeInstanceOf(BadRequestException);
  });

  it('uses NOT EXISTS for hasAttachments=false question filtering', async () => {
    const { service, repos } = makeQuestionBankService();
    const andWhere = jest.fn().mockReturnThis();
    repos.questionRepo.createQueryBuilder.mockReturnValue({
      leftJoinAndSelect: jest.fn().mockReturnThis(),
      where: jest.fn().mockReturnThis(),
      andWhere,
      orderBy: jest.fn().mockReturnThis(),
      addOrderBy: jest.fn().mockReturnThis(),
      skip: jest.fn().mockReturnThis(),
      take: jest.fn().mockReturnThis(),
      getManyAndCount: jest.fn().mockResolvedValue([[], 0]),
    });

    await service.listQuestions({ hasAttachments: 'false' as any }, 99);

    expect(
      andWhere.mock.calls.some((call) =>
        String(call[0]).includes('NOT EXISTS'),
      ),
    ).toBe(true);
  });

  it('transforms hasAttachments=false query string to boolean false', () => {
    const dto = plainToInstance(QuestionBankQueryDto, {
      hasAttachments: 'false',
    });

    expect(dto.hasAttachments).toBe(false);
  });
});
