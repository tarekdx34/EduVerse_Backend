import {
  Controller,
  Get,
  Post,
  Put,
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
import { CommunitiesService } from '../services/communities.service';
import { CommunityPostsService } from '../services/community-posts.service';
import { CommunityTagsService } from '../services/community-tags.service';
import {
  CreateCommunityDto,
  UpdateCommunityDto,
  CommunityQueryDto,
  CreatePostDto,
  PostQueryDto,
  CreateTagDto,
} from '../dto';

@ApiTags('🏘️ Communities')
@ApiBearerAuth('JWT-auth')
@Controller('api/community')
@UseGuards(JwtAuthGuard, RolesGuard)
export class CommunitiesController {
  constructor(
    private readonly communitiesService: CommunitiesService,
    private readonly postsService: CommunityPostsService,
    private readonly tagsService: CommunityTagsService,
  ) {}

  // ============== COMMUNITY CRUD ==============

  @Get('communities')
  @ApiOperation({
    summary: 'List communities',
    description: 'List all communities the user has access to. Global communities are visible to all. Department communities are filtered by enrollment.',
  })
  @ApiResponse({ status: 200, description: 'Paginated list of communities' })
  async findAllCommunities(@Query() query: CommunityQueryDto, @Req() req: any) {
    const userId = req.user.userId || req.user.id;
    const roles = this.extractRoles(req.user);
    return this.communitiesService.findAll(query, userId, roles);
  }

  @Post('communities')
  @HttpCode(HttpStatus.CREATED)
  @Roles(RoleName.ADMIN, RoleName.IT_ADMIN, RoleName.DEPARTMENT_HEAD, RoleName.INSTRUCTOR)
  @ApiOperation({
    summary: 'Create a community',
    description: 'Create a new global or department community. Admin/Instructor/Department Head only.',
  })
  @ApiBody({ type: CreateCommunityDto })
  @ApiResponse({ status: 201, description: 'Community created' })
  async createCommunity(@Body() dto: CreateCommunityDto, @Req() req: any) {
    const userId = req.user.userId || req.user.id;
    return this.communitiesService.create(dto, userId);
  }

  @Get('communities/:communityId')
  @ApiOperation({ summary: 'Get community details' })
  @ApiParam({ name: 'communityId', description: 'Community ID' })
  @ApiResponse({ status: 200, description: 'Community details' })
  async getCommunity(@Param('communityId', ParseIntPipe) communityId: number, @Req() req: any) {
    const userId = req.user.userId || req.user.id;
    const roles = this.extractRoles(req.user);
    return this.communitiesService.checkAccess(communityId, userId, roles);
  }

  @Put('communities/:communityId')
  @Roles(RoleName.ADMIN, RoleName.IT_ADMIN, RoleName.DEPARTMENT_HEAD, RoleName.INSTRUCTOR)
  @ApiOperation({ summary: 'Update a community' })
  @ApiParam({ name: 'communityId', description: 'Community ID' })
  @ApiBody({ type: UpdateCommunityDto })
  async updateCommunity(
    @Param('communityId', ParseIntPipe) communityId: number,
    @Body() dto: UpdateCommunityDto,
    @Req() req: any,
  ) {
    const userId = req.user.userId || req.user.id;
    const roles = this.extractRoles(req.user);
    return this.communitiesService.update(communityId, dto, userId, roles);
  }

  // ============== COMMUNITY POSTS ==============

  @Get('communities/:communityId/posts')
  @ApiOperation({
    summary: 'List posts in a community',
    description: 'Get paginated posts from a specific community. Access is validated.',
  })
  @ApiParam({ name: 'communityId', description: 'Community ID' })
  async getCommunityPosts(
    @Param('communityId', ParseIntPipe) communityId: number,
    @Query() query: PostQueryDto,
    @Req() req: any,
  ) {
    const userId = req.user.userId || req.user.id;
    const roles = this.extractRoles(req.user);
    // Validate access
    await this.communitiesService.checkAccess(communityId, userId, roles);
    // Override communityId in query
    query.communityId = communityId;
    return this.postsService.findAll(query);
  }

  @Post('communities/:communityId/posts')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Create a post in a community',
    description: 'Create a new post in a specific community. Access is validated.',
  })
  @ApiParam({ name: 'communityId', description: 'Community ID' })
  @ApiBody({ type: CreatePostDto })
  async createCommunityPost(
    @Param('communityId', ParseIntPipe) communityId: number,
    @Body() dto: CreatePostDto,
    @Req() req: any,
  ) {
    const userId = req.user.userId || req.user.id;
    const roles = this.extractRoles(req.user);
    // Validate access
    await this.communitiesService.checkAccess(communityId, userId, roles);
    // Override communityId
    dto.communityId = communityId;
    return this.postsService.create(dto, userId);
  }

  // ============== CONVENIENCE ROUTES ==============

  @Get('global')
  @ApiOperation({
    summary: 'Get global community posts',
    description: 'Shortcut to list posts from the global community (community_id = 1).',
  })
  async getGlobalPosts(@Query() query: PostQueryDto) {
    query.communityId = 1; // Global community is always ID 1
    return this.postsService.findAll(query);
  }

  @Post('global/posts')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Create a post in global community',
    description: 'Shortcut to create a post in the global community.',
  })
  @ApiBody({ type: CreatePostDto })
  async createGlobalPost(@Body() dto: CreatePostDto, @Req() req: any) {
    const userId = req.user.userId || req.user.id;
    dto.communityId = 1;
    return this.postsService.create(dto, userId);
  }

  @Get('department/:departmentId')
  @ApiOperation({
    summary: 'List department communities',
    description: 'List all communities for a specific department. Access is validated by enrollment.',
  })
  @ApiParam({ name: 'departmentId', description: 'Department ID' })
  async getDepartmentCommunities(
    @Param('departmentId', ParseIntPipe) departmentId: number,
    @Query() query: CommunityQueryDto,
    @Req() req: any,
  ) {
    const userId = req.user.userId || req.user.id;
    const roles = this.extractRoles(req.user);
    query.departmentId = departmentId;
    return this.communitiesService.findAll(query, userId, roles);
  }

  @Get('my-departments')
  @ApiOperation({
    summary: 'Get my accessible departments',
    description: 'Returns department IDs the user has access to based on enrollment.',
  })
  async getMyDepartments(@Req() req: any) {
    const userId = req.user.userId || req.user.id;
    const departmentIds = await this.communitiesService.getUserDepartmentIds(userId);
    return { departmentIds };
  }

  // ============== TAGS ==============

  @Get('tags')
  @ApiOperation({ summary: 'List all tags' })
  async getAllTags() {
    return this.tagsService.findAll();
  }

  @Post('tags')
  @HttpCode(HttpStatus.CREATED)
  @Roles(RoleName.INSTRUCTOR, RoleName.ADMIN, RoleName.IT_ADMIN, RoleName.TA)
  @ApiOperation({
    summary: 'Create a tag',
    description: 'Create a new tag. Instructor/Admin/TA only.',
  })
  @ApiBody({ type: CreateTagDto })
  async createTag(@Body() dto: CreateTagDto) {
    return this.tagsService.create(dto);
  }

  // ============== HELPER ==============

  private extractRoles(user: any): string[] {
    if (!user.roles) return [];
    return user.roles.map((r: any) => r.roleName || r.name || r);
  }
}
