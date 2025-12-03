import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Param,
  Body,
  Query,
  UseGuards,
  UseInterceptors,
  UploadedFile,
  HttpCode,
  HttpStatus,
  ParseIntPipe,
  Res,
  StreamableFile,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import type { Response } from 'express';
import { FilesService } from './files.service';
import { FilePermissionService } from './file-permission.service';
import { PermissionType } from './entities/file-permission.entity';
import { UploadFileDto } from './dto/upload-file.dto';
import { FileResponseDto } from './dto/file-response.dto';
import { FileVersionResponseDto } from './dto/file-version-response.dto';
import { FilePermissionDto } from './dto/file-permission.dto';
import { GrantPermissionDto } from './dto/grant-permission.dto';
import { FileSearchDto } from './dto/file-search.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { User } from '../auth/entities/user.entity';
import { createReadStream } from 'fs';
import type { Multer } from 'multer';

@Controller('api/files')
@UseGuards(JwtAuthGuard)
export class FilesController {
  constructor(
    private readonly filesService: FilesService,
    private readonly filePermissionService: FilePermissionService,
  ) {}

  @Post('upload')
  @UseInterceptors(FileInterceptor('file'))
  @HttpCode(HttpStatus.CREATED)
  async uploadFile(
    @UploadedFile() file: Multer.File,
    @Body() uploadDto: UploadFileDto,
    @CurrentUser() user: User,
  ): Promise<FileResponseDto> {
    if (!file) {
      throw new Error('No file uploaded');
    }

    return this.filesService.uploadFile(
      file,
      user.userId,
      uploadDto.folderId,
      uploadDto.courseId,
    );
  }

  @Get(':fileId')
  async getFile(
    @Param('fileId', ParseIntPipe) fileId: number,
    @CurrentUser() user: User,
  ): Promise<FileResponseDto> {
    return this.filesService.getFile(fileId, user.userId);
  }

  @Get(':fileId/download')
  async downloadFile(
    @Param('fileId', ParseIntPipe) fileId: number,
    @CurrentUser() user: User,
    @Res({ passthrough: true }) res: Response,
  ): Promise<StreamableFile> {
    const { file, filePath } = await this.filesService.downloadFile(
      fileId,
      user.userId,
    );

    res.set({
      'Content-Type': file.mimeType,
      'Content-Disposition': `attachment; filename="${file.originalFileName}"`,
      'Content-Length': file.fileSize.toString(),
    });

    const fileStream = createReadStream(filePath);

    return new StreamableFile(fileStream);
  }

  @Put(':fileId')
  async updateFile(
    @Param('fileId', ParseIntPipe) fileId: number,
    @Body() updates: { fileName?: string; folderId?: number },
    @CurrentUser() user: User,
  ): Promise<FileResponseDto> {
    return this.filesService.updateFile(fileId, user.userId, updates);
  }

  @Delete(':fileId')
  @HttpCode(HttpStatus.NO_CONTENT)
  async deleteFile(
    @Param('fileId', ParseIntPipe) fileId: number,
    @CurrentUser() user: User,
  ): Promise<void> {
    return this.filesService.deleteFile(fileId, user.userId);
  }

  @Post(':fileId/versions')
  @UseInterceptors(FileInterceptor('file'))
  @HttpCode(HttpStatus.CREATED)
  async createVersion(
    @Param('fileId', ParseIntPipe) fileId: number,
    @UploadedFile() file: Multer.File,
    @CurrentUser() user: User,
  ): Promise<FileVersionResponseDto> {
    if (!file) {
      throw new Error('No file uploaded');
    }

    return this.filesService.createVersion(fileId, file, user.userId);
  }

  @Get(':fileId/versions')
  async getFileVersions(
    @Param('fileId', ParseIntPipe) fileId: number,
    @CurrentUser() user: User,
  ): Promise<FileVersionResponseDto[]> {
    return this.filesService.getFileVersions(fileId, user.userId);
  }

  @Get(':fileId/versions/:versionId/download')
  async downloadVersion(
    @Param('fileId', ParseIntPipe) fileId: number,
    @Param('versionId', ParseIntPipe) versionId: number,
    @CurrentUser() user: User,
    @Res({ passthrough: true }) res: Response,
  ): Promise<StreamableFile> {
    const { version, filePath } = await this.filesService.downloadVersion(
      fileId,
      versionId,
      user.userId,
    );

    res.set({
      'Content-Type': 'application/octet-stream',
      'Content-Disposition': `attachment; filename="version-${version.versionNumber}"`,
      'Content-Length': version.fileSize.toString(),
    });

    const fileStream = createReadStream(filePath);

    return new StreamableFile(fileStream);
  }

  @Get(':fileId/permissions')
  async getFilePermissions(
    @Param('fileId', ParseIntPipe) fileId: number,
    @CurrentUser() user: User,
  ): Promise<FilePermissionDto[]> {
    // Check if user has permission to view permissions
    await this.filePermissionService.requirePermission(
      fileId,
      user.userId,
      PermissionType.READ,
    );

    const permissions = await this.filePermissionService.getFilePermissions(
      fileId,
    );

    return permissions.map((p) => ({
      permissionId: p.permissionId,
      fileId: p.fileId,
      userId: p.userId,
      userName: p.user
        ? `${p.user.firstName} ${p.user.lastName}`
        : undefined,
      roleId: p.roleId,
      roleName: p.role?.roleName,
      permissionType: p.permissionType,
      grantedBy: p.grantedBy,
      granterName: p.granter
        ? `${p.granter.firstName} ${p.granter.lastName}`
        : undefined,
      createdAt: p.createdAt,
    }));
  }

  @Post(':fileId/permissions')
  @HttpCode(HttpStatus.CREATED)
  async grantPermission(
    @Param('fileId', ParseIntPipe) fileId: number,
    @Body() grantDto: GrantPermissionDto,
    @CurrentUser() user: User,
  ): Promise<FilePermissionDto> {
    const permission = await this.filePermissionService.grantPermission(
      fileId,
      user.userId,
      grantDto.permissionType,
      user.userId,
      grantDto.userId,
      grantDto.roleId,
    );

    return {
      permissionId: permission.permissionId,
      fileId: permission.fileId,
      userId: permission.userId,
      roleId: permission.roleId,
      permissionType: permission.permissionType,
      grantedBy: permission.grantedBy,
      createdAt: permission.createdAt,
    };
  }

  @Delete(':fileId/permissions/:permissionId')
  @HttpCode(HttpStatus.NO_CONTENT)
  async revokePermission(
    @Param('fileId', ParseIntPipe) fileId: number,
    @Param('permissionId', ParseIntPipe) permissionId: number,
    @CurrentUser() user: User,
  ): Promise<void> {
    return this.filePermissionService.revokePermission(permissionId, user.userId);
  }

  @Get('search')
  async searchFiles(
    @Query() searchDto: FileSearchDto,
    @CurrentUser() user: User,
  ): Promise<FileResponseDto[]> {
    return this.filesService.searchFiles(searchDto, user.userId);
  }

  @Get('recent')
  async getRecentFiles(
    @CurrentUser() user: User,
    @Query('limit') limit?: number,
  ): Promise<FileResponseDto[]> {
    return this.filesService.getRecentFiles(user.userId, limit);
  }

  @Get('shared')
  async getSharedFiles(
    @CurrentUser() user: User,
  ): Promise<FileResponseDto[]> {
    return this.filesService.getSharedFiles(user.userId);
  }
}

