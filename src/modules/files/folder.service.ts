import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Folder } from './entities/folder.entity';
import { File } from './entities/file.entity';
import { CreateFolderDto } from './dto/create-folder.dto';
import { UpdateFolderDto } from './dto/update-folder.dto';
import { FolderResponseDto } from './dto/folder-response.dto';

@Injectable()
export class FolderService {
  constructor(
    @InjectRepository(Folder)
    private folderRepository: Repository<Folder>,
    @InjectRepository(File)
    private fileRepository: Repository<File>,
  ) {}

  async create(
    createFolderDto: CreateFolderDto,
    userId: number,
  ): Promise<FolderResponseDto> {
    // Validate parent folder exists if provided
    if (createFolderDto.parentFolderId) {
      const parentFolder = await this.folderRepository.findOne({
        where: { folderId: createFolderDto.parentFolderId },
      });

      if (!parentFolder) {
        throw new NotFoundException(
          `Parent folder with ID ${createFolderDto.parentFolderId} not found`,
        );
      }
    }

    const folder = this.folderRepository.create({
      ...createFolderDto,
      userId: createFolderDto.userId || userId,
    });

    const savedFolder = await this.folderRepository.save(folder);
    return await this.mapToFolderResponseDto(savedFolder);
  }

  async findById(folderId: number): Promise<FolderResponseDto> {
    const folder = await this.folderRepository.findOne({
      where: { folderId },
      relations: ['parentFolder', 'user'],
    });

    if (!folder) {
      throw new NotFoundException(`Folder with ID ${folderId} not found`);
    }

    return await this.mapToFolderResponseDto(folder);
  }

  async getChildren(folderId: number): Promise<{
    folders: FolderResponseDto[];
    files: any[];
  }> {
    const folder = await this.folderRepository.findOne({
      where: { folderId },
    });

    if (!folder) {
      throw new NotFoundException(`Folder with ID ${folderId} not found`);
    }

    const childFolders = await this.folderRepository.find({
      where: { parentFolderId: folderId },
      relations: ['user'],
    });

    const files = await this.fileRepository.find({
      where: { folderId },
      relations: ['uploader'],
    });

    return {
      folders: await Promise.all(
        childFolders.map((f) => this.mapToFolderResponseDto(f)),
      ),
      files: files.map((file) => ({
        fileId: file.fileId,
        fileName: file.fileName,
        originalFileName: file.originalFileName,
        fileSize: file.fileSize,
        mimeType: file.mimeType,
        uploadedBy: file.uploadedBy,
        uploaderName: file.uploader
          ? `${file.uploader.firstName} ${file.uploader.lastName}`
          : undefined,
        createdAt: file.createdAt,
      })),
    };
  }

  async getFolderTree(folderId: number): Promise<FolderResponseDto> {
    const folder = await this.folderRepository.findOne({
      where: { folderId },
      relations: ['children', 'user'],
    });

    if (!folder) {
      throw new NotFoundException(`Folder with ID ${folderId} not found`);
    }

    const buildTree = async (folder: Folder): Promise<FolderResponseDto> => {
      const children = await this.folderRepository.find({
        where: { parentFolderId: folder.folderId },
      });

      const childrenTree = await Promise.all(
        children.map((child) => buildTree(child)),
      );

      const folderDto = await this.mapToFolderResponseDto(folder);
      folderDto.children = childrenTree;


      return folderDto;
    };

    return buildTree(folder);
  }

  async update(
    folderId: number,
    updateFolderDto: UpdateFolderDto,
  ): Promise<FolderResponseDto> {
    const folder = await this.folderRepository.findOne({
      where: { folderId },
    });

    if (!folder) {
      throw new NotFoundException(`Folder with ID ${folderId} not found`);
    }

    // Validate parent folder if changing
    if (
      updateFolderDto.parentFolderId !== undefined &&
      updateFolderDto.parentFolderId !== folder.parentFolderId
    ) {
      if (updateFolderDto.parentFolderId !== null) {
        const parentFolder = await this.folderRepository.findOne({
          where: { folderId: updateFolderDto.parentFolderId },
        });

        if (!parentFolder) {
          throw new NotFoundException(
            `Parent folder with ID ${updateFolderDto.parentFolderId} not found`,
          );
        }

        // Prevent circular reference
        if (updateFolderDto.parentFolderId === folderId) {
          throw new Error('Cannot set folder as its own parent');
        }

        // Check if new parent is a descendant (would create cycle)
        const isDescendant = await this.isDescendant(
          updateFolderDto.parentFolderId,
          folderId,
        );
        if (isDescendant) {
          throw new Error('Cannot set folder as parent of its descendant');
        }
      }
    }

    Object.assign(folder, updateFolderDto);
    const updatedFolder = await this.folderRepository.save(folder);

    return await this.mapToFolderResponseDto(updatedFolder);
  }

  private async mapToFolderResponseDto(
    folder: Folder,
  ): Promise<FolderResponseDto> {
    const fileCount = await this.fileRepository.count({
      where: { folderId: folder.folderId },
    });

    return {
      folderId: folder.folderId,
      folderName: folder.folderName,
      parentFolderId: folder.parentFolderId,
      courseId: folder.courseId,
      userId: folder.userId,
      createdAt: folder.createdAt,
      fileCount,
    };
  }

  async delete(folderId: number): Promise<void> {
    const folder = await this.folderRepository.findOne({
      where: { folderId },
      relations: ['children', 'files'],
    });

    if (!folder) {
      throw new NotFoundException(`Folder with ID ${folderId} not found`);
    }

    // Check if folder has children
    const childCount = await this.folderRepository.count({
      where: { parentFolderId: folderId },
    });

    if (childCount > 0) {
      throw new Error(
        'Cannot delete folder with subfolders. Please delete or move subfolders first.',
      );
    }

    // Check if folder has files
    const fileCount = await this.fileRepository.count({
      where: { folderId },
    });

    if (fileCount > 0) {
      throw new Error(
        'Cannot delete folder with files. Please delete or move files first.',
      );
    }

    await this.folderRepository.softDelete(folderId);
  }

  private async isDescendant(
    ancestorId: number,
    descendantId: number,
  ): Promise<boolean> {
    const folder = await this.folderRepository.findOne({
      where: { folderId: descendantId },
    });

    if (!folder || !folder.parentFolderId) {
      return false;
    }

    if (folder.parentFolderId === ancestorId) {
      return true;
    }

    return this.isDescendant(ancestorId, folder.parentFolderId);
  }
}

