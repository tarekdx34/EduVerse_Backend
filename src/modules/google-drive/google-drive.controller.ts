// src/modules/google-drive/google-drive.controller.ts
import {
  Controller,
  Post,
  Get,
  Delete,
  Query,
  Param,
  Body,
  UseInterceptors,
  UploadedFile,
  Res,
  BadRequestException,
  UseGuards,
  Req,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiQuery,
  ApiBody,
  ApiConsumes,
  ApiParam,
  ApiBearerAuth,
} from '@nestjs/swagger';
import { FileInterceptor } from '@nestjs/platform-express';
import type { Response, Request } from 'express';
import { GoogleDriveService } from './google-drive.service';
import { DriveFolderService } from './services/drive-folder.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@ApiTags('📁 Google Drive')
@Controller('google-drive')
export class GoogleDriveController {
  constructor(
    private readonly driveService: GoogleDriveService,
    private readonly folderService: DriveFolderService,
  ) {}

  @Get('auth')
  @ApiOperation({
    summary: 'Get Google OAuth URL with YouTube + Drive scopes',
    description: `
## Get OAuth Authentication URL

Returns the OAuth2 authentication URL for both YouTube and Google Drive API access.

### Important
This URL requests authorization for BOTH:
- \`youtube.upload\` - Upload videos to YouTube
- \`drive.file\` - Create and manage files in Google Drive

### Process
1. Call this endpoint to get the auth URL
2. Open the URL in your browser
3. Sign in with your Google account
4. Grant permissions for YouTube and Drive
5. Google redirects to the callback with a code
6. The callback returns a new refresh token
7. Update your .env with the new YOUTUBE_REFRESH_TOKEN

### Note
After re-authorizing, both YouTube AND Drive will work with the new token.
    `,
  })
  @ApiResponse({
    status: 200,
    description: 'OAuth authentication URL',
    schema: {
      example: {
        authUrl: 'https://accounts.google.com/o/oauth2/v2/auth?...',
        scopes: ['youtube.upload', 'drive.file'],
        instructions: 'Open this URL in your browser to authorize',
      },
    },
  })
  getAuthUrl() {
    const url = this.driveService.getAuthUrl();
    return {
      authUrl: url,
      scopes: ['youtube.upload', 'drive.file'],
      instructions: 'Open this URL in your browser to authorize. After authorization, update YOUTUBE_REFRESH_TOKEN in .env with the returned token.',
    };
  }

  @Get('callback')
  @ApiOperation({
    summary: 'Handle OAuth callback',
    description: `
## Handle OAuth Callback

Exchanges the authorization code for access and refresh tokens.

### Access Control
- **Authentication Required**: No (Callback from Google)

### Process
Called automatically by Google after user authorization.
Returns the refresh token to save in your .env file.
    `,
  })
  @ApiQuery({ name: 'code', description: 'Authorization code from Google', type: String })
  @ApiResponse({
    status: 200,
    description: 'Authentication tokens',
    schema: {
      example: {
        message: 'Authentication successful! Update your .env with the new refresh token.',
        refreshToken: '1//04xxx...',
        instructions: 'Copy the refreshToken above and update YOUTUBE_REFRESH_TOKEN in your .env file',
      },
    },
  })
  @ApiResponse({ status: 400, description: 'Invalid or expired code' })
  async handleCallback(@Query('code') code: string) {
    if (!code) {
      throw new BadRequestException('Authorization code is required');
    }

    const tokens = await this.driveService.getTokens(code);
    return {
      message: 'Authentication successful! Update your .env with the new refresh token.',
      refreshToken: tokens.refresh_token,
      accessToken: tokens.access_token,
      expiresIn: tokens.expiry_date,
      instructions: 'Copy the refreshToken above and update YOUTUBE_REFRESH_TOKEN in your .env file. Then restart the server.',
    };
  }

  @Post('folders')
  @ApiOperation({
    summary: 'Create a folder in Google Drive',
    description: `
## Create Folder

Creates a new folder in Google Drive.

### Body Parameters
- \`name\`: Folder name (required)
- \`parentId\`: Parent folder ID (optional, defaults to root)
    `,
  })
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        name: { type: 'string', description: 'Folder name', example: 'Course_Materials' },
        parentId: { type: 'string', description: 'Parent folder ID', example: '1abc123...' },
      },
      required: ['name'],
    },
  })
  @ApiResponse({
    status: 201,
    description: 'Folder created successfully',
    schema: {
      example: {
        id: '1abc123...',
        name: 'Course_Materials',
        webViewLink: 'https://drive.google.com/drive/folders/1abc123...',
        createdTime: '2024-01-15T10:30:00.000Z',
      },
    },
  })
  async createFolder(
    @Body('name') name: string,
    @Body('parentId') parentId?: string,
  ) {
    if (!name) {
      throw new BadRequestException('Folder name is required');
    }
    return await this.driveService.createFolder(name, parentId);
  }

  @Get('folders/:folderId')
  @ApiOperation({
    summary: 'List contents of a folder',
    description: 'Returns all files and subfolders within the specified folder.',
  })
  @ApiParam({ name: 'folderId', description: 'Folder ID to list contents of' })
  @ApiResponse({
    status: 200,
    description: 'Folder contents',
    schema: {
      example: {
        files: [
          {
            id: '1abc123...',
            name: 'lecture.pdf',
            mimeType: 'application/pdf',
            size: '1048576',
            webViewLink: 'https://drive.google.com/file/d/1abc123.../view',
          },
        ],
      },
    },
  })
  async listFolder(@Param('folderId') folderId: string) {
    const files = await this.driveService.listFolder(folderId);
    return { files };
  }

  @Post('files/upload')
  @UseInterceptors(FileInterceptor('file'))
  @ApiOperation({
    summary: 'Upload a file to Google Drive',
    description: `
## Upload File

Uploads a file to Google Drive.

### Supported File Types
PDF, DOC, DOCX, XLS, XLSX, PPT, PPTX, JPG, PNG, GIF, MP4, ZIP, and more.

### Body Parameters
- \`file\`: File to upload (required)
- \`folderId\`: Target folder ID (optional)
    `,
  })
  @ApiConsumes('multipart/form-data')
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        file: { type: 'string', format: 'binary', description: 'File to upload' },
        folderId: { type: 'string', description: 'Target folder ID' },
      },
      required: ['file'],
    },
  })
  @ApiResponse({
    status: 201,
    description: 'File uploaded successfully',
    schema: {
      example: {
        id: '1abc123...',
        name: 'lecture.pdf',
        mimeType: 'application/pdf',
        size: '1048576',
        webViewLink: 'https://drive.google.com/file/d/1abc123.../view',
        webContentLink: 'https://drive.google.com/uc?id=1abc123...&export=download',
      },
    },
  })
  async uploadFile(
    @UploadedFile() file: Express.Multer.File,
    @Body('folderId') folderId?: string,
  ) {
    if (!file) {
      throw new BadRequestException('File is required');
    }

    return await this.driveService.uploadFile(
      file.buffer,
      file.originalname,
      file.mimetype,
      folderId,
    );
  }

  @Get('files/:fileId')
  @ApiOperation({
    summary: 'Get file metadata',
    description: 'Returns metadata for a specific file.',
  })
  @ApiParam({ name: 'fileId', description: 'File ID' })
  @ApiResponse({
    status: 200,
    description: 'File metadata',
  })
  async getFile(@Param('fileId') fileId: string) {
    return await this.driveService.getFile(fileId);
  }

  @Get('files/:fileId/download')
  @ApiOperation({
    summary: 'Download a file',
    description: 'Downloads the file content.',
  })
  @ApiParam({ name: 'fileId', description: 'File ID' })
  @ApiResponse({
    status: 200,
    description: 'File content',
  })
  async downloadFile(@Param('fileId') fileId: string, @Res() res: Response) {
    const metadata = await this.driveService.getFile(fileId);
    const buffer = await this.driveService.downloadFile(fileId);

    res.set({
      'Content-Type': metadata.mimeType,
      'Content-Disposition': `attachment; filename="${metadata.name}"`,
      'Content-Length': buffer.length,
    });

    res.send(buffer);
  }

  @Delete('files/:fileId')
  @ApiOperation({
    summary: 'Delete a file or folder',
    description: 'Permanently deletes a file or folder from Google Drive.',
  })
  @ApiParam({ name: 'fileId', description: 'File or folder ID to delete' })
  @ApiResponse({
    status: 200,
    description: 'File deleted successfully',
    schema: {
      example: { message: 'File deleted successfully', fileId: '1abc123...' },
    },
  })
  async deleteFile(@Param('fileId') fileId: string) {
    await this.driveService.deleteFile(fileId);
    return { message: 'File deleted successfully', fileId };
  }

  @Get('quota')
  @ApiOperation({
    summary: 'Get storage quota information',
    description: 'Returns the Google Drive storage quota for the authenticated account.',
  })
  @ApiResponse({
    status: 200,
    description: 'Storage quota',
    schema: {
      example: {
        limit: '16106127360',
        usage: '1073741824',
        usageInDrive: '536870912',
      },
    },
  })
  async getQuota() {
    return await this.driveService.getStorageQuota();
  }

  @Post('folders/find-or-create')
  @ApiOperation({
    summary: 'Find or create a folder',
    description: 'Returns existing folder if found, otherwise creates it.',
  })
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        name: { type: 'string', description: 'Folder name', example: 'Course_Materials' },
        parentId: { type: 'string', description: 'Parent folder ID' },
      },
      required: ['name'],
    },
  })
  @ApiResponse({
    status: 200,
    description: 'Folder (existing or newly created)',
  })
  async findOrCreateFolder(
    @Body('name') name: string,
    @Body('parentId') parentId?: string,
  ) {
    if (!name) {
      throw new BadRequestException('Folder name is required');
    }
    return await this.driveService.getOrCreateFolder(name, parentId);
  }

  // ============================================================================
  // ADMIN ENDPOINTS
  // ============================================================================

  @Post('admin/init')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({
    summary: 'Initialize EduVerse root folder',
    description: `
## Initialize Root Folder

Creates the root "EduVerse" folder in Google Drive and saves it to the database.
This must be called once before using other Drive features.

### Access Control
- **Authentication Required**: Yes
- **Roles Required**: Admin recommended
    `,
  })
  @ApiResponse({
    status: 201,
    description: 'Root folder initialized',
    schema: {
      example: {
        message: 'Root folder initialized successfully',
        folderId: 1,
        driveId: '1abc123...',
        folderName: 'EduVerse',
      },
    },
  })
  async initRootFolder(@Req() req: Request) {
    const userId = (req as any).user?.userId || 1;
    const rootFolder = await this.folderService.initRootFolder(userId);
    return {
      message: 'Root folder initialized successfully',
      folderId: rootFolder.driveFolderId,
      driveId: rootFolder.driveId,
      folderName: rootFolder.folderName,
    };
  }

  @Post('admin/courses/:courseId/init')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({
    summary: 'Initialize folder structure for a course',
    description: `
## Initialize Course Folder Structure

Creates the complete folder hierarchy for a course:
Department → Academic Year → Semester → Course → (General, Lectures, Labs, Assignments, Projects)
    `,
  })
  @ApiParam({ name: 'courseId', description: 'Course ID' })
  @ApiResponse({
    status: 201,
    description: 'Course folder structure created',
  })
  async initCourseStructure(
    @Param('courseId') courseId: string,
    @Req() req: Request,
  ) {
    const userId = (req as any).user?.userId || 1;
    const hierarchy = await this.folderService.ensureCourseHierarchy(parseInt(courseId, 10), userId);
    return {
      message: 'Course folder structure initialized',
      folders: {
        course: { id: hierarchy.course.driveFolderId, driveId: hierarchy.course.driveId, path: hierarchy.course.folderPath },
        general: { id: hierarchy.general.driveFolderId, driveId: hierarchy.general.driveId },
        lectures: { id: hierarchy.lectures.driveFolderId, driveId: hierarchy.lectures.driveId },
        labs: { id: hierarchy.labs.driveFolderId, driveId: hierarchy.labs.driveId },
        assignments: { id: hierarchy.assignments.driveFolderId, driveId: hierarchy.assignments.driveId },
        projects: { id: hierarchy.projects.driveFolderId, driveId: hierarchy.projects.driveId },
      },
    };
  }

  @Post('admin/labs/:labId/init')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({
    summary: 'Initialize folder structure for a lab',
    description: 'Creates Lab folder with instructions, ta_materials, and submissions subfolders.',
  })
  @ApiParam({ name: 'labId', description: 'Lab ID' })
  @ApiResponse({
    status: 201,
    description: 'Lab folder structure created',
  })
  async initLabStructure(
    @Param('labId') labId: string,
    @Req() req: Request,
  ) {
    const userId = (req as any).user?.userId || 1;
    const folders = await this.folderService.createLabFolderStructure(parseInt(labId, 10), userId);
    return {
      message: 'Lab folder structure initialized',
      folders: {
        lab: { id: folders.lab.driveFolderId, driveId: folders.lab.driveId, path: folders.lab.folderPath },
        instructions: { id: folders.instructions.driveFolderId, driveId: folders.instructions.driveId },
        taMaterials: { id: folders.taMaterials.driveFolderId, driveId: folders.taMaterials.driveId },
        submissions: { id: folders.submissions.driveFolderId, driveId: folders.submissions.driveId },
      },
    };
  }

  @Post('admin/assignments/:assignmentId/init')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({
    summary: 'Initialize folder structure for an assignment',
    description: 'Creates Assignment folder with instructions and submissions subfolders.',
  })
  @ApiParam({ name: 'assignmentId', description: 'Assignment ID' })
  @ApiResponse({
    status: 201,
    description: 'Assignment folder structure created',
  })
  async initAssignmentStructure(
    @Param('assignmentId') assignmentId: string,
    @Req() req: Request,
  ) {
    const userId = (req as any).user?.userId || 1;
    const folders = await this.folderService.createAssignmentFolderStructure(parseInt(assignmentId, 10), userId);
    return {
      message: 'Assignment folder structure initialized',
      folders: {
        assignment: { id: folders.assignment.driveFolderId, driveId: folders.assignment.driveId, path: folders.assignment.folderPath },
        instructions: { id: folders.instructions.driveFolderId, driveId: folders.instructions.driveId },
        submissions: { id: folders.submissions.driveFolderId, driveId: folders.submissions.driveId },
      },
    };
  }

  @Get('admin/tree')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({
    summary: 'Get full folder tree',
    description: 'Returns all Drive folders stored in the database.',
  })
  @ApiResponse({
    status: 200,
    description: 'Folder tree',
  })
  async getFolderTree() {
    const folders = await this.folderService.getFullTree();
    return { folders };
  }

  @Get('admin/courses/:courseId/tree')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({
    summary: 'Get folder tree for a course',
    description: 'Returns all Drive folders for a specific course.',
  })
  @ApiParam({ name: 'courseId', description: 'Course ID' })
  @ApiResponse({
    status: 200,
    description: 'Course folder tree',
  })
  async getCourseFolderTree(@Param('courseId') courseId: string) {
    const folders = await this.folderService.getCourseTree(parseInt(courseId, 10));
    return { folders };
  }
}
