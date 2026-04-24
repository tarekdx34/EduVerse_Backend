import { DataSource } from 'typeorm';
import { Role, RoleName } from '../../modules/auth/entities/role.entity';
import { Permission } from '../../modules/auth/entities/permission.entity';

export async function seedAuthData(dataSource: DataSource) {
  const roleRepository = dataSource.getRepository(Role);
  const permissionRepository = dataSource.getRepository(Permission);

  // Seed Roles
  const roles = [
    {
      roleName: RoleName.STUDENT,
      roleDescription: 'Student with access to courses and assignments',
    },
    {
      roleName: RoleName.INSTRUCTOR,
      roleDescription: 'Instructor with course management capabilities',
    },
    {
      roleName: RoleName.TA,
      roleDescription: 'Teaching Assistant with limited instructor access',
    },
    {
      roleName: RoleName.ADMIN,
      roleDescription: 'Administrator with campus-wide access',
    },
    {
      roleName: RoleName.IT_ADMIN,
      roleDescription: 'IT Administrator with system-wide access',
    },
  ];

  for (const roleData of roles) {
    const existingRole = await roleRepository.findOne({
      where: { roleName: roleData.roleName },
    });
    if (!existingRole) {
      const role = roleRepository.create(roleData);
      await roleRepository.save(role);
      console.log(`✅ Created role: ${roleData.roleName}`);
    }
  }

  // Seed Basic Permissions
  const permissions = [
    {
      permissionName: 'read:courses',
      permissionDescription: 'View courses',
      module: 'courses',
    },
    {
      permissionName: 'create:courses',
      permissionDescription: 'Create courses',
      module: 'courses',
    },
    {
      permissionName: 'update:courses',
      permissionDescription: 'Update courses',
      module: 'courses',
    },
    {
      permissionName: 'delete:courses',
      permissionDescription: 'Delete courses',
      module: 'courses',
    },
    {
      permissionName: 'read:users',
      permissionDescription: 'View users',
      module: 'users',
    },
    {
      permissionName: 'manage:users',
      permissionDescription: 'Manage users',
      module: 'users',
    },
  ];

  for (const permData of permissions) {
    const existingPerm = await permissionRepository.findOne({
      where: { permissionName: permData.permissionName },
    });
    if (!existingPerm) {
      const permission = permissionRepository.create(permData);
      await permissionRepository.save(permission);
      console.log(`✅ Created permission: ${permData.permissionName}`);
    }
  }

  console.log('✅ Auth seeding completed!');
}

export class AuthSeeder {
  async run(dataSource: DataSource) {
    await seedAuthData(dataSource);
  }
}
