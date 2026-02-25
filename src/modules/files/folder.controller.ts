import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Param,
  Body,
  UseGuards,
  HttpCode,
  HttpStatus,
  ParseIntPipe,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
  ApiParam,
  ApiBody,
} from '@nestjs/swagger';
import { FolderService } from './folder.service';
import { CreateFolderDto } from './dto/create-folder.dto';
import { UpdateFolderDto } from './dto/update-folder.dto';
import { FolderResponseDto } from './dto/folder-response.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { User } from '../auth/entities/user.entity';

@ApiTags('📂 Folders')
@Controller('api/files/folders')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth('JWT-auth')
export class FolderController {
  constructor(private readonly folderService: FolderService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Create folder',
    description: `
## Create New Folder

Creates a new folder for organizing files.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: Any authenticated user

### Notes
- Folders can be nested inside other folders
- Root folders have no parent
    `,
  })
  @ApiBody({ type: CreateFolderDto })
  @ApiResponse({ status: 201, description: 'Folder created successfully' })
  @ApiResponse({ status: 400, description: 'Invalid input data' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async create(
    @Body() createFolderDto: CreateFolderDto,
    @CurrentUser() user: User,
  ): Promise<FolderResponseDto> {
    return this.folderService.create(createFolderDto, user.userId);
  }

  @Get(':folderId')
  @ApiOperation({
    summary: 'Get folder by ID',
    description: `
## Get Folder Details

Retrieves information about a specific folder.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: Any authenticated user with access
    `,
  })
  @ApiParam({ name: 'folderId', description: 'Folder ID', type: Number })
  @ApiResponse({ status: 200, description: 'Folder details' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 404, description: 'Folder not found' })
  async findById(
    @Param('folderId', ParseIntPipe) folderId: number,
  ): Promise<FolderResponseDto> {
    return this.folderService.findById(folderId);
  }

  @Get(':folderId/children')
  @ApiOperation({
    summary: 'Get folder contents',
    description: `
## Get Folder Children

Retrieves all folders and files within a folder.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: Any authenticated user with access

### Response
Returns separate arrays for subfolders and files.
    `,
  })
  @ApiParam({ name: 'folderId', description: 'Folder ID', type: Number })
  @ApiResponse({ status: 200, description: 'Folder contents' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 404, description: 'Folder not found' })
  async getChildren(
    @Param('folderId', ParseIntPipe) folderId: number,
  ): Promise<{ folders: FolderResponseDto[]; files: any[] }> {
    return this.folderService.getChildren(folderId);
  }

  @Get(':folderId/tree')
  @ApiOperation({
    summary: 'Get folder tree',
    description: `
## Get Folder Tree Structure

Retrieves the folder with its complete nested hierarchy.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: Any authenticated user with access

### Response
Returns folder with nested children recursively.
    `,
  })
  @ApiParam({ name: 'folderId', description: 'Folder ID', type: Number })
  @ApiResponse({ status: 200, description: 'Folder tree' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 404, description: 'Folder not found' })
  async getFolderTree(
    @Param('folderId', ParseIntPipe) folderId: number,
  ): Promise<FolderResponseDto> {
    return this.folderService.getFolderTree(folderId);
  }

  @Put(':folderId')
  @ApiOperation({
    summary: 'Update folder',
    description: `
## Update Folder

Updates folder name or moves it to a different parent.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: Folder owner or admin
    `,
  })
  @ApiParam({ name: 'folderId', description: 'Folder ID', type: Number })
  @ApiBody({ type: UpdateFolderDto })
  @ApiResponse({ status: 200, description: 'Folder updated' })
  @ApiResponse({ status: 400, description: 'Invalid input data' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 404, description: 'Folder not found' })
  async update(
    @Param('folderId', ParseIntPipe) folderId: number,
    @Body() updateFolderDto: UpdateFolderDto,
  ): Promise<FolderResponseDto> {
    return this.folderService.update(folderId, updateFolderDto);
  }

  @Delete(':folderId')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({
    summary: 'Delete folder',
    description: `
## Delete Folder

Deletes a folder and all its contents.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: Folder owner or admin

### ⚠️ Warning
This recursively deletes all subfolders and files within!
    `,
  })
  @ApiParam({ name: 'folderId', description: 'Folder ID', type: Number })
  @ApiResponse({ status: 204, description: 'Folder deleted' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  @ApiResponse({ status: 404, description: 'Folder not found' })
  async delete(
    @Param('folderId', ParseIntPipe) folderId: number,
  ): Promise<void> {
    return this.folderService.delete(folderId);
  }
}

