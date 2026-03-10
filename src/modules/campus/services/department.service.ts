import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Department } from '../entities/department.entity';
import { CreateDepartmentDto, UpdateDepartmentDto } from '../dtos/department.dto';
import { Status } from '../enums/status.enum';
import {
  DepartmentNotFoundException,
  DepartmentCodeAlreadyExistsException,
  CannotDeleteDepartmentWithProgramsException,
  InvalidHeadOfDepartmentException,
} from '../exceptions/campus.exceptions';
import { User } from '../../auth/entities/user.entity';

@Injectable()
export class DepartmentService {
  constructor(
    @InjectRepository(Department)
    private departmentRepository: Repository<Department>,
    @InjectRepository(User)
    private userRepository: Repository<User>,
  ) {}

  async findByCampusId(campusId: number): Promise<Department[]> {
    return this.departmentRepository.find({
      where: { campusId },
      relations: ['campus', 'head'],
      order: { name: 'ASC' },
    });
  }

  async findById(id: number): Promise<Department> {
    const department = await this.departmentRepository.findOne({
      where: { id },
      relations: ['campus', 'programs', 'head'],
    });

    if (!department) {
      throw new DepartmentNotFoundException(id);
    }

    return department;
  }

  async create(dto: CreateDepartmentDto): Promise<Department> {
    if (dto.headOfDepartmentId) {
      await this.validateHeadOfDepartment(dto.headOfDepartmentId);
    }

    const existing = await this.departmentRepository.findOne({
      where: {
        campusId: dto.campusId,
        code: dto.code,
      },
    });

    if (existing) {
      throw new DepartmentCodeAlreadyExistsException(dto.code);
    }

    const department = this.departmentRepository.create({
      campusId: dto.campusId,
      name: dto.name,
      code: dto.code,
      headOfDepartmentId: dto.headOfDepartmentId,
      description: dto.description,
      status: dto.status || Status.ACTIVE,
    });

    return this.departmentRepository.save(department);
  }

  async update(id: number, dto: UpdateDepartmentDto): Promise<Department> {
    const department = await this.findById(id);

    if (dto.headOfDepartmentId && dto.headOfDepartmentId !== department.headOfDepartmentId) {
      await this.validateHeadOfDepartment(dto.headOfDepartmentId);
    }

    if (dto.code && dto.code !== department.code) {
      const existing = await this.departmentRepository.findOne({
        where: {
          campusId: department.campusId,
          code: dto.code,
        },
      });

      if (existing) {
        throw new DepartmentCodeAlreadyExistsException(dto.code);
      }
    }

    Object.assign(department, dto);
    return this.departmentRepository.save(department);
  }

  async delete(id: number): Promise<void> {
    const department = await this.findById(id);

    const programCount = await this.departmentRepository
      .createQueryBuilder('department')
      .leftJoin('department.programs', 'program')
      .where('department.id = :id', { id })
      .select('COUNT(program.id)', 'count')
      .getRawOne();

    if (programCount && parseInt(programCount.count) > 0) {
      throw new CannotDeleteDepartmentWithProgramsException();
    }

    await this.departmentRepository.remove(department);
  }

  async validateHeadOfDepartment(userId: number): Promise<void> {
    const user = await this.userRepository
      .createQueryBuilder('user')
      .leftJoinAndSelect('user.roles', 'role')
      .where('user.id = :id', { id: userId })
      .getOne();

    if (!user) {
      throw new InvalidHeadOfDepartmentException();
    }

    const hasRequiredRole = user.roles.some(
      (role) => (role as any).roleName === 'instructor' || (role as any).roleName === 'admin',
    );

    if (!hasRequiredRole) {
      throw new InvalidHeadOfDepartmentException();
    }
  }
}
