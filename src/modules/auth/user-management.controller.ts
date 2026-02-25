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
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
  ApiParam,
  ApiQuery,
  ApiBody,
} from '@nestjs/swagger';
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

@ApiTags('👥 User Management')
@Controller('api/admin')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth('JWT-auth')
export class UserManagementController {
  constructor(private readonly userManagementService: UserManagementService) {}

  // ============ USER MANAGEMENT ENDPOINTS ============

  @Get('users')
  @ApiOperation({
    summary: 'List all users',
    description: `
## List All Users (Paginated)

Retrieves a paginated list of all users in the system with optional filters.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: ADMIN, IT_ADMIN

### Query Parameters
- \`page\`: Page number (default: 1)
- \`size\`: Items per page (default: 10, max: 100)
- \`sort\`: Sort field (default: createdAt)
- \`status\`: Filter by user status (active, inactive, suspended)
- \`role\`: Filter by role name
- \`campusId\`: Filter by campus

### Notes
- Results are sorted by creation date descending by default
- Includes user roles and basic profile information
    `,
  })
  @ApiQuery({ name: 'page', required: false, type: Number, example: 1 })
  @ApiQuery({ name: 'size', required: false, type: Number, example: 10 })
  @ApiQuery({ name: 'sort', required: false, type: String, example: 'createdAt' })
  @ApiQuery({ name: 'status', required: false, enum: ['active', 'inactive', 'suspended'] })
  @ApiQuery({ name: 'role', required: false, type: String, example: 'student' })
  @ApiQuery({ name: 'campusId', required: false, type: Number })
  @ApiResponse({ status: 200, description: 'Paginated list of users' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - Admin access required' })
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
  @ApiOperation({
    summary: 'Get user by ID',
    description: `
## Get User Details

Retrieves complete details of a specific user by their ID.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: ADMIN, IT_ADMIN

### Response Includes
- User profile information
- All assigned roles
- Associated permissions
- Account status and activity
    `,
  })
  @ApiParam({ name: 'id', description: 'User ID', type: Number })
  @ApiResponse({ status: 200, description: 'User details' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - Admin access required' })
  @ApiResponse({ status: 404, description: 'User not found' })
  async getUserById(@Param('id', ParseIntPipe) userId: number): Promise<UserResponseDto> {
    return this.userManagementService.getUserById(userId);
  }

  @Put('users/:id')
  @ApiOperation({
    summary: 'Update user',
    description: `
## Update User Profile

Updates a user's profile information.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: ADMIN, IT_ADMIN

### Updatable Fields
- firstName, lastName
- phone number
- Campus assignment
- Profile settings

### Notes
- Email cannot be changed through this endpoint
- Password changes use separate endpoint
- Role changes use the role assignment endpoints
    `,
  })
  @ApiParam({ name: 'id', description: 'User ID', type: Number })
  @ApiBody({ type: UserUpdateDto })
  @ApiResponse({ status: 200, description: 'User updated successfully' })
  @ApiResponse({ status: 400, description: 'Invalid input data' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - Admin access required' })
  @ApiResponse({ status: 404, description: 'User not found' })
  async updateUser(
    @Param('id', ParseIntPipe) userId: number,
    @Body() updateDto: UserUpdateDto,
  ): Promise<UserResponseDto> {
    return this.userManagementService.updateUser(userId, updateDto);
  }

  @Delete('users/:id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({
    summary: 'Delete user',
    description: `
## Delete User Account

Permanently deletes a user account from the system.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: ADMIN, IT_ADMIN

### ⚠️ Warning
This action is **irreversible**. Consider using status update to deactivate instead.

### Process Flow
1. Removes all user sessions
2. Removes role assignments
3. Removes user record
4. Related data may be orphaned or cascade deleted
    `,
  })
  @ApiParam({ name: 'id', description: 'User ID', type: Number })
  @ApiResponse({ status: 204, description: 'User deleted successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - Admin access required' })
  @ApiResponse({ status: 404, description: 'User not found' })
  async deleteUser(@Param('id', ParseIntPipe) userId: number): Promise<void> {
    return this.userManagementService.deleteUser(userId);
  }

  @Put('users/:id/status')
  @ApiOperation({
    summary: 'Update user status',
    description: `
## Update User Account Status

Changes the status of a user account (activate, deactivate, suspend).

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: ADMIN, IT_ADMIN

### Available Statuses
- \`active\`: User can access the system normally
- \`inactive\`: User cannot login (soft disable)
- \`suspended\`: User is temporarily blocked (can include reason)

### Notes
- Suspended users' active sessions are terminated
- Reactivating a user requires a new login
    `,
  })
  @ApiParam({ name: 'id', description: 'User ID', type: Number })
  @ApiBody({ type: UserStatusUpdateDto })
  @ApiResponse({ status: 200, description: 'User status updated' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - Admin access required' })
  @ApiResponse({ status: 404, description: 'User not found' })
  async updateUserStatus(
    @Param('id', ParseIntPipe) userId: number,
    @Body() statusDto: UserStatusUpdateDto,
  ): Promise<UserResponseDto> {
    return this.userManagementService.updateUserStatus(userId, statusDto);
  }

  @Get('users/search')
  @ApiOperation({
    summary: 'Search users',
    description: `
## Search Users

Search for users by name, email, or other criteria.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: ADMIN, IT_ADMIN

### Search Fields
- Email address
- First name
- Last name
- Combined full name

### Notes
- Search is case-insensitive
- Partial matches are supported
- Returns up to 50 results
    `,
  })
  @ApiQuery({ name: 'query', description: 'Search term', type: String, example: 'john' })
  @ApiResponse({ status: 200, description: 'Search results' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - Admin access required' })
  async searchUsers(@Query('query') query: string): Promise<UserListResponseDto[]> {
    return this.userManagementService.searchUsers(query);
  }

  // ============ USER ROLE MANAGEMENT ============

  @Post('users/:id/roles')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Assign role to user',
    description: `
## Assign Role to User

Assigns an additional role to a user.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: ADMIN, IT_ADMIN

### Available Roles
- \`student\`: Regular student access
- \`instructor\`: Faculty/teaching access
- \`ta\`: Teaching assistant access
- \`admin\`: Administrative access
- \`it_admin\`: Full system access

### Notes
- Users can have multiple roles
- Duplicate role assignments are ignored
- New permissions take effect immediately
    `,
  })
  @ApiParam({ name: 'id', description: 'User ID', type: Number })
  @ApiBody({ type: RoleAssignmentDto })
  @ApiResponse({ status: 201, description: 'Role assigned successfully' })
  @ApiResponse({ status: 400, description: 'Invalid role or already assigned' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - Admin access required' })
  @ApiResponse({ status: 404, description: 'User or role not found' })
  async assignRoleToUser(
    @Param('id', ParseIntPipe) userId: number,
    @Body() roleDto: RoleAssignmentDto,
  ): Promise<UserResponseDto> {
    return this.userManagementService.assignRoleToUser(userId, roleDto);
  }

  @Delete('users/:id/roles/:roleId')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({
    summary: 'Remove role from user',
    description: `
## Remove Role from User

Removes a role from a user.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: ADMIN, IT_ADMIN

### Notes
- Users must have at least one role
- Removing all roles will fail
- Permission changes take effect on next request
    `,
  })
  @ApiParam({ name: 'id', description: 'User ID', type: Number })
  @ApiParam({ name: 'roleId', description: 'Role ID to remove', type: Number })
  @ApiResponse({ status: 204, description: 'Role removed successfully' })
  @ApiResponse({ status: 400, description: 'Cannot remove last role' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - Admin access required' })
  @ApiResponse({ status: 404, description: 'User or role assignment not found' })
  async removeRoleFromUser(
    @Param('id', ParseIntPipe) userId: number,
    @Param('roleId', ParseIntPipe) roleId: number,
  ): Promise<void> {
    return this.userManagementService.removeRoleFromUser(userId, roleId);
  }

  @Get('users/:id/permissions')
  @ApiOperation({
    summary: 'Get user permissions',
    description: `
## Get User Effective Permissions

Returns all permissions a user has through their assigned roles.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: ADMIN, IT_ADMIN

### Response Includes
- Direct permissions from each role
- Aggregated unique permissions
- Permission module groupings
    `,
  })
  @ApiParam({ name: 'id', description: 'User ID', type: Number })
  @ApiResponse({ status: 200, description: 'User permissions list' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - Admin access required' })
  @ApiResponse({ status: 404, description: 'User not found' })
  async getUserPermissions(
    @Param('id', ParseIntPipe) userId: number,
  ): Promise<PermissionResponseDto[]> {
    return this.userManagementService.getUserPermissions(userId);
  }

  // ============ ROLE MANAGEMENT ENDPOINTS ============

  @Get('roles')
  @ApiOperation({
    summary: 'List all roles',
    description: `
## List All Roles

Returns all available roles in the system.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: ADMIN, IT_ADMIN

### Response Includes
- Role ID and name
- Role description
- Associated permissions count
    `,
  })
  @ApiResponse({ status: 200, description: 'List of all roles' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - Admin access required' })
  async getAllRoles(): Promise<RoleResponseDto[]> {
    return this.userManagementService.getAllRoles();
  }

  @Get('roles/:id')
  @ApiOperation({
    summary: 'Get role by ID',
    description: `
## Get Role Details

Returns details of a specific role including its permissions.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: ADMIN, IT_ADMIN
    `,
  })
  @ApiParam({ name: 'id', description: 'Role ID', type: Number })
  @ApiResponse({ status: 200, description: 'Role details' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - Admin access required' })
  @ApiResponse({ status: 404, description: 'Role not found' })
  async getRoleById(@Param('id', ParseIntPipe) roleId: number): Promise<RoleResponseDto> {
    return this.userManagementService.getRoleById(roleId);
  }

  @Post('roles')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Create new role',
    description: `
## Create New Role

Creates a new role in the system.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: IT_ADMIN only

### Notes
- Role names must be unique
- New roles start with no permissions
- Use permission assignment endpoints to add permissions
    `,
  })
  @ApiBody({ type: RoleCreateDto })
  @ApiResponse({ status: 201, description: 'Role created successfully' })
  @ApiResponse({ status: 400, description: 'Invalid input or duplicate role name' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - IT Admin access required' })
  async createRole(@Body() createDto: RoleCreateDto): Promise<RoleResponseDto> {
    return this.userManagementService.createRole(createDto);
  }

  @Put('roles/:id')
  @ApiOperation({
    summary: 'Update role',
    description: `
## Update Role

Updates an existing role's name or description.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: IT_ADMIN only

### Notes
- Built-in roles (student, instructor, admin, etc.) should not be renamed
- Permission changes use separate endpoints
    `,
  })
  @ApiParam({ name: 'id', description: 'Role ID', type: Number })
  @ApiBody({ type: RoleUpdateDto })
  @ApiResponse({ status: 200, description: 'Role updated successfully' })
  @ApiResponse({ status: 400, description: 'Invalid input' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - IT Admin access required' })
  @ApiResponse({ status: 404, description: 'Role not found' })
  async updateRole(
    @Param('id', ParseIntPipe) roleId: number,
    @Body() updateDto: RoleUpdateDto,
  ): Promise<RoleResponseDto> {
    return this.userManagementService.updateRole(roleId, updateDto);
  }

  @Delete('roles/:id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({
    summary: 'Delete role',
    description: `
## Delete Role

Deletes a role from the system.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: IT_ADMIN only

### ⚠️ Warning
- Built-in roles cannot be deleted
- Roles with assigned users cannot be deleted
- This action is irreversible
    `,
  })
  @ApiParam({ name: 'id', description: 'Role ID', type: Number })
  @ApiResponse({ status: 204, description: 'Role deleted successfully' })
  @ApiResponse({ status: 400, description: 'Cannot delete built-in or assigned role' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - IT Admin access required' })
  @ApiResponse({ status: 404, description: 'Role not found' })
  async deleteRole(@Param('id', ParseIntPipe) roleId: number): Promise<void> {
    return this.userManagementService.deleteRole(roleId);
  }

  // ============ ROLE PERMISSION MANAGEMENT ============

  @Post('roles/:id/permissions')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Add permission to role',
    description: `
## Add Permission to Role

Assigns a permission to a role.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: IT_ADMIN only

### Notes
- All users with this role will gain the permission
- Duplicate assignments are ignored
    `,
  })
  @ApiParam({ name: 'id', description: 'Role ID', type: Number })
  @ApiBody({ type: PermissionAssignmentDto })
  @ApiResponse({ status: 201, description: 'Permission added to role' })
  @ApiResponse({ status: 400, description: 'Invalid permission or already assigned' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - IT Admin access required' })
  @ApiResponse({ status: 404, description: 'Role or permission not found' })
  async addPermissionToRole(
    @Param('id', ParseIntPipe) roleId: number,
    @Body() permDto: PermissionAssignmentDto,
  ): Promise<RoleResponseDto> {
    return this.userManagementService.addPermissionToRole(roleId, permDto);
  }

  @Delete('roles/:id/permissions/:permId')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({
    summary: 'Remove permission from role',
    description: `
## Remove Permission from Role

Removes a permission from a role.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: IT_ADMIN only

### Notes
- All users with this role will lose the permission
- Changes take effect on next request
    `,
  })
  @ApiParam({ name: 'id', description: 'Role ID', type: Number })
  @ApiParam({ name: 'permId', description: 'Permission ID', type: Number })
  @ApiResponse({ status: 204, description: 'Permission removed from role' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - IT Admin access required' })
  @ApiResponse({ status: 404, description: 'Role or permission assignment not found' })
  async removePermissionFromRole(
    @Param('id', ParseIntPipe) roleId: number,
    @Param('permId', ParseIntPipe) permissionId: number,
  ): Promise<void> {
    return this.userManagementService.removePermissionFromRole(roleId, permissionId);
  }

  // ============ PERMISSION MANAGEMENT ENDPOINTS ============

  @Get('permissions')
  @ApiOperation({
    summary: 'List all permissions',
    description: `
## List All Permissions

Returns all available permissions in the system.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: ADMIN, IT_ADMIN
    `,
  })
  @ApiResponse({ status: 200, description: 'List of all permissions' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - Admin access required' })
  async getAllPermissions(): Promise<PermissionResponseDto[]> {
    return this.userManagementService.getAllPermissions();
  }

  @Get('permissions/module/:module')
  @ApiOperation({
    summary: 'Get permissions by module',
    description: `
## Get Permissions by Module

Returns all permissions belonging to a specific module.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: ADMIN, IT_ADMIN

### Available Modules
- auth, users, courses, enrollments, files, campus, etc.
    `,
  })
  @ApiParam({ name: 'module', description: 'Module name', type: String, example: 'courses' })
  @ApiResponse({ status: 200, description: 'Permissions for the module' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - Admin access required' })
  async getPermissionsByModule(@Param('module') module: string): Promise<PermissionResponseDto[]> {
    return this.userManagementService.getPermissionsByModule(module);
  }

  @Post('permissions')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Create permission',
    description: `
## Create New Permission

Creates a new permission in the system.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: IT_ADMIN only

### Notes
- Permission names should follow pattern: module:action
- Example: courses:create, users:delete
    `,
  })
  @ApiBody({ type: PermissionCreateDto })
  @ApiResponse({ status: 201, description: 'Permission created successfully' })
  @ApiResponse({ status: 400, description: 'Invalid input or duplicate permission' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - IT Admin access required' })
  async createPermission(@Body() createDto: PermissionCreateDto): Promise<PermissionResponseDto> {
    return this.userManagementService.createPermission(createDto);
  }

  @Put('permissions/:id')
  @ApiOperation({
    summary: 'Update permission',
    description: `
## Update Permission

Updates an existing permission.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: IT_ADMIN only
    `,
  })
  @ApiParam({ name: 'id', description: 'Permission ID', type: Number })
  @ApiBody({ type: PermissionUpdateDto })
  @ApiResponse({ status: 200, description: 'Permission updated successfully' })
  @ApiResponse({ status: 400, description: 'Invalid input' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - IT Admin access required' })
  @ApiResponse({ status: 404, description: 'Permission not found' })
  async updatePermission(
    @Param('id', ParseIntPipe) permissionId: number,
    @Body() updateDto: PermissionUpdateDto,
  ): Promise<PermissionResponseDto> {
    return this.userManagementService.updatePermission(permissionId, updateDto);
  }

  @Delete('permissions/:id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({
    summary: 'Delete permission',
    description: `
## Delete Permission

Deletes a permission from the system.

### Access Control
- **Authentication Required**: ✅ Yes (Bearer Token)
- **Roles Required**: IT_ADMIN only

### ⚠️ Warning
- Permissions assigned to roles will be removed
- This action is irreversible
    `,
  })
  @ApiParam({ name: 'id', description: 'Permission ID', type: Number })
  @ApiResponse({ status: 204, description: 'Permission deleted successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - IT Admin access required' })
  @ApiResponse({ status: 404, description: 'Permission not found' })
  async deletePermission(@Param('id', ParseIntPipe) permissionId: number): Promise<void> {
    return this.userManagementService.deletePermission(permissionId);
  }
}
