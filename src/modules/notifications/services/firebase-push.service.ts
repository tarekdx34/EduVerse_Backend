import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as admin from 'firebase-admin';
import { Notification } from '../entities/notification.entity';
import { NotificationDeviceToken } from '../entities/notification-device-token.entity';

interface FirebasePushResult {
  successCount: number;
  failureCount: number;
  invalidTokenHashes: string[];
}

@Injectable()
export class FirebasePushService implements OnModuleInit {
  private readonly logger = new Logger(FirebasePushService.name);
  private app: admin.app.App | null = null;
  private disabledReasonLogged = false;

  constructor(private readonly configService: ConfigService) {}

  onModuleInit(): void {
    this.ensureInitialized();
  }

  isEnabled(): boolean {
    return this.ensureInitialized(false);
  }

  async sendNotification(
    deviceTokens: NotificationDeviceToken[],
    notification: Notification,
    unreadCount?: number,
  ): Promise<FirebasePushResult> {
    if (!deviceTokens.length || !this.ensureInitialized(false) || !this.app) {
      return { successCount: 0, failureCount: 0, invalidTokenHashes: [] };
    }

    const tokenByValue = new Map<string, NotificationDeviceToken>();
    for (const deviceToken of deviceTokens) {
      if (deviceToken.fcmToken && !tokenByValue.has(deviceToken.fcmToken)) {
        tokenByValue.set(deviceToken.fcmToken, deviceToken);
      }
    }

    const tokens = [...tokenByValue.keys()];
    if (!tokens.length) {
      return { successCount: 0, failureCount: 0, invalidTokenHashes: [] };
    }

    const response = await admin.messaging(this.app).sendEachForMulticast({
      tokens,
      data: this.buildDataPayload(notification, unreadCount),
      android: {
        priority: 'high',
        ttl: 7 * 24 * 60 * 60 * 1000,
      },
    });

    const invalidTokenHashes = response.responses
      .map((result, index) => {
        if (!result.error || !this.isInvalidTokenError(result.error.code)) {
          return null;
        }

        return tokenByValue.get(tokens[index])?.tokenHash ?? null;
      })
      .filter((tokenHash): tokenHash is string => Boolean(tokenHash));

    if (response.failureCount > 0) {
      this.logger.warn(
        `Firebase push finished with ${response.successCount} successes and ${response.failureCount} failures`,
      );
    }

    return {
      successCount: response.successCount,
      failureCount: response.failureCount,
      invalidTokenHashes,
    };
  }

  private ensureInitialized(logDisabled = true): boolean {
    if (this.app) {
      return true;
    }

    const existingApp = admin.apps.find(Boolean);
    if (existingApp) {
      this.app = existingApp;
      return true;
    }

    try {
      const credential = this.resolveCredential(logDisabled);
      if (!credential) {
        return false;
      }

      this.app = admin.initializeApp({
        credential,
        projectId:
          this.configService.get<string>('FIREBASE_PROJECT_ID') || undefined,
      });
      this.logger.log(
        'Firebase Admin initialized for Android push notifications',
      );
      return true;
    } catch (error) {
      this.logger.error(
        `Firebase Admin initialization failed: ${(error as Error).message}`,
      );
      return false;
    }
  }

  private resolveCredential(
    logDisabled: boolean,
  ): admin.credential.Credential | null {
    const base64ServiceAccount = this.configService.get<string>(
      'FIREBASE_SERVICE_ACCOUNT_BASE64',
    );
    if (base64ServiceAccount) {
      const serviceAccount = JSON.parse(
        Buffer.from(base64ServiceAccount.replace(/\s/g, ''), 'base64').toString(
          'utf8',
        ),
      ) as admin.ServiceAccount;

      return admin.credential.cert(serviceAccount);
    }

    const jsonServiceAccount = this.configService.get<string>(
      'FIREBASE_SERVICE_ACCOUNT_JSON',
    );
    if (jsonServiceAccount) {
      return admin.credential.cert(
        JSON.parse(jsonServiceAccount) as admin.ServiceAccount,
      );
    }

    if (this.configService.get<string>('GOOGLE_APPLICATION_CREDENTIALS')) {
      return admin.credential.applicationDefault();
    }

    if (logDisabled && !this.disabledReasonLogged) {
      this.disabledReasonLogged = true;
      this.logger.log(
        'Firebase push notifications are disabled. Set FIREBASE_SERVICE_ACCOUNT_BASE64 to enable Android push.',
      );
    }

    return null;
  }

  private buildDataPayload(
    notification: Notification,
    unreadCount?: number,
  ): Record<string, string> {
    const data: Record<string, string> = {
      notificationId: String(notification.id),
      userId: String(notification.userId),
      notificationType: notification.notificationType,
      type: notification.notificationType,
      title: notification.title,
      body: notification.body,
      priority: notification.priority,
      createdAt: notification.createdAt.toISOString(),
    };

    if (notification.actionUrl) {
      data.actionUrl = notification.actionUrl;
    }
    if (notification.relatedEntityType) {
      data.relatedEntityType = notification.relatedEntityType;
    }
    if (notification.relatedEntityId) {
      data.relatedEntityId = String(notification.relatedEntityId);
    }
    if (unreadCount != null) {
      data.unreadCount = String(unreadCount);
    }

    return data;
  }

  private isInvalidTokenError(code: string): boolean {
    return [
      'messaging/invalid-registration-token',
      'messaging/registration-token-not-registered',
      'messaging/mismatched-credential',
    ].includes(code);
  }
}
