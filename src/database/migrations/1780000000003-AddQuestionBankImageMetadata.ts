import { MigrationInterface, QueryRunner } from 'typeorm';

export class AddQuestionBankImageMetadata1780000000003
  implements MigrationInterface
{
  name = 'AddQuestionBankImageMetadata1780000000003';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await this.addColumnIfMissing(
      queryRunner,
      'question_bank_questions',
      'question_file_caption',
      '`question_file_caption` varchar(500) NULL',
    );
    await this.addColumnIfMissing(
      queryRunner,
      'question_bank_questions',
      'question_file_alt_text',
      '`question_file_alt_text` varchar(500) NULL',
    );
    await this.addColumnIfMissing(
      queryRunner,
      'question_bank_question_groups',
      'shared_file_caption',
      '`shared_file_caption` varchar(500) NULL',
    );
    await this.addColumnIfMissing(
      queryRunner,
      'question_bank_question_groups',
      'shared_file_alt_text',
      '`shared_file_alt_text` varchar(500) NULL',
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await this.dropColumnIfExists(
      queryRunner,
      'question_bank_question_groups',
      'shared_file_alt_text',
    );
    await this.dropColumnIfExists(
      queryRunner,
      'question_bank_question_groups',
      'shared_file_caption',
    );
    await this.dropColumnIfExists(
      queryRunner,
      'question_bank_questions',
      'question_file_alt_text',
    );
    await this.dropColumnIfExists(
      queryRunner,
      'question_bank_questions',
      'question_file_caption',
    );
  }

  private async addColumnIfMissing(
    queryRunner: QueryRunner,
    tableName: string,
    columnName: string,
    definition: string,
  ): Promise<void> {
    const hasColumn = await queryRunner.hasColumn(tableName, columnName);
    if (!hasColumn) {
      await queryRunner.query(
        `ALTER TABLE \`${tableName}\` ADD COLUMN ${definition}`,
      );
    }
  }

  private async dropColumnIfExists(
    queryRunner: QueryRunner,
    tableName: string,
    columnName: string,
  ): Promise<void> {
    const hasColumn = await queryRunner.hasColumn(tableName, columnName);
    if (hasColumn) {
      await queryRunner.query(
        `ALTER TABLE \`${tableName}\` DROP COLUMN \`${columnName}\``,
      );
    }
  }
}
