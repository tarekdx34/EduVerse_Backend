import { Expose } from 'class-transformer';

export class PermissionResponseDto {
  @Expose()
  permissionId: number;

  @Expose()
  permissionName: string;

  @Expose()
  permissionDescription?: string;

  @Expose()
  module?: string;
}

export class RoleResponseDto {
  @Expose()
  roleId: number;

  @Expose()
  roleName: string;

  @Expose()
  roleDescription?: string;

  @Expose()
  permissions?: PermissionResponseDto[];

  @Expose()
  permissionCount?: number;
}

export class UserResponseDto {
  @Expose()
  userId: number;

  @Expose()
  email: string;

  @Expose()
  firstName: string;

  @Expose()
  lastName: string;

  @Expose()
  fullName: string;

  @Expose()
  phone?: string;

  @Expose()
  profilePictureUrl?: string;

  @Expose()
  campusId?: number;

  @Expose()
  status: string;

  @Expose()
  emailVerified: boolean;

  @Expose()
  lastLoginAt?: Date;

  @Expose()
  createdAt: Date;

  @Expose()
  updatedAt: Date;

  @Expose()
  roles?: RoleResponseDto[];
}

export class UserListResponseDto {
  @Expose()
  userId: number;

  @Expose()
  email: string;

  @Expose()
  firstName: string;

  @Expose()
  lastName: string;

  @Expose()
  fullName: string;

  @Expose()
  status: string;

  @Expose()
  emailVerified: boolean;

  @Expose()
  createdAt: Date;

  @Expose()
  roles?: RoleResponseDto[];
}

export class PaginatedResponseDto<T> {
  data: T[];
  total: number;
  page: number;
  size: number;
  totalPages: number;
  hasNextPage: boolean;
  hasPreviousPage: boolean;
}
