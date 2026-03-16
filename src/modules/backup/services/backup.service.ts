import { Injectable, Logger, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ConfigService } from '@nestjs/config';
import { BackupRecord, BackupStatus, BackupType } from '../entities/backup-record.entity';
import * as path from 'path';
import * as fs from 'fs';
import { exec } from 'child_process';
import { promisify } from 'util';

const execAsync = promisify(exec);

@Injectable()
export class BackupService {
  private readonly logger = new Logger(BackupService.name);
  private readonly backupDir: string;

  constructor(
    @InjectRepository(BackupRecord)
    private backupRepo: Repository<BackupRecord>,
    private configService: ConfigService,
  ) {
    this.backupDir = path.join(process.cwd(), 'backups');
    if (!fs.existsSync(this.backupDir)) {
      fs.mkdirSync(this.backupDir, { recursive: true });
    }
  }

  async listBackups() {
    const data = await this.backupRepo.find({
      order: { createdAt: 'DESC' },
      relations: ['creator'],
    });
    return { data };
  }

  async createBackup(userId: number) {
    const dbConfig = this.configService.get('database');
    const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
    const fileName = `backup_${timestamp}.sql`;
    const filePath = path.join(this.backupDir, fileName);

    // Create a record
    const record = this.backupRepo.create({
      fileName,
      fileSizeBytes: 0,
      type: BackupType.MANUAL,
      status: BackupStatus.IN_PROGRESS,
      createdBy: userId,
    });
    const saved = await this.backupRepo.save(record);

    try {
      const host = dbConfig?.host || 'localhost';
      const port = dbConfig?.port || 3306;
      const user = dbConfig?.username || 'root';
      const password = dbConfig?.password || '';
      const database = dbConfig?.database || 'eduverse_db';

      let cmd = `mysqldump -h ${host} -P ${port} -u ${user}`;
      if (password) cmd += ` -p${password}`;
      cmd += ` ${database} > "${filePath}"`;

      await execAsync(cmd);

      const stats = fs.statSync(filePath);
      saved.fileSizeBytes = stats.size;
      saved.status = BackupStatus.COMPLETED;
      saved.completedAt = new Date();
      await this.backupRepo.save(saved);

      this.logger.log(`Backup created: ${fileName} (${stats.size} bytes)`);
      return { data: saved, message: 'Backup created successfully' };
    } catch (error) {
      saved.status = BackupStatus.FAILED;
      await this.backupRepo.save(saved);
      this.logger.error(`Backup failed: ${error.message}`);
      return { data: saved, message: `Backup failed: ${error.message}` };
    }
  }

  async deleteBackup(id: number) {
    const record = await this.backupRepo.findOne({ where: { id } });
    if (!record) {
      throw new NotFoundException(`Backup #${id} not found`);
    }

    // Remove file if exists
    const filePath = path.join(this.backupDir, record.fileName);
    if (fs.existsSync(filePath)) {
      fs.unlinkSync(filePath);
    }

    await this.backupRepo.remove(record);
    return { message: `Backup #${id} deleted successfully` };
  }

  async getBackupDetails(id: number) {
    const record = await this.backupRepo.findOne({
      where: { id },
      relations: ['creator'],
    });
    if (!record) {
      throw new NotFoundException(`Backup #${id} not found`);
    }
    return { data: record };
  }
}
