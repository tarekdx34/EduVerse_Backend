import {
  Injectable,
  BadRequestException,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, IsNull } from 'typeorm';
import { plainToClass } from 'class-transformer';
import { User, UserStatus } from './entities/user.entity';
import { Role, RoleName } from './entities/role.entity';
import { Permission } from './entities/permission.entity';
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
      query = query.andWhere('user.status = :status', { status: filters.status });
    }

    if (filters?.campusId) {
      query = query.andWhere('user.campusId = :campusId', { campusId: filters.campusId });
    }

    if (filters?.role) {
      query = query.andWhere('roles.roleName = :roleName', { roleName: filters.role });
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

  async updateUser(userId: number, updateDto: UserUpdateDto): Promise<UserResponseDto> {
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
    if (updateDto.profilePictureUrl !== undefined) user.profilePictureUrl = updateDto.profilePictureUrl;
    if (updateDto.campusId !== undefined) user.campusId = updateDto.campusId;

    await this.userRepository.save(user);

    return this.transformToUserDto(user);
  }

  async deleteUser(userId: number): Promise<void> {
    const user = await this.userRepository.findOne({ where: { userId, deletedAt: IsNull() as any } });

    if (!user) {
      throw new NotFoundException(`User with ID ${userId} not found`);
    }

    user.deletedAt = new Date();
    await this.userRepository.save(user);
  }

  async updateUserStatus(userId: number, statusDto: UserStatusUpdateDto): Promise<UserResponseDto> {
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

  async assignRoleToUser(userId: number, roleDto: RoleAssignmentDto): Promise<UserResponseDto> {
    const user = await this.userRepository.findOne({
      where: { userId, deletedAt: IsNull() as any },
      relations: ['roles'],
    });

    if (!user) {
      throw new NotFoundException(`User with ID ${userId} not found`);
    }

    const role = await this.roleRepository.findOne({ where: { roleId: roleDto.roleId } });

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
      throw new BadRequestException(`Role '${createDto.roleName}' already exists`);
    }

    const role = this.roleRepository.create({
      roleName: createDto.roleName as RoleName,
      roleDescription: createDto.roleDescription,
      permissions: [],
    });

    await this.roleRepository.save(role);

    return this.transformToRoleDto(role);
  }

  async updateRole(roleId: number, updateDto: RoleUpdateDto): Promise<RoleResponseDto> {
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
        throw new BadRequestException(`Role '${updateDto.roleName}' already exists`);
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
      throw new BadRequestException('Cannot delete role that is assigned to users');
    }

    await this.roleRepository.remove(role);
  }

  // ============ PERMISSION MANAGEMENT ============

  async getAllPermissions(): Promise<PermissionResponseDto[]> {
    const permissions = await this.permissionRepository.find();
    return permissions.map((p) => this.transformToPermissionDto(p));
  }

  async getPermissionsByModule(module: string): Promise<PermissionResponseDto[]> {
    const permissions = await this.permissionRepository.find({
      where: { module },
    });
    return permissions.map((p) => this.transformToPermissionDto(p));
  }

  async createPermission(createDto: PermissionCreateDto): Promise<PermissionResponseDto> {
    const existing = await this.permissionRepository.findOne({
      where: { permissionName: createDto.permissionName },
    });

    if (existing) {
      throw new BadRequestException(`Permission '${createDto.permissionName}' already exists`);
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
      throw new NotFoundException(`Permission with ID ${permissionId} not found`);
    }

    if (updateDto.permissionName && updateDto.permissionName !== permission.permissionName) {
      const existing = await this.permissionRepository.findOne({
        where: { permissionName: updateDto.permissionName },
      });
      if (existing) {
        throw new BadRequestException(`Permission '${updateDto.permissionName}' already exists`);
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
      throw new NotFoundException(`Permission with ID ${permissionId} not found`);
    }

    if (permission.roles && permission.roles.length > 0) {
      throw new BadRequestException('Cannot delete permission that is assigned to roles');
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
      throw new NotFoundException(`Permission with ID ${permDto.permissionId} not found`);
    }

    if (role.permissions.find((p) => p.permissionId === permission.permissionId)) {
      throw new BadRequestException('Role already has this permission');
    }

    role.permissions.push(permission);
    await this.roleRepository.save(role);

    return this.getRoleById(roleId);
  }

  async removePermissionFromRole(roleId: number, permissionId: number): Promise<void> {
    const role = await this.roleRepository.findOne({
      where: { roleId },
      relations: ['permissions'],
    });

    if (!role) {
      throw new NotFoundException(`Role with ID ${roleId} not found`);
    }

    const permIndex = role.permissions.findIndex((p) => p.permissionId === permissionId);

    if (permIndex === -1) {
      throw new NotFoundException('Role does not have this permission');
    }

    role.permissions.splice(permIndex, 1);
    await this.roleRepository.save(role);
  }

  // ============ HELPER METHODS ============

  private transformToUserDto(user: User): UserResponseDto {
    const userDto = plainToClass(UserResponseDto, user, {
      excludeExtraneousValues: false,
    });

    if (user.roles && Array.isArray(user.roles)) {
      userDto.roles = (user.roles as Role[]).map((role) => this.transformToRoleDto(role));
    }

    return userDto;
  }

  private transformToUserListDto(user: User): UserListResponseDto {
    const userDto = plainToClass(UserListResponseDto, user, {
      excludeExtraneousValues: false,
    });

    if (user.roles && Array.isArray(user.roles)) {
      userDto.roles = (user.roles as Role[]).map((role) => ({
        roleId: role.roleId,
        roleName: role.roleName,
      } as RoleResponseDto));
    }

    return userDto;
  }

  private transformToRoleDto(role: Role): RoleResponseDto {
    const roleDto = plainToClass(RoleResponseDto, role, {
      excludeExtraneousValues: false,
    });

    if (role.permissions && Array.isArray(role.permissions)) {
      roleDto.permissions = (role.permissions as Permission[]).map((p) => this.transformToPermissionDto(p));
      roleDto.permissionCount = role.permissions.length;
    }

    return roleDto;
  }

  private transformToPermissionDto(permission: Permission): PermissionResponseDto {
    return plainToClass(PermissionResponseDto, permission, {
      excludeExtraneousValues: false,
    });
  }
}
