import { MigrationInterface, QueryRunner } from 'typeorm';

export class VerifyQuestionBankExamConstraintsAndAddOverrideReasons1780000000002
  implements MigrationInterface
{
  name =
    'VerifyQuestionBankExamConstraintsAndAddOverrideReasons1780000000002';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await this.assertNoDuplicates(
      queryRunner,
      'question_bank_options',
      ['question_id', 'option_order'],
      'Duplicate question option order found',
    );
    await this.assertNoDuplicates(
      queryRunner,
      'question_bank_fill_blanks',
      ['question_id', 'blank_key'],
      'Duplicate fill blank key found',
    );
    await this.assertNoDuplicates(
      queryRunner,
      'exam_draft_items',
      ['draft_id', 'item_order'],
      'Duplicate draft item order found',
    );
    await this.assertNoDuplicates(
      queryRunner,
      'exam_draft_items',
      ['draft_id', 'question_id'],
      'Duplicate question in draft found',
    );
    await this.assertNoDuplicates(
      queryRunner,
      'exam_items',
      ['exam_id', 'item_order'],
      'Duplicate exam item order found',
    );
    await this.assertNoDuplicates(
      queryRunner,
      'exam_items',
      ['exam_id', 'question_id'],
      'Duplicate question in saved exam found',
    );

    await this.addColumnIfMissing(
      queryRunner,
      'exam_draft_items',
      'override_reason',
      '`override_reason` text NULL',
    );
    await this.addColumnIfMissing(
      queryRunner,
      'exam_items',
      'override_reason',
      '`override_reason` text NULL',
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await this.dropColumnIfExists(queryRunner, 'exam_items', 'override_reason');
    await this.dropColumnIfExists(
      queryRunner,
      'exam_draft_items',
      'override_reason',
    );
  }

  private async assertNoDuplicates(
    queryRunner: QueryRunner,
    tableName: string,
    columns: string[],
    message: string,
  ): Promise<void> {
    const columnList = columns.map((column) => `\`${column}\``).join(', ');
    const nullChecks = columns
      .map((column) => `\`${column}\` IS NOT NULL`)
      .join(' AND ');
    const rows = await queryRunner.query(
      `
        SELECT ${columnList}, COUNT(*) AS duplicateCount
        FROM \`${tableName}\`
        WHERE ${nullChecks}
        GROUP BY ${columnList}
        HAVING COUNT(*) > 1
        LIMIT 1
      `,
    );
    if (rows.length) {
      throw new Error(`${message} in ${tableName}`);
    }
  }

  private async addColumnIfMissing(
    queryRunner: QueryRunner,
    tableName: string,
    columnName: string,
    definition: string,
  ): Promise<void> {
    const table = await queryRunner.getTable(tableName);
    if (!table?.findColumnByName(columnName)) {
      await queryRunner.query(`ALTER TABLE \`${tableName}\` ADD COLUMN ${definition}`);
    }
  }

  private async dropColumnIfExists(
    queryRunner: QueryRunner,
    tableName: string,
    columnName: string,
  ): Promise<void> {
    const table = await queryRunner.getTable(tableName);
    if (table?.findColumnByName(columnName)) {
      await queryRunner.query(
        `ALTER TABLE \`${tableName}\` DROP COLUMN \`${columnName}\``,
      );
    }
  }
}
