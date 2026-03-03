import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ForumCategory } from './entities/forum-category.entity';
import { CommunityPost } from './entities/community-post.entity';
import { CommunityComment } from './entities/community-comment.entity';
import { CommunityReaction } from './entities/community-reaction.entity';
import { CommunityPostsController } from './controllers/community-posts.controller';
import { CommunityCommentsController } from './controllers/community-comments.controller';
import { ForumCategoriesController } from './controllers/forum-categories.controller';
import { CommunityPostsService } from './services/community-posts.service';
import { CommunityCommentsService } from './services/community-comments.service';
import { ForumCategoriesService } from './services/forum-categories.service';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      ForumCategory,
      CommunityPost,
      CommunityComment,
      CommunityReaction,
    ]),
  ],
  controllers: [
    CommunityPostsController,
    CommunityCommentsController,
    ForumCategoriesController,
  ],
  providers: [
    CommunityPostsService,
    CommunityCommentsService,
    ForumCategoriesService,
  ],
  exports: [
    CommunityPostsService,
    CommunityCommentsService,
    ForumCategoriesService,
  ],
})
export class CommunityModule {}
