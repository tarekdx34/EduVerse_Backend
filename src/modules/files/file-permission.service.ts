import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { FilePermission, PermissionType } from './entities/file-permission.entity';
import { File } from './entities/file.entity';
import { User } from '../auth/entities/user.entity';
import { Role, RoleName } from '../auth/entities/role.entity';
import { PermissionDeniedException } from './exceptions/permission-denied.exception';

@Injectable()
export class FilePermissionService {
  constructor(
    @InjectRepository(FilePermission)
    private permissionRepository: Repository<FilePermission>,
    @InjectRepository(File)
    private fileRepository: Repository<File>,
    @InjectRepository(User)
    private userRepository: Repository<User>,
    @InjectRepository(Role)
    private roleRepository: Repository<Role>,
  ) {}

  async checkPermission(
    fileId: number,
    userId: number,
    requiredPermission: PermissionType,
  ): Promise<boolean> {
    const file = await this.fileRepository.findOne({
      where: { fileId },
      relations: ['uploader'],
    });

    if (!file) {
      return false;
    }

    // File owner has all permissions
    if (file.uploadedBy === userId) {
      return true;
    }

    // Check user-specific permissions
    const userPermission = await this.permissionRepository.findOne({
      where: {
        fileId,
        userId,
        permissionType: requiredPermission,
      },
    });

    if (userPermission) {
      return true;
    }

    // Check role-based permissions
    const user = await this.userRepository.findOne({
      where: { userId },
      relations: ['roles'],
    });

    if (user && user.roles) {
      for (const role of user.roles) {
        const rolePermission = await this.permissionRepository.findOne({
          where: {
            fileId,
            roleId: role.roleId,
            permissionType: requiredPermission,
          },
        });

        if (rolePermission) {
          return true;
        }
      }
    }

    // Check course-based permissions (if file belongs to a course)
    if (file.courseId) {
      // Course instructors have READ/WRITE by default
      // This would need course enrollment check - simplified for now
      // TODO: Implement course-based permission check when course module is available
    }

    return false;
  }

  async requirePermission(
    fileId: number,
    userId: number,
    requiredPermission: PermissionType,
  ): Promise<void> {
    const hasPermission = await this.checkPermission(
      fileId,
      userId,
      requiredPermission,
    );

    if (!hasPermission) {
      throw new PermissionDeniedException(
        `You do not have ${requiredPermission} permission for this file`,
      );
    }
  }

  async grantPermission(
    fileId: number,
    userId: number,
    permissionType: PermissionType,
    grantedBy: number,
    targetUserId?: number,
    targetRoleId?: number,
  ): Promise<FilePermission> {
    // Verify granter has SHARE permission
    await this.requirePermission(fileId, grantedBy, PermissionType.SHARE);

    if (!targetUserId && !targetRoleId) {
      throw new Error('Either userId or roleId must be provided');
    }

    // Check if permission already exists
    const existing = await this.permissionRepository.findOne({
      where: {
        fileId,
        userId: targetUserId || undefined,
        roleId: targetRoleId || undefined,
        permissionType,
      },
    });

    if (existing) {
      return existing;
    }

    const permission = this.permissionRepository.create({
      fileId,
      userId: targetUserId,
      roleId: targetRoleId,
      permissionType,
      grantedBy,
    });

    return await this.permissionRepository.save(permission);
  }

  async revokePermission(permissionId: number, userId: number): Promise<void> {
    const permission = await this.permissionRepository.findOne({
      where: { permissionId },
      relations: ['file'],
    });

    if (!permission) {
      return;
    }

    // Verify user has SHARE permission or is the file owner
    const file = await this.fileRepository.findOne({
      where: { fileId: permission.fileId },
    });

    if (file && file.uploadedBy !== userId) {
      await this.requirePermission(
        permission.fileId,
        userId,
        PermissionType.SHARE,
      );
    }

    await this.permissionRepository.remove(permission);
  }

  async getFilePermissions(fileId: number): Promise<FilePermission[]> {
    return await this.permissionRepository.find({
      where: { fileId },
      relations: ['user', 'role', 'granter'],
    });
  }
}

