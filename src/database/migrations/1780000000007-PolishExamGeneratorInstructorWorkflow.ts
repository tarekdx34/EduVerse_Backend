import { MigrationInterface, QueryRunner } from 'typeorm';

export class PolishExamGeneratorInstructorWorkflow1780000000007
  implements MigrationInterface
{
  name = 'PolishExamGeneratorInstructorWorkflow1780000000007';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await this.addColumnIfMissing(
      queryRunner,
      'exam_draft_items',
      'origin_rule_json',
      '`origin_rule_json` json NULL',
    );

    for (const table of ['exam_drafts', 'exams']) {
      await this.addColumnIfMissing(
        queryRunner,
        table,
        'student_name_line',
        '`student_name_line` tinyint NOT NULL DEFAULT 1',
      );
      await this.addColumnIfMissing(
        queryRunner,
        table,
        'show_course_code',
        '`show_course_code` tinyint NOT NULL DEFAULT 1',
      );
      await this.addColumnIfMissing(
        queryRunner,
        table,
        'page_break_per_section',
        '`page_break_per_section` tinyint NOT NULL DEFAULT 0',
      );
      await this.addColumnIfMissing(
        queryRunner,
        table,
        'show_instructor_name',
        '`show_instructor_name` tinyint NOT NULL DEFAULT 0',
      );
      await this.addColumnIfMissing(
        queryRunner,
        table,
        'answer_key_style',
        "`answer_key_style` varchar(20) NOT NULL DEFAULT 'inline'",
      );
    }
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    for (const table of ['exam_drafts', 'exams']) {
      await this.dropColumnIfExists(queryRunner, table, 'answer_key_style');
      await this.dropColumnIfExists(queryRunner, table, 'show_instructor_name');
      await this.dropColumnIfExists(queryRunner, table, 'page_break_per_section');
      await this.dropColumnIfExists(queryRunner, table, 'show_course_code');
      await this.dropColumnIfExists(queryRunner, table, 'student_name_line');
    }
    await this.dropColumnIfExists(
      queryRunner,
      'exam_draft_items',
      'origin_rule_json',
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
