import { MigrationInterface, QueryRunner } from 'typeorm';

export class RecoverMissingScheduleTemplateSlotsTable1765457460000
  implements MigrationInterface
{
  name = 'RecoverMissingScheduleTemplateSlotsTable1765457460000';

  private async addForeignKeyIfMissing(
    queryRunner: QueryRunner,
    tableName: string,
    constraintName: string,
    statement: string,
  ): Promise<void> {
    const database = queryRunner.connection.options.database;
    if (typeof database !== 'string' || database.length === 0) {
      throw new Error('Database name is required to verify foreign key constraints.');
    }

    const existing = await queryRunner.query(
      `
        SELECT 1
        FROM information_schema.TABLE_CONSTRAINTS
        WHERE CONSTRAINT_SCHEMA = ?
          AND TABLE_NAME = ?
          AND CONSTRAINT_NAME = ?
          AND CONSTRAINT_TYPE = 'FOREIGN KEY'
        LIMIT 1
      `,
      [database, tableName, constraintName],
    );

    if (Array.isArray(existing) && existing.length > 0) {
      return;
    }

    await queryRunner.query(statement);
  }

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      CREATE TABLE IF NOT EXISTS \`schedule_templates\` (
        \`template_id\` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
        \`name\` varchar(255) NOT NULL,
        \`description\` text NULL,
        \`department_id\` bigint UNSIGNED NULL,
        \`schedule_type\` enum('LECTURE','LAB','TUTORIAL','HYBRID') NOT NULL DEFAULT 'LECTURE',
        \`created_by\` bigint UNSIGNED NOT NULL,
        \`is_active\` tinyint NOT NULL DEFAULT 1,
        \`created_at\` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
        \`updated_at\` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
        PRIMARY KEY (\`template_id\`),
        INDEX \`IDX_schedule_templates_department_id\` (\`department_id\`),
        INDEX \`IDX_schedule_templates_is_active\` (\`is_active\`),
        INDEX \`IDX_schedule_templates_created_by\` (\`created_by\`),
        INDEX \`IDX_schedule_templates_schedule_type\` (\`schedule_type\`),
        INDEX \`IDX_schedule_templates_is_active_department\` (\`is_active\`, \`department_id\`)
      ) ENGINE=InnoDB
    `);

    await queryRunner.query(`
      CREATE TABLE IF NOT EXISTS \`schedule_template_slots\` (
        \`slot_id\` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
        \`template_id\` bigint UNSIGNED NOT NULL,
        \`day_of_week\` enum('MONDAY','TUESDAY','WEDNESDAY','THURSDAY','FRIDAY','SATURDAY','SUNDAY') NOT NULL,
        \`start_time\` time NOT NULL,
        \`end_time\` time NOT NULL,
        \`slot_type\` enum('LECTURE','LAB','TUTORIAL','HYBRID','EXAM') NOT NULL,
        \`duration_minutes\` int NOT NULL,
        \`building\` varchar(100) NULL,
        \`room\` varchar(100) NULL,
        PRIMARY KEY (\`slot_id\`),
        INDEX \`IDX_schedule_template_slots_template_id\` (\`template_id\`),
        INDEX \`IDX_schedule_template_slots_day_time\` (\`day_of_week\`, \`start_time\`),
        INDEX \`IDX_schedule_template_slots_template_slot_type\` (\`template_id\`, \`slot_type\`)
      ) ENGINE=InnoDB
    `);

    await this.addForeignKeyIfMissing(
      queryRunner,
      'schedule_templates',
      'FK_schedule_templates_department',
      `
        ALTER TABLE \`schedule_templates\`
        ADD CONSTRAINT \`FK_schedule_templates_department\`
        FOREIGN KEY (\`department_id\`) REFERENCES \`departments\`(\`department_id\`)
        ON DELETE SET NULL ON UPDATE NO ACTION
      `,
    );

    await this.addForeignKeyIfMissing(
      queryRunner,
      'schedule_templates',
      'FK_schedule_templates_creator',
      `
        ALTER TABLE \`schedule_templates\`
        ADD CONSTRAINT \`FK_schedule_templates_creator\`
        FOREIGN KEY (\`created_by\`) REFERENCES \`users\`(\`user_id\`)
        ON DELETE CASCADE ON UPDATE NO ACTION
      `,
    );

    await this.addForeignKeyIfMissing(
      queryRunner,
      'schedule_template_slots',
      'FK_schedule_template_slots_template',
      `
        ALTER TABLE \`schedule_template_slots\`
        ADD CONSTRAINT \`FK_schedule_template_slots_template\`
        FOREIGN KEY (\`template_id\`) REFERENCES \`schedule_templates\`(\`template_id\`)
        ON DELETE CASCADE ON UPDATE NO ACTION
      `,
    );
  }

  public async down(): Promise<void> {
    // No-op by design: this recovery migration should not drop existing production data.
  }
}
