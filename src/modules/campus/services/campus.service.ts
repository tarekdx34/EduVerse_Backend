import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Campus } from '../entities/campus.entity';
import { CreateCampusDto, UpdateCampusDto } from '../dtos/campus.dto';
import { Status } from '../enums/status.enum';
import {
  CampusNotFoundException,
  CampusCodeAlreadyExistsException,
  CannotDeleteCampusWithDepartmentsException,
} from '../exceptions/campus.exceptions';

@Injectable()
export class CampusService {
  constructor(
    @InjectRepository(Campus)
    private campusRepository: Repository<Campus>,
  ) {}

  async findAll(status?: Status): Promise<Campus[]> {
    const query = this.campusRepository.createQueryBuilder('campus');

    if (status) {
      query.where('campus.status = :status', { status });
    }

    return query.orderBy('campus.name', 'ASC').getMany();
  }

  async findById(id: number): Promise<Campus> {
    const campus = await this.campusRepository.findOne({
      where: { id },
      relations: ['departments'],
    });

    if (!campus) {
      throw new CampusNotFoundException(id);
    }

    return campus;
  }

  async create(dto: CreateCampusDto): Promise<Campus> {
    const existing = await this.campusRepository.findOne({
      where: { code: dto.code },
    });

    if (existing) {
      throw new CampusCodeAlreadyExistsException(dto.code);
    }

    const campus = this.campusRepository.create({
      name: dto.name,
      code: dto.code,
      address: dto.address,
      city: dto.city,
      country: dto.country,
      phone: dto.phone,
      email: dto.email,
      timezone: dto.timezone || 'UTC',
      status: dto.status || Status.ACTIVE,
    });

    return this.campusRepository.save(campus);
  }

  async update(id: number, dto: UpdateCampusDto): Promise<Campus> {
    const campus = await this.findById(id);

    if (dto.code && dto.code !== campus.code) {
      const existing = await this.campusRepository.findOne({
        where: { code: dto.code },
      });

      if (existing) {
        throw new CampusCodeAlreadyExistsException(dto.code);
      }
    }

    Object.assign(campus, dto);
    return this.campusRepository.save(campus);
  }

  async delete(id: number): Promise<void> {
    const campus = await this.findById(id);

    const departmentCount = await this.campusRepository
      .createQueryBuilder('campus')
      .leftJoin('campus.departments', 'department')
      .where('campus.id = :id', { id })
      .select('COUNT(department.id)', 'count')
      .getRawOne();

    if (departmentCount && parseInt(departmentCount.count) > 0) {
      throw new CannotDeleteCampusWithDepartmentsException();
    }

    await this.campusRepository.remove(campus);
  }

  async getCampusWithDepartmentCount(id: number): Promise<any> {
    const result = await this.campusRepository
      .createQueryBuilder('campus')
      .leftJoinAndSelect('campus.departments', 'department')
      .where('campus.id = :id', { id })
      .loadRelationCountAndMap('campus.departmentCount', 'campus.departments')
      .getOne();

    if (!result) {
      throw new CampusNotFoundException(id);
    }

    return result;
  }
}
