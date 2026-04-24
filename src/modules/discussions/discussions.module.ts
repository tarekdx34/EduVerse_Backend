import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { CourseChatThread } from './entities/course-chat-thread.entity';
import { ChatMessage } from './entities/chat-message.entity';
import { CourseChatThreadView } from './entities/course-chat-thread-view.entity';
import { ChatMessageUpvote } from './entities/chat-message-upvote.entity';
import { NotificationsModule } from '../notifications/notifications.module';
import { DiscussionsService } from './services/discussions.service';
import { DiscussionsController } from './controllers/discussions.controller';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      CourseChatThread,
      ChatMessage,
      CourseChatThreadView,
      ChatMessageUpvote,
    ]),
    NotificationsModule,
  ],
  controllers: [DiscussionsController],
  providers: [DiscussionsService],
  exports: [DiscussionsService],
})
export class DiscussionsModule {}
