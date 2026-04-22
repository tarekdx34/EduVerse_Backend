import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Patch,
  Body,
  Param,
  Query,
  Req,
  UseGuards,
  ParseIntPipe,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiParam,
  ApiBody,
  ApiResponse,
  ApiBearerAuth,
} from '@nestjs/swagger';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../auth/guards/roles.guard';
import { Roles } from '../../auth/roles.decorator';
import { RoleName } from '../../auth/entities/role.entity';
import { NotificationsService } from '../services/notifications.service';
import {
  SendNotificationDto,
  NotificationQueryDto,
  UpdatePreferencesDto,
} from '../dto';

@ApiTags('Notifications')
@ApiBearerAuth('JWT-auth')
@Controller('api/notifications')
@UseGuards(JwtAuthGuard, RolesGuard)
export class NotificationsController {
  constructor(private readonly notificationsService: NotificationsService) {}

  // ============ NOTIFICATIONS ============

  @Get()
  @ApiOperation({
    summary: 'List notifications',
    description: 'List current user\'s notifications with optional filters. Supports pagination.',
  })
  @ApiResponse({ status: 200, description: 'Notifications retrieved' })
  async findAll(@Query() query: NotificationQueryDto, @Req() req: any) {
    const userId = req.user.userId || req.user.id;
    return this.notificationsService.findAll(userId, query);
  }

  @Get('unread-count')
  @ApiOperation({
    summary: 'Get unread count',
    description: 'Get the count of unread notifications for the current user.',
  })
  @ApiResponse({ status: 200, description: 'Unread count', schema: { example: { count: 5 } } })
  async getUnreadCount(@Req() req: any) {
    const userId = req.user.userId || req.user.id;
    return this.notificationsService.getUnreadCount(userId);
  }

  @Patch('read-all')
  @ApiOperation({
    summary: 'Mark all as read',
    description: 'Mark all of the current user\'s notifications as read.',
  })
  @ApiResponse({ status: 200, description: 'All notifications marked as read', schema: { example: { affected: 10 } } })
  async markAllAsRead(@Req() req: any) {
    const userId = req.user.userId || req.user.id;
    return this.notificationsService.markAllAsRead(userId);
  }

  @Delete('clear-all')
  @ApiOperation({
    summary: 'Clear all notifications',
    description: 'Delete all notifications for the current user.',
  })
  @ApiResponse({ status: 200, description: 'All notifications cleared', schema: { example: { affected: 10 } } })
  async clearAll(@Req() req: any) {
    const userId = req.user.userId || req.user.id;
    return this.notificationsService.clearAll(userId);
  }

  @Delete('clear-read')
  @ApiOperation({
    summary: 'Clear read notifications',
    description: 'Delete all read notifications for the current user.',
  })
  @ApiResponse({ status: 200, description: 'Read notifications cleared', schema: { example: { affected: 10 } } })
  async clearRead(@Req() req: any) {
    const userId = req.user.userId || req.user.id;
    return this.notificationsService.clearRead(userId);
  }

  @Get('preferences')
  @ApiOperation({
    summary: 'Get notification preferences',
    description: 'Get the current user\'s notification preferences. Creates default preferences if none exist.',
  })
  @ApiResponse({ status: 200, description: 'Preferences retrieved' })
  async getPreferences(@Req() req: any) {
    const userId = req.user.userId || req.user.id;
    return this.notificationsService.getPreferences(userId);
  }

  @Put('preferences')
  @ApiOperation({
    summary: 'Update notification preferences',
    description: 'Update the current user\'s notification preferences (email, push, quiet hours, etc.).',
  })
  @ApiBody({ type: UpdatePreferencesDto })
  @ApiResponse({ status: 200, description: 'Preferences updated' })
  async updatePreferences(@Body() dto: UpdatePreferencesDto, @Req() req: any) {
    const userId = req.user.userId || req.user.id;
    return this.notificationsService.updatePreferences(userId, dto);
  }

  @Patch(':id/read')
  @ApiOperation({
    summary: 'Mark notification as read',
    description: 'Mark a single notification as read.',
  })
  @ApiParam({ name: 'id', description: 'Notification ID', example: 1 })
  @ApiResponse({ status: 200, description: 'Notification marked as read' })
  @ApiResponse({ status: 404, description: 'Notification not found' })
  async markAsRead(@Param('id', ParseIntPipe) id: number, @Req() req: any) {
    const userId = req.user.userId || req.user.id;
    return this.notificationsService.markAsRead(userId, id);
  }

  @Delete(':id')
  @ApiOperation({
    summary: 'Delete notification',
    description: 'Delete a single notification.',
  })
  @ApiParam({ name: 'id', description: 'Notification ID', example: 1 })
  @ApiResponse({ status: 200, description: 'Notification deleted' })
  @ApiResponse({ status: 404, description: 'Notification not found' })
  async delete(@Param('id', ParseIntPipe) id: number, @Req() req: any) {
    const userId = req.user.userId || req.user.id;
    return this.notificationsService.delete(userId, id);
  }

  // ============ SEND (Admin Only) ============

  @Post('send')
  @Roles(RoleName.ADMIN, RoleName.IT_ADMIN)
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Send notification (Admin)',
    description: 'Send a notification to one or more users. Requires ADMIN or IT_ADMIN role.',
  })
  @ApiBody({ type: SendNotificationDto })
  @ApiResponse({ status: 201, description: 'Notifications sent' })
  @ApiResponse({ status: 403, description: 'Forbidden - Admin access required' })
  async send(@Body() dto: SendNotificationDto) {
    return this.notificationsService.send(dto);
  }
}
