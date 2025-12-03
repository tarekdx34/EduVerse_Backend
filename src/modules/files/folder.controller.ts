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
import { FolderService } from './folder.service';
import { CreateFolderDto } from './dto/create-folder.dto';
import { UpdateFolderDto } from './dto/update-folder.dto';
import { FolderResponseDto } from './dto/folder-response.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { User } from '../auth/entities/user.entity';

@Controller('api/files/folders')
@UseGuards(JwtAuthGuard)
export class FolderController {
  constructor(private readonly folderService: FolderService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  async create(
    @Body() createFolderDto: CreateFolderDto,
    @CurrentUser() user: User,
  ): Promise<FolderResponseDto> {
    return this.folderService.create(createFolderDto, user.userId);
  }

  @Get(':folderId')
  async findById(
    @Param('folderId', ParseIntPipe) folderId: number,
  ): Promise<FolderResponseDto> {
    return this.folderService.findById(folderId);
  }

  @Get(':folderId/children')
  async getChildren(
    @Param('folderId', ParseIntPipe) folderId: number,
  ): Promise<{ folders: FolderResponseDto[]; files: any[] }> {
    return this.folderService.getChildren(folderId);
  }

  @Get(':folderId/tree')
  async getFolderTree(
    @Param('folderId', ParseIntPipe) folderId: number,
  ): Promise<FolderResponseDto> {
    return this.folderService.getFolderTree(folderId);
  }

  @Put(':folderId')
  async update(
    @Param('folderId', ParseIntPipe) folderId: number,
    @Body() updateFolderDto: UpdateFolderDto,
  ): Promise<FolderResponseDto> {
    return this.folderService.update(folderId, updateFolderDto);
  }

  @Delete(':folderId')
  @HttpCode(HttpStatus.NO_CONTENT)
  async delete(
    @Param('folderId', ParseIntPipe) folderId: number,
  ): Promise<void> {
    return this.folderService.delete(folderId);
  }
}

