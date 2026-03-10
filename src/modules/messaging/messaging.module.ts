import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ConfigModule } from '@nestjs/config';
import { Message } from './entities/message.entity';
import { MessageParticipant } from './entities/message-participant.entity';
import { User } from '../auth/entities/user.entity';
import { MessagingService } from './services/messaging.service';
import { MessagingController } from './controllers/messaging.controller';
import { MessagingGateway } from './gateways/messaging.gateway';

@Module({
  imports: [
    TypeOrmModule.forFeature([Message, MessageParticipant, User]),
    ConfigModule,
  ],
  controllers: [MessagingController],
  providers: [MessagingService, MessagingGateway],
  exports: [MessagingService],
})
export class MessagingModule {}
