import { MigrationInterface, QueryRunner } from 'typeorm';

export class ExpandExamGeneratorTeachingIntent1780000000006
  implements MigrationInterface
{
  name = 'ExpandExamGeneratorTeachingIntent1780000000006';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await this.addColumnIfMissing(
      queryRunner,
      'exam_draft_items',
      'source_group_id',
      '`source_group_id` bigint UNSIGNED NULL',
    );
    await this.addColumnIfMissing(
      queryRunner,
      'exam_draft_items',
      'source_group_item_order',
      '`source_group_item_order` int UNSIGNED NULL',
    );

    await this.addColumnIfMissing(
      queryRunner,
      'exam_item_snapshots',
      'question_file_id',
      '`question_file_id` bigint UNSIGNED NULL',
    );
    await this.addColumnIfMissing(
      queryRunner,
      'exam_item_snapshots',
      'question_file_storage_path',
      '`question_file_storage_path` varchar(500) NULL',
    );
    await this.addColumnIfMissing(
      queryRunner,
      'exam_item_snapshots',
      'question_file_caption',
      '`question_file_caption` varchar(500) NULL',
    );
    await this.addColumnIfMissing(
      queryRunner,
      'exam_item_snapshots',
      'question_file_alt_text',
      '`question_file_alt_text` varchar(500) NULL',
    );
    await this.addColumnIfMissing(
      queryRunner,
      'exam_item_snapshots',
      'source_group_id',
      '`source_group_id` bigint UNSIGNED NULL',
    );
    await this.addColumnIfMissing(
      queryRunner,
      'exam_item_snapshots',
      'source_group_title',
      '`source_group_title` varchar(255) NULL',
    );
    await this.addColumnIfMissing(
      queryRunner,
      'exam_item_snapshots',
      'source_group_type',
      '`source_group_type` varchar(50) NULL',
    );
    await this.addColumnIfMissing(
      queryRunner,
      'exam_item_snapshots',
      'source_group_prompt',
      '`source_group_prompt` text NULL',
    );
    await this.addColumnIfMissing(
      queryRunner,
      'exam_item_snapshots',
      'source_group_file_id',
      '`source_group_file_id` bigint UNSIGNED NULL',
    );
    await this.addColumnIfMissing(
      queryRunner,
      'exam_item_snapshots',
      'source_group_file_storage_path',
      '`source_group_file_storage_path` varchar(500) NULL',
    );
    await this.addColumnIfMissing(
      queryRunner,
      'exam_item_snapshots',
      'source_group_file_caption',
      '`source_group_file_caption` varchar(500) NULL',
    );
    await this.addColumnIfMissing(
      queryRunner,
      'exam_item_snapshots',
      'source_group_file_alt_text',
      '`source_group_file_alt_text` varchar(500) NULL',
    );
    await this.addColumnIfMissing(
      queryRunner,
      'exam_item_snapshots',
      'source_group_item_order',
      '`source_group_item_order` int UNSIGNED NULL',
    );

    for (const table of ['exam_drafts', 'exams']) {
      await this.addColumnIfMissing(
        queryRunner,
        table,
        'duration_minutes',
        '`duration_minutes` int UNSIGNED NULL',
      );
      await this.addColumnIfMissing(
        queryRunner,
        table,
        'instructions',
        '`instructions` text NULL',
      );
      await this.addColumnIfMissing(
        queryRunner,
        table,
        'header_text',
        '`header_text` text NULL',
      );
      await this.addColumnIfMissing(
        queryRunner,
        table,
        'footer_text',
        '`footer_text` text NULL',
      );
    }
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    for (const table of ['exam_drafts', 'exams']) {
      await this.dropColumnIfExists(queryRunner, table, 'footer_text');
      await this.dropColumnIfExists(queryRunner, table, 'header_text');
      await this.dropColumnIfExists(queryRunner, table, 'instructions');
      await this.dropColumnIfExists(queryRunner, table, 'duration_minutes');
    }

    for (const column of [
      'source_group_item_order',
      'source_group_file_alt_text',
      'source_group_file_caption',
      'source_group_file_storage_path',
      'source_group_file_id',
      'source_group_prompt',
      'source_group_type',
      'source_group_title',
      'source_group_id',
      'question_file_alt_text',
      'question_file_caption',
      'question_file_storage_path',
      'question_file_id',
    ]) {
      await this.dropColumnIfExists(queryRunner, 'exam_item_snapshots', column);
    }

    await this.dropColumnIfExists(
      queryRunner,
      'exam_draft_items',
      'source_group_item_order',
    );
    await this.dropColumnIfExists(
      queryRunner,
      'exam_draft_items',
      'source_group_id',
    );
  }

  private async addColumnIfMissing(
    queryRunner: QueryRunner,
    table: string,
    column: string,
    definition: string,
  ): Promise<void> {
    const exists = await queryRunner.hasColumn(table, column);
    if (!exists) {
      await queryRunner.query(`ALTER TABLE \`${table}\` ADD COLUMN ${definition}`);
    }
  }

  private async dropColumnIfExists(
    queryRunner: QueryRunner,
    table: string,
    column: string,
  ): Promise<void> {
    const exists = await queryRunner.hasColumn(table, column);
    if (exists) {
      await queryRunner.query(`ALTER TABLE \`${table}\` DROP COLUMN \`${column}\``);
    }
  }
}
