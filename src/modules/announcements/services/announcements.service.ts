import {
  Injectable,
  Logger,
  NotFoundException,
  ForbiddenException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, In } from 'typeorm';
import { Announcement } from '../entities/announcement.entity';
import { CourseEnrollment } from '../../enrollments/entities/course-enrollment.entity';
import { CourseInstructor } from '../../enrollments/entities/course-instructor.entity';
import { CourseTA } from '../../enrollments/entities/course-ta.entity';
import { CourseSection } from '../../courses/entities/course-section.entity';
import {
  CreateAnnouncementDto,
  UpdateAnnouncementDto,
  AnnouncementQueryDto,
  ScheduleAnnouncementDto,
} from '../dto';
import { AnnouncementNotFoundException } from '../exceptions';

@Injectable()
export class AnnouncementsService {
  private readonly logger = new Logger(AnnouncementsService.name);

  constructor(
    @InjectRepository(Announcement)
    private announcementRepository: Repository<Announcement>,
    @InjectRepository(CourseEnrollment)
    private enrollmentRepository: Repository<CourseEnrollment>,
    @InjectRepository(CourseInstructor)
    private instructorRepository: Repository<CourseInstructor>,
    @InjectRepository(CourseTA)
    private taRepository: Repository<CourseTA>,
    @InjectRepository(CourseSection)
    private sectionRepository: Repository<CourseSection>,
  ) {}

  /**
   * Get course IDs accessible by user based on their role
   */
  private async getUserAccessibleCourseIds(userId: number, roles: string[]): Promise<number[]> {
    const courseIds: Set<number> = new Set();

    // If admin, return empty array to signal "access all"
    if (roles.includes('admin') || roles.includes('it_admin')) {
      return []; // Empty means all courses accessible
    }

    try {
      // For instructors: get courses they teach
      if (roles.includes('instructor')) {
        this.logger.debug(`Fetching instructor assignments for user ${userId}`);
        const instructorAssignments = await this.instructorRepository.find({
          where: { userId },
          relations: ['section'],
        });
        this.logger.debug(`Found ${instructorAssignments.length} instructor assignments`);
        for (const assignment of instructorAssignments) {
          if (assignment.section?.courseId) {
            courseIds.add(assignment.section.courseId);
          }
        }
      }

      // For TAs: get courses they assist
      if (roles.includes('teaching_assistant')) {
        this.logger.debug(`Fetching TA assignments for user ${userId}`);
        const taAssignments = await this.taRepository.find({
          where: { userId },
          relations: ['section'],
        });
        this.logger.debug(`Found ${taAssignments.length} TA assignments`);
        for (const assignment of taAssignments) {
          if (assignment.section?.courseId) {
            courseIds.add(assignment.section.courseId);
          }
        }
      }

      // For students: get enrolled courses
      if (roles.includes('student')) {
        this.logger.debug(`Fetching enrollments for user ${userId}`);
        const enrollments = await this.enrollmentRepository.find({
          where: { userId, status: 'enrolled' as any },
          relations: ['section'],
        });
        this.logger.debug(`Found ${enrollments.length} enrollments`);
        for (const enrollment of enrollments) {
          if (enrollment.section?.courseId) {
            courseIds.add(enrollment.section.courseId);
          }
        }
      }
    } catch (error) {
      this.logger.error(`Error fetching accessible courses: ${error.message}`, error.stack);
      throw error;
    }

    return Array.from(courseIds);
  }

  /**
   * List announcements with role-based filtering
   */
  async findAll(query: AnnouncementQueryDto, userId: number, roles: string[]) {
    try {
      const { courseId, announcementType, priority, isPublished, page = 1, limit = 20 } = query;
      const isAdmin = roles.includes('admin') || roles.includes('it_admin');

      const qb = this.announcementRepository.createQueryBuilder('a')
        .leftJoinAndSelect('a.author', 'author')
        .leftJoinAndSelect('a.course', 'course');

      // Apply role-based filtering
      if (!isAdmin) {
        const accessibleCourseIds = await this.getUserAccessibleCourseIds(userId, roles);
        this.logger.debug(`User ${userId} accessible courses: ${accessibleCourseIds.join(', ')}`);
        
      
      if (roles.includes('student')) {
        // Students only see published announcements for their courses and targeted at them
        qb.andWhere('a.isPublished = :isPublished', { isPublished: true });
        qb.andWhere('(a.targetAudience = :allAudience OR a.targetAudience = :studentAudience)', {
          allAudience: 'all',
          studentAudience: 'students',
        });
        
        if (accessibleCourseIds.length > 0) {
          qb.andWhere('(a.courseId IN (:...courseIds) OR a.courseId IS NULL)', { courseIds: accessibleCourseIds });
        } else {
          // Student has no enrollments - only see system-wide announcements
          qb.andWhere('a.courseId IS NULL');
        }
      } else {
        // Instructors/TAs see their courses + their own drafts + announcements targeted at their role
        const roleAudiences = ['all'];
        if (roles.includes('instructor')) roleAudiences.push('instructors');
        if (roles.includes('teaching_assistant')) roleAudiences.push('tas');

        qb.andWhere('(a.targetAudience IN (:...roleAudiences) OR a.createdBy = :userId)', {
          roleAudiences,
          userId,
        });

        if (accessibleCourseIds.length > 0) {
          qb.andWhere('(a.courseId IN (:...courseIds) OR a.createdBy = :userId OR a.courseId IS NULL)', {
            courseIds: accessibleCourseIds,
            userId,
          });
        } else {
          // No course assignments - only see own drafts and system-wide
          qb.andWhere('(a.createdBy = :userId OR a.courseId IS NULL)', { userId });
        }
      }
    }

    // Apply query filters
    if (courseId) {
      qb.andWhere('a.courseId = :courseId', { courseId });
    }
    if (announcementType) {
      qb.andWhere('a.announcementType = :announcementType', { announcementType });
    }
    if (priority) {
      qb.andWhere('a.priority = :priority', { priority });
    }
    if (isPublished !== undefined && isAdmin) {
      qb.andWhere('a.isPublished = :isPublished', { isPublished: isPublished ? 1 : 0 });
    }

    // Order by date (pinned not supported in current schema)
    qb.orderBy('a.createdAt', 'DESC')
      .skip((page - 1) * limit)
      .take(limit);

    const [data, total] = await qb.getManyAndCount();

    return {
      data,
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
    } catch (error) {
      this.logger.error(`Error in findAll: ${error.message}`, error.stack);
      throw error;
    }
  }

  /**
   * Get single announcement by ID
   */
  async findOne(id: number, userId: number, roles: string[]): Promise<Announcement> {
    const announcement = await this.announcementRepository.findOne({
      where: { id },
      relations: ['author', 'course'],
    });

    if (!announcement) {
      throw new AnnouncementNotFoundException(id);
    }

    // Increment view count
    await this.announcementRepository.increment({ id }, 'viewCount', 1);
    announcement.viewCount++;

    return announcement;
  }

  /**
   * Create a new announcement
   */
  async create(dto: CreateAnnouncementDto, userId: number): Promise<Announcement> {
    const announcement = this.announcementRepository.create({
      ...dto,
      createdBy: userId,
      publishedAt: dto.isPublished ? new Date() : undefined,
    });

    const saved = await this.announcementRepository.save(announcement);
    this.logger.log(`Announcement ${saved.id} created by user ${userId}`);

    // Reload with relations
    const result = await this.announcementRepository.findOne({
      where: { id: saved.id },
      relations: ['author', 'course'],
    });
    return result!;
  }

  /**
   * Update an announcement
   */
  async update(id: number, dto: UpdateAnnouncementDto, userId: number, roles: string[]): Promise<Announcement> {
    const announcement = await this.findOne(id, userId, roles);
    const isAdmin = roles.includes('admin') || roles.includes('it_admin');
    const isOwner = Number(announcement.createdBy) === Number(userId);

    if (!isOwner && !isAdmin) {
      throw new ForbiddenException('You can only update your own announcements');
    }

    Object.assign(announcement, dto);
    
    // If publishing now, set published date
    if (dto.isPublished && !announcement.publishedAt) {
      announcement.publishedAt = new Date();
    }

    const saved = await this.announcementRepository.save(announcement);
    this.logger.log(`Announcement ${id} updated by user ${userId}`);

    return saved;
  }

  /**
   * Delete an announcement
   */
  async remove(id: number, userId: number, roles: string[]): Promise<void> {
    const announcement = await this.findOne(id, userId, roles);
    const isAdmin = roles.includes('admin') || roles.includes('it_admin');
    const isOwner = Number(announcement.createdBy) === Number(userId);

    if (!isOwner && !isAdmin) {
      throw new ForbiddenException('You can only delete your own announcements');
    }

    await this.announcementRepository.remove(announcement);
    this.logger.log(`Announcement ${id} deleted by user ${userId}`);
  }

  /**
   * Publish an announcement
   */
  async publish(id: number, userId: number, roles: string[]): Promise<Announcement> {
    const announcement = await this.findOne(id, userId, roles);
    const isAdmin = roles.includes('admin') || roles.includes('it_admin');
    const isOwner = Number(announcement.createdBy) === Number(userId);

    if (!isOwner && !isAdmin) {
      throw new ForbiddenException('You can only publish your own announcements');
    }

    announcement.isPublished = true;
    announcement.publishedAt = new Date();

    const saved = await this.announcementRepository.save(announcement);
    this.logger.log(`Announcement ${id} published by user ${userId}`);

    return saved;
  }

  /**
   * Schedule an announcement for future publishing
   * Note: Uses expires_at temporarily to store scheduled date since scheduled_at column doesn't exist
   */
  async schedule(id: number, dto: ScheduleAnnouncementDto, userId: number, roles: string[]): Promise<Announcement> {
    const announcement = await this.findOne(id, userId, roles);
    const isAdmin = roles.includes('admin') || roles.includes('it_admin');
    const isOwner = Number(announcement.createdBy) === Number(userId);

    if (!isOwner && !isAdmin) {
      throw new ForbiddenException('You can only schedule your own announcements');
    }

    // Store scheduled date in expiresAt for now (workaround)
    announcement.expiresAt = new Date(dto.scheduledAt);
    announcement.isPublished = false;

    const saved = await this.announcementRepository.save(announcement);
    this.logger.log(`Announcement ${id} scheduled for ${dto.scheduledAt} by user ${userId}`);

    return saved;
  }

  /**
   * Toggle pin status of an announcement
   * Note: is_pinned column doesn't exist in current schema - returns unchanged announcement
   */
  async togglePin(id: number, userId: number, roles: string[]): Promise<Announcement> {
    const announcement = await this.findOne(id, userId, roles);
    const isAdmin = roles.includes('admin') || roles.includes('it_admin');
    const isInstructor = roles.includes('instructor');

    if (!isAdmin && !isInstructor) {
      throw new ForbiddenException('Only instructors and admins can pin announcements');
    }

    // Note: is_pinned column not in current schema, this is a no-op
    this.logger.warn(`Pin toggle attempted for announcement ${id} but is_pinned column not in schema`);

    return announcement;
  }

  /**
   * Get analytics for an announcement
   */
  async getAnalytics(id: number, userId: number, roles: string[]) {
    const announcement = await this.findOne(id, userId, roles);
    const isAdmin = roles.includes('admin') || roles.includes('it_admin');
    const isInstructor = roles.includes('instructor');
    const isOwner = Number(announcement.createdBy) === Number(userId);

    if (!isAdmin && !isInstructor && !isOwner) {
      throw new ForbiddenException('Only the author, instructors, and admins can view analytics');
    }

    return {
      announcementId: announcement.id,
      title: announcement.title,
      viewCount: announcement.viewCount,
      isPublished: announcement.isPublished,
      publishedAt: announcement.publishedAt,
      createdAt: announcement.createdAt,
    };
  }
}
