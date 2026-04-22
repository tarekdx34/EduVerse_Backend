import { DataSource } from 'typeorm';
import { Role, RoleName } from '../../modules/auth/entities/role.entity';
import { Permission } from '../../modules/auth/entities/permission.entity';
import { User, UserStatus } from '../../modules/auth/entities/user.entity';

export async function seedAuthData(dataSource: DataSource) {
  const roleRepository = dataSource.getRepository(Role);
  const permissionRepository = dataSource.getRepository(Permission);
  const userRepository = dataSource.getRepository(User);

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

  const roleMap = new Map<RoleName, Role>();
  const allRoles = await roleRepository.find();
  for (const role of allRoles) {
    roleMap.set(role.roleName, role);
  }

  const seedUsers = [
    ...buildUsers('student', RoleName.STUDENT, 200),
    ...buildUsers('ta', RoleName.TA, 40),
    ...buildUsers('instructor', RoleName.INSTRUCTOR, 20),
    ...buildUsers('admin', RoleName.ADMIN, 5),
    ...buildUsers('itadmin', RoleName.IT_ADMIN, 1),
  ];

  const existingUsers = await userRepository.find({
    where: seedUsers.map((u) => ({ email: u.email })),
    relations: ['roles'],
  });
  const existingByEmail = new Map(existingUsers.map((u) => [u.email, u]));

  let createdCount = 0;
  let updatedRoleCount = 0;

  for (const seedUser of seedUsers) {
    const role = roleMap.get(seedUser.roleName);
    if (!role) {
      throw new Error(`Missing role for ${seedUser.roleName}. Run role seeding first.`);
    }

    const existing = existingByEmail.get(seedUser.email);
    if (!existing) {
      const user = userRepository.create({
        email: seedUser.email,
        passwordHash: 'password123',
        firstName: seedUser.firstName,
        lastName: seedUser.lastName,
        status: UserStatus.ACTIVE,
        emailVerified: true,
        roles: [role],
      });
      await userRepository.save(user);
      createdCount++;
      continue;
    }

    const hasRole = existing.roles?.some((r) => r.roleName === seedUser.roleName);
    if (!hasRole) {
      existing.roles = [role];
      existing.status = UserStatus.ACTIVE;
      existing.emailVerified = true;
      await userRepository.save(existing);
      updatedRoleCount++;
    }
  }

  console.log(`✅ Seeded users: created ${createdCount}, updated ${updatedRoleCount}`);
  console.log('✅ Auth seeding completed!');
}

function buildUsers(
  prefix: string,
  roleName: RoleName,
  count: number,
): Array<{
  email: string;
  firstName: string;
  lastName: string;
  roleName: RoleName;
}> {
  return Array.from({ length: count }, (_, i) => {
    const index = i + 1;
    return {
      email: `${prefix}${index}.tarek@example.com`,
      firstName: `${toTitleCase(prefix)}${index}`,
      lastName: roleNameToLastName(roleName),
      roleName,
    };
  });
}

function toTitleCase(value: string): string {
  return value.charAt(0).toUpperCase() + value.slice(1).toLowerCase();
}

function roleNameToLastName(roleName: RoleName): string {
  switch (roleName) {
    case RoleName.STUDENT:
      return 'Student';
    case RoleName.TA:
      return 'TA';
    case RoleName.INSTRUCTOR:
      return 'Instructor';
    case RoleName.ADMIN:
      return 'Admin';
    case RoleName.IT_ADMIN:
      return 'ITAdmin';
    default:
      return 'User';
  }
}

export class AuthSeeder {
  async run(dataSource: DataSource) {
    await seedAuthData(dataSource);
  }
}
