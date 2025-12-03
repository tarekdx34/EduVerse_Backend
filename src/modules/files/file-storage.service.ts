import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as fs from 'fs/promises';
import * as path from 'path';
import * as crypto from 'crypto';
import type { Multer } from 'multer';

@Injectable()
export class FileStorageService {
  private readonly logger = new Logger(FileStorageService.name);
  private readonly storagePath: string;
  private readonly maxFileSize: number;
  private readonly allowedFileTypes: string[];

  constructor(private configService: ConfigService) {
    this.storagePath =
      this.configService.get<string>('FILE_STORAGE_PATH') || './uploads/files';
    this.maxFileSize =
      parseInt(this.configService.get<string>('MAX_FILE_SIZE') || '10485760') ||
      10485760; // 10MB default
    const allowedTypes =
      this.configService.get<string>('ALLOWED_FILE_TYPES') ||
      'pdf,doc,docx,xls,xlsx,ppt,pptx,jpg,jpeg,png,gif,mp4,mp3,zip,rar';
    this.allowedFileTypes = allowedTypes.split(',').map((t) => t.trim());

    this.ensureStorageDirectoryExists();
  }

  private async ensureStorageDirectoryExists(): Promise<void> {
    try {
      await fs.mkdir(this.storagePath, { recursive: true });
      this.logger.log(`Storage directory initialized: ${this.storagePath}`);
    } catch (error) {
      this.logger.error(`Failed to create storage directory: ${error}`);
      throw error;
    }
  }

  async saveFile(
    file: Multer.File,
    subfolder?: string,
  ): Promise<string> {
    // Validate file size
    if (file.size > this.maxFileSize) {
      throw new Error(
        `File size ${file.size} exceeds maximum allowed size of ${this.maxFileSize} bytes`,
      );
    }

    // Validate file type
    const fileExtension = path.extname(file.originalname).slice(1).toLowerCase();
    if (!this.allowedFileTypes.includes(fileExtension)) {
      throw new Error(
        `File type .${fileExtension} is not allowed. Allowed types: ${this.allowedFileTypes.join(', ')}`,
      );
    }

    // Generate unique filename
    const uniqueId = crypto.randomBytes(16).toString('hex');
    const sanitizedOriginalName = this.sanitizeFileName(file.originalname);
    const fileName = `${uniqueId}-${sanitizedOriginalName}`;

    // Create subfolder path if provided
    const targetPath = subfolder
      ? path.join(this.storagePath, subfolder)
      : this.storagePath;

    // Ensure subfolder exists
    await fs.mkdir(targetPath, { recursive: true });

    // Full file path
    const filePath = path.join(targetPath, fileName);

    // Save file
    await fs.writeFile(filePath, file.buffer);

    // Return relative path from storage root
    return subfolder ? path.join(subfolder, fileName) : fileName;
  }

  async deleteFile(filePath: string): Promise<void> {
    const fullPath = path.join(this.storagePath, filePath);
    try {
      await fs.unlink(fullPath);
      this.logger.log(`File deleted: ${fullPath}`);
    } catch (error) {
      if ((error as NodeJS.ErrnoException).code !== 'ENOENT') {
        this.logger.error(`Failed to delete file: ${error}`);
        throw error;
      }
      // File doesn't exist, which is fine
    }
  }

  async fileExists(filePath: string): Promise<boolean> {
    const fullPath = path.join(this.storagePath, filePath);
    try {
      await fs.access(fullPath);
      return true;
    } catch {
      return false;
    }
  }

  getStoragePath(): string {
    return this.storagePath;
  }

  getMaxFileSize(): number {
    return this.maxFileSize;
  }

  getAllowedFileTypes(): string[] {
    return this.allowedFileTypes;
  }

  private sanitizeFileName(fileName: string): string {
    // Remove path traversal attempts and dangerous characters
    return fileName
      .replace(/[^a-zA-Z0-9._-]/g, '_')
      .replace(/\.\./g, '_')
      .substring(0, 255);
  }
}

