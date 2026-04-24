import {
  WebSocketGateway,
  WebSocketServer,
  OnGatewayConnection,
  OnGatewayDisconnect,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { Logger, UseGuards } from '@nestjs/common';

@WebSocketGateway({
  cors: {
    origin: '*',
  },
  namespace: '/notifications',
})
export class NotificationsGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  server: Server;

  private readonly logger = new Logger(NotificationsGateway.name);

  // Map to store connected users: userId -> Set of socket IDs
  private connectedUsers = new Map<number, Set<string>>();

  handleConnection(client: Socket) {
    this.logger.debug(`Client connected: ${client.id}`);
    
    // Attempt to extract userId from query params or auth token
    const userId = this.extractUserId(client);
    if (userId) {
      this.addUserConnection(userId, client.id);
      client.join(`user_${userId}`); // Join a room specific to the user
      this.logger.debug(`Client ${client.id} joined user room user_${userId}`);
    } else {
      this.logger.warn(`Client ${client.id} connected without a valid userId`);
    }
  }

  handleDisconnect(client: Socket) {
    this.logger.debug(`Client disconnected: ${client.id}`);
    const userId = this.extractUserId(client);
    if (userId) {
      this.removeUserConnection(userId, client.id);
    }
  }

  private extractUserId(client: Socket): number | null {
    // Basic extraction from handshake query for simplicity.
    // In production, this should decode the JWT from the authorization header or query.
    const userIdQuery = client.handshake.query.userId;
    if (userIdQuery && !Array.isArray(userIdQuery)) {
      return parseInt(userIdQuery, 10);
    }
    return null;
  }

  private addUserConnection(userId: number, socketId: string) {
    if (!this.connectedUsers.has(userId)) {
      this.connectedUsers.set(userId, new Set());
    }
    this.connectedUsers.get(userId)!.add(socketId);
  }

  private removeUserConnection(userId: number, socketId: string) {
    const userSockets = this.connectedUsers.get(userId);
    if (userSockets) {
      userSockets.delete(socketId);
      if (userSockets.size === 0) {
        this.connectedUsers.delete(userId);
      }
    }
  }

  /**
   * Send a notification to a specific user
   */
  sendNotificationToUser(userId: number, notification: any) {
    this.server.to(`user_${userId}`).emit('newNotification', notification);
    this.logger.debug(`Sent realtime notification to user ${userId}`);
  }

  /**
   * Broadcast a badge count update
   */
  sendUnreadCountUpdate(userId: number, count: number) {
    this.server.to(`user_${userId}`).emit('unreadCountUpdate', { count });
    this.logger.debug(`Sent unread count update (${count}) to user ${userId}`);
  }
}
