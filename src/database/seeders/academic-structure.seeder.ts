import { DataSource, In, Repository } from 'typeorm';
import { Campus } from '../../modules/campus/entities/campus.entity';
import { Department } from '../../modules/campus/entities/department.entity';
import { Semester } from '../../modules/campus/entities/semester.entity';
import { Status } from '../../modules/campus/enums/status.enum';
import { SemesterStatus } from '../../modules/campus/enums/semester-status.enum';
import { Course } from '../../modules/courses/entities/course.entity';
import { CourseSection } from '../../modules/courses/entities/course-section.entity';
import { CourseLevel, CourseStatus, SectionStatus } from '../../modules/courses/enums';
import { CourseInstructor, InstructorRole } from '../../modules/enrollments/entities/course-instructor.entity';
import { CourseTA } from '../../modules/enrollments/entities/course-ta.entity';
import { CourseEnrollment } from '../../modules/enrollments/entities/course-enrollment.entity';
import { EnrollmentStatus } from '../../modules/enrollments/enums';
import { User } from '../../modules/auth/entities/user.entity';

type SeedDepartment = {
  code: string;
  name: string;
  description: string;
  courses: Array<{
    code: string;
    name: string;
    credits: number;
    level: CourseLevel;
  }>;
};

const DEPARTMENTS: SeedDepartment[] = [
  {
    code: 'ECE',
    name: 'Electrical Communications and Electrical Engineering',
    description: 'Electrical systems, communications, and electronics engineering.',
    courses: [
      { code: 'ECE301', name: 'Automatic Control', credits: 3, level: CourseLevel.JUNIOR },
      { code: 'ECE302', name: 'Antenna', credits: 3, level: CourseLevel.JUNIOR },
      { code: 'ECE303', name: 'Digital Communications', credits: 3, level: CourseLevel.SENIOR },
      { code: 'ECE304', name: 'Digital IC', credits: 3, level: CourseLevel.SENIOR },
      { code: 'ECE399', name: 'Law of Ethics', credits: 2, level: CourseLevel.SOPHOMORE },
    ],
  },
  {
    code: 'ME',
    name: 'Mechanical Engineering',
    description: 'Mechanical systems, thermodynamics, and manufacturing engineering.',
    courses: [
      { code: 'ME301', name: 'Thermodynamics II', credits: 3, level: CourseLevel.JUNIOR },
      { code: 'ME302', name: 'Fluid Mechanics', credits: 3, level: CourseLevel.JUNIOR },
      { code: 'ME303', name: 'Machine Design', credits: 3, level: CourseLevel.SENIOR },
      { code: 'ME304', name: 'Heat Transfer', credits: 3, level: CourseLevel.SENIOR },
      { code: 'ME399', name: 'Law of Ethics', credits: 2, level: CourseLevel.SOPHOMORE },
    ],
  },
  {
    code: 'CE',
    name: 'Civil Engineering',
    description: 'Infrastructure, structures, and construction engineering.',
    courses: [
      { code: 'CE301', name: 'Structural Analysis', credits: 3, level: CourseLevel.JUNIOR },
      { code: 'CE302', name: 'Geotechnical Engineering', credits: 3, level: CourseLevel.JUNIOR },
      { code: 'CE303', name: 'Transportation Engineering', credits: 3, level: CourseLevel.SENIOR },
      { code: 'CE304', name: 'Reinforced Concrete Design', credits: 3, level: CourseLevel.SENIOR },
      { code: 'CE399', name: 'Law of Ethics', credits: 2, level: CourseLevel.SOPHOMORE },
    ],
  },
  {
    code: 'CSE',
    name: 'Computer Engineering',
    description: 'Computer systems, software, and digital infrastructure.',
    courses: [
      { code: 'CSE301', name: 'Data Structures and Algorithms', credits: 3, level: CourseLevel.JUNIOR },
      { code: 'CSE302', name: 'Operating Systems', credits: 3, level: CourseLevel.JUNIOR },
      { code: 'CSE303', name: 'Database Systems', credits: 3, level: CourseLevel.SENIOR },
      { code: 'CSE304', name: 'Computer Networks', credits: 3, level: CourseLevel.SENIOR },
      { code: 'CSE399', name: 'Law of Ethics', credits: 2, level: CourseLevel.SOPHOMORE },
    ],
  },
  {
    code: 'CHE',
    name: 'Chemical Engineering',
    description: 'Chemical processes, reaction systems, and plant design.',
    courses: [
      { code: 'CHE301', name: 'Process Control', credits: 3, level: CourseLevel.JUNIOR },
      { code: 'CHE302', name: 'Chemical Reaction Engineering', credits: 3, level: CourseLevel.JUNIOR },
      { code: 'CHE303', name: 'Separation Processes', credits: 3, level: CourseLevel.SENIOR },
      { code: 'CHE304', name: 'Chemical Engineering Thermodynamics', credits: 3, level: CourseLevel.SENIOR },
      { code: 'CHE399', name: 'Law of Ethics', credits: 2, level: CourseLevel.SOPHOMORE },
    ],
  },
];

export async function seedAcademicStructure(dataSource: DataSource) {
  const campusRepository = dataSource.getRepository(Campus);
  const departmentRepository = dataSource.getRepository(Department);
  const semesterRepository = dataSource.getRepository(Semester);
  const courseRepository = dataSource.getRepository(Course);
  const sectionRepository = dataSource.getRepository(CourseSection);
  const instructorRepository = dataSource.getRepository(CourseInstructor);
  const taRepository = dataSource.getRepository(CourseTA);
  const enrollmentRepository = dataSource.getRepository(CourseEnrollment);
  const userRepository = dataSource.getRepository(User);

  const campus = await ensureMainCampus(campusRepository);
  const semester = await ensureActiveSemester(semesterRepository);
  const departments = await ensureDepartments(departmentRepository, campus.id);

  const adminUsers = await findUsersByPattern(userRepository, 'admin', 5);
  const instructorUsers = await findUsersByPattern(userRepository, 'instructor', 20);
  const taUsers = await findUsersByPattern(userRepository, 'ta', 40);
  const studentUsers = await findUsersByPattern(userRepository, 'student', 200);

  if (
    adminUsers.length < 5 ||
    instructorUsers.length < 20 ||
    taUsers.length < 40 ||
    studentUsers.length < 200
  ) {
    throw new Error('Required users not found. Run auth seeder first.');
  }

  // Map one admin per department as responsible owner/head.
  for (let i = 0; i < DEPARTMENTS.length; i++) {
    const dept = departments.get(DEPARTMENTS[i].code);
    if (!dept) continue;
    dept.headOfDepartmentId = adminUsers[i].userId;
    await departmentRepository.save(dept);
  }

  const coursesByDepartment = await ensureCourses(courseRepository, departments);
  const sectionsByDepartment = await ensureSections(
    sectionRepository,
    semester.id,
    coursesByDepartment,
  );

  await seedInstructorAssignments(
    instructorRepository,
    sectionsByDepartment,
    instructorUsers,
  );
  await seedTAAssignments(taRepository, sectionsByDepartment, taUsers);
  await seedStudentEnrollments(
    enrollmentRepository,
    sectionRepository,
    sectionsByDepartment,
    studentUsers,
  );

  // Set course-level instructor hints from first section instructor.
  await updateCourseOwnerHints(
    courseRepository,
    sectionRepository,
    instructorRepository,
    coursesByDepartment,
  );

  console.log('✅ Academic structure seeding completed!');
}

async function ensureMainCampus(repo: Repository<Campus>) {
  let campus = await repo.findOne({ where: { code: 'MAIN' } });
  if (!campus) {
    campus = repo.create({
      name: 'EduVerse Main Campus',
      code: 'MAIN',
      city: 'Cairo',
      country: 'Egypt',
      timezone: 'Africa/Cairo',
      status: Status.ACTIVE,
    });
    campus = await repo.save(campus);
  }
  return campus;
}

async function ensureActiveSemester(repo: Repository<Semester>) {
  let semester = await repo.findOne({ where: { code: 'SP26' } });
  if (!semester) {
    semester = repo.create({
      name: 'Spring 2026',
      code: 'SP26',
      startDate: new Date('2026-02-01'),
      endDate: new Date('2026-06-30'),
      registrationStart: new Date('2026-01-10'),
      registrationEnd: new Date('2026-02-10'),
      status: SemesterStatus.ACTIVE,
    });
    semester = await repo.save(semester);
  }
  return semester;
}

async function ensureDepartments(
  repo: Repository<Department>,
  campusId: number,
) {
  const map = new Map<string, Department>();
  for (const d of DEPARTMENTS) {
    let department = await repo.findOne({ where: { campusId, code: d.code } });
    if (!department) {
      department = repo.create({
        campusId,
        code: d.code,
        name: d.name,
        description: d.description,
        status: Status.ACTIVE,
      });
    } else {
      department.name = d.name;
      department.description = d.description;
      department.status = Status.ACTIVE;
    }
    department = await repo.save(department);
    map.set(d.code, department);
  }
  return map;
}

async function ensureCourses(
  repo: Repository<Course>,
  departments: Map<string, Department>,
) {
  const map = new Map<string, Course[]>();
  for (const seedDepartment of DEPARTMENTS) {
    const department = departments.get(seedDepartment.code);
    if (!department) continue;
    const list: Course[] = [];
    for (const c of seedDepartment.courses) {
      let course = await repo.findOne({
        where: { departmentId: department.id, code: c.code },
      });
      if (!course) {
        course = repo.create({
          departmentId: department.id,
          code: c.code,
          name: c.name,
          description: `${c.name} for ${seedDepartment.name}`,
          credits: c.credits,
          level: c.level,
          status: CourseStatus.ACTIVE,
          skills: [],
        });
      } else {
        course.name = c.name;
        course.description = `${c.name} for ${seedDepartment.name}`;
        course.credits = c.credits;
        course.level = c.level;
        course.status = CourseStatus.ACTIVE;
      }
      course = await repo.save(course);
      list.push(course);
    }
    map.set(seedDepartment.code, list);
  }
  return map;
}

async function ensureSections(
  repo: Repository<CourseSection>,
  semesterId: number,
  coursesByDepartment: Map<string, Course[]>,
) {
  const map = new Map<string, CourseSection[]>();
  for (const [deptCode, courses] of coursesByDepartment.entries()) {
    const sections: CourseSection[] = [];
    for (const course of courses) {
      for (const sectionNumber of ['101', '102']) {
        let section = await repo.findOne({
          where: {
            courseId: course.id,
            semesterId,
            sectionNumber,
          },
        });
        if (!section) {
          section = repo.create({
            courseId: course.id,
            semesterId,
            sectionNumber,
            maxCapacity: 60,
            currentEnrollment: 0,
            location: `${deptCode}-Building Room ${sectionNumber}`,
            status: SectionStatus.OPEN,
          });
        } else {
          section.maxCapacity = 60;
          section.location = `${deptCode}-Building Room ${sectionNumber}`;
          section.status = SectionStatus.OPEN;
        }
        section = await repo.save(section);
        sections.push(section);
      }
    }
    map.set(deptCode, sections);
  }
  return map;
}

async function seedInstructorAssignments(
  repo: Repository<CourseInstructor>,
  sectionsByDepartment: Map<string, CourseSection[]>,
  instructors: User[],
) {
  const sections = flattenSections(sectionsByDepartment);
  for (let i = 0; i < sections.length; i++) {
    const section = sections[i];
    const instructor = instructors[i % instructors.length];
    const existing = await repo.findOne({
      where: { sectionId: section.id, userId: instructor.userId },
    });
    if (!existing) {
      await repo.save(
        repo.create({
          sectionId: section.id,
          userId: instructor.userId,
          role: InstructorRole.PRIMARY,
        }),
      );
    }
  }
}

async function seedTAAssignments(
  repo: Repository<CourseTA>,
  sectionsByDepartment: Map<string, CourseSection[]>,
  tas: User[],
) {
  const sections = flattenSections(sectionsByDepartment);
  const assignmentCount = Math.min(sections.length, tas.length);
  for (let i = 0; i < assignmentCount; i++) {
    const section = sections[i];
    const ta = tas[i];
    const existing = await repo.findOne({
      where: { sectionId: section.id, userId: ta.userId },
    });
    if (!existing) {
      await repo.save(
        repo.create({
          sectionId: section.id,
          userId: ta.userId,
          responsibilities: 'Lab support, office hours, and grading assistance',
        }),
      );
    }
  }
}

async function seedStudentEnrollments(
  enrollmentRepo: Repository<CourseEnrollment>,
  sectionRepo: Repository<CourseSection>,
  sectionsByDepartment: Map<string, CourseSection[]>,
  students: User[],
) {
  const departmentCodes = DEPARTMENTS.map((d) => d.code);
  const perDepartment = students.length / departmentCodes.length;

  for (let i = 0; i < students.length; i++) {
    const student = students[i];
    const deptCode = departmentCodes[Math.floor(i / perDepartment)];
    const deptSections = sectionsByDepartment.get(deptCode) ?? [];
    if (deptSections.length < 3) continue;

    const base = i % perDepartment;
    const picks = [base % deptSections.length, (base + 7) % deptSections.length, (base + 13) % deptSections.length];
    const uniqueSectionIds = Array.from(new Set(picks.map((idx) => deptSections[idx].id)));

    for (const sectionId of uniqueSectionIds) {
      const existing = await enrollmentRepo.findOne({
        where: { userId: student.userId, sectionId },
      });
      if (!existing) {
        await enrollmentRepo.save(
          enrollmentRepo.create({
            userId: student.userId,
            sectionId,
            status: EnrollmentStatus.ENROLLED,
            programId: null,
          }),
        );
      }
    }
  }

  // Recalculate section enrollment totals from actual enrollment rows.
  const allSections = flattenSections(sectionsByDepartment);
  for (const section of allSections) {
    const count = await enrollmentRepo.count({
      where: { sectionId: section.id, status: EnrollmentStatus.ENROLLED },
    });
    section.currentEnrollment = count;
    section.status = count >= section.maxCapacity ? SectionStatus.FULL : SectionStatus.OPEN;
    await sectionRepo.save(section);
  }
}

async function updateCourseOwnerHints(
  courseRepo: Repository<Course>,
  sectionRepo: Repository<CourseSection>,
  instructorRepo: Repository<CourseInstructor>,
  coursesByDepartment: Map<string, Course[]>,
) {
  const allCourses = Array.from(coursesByDepartment.values()).flat();
  for (const course of allCourses) {
    const sections = await sectionRepo.find({
      where: { courseId: course.id },
      select: ['id'],
    });
    if (sections.length === 0) {
      continue;
    }

    const primaryAssignment = await instructorRepo.findOne({
      where: {
        role: InstructorRole.PRIMARY,
        sectionId: In(sections.map((s) => s.id)),
      },
      order: { assignedAt: 'ASC' },
    });
    if (primaryAssignment) {
      course.instructorId = primaryAssignment.userId;
      await courseRepo.save(course);
    }
  }
}

async function findUsersByPattern(
  repo: Repository<User>,
  prefix: string,
  count: number,
) {
  const emails = Array.from(
    { length: count },
    (_, i) => `${prefix}${i + 1}.tarek@example.com`,
  );
  return repo.find({ where: { email: In(emails) }, relations: ['roles'] });
}

function flattenSections(map: Map<string, CourseSection[]>) {
  return Array.from(map.values()).flat();
}

export class AcademicStructureSeeder {
  async run(dataSource: DataSource) {
    await seedAcademicStructure(dataSource);
  }
}
