import { MigrationInterface, QueryRunner } from 'typeorm';

export class MakeQuestionGroupChapterOptional1780000000004
  implements MigrationInterface
{
  name = 'MakeQuestionGroupChapterOptional1780000000004';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await this.dropForeignKeyIfExists(
      queryRunner,
      'question_bank_question_groups',
      'FK_qb_question_groups_chapter',
    );
    await queryRunner.query(`
      ALTER TABLE \`question_bank_question_groups\`
      MODIFY COLUMN \`chapter_id\` bigint UNSIGNED NULL
    `);
    await this.addForeignKeyIfMissing(
      queryRunner,
      'question_bank_question_groups',
      'FK_qb_question_groups_chapter',
      'FOREIGN KEY (`chapter_id`) REFERENCES `course_chapters`(`chapter_id`) ON DELETE SET NULL ON UPDATE NO ACTION',
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      UPDATE \`question_bank_question_groups\` g
      JOIN (
        SELECT \`course_id\`, MIN(\`chapter_id\`) AS \`chapter_id\`
        FROM \`course_chapters\`
        GROUP BY \`course_id\`
      ) c ON c.\`course_id\` = g.\`course_id\`
      SET g.\`chapter_id\` = c.\`chapter_id\`
      WHERE g.\`chapter_id\` IS NULL
    `);
    await this.dropForeignKeyIfExists(
      queryRunner,
      'question_bank_question_groups',
      'FK_qb_question_groups_chapter',
    );
    await queryRunner.query(`
      ALTER TABLE \`question_bank_question_groups\`
      MODIFY COLUMN \`chapter_id\` bigint UNSIGNED NOT NULL
    `);
    await this.addForeignKeyIfMissing(
      queryRunner,
      'question_bank_question_groups',
      'FK_qb_question_groups_chapter',
      'FOREIGN KEY (`chapter_id`) REFERENCES `course_chapters`(`chapter_id`) ON DELETE CASCADE ON UPDATE NO ACTION',
    );
  }

  private async addForeignKeyIfMissing(
    queryRunner: QueryRunner,
    tableName: string,
    constraintName: string,
    definition: string,
  ): Promise<void> {
    const exists = await this.constraintExists(
      queryRunner,
      tableName,
      constraintName,
    );
    if (!exists) {
      await queryRunner.query(
        `ALTER TABLE \`${tableName}\` ADD CONSTRAINT \`${constraintName}\` ${definition}`,
      );
    }
  }

  private async dropForeignKeyIfExists(
    queryRunner: QueryRunner,
    tableName: string,
    constraintName: string,
  ): Promise<void> {
    const exists = await this.constraintExists(
      queryRunner,
      tableName,
      constraintName,
    );
    if (exists) {
      await queryRunner.query(
        `ALTER TABLE \`${tableName}\` DROP FOREIGN KEY \`${constraintName}\``,
      );
    }
  }

  private async constraintExists(
    queryRunner: QueryRunner,
    tableName: string,
    constraintName: string,
  ): Promise<boolean> {
    const rows = (await queryRunner.query(
      `
        SELECT 1
        FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = ?
          AND CONSTRAINT_NAME = ?
        LIMIT 1
      `,
      [tableName, constraintName],
    )) as unknown[];
    return rows.length > 0;
  }
}
