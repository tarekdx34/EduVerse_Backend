import { IsString, IsOptional, IsEmail, IsEnum, IsNumber, MinLength, MaxLength } from 'class-validator';
import { UserStatus } from '../entities/user.entity';
import { RoleName } from '../entities/role.entity';

export class UserUpdateDto {
  @IsString()
  @IsOptional()
  @MinLength(2)
  @MaxLength(50)
  firstName?: string;

  @IsString()
  @IsOptional()
  @MinLength(2)
  @MaxLength(50)
  lastName?: string;

  @IsString()
  @IsOptional()
  phone?: string;

  @IsString()
  @IsOptional()
  profilePictureUrl?: string;

  @IsNumber()
  @IsOptional()
  campusId?: number;
}

export class UserStatusUpdateDto {
  @IsEnum(UserStatus)
  status: UserStatus;
}

export class RoleAssignmentDto {
  @IsNumber()
  roleId: number;
}

export class RoleCreateDto {
  @IsEnum(RoleName)
  roleName: RoleName;

  @IsString()
  @IsOptional()
  roleDescription?: string;
}

export class RoleUpdateDto {
  @IsEnum(RoleName)
  @IsOptional()
  roleName?: RoleName;

  @IsString()
  @IsOptional()
  roleDescription?: string;
}

export class PermissionCreateDto {
  @IsString()
  @MinLength(2)
  @MaxLength(100)
  permissionName: string;

  @IsString()
  @IsOptional()
  permissionDescription?: string;

  @IsString()
  @IsOptional()
  @MaxLength(50)
  module?: string;
}

export class PermissionUpdateDto {
  @IsString()
  @IsOptional()
  @MinLength(2)
  @MaxLength(100)
  permissionName?: string;

  @IsString()
  @IsOptional()
  permissionDescription?: string;

  @IsString()
  @IsOptional()
  @MaxLength(50)
  module?: string;
}

export class PermissionAssignmentDto {
  @IsNumber()
  permissionId: number;
}

export class UserSearchDto {
  @IsString()
  @MinLength(1)
  query: string;
}

export class UserFilterDto {
  @IsOptional()
  @IsEnum(UserStatus)
  status?: UserStatus;

  @IsOptional()
  @IsString()
  role?: string;

  @IsOptional()
  @IsNumber()
  campusId?: number;
}
