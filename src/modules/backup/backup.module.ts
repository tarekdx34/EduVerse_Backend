import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ConfigModule } from '@nestjs/config';
import { BackupRecord } from './entities/backup-record.entity';
import { BackupService } from './services/backup.service';
import { DatabaseService } from './services/database.service';
import { BackupController } from './controllers/backup.controller';
import { DatabaseController } from './controllers/database.controller';

@Module({
  imports: [
    TypeOrmModule.forFeature([BackupRecord]),
    ConfigModule,
  ],
  controllers: [BackupController, DatabaseController],
  providers: [BackupService, DatabaseService],
  exports: [BackupService, DatabaseService],
})
export class BackupModule {}
