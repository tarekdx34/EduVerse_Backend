import { Injectable, Logger, NotFoundException, ForbiddenException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, IsNull, Not, In } from 'typeorm';
import { Message } from '../entities/message.entity';
import { MessageParticipant } from '../entities/message-participant.entity';
import {
  StartConversationDto,
  SendMessageDto,
  MessageQueryDto,
  SearchMessagesDto,
} from '../dto';

const DELETED_MARKER = '__DELETED__';

@Injectable()
export class MessagingService {
  private readonly logger = new Logger(MessagingService.name);

  // Track online users: userId -> Set<socketId>
  private onlineUsers = new Map<number, Set<string>>();

  constructor(
    @InjectRepository(Message)
    private messageRepository: Repository<Message>,
    @InjectRepository(MessageParticipant)
    private participantRepository: Repository<MessageParticipant>,
  ) {}

  // ============ CONVERSATIONS ============

  async listConversations(userId: number) {
    // Find all root messages (conversations) where user is a participant
    const rootParticipations = await this.participantRepository
      .createQueryBuilder('mp')
      .innerJoin('mp.message', 'm')
      .where('mp.userId = :userId', { userId })
      .andWhere('m.parentMessageId IS NULL')
      .andWhere('mp.deletedAt IS NULL')
      .select('m.message_id', 'conversationId')
      .getRawMany();

    const conversationIds = rootParticipations.map((r) => r.conversationId);
    if (conversationIds.length === 0) return [];

    const conversations: Array<any> = [];
    for (const convId of conversationIds) {
      const conv = await this.getConversationSummary(convId, userId);
      if (conv) conversations.push(conv);
    }

    // Sort by last message time descending
    conversations.sort((a, b) => new Date(b.lastMessageAt).getTime() - new Date(a.lastMessageAt).getTime());
    return conversations;
  }

  private async getConversationSummary(conversationId: number, userId: number) {
    const rootMessage = await this.messageRepository.findOne({
      where: { id: conversationId },
      relations: ['participants'],
    });
    if (!rootMessage) return null;

    // Get all participants with user info
    const participants = await this.participantRepository
      .createQueryBuilder('mp')
      .where('mp.messageId = :messageId', { messageId: conversationId })
      .select(['mp.userId'])
      .getMany();

    // Get last message in conversation (not deleted for this user)
    const lastMessage = await this.messageRepository
      .createQueryBuilder('m')
      .leftJoin('message_participants', 'mp', 'mp.message_id = m.message_id AND mp.user_id = :userId', { userId })
      .where('(m.message_id = :convId OR m.parent_message_id = :convId)', { convId: conversationId })
      .andWhere('(mp.deleted_at IS NULL OR mp.participant_id IS NULL)')
      .orderBy('m.sent_at', 'DESC')
      .getOne();

    // Count unread messages
    const unreadCount = await this.participantRepository
      .createQueryBuilder('mp')
      .innerJoin('mp.message', 'm')
      .where('mp.userId = :userId', { userId })
      .andWhere('(m.message_id = :convId OR m.parentMessageId = :convId)', { convId: conversationId })
      .andWhere('mp.readAt IS NULL')
      .andWhere('mp.deletedAt IS NULL')
      .andWhere('m.senderId != :userId', { userId })
      .getCount();

    const lastBody = lastMessage?.body === DELETED_MARKER
      ? 'This message was deleted'
      : (lastMessage?.body || rootMessage.body);

    return {
      conversationId,
      type: rootMessage.messageType,
      name: rootMessage.messageType === 'group' ? rootMessage.subject : null,
      participants: participants.map((p) => p.userId),
      lastMessage: lastBody,
      lastMessageAt: lastMessage?.sentAt || rootMessage.sentAt,
      lastSenderId: lastMessage?.senderId || rootMessage.senderId,
      unreadCount,
    };
  }

  async startConversation(senderId: number, dto: StartConversationDto): Promise<any> {
    const { participantIds, type, groupName, text, fileId } = dto;

    // For direct messages, check if conversation already exists between these 2 users
    if (type === 'direct') {
      if (participantIds.length !== 1) {
        throw new BadRequestException('Direct messages must have exactly one participant');
      }
      const existing = await this.findExistingDirectConversation(senderId, participantIds[0]);
      if (existing) {
        // Conversation exists, send message there instead
        const msg = await this.sendMessage(existing, senderId, { text, fileId });
        return { conversationId: existing, message: msg, existing: true };
      }
    }

    // Create root message (conversation)
    const rootMessage = this.messageRepository.create({
      senderId,
      subject: type === 'group' ? (groupName || 'Group Chat') : null,
      body: text,
      messageType: type,
      readStatus: false,
    });

    // Store file metadata in subject for non-group root messages
    if (fileId && type !== 'group') {
      rootMessage.subject = JSON.stringify({ fileId });
    } else if (fileId && type === 'group') {
      // For group, store file in body metadata
      rootMessage.body = text;
    }

    const saved = await this.messageRepository.save(rootMessage);

    // Add all participants (including sender)
    const allParticipantIds = [senderId, ...participantIds.filter((id) => id !== senderId)];
    for (const uid of allParticipantIds) {
      const participant = this.participantRepository.create({
        messageId: saved.id,
        userId: uid,
        readAt: uid === senderId ? new Date() : null,
      } as any);
      await this.participantRepository.save(participant);
    }

    this.logger.log(`Conversation ${saved.id} created by user ${senderId} (${type})`);
    return { conversationId: saved.id, message: saved, existing: false };
  }

  private async findExistingDirectConversation(userA: number, userB: number): Promise<number | null> {
    // Find root messages of type 'direct' where both users are participants
    const result = await this.messageRepository
      .createQueryBuilder('m')
      .innerJoin('message_participants', 'mpA', 'mpA.message_id = m.message_id AND mpA.user_id = :userA', { userA })
      .innerJoin('message_participants', 'mpB', 'mpB.message_id = m.message_id AND mpB.user_id = :userB', { userB })
      .where('m.parent_message_id IS NULL')
      .andWhere('m.message_type = :type', { type: 'direct' })
      .select('m.message_id', 'id')
      .getRawOne();

    return result ? result.id : null;
  }

  // ============ MESSAGES ============

  async getConversationMessages(conversationId: number, userId: number, query: MessageQueryDto) {
    const { page = 1, limit = 50 } = query;

    // Verify user is a participant
    await this.verifyParticipant(conversationId, userId);

    // Get IDs of messages deleted for this user
    const deletedMessages = await this.participantRepository
      .createQueryBuilder('mp')
      .select('mp.messageId', 'messageId')
      .where('mp.userId = :userId', { userId })
      .andWhere('mp.deletedAt IS NOT NULL')
      .getRawMany();
    const deletedIds = deletedMessages.map((d) => d.messageId);

    // Get all messages in this conversation (root + replies)
    const qb = this.messageRepository
      .createQueryBuilder('m')
      .where('(m.message_id = :convId OR m.parent_message_id = :convId)', { convId: conversationId })
      .orderBy('m.sent_at', 'ASC')
      .skip((page - 1) * limit)
      .take(limit);

    if (deletedIds.length > 0) {
      qb.andWhere('m.message_id NOT IN (:...deletedIds)', { deletedIds });
    }

    const [messages, total] = await qb.getManyAndCount();

    // Enrich messages with status and file info
    const enriched = messages.map((m) => ({
      id: m.id,
      senderId: m.senderId,
      text: m.body === DELETED_MARKER ? null : m.body,
      isDeleted: m.body === DELETED_MARKER,
      deletedText: m.body === DELETED_MARKER ? 'This message was deleted' : undefined,
      fileId: this.extractFileId(m.subject, m.parentMessageId),
      replyToId: m.parentMessageId !== conversationId ? m.parentMessageId : null,
      sentAt: m.sentAt,
      status: this.getMessageStatus(m),
    }));

    return {
      data: enriched,
      meta: { total, page, limit, totalPages: Math.ceil(total / limit) },
    };
  }

  async sendMessage(conversationId: number, senderId: number, dto: SendMessageDto): Promise<any> {
    // Verify user is a participant of the root conversation
    await this.verifyParticipant(conversationId, senderId);

    const message = this.messageRepository.create({
      senderId,
      body: dto.text,
      messageType: 'direct', // child messages inherit type
      parentMessageId: conversationId,
      readStatus: false,
    });

    // Store file metadata in subject field
    if (dto.fileId) {
      message.subject = JSON.stringify({ fileId: dto.fileId });
    }

    const saved = await this.messageRepository.save(message);

    // Add sender as participant (already read)
    const senderParticipant = this.participantRepository.create({
      messageId: saved.id,
      userId: senderId,
      readAt: new Date(),
    } as any);
    await this.participantRepository.save(senderParticipant);

    // Add all other conversation participants as unread
    const rootParticipants = await this.participantRepository.find({
      where: { messageId: conversationId },
    });
    for (const p of rootParticipants) {
      if (Number(p.userId) !== Number(senderId)) {
        const participant = this.participantRepository.create({
          messageId: saved.id,
          userId: p.userId,
        } as any);
        await this.participantRepository.save(participant);
      }
    }

    return {
      id: saved.id,
      conversationId,
      senderId,
      text: saved.body,
      fileId: dto.fileId || null,
      sentAt: saved.sentAt,
      status: 'sent',
    };
  }

  // ============ READ RECEIPTS ============

  async markAsRead(messageId: number, userId: number) {
    const participant = await this.participantRepository.findOne({
      where: { messageId, userId },
    });
    if (!participant) throw new NotFoundException('Message not found');

    participant.readAt = new Date();
    await this.participantRepository.save(participant);
    return { messageId, readAt: participant.readAt };
  }

  async markConversationAsRead(conversationId: number, userId: number) {
    // Mark all unread messages in conversation as read
    const result = await this.participantRepository
      .createQueryBuilder()
      .update(MessageParticipant)
      .set({ readAt: new Date() })
      .where('userId = :userId', { userId })
      .andWhere('readAt IS NULL')
      .andWhere('messageId IN (SELECT message_id FROM messages WHERE message_id = :convId OR parent_message_id = :convId)', { convId: conversationId })
      .execute();

    return { conversationId, markedRead: result.affected || 0 };
  }

  // ============ DELETE ============

  async deleteForMe(messageId: number, userId: number) {
    const participant = await this.participantRepository.findOne({
      where: { messageId, userId },
    });
    if (!participant) throw new NotFoundException('Message not found');

    participant.deletedAt = new Date();
    await this.participantRepository.save(participant);
    return { messageId, deletedForMe: true };
  }

  async deleteForEveryone(messageId: number, senderId: number) {
    const message = await this.messageRepository.findOne({ where: { id: messageId } });
    if (!message) throw new NotFoundException('Message not found');
    if (Number(message.senderId) !== Number(senderId)) {
      throw new ForbiddenException('Only the sender can delete for everyone');
    }

    message.body = DELETED_MARKER;
    message.subject = null;
    await this.messageRepository.save(message);
    return { messageId, deletedForEveryone: true };
  }

  // ============ UNREAD COUNT ============

  async getUnreadCount(userId: number): Promise<{ count: number }> {
    const count = await this.participantRepository
      .createQueryBuilder('mp')
      .innerJoin('mp.message', 'm')
      .where('mp.userId = :userId', { userId })
      .andWhere('mp.readAt IS NULL')
      .andWhere('mp.deletedAt IS NULL')
      .andWhere('m.senderId != :userId', { userId })
      .getCount();

    return { count };
  }

  // ============ SEARCH ============

  async searchMessages(userId: number, dto: SearchMessagesDto) {
    const { query, page = 1, limit = 20 } = dto;

    // First find all conversation IDs the user participates in
    const participantConvs = await this.participantRepository
      .createQueryBuilder('mp')
      .select('DISTINCT mp.messageId', 'messageId')
      .where('mp.userId = :userId', { userId })
      .andWhere('mp.deletedAt IS NULL')
      .getRawMany();
    const messageIds = participantConvs.map((p) => p.messageId);
    if (messageIds.length === 0) {
      return { data: [], meta: { total: 0, page, limit, totalPages: 0 } };
    }

    const qb = this.messageRepository
      .createQueryBuilder('m')
      .where('(m.message_id IN (:...messageIds) OR m.parent_message_id IN (:...messageIds))', { messageIds })
      .andWhere('m.body LIKE :searchTerm', { searchTerm: `%${query}%` })
      .andWhere('m.body <> :deleted', { deleted: DELETED_MARKER })
      .orderBy('m.sent_at', 'DESC')
      .skip((page - 1) * limit)
      .take(limit);

    const [messages, total] = await qb.getManyAndCount();

    return {
      data: messages.map((m) => ({
        id: m.id,
        conversationId: m.parentMessageId || m.id,
        senderId: m.senderId,
        text: m.body,
        sentAt: m.sentAt,
      })),
      meta: { total, page, limit, totalPages: Math.ceil(total / limit) },
    };
  }

  // ============ ONLINE STATUS ============

  addOnlineUser(userId: number, socketId: string) {
    if (!this.onlineUsers.has(userId)) {
      this.onlineUsers.set(userId, new Set());
    }
    this.onlineUsers.get(userId)!.add(socketId);
  }

  removeOnlineUser(userId: number, socketId: string): boolean {
    const sockets = this.onlineUsers.get(userId);
    if (sockets) {
      sockets.delete(socketId);
      if (sockets.size === 0) {
        this.onlineUsers.delete(userId);
        return true; // User went fully offline
      }
    }
    return false;
  }

  isUserOnline(userId: number): boolean {
    return this.onlineUsers.has(userId) && this.onlineUsers.get(userId)!.size > 0;
  }

  getOnlineUserIds(): number[] {
    return Array.from(this.onlineUsers.keys());
  }

  // ============ HELPERS ============

  async getConversationParticipantIds(conversationId: number): Promise<number[]> {
    const participants = await this.participantRepository.find({
      where: { messageId: conversationId },
    });
    return participants.map((p) => p.userId);
  }

  private async verifyParticipant(conversationId: number, userId: number) {
    const participant = await this.participantRepository.findOne({
      where: { messageId: conversationId, userId },
    });
    if (!participant) {
      throw new ForbiddenException('You are not a participant of this conversation');
    }
  }

  private extractFileId(subject: string | null, parentMessageId: number): number | null {
    if (!subject || !parentMessageId) return null;
    try {
      const meta = JSON.parse(subject);
      return meta.fileId || null;
    } catch {
      return null;
    }
  }

  private getMessageStatus(message: Message): string {
    if (message.body === DELETED_MARKER) return 'deleted';
    if (message.readStatus) return 'read';
    return 'delivered';
  }
}
