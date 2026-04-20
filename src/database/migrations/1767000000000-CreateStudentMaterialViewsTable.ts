import { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateStudentMaterialViewsTable1767000000000
  implements MigrationInterface
{
  name = 'CreateStudentMaterialViewsTable1767000000000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      CREATE TABLE \`student_material_views\` (
        \`view_id\` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
        \`user_id\` bigint UNSIGNED NOT NULL,
        \`course_id\` bigint UNSIGNED NOT NULL,
        \`material_id\` bigint UNSIGNED NOT NULL,
        \`views_count\` int NOT NULL DEFAULT 1,
        \`first_viewed_at\` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
        \`last_viewed_at\` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
        UNIQUE INDEX \`UQ_student_material_views_user_material\` (\`user_id\`, \`material_id\`),
        INDEX \`IDX_student_material_views_user_course\` (\`user_id\`, \`course_id\`),
        INDEX \`IDX_student_material_views_material\` (\`material_id\`),
        PRIMARY KEY (\`view_id\`)
      ) ENGINE=InnoDB
    `);

    await queryRunner.query(`
      ALTER TABLE \`student_material_views\`
      ADD CONSTRAINT \`FK_student_material_views_user\`
      FOREIGN KEY (\`user_id\`) REFERENCES \`users\`(\`user_id\`)
      ON DELETE CASCADE ON UPDATE NO ACTION
    `);

    await queryRunner.query(`
      ALTER TABLE \`student_material_views\`
      ADD CONSTRAINT \`FK_student_material_views_course\`
      FOREIGN KEY (\`course_id\`) REFERENCES \`courses\`(\`course_id\`)
      ON DELETE CASCADE ON UPDATE NO ACTION
    `);

    await queryRunner.query(`
      ALTER TABLE \`student_material_views\`
      ADD CONSTRAINT \`FK_student_material_views_material\`
      FOREIGN KEY (\`material_id\`) REFERENCES \`course_materials\`(\`material_id\`)
      ON DELETE CASCADE ON UPDATE NO ACTION
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      ALTER TABLE \`student_material_views\` DROP FOREIGN KEY \`FK_student_material_views_material\`
    `);
    await queryRunner.query(`
      ALTER TABLE \`student_material_views\` DROP FOREIGN KEY \`FK_student_material_views_course\`
    `);
    await queryRunner.query(`
      ALTER TABLE \`student_material_views\` DROP FOREIGN KEY \`FK_student_material_views_user\`
    `);
    await queryRunner.query('DROP INDEX `IDX_student_material_views_material` ON `student_material_views`');
    await queryRunner.query('DROP INDEX `IDX_student_material_views_user_course` ON `student_material_views`');
    await queryRunner.query('DROP INDEX `UQ_student_material_views_user_material` ON `student_material_views`');
    await queryRunner.query('DROP TABLE `student_material_views`');
  }
}
