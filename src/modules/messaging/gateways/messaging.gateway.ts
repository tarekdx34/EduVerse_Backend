import {
  WebSocketGateway,
  WebSocketServer,
  SubscribeMessage,
  OnGatewayConnection,
  OnGatewayDisconnect,
  ConnectedSocket,
  MessageBody,
} from '@nestjs/websockets';
import { Logger } from '@nestjs/common';
import { Server, Socket } from 'socket.io';
import { ConfigService } from '@nestjs/config';
import * as jwt from 'jsonwebtoken';
import { MessagingService } from '../services/messaging.service';
import { WsSendMessageDto, WsTypingDto, WsMarkReadDto, WsDeleteMessageDto, WsEditMessageDto } from '../dto';

interface AuthenticatedSocket extends Socket {
  userId?: number;
  userEmail?: string;
}

@WebSocketGateway({
  namespace: '/messaging',
  cors: {
    origin: '*',
    credentials: true,
  },
})
export class MessagingGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  server: Server;

  private readonly logger = new Logger(MessagingGateway.name);
  private jwtSecret: string;

  constructor(
    private readonly messagingService: MessagingService,
    private readonly configService: ConfigService,
  ) {
    this.jwtSecret = this.configService.get<string>('JWT_SECRET') || 'eduverse_jwt_secret_key_2024';
  }

  // ============ CONNECTION LIFECYCLE ============

  async handleConnection(client: AuthenticatedSocket) {
    try {
      const token = client.handshake.query.token as string
        || client.handshake.auth?.token as string;

      if (!token) {
        this.logger.warn(`Client ${client.id} rejected: no token`);
        client.disconnect();
        return;
      }

      const payload = jwt.verify(token, this.jwtSecret) as any;
      client.userId = payload.sub;
      client.userEmail = payload.email;

      // Track online status
      this.messagingService.addOnlineUser(client.userId!, client.id);

      // Join a personal room for direct notifications
      client.join(`user_${client.userId}`);

      // Broadcast online status to all connected clients
      this.server.emit('user_status', {
        userId: client.userId,
        isOnline: true,
        lastSeen: new Date(),
      });

      this.logger.log(`User ${client.userId} connected (socket: ${client.id})`);
    } catch (error) {
      this.logger.warn(`Client ${client.id} rejected: invalid token`);
      client.disconnect();
    }
  }

  async handleDisconnect(client: AuthenticatedSocket) {
    if (client.userId) {
      const wentOffline = this.messagingService.removeOnlineUser(client.userId, client.id);
      if (wentOffline) {
        this.server.emit('user_status', {
          userId: client.userId,
          isOnline: false,
          lastSeen: new Date(),
        });
      }
      this.logger.log(`User ${client.userId} disconnected (socket: ${client.id})`);
    }
  }

  // ============ CONVERSATION ROOMS ============

  @SubscribeMessage('join_conversation')
  async handleJoinConversation(
    @ConnectedSocket() client: AuthenticatedSocket,
    @MessageBody() data: { conversationId: number },
  ) {
    const room = `conversation_${data.conversationId}`;
    client.join(room);
    this.logger.debug(`User ${client.userId} joined ${room}`);
    return { event: 'joined', data: { conversationId: data.conversationId } };
  }

  @SubscribeMessage('leave_conversation')
  async handleLeaveConversation(
    @ConnectedSocket() client: AuthenticatedSocket,
    @MessageBody() data: { conversationId: number },
  ) {
    const room = `conversation_${data.conversationId}`;
    client.leave(room);
    this.logger.debug(`User ${client.userId} left ${room}`);
    return { event: 'left', data: { conversationId: data.conversationId } };
  }

  // ============ SEND MESSAGE (Real-time) ============

  @SubscribeMessage('send_message')
  async handleSendMessage(
    @ConnectedSocket() client: AuthenticatedSocket,
    @MessageBody() data: WsSendMessageDto,
  ) {
    if (!client.userId) return;

    try {
      const message = await this.messagingService.sendMessage(
        data.conversationId,
        client.userId,
        { text: data.text, fileId: data.fileId, replyToId: data.replyToId },
      );

      // Broadcast to conversation room
      const room = `conversation_${data.conversationId}`;
      this.server.to(room).emit('new_message', {
        ...message,
        senderUserId: client.userId,
      });

      // Also notify participants not in the room via their personal rooms
      const participantIds = await this.messagingService.getConversationParticipantIds(data.conversationId);
      for (const uid of participantIds) {
        if (uid !== client.userId) {
          this.server.to(`user_${uid}`).emit('new_message_notification', {
            conversationId: data.conversationId,
            message,
            senderUserId: client.userId,
          });
        }
      }

      return { event: 'message_sent', data: message };
    } catch (error) {
      return { event: 'error', data: { message: error.message } };
    }
  }

  // ============ TYPING INDICATOR ============

  @SubscribeMessage('typing')
  async handleTyping(
    @ConnectedSocket() client: AuthenticatedSocket,
    @MessageBody() data: WsTypingDto,
  ) {
    if (!client.userId) return;

    const room = `conversation_${data.conversationId}`;
    client.to(room).emit('user_typing', {
      conversationId: data.conversationId,
      userId: client.userId,
      isTyping: data.isTyping,
    });
  }

  // ============ MARK READ (Real-time receipts) ============

  @SubscribeMessage('mark_read')
  async handleMarkRead(
    @ConnectedSocket() client: AuthenticatedSocket,
    @MessageBody() data: WsMarkReadDto,
  ) {
    if (!client.userId) return;

    try {
      const result = await this.messagingService.markConversationAsRead(
        data.conversationId,
        client.userId,
      );

      // Broadcast read receipt to conversation room
      const room = `conversation_${data.conversationId}`;
      this.server.to(room).emit('message_read', {
        conversationId: data.conversationId,
        userId: client.userId,
        readAt: new Date(),
        markedRead: result.markedRead,
      });

      return { event: 'read_confirmed', data: result };
    } catch (error) {
      return { event: 'error', data: { message: error.message } };
    }
  }

  // ============ DELETE MESSAGE (Real-time) ============

  @SubscribeMessage('delete_message')
  async handleDeleteMessage(
    @ConnectedSocket() client: AuthenticatedSocket,
    @MessageBody() data: WsDeleteMessageDto,
  ) {
    if (!client.userId) return;

    try {
      let result;
      if (data.forEveryone) {
        result = await this.messagingService.deleteForEveryone(data.messageId, client.userId);
        // Broadcast deletion to all participants
        this.server.emit('message_deleted', {
          messageId: data.messageId,
          deletedForEveryone: true,
          deletedBy: client.userId,
        });
      } else {
        result = await this.messagingService.deleteForMe(data.messageId, client.userId);
      }

      return { event: 'delete_confirmed', data: result };
    } catch (error) {
      return { event: 'error', data: { message: error.message } };
    }
  }

  // ============ EDIT MESSAGE (Real-time) ============

  @SubscribeMessage('edit_message')
  async handleEditMessage(
    @ConnectedSocket() client: AuthenticatedSocket,
    @MessageBody() data: WsEditMessageDto,
  ) {
    if (!client.userId) return;

    try {
      const result = await this.messagingService.editMessage(
        data.messageId,
        client.userId,
        data.text,
      );

      // Broadcast to conversation room
      if (result.conversationId) {
        const room = `conversation_${result.conversationId}`;
        this.server.to(room).emit('message_edited', {
          messageId: result.messageId,
          text: result.text,
          editedAt: result.editedAt,
          editedBy: client.userId,
        });
      }

      return { event: 'edit_confirmed', data: result };
    } catch (error) {
      return { event: 'error', data: { message: error.message } };
    }
  }
}
