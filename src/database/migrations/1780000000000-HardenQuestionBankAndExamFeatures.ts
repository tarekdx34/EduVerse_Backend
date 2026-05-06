import { MigrationInterface, QueryRunner } from 'typeorm';

export class HardenQuestionBankAndExamFeatures1780000000000
  implements MigrationInterface
{
  name = 'HardenQuestionBankAndExamFeatures1780000000000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await this.addColumnIfMissing(
      queryRunner,
      'question_bank_questions',
      'reviewed_by',
      '`reviewed_by` bigint UNSIGNED NULL',
    );
    await this.addColumnIfMissing(
      queryRunner,
      'question_bank_questions',
      'reviewed_at',
      '`reviewed_at` datetime NULL',
    );
    await this.addColumnIfMissing(
      queryRunner,
      'question_bank_questions',
      'review_comment',
      '`review_comment` text NULL',
    );
    await this.addColumnIfMissing(
      queryRunner,
      'question_bank_questions',
      'deleted_at',
      '`deleted_at` datetime(6) NULL',
    );

    await queryRunner.query(`
      CREATE TABLE IF NOT EXISTS \`question_bank_question_attachments\` (
        \`attachment_id\` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
        \`question_id\` bigint UNSIGNED NOT NULL,
        \`file_id\` bigint UNSIGNED NOT NULL,
        \`attachment_type\` enum('image','document','audio','video') NOT NULL DEFAULT 'image',
        \`caption\` varchar(500) NULL,
        \`alt_text\` varchar(500) NULL,
        \`display_order\` int UNSIGNED NOT NULL DEFAULT 0,
        \`is_primary\` tinyint NOT NULL DEFAULT 0,
        \`storage_path\` varchar(500) NULL,
        \`created_by\` bigint UNSIGNED NOT NULL,
        \`created_at\` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
        \`updated_at\` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
        \`deleted_at\` datetime(6) NULL,
        UNIQUE INDEX \`UQ_qb_question_attachments_question_order\` (\`question_id\`, \`display_order\`),
        INDEX \`IDX_qb_question_attachments_file\` (\`file_id\`),
        PRIMARY KEY (\`attachment_id\`)
      ) ENGINE=InnoDB
    `);
    await this.addForeignKeyIfMissing(
      queryRunner,
      'question_bank_question_attachments',
      'FK_qb_question_attachments_question',
      'FOREIGN KEY (`question_id`) REFERENCES `question_bank_questions`(`question_id`) ON DELETE CASCADE ON UPDATE NO ACTION',
    );
    await this.addForeignKeyIfMissing(
      queryRunner,
      'question_bank_question_attachments',
      'FK_qb_question_attachments_file',
      'FOREIGN KEY (`file_id`) REFERENCES `files`(`file_id`) ON DELETE RESTRICT ON UPDATE NO ACTION',
    );

    await queryRunner.query(`
      INSERT IGNORE INTO \`question_bank_question_attachments\`
        (\`question_id\`, \`file_id\`, \`attachment_type\`, \`display_order\`, \`is_primary\`, \`storage_path\`, \`created_by\`, \`created_at\`, \`updated_at\`)
      SELECT
        q.\`question_id\`,
        q.\`question_file_id\`,
        'image',
        0,
        1,
        CONCAT(
          'question-bank/files/',
          q.\`question_file_id\`,
          CASE
            WHEN f.\`mime_type\` = 'image/png' THEN '.png'
            WHEN f.\`mime_type\` = 'image/webp' THEN '.webp'
            WHEN f.\`mime_type\` = 'image/gif' THEN '.gif'
            ELSE '.jpg'
          END
        ),
        q.\`created_by\`,
        q.\`created_at\`,
        q.\`updated_at\`
      FROM \`question_bank_questions\` q
      LEFT JOIN \`files\` f ON f.\`file_id\` = q.\`question_file_id\`
      WHERE q.\`question_file_id\` IS NOT NULL
    `);

    await queryRunner.query(`
      CREATE TABLE IF NOT EXISTS \`question_bank_question_groups\` (
        \`group_id\` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
        \`course_id\` bigint UNSIGNED NOT NULL,
        \`chapter_id\` bigint UNSIGNED NOT NULL,
        \`title\` varchar(255) NULL,
        \`shared_prompt\` text NULL,
        \`shared_file_id\` bigint UNSIGNED NULL,
        \`group_type\` enum('passage','case_study','image_set','multipart','other') NOT NULL DEFAULT 'other',
        \`created_by\` bigint UNSIGNED NOT NULL,
        \`created_at\` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
        \`updated_at\` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
        \`deleted_at\` datetime(6) NULL,
        INDEX \`IDX_qb_question_groups_course_chapter\` (\`course_id\`, \`chapter_id\`),
        PRIMARY KEY (\`group_id\`)
      ) ENGINE=InnoDB
    `);
    await this.addForeignKeyIfMissing(
      queryRunner,
      'question_bank_question_groups',
      'FK_qb_question_groups_course',
      'FOREIGN KEY (`course_id`) REFERENCES `courses`(`course_id`) ON DELETE CASCADE ON UPDATE NO ACTION',
    );
    await this.addForeignKeyIfMissing(
      queryRunner,
      'question_bank_question_groups',
      'FK_qb_question_groups_chapter',
      'FOREIGN KEY (`chapter_id`) REFERENCES `course_chapters`(`chapter_id`) ON DELETE CASCADE ON UPDATE NO ACTION',
    );
    await this.addForeignKeyIfMissing(
      queryRunner,
      'question_bank_question_groups',
      'FK_qb_question_groups_file',
      'FOREIGN KEY (`shared_file_id`) REFERENCES `files`(`file_id`) ON DELETE SET NULL ON UPDATE NO ACTION',
    );

    await queryRunner.query(`
      CREATE TABLE IF NOT EXISTS \`question_bank_question_group_items\` (
        \`group_item_id\` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
        \`group_id\` bigint UNSIGNED NOT NULL,
        \`question_id\` bigint UNSIGNED NOT NULL,
        \`item_order\` int UNSIGNED NOT NULL DEFAULT 0,
        \`created_at\` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
        UNIQUE INDEX \`UQ_qb_group_items_group_question\` (\`group_id\`, \`question_id\`),
        UNIQUE INDEX \`UQ_qb_group_items_group_order\` (\`group_id\`, \`item_order\`),
        PRIMARY KEY (\`group_item_id\`)
      ) ENGINE=InnoDB
    `);
    await this.addForeignKeyIfMissing(
      queryRunner,
      'question_bank_question_group_items',
      'FK_qb_group_items_group',
      'FOREIGN KEY (`group_id`) REFERENCES `question_bank_question_groups`(`group_id`) ON DELETE CASCADE ON UPDATE NO ACTION',
    );
    await this.addForeignKeyIfMissing(
      queryRunner,
      'question_bank_question_group_items',
      'FK_qb_group_items_question',
      'FOREIGN KEY (`question_id`) REFERENCES `question_bank_questions`(`question_id`) ON DELETE CASCADE ON UPDATE NO ACTION',
    );

    await queryRunner.query(`
      CREATE TABLE IF NOT EXISTS \`question_bank_question_versions\` (
        \`version_id\` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
        \`question_id\` bigint UNSIGNED NOT NULL,
        \`version_number\` int UNSIGNED NOT NULL,
        \`snapshot_json\` json NOT NULL,
        \`created_by\` bigint UNSIGNED NOT NULL,
        \`created_at\` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
        UNIQUE INDEX \`UQ_qb_question_versions_question_number\` (\`question_id\`, \`version_number\`),
        PRIMARY KEY (\`version_id\`)
      ) ENGINE=InnoDB
    `);
    await this.addForeignKeyIfMissing(
      queryRunner,
      'question_bank_question_versions',
      'FK_qb_question_versions_question',
      'FOREIGN KEY (`question_id`) REFERENCES `question_bank_questions`(`question_id`) ON DELETE CASCADE ON UPDATE NO ACTION',
    );

    await queryRunner.query(`
      CREATE TABLE IF NOT EXISTS \`question_bank_review_events\` (
        \`review_event_id\` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
        \`question_id\` bigint UNSIGNED NOT NULL,
        \`from_status\` enum('draft','approved','archived') NULL,
        \`to_status\` enum('draft','approved','archived') NOT NULL,
        \`comment\` text NULL,
        \`created_by\` bigint UNSIGNED NOT NULL,
        \`created_at\` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
        INDEX \`IDX_qb_review_events_question_created\` (\`question_id\`, \`created_at\`),
        PRIMARY KEY (\`review_event_id\`)
      ) ENGINE=InnoDB
    `);
    await this.addForeignKeyIfMissing(
      queryRunner,
      'question_bank_review_events',
      'FK_qb_review_events_question',
      'FOREIGN KEY (`question_id`) REFERENCES `question_bank_questions`(`question_id`) ON DELETE CASCADE ON UPDATE NO ACTION',
    );

    await this.addColumnIfMissing(
      queryRunner,
      'exam_drafts',
      'total_marks',
      '`total_marks` decimal(10,2) NULL',
    );
    await this.addColumnIfMissing(
      queryRunner,
      'exam_drafts',
      'mark_distribution_mode',
      "`mark_distribution_mode` enum('manual','weight_normalized','equal') NOT NULL DEFAULT 'weight_normalized'",
    );
    await this.addColumnIfMissing(
      queryRunner,
      'exam_drafts',
      'rounding_policy',
      "`rounding_policy` enum('none','nearest_0_25','nearest_0_5','nearest_1') NOT NULL DEFAULT 'none'",
    );
    await this.addColumnIfMissing(
      queryRunner,
      'exam_drafts',
      'status',
      "`status` enum('open','finalized','expired','cancelled','failed') NOT NULL DEFAULT 'open'",
    );
    await this.addColumnIfMissing(
      queryRunner,
      'exam_drafts',
      'finalized_exam_id',
      '`finalized_exam_id` bigint UNSIGNED NULL',
    );
    await this.addColumnIfMissing(
      queryRunner,
      'exam_drafts',
      'finalized_by',
      '`finalized_by` bigint UNSIGNED NULL',
    );
    await this.addColumnIfMissing(
      queryRunner,
      'exam_drafts',
      'finalized_at',
      '`finalized_at` datetime NULL',
    );
    await this.addColumnIfMissing(
      queryRunner,
      'exam_drafts',
      'failure_reason',
      '`failure_reason` text NULL',
    );
    await queryRunner.query(`
      UPDATE \`exam_drafts\`
      SET \`status\` = 'expired'
      WHERE \`expires_at\` < NOW()
        AND \`status\` = 'open'
    `);

    await queryRunner.query(`
      CREATE TABLE IF NOT EXISTS \`exam_draft_sections\` (
        \`draft_section_id\` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
        \`draft_id\` bigint UNSIGNED NOT NULL,
        \`title\` varchar(255) NOT NULL,
        \`instructions\` text NULL,
        \`section_order\` int UNSIGNED NOT NULL,
        \`total_marks\` decimal(10,2) NULL,
        \`answer_policy\` enum('answer_all','answer_any') NOT NULL DEFAULT 'answer_all',
        \`required_answer_count\` int UNSIGNED NULL,
        \`created_at\` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
        \`updated_at\` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
        UNIQUE INDEX \`UQ_exam_draft_sections_draft_order\` (\`draft_id\`, \`section_order\`),
        PRIMARY KEY (\`draft_section_id\`)
      ) ENGINE=InnoDB
    `);
    await this.addForeignKeyIfMissing(
      queryRunner,
      'exam_draft_sections',
      'FK_exam_draft_sections_draft',
      'FOREIGN KEY (`draft_id`) REFERENCES `exam_drafts`(`draft_id`) ON DELETE CASCADE ON UPDATE NO ACTION',
    );

    await this.addColumnIfMissing(
      queryRunner,
      'exam_draft_items',
      'draft_section_id',
      '`draft_section_id` bigint UNSIGNED NULL AFTER `question_id`',
    );
    await this.addColumnIfMissing(
      queryRunner,
      'exam_draft_items',
      'weight_units',
      '`weight_units` decimal(7,2) NULL AFTER `weight`',
    );
    await this.addColumnIfMissing(
      queryRunner,
      'exam_draft_items',
      'marks',
      '`marks` decimal(7,2) NULL AFTER `weight_units`',
    );
    await queryRunner.query(`
      UPDATE \`exam_draft_items\`
      SET \`weight_units\` = COALESCE(\`weight_units\`, \`weight\`),
          \`marks\` = COALESCE(\`marks\`, \`weight\`)
    `);
    await this.addForeignKeyIfMissing(
      queryRunner,
      'exam_draft_items',
      'FK_exam_draft_items_section',
      'FOREIGN KEY (`draft_section_id`) REFERENCES `exam_draft_sections`(`draft_section_id`) ON DELETE SET NULL ON UPDATE NO ACTION',
    );

    await this.addColumnIfMissing(
      queryRunner,
      'exams',
      'total_marks',
      '`total_marks` decimal(10,2) NULL AFTER `total_weight`',
    );
    await this.addColumnIfMissing(
      queryRunner,
      'exams',
      'published_by',
      '`published_by` bigint UNSIGNED NULL',
    );
    await this.addColumnIfMissing(
      queryRunner,
      'exams',
      'published_at',
      '`published_at` datetime NULL',
    );
    await this.addColumnIfMissing(
      queryRunner,
      'exams',
      'archived_by',
      '`archived_by` bigint UNSIGNED NULL',
    );
    await this.addColumnIfMissing(
      queryRunner,
      'exams',
      'archived_at',
      '`archived_at` datetime NULL',
    );
    await this.addColumnIfMissing(
      queryRunner,
      'exams',
      'status_reason',
      '`status_reason` text NULL',
    );
    await queryRunner.query(`
      UPDATE \`exams\`
      SET \`total_marks\` = COALESCE(\`total_marks\`, \`total_weight\`)
    `);

    await queryRunner.query(`
      CREATE TABLE IF NOT EXISTS \`exam_sections\` (
        \`section_id\` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
        \`exam_id\` bigint UNSIGNED NOT NULL,
        \`title\` varchar(255) NOT NULL,
        \`instructions\` text NULL,
        \`section_order\` int UNSIGNED NOT NULL,
        \`total_marks\` decimal(10,2) NULL,
        \`answer_policy\` enum('answer_all','answer_any') NOT NULL DEFAULT 'answer_all',
        \`required_answer_count\` int UNSIGNED NULL,
        \`created_at\` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
        \`updated_at\` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
        UNIQUE INDEX \`UQ_exam_sections_exam_order\` (\`exam_id\`, \`section_order\`),
        PRIMARY KEY (\`section_id\`)
      ) ENGINE=InnoDB
    `);
    await this.addForeignKeyIfMissing(
      queryRunner,
      'exam_sections',
      'FK_exam_sections_exam',
      'FOREIGN KEY (`exam_id`) REFERENCES `exams`(`exam_id`) ON DELETE CASCADE ON UPDATE NO ACTION',
    );

    await this.addColumnIfMissing(
      queryRunner,
      'exam_items',
      'section_id',
      '`section_id` bigint UNSIGNED NULL AFTER `question_id`',
    );
    await this.addColumnIfMissing(
      queryRunner,
      'exam_items',
      'weight_units',
      '`weight_units` decimal(7,2) NULL AFTER `weight`',
    );
    await this.addColumnIfMissing(
      queryRunner,
      'exam_items',
      'marks',
      '`marks` decimal(7,2) NULL AFTER `weight_units`',
    );
    await queryRunner.query(`
      UPDATE \`exam_items\`
      SET \`weight_units\` = COALESCE(\`weight_units\`, \`weight\`),
          \`marks\` = COALESCE(\`marks\`, \`weight\`)
    `);
    await this.addForeignKeyIfMissing(
      queryRunner,
      'exam_items',
      'FK_exam_items_section',
      'FOREIGN KEY (`section_id`) REFERENCES `exam_sections`(`section_id`) ON DELETE SET NULL ON UPDATE NO ACTION',
    );

    await queryRunner.query(`
      CREATE TABLE IF NOT EXISTS \`exam_item_snapshots\` (
        \`snapshot_id\` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
        \`exam_item_id\` bigint UNSIGNED NOT NULL,
        \`source_question_id\` bigint UNSIGNED NOT NULL,
        \`source_question_version_id\` bigint UNSIGNED NULL,
        \`section_id\` bigint UNSIGNED NULL,
        \`question_type\` enum('written','mcq','true_false','fill_blanks','essay') NOT NULL,
        \`question_text\` text NULL,
        \`options_json\` json NULL,
        \`fill_blanks_json\` json NULL,
        \`expected_answer_text\` text NULL,
        \`hints\` text NULL,
        \`attachments_json\` json NULL,
        \`marks\` decimal(7,2) NULL,
        \`item_order\` int UNSIGNED NOT NULL,
        \`created_at\` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
        UNIQUE INDEX \`UQ_exam_item_snapshots_item\` (\`exam_item_id\`),
        PRIMARY KEY (\`snapshot_id\`)
      ) ENGINE=InnoDB
    `);
    await this.addForeignKeyIfMissing(
      queryRunner,
      'exam_item_snapshots',
      'FK_exam_item_snapshots_item',
      'FOREIGN KEY (`exam_item_id`) REFERENCES `exam_items`(`exam_item_id`) ON DELETE CASCADE ON UPDATE NO ACTION',
    );

    await queryRunner.query(`
      CREATE TABLE IF NOT EXISTS \`exam_exports\` (
        \`export_id\` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
        \`exam_id\` bigint UNSIGNED NOT NULL,
        \`format\` enum('html_doc','docx','pdf') NOT NULL,
        \`status\` enum('pending','completed','failed') NOT NULL DEFAULT 'pending',
        \`file_id\` bigint UNSIGNED NULL,
        \`requested_by\` bigint UNSIGNED NOT NULL,
        \`created_at\` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
        \`completed_at\` datetime NULL,
        \`failure_reason\` text NULL,
        INDEX \`IDX_exam_exports_exam_created\` (\`exam_id\`, \`created_at\`),
        PRIMARY KEY (\`export_id\`)
      ) ENGINE=InnoDB
    `);
    await this.addForeignKeyIfMissing(
      queryRunner,
      'exam_exports',
      'FK_exam_exports_exam',
      'FOREIGN KEY (`exam_id`) REFERENCES `exams`(`exam_id`) ON DELETE CASCADE ON UPDATE NO ACTION',
    );
    await this.addForeignKeyIfMissing(
      queryRunner,
      'exam_exports',
      'FK_exam_exports_file',
      'FOREIGN KEY (`file_id`) REFERENCES `files`(`file_id`) ON DELETE SET NULL ON UPDATE NO ACTION',
    );

    await this.addUniqueIndexIfMissing(
      queryRunner,
      'question_bank_options',
      'UQ_qb_options_question_order',
      '`question_id`, `option_order`',
    );
    await this.addUniqueIndexIfMissing(
      queryRunner,
      'question_bank_fill_blanks',
      'UQ_qb_blanks_question_key',
      '`question_id`, `blank_key`',
    );
    await this.addUniqueIndexIfMissing(
      queryRunner,
      'exam_draft_items',
      'UQ_exam_draft_items_draft_order',
      '`draft_id`, `item_order`',
    );
    await this.addUniqueIndexIfMissing(
      queryRunner,
      'exam_draft_items',
      'UQ_exam_draft_items_draft_question',
      '`draft_id`, `question_id`',
    );
    await this.addUniqueIndexIfMissing(
      queryRunner,
      'exam_items',
      'UQ_exam_items_exam_order',
      '`exam_id`, `item_order`',
    );
    await this.addUniqueIndexIfMissing(
      queryRunner,
      'exam_items',
      'UQ_exam_items_exam_question',
      '`exam_id`, `question_id`',
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await this.dropIndexIfExists(queryRunner, 'exam_items', 'UQ_exam_items_exam_question');
    await this.dropIndexIfExists(queryRunner, 'exam_items', 'UQ_exam_items_exam_order');
    await this.dropIndexIfExists(queryRunner, 'exam_draft_items', 'UQ_exam_draft_items_draft_question');
    await this.dropIndexIfExists(queryRunner, 'exam_draft_items', 'UQ_exam_draft_items_draft_order');
    await this.dropIndexIfExists(queryRunner, 'question_bank_fill_blanks', 'UQ_qb_blanks_question_key');
    await this.dropIndexIfExists(queryRunner, 'question_bank_options', 'UQ_qb_options_question_order');

    await this.dropTableIfExists(queryRunner, 'exam_exports');
    await this.dropTableIfExists(queryRunner, 'exam_item_snapshots');
    await this.dropForeignKeyIfExists(queryRunner, 'exam_items', 'FK_exam_items_section');
    await this.dropColumnIfExists(queryRunner, 'exam_items', 'marks');
    await this.dropColumnIfExists(queryRunner, 'exam_items', 'weight_units');
    await this.dropColumnIfExists(queryRunner, 'exam_items', 'section_id');
    await this.dropTableIfExists(queryRunner, 'exam_sections');
    await this.dropColumnIfExists(queryRunner, 'exams', 'status_reason');
    await this.dropColumnIfExists(queryRunner, 'exams', 'archived_at');
    await this.dropColumnIfExists(queryRunner, 'exams', 'archived_by');
    await this.dropColumnIfExists(queryRunner, 'exams', 'published_at');
    await this.dropColumnIfExists(queryRunner, 'exams', 'published_by');
    await this.dropColumnIfExists(queryRunner, 'exams', 'total_marks');

    await this.dropForeignKeyIfExists(queryRunner, 'exam_draft_items', 'FK_exam_draft_items_section');
    await this.dropColumnIfExists(queryRunner, 'exam_draft_items', 'marks');
    await this.dropColumnIfExists(queryRunner, 'exam_draft_items', 'weight_units');
    await this.dropColumnIfExists(queryRunner, 'exam_draft_items', 'draft_section_id');
    await this.dropTableIfExists(queryRunner, 'exam_draft_sections');
    await this.dropColumnIfExists(queryRunner, 'exam_drafts', 'failure_reason');
    await this.dropColumnIfExists(queryRunner, 'exam_drafts', 'finalized_at');
    await this.dropColumnIfExists(queryRunner, 'exam_drafts', 'finalized_by');
    await this.dropColumnIfExists(queryRunner, 'exam_drafts', 'finalized_exam_id');
    await this.dropColumnIfExists(queryRunner, 'exam_drafts', 'status');
    await this.dropColumnIfExists(queryRunner, 'exam_drafts', 'rounding_policy');
    await this.dropColumnIfExists(queryRunner, 'exam_drafts', 'mark_distribution_mode');
    await this.dropColumnIfExists(queryRunner, 'exam_drafts', 'total_marks');

    await this.dropTableIfExists(queryRunner, 'question_bank_review_events');
    await this.dropTableIfExists(queryRunner, 'question_bank_question_versions');
    await this.dropTableIfExists(queryRunner, 'question_bank_question_group_items');
    await this.dropTableIfExists(queryRunner, 'question_bank_question_groups');
    await this.dropTableIfExists(queryRunner, 'question_bank_question_attachments');
    await this.dropColumnIfExists(queryRunner, 'question_bank_questions', 'deleted_at');
    await this.dropColumnIfExists(queryRunner, 'question_bank_questions', 'review_comment');
    await this.dropColumnIfExists(queryRunner, 'question_bank_questions', 'reviewed_at');
    await this.dropColumnIfExists(queryRunner, 'question_bank_questions', 'reviewed_by');
  }

  private async addColumnIfMissing(
    queryRunner: QueryRunner,
    tableName: string,
    columnName: string,
    definition: string,
  ): Promise<void> {
    if (!(await queryRunner.hasColumn(tableName, columnName))) {
      await queryRunner.query(`ALTER TABLE \`${tableName}\` ADD COLUMN ${definition}`);
    }
  }

  private async dropColumnIfExists(
    queryRunner: QueryRunner,
    tableName: string,
    columnName: string,
  ): Promise<void> {
    if (await queryRunner.hasColumn(tableName, columnName)) {
      await queryRunner.query(`ALTER TABLE \`${tableName}\` DROP COLUMN \`${columnName}\``);
    }
  }

  private async addForeignKeyIfMissing(
    queryRunner: QueryRunner,
    tableName: string,
    constraintName: string,
    definition: string,
  ): Promise<void> {
    if (!(await this.constraintExists(queryRunner, tableName, constraintName))) {
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
    if (await this.constraintExists(queryRunner, tableName, constraintName)) {
      await queryRunner.query(
        `ALTER TABLE \`${tableName}\` DROP FOREIGN KEY \`${constraintName}\``,
      );
    }
  }

  private async addUniqueIndexIfMissing(
    queryRunner: QueryRunner,
    tableName: string,
    indexName: string,
    columns: string,
  ): Promise<void> {
    if (!(await this.indexExists(queryRunner, tableName, indexName))) {
      await queryRunner.query(
        `ALTER TABLE \`${tableName}\` ADD UNIQUE INDEX \`${indexName}\` (${columns})`,
      );
    }
  }

  private async dropIndexIfExists(
    queryRunner: QueryRunner,
    tableName: string,
    indexName: string,
  ): Promise<void> {
    if (await this.indexExists(queryRunner, tableName, indexName)) {
      await queryRunner.query(`DROP INDEX \`${indexName}\` ON \`${tableName}\``);
    }
  }

  private async dropTableIfExists(
    queryRunner: QueryRunner,
    tableName: string,
  ): Promise<void> {
    if (await queryRunner.hasTable(tableName)) {
      await queryRunner.query(`DROP TABLE \`${tableName}\``);
    }
  }

  private async constraintExists(
    queryRunner: QueryRunner,
    tableName: string,
    constraintName: string,
  ): Promise<boolean> {
    const rows = await queryRunner.query(
      `
        SELECT CONSTRAINT_NAME
        FROM information_schema.TABLE_CONSTRAINTS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = ?
          AND CONSTRAINT_NAME = ?
      `,
      [tableName, constraintName],
    );
    return rows.length > 0;
  }

  private async indexExists(
    queryRunner: QueryRunner,
    tableName: string,
    indexName: string,
  ): Promise<boolean> {
    const rows = await queryRunner.query(
      `
        SELECT INDEX_NAME
        FROM information_schema.STATISTICS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = ?
          AND INDEX_NAME = ?
      `,
      [tableName, indexName],
    );
    return rows.length > 0;
  }
}
