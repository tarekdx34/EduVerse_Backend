import { Injectable, Logger, NotFoundException, ForbiddenException, BadRequestException, Inject, forwardRef } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CourseChatThread } from '../entities/course-chat-thread.entity';
import { ChatMessage } from '../entities/chat-message.entity';
import { CreateThreadDto, UpdateThreadDto, CreateReplyDto, ThreadQueryDto } from '../dto';
import { CourseChatThreadView } from '../entities/course-chat-thread-view.entity';
import { ChatMessageUpvote } from '../entities/chat-message-upvote.entity';
import { NotificationType, NotificationPriority } from '../../notifications/enums';
import { NotificationsService } from '../../notifications/services/notifications.service';

@Injectable()
export class DiscussionsService {
  private readonly logger = new Logger(DiscussionsService.name);

  constructor(
    @InjectRepository(CourseChatThread)
    private threadRepository: Repository<CourseChatThread>,
    @InjectRepository(ChatMessage)
    private messageRepository: Repository<ChatMessage>,
    @InjectRepository(CourseChatThreadView)
    private threadViewRepository: Repository<CourseChatThreadView>,
    @InjectRepository(ChatMessageUpvote)
    private messageUpvoteRepository: Repository<ChatMessageUpvote>,
    private notificationsService: NotificationsService,
  ) {}

  // ============ ENROLLMENT CHECK ============

  /**
   * Validate user has access to a course's discussions.
   * Admin/IT_Admin and Instructor/TA are always allowed.
   * Students must be enrolled in the course via course_enrollments.
   */
  private async validateCourseAccess(courseId: number, userId: number, roles: string[]): Promise<void> {
    const isAdmin = roles.includes('admin') || roles.includes('it_admin');
    const isStaff = roles.includes('instructor') || roles.includes('teaching_assistant');

    if (isAdmin || isStaff) return;

    const enrollment = await this.threadRepository.manager.query(
      `SELECT 1 FROM course_enrollments ce
       JOIN course_sections cs ON ce.section_id = cs.section_id
       WHERE ce.user_id = ? AND cs.course_id = ? AND ce.enrollment_status = 'enrolled'
       LIMIT 1`,
      [userId, courseId],
    );

    if (!enrollment || enrollment.length === 0) {
      throw new ForbiddenException('You must be enrolled in this course to access its discussions');
    }
  }

  // ============ THREADS ============

  async findAll(query: ThreadQueryDto, userId: number, roles: string[]) {
    const { courseId, page = 1, limit = 20 } = query;

    if (courseId) {
      await this.validateCourseAccess(courseId, userId, roles);
    }

    const qb = this.threadRepository.createQueryBuilder('t')
      .leftJoinAndSelect('t.course', 'course')
      .leftJoinAndSelect('t.creator', 'creator');

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

  async getThreadWithReplies(id: number, userId: number, roles: string[], page = 1, limit = 50) {
    const thread = await this.findById(id);
    await this.validateCourseAccess(thread.courseId, userId, roles);

    // Increment view count logically
    const existingView = await this.threadViewRepository.findOne({ where: { threadId: id, userId } });
    if (!existingView) {
      await this.threadViewRepository.save(this.threadViewRepository.create({ threadId: id, userId }));
      await this.threadRepository.increment({ id }, 'viewCount', 1);
      thread.viewCount++;
    }

    // Get replies (paginated, answers first)
    const qb = this.messageRepository
      .createQueryBuilder('m')
      .leftJoinAndSelect('m.user', 'user')
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

  async create(dto: CreateThreadDto, userId: number, roles: string[]): Promise<CourseChatThread> {
    await this.validateCourseAccess(dto.courseId, userId, roles);
    const thread = this.threadRepository.create({
      courseId: dto.courseId,
      createdBy: userId,
      title: dto.title,
      description: dto.description,
    });
    const saved = await this.threadRepository.save(thread);
    this.logger.log(`Thread ${saved.id} created by user ${userId}`);

    const staffIds = (await this.notificationsService.getCourseStaffUserIds(dto.courseId)).filter(
      (staffUserId) => Number(staffUserId) !== Number(userId),
    );

    if (staffIds.length) {
      await this.notificationsService.createBulkNotifications(staffIds, {
        notificationType: NotificationType.DISCUSSION,
        title: 'New Discussion Thread',
        body: `A new discussion thread "${dto.title}" was created in one of your courses.`,
        relatedEntityType: 'discussion_thread',
        relatedEntityId: saved.id,
        priority: NotificationPriority.LOW,
        actionUrl: `/courses/${dto.courseId}/discussions/${saved.id}`,
      });
    }

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

  async addReply(threadId: number, userId: number, roles: string[], dto: CreateReplyDto): Promise<ChatMessage> {
    const thread = await this.findById(threadId);
    await this.validateCourseAccess(thread.courseId, userId, roles);
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

    // Notify thread author if not the same person
    if (Number(thread.createdBy) !== Number(userId)) {
      await this.notificationsService.createNotification({
        userId: thread.createdBy,
        notificationType: NotificationType.DISCUSSION,
        title: 'New Reply in Discussion',
        body: `Someone replied to your discussion thread: "${thread.title.substring(0, 30)}..."`,
        relatedEntityType: 'discussion_thread',
        relatedEntityId: threadId,
        priority: NotificationPriority.LOW,
        actionUrl: `/courses/${thread.courseId}/discussions/${threadId}`,
      });
    }

    // Notify parent message author if reply and not the same person
    if (dto.parentMessageId) {
      const parentMessage = await this.messageRepository.findOne({ where: { id: dto.parentMessageId } });
      if (parentMessage && Number(parentMessage.userId) !== Number(userId) && Number(parentMessage.userId) !== Number(thread.createdBy)) {
        await this.notificationsService.createNotification({
          userId: parentMessage.userId,
          notificationType: NotificationType.DISCUSSION,
          title: 'New Reply to Your Message',
          body: `Someone replied to your message in: "${thread.title.substring(0, 30)}..."`,
          relatedEntityType: 'discussion_thread',
          relatedEntityId: threadId,
          priority: NotificationPriority.LOW,
          actionUrl: `/courses/${thread.courseId}/discussions/${threadId}`,
        });
      }
    }

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

  async toggleLock(id: number, actorId: number): Promise<CourseChatThread> {
    const thread = await this.findById(id);
    thread.isLocked = !thread.isLocked;
    const saved = await this.threadRepository.save(thread);
    this.logger.log(`Thread ${id} ${saved.isLocked ? 'locked' : 'unlocked'}`);

    if (saved.isLocked && Number(saved.createdBy) !== Number(actorId)) {
      await this.notificationsService.createNotification({
        userId: saved.createdBy,
        notificationType: NotificationType.DISCUSSION,
        title: 'Discussion Thread Locked',
        body: `Your discussion thread has been locked by course staff.`,
        relatedEntityType: 'discussion_thread',
        relatedEntityId: saved.id,
        priority: NotificationPriority.MEDIUM,
        actionUrl: `/courses/${saved.courseId}/discussions/${saved.id}`,
      });
    }

    return saved;
  }

  // ============ MARK ANSWER / ENDORSE ============

  async markAnswer(replyId: number): Promise<ChatMessage> {
    const reply = await this.messageRepository.findOne({
      where: { id: replyId },
      relations: ['thread'],
    });
    if (!reply) throw new NotFoundException(`Reply ${replyId} not found`);

    reply.isAnswer = !reply.isAnswer;
    const saved = await this.messageRepository.save(reply);
    this.logger.log(`Reply ${replyId} ${saved.isAnswer ? 'marked' : 'unmarked'} as answer`);

    if (saved.isAnswer && Number(saved.userId) !== Number(saved.thread?.createdBy)) {
      await this.notificationsService.createNotification({
        userId: saved.userId,
        notificationType: NotificationType.DISCUSSION,
        title: 'Reply Marked as Answer',
        body: `Your reply was marked as the correct answer in: "${saved.thread?.title.substring(0, 30)}..."`,
        relatedEntityType: 'discussion_thread',
        relatedEntityId: saved.threadId,
        priority: NotificationPriority.MEDIUM,
        actionUrl: `/courses/${saved.thread?.courseId}/discussions/${saved.threadId}`,
      });
    }

    return saved;
  }

  async endorseReply(replyId: number, endorserId: number): Promise<ChatMessage> {
    const reply = await this.messageRepository.findOne({
      where: { id: replyId },
      relations: ['thread'],
    });
    if (!reply) throw new NotFoundException(`Reply ${replyId} not found`);

    reply.isEndorsed = !reply.isEndorsed;
    reply.endorsedBy = reply.isEndorsed ? endorserId : null;
    const saved = await this.messageRepository.save(reply);
    this.logger.log(`Reply ${replyId} ${saved.isEndorsed ? 'endorsed' : 'unendorsed'} by user ${endorserId}`);

    if (saved.isEndorsed && Number(saved.userId) !== Number(endorserId)) {
      await this.notificationsService.createNotification({
        userId: saved.userId,
        notificationType: NotificationType.DISCUSSION,
        title: 'Reply Endorsed',
        body: `An instructor endorsed your reply in: "${saved.thread?.title.substring(0, 30)}..."`,
        relatedEntityType: 'discussion_thread',
        relatedEntityId: saved.threadId,
        priority: NotificationPriority.MEDIUM,
        actionUrl: `/courses/${saved.thread?.courseId}/discussions/${saved.threadId}`,
      });
    }

    return saved;
  }

  async toggleMessageUpvote(replyId: number, userId: number) {
    const reply = await this.messageRepository.findOne({
      where: { id: replyId },
      relations: ['thread'],
    });
    if (!reply) throw new NotFoundException(`Reply ${replyId} not found`);

    const existingUpvote = await this.messageUpvoteRepository.findOne({ where: { messageId: replyId, userId } });

    if (existingUpvote) {
      await this.messageUpvoteRepository.remove(existingUpvote);
      await this.messageRepository.decrement({ id: replyId }, 'upvoteCount', 1);
      this.logger.log(`Upvote removed from reply ${replyId} by user ${userId}`);
      return { action: 'removed' };
    } else {
      await this.messageUpvoteRepository.save(this.messageUpvoteRepository.create({ messageId: replyId, userId }));
      await this.messageRepository.increment({ id: replyId }, 'upvoteCount', 1);
      this.logger.log(`Upvote added to reply ${replyId} by user ${userId}`);

      // Notify reply author if not the same person
      if (Number(reply.userId) !== Number(userId)) {
        await this.notificationsService.createNotification({
          userId: reply.userId,
          notificationType: NotificationType.DISCUSSION,
          title: 'Reply Upvoted',
          body: `Someone upvoted your reply in a discussion.`,
          relatedEntityType: 'discussion_thread',
          relatedEntityId: reply.threadId,
          priority: NotificationPriority.LOW,
          actionUrl: `/courses/${reply.thread?.courseId}/discussions/${reply.threadId}`,
        });
      }

      return { action: 'added' };
    }
  }
}
