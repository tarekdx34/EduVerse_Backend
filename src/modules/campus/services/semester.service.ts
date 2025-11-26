import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Between } from 'typeorm';
import { Semester } from '../entities/semester.entity';
import { CreateSemesterDto, UpdateSemesterDto } from '../dtos/semester.dto';
import { SemesterStatus } from '../enums/semester-status.enum';
import {
  SemesterNotFoundException,
  SemesterCodeAlreadyExistsException,
  InvalidDateRangeException,
} from '../exceptions/campus.exceptions';

@Injectable()
export class SemesterService {
  constructor(
    @InjectRepository(Semester)
    private semesterRepository: Repository<Semester>,
  ) {}

  async findAll(status?: SemesterStatus, year?: number): Promise<Semester[]> {
    const query = this.semesterRepository.createQueryBuilder('semester');

    if (status) {
      query.where('semester.status = :status', { status });
    }

    if (year) {
      query.andWhere('YEAR(semester.startDate) = :year', { year });
    }

    return query.orderBy('semester.startDate', 'ASC').getMany();
  }

  async findById(id: number): Promise<Semester> {
    const semester = await this.semesterRepository.findOne({
      where: { id },
    });

    if (!semester) {
      throw new SemesterNotFoundException(id);
    }

    return semester;
  }

  async findCurrentSemester(): Promise<Semester> {
    const now = new Date();
    now.setHours(0, 0, 0, 0);

    const semester = await this.semesterRepository.findOne({
      where: {
        startDate: Between(new Date(0), now),
        endDate: Between(now, new Date(2099, 12, 31)),
      },
    });

    if (!semester) {
      throw new SemesterNotFoundException();
    }

    return semester;
  }

  async create(dto: CreateSemesterDto): Promise<Semester> {
    this.validateDateRange(dto);

    const existing = await this.semesterRepository.findOne({
      where: { code: dto.code },
    });

    if (existing) {
      throw new SemesterCodeAlreadyExistsException(dto.code);
    }

    const startDate = new Date(dto.startDate);
    const endDate = new Date(dto.endDate);
    const status = this.calculateStatus(startDate, endDate);

    const semester = this.semesterRepository.create({
      name: dto.name,
      code: dto.code,
      startDate,
      endDate,
      registrationStart: new Date(dto.registrationStart),
      registrationEnd: new Date(dto.registrationEnd),
      status,
    });

    return this.semesterRepository.save(semester);
  }

  async update(id: number, dto: UpdateSemesterDto): Promise<Semester> {
    const semester = await this.findById(id);

    if (dto.startDate || dto.endDate) {
      const startDate = dto.startDate ? new Date(dto.startDate) : semester.startDate;
      const endDate = dto.endDate ? new Date(dto.endDate) : semester.endDate;
      this.validateDateRangeForUpdate(startDate, endDate);
    }

    if (dto.code && dto.code !== semester.code) {
      const existing = await this.semesterRepository.findOne({
        where: { code: dto.code },
      });

      if (existing) {
        throw new SemesterCodeAlreadyExistsException(dto.code);
      }
    }

    if (dto.startDate || dto.endDate) {
      const startDate = dto.startDate ? new Date(dto.startDate) : semester.startDate;
      const endDate = dto.endDate ? new Date(dto.endDate) : semester.endDate;
      semester.status = this.calculateStatus(startDate, endDate);
    }

    Object.assign(semester, dto);
    return this.semesterRepository.save(semester);
  }

  async delete(id: number): Promise<void> {
    const semester = await this.findById(id);
    await this.semesterRepository.remove(semester);
  }

  calculateStatus(startDate: Date, endDate: Date): SemesterStatus {
    const now = new Date();
    now.setHours(0, 0, 0, 0);

    if (now < startDate) {
      return SemesterStatus.UPCOMING;
    } else if (now > endDate) {
      return SemesterStatus.COMPLETED;
    } else {
      return SemesterStatus.ACTIVE;
    }
  }

  private validateDateRange(dto: CreateSemesterDto): void {
    const startDate = new Date(dto.startDate);
    const endDate = new Date(dto.endDate);
    const registrationStart = new Date(dto.registrationStart);
    const registrationEnd = new Date(dto.registrationEnd);

    if (startDate >= endDate) {
      throw new InvalidDateRangeException('Start date must be before end date');
    }

    if (registrationStart >= registrationEnd) {
      throw new InvalidDateRangeException(
        'Registration start must be before registration end',
      );
    }

    if (registrationEnd > startDate) {
      throw new InvalidDateRangeException(
        'Registration must end before semester starts',
      );
    }
  }

  private validateDateRangeForUpdate(startDate: Date, endDate: Date): void {
    if (startDate >= endDate) {
      throw new InvalidDateRangeException('Start date must be before end date');
    }
  }
}
