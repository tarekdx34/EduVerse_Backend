import {
  Injectable,
  Logger,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ForumCategory } from '../entities/forum-category.entity';
import { CreateCategoryDto, UpdateCategoryDto } from '../dto';
import { CategoryNotFoundException } from '../exceptions';

@Injectable()
export class ForumCategoriesService {
  private readonly logger = new Logger(ForumCategoriesService.name);

  constructor(
    @InjectRepository(ForumCategory)
    private categoryRepository: Repository<ForumCategory>,
  ) {}

  /**
   * List all categories, optionally filtered by course
   */
  async findAll(courseId?: number) {
    const qb = this.categoryRepository.createQueryBuilder('c')
      .leftJoinAndSelect('c.course', 'course');

    if (courseId) {
      qb.where('c.courseId = :courseId', { courseId });
    }

    qb.orderBy('c.orderIndex', 'ASC').addOrderBy('c.createdAt', 'ASC');

    const data = await qb.getMany();
    return { data };
  }

  /**
   * Get a single category by ID
   */
  async findOne(id: number): Promise<ForumCategory> {
    const category = await this.categoryRepository.findOne({
      where: { id },
      relations: ['course'],
    });

    if (!category) {
      throw new CategoryNotFoundException(id);
    }

    return category;
  }

  /**
   * Create a new category (admin only)
   */
  async create(dto: CreateCategoryDto): Promise<ForumCategory> {
    const category = this.categoryRepository.create(dto);
    const saved = await this.categoryRepository.save(category);
    
    this.logger.log(`Category ${saved.id} created: ${dto.name}`);

    const result = await this.categoryRepository.findOne({
      where: { id: saved.id },
      relations: ['course'],
    });
    return result!;
  }

  /**
   * Update a category (admin only)
   */
  async update(id: number, dto: UpdateCategoryDto): Promise<ForumCategory> {
    const category = await this.findOne(id);

    Object.assign(category, dto);
    const saved = await this.categoryRepository.save(category);
    
    this.logger.log(`Category ${id} updated`);

    const result = await this.categoryRepository.findOne({
      where: { id: saved.id },
      relations: ['course'],
    });
    return result!;
  }

  /**
   * Delete a category (admin only)
   */
  async remove(id: number): Promise<void> {
    const category = await this.findOne(id);
    await this.categoryRepository.remove(category);
    
    this.logger.log(`Category ${id} deleted`);
  }
}
