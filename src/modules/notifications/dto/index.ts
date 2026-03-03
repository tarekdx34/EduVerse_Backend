import { IsString, IsOptional, IsInt, IsEnum, IsBoolean, IsDateString, Min, Max } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { NotificationType, NotificationPriority } from '../enums';

export class CreateNotificationDto {
  @ApiProperty({ example: 57, description: 'Target user ID' })
  @IsInt()
  userId: number;

  @ApiProperty({ example: 'assignment', enum: NotificationType, description: 'Notification type' })
  @IsEnum(NotificationType)
  notificationType: NotificationType;

  @ApiProperty({ example: 'New Assignment Posted', description: 'Notification title' })
  @IsString()
  title: string;

  @ApiProperty({ example: 'A new assignment has been posted in CS101', description: 'Notification body' })
  @IsString()
  body: string;

  @ApiPropertyOptional({ example: 'assignment', description: 'Related entity type' })
  @IsOptional()
  @IsString()
  relatedEntityType?: string;

  @ApiPropertyOptional({ example: 3, description: 'Related entity ID' })
  @IsOptional()
  @IsInt()
  relatedEntityId?: number;

  @ApiPropertyOptional({ example: 'medium', enum: NotificationPriority, description: 'Priority level' })
  @IsOptional()
  @IsEnum(NotificationPriority)
  priority?: NotificationPriority;

  @ApiPropertyOptional({ example: '/assignments/3', description: 'Action URL for frontend routing' })
  @IsOptional()
  @IsString()
  actionUrl?: string;
}

export class SendNotificationDto {
  @ApiProperty({ example: [57, 58, 59], description: 'Target user IDs' })
  @IsInt({ each: true })
  userIds: number[];

  @ApiProperty({ example: 'system', enum: NotificationType, description: 'Notification type' })
  @IsEnum(NotificationType)
  notificationType: NotificationType;

  @ApiProperty({ example: 'System Maintenance', description: 'Notification title' })
  @IsString()
  title: string;

  @ApiProperty({ example: 'System will be down for maintenance on Sunday', description: 'Body' })
  @IsString()
  body: string;

  @ApiPropertyOptional({ example: 'high', enum: NotificationPriority })
  @IsOptional()
  @IsEnum(NotificationPriority)
  priority?: NotificationPriority;

  @ApiPropertyOptional({ example: '/system/maintenance', description: 'Action URL' })
  @IsOptional()
  @IsString()
  actionUrl?: string;
}

export class NotificationQueryDto {
  @ApiPropertyOptional({ example: 'assignment', enum: NotificationType, description: 'Filter by type' })
  @IsOptional()
  @IsEnum(NotificationType)
  type?: NotificationType;

  @ApiPropertyOptional({ example: 'high', enum: NotificationPriority, description: 'Filter by priority' })
  @IsOptional()
  @IsEnum(NotificationPriority)
  priority?: NotificationPriority;

  @ApiPropertyOptional({ example: false, description: 'Filter by read status' })
  @IsOptional()
  @Type(() => Boolean)
  @IsBoolean()
  isRead?: boolean;

  @ApiPropertyOptional({ example: 1, description: 'Page number' })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page?: number = 1;

  @ApiPropertyOptional({ example: 20, description: 'Items per page' })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  limit?: number = 20;
}

export class UpdatePreferencesDto {
  @ApiPropertyOptional({ example: true, description: 'Enable email notifications' })
  @IsOptional()
  @IsBoolean()
  emailEnabled?: boolean;

  @ApiPropertyOptional({ example: true, description: 'Enable push notifications' })
  @IsOptional()
  @IsBoolean()
  pushEnabled?: boolean;

  @ApiPropertyOptional({ example: false, description: 'Enable SMS notifications' })
  @IsOptional()
  @IsBoolean()
  smsEnabled?: boolean;

  @ApiPropertyOptional({ example: true, description: 'Email for announcements' })
  @IsOptional()
  @IsBoolean()
  announcementEmail?: boolean;

  @ApiPropertyOptional({ example: true, description: 'Email for grades' })
  @IsOptional()
  @IsBoolean()
  gradeEmail?: boolean;

  @ApiPropertyOptional({ example: true, description: 'Email for assignments' })
  @IsOptional()
  @IsBoolean()
  assignmentEmail?: boolean;

  @ApiPropertyOptional({ example: true, description: 'Email for messages' })
  @IsOptional()
  @IsBoolean()
  messageEmail?: boolean;

  @ApiPropertyOptional({ example: 2, description: 'Days before deadline to send reminder' })
  @IsOptional()
  @IsInt()
  @Min(0)
  @Max(30)
  deadlineReminderDays?: number;

  @ApiPropertyOptional({ example: '22:00:00', description: 'Quiet hours start (HH:mm:ss)' })
  @IsOptional()
  @IsString()
  quietHoursStart?: string;

  @ApiPropertyOptional({ example: '07:00:00', description: 'Quiet hours end (HH:mm:ss)' })
  @IsOptional()
  @IsString()
  quietHoursEnd?: string;
}
