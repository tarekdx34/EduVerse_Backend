import { MigrationInterface, QueryRunner } from 'typeorm';

export class AddExamPaperTemplates1780000000008 implements MigrationInterface {
  name = 'AddExamPaperTemplates1780000000008';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      CREATE TABLE IF NOT EXISTS \`exam_paper_templates\` (
        \`template_id\` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
        \`owner_instructor_id\` bigint UNSIGNED NOT NULL,
        \`course_id\` bigint UNSIGNED NULL,
        \`name\` varchar(255) NOT NULL,
        \`layout_mode\` enum('structured', 'free', 'hybrid') NOT NULL DEFAULT 'structured',
        \`page_size\` varchar(20) NOT NULL DEFAULT 'A4',
        \`orientation\` varchar(20) NOT NULL DEFAULT 'portrait',
        \`margins_json\` json NULL,
        \`header_json\` json NULL,
        \`trailing_json\` json NULL,
        \`footer_json\` json NULL,
        \`created_at\` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
        \`updated_at\` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
        INDEX \`IDX_exam_paper_templates_owner\` (\`owner_instructor_id\`),
        INDEX \`IDX_exam_paper_templates_course\` (\`course_id\`),
        PRIMARY KEY (\`template_id\`)
      ) ENGINE=InnoDB
    `);
    await this.addForeignKeyIfMissing(
      queryRunner,
      'exam_paper_templates',
      'FK_exam_paper_templates_course',
      'ALTER TABLE `exam_paper_templates` ADD CONSTRAINT `FK_exam_paper_templates_course` FOREIGN KEY (`course_id`) REFERENCES `courses`(`course_id`) ON DELETE CASCADE ON UPDATE NO ACTION',
    );

    for (const table of ['exams', 'exam_drafts']) {
      await this.addColumnIfMissing(
        queryRunner,
        table,
        'paper_template_id',
        '`paper_template_id` bigint UNSIGNED NULL',
      );
      await this.addColumnIfMissing(
        queryRunner,
        table,
        'paper_template_snapshot_json',
        '`paper_template_snapshot_json` json NULL',
      );
      await this.addForeignKeyIfMissing(
        queryRunner,
        table,
        `FK_${table}_paper_template`,
        `ALTER TABLE \`${table}\` ADD CONSTRAINT \`FK_${table}_paper_template\` FOREIGN KEY (\`paper_template_id\`) REFERENCES \`exam_paper_templates\`(\`template_id\`) ON DELETE SET NULL ON UPDATE NO ACTION`,
      );
    }
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    for (const table of ['exam_drafts', 'exams']) {
      await this.dropForeignKeyIfExists(
        queryRunner,
        table,
        `FK_${table}_paper_template`,
      );
      await this.dropColumnIfExists(
        queryRunner,
        table,
        'paper_template_snapshot_json',
      );
      await this.dropColumnIfExists(queryRunner, table, 'paper_template_id');
    }
    await this.dropForeignKeyIfExists(
      queryRunner,
      'exam_paper_templates',
      'FK_exam_paper_templates_course',
    );
    await queryRunner.query('DROP TABLE IF EXISTS `exam_paper_templates`');
  }

  private async addColumnIfMissing(
    queryRunner: QueryRunner,
    table: string,
    column: string,
    definition: string,
  ): Promise<void> {
    if (!(await queryRunner.hasColumn(table, column))) {
      await queryRunner.query(`ALTER TABLE \`${table}\` ADD COLUMN ${definition}`);
    }
  }

  private async dropColumnIfExists(
    queryRunner: QueryRunner,
    table: string,
    column: string,
  ): Promise<void> {
    if (await queryRunner.hasColumn(table, column)) {
      await queryRunner.query(`ALTER TABLE \`${table}\` DROP COLUMN \`${column}\``);
    }
  }

  private async addForeignKeyIfMissing(
    queryRunner: QueryRunner,
    table: string,
    name: string,
    sql: string,
  ): Promise<void> {
    const rows = await queryRunner.query(
      `
        SELECT 1
        FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = ?
          AND CONSTRAINT_NAME = ?
        LIMIT 1
      `,
      [table, name],
    );
    if (!rows.length) {
      await queryRunner.query(sql);
    }
  }

  private async dropForeignKeyIfExists(
    queryRunner: QueryRunner,
    table: string,
    name: string,
  ): Promise<void> {
    const rows = await queryRunner.query(
      `
        SELECT 1
        FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = ?
          AND CONSTRAINT_NAME = ?
        LIMIT 1
      `,
      [table, name],
    );
    if (rows.length) {
      await queryRunner.query(`ALTER TABLE \`${table}\` DROP FOREIGN KEY \`${name}\``);
    }
  }
}
