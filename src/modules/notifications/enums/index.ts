export enum NotificationType {
  ANNOUNCEMENT = 'announcement',
  GRADE = 'grade',
  ASSIGNMENT = 'assignment',
  MESSAGE = 'message',
  DEADLINE = 'deadline',
  SYSTEM = 'system',
  LAB = 'lab',
  QUIZ = 'quiz',
  MATERIAL = 'material',
  COMMUNITY = 'community',
  DISCUSSION = 'discussion',
  ENROLLMENT = 'enrollment',
  SCHEDULE = 'schedule',
  OFFICE_HOURS = 'office_hours',
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
