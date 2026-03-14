// src/modules/google-drive/google-drive.module.ts
import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { GoogleDriveService } from './google-drive.service';
import { GoogleDriveController } from './google-drive.controller';
import { DriveFolder } from './entities/drive-folder.entity';
import { DriveFile } from './entities/drive-file.entity';
import { DriveFolderService } from './services/drive-folder.service';

@Module({
  imports: [
    ConfigModule,
    TypeOrmModule.forFeature([DriveFolder, DriveFile]),
  ],
  controllers: [GoogleDriveController],
  providers: [GoogleDriveService, DriveFolderService],
  exports: [GoogleDriveService, DriveFolderService],
})
export class GoogleDriveModule {}
