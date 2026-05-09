import { Injectable, Logger } from '@nestjs/common';
import { Cron } from '@nestjs/schedule';
import { DataSource } from 'typeorm';
import { FilesService } from '../files/files.service';

@Injectable()
export class QuestionBankCleanupService {
  private readonly logger = new Logger(QuestionBankCleanupService.name);

  constructor(
    private readonly dataSource: DataSource,
    private readonly filesService: FilesService,
  ) {}

  @Cron('0 2 * * *')
  async auditQuestionBankFiles(): Promise<void> {
    const orphanFiles = await this.dataSource.query<
      Array<{
        fileId: number;
        filePath: string;
        mimeType: string;
        fileExtension?: string;
      }>
    >(`
      SELECT f.file_id AS fileId,
             f.file_path AS filePath,
             f.mime_type AS mimeType,
             f.file_extension AS fileExtension
      FROM files f
      WHERE f.status = 'active'
        AND f.mime_type LIKE 'image/%'
        AND f.uploaded_at < DATE_SUB(NOW(), INTERVAL 1 DAY)
        AND NOT EXISTS (
          SELECT 1 FROM question_bank_questions q
          WHERE q.question_file_id = f.file_id
        )
        AND NOT EXISTS (
          SELECT 1 FROM question_bank_question_attachments a
          WHERE a.file_id = f.file_id AND a.deleted_at IS NULL
        )
        AND NOT EXISTS (
          SELECT 1 FROM question_bank_question_groups g
          WHERE g.shared_file_id = f.file_id AND g.deleted_at IS NULL
        )
    `);

    for (const file of orphanFiles) {
      await this.filesService.deleteStorageArtifactsForFile(file);
    }

    const deleteResult = (await this.dataSource.query(`
      UPDATE files f
      SET f.status = 'deleted',
          f.deleted_at = COALESCE(f.deleted_at, NOW())
      WHERE f.status = 'active'
        AND f.mime_type LIKE 'image/%'
        AND f.uploaded_at < DATE_SUB(NOW(), INTERVAL 1 DAY)
        AND NOT EXISTS (
          SELECT 1 FROM question_bank_questions q
          WHERE q.question_file_id = f.file_id
        )
        AND NOT EXISTS (
          SELECT 1 FROM question_bank_question_attachments a
          WHERE a.file_id = f.file_id AND a.deleted_at IS NULL
        )
        AND NOT EXISTS (
          SELECT 1 FROM question_bank_question_groups g
          WHERE g.shared_file_id = f.file_id AND g.deleted_at IS NULL
        )
    `)) as { affectedRows?: string | number };

    const [brokenAttachmentRow] = await this.dataSource.query<
      Array<{ brokenAttachmentCount: string | number }>
    >(`
      SELECT COUNT(*) AS brokenAttachmentCount
      FROM question_bank_question_attachments a
      LEFT JOIN files f ON f.file_id = a.file_id
      WHERE a.deleted_at IS NULL
        AND f.file_id IS NULL
    `);

    const orphanCount = Number(deleteResult?.affectedRows || 0);
    const brokenAttachmentCount = Number(
      brokenAttachmentRow?.brokenAttachmentCount || 0,
    );
    if (orphanCount || brokenAttachmentCount) {
      this.logger.warn(
        `Question bank cleanup handled orphanFiles=${orphanCount} brokenAttachments=${brokenAttachmentCount}`,
      );
    }
  }
}
