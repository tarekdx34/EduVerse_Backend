import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { FilesService } from './files.service';
import { FolderService } from './folder.service';
import { FileStorageService } from './file-storage.service';
import { FilePermissionService } from './file-permission.service';
import { FilesController } from './files.controller';
import { FolderController } from './folder.controller';
import { Folder } from './entities/folder.entity';
import { File } from './entities/file.entity';
import { FileVersion } from './entities/file-version.entity';
import { FilePermission } from './entities/file-permission.entity';
import { User } from '../auth/entities/user.entity';
import { Role } from '../auth/entities/role.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      Folder,
      File,
      FileVersion,
      FilePermission,
      User,
      Role,
    ]),
  ],
  controllers: [FilesController, FolderController],
  providers: [
    FilesService,
    FolderService,
    FileStorageService,
    FilePermissionService,
  ],
  exports: [FilesService, FolderService, FileStorageService],
})
export class FilesModule {}

