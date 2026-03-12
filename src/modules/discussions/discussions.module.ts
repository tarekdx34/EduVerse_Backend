import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { CourseChatThread } from './entities/course-chat-thread.entity';
import { ChatMessage } from './entities/chat-message.entity';
import { DiscussionsService } from './services/discussions.service';
import { DiscussionsController } from './controllers/discussions.controller';

@Module({
  imports: [
    TypeOrmModule.forFeature([CourseChatThread, ChatMessage]),
  ],
  controllers: [DiscussionsController],
  providers: [DiscussionsService],
  exports: [DiscussionsService],
})
export class DiscussionsModule {}
