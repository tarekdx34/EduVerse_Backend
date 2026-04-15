import { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateStudentFaceReferencesTable1766010000000
  implements MigrationInterface
{
  name = 'CreateStudentFaceReferencesTable1766010000000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      CREATE TABLE IF NOT EXISTS \`student_face_references\` (
        \`reference_id\` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
        \`user_id\` bigint UNSIGNED NOT NULL,
        \`bucket_name\` varchar(120) NOT NULL,
        \`storage_path\` varchar(500) NOT NULL,
        \`mime_type\` varchar(100) NOT NULL,
        \`file_size\` int UNSIGNED NOT NULL,
        \`is_primary\` tinyint NOT NULL DEFAULT 1,
        \`is_active\` tinyint NOT NULL DEFAULT 1,
        \`created_at\` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
        \`updated_at\` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
        PRIMARY KEY (\`reference_id\`),
        INDEX \`IDX_student_face_references_user_active\` (\`user_id\`, \`is_active\`),
        INDEX \`IDX_student_face_references_user_primary\` (\`user_id\`, \`is_primary\`),
        CONSTRAINT \`FK_student_face_references_user\`
          FOREIGN KEY (\`user_id\`) REFERENCES \`users\`(\`user_id\`)
          ON DELETE CASCADE ON UPDATE NO ACTION
      ) ENGINE=InnoDB
    `);
  }

  public async down(): Promise<void> {
    // No-op by design to avoid accidental deletion of face-reference data.
  }
}

