import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
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
import { MessagingService } from '../services/messaging.service';
import {
  StartConversationDto,
  SendMessageDto,
  MessageQueryDto,
  SearchMessagesDto,
  EditMessageDto,
  SearchUsersDto,
} from '../dto';

@ApiTags('💬 Messaging')
@ApiBearerAuth('JWT-auth')
@Controller('api/messages')
@UseGuards(JwtAuthGuard, RolesGuard)
export class MessagingController {
  constructor(private readonly messagingService: MessagingService) {}

  @Get('users/search')
  @ApiOperation({
    summary: 'Search users',
    description: 'Search for users by name or email. Available to all authenticated users. Useful for starting new conversations.',
  })
  @ApiResponse({ status: 200, description: 'Matching users' })
  async searchUsers(@Query() dto: SearchUsersDto) {
    return this.messagingService.searchUsers(dto.query, dto.limit);
  }

  @Get('conversations')
  @ApiOperation({
    summary: 'List conversations',
    description: 'List all conversations for the current user. Returns last message, unread count, and participants for each conversation.',
  })
  @ApiResponse({ status: 200, description: 'Conversations retrieved' })
  async listConversations(@Req() req: any) {
    const userId = req.user.userId || req.user.id;
    return this.messagingService.listConversations(userId);
  }

  @Post('conversations')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Start new conversation',
    description: 'Start a new direct or group conversation. For direct messages, if a conversation already exists with the same user, the message is sent there instead.',
  })
  @ApiBody({ type: StartConversationDto })
  @ApiResponse({ status: 201, description: 'Conversation created or message sent to existing' })
  async startConversation(@Body() dto: StartConversationDto, @Req() req: any) {
    const userId = req.user.userId || req.user.id;
    return this.messagingService.startConversation(userId, dto);
  }

  @Get('conversations/:id')
  @ApiOperation({
    summary: 'Get conversation messages',
    description: 'Get paginated messages in a conversation. Messages deleted for the current user are excluded. Deleted-for-everyone messages show "This message was deleted".',
  })
  @ApiParam({ name: 'id', description: 'Conversation (root message) ID', example: 1 })
  @ApiResponse({ status: 200, description: 'Messages retrieved' })
  async getConversationMessages(
    @Param('id', ParseIntPipe) id: number,
    @Query() query: MessageQueryDto,
    @Req() req: any,
  ) {
    const userId = req.user.userId || req.user.id;
    return this.messagingService.getConversationMessages(id, userId, query);
  }

  @Post('conversations/:id')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Send message in conversation',
    description: 'Send a message in an existing conversation. Supports text and optional file attachment. Message is delivered in real-time via WebSocket to all participants.',
  })
  @ApiParam({ name: 'id', description: 'Conversation ID', example: 1 })
  @ApiBody({ type: SendMessageDto })
  @ApiResponse({ status: 201, description: 'Message sent' })
  async sendMessage(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: SendMessageDto,
    @Req() req: any,
  ) {
    const userId = req.user.userId || req.user.id;
    return this.messagingService.sendMessage(id, userId, dto);
  }

  @Patch(':id')
  @ApiOperation({
    summary: 'Edit message',
    description: 'Edit the text of a message. Only the original sender can edit. Updates the editedAt timestamp.',
  })
  @ApiParam({ name: 'id', description: 'Message ID', example: 1 })
  @ApiBody({ type: EditMessageDto })
  @ApiResponse({ status: 200, description: 'Message edited' })
  @ApiResponse({ status: 403, description: 'Only the sender can edit' })
  async editMessage(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: EditMessageDto,
    @Req() req: any,
  ) {
    const userId = req.user.userId || req.user.id;
    return this.messagingService.editMessage(id, userId, dto.text);
  }

  @Patch(':id/read')
  @ApiOperation({
    summary: 'Mark message as read',
    description: 'Mark a single message as read. Updates the read receipt timestamp.',
  })
  @ApiParam({ name: 'id', description: 'Message ID', example: 1 })
  @ApiResponse({ status: 200, description: 'Message marked as read' })
  async markAsRead(@Param('id', ParseIntPipe) id: number, @Req() req: any) {
    const userId = req.user.userId || req.user.id;
    return this.messagingService.markAsRead(id, userId);
  }

  @Delete(':id')
  @ApiOperation({
    summary: 'Delete message for me',
    description: 'Soft-delete a message for the current user only. Other participants can still see it.',
  })
  @ApiParam({ name: 'id', description: 'Message ID', example: 1 })
  @ApiResponse({ status: 200, description: 'Message deleted for you' })
  async deleteForMe(@Param('id', ParseIntPipe) id: number, @Req() req: any) {
    const userId = req.user.userId || req.user.id;
    return this.messagingService.deleteForMe(id, userId);
  }

  @Delete(':id/everyone')
  @ApiOperation({
    summary: 'Delete message for everyone',
    description: 'Delete a message for all participants (WhatsApp-style). Only the original sender can do this. Shows "This message was deleted" for all.',
  })
  @ApiParam({ name: 'id', description: 'Message ID', example: 1 })
  @ApiResponse({ status: 200, description: 'Message deleted for everyone' })
  @ApiResponse({ status: 403, description: 'Only the sender can delete for everyone' })
  async deleteForEveryone(@Param('id', ParseIntPipe) id: number, @Req() req: any) {
    const userId = req.user.userId || req.user.id;
    return this.messagingService.deleteForEveryone(id, userId);
  }

  @Get('unread-count')
  @ApiOperation({
    summary: 'Get unread message count',
    description: 'Get total count of unread messages across all conversations.',
  })
  @ApiResponse({ status: 200, description: 'Unread count', schema: { example: { count: 5 } } })
  async getUnreadCount(@Req() req: any) {
    const userId = req.user.userId || req.user.id;
    return this.messagingService.getUnreadCount(userId);
  }

  @Get('search')
  @ApiOperation({
    summary: 'Search messages',
    description: 'Search through all messages the user has access to. Returns matching messages with conversation context.',
  })
  @ApiResponse({ status: 200, description: 'Search results' })
  async searchMessages(@Query() dto: SearchMessagesDto, @Req() req: any) {
    const userId = req.user.userId || req.user.id;
    return this.messagingService.searchMessages(userId, dto);
  }

  @Get('online-users')
  @ApiOperation({
    summary: 'Get online users',
    description: 'Get list of currently online user IDs (connected via WebSocket).',
  })
  @ApiResponse({ status: 200, description: 'Online user IDs', schema: { example: { onlineUserIds: [57, 58] } } })
  async getOnlineUsers() {
    return { onlineUserIds: this.messagingService.getOnlineUserIds() };
  }
}
