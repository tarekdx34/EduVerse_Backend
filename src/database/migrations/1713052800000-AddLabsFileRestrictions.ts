import { MigrationInterface, QueryRunner } from 'typeorm';

export class AddLabsFileRestrictions1713052800000 implements MigrationInterface {
  name = 'AddLabsFileRestrictions1713052800000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    // Check if allowed_file_types column already exists
    const columnsExist = await queryRunner.query(
      `
        SELECT COLUMN_NAME
        FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = 'labs'
          AND COLUMN_NAME IN ('allowed_file_types', 'max_file_size_mb')
      `,
    );

    const hasAllowedFileTypes = columnsExist.some(
      (col: any) => col.COLUMN_NAME === 'allowed_file_types',
    );
    const hasMaxFileSizeMb = columnsExist.some(
      (col: any) => col.COLUMN_NAME === 'max_file_size_mb',
    );

    if (!hasAllowedFileTypes) {
      await queryRunner.query(`
        ALTER TABLE \`labs\`
        ADD COLUMN \`allowed_file_types\` VARCHAR(255) NULL 
        COMMENT 'Comma-separated list of allowed file extensions for student submissions'
      `);
    }

    if (!hasMaxFileSizeMb) {
      await queryRunner.query(`
        ALTER TABLE \`labs\`
        ADD COLUMN \`max_file_size_mb\` FLOAT NULL 
        COMMENT 'Maximum file size in MB for student submissions'
      `);
    }
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      'ALTER TABLE `labs` DROP COLUMN IF EXISTS `allowed_file_types`',
    );
    await queryRunner.query(
      'ALTER TABLE `labs` DROP COLUMN IF EXISTS `max_file_size_mb`',
    );
  }
}
