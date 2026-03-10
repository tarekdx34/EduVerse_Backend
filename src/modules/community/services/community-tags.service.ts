import {
  Injectable,
  Logger,
  NotFoundException,
  ConflictException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CommunityTag } from '../entities/community-tag.entity';
import { CreateTagDto } from '../dto';

@Injectable()
export class CommunityTagsService {
  private readonly logger = new Logger(CommunityTagsService.name);

  constructor(
    @InjectRepository(CommunityTag)
    private tagRepository: Repository<CommunityTag>,
  ) {}

  async findAll(): Promise<CommunityTag[]> {
    return this.tagRepository.find({ order: { name: 'ASC' } });
  }

  async findById(id: number): Promise<CommunityTag> {
    const tag = await this.tagRepository.findOne({ where: { id } });
    if (!tag) throw new NotFoundException(`Tag with ID ${id} not found`);
    return tag;
  }

  async findByName(name: string): Promise<CommunityTag | null> {
    return this.tagRepository.findOne({ where: { name: name.toLowerCase().trim() } });
  }

  async create(dto: CreateTagDto): Promise<CommunityTag> {
    const normalizedName = dto.name.toLowerCase().trim();
    const existing = await this.findByName(normalizedName);
    if (existing) {
      throw new ConflictException(`Tag "${normalizedName}" already exists`);
    }

    const tag = this.tagRepository.create({ name: normalizedName });
    const saved = await this.tagRepository.save(tag);
    this.logger.log(`Tag "${saved.name}" created`);
    return saved;
  }

  async delete(id: number): Promise<void> {
    const tag = await this.findById(id);
    await this.tagRepository.remove(tag);
    this.logger.log(`Tag "${tag.name}" deleted`);
  }

  /**
   * Find or create tags by names. Returns existing or newly created tag entities.
   */
  async findOrCreateByNames(names: string[]): Promise<CommunityTag[]> {
    const tags: CommunityTag[] = [];
    for (const rawName of names) {
      const name = rawName.toLowerCase().trim();
      if (!name) continue;
      let tag = await this.tagRepository.findOne({ where: { name } });
      if (!tag) {
        tag = this.tagRepository.create({ name });
        tag = await this.tagRepository.save(tag);
      }
      tags.push(tag);
    }
    return tags;
  }
}
