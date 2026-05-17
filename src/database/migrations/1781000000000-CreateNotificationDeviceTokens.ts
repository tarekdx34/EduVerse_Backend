import { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateNotificationDeviceTokens1781000000000
  implements MigrationInterface
{
  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      CREATE TABLE notification_device_tokens (
        device_token_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
        user_id BIGINT UNSIGNED NOT NULL,
        fcm_token TEXT NOT NULL,
        token_hash VARCHAR(64) NOT NULL,
        platform ENUM('android') NOT NULL DEFAULT 'android',
        device_id VARCHAR(255) NULL,
        device_name VARCHAR(255) NULL,
        app_version VARCHAR(64) NULL,
        locale VARCHAR(32) NULL,
        is_active TINYINT NOT NULL DEFAULT 1,
        last_seen_at TIMESTAMP NULL,
        created_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
        updated_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
        PRIMARY KEY (device_token_id),
        UNIQUE INDEX idx_notification_device_tokens_token_hash (token_hash),
        INDEX idx_notification_device_tokens_user_active (user_id, is_active),
        CONSTRAINT fk_notification_device_tokens_user
          FOREIGN KEY (user_id)
          REFERENCES users(user_id)
          ON DELETE CASCADE
      ) ENGINE=InnoDB
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query('DROP TABLE IF EXISTS notification_device_tokens');
  }
}
