import { Injectable, NotFoundException, ForbiddenException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, DataSource, Brackets } from 'typeorm';
import { CampusEvent, CampusEventType, CampusEventStatus } from '../entities/campus-event.entity';
import { CampusEventRegistration, RegistrationStatus } from '../entities/campus-event-registration.entity';
import {
  CreateCampusEventDto,
  UpdateCampusEventDto,
  QueryCampusEventDto,
  RegisterCampusEventDto,
} from '../dto';

@Injectable()
export class CampusEventsService {
  constructor(
    @InjectRepository(CampusEvent)
    private readonly eventRepo: Repository<CampusEvent>,
    @InjectRepository(CampusEventRegistration)
    private readonly registrationRepo: Repository<CampusEventRegistration>,
    private readonly dataSource: DataSource,
  ) {}

  /**
   * Get user's department, campus, and program IDs for filtering
   */
  private async getUserScope(userId: number): Promise<{
    departmentIds: number[];
    campusIds: number[];
    programIds: number[];
  }> {
    // Get user's department via enrollments
    const enrollmentResult = await this.dataSource.query(`
      SELECT DISTINCT c.department_id
      FROM course_enrollments ce
      INNER JOIN course_sections cs ON ce.section_id = cs.section_id
      INNER JOIN courses c ON cs.course_id = c.course_id
      WHERE ce.user_id = ? AND ce.enrollment_status = 'enrolled'
    `, [userId]);

    // Get user's campus (assuming users table has campus_id if needed)
    const userResult = await this.dataSource.query(`
      SELECT u.user_id
      FROM users u
      WHERE u.user_id = ?
    `, [userId]);

    return {
      departmentIds: enrollmentResult.map((r: any) => r.department_id).filter(Boolean),
      campusIds: [], // Add campus logic if needed
      programIds: [], // Add program logic if needed
    };
  }

  async findAll(query: QueryCampusEventDto, userId: number, roles: string[]) {
    const {
      eventType,
      scopeId,
      status,
      fromDate,
      toDate,
      tag,
      search,
      page = 1,
      limit = 10,
    } = query;

    const isAdmin = roles.includes('admin') || roles.includes('it_admin');
    const isDeptHead = roles.includes('department_head');

    const qb = this.eventRepo.createQueryBuilder('event')
      .leftJoinAndSelect('event.organizer', 'organizer')
      .leftJoinAndSelect('organizer.roles', 'organizerRoles');

    // Visibility filtering
    if (!isAdmin) {
      const userScope = await this.getUserScope(userId);

      qb.where(new Brackets(qb => {
        // University-wide events visible to all
        qb.where('event.eventType = :universityWide', { universityWide: CampusEventType.UNIVERSITY_WIDE });

        // Department events visible if user is in that department
        if (userScope.departmentIds.length > 0) {
          qb.orWhere(
            'event.eventType = :department AND event.scopeId IN (:...deptIds)',
            { department: CampusEventType.DEPARTMENT, deptIds: userScope.departmentIds }
          );
        }

        // If department head, show all events in their department
        if (isDeptHead) {
          // Add logic to get dept head's department and show those events
        }
      }));

      // Only show published events to non-admins
      qb.andWhere('event.status = :published', { published: CampusEventStatus.PUBLISHED });
    }

    // Filters
    if (eventType) {
      qb.andWhere('event.eventType = :eventType', { eventType });
    }

    if (scopeId) {
      qb.andWhere('event.scopeId = :scopeId', { scopeId });
    }

    if (status) {
      qb.andWhere('event.status = :status', { status });
    }

    if (fromDate) {
      qb.andWhere('event.startDatetime >= :fromDate', { fromDate: new Date(fromDate) });
    }

    if (toDate) {
      qb.andWhere('event.endDatetime <= :toDate', { toDate: new Date(toDate) });
    }

    if (tag) {
      qb.andWhere('JSON_CONTAINS(event.tags, :tag)', { tag: JSON.stringify(tag) });
    }

    if (search) {
      qb.andWhere(
        new Brackets(qb => {
          qb.where('event.title LIKE :search', { search: `%${search}%` })
            .orWhere('event.description LIKE :search', { search: `%${search}%` });
        })
      );
    }

    qb.orderBy('event.startDatetime', 'ASC')
      .skip((page - 1) * limit)
      .take(limit);

    const [items, total] = await qb.getManyAndCount();

    // Get registration status for each event
    const itemsWithRegistration = await Promise.all(
      items.map(async (event) => {
        const registration = event.registrationRequired
          ? await this.registrationRepo.findOne({
              where: { eventId: event.eventId, userId },
            })
          : null;

        const registrationCount = event.registrationRequired
          ? await this.registrationRepo.count({
              where: { eventId: event.eventId, status: RegistrationStatus.REGISTERED },
            })
          : 0;

        return {
          ...event,
          userRegistration: registration,
          registrationCount,
          spotsRemaining: event.maxAttendees
            ? Math.max(0, event.maxAttendees - registrationCount)
            : null,
        };
      })
    );

    return {
      data: itemsWithRegistration,
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  async findMyEvents(userId: number, roles: string[]) {
    // Get events visible to this user
    const query: QueryCampusEventDto = {
      status: CampusEventStatus.PUBLISHED,
      fromDate: new Date().toISOString().split('T')[0], // From today
    };

    return this.findAll(query, userId, roles);
  }

  async findById(id: number, userId: number, roles: string[]) {
    const event = await this.eventRepo.findOne({
      where: { eventId: id },
      relations: ['organizer', 'organizer.roles'],
    });

    if (!event) {
      throw new NotFoundException(`Campus event with ID ${id} not found`);
    }

    // Check visibility
    const isAdmin = roles.includes('admin') || roles.includes('it_admin');
    if (!isAdmin && event.status !== CampusEventStatus.PUBLISHED) {
      throw new ForbiddenException('You do not have permission to view this event');
    }

    // Get registration info
    const registration = event.registrationRequired
      ? await this.registrationRepo.findOne({
          where: { eventId: event.eventId, userId },
        })
      : null;

    const registrationCount = event.registrationRequired
      ? await this.registrationRepo.count({
          where: { eventId: event.eventId, status: RegistrationStatus.REGISTERED },
        })
      : 0;

    return {
      ...event,
      userRegistration: registration,
      registrationCount,
      spotsRemaining: event.maxAttendees
        ? Math.max(0, event.maxAttendees - registrationCount)
        : null,
    };
  }

  async create(dto: CreateCampusEventDto, userId: number, roles: string[]) {
    // Check permissions
    const isAdmin = roles.includes('admin') || roles.includes('it_admin');
    const isDeptHead = roles.includes('department_head');

    if (!isAdmin && !isDeptHead) {
      throw new ForbiddenException('Only admins and department heads can create campus events');
    }

    // Department heads can only create department events
    if (isDeptHead && !isAdmin) {
      if (dto.eventType !== CampusEventType.DEPARTMENT) {
        throw new ForbiddenException('Department heads can only create department-level events');
      }
      // TODO: Verify scopeId matches dept head's department
    }

    // Validate dates
    if (new Date(dto.startDatetime) >= new Date(dto.endDatetime)) {
      throw new BadRequestException('End datetime must be after start datetime');
    }

    const event = this.eventRepo.create({
      ...dto,
      organizerId: userId,
      startDatetime: new Date(dto.startDatetime),
      endDatetime: new Date(dto.endDatetime),
    });

    return this.eventRepo.save(event);
  }

  async update(id: number, dto: UpdateCampusEventDto, userId: number, roles: string[]) {
    const event = await this.findById(id, userId, roles);

    // Check permissions
    const isAdmin = roles.includes('admin') || roles.includes('it_admin');
    const isDeptHead = roles.includes('department_head');

    if (!isAdmin && event.organizerId !== userId && !isDeptHead) {
      throw new ForbiddenException('You can only edit your own events');
    }

    // Validate dates if provided
    if (dto.startDatetime && dto.endDatetime) {
      if (new Date(dto.startDatetime) >= new Date(dto.endDatetime)) {
        throw new BadRequestException('End datetime must be after start datetime');
      }
    }

    if (dto.startDatetime) {
      dto.startDatetime = new Date(dto.startDatetime) as any;
    }
    if (dto.endDatetime) {
      dto.endDatetime = new Date(dto.endDatetime) as any;
    }

    Object.assign(event, dto);
    return this.eventRepo.save(event);
  }

  async delete(id: number, userId: number, roles: string[]) {
    const event = await this.findById(id, userId, roles);

    // Check permissions
    const isAdmin = roles.includes('admin') || roles.includes('it_admin');
    
    if (!isAdmin && event.organizerId !== userId) {
      throw new ForbiddenException('You can only delete your own events');
    }

    await this.eventRepo.remove(event);
    return { message: 'Campus event deleted successfully' };
  }

  async register(eventId: number, dto: RegisterCampusEventDto, userId: number) {
    const event = await this.eventRepo.findOne({ where: { eventId } });

    if (!event) {
      throw new NotFoundException(`Campus event with ID ${eventId} not found`);
    }

    if (!event.registrationRequired) {
      throw new BadRequestException('This event does not require registration');
    }

    if (event.status !== CampusEventStatus.PUBLISHED) {
      throw new BadRequestException('Cannot register for unpublished events');
    }

    // Check if already registered
    const existing = await this.registrationRepo.findOne({
      where: { eventId, userId },
    });

    if (existing && existing.status === RegistrationStatus.REGISTERED) {
      throw new BadRequestException('You are already registered for this event');
    }

    // Check capacity
    if (event.maxAttendees) {
      const currentCount = await this.registrationRepo.count({
        where: { eventId, status: RegistrationStatus.REGISTERED },
      });

      if (currentCount >= event.maxAttendees) {
        throw new BadRequestException('Event is at maximum capacity');
      }
    }

    // Create or update registration
    if (existing) {
      existing.status = RegistrationStatus.REGISTERED;
      existing.notes = dto.notes || null;
      return this.registrationRepo.save(existing);
    }

    const registration = this.registrationRepo.create({
      eventId,
      userId,
      status: RegistrationStatus.REGISTERED,
      notes: dto.notes,
    });

    return this.registrationRepo.save(registration);
  }

  async unregister(eventId: number, userId: number) {
    const registration = await this.registrationRepo.findOne({
      where: { eventId, userId },
    });

    if (!registration) {
      throw new NotFoundException('Registration not found');
    }

    if (registration.status === RegistrationStatus.CANCELLED) {
      throw new BadRequestException('Registration already cancelled');
    }

    registration.status = RegistrationStatus.CANCELLED;
    await this.registrationRepo.save(registration);

    return { message: 'Successfully unregistered from event' };
  }

  async getRegistrations(eventId: number, userId: number, roles: string[]) {
    const event = await this.eventRepo.findOne({ where: { eventId } });

    if (!event) {
      throw new NotFoundException(`Campus event with ID ${eventId} not found`);
    }

    // Check permissions
    const isAdmin = roles.includes('admin') || roles.includes('it_admin');
    if (!isAdmin && event.organizerId !== userId) {
      throw new ForbiddenException('Only event organizers and admins can view registrations');
    }

    const registrations = await this.registrationRepo.find({
      where: { eventId },
      relations: ['user'],
      order: { registeredAt: 'DESC' },
    });

    return {
      event,
      registrations,
      summary: {
        total: registrations.length,
        registered: registrations.filter(r => r.status === RegistrationStatus.REGISTERED).length,
        attended: registrations.filter(r => r.status === RegistrationStatus.ATTENDED).length,
        cancelled: registrations.filter(r => r.status === RegistrationStatus.CANCELLED).length,
        noShow: registrations.filter(r => r.status === RegistrationStatus.NO_SHOW).length,
      },
    };
  }
}
