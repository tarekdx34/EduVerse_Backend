import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { File } from './entities/file.entity';
import { FileVersion } from './entities/file-version.entity';
import { Folder } from './entities/folder.entity';
import { FileStorageService } from './file-storage.service';
import { FilePermissionService } from './file-permission.service';
import { PermissionType } from './entities/file-permission.entity';
import { FileNotFoundException } from './exceptions/file-not-found.exception';
import { FileSizeExceededException } from './exceptions/file-size-exceeded.exception';
import { InvalidFileTypeException } from './exceptions/invalid-file-type.exception';
import { FileResponseDto } from './dto/file-response.dto';
import { FileVersionResponseDto } from './dto/file-version-response.dto';
import { FileSearchDto } from './dto/file-search.dto';
import * as path from 'path';
import type { Multer } from 'multer';

@Injectable()
export class FilesService {
  constructor(
    @InjectRepository(File)
    private fileRepository: Repository<File>,
    @InjectRepository(FileVersion)
    private fileVersionRepository: Repository<FileVersion>,
    @InjectRepository(Folder)
    private folderRepository: Repository<Folder>,
    private fileStorageService: FileStorageService,
    private filePermissionService: FilePermissionService,
  ) {}

  async uploadFile(
    file: Multer.File,
    userId: number,
    folderId?: number,
    courseId?: number,
  ): Promise<FileResponseDto> {
    // Validate folder exists if provided
    if (folderId) {
      const folder = await this.folderRepository.findOne({
        where: { folderId },
      });
      if (!folder) {
        throw new NotFoundException(`Folder with ID ${folderId} not found`);
      }
    }

    // Validate file size
    if (file.size > this.fileStorageService.getMaxFileSize()) {
      throw new FileSizeExceededException(
        this.fileStorageService.getMaxFileSize(),
      );
    }

    // Validate file type
    const fileExtension = file.originalname.split('.').pop()?.toLowerCase();
    const allowedTypes = this.fileStorageService.getAllowedFileTypes();
    if (fileExtension && !allowedTypes.includes(fileExtension)) {
      throw new InvalidFileTypeException(allowedTypes);
    }

    // Save file to storage
    const storagePath = await this.fileStorageService.saveFile(
      file,
      folderId ? `folder-${folderId}` : undefined,
    );

    // Create file record
    const fileEntity = this.fileRepository.create({
      fileName: storagePath.split('/').pop() || storagePath,
      originalFileName: file.originalname,
      filePath: storagePath,
      fileSize: file.size,
      mimeType: file.mimetype,
      folderId,
      courseId,
      uploadedBy: userId,
    });

    const savedFile = await this.fileRepository.save(fileEntity);

    // Load relations for response
    const fileWithRelations = await this.fileRepository.findOne({
      where: { fileId: savedFile.fileId },
      relations: ['uploader'],
    });

    if (!fileWithRelations) {
      throw new FileNotFoundException(savedFile.fileId);
    }

    return this.mapToFileResponseDto(fileWithRelations);
  }

  async getFile(fileId: number, userId: number): Promise<FileResponseDto> {
    const file = await this.fileRepository.findOne({
      where: { fileId },
      relations: ['uploader', 'versions'],
    });

    if (!file) {
      throw new FileNotFoundException(fileId);
    }

    // Check READ permission
    await this.filePermissionService.requirePermission(
      fileId,
      userId,
      PermissionType.READ,
    );

    return this.mapToFileResponseDto(file);
  }

  async downloadFile(fileId: number, userId: number): Promise<{
    file: File;
    filePath: string;
  }> {
    const file = await this.fileRepository.findOne({
      where: { fileId },
      relations: ['uploader'],
    });

    if (!file) {
      throw new FileNotFoundException(fileId);
    }

    // Check READ permission
    await this.filePermissionService.requirePermission(
      fileId,
      userId,
      PermissionType.READ,
    );

    // Return file info and path
    const fullPath = path.join(
      this.fileStorageService.getStoragePath(),
      file.filePath,
    );

    return { file, filePath: fullPath };
  }

  async updateFile(
    fileId: number,
    userId: number,
    updates: {
      fileName?: string;
      folderId?: number;
    },
  ): Promise<FileResponseDto> {
    const file = await this.fileRepository.findOne({
      where: { fileId },
      relations: ['uploader'],
    });

    if (!file) {
      throw new FileNotFoundException(fileId);
    }

    // Check WRITE permission
    await this.filePermissionService.requirePermission(
      fileId,
      userId,
      PermissionType.WRITE,
    );

    // Validate folder if changing
    if (updates.folderId !== undefined && updates.folderId !== file.folderId) {
      if (updates.folderId !== null) {
        const folder = await this.folderRepository.findOne({
          where: { folderId: updates.folderId },
        });
        if (!folder) {
          throw new NotFoundException(
            `Folder with ID ${updates.folderId} not found`,
          );
        }
      }
    }

    Object.assign(file, updates);
    const updatedFile = await this.fileRepository.save(file);

    return this.mapToFileResponseDto(updatedFile);
  }

  async deleteFile(fileId: number, userId: number): Promise<void> {
    const file = await this.fileRepository.findOne({
      where: { fileId },
    });

    if (!file) {
      throw new FileNotFoundException(fileId);
    }

    // Check DELETE permission
    await this.filePermissionService.requirePermission(
      fileId,
      userId,
      PermissionType.DELETE,
    );

    // Soft delete file record
    await this.fileRepository.softDelete(fileId);

    // Delete physical file (optional - you might want to keep it for recovery)
    // await this.fileStorageService.deleteFile(file.filePath);
  }

  async createVersion(
    fileId: number,
    file: Multer.File,
    userId: number,
  ): Promise<FileVersionResponseDto> {
    const originalFile = await this.fileRepository.findOne({
      where: { fileId },
      relations: ['versions'],
    });

    if (!originalFile) {
      throw new FileNotFoundException(fileId);
    }

    // Check WRITE permission
    await this.filePermissionService.requirePermission(
      fileId,
      userId,
      PermissionType.WRITE,
    );

    // Get next version number
    const existingVersions = await this.fileVersionRepository.find({
      where: { fileId },
      order: { versionNumber: 'DESC' },
    });

    const nextVersionNumber =
      existingVersions.length > 0
        ? existingVersions[0].versionNumber + 1
        : 1;

    // Save new version file
    const storagePath = await this.fileStorageService.saveFile(
      file,
      `versions/file-${fileId}`,
    );

    // Create version record
    const version = this.fileVersionRepository.create({
      fileId,
      versionNumber: nextVersionNumber,
      filePath: storagePath,
      fileSize: file.size,
      uploadedBy: userId,
    });

    const savedVersion = await this.fileVersionRepository.save(version);

    // Update main file record
    originalFile.fileName = storagePath.split('/').pop() || storagePath;
    originalFile.filePath = storagePath;
    originalFile.fileSize = file.size;
    originalFile.mimeType = file.mimetype;
    await this.fileRepository.save(originalFile);

    const versionWithRelations = await this.fileVersionRepository.findOne({
      where: { versionId: savedVersion.versionId },
      relations: ['uploader'],
    });

    if (!versionWithRelations) {
      throw new NotFoundException(
        `Version ${savedVersion.versionId} not found for file ${fileId}`,
      );
    }

    return this.mapToFileVersionResponseDto(versionWithRelations);
  }

  async getFileVersions(fileId: number, userId: number): Promise<FileVersionResponseDto[]> {
    const file = await this.fileRepository.findOne({
      where: { fileId },
    });

    if (!file) {
      throw new FileNotFoundException(fileId);
    }

    // Check READ permission
    await this.filePermissionService.requirePermission(
      fileId,
      userId,
      PermissionType.READ,
    );

    const versions = await this.fileVersionRepository.find({
      where: { fileId },
      relations: ['uploader'],
      order: { versionNumber: 'DESC' },
    });

    return versions.map((version) => this.mapToFileVersionResponseDto(version));
  }

  async downloadVersion(
    fileId: number,
    versionId: number,
    userId: number,
  ): Promise<{ version: FileVersion; filePath: string }> {
    const file = await this.fileRepository.findOne({
      where: { fileId },
    });

    if (!file) {
      throw new FileNotFoundException(fileId);
    }

    // Check READ permission
    await this.filePermissionService.requirePermission(
      fileId,
      userId,
      PermissionType.READ,
    );

    const version = await this.fileVersionRepository.findOne({
      where: { versionId, fileId },
    });

    if (!version) {
      throw new NotFoundException(
        `Version ${versionId} not found for file ${fileId}`,
      );
    }

    const fullPath = path.join(
      this.fileStorageService.getStoragePath(),
      version.filePath,
    );

    return { version, filePath: fullPath };
  }

  async searchFiles(
    searchDto: FileSearchDto,
    userId: number,
  ): Promise<FileResponseDto[]> {
    const query = this.fileRepository
      .createQueryBuilder('file')
      .leftJoinAndSelect('file.uploader', 'uploader')
      .where('file.deletedAt IS NULL');

    if (searchDto.name) {
      query.andWhere('file.originalFileName LIKE :name', {
        name: `%${searchDto.name}%`,
      });
    }

    if (searchDto.type) {
      query.andWhere('file.mimeType LIKE :type', {
        type: `%${searchDto.type}%`,
      });
    }

    if (searchDto.courseId) {
      query.andWhere('file.courseId = :courseId', {
        courseId: searchDto.courseId,
      });
    }

    if (searchDto.folderId) {
      query.andWhere('file.folderId = :folderId', {
        folderId: searchDto.folderId,
      });
    }

    // Filter by user's accessible files
    // This is simplified - in production, you'd want to check permissions
    query.andWhere(
      '(file.uploadedBy = :userId OR file.courseId IS NOT NULL)',
      { userId },
    );

    const page = searchDto.page || 1;
    const limit = searchDto.limit || 20;
    query.skip((page - 1) * limit).take(limit);

    const files = await query.getMany();

    // Filter by permissions
    const accessibleFiles: File[] = [];
    for (const file of files) {
      try {
        await this.filePermissionService.requirePermission(
          file.fileId,
          userId,
          PermissionType.READ,
        );
        accessibleFiles.push(file);
      } catch {
        // Skip files without permission
      }
    }

    return accessibleFiles.map((file) => this.mapToFileResponseDto(file));
  }

  async getRecentFiles(userId: number, limit = 10): Promise<FileResponseDto[]> {
    const files = await this.fileRepository.find({
      where: { uploadedBy: userId },
      relations: ['uploader'],
      order: { updatedAt: 'DESC' },
      take: limit,
    });

    return files.map((file) => this.mapToFileResponseDto(file));
  }

  async getSharedFiles(userId: number): Promise<FileResponseDto[]> {
    // Get files shared with user via permissions
    // This requires accessing the permission repository through the service
    // For now, we'll get all files the user has permissions for
    const allFiles = await this.fileRepository.find({
      relations: ['uploader', 'permissions'],
    });

    const sharedFiles: File[] = [];
    for (const file of allFiles) {
      if (file.uploadedBy !== userId) {
        try {
          await this.filePermissionService.requirePermission(
            file.fileId,
            userId,
            PermissionType.READ,
          );
          sharedFiles.push(file);
        } catch {
          // Skip files without permission
        }
      }
    }

    return sharedFiles.map((file) => this.mapToFileResponseDto(file));
  }

  private mapToFileResponseDto(file: File): FileResponseDto {
    return {
      fileId: file.fileId,
      fileName: file.fileName,
      originalFileName: file.originalFileName,
      fileSize: file.fileSize,
      mimeType: file.mimeType,
      folderId: file.folderId,
      courseId: file.courseId,
      uploadedBy: file.uploadedBy,
      uploaderName: file.uploader
        ? `${file.uploader.firstName} ${file.uploader.lastName}`
        : undefined,
      createdAt: file.createdAt,
      versionCount: file.versions?.length,
    };
  }

  private mapToFileVersionResponseDto(
    version: FileVersion,
  ): FileVersionResponseDto {
    return {
      versionId: version.versionId,
      fileId: version.fileId,
      versionNumber: version.versionNumber,
      fileSize: version.fileSize,
      uploadedBy: version.uploadedBy,
      uploaderName: version.uploader
        ? `${version.uploader.firstName} ${version.uploader.lastName}`
        : undefined,
      createdAt: version.createdAt,
    };
  }
}

