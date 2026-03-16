import {
  Injectable,
  Logger,
  NotFoundException,
  BadRequestException,
  ForbiddenException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { StudyGroup } from '../entities/study-group.entity';
import { StudyGroupMember } from '../entities/study-group-member.entity';
import { CreateStudyGroupDto } from '../dto/create-study-group.dto';
import { UpdateStudyGroupDto } from '../dto/update-study-group.dto';

@Injectable()
export class StudyGroupsService {
  private readonly logger = new Logger(StudyGroupsService.name);

  constructor(
    @InjectRepository(StudyGroup)
    private groupRepo: Repository<StudyGroup>,
    @InjectRepository(StudyGroupMember)
    private memberRepo: Repository<StudyGroupMember>,
  ) {}

  async findAll(courseId?: number) {
    const qb = this.groupRepo.createQueryBuilder('sg')
      .leftJoinAndSelect('sg.creator', 'creator')
      .orderBy('sg.createdAt', 'DESC');

    if (courseId) {
      qb.where('sg.courseId = :courseId', { courseId });
    }

    const data = await qb.getMany();
    return { data };
  }

  async findById(id: number) {
    const group = await this.groupRepo.findOne({
      where: { groupId: id },
      relations: ['creator'],
    });
    if (!group) {
      throw new NotFoundException(`Study group #${id} not found`);
    }
    return { data: group };
  }

  async findMyGroups(userId: number) {
    const memberships = await this.memberRepo.find({
      where: { userId },
      relations: ['group', 'group.creator'],
    });
    const data = memberships.map((m) => ({
      ...m.group,
      memberRole: m.role,
      joinedAt: m.joinedAt,
    }));
    return { data };
  }

  async createGroup(dto: CreateStudyGroupDto, userId: number) {
    const group = this.groupRepo.create({
      ...dto,
      createdBy: userId,
      currentMembers: 1,
    });
    const saved = await this.groupRepo.save(group);

    // Add creator as first member
    const member = this.memberRepo.create({
      groupId: saved.groupId,
      userId,
      role: 'creator',
    });
    await this.memberRepo.save(member);

    return { data: saved, message: 'Study group created successfully' };
  }

  async updateGroup(id: number, dto: UpdateStudyGroupDto, userId: number) {
    const group = await this.groupRepo.findOne({ where: { groupId: id } });
    if (!group) {
      throw new NotFoundException(`Study group #${id} not found`);
    }
    if (group.createdBy != userId) {
      throw new ForbiddenException('Only the group creator can update this group');
    }
    Object.assign(group, dto);
    const saved = await this.groupRepo.save(group);
    return { data: saved, message: `Study group #${id} updated successfully` };
  }

  async deleteGroup(id: number, userId: number, userRoles: string[]) {
    const group = await this.groupRepo.findOne({ where: { groupId: id } });
    if (!group) {
      throw new NotFoundException(`Study group #${id} not found`);
    }
    const isAdmin = userRoles.some((r) => r === 'admin' || r === 'it_admin');
    if (group.createdBy != userId && !isAdmin) {
      throw new ForbiddenException('Only the group creator or admins can delete this group');
    }
    // Remove all members first
    await this.memberRepo.delete({ groupId: id });
    await this.groupRepo.remove(group);
    return { message: `Study group #${id} deleted successfully` };
  }

  async joinGroup(id: number, userId: number) {
    const group = await this.groupRepo.findOne({ where: { groupId: id } });
    if (!group) {
      throw new NotFoundException(`Study group #${id} not found`);
    }
    if (group.status !== 'active') {
      throw new BadRequestException('This group is not active');
    }
    if (group.currentMembers >= group.maxMembers) {
      throw new BadRequestException('This group is full');
    }

    // Check if already a member
    const existing = await this.memberRepo.findOne({
      where: { groupId: id, userId },
    });
    if (existing) {
      throw new BadRequestException('You are already a member of this group');
    }

    const member = this.memberRepo.create({
      groupId: id,
      userId,
      role: 'member',
    });
    await this.memberRepo.save(member);

    group.currentMembers += 1;
    await this.groupRepo.save(group);

    return { message: 'Joined study group successfully' };
  }

  async leaveGroup(id: number, userId: number) {
    const group = await this.groupRepo.findOne({ where: { groupId: id } });
    if (!group) {
      throw new NotFoundException(`Study group #${id} not found`);
    }

    const member = await this.memberRepo.findOne({
      where: { groupId: id, userId },
    });
    if (!member) {
      throw new BadRequestException('You are not a member of this group');
    }
    if (member.role === 'creator') {
      throw new BadRequestException('The group creator cannot leave. Delete the group instead.');
    }

    await this.memberRepo.remove(member);
    group.currentMembers = Math.max(0, group.currentMembers - 1);
    await this.groupRepo.save(group);

    return { message: 'Left study group successfully' };
  }

  async getMembers(id: number) {
    const group = await this.groupRepo.findOne({ where: { groupId: id } });
    if (!group) {
      throw new NotFoundException(`Study group #${id} not found`);
    }
    const data = await this.memberRepo.find({
      where: { groupId: id },
      relations: ['user'],
      order: { joinedAt: 'ASC' },
    });
    return { data };
  }
}
