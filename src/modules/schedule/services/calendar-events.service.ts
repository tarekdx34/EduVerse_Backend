import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CalendarEvent } from '../entities';
import {
  CreateCalendarEventDto,
  UpdateCalendarEventDto,
  QueryCalendarEventDto,
} from '../dto';

@Injectable()
export class CalendarEventsService {
  constructor(
    @InjectRepository(CalendarEvent)
    private readonly eventRepo: Repository<CalendarEvent>,
  ) {}

  async findAll(query: QueryCalendarEventDto, userId: number, roles: string[]) {
    const { courseId, eventType, status, fromDate, toDate, page = 1, limit = 10 } = query;

    const qb = this.eventRepo.createQueryBuilder('event')
      .leftJoinAndSelect('event.course', 'course')
      .leftJoinAndSelect('event.user', 'user');

    // Role-based filtering
    const isAdmin = roles.includes('admin') || roles.includes('it_admin');

    if (!isAdmin) {
      // User can see their own events + course events for enrolled/taught courses
      qb.where(`(event.userId = :userId OR (event.courseId IS NOT NULL AND (
        event.courseId IN (SELECT cs.course_id FROM course_sections cs INNER JOIN course_enrollments ce ON ce.section_id = cs.section_id WHERE ce.user_id = :userId AND ce.enrollment_status = :enrolled) 
        OR event.courseId IN (SELECT cs2.course_id FROM course_sections cs2 INNER JOIN course_instructors ci ON ci.section_id = cs2.section_id WHERE ci.user_id = :userId) 
        OR event.courseId IN (SELECT cs3.course_id FROM course_sections cs3 INNER JOIN course_tas ct ON ct.section_id = cs3.section_id WHERE ct.user_id = :userId)
      )))`, { 
        userId, 
        enrolled: 'enrolled' 
      });
    }

    if (courseId) {
      qb.andWhere('event.courseId = :courseId', { courseId });
    }

    if (eventType) {
      qb.andWhere('event.eventType = :eventType', { eventType });
    }

    if (status) {
      qb.andWhere('event.status = :status', { status });
    }

    if (fromDate) {
      qb.andWhere('event.startTime >= :fromDate', { fromDate });
    }

    if (toDate) {
      qb.andWhere('event.endTime <= :toDate', { toDate });
    }

    qb.orderBy('event.startTime', 'ASC')
      .skip((page - 1) * limit)
      .take(limit);

    const [items, total] = await qb.getManyAndCount();

    return {
      data: items,
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  async findById(id: number, userId: number, roles: string[]) {
    const event = await this.eventRepo.findOne({
      where: { eventId: id },
      relations: ['course', 'user'],
    });

    if (!event) {
      throw new NotFoundException(`Calendar event with ID ${id} not found`);
    }

    // Access control
    const isAdmin = roles.includes('admin') || roles.includes('it_admin');
    if (!isAdmin && event.userId !== userId) {
      // Could add course access check here
    }

    return event;
  }

  async create(dto: CreateCalendarEventDto, userId: number, roles: string[]) {
    // If creating course event, check permissions
    if (dto.courseId) {
      const isAdmin = roles.includes('admin') || roles.includes('it_admin');
      const isInstructor = roles.includes('instructor');
      if (!isAdmin && !isInstructor) {
        throw new ForbiddenException('Only instructors and admins can create course events');
      }
    }

    const event = this.eventRepo.create({
      ...dto,
      userId,
      startTime: new Date(dto.startTime),
      endTime: new Date(dto.endTime),
    });

    return this.eventRepo.save(event);
  }

  async update(id: number, dto: UpdateCalendarEventDto, userId: number, roles: string[]) {
    const event = await this.findById(id, userId, roles);

    // Check ownership
    const isAdmin = roles.includes('admin') || roles.includes('it_admin');
    const isInstructor = roles.includes('instructor');
    
    if (!isAdmin && event.userId !== userId) {
      // Allow instructors to edit course events
      if (!isInstructor || !event.courseId) {
        throw new ForbiddenException('You can only edit your own events');
      }
    }

    if (dto.startTime) {
      dto.startTime = new Date(dto.startTime).toISOString();
    }
    if (dto.endTime) {
      dto.endTime = new Date(dto.endTime).toISOString();
    }

    Object.assign(event, dto);
    return this.eventRepo.save(event);
  }

  async delete(id: number, userId: number, roles: string[]) {
    const event = await this.findById(id, userId, roles);

    // Check ownership
    const isAdmin = roles.includes('admin') || roles.includes('it_admin');
    const isInstructor = roles.includes('instructor');
    
    if (!isAdmin && event.userId !== userId) {
      if (!isInstructor || !event.courseId) {
        throw new ForbiddenException('You can only delete your own events');
      }
    }

    await this.eventRepo.remove(event);
    return { message: 'Calendar event deleted successfully' };
  }
}
