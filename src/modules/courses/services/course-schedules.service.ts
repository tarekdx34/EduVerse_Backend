import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CourseSchedule } from '../entities/course-schedule.entity';
import { CreateScheduleDto } from '../dtos';
import {
  ScheduleNotFoundException,
  InvalidTimeRangeException,
  ScheduleConflictException,
} from '../exceptions';
import { CourseSectionsService } from './course-sections.service';

@Injectable()
export class CourseSchedulesService {
  private readonly logger = new Logger(CourseSchedulesService.name);

  constructor(
    @InjectRepository(CourseSchedule)
    private scheduleRepository: Repository<CourseSchedule>,
    private sectionsService: CourseSectionsService,
  ) {}

  async findBySectionId(sectionId: number) {
    return this.scheduleRepository.find({
      where: { sectionId },
      order: { dayOfWeek: 'ASC', startTime: 'ASC' },
    });
  }

  async findById(id: number) {
    const schedule = await this.scheduleRepository.findOne({
      where: { id },
      relations: ['section'],
    });

    if (!schedule) {
      throw new ScheduleNotFoundException(id);
    }

    return schedule;
  }

  async create(sectionId: number, dto: CreateScheduleDto): Promise<CourseSchedule> {
    await this.sectionsService.findById(sectionId);

    this.validateTimeRange(dto.startTime, dto.endTime);
    await this.checkForConflicts(sectionId, dto);

    const schedule = this.scheduleRepository.create({
      sectionId,
      dayOfWeek: dto.dayOfWeek,
      startTime: dto.startTime,
      endTime: dto.endTime,
      room: dto.room || null,
      building: dto.building || null,
      scheduleType: dto.scheduleType,
    });

    await this.scheduleRepository.save(schedule);
    this.logger.log(
      `Schedule created: ${schedule.id} for section ${sectionId}`,
    );

    return schedule;
  }

  async delete(id: number): Promise<void> {
    const schedule = await this.findById(id);
    await this.scheduleRepository.remove(schedule);
    this.logger.log(`Schedule deleted: ${id}`);
  }

  private validateTimeRange(startTime: string, endTime: string): void {
    const [startHour, startMin] = startTime.split(':').map(Number);
    const [endHour, endMin] = endTime.split(':').map(Number);

    const startTotal = startHour * 60 + startMin;
    const endTotal = endHour * 60 + endMin;

    if (endTotal <= startTotal) {
      throw new InvalidTimeRangeException();
    }
  }

  private async checkForConflicts(
    sectionId: number,
    dto: CreateScheduleDto,
  ): Promise<void> {
    const section = await this.sectionsService.findById(sectionId);

    const conflictingSchedules = await this.scheduleRepository
      .createQueryBuilder('schedule')
      .innerJoinAndSelect(
        'schedule.section',
        'section',
        'section.semesterId = :semesterId',
        { semesterId: section.semesterId },
      )
      .where('schedule.dayOfWeek = :dayOfWeek', { dayOfWeek: dto.dayOfWeek })
      .andWhere('schedule.building = :building', { building: dto.building })
      .andWhere('schedule.room = :room', { room: dto.room })
      .andWhere(
        `(
          (schedule.startTime < :endTime AND schedule.endTime > :startTime)
        )`,
        { startTime: dto.startTime, endTime: dto.endTime },
      )
      .getMany();

    if (conflictingSchedules.length > 0) {
      throw new ScheduleConflictException(
        `Time conflict on ${dto.dayOfWeek} in ${dto.building} ${dto.room}`,
      );
    }
  }
}
