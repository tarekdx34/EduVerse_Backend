import {
  Injectable,
  Logger,
  NotFoundException,
  ForbiddenException,
  BadRequestException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Community, CommunityType } from '../entities/community.entity';
import { CreateCommunityDto, UpdateCommunityDto, CommunityQueryDto } from '../dto';

@Injectable()
export class CommunitiesService {
  private readonly logger = new Logger(CommunitiesService.name);

  constructor(
    @InjectRepository(Community)
    private communityRepository: Repository<Community>,
  ) {}

  async findAll(query: CommunityQueryDto, userId: number, roles: string[]) {
    const { communityType, departmentId, page = 1, limit = 20 } = query;
    const isAdmin = roles.includes('admin') || roles.includes('it_admin');

    const qb = this.communityRepository.createQueryBuilder('c')
      .leftJoinAndSelect('c.department', 'department')
      .leftJoinAndSelect('c.createdBy', 'creator')
      .where('c.isActive = :active', { active: true });

    if (communityType) {
      qb.andWhere('c.communityType = :communityType', { communityType });
    }

    if (departmentId) {
      qb.andWhere('c.departmentId = :departmentId', { departmentId });
    }

    // For non-admin users, filter department communities to only departments they're enrolled in
    if (!isAdmin && (!communityType || communityType === CommunityType.DEPARTMENT)) {
      qb.andWhere(`(
        c.communityType = 'global'
        OR (c.communityType = 'department' AND c.departmentId IN (
          SELECT DISTINCT co.department_id 
          FROM course_enrollments ce
          JOIN course_sections cs ON ce.section_id = cs.section_id
          JOIN courses co ON cs.course_id = co.course_id
          WHERE ce.user_id = :userId AND ce.enrollment_status = 'enrolled'
        ))
      )`, { userId });
    }

    qb.orderBy('c.communityType', 'ASC') // global first
      .addOrderBy('c.name', 'ASC');

    qb.skip((page - 1) * limit).take(limit);

    const [data, total] = await qb.getManyAndCount();

    return {
      data,
      meta: { total, page, limit, totalPages: Math.ceil(total / limit) },
    };
  }

  async findById(id: number): Promise<Community> {
    const community = await this.communityRepository.findOne({
      where: { id },
      relations: ['department', 'createdBy'],
    });
    if (!community) {
      throw new NotFoundException(`Community with ID ${id} not found`);
    }
    return community;
  }

  async create(dto: CreateCommunityDto, userId: number): Promise<Community> {
    if (dto.communityType === CommunityType.DEPARTMENT && !dto.departmentId) {
      throw new BadRequestException('Department communities must specify a departmentId');
    }
    if (dto.communityType === CommunityType.GLOBAL && dto.departmentId) {
      throw new BadRequestException('Global communities cannot have a departmentId');
    }

    const community = this.communityRepository.create({
      ...dto,
      createdById: userId,
    });

    const saved = await this.communityRepository.save(community);
    this.logger.log(`Community ${saved.id} "${saved.name}" created by user ${userId}`);

    return this.findById(saved.id);
  }

  async update(id: number, dto: UpdateCommunityDto, userId: number, roles: string[]): Promise<Community> {
    const community = await this.findById(id);

    const isAdmin = roles.includes('admin') || roles.includes('it_admin');
    const isOwner = Number(community.createdById) === Number(userId);

    if (!isAdmin && !isOwner) {
      throw new ForbiddenException('Only community creator or admin can update a community');
    }

    Object.assign(community, dto);
    await this.communityRepository.save(community);
    this.logger.log(`Community ${id} updated by user ${userId}`);

    return this.findById(id);
  }

  /**
   * Check if a user has access to a specific community
   */
  async checkAccess(communityId: number, userId: number, roles: string[]): Promise<Community> {
    const community = await this.findById(communityId);

    const isAdmin = roles.includes('admin') || roles.includes('it_admin');
    if (isAdmin) return community;

    if (community.communityType === CommunityType.GLOBAL) {
      return community; // Everyone can access global
    }

    if (community.communityType === CommunityType.DEPARTMENT) {
      const hasAccess = await this.communityRepository.manager.query(`
        SELECT 1 FROM course_enrollments ce
        JOIN course_sections cs ON ce.section_id = cs.section_id
        JOIN courses co ON cs.course_id = co.course_id
        WHERE ce.user_id = ? AND co.department_id = ? AND ce.enrollment_status = 'enrolled'
        LIMIT 1
      `, [userId, community.departmentId]);

      if (!hasAccess || hasAccess.length === 0) {
        // Also check if user is instructor/TA — they might teach in the department
        const isInstructor = roles.includes('instructor') || roles.includes('teaching_assistant');
        if (!isInstructor) {
          throw new ForbiddenException('You do not have access to this department community');
        }
      }
    }

    return community;
  }

  /**
   * Get user's accessible department IDs
   */
  async getUserDepartmentIds(userId: number): Promise<number[]> {
    const result = await this.communityRepository.manager.query(`
      SELECT DISTINCT co.department_id 
      FROM course_enrollments ce
      JOIN course_sections cs ON ce.section_id = cs.section_id
      JOIN courses co ON cs.course_id = co.course_id
      WHERE ce.user_id = ? AND ce.enrollment_status = 'enrolled'
    `, [userId]);

    return result.map((r: any) => Number(r.department_id));
  }
}
