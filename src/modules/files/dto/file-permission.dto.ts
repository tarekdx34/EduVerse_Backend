import { PermissionType } from '../entities/file-permission.entity';

export class FilePermissionDto {
  permissionId: number;
  fileId: number;
  userId?: number;
  userName?: string;
  roleId?: number;
  roleName?: string;
  permissionType: PermissionType;
  grantedBy: number;
  granterName?: string;
  createdAt: Date;
}

