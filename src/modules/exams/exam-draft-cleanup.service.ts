import { Injectable, Logger } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { InjectRepository } from '@nestjs/typeorm';
import { LessThan, Repository } from 'typeorm';
import { ExamDraft, ExamDraftStatus } from './entities/exam-draft.entity';

@Injectable()
export class ExamDraftCleanupService {
  private readonly logger = new Logger(ExamDraftCleanupService.name);

  constructor(
    @InjectRepository(ExamDraft)
    private readonly draftRepo: Repository<ExamDraft>,
  ) {}

  @Cron(CronExpression.EVERY_HOUR)
  async cleanupExpiredAndEmptyDrafts(): Promise<void> {
    const now = new Date();
    const expiredResult = await this.draftRepo.update(
      {
        status: ExamDraftStatus.OPEN,
        expiresAt: LessThan(now),
      },
      { status: ExamDraftStatus.EXPIRED },
    );

    const emptyFailedResult = await this.draftRepo
      .createQueryBuilder()
      .update(ExamDraft)
      .set({ status: ExamDraftStatus.FAILED, failureReason: 'Draft has no items' })
      .where('status IN (:...statuses)', {
        statuses: [ExamDraftStatus.OPEN, ExamDraftStatus.EXPIRED],
      })
      .andWhere(
        'NOT EXISTS (SELECT 1 FROM exam_draft_items item WHERE item.draft_id = exam_drafts.draft_id)',
      )
      .execute();

    if ((expiredResult.affected || 0) + (emptyFailedResult.affected || 0) > 0) {
      this.logger.log(
        `Draft cleanup marked ${expiredResult.affected || 0} expired and ${emptyFailedResult.affected || 0} failed`,
      );
    }
  }
}
