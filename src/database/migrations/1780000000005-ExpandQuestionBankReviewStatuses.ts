import { MigrationInterface, QueryRunner } from 'typeorm';

export class ExpandQuestionBankReviewStatuses1780000000005
  implements MigrationInterface
{
  name = 'ExpandQuestionBankReviewStatuses1780000000005';

  public async up(queryRunner: QueryRunner): Promise<void> {
    const expanded =
      "enum('draft','under_review','approved','rejected','archived')";

    await queryRunner.query(`
      ALTER TABLE \`question_bank_review_events\`
      MODIFY COLUMN \`from_status\` ${expanded} NULL
    `);
    await queryRunner.query(`
      ALTER TABLE \`question_bank_review_events\`
      MODIFY COLUMN \`to_status\` ${expanded} NOT NULL
    `);
    await queryRunner.query(`
      ALTER TABLE \`question_bank_questions\`
      MODIFY COLUMN \`status\` ${expanded} NOT NULL DEFAULT 'draft'
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    const legacy = "enum('draft','approved','archived')";

    await queryRunner.query(`
      UPDATE \`question_bank_questions\`
      SET \`status\` = 'draft'
      WHERE \`status\` IN ('under_review', 'rejected')
    `);
    await queryRunner.query(`
      UPDATE \`question_bank_review_events\`
      SET \`from_status\` = 'draft'
      WHERE \`from_status\` IN ('under_review', 'rejected')
    `);
    await queryRunner.query(`
      UPDATE \`question_bank_review_events\`
      SET \`to_status\` = 'draft'
      WHERE \`to_status\` IN ('under_review', 'rejected')
    `);
    await queryRunner.query(`
      ALTER TABLE \`question_bank_questions\`
      MODIFY COLUMN \`status\` ${legacy} NOT NULL DEFAULT 'draft'
    `);
    await queryRunner.query(`
      ALTER TABLE \`question_bank_review_events\`
      MODIFY COLUMN \`to_status\` ${legacy} NOT NULL
    `);
    await queryRunner.query(`
      ALTER TABLE \`question_bank_review_events\`
      MODIFY COLUMN \`from_status\` ${legacy} NULL
    `);
  }
}
