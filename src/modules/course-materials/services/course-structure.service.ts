import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, In, DataSource } from 'typeorm';
import { LectureSectionLab } from '../entities';
import {
  CreateStructureDto,
  UpdateStructureDto,
  ReorderStructureDto,
} from '../dto';

@Injectable()
export class CourseStructureService {
  constructor(
    @InjectRepository(LectureSectionLab)
    private readonly structureRepo: Repository<LectureSectionLab>,
    private readonly dataSource: DataSource,
  ) {}

  /**
   * Check if user is assigned to a course (as instructor or TA)
   */
  private async isUserAssignedToCourse(userId: number, courseId: number, roles: string[]): Promise<boolean> {
    const isInstructor = roles.includes('instructor');
    const isTA = roles.includes('teaching_assistant');

    if (isInstructor) {
      // Check if instructor is assigned to any section of this course
      const result = await this.dataSource.query(`
        SELECT COUNT(*) as count FROM course_instructors ci
        INNER JOIN course_sections cs ON ci.section_id = cs.section_id
        WHERE ci.user_id = ? AND cs.course_id = ?
      `, [userId, courseId]);
      return parseInt(result[0].count) > 0;
    }

    if (isTA) {
      // Check if TA is assigned to any section of this course
      const result = await this.dataSource.query(`
        SELECT COUNT(*) as count FROM course_tas ct
        INNER JOIN course_sections cs ON ct.section_id = cs.section_id
        WHERE ct.user_id = ? AND cs.course_id = ?
      `, [userId, courseId]);
      return parseInt(result[0].count) > 0;
    }

    return false;
  }

  async findAll(courseId: number) {
    const items = await this.structureRepo.find({
      where: { courseId },
      relations: ['material'],
      order: { weekNumber: 'ASC', orderIndex: 'ASC' },
    });

    // Group by week number
    const groupedByWeek = items.reduce((acc, item) => {
      const week = item.weekNumber || 0;
      if (!acc[week]) {
        acc[week] = [];
      }
      acc[week].push(item);
      return acc;
    }, {} as Record<number, LectureSectionLab[]>);

    return {
      data: items,
      byWeek: groupedByWeek,
    };
  }

  async findById(id: number) {
    const item = await this.structureRepo.findOne({
      where: { organizationId: id },
      relations: ['course', 'material'],
    });

    if (!item) {
      throw new NotFoundException(`Structure item with ID ${id} not found`);
    }

    return item;
  }

  async create(courseId: number, dto: CreateStructureDto, userId: number, roles: string[]) {
    // Check permission
    const isAdmin = roles.includes('admin') || roles.includes('it_admin');
    const isInstructor = roles.includes('instructor');

    if (!isAdmin && !isInstructor) {
      throw new ForbiddenException('Only instructors and admins can create course structure');
    }

    // Non-admins must be assigned to the course
    if (!isAdmin) {
      const isAssigned = await this.isUserAssignedToCourse(userId, courseId, roles);
      if (!isAssigned) {
        throw new ForbiddenException('You are not assigned to this course and cannot create structure items');
      }
    }

    // Get max order index for this week
    const maxOrder = await this.structureRepo
      .createQueryBuilder('s')
      .select('MAX(s.order_index)', 'maxOrder')
      .where('s.course_id = :courseId', { courseId })
      .andWhere('s.week_number = :weekNumber', { weekNumber: dto.weekNumber || 1 })
      .getRawOne();

    const orderIndex = dto.orderIndex ?? ((maxOrder?.maxOrder ?? -1) + 1);

    const item = this.structureRepo.create({
      ...dto,
      courseId,
      orderIndex,
    });

    return this.structureRepo.save(item);
  }

  async update(id: number, dto: UpdateStructureDto, userId: number, roles: string[]) {
    const item = await this.findById(id);

    // Check permission
    const isAdmin = roles.includes('admin') || roles.includes('it_admin');
    const isInstructor = roles.includes('instructor');

    if (!isAdmin && !isInstructor) {
      throw new ForbiddenException('Only instructors and admins can update course structure');
    }

    // Non-admins must be assigned to the course
    if (!isAdmin) {
      const isAssigned = await this.isUserAssignedToCourse(userId, item.courseId, roles);
      if (!isAssigned) {
        throw new ForbiddenException('You are not assigned to this course and cannot update structure items');
      }
    }

    Object.assign(item, dto);
    return this.structureRepo.save(item);
  }

  async delete(id: number, userId: number, roles: string[]) {
    const item = await this.findById(id);

    // Check permission
    const isAdmin = roles.includes('admin') || roles.includes('it_admin');
    const isInstructor = roles.includes('instructor');

    if (!isAdmin && !isInstructor) {
      throw new ForbiddenException('Only instructors and admins can delete course structure');
    }

    // Non-admins must be assigned to the course
    if (!isAdmin) {
      const isAssigned = await this.isUserAssignedToCourse(userId, item.courseId, roles);
      if (!isAssigned) {
        throw new ForbiddenException('You are not assigned to this course and cannot delete structure items');
      }
    }

    await this.structureRepo.remove(item);
    return { message: 'Structure item deleted successfully' };
  }

  async reorder(courseId: number, dto: ReorderStructureDto, userId: number, roles: string[]) {
    // Check permission
    const isAdmin = roles.includes('admin') || roles.includes('it_admin');
    const isInstructor = roles.includes('instructor');

    if (!isAdmin && !isInstructor) {
      throw new ForbiddenException('Only instructors and admins can reorder course structure');
    }

    // Non-admins must be assigned to the course
    if (!isAdmin) {
      const isAssigned = await this.isUserAssignedToCourse(userId, courseId, roles);
      if (!isAssigned) {
        throw new ForbiddenException('You are not assigned to this course and cannot reorder structure items');
      }
    }

    // Validate all IDs belong to this course
    const items = await this.structureRepo.find({
      where: { 
        organizationId: In(dto.orderIds),
        courseId,
      },
    });

    if (items.length !== dto.orderIds.length) {
      throw new NotFoundException('Some structure items not found or do not belong to this course');
    }

    // Update order indices
    const updates = dto.orderIds.map((id, index) => {
      return this.structureRepo.update(id, { orderIndex: index });
    });

    await Promise.all(updates);

    return { message: 'Structure reordered successfully' };
  }
}
