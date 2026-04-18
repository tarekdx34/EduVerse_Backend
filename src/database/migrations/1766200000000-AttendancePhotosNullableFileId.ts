import { MigrationInterface, QueryRunner } from 'typeorm';

/**
 * AI class photos are processed from multipart upload without a `files` row yet.
 * Allow NULL file_id so attendance_photos does not reference a non-existent files.file_id.
 */
export class AttendancePhotosNullableFileId1766200000000
  implements MigrationInterface
{
  name = 'AttendancePhotosNullableFileId1766200000000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE \`attendance_photos\` DROP FOREIGN KEY \`attendance_photos_ibfk_2\``,
    );
    await queryRunner.query(
      `ALTER TABLE \`attendance_photos\` MODIFY \`file_id\` bigint UNSIGNED NULL`,
    );
    await queryRunner.query(
      `ALTER TABLE \`attendance_photos\` ADD CONSTRAINT \`attendance_photos_ibfk_2\` FOREIGN KEY (\`file_id\`) REFERENCES \`files\` (\`file_id\`) ON DELETE CASCADE`,
    );
  }

  public async down(): Promise<void> {
    // Not safely reversible if any row has file_id NULL.
  }
}
