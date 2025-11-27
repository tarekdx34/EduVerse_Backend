import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CourseSection } from '../entities/course-section.entity';
import { CourseSchedule } from '../entities/course-schedule.entity';
import { CreateSectionDto, UpdateSectionDto } from '../dtos';
import { SectionStatus } from '../enums';
import {
  SectionNotFoundException,
  SectionFullException,
  ScheduleConflictException,
} from '../exceptions';
import { CoursesService } from './courses.service';
import { Semester } from '../../campus/entities/semester.entity';

@Injectable()
export class CourseSectionsService {
  private readonly logger = new Logger(CourseSectionsService.name);

  constructor(
    @InjectRepository(CourseSection)
    private sectionRepository: Repository<CourseSection>,
    @InjectRepository(CourseSchedule)
    private scheduleRepository: Repository<CourseSchedule>,
    @InjectRepository(Semester)
    private semesterRepository: Repository<Semester>,
    private coursesService: CoursesService,
  ) {}

  async findByCourseId(courseId: number, semesterId?: number) {
    let query = this.sectionRepository
      .createQueryBuilder('section')
      .leftJoinAndSelect('section.course', 'course')
      .leftJoinAndSelect('section.semester', 'semester')
      .leftJoinAndSelect('section.schedules', 'schedules')
      .where('section.courseId = :courseId', { courseId });

    if (semesterId) {
      query = query.andWhere('section.semesterId = :semesterId', { semesterId });
    }

    return query.orderBy('section.sectionNumber', 'ASC').getMany();
  }

  async findById(id: number) {
    const section = await this.sectionRepository.findOne({
      where: { id },
      relations: ['course', 'semester', 'schedules'],
    });

    if (!section) {
      throw new SectionNotFoundException(id);
    }

    return section;
  }

  async create(dto: CreateSectionDto): Promise<CourseSection> {
    await this.coursesService.findById(dto.courseId);

    const semester = await this.semesterRepository.findOne({
      where: { id: dto.semesterId },
    });

    if (!semester) {
      throw new Error(`Semester ${dto.semesterId} not found`);
    }

    const section = this.sectionRepository.create({
      courseId: dto.courseId,
      semesterId: dto.semesterId,
      sectionNumber: dto.sectionNumber
        ? `${dto.sectionNumber}`
        : await this.generateSectionNumber(dto.courseId, dto.semesterId),
      maxCapacity: dto.maxCapacity,
      currentEnrollment: dto.currentEnrollment || 0,
      location: dto.location || null,
      status: SectionStatus.OPEN,
    });

    await this.sectionRepository.save(section);
    this.logger.log(`Section created: ${section.id}`);

    return section;
  }

  async update(id: number, dto: UpdateSectionDto): Promise<CourseSection> {
    const section = await this.findById(id);

    if (dto.maxCapacity && dto.maxCapacity < section.currentEnrollment) {
      throw new Error(
        `Cannot reduce capacity below current enrollment (${section.currentEnrollment})`,
      );
    }

    Object.assign(section, dto);

    if (!dto.status) {
      section.status = this.calculateSectionStatus(
        section.maxCapacity,
        section.currentEnrollment,
      );
    }

    await this.sectionRepository.save(section);
    this.logger.log(`Section updated: ${id}`);

    return section;
  }

  async updateEnrollment(id: number, currentEnrollment: number): Promise<void> {
    const section = await this.findById(id);

    if (currentEnrollment > section.maxCapacity) {
      throw new SectionFullException(id);
    }

    section.currentEnrollment = currentEnrollment;
    section.status = this.calculateSectionStatus(
      section.maxCapacity,
      currentEnrollment,
    );

    await this.sectionRepository.save(section);
  }

  private calculateSectionStatus(
    maxCapacity: number,
    currentEnrollment: number,
  ): SectionStatus {
    if (currentEnrollment >= maxCapacity) {
      return SectionStatus.FULL;
    }
    return SectionStatus.OPEN;
  }

  private async generateSectionNumber(
    courseId: number,
    semesterId: number,
  ): Promise<string> {
    const count = await this.sectionRepository.count({
      where: { courseId, semesterId },
    });

    return `${count + 1}`;
  }
}
