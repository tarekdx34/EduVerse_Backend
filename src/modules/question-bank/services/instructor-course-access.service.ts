import {
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CourseSection } from '../../courses/entities/course-section.entity';
import { Course } from '../../courses/entities/course.entity';
import { CourseInstructor } from '../../enrollments/entities/course-instructor.entity';

@Injectable()
export class InstructorCourseAccessService {
  constructor(
    @InjectRepository(Course)
    private readonly courseRepo: Repository<Course>,
    @InjectRepository(CourseInstructor)
    private readonly courseInstructorRepo: Repository<CourseInstructor>,
  ) {}

  async assertInstructorOwnsCourse(
    userId: number,
    courseId: number,
  ): Promise<void> {
    const courseExists = await this.courseRepo.exist({
      where: { id: courseId },
    });
    if (!courseExists) {
      throw new NotFoundException('Course not found');
    }

    const ownsCourse = await this.courseInstructorRepo
      .createQueryBuilder('assignment')
      .innerJoin(CourseSection, 'section', 'section.section_id = assignment.section_id')
      .where('assignment.user_id = :userId', { userId })
      .andWhere('section.course_id = :courseId', { courseId })
      .getExists();

    if (!ownsCourse) {
      throw new ForbiddenException(
        'Instructor is not assigned to this course',
      );
    }
  }

  async getInstructorCourseIds(userId: number): Promise<number[]> {
    const rows = await this.courseInstructorRepo
      .createQueryBuilder('assignment')
      .innerJoin(CourseSection, 'section', 'section.section_id = assignment.section_id')
      .select('DISTINCT section.course_id', 'courseId')
      .where('assignment.user_id = :userId', { userId })
      .getRawMany<{ courseId: string | number }>();

    return rows.map((row) => Number(row.courseId));
  }
}
