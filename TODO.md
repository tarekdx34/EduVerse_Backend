NEW REQUIREMENTS:

1. Admin dashboard to manage users
2. Assign/remove roles to/from users
3. Manage roles and their permissions
4. Search and filter users
5. Update user information
6. Activate/suspend user accounts
7. View user permissions (inherited from roles)
8. Pagination for user lists
9. Soft delete users

ROLE HIERARCHY:

- IT_ADMIN: Full system access
- ADMIN: Campus-wide management
- INSTRUCTOR: Course management
- TA: Teaching assistant
- STUDENT: Learning activities

API ENDPOINTS TO IMPLEMENT:

USER MANAGEMENT:

1. GET /api/users - List all users (paginated, filterable)
   - Query params: page, size, sort, status, role, campus
   - Response: Paginated list of UserResponseDto
   - Access: ADMIN, IT_ADMIN only

2. GET /api/users/{id} - Get user by ID
   - Response: UserResponseDto with roles
   - Access: ADMIN, IT_ADMIN, or self

3. PUT /api/users/{id} - Update user info
   - Request: UserUpdateDto (firstName, lastName, phone, profilePicture, campusId)
   - Response: Updated UserResponseDto
   - Access: ADMIN, IT_ADMIN, or self (self can't change roles/status)

4. DELETE /api/users/{id} - Soft delete user
   - Sets deleted_at timestamp
   - Response: 204 No Content
   - Access: ADMIN, IT_ADMIN only

5. POST /api/users/{id}/roles - Assign role to user
   - Request: RoleAssignmentDto {roleId, assignedBy}
   - Creates entry in user_roles table
   - Response: Updated UserResponseDto
   - Access: ADMIN, IT_ADMIN only

6. DELETE /api/users/{id}/roles/{roleId} - Remove role from user
   - Response: 204 No Content
   - Access: ADMIN, IT_ADMIN only

7. GET /api/users/{id}/permissions - Get all permissions for user
   - Aggregates permissions from all user's roles
   - Response: List<PermissionDto>
   - Access: ADMIN, IT_ADMIN, or self

8. PUT /api/users/{id}/status - Update user status
   - Request: {status: 'active'|'inactive'|'suspended'|'pending'}
   - Response: Updated UserResponseDto
   - Access: ADMIN, IT_ADMIN only

9. GET /api/users/search?query={query} - Search users
   - Searches firstName, lastName, email
   - Response: List<UserResponseDto>
   - Access: ADMIN, IT_ADMIN, INSTRUCTOR

ROLE MANAGEMENT: 10. GET /api/roles - List all roles - Response: List<RoleDto> with permission counts - Access: ADMIN, IT_ADMIN

11. POST /api/roles - Create new role
    - Request: RoleCreateDto {roleName, description}
    - Response: Created RoleDto (201)
    - Access: IT_ADMIN only

12. PUT /api/roles/{id} - Update role
    - Request: RoleDto
    - Response: Updated RoleDto
    - Access: IT_ADMIN only

13. DELETE /api/roles/{id} - Delete role
    - Check if role is assigned to any users first
    - Response: 204 No Content
    - Access: IT_ADMIN only

14. POST /api/roles/{id}/permissions - Add permission to role
    - Request: {permissionId}
    - Creates entry in role_permissions table
    - Response: Updated RoleDto
    - Access: IT_ADMIN only

15. DELETE /api/roles/{id}/permissions/{permissionId} - Remove permission
    - Response: 204 No Content
    - Access: IT_ADMIN only

PERMISSION MANAGEMENT: 16. GET /api/permissions - List all permissions - Group by module - Response: List<PermissionDto> - Access: ADMIN, IT_ADMIN

17. POST /api/permissions - Create permission
    - Request: PermissionCreateDto {name, description, module}
    - Response: Created PermissionDto (201)
    - Access: IT_ADMIN only

18. PUT /api/permissions/{id} - Update permission
    - Request: PermissionDto
    - Response: Updated PermissionDto
    - Access: IT_ADMIN only

19. DELETE /api/permissions/{id} - Delete permission - Check if permission is assigned to any roles first - Response: 204 No Content - Access: IT_ADMIN only
    IMPORTANT:

- Reuse existing User, Role, Permission entities
- Don't break existing authentication endpoints

This was for JAVA spring bot ==> I want to build this for my NestJS project
