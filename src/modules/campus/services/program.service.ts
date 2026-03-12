import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Program } from '../entities/program.entity';
import { CreateProgramDto, UpdateProgramDto } from '../dtos/program.dto';
import { Status } from '../enums/status.enum';
import {
  ProgramNotFoundException,
  ProgramCodeAlreadyExistsException,
} from '../exceptions/campus.exceptions';

@Injectable()
export class ProgramService {
  constructor(
    @InjectRepository(Program)
    private programRepository: Repository<Program>,
  ) {}

  async findByDepartmentId(departmentId: number): Promise<Program[]> {
    return this.programRepository.find({
      where: { departmentId },
      relations: ['department'],
      order: { name: 'ASC' },
    });
  }

  async findById(id: number): Promise<Program> {
    const program = await this.programRepository.findOne({
      where: { id },
      relations: ['department', 'department.campus'],
    });

    if (!program) {
      throw new ProgramNotFoundException(id);
    }

    return program;
  }

  async create(dto: CreateProgramDto): Promise<Program> {
    const existing = await this.programRepository.findOne({
      where: {
        departmentId: dto.departmentId,
        code: dto.code,
      },
    });

    if (existing) {
      throw new ProgramCodeAlreadyExistsException(dto.code);
    }

    const program = this.programRepository.create({
      departmentId: dto.departmentId,
      name: dto.name,
      code: dto.code,
      degreeType: dto.degreeType,
      durationYears: dto.durationYears,
      description: dto.description,
      status: dto.status || Status.ACTIVE,
    });

    return this.programRepository.save(program);
  }

  async update(id: number, dto: UpdateProgramDto): Promise<Program> {
    const program = await this.findById(id);

    if (dto.code && dto.code !== program.code) {
      const existing = await this.programRepository.findOne({
        where: {
          departmentId: program.departmentId,
          code: dto.code,
        },
      });

      if (existing) {
        throw new ProgramCodeAlreadyExistsException(dto.code);
      }
    }

    Object.assign(program, dto);
    return this.programRepository.save(program);
  }

  async delete(id: number): Promise<void> {
    const program = await this.findById(id);
    await this.programRepository.remove(program);
  }
}
