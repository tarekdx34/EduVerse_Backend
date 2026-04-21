import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ForumCategory } from './entities/forum-category.entity';
import { CommunityPost } from './entities/community-post.entity';
import { CommunityComment } from './entities/community-comment.entity';
import { CommunityReaction } from './entities/community-reaction.entity';
import { Community } from './entities/community.entity';
import { CommunityTag } from './entities/community-tag.entity';
import { CommunityPostView } from './entities/community-post-view.entity';
import { CommunityPostsController } from './controllers/community-posts.controller';
import { CommunityCommentsController } from './controllers/community-comments.controller';
import { ForumCategoriesController } from './controllers/forum-categories.controller';
import { CommunitiesController } from './controllers/communities.controller';
import { CommunityPostsService } from './services/community-posts.service';
import { CommunityCommentsService } from './services/community-comments.service';
import { ForumCategoriesService } from './services/forum-categories.service';
import { CommunitiesService } from './services/communities.service';
import { CommunityTagsService } from './services/community-tags.service';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      ForumCategory,
      CommunityPost,
      CommunityComment,
      CommunityReaction,
      Community,
      CommunityTag,
      CommunityPostView,
    ]),
  ],
  controllers: [
    CommunitiesController,
    CommunityPostsController,
    CommunityCommentsController,
    ForumCategoriesController,
  ],
  providers: [
    CommunitiesService,
    CommunityTagsService,
    CommunityPostsService,
    CommunityCommentsService,
    ForumCategoriesService,
  ],
  exports: [
    CommunitiesService,
    CommunityTagsService,
    CommunityPostsService,
    CommunityCommentsService,
    ForumCategoriesService,
  ],
})
export class CommunityModule {}
