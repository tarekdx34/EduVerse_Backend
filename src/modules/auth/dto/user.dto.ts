import { Exclude } from 'class-transformer';
import { UserStatus } from '../entities/user.entity';
import { RoleName } from '../entities/role.entity';

export class UserDto {
  userId: number;
  email: string;
  firstName: string;
  lastName: string;
  fullName: string;
  phone?: string;
  profilePictureUrl?: string;
  campusId?: number;
  status: UserStatus;
  emailVerified: boolean;
  lastLoginAt?: Date;
  roles: RoleName[];
  createdAt: Date;

  @Exclude()
  passwordHash: string;

  @Exclude()
  updatedAt: Date;

  @Exclude()
  deletedAt?: Date;
}
