import {
  Controller,
  Get,
  Post,
  Put,
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
  ApiQuery,
} from '@nestjs/swagger';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../auth/guards/roles.guard';
import { Roles } from '../../auth/roles.decorator';
import { RoleName } from '../../auth/entities/role.entity';
import { CommunityPostsService } from '../services/community-posts.service';
import {
  CreatePostDto,
  UpdatePostDto,
  PostQueryDto,
  CreateCommentDto,
  CreateReactionDto,
} from '../dto';

@ApiTags('🌐 Community Posts')
@ApiBearerAuth('JWT-auth')
@Controller('api/community/posts')
@UseGuards(JwtAuthGuard, RolesGuard)
export class CommunityPostsController {
  constructor(private readonly postsService: CommunityPostsService) {}

  @Get()
  @ApiOperation({
    summary: 'List community posts',
    description: `
List community posts with optional filtering by course, category, and post type.

**Sorting Options**:
- \`recent\`: Most recent posts first (default)
- \`popular\`: Most upvoted posts first
- \`most_comments\`: Posts with most comments first

**Note**: Pinned posts always appear at the top regardless of sort order.
    `,
  })
  @ApiResponse({ status: 200, description: 'Paginated list of posts' })
  async findAll(@Query() query: PostQueryDto) {
    return this.postsService.findAll(query);
  }

  @Post()
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Create a new post',
    description: `
Create a new community post in a course.

**Post Types**:
- \`discussion\`: General discussion topic
- \`question\`: Question seeking answers
- \`announcement\`: Important announcement (different from admin announcements)
- \`resource\`: Shared resource or material
    `,
  })
  @ApiBody({ type: CreatePostDto })
  @ApiResponse({ status: 201, description: 'Post created successfully' })
  async create(@Body() dto: CreatePostDto, @Req() req: any) {
    const userId = req.user.userId || req.user.id;
    return this.postsService.create(dto, userId);
  }

  @Get(':id')
  @ApiOperation({
    summary: 'Get post with comments',
    description: 'Get a single post with paginated comments and reaction summary. Increments view count.',
  })
  @ApiParam({ name: 'id', description: 'Post ID', example: 1 })
  @ApiQuery({ name: 'page', required: false, description: 'Comment page number', example: 1 })
  @ApiQuery({ name: 'limit', required: false, description: 'Comments per page', example: 50 })
  @ApiResponse({ status: 200, description: 'Post with comments and reactions' })
  @ApiResponse({ status: 404, description: 'Post not found' })
  async findOne(
    @Param('id', ParseIntPipe) id: number,
    @Req() req: any,
    @Query('page') page?: number,
    @Query('limit') limit?: number,
  ) {
    const userId = req.user?.userId || req.user?.id;
    return this.postsService.findOne(id, userId, page || 1, limit || 50);
  }

  @Put(':id')
  @ApiOperation({
    summary: 'Update post',
    description: `
Update a community post. 

**Note**: Only the post owner can update their posts.
    `,
  })
  @ApiParam({ name: 'id', description: 'Post ID', example: 1 })
  @ApiBody({ type: UpdatePostDto })
  @ApiResponse({ status: 200, description: 'Post updated successfully' })
  @ApiResponse({ status: 403, description: 'Forbidden - Not the owner' })
  @ApiResponse({ status: 404, description: 'Post not found' })
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdatePostDto,
    @Req() req: any,
  ) {
    const userId = req.user.userId || req.user.id;
    const roles = this.extractRoles(req.user);
    return this.postsService.update(id, dto, userId, roles);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({
    summary: 'Delete post',
    description: `
Delete a community post.

**Allowed**: Post owner or Admin
    `,
  })
  @ApiParam({ name: 'id', description: 'Post ID', example: 1 })
  @ApiResponse({ status: 204, description: 'Post deleted successfully' })
  @ApiResponse({ status: 403, description: 'Forbidden - Not owner or admin' })
  @ApiResponse({ status: 404, description: 'Post not found' })
  async remove(@Param('id', ParseIntPipe) id: number, @Req() req: any) {
    const userId = req.user.userId || req.user.id;
    const roles = this.extractRoles(req.user);
    return this.postsService.remove(id, userId, roles);
  }

  @Post(':id/comment')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Add comment to post',
    description: `
Add a comment to a community post. Supports nested replies via \`parentCommentId\`.

**Note**: Cannot comment on locked posts.
    `,
  })
  @ApiParam({ name: 'id', description: 'Post ID', example: 1 })
  @ApiBody({ type: CreateCommentDto })
  @ApiResponse({ status: 201, description: 'Comment added successfully' })
  @ApiResponse({ status: 400, description: 'Post is locked' })
  @ApiResponse({ status: 404, description: 'Post not found' })
  async addComment(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: CreateCommentDto,
    @Req() req: any,
  ) {
    const userId = req.user.userId || req.user.id;
    return this.postsService.addComment(id, dto, userId);
  }

  @Post(':id/react')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Toggle reaction on post',
    description: `
Add or remove a reaction on a post. If the same reaction type exists, it will be removed (toggle behavior).

**Reaction Types**: like, helpful, insightful, thanks
    `,
  })
  @ApiParam({ name: 'id', description: 'Post ID', example: 1 })
  @ApiBody({ type: CreateReactionDto })
  @ApiResponse({ status: 200, description: 'Reaction toggled. Returns action (added/removed)' })
  @ApiResponse({ status: 404, description: 'Post not found' })
  async toggleReaction(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: CreateReactionDto,
    @Req() req: any,
  ) {
    const userId = req.user.userId || req.user.id;
    return this.postsService.toggleReaction(id, dto, userId);
  }

  @Post(':id/upvote')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Toggle upvote on post',
    description: 'Add or remove an upvote on a post.',
  })
  @ApiParam({ name: 'id', description: 'Post ID', example: 1 })
  @ApiResponse({ status: 200, description: 'Upvote toggled. Returns action (added/removed)' })
  @ApiResponse({ status: 404, description: 'Post not found' })
  async toggleUpvote(
    @Param('id', ParseIntPipe) id: number,
    @Req() req: any,
  ) {
    const userId = req.user.userId || req.user.id;
    return this.postsService.toggleReaction(id, { reactionType: 'upvote' as any }, userId);
  }

  @Patch(':id/pin')
  @Roles(RoleName.INSTRUCTOR, RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'Toggle pin post',
    description: `
Pin or unpin a community post. Pinned posts appear at the top of listings.

**Allowed Roles**: Instructor, Admin
    `,
  })
  @ApiParam({ name: 'id', description: 'Post ID', example: 1 })
  @ApiResponse({ status: 200, description: 'Pin status toggled' })
  @ApiResponse({ status: 403, description: 'Forbidden - Insufficient permissions' })
  @ApiResponse({ status: 404, description: 'Post not found' })
  async togglePin(@Param('id', ParseIntPipe) id: number, @Req() req: any) {
    const userId = req.user.userId || req.user.id;
    const roles = this.extractRoles(req.user);
    return this.postsService.togglePin(id, userId, roles);
  }

  @Patch(':id/lock')
  @Roles(RoleName.INSTRUCTOR, RoleName.ADMIN, RoleName.IT_ADMIN)
  @ApiOperation({
    summary: 'Toggle lock post',
    description: `
Lock or unlock a community post. Locked posts cannot receive new comments.

**Allowed Roles**: Instructor, Admin
    `,
  })
  @ApiParam({ name: 'id', description: 'Post ID', example: 1 })
  @ApiResponse({ status: 200, description: 'Lock status toggled' })
  @ApiResponse({ status: 403, description: 'Forbidden - Insufficient permissions' })
  @ApiResponse({ status: 404, description: 'Post not found' })
  async toggleLock(@Param('id', ParseIntPipe) id: number, @Req() req: any) {
    const userId = req.user.userId || req.user.id;
    const roles = this.extractRoles(req.user);
    return this.postsService.toggleLock(id, userId, roles);
  }

  /**
   * Helper to extract role names from user object
   */
  private extractRoles(user: any): string[] {
    if (!user.roles) return [];
    return user.roles.map((r: any) => r.roleName || r.name || r);
  }
}
