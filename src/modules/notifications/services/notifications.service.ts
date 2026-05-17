import { Injectable, Logger, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, Repository } from 'typeorm';
import { createHash } from 'crypto';
import { Notification } from '../entities/notification.entity';
import { NotificationPreference } from '../entities/notification-preference.entity';
import { ScheduledNotification } from '../entities/scheduled-notification.entity';
import {
  NotificationDevicePlatform,
  NotificationDeviceToken,
} from '../entities/notification-device-token.entity';
import {
  CreateNotificationDto,
  SendNotificationDto,
  NotificationQueryDto,
  UpdatePreferencesDto,
  RegisterDeviceTokenDto,
  UnregisterDeviceTokenDto,
} from '../dto';
import { NotificationsGateway } from '../notifications.gateway';
import { FirebasePushService } from './firebase-push.service';
import { CourseEnrollment } from '../../enrollments/entities/course-enrollment.entity';
import { EnrollmentStatus } from '../../enrollments/enums';
import { CourseInstructor } from '../../enrollments/entities/course-instructor.entity';
import { CourseTA } from '../../enrollments/entities/course-ta.entity';
import { User } from '../../auth/entities/user.entity';
import { RoleName } from '../../auth/entities/role.entity';
import {
  CampusEventRegistration,
  RegistrationStatus,
} from '../../schedule/entities/campus-event-registration.entity';
import { ScheduledNotificationStatus } from '../enums';

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
    @InjectRepository(NotificationDeviceToken)
    private deviceTokenRepository: Repository<NotificationDeviceToken>,
    @InjectRepository(CourseEnrollment)
    private enrollmentRepository: Repository<CourseEnrollment>,
    @InjectRepository(CourseInstructor)
    private instructorRepository: Repository<CourseInstructor>,
    @InjectRepository(CourseTA)
    private taRepository: Repository<CourseTA>,
    @InjectRepository(User)
    private userRepository: Repository<User>,
    @InjectRepository(CampusEventRegistration)
    private campusEventRegistrationRepository: Repository<CampusEventRegistration>,
    private notificationsGateway: NotificationsGateway,
    private firebasePushService: FirebasePushService,
  ) {}

  private dedupeUserIds(userIds: number[]): number[] {
    return [
      ...new Set(
        (userIds || [])
          .map((id) => Number(id))
          .filter((id) => Number.isInteger(id) && id > 0),
      ),
    ];
  }

  private normalizeScheduledFor(scheduledFor: Date): Date {
    const normalized = new Date(scheduledFor);
    normalized.setSeconds(0, 0);
    return normalized;
  }

  private hashDeviceToken(token: string): string {
    return createHash('sha256').update(token.trim()).digest('hex');
  }

  private toDeviceTokenResponse(deviceToken: NotificationDeviceToken) {
    return {
      id: deviceToken.id,
      platform: deviceToken.platform,
      deviceId: deviceToken.deviceId,
      deviceName: deviceToken.deviceName,
      appVersion: deviceToken.appVersion,
      locale: deviceToken.locale,
      isActive: deviceToken.isActive,
      lastSeenAt: deviceToken.lastSeenAt,
      firebaseEnabled: this.firebasePushService.isEnabled(),
    };
  }

  private queuePushNotifications(notifications: Notification[]): void {
    this.dispatchPushNotifications(notifications).catch((error) => {
      this.logger.error(
        `Failed to dispatch Firebase push notifications: ${error.message}`,
      );
    });
  }

  private async dispatchPushNotifications(
    notifications: Notification[],
  ): Promise<void> {
    const savedNotifications = notifications.filter(
      (notification) => notification?.userId,
    );
    if (!savedNotifications.length || !this.firebasePushService.isEnabled()) {
      return;
    }

    const userIds = this.dedupeUserIds(
      savedNotifications.map((notification) => notification.userId),
    );
    const [preferences, deviceTokens] = await Promise.all([
      this.preferenceRepository.find({
        where: { userId: In(userIds) },
        select: ['userId', 'pushEnabled'],
      }),
      this.deviceTokenRepository.find({
        where: {
          userId: In(userIds),
          isActive: true as any,
          platform: NotificationDevicePlatform.ANDROID,
        },
      }),
    ]);

    if (!deviceTokens.length) {
      return;
    }

    const pushDisabledUserIds = new Set(
      preferences
        .filter(
          (preference) =>
            preference.pushEnabled === false ||
            Number(preference.pushEnabled) === 0,
        )
        .map((preference) => Number(preference.userId)),
    );

    const tokensByUserId = new Map<number, NotificationDeviceToken[]>();
    for (const deviceToken of deviceTokens) {
      if (pushDisabledUserIds.has(Number(deviceToken.userId))) {
        continue;
      }

      const userTokens = tokensByUserId.get(Number(deviceToken.userId)) ?? [];
      userTokens.push(deviceToken);
      tokensByUserId.set(Number(deviceToken.userId), userTokens);
    }

    const unreadCountsByUserId = new Map<number, number>();
    await Promise.all(
      [...tokensByUserId.keys()].map(async (userId) => {
        const { count } = await this.getUnreadCount(userId);
        unreadCountsByUserId.set(userId, count);
      }),
    );

    const invalidTokenHashes = new Set<string>();
    for (const notification of savedNotifications) {
      const userTokens = tokensByUserId.get(Number(notification.userId)) ?? [];
      if (!userTokens.length) {
        continue;
      }

      const result = await this.firebasePushService.sendNotification(
        userTokens,
        notification,
        unreadCountsByUserId.get(Number(notification.userId)),
      );
      result.invalidTokenHashes.forEach((tokenHash) =>
        invalidTokenHashes.add(tokenHash),
      );
    }

    if (invalidTokenHashes.size > 0) {
      await this.deviceTokenRepository.update(
        { tokenHash: In([...invalidTokenHashes]) },
        { isActive: false, lastSeenAt: new Date() } as any,
      );
    }
  }

  private async updateUnreadCountsForUsers(userIds: number[]): Promise<void> {
    const dedupedUserIds = this.dedupeUserIds(userIds);
    if (!dedupedUserIds.length) {
      return;
    }

    await Promise.all(
      dedupedUserIds.map(async (userId) => {
        const { count } = await this.getUnreadCount(userId);
        this.notificationsGateway.sendUnreadCountUpdate(userId, count);
      }),
    );
  }

  // ============ NOTIFICATIONS ============

  async findAll(userId: number, query: NotificationQueryDto) {
    const { type, priority, isRead, page = 1, limit = 20 } = query;
    const qb = this.notificationRepository
      .createQueryBuilder('n')
      .where('n.userId = :userId', { userId });

    if (type) qb.andWhere('n.notificationType = :type', { type });
    if (priority) qb.andWhere('n.priority = :priority', { priority });
    if (isRead !== undefined)
      qb.andWhere('n.isRead = :isRead', { isRead: isRead ? 1 : 0 });

    qb.orderBy('n.createdAt', 'DESC')
      .skip((page - 1) * limit)
      .take(limit);

    const [data, total] = await qb.getManyAndCount();
    return {
      data,
      meta: { total, page, limit, totalPages: Math.ceil(total / limit) },
    };
  }

  async getUnreadCount(userId: number): Promise<{ count: number }> {
    const count = await this.notificationRepository.count({
      where: { userId, isRead: false as any },
    });
    return { count };
  }

  async markAsRead(
    userId: number,
    notificationId: number,
  ): Promise<Notification> {
    const notification = await this.notificationRepository.findOne({
      where: { id: notificationId, userId },
    });
    if (!notification)
      throw new NotFoundException(`Notification ${notificationId} not found`);

    notification.isRead = true;
    notification.readAt = new Date();
    const saved = await this.notificationRepository.save(notification);

    // Update unread count via socket
    const { count } = await this.getUnreadCount(userId);
    this.notificationsGateway.sendUnreadCountUpdate(userId, count);

    return saved;
  }

  async markAllAsRead(userId: number): Promise<{ affected: number }> {
    const result = await this.notificationRepository.update(
      { userId, isRead: false as any },
      { isRead: true, readAt: new Date() },
    );
    this.notificationsGateway.sendUnreadCountUpdate(userId, 0);
    return { affected: result.affected || 0 };
  }

  async delete(userId: number, notificationId: number): Promise<void> {
    const notification = await this.notificationRepository.findOne({
      where: { id: notificationId, userId },
    });
    if (!notification)
      throw new NotFoundException(`Notification ${notificationId} not found`);
    await this.notificationRepository.remove(notification);
  }

  async clearAll(userId: number): Promise<{ affected: number }> {
    const result = await this.notificationRepository.delete({ userId });
    return { affected: result.affected || 0 };
  }

  async clearRead(userId: number): Promise<{ affected: number }> {
    const result = await this.notificationRepository.delete({
      userId,
      isRead: true as any,
    });
    return { affected: result.affected || 0 };
  }

  // ============ DEVICE TOKENS ============

  async registerDeviceToken(userId: number, dto: RegisterDeviceTokenDto) {
    const token = dto.token.trim();
    const tokenHash = this.hashDeviceToken(token);
    let deviceToken = await this.deviceTokenRepository.findOne({
      where: { tokenHash },
    });

    if (!deviceToken) {
      deviceToken = this.deviceTokenRepository.create({
        userId,
        fcmToken: token,
        tokenHash,
      });
    }

    deviceToken.userId = userId;
    deviceToken.fcmToken = token;
    deviceToken.platform = NotificationDevicePlatform.ANDROID;
    deviceToken.deviceId = dto.deviceId ?? deviceToken.deviceId ?? null;
    deviceToken.deviceName = dto.deviceName ?? deviceToken.deviceName ?? null;
    deviceToken.appVersion = dto.appVersion ?? deviceToken.appVersion ?? null;
    deviceToken.locale = dto.locale ?? deviceToken.locale ?? null;
    deviceToken.isActive = true;
    deviceToken.lastSeenAt = new Date();

    const saved = await this.deviceTokenRepository.save(deviceToken);
    return this.toDeviceTokenResponse(saved);
  }

  async unregisterDeviceToken(
    userId: number,
    dto: UnregisterDeviceTokenDto,
  ): Promise<{ affected: number }> {
    const result = await this.deviceTokenRepository.update(
      {
        userId,
        tokenHash: this.hashDeviceToken(dto.token),
      },
      {
        isActive: false,
        lastSeenAt: new Date(),
      } as any,
    );

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

  async updatePreferences(
    userId: number,
    dto: UpdatePreferencesDto,
  ): Promise<NotificationPreference> {
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
    for (const userId of this.dedupeUserIds(dto.userIds)) {
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
    this.logger.log(
      `Sent ${notifications.length} notifications: "${dto.title}"`,
    );
    this.queuePushNotifications(notifications);
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
    this.logger.log(
      `Notification created for user ${dto.userId}: "${dto.title}"`,
    );

    // Send realtime notification
    this.notificationsGateway.sendNotificationToUser(dto.userId, saved);
    const { count } = await this.getUnreadCount(dto.userId);
    this.notificationsGateway.sendUnreadCountUpdate(dto.userId, count);
    this.queuePushNotifications([saved]);

    return saved;
  }

  async createBulkNotifications(
    userIds: number[],
    dto: Omit<CreateNotificationDto, 'userId'>,
  ): Promise<Notification[]> {
    const dedupedUserIds = this.dedupeUserIds(userIds);
    if (!dedupedUserIds.length) {
      return [];
    }

    const entities = dedupedUserIds.map((userId) =>
      this.notificationRepository.create({
        userId,
        notificationType: dto.notificationType,
        title: dto.title,
        body: dto.body,
        relatedEntityType: dto.relatedEntityType,
        relatedEntityId: dto.relatedEntityId,
        priority: dto.priority || 'medium',
        actionUrl: dto.actionUrl,
      }),
    );

    // Save in chunks to avoid query length limits
    const saved = await this.notificationRepository.save(entities, {
      chunk: 50,
    });
    this.logger.log(
      `Bulk notifications created for ${saved.length} users: "${dto.title}"`,
    );

    // Send realtime updates
    for (const notification of saved) {
      this.notificationsGateway.sendNotificationToUser(
        notification.userId,
        notification,
      );
    }

    // Update unread counts asynchronously
    this.updateUnreadCountsForUsers(dedupedUserIds).catch((err) =>
      this.logger.error(`Error updating bulk unread counts: ${err.message}`),
    );
    this.queuePushNotifications(saved);

    return saved;
  }

  async getEnrolledStudentIds(courseId: number): Promise<number[]> {
    const enrollments = await this.enrollmentRepository
      .createQueryBuilder('enrollment')
      .innerJoin('enrollment.section', 'section')
      .select('enrollment.userId', 'userId')
      .where('section.courseId = :courseId', { courseId })
      .andWhere('enrollment.status = :status', {
        status: EnrollmentStatus.ENROLLED,
      })
      .getRawMany<{ userId: string }>();

    return this.dedupeUserIds(enrollments.map((row) => Number(row.userId)));
  }

  async getCourseStaffUserIds(courseId: number): Promise<number[]> {
    const [instructors, tas] = await Promise.all([
      this.instructorRepository
        .createQueryBuilder('assignment')
        .innerJoin('assignment.section', 'section')
        .select('assignment.userId', 'userId')
        .where('section.courseId = :courseId', { courseId })
        .getRawMany<{ userId: string }>(),
      this.taRepository
        .createQueryBuilder('assignment')
        .innerJoin('assignment.section', 'section')
        .select('assignment.userId', 'userId')
        .where('section.courseId = :courseId', { courseId })
        .getRawMany<{ userId: string }>(),
    ]);

    return this.dedupeUserIds([
      ...instructors.map((row) => Number(row.userId)),
      ...tas.map((row) => Number(row.userId)),
    ]);
  }

  async getCampusEventRegistrantIds(eventId: number): Promise<number[]> {
    const registrations = await this.campusEventRegistrationRepository.find({
      where: {
        eventId,
        status: RegistrationStatus.REGISTERED,
      },
      select: ['userId'],
    });

    return this.dedupeUserIds(
      registrations.map((registration) => Number(registration.userId)),
    );
  }

  async getOperationalAdminIds(): Promise<number[]> {
    const users = await this.userRepository
      .createQueryBuilder('user')
      .innerJoin('user.roles', 'role')
      .select('user.userId', 'userId')
      .where('role.roleName = :roleName', { roleName: RoleName.IT_ADMIN })
      .getRawMany<{ userId: string }>();

    return this.dedupeUserIds(users.map((row) => Number(row.userId)));
  }

  async createScheduledNotificationsIfAbsent(
    userIds: number[],
    dto: Omit<CreateNotificationDto, 'userId'>,
    scheduledFor: Date,
    createdBy?: number | null,
  ): Promise<ScheduledNotification[]> {
    const dedupedUserIds = this.dedupeUserIds(userIds);
    if (!dedupedUserIds.length) {
      return [];
    }

    const normalizedScheduledFor = this.normalizeScheduledFor(scheduledFor);
    const existingRows = await this.scheduledRepository.find({
      where: {
        userId: In(dedupedUserIds),
        notificationType: dto.notificationType,
        title: dto.title,
        scheduledFor: normalizedScheduledFor,
        status: In([
          ScheduledNotificationStatus.PENDING,
          ScheduledNotificationStatus.SENT,
        ]) as any,
      },
      select: ['userId'],
    });

    const existingUserIds = new Set(
      existingRows.map((row) => Number(row.userId)),
    );
    const scheduledRows = dedupedUserIds
      .filter((userId) => !existingUserIds.has(userId))
      .map((userId) =>
        this.scheduledRepository.create({
          userId,
          notificationType: dto.notificationType,
          title: dto.title,
          body: dto.body,
          scheduledFor: normalizedScheduledFor,
          status: ScheduledNotificationStatus.PENDING,
          createdBy: createdBy ?? null,
        }),
      );

    if (!scheduledRows.length) {
      return [];
    }

    return this.scheduledRepository.save(scheduledRows, { chunk: 50 });
  }

  async dispatchScheduledNotifications(
    userIds: number[],
    dto: Omit<CreateNotificationDto, 'userId'>,
    scheduledFor: Date,
    createdBy?: number | null,
  ): Promise<number> {
    const scheduledRows = await this.createScheduledNotificationsIfAbsent(
      userIds,
      dto,
      scheduledFor,
      createdBy,
    );

    if (!scheduledRows.length) {
      return 0;
    }

    try {
      await this.createBulkNotifications(
        scheduledRows.map((row) => Number(row.userId)),
        dto,
      );

      await this.scheduledRepository.update(
        { id: In(scheduledRows.map((row) => row.id)) as any },
        {
          status: ScheduledNotificationStatus.SENT,
          sentAt: new Date(),
        } as any,
      );

      return scheduledRows.length;
    } catch (error) {
      await this.scheduledRepository.update(
        { id: In(scheduledRows.map((row) => row.id)) as any },
        { status: ScheduledNotificationStatus.FAILED } as any,
      );
      this.logger.error(
        `Failed to dispatch scheduled notifications "${dto.title}": ${error.message}`,
      );
      throw error;
    }
  }
}
