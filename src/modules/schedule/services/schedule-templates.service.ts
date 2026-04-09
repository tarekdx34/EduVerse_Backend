import { Injectable, NotFoundException, ForbiddenException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, DataSource, Brackets, In } from 'typeorm';
import { ScheduleTemplate, TemplateScheduleType } from '../entities/schedule-template.entity';
import { ScheduleTemplateSlot } from '../entities/schedule-template-slot.entity';
import { CourseSchedule } from '../../courses/entities/course-schedule.entity';
import {
  CreateScheduleTemplateDto,
  UpdateScheduleTemplateDto,
  ApplyTemplateToSectionDto,
  BulkApplyTemplateDto,
  QueryScheduleTemplateDto,
} from '../dto';

@Injectable()
export class ScheduleTemplatesService {
  constructor(
    @InjectRepository(ScheduleTemplate)
    private readonly templateRepo: Repository<ScheduleTemplate>,
    @InjectRepository(ScheduleTemplateSlot)
    private readonly slotRepo: Repository<ScheduleTemplateSlot>,
    @InjectRepository(CourseSchedule)
    private readonly courseScheduleRepo: Repository<CourseSchedule>,
    private readonly dataSource: DataSource,
  ) {}

  async findAll(query: QueryScheduleTemplateDto, userId: number, roles: string[]) {
    const {
      scheduleType,
      departmentId,
      isActive,
      search,
      page = 1,
      limit = 10,
    } = query;

    const isAdmin = roles.includes('admin') || roles.includes('it_admin');
    const isDeptHead = roles.includes('department_head');

    const qb = this.templateRepo.createQueryBuilder('template')
      .leftJoinAndSelect('template.creator', 'creator')
      .leftJoinAndSelect('template.department', 'department')
      .leftJoinAndSelect('template.slots', 'slots');

    // Visibility filtering
    if (!isAdmin) {
      if (isDeptHead) {
        // TODO: Get dept head's department and filter
        // For now, show university-wide and own department templates
        qb.where(
          new Brackets(qb => {
            qb.where('template.departmentId IS NULL')
              .orWhere('template.createdBy = :userId', { userId });
          })
        );
      } else {
        // Regular users can only see active university-wide templates
        qb.where('template.departmentId IS NULL')
          .andWhere('template.isActive = 1');
      }
    }

    // Filters
    if (scheduleType) {
      qb.andWhere('template.scheduleType = :scheduleType', { scheduleType });
    }

    if (departmentId !== undefined) {
      if (departmentId === null) {
        qb.andWhere('template.departmentId IS NULL');
      } else {
        qb.andWhere('template.departmentId = :departmentId', { departmentId });
      }
    }

    if (isActive !== undefined) {
      qb.andWhere('template.isActive = :isActive', { isActive });
    }

    if (search) {
      qb.andWhere(
        new Brackets(qb => {
          qb.where('template.name LIKE :search', { search: `%${search}%` })
            .orWhere('template.description LIKE :search', { search: `%${search}%` });
        })
      );
    }

    qb.orderBy('template.createdAt', 'DESC')
      .skip((page - 1) * limit)
      .take(limit);

    const [items, total] = await qb.getManyAndCount();
    const data = items.map((item) => this.normalizeTemplate(item));

    return {
      data,
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  async findById(id: number) {
    const template = await this.templateRepo.findOne({
      where: { templateId: id },
      relations: ['creator', 'department', 'slots'],
      order: {
        slots: {
          dayOfWeek: 'ASC',
          startTime: 'ASC',
        },
      },
    });

    if (!template) {
      throw new NotFoundException(`Schedule template with ID ${id} not found`);
    }

    return this.normalizeTemplate(template);
  }

  async create(dto: CreateScheduleTemplateDto, userId: number, roles: string[]) {
    // Check permissions
    const isAdmin = roles.includes('admin') || roles.includes('it_admin');
    const isDeptHead = roles.includes('department_head');

    if (!isAdmin && !isDeptHead) {
      throw new ForbiddenException('Only admins and department heads can create schedule templates');
    }

    // Department heads can only create department templates
    if (isDeptHead && !isAdmin && !dto.departmentId) {
      throw new ForbiddenException('Department heads must specify a department');
    }

    // Validate slots
    this.validateSlots(dto.slots);

    // Create template
    const template = this.templateRepo.create({
      name: dto.name,
      description: dto.description,
      departmentId: dto.departmentId,
      scheduleType: dto.scheduleType,
      createdBy: userId,
      isActive: dto.isActive !== undefined ? dto.isActive : true,
    });

    const savedTemplate = await this.templateRepo.save(template);

    // Create slots
    const slots = dto.slots.map(slot => {
      const durationMinutes = this.calculateDuration(slot.startTime, slot.endTime);
      return this.slotRepo.create({
        templateId: savedTemplate.templateId,
        dayOfWeek: slot.dayOfWeek,
        startTime: slot.startTime,
        endTime: slot.endTime,
        slotType: slot.slotType,
        durationMinutes,
        building: slot.building,
        room: slot.room,
      });
    });

    await this.slotRepo.save(slots);

    return this.findById(savedTemplate.templateId);
  }

  async update(id: number, dto: UpdateScheduleTemplateDto, userId: number, roles: string[]) {
    const template = await this.findById(id);

    // Check permissions
    const isAdmin = roles.includes('admin') || roles.includes('it_admin');

    if (!isAdmin && template.createdBy !== userId) {
      throw new ForbiddenException('You can only edit your own templates');
    }

    Object.assign(template, dto);
    const updated = await this.templateRepo.save(template);
    return this.findById(updated.templateId);
  }

  async delete(id: number, userId: number, roles: string[]) {
    const template = await this.findById(id);

    // Check permissions
    const isAdmin = roles.includes('admin') || roles.includes('it_admin');

    if (!isAdmin && template.createdBy !== userId) {
      throw new ForbiddenException('You can only delete your own templates');
    }

    await this.templateRepo.remove(template);
    return { message: 'Schedule template deleted successfully' };
  }

  async applyToSection(dto: ApplyTemplateToSectionDto, userId: number, roles: string[]) {
    const isAdmin = roles.includes('admin') || roles.includes('it_admin');
    const isDeptHead = roles.includes('department_head');

    if (!isAdmin && !isDeptHead) {
      throw new ForbiddenException('Only admins and department heads can apply schedule templates');
    }

    const template = await this.findById(dto.templateId);

    // Check if section exists
    const sectionExists = await this.dataSource.query(
      'SELECT section_id FROM course_sections WHERE section_id = ?',
      [dto.sectionId]
    );

    if (!sectionExists || sectionExists.length === 0) {
      throw new NotFoundException(`Course section with ID ${dto.sectionId} not found`);
    }

    // Delete existing schedules for this section
    await this.courseScheduleRepo.delete({ sectionId: dto.sectionId });

    // Create new schedules from template
    const schedules = template.slots.map(slot => {
      return this.courseScheduleRepo.create({
        sectionId: dto.sectionId,
        dayOfWeek: slot.dayOfWeek,
        startTime: slot.startTime,
        endTime: slot.endTime,
        scheduleType: slot.slotType,
        building: dto.building || slot.building,
        room: dto.room || slot.room,
      });
    });

    await this.courseScheduleRepo.save(schedules);

    return {
      message: 'Schedule template applied successfully',
      sectionId: dto.sectionId,
      schedulesCreated: schedules.length,
    };
  }

  async bulkApply(dto: BulkApplyTemplateDto, userId: number, roles: string[]) {
    const isAdmin = roles.includes('admin') || roles.includes('it_admin');
    const isDeptHead = roles.includes('department_head');

    if (!isAdmin && !isDeptHead) {
      throw new ForbiddenException('Only admins and department heads can apply schedule templates');
    }

    const template = await this.findById(dto.templateId);

    const results: Array<{ sectionId: number; status: string }> = [];
    const errors: Array<{ sectionId: number; status: string; message: string }> = [];

    for (const sectionId of dto.sectionIds) {
      try {
        await this.applyToSection(
          {
            templateId: dto.templateId,
            sectionId,
            building: dto.building,
            room: dto.room,
          },
          userId,
          roles
        );
        results.push({ sectionId, status: 'success' });
      } catch (error) {
        errors.push({
          sectionId,
          status: 'error',
          message: error.message,
        });
      }
    }

    return {
      message: 'Bulk template application completed',
      successful: results.length,
      failed: errors.length,
      results,
      errors,
    };
  }

  private validateSlots(slots: any[]) {
    if (slots.length === 0) {
      throw new BadRequestException('Template must have at least one time slot');
    }

    for (const slot of slots) {
      const duration = this.calculateDuration(slot.startTime, slot.endTime);
      if (duration <= 0) {
        throw new BadRequestException(`Invalid time range: ${slot.startTime} to ${slot.endTime}`);
      }
    }
  }

  private calculateDuration(startTime: string, endTime: string): number {
    const [startHour, startMin] = startTime.split(':').map(Number);
    const [endHour, endMin] = endTime.split(':').map(Number);

    const startTotal = startHour * 60 + startMin;
    const endTotal = endHour * 60 + endMin;

    return endTotal - startTotal;
  }

  private normalizeTemplate(template: ScheduleTemplate): ScheduleTemplate {
    if (!template.creator) {
      return {
        ...template,
        creator: {
          userId: 0,
          firstName: 'Unknown',
          lastName: 'User',
          email: 'unknown@system.local',
          passwordHash: '',
          status: 'active' as any,
          emailVerified: true,
          createdAt: template.createdAt,
          updatedAt: template.updatedAt,
          roles: [],
          sessions: [],
          passwordResets: [],
          twoFactorAuths: [],
        } as any,
      };
    }

    return template;
  }
}
