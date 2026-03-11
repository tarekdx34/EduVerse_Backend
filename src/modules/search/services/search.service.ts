import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Brackets } from 'typeorm';
import { SearchIndex, SearchEntityType } from '../entities/search-index.entity';
import { SearchHistory } from '../entities/search-history.entity';
import { GlobalSearchDto, SearchSortBy } from '../dto/global-search.dto';

@Injectable()
export class SearchService {
  private readonly logger = new Logger(SearchService.name);

  constructor(
    @InjectRepository(SearchIndex)
    private searchIndexRepo: Repository<SearchIndex>,
    @InjectRepository(SearchHistory)
    private searchHistoryRepo: Repository<SearchHistory>,
  ) {}

  async globalSearch(dto: GlobalSearchDto, userId: number) {
    const {
      query,
      entityType,
      courseId,
      campusId,
      visibility,
      page = 1,
      limit = 20,
      sortBy = SearchSortBy.RELEVANCE,
    } = dto;

    this.logger.debug(`Global search: query="${query}" by user ${userId}`);

    const qb = this.searchIndexRepo.createQueryBuilder('si');

    qb.where(
      new Brackets((wb) => {
        wb.where('si.title LIKE :search', { search: `%${query}%` })
          .orWhere('si.content LIKE :search', { search: `%${query}%` })
          .orWhere('si.keywords LIKE :search', { search: `%${query}%` });
      }),
    );

    if (entityType) {
      qb.andWhere('si.entity_type = :entityType', { entityType });
    }
    if (courseId) {
      qb.andWhere('si.course_id = :courseId', { courseId });
    }
    if (campusId) {
      qb.andWhere('si.campus_id = :campusId', { campusId });
    }
    if (visibility) {
      qb.andWhere('si.visibility = :visibility', { visibility });
    }

    if (sortBy === SearchSortBy.RECENT) {
      qb.orderBy('si.created_at', 'DESC');
    } else {
      // Relevance: prioritize title matches, then keywords, then content
      qb.addSelect(
        `(CASE WHEN si.title LIKE :search THEN 3 ELSE 0 END) + ` +
          `(CASE WHEN si.keywords LIKE :search THEN 2 ELSE 0 END) + ` +
          `(CASE WHEN si.content LIKE :search THEN 1 ELSE 0 END)`,
        'relevance_score',
      );
      qb.orderBy('relevance_score', 'DESC');
    }

    const total = await qb.getCount();
    const items = await qb
      .skip((page - 1) * limit)
      .take(limit)
      .getMany();

    // Group results by entity_type
    const grouped = new Map<string, SearchIndex[]>();
    for (const item of items) {
      const group = grouped.get(item.entityType) || [];
      group.push(item);
      grouped.set(item.entityType, group);
    }

    const results = Array.from(grouped.entries()).map(([type, groupItems]) => ({
      entityType: type,
      items: groupItems,
      count: groupItems.length,
    }));

    // Record in search history
    await this.recordHistory(userId, query, dto, total);

    const totalPages = Math.ceil(total / limit);

    return {
      results,
      totalResults: total,
      meta: {
        total,
        page,
        limit,
        totalPages,
      },
    };
  }

  async searchCourses(query: string, userId: number, page = 1, limit = 20) {
    this.logger.debug(`Search courses: query="${query}" by user ${userId}`);
    return this.searchByEntityType(query, SearchEntityType.COURSE, userId, page, limit);
  }

  async searchUsers(query: string, userId: number, page = 1, limit = 20) {
    this.logger.debug(`Search users: query="${query}" by user ${userId}`);
    return this.searchByEntityType(query, SearchEntityType.USER, userId, page, limit);
  }

  async searchMaterials(query: string, userId: number, page = 1, limit = 20) {
    this.logger.debug(`Search materials: query="${query}" by user ${userId}`);
    return this.searchByEntityType(query, SearchEntityType.MATERIAL, userId, page, limit);
  }

  async getHistory(userId: number, page = 1, limit = 20) {
    this.logger.debug(`Get search history for user ${userId}`);

    const [data, total] = await this.searchHistoryRepo.findAndCount({
      where: { userId },
      order: { createdAt: 'DESC' },
      skip: (page - 1) * limit,
      take: limit,
    });

    const totalPages = Math.ceil(total / limit);

    return {
      data,
      meta: {
        total,
        page,
        limit,
        totalPages,
      },
    };
  }

  async clearHistory(userId: number) {
    this.logger.log(`Clearing search history for user ${userId}`);

    const result = await this.searchHistoryRepo.delete({ userId });

    return {
      message: 'Search history cleared successfully',
      deletedCount: result.affected || 0,
    };
  }

  private async searchByEntityType(
    query: string,
    entityType: SearchEntityType,
    userId: number,
    page: number,
    limit: number,
  ) {
    const qb = this.searchIndexRepo.createQueryBuilder('si');

    qb.where('si.entity_type = :entityType', { entityType }).andWhere(
      new Brackets((wb) => {
        wb.where('si.title LIKE :search', { search: `%${query}%` })
          .orWhere('si.content LIKE :search', { search: `%${query}%` })
          .orWhere('si.keywords LIKE :search', { search: `%${query}%` });
      }),
    );

    qb.orderBy('si.created_at', 'DESC');

    const total = await qb.getCount();
    const data = await qb
      .skip((page - 1) * limit)
      .take(limit)
      .getMany();

    await this.recordHistory(userId, query, { entityType } as any, total);

    const totalPages = Math.ceil(total / limit);

    return {
      data,
      meta: {
        total,
        page,
        limit,
        totalPages,
      },
    };
  }

  private async recordHistory(
    userId: number,
    query: string,
    filters: Record<string, any>,
    resultsCount: number,
  ) {
    try {
      const history = this.searchHistoryRepo.create({
        userId,
        searchQuery: query,
        searchFilters: JSON.stringify(filters),
        resultsCount,
      });
      await this.searchHistoryRepo.save(history);
    } catch (error) {
      this.logger.error(`Failed to record search history: ${error.message}`, error.stack);
    }
  }
}
