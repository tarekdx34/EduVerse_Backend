import {
  Injectable,
  BadRequestException,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, IsNull } from 'typeorm';
import { plainToClass } from 'class-transformer';
import { UserStatus } from './enums/user-status.enum';
import { User } from './entities/user.entity';
import { Role, RoleName } from './entities/role.entity';
import { Permission } from './entities/permission.entity';
import { UserPreference } from './entities/user-preference.entity';
import {
  UserUpdateDto,
  UserStatusUpdateDto,
  RoleAssignmentDto,
  RoleCreateDto,
  RoleUpdateDto,
  PermissionCreateDto,
  PermissionUpdateDto,
  PermissionAssignmentDto,
  UserFilterDto,
  BulkPermissionsDto,
  BulkImportResultDto,
  BulkStatusDto,
  UpdateProfileDto,
  UpdateUserPreferencesDto,
  ChangePasswordDto,
} from './dto/user-management.dto';
import {
  UserResponseDto,
  UserListResponseDto,
  RoleResponseDto,
  PermissionResponseDto,
  PaginatedResponseDto,
} from './dto/user-response.dto';

@Injectable()
export class UserManagementService {
  constructor(
    @InjectRepository(User)
    private userRepository: Repository<User>,
    @InjectRepository(Role)
    private roleRepository: Repository<Role>,
    @InjectRepository(Permission)
    private permissionRepository: Repository<Permission>,
    @InjectRepository(UserPreference)
    private userPreferenceRepository: Repository<UserPreference>,
  ) {}

  // ============ USER MANAGEMENT ============

  async getUsers(
    page: number = 1,
    size: number = 10,
    sort: string = 'createdAt',
    filters?: UserFilterDto,
  ): Promise<PaginatedResponseDto<UserListResponseDto>> {
    const skip = (page - 1) * size;

    let query = this.userRepository
      .createQueryBuilder('user')
      .leftJoinAndSelect('user.roles', 'roles')
      .where('user.deletedAt IS NULL');

    if (filters?.status) {
      query = query.andWhere('user.status = :status', {
        status: filters.status,
      });
    }

    if (filters?.campusId) {
      query = query.andWhere('user.campusId = :campusId', {
        campusId: filters.campusId,
      });
    }

    if (filters?.role) {
      query = query.andWhere('roles.roleName = :roleName', {
        roleName: filters.role,
      });
    }

    const [data, total] = await query
      .orderBy(`user.${sort}`, 'DESC')
      .skip(skip)
      .take(size)
      .getManyAndCount();

    const totalPages = Math.ceil(total / size);

    return {
      data: data.map((user) => this.transformToUserListDto(user)),
      total,
      page,
      size,
      totalPages,
      hasNextPage: page < totalPages,
      hasPreviousPage: page > 1,
    };
  }

  async getUserById(userId: number): Promise<UserResponseDto> {
    const user = await this.userRepository.findOne({
      where: { userId, deletedAt: IsNull() as any },
      relations: ['roles', 'roles.permissions'],
    });

    if (!user) {
      throw new NotFoundException(`User with ID ${userId} not found`);
    }

    return this.transformToUserDto(user);
  }

  async updateUser(
    userId: number,
    updateDto: UserUpdateDto,
  ): Promise<UserResponseDto> {
    const user = await this.userRepository.findOne({
      where: { userId, deletedAt: IsNull() as any },
      relations: ['roles', 'roles.permissions'],
    });

    if (!user) {
      throw new NotFoundException(`User with ID ${userId} not found`);
    }

    if (updateDto.firstName) user.firstName = updateDto.firstName;
    if (updateDto.lastName) user.lastName = updateDto.lastName;
    if (updateDto.phone !== undefined) user.phone = updateDto.phone;
    if (updateDto.profilePictureUrl !== undefined)
      user.profilePictureUrl = updateDto.profilePictureUrl;
    if (updateDto.campusId !== undefined) user.campusId = updateDto.campusId;

    await this.userRepository.save(user);

    return this.transformToUserDto(user);
  }

  async deleteUser(userId: number): Promise<void> {
    const user = await this.userRepository.findOne({
      where: { userId, deletedAt: IsNull() as any },
    });

    if (!user) {
      throw new NotFoundException(`User with ID ${userId} not found`);
    }

    user.deletedAt = new Date();
    await this.userRepository.save(user);
  }

  async updateUserStatus(
    userId: number,
    statusDto: UserStatusUpdateDto,
  ): Promise<UserResponseDto> {
    const user = await this.userRepository.findOne({
      where: { userId, deletedAt: IsNull() as any },
      relations: ['roles', 'roles.permissions'],
    });

    if (!user) {
      throw new NotFoundException(`User with ID ${userId} not found`);
    }

    user.status = statusDto.status;
    await this.userRepository.save(user);

    return this.transformToUserDto(user);
  }

  async searchUsers(query: string): Promise<UserListResponseDto[]> {
    const users = await this.userRepository
      .createQueryBuilder('user')
      .leftJoinAndSelect('user.roles', 'roles')
      .where('user.deletedAt IS NULL')
      .andWhere(
        `(
        LOWER(user.firstName) LIKE LOWER(:query) OR 
        LOWER(user.lastName) LIKE LOWER(:query) OR 
        LOWER(user.email) LIKE LOWER(:query)
      )`,
        { query: `%${query}%` },
      )
      .take(20)
      .getMany();

    return users.map((user) => this.transformToUserListDto(user));
  }

  // ============ USER ROLE MANAGEMENT ============

  async assignRoleToUser(
    userId: number,
    roleDto: RoleAssignmentDto,
  ): Promise<UserResponseDto> {
    const user = await this.userRepository.findOne({
      where: { userId, deletedAt: IsNull() as any },
      relations: ['roles'],
    });

    if (!user) {
      throw new NotFoundException(`User with ID ${userId} not found`);
    }

    const role = await this.roleRepository.findOne({
      where: { roleId: roleDto.roleId },
    });

    if (!role) {
      throw new NotFoundException(`Role with ID ${roleDto.roleId} not found`);
    }

    if (!user.roles) user.roles = [];
    if (user.roles.find((r) => r.roleId === role.roleId)) {
      throw new BadRequestException('User already has this role');
    }

    user.roles.push(role);
    await this.userRepository.save(user);

    return this.getUserById(userId);
  }

  async removeRoleFromUser(userId: number, roleId: number): Promise<void> {
    const user = await this.userRepository.findOne({
      where: { userId, deletedAt: IsNull() as any },
      relations: ['roles'],
    });

    if (!user) {
      throw new NotFoundException(`User with ID ${userId} not found`);
    }

    const roleIndex = user.roles.findIndex((r) => r.roleId === roleId);

    if (roleIndex === -1) {
      throw new NotFoundException('User does not have this role');
    }

    user.roles.splice(roleIndex, 1);
    await this.userRepository.save(user);
  }

  async getUserPermissions(userId: number): Promise<PermissionResponseDto[]> {
    const user = await this.userRepository.findOne({
      where: { userId, deletedAt: IsNull() as any },
      relations: ['roles', 'roles.permissions'],
    });

    if (!user) {
      throw new NotFoundException(`User with ID ${userId} not found`);
    }

    const permissionsSet = new Set<number>();
    const permissions: PermissionResponseDto[] = [];

    user.roles.forEach((role) => {
      role.permissions.forEach((permission) => {
        if (!permissionsSet.has(permission.permissionId)) {
          permissionsSet.add(permission.permissionId);
          permissions.push(this.transformToPermissionDto(permission));
        }
      });
    });

    return permissions;
  }

  // ============ ROLE MANAGEMENT ============

  async getAllRoles(): Promise<RoleResponseDto[]> {
    const roles = await this.roleRepository.find({
      relations: ['permissions'],
    });

    return roles.map((role) => this.transformToRoleDto(role));
  }

  async getRolesWithUserCounts(): Promise<any[]> {
    const roles = await this.roleRepository
      .createQueryBuilder('role')
      .leftJoin('role.users', 'user')
      .select('role.roleId', 'roleId')
      .addSelect('role.roleName', 'roleName')
      .addSelect('role.roleDescription', 'roleDescription')
      .addSelect('COUNT(user.userId)', 'userCount')
      .groupBy('role.roleId')
      .getRawMany();
    return roles.map((r) => ({ ...r, userCount: parseInt(r.userCount) || 0 }));
  }

  async getRoleById(roleId: number): Promise<RoleResponseDto> {
    const role = await this.roleRepository.findOne({
      where: { roleId },
      relations: ['permissions'],
    });

    if (!role) {
      throw new NotFoundException(`Role with ID ${roleId} not found`);
    }

    return this.transformToRoleDto(role);
  }

  async createRole(createDto: RoleCreateDto): Promise<RoleResponseDto> {
    const existingRole = await this.roleRepository.findOne({
      where: { roleName: createDto.roleName as RoleName },
    });

    if (existingRole) {
      throw new BadRequestException(
        `Role '${createDto.roleName}' already exists`,
      );
    }

    const role = this.roleRepository.create({
      roleName: createDto.roleName as RoleName,
      roleDescription: createDto.roleDescription,
      permissions: [],
    });

    await this.roleRepository.save(role);

    return this.transformToRoleDto(role);
  }

  async updateRole(
    roleId: number,
    updateDto: RoleUpdateDto,
  ): Promise<RoleResponseDto> {
    const role = await this.roleRepository.findOne({
      where: { roleId },
      relations: ['permissions'],
    });

    if (!role) {
      throw new NotFoundException(`Role with ID ${roleId} not found`);
    }

    if (updateDto.roleName && updateDto.roleName !== role.roleName) {
      const existing = await this.roleRepository.findOne({
        where: { roleName: updateDto.roleName as RoleName },
      });
      if (existing) {
        throw new BadRequestException(
          `Role '${updateDto.roleName}' already exists`,
        );
      }
      role.roleName = updateDto.roleName as RoleName;
    }

    if (updateDto.roleDescription !== undefined) {
      role.roleDescription = updateDto.roleDescription;
    }

    await this.roleRepository.save(role);

    return this.transformToRoleDto(role);
  }

  async deleteRole(roleId: number): Promise<void> {
    const role = await this.roleRepository.findOne({
      where: { roleId },
      relations: ['users'],
    });

    if (!role) {
      throw new NotFoundException(`Role with ID ${roleId} not found`);
    }

    if (role.users && role.users.length > 0) {
      throw new BadRequestException(
        'Cannot delete role that is assigned to users',
      );
    }

    await this.roleRepository.remove(role);
  }

  // ============ PERMISSION MANAGEMENT ============

  async getAllPermissions(): Promise<PermissionResponseDto[]> {
    const permissions = await this.permissionRepository.find();
    return permissions.map((p) => this.transformToPermissionDto(p));
  }

  async getPermissionMatrix(): Promise<any> {
    const roles = await this.roleRepository.find({
      relations: ['permissions'],
    });
    const allPermissions = await this.permissionRepository.find({
      order: { module: 'ASC', permissionName: 'ASC' },
    });

    const matrix: Record<number, number[]> = {};
    roles.forEach((role) => {
      matrix[role.roleId] = role.permissions.map((p) => p.permissionId);
    });

    return {
      roles: roles.map((r) => ({
        roleId: r.roleId,
        roleName: r.roleName,
        roleDescription: r.roleDescription,
      })),
      permissions: allPermissions.map((p) => ({
        permissionId: p.permissionId,
        permissionName: p.permissionName,
        permissionDescription: p.permissionDescription,
        module: p.module,
      })),
      matrix,
    };
  }

  async getPermissionsByModule(
    module: string,
  ): Promise<PermissionResponseDto[]> {
    const permissions = await this.permissionRepository.find({
      where: { module },
    });
    return permissions.map((p) => this.transformToPermissionDto(p));
  }

  async createPermission(
    createDto: PermissionCreateDto,
  ): Promise<PermissionResponseDto> {
    const existing = await this.permissionRepository.findOne({
      where: { permissionName: createDto.permissionName },
    });

    if (existing) {
      throw new BadRequestException(
        `Permission '${createDto.permissionName}' already exists`,
      );
    }

    const permission = this.permissionRepository.create({
      permissionName: createDto.permissionName,
      permissionDescription: createDto.permissionDescription,
      module: createDto.module,
    });

    await this.permissionRepository.save(permission);

    return this.transformToPermissionDto(permission);
  }

  async updatePermission(
    permissionId: number,
    updateDto: PermissionUpdateDto,
  ): Promise<PermissionResponseDto> {
    const permission = await this.permissionRepository.findOne({
      where: { permissionId },
    });

    if (!permission) {
      throw new NotFoundException(
        `Permission with ID ${permissionId} not found`,
      );
    }

    if (
      updateDto.permissionName &&
      updateDto.permissionName !== permission.permissionName
    ) {
      const existing = await this.permissionRepository.findOne({
        where: { permissionName: updateDto.permissionName },
      });
      if (existing) {
        throw new BadRequestException(
          `Permission '${updateDto.permissionName}' already exists`,
        );
      }
      permission.permissionName = updateDto.permissionName;
    }

    if (updateDto.permissionDescription !== undefined) {
      permission.permissionDescription = updateDto.permissionDescription;
    }

    if (updateDto.module !== undefined) {
      permission.module = updateDto.module;
    }

    await this.permissionRepository.save(permission);

    return this.transformToPermissionDto(permission);
  }

  async deletePermission(permissionId: number): Promise<void> {
    const permission = await this.permissionRepository.findOne({
      where: { permissionId },
      relations: ['roles'],
    });

    if (!permission) {
      throw new NotFoundException(
        `Permission with ID ${permissionId} not found`,
      );
    }

    if (permission.roles && permission.roles.length > 0) {
      throw new BadRequestException(
        'Cannot delete permission that is assigned to roles',
      );
    }

    await this.permissionRepository.remove(permission);
  }

  // ============ ROLE PERMISSION MANAGEMENT ============

  async addPermissionToRole(
    roleId: number,
    permDto: PermissionAssignmentDto,
  ): Promise<RoleResponseDto> {
    const role = await this.roleRepository.findOne({
      where: { roleId },
      relations: ['permissions'],
    });

    if (!role) {
      throw new NotFoundException(`Role with ID ${roleId} not found`);
    }

    const permission = await this.permissionRepository.findOne({
      where: { permissionId: permDto.permissionId },
    });

    if (!permission) {
      throw new NotFoundException(
        `Permission with ID ${permDto.permissionId} not found`,
      );
    }

    if (
      role.permissions.find((p) => p.permissionId === permission.permissionId)
    ) {
      throw new BadRequestException('Role already has this permission');
    }

    role.permissions.push(permission);
    await this.roleRepository.save(role);

    return this.getRoleById(roleId);
  }

  async removePermissionFromRole(
    roleId: number,
    permissionId: number,
  ): Promise<void> {
    const role = await this.roleRepository.findOne({
      where: { roleId },
      relations: ['permissions'],
    });

    if (!role) {
      throw new NotFoundException(`Role with ID ${roleId} not found`);
    }

    const permIndex = role.permissions.findIndex(
      (p) => p.permissionId === permissionId,
    );

    if (permIndex === -1) {
      throw new NotFoundException('Role does not have this permission');
    }

    role.permissions.splice(permIndex, 1);
    await this.roleRepository.save(role);
  }

  async bulkSetPermissions(
    roleId: number,
    permissionIds: number[],
  ): Promise<RoleResponseDto> {
    const role = await this.roleRepository.findOne({
      where: { roleId },
      relations: ['permissions'],
    });

    if (!role) {
      throw new NotFoundException(`Role with ID ${roleId} not found`);
    }

    const permissions =
      await this.permissionRepository.findByIds(permissionIds);
    role.permissions = permissions;
    await this.roleRepository.save(role);

    return this.getRoleById(roleId);
  }

  // ============ BULK IMPORT ============

  async bulkImportUsers(fileBuffer: Buffer): Promise<BulkImportResultDto> {
    const content = fileBuffer.toString('utf-8');
    const lines = content.split(/\r?\n/).filter((line) => line.trim() !== '');

    if (lines.length < 2) {
      throw new BadRequestException(
        'CSV file must contain a header row and at least one data row',
      );
    }

    const header = lines[0].split(',').map((h) => h.trim().toLowerCase());
    const emailIdx = header.indexOf('email');
    const firstNameIdx = header.indexOf('firstname');
    const lastNameIdx = header.indexOf('lastname');
    const roleIdx = header.indexOf('role');
    const phoneIdx = header.indexOf('phone');

    if (
      emailIdx === -1 ||
      firstNameIdx === -1 ||
      lastNameIdx === -1 ||
      roleIdx === -1
    ) {
      throw new BadRequestException(
        'CSV must contain columns: email, firstName, lastName, role. Optional: phone',
      );
    }

    const validRoleNames = Object.values(RoleName) as string[];
    const result: BulkImportResultDto = { imported: 0, failed: 0, errors: [] };

    for (let i = 1; i < lines.length; i++) {
      const cols = lines[i].split(',').map((c) => c.trim());
      const rowNum = i + 1;
      const email = cols[emailIdx] || '';
      const firstName = cols[firstNameIdx] || '';
      const lastName = cols[lastNameIdx] || '';
      const roleName = cols[roleIdx] || '';
      const phone = phoneIdx !== -1 ? cols[phoneIdx] : undefined;

      // Validate required fields
      if (!email || !firstName || !lastName || !roleName) {
        result.failed++;
        result.errors.push({
          row: rowNum,
          email: email || undefined,
          reason: 'Missing required fields',
        });
        continue;
      }

      // Validate email format
      const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
      if (!emailRegex.test(email)) {
        result.failed++;
        result.errors.push({
          row: rowNum,
          email,
          reason: 'Invalid email format',
        });
        continue;
      }

      // Validate role
      if (!validRoleNames.includes(roleName)) {
        result.failed++;
        result.errors.push({
          row: rowNum,
          email,
          reason: `Invalid role '${roleName}'. Valid: ${validRoleNames.join(', ')}`,
        });
        continue;
      }

      // Check for duplicate email
      const existingUser = await this.userRepository.findOne({
        where: { email },
        withDeleted: true,
      });
      if (existingUser) {
        result.failed++;
        result.errors.push({
          row: rowNum,
          email,
          reason: 'Email already exists',
        });
        continue;
      }

      // Find role entity
      const role = await this.roleRepository.findOne({
        where: { roleName: roleName as RoleName },
      });
      if (!role) {
        result.failed++;
        result.errors.push({
          row: rowNum,
          email,
          reason: `Role '${roleName}' not found in database`,
        });
        continue;
      }

      try {
        const user = this.userRepository.create({
          email,
          firstName,
          lastName,
          passwordHash: 'EduVerse@2024',
          phone: phone || undefined,
          roles: [role],
        });

        await this.userRepository.save(user);
        result.imported++;
      } catch (error) {
        result.failed++;
        result.errors.push({
          row: rowNum,
          email,
          reason: error.message || 'Unknown error',
        });
      }
    }

    return result;
  }

  // ============ BULK STATUS UPDATE ============

  async bulkUpdateStatus(dto: BulkStatusDto): Promise<{ updated: number }> {
    const result = await this.userRepository
      .createQueryBuilder()
      .update()
      .set({ status: dto.status as any })
      .whereInIds(dto.userIds)
      .execute();

    return { updated: result.affected || 0 };
  }

  // ============ USER STATISTICS ============

  async getUserStatistics(): Promise<any> {
    const totalUsers = await this.userRepository.count();
    const activeUsers = await this.userRepository.count({
      where: { status: 'active' as any },
    });
    const inactiveUsers = await this.userRepository.count({
      where: { status: 'inactive' as any },
    });
    const suspendedUsers = await this.userRepository.count({
      where: { status: 'suspended' as any },
    });
    const pendingUsers = await this.userRepository.count({
      where: { status: 'pending' as any },
    });

    const registrationsByMonth = await this.userRepository
      .createQueryBuilder('user')
      .select("DATE_FORMAT(user.created_at, '%Y-%m')", 'month')
      .addSelect('COUNT(*)', 'count')
      .where('user.created_at >= DATE_SUB(NOW(), INTERVAL 12 MONTH)')
      .groupBy('month')
      .orderBy('month', 'ASC')
      .getRawMany();

    const roleDistribution = await this.userRepository
      .createQueryBuilder('user')
      .leftJoin('user.roles', 'role')
      .select('role.roleName', 'role')
      .addSelect('COUNT(user.userId)', 'count')
      .groupBy('role.roleName')
      .getRawMany();

    return {
      totalUsers,
      activeUsers,
      inactiveUsers,
      suspendedUsers,
      pendingUsers,
      registrationsByMonth,
      roleDistribution,
    };
  }

  // ============ USER EXPORT ============

  async exportUsers(format: string): Promise<any> {
    const users = await this.userRepository.find({
      relations: ['roles'],
      where: { deletedAt: IsNull() as any },
    });

    if (format === 'csv') {
      const header = 'email,firstName,lastName,phone,status,roles,createdAt';
      const rows = users.map((user) => {
        const roles = user.roles
          ? (user.roles as Role[]).map((r) => r.roleName).join(';')
          : '';
        const phone = user.phone || '';
        const createdAt = user.createdAt ? user.createdAt.toISOString() : '';
        return `${user.email},${user.firstName},${user.lastName},${phone},${user.status},${roles},${createdAt}`;
      });
      return [header, ...rows].join('\n');
    }

    return users.map((user) => ({
      email: user.email,
      firstName: user.firstName,
      lastName: user.lastName,
      phone: user.phone,
      status: user.status,
      roles: user.roles ? (user.roles as Role[]).map((r) => r.roleName) : [],
      createdAt: user.createdAt,
    }));
  }

  // ============ HELPER METHODS ============

  private transformToUserDto(user: User): UserResponseDto {
    const userDto = plainToClass(UserResponseDto, user, {
      excludeExtraneousValues: false,
    });

    if (user.roles && Array.isArray(user.roles)) {
      userDto.roles = (user.roles as Role[]).map((role) =>
        this.transformToRoleDto(role),
      );
    }

    return userDto;
  }

  private transformToUserListDto(user: User): UserListResponseDto {
    const userDto = plainToClass(UserListResponseDto, user, {
      excludeExtraneousValues: false,
    });

    if (user.roles && Array.isArray(user.roles)) {
      userDto.roles = (user.roles as Role[]).map(
        (role) =>
          ({
            roleId: role.roleId,
            roleName: role.roleName,
          }) as RoleResponseDto,
      );
    }

    return userDto;
  }

  private transformToRoleDto(role: Role): RoleResponseDto {
    const roleDto = plainToClass(RoleResponseDto, role, {
      excludeExtraneousValues: false,
    });

    if (role.permissions && Array.isArray(role.permissions)) {
      roleDto.permissions = (role.permissions as Permission[]).map((p) =>
        this.transformToPermissionDto(p),
      );
      roleDto.permissionCount = role.permissions.length;
    }

    return roleDto;
  }

  private transformToPermissionDto(
    permission: Permission,
  ): PermissionResponseDto {
    return plainToClass(PermissionResponseDto, permission, {
      excludeExtraneousValues: false,
    });
  }

  // ============ USER SELF-SERVICE ============

  async getProfile(userId: number) {
    const user = await this.userRepository.findOne({
      where: { userId },
      relations: ['roles'],
    });
    if (!user) throw new NotFoundException('User not found');

    const fields = [
      user.firstName,
      user.lastName,
      user.email,
      user.phone,
      user.profilePictureUrl,
      user.bio,
    ];
    const filled = fields.filter(
      (f) => f && String(f).trim().length > 0,
    ).length;
    const completeness = Math.round((filled / fields.length) * 100);

    return {
      userId: user.userId,
      email: user.email,
      firstName: user.firstName,
      lastName: user.lastName,
      phone: user.phone,
      profilePictureUrl: user.profilePictureUrl,
      bio: user.bio,
      socialLinks: user.socialLinks,
      academicInterests: user.academicInterests || [],
      skills: user.skills || [],
      status: user.status,
      emailVerified: user.emailVerified,
      roles: user.roles?.map((r) => r.roleName) || [],
      createdAt: user.createdAt,
      profileCompleteness: completeness,
    };
  }

  async getPublicProfile(userId: number) {
    const user = await this.userRepository.findOne({
      where: { userId },
      relations: ['roles'],
    });
    if (!user) throw new NotFoundException('User not found');

    return {
      userId: user.userId,
      email: user.email,
      firstName: user.firstName,
      lastName: user.lastName,
      fullName: `${user.firstName || ''} ${user.lastName || ''}`.trim(),
      profilePictureUrl: user.profilePictureUrl,
      bio: user.bio,
      socialLinks: user.socialLinks,
      academicInterests: user.academicInterests || [],
      skills: user.skills || [],
      roles: user.roles?.map((r) => r.roleName) || [],
    };
  }

  async updateProfile(userId: number, dto: UpdateProfileDto) {
    const user = await this.userRepository.findOne({ where: { userId } });
    if (!user) throw new NotFoundException('User not found');

    if (dto.firstName !== undefined) user.firstName = dto.firstName;
    if (dto.lastName !== undefined) user.lastName = dto.lastName;
    if (dto.phone !== undefined) user.phone = dto.phone;
    if (dto.profilePictureUrl !== undefined)
      user.profilePictureUrl = dto.profilePictureUrl;
    if (dto.bio !== undefined) user.bio = dto.bio;
    if (dto.socialLinks !== undefined) user.socialLinks = dto.socialLinks;
    if (dto.academicInterests !== undefined) user.academicInterests = dto.academicInterests;
    if (dto.skills !== undefined) user.skills = dto.skills;

    await this.userRepository.save(user);
    return this.getProfile(userId);
  }

  async getPreferences(userId: number) {
    let prefs = await this.userPreferenceRepository.findOne({
      where: { userId },
    });
    if (!prefs) {
      prefs = this.userPreferenceRepository.create({
        userId,
        language: 'en',
        theme: 'light',
        emailNotifications: true,
        pushNotifications: true,
      });
      prefs = await this.userPreferenceRepository.save(prefs);
    }
    return {
      language: prefs.language,
      theme: prefs.theme,
      emailNotifications: prefs.emailNotifications,
      pushNotifications: prefs.pushNotifications,
    };
  }

  async updatePreferences(userId: number, dto: UpdateUserPreferencesDto) {
    let prefs = await this.userPreferenceRepository.findOne({
      where: { userId },
    });
    if (!prefs) {
      prefs = this.userPreferenceRepository.create({ userId });
    }
    if (dto.language !== undefined) prefs.language = dto.language;
    if (dto.theme !== undefined) prefs.theme = dto.theme;
    if (dto.emailNotifications !== undefined)
      prefs.emailNotifications = dto.emailNotifications;
    if (dto.pushNotifications !== undefined)
      prefs.pushNotifications = dto.pushNotifications;

    await this.userPreferenceRepository.save(prefs);
    return this.getPreferences(userId);
  }

  async changePassword(userId: number, dto: ChangePasswordDto) {
    const user = await this.userRepository.findOne({ where: { userId } });
    if (!user) throw new NotFoundException('User not found');

    const isValid = await user.validatePassword(dto.currentPassword);
    if (!isValid)
      throw new BadRequestException('Current password is incorrect');

    user.passwordHash = dto.newPassword;
    await this.userRepository.save(user);

    return { message: 'Password changed successfully' };
  }
}
