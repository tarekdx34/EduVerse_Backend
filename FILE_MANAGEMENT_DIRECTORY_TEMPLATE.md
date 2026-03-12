# 📂 File Management - Directory Structure Template

Create this exact structure to maintain consistency with other modules:

```
src/modules/files/
│
├── files.module.ts                          [Module definition - Entry point]
│
├── controllers/
│   ├── index.ts                             [Barrel export]
│   ├── files.controller.ts                  [File operations: upload, download, CRUD]
│   ├── folders.controller.ts                [Folder operations: create, list, update, delete]
│   ├── file-versions.controller.ts          [Version operations: list, rollback]
│   └── file-permissions.controller.ts       [Permission operations: grant, revoke]
│
├── services/
│   ├── index.ts                             [Barrel export]
│   ├── file-storage.service.ts              [Storage abstraction (local/S3)]
│   ├── files.service.ts                     [File CRUD & metadata]
│   ├── folders.service.ts                   [Folder CRUD & hierarchy]
│   ├── file-versions.service.ts             [Version tracking & rollback]
│   └── file-permissions.service.ts          [Permission logic & checks]
│
├── entities/
│   ├── index.ts                             [Barrel export]
│   ├── file.entity.ts                       [@Entity File TypeORM]
│   ├── folder.entity.ts                     [@Entity Folder TypeORM]
│   ├── file-version.entity.ts               [@Entity FileVersion TypeORM]
│   └── file-permission.entity.ts            [@Entity FilePermission TypeORM]
│
├── dtos/
│   ├── index.ts                             [Barrel export]
│   ├── upload-file.dto.ts                   [File upload request DTO]
│   ├── create-folder.dto.ts                 [Folder creation request DTO]
│   ├── grant-permission.dto.ts              [Permission grant request DTO]
│   ├── file-response.dto.ts                 [File response DTO]
│   ├── folder-response.dto.ts               [Folder response DTO]
│   └── file-version-response.dto.ts         [Version response DTO]
│
├── enums/
│   ├── index.ts                             [Barrel export]
│   ├── file-status.enum.ts                  [Status: active, processing, archived, deleted]
│   └── permission-type.enum.ts              [Types: read, write, delete, share]
│
├── exceptions/
│   ├── index.ts                             [Barrel export]
│   ├── file-not-found.exception.ts
│   ├── folder-not-found.exception.ts
│   ├── permission-denied.exception.ts
│   ├── file-upload-failed.exception.ts
│   └── invalid-folder-hierarchy.exception.ts
│
├── guards/
│   ├── index.ts                             [Barrel export]
│   ├── file-access.guard.ts                 [Check READ/WRITE permission on file]
│   ├── folder-access.guard.ts               [Check permission on folder (cascade)]
│   └── upload-quota.guard.ts                [Check storage quota]
│
├── interceptors/
│   ├── index.ts                             [Barrel export]
│   └── file-logging.interceptor.ts          [Log file operations]
│
├── decorators/
│   ├── index.ts                             [Barrel export]
│   └── has-permission.decorator.ts          [Custom @HasPermission decorator]
│
└── tests/
    ├── files.service.spec.ts                [File service unit tests]
    ├── folders.service.spec.ts              [Folder service unit tests]
    ├── file-permissions.service.spec.ts     [Permission service unit tests]
    └── files.controller.spec.ts             [File controller tests]
```

---

## 📝 File Templates

### **files.module.ts**
```typescript
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { FilesController } from './controllers';
import { FoldersController } from './controllers';
import { FileVersionsController } from './controllers';
import { FilePermissionsController } from './controllers';
import {
  FileStorageService,
  FilesService,
  FoldersService,
  FileVersionsService,
  FilePermissionsService,
} from './services';
import {
  File,
  Folder,
  FileVersion,
  FilePermission,
} from './entities';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      File,
      Folder,
      FileVersion,
      FilePermission,
    ]),
  ],
  controllers: [
    FilesController,
    FoldersController,
    FileVersionsController,
    FilePermissionsController,
  ],
  providers: [
    FileStorageService,
    FilesService,
    FoldersService,
    FileVersionsService,
    FilePermissionsService,
  ],
  exports: [
    FilesService,
    FilePermissionsService,
    FoldersService,
  ],
})
export class FilesModule {}
```

---

### **files.controller.ts** (Structure)
```typescript
import { Controller, Post, Get, Put, Delete, Param, Body, UseGuards, UseInterceptors } from '@nestjs/common';
import { FilesService } from '../services';
import { FileAccessGuard } from '../guards';
import { CurrentUser } from '@common/decorators';

@Controller('api/files')
@UseGuards(JwtAuthGuard)
export class FilesController {
  constructor(private filesService: FilesService) {}

  @Post('upload')
  @UseInterceptors(FileInterceptor('file'))
  async uploadFile(@UploadedFile() file: Express.Multer.File, @Body() dto: UploadFileDto, @CurrentUser() user) {
    // Implementation
  }

  @Get(':fileId/download')
  @UseGuards(FileAccessGuard)
  async downloadFile(@Param('fileId') fileId: number) {
    // Implementation
  }

  @Get(':fileId')
  @UseGuards(FileAccessGuard)
  async getFile(@Param('fileId') fileId: number) {
    // Implementation
  }

  @Put(':fileId')
  @UseGuards(FileAccessGuard)
  async updateFile(@Param('fileId') fileId: number, @Body() dto) {
    // Implementation
  }

  @Delete(':fileId')
  @UseGuards(FileAccessGuard)
  async deleteFile(@Param('fileId') fileId: number, @CurrentUser() user) {
    // Implementation
  }

  @Get('by-folder/:folderId')
  async getFilesByFolder(@Param('folderId') folderId: number) {
    // Implementation
  }

  @Get('search')
  async searchFiles(@Query('query') query: string) {
    // Implementation
  }
}
```

---

### **files.service.ts** (Structure)
```typescript
import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { File } from '../entities';
import { FileStorageService } from './file-storage.service';
import { FileVersionsService } from './file-versions.service';

@Injectable()
export class FilesService {
  constructor(
    @InjectRepository(File)
    private fileRepository: Repository<File>,
    private fileStorageService: FileStorageService,
    private fileVersionsService: FileVersionsService,
  ) {}

  async uploadFile(file: Express.Multer.File, userId: number, folderId?: number) {
    // 1. Store file
    // 2. Create file metadata
    // 3. Create version v1
    // 4. Return file info
  }

  async getFile(fileId: number) {
    return this.fileRepository.findOne({
      where: { file_id: fileId, status: 'active' },
      relations: ['folder', 'uploadedBy'],
    });
  }

  async updateFile(fileId: number, updates: any) {
    // Update metadata, trigger new version
  }

  async deleteFile(fileId: number, softDelete = true) {
    // Soft delete or hard delete
  }

  async getFilesByFolder(folderId: number, page = 1, limit = 20) {
    // Paginated list with permissions
  }

  async incrementDownloadCount(fileId: number) {
    // Track downloads
  }

  async searchFiles(query: string, userId: number) {
    // Full-text search with permission filtering
  }
}
```

---

### **file.entity.ts** (Structure)
```typescript
import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, JoinColumn, OneToMany } from 'typeorm';
import { User } from '@modules/auth/entities';
import { Folder } from './folder.entity';
import { FileVersion } from './file-version.entity';
import { FilePermission } from './file-permission.entity';

@Entity('files')
export class File {
  @PrimaryGeneratedColumn({ name: 'file_id' })
  file_id: number;

  @Column({ type: 'varchar', length: 255 })
  file_name: string;

  @Column({ type: 'varchar', length: 255 })
  original_filename: string;

  @Column({ type: 'varchar', length: 500 })
  file_path: string;

  @Column({ type: 'bigint', unsigned: true, nullable: true })
  file_size: number;

  @Column({ type: 'varchar', length: 100, nullable: true })
  mime_type: string;

  @Column({ type: 'varchar', length: 10, nullable: true })
  file_extension: string;

  @Column({ name: 'uploaded_by', type: 'bigint', unsigned: true })
  uploaded_by: number;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'uploaded_by' })
  uploadedByUser: User;

  @Column({ name: 'folder_id', type: 'bigint', unsigned: true, nullable: true })
  folder_id: number;

  @ManyToOne(() => Folder, (folder) => folder.files, { nullable: true })
  @JoinColumn({ name: 'folder_id' })
  folder: Folder;

  @Column({ type: 'varchar', length: 64, nullable: true })
  checksum: string;

  @Column({ type: 'int', default: 0 })
  download_count: number;

  @Column({ type: 'tinyint', default: 0 })
  is_public: boolean;

  @Column({ type: 'enum', enum: ['active', 'processing', 'archived', 'deleted'], default: 'active' })
  status: string;

  @Column({ type: 'timestamp', default: () => 'CURRENT_TIMESTAMP' })
  uploaded_at: Date;

  @Column({ type: 'timestamp', default: () => 'CURRENT_TIMESTAMP', onUpdate: 'CURRENT_TIMESTAMP' })
  updated_at: Date;

  @Column({ type: 'timestamp', nullable: true })
  deleted_at: Date;

  @OneToMany(() => FileVersion, (version) => version.file)
  versions: FileVersion[];

  @OneToMany(() => FilePermission, (perm) => perm.file)
  permissions: FilePermission[];
}
```

---

### **folder.entity.ts** (Structure)
```typescript
import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, JoinColumn, OneToMany } from 'typeorm';
import { User } from '@modules/auth/entities';
import { File } from './file.entity';

@Entity('folders')
export class Folder {
  @PrimaryGeneratedColumn({ name: 'folder_id' })
  folder_id: number;

  @Column({ type: 'varchar', length: 255 })
  folder_name: string;

  @Column({ name: 'parent_folder_id', type: 'bigint', unsigned: true, nullable: true })
  parent_folder_id: number;

  @ManyToOne(() => Folder, (folder) => folder.children, { nullable: true })
  @JoinColumn({ name: 'parent_folder_id' })
  parent: Folder;

  @Column({ name: 'created_by', type: 'bigint', unsigned: true })
  created_by: number;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'created_by' })
  createdByUser: User;

  @Column({ type: 'text', nullable: true })
  path: string;

  @Column({ type: 'int', default: 0 })
  level: number;

  @Column({ type: 'tinyint', default: 0 })
  is_system_folder: boolean;

  @Column({ type: 'timestamp', default: () => 'CURRENT_TIMESTAMP' })
  created_at: Date;

  @Column({ type: 'timestamp', default: () => 'CURRENT_TIMESTAMP', onUpdate: 'CURRENT_TIMESTAMP' })
  updated_at: Date;

  @OneToMany(() => Folder, (folder) => folder.parent)
  children: Folder[];

  @OneToMany(() => File, (file) => file.folder)
  files: File[];
}
```

---

## 🔄 Index Files (Barrel Exports)

### **services/index.ts**
```typescript
export { FileStorageService } from './file-storage.service';
export { FilesService } from './files.service';
export { FoldersService } from './folders.service';
export { FileVersionsService } from './file-versions.service';
export { FilePermissionsService } from './file-permissions.service';
```

### **controllers/index.ts**
```typescript
export { FilesController } from './files.controller';
export { FoldersController } from './folders.controller';
export { FileVersionsController } from './file-versions.controller';
export { FilePermissionsController } from './file-permissions.controller';
```

### **entities/index.ts**
```typescript
export { File } from './file.entity';
export { Folder } from './folder.entity';
export { FileVersion } from './file-version.entity';
export { FilePermission } from './file-permission.entity';
```

---

## 📋 Priority Order

1. **Entities & Module** - Get database structure right
2. **File Storage Service** - Abstract upload/download logic
3. **File & Folder Services** - Core CRUD operations
4. **Permission Service** - Access control logic
5. **Guards** - Enforce permissions
6. **Controllers** - REST endpoints
7. **DTOs & Validation** - Request/response structure
8. **Tests** - Verify everything works

---

## ✅ Completion Checklist

- [ ] All 4 entities created
- [ ] All 5 services created
- [ ] All 4 controllers created
- [ ] All DTOs created
- [ ] All guards created
- [ ] All exceptions created
- [ ] Module registered in app.module.ts
- [ ] Unit tests written (80%+ coverage)
- [ ] Integration tests written
- [ ] API documentation updated

---

## 🎓 Next Steps

1. Create directory structure
2. Create entities first
3. Create services (business logic)
4. Create controllers (HTTP endpoints)
5. Implement guards (security)
6. Write tests
7. Test with Postman

**Estimated Time:** 6 days (1 week)

---

**Version:** 1.0  
**Last Updated:** 2025-11-30
