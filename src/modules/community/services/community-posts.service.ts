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
import { CommunityTag } from '../entities/community-tag.entity';
import { CommunityPostView } from '../entities/community-post-view.entity';
import {
  CreatePostDto,
  UpdatePostDto,
  PostQueryDto,
  CreateCommentDto,
  CreateReactionDto,
} from '../dto';
import { PostNotFoundException, CommentNotFoundException } from '../exceptions';
import { NotificationType, NotificationPriority } from '../../notifications/enums';
import { NotificationsService } from '../../notifications/services/notifications.service';

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
    @InjectRepository(CommunityTag)
    private tagRepository: Repository<CommunityTag>,
    @InjectRepository(CommunityPostView)
    private postViewRepository: Repository<CommunityPostView>,
    private notificationsService: NotificationsService,
  ) {}

  /**
   * List posts with filtering and pagination
   */
  async findAll(query: PostQueryDto) {
    const { communityId, postType, tag, sortBy = 'recent', page = 1, limit = 20 } = query;

    const qb = this.postRepository.createQueryBuilder('p')
      .leftJoinAndSelect('p.author', 'author')
      .leftJoinAndSelect('p.community', 'community')
      .leftJoinAndSelect('p.tags', 'tags');

    if (communityId) {
      qb.andWhere('p.communityId = :communityId', { communityId });
    }
    if (postType) {
      qb.andWhere('p.postType = :postType', { postType });
    }
    if (tag) {
      qb.andWhere('tags.name = :tag', { tag: tag.toLowerCase().trim() });
    }

    // Sorting: pinned posts always first
    qb.orderBy('p.isPinned', 'DESC');

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
  async findOne(id: number, userId?: number, page = 1, limit = 50): Promise<any> {
    const post = await this.postRepository.findOne({
      where: { id },
      relations: ['author', 'community', 'tags'],
    });

    if (!post) {
      throw new PostNotFoundException(id);
    }

    // Increment view count logically
    if (userId) {
      const existingView = await this.postViewRepository.findOne({ where: { postId: id, userId } });
      if (!existingView) {
        await this.postViewRepository.save(this.postViewRepository.create({ postId: id, userId }));
        await this.postRepository.increment({ id }, 'viewCount', 1);
        post.viewCount++;
      }
    }

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
    // Handle tags
    let tags: CommunityTag[] = [];
    if (dto.tags && dto.tags.length > 0) {
      tags = await this.findOrCreateTags(dto.tags);
    }

    const post = this.postRepository.create({
      title: dto.title,
      content: dto.content,
      communityId: dto.communityId,
      postType: dto.postType,
      userId,
      tags,
    });

    const saved = await this.postRepository.save(post);
    this.logger.log(`Post ${saved.id} created by user ${userId} in community ${dto.communityId}`);

    const result = await this.postRepository.findOne({
      where: { id: saved.id },
      relations: ['author', 'community', 'tags'],
    });
    return result!;
  }

  /**
   * Find or create tags by name
   */
  private async findOrCreateTags(names: string[]): Promise<CommunityTag[]> {
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
      relations: ['author', 'community', 'tags'],
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

    if (dto.parentCommentId) {
      const parentComment = await this.commentRepository.findOne({
        where: { id: dto.parentCommentId, postId },
      });
      if (!parentComment) {
        throw new BadRequestException(`Parent comment with ID ${dto.parentCommentId} not found in this post`);
      }
    }

    const comment = this.commentRepository.create({
      postId,
      userId,
      commentText: dto.commentText,
      parentCommentId: dto.parentCommentId,
    });

    const saved = await this.commentRepository.save(comment);
    await this.postRepository.increment({ id: postId }, 'replyCount', 1);

    this.logger.log(`Comment ${saved.id} added to post ${postId} by user ${userId}`);

    const result = await this.commentRepository.findOne({
      where: { id: saved.id },
      relations: ['author'],
    });

    // Notify post author if not the same person
    if (Number(post.userId) !== Number(userId)) {
      await this.notificationsService.createNotification({
        userId: post.userId,
        notificationType: NotificationType.COMMUNITY,
        title: 'New Comment on Your Post',
        body: `Someone commented on your post: "${post.title.substring(0, 30)}..."`,
        relatedEntityType: 'community_post',
        relatedEntityId: postId,
        priority: NotificationPriority.LOW,
        actionUrl: `/community/posts/${postId}`,
      });
    }

    // Notify parent comment author if reply and not the same person
    if (dto.parentCommentId) {
      const parentComment = await this.commentRepository.findOne({ where: { id: dto.parentCommentId } });
      if (parentComment && Number(parentComment.userId) !== Number(userId) && Number(parentComment.userId) !== Number(post.userId)) {
        await this.notificationsService.createNotification({
          userId: parentComment.userId,
          notificationType: NotificationType.COMMUNITY,
          title: 'New Reply to Your Comment',
          body: `Someone replied to your comment on post: "${post.title.substring(0, 30)}..."`,
          relatedEntityType: 'community_post',
          relatedEntityId: postId,
          priority: NotificationPriority.LOW,
          actionUrl: `/community/posts/${postId}`,
        });
      }
    }

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

    const existingReaction = await this.reactionRepository.findOne({
      where: { postId, userId, reactionType: dto.reactionType },
    });

    if (existingReaction) {
      await this.reactionRepository.remove(existingReaction);
      await this.postRepository.decrement({ id: postId }, 'upvoteCount', 1);
      this.logger.log(`Reaction ${dto.reactionType} removed from post ${postId} by user ${userId}`);
      return { action: 'removed', reactionType: dto.reactionType };
    } else {
      const reaction = this.reactionRepository.create({
        postId,
        userId,
        reactionType: dto.reactionType,
      });
      await this.reactionRepository.save(reaction);
      await this.postRepository.increment({ id: postId }, 'upvoteCount', 1);
      this.logger.log(`Reaction ${dto.reactionType} added to post ${postId} by user ${userId}`);

      // Notify post author if not the same person
      if (Number(post.userId) !== Number(userId)) {
        await this.notificationsService.createNotification({
          userId: post.userId,
          notificationType: NotificationType.COMMUNITY,
          title: 'Post Reacted To',
          body: `Your post "${post.title.substring(0, 30)}..." received a ${dto.reactionType} reaction.`,
          relatedEntityType: 'community_post',
          relatedEntityId: postId,
          priority: NotificationPriority.LOW,
          actionUrl: `/community/posts/${postId}`,
        });
      }

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
      relations: ['author', 'community', 'tags'],
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
      relations: ['author', 'community', 'tags'],
    });
    return result!;
  }
}
