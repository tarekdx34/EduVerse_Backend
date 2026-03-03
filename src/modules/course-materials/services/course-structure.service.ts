import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, In } from 'typeorm';
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
  ) {}

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
