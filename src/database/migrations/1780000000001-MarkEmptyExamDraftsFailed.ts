import { MigrationInterface, QueryRunner } from 'typeorm';

export class MarkEmptyExamDraftsFailed1780000000001
  implements MigrationInterface
{
  name = 'MarkEmptyExamDraftsFailed1780000000001';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      UPDATE \`exam_drafts\` d
      SET d.\`status\` = 'failed',
          d.\`failure_reason\` = COALESCE(d.\`failure_reason\`, 'Draft has no items')
      WHERE d.\`status\` IN ('open', 'expired')
        AND NOT EXISTS (
          SELECT 1
          FROM \`exam_draft_items\` i
          WHERE i.\`draft_id\` = d.\`draft_id\`
        )
    `);
  }

  public async down(): Promise<void> {
    // Data cleanup is intentionally not reverted.
  }
}
