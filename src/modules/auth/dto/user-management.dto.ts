import { IsString, IsOptional, IsEmail, IsEnum, IsNumber, IsArray, IsBoolean, MinLength, MaxLength, Matches } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
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

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  academicInterests?: string[];

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  skills?: string[];
}

export class UserStatusUpdateDto {
  @ApiProperty({ description: 'New status', enum: ['active', 'inactive', 'blocked', 'pending'], example: 'active' })
  @IsEnum(UserStatus)
  status: UserStatus;
}

export class RoleAssignmentDto {
  @IsNumber()
  roleId: number;
}

export class RoleCreateDto {
  @ApiProperty({ description: 'Role name', enum: ['student', 'instructor', 'ta', 'admin', 'it_admin'], example: 'student' })
  @IsEnum(RoleName)
  roleName: RoleName;

  @IsString()
  @IsOptional()
  roleDescription?: string;
}

export class RoleUpdateDto {
  @ApiPropertyOptional({ description: 'Role name', enum: ['student', 'instructor', 'ta', 'admin', 'it_admin'], example: 'student' })
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

export class BulkPermissionsDto {
  @ApiProperty({ description: 'Array of permission IDs to assign to the role', example: [1, 2, 3], type: [Number] })
  @IsArray()
  @IsNumber({}, { each: true })
  permissionIds: number[];
}

export class UserFilterDto {
  @ApiPropertyOptional({ description: 'Filter by status', enum: ['active', 'inactive', 'blocked', 'pending'] })
  @IsOptional()
  @IsEnum(UserStatus)
  status?: UserStatus;

  @ApiPropertyOptional({ description: 'Filter by role name', example: 'student' })
  @IsOptional()
  @IsString()
  role?: string;

  @ApiPropertyOptional({ description: 'Filter by campus ID', example: 1 })
  @IsOptional()
  @IsNumber()
  campusId?: number;
}

export class BulkImportResultDto {
  imported: number;
  failed: number;
  errors: Array<{ row: number; email?: string; reason: string }>;
}

export class BulkStatusDto {
  @ApiProperty({ description: 'Array of user IDs to update', example: [1, 2, 3], type: [Number] })
  @IsArray()
  @IsNumber({}, { each: true })
  userIds: number[];

  @ApiProperty({ description: 'New status to set', example: 'active' })
  @IsString()
  status: string;
}

export class UpdateProfileDto {
  @IsOptional()
  @IsString()
  @MaxLength(50)
  firstName?: string;

  @IsOptional()
  @IsString()
  @MaxLength(50)
  lastName?: string;

  @IsOptional()
  @IsString()
  @MaxLength(20)
  phone?: string;

  @IsOptional()
  @IsString()
  profilePictureUrl?: string;

  @IsOptional()
  @IsString()
  @MaxLength(500)
  bio?: string;

  @IsOptional()
  socialLinks?: Record<string, string>;

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  academicInterests?: string[];

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  skills?: string[];
}

export class UpdateUserPreferencesDto {
  @IsOptional()
  @IsString()
  @MaxLength(10)
  language?: string;

  @IsOptional()
  @IsString()
  @MaxLength(20)
  theme?: string;

  @IsOptional()
  @IsBoolean()
  emailNotifications?: boolean;

  @IsOptional()
  @IsBoolean()
  pushNotifications?: boolean;
}

export class ChangePasswordDto {
  @IsString()
  @MinLength(1)
  currentPassword: string;

  @IsString()
  @MinLength(8)
  @Matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])/, {
    message: 'Password must contain uppercase, lowercase, number, and special character',
  })
  newPassword: string;
}
