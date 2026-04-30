import { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateQuestionBankAndExams1778000000000 implements MigrationInterface {
  name = 'CreateQuestionBankAndExams1778000000000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      CREATE TABLE \`course_chapters\` (
        \`chapter_id\` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
        \`course_id\` bigint UNSIGNED NOT NULL,
        \`name\` varchar(200) NOT NULL,
        \`chapter_order\` int UNSIGNED NOT NULL,
        \`is_active\` tinyint NOT NULL DEFAULT 1,
        \`created_at\` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
        \`updated_at\` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
        UNIQUE INDEX \`UQ_course_chapters_course_order\` (\`course_id\`, \`chapter_order\`),
        UNIQUE INDEX \`UQ_course_chapters_course_name\` (\`course_id\`, \`name\`),
        PRIMARY KEY (\`chapter_id\`)
      ) ENGINE=InnoDB
    `);

    await queryRunner.query(`
      CREATE TABLE \`question_bank_questions\` (
        \`question_id\` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
        \`course_id\` bigint UNSIGNED NOT NULL,
        \`chapter_id\` bigint UNSIGNED NOT NULL,
        \`bloom_level\` enum('remembering','understanding','applying','analyzing','evaluating','creating') NOT NULL,
        \`question_type\` enum('written','mcq','true_false','fill_blanks','essay') NOT NULL,
        \`difficulty\` enum('easy','medium','hard') NOT NULL,
        \`question_text\` text NULL,
        \`question_file_id\` bigint UNSIGNED NULL,
        \`expected_answer_text\` text NULL,
        \`hints\` text NULL,
        \`status\` enum('draft','approved','archived') NOT NULL DEFAULT 'draft',
        \`created_by\` bigint UNSIGNED NOT NULL,
        \`updated_by\` bigint UNSIGNED NULL,
        \`created_at\` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
        \`updated_at\` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
        INDEX \`IDX_qb_course_chapter_type_diff_bloom_status_id\` (\`course_id\`, \`chapter_id\`, \`question_type\`, \`difficulty\`, \`bloom_level\`, \`status\`, \`question_id\`),
        INDEX \`IDX_qb_course_bloom_status_id\` (\`course_id\`, \`bloom_level\`, \`status\`, \`question_id\`),
        PRIMARY KEY (\`question_id\`)
      ) ENGINE=InnoDB
    `);

    await queryRunner.query(`
      CREATE TABLE \`question_bank_options\` (
        \`option_id\` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
        \`question_id\` bigint UNSIGNED NOT NULL,
        \`option_text\` text NOT NULL,
        \`is_correct\` tinyint NOT NULL DEFAULT 0,
        \`option_order\` int UNSIGNED NOT NULL DEFAULT 0,
        INDEX \`IDX_qb_options_question_order\` (\`question_id\`, \`option_order\`),
        PRIMARY KEY (\`option_id\`)
      ) ENGINE=InnoDB
    `);

    await queryRunner.query(`
      CREATE TABLE \`question_bank_fill_blanks\` (
        \`blank_id\` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
        \`question_id\` bigint UNSIGNED NOT NULL,
        \`blank_key\` varchar(100) NOT NULL,
        \`acceptable_answer\` text NOT NULL,
        \`is_case_sensitive\` tinyint NOT NULL DEFAULT 0,
        PRIMARY KEY (\`blank_id\`)
      ) ENGINE=InnoDB
    `);

    await queryRunner.query(`
      CREATE TABLE \`exam_drafts\` (
        \`draft_id\` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
        \`course_id\` bigint UNSIGNED NOT NULL,
        \`title\` varchar(255) NOT NULL,
        \`generation_request_json\` json NOT NULL,
        \`generated_by\` bigint UNSIGNED NOT NULL,
        \`seed\` varchar(100) NOT NULL,
        \`expires_at\` datetime NOT NULL,
        \`created_at\` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
        \`updated_at\` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
        PRIMARY KEY (\`draft_id\`)
      ) ENGINE=InnoDB
    `);

    await queryRunner.query(`
      CREATE TABLE \`exam_draft_items\` (
        \`draft_item_id\` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
        \`draft_id\` bigint UNSIGNED NOT NULL,
        \`question_id\` bigint UNSIGNED NOT NULL,
        \`chapter_id\` bigint UNSIGNED NOT NULL,
        \`question_type\` enum('written','mcq','true_false','fill_blanks','essay') NOT NULL,
        \`difficulty\` enum('easy','medium','hard') NOT NULL,
        \`bloom_level\` enum('remembering','understanding','applying','analyzing','evaluating','creating') NOT NULL,
        \`weight\` decimal(7,2) NOT NULL,
        \`item_order\` int UNSIGNED NOT NULL,
        INDEX \`IDX_exam_draft_items_draft_order\` (\`draft_id\`, \`item_order\`),
        PRIMARY KEY (\`draft_item_id\`)
      ) ENGINE=InnoDB
    `);

    await queryRunner.query(`
      CREATE TABLE \`exams\` (
        \`exam_id\` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
        \`course_id\` bigint UNSIGNED NOT NULL,
        \`title\` varchar(255) NOT NULL,
        \`total_weight\` decimal(10,2) NOT NULL DEFAULT '0.00',
        \`status\` enum('draft','published','archived') NOT NULL DEFAULT 'draft',
        \`snapshot_json\` json NOT NULL,
        \`created_by\` bigint UNSIGNED NOT NULL,
        \`created_at\` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
        \`updated_at\` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
        PRIMARY KEY (\`exam_id\`)
      ) ENGINE=InnoDB
    `);

    await queryRunner.query(`
      CREATE TABLE \`exam_items\` (
        \`exam_item_id\` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
        \`exam_id\` bigint UNSIGNED NOT NULL,
        \`question_id\` bigint UNSIGNED NOT NULL,
        \`weight\` decimal(7,2) NOT NULL,
        \`item_order\` int UNSIGNED NOT NULL,
        PRIMARY KEY (\`exam_item_id\`)
      ) ENGINE=InnoDB
    `);

    await queryRunner.query(`
      ALTER TABLE \`course_chapters\`
      ADD CONSTRAINT \`FK_course_chapters_course\`
      FOREIGN KEY (\`course_id\`) REFERENCES \`courses\`(\`course_id\`) ON DELETE CASCADE ON UPDATE NO ACTION
    `);
    await queryRunner.query(`
      ALTER TABLE \`question_bank_questions\`
      ADD CONSTRAINT \`FK_qb_questions_course\`
      FOREIGN KEY (\`course_id\`) REFERENCES \`courses\`(\`course_id\`) ON DELETE CASCADE ON UPDATE NO ACTION
    `);
    await queryRunner.query(`
      ALTER TABLE \`question_bank_questions\`
      ADD CONSTRAINT \`FK_qb_questions_chapter\`
      FOREIGN KEY (\`chapter_id\`) REFERENCES \`course_chapters\`(\`chapter_id\`) ON DELETE CASCADE ON UPDATE NO ACTION
    `);
    await queryRunner.query(`
      ALTER TABLE \`question_bank_questions\`
      ADD CONSTRAINT \`FK_qb_questions_file\`
      FOREIGN KEY (\`question_file_id\`) REFERENCES \`files\`(\`file_id\`) ON DELETE SET NULL ON UPDATE NO ACTION
    `);
    await queryRunner.query(`
      ALTER TABLE \`question_bank_options\`
      ADD CONSTRAINT \`FK_qb_options_question\`
      FOREIGN KEY (\`question_id\`) REFERENCES \`question_bank_questions\`(\`question_id\`) ON DELETE CASCADE ON UPDATE NO ACTION
    `);
    await queryRunner.query(`
      ALTER TABLE \`question_bank_fill_blanks\`
      ADD CONSTRAINT \`FK_qb_blanks_question\`
      FOREIGN KEY (\`question_id\`) REFERENCES \`question_bank_questions\`(\`question_id\`) ON DELETE CASCADE ON UPDATE NO ACTION
    `);
    await queryRunner.query(`
      ALTER TABLE \`exam_drafts\`
      ADD CONSTRAINT \`FK_exam_drafts_course\`
      FOREIGN KEY (\`course_id\`) REFERENCES \`courses\`(\`course_id\`) ON DELETE CASCADE ON UPDATE NO ACTION
    `);
    await queryRunner.query(`
      ALTER TABLE \`exam_draft_items\`
      ADD CONSTRAINT \`FK_exam_draft_items_draft\`
      FOREIGN KEY (\`draft_id\`) REFERENCES \`exam_drafts\`(\`draft_id\`) ON DELETE CASCADE ON UPDATE NO ACTION
    `);
    await queryRunner.query(`
      ALTER TABLE \`exam_draft_items\`
      ADD CONSTRAINT \`FK_exam_draft_items_question\`
      FOREIGN KEY (\`question_id\`) REFERENCES \`question_bank_questions\`(\`question_id\`) ON DELETE RESTRICT ON UPDATE NO ACTION
    `);
    await queryRunner.query(`
      ALTER TABLE \`exams\`
      ADD CONSTRAINT \`FK_exams_course\`
      FOREIGN KEY (\`course_id\`) REFERENCES \`courses\`(\`course_id\`) ON DELETE CASCADE ON UPDATE NO ACTION
    `);
    await queryRunner.query(`
      ALTER TABLE \`exam_items\`
      ADD CONSTRAINT \`FK_exam_items_exam\`
      FOREIGN KEY (\`exam_id\`) REFERENCES \`exams\`(\`exam_id\`) ON DELETE CASCADE ON UPDATE NO ACTION
    `);
    await queryRunner.query(`
      ALTER TABLE \`exam_items\`
      ADD CONSTRAINT \`FK_exam_items_question\`
      FOREIGN KEY (\`question_id\`) REFERENCES \`question_bank_questions\`(\`question_id\`) ON DELETE RESTRICT ON UPDATE NO ACTION
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query('ALTER TABLE `exam_items` DROP FOREIGN KEY `FK_exam_items_question`');
    await queryRunner.query('ALTER TABLE `exam_items` DROP FOREIGN KEY `FK_exam_items_exam`');
    await queryRunner.query('ALTER TABLE `exams` DROP FOREIGN KEY `FK_exams_course`');
    await queryRunner.query('ALTER TABLE `exam_draft_items` DROP FOREIGN KEY `FK_exam_draft_items_question`');
    await queryRunner.query('ALTER TABLE `exam_draft_items` DROP FOREIGN KEY `FK_exam_draft_items_draft`');
    await queryRunner.query('ALTER TABLE `exam_drafts` DROP FOREIGN KEY `FK_exam_drafts_course`');
    await queryRunner.query('ALTER TABLE `question_bank_fill_blanks` DROP FOREIGN KEY `FK_qb_blanks_question`');
    await queryRunner.query('ALTER TABLE `question_bank_options` DROP FOREIGN KEY `FK_qb_options_question`');
    await queryRunner.query('ALTER TABLE `question_bank_questions` DROP FOREIGN KEY `FK_qb_questions_file`');
    await queryRunner.query('ALTER TABLE `question_bank_questions` DROP FOREIGN KEY `FK_qb_questions_chapter`');
    await queryRunner.query('ALTER TABLE `question_bank_questions` DROP FOREIGN KEY `FK_qb_questions_course`');
    await queryRunner.query('ALTER TABLE `course_chapters` DROP FOREIGN KEY `FK_course_chapters_course`');

    await queryRunner.query('DROP TABLE `exam_items`');
    await queryRunner.query('DROP TABLE `exams`');
    await queryRunner.query('DROP TABLE `exam_draft_items`');
    await queryRunner.query('DROP TABLE `exam_drafts`');
    await queryRunner.query('DROP TABLE `question_bank_fill_blanks`');
    await queryRunner.query('DROP TABLE `question_bank_options`');
    await queryRunner.query('DROP TABLE `question_bank_questions`');
    await queryRunner.query('DROP TABLE `course_chapters`');
  }
}

