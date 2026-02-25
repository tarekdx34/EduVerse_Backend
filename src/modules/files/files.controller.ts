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
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
  ApiParam,
  ApiQuery,
  ApiBody,
  ApiConsumes,
} from '@nestjs/swagger';
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

@ApiTags('📁 Files')
@Controller('api/files')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth('JWT-auth')
export class FilesController {
  constructor(
    private readonly filesService: FilesService,
    private readonly filePermissionService: FilePermissionService,
  ) {}

  @Post('upload')
  @UseInterceptors(FileInterceptor('file'))
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Upload a file',
    description: `
## Upload File

Uploads a file to the system.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: Any authenticated user

### Supported File Types
Most common file types are supported including documents, images, videos, and archives.

### Notes
- Maximum file size: 50MB (configurable)
- Files are associated with the uploading user
- Optional folder and course association
    `,
  })
  @ApiConsumes('multipart/form-data')
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        file: { type: 'string', format: 'binary', description: 'File to upload' },
        folderId: { type: 'number', description: 'Optional folder ID' },
        courseId: { type: 'number', description: 'Optional course ID' },
      },
      required: ['file'],
    },
  })
  @ApiResponse({ status: 201, description: 'File uploaded successfully' })
  @ApiResponse({ status: 400, description: 'No file provided or invalid file type' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 413, description: 'File too large' })
  async uploadFile(
    @UploadedFile() file: Express.Multer.File,
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
  @ApiOperation({
    summary: 'Get file metadata',
    description: `
## Get File Information

Retrieves metadata about a specific file.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: User with READ permission on the file

### Response Includes
- File name, type, size
- Upload date and uploader
- Folder location
- Version information
    `,
  })
  @ApiParam({ name: 'fileId', description: 'File ID', type: Number })
  @ApiResponse({ status: 200, description: 'File metadata' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - No read permission' })
  @ApiResponse({ status: 404, description: 'File not found' })
  async getFile(
    @Param('fileId', ParseIntPipe) fileId: number,
    @CurrentUser() user: User,
  ): Promise<FileResponseDto> {
    return this.filesService.getFile(fileId, user.userId);
  }

  @Get(':fileId/download')
  @ApiOperation({
    summary: 'Download file',
    description: `
## Download File

Downloads the file content.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: User with READ permission on the file

### Response
Returns the file as a binary stream with appropriate content headers.
    `,
  })
  @ApiParam({ name: 'fileId', description: 'File ID', type: Number })
  @ApiResponse({ status: 200, description: 'File content' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - No read permission' })
  @ApiResponse({ status: 404, description: 'File not found' })
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
  @ApiOperation({
    summary: 'Update file',
    description: `
## Update File Metadata

Updates file name or folder location.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: User with WRITE permission on the file
    `,
  })
  @ApiParam({ name: 'fileId', description: 'File ID', type: Number })
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        fileName: { type: 'string', description: 'New file name' },
        folderId: { type: 'number', description: 'New folder ID' },
      },
    },
  })
  @ApiResponse({ status: 200, description: 'File updated' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - No write permission' })
  @ApiResponse({ status: 404, description: 'File not found' })
  async updateFile(
    @Param('fileId', ParseIntPipe) fileId: number,
    @Body() updates: { fileName?: string; folderId?: number },
    @CurrentUser() user: User,
  ): Promise<FileResponseDto> {
    return this.filesService.updateFile(fileId, user.userId, updates);
  }

  @Delete(':fileId')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({
    summary: 'Delete file',
    description: `
## Delete File

Permanently deletes a file.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: User with DELETE permission (usually owner)

### ⚠️ Warning
This action is irreversible. All versions will be deleted.
    `,
  })
  @ApiParam({ name: 'fileId', description: 'File ID', type: Number })
  @ApiResponse({ status: 204, description: 'File deleted' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - No delete permission' })
  @ApiResponse({ status: 404, description: 'File not found' })
  async deleteFile(
    @Param('fileId', ParseIntPipe) fileId: number,
    @CurrentUser() user: User,
  ): Promise<void> {
    return this.filesService.deleteFile(fileId, user.userId);
  }

  @Post(':fileId/versions')
  @UseInterceptors(FileInterceptor('file'))
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Upload new file version',
    description: `
## Upload New Version

Uploads a new version of an existing file.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: User with WRITE permission on the file

### Version Management
- Previous versions are preserved
- Version numbers auto-increment
    `,
  })
  @ApiParam({ name: 'fileId', description: 'File ID', type: Number })
  @ApiConsumes('multipart/form-data')
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        file: { type: 'string', format: 'binary' },
      },
      required: ['file'],
    },
  })
  @ApiResponse({ status: 201, description: 'Version created' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - No write permission' })
  @ApiResponse({ status: 404, description: 'File not found' })
  async createVersion(
    @Param('fileId', ParseIntPipe) fileId: number,
    @UploadedFile() file: Express.Multer.File,
    @CurrentUser() user: User,
  ): Promise<FileVersionResponseDto> {
    if (!file) {
      throw new Error('No file uploaded');
    }

    return this.filesService.createVersion(fileId, file, user.userId);
  }

  @Get(':fileId/versions')
  @ApiOperation({
    summary: 'List file versions',
    description: `
## List File Versions

Retrieves all versions of a file.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: User with READ permission on the file
    `,
  })
  @ApiParam({ name: 'fileId', description: 'File ID', type: Number })
  @ApiResponse({ status: 200, description: 'List of versions' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - No read permission' })
  @ApiResponse({ status: 404, description: 'File not found' })
  async getFileVersions(
    @Param('fileId', ParseIntPipe) fileId: number,
    @CurrentUser() user: User,
  ): Promise<FileVersionResponseDto[]> {
    return this.filesService.getFileVersions(fileId, user.userId);
  }

  @Get(':fileId/versions/:versionId/download')
  @ApiOperation({
    summary: 'Download specific version',
    description: `
## Download File Version

Downloads a specific version of a file.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: User with READ permission on the file
    `,
  })
  @ApiParam({ name: 'fileId', description: 'File ID', type: Number })
  @ApiParam({ name: 'versionId', description: 'Version ID', type: Number })
  @ApiResponse({ status: 200, description: 'Version content' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - No read permission' })
  @ApiResponse({ status: 404, description: 'File or version not found' })
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
  @ApiOperation({
    summary: 'Get file permissions',
    description: `
## Get File Permissions

Retrieves all permissions set on a file.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: User with READ permission on the file
    `,
  })
  @ApiParam({ name: 'fileId', description: 'File ID', type: Number })
  @ApiResponse({ status: 200, description: 'List of permissions' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  @ApiResponse({ status: 404, description: 'File not found' })
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
  @ApiOperation({
    summary: 'Grant file permission',
    description: `
## Grant Permission on File

Grants read, write, or delete permission to a user or role.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: User with WRITE permission (file owner or admin)

### Permission Types
- READ: View and download file
- WRITE: Edit and create versions
- DELETE: Remove file
    `,
  })
  @ApiParam({ name: 'fileId', description: 'File ID', type: Number })
  @ApiBody({ type: GrantPermissionDto })
  @ApiResponse({ status: 201, description: 'Permission granted' })
  @ApiResponse({ status: 400, description: 'Invalid permission data' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - Cannot grant permissions' })
  @ApiResponse({ status: 404, description: 'File not found' })
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
  @ApiOperation({
    summary: 'Revoke file permission',
    description: `
## Revoke Permission on File

Removes a permission from a file.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: User with WRITE permission (file owner or admin)
    `,
  })
  @ApiParam({ name: 'fileId', description: 'File ID', type: Number })
  @ApiParam({ name: 'permissionId', description: 'Permission ID', type: Number })
  @ApiResponse({ status: 204, description: 'Permission revoked' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  @ApiResponse({ status: 404, description: 'Permission not found' })
  async revokePermission(
    @Param('fileId', ParseIntPipe) fileId: number,
    @Param('permissionId', ParseIntPipe) permissionId: number,
    @CurrentUser() user: User,
  ): Promise<void> {
    return this.filePermissionService.revokePermission(permissionId, user.userId);
  }

  @Get('search')
  @ApiOperation({
    summary: 'Search files',
    description: `
## Search Files

Searches for files by name, type, or other criteria.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: Any authenticated user

### Search Scope
Only returns files the user has permission to access.
    `,
  })
  @ApiResponse({ status: 200, description: 'Search results' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async searchFiles(
    @Query() searchDto: FileSearchDto,
    @CurrentUser() user: User,
  ): Promise<FileResponseDto[]> {
    return this.filesService.searchFiles(searchDto, user.userId);
  }

  @Get('recent')
  @ApiOperation({
    summary: 'Get recent files',
    description: `
## Get Recently Accessed Files

Returns files recently uploaded or accessed by the user.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: Any authenticated user
    `,
  })
  @ApiQuery({ name: 'limit', required: false, type: Number, example: 10 })
  @ApiResponse({ status: 200, description: 'Recent files' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getRecentFiles(
    @CurrentUser() user: User,
    @Query('limit') limit?: number,
  ): Promise<FileResponseDto[]> {
    return this.filesService.getRecentFiles(user.userId, limit);
  }

  @Get('shared')
  @ApiOperation({
    summary: 'Get shared files',
    description: `
## Get Files Shared with User

Returns files that others have shared with the current user.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: Any authenticated user
    `,
  })
  @ApiResponse({ status: 200, description: 'Shared files' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getSharedFiles(
    @CurrentUser() user: User,
  ): Promise<FileResponseDto[]> {
    return this.filesService.getSharedFiles(user.userId);
  }
}

