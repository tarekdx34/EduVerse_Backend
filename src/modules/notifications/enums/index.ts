export enum NotificationType {
  ANNOUNCEMENT = 'announcement',
  GRADE = 'grade',
  ASSIGNMENT = 'assignment',
  MESSAGE = 'message',
  DEADLINE = 'deadline',
  SYSTEM = 'system',
}

export enum NotificationPriority {
  LOW = 'low',
  MEDIUM = 'medium',
  HIGH = 'high',
  URGENT = 'urgent',
}

export enum ScheduledNotificationStatus {
  PENDING = 'pending',
  SENT = 'sent',
  FAILED = 'failed',
  CANCELLED = 'cancelled',
}
