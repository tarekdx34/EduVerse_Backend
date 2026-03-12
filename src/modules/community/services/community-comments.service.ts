import {
  Injectable,
  Logger,
  ForbiddenException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CommunityComment } from '../entities/community-comment.entity';
import { CommunityPost } from '../entities/community-post.entity';
import { UpdateCommentDto } from '../dto';
import { CommentNotFoundException, PostNotFoundException } from '../exceptions';

@Injectable()
export class CommunityCommentsService {
  private readonly logger = new Logger(CommunityCommentsService.name);

  constructor(
    @InjectRepository(CommunityComment)
    private commentRepository: Repository<CommunityComment>,
    @InjectRepository(CommunityPost)
    private postRepository: Repository<CommunityPost>,
  ) {}

  /**
   * Update a comment (owner only)
   */
  async update(id: number, dto: UpdateCommentDto, userId: number): Promise<CommunityComment> {
    const comment = await this.commentRepository.findOne({
      where: { id },
      relations: ['author'],
    });

    if (!comment) {
      throw new CommentNotFoundException(id);
    }

    const isOwner = Number(comment.userId) === Number(userId);
    if (!isOwner) {
      throw new ForbiddenException('You can only update your own comments');
    }

    comment.commentText = dto.commentText;
    const saved = await this.commentRepository.save(comment);
    
    this.logger.log(`Comment ${id} updated by user ${userId}`);

    const result = await this.commentRepository.findOne({
      where: { id: saved.id },
      relations: ['author'],
    });
    return result!;
  }

  /**
   * Delete a comment (owner or admin)
   */
  async remove(id: number, userId: number, roles: string[]): Promise<void> {
    const comment = await this.commentRepository.findOne({ where: { id } });

    if (!comment) {
      throw new CommentNotFoundException(id);
    }

    const isOwner = Number(comment.userId) === Number(userId);
    const isAdmin = roles.includes('admin') || roles.includes('it_admin');

    if (!isOwner && !isAdmin) {
      throw new ForbiddenException('You can only delete your own comments');
    }

    // Decrement reply count on the post
    await this.postRepository.decrement({ id: comment.postId }, 'replyCount', 1);

    await this.commentRepository.remove(comment);
    this.logger.log(`Comment ${id} deleted by user ${userId}`);
  }

  /**
   * Get comments for a post
   */
  async findByPost(postId: number, page = 1, limit = 50) {
    const [data, total] = await this.commentRepository.findAndCount({
      where: { postId },
      relations: ['author', 'parentComment'],
      order: { createdAt: 'ASC' },
      skip: (page - 1) * limit,
      take: limit,
    });

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
}
