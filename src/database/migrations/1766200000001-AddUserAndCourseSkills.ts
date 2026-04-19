import { MigrationInterface, QueryRunner } from 'typeorm';

export class AddUserAndCourseSkills1766200000001 implements MigrationInterface {
  name = 'AddUserAndCourseSkills1766200000001';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE \`users\` ADD \`academic_interests\` json NULL`
    );
    await queryRunner.query(
      `ALTER TABLE \`users\` ADD \`skills\` json NULL`
    );
    await queryRunner.query(
      `ALTER TABLE \`courses\` ADD \`skills\` json NULL`
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE \`courses\` DROP COLUMN \`skills\``
    );
    await queryRunner.query(
      `ALTER TABLE \`users\` DROP COLUMN \`skills\``
    );
    await queryRunner.query(
      `ALTER TABLE \`users\` DROP COLUMN \`academic_interests\``
    );
  }
}
