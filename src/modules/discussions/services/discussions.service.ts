import { Injectable, Logger, NotFoundException, ForbiddenException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CourseChatThread } from '../entities/course-chat-thread.entity';
import { ChatMessage } from '../entities/chat-message.entity';
import { CreateThreadDto, UpdateThreadDto, CreateReplyDto, ThreadQueryDto } from '../dto';

@Injectable()
export class DiscussionsService {
  private readonly logger = new Logger(DiscussionsService.name);

  constructor(
    @InjectRepository(CourseChatThread)
    private threadRepository: Repository<CourseChatThread>,
    @InjectRepository(ChatMessage)
    private messageRepository: Repository<ChatMessage>,
  ) {}

  // ============ THREADS ============

  async findAll(query: ThreadQueryDto) {
    const { courseId, page = 1, limit = 20 } = query;
    const qb = this.threadRepository.createQueryBuilder('t');

    if (courseId) qb.andWhere('t.courseId = :courseId', { courseId });

    // Pinned threads first, then by most recent
    qb.orderBy('t.isPinned', 'DESC')
      .addOrderBy('t.updatedAt', 'DESC')
      .skip((page - 1) * limit)
      .take(limit);

    const [data, total] = await qb.getManyAndCount();
    return { data, meta: { total, page, limit, totalPages: Math.ceil(total / limit) } };
  }

  async findById(id: number): Promise<CourseChatThread> {
    const thread = await this.threadRepository.findOne({ where: { id } });
    if (!thread) throw new NotFoundException(`Discussion thread ${id} not found`);
    return thread;
  }

  async getThreadWithReplies(id: number, page = 1, limit = 50) {
    const thread = await this.findById(id);

    // Increment view count
    await this.threadRepository.increment({ id }, 'viewCount', 1);
    thread.viewCount++;

    // Get replies (paginated, answers first)
    const qb = this.messageRepository
      .createQueryBuilder('m')
      .where('m.threadId = :threadId', { threadId: id })
      .orderBy('m.isAnswer', 'DESC')
      .addOrderBy('m.createdAt', 'ASC')
      .skip((page - 1) * limit)
      .take(limit);

    const [replies, total] = await qb.getManyAndCount();

    return {
      thread,
      replies: {
        data: replies,
        meta: { total, page, limit, totalPages: Math.ceil(total / limit) },
      },
    };
  }

  async create(dto: CreateThreadDto, userId: number): Promise<CourseChatThread> {
    const thread = this.threadRepository.create({
      courseId: dto.courseId,
      createdBy: userId,
      title: dto.title,
      description: dto.description,
    });
    const saved = await this.threadRepository.save(thread);
    this.logger.log(`Thread ${saved.id} created by user ${userId}`);
    return saved;
  }

  async update(id: number, dto: UpdateThreadDto, userId: number, userRoles: string[]): Promise<CourseChatThread> {
    const thread = await this.findById(id);
    const isAuthor = Number(thread.createdBy) === Number(userId);
    const isPrivileged = userRoles.some((r) => ['admin', 'instructor', 'it_admin'].includes(r));

    if (!isAuthor && !isPrivileged) {
      throw new ForbiddenException('Only the thread author or instructors/admins can update this thread');
    }

    if (dto.title) thread.title = dto.title;
    if (dto.description !== undefined) thread.description = dto.description;

    return this.threadRepository.save(thread);
  }

  async remove(id: number): Promise<void> {
    const thread = await this.findById(id);
    await this.threadRepository.remove(thread);
    this.logger.log(`Thread ${id} deleted`);
  }

  // ============ REPLIES ============

  async addReply(threadId: number, userId: number, dto: CreateReplyDto): Promise<ChatMessage> {
    const thread = await this.findById(threadId);
    if (thread.isLocked) {
      throw new BadRequestException('This thread is locked and cannot receive new replies');
    }

    const reply = this.messageRepository.create({
      threadId,
      userId,
      messageText: dto.messageText,
      parentMessageId: dto.parentMessageId,
    });
    const saved = await this.messageRepository.save(reply);

    // Update reply count
    await this.threadRepository.increment({ id: threadId }, 'replyCount', 1);

    this.logger.log(`Reply ${saved.id} added to thread ${threadId} by user ${userId}`);
    return saved;
  }

  // ============ PIN / LOCK ============

  async togglePin(id: number): Promise<CourseChatThread> {
    const thread = await this.findById(id);
    thread.isPinned = !thread.isPinned;
    const saved = await this.threadRepository.save(thread);
    this.logger.log(`Thread ${id} ${saved.isPinned ? 'pinned' : 'unpinned'}`);
    return saved;
  }

  async toggleLock(id: number): Promise<CourseChatThread> {
    const thread = await this.findById(id);
    thread.isLocked = !thread.isLocked;
    const saved = await this.threadRepository.save(thread);
    this.logger.log(`Thread ${id} ${saved.isLocked ? 'locked' : 'unlocked'}`);
    return saved;
  }

  // ============ MARK ANSWER / ENDORSE ============

  async markAnswer(replyId: number): Promise<ChatMessage> {
    const reply = await this.messageRepository.findOne({ where: { id: replyId } });
    if (!reply) throw new NotFoundException(`Reply ${replyId} not found`);

    reply.isAnswer = !reply.isAnswer;
    const saved = await this.messageRepository.save(reply);
    this.logger.log(`Reply ${replyId} ${saved.isAnswer ? 'marked' : 'unmarked'} as answer`);
    return saved;
  }

  async endorseReply(replyId: number, endorserId: number): Promise<ChatMessage> {
    const reply = await this.messageRepository.findOne({ where: { id: replyId } });
    if (!reply) throw new NotFoundException(`Reply ${replyId} not found`);

    reply.isEndorsed = !reply.isEndorsed;
    reply.endorsedBy = reply.isEndorsed ? endorserId : null;
    const saved = await this.messageRepository.save(reply);
    this.logger.log(`Reply ${replyId} ${saved.isEndorsed ? 'endorsed' : 'unendorsed'} by user ${endorserId}`);
    return saved;
  }
}
