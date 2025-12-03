import {
  IsEnum,
  IsNotEmpty,
  IsOptional,
  IsNumber,
} from 'class-validator';
import { PermissionType } from '../entities/file-permission.entity';

export class GrantPermissionDto {
  @IsEnum(PermissionType, { message: 'Invalid permission type' })
  @IsNotEmpty({ message: 'Permission type is required' })
  permissionType: PermissionType;

  @IsOptional()
  @IsNumber()
  userId?: number;

  @IsOptional()
  @IsNumber()
  roleId?: number;
}

