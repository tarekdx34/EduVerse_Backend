import { MigrationInterface, QueryRunner } from "typeorm";

export class ExpandNotificationTypeEnum1777056804622 implements MigrationInterface {
    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`
            ALTER TABLE notifications 
            MODIFY COLUMN notification_type ENUM(
                'announcement', 'grade', 'assignment', 'message', 
                'deadline', 'system', 'lab', 'quiz', 'material', 
                'community', 'discussion', 'enrollment', 'schedule', 'office_hours'
            ) NOT NULL
        `);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`
            ALTER TABLE notifications 
            MODIFY COLUMN notification_type ENUM(
                'announcement', 'grade', 'assignment', 'message', 'deadline', 'system'
            ) NOT NULL
        `);
    }
}
