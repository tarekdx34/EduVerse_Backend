import { Injectable, Logger, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Notification } from '../entities/notification.entity';
import { NotificationPreference } from '../entities/notification-preference.entity';
import { ScheduledNotification } from '../entities/scheduled-notification.entity';
import {
  CreateNotificationDto,
  SendNotificationDto,
  NotificationQueryDto,
  UpdatePreferencesDto,
} from '../dto';

@Injectable()
export class NotificationsService {
  private readonly logger = new Logger(NotificationsService.name);

  constructor(
    @InjectRepository(Notification)
    private notificationRepository: Repository<Notification>,
    @InjectRepository(NotificationPreference)
    private preferenceRepository: Repository<NotificationPreference>,
    @InjectRepository(ScheduledNotification)
    private scheduledRepository: Repository<ScheduledNotification>,
  ) {}

  // ============ NOTIFICATIONS ============

  async findAll(userId: number, query: NotificationQueryDto) {
    const { type, priority, isRead, page = 1, limit = 20 } = query;
    const qb = this.notificationRepository.createQueryBuilder('n')
      .where('n.userId = :userId', { userId });

    if (type) qb.andWhere('n.notificationType = :type', { type });
    if (priority) qb.andWhere('n.priority = :priority', { priority });
    if (isRead !== undefined) qb.andWhere('n.isRead = :isRead', { isRead: isRead ? 1 : 0 });

    qb.orderBy('n.createdAt', 'DESC')
      .skip((page - 1) * limit)
      .take(limit);

    const [data, total] = await qb.getManyAndCount();
    return { data, meta: { total, page, limit, totalPages: Math.ceil(total / limit) } };
  }

  async getUnreadCount(userId: number): Promise<{ count: number }> {
    const count = await this.notificationRepository.count({
      where: { userId, isRead: false as any },
    });
    return { count };
  }

  async markAsRead(userId: number, notificationId: number): Promise<Notification> {
    const notification = await this.notificationRepository.findOne({
      where: { id: notificationId, userId },
    });
    if (!notification) throw new NotFoundException(`Notification ${notificationId} not found`);

    notification.isRead = true;
    notification.readAt = new Date();
    return this.notificationRepository.save(notification);
  }

  async markAllAsRead(userId: number): Promise<{ affected: number }> {
    const result = await this.notificationRepository.update(
      { userId, isRead: false as any },
      { isRead: true, readAt: new Date() },
    );
    return { affected: result.affected || 0 };
  }

  async delete(userId: number, notificationId: number): Promise<void> {
    const notification = await this.notificationRepository.findOne({
      where: { id: notificationId, userId },
    });
    if (!notification) throw new NotFoundException(`Notification ${notificationId} not found`);
    await this.notificationRepository.remove(notification);
  }

  async clearAll(userId: number): Promise<{ affected: number }> {
    const result = await this.notificationRepository.delete({ userId });
    return { affected: result.affected || 0 };
  }

  // ============ PREFERENCES ============

  async getPreferences(userId: number): Promise<NotificationPreference> {
    let prefs = await this.preferenceRepository.findOne({ where: { userId } });
    if (!prefs) {
      prefs = this.preferenceRepository.create({ userId });
      prefs = await this.preferenceRepository.save(prefs);
    }
    return prefs;
  }

  async updatePreferences(userId: number, dto: UpdatePreferencesDto): Promise<NotificationPreference> {
    let prefs = await this.preferenceRepository.findOne({ where: { userId } });
    if (!prefs) {
      prefs = this.preferenceRepository.create({ userId });
    }
    Object.assign(prefs, dto);
    return this.preferenceRepository.save(prefs);
  }

  // ============ SEND (Admin/System) ============

  async send(dto: SendNotificationDto): Promise<Notification[]> {
    const notifications: Notification[] = [];
    for (const userId of dto.userIds) {
      const notification = this.notificationRepository.create({
        userId,
        notificationType: dto.notificationType,
        title: dto.title,
        body: dto.body,
        priority: dto.priority || 'medium',
        actionUrl: dto.actionUrl,
      });
      notifications.push(await this.notificationRepository.save(notification));
    }
    this.logger.log(`Sent ${notifications.length} notifications: "${dto.title}"`);
    return notifications;
  }

  // ============ CREATE (for other modules to use) ============

  async createNotification(dto: CreateNotificationDto): Promise<Notification> {
    const notification = this.notificationRepository.create({
      userId: dto.userId,
      notificationType: dto.notificationType,
      title: dto.title,
      body: dto.body,
      relatedEntityType: dto.relatedEntityType,
      relatedEntityId: dto.relatedEntityId,
      priority: dto.priority || 'medium',
      actionUrl: dto.actionUrl,
    });
    const saved = await this.notificationRepository.save(notification);
    this.logger.log(`Notification created for user ${dto.userId}: "${dto.title}"`);
    return saved;
  }
}
