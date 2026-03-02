import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Rubric, RubricCriteria } from '../entities';
import { RubricNotFoundException } from '../exceptions';
import { CreateRubricDto } from '../dto';
import { Course } from '../../courses/entities/course.entity';

@Injectable()
export class RubricsService {
  private readonly logger = new Logger(RubricsService.name);

  constructor(
    @InjectRepository(Rubric)
    private rubricRepo: Repository<Rubric>,
    @InjectRepository(RubricCriteria)
    private criteriaRepo: Repository<RubricCriteria>,
    @InjectRepository(Course)
    private courseRepo: Repository<Course>,
  ) {}

  async create(dto: CreateRubricDto, userId: number): Promise<Rubric> {
    const course = await this.courseRepo.findOne({
      where: { id: dto.courseId },
    });
    if (!course) {
      throw new RubricNotFoundException();
    }

    const rubric = this.rubricRepo.create({
      ...dto,
      createdBy: userId,
    });

    const saved = await this.rubricRepo.save(rubric);
    this.logger.log(`Rubric created: ${saved.id} for course ${dto.courseId}`);
    return saved;
  }

  async findAll(courseId: number): Promise<Rubric[]> {
    return this.rubricRepo.find({
      where: { courseId },
      order: { createdAt: 'DESC' },
    });
  }

  async findOne(id: number): Promise<Rubric> {
    const rubric = await this.rubricRepo.findOne({
      where: { id },
    });
    if (!rubric) {
      throw new RubricNotFoundException(id);
    }
    return rubric;
  }

  async update(id: number, dto: Partial<CreateRubricDto>): Promise<Rubric> {
    const rubric = await this.findOne(id);
    Object.assign(rubric, dto);
    return this.rubricRepo.save(rubric);
  }

  async remove(id: number): Promise<void> {
    const rubric = await this.findOne(id);
    await this.rubricRepo.remove(rubric);
    this.logger.log(`Rubric deleted: ${id}`);
  }
}
