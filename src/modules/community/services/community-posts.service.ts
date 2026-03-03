import {
  Injectable,
  Logger,
  ForbiddenException,
  BadRequestException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CommunityPost } from '../entities/community-post.entity';
import { CommunityComment } from '../entities/community-comment.entity';
import { CommunityReaction } from '../entities/community-reaction.entity';
import {
  CreatePostDto,
  UpdatePostDto,
  PostQueryDto,
  CreateCommentDto,
  CreateReactionDto,
} from '../dto';
import { PostNotFoundException, CommentNotFoundException } from '../exceptions';

@Injectable()
export class CommunityPostsService {
  private readonly logger = new Logger(CommunityPostsService.name);

  constructor(
    @InjectRepository(CommunityPost)
    private postRepository: Repository<CommunityPost>,
    @InjectRepository(CommunityComment)
    private commentRepository: Repository<CommunityComment>,
    @InjectRepository(CommunityReaction)
    private reactionRepository: Repository<CommunityReaction>,
  ) {}

  /**
   * List posts with filtering and pagination
   */
  async findAll(query: PostQueryDto) {
    const { courseId, postType, sortBy = 'recent', page = 1, limit = 20 } = query;

    const qb = this.postRepository.createQueryBuilder('p')
      .leftJoinAndSelect('p.author', 'author')
      .leftJoinAndSelect('p.course', 'course');

    // Apply filters
    if (courseId) {
      qb.andWhere('p.courseId = :courseId', { courseId });
    }
    if (postType) {
      qb.andWhere('p.postType = :postType', { postType });
    }

    // Sorting: pinned posts always first
    qb.orderBy('p.isPinned', 'DESC');

    // Apply sort order
    switch (sortBy) {
      case 'popular':
        qb.addOrderBy('p.upvoteCount', 'DESC');
        break;
      case 'most_comments':
        qb.addOrderBy('p.replyCount', 'DESC');
        break;
      case 'recent':
      default:
        qb.addOrderBy('p.createdAt', 'DESC');
        break;
    }

    qb.skip((page - 1) * limit).take(limit);

    const [data, total] = await qb.getManyAndCount();

    return {
      data,
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  /**
   * Get a single post with comments
   */
  async findOne(id: number, page = 1, limit = 50): Promise<any> {
    const post = await this.postRepository.findOne({
      where: { id },
      relations: ['author', 'course'],
    });

    if (!post) {
      throw new PostNotFoundException(id);
    }

    // Increment view count
    await this.postRepository.increment({ id }, 'viewCount', 1);
    post.viewCount++;

    // Get comments (paginated)
    const [comments, commentTotal] = await this.commentRepository.findAndCount({
      where: { postId: id },
      relations: ['author', 'parentComment'],
      order: { createdAt: 'ASC' },
      skip: (page - 1) * limit,
      take: limit,
    });

    // Get reactions summary
    const reactions = await this.getReactionSummary(id);

    return {
      post,
      comments: {
        data: comments,
        meta: {
          total: commentTotal,
          page,
          limit,
          totalPages: Math.ceil(commentTotal / limit),
        },
      },
      reactions,
    };
  }

  /**
   * Get reaction summary for a post
   */
  private async getReactionSummary(postId: number) {
    const result = await this.reactionRepository
      .createQueryBuilder('r')
      .select('r.reactionType', 'type')
      .addSelect('COUNT(*)', 'count')
      .where('r.postId = :postId', { postId })
      .groupBy('r.reactionType')
      .getRawMany();

    return result.reduce((acc, item) => {
      acc[item.type] = parseInt(item.count, 10);
      return acc;
    }, {});
  }

  /**
   * Create a new post
   */
  async create(dto: CreatePostDto, userId: number): Promise<CommunityPost> {
    const post = this.postRepository.create({
      ...dto,
      userId,
    });

    const saved = await this.postRepository.save(post);
    this.logger.log(`Post ${saved.id} created by user ${userId}`);

    // Reload with relations
    const result = await this.postRepository.findOne({
      where: { id: saved.id },
      relations: ['author', 'course'],
    });
    return result!;
  }

  /**
   * Update a post (owner only)
   */
  async update(id: number, dto: UpdatePostDto, userId: number, roles: string[]): Promise<CommunityPost> {
    const post = await this.postRepository.findOne({ where: { id } });
    
    if (!post) {
      throw new PostNotFoundException(id);
    }

    const isOwner = Number(post.userId) === Number(userId);
    if (!isOwner) {
      throw new ForbiddenException('You can only update your own posts');
    }

    Object.assign(post, dto);
    const saved = await this.postRepository.save(post);
    this.logger.log(`Post ${id} updated by user ${userId}`);

    const result = await this.postRepository.findOne({
      where: { id: saved.id },
      relations: ['author', 'course'],
    });
    return result!;
  }

  /**
   * Delete a post (owner or admin)
   */
  async remove(id: number, userId: number, roles: string[]): Promise<void> {
    const post = await this.postRepository.findOne({ where: { id } });
    
    if (!post) {
      throw new PostNotFoundException(id);
    }

    const isOwner = Number(post.userId) === Number(userId);
    const isAdmin = roles.includes('admin') || roles.includes('it_admin');

    if (!isOwner && !isAdmin) {
      throw new ForbiddenException('You can only delete your own posts');
    }

    await this.postRepository.remove(post);
    this.logger.log(`Post ${id} deleted by user ${userId}`);
  }

  /**
   * Add a comment to a post
   */
  async addComment(postId: number, dto: CreateCommentDto, userId: number): Promise<CommunityComment> {
    const post = await this.postRepository.findOne({ where: { id: postId } });
    
    if (!post) {
      throw new PostNotFoundException(postId);
    }

    if (post.isLocked) {
      throw new BadRequestException('This post is locked and cannot receive new comments');
    }

    const comment = this.commentRepository.create({
      postId,
      userId,
      commentText: dto.commentText,
      parentCommentId: dto.parentCommentId,
    });

    const saved = await this.commentRepository.save(comment);

    // Update reply count
    await this.postRepository.increment({ id: postId }, 'replyCount', 1);

    this.logger.log(`Comment ${saved.id} added to post ${postId} by user ${userId}`);

    const result = await this.commentRepository.findOne({
      where: { id: saved.id },
      relations: ['author'],
    });
    return result!;
  }

  /**
   * Toggle reaction on a post
   */
  async toggleReaction(postId: number, dto: CreateReactionDto, userId: number) {
    const post = await this.postRepository.findOne({ where: { id: postId } });
    
    if (!post) {
      throw new PostNotFoundException(postId);
    }

    // Check if reaction exists
    const existingReaction = await this.reactionRepository.findOne({
      where: { postId, userId, reactionType: dto.reactionType },
    });

    if (existingReaction) {
      // Remove reaction
      await this.reactionRepository.remove(existingReaction);
      await this.postRepository.decrement({ id: postId }, 'upvoteCount', 1);
      
      this.logger.log(`Reaction ${dto.reactionType} removed from post ${postId} by user ${userId}`);
      return { action: 'removed', reactionType: dto.reactionType };
    } else {
      // Add reaction
      const reaction = this.reactionRepository.create({
        postId,
        userId,
        reactionType: dto.reactionType,
      });
      await this.reactionRepository.save(reaction);
      await this.postRepository.increment({ id: postId }, 'upvoteCount', 1);
      
      this.logger.log(`Reaction ${dto.reactionType} added to post ${postId} by user ${userId}`);
      return { action: 'added', reactionType: dto.reactionType };
    }
  }

  /**
   * Toggle pin status (instructor/admin only)
   */
  async togglePin(id: number, userId: number, roles: string[]): Promise<CommunityPost> {
    const post = await this.postRepository.findOne({ where: { id } });
    
    if (!post) {
      throw new PostNotFoundException(id);
    }

    const isAdmin = roles.includes('admin') || roles.includes('it_admin');
    const isInstructor = roles.includes('instructor');

    if (!isAdmin && !isInstructor) {
      throw new ForbiddenException('Only instructors and admins can pin posts');
    }

    post.isPinned = !post.isPinned;
    const saved = await this.postRepository.save(post);
    
    this.logger.log(`Post ${id} ${saved.isPinned ? 'pinned' : 'unpinned'} by user ${userId}`);

    const result = await this.postRepository.findOne({
      where: { id: saved.id },
      relations: ['author', 'course'],
    });
    return result!;
  }

  /**
   * Toggle lock status (instructor/admin only)
   */
  async toggleLock(id: number, userId: number, roles: string[]): Promise<CommunityPost> {
    const post = await this.postRepository.findOne({ where: { id } });
    
    if (!post) {
      throw new PostNotFoundException(id);
    }

    const isAdmin = roles.includes('admin') || roles.includes('it_admin');
    const isInstructor = roles.includes('instructor');

    if (!isAdmin && !isInstructor) {
      throw new ForbiddenException('Only instructors and admins can lock posts');
    }

    post.isLocked = !post.isLocked;
    const saved = await this.postRepository.save(post);
    
    this.logger.log(`Post ${id} ${saved.isLocked ? 'locked' : 'unlocked'} by user ${userId}`);

    const result = await this.postRepository.findOne({
      where: { id: saved.id },
      relations: ['author', 'course'],
    });
    return result!;
  }
}
