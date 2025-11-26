import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  Query,
  ParseIntPipe,
  HttpCode,
  HttpStatus,
  UseGuards,
} from '@nestjs/common';
import { JwtAuthGuard } from './guards/jwt-auth.guard';
import { UserManagementService } from './user-management.service';
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

@Controller('api/admin')
@UseGuards(JwtAuthGuard)
export class UserManagementController {
  constructor(private readonly userManagementService: UserManagementService) {}

  // ============ USER MANAGEMENT ENDPOINTS ============

  @Get('users')
  async getUsers(
    @Query('page', new ParseIntPipe({ optional: true })) page: number = 1,
    @Query('size', new ParseIntPipe({ optional: true })) size: number = 10,
    @Query('sort') sort: string = 'createdAt',
    @Query('status') status?: string,
    @Query('role') role?: string,
    @Query('campusId', new ParseIntPipe({ optional: true })) campusId?: number,
  ): Promise<PaginatedResponseDto<UserListResponseDto>> {
    const filters: UserFilterDto = {};
    if (status) filters.status = status as any;
    if (role) filters.role = role;
    if (campusId) filters.campusId = campusId;

    return this.userManagementService.getUsers(page, size, sort, filters);
  }

  @Get('users/:id')
  async getUserById(@Param('id', ParseIntPipe) userId: number): Promise<UserResponseDto> {
    return this.userManagementService.getUserById(userId);
  }

  @Put('users/:id')
  async updateUser(
    @Param('id', ParseIntPipe) userId: number,
    @Body() updateDto: UserUpdateDto,
  ): Promise<UserResponseDto> {
    return this.userManagementService.updateUser(userId, updateDto);
  }

  @Delete('users/:id')
  @HttpCode(HttpStatus.NO_CONTENT)
  async deleteUser(@Param('id', ParseIntPipe) userId: number): Promise<void> {
    return this.userManagementService.deleteUser(userId);
  }

  @Put('users/:id/status')
  async updateUserStatus(
    @Param('id', ParseIntPipe) userId: number,
    @Body() statusDto: UserStatusUpdateDto,
  ): Promise<UserResponseDto> {
    return this.userManagementService.updateUserStatus(userId, statusDto);
  }

  @Get('users/search')
  async searchUsers(@Query('query') query: string): Promise<UserListResponseDto[]> {
    return this.userManagementService.searchUsers(query);
  }

  // ============ USER ROLE MANAGEMENT ============

  @Post('users/:id/roles')
  @HttpCode(HttpStatus.CREATED)
  async assignRoleToUser(
    @Param('id', ParseIntPipe) userId: number,
    @Body() roleDto: RoleAssignmentDto,
  ): Promise<UserResponseDto> {
    return this.userManagementService.assignRoleToUser(userId, roleDto);
  }

  @Delete('users/:id/roles/:roleId')
  @HttpCode(HttpStatus.NO_CONTENT)
  async removeRoleFromUser(
    @Param('id', ParseIntPipe) userId: number,
    @Param('roleId', ParseIntPipe) roleId: number,
  ): Promise<void> {
    return this.userManagementService.removeRoleFromUser(userId, roleId);
  }

  @Get('users/:id/permissions')
  async getUserPermissions(
    @Param('id', ParseIntPipe) userId: number,
  ): Promise<PermissionResponseDto[]> {
    return this.userManagementService.getUserPermissions(userId);
  }

  // ============ ROLE MANAGEMENT ENDPOINTS ============

  @Get('roles')
  async getAllRoles(): Promise<RoleResponseDto[]> {
    return this.userManagementService.getAllRoles();
  }

  @Get('roles/:id')
  async getRoleById(@Param('id', ParseIntPipe) roleId: number): Promise<RoleResponseDto> {
    return this.userManagementService.getRoleById(roleId);
  }

  @Post('roles')
  @HttpCode(HttpStatus.CREATED)
  async createRole(@Body() createDto: RoleCreateDto): Promise<RoleResponseDto> {
    return this.userManagementService.createRole(createDto);
  }

  @Put('roles/:id')
  async updateRole(
    @Param('id', ParseIntPipe) roleId: number,
    @Body() updateDto: RoleUpdateDto,
  ): Promise<RoleResponseDto> {
    return this.userManagementService.updateRole(roleId, updateDto);
  }

  @Delete('roles/:id')
  @HttpCode(HttpStatus.NO_CONTENT)
  async deleteRole(@Param('id', ParseIntPipe) roleId: number): Promise<void> {
    return this.userManagementService.deleteRole(roleId);
  }

  // ============ ROLE PERMISSION MANAGEMENT ============

  @Post('roles/:id/permissions')
  @HttpCode(HttpStatus.CREATED)
  async addPermissionToRole(
    @Param('id', ParseIntPipe) roleId: number,
    @Body() permDto: PermissionAssignmentDto,
  ): Promise<RoleResponseDto> {
    return this.userManagementService.addPermissionToRole(roleId, permDto);
  }

  @Delete('roles/:id/permissions/:permId')
  @HttpCode(HttpStatus.NO_CONTENT)
  async removePermissionFromRole(
    @Param('id', ParseIntPipe) roleId: number,
    @Param('permId', ParseIntPipe) permissionId: number,
  ): Promise<void> {
    return this.userManagementService.removePermissionFromRole(roleId, permissionId);
  }

  // ============ PERMISSION MANAGEMENT ENDPOINTS ============

  @Get('permissions')
  async getAllPermissions(): Promise<PermissionResponseDto[]> {
    return this.userManagementService.getAllPermissions();
  }

  @Get('permissions/module/:module')
  async getPermissionsByModule(@Param('module') module: string): Promise<PermissionResponseDto[]> {
    return this.userManagementService.getPermissionsByModule(module);
  }

  @Post('permissions')
  @HttpCode(HttpStatus.CREATED)
  async createPermission(@Body() createDto: PermissionCreateDto): Promise<PermissionResponseDto> {
    return this.userManagementService.createPermission(createDto);
  }

  @Put('permissions/:id')
  async updatePermission(
    @Param('id', ParseIntPipe) permissionId: number,
    @Body() updateDto: PermissionUpdateDto,
  ): Promise<PermissionResponseDto> {
    return this.userManagementService.updatePermission(permissionId, updateDto);
  }

  @Delete('permissions/:id')
  @HttpCode(HttpStatus.NO_CONTENT)
  async deletePermission(@Param('id', ParseIntPipe) permissionId: number): Promise<void> {
    return this.userManagementService.deletePermission(permissionId);
  }
}
